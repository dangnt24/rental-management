using Microsoft.EntityFrameworkCore;
using Rental.Api.Data;
using Rental.Api.Domain;
using Rental.Api.Features.Common;
using static Rental.Api.Features.Common.BusinessRules;
using Rental.Api.Features.Deposits;

namespace Rental.Api.Features.Contracts;
/// <summary>Hợp đồng, gia hạn và trả phòng; thao tác ghi dùng giao dịch chung của endpoint filter.</summary>
public sealed class ContractService(RentalDb database, IHttpContextAccessor accessor, DepositService deposits) : FeatureService(database, accessor)
{
    public async Task<object> CreateContract(ContractRequest r)
    {
        var room = await Room(r.RoomId);
        Require(!room.IsArchived && !room.IsMaintenance, "Phòng đã ngừng sử dụng hoặc đang sửa.");
        Money(r.Rent);
        Money(r.Deposit);
        Money(r.DepositReceived);
        Require(r.EndDate >= r.StartDate && r.StartDate <= Today && r.StartDate.Year >= 2000 && r.EndDate.Year <= 2100, "Ngày hợp đồng không hợp lệ; bản đầu chỉ tạo hợp đồng đã bắt đầu.");
        Require(r.DepositReceived <= r.Deposit, "Tiền cọc đã nhận vượt mức cọc thỏa thuận.");
        Require(!await db.Contracts.AnyAsync(x => x.RoomId == r.RoomId && x.Status == "Active"), "Phòng đã có hợp đồng đang hoạt động.");
        Require(!await db.Contracts.AnyAsync(x => x.RoomId == r.RoomId && x.StartDate <= r.EndDate && (x.ClosedDate ?? x.EndDate) >= r.StartDate), "Khoảng thời gian hợp đồng trùng lịch sử thuê phòng.");
        var tenantIds = r.TenantIds?.Distinct().ToArray() ?? [];
        Require(tenantIds.Length > 0 && tenantIds.Length <= room.Capacity && tenantIds.Contains(r.RepresentativeId), "Cần người đại diện thuộc danh sách người ở và không vượt sức chứa.");
        Require(await db.Tenants.CountAsync(x => tenantIds.Contains(x.Id) && x.BranchId == room.BranchId && !x.IsArchived) == tenantIds.Length, "Người thuê phải thuộc cùng khu trọ.");
        var occupied = await (
            from ct in db.ContractTenants
            join c in db.Contracts on ct.ContractId equals c.Id
            where tenantIds.Contains(ct.TenantId) && c.Status == "Active"
            select ct.TenantId).AnyAsync();
        Require(!occupied, "Có người thuê đang thuộc hợp đồng khác; cần kết thúc hợp đồng trước.");
        var contract = new Contract
        {
            RoomId = r.RoomId,
            StartDate = r.StartDate,
            EndDate = r.EndDate,
            Rent = r.Rent,
            Deposit = r.Deposit,
            Note = Text(r.Note, "Ghi chú", 2000, false),
            CreatedBy = Actor
        };
        db.Contracts.Add(contract);
        await db.SaveChangesAsync();
        db.ContractTenants.AddRange(tenantIds.Select(x => new ContractTenant { ContractId = contract.Id, TenantId = x, IsRepresentative = x == r.RepresentativeId }));
        if (r.DepositReceived > 0)
            db.DepositEntries.Add(new DepositEntry { ContractId = contract.Id, Type = "Received", Amount = r.DepositReceived, Note = "Nhận cọc khi lập hợp đồng" });
        await Save("contract.create", $"Hợp đồng #{contract.Id}");
        return contract;
    }

    public async Task RenewContract(int id, RenewContractRequest r)
    {
        var contract = await Contract(id);
        Money(r.Rent);
        Require(contract.Status == "Active" && r.EndDate > contract.EndDate && r.EndDate.Year <= 2100, "Chỉ gia hạn hợp đồng đang thuê với ngày kết thúc mới lớn hơn ngày cũ.");
        Require(!await db.Invoices.AnyAsync(x => x.ContractId == id && x.Status == "Issued" && (x.Year > Today.Year || x.Year == Today.Year && x.Month > Today.Month)), "Đã có hóa đơn kỳ tương lai; cần đối soát trước khi đổi giá.");
        var previous = $"Đến {contract.EndDate}, giá {contract.Rent}";
        contract.EndDate = r.EndDate;
        contract.Rent = r.Rent;
        await Save("contract.renew", $"Hợp đồng #{id}: {previous}; mới đến {r.EndDate}, giá {r.Rent}");
    }

    public async Task CloseContract(int id, CloseContractRequest r)
    {
        var contract = await Contract(id);
        Money(r.Deduction);
        Require(contract.Status == "Active" && r.ClosedDate >= contract.StartDate && r.ClosedDate <= Today, "Ngày trả phòng hoặc trạng thái hợp đồng không hợp lệ.");
        var invoices = await db.Invoices.Where(x => x.ContractId == id && x.Status == "Issued").ToListAsync();
        var invoiceIds = invoices.Select(x => x.Id).ToArray();
        var payments = await db.Payments.Where(x => invoiceIds.Contains(x.InvoiceId)).ToListAsync();
        Require(invoices.All(x => x.Total == payments.Where(p => p.InvoiceId == x.Id).Sum(p => p.Amount)), "Còn công nợ; hãy thu tiền hoặc dùng cọc để thanh toán trước khi trả phòng.");
        Require(invoices.All(x => new DateOnly(x.Year, x.Month, 1) <= r.ClosedDate), "Có hóa đơn sau ngày trả phòng; cần hủy trước.");
        var lastPeriod = new DateOnly(r.ClosedDate.Year, r.ClosedDate.Month, 1);
        for (var period = new DateOnly(contract.StartDate.Year, contract.StartDate.Month, 1); period <= lastPeriod; period = period.AddMonths(1))
            Require(invoices.Any(x => x.Year == period.Year && x.Month == period.Month), $"Còn thiếu hóa đơn kỳ {period.Month}/{period.Year}; cần lập và thanh toán trước khi quyết toán.");
        var balance = await deposits.DepositBalance(id);
        Require(r.Deduction <= balance, "Khoản khấu trừ vượt cọc còn giữ.");
        var note = Text(r.Note, "Lý do quyết toán", 1000);
        if (r.Deduction > 0)
            db.DepositEntries.Add(new DepositEntry { ContractId = id, Amount = r.Deduction, Type = "Deducted", Note = note });
        if (balance - r.Deduction > 0)
            db.DepositEntries.Add(new DepositEntry { ContractId = id, Amount = balance - r.Deduction, Type = "Refunded", Note = note });
        contract.Status = "Closed";
        contract.ClosedDate = r.ClosedDate;
        await Save("contract.close", $"Hợp đồng #{id}, khấu trừ {r.Deduction}, hoàn cọc {balance - r.Deduction}. {note}");
    }
}
