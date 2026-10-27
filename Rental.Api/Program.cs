using System.Data;
using System.Security.Claims;
using System.Threading.RateLimiting;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.DataProtection;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.EntityFrameworkCore;
using Rental.Api.Data;
using Rental.Api.Domain;
using Rental.Api.Features.Common;
using Rental.Api.Features.Branches;
using Rental.Api.Features.Rooms;
using Rental.Api.Features.Tenants;
using Rental.Api.Features.Fees;
using Rental.Api.Features.Contracts;
using Rental.Api.Features.Deposits;
using Rental.Api.Features.Billing;
using Rental.Api.Features.Payments;
using Rental.Api.Features.Incidents;
using Rental.Api.Features.Accounts;
using Rental.Api.Features.Attachments;
using Rental.Api.Features.Workspace;
using Rental.Api.Features.Catalog;
using Rental.Api.Features.TenantPortal;

var builder = WebApplication.CreateBuilder(args);
// Cấu hình riêng của máy không đưa lên Git; môi trường/CLI vẫn có độ ưu tiên cao hơn.
builder.Configuration.AddJsonFile("appsettings.Local.json", optional: true, reloadOnChange: false).AddEnvironmentVariables().AddCommandLine(args);
builder.Logging.ClearProviders();
builder.Logging.AddConsole();
var dataDirectory = Path.GetFullPath(builder.Configuration["Database:DataDirectory"] ?? Path.Combine(builder.Environment.ContentRootPath, "App_Data"));
Directory.CreateDirectory(dataDirectory);
builder.Services.AddDataProtection().PersistKeysToFileSystem(new DirectoryInfo(Path.Combine(dataDirectory, "keys"))).SetApplicationName("RentalManagement");
// Ứng dụng chỉ dùng PostgreSQL; RentalDb định nghĩa cách entity ánh xạ vào bảng.
builder.Services.AddDbContext<RentalDb>(o =>
    o.UseNpgsql(builder.Configuration.GetConnectionString("Rental")
        ?? throw new InvalidOperationException("Thiếu ConnectionStrings:Rental.")));
builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<BranchService>();
builder.Services.AddScoped<RoomService>();
builder.Services.AddScoped<TenantService>();
builder.Services.AddScoped<FeeService>();
builder.Services.AddScoped<ContractService>();
builder.Services.AddScoped<DepositService>();
builder.Services.AddScoped<ReadingService>();
builder.Services.AddScoped<InvoiceService>();
builder.Services.AddScoped<PaymentService>();
builder.Services.AddScoped<IncidentService>();
builder.Services.AddScoped<UserService>();
builder.Services.AddScoped<AttachmentService>();
builder.Services.AddScoped<WorkspaceService>();
builder.Services.AddScoped<CatalogService>();
builder.Services.AddScoped<TenantPortalService>();
builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme).AddCookie(o =>
{
    o.Cookie.Name = "rental.session";
    o.Cookie.HttpOnly = true;
    o.Cookie.SameSite = SameSiteMode.Strict;
    o.Cookie.SecurePolicy = CookieSecurePolicy.SameAsRequest;
    o.ExpireTimeSpan = TimeSpan.FromHours(8);
    o.SlidingExpiration = false;
    o.Events.OnRedirectToLogin = ctx =>
    {
        ctx.Response.StatusCode = 401;
        return Task.CompletedTask;
    };
    o.Events.OnRedirectToAccessDenied = ctx =>
    {
        ctx.Response.StatusCode = 403;
        return Task.CompletedTask;
    };
    o.Events.OnValidatePrincipal = async ctx =>
    {
        var db = ctx.HttpContext.RequestServices.GetRequiredService<RentalDb>();
        var userId = int.TryParse(ctx.Principal?.FindFirstValue(ClaimTypes.NameIdentifier), out var id) ? id : 0;
        var user = await db.Users.AsNoTracking().SingleOrDefaultAsync(x => x.Id == userId);
        if (user == null || !user.IsActive || user.Role != ctx.Principal?.FindFirstValue(ClaimTypes.Role) || ctx.Principal?.FindFirstValue("tenant") != (user.TenantId?.ToString() ?? "") || ctx.Principal?.FindFirstValue("credential") != CredentialStamp(user.PasswordHash))
        {
            ctx.RejectPrincipal();
            await ctx.HttpContext.SignOutAsync();
        }
    };
});
builder.Services.AddAuthorization();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddRateLimiter(o =>
{
    o.RejectionStatusCode = 429;
    o.AddPolicy("login", c => RateLimitPartition.GetFixedWindowLimiter(c.Connection.RemoteIpAddress?.ToString() ?? "local", _ => new FixedWindowRateLimiterOptions { PermitLimit = 10, Window = TimeSpan.FromMinutes(1), QueueLimit = 0 }));
});
builder.WebHost.ConfigureKestrel(o => o.Limits.MaxRequestBodySize = 6 * 1024 * 1024);
var app = builder.Build();
if (args.Contains("--export-schema"))
{
    using var exportDb = new RentalDb(new DbContextOptionsBuilder<RentalDb>().UseNpgsql("Host=localhost;Database=rental;Username=unused").Options);
    var target = Path.GetFullPath(Path.Combine(app.Environment.ContentRootPath, "../Database/01_schema.sql"));
    Directory.CreateDirectory(Path.GetDirectoryName(target)!);
    await File.WriteAllTextAsync(target, "-- PostgreSQL 16+. Chạy trên database trống. Không xóa dữ liệu cũ.\n-- Sinh từ RentalDb; không trộn với bộ SQL V2 cũ.\nBEGIN;\n" + exportDb.Database.GenerateCreateScript() + "\nCOMMIT;\n");
    Console.WriteLine(target);
    return;
}

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<RentalDb>();
    if (!await db.Database.CanConnectAsync())
        throw new InvalidOperationException("Không kết nối PostgreSQL. Chạy Database/01_schema.sql và 02_sample.sql trước.");
    try
    {
        await db.Users.OrderBy(x => x.Id).Select(x => x.TenantId).Take(1).ToListAsync();
    }
    catch (Npgsql.PostgresException ex) when (ex.SqlState == "42703")
    {
        throw new InvalidOperationException("Database chưa cập nhật. Chạy Database/03_public_tenant.sql trước khi mở bản mới.", ex);
    }
    if (builder.Configuration.GetValue<bool>("Database:SeedDemo") && !await db.Users.AnyAsync())
    {
        var samplePath = Path.Combine(AppContext.BaseDirectory, "Database", "02_sample.sql");
        var sql = await File.ReadAllTextAsync(samplePath);
        await using var tx = await db.Database.BeginTransactionAsync();
        await db.Database.ExecuteSqlRawAsync(sql);
        await tx.CommitAsync();
    }
}

