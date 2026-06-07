using Rental.Application.Interfaces.Persistence;
using Rental.Application.Interfaces.Services;
using Rental.Application.DTOs;
using Rental.Core;
using Rental.Domain.Entities;
using AutoMapper;
using Microsoft.EntityFrameworkCore;
using System.Linq;
using System.Threading.Tasks;
using System.Collections.Generic;

namespace Rental.Application.Services
{
    public class FeeTypeService : IFeeTypeService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;

        public FeeTypeService(IUnitOfWork unitOfWork, IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
        }

        public async Task<ApiResult<FeeTypeDto>> GetByIdAsync(int id)
        {
            var feeType = await _unitOfWork.FeeTypes.GetByIdAsync(id);
            if (feeType == null) return ApiResult<FeeTypeDto>.Failure("Không tìm thấy loại phí");
            return ApiResult<FeeTypeDto>.Success(_mapper.Map<FeeTypeDto>(feeType));
        }

        public async Task<ApiResult<PagedResult<FeeTypeDto>>> GetPagedListAsync(int pageNumber, int pageSize, int? branchId)
        {
            var query = _unitOfWork.FeeTypes.Find(x => !x.IsDeleted);

            if (branchId.HasValue)
                query = query.Where(x => x.BranchId == branchId.Value);

            var totalCount = await query.CountAsync();
            var items = await query
                .OrderBy(x => x.FeeName)
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return ApiResult<PagedResult<FeeTypeDto>>.Success(new PagedResult<FeeTypeDto>
            {
                Items = _mapper.Map<List<FeeTypeDto>>(items),
                TotalCount = totalCount,
                PageNumber = pageNumber,
                PageSize = pageSize
            });
        }

        public async Task<ApiResult<FeeTypeDto>> CreateAsync(FeeTypeDto dto)
        {
            var feeType = _mapper.Map<FeeType>(dto);
            await _unitOfWork.FeeTypes.AddAsync(feeType);
            await _unitOfWork.CompleteAsync();
            return ApiResult<FeeTypeDto>.Success(_mapper.Map<FeeTypeDto>(feeType));
        }

        public async Task<ApiResult<FeeTypeDto>> UpdateAsync(FeeTypeDto dto)
        {
            var feeType = await _unitOfWork.FeeTypes.GetByIdAsync(dto.Id);
            if (feeType == null) return ApiResult<FeeTypeDto>.Failure("Không tìm thấy loại phí");
            _mapper.Map(dto, feeType);
            _unitOfWork.FeeTypes.Update(feeType);
            await _unitOfWork.CompleteAsync();
            return ApiResult<FeeTypeDto>.Success(_mapper.Map<FeeTypeDto>(feeType));
        }

        public async Task<ApiResult<bool>> DeleteAsync(int id)
        {
            var feeType = await _unitOfWork.FeeTypes.GetByIdAsync(id);
            if (feeType == null) return ApiResult<bool>.Failure("Không tìm thấy loại phí");
            _unitOfWork.FeeTypes.Remove(feeType);
            await _unitOfWork.CompleteAsync();
            return ApiResult<bool>.Success(true);
        }
    }
}
