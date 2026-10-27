namespace Rental.Api.Features.Fees;
public record FeeRequest(int BranchId, string Name, string Method, long UnitPrice, bool IsArchived = false);
