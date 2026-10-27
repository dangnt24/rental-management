namespace Rental.Api.Features.Contracts;
public record ContractRequest(int RoomId, int[] TenantIds, int RepresentativeId, DateOnly StartDate, DateOnly EndDate, long Rent, long Deposit, long DepositReceived, string Note);
public record CloseContractRequest(DateOnly ClosedDate, long Deduction, string Note);
public record RenewContractRequest(DateOnly EndDate, long Rent);
