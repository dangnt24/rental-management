namespace Rental.Web.ViewModels
{
    public class CommonComboBoxModel
    {
        public string Type { get; set; }
        public string Name { get; set; }
        public string Label { get; set; }
        public string SelectedValue { get; set; }
        public string DefaultValue { get; set; }
        public bool Required { get; set; }
        public bool ShowPlaceholder { get; set; } = true;
        public string PlaceholderText { get; set; }
        public bool EnableSearch { get; set; }
        public string WrapperClass { get; set; } = "mb-3";
    }

    public class FileUploadModel
    {
        public string Name { get; set; }
        public string Label { get; set; }
        public string Hint { get; set; }
        public string ButtonText { get; set; } = "Chọn tệp";
        public string[] AllowedExtensions { get; set; } = new[] { ".pdf", ".doc", ".docx", ".jpg", ".jpeg", ".png" };
        public bool Required { get; set; }
        public string SelectedFileName { get; set; }
        public string ExistingFilePath { get; set; }
        public string PreviewUrl { get; set; }
        public bool IsImage { get; set; }
        public string WrapperClass { get; set; } = "mb-4";
    }

    public class ImageUploadModel
    {
        public string Name { get; set; }
        public string Label { get; set; }
        public string Hint { get; set; }
        public string ButtonText { get; set; } = "Chọn ảnh";
        public string CurrentImageUrl { get; set; }
        public bool Required { get; set; }
        public string WrapperClass { get; set; } = "mb-4";
    }

    public class FileUploadPreviewModel
    {
        public string TableName { get; set; }
        public int RefId { get; set; }
        public string Label { get; set; } = "Tải lên tệp mới";
        public string Hint { get; set; } = "Có thể chọn nhiều tệp cùng lúc";
        public string Accept { get; set; } = ".pdf,.doc,.docx,.jpg,.jpeg,.png";
        public string WrapperClass { get; set; } = "";
    }
}