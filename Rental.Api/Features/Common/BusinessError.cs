namespace Rental.Api.Features.Common;
public sealed class BusinessError(string message, int status = 400) : Exception(message)
{
    public int Status { get; } = status;
}
