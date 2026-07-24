using Rental.Application.Interfaces.Persistence;
using Rental.Application.Interfaces.Services;
using Rental.Application.DTOs;
using Rental.Core;
using Rental.Domain.Entities;
using Rental.Domain.Constants;
using AutoMapper;
using Microsoft.EntityFrameworkCore;
using System.Linq;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Rental.Application.Services
{
    public class RoomService : IRoomService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        private readonly ICommonService _commonService;

        public RoomService(IUnitOfWork unitOfWork, IMapper mapper, ICommonService commonService)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _commonService = commonService;
        }

        public async Task<ApiResult<RoomDto>> GetByIdAsync(int id)
        {
            var room = await _unitOfWork.Rooms.Find(r => r.Id == id)
                .Include(r => r.Branch)
                .FirstOrDefaultAsync();

            if (room == null) return ApiResult<RoomDto>.Failure("Không tìm thấy phòng");
            return ApiResult<RoomDto>.Success(_mapper.Map<RoomDto>(room));
        }

        public async Task<ApiResult<PagedResult<RoomDto>>> GetPagedListAsync(int pageNumber, int pageSize, string? searchTerm, string? statusCode, int? branchId)
        {
            var query = _unitOfWork.Rooms.Find(x => true);

            if (!string.IsNullOrEmpty(searchTerm))
                query = query.Where(x => x.RoomName.Contains(searchTerm));

            if (!string.IsNullOrEmpty(statusCode))
                query = query.Where(x => x.StatusCode == statusCode);

            if (branchId.HasValue)
                query = query.Where(x => x.BranchId == branchId.Value);

            var totalCount = await query.CountAsync();
            var items = await query
                .Include(r => r.Branch)
                .OrderBy(r => r.RoomName)
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return ApiResult<PagedResult<RoomDto>>.Success(new PagedResult<RoomDto>
            {
                Items = _mapper.Map<List<RoomDto>>(items),
                TotalCount = totalCount,
                PageNumber = pageNumber,
                PageSize = pageSize
            });
        }

        public async Task<ApiResult<RoomDto>> CreateAsync(RoomDto roomDto)
        {
            await _commonService.EnsureCodeExistsAsync(CommonTypes.RoomStatus, RoomStatus.Empty);

            var room = _mapper.Map<Room>(roomDto);
            room.StatusCode = RoomStatus.Empty;

            await _unitOfWork.Rooms.AddAsync(room);
            await _unitOfWork.CompleteAsync();

            return ApiResult<RoomDto>.Success(_mapper.Map<RoomDto>(room));
        }

        public async Task<ApiResult<RoomDto>> UpdateAsync(RoomDto roomDto)
        {
            var room = await _unitOfWork.Rooms.Find(r => r.Id == roomDto.Id).FirstOrDefaultAsync();
            if (room == null) return ApiResult<RoomDto>.Failure("Không tìm thấy phòng");

            _mapper.Map(roomDto, room);
            _unitOfWork.Rooms.Update(room);
            await _unitOfWork.CompleteAsync();

            return ApiResult<RoomDto>.Success(_mapper.Map<RoomDto>(room));
        }

        public async Task<ApiResult<bool>> DeleteAsync(int id)
        {
            var room = await _unitOfWork.Rooms.Find(r => r.Id == id).FirstOrDefaultAsync();
            if (room == null) return ApiResult<bool>.Failure("Không tìm thấy phòng");

            _unitOfWork.Rooms.Remove(room);
            await _unitOfWork.CompleteAsync();

            return ApiResult<bool>.Success(true);
        }
    }

    public class TenantService : ITenantService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        private readonly ICommonService _commonService;

        public TenantService(IUnitOfWork unitOfWork, IMapper mapper, ICommonService commonService)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _commonService = commonService;
        }

        public async Task<ApiResult<TenantDto>> GetByIdAsync(int id)
        {
            var tenant = await _unitOfWork.Tenants.Find(t => t.Id == id)
                .FirstOrDefaultAsync();

            if (tenant == null) return ApiResult<TenantDto>.Failure("Không tìm thấy khách thuê");
            return ApiResult<TenantDto>.Success(_mapper.Map<TenantDto>(tenant));
        }

        public async Task<ApiResult<PagedResult<TenantDto>>> GetPagedListAsync(int pageNumber, int pageSize, string? searchTerm)
        {
            var query = _unitOfWork.Tenants.Find(x => true);

            if (!string.IsNullOrEmpty(searchTerm))
                query = query.Where(x => x.FullName.Contains(searchTerm) || x.Phone.Contains(searchTerm) || x.IdentityNumber.Contains(searchTerm));

            var totalCount = await query.CountAsync();
            var items = await query
                .OrderByDescending(x => x.CreatedDate)
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return ApiResult<PagedResult<TenantDto>>.Success(new PagedResult<TenantDto>
            {
                Items = _mapper.Map<List<TenantDto>>(items),
                TotalCount = totalCount,
                PageNumber = pageNumber,
                PageSize = pageSize
            });
        }

        public async Task<ApiResult<TenantDto>> CreateAsync(TenantDto tenantDto)
        {
            await _commonService.EnsureCodeExistsAsync(CommonTypes.TenantStatus, TenantStatusCodes.Active);

            var tenant = _mapper.Map<Tenant>(tenantDto);
            tenant.StatusCode = TenantStatusCodes.Active;

            await _unitOfWork.Tenants.AddAsync(tenant);
            await _unitOfWork.CompleteAsync();

            return ApiResult<TenantDto>.Success(_mapper.Map<TenantDto>(tenant));
        }

        public async Task<ApiResult<TenantDto>> UpdateAsync(TenantDto tenantDto)
        {
            var tenant = await _unitOfWork.Tenants.Find(t => t.Id == tenantDto.Id).FirstOrDefaultAsync();
            if (tenant == null) return ApiResult<TenantDto>.Failure("Không tìm thấy khách thuê");

            _mapper.Map(tenantDto, tenant);
            _unitOfWork.Tenants.Update(tenant);
            await _unitOfWork.CompleteAsync();

            return ApiResult<TenantDto>.Success(_mapper.Map<TenantDto>(tenant));
        }

        public async Task<ApiResult<bool>> DeleteAsync(int id)
        {
            var tenant = await _unitOfWork.Tenants.Find(t => t.Id == id).FirstOrDefaultAsync();
            if (tenant == null) return ApiResult<bool>.Failure("Không tìm thấy khách thuê");

            _unitOfWork.Tenants.Remove(tenant);
            await _unitOfWork.CompleteAsync();

            return ApiResult<bool>.Success(true);
        }
    }
}
