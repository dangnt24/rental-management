namespace Rental.Api.Features.Billing;
public record ReadingRequest(int ContractId, int Year, int Month, decimal ElectricityOld, decimal ElectricityNew, decimal WaterOld, decimal WaterNew);
public record InvoiceRequest(int ContractId, int Year, int Month, DateOnly DueDate);
public record CancelInvoiceRequest(string Reason);
