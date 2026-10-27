using Microsoft.EntityFrameworkCore;
using Rental.Api.Data;
using Rental.Api.Domain;
using Rental.Api.Features.Common;

namespace Rental.Api.Features.Attachments;
public record AttachmentVisibilityRequest(bool IsPublic);
public static class AttachmentEndpoints
{
    public static void MapAttachmentEndpoints(this RouteGroupBuilder api, string dataDirectory)
    {
        api.MapPost("/attachments/{id:int}/visibility", async (int id, AttachmentVisibilityRequest r, AttachmentService service, RentalDb db) =>
        {
            var file = await db.Attachments.FindAsync(id) ?? throw new BusinessError("Không tìm thấy file.", 404);
            await service.CheckAttachmentScope(file.EntityType, file.EntityId);
            BusinessRules.Require(file.EntityType == "room" && (file.ContentType == "image/jpeg" || file.ContentType == "image/png"), "Chỉ công khai ảnh giới thiệu phòng.");
            file.IsPublic = r.IsPublic;
            await service.Save("attachment.visibility", $"Ảnh #{id}: công khai={r.IsPublic}");
            return Results.NoContent();
        });
        api.MapPost("/attachments/{type}/{id:int}", async (string type, int id, HttpRequest request, AttachmentService service, RentalDb db) =>
        {
            await service.CheckAttachmentScope(type, id);
            BusinessRules.Require(request.HasFormContentType, "Cần chọn file đính kèm.");
            var form = await request.ReadFormAsync();
            var file = form.Files.GetFile("file");
            BusinessRules.Require(file != null && file.Length is> 0 and <= 5 * 1024 * 1024, "File phải có dung lượng từ 1 byte đến 5 MB.");
            var extension = Path.GetExtension(file!.FileName).ToLowerInvariant();
            var originalName = Path.GetFileName(file.FileName);
            BusinessRules.Require(originalName.Length <= 250, "Tên file quá dài.");
            BusinessRules.Require(new[] { ".jpg", ".jpeg", ".png", ".pdf" }.Contains(extension), "Chỉ chấp nhận JPG, PNG hoặc PDF.");
            await using var stream = file.OpenReadStream();
            var signature = new byte[8];
            var read = await stream.ReadAsync(signature);
            var isPdf = read >= 5 && signature.AsSpan(0, 5).SequenceEqual("%PDF-"u8);
            var isPng = read >= 8 && signature.AsSpan(0, 8).SequenceEqual(new byte[] { 137, 80, 78, 71, 13, 10, 26, 10 });
            var isJpeg = read >= 3 && signature[0] == 255 && signature[1] == 216 && signature[2] == 255;
            BusinessRules.Require(extension == ".pdf" && isPdf || extension == ".png" && isPng || (extension is ".jpg" or ".jpeg") && isJpeg, "Nội dung file không khớp định dạng.");
            var directory = Path.Combine(dataDirectory, "uploads");
            Directory.CreateDirectory(directory);
            var name = Guid.NewGuid().ToString("N") + extension;
            request.HttpContext.Items["uploaded_file"] = Path.Combine(directory, name);
            await using (var target = File.Create(Path.Combine(directory, name)))
            {
                await target.WriteAsync(signature.AsMemory(0, read));
                await stream.CopyToAsync(target);
            }

            var attachment = new Attachment
            {
                EntityType = type,
                EntityId = id,
                OriginalName = originalName,
                StoredName = name,
                ContentType = isPdf ? "application/pdf" : isPng ? "image/png" : "image/jpeg",
                Size = file.Length
            };
            db.Attachments.Add(attachment);
            await service.Save("attachment.upload", $"{type} #{id}");
            return Results.Ok(new { attachment.Id, attachment.OriginalName });
        });
        api.MapGet("/attachments/{id:int}", async (int id, AttachmentService service, RentalDb db) =>
        {
            var file = await db.Attachments.FindAsync(id) ?? throw new BusinessError("Không tìm thấy file.", 404);
            await service.CheckAttachmentScope(file.EntityType, file.EntityId);
            var path = Path.Combine(dataDirectory, "uploads", Path.GetFileName(file.StoredName));
            BusinessRules.Require(File.Exists(path), "File không còn trên máy chủ.", 404);
            return Results.File(path, file.ContentType, file.OriginalName, enableRangeProcessing: true);
        });
    }
}
