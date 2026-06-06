using Hangfire;
using Rental.Mail;

namespace Rental.Hangfire
{
    /// <summary>
    /// Các tác vụ chạy ngầm sử dụng Hangfire.
    /// </summary>
    public class BackgroundJobs
    {
        private readonly IMailService _mailService;

        public BackgroundJobs(IMailService mailService)
        {
            _mailService = mailService;
        }

        /// <summary>
        /// Gửi email nhắc đóng tiền phòng.
        /// </summary>
        public async System.Threading.Tasks.Task SendPaymentReminderJob(string email, string tenantName)
        {
            await _mailService.SendEmailAsync(email, "Nhắc đóng tiền phòng", $"Chào {tenantName}, vui lòng thanh toán tiền phòng đúng hạn.");
        }
    }
}