app.Use(async (ctx, next) =>
{
    ctx.Response.Headers["X-Content-Type-Options"] = "nosniff";
    ctx.Response.Headers["Referrer-Policy"] = "same-origin";
    ctx.Response.Headers["Content-Security-Policy"] = "default-src 'self'; img-src 'self' blob: data:; style-src 'self' 'unsafe-inline'; script-src 'self'; connect-src 'self'; frame-ancestors 'none'; object-src 'none'; base-uri 'self'";
    if (ctx.Request.Path.StartsWithSegments("/api"))
        ctx.Response.Headers.CacheControl = "no-store";
    try
    {
        // Header riêng và không bật CORS ngăn website khác gửi yêu cầu ghi bằng cookie của người dùng.
        if (ctx.Request.Path.StartsWithSegments("/api") && !HttpMethods.IsGet(ctx.Request.Method) && !HttpMethods.IsHead(ctx.Request.Method))
            BusinessRules.Require(ctx.Request.Headers["X-Rental-Request"] == "1", "Yêu cầu thiếu header xác thực nguồn.", 403);
        await next();
    }
    catch (BusinessError ex)
    {
        ctx.Response.StatusCode = ex.Status;
        await ctx.Response.WriteAsJsonAsync(new { error = ex.Message });
    }
    catch (DbUpdateException ex)
    {
        app.Logger.LogWarning(ex, "Database rejected update");
        ctx.Response.StatusCode = 409;
        await ctx.Response.WriteAsJsonAsync(new { error = "Dữ liệu trùng hoặc đã thay đổi. Tải lại và kiểm tra tên, kỳ thu hoặc hợp đồng." });
    }
    catch (Npgsql.PostgresException ex) when (ex.SqlState == "40001")
    {
        ctx.Response.StatusCode = 409;
        await ctx.Response.WriteAsJsonAsync(new { error = "Có thao tác đồng thời. Tải lại dữ liệu trước khi thử lại." });
    }
    catch (Exception ex)
    {
        app.Logger.LogError(ex, "Request failed");
        ctx.Response.StatusCode = 500;
        await ctx.Response.WriteAsJsonAsync(new { error = "Không thể hoàn tất thao tác. Vui lòng kiểm tra log máy chủ." });
    }
});
app.UseDefaultFiles();
app.UseStaticFiles();
app.UseRateLimiter();
app.UseAuthentication();
app.UseAuthorization();
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.MapGet("/api/health", () => new { application = "RentalManagement", status = "ok", database = "PostgreSQL", demo = builder.Configuration.GetValue<bool>("Database:SeedDemo") });
app.MapPost("/api/auth/login", async (LoginRequest r, RentalDb db, HttpContext context) =>
{
    var username = (r.Username ?? "").Trim().ToLowerInvariant();
    BusinessRules.Require(username.Length <= 50 && r.Password?.Length <= 128, "Thông tin đăng nhập không hợp lệ.", 401);
    var user = await db.Users.SingleOrDefaultAsync(x => x.Username == username && x.IsActive);
    var valid = user != null && new PasswordHasher<User>().VerifyHashedPassword(user, user.PasswordHash, r.Password ?? "") != PasswordVerificationResult.Failed;
    BusinessRules.Require(valid, "Tên đăng nhập hoặc mật khẩu không đúng.", 401);
    var identity = new ClaimsIdentity(new[] { new Claim(ClaimTypes.NameIdentifier, user!.Id.ToString()), new Claim(ClaimTypes.Name, user.Username), new Claim(ClaimTypes.Role, user.Role), new Claim("tenant", user.TenantId?.ToString() ?? ""), new Claim("credential", CredentialStamp(user.PasswordHash)) }, CookieAuthenticationDefaults.AuthenticationScheme);
    await context.SignInAsync(new ClaimsPrincipal(identity));
    return Results.Ok(new { user.Id, user.Username, user.FullName, user.Role });
}).RequireRateLimiting("login");
var api = app.MapGroup("/api").RequireAuthorization().AddEndpointFilter<WriteTransactionFilter>();
api.MapGet("/auth/me", async (HttpContext context, RentalDb db) =>
{
    var id = int.Parse(context.User.FindFirstValue(ClaimTypes.NameIdentifier)!);
    return await db.Users.Where(x => x.Id == id).Select(x => new { x.Id, x.Username, x.FullName, x.Role }).SingleAsync();
});
api.MapPost("/auth/logout", async (HttpContext c) =>
{
    await c.SignOutAsync();
    return Results.NoContent();
});
api.MapPost("/auth/password", async (PasswordRequest r, UserService s) =>
{
    await s.ChangePassword(r);
    return Results.NoContent();
});
// Ba phạm vi riêng: khách công khai, người thuê, nhân sự quản lý.
var publicApi = app.MapGroup("/api/public").AllowAnonymous();
publicApi.MapGet("/rooms", (string? q, int? branchId, long? minPrice, long? maxPrice, int? capacity, string? sort, CatalogService s) => s.Browse(q, branchId, minPrice, maxPrice, capacity, sort));
publicApi.MapGet("/rooms/{roomId:int}/photos/{id:int}", async (int roomId, int id, CatalogService s) =>
{
    var photo = await s.Photo(roomId, id);
    var path = Path.Combine(dataDirectory, "uploads", Path.GetFileName(photo.StoredName));
    BusinessRules.Require(File.Exists(path), "Ảnh không còn trên máy chủ.", 404);
    return Results.File(path, photo.ContentType, enableRangeProcessing: true);
});
var tenantApi = api.MapGroup("/tenant").RequireAuthorization(p => p.RequireRole("Tenant"));
tenantApi.MapGet("/workspace", (TenantPortalService s) => s.Workspace());
tenantApi.MapPost("/incidents", (TenantIncidentRequest r, TenantPortalService s) => s.ReportIncident(r));

