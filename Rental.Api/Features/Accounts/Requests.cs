namespace Rental.Api.Features.Accounts;
public record LoginRequest(string Username, string Password);
public record UserRequest(string Username, string FullName, string Role, string Password, int[] BranchIds, bool IsActive = true, int? TenantId = null, string? Email = null, string? Phone = null);
public record PasswordRequest(string CurrentPassword, string NewPassword);
