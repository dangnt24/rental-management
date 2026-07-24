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
using System.Collections.Generic;

namespace Rental.Application.Services
{
    public class IncidentService : IIncidentService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        private readonly ICommonService _commonService;

        public IncidentService(IUnitOfWork unitOfWork, IMapper mapper, ICommonService commonService)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _commonService = commonService;
        }

        public async Task<ApiResult<IncidentDto>> GetByIdAsync(int id)
        {
            var incident = await _unitOfWork.Incidents.Find(x => x.Id == id)
                .Include(x => x.Room)
                .Include(x => x.Tenant)
                .FirstOrDefaultAsync();

            if (incident == null) return ApiResult<IncidentDto>.Failure("Không tìm thấy sự cố");
            return ApiResult<IncidentDto>.Success(_mapper.Map<IncidentDto>(incident));
        }

        public async Task<ApiResult<PagedResult<IncidentDto>>> GetPagedListAsync(int pageNumber, int pageSize, string? statusCode, int? roomId)
        {
            var query = _unitOfWork.Incidents.Find(x => true);

            if (!string.IsNullOrEmpty(statusCode))
                query = query.Where(x => x.StatusCode == statusCode);
            if (roomId.HasValue)
                query = query.Where(x => x.RoomId == roomId.Value);

            var totalCount = await query.CountAsync();
            var items = await query
                .Include(x => x.Room)
                .Include(x => x.Tenant)
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
            await _commonService.EnsureCodeExistsAsync(CommonTypes.IncidentStatus, IncidentStatus.Pending);

            var incident = _mapper.Map<Incident>(dto);
            incident.StatusCode = IncidentStatus.Pending;
            incident.ReportedDate = System.DateTime.UtcNow;

            await _unitOfWork.Incidents.AddAsync(incident);
            await _unitOfWork.CompleteAsync();

            return ApiResult<IncidentDto>.Success(_mapper.Map<IncidentDto>(incident));
        }

        public async Task<ApiResult<IncidentDto>> UpdateAsync(IncidentDto dto)
        {
            var incident = await _unitOfWork.Incidents.Find(i => i.Id == dto.Id).FirstOrDefaultAsync();
            if (incident == null) return ApiResult<IncidentDto>.Failure("Không tìm thấy sự cố");

            _mapper.Map(dto, incident);
            _unitOfWork.Incidents.Update(incident);
            await _unitOfWork.CompleteAsync();

            return ApiResult<IncidentDto>.Success(_mapper.Map<IncidentDto>(incident));
        }

        public async Task<ApiResult<bool>> DeleteAsync(int id)
        {
            var incident = await _unitOfWork.Incidents.Find(i => i.Id == id).FirstOrDefaultAsync();
            if (incident == null) return ApiResult<bool>.Failure("Không tìm thấy sự cố");

            _unitOfWork.Incidents.Remove(incident);
            await _unitOfWork.CompleteAsync();

            return ApiResult<bool>.Success(true);
        }
    }
}
