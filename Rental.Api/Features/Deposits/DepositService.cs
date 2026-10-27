using Microsoft.EntityFrameworkCore;
using Rental.Api.Data;
using Rental.Api.Domain;
using Rental.Api.Features.Common;
using static Rental.Api.Features.Common.BusinessRules;

namespace Rental.Api.Features.Deposits;
/// <summary>Sổ nhận và số dư tiền cọc; thao tác ghi dùng giao dịch chung của endpoint filter.</summary>
public sealed class DepositService(RentalDb database, IHttpContextAccessor accessor) : FeatureService(database, accessor)
{
    public async Task<long> DepositBalance(int contractId)
    {
        var entries = await db.DepositEntries.Where(x => x.ContractId == contractId).ToListAsync();
        return entries.Sum(x => x.Type == "Received" ? x.Amount : -x.Amount);
    }

    public async Task ReceiveDeposit(int id, DepositRequest r)
    {
        var contract = await Contract(id);
        Money(r.Amount);
        Require(r.Amount > 0 && contract.Status == "Active", "Số tiền phải dương và hợp đồng còn hoạt động.");
        var received = await db.DepositEntries.Where(x => x.ContractId == id && x.Type == "Received").SumAsync(x => x.Amount);
        Require(received + r.Amount <= contract.Deposit, "Tổng cọc nhận vượt cọc thỏa thuận.");
        db.DepositEntries.Add(new DepositEntry { ContractId = id, Amount = r.Amount, Type = "Received", Note = Text(r.Note, "Ghi chú", 500, false) });
        await Save("deposit.receive", $"Hợp đồng #{id}, số tiền {r.Amount}");
    }
}
