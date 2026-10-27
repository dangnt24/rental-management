using Rental.Api.Domain;

namespace Rental.Api.Features.Notifications;

public sealed class EmailReminderSettings : Entity
{
    public bool Enabled { get; set; }
    public bool InvoiceEnabled { get; set; } = true;
    public bool ContractEnabled { get; set; } = true;
    public int ContractDaysBefore { get; set; } = 7;
    public DateTime? LastScanAt { get; set; }
}

// Một thông báo / hóa đơn hoặc ngày hết hạn / người đại diện; độc lập với số job retry.
public sealed class EmailReminder : Entity
{
    public string DedupKey { get; set; } = "";
    public string Kind { get; set; } = "";
    public int EntityId { get; set; }
    public int ContractId { get; set; }
    public int TenantId { get; set; }
    public DateOnly EventDate { get; set; }
    public string Recipient { get; set; } = "";
    public string Subject { get; set; } = "";
    public string Status { get; set; } = "Pending";
    public int Attempts { get; set; }
    public DateTime? LastAttemptAt { get; set; }
    public DateTime? SentAt { get; set; }
    public string Error { get; set; } = "";
}

public sealed class SmtpOptions
{
    public string Host { get; set; } = "";
    public int Port { get; set; } = 587;
    public string Security { get; set; } = "StartTls";
    public string Username { get; set; } = "";
    public string Password { get; set; } = "";
    public string FromAddress { get; set; } = "";
    public string FromName { get; set; } = "DVP Home";
    public string PublicBaseUrl { get; set; } = "";
    public bool IsConfigured => !string.IsNullOrWhiteSpace(Host) && Port is > 0 and <= 65535 &&
        MimeKit.MailboxAddress.TryParse(FromAddress, out var from) && from.Address == FromAddress &&
        (Security is "StartTls" or "SslOnConnect" || Security == "None" && Host is "localhost" or "127.0.0.1" or "::1") &&
        (Host is "localhost" or "127.0.0.1" or "::1" || Username.Length > 0 && Password.Length > 0);
}

public sealed record ReminderPayload(string Kind, int EntityId, int ContractId, int TenantId, DateOnly EventDate,
    string Recipient, string RecipientName, string RoomName, string BranchName, string Subject, string Html, string Text)
{
    public string Key => $"{Kind}:{EntityId}:{EventDate:yyyy-MM-dd}:{TenantId}";
}
