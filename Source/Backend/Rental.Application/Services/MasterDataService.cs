using Rental.Application.Interfaces.Persistence;
using Rental.Application.Interfaces.Services;
using Rental.Application.DTOs;
using Rental.Core;
using Rental.Domain.Entities;
using AutoMapper;
using Microsoft.EntityFrameworkCore;
using System.Linq;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Rental.Application.Services
{
    /// <summary>
    /// Triển khai dịch vụ quản lý Phòng.
    /// </summary>
    public class RoomService : IRoomService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;

        public RoomService(IUnitOfWork unitOfWork, IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
        }

        public async Task<ApiResult<RoomDto>> GetByIdAsync(int id)
        {
            var room = await _unitOfWork.Rooms.GetByIdAsync(id);
            if (room == null) return ApiResult<RoomDto>.Failure("Không tìm thấy phòng");
            return ApiResult<RoomDto>.Success(_mapper.Map<RoomDto>(room));
        }

        public async Task<ApiResult<PagedResult<RoomDto>>> GetPagedListAsync(int pageNumber, int pageSize, string? searchTerm, string? statusCode, int? branchId)
        {
            var query = _unitOfWork.Rooms.Find(x => !x.IsDeleted);

            if (!string.IsNullOrEmpty(searchTerm))
                query = query.Where(x => x.RoomName.Contains(searchTerm));

            if (!string.IsNullOrEmpty(statusCode))
                query = query.Where(x => x.StatusCode == statusCode);

            if (branchId.HasValue)
                query = query.Where(x => x.BranchId == branchId.Value);

            var totalCount = await query.CountAsync();
            var items = await query.Skip((pageNumber - 1) * pageSize).Take(pageSize).ToListAsync();

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
            var room = _mapper.Map<Room>(roomDto);
            room.StatusCode = "EMPTY";
            await _unitOfWork.Rooms.AddAsync(room);
            await _unitOfWork.CompleteAsync();
            return ApiResult<RoomDto>.Success(_mapper.Map<RoomDto>(room));
        }

        public async Task<ApiResult<RoomDto>> UpdateAsync(RoomDto roomDto)
        {
            var room = await _unitOfWork.Rooms.GetByIdAsync(roomDto.Id);
            if (room == null) return ApiResult<RoomDto>.Failure("Không tìm thấy phòng");

            _mapper.Map(roomDto, room);
            _unitOfWork.Rooms.Update(room);
            await _unitOfWork.CompleteAsync();
            return ApiResult<RoomDto>.Success(_mapper.Map<RoomDto>(room));
        }

        public async Task<ApiResult<bool>> DeleteAsync(int id)
        {
            var room = await _unitOfWork.Rooms.GetByIdAsync(id);
            if (room == null) return ApiResult<bool>.Failure("Không tìm thấy phòng");

            _unitOfWork.Rooms.Remove(room);
            await _unitOfWork.CompleteAsync();
            return ApiResult<bool>.Success(true);
        }
    }

    /// <summary>
    /// Triển khai dịch vụ quản lý Người thuê.
    /// </summary>
    public class TenantService : ITenantService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;

        public TenantService(IUnitOfWork unitOfWork, IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
        }

        public async Task<ApiResult<TenantDto>> GetByIdAsync(int id)
        {
            var tenant = await _unitOfWork.Tenants.GetByIdAsync(id);
            if (tenant == null) return ApiResult<TenantDto>.Failure("Không tìm thấy khách thuê");
            return ApiResult<TenantDto>.Success(_mapper.Map<TenantDto>(tenant));
        }

        public async Task<ApiResult<PagedResult<TenantDto>>> GetPagedListAsync(int pageNumber, int pageSize, string? searchTerm)
        {
            var query = _unitOfWork.Tenants.Find(x => !x.IsDeleted);

            if (!string.IsNullOrEmpty(searchTerm))
                query = query.Where(x => x.FullName.Contains(searchTerm) || x.Phone.Contains(searchTerm) || x.IdentityNumber.Contains(searchTerm));

            var totalCount = await query.CountAsync();
            var items = await query.Skip((pageNumber - 1) * pageSize).Take(pageSize).ToListAsync();

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
            var tenant = _mapper.Map<Tenant>(tenantDto);
            await _unitOfWork.Tenants.AddAsync(tenant);
            await _unitOfWork.CompleteAsync();
            return ApiResult<TenantDto>.Success(_mapper.Map<TenantDto>(tenant));
        }

        public async Task<ApiResult<TenantDto>> UpdateAsync(TenantDto tenantDto)
        {
            var tenant = await _unitOfWork.Tenants.GetByIdAsync(tenantDto.Id);
            if (tenant == null) return ApiResult<TenantDto>.Failure("Không tìm thấy khách thuê");

            _mapper.Map(tenantDto, tenant);
            _unitOfWork.Tenants.Update(tenant);
            await _unitOfWork.CompleteAsync();
            return ApiResult<TenantDto>.Success(_mapper.Map<TenantDto>(tenant));
        }

        public async Task<ApiResult<bool>> DeleteAsync(int id)
        {
            var tenant = await _unitOfWork.Tenants.GetByIdAsync(id);
            if (tenant == null) return ApiResult<bool>.Failure("Không tìm thấy khách thuê");

            _unitOfWork.Tenants.Remove(tenant);
            await _unitOfWork.CompleteAsync();
            return ApiResult<bool>.Success(true);
        }
    }
}
