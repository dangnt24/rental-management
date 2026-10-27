namespace Rental.Api.Features.Tenants;
public record TenantRequest(int BranchId, string FullName, string Phone, string IdentityNumber, string Address);
