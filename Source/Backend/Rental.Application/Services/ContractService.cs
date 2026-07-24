using Rental.Application.Interfaces.Persistence;
using Rental.Application.Interfaces.Services;
using Rental.Application.DTOs;
using Rental.Core;
using Rental.Domain.Entities;
using Rental.Domain.Constants;
using AutoMapper;
using Microsoft.EntityFrameworkCore;
using System.Linq;
using System.Threading.Tasks;
using System;
using System.Collections.Generic;

namespace Rental.Application.Services
{
    public class ContractService : IContractService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        private readonly ICommonService _commonService;
        private readonly IDocumentNumberingService _documentNumberingService;

        public ContractService(
            IUnitOfWork unitOfWork,
            IMapper mapper,
            ICommonService commonService,
            IDocumentNumberingService documentNumberingService)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _commonService = commonService;
            _documentNumberingService = documentNumberingService;
        }

        public async Task<ApiResult<ContractDto>> CreateContractAsync(ContractDto contractDto)
        {
            await _commonService.EnsureCodeExistsAsync(CommonTypes.ContractStatus, ContractStatus.Active);
            await _commonService.EnsureCodeExistsAsync(CommonTypes.RoomStatus, RoomStatus.Empty);
            await _commonService.EnsureCodeExistsAsync(CommonTypes.RoomStatus, RoomStatus.Rented);

            var room = await _unitOfWork.Rooms.Find(r => r.Id == contractDto.RoomId).FirstOrDefaultAsync();
            if (room == null) return ApiResult<ContractDto>.Failure("Không tìm thấy phòng");
            if (room.StatusCode != RoomStatus.Empty) return ApiResult<ContractDto>.Failure("Phòng không trống");

            var contract = _mapper.Map<Contract>(contractDto);
            contract.ContractCode = await _documentNumberingService.GenerateNextNumberAsync(TransactionTypes.Contract);
            contract.StatusCode = ContractStatus.Active;

            await _unitOfWork.Contracts.AddAsync(contract);
            await _unitOfWork.CompleteAsync();

            if (contractDto.Tenants != null && contractDto.Tenants.Count > 0)
            {
                foreach (var tenantDto in contractDto.Tenants)
                {
                    var detail = new ContractDetail
                    {
                        ContractId = contract.Id,
                        TenantId = tenantDto.Id,
                        IsMain = tenantDto == contractDto.Tenants[0]
                    };
                    await _unitOfWork.ContractDetails.AddAsync(detail);
                }
                await _unitOfWork.CompleteAsync();
            }

            room.StatusCode = RoomStatus.Rented;
            _unitOfWork.Rooms.Update(room);
            await _unitOfWork.CompleteAsync();

            var result = await GetByIdAsync(contract.Id);
            return ApiResult<ContractDto>.Success(result.Data);
        }

        public async Task<ApiResult<ContractDto>> GetByIdAsync(int id)
        {
            var contract = await _unitOfWork.Contracts.Find(x => x.Id == id)
                .Include(c => c.Room)
                .Include(c => c.ContractDetails).ThenInclude(cd => cd.Tenant)
                .FirstOrDefaultAsync();

            if (contract == null) return ApiResult<ContractDto>.Failure("Không tìm thấy hợp đồng");

            var dto = _mapper.Map<ContractDto>(contract);
            dto.Tenants = contract.ContractDetails?
                .Select(cd => _mapper.Map<TenantDto>(cd.Tenant))
                .ToList() ?? new List<TenantDto>();

            return ApiResult<ContractDto>.Success(dto);
        }

        public async Task<ApiResult<ContractDto>> GetActiveContractByRoomAsync(int roomId)
        {
            var contract = await _unitOfWork.Contracts
                .Find(c => c.RoomId == roomId && c.StatusCode == ContractStatus.Active)
                .Include(c => c.Room)
                .Include(c => c.ContractDetails).ThenInclude(cd => cd.Tenant)
                .FirstOrDefaultAsync();

            if (contract == null) return ApiResult<ContractDto>.Failure("Không tìm thấy hợp đồng đang hoạt động");

            var dto = _mapper.Map<ContractDto>(contract);
            dto.Tenants = contract.ContractDetails?
                .Select(cd => _mapper.Map<TenantDto>(cd.Tenant))
                .ToList() ?? new List<TenantDto>();

            return ApiResult<ContractDto>.Success(dto);
        }

        public async Task<ApiResult<bool>> TerminateContractAsync(int contractId)
        {
            await _commonService.EnsureCodeExistsAsync(CommonTypes.ContractStatus, ContractStatus.Terminated);
            await _commonService.EnsureCodeExistsAsync(CommonTypes.RoomStatus, RoomStatus.Empty);

            var contract = await _unitOfWork.Contracts.Find(c => c.Id == contractId).FirstOrDefaultAsync();
            if (contract == null) return ApiResult<bool>.Failure("Không tìm thấy hợp đồng");

            contract.StatusCode = ContractStatus.Terminated;
            contract.EndDate = DateTime.UtcNow;
            _unitOfWork.Contracts.Update(contract);

            var room = await _unitOfWork.Rooms.Find(r => r.Id == contract.RoomId).FirstOrDefaultAsync();
            if (room != null)
            {
                room.StatusCode = RoomStatus.Empty;
                _unitOfWork.Rooms.Update(room);
            }

            await _unitOfWork.CompleteAsync();
            return ApiResult<bool>.Success(true);
        }

        public async Task<ApiResult<PagedResult<ContractDto>>> GetPagedListAsync(int pageNumber, int pageSize, string? statusCode, int? roomId)
        {
            var query = _unitOfWork.Contracts.Find(x => true);

            if (!string.IsNullOrEmpty(statusCode))
                query = query.Where(x => x.StatusCode == statusCode);
            if (roomId.HasValue)
                query = query.Where(x => x.RoomId == roomId.Value);

            var totalCount = await query.CountAsync();
            var items = await query
                .Include(c => c.Room)
                .Include(c => c.ContractDetails).ThenInclude(cd => cd.Tenant)
                .OrderByDescending(c => c.CreatedDate)
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            var dtos = items.Select(c =>
            {
                var dto = _mapper.Map<ContractDto>(c);
                dto.Tenants = c.ContractDetails?
                    .Select(cd => _mapper.Map<TenantDto>(cd.Tenant))
                    .ToList() ?? new List<TenantDto>();
                return dto;
            }).ToList();

            return ApiResult<PagedResult<ContractDto>>.Success(new PagedResult<ContractDto>
            {
                Items = dtos,
                TotalCount = totalCount,
                PageNumber = pageNumber,
                PageSize = pageSize
            });
        }
    }
}
