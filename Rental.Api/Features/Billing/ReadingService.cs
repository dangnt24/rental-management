using Microsoft.EntityFrameworkCore;
using Rental.Api.Data;
using Rental.Api.Domain;
using Rental.Api.Features.Common;
using static Rental.Api.Features.Common.BusinessRules;
using static Rental.Api.Features.Billing.BillingRules;

namespace Rental.Api.Features.Billing;
/// <summary>Chỉ số điện nước; thao tác ghi dùng giao dịch chung của endpoint filter.</summary>
public sealed class ReadingService(RentalDb database, IHttpContextAccessor accessor) : FeatureService(database, accessor)
{
    public async Task<object> RecordReading(ReadingRequest r)
    {
        var contract = await Contract(r.ContractId);
        var period = Period(r.Year, r.Month);
        CheckPeriod(contract, period);
        var values = new[]
        {
            r.ElectricityOld,
            r.ElectricityNew,
            r.WaterOld,
            r.WaterNew
        };
        Require(values.All(x => x is >= 0 and <= 1_000_000_000 && decimal.Round(x, 3) == x) && r.ElectricityNew >= r.ElectricityOld && r.WaterNew >= r.WaterOld, "Chỉ số phải không âm, tối đa 3 số lẻ và chỉ số mới không nhỏ hơn chỉ số cũ.");
        Require(!await db.Invoices.AnyAsync(x => x.ContractId == r.ContractId && x.Year == r.Year && x.Month == r.Month && x.Status == "Issued"), "Đã xuất hóa đơn; chỉ số kỳ này đã khóa.");
        var previous = await db.Readings.Where(x => x.ContractId == r.ContractId && (x.Year < r.Year || x.Year == r.Year && x.Month < r.Month)).OrderByDescending(x => x.Year).ThenByDescending(x => x.Month).FirstOrDefaultAsync();
        var next = await db.Readings.Where(x => x.ContractId == r.ContractId && (x.Year > r.Year || x.Year == r.Year && x.Month > r.Month)).OrderBy(x => x.Year).ThenBy(x => x.Month).FirstOrDefaultAsync();
        Require(previous == null || previous.ElectricityNew == r.ElectricityOld && previous.WaterNew == r.WaterOld, "Chỉ số cũ phải bằng chỉ số mới của kỳ trước đã ghi.");
        Require(next == null || next.ElectricityOld == r.ElectricityNew && next.WaterOld == r.WaterNew, "Chỉ số mới phải khớp chỉ số cũ của kỳ tiếp theo đã ghi.");
        var reading = await db.Readings.SingleOrDefaultAsync(x => x.ContractId == r.ContractId && x.Year == r.Year && x.Month == r.Month);
        if (reading == null)
        {
            reading = new Reading
            {
                ContractId = r.ContractId,
                Year = r.Year,
                Month = r.Month
            };
            db.Readings.Add(reading);
        }

        reading.ElectricityOld = r.ElectricityOld;
        reading.ElectricityNew = r.ElectricityNew;
        reading.WaterOld = r.WaterOld;
        reading.WaterNew = r.WaterNew;
        await Save("reading.save", $"Hợp đồng #{r.ContractId}, kỳ {r.Month}/{r.Year}");
        return reading;
    }
}
