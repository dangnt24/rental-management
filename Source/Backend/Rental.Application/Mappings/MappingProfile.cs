using AutoMapper;
using Rental.Application.DTOs;
using Rental.Domain.Entities;

namespace Rental.Application.Mappings
{
    public class MappingProfile : Profile
    {
        public MappingProfile()
        {
            CreateMap<User, UserDto>();
            CreateMap<UserDto, User>()
                .ForMember(d => d.PasswordHash, o => o.Ignore())
                .ForMember(d => d.RefreshToken, o => o.Ignore())
                .ForMember(d => d.RefreshTokenExpiry, o => o.Ignore())
                .ForMember(d => d.LastLogin, o => o.Ignore())
                .ForMember(d => d.AvatarId, o => o.Ignore());

            CreateMap<Room, RoomDto>().ReverseMap();
            CreateMap<Tenant, TenantDto>().ReverseMap();
            CreateMap<Branch, BranchDto>().ReverseMap();
            CreateMap<FeeType, FeeTypeDto>().ReverseMap();

            CreateMap<Contract, ContractDto>()
                .ForMember(d => d.RoomName, o => o.MapFrom(s => s.Room != null ? s.Room.RoomName : null))
                .ForMember(d => d.Tenants, o => o.Ignore());

            CreateMap<ContractDto, Contract>()
                .ForMember(d => d.Room, o => o.Ignore())
                .ForMember(d => d.ContractDetails, o => o.Ignore())
                .ForMember(d => d.Invoices, o => o.Ignore());

            CreateMap<UtilityReading, UtilityReadingDto>()
                .ForMember(d => d.RoomName, o => o.MapFrom(s => s.Room != null ? s.Room.RoomName : null));
            CreateMap<UtilityReadingDto, UtilityReading>()
                .ForMember(d => d.Room, o => o.Ignore());

            CreateMap<Invoice, InvoiceDto>()
                .ForMember(d => d.RoomName, o => o.MapFrom(s => s.Contract != null && s.Contract.Room != null ? s.Contract.Room.RoomName : null))
                .ForMember(d => d.Items, o => o.MapFrom(s => s.InvoiceItems));
            CreateMap<InvoiceDto, Invoice>()
                .ForMember(d => d.Contract, o => o.Ignore())
                .ForMember(d => d.InvoiceItems, o => o.Ignore())
                .ForMember(d => d.Payments, o => o.Ignore());

            CreateMap<InvoiceItem, InvoiceItemDto>()
                .ForMember(d => d.FeeName, o => o.MapFrom(s => s.FeeType != null ? s.FeeType.FeeName : null));
            CreateMap<InvoiceItemDto, InvoiceItem>()
                .ForMember(d => d.Invoice, o => o.Ignore())
                .ForMember(d => d.FeeType, o => o.Ignore());

            CreateMap<Payment, PaymentDto>()
                .ForMember(d => d.InvoiceCode, o => o.MapFrom(s => s.Invoice != null ? s.Invoice.InvoiceCode : null));
            CreateMap<PaymentDto, Payment>()
                .ForMember(d => d.Invoice, o => o.Ignore());

            CreateMap<Incident, IncidentDto>()
                .ForMember(d => d.RoomName, o => o.MapFrom(s => s.Room != null ? s.Room.RoomName : null))
                .ForMember(d => d.TenantName, o => o.MapFrom(s => s.Tenant != null ? s.Tenant.FullName : null));
            CreateMap<IncidentDto, Incident>()
                .ForMember(d => d.Room, o => o.Ignore())
                .ForMember(d => d.Tenant, o => o.Ignore());
        }
    }
}
