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
    public class BillingService : IBillingService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        private readonly ICommonService _commonService;
        private readonly IDocumentNumberingService _documentNumberingService;

        public BillingService(
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

        public async Task<ApiResult<UtilityReadingDto>> RecordReadingAsync(UtilityReadingDto readingDto)
        {
            var reading = _mapper.Map<UtilityReading>(readingDto);
            await _unitOfWork.UtilityReadings.AddAsync(reading);
            await _unitOfWork.CompleteAsync();
            return ApiResult<UtilityReadingDto>.Success(_mapper.Map<UtilityReadingDto>(reading));
        }

        public async Task<ApiResult<InvoiceDto>> GenerateMonthlyInvoiceAsync(int contractId, int month, int year)
        {
            await _commonService.EnsureCodeExistsAsync(CommonTypes.InvoiceStatus, InvoiceStatus.Unpaid);

            var contract = await _unitOfWork.Contracts.Find(c => c.Id == contractId)
                .Include(c => c.Room)
                .ThenInclude(r => r.Branch)
                .FirstOrDefaultAsync();

            if (contract == null) return ApiResult<InvoiceDto>.Failure("Không tìm thấy hợp đồng");

            var invoice = new Invoice
            {
                ContractId = contractId,
                BranchId = contract.Room.BranchId,
                InvoiceCode = await _documentNumberingService.GenerateNextNumberAsync(TransactionTypes.Invoice),
                BillingMonth = month,
                BillingYear = year,
                StatusCode = InvoiceStatus.Unpaid,
                DueDate = new DateTime(year, month, 5, 0, 0, 0, DateTimeKind.Utc).AddMonths(1),
                TotalAmount = 0
            };

            var items = new List<InvoiceItem>();
            var branchId = contract.Room.BranchId;

            var systemFees = await _unitOfWork.FeeTypes
                .Find(f => f.BranchId == branchId && f.IsSystem && f.IsActive)
                .ToListAsync();

            var rentFee = systemFees.FirstOrDefault(f => f.FeeName == SystemFeeNames.Rent);
            items.Add(new InvoiceItem
            {
                FeeTypeId = rentFee?.Id,
                Description = rentFee != null
                    ? rentFee.FeeName
                    : $"Tiền thuê phòng tháng {month}/{year}",
                Quantity = 1,
                UnitPrice = contract.ActualRentPrice,
                Amount = contract.ActualRentPrice
            });

            var reading = await _unitOfWork.UtilityReadings
                .Find(r => r.RoomId == contract.RoomId && r.ReadingDate.Month == month && r.ReadingDate.Year == year)
                .FirstOrDefaultAsync();

            if (reading != null)
            {
                var elecFee = systemFees.FirstOrDefault(f => f.FeeName == SystemFeeNames.Electricity);
                if (elecFee != null)
                {
                    var consumption = reading.ElecIndexNew - reading.ElecIndexOld;
                    if (consumption > 0)
                    {
                        items.Add(new InvoiceItem
                        {
                            FeeTypeId = elecFee.Id,
                            Description = $"{elecFee.FeeName} ({reading.ElecIndexOld} -> {reading.ElecIndexNew})",
                            Quantity = consumption,
                            UnitPrice = elecFee.UnitPrice,
                            Amount = consumption * elecFee.UnitPrice
                        });
                    }
                }

                var waterFee = systemFees.FirstOrDefault(f => f.FeeName == SystemFeeNames.Water);
                if (waterFee != null)
                {
                    var consumption = reading.WaterIndexNew - reading.WaterIndexOld;
                    if (consumption > 0)
                    {
                        items.Add(new InvoiceItem
                        {
                            FeeTypeId = waterFee.Id,
                            Description = $"{waterFee.FeeName} ({reading.WaterIndexOld} -> {reading.WaterIndexNew})",
                            Quantity = consumption,
                            UnitPrice = waterFee.UnitPrice,
                            Amount = consumption * waterFee.UnitPrice
                        });
                    }
                }
            }

            var fixedFees = await _unitOfWork.FeeTypes
                .Find(f => f.BranchId == branchId && f.CalcMethod == FeeCalcMethod.Fixed && f.IsActive)
                .ToListAsync();

            foreach (var fee in fixedFees)
            {
                items.Add(new InvoiceItem
                {
                    FeeTypeId = fee.Id,
                    Description = fee.FeeName,
                    Quantity = 1,
                    UnitPrice = fee.UnitPrice,
                    Amount = fee.UnitPrice
                });
            }

            invoice.TotalAmount = items.Sum(x => x.Amount);
            invoice.InvoiceItems = items;

            await _unitOfWork.Invoices.AddAsync(invoice);
            await _unitOfWork.CompleteAsync();

            return ApiResult<InvoiceDto>.Success(_mapper.Map<InvoiceDto>(invoice));
        }

        public async Task<ApiResult<List<InvoiceDto>>> GetUnpaidInvoicesAsync()
        {
            await _commonService.EnsureCodeExistsAsync(CommonTypes.InvoiceStatus, InvoiceStatus.Paid);

            var invoices = await _unitOfWork.Invoices
                .Find(i => i.StatusCode != InvoiceStatus.Paid)
                .Include(i => i.Contract).ThenInclude(c => c.Room)
                .OrderByDescending(i => i.CreatedDate)
                .ToListAsync();

            return ApiResult<List<InvoiceDto>>.Success(_mapper.Map<List<InvoiceDto>>(invoices));
        }

        public async Task<ApiResult<PagedResult<InvoiceDto>>> GetPagedUnpaidListAsync(int pageNumber, int pageSize, string? statusCode, int? branchId)
        {
            var query = _unitOfWork.Invoices.Find(x => true);

            if (!string.IsNullOrEmpty(statusCode))
                query = query.Where(i => i.StatusCode == statusCode);
            if (branchId.HasValue)
                query = query.Where(i => i.BranchId == branchId.Value);

            var totalCount = await query.CountAsync();
            var items = await query
                .Include(i => i.Contract).ThenInclude(c => c.Room)
                .OrderByDescending(i => i.CreatedDate)
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return ApiResult<PagedResult<InvoiceDto>>.Success(new PagedResult<InvoiceDto>
            {
                Items = _mapper.Map<List<InvoiceDto>>(items),
                TotalCount = totalCount,
                PageNumber = pageNumber,
                PageSize = pageSize
            });
        }
    }
}
