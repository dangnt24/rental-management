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
    public class PaymentService : IPaymentService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        private readonly ICommonService _commonService;

        public PaymentService(IUnitOfWork unitOfWork, IMapper mapper, ICommonService commonService)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _commonService = commonService;
        }

        public async Task<ApiResult<PaymentDto>> ProcessPaymentAsync(PaymentDto paymentDto)
        {
            await _commonService.EnsureCodeExistsAsync(CommonTypes.InvoiceStatus, InvoiceStatus.Paid);
            await _commonService.EnsureCodeExistsAsync(CommonTypes.InvoiceStatus, InvoiceStatus.Partial);

            var invoice = await _unitOfWork.Invoices.Find(i => i.Id == paymentDto.InvoiceId).FirstOrDefaultAsync();
            if (invoice == null) return ApiResult<PaymentDto>.Failure("Không tìm thấy hóa đơn");

            var payment = _mapper.Map<Payment>(paymentDto);
            await _unitOfWork.Payments.AddAsync(payment);
            await _unitOfWork.CompleteAsync();

            var totalPaid = await _unitOfWork.Payments
                .Find(p => p.InvoiceId == paymentDto.InvoiceId)
                .SumAsync(p => p.Amount);

            invoice.PaidAmount = totalPaid;
            invoice.StatusCode = totalPaid >= invoice.TotalAmount ? InvoiceStatus.Paid : InvoiceStatus.Partial;
            _unitOfWork.Invoices.Update(invoice);
            await _unitOfWork.CompleteAsync();

            return ApiResult<PaymentDto>.Success(_mapper.Map<PaymentDto>(payment));
        }

        public async Task<ApiResult<PagedResult<PaymentDto>>> GetPagedListAsync(int pageNumber, int pageSize, int? invoiceId)
        {
            var query = _unitOfWork.Payments.Find(x => true);

            if (invoiceId.HasValue)
                query = query.Where(x => x.InvoiceId == invoiceId.Value);

            var totalCount = await query.CountAsync();
            var items = await query
                .Include(p => p.Invoice)
                .OrderByDescending(p => p.PaymentDate)
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return ApiResult<PagedResult<PaymentDto>>.Success(new PagedResult<PaymentDto>
            {
                Items = _mapper.Map<List<PaymentDto>>(items),
                TotalCount = totalCount,
                PageNumber = pageNumber,
                PageSize = pageSize
            });
        }
    }
}
