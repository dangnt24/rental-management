using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Rental.Application.Interfaces.Services;
using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;

namespace Rental.Web.Controllers
{
    [IgnoreAntiforgeryToken]
    public class FileController : Controller
    {
        private readonly IFileService _fileService;
        private readonly ILogger<FileController> _logger;

        public FileController(IFileService fileService, ILogger<FileController> logger)
        {
            _fileService = fileService;
            _logger = logger;
        }

        [HttpPost]
        public async Task<IActionResult> Upload(string tableName, int refId, Microsoft.AspNetCore.Http.IFormFile file)
        {
            try
            {
                if (file != null && file.Length > 0)
                {
                    using var stream = file.OpenReadStream();
                    var request = new FileUploadRequest
                    {
                        TableName = tableName,
                        RefId = refId,
                        FileName = file.FileName,
                        ContentType = file.ContentType,
                        Content = stream,
                        Length = file.Length
                    };
                    await _fileService.UploadAsync(request);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Upload failed: {FileName}", file?.FileName);
                TempData["Error"] = "Lỗi upload: " + ex.Message;
            }
            return Redirect(Request.Headers["Referer"].ToString());
        }

        [HttpPost]
        public async Task<IActionResult> UploadMultiple(string tableName, int refId, List<Microsoft.AspNetCore.Http.IFormFile> files)
        {
            try
            {
                if (files != null)
                {
                    foreach (var file in files)
                    {
                        if (file.Length > 0)
                        {
                            using var stream = file.OpenReadStream();
                            var request = new FileUploadRequest
                            {
                                TableName = tableName,
                                RefId = refId,
                                FileName = file.FileName,
                                ContentType = file.ContentType,
                                Content = stream,
                                Length = file.Length
                            };
                            var result = await _fileService.UploadAsync(request);
                            if (!result.IsSuccess)
                            {
                                _logger.LogWarning("Upload file failed: {Reason}", result.Message);
                                TempData["Error"] = result.Message;
                                return Redirect(Request.Headers["Referer"].ToString());
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "UploadMultiple failed for table={Table} refId={RefId}", tableName, refId);
                TempData["Error"] = "Lỗi upload: " + ex.Message;
            }
            return Redirect(Request.Headers["Referer"].ToString());
        }

        public async Task<IActionResult> Download(Guid id)
        {
            var file = await _fileService.GetByIdAsync(id);
            if (file == null) return NotFound();

            var fullPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", file.FilePath);
            if (!System.IO.File.Exists(fullPath))
                return NotFound();

            var contentType = file.FileType ?? "application/octet-stream";
            return PhysicalFile(fullPath, contentType, file.FileName);
        }

        [HttpPost]
        public async Task<IActionResult> DeleteFile(Guid id)
        {
            try
            {
                await _fileService.DeleteAsync(id);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "DeleteFile failed: {Id}", id);
                TempData["Error"] = "Lỗi xóa file: " + ex.Message;
            }
            return Redirect(Request.Headers["Referer"].ToString());
        }
    }
}
