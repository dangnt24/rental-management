namespace Rental.Api.Features.Common;
/// <summary>Validation và ngày nghiệp vụ dùng chung giữa các chức năng.</summary>
public static class BusinessRules
{
    public static DateOnly Today => DateOnly.FromDateTime(DateTime.UtcNow.AddHours(7));

    public static void Require(bool condition, string message, int status = 400)
    {
        if (!condition)
            throw new BusinessError(message, status);
    }

    public static string Text(string? value, string name, int max = 500, bool required = true)
    {
        var text = (value ?? "").Trim();
        Require((!required || text.Length > 0) && text.Length <= max, $"{name}: cần nhập và tối đa {max} ký tự.");
        return text;
    }

    public static void Money(long value) => Require(value is >= 0 and <= 1_000_000_000, "Số tiền phải từ 0 đến 1 tỷ đồng.");
}
