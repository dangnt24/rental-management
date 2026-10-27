using MailKit.Net.Smtp;
using MailKit.Security;
using Microsoft.Extensions.Options;
using MimeKit;

namespace Rental.Api.Features.Notifications;

public sealed class MailDeliveryError(string message, bool definitelyRejected, Exception inner) : Exception(message, inner)
{
    public bool DefinitelyRejected { get; } = definitelyRejected;
}

public sealed class SmtpEmailSender(IOptions<SmtpOptions> options)
{
    public async Task Send(ReminderPayload payload, string messageId, CancellationToken token)
    {
        var config = options.Value;
        using var client = new SmtpClient { Timeout = 30000 };
        var security = config.Security switch { "SslOnConnect" => SecureSocketOptions.SslOnConnect, "None" => SecureSocketOptions.None, _ => SecureSocketOptions.StartTls };
        try
        {
            await client.ConnectAsync(config.Host, config.Port, security, token);
            if (config.Username.Length > 0) await client.AuthenticateAsync(config.Username, config.Password, token);
        }
        catch (Exception ex)
        { throw new MailDeliveryError("Chưa kết nối/xác thực được SMTP. Kiểm tra cấu hình, TLS và mật khẩu ứng dụng.", true, ex); }
        var message = new MimeMessage { Subject = payload.Subject, MessageId = messageId };
        message.From.Add(new MailboxAddress(config.FromName, config.FromAddress));
        message.To.Add(new MailboxAddress(payload.RecipientName, payload.Recipient));
        message.Body = new BodyBuilder { HtmlBody = payload.Html, TextBody = payload.Text }.ToMessageBody();
        try { await client.SendAsync(message, token); }
        catch (SmtpCommandException ex)
        { throw new MailDeliveryError($"SMTP từ chối email (mã {(int)ex.StatusCode}). Kiểm tra người nhận/hạn mức gửi.", true, ex); }
        catch (Exception ex)
        { throw new MailDeliveryError("Kết nối gián đoạn khi gửi; chưa xác định SMTP đã nhận thư hay chưa. Kiểm tra trước khi gửi lại.", false, ex); }
        // QUIT lỗi sau DATA thành công không có nghĩa thư gửi thất bại.
        try { await client.DisconnectAsync(true, token); } catch { }
    }
}
