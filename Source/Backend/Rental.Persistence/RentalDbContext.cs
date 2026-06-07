using Microsoft.EntityFrameworkCore;
using Rental.Domain.Entities;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System;

namespace Rental.Persistence
{
    public class RentalDbContext : DbContext
    {
        public RentalDbContext(DbContextOptions<RentalDbContext> options) : base(options)
        {
        }

        // --- SYSTEM TABLES (sy_) ---
        public DbSet<User> Users { get; set; }
        public DbSet<Role> Roles { get; set; }
        public DbSet<Permission> Permissions { get; set; }
        public DbSet<RolePermission> RolePermissions { get; set; }
        public DbSet<Common> Commons { get; set; }
        public DbSet<FileAttachment> FileAttachments { get; set; }
        public DbSet<DocumentSetting> DocumentSettings { get; set; }

        // --- MASTER DATA (ms_) ---
        public DbSet<Branch> Branches { get; set; }
        public DbSet<Room> Rooms { get; set; }
        public DbSet<Tenant> Tenants { get; set; }
        public DbSet<FeeType> FeeTypes { get; set; }

        // --- TRANSACTIONS (tr_) ---
        public DbSet<Contract> Contracts { get; set; }
        public DbSet<ContractDetail> ContractDetails { get; set; }
        public DbSet<Invoice> Invoices { get; set; }
        public DbSet<InvoiceItem> InvoiceItems { get; set; }
        public DbSet<Payment> Payments { get; set; }
        public DbSet<UtilityReading> UtilityReadings { get; set; }
        public DbSet<Incident> Incidents { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // 1. Mapping table names (System - sy_)
            modelBuilder.Entity<User>().ToTable("sy_users");
            modelBuilder.Entity<Role>().ToTable("sy_roles").HasKey(r => r.RoleCode);
            modelBuilder.Entity<Permission>().ToTable("sy_permissions").HasKey(p => p.PermissionCode);
            modelBuilder.Entity<RolePermission>().ToTable("sy_role_permissions").HasKey(rp => new { rp.RoleCode, rp.PermissionCode });
            modelBuilder.Entity<Common>().ToTable("sy_commons");
            modelBuilder.Entity<FileAttachment>().ToTable("sy_file_attachments");
            modelBuilder.Entity<DocumentSetting>().ToTable("sy_document_settings");

            // 2. Mapping table names (Master Data - ms_)
            modelBuilder.Entity<Branch>().ToTable("ms_branches");
            modelBuilder.Entity<Room>().ToTable("ms_rooms");
            modelBuilder.Entity<Tenant>().ToTable("ms_tenants");
            modelBuilder.Entity<FeeType>().ToTable("ms_fee_types");

            // 3. Mapping table names (Transactions - tr_)
            modelBuilder.Entity<Contract>().ToTable("tr_contracts");
            modelBuilder.Entity<ContractDetail>().ToTable("tr_contract_details").HasKey(cd => new { cd.ContractId, cd.TenantId });
            modelBuilder.Entity<Invoice>().ToTable("tr_invoices");
            modelBuilder.Entity<InvoiceItem>().ToTable("tr_invoice_items");
            modelBuilder.Entity<Payment>().ToTable("tr_payments");
            modelBuilder.Entity<UtilityReading>().ToTable("tr_utility_readings");
            modelBuilder.Entity<Incident>().ToTable("tr_incidents");

            // 4. Cấu hình Quan hệ (Relationships) - CỰC KỲ QUAN TRỌNG ĐỂ TRÁNH role_id
            modelBuilder.Entity<User>()
                .HasOne(u => u.Role)
                .WithMany(r => r.Users)
                .HasForeignKey(u => u.RoleCode)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<RolePermission>()
                .HasOne(rp => rp.Role)
                .WithMany(r => r.RolePermissions)
                .HasForeignKey(rp => rp.RoleCode);

            modelBuilder.Entity<RolePermission>()
                .HasOne(rp => rp.Permission)
                .WithMany(p => p.RolePermissions)
                .HasForeignKey(rp => rp.PermissionCode);

            // 5. Tự động chuyển đổi PascalCase sang snake_case cho toàn bộ Column (Bao gồm Shadow Properties)
            foreach (var entity in modelBuilder.Model.GetEntityTypes())
            {
                foreach (var property in entity.GetProperties())
                {
                    var pascalName = property.Name;
                    var snakeName = System.Text.RegularExpressions.Regex.Replace(pascalName, "([a-z])([A-Z])", "$1_$2").ToLower();
                    property.SetColumnName(snakeName);
                }
            }

            // 6. Global Query Filter cho Soft Delete
            foreach (var entityType in modelBuilder.Model.GetEntityTypes())
            {
                var isDeletedProperty = entityType.FindProperty("IsDeleted");
                if (isDeletedProperty != null && isDeletedProperty.ClrType == typeof(bool))
                {
                    modelBuilder.Entity(entityType.ClrType).HasQueryFilter(ConvertFilterExpression(entityType.ClrType));
                }
            }
        }

