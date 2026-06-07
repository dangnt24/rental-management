using Rental.Application.Interfaces.Persistence;
using Rental.Application.Interfaces.Services;
using Rental.Application.DTOs;
using Rental.Core;
using Rental.Domain.Entities;
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

        public ContractService(IUnitOfWork unitOfWork, IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
        }

        public async Task<ApiResult<ContractDto>> CreateContractAsync(ContractDto contractDto)
        {
            var room = await _unitOfWork.Rooms.GetByIdAsync(contractDto.RoomId);
            if (room == null) return ApiResult<ContractDto>.Failure("Không tìm thấy phòng");
            if (room.StatusCode == "RENTED") return ApiResult<ContractDto>.Failure("Phòng đã có người thuê");

            var contract = _mapper.Map<Contract>(contractDto);
            contract.ContractCode = $"HD-{contractDto.RoomId}-{DateTime.UtcNow:yyyyMMddHHmmss}";
            contract.StatusCode = "ACTIVE";

            await _unitOfWork.Contracts.AddAsync(contract);
            await _unitOfWork.CompleteAsync();

            room.StatusCode = "RENTED";
            _unitOfWork.Rooms.Update(room);
            await _unitOfWork.CompleteAsync();

            return ApiResult<ContractDto>.Success(_mapper.Map<ContractDto>(contract));
        }

        public async Task<ApiResult<ContractDto>> GetByIdAsync(int id)
        {
            var contract = await _unitOfWork.Contracts.Find(x => x.Id == id)
                .Include(c => c.Room)
                .FirstOrDefaultAsync();
            if (contract == null) return ApiResult<ContractDto>.Failure("Không tìm thấy hợp đồng");
            return ApiResult<ContractDto>.Success(_mapper.Map<ContractDto>(contract));
        }

        public async Task<ApiResult<ContractDto>> GetActiveContractByRoomAsync(int roomId)
        {
            var contract = await _unitOfWork.Contracts
                .Find(c => c.RoomId == roomId && c.StatusCode == "ACTIVE")
                .Include(c => c.Room)
                .FirstOrDefaultAsync();

            if (contract == null) return ApiResult<ContractDto>.Failure("Không tìm thấy hợp đồng");
            return ApiResult<ContractDto>.Success(_mapper.Map<ContractDto>(contract));
        }

        public async Task<ApiResult<bool>> TerminateContractAsync(int contractId)
        {
            var contract = await _unitOfWork.Contracts.GetByIdAsync(contractId);
            if (contract == null) return ApiResult<bool>.Failure("Không tìm thấy hợp đồng");

            contract.StatusCode = "TERMINATED";
            contract.EndDate = DateTime.UtcNow;
            _unitOfWork.Contracts.Update(contract);

            var room = await _unitOfWork.Rooms.GetByIdAsync(contract.RoomId);
            if (room != null)
            {
                room.StatusCode = "EMPTY";
                _unitOfWork.Rooms.Update(room);
            }

            await _unitOfWork.CompleteAsync();
            return ApiResult<bool>.Success(true);
        }

        public async Task<ApiResult<PagedResult<ContractDto>>> GetPagedListAsync(int pageNumber, int pageSize, string? statusCode, int? roomId)
        {
            var query = _unitOfWork.Contracts.Find(x => !x.IsDeleted);

            if (!string.IsNullOrEmpty(statusCode))
                query = query.Where(x => x.StatusCode == statusCode);
            if (roomId.HasValue)
                query = query.Where(x => x.RoomId == roomId.Value);

            var totalCount = await query.CountAsync();
            var items = await query
                .Include(c => c.Room)
                .OrderByDescending(c => c.CreatedDate)
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return ApiResult<PagedResult<ContractDto>>.Success(new PagedResult<ContractDto>
            {
                Items = _mapper.Map<List<ContractDto>>(items),
                TotalCount = totalCount,
                PageNumber = pageNumber,
                PageSize = pageSize
            });
        }
    }
}
