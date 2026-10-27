namespace Rental.Api.Domain;

/// <summary>Thông tin tạo lập để giữ dấu vết nghiệp vụ.</summary>
public abstract class Entity
{
    public int Id { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public string CreatedBy { get; set; } = "system";
    public bool IsArchived { get; set; }
}

public sealed class Branch : Entity
{
    public string Name { get; set; } = "";
    public string Address { get; set; } = "";
}

public sealed class User : Entity
{
    public string Username { get; set; } = "";
    public string FullName { get; set; } = "";
    public string PasswordHash { get; set; } = "";
    public string Role { get; set; } = "Manager";
    public bool IsActive { get; set; } = true;
    public int? TenantId { get; set; }
}

public sealed class UserBranch
{
    public int UserId { get; set; }
    public int BranchId { get; set; }
}

public sealed class Room : Entity
{
    public int BranchId { get; set; }
    public string Name { get; set; } = "";
    public long Price { get; set; }
    public int Capacity { get; set; } = 2;
    public bool IsMaintenance { get; set; }
    public string Description { get; set; } = "";
}

public sealed class Tenant : Entity
{
    public int BranchId { get; set; }
    public string FullName { get; set; } = "";
    public string Phone { get; set; } = "";
    public string IdentityNumber { get; set; } = "";
    public string Address { get; set; } = "";
}

public sealed class Contract : Entity
{
    public int RoomId { get; set; }
    public DateOnly StartDate { get; set; }
    public DateOnly EndDate { get; set; }
    public DateOnly? ClosedDate { get; set; }
    public long Rent { get; set; }
    public long Deposit { get; set; }
    public string Status { get; set; } = "Active";
    public string Note { get; set; } = "";
}

public sealed class ContractTenant
{
    public int ContractId { get; set; }
    public int TenantId { get; set; }
    public bool IsRepresentative { get; set; }
}

public sealed class Fee : Entity
{
    public int BranchId { get; set; }
    public string Name { get; set; } = "";
    public string Method { get; set; } = "Fixed";
    public long UnitPrice { get; set; }
}

public sealed class Reading : Entity
{
    public int ContractId { get; set; }
    public int Year { get; set; }
    public int Month { get; set; }
    public decimal ElectricityOld { get; set; }
    public decimal ElectricityNew { get; set; }
    public decimal WaterOld { get; set; }
    public decimal WaterNew { get; set; }
}

public sealed class Invoice : Entity
{
    public int ContractId { get; set; }
    public int Year { get; set; }
    public int Month { get; set; }
    public DateOnly DueDate { get; set; }
    public long Total { get; set; }
    public string Status { get; set; } = "Issued";
    public string CancellationReason { get; set; } = "";
    public List<InvoiceItem> Items { get; set; } = [];
}

public sealed class InvoiceItem
{
    public int Id { get; set; }
    public int InvoiceId { get; set; }
    public string Description { get; set; } = "";
    public decimal Quantity { get; set; }
    public long UnitPrice { get; set; }
    public long Amount { get; set; }
}

public sealed class Payment : Entity
{
    public int InvoiceId { get; set; }
    public long Amount { get; set; }
    public string Method { get; set; } = "Cash";
    public DateOnly PaidDate { get; set; }
    public string Note { get; set; } = "";
}

public sealed class DepositEntry : Entity
{
    public int ContractId { get; set; }
    public string Type { get; set; } = "Received";
    public long Amount { get; set; }
    public string Note { get; set; } = "";
}

public sealed class Incident : Entity
{
    public int RoomId { get; set; }
    public int? ReportedByTenantId { get; set; }
    public string Description { get; set; } = "";
    public string Status { get; set; } = "Open";
    public string Resolution { get; set; } = "";
    public long Cost { get; set; }
}

public sealed class Attachment : Entity
{
    public bool IsPublic { get; set; }
    public string EntityType { get; set; } = "";
    public int EntityId { get; set; }
    public string OriginalName { get; set; } = "";
    public string StoredName { get; set; } = "";
    public string ContentType { get; set; } = "";
    public long Size { get; set; }
}

public sealed class AuditEntry : Entity
{
    public string Action { get; set; } = "";
    public string Detail { get; set; } = "";
}
