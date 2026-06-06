using System;
using System.IO;

namespace Rental.Utilities
{
    /// <summary>
    /// Helper quản lý File.
    /// </summary>
    public static class FileHelper
    {
        public static string GetFileExtension(string fileName)
        {
            return Path.GetExtension(fileName);
        }

        public static string GenerateUniqueFileName(string fileName)
        {
            return $"{Guid.NewGuid()}{GetFileExtension(fileName)}";
        }
    }

    /// <summary>
    /// Helper xử lý chuỗi.
    /// </summary>
    public static class StringHelper
    {
        public static bool IsNullOrEmpty(string value)
        {
            return string.IsNullOrEmpty(value);
        }
    }
}
