namespace Rental.Api.Features.Payments;
public record PaymentRequest(int InvoiceId, long Amount, string Method, DateOnly PaidDate, string Note);
