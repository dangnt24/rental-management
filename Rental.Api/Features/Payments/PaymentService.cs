using Microsoft.EntityFrameworkCore;
using Rental.Api.Data;
using Rental.Api.Domain;
using Rental.Api.Features.Common;
using static Rental.Api.Features.Common.BusinessRules;
using Rental.Api.Features.Deposits;

namespace Rental.Api.Features.Payments;
/// <summary>Thu tiền và bù trừ công nợ; thao tác ghi dùng giao dịch chung của endpoint filter.</summary>
public sealed class PaymentService(RentalDb database, IHttpContextAccessor accessor, DepositService deposits) : FeatureService(database, accessor)
{
    public async Task<object> RecordPayment(PaymentRequest r)
    {
        var invoice = await Invoice(r.InvoiceId);
        Money(r.Amount);
        Require(invoice.Status == "Issued", "Hóa đơn đã hủy.");
        var paid = await db.Payments.Where(x => x.InvoiceId == r.InvoiceId).SumAsync(x => x.Amount);
        Require(r.Amount > 0 && r.Amount <= invoice.Total - paid, "Số tiền phải lớn hơn 0 và không vượt công nợ còn lại.");
        Require(new[] { "Cash", "Transfer", "Deposit" }.Contains(r.Method), "Phương thức thanh toán không hợp lệ.");
        var contract = await Contract(invoice.ContractId);
        Require(r.PaidDate <= Today && r.PaidDate >= contract.StartDate, "Ngày thu tiền không hợp lệ.");
        if (r.Method == "Deposit")
        {
            Require(contract.Status == "Active" && await deposits.DepositBalance(contract.Id) >= r.Amount, "Cọc còn giữ không đủ hoặc hợp đồng đã kết thúc.");
            db.DepositEntries.Add(new DepositEntry { ContractId = contract.Id, Amount = r.Amount, Type = "Applied", Note = $"Bù trừ hóa đơn #{invoice.Id}" });
        }

        var payment = new Payment
        {
            InvoiceId = r.InvoiceId,
            Amount = r.Amount,
            Method = r.Method,
            PaidDate = r.PaidDate,
            Note = Text(r.Note, "Ghi chú", 1000, false)
        };
        db.Payments.Add(payment);
        await Save("payment.create", $"Hóa đơn #{invoice.Id}, số tiền {r.Amount}, {r.Method}");
        return payment;
    }
}
