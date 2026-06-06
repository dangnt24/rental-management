using Microsoft.EntityFrameworkCore;
using Rental.Domain.Entities;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System;

namespace Rental.Persistence
{
    /// <summary>
    /// Context kết nối cơ sở dữ liệu PostgreSQL.
    /// Cấu hình Fluent API, Soft Delete và Audit Fields.
    /// </summary>
    public class RentalDbContext : DbContext
    {
        public RentalDbContext(DbContextOptions<RentalDbContext> options) : base(options)
        {
        }

        public DbSet<User> Users { get; set; }
        public DbSet<Role> Roles { get; set; }
        public DbSet<Permission> Permissions { get; set; }
        public DbSet<RolePermission> RolePermissions { get; set; }
        public DbSet<Branch> Branches { get; set; }
        public DbSet<Room> Rooms { get; set; }
        public DbSet<Tenant> Tenants { get; set; }
        public DbSet<Contract> Contracts { get; set; }
        public DbSet<ContractDetail> ContractDetails { get; set; }
        public DbSet<Invoice> Invoices { get; set; }
        public DbSet<InvoiceItem> InvoiceItems { get; set; }
        public DbSet<FeeType> FeeTypes { get; set; }
        public DbSet<Payment> Payments { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Cấu hình bảng RolePermission (Khóa chính phức hợp)
            modelBuilder.Entity<RolePermission>()
                .HasKey(rp => new { rp.RoleCode, rp.PermissionCode });

            // Cấu hình bảng ContractDetail (Khóa chính phức hợp)
            modelBuilder.Entity<ContractDetail>()
                .HasKey(cd => new { cd.ContractId, cd.TenantId });

            // Global Query Filter cho Soft Delete
            // Chỉ lấy các bản ghi chưa bị xóa (IsDeleted = false)
            foreach (var entityType in modelBuilder.Model.GetEntityTypes())
            {
                if (typeof(Rental.Core.BaseEntity).IsAssignableFrom(entityType.ClrType))
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

        /// <summary>
        /// Ghi đè SaveChanges để tự động cập nhật Audit Fields.
        /// </summary>
        public override async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
        {
            UpdateAuditFields();
            return await base.SaveChangesAsync(cancellationToken);
        }

        public override int SaveChanges()
        {
            UpdateAuditFields();
            return base.SaveChanges();
        }

        private void UpdateAuditFields()
        {
            var entries = ChangeTracker.Entries()
                .Where(e => e.Entity is Rental.Core.BaseEntity && (e.State == EntityState.Added || e.State == EntityState.Modified || e.State == EntityState.Deleted));

            foreach (var entry in entries)
            {
                var entity = (Rental.Core.BaseEntity)entry.Entity;
                var now = DateTime.Now;
                var currentUser = "System"; // TODO: Lấy từ IHttpContextAccessor

                if (entry.State == EntityState.Added)
                {
                    entity.CreatedDate = now;
                    entity.CreatedBy = currentUser;
                    entity.Version = 1;
                }
                else if (entry.State == EntityState.Modified)
                {
                    entity.UpdatedDate = now;
                    entity.UpdatedBy = currentUser;
                    entity.Version++;
                }
                else if (entry.State == EntityState.Deleted)
                {
                    // Chuyển sang Soft Delete
                    entry.State = EntityState.Modified;
                    entity.IsDeleted = true;
                    entity.DeletedDate = now;
                    entity.DeletedBy = currentUser;
                }
            }
        }
    }
}
