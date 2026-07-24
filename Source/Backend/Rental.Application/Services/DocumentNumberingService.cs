using Microsoft.EntityFrameworkCore;
using Rental.Application.Interfaces.Persistence;
using Rental.Application.Interfaces.Services;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace Rental.Application.Services
{
    public class DocumentNumberingService : IDocumentNumberingService
    {
        private readonly IUnitOfWork _unitOfWork;

        public DocumentNumberingService(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        public async Task<string> GenerateNextNumberAsync(string transactionType)
        {
            var setting = await _unitOfWork.DocumentSettings
                .Find(d => d.TransactionType == transactionType)
                .FirstOrDefaultAsync();

            if (setting == null)
            {
                throw new InvalidOperationException($"Document setting for '{transactionType}' not configured in sy_document_settings");
            }

            setting.CurrentNumber += 1;

            var datePart = DateTime.Now.ToString(setting.DateFormat ?? "yyyyMMdd");
            var numberPart = setting.CurrentNumber.ToString().PadLeft(setting.NumberDigits, '0');

            _unitOfWork.DocumentSettings.Update(setting);
            await _unitOfWork.CompleteAsync();

            return $"{setting.Prefix}{datePart}{numberPart}";
        }
    }
}
