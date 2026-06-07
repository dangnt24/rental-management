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
    public class BillingService : IBillingService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;

        public BillingService(IUnitOfWork unitOfWork, IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
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
            var contract = await _unitOfWork.Contracts.Find(c => c.Id == contractId)
                .Include(c => c.Room)
                .ThenInclude(r => r.Branch)
                .FirstOrDefaultAsync();

            if (contract == null) return ApiResult<InvoiceDto>.Failure("Không tìm thấy hợp đồng");

            // 1. Tạo Invoice master
            var invoice = new Invoice
            {
                ContractId = contractId,
                BranchId = contract.Room.BranchId,
                InvoiceCode = $"INV-{contract.ContractCode}-{month:D2}{year}",
                BillingMonth = month,
                BillingYear = year,
                StatusCode = "UNPAID",
                DueDate = new DateTime(year, month, 5, 0, 0, 0, DateTimeKind.Utc).AddMonths(1), // Hạn đóng là mùng 5 tháng sau
                TotalAmount = 0
            };

            var items = new List<InvoiceItem>();

            // 2. Thêm Tiền phòng
            items.Add(new InvoiceItem
            {
                Description = $"Tiền thuê phòng tháng {month}/{year}",
                Quantity = 1,
                UnitPrice = contract.ActualRentPrice,
                Amount = contract.ActualRentPrice
            });

            // 3. Tính tiền Điện (Lấy chỉ số mới nhất)
            var reading = await _unitOfWork.UtilityReadings
                .Find(r => r.RoomId == contract.RoomId && r.ReadingDate.Month == month && r.ReadingDate.Year == year)
                .FirstOrDefaultAsync();

            if (reading != null)
            {
                var elecFee = await _unitOfWork.FeeTypes.Find(f => f.BranchId == contract.Room.BranchId && f.FeeName.Contains("điện")).FirstOrDefaultAsync();
                if (elecFee != null)
                {
                    var consumption = reading.ElecIndexNew - reading.ElecIndexOld;
                    items.Add(new InvoiceItem
                    {
                        FeeTypeId = elecFee.Id,
                        Description = $"Tiền điện ({reading.ElecIndexOld} -> {reading.ElecIndexNew})",
                        Quantity = consumption,
                        UnitPrice = elecFee.UnitPrice,
                        Amount = consumption * elecFee.UnitPrice
                    });
                }
            }

            // 4. Các phí dịch vụ cố định (Wifi, Rác...)
            var serviceFees = await _unitOfWork.FeeTypes.Find(f => f.BranchId == contract.Room.BranchId && f.CalcMethod == "FIXED" && !f.FeeName.Contains("phòng")).ToListAsync();
            foreach (var fee in serviceFees)
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
            var invoices = await _unitOfWork.Invoices.Find(i => i.StatusCode != "PAID")
                .Include(i => i.Contract)
                .ThenInclude(c => c.Room)
                .ToListAsync();

            return ApiResult<List<InvoiceDto>>.Success(_mapper.Map<List<InvoiceDto>>(invoices));
        }

        public async Task<ApiResult<PagedResult<InvoiceDto>>> GetPagedUnpaidListAsync(int pageNumber, int pageSize, string? statusCode, int? branchId)
        {
            var query = _unitOfWork.Invoices.Find(i => !i.IsDeleted);

            if (!string.IsNullOrEmpty(statusCode))
                query = query.Where(i => i.StatusCode == statusCode);
            if (branchId.HasValue)
                query = query.Where(i => i.BranchId == branchId.Value);

            var totalCount = await query.CountAsync();
            var items = await query
                .Include(i => i.Contract)
                .ThenInclude(c => c.Room)
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
