using System;
using System.Threading.Tasks;
using Rental.Persistence.Repositories;
using Rental.Domain.Entities;

namespace Rental.Persistence.UnitOfWork
{
    /// <summary>
    /// Giao diện Unit Of Work để quản lý giao dịch và repositories.
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
        
        Task<int> CompleteAsync();
    }

    /// <summary>
    /// Triển khai Unit Of Work.
    /// </summary>
    public class UnitOfWork : IUnitOfWork
    {
        private readonly RentalDbContext _context;

        public UnitOfWork(RentalDbContext context)
        {
            _context = context;
            Users = new GenericRepository<User>(_context);
            Roles = new GenericRepository<Role>(_context);
            Branches = new GenericRepository<Branch>(_context);
            Rooms = new GenericRepository<Room>(_context);
            Tenants = new GenericRepository<Tenant>(_context);
            Contracts = new GenericRepository<Contract>(_context);
            Invoices = new GenericRepository<Invoice>(_context);
        }

        public IGenericRepository<User> Users { get; private set; }
        public IGenericRepository<Role> Roles { get; private set; }
        public IGenericRepository<Branch> Branches { get; private set; }
        public IGenericRepository<Room> Rooms { get; private set; }
        public IGenericRepository<Tenant> Tenants { get; private set; }
        public IGenericRepository<Contract> Contracts { get; private set; }
        public IGenericRepository<Invoice> Invoices { get; private set; }

        public async Task<int> CompleteAsync()
        {
            return await _context.SaveChangesAsync();
        }

        public void Dispose()
        {
            _context.Dispose();
        }
    }
}
