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
    public class BranchService : IBranchService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;

        public BranchService(IUnitOfWork unitOfWork, IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
        }

        public async Task<ApiResult<BranchDto>> GetByIdAsync(int id)
        {
            var branch = await _unitOfWork.Branches.GetByIdAsync(id);
            if (branch == null) return ApiResult<BranchDto>.Failure("Không tìm thấy chi nhánh");
            return ApiResult<BranchDto>.Success(_mapper.Map<BranchDto>(branch));
        }

        public async Task<ApiResult<List<BranchDto>>> GetAllAsync()
        {
            var branches = await _unitOfWork.Branches.Find(x => !x.IsDeleted && x.IsActive).ToListAsync();
            return ApiResult<List<BranchDto>>.Success(_mapper.Map<List<BranchDto>>(branches));
        }

        public async Task<ApiResult<BranchDto>> CreateAsync(BranchDto dto)
        {
            var branch = _mapper.Map<Branch>(dto);
            await _unitOfWork.Branches.AddAsync(branch);
            await _unitOfWork.CompleteAsync();
            return ApiResult<BranchDto>.Success(_mapper.Map<BranchDto>(branch));
        }

        public async Task<ApiResult<BranchDto>> UpdateAsync(BranchDto dto)
        {
            var branch = await _unitOfWork.Branches.GetByIdAsync(dto.Id);
            if (branch == null) return ApiResult<BranchDto>.Failure("Không tìm thấy chi nhánh");
            _mapper.Map(dto, branch);
            _unitOfWork.Branches.Update(branch);
            await _unitOfWork.CompleteAsync();
            return ApiResult<BranchDto>.Success(_mapper.Map<BranchDto>(branch));
        }

        public async Task<ApiResult<bool>> DeleteAsync(int id)
        {
            var branch = await _unitOfWork.Branches.GetByIdAsync(id);
            if (branch == null) return ApiResult<bool>.Failure("Không tìm thấy chi nhánh");
            _unitOfWork.Branches.Remove(branch);
            await _unitOfWork.CompleteAsync();
            return ApiResult<bool>.Success(true);
        }
    }
}
