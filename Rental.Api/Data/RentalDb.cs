using Microsoft.EntityFrameworkCore;
using Rental.Api.Domain;

namespace Rental.Api.Data;

/// <summary>Ánh xạ entity C# sang bảng, quan hệ và ràng buộc PostgreSQL.</summary>
public sealed class RentalDb(DbContextOptions<RentalDb> options) : DbContext(options)
{
    public DbSet<Branch> Branches => Set<Branch>();
    public DbSet<User> Users => Set<User>();
    public DbSet<UserBranch> UserBranches => Set<UserBranch>();
    public DbSet<Room> Rooms => Set<Room>();
    public DbSet<Tenant> Tenants => Set<Tenant>();
    public DbSet<Contract> Contracts => Set<Contract>();
    public DbSet<ContractTenant> ContractTenants => Set<ContractTenant>();
    public DbSet<Fee> Fees => Set<Fee>();
    public DbSet<Reading> Readings => Set<Reading>();
    public DbSet<Invoice> Invoices => Set<Invoice>();
    public DbSet<Payment> Payments => Set<Payment>();
    public DbSet<DepositEntry> DepositEntries => Set<DepositEntry>();
    public DbSet<Incident> Incidents => Set<Incident>();
    public DbSet<Attachment> Attachments => Set<Attachment>();
    public DbSet<AuditEntry> AuditEntries => Set<AuditEntry>();