var staff = api.MapGroup("").RequireAuthorization(p => p.RequireRole("Owner", "Manager"));
staff.MapGet("/workspace", (WorkspaceService s) => s.Workspace());
staff.MapPost("/branches", (BranchRequest r, BranchService s) => s.UpsertBranch(null, r));
staff.MapPut("/branches/{id:int}", (int id, BranchRequest r, BranchService s) => s.UpsertBranch(id, r));
staff.MapPost("/rooms", (RoomRequest r, RoomService s) => s.UpsertRoom(null, r));
staff.MapPut("/rooms/{id:int}", (int id, RoomRequest r, RoomService s) => s.UpsertRoom(id, r));
staff.MapDelete("/rooms/{id:int}", async (int id, RoomService s) =>
{
    await s.ArchiveRoom(id);
    return Results.NoContent();
});
staff.MapPost("/tenants", (TenantRequest r, TenantService s) => s.UpsertTenant(null, r));
staff.MapPut("/tenants/{id:int}", (int id, TenantRequest r, TenantService s) => s.UpsertTenant(id, r));
staff.MapPost("/fees", (FeeRequest r, FeeService s) => s.UpsertFee(null, r));
staff.MapPut("/fees/{id:int}", (int id, FeeRequest r, FeeService s) => s.UpsertFee(id, r));
staff.MapPost("/contracts", (ContractRequest r, ContractService s) => s.CreateContract(r));
staff.MapPost("/contracts/{id:int}/renew", async (int id, RenewContractRequest r, ContractService s) =>
{
    await s.RenewContract(id, r);
    return Results.NoContent();
});
staff.MapPost("/contracts/{id:int}/deposit", async (int id, DepositRequest r, DepositService s) =>
{
    await s.ReceiveDeposit(id, r);
    return Results.NoContent();
});
staff.MapPost("/contracts/{id:int}/close", async (int id, CloseContractRequest r, ContractService s) =>
{
    await s.CloseContract(id, r);
    return Results.NoContent();
});
staff.MapPost("/readings", (ReadingRequest r, ReadingService s) => s.RecordReading(r));
staff.MapPost("/invoices", (InvoiceRequest r, InvoiceService s) => s.GenerateInvoice(r));
staff.MapGet("/invoices/{id:int}", (int id, InvoiceService s) => s.InvoiceDetail(id));
staff.MapPost("/invoices/{id:int}/cancel", async (int id, CancelInvoiceRequest r, InvoiceService s) =>
{
    await s.CancelInvoice(id, r);
    return Results.NoContent();
});
staff.MapPost("/payments", (PaymentRequest r, PaymentService s) => s.RecordPayment(r));
staff.MapPost("/incidents", (IncidentRequest r, IncidentService s) => s.UpsertIncident(null, r));
staff.MapPut("/incidents/{id:int}", (int id, IncidentRequest r, IncidentService s) => s.UpsertIncident(id, r));
staff.MapPost("/users", (UserRequest r, UserService s) => s.UpsertUser(null, r));
staff.MapPut("/users/{id:int}", (int id, UserRequest r, UserService s) => s.UpsertUser(id, r));
staff.MapAttachmentEndpoints(dataDirectory);
app.MapFallback(async context =>
{
    if (context.Request.Path.StartsWithSegments("/api"))
    {
        context.Response.StatusCode = 404;
        await context.Response.WriteAsJsonAsync(new { error = "Không tìm thấy API." });
        return;
    }

    var index = Path.Combine(app.Environment.WebRootPath ?? Path.Combine(app.Environment.ContentRootPath, "wwwroot"), "index.html");
    if (File.Exists(index))
    {
        context.Response.ContentType = "text/html; charset=utf-8";
        await context.Response.SendFileAsync(index);
    }
    else
    {
        context.Response.StatusCode = 503;
        await context.Response.WriteAsync("Chay Start.ps1 de build giao dien truoc.");
    }
});
app.Run();
static string CredentialStamp(string hash) => Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(System.Text.Encoding.UTF8.GetBytes(hash)));
/// <summary>Ghi nghiệp vụ và audit trong cùng giao dịch; PostgreSQL kiểm soát ghi đồng thời bằng serializable.</summary>
public sealed class WriteTransactionFilter(RentalDb db) : IEndpointFilter
{
    private static readonly SemaphoreSlim Gate = new(1, 1);
    public async ValueTask<object?> InvokeAsync(EndpointFilterInvocationContext context, EndpointFilterDelegate next)
    {
        if (HttpMethods.IsGet(context.HttpContext.Request.Method) || HttpMethods.IsHead(context.HttpContext.Request.Method))
            return await next(context);
        await Gate.WaitAsync(context.HttpContext.RequestAborted);
        try
        {
            await using var transaction = await db.Database.BeginTransactionAsync(IsolationLevel.Serializable, context.HttpContext.RequestAborted);
            try
            {
                var result = await next(context);
                await transaction.CommitAsync(context.HttpContext.RequestAborted);
                return result;
            }
            catch
            {
                if (context.HttpContext.Items["uploaded_file"] is string path && File.Exists(path))
                    File.Delete(path);
                throw;
            }
        }
        finally
        {
            Gate.Release();
        }
    }
}
