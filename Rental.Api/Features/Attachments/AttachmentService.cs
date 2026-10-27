using Microsoft.EntityFrameworkCore;
using Rental.Api.Data;
using Rental.Api.Domain;
using Rental.Api.Features.Common;
using static Rental.Api.Features.Common.BusinessRules;

namespace Rental.Api.Features.Attachments;
/// <summary>Phạm vi quyền truy cập file; thao tác ghi dùng giao dịch chung của endpoint filter.</summary>
public sealed class AttachmentService(RentalDb database, IHttpContextAccessor accessor) : FeatureService(database, accessor)
{
    public async Task OrderRoomPhotos(int roomId, int[]? photoIds)
    {
        await CheckAttachmentScope("room", roomId);
        var photos = await db.Attachments.Where(x => x.EntityType == "room" && x.EntityId == roomId && !x.IsArchived && (x.ContentType == "image/jpeg" || x.ContentType == "image/png")).ToListAsync();
        Require(photoIds != null && photoIds.Length == photoIds.Distinct().Count(), "Thứ tự ảnh không hợp lệ hoặc có ảnh trùng.");
        Require(photoIds!.Length == photos.Count && photoIds.ToHashSet().SetEquals(photos.Select(x => x.Id)), "Danh sách ảnh đã thay đổi hoặc có ảnh không thuộc phòng. Hãy tải lại danh sách trước khi lưu thứ tự.", 409);
        var byId = photos.ToDictionary(x => x.Id);
        for (var index = 0; index < photoIds.Length; index++) byId[photoIds[index]].SortOrder = index;
        await Save("attachment.order", $"Thứ tự ảnh phòng #{roomId}: {string.Join(',', photoIds)}");
    }

    // Endpoint đã kiểm tra phạm vi trước khi đọc multipart. Kiểm tra cả lượt trước khi tạo file.
    public async Task<List<Attachment>> UploadFiles(string type, int id, IFormFile[] files, string dataDirectory, HttpContext context)
    {
        Require(files.Length is >= 1 and <= 10, "Mỗi lượt chọn từ 1 đến 10 file.");
        var validated = new List<(IFormFile File, string OriginalName, string Extension, string ContentType)>();
        foreach (var file in files)
        {
            Require(file.Length is > 0 and <= 10 * 1024 * 1024, $"File “{Path.GetFileName(file.FileName)}” phải có dung lượng từ 1 byte đến 10 MB.");
            var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
            var originalName = Path.GetFileName(file.FileName);
            Require(originalName.Length is > 0 and <= 250, "Tên file phải từ 1 đến 250 ký tự.");
            Require(new[] { ".jpg", ".jpeg", ".png", ".pdf" }.Contains(extension), $"File “{originalName}”: chỉ chấp nhận JPG, PNG hoặc PDF.");
            await using var stream = file.OpenReadStream();
            var signature = new byte[8];
            var read = 0;
            while (read < signature.Length)
            {
                var count = await stream.ReadAsync(signature.AsMemory(read), context.RequestAborted);
                if (count == 0) break;
                read += count;
            }
            var pdf = read >= 5 && signature.AsSpan(0, 5).SequenceEqual("%PDF-"u8);
            var png = read >= 8 && signature.AsSpan(0, 8).SequenceEqual(new byte[] { 137, 80, 78, 71, 13, 10, 26, 10 });
            var jpeg = read >= 3 && signature[0] == 255 && signature[1] == 216 && signature[2] == 255;
            Require(extension == ".pdf" && pdf || extension == ".png" && png || (extension is ".jpg" or ".jpeg") && jpeg, $"Nội dung file “{originalName}” không khớp định dạng.");
            validated.Add((file, originalName, extension, pdf ? "application/pdf" : png ? "image/png" : "image/jpeg"));
        }
        var nextOrder = (await db.Attachments.Where(x => x.EntityType == type && x.EntityId == id && !x.IsArchived).MaxAsync(x => (int?)x.SortOrder) ?? -1) + 1;
        var directory = Path.Combine(dataDirectory, "uploads");
        Directory.CreateDirectory(directory);
        var paths = new List<string>();
        context.Items["uploaded_files"] = paths;
        var attachments = new List<Attachment>();
        foreach (var item in validated)
        {
            var storedName = Guid.NewGuid().ToString("N") + item.Extension;
            var path = Path.Combine(directory, storedName);
            paths.Add(path);
            await using (var output = File.Create(path)) await item.File.CopyToAsync(output, context.RequestAborted);
            attachments.Add(new Attachment { EntityType = type, EntityId = id, OriginalName = item.OriginalName, StoredName = storedName, ContentType = item.ContentType, Size = item.File.Length, SortOrder = nextOrder++ });
        }
        db.Attachments.AddRange(attachments);
        await Save("attachment.upload", $"{type} #{id}: {attachments.Count} file");
        return attachments;
    }

    public async Task CheckAttachmentScope(string type, int id)
    {
        switch (type)
        {
            case "room":
                await Room(id);
                break;
            case "contract":
                await Contract(id);
                break;
            case "tenant":
                var tenant = await db.Tenants.FindAsync(id) ?? throw new BusinessError("Không tìm thấy người thuê.", 404);
                await CheckBranch(tenant.BranchId);
                break;
            case "incident":
                var incident = await db.Incidents.FindAsync(id) ?? throw new BusinessError("Không tìm thấy sự cố.", 404);
                await Room(incident.RoomId);
                break;
            case "payment":
                var payment = await db.Payments.FindAsync(id) ?? throw new BusinessError("Không tìm thấy thanh toán.", 404);
                await Invoice(payment.InvoiceId);
                break;
            default:
                throw new BusinessError("Loại file đính kèm không hợp lệ.");
        }
    }
}
