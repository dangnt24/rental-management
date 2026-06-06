using System.Threading.Tasks;

namespace Rental.Mail
{
    /// <summary>
    /// Dịch vụ gửi Email.
    /// </summary>
    public interface IMailService
    {
        Task SendEmailAsync(string to, string subject, string body);
    }

    public class MailService : IMailService
    {
        public async Task SendEmailAsync(string to, string subject, string body)
        {
            // TODO: Implement SMTP or SendGrid
            await Task.CompletedTask;
        }
    }
}
