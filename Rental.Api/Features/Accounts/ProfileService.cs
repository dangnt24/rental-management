using Microsoft.EntityFrameworkCore;
using Rental.Api.Data;
using Rental.Api.Domain;
using Rental.Api.Features.Common;
using static Rental.Api.Features.Common.BusinessRules;

namespace Rental.Api.Features.Accounts;

/// <summary>Chỉ cho sửa tên/ảnh của chính mình; email/phone do chủ trọ quản lý.</summary>
public sealed class ProfileService(RentalDb database, IHttpContextAccessor accessor) : FeatureService(database, accessor)
{
    public async Task<object> Update(HttpRequest request, string dataDirectory)
    {
        Require(request.HasFormContentType, "Dữ liệu hồ sơ không hợp lệ.");
        var form = await request.ReadFormAsync(request.HttpContext.RequestAborted);
        Require(form.Keys.All(key => key.Equals("fullName", StringComparison.OrdinalIgnoreCase)) && form["fullName"].Count == 1, "Chỉ được tự sửa tên và ảnh đại diện. Email, số điện thoại và quyền do quản trị viên quản lý.");
        Require(form.Files.Count <= 1 && form.Files.All(file => file.Name == "avatar"), "Chỉ chọn một ảnh đại diện.");
        var user = await db.Users.FindAsync(UserId) ?? throw new BusinessError("Không tìm thấy tài khoản.", 401);
        user.FullName = Text(form["fullName"].ToString(), "Họ tên", 100);
        if (form.Files.Count == 1)
        {
            var file = form.Files[0];
            Require(file.Length is > 0 and <= 2 * 1024 * 1024, "Ảnh đại diện tối đa 2 MB.");
            var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
            Require(extension is ".jpg" or ".jpeg" or ".png", "Ảnh đại diện chỉ nhận JPG hoặc PNG.");
            await using var input = file.OpenReadStream();
            var signature = new byte[8];
            var read = await input.ReadAtLeastAsync(signature, (int)Math.Min(file.Length, 8), throwOnEndOfStream: false, request.HttpContext.RequestAborted);
            var png = read >= 8 && signature.AsSpan(0, 8).SequenceEqual(new byte[] { 137, 80, 78, 71, 13, 10, 26, 10 });
            var jpeg = read >= 3 && signature[0] == 255 && signature[1] == 216 && signature[2] == 255;
            Require(extension == ".png" ? png : jpeg, "Nội dung ảnh đại diện không đúng định dạng.");
            var name = Guid.NewGuid().ToString("N") + extension;
            var directory = Path.Combine(dataDirectory, "avatars");
            Directory.CreateDirectory(directory);
            var path = Path.Combine(directory, name);
            request.HttpContext.Items["uploaded_files"] = new List<string> { path };
            await using (var output = File.Create(path)) await file.CopyToAsync(output, request.HttpContext.RequestAborted);
            user.AvatarStoredName = name;
            user.AvatarVersion++;
        }
        await Save("user.profile", $"Cập nhật tên/ảnh tài khoản #{UserId}");
        return UserService.View(user);
    }

    public async Task<(string Path, string ContentType)> Avatar(int id, string dataDirectory)
    {
        Require(id == UserId || IsOwner, "Không có quyền xem ảnh tài khoản này.", 403);
        var user = await db.Users.AsNoTracking().SingleOrDefaultAsync(x => x.Id == id && !x.IsArchived) ?? throw new BusinessError("Không tìm thấy tài khoản.", 404);
        Require(user.AvatarStoredName.Length > 0, "Tài khoản chưa có ảnh đại diện.", 404);
        var path = Path.Combine(dataDirectory, "avatars", Path.GetFileName(user.AvatarStoredName));
        Require(File.Exists(path), "Không tìm thấy ảnh đại diện.", 404);
        return (path, Path.GetExtension(path) == ".png" ? "image/png" : "image/jpeg");
    }
}
