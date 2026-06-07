using AutoMapper;
using Rental.Application.DTOs;
using Rental.Domain.Entities;

namespace Rental.Application.Mappings
{
    /// <summary>
    /// Cấu hình ánh xạ giữa Entity và DTO.
    /// </summary>
    public class MappingProfile : Profile
    {
        public MappingProfile()
        {
            CreateMap<User, UserDto>().ReverseMap();
            CreateMap<Room, RoomDto>().ReverseMap();
            CreateMap<Tenant, TenantDto>().ReverseMap();
            CreateMap<Branch, BranchDto>().ReverseMap();
            CreateMap<Contract, ContractDto>().ReverseMap();
            CreateMap<UtilityReading, UtilityReadingDto>().ReverseMap();
            CreateMap<Invoice, InvoiceDto>().ReverseMap();
            CreateMap<InvoiceItem, InvoiceItemDto>().ReverseMap();
            CreateMap<Payment, PaymentDto>().ReverseMap();
            CreateMap<Incident, IncidentDto>().ReverseMap();
            CreateMap<FeeType, FeeTypeDto>().ReverseMap();
        }
    }
}
