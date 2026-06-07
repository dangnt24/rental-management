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
    public class IncidentService : IIncidentService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;

        public IncidentService(IUnitOfWork unitOfWork, IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
        }

        public async Task<ApiResult<IncidentDto>> GetByIdAsync(int id)
        {
            var incident = await _unitOfWork.Incidents.Find(x => x.Id == id)
                .Include(x => x.Room)
                .FirstOrDefaultAsync();
            if (incident == null) return ApiResult<IncidentDto>.Failure("Không tìm thấy sự cố");
            return ApiResult<IncidentDto>.Success(_mapper.Map<IncidentDto>(incident));
        }

        public async Task<ApiResult<PagedResult<IncidentDto>>> GetPagedListAsync(int pageNumber, int pageSize, string? statusCode, int? roomId)
        {
            var query = _unitOfWork.Incidents.Find(x => !x.IsDeleted);

            if (!string.IsNullOrEmpty(statusCode))
                query = query.Where(x => x.StatusCode == statusCode);
            if (roomId.HasValue)
                query = query.Where(x => x.RoomId == roomId.Value);

            var totalCount = await query.CountAsync();
            var items = await query
                .Include(x => x.Room)
                .OrderByDescending(x => x.ReportedDate)
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return ApiResult<PagedResult<IncidentDto>>.Success(new PagedResult<IncidentDto>
            {
                Items = _mapper.Map<List<IncidentDto>>(items),
                TotalCount = totalCount,
                PageNumber = pageNumber,
                PageSize = pageSize
            });
        }

        public async Task<ApiResult<IncidentDto>> CreateAsync(IncidentDto dto)
        {
            var incident = _mapper.Map<Incident>(dto);
            incident.StatusCode = "PENDING";
            await _unitOfWork.Incidents.AddAsync(incident);
            await _unitOfWork.CompleteAsync();
            return ApiResult<IncidentDto>.Success(_mapper.Map<IncidentDto>(incident));
        }

        public async Task<ApiResult<IncidentDto>> UpdateAsync(IncidentDto dto)
        {
            var incident = await _unitOfWork.Incidents.GetByIdAsync(dto.Id);
            if (incident == null) return ApiResult<IncidentDto>.Failure("Không tìm thấy sự cố");

            _mapper.Map(dto, incident);
            _unitOfWork.Incidents.Update(incident);
            await _unitOfWork.CompleteAsync();
            return ApiResult<IncidentDto>.Success(_mapper.Map<IncidentDto>(incident));
        }

        public async Task<ApiResult<bool>> DeleteAsync(int id)
        {
            var incident = await _unitOfWork.Incidents.GetByIdAsync(id);
            if (incident == null) return ApiResult<bool>.Failure("Không tìm thấy sự cố");
            _unitOfWork.Incidents.Remove(incident);
            await _unitOfWork.CompleteAsync();
            return ApiResult<bool>.Success(true);
        }
    }
}
