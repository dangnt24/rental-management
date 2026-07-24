using System;
using System.Threading.Tasks;
using Rental.Domain.Entities;

namespace Rental.Application.Interfaces.Persistence
{
    public interface IUnitOfWork : IDisposable
    {
        IGenericRepository<User> Users { get; }
        IGenericRepository<Role> Roles { get; }
        IGenericRepository<Permission> Permissions { get; }
        IGenericRepository<RolePermission> RolePermissions { get; }
        IGenericRepository<Common> Commons { get; }
        IGenericRepository<DocumentSetting> DocumentSettings { get; }
        IGenericRepository<FileAttachment> FileAttachments { get; }
        IGenericRepository<Branch> Branches { get; }
        IGenericRepository<Room> Rooms { get; }
        IGenericRepository<Tenant> Tenants { get; }
        IGenericRepository<FeeType> FeeTypes { get; }
        IGenericRepository<Contract> Contracts { get; }
        IGenericRepository<ContractDetail> ContractDetails { get; }
        IGenericRepository<Invoice> Invoices { get; }
        IGenericRepository<InvoiceItem> InvoiceItems { get; }
        IGenericRepository<UtilityReading> UtilityReadings { get; }
        IGenericRepository<Payment> Payments { get; }
        IGenericRepository<Incident> Incidents { get; }

        Task<int> CompleteAsync();
    }
}
