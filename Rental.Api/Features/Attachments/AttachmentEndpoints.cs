using Microsoft.EntityFrameworkCore;
using Rental.Api.Data;
using Rental.Api.Domain;
using Rental.Api.Features.Common;
using Microsoft.AspNetCore.Http.Features;

namespace Rental.Api.Features.Attachments;
public record AttachmentVisibilityRequest(bool IsPublic);
public record AttachmentOrderRequest(int[]? PhotoIds);
public static class AttachmentEndpoints
{
    public static void MapAttachmentEndpoints(this RouteGroupBuilder api, string dataDirectory)
    {
        api.MapPost("/attachments/room/{id:int}/order", async (int id, AttachmentOrderRequest request, AttachmentService service) =>
        {
            await service.OrderRoomPhotos(id, request.PhotoIds);
            return Results.NoContent();
        });
        api.MapDelete("/attachments/{id:int}", async (int id, AttachmentService service, RentalDb db) =>
        {
            var file = await db.Attachments.SingleOrDefaultAsync(x => x.Id == id && !x.IsArchived)
                ?? throw new BusinessError("Không tìm thấy file.", 404);
            await service.CheckAttachmentScope(file.EntityType, file.EntityId);
            // Gỡ khỏi hồ sơ/trang công khai; giữ dấu vết và bản lưu để tránh mất chứng từ.
            file.IsArchived = true;
            file.IsPublic = false;
            await service.Save("attachment.delete", $"File #{id}, {file.EntityType} #{file.EntityId}: {file.OriginalName}");
            return Results.NoContent();
        });
        api.MapPost("/attachments/{id:int}/visibility", async (int id, AttachmentVisibilityRequest r, AttachmentService service, RentalDb db) =>
        {
            var file = await db.Attachments.SingleOrDefaultAsync(x => x.Id == id && !x.IsArchived) ?? throw new BusinessError("Không tìm thấy file.", 404);
            await service.CheckAttachmentScope(file.EntityType, file.EntityId);
            BusinessRules.Require(file.EntityType == "room" && (file.ContentType == "image/jpeg" || file.ContentType == "image/png"), "Chỉ công khai ảnh giới thiệu phòng.");
            file.IsPublic = r.IsPublic;
            await service.Save("attachment.visibility", $"Ảnh #{id}: công khai={r.IsPublic}");
            return Results.NoContent();
        });
        api.MapPost("/attachments/{type}/{id:int}", async (string type, int id, HttpRequest request, AttachmentService service) =>
        {
            await service.CheckAttachmentScope(type, id);
            BusinessRules.Require(request.HasFormContentType, "Cần chọn file đính kèm.");
            const long batchLimit = 102L * 1024 * 1024; // 10 × 10 MB và phần multipart.
            BusinessRules.Require(request.ContentLength == null || request.ContentLength <= batchLimit, "Lượt tải lên vượt giới hạn dung lượng.", 413);
            var sizeFeature = request.HttpContext.Features.Get<IHttpMaxRequestBodySizeFeature>();
            if (sizeFeature is { IsReadOnly: false }) sizeFeature.MaxRequestBodySize = batchLimit;
            IFormCollection form;
            try { form = await request.ReadFormAsync(request.HttpContext.RequestAborted); }
            catch (InvalidDataException) { throw new BusinessError("Dữ liệu tải lên không hợp lệ hoặc vượt giới hạn dung lượng."); }
            var files = form.Files.Where(file => file.Name is "file" or "files").ToArray();
            BusinessRules.Require(files.Length == form.Files.Count, "Tên trường file không hợp lệ.");
            var attachments = await service.UploadFiles(type, id, files, dataDirectory, request.HttpContext);
            // Giữ phản hồi của client cũ gửi một trường `file`; client mới dùng `files`.
            if (files.Length == 1 && files[0].Name == "file")
                return Results.Ok(new { attachments[0].Id, attachments[0].OriginalName, attachments[0].SortOrder });
            return Results.Ok(new { Files = attachments.Select(file => new { file.Id, file.OriginalName, file.SortOrder }) });
        });
        api.MapGet("/attachments/{id:int}", async (int id, AttachmentService service, RentalDb db) =>
        {
            var file = await db.Attachments.SingleOrDefaultAsync(x => x.Id == id && !x.IsArchived) ?? throw new BusinessError("Không tìm thấy file.", 404);
            await service.CheckAttachmentScope(file.EntityType, file.EntityId);
            var path = Path.Combine(dataDirectory, "uploads", Path.GetFileName(file.StoredName));
            BusinessRules.Require(File.Exists(path), "File không còn trên máy chủ.", 404);
            return Results.File(path, file.ContentType, file.OriginalName, enableRangeProcessing: true);
        });
    }
}
