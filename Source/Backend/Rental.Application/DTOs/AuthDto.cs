using System;

namespace Rental.Application.DTOs
{
    /// <summary>
    /// DTO cơ bản cho tất cả các phản hồi.
    /// </summary>
    public abstract class BaseDto
    {
        public int Id { get; set; }
        public DateTime CreatedDate { get; set; }
        public string CreatedBy { get; set; }
    }

    /// <summary>
    /// DTO thông tin Người dùng.
    /// </summary>
    public class UserDto : BaseDto
    {
        public string Username { get; set; }
        public string FullName { get; set; }
        public string Email { get; set; }
        public string Phone { get; set; }
        public string RoleCode { get; set; }
        public bool IsActive { get; set; }
    }

    public class LoginRequest
    {
        public string Username { get; set; }
        public string Password { get; set; }
    }

    public class RefreshTokenRequest
    {
        public string RefreshToken { get; set; }
    }

    /// <summary>
    /// Phản hồi sau khi đăng nhập thành công.
    /// </summary>
    public class LoginResponse
    {
        public string AccessToken { get; set; }
        public string RefreshToken { get; set; }
        public UserDto User { get; set; }
    }
}