        private static System.Linq.Expressions.LambdaExpression ConvertFilterExpression(Type type)
        {
            var parameter = System.Linq.Expressions.Expression.Parameter(type, "e");
            var propertyMethod = typeof(EF).GetMethod("Property").MakeGenericMethod(typeof(bool));
            var isDeletedProperty = System.Linq.Expressions.Expression.Call(null, propertyMethod, parameter, System.Linq.Expressions.Expression.Constant("IsDeleted"));
            var compareExpression = System.Linq.Expressions.Expression.Equal(isDeletedProperty, System.Linq.Expressions.Expression.Constant(false));
            return System.Linq.Expressions.Expression.Lambda(compareExpression, parameter);
        }

        public override async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
        {
            UpdateAuditFields();
            NormalizeDateTimesToUtc();
            return await base.SaveChangesAsync(cancellationToken);
        }

        public override int SaveChanges()
        {
            UpdateAuditFields();
            NormalizeDateTimesToUtc();
            return base.SaveChanges();
        }

        private void NormalizeDateTimesToUtc()
        {
            var entries = ChangeTracker.Entries()
                .Where(e => e.State == EntityState.Added || e.State == EntityState.Modified);

            foreach (var entry in entries)
            {
                foreach (var property in entry.Entity.GetType().GetProperties())
                {
                    if (property.PropertyType == typeof(DateTime))
                    {
                        var value = (DateTime?)property.GetValue(entry.Entity);
                        if (value.HasValue && value.Value.Kind != DateTimeKind.Utc)
                        {
                            property.SetValue(entry.Entity, DateTime.SpecifyKind(value.Value, DateTimeKind.Utc));
                        }
                    }
                    else if (property.PropertyType == typeof(DateTime?))
                    {
                        var value = (DateTime?)property.GetValue(entry.Entity);
                        if (value.HasValue && value.Value.Kind != DateTimeKind.Utc)
                        {
                            property.SetValue(entry.Entity, DateTime.SpecifyKind(value.Value, DateTimeKind.Utc));
                        }
                    }
                }
            }
        }

        private void UpdateAuditFields()
        {
            var entries = ChangeTracker.Entries()
                .Where(e => e.State == EntityState.Added || e.State == EntityState.Modified || e.State == EntityState.Deleted);

            foreach (var entry in entries)
            {
                var now = DateTime.UtcNow;
                var currentUser = "System";

                // Kiểm tra xem thực thể có các property tương ứng không thay vì check BaseEntity
                var isDeletedProp = entry.Entity.GetType().GetProperty("IsDeleted");
                var createdDateProp = entry.Entity.GetType().GetProperty("CreatedDate");
                var createdByProp = entry.Entity.GetType().GetProperty("CreatedBy");
                var updatedDateProp = entry.Entity.GetType().GetProperty("UpdatedDate");
                var updatedByProp = entry.Entity.GetType().GetProperty("UpdatedBy");
                var deletedDateProp = entry.Entity.GetType().GetProperty("DeletedDate");
                var deletedByProp = entry.Entity.GetType().GetProperty("DeletedBy");
                var versionProp = entry.Entity.GetType().GetProperty("Version");

                if (entry.State == EntityState.Added)
                {
                    createdDateProp?.SetValue(entry.Entity, now);
                    createdByProp?.SetValue(entry.Entity, currentUser);
                    versionProp?.SetValue(entry.Entity, 1);
                }
                else if (entry.State == EntityState.Modified)
                {
                    updatedDateProp?.SetValue(entry.Entity, now);
                    updatedByProp?.SetValue(entry.Entity, currentUser);
                    var currentVersion = (int)(versionProp?.GetValue(entry.Entity) ?? 1);
                    versionProp?.SetValue(entry.Entity, currentVersion + 1);
                }
                else if (entry.State == EntityState.Deleted && isDeletedProp != null)
                {
                    entry.State = EntityState.Modified;
                    isDeletedProp.SetValue(entry.Entity, true);
                    deletedDateProp?.SetValue(entry.Entity, now);
                    deletedByProp?.SetValue(entry.Entity, currentUser);
                }
            }
        }
    }
}
