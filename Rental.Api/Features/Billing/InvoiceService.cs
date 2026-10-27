using Microsoft.EntityFrameworkCore;
using Rental.Api.Data;
using Rental.Api.Domain;
using Rental.Api.Features.Common;
using static Rental.Api.Features.Common.BusinessRules;
using static Rental.Api.Features.Billing.BillingRules;

namespace Rental.Api.Features.Billing;
/// <summary>Hóa đơn và chi tiết khoản thu; thao tác ghi dùng giao dịch chung của endpoint filter.</summary>
public sealed class InvoiceService(RentalDb database, IHttpContextAccessor accessor) : FeatureService(database, accessor)
{
    public async Task<object> GenerateInvoice(InvoiceRequest r)
    {
        var contract = await Contract(r.ContractId);
        var period = Period(r.Year, r.Month);
        CheckPeriod(contract, period);
        Require(r.DueDate >= period && r.DueDate.Year <= 2100, "Hạn thanh toán không được trước kỳ thu.");
        Require(!await db.Invoices.AnyAsync(x => x.ContractId == r.ContractId && x.Year == r.Year && x.Month == r.Month && x.Status == "Issued"), "Kỳ này đã có hóa đơn.");
        var room = await Room(contract.RoomId);
        var fees = await db.Fees.Where(x => x.BranchId == room.BranchId && !x.IsArchived).ToListAsync();
        var reading = await db.Readings.SingleOrDefaultAsync(x => x.ContractId == r.ContractId && x.Year == r.Year && x.Month == r.Month);
        Require(reading != null || fees.All(x => x.Method != "Electricity" && x.Method != "Water"), "Cần chốt chỉ số điện/nước trước khi lập hóa đơn.");
        var occupants = await db.ContractTenants.CountAsync(x => x.ContractId == contract.Id);
        var invoice = new Invoice
        {
            ContractId = contract.Id,
            Year = r.Year,
            Month = r.Month,
            DueDate = r.DueDate
        };
        invoice.Items.Add(new InvoiceItem { Description = "Tiền thuê phòng (đủ tháng)", Quantity = 1, UnitPrice = contract.Rent, Amount = contract.Rent });
        foreach (var fee in fees)
        {
            var quantity = fee.Method switch
            {
                "Electricity" => reading!.ElectricityNew - reading.ElectricityOld,
                "Water" => reading!.WaterNew - reading.WaterOld,
                "PerPerson" => occupants,
                _ => 1m
            };
            var description = fee.Name + (fee.Method == "Electricity" ? $" ({reading!.ElectricityOld} → {reading.ElectricityNew})" : fee.Method == "Water" ? $" ({reading!.WaterOld} → {reading.WaterNew})" : "");
            invoice.Items.Add(new InvoiceItem { Description = description, Quantity = quantity, UnitPrice = fee.UnitPrice, Amount = checked((long)decimal.Round(quantity * fee.UnitPrice, 0, MidpointRounding.AwayFromZero)) });
        }

        invoice.Total = invoice.Items.Sum(x => x.Amount);
        db.Invoices.Add(invoice);
        await Save("invoice.create", $"Hợp đồng #{contract.Id}, kỳ {r.Month}/{r.Year}, tổng {invoice.Total}");
        return invoice;
    }

    public async Task CancelInvoice(int id, CancelInvoiceRequest r)
    {
        OwnerOnly();
        var invoice = await Invoice(id);
        Require(invoice.Status == "Issued" && !await db.Payments.AnyAsync(x => x.InvoiceId == id), "Chỉ hủy hóa đơn chưa có thanh toán.");
        var contract = await Contract(invoice.ContractId);
        Require(contract.Status == "Active", "Không hủy hóa đơn của hợp đồng đã quyết toán.");
        invoice.CancellationReason = Text(r.Reason, "Lý do hủy", 1000);
        invoice.Status = "Cancelled";
        await Save("invoice.cancel", $"Hóa đơn #{id}: {invoice.CancellationReason}");
    }

    public async Task<object> InvoiceDetail(int id)
    {
        var invoice = await Invoice(id);
        var contract = await Contract(invoice.ContractId);
        var room = await Room(contract.RoomId);
        var branch = await db.Branches.FindAsync(room.BranchId);
        var representativeId = await db.ContractTenants.Where(x => x.ContractId == contract.Id && x.IsRepresentative).Select(x => x.TenantId).SingleAsync();
        var tenant = await db.Tenants.FindAsync(representativeId);
        var paid = await db.Payments.Where(x => x.InvoiceId == id).SumAsync(x => x.Amount);
        return new
        {
            Invoice = invoice,
            Room = room.Name,
            Branch = branch!.Name,
            branch.Address,
            Tenant = tenant!.FullName,
            Paid = paid,
            Outstanding = invoice.Total - paid
        };
    }
}
