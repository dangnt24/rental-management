using Microsoft.EntityFrameworkCore;
using Rental.Application.Interfaces.Persistence;
using Rental.Application.Interfaces.Services;
using Rental.Core;
using Rental.Domain.Entities;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;

namespace Rental.Application.Services
{
    public class FileService : IFileService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly string _uploadRoot;

        public FileService(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
            _uploadRoot = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads");
            if (!Directory.Exists(_uploadRoot))
                Directory.CreateDirectory(_uploadRoot);
        }

        public async Task<ApiResult<FileAttachment>> UploadAsync(FileUploadRequest request)
        {
            if (request.Content == null || request.Length == 0)
                return ApiResult<FileAttachment>.Failure("Vui lòng chọn tệp");

            var ext = Path.GetExtension(request.FileName).ToLowerInvariant();
            var allowed = new[] { ".pdf", ".doc", ".docx", ".jpg", ".jpeg", ".png", ".gif", ".xls", ".xlsx" };
            if (!allowed.Contains(ext))
                return ApiResult<FileAttachment>.Failure("Định dạng tệp không được hỗ trợ");

            var maxSize = 10 * 1024 * 1024L;
            if (request.Length > maxSize)
                return ApiResult<FileAttachment>.Failure("Kích thước tệp tối đa 10MB");

            var folder = Path.Combine(_uploadRoot, request.TableName);
            if (!Directory.Exists(folder))
                Directory.CreateDirectory(folder);

            var fileName = $"{Guid.NewGuid()}{ext}";
            var filePath = Path.Combine(folder, fileName);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await request.Content.CopyToAsync(stream);
            }

            var attachment = new FileAttachment
            {
                TableName = request.TableName,
                RefId = request.RefId,
                FileName = request.FileName,
                FilePath = Path.Combine("uploads", request.TableName, fileName),
                FileType = request.ContentType ?? ext,
                FileSize = request.Length
            };

            await _unitOfWork.FileAttachments.AddAsync(attachment);
            await _unitOfWork.CompleteAsync();

            return ApiResult<FileAttachment>.Success(attachment);
        }

        public async Task<ApiResult<bool>> DeleteAsync(Guid id)
        {
            var attachment = await _unitOfWork.FileAttachments
                .Find(x => x.Id == id)
                .FirstOrDefaultAsync();

            if (attachment == null)
                return ApiResult<bool>.Failure("Không tìm thấy tệp");

            var fullPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", attachment.FilePath);
            if (File.Exists(fullPath))
                File.Delete(fullPath);

            _unitOfWork.FileAttachments.Remove(attachment);
            await _unitOfWork.CompleteAsync();

            return ApiResult<bool>.Success(true);
        }

        public async Task<List<FileAttachment>> GetFilesAsync(string tableName, int refId)
        {
            return await _unitOfWork.FileAttachments
                .Find(x => x.TableName == tableName && x.RefId == refId && !x.IsDeleted)
                .OrderByDescending(x => x.CreatedDate)
                .ToListAsync();
        }

        public async Task<FileAttachment?> GetByIdAsync(Guid id)
        {
            return await _unitOfWork.FileAttachments
                .Find(x => x.Id == id && !x.IsDeleted)
                .FirstOrDefaultAsync();
        }

        public string GetFileUrl(FileAttachment file)
        {
            return $"/{file.FilePath.Replace("\\", "/")}";
        }
    }
}