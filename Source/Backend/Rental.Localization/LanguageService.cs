using Microsoft.Extensions.Localization;
using System.Globalization;

namespace Rental.Localization
{
    /// <summary>
    /// Dịch vụ quản lý đa ngôn ngữ.
    /// </summary>
    public interface ILanguageService
    {
        string GetString(string key);
        string GetString(string key, string culture);
    }

    public class LanguageService : ILanguageService
    {
        private readonly IStringLocalizer _localizer;

        public LanguageService(IStringLocalizerFactory factory)
        {
            // Giả định sử dụng IStringLocalizer chuẩn của .NET
        }

        public string GetString(string key)
        {
            return key; // TODO: Implement real localization logic
        }

        public string GetString(string key, string culture)
        {
            return key;
        }
    }
}
