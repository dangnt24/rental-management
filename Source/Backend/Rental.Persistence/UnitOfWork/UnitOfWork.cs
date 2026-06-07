using Rental.Application.Interfaces.Persistence;
using Rental.Domain.Entities;
using Rental.Persistence.Repositories;
using System;
using System.Threading.Tasks;

namespace Rental.Persistence.UnitOfWork
{
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
            UtilityReadings = new GenericRepository<UtilityReading>(_context);
            Payments = new GenericRepository<Payment>(_context);
            Incidents = new GenericRepository<Incident>(_context);
            FeeTypes = new GenericRepository<FeeType>(_context);
        }

        public IGenericRepository<User> Users { get; private set; }
        public IGenericRepository<Role> Roles { get; private set; }
        public IGenericRepository<Branch> Branches { get; private set; }
        public IGenericRepository<Room> Rooms { get; private set; }
        public IGenericRepository<Tenant> Tenants { get; private set; }
        public IGenericRepository<Contract> Contracts { get; private set; }
        public IGenericRepository<Invoice> Invoices { get; private set; }
        public IGenericRepository<UtilityReading> UtilityReadings { get; private set; }
        public IGenericRepository<Payment> Payments { get; private set; }
        public IGenericRepository<Incident> Incidents { get; private set; }
        public IGenericRepository<FeeType> FeeTypes { get; private set; }

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
