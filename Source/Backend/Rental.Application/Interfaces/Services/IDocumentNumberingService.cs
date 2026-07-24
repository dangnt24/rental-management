using System.Threading.Tasks;

namespace Rental.Application.Interfaces.Services
{
    public interface IDocumentNumberingService
    {
        Task<string> GenerateNextNumberAsync(string transactionType);
    }
}
