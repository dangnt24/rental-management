using Rental.Application.Interfaces.Persistence;
using Rental.Application.Interfaces.Services;
using Rental.Application.DTOs;
using Rental.Core;
using Rental.Domain.Constants;
using Microsoft.EntityFrameworkCore;
using System.Linq;
using System.Threading.Tasks;
using System;
using System.Collections.Generic;

namespace Rental.Application.Services
{
    public class SearchService : ISearchService
    {
        private readonly IUnitOfWork _unitOfWork;

        public SearchService(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        public async Task<ApiResult<PagedResult<ContractSearchResult>>> SearchContractsAsync(SearchRequest request)
        {
            var query = _unitOfWork.Contracts.Find(c => true)
                .Include(c => c.Room)
                .Include(c => c.ContractDetails).ThenInclude(cd => cd.Tenant)
                .AsQueryable();

            if (!string.IsNullOrWhiteSpace(request.Keyword))
            {
                var kw = request.Keyword.ToLower();
                query = query.Where(c => c.ContractCode.ToLower().Contains(kw)
                    || c.Room.RoomName.ToLower().Contains(kw)
                    || c.ContractDetails.Any(cd => cd.Tenant.FullName.ToLower().Contains(kw)
                        || cd.Tenant.Phone.Contains(kw)));
            }
            if (!string.IsNullOrEmpty(request.StatusCode))
                query = query.Where(c => c.StatusCode == request.StatusCode);
            if (request.RoomId.HasValue)
                query = query.Where(c => c.RoomId == request.RoomId.Value);
            if (request.FromDate.HasValue)
                query = query.Where(c => c.StartDate >= request.FromDate.Value);
            if (request.ToDate.HasValue)
                query = query.Where(c => c.StartDate <= request.ToDate.Value);

            var totalCount = await query.CountAsync();
            var items = await query
                .OrderByDescending(c => c.CreatedDate)
                .Skip((request.PageNumber - 1) * request.PageSize)
                .Take(request.PageSize)
                .ToListAsync();

            var results = items.Select(c => new ContractSearchResult
            {
                Id = c.Id,
                ContractCode = c.ContractCode,
                RoomName = c.Room?.RoomName ?? "",
                TenantName = c.ContractDetails?.FirstOrDefault()?.Tenant?.FullName ?? "",
                TenantPhone = c.ContractDetails?.FirstOrDefault()?.Tenant?.Phone ?? "",
                StartDate = c.StartDate,
                EndDate = c.EndDate,
                ActualRentPrice = c.ActualRentPrice,
                StatusCode = c.StatusCode,
                CreatedDate = c.CreatedDate
            }).ToList();

            return ApiResult<PagedResult<ContractSearchResult>>.Success(new PagedResult<ContractSearchResult>
            {
                Items = results,
                TotalCount = totalCount,
                PageNumber = request.PageNumber,
                PageSize = request.PageSize
            });
        }

        public async Task<ApiResult<PagedResult<PaymentSearchResult>>> SearchPaymentsAsync(SearchRequest request)
        {
            var query = _unitOfWork.Payments.Find(p => true)
                .Include(p => p.Invoice).ThenInclude(i => i.Contract).ThenInclude(c => c.Room)
                .AsQueryable();

            if (!string.IsNullOrWhiteSpace(request.Keyword))
            {
                var kw = request.Keyword.ToLower();
                query = query.Where(p => p.Invoice.InvoiceCode.ToLower().Contains(kw)
                    || p.Invoice.Contract.Room.RoomName.ToLower().Contains(kw));
            }
            if (request.FromDate.HasValue)
                query = query.Where(p => p.PaymentDate >= request.FromDate.Value);
            if (request.ToDate.HasValue)
                query = query.Where(p => p.PaymentDate <= request.ToDate.Value);
            if (request.MinAmount.HasValue)
                query = query.Where(p => p.Amount >= request.MinAmount.Value);
            if (request.MaxAmount.HasValue)
                query = query.Where(p => p.Amount <= request.MaxAmount.Value);

            var totalCount = await query.CountAsync();
            var items = await query
                .OrderByDescending(p => p.PaymentDate)
                .Skip((request.PageNumber - 1) * request.PageSize)
                .Take(request.PageSize)
                .ToListAsync();

            var results = items.Select(p => new PaymentSearchResult
            {
                Id = p.Id,
                InvoiceCode = p.Invoice?.InvoiceCode ?? "",
                RoomName = p.Invoice?.Contract?.Room?.RoomName ?? "",
                Amount = p.Amount,
                PaymentDate = p.PaymentDate,
                MethodCode = p.MethodCode,
                Remark = p.Remark
            }).ToList();

            return ApiResult<PagedResult<PaymentSearchResult>>.Success(new PagedResult<PaymentSearchResult>
            {
                Items = results,
                TotalCount = totalCount,
                PageNumber = request.PageNumber,
                PageSize = request.PageSize
            });
        }

        public async Task<ApiResult<PagedResult<IncidentSearchResult>>> SearchIncidentsAsync(SearchRequest request)
        {
            var query = _unitOfWork.Incidents.Find(i => true)
                .Include(i => i.Room)
                .Include(i => i.Tenant)
                .AsQueryable();

            if (!string.IsNullOrWhiteSpace(request.Keyword))
            {
                var kw = request.Keyword.ToLower();
                query = query.Where(i => i.Description.ToLower().Contains(kw)
                    || i.Room.RoomName.ToLower().Contains(kw)
                    || i.Tenant.FullName.ToLower().Contains(kw));
            }
            if (!string.IsNullOrEmpty(request.StatusCode))
                query = query.Where(i => i.StatusCode == request.StatusCode);
            if (request.RoomId.HasValue)
                query = query.Where(i => i.RoomId == request.RoomId.Value);
            if (request.FromDate.HasValue)
                query = query.Where(i => i.ReportedDate >= request.FromDate.Value);
            if (request.ToDate.HasValue)
                query = query.Where(i => i.ReportedDate <= request.ToDate.Value);

            var totalCount = await query.CountAsync();
            var items = await query
                .OrderByDescending(i => i.ReportedDate)
                .Skip((request.PageNumber - 1) * request.PageSize)
                .Take(request.PageSize)
                .ToListAsync();

            var results = items.Select(i => new IncidentSearchResult
            {
                Id = i.Id,
                RoomName = i.Room?.RoomName ?? "",
                Description = i.Description,
                PriorityCode = i.PriorityCode,
                StatusCode = i.StatusCode,
                RepairCost = i.RepairCost,
                ReportedDate = i.ReportedDate,
                ResolvedDate = i.ResolvedDate,
                TenantName = i.Tenant?.FullName ?? ""
            }).ToList();

            return ApiResult<PagedResult<IncidentSearchResult>>.Success(new PagedResult<IncidentSearchResult>
            {
                Items = results,
                TotalCount = totalCount,
                PageNumber = request.PageNumber,
                PageSize = request.PageSize
            });
        }

        public async Task<ApiResult<PagedResult<TenantSearchResult>>> SearchTenantsAsync(SearchRequest request)
        {
            var query = _unitOfWork.Tenants.Find(t => true)
                .Include(t => t.ContractDetails).ThenInclude(cd => cd.Contract).ThenInclude(c => c.Room)
                .AsQueryable();

            if (!string.IsNullOrWhiteSpace(request.Keyword))
            {
                var kw = request.Keyword.ToLower();
                query = query.Where(t => t.FullName.ToLower().Contains(kw)
                    || t.Phone.Contains(kw)
                    || t.IdentityNumber.Contains(kw)
                    || t.Email.ToLower().Contains(kw));
            }
            if (!string.IsNullOrEmpty(request.StatusCode))
                query = query.Where(t => t.StatusCode == request.StatusCode);

            var totalCount = await query.CountAsync();
            var items = await query
                .OrderByDescending(t => t.CreatedDate)
                .Skip((request.PageNumber - 1) * request.PageSize)
                .Take(request.PageSize)
                .ToListAsync();

            var results = items.Select(t =>
            {
                var activeContract = t.ContractDetails?
                    .FirstOrDefault(cd => cd.Contract.StatusCode == ContractStatus.Active)?.Contract;
                return new TenantSearchResult
                {
                    Id = t.Id,
                    FullName = t.FullName,
                    Phone = t.Phone,
                    IdentityNumber = t.IdentityNumber,
                    Email = t.Email,
                    StatusCode = t.StatusCode,
                    RoomName = activeContract?.Room?.RoomName ?? ""
                };
            }).ToList();

            return ApiResult<PagedResult<TenantSearchResult>>.Success(new PagedResult<TenantSearchResult>
            {
                Items = results,
                TotalCount = totalCount,
                PageNumber = request.PageNumber,
                PageSize = request.PageSize
            });
        }

        public async Task<ApiResult<PagedResult<RoomSearchResult>>> SearchRoomsAsync(SearchRequest request)
        {
            var query = _unitOfWork.Rooms.Find(r => true)
                .Include(r => r.Branch)
                .AsQueryable();

            if (!string.IsNullOrWhiteSpace(request.Keyword))
            {
                var kw = request.Keyword.ToLower();
                query = query.Where(r => r.RoomName.ToLower().Contains(kw)
                    || r.Branch.BranchName.ToLower().Contains(kw));
            }
            if (!string.IsNullOrEmpty(request.StatusCode))
                query = query.Where(r => r.StatusCode == request.StatusCode);
            if (request.BranchId.HasValue)
                query = query.Where(r => r.BranchId == request.BranchId.Value);
            if (request.MinAmount.HasValue)
                query = query.Where(r => r.Price >= request.MinAmount.Value);
            if (request.MaxAmount.HasValue)
                query = query.Where(r => r.Price <= request.MaxAmount.Value);

            var totalCount = await query.CountAsync();
            var items = await query
                .OrderBy(r => r.RoomName)
                .Skip((request.PageNumber - 1) * request.PageSize)
                .Take(request.PageSize)
                .ToListAsync();

            var results = items.Select(r => new RoomSearchResult
            {
                Id = r.Id,
                RoomName = r.RoomName,
                BranchName = r.Branch?.BranchName ?? "",
                Price = r.Price,
                MaxOccupants = r.MaxOccupants,
                StatusCode = r.StatusCode
            }).ToList();

            return ApiResult<PagedResult<RoomSearchResult>>.Success(new PagedResult<RoomSearchResult>
            {
                Items = results,
                TotalCount = totalCount,
                PageNumber = request.PageNumber,
                PageSize = request.PageSize
            });
        }

        public async Task<ApiResult<PagedResult<InvoiceSearchResult>>> SearchInvoicesAsync(SearchRequest request)
        {
            var query = _unitOfWork.Invoices.Find(i => true)
                .Include(i => i.Contract).ThenInclude(c => c.Room)
                .AsQueryable();

            if (!string.IsNullOrWhiteSpace(request.Keyword))
            {
                var kw = request.Keyword.ToLower();
                query = query.Where(i => i.InvoiceCode.ToLower().Contains(kw)
                    || i.Contract.Room.RoomName.ToLower().Contains(kw));
            }
            if (!string.IsNullOrEmpty(request.StatusCode))
                query = query.Where(i => i.StatusCode == request.StatusCode);
            if (request.BranchId.HasValue)
                query = query.Where(i => i.BranchId == request.BranchId.Value);
            if (request.FromDate.HasValue)
                query = query.Where(i => i.CreatedDate >= request.FromDate.Value);
            if (request.ToDate.HasValue)
                query = query.Where(i => i.CreatedDate <= request.ToDate.Value);

            var totalCount = await query.CountAsync();
            var items = await query
                .OrderByDescending(i => i.CreatedDate)
                .Skip((request.PageNumber - 1) * request.PageSize)
                .Take(request.PageSize)
                .ToListAsync();

            var results = items.Select(i => new InvoiceSearchResult
            {
                Id = i.Id,
                InvoiceCode = i.InvoiceCode,
                RoomName = i.Contract?.Room?.RoomName ?? "",
                BillingMonth = i.BillingMonth,
                BillingYear = i.BillingYear,
                TotalAmount = i.TotalAmount,
                PaidAmount = i.PaidAmount,
                StatusCode = i.StatusCode,
                DueDate = i.DueDate
            }).ToList();

            return ApiResult<PagedResult<InvoiceSearchResult>>.Success(new PagedResult<InvoiceSearchResult>
            {
                Items = results,
                TotalCount = totalCount,
                PageNumber = request.PageNumber,
                PageSize = request.PageSize
            });
        }
    }
}