    protected override void OnModelCreating(ModelBuilder b)
    {
        b.Entity<Branch>().ToTable("branches");
        b.Entity<User>().ToTable("users", t =>
        {
            t.HasCheckConstraint("ck_user_role", "\"Role\" IN ('Owner','Manager','Tenant')");
            t.HasCheckConstraint("ck_user_tenant", "(\"Role\" = 'Tenant' AND \"TenantId\" IS NOT NULL) OR (\"Role\" <> 'Tenant' AND \"TenantId\" IS NULL)");
        });
        b.Entity<User>().HasIndex(x => x.Username).IsUnique();
        b.Entity<User>().HasIndex(x => x.TenantId).IsUnique();
        b.Entity<User>().HasOne<Tenant>().WithMany().HasForeignKey(x => x.TenantId).OnDelete(DeleteBehavior.Restrict);
        b.Entity<UserBranch>().ToTable("user_branches").HasKey(x => new { x.UserId, x.BranchId });
        b.Entity<UserBranch>().HasOne<User>().WithMany().HasForeignKey(x => x.UserId).OnDelete(DeleteBehavior.Restrict);
        b.Entity<UserBranch>().HasOne<Branch>().WithMany().HasForeignKey(x => x.BranchId).OnDelete(DeleteBehavior.Restrict);
        b.Entity<Room>().ToTable("rooms", t => t.HasCheckConstraint("ck_room_values", "\"Price\" >= 0 AND \"Capacity\" BETWEEN 1 AND 50"));
        b.Entity<Room>().HasOne<Branch>().WithMany().HasForeignKey(x => x.BranchId).OnDelete(DeleteBehavior.Restrict);
        b.Entity<Room>().HasIndex(x => new { x.BranchId, x.Name }).IsUnique();
        b.Entity<Tenant>().ToTable("tenants");
        b.Entity<Tenant>().HasOne<Branch>().WithMany().HasForeignKey(x => x.BranchId).OnDelete(DeleteBehavior.Restrict);
        b.Entity<Contract>().ToTable("contracts", t =>
        {
            t.HasCheckConstraint("ck_contract_values", "\"Rent\" >= 0 AND \"Deposit\" >= 0 AND \"EndDate\" >= \"StartDate\"");
            t.HasCheckConstraint("ck_contract_status", "\"Status\" IN ('Active','Closed')");
        });
        b.Entity<Contract>().HasOne<Room>().WithMany().HasForeignKey(x => x.RoomId).OnDelete(DeleteBehavior.Restrict);
        // Một phòng chỉ có một hợp đồng chưa quyết toán, kể cả đã quá ngày hết hạn.
        b.Entity<Contract>().HasIndex(x => x.RoomId).IsUnique().HasFilter("\"Status\" = 'Active'");
        b.Entity<ContractTenant>().ToTable("contract_tenants").HasKey(x => new { x.ContractId, x.TenantId });
        b.Entity<ContractTenant>().HasOne<Contract>().WithMany().HasForeignKey(x => x.ContractId).OnDelete(DeleteBehavior.Restrict);
        b.Entity<ContractTenant>().HasOne<Tenant>().WithMany().HasForeignKey(x => x.TenantId).OnDelete(DeleteBehavior.Restrict);
        b.Entity<ContractTenant>().HasIndex(x => x.ContractId).IsUnique().HasFilter("\"IsRepresentative\" = true");
        b.Entity<Fee>().ToTable("fees", t => t.HasCheckConstraint("ck_fee_values", "\"UnitPrice\" >= 0 AND \"Method\" IN ('Electricity','Water','Fixed','PerPerson')"));
        b.Entity<Fee>().HasOne<Branch>().WithMany().HasForeignKey(x => x.BranchId).OnDelete(DeleteBehavior.Restrict);
        b.Entity<Fee>().HasIndex(x => new { x.BranchId, x.Name }).IsUnique();
        b.Entity<Fee>().HasIndex(x => new { x.BranchId, x.Method }).IsUnique().HasFilter("\"Method\" IN ('Electricity','Water') AND \"IsArchived\" = false");
        b.Entity<Reading>().ToTable("readings", t =>
        {
            t.HasCheckConstraint("ck_reading_values", "\"ElectricityOld\" >= 0 AND \"ElectricityNew\" >= \"ElectricityOld\" AND \"WaterOld\" >= 0 AND \"WaterNew\" >= \"WaterOld\"");
            t.HasCheckConstraint("ck_reading_period", "\"Month\" BETWEEN 1 AND 12 AND \"Year\" BETWEEN 2000 AND 2100");
        });
        b.Entity<Reading>().HasOne<Contract>().WithMany().HasForeignKey(x => x.ContractId).OnDelete(DeleteBehavior.Restrict);
        b.Entity<Reading>().HasIndex(x => new { x.ContractId, x.Year, x.Month }).IsUnique();
        b.Entity<Invoice>().ToTable("invoices", t =>
        {
            t.HasCheckConstraint("ck_invoice_values", "\"Total\" >= 0 AND \"Month\" BETWEEN 1 AND 12 AND \"Year\" BETWEEN 2000 AND 2100");
            t.HasCheckConstraint("ck_invoice_status", "\"Status\" IN ('Issued','Cancelled')");
        });
        b.Entity<Invoice>().HasOne<Contract>().WithMany().HasForeignKey(x => x.ContractId).OnDelete(DeleteBehavior.Restrict);
        b.Entity<Invoice>().HasIndex(x => new { x.ContractId, x.Year, x.Month }).IsUnique().HasFilter("\"Status\" = 'Issued'");
        b.Entity<InvoiceItem>().ToTable("invoice_items", t => t.HasCheckConstraint("ck_item_values", "\"Quantity\" >= 0 AND \"UnitPrice\" >= 0 AND \"Amount\" >= 0"));
        b.Entity<Invoice>().HasMany(x => x.Items).WithOne().HasForeignKey(x => x.InvoiceId).OnDelete(DeleteBehavior.Restrict);
        b.Entity<Payment>().ToTable("payments", t => t.HasCheckConstraint("ck_payment_values", "\"Amount\" > 0 AND \"Method\" IN ('Cash','Transfer','Deposit')"));
        b.Entity<Payment>().HasOne<Invoice>().WithMany().HasForeignKey(x => x.InvoiceId).OnDelete(DeleteBehavior.Restrict);
        b.Entity<DepositEntry>().ToTable("deposit_entries", t => t.HasCheckConstraint("ck_deposit_values", "\"Amount\" > 0 AND \"Type\" IN ('Received','Applied','Deducted','Refunded')"));
        b.Entity<DepositEntry>().HasOne<Contract>().WithMany().HasForeignKey(x => x.ContractId).OnDelete(DeleteBehavior.Restrict);
        b.Entity<Incident>().ToTable("incidents", t => t.HasCheckConstraint("ck_incident_values", "\"Cost\" >= 0 AND \"Status\" IN ('Open','InProgress','Resolved')"));
        b.Entity<Incident>().HasOne<Room>().WithMany().HasForeignKey(x => x.RoomId).OnDelete(DeleteBehavior.Restrict);
        b.Entity<Incident>().HasOne<Tenant>().WithMany().HasForeignKey(x => x.ReportedByTenantId).OnDelete(DeleteBehavior.Restrict);
        b.Entity<Attachment>().ToTable("attachments", t => t.HasCheckConstraint("ck_attachment_values", "\"Size\" > 0 AND \"EntityType\" IN ('room','tenant','contract','incident','payment')"));
        b.Entity<Attachment>().HasIndex(x => new { x.EntityType, x.EntityId });
        b.Entity<AuditEntry>().ToTable("audit_entries");
        foreach (var entity in b.Model.GetEntityTypes())
        {
            foreach (var property in entity.GetProperties())
            {
                if (property.ClrType == typeof(decimal))
                {
                    property.SetPrecision(18); property.SetScale(3);
                }
                if (property.ClrType == typeof(string)) property.SetMaxLength(2000);
            }
        }
        b.Entity<User>().Property(x => x.Username).HasMaxLength(50);
        b.Entity<User>().Property(x => x.FullName).HasMaxLength(100);
        b.Entity<User>().Property(x => x.Role).HasMaxLength(20);
        b.Entity<Branch>().Property(x => x.Name).HasMaxLength(100);
        b.Entity<Room>().Property(x => x.Name).HasMaxLength(50);
        b.Entity<Tenant>().Property(x => x.FullName).HasMaxLength(100);
        b.Entity<Tenant>().Property(x => x.Phone).HasMaxLength(20);
        b.Entity<Tenant>().Property(x => x.IdentityNumber).HasMaxLength(30);
        b.Entity<Fee>().Property(x => x.Name).HasMaxLength(100);
        b.Entity<Fee>().Property(x => x.Method).HasMaxLength(20);
        b.Entity<Contract>().Property(x => x.Status).HasMaxLength(20);
        b.Entity<Invoice>().Property(x => x.Status).HasMaxLength(20);
        b.Entity<Payment>().Property(x => x.Method).HasMaxLength(20);
        b.Entity<DepositEntry>().Property(x => x.Type).HasMaxLength(20);
        b.Entity<Incident>().Property(x => x.Status).HasMaxLength(20);
        b.Entity<Attachment>().Property(x => x.EntityType).HasMaxLength(20);
        b.Entity<Attachment>().Property(x => x.OriginalName).HasMaxLength(250);
        b.Entity<Attachment>().Property(x => x.StoredName).HasMaxLength(64);
        b.Entity<Attachment>().Property(x => x.ContentType).HasMaxLength(100);
    }
}
