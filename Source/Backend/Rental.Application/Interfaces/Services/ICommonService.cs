using Rental.Core;
using Rental.Domain.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Rental.Application.Interfaces.Services
{
    public interface ICommonService
    {
        Task<string> GetCodeNameAsync(string type, string code);
        Task<List<Common>> GetListByTypeAsync(string type);
        Task<bool> IsValidCodeAsync(string type, string code);
        Task EnsureCodeExistsAsync(string type, string code);
    }
}
