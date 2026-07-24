using Rental.Core;
using Rental.Domain.Entities;
using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;

namespace Rental.Application.Interfaces.Services
{
    public class FileUploadRequest
    {
        public string TableName { get; set; }
        public int RefId { get; set; }
        public string FileName { get; set; }
        public string ContentType { get; set; }
        public Stream Content { get; set; }
        public long Length { get; set; }
    }

    public interface IFileService
    {
        Task<ApiResult<FileAttachment>> UploadAsync(FileUploadRequest request);
        Task<ApiResult<bool>> DeleteAsync(Guid id);
        Task<List<FileAttachment>> GetFilesAsync(string tableName, int refId);
        Task<FileAttachment?> GetByIdAsync(Guid id);
        string GetFileUrl(FileAttachment file);
    }
}