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
            
            // Thêm các ánh xạ khác tại đây
            // CreateMap<Branch, BranchDto>().ReverseMap();
            // CreateMap<Room, RoomDto>().ReverseMap();
        }
    }
}
