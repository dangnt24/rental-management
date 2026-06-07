using System;
using System.Threading.Tasks;
using Rental.Domain.Entities;

namespace Rental.Application.Interfaces.Persistence
{
    /// <summary>
    /// Giao diện Unit Of Work.
    /// Định nghĩa tại tầng Application để các Service có thể sử dụng mà không cần phụ thuộc vào Persistence.
    /// </summary>
    public interface IUnitOfWork : IDisposable
    {
        IGenericRepository<User> Users { get; }
        IGenericRepository<Role> Roles { get; }
        IGenericRepository<Branch> Branches { get; }
        IGenericRepository<Room> Rooms { get; }
        IGenericRepository<Tenant> Tenants { get; }
        IGenericRepository<Contract> Contracts { get; }
        IGenericRepository<Invoice> Invoices { get; }
        IGenericRepository<UtilityReading> UtilityReadings { get; }
        IGenericRepository<Payment> Payments { get; }
        IGenericRepository<Incident> Incidents { get; }
        IGenericRepository<FeeType> FeeTypes { get; }
        
        Task<int> CompleteAsync();
    }
}
