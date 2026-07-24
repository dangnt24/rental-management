using Microsoft.EntityFrameworkCore;
using Rental.Application.Interfaces.Persistence;
using Rental.Application.Interfaces.Services;
using Rental.Core;
using Rental.Domain.Entities;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Rental.Application.Services
{
    public class CommonService : ICommonService
    {
        private readonly IUnitOfWork _unitOfWork;

        public CommonService(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        public async Task<string> GetCodeNameAsync(string type, string code)
        {
            var item = await _unitOfWork.Commons
                .Find(c => c.Type == type && c.Code == code && c.IsActive)
                .FirstOrDefaultAsync();

            return item?.NameVi ?? code;
        }

        public async Task<List<Common>> GetListByTypeAsync(string type)
        {
            return await _unitOfWork.Commons
                .Find(c => c.Type == type && c.IsActive)
                .OrderBy(c => c.SortOrder)
                .ToListAsync();
        }

        public async Task<bool> IsValidCodeAsync(string type, string code)
        {
            return await _unitOfWork.Commons
                .Find(c => c.Type == type && c.Code == code && c.IsActive)
                .AnyAsync();
        }

        public async Task EnsureCodeExistsAsync(string type, string code)
        {
            var exists = await IsValidCodeAsync(type, code);
            if (!exists)
            {
                throw new KeyNotFoundException($"Code '{code}' of type '{type}' not found in sy_commons");
            }
        }
    }
}
