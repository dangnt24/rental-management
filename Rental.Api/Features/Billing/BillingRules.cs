using Microsoft.EntityFrameworkCore;
using Rental.Api.Data;
using Rental.Api.Domain;
using Rental.Api.Features.Common;
using static Rental.Api.Features.Common.BusinessRules;

namespace Rental.Api.Features.Billing;
/// <summary>Kiểm tra kỳ ghi chỉ số và kỳ lập hóa đơn trong thời gian hợp đồng.</summary>
public static class BillingRules
{
    public static DateOnly Period(int year, int month)
    {
        Require(year is >= 2000 and <= 2100 && month is >= 1 and <= 12, "Tháng/năm không hợp lệ.");
        return new DateOnly(year, month, 1);
    }

    public static void CheckPeriod(Contract contract, DateOnly period)
    {
        Require(contract.Status == "Active", "Hợp đồng đã kết thúc.");
        Require(period <= contract.EndDate && period.AddMonths(1).AddDays(-1) >= contract.StartDate, "Kỳ thu nằm ngoài thời gian hợp đồng; cần gia hạn nếu đã hết hạn.");
        Require(period <= new DateOnly(Today.Year, Today.Month, 1), "Chỉ chốt chỉ số và lập hóa đơn đến kỳ hiện tại.");
    }
}
