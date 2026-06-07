using Rental.Application.Interfaces.Persistence;
using Rental.Application.Interfaces.Services;
using Rental.Application.DTOs;
using Rental.Core;
using Rental.Domain.Entities;
using AutoMapper;
using Microsoft.EntityFrameworkCore;
using System.Linq;
using System.Threading.Tasks;
using System.Collections.Generic;
using Rental.Security.Password;

namespace Rental.Application.Services
{
    public class UserService : IUserService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        private readonly IPasswordHasher _passwordHasher;

        public UserService(IUnitOfWork unitOfWork, IMapper mapper, IPasswordHasher passwordHasher)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _passwordHasher = passwordHasher;
        }

        public async Task<ApiResult<UserDto>> GetByIdAsync(int id)
        {
            var user = await _unitOfWork.Users.GetByIdAsync(id);
            if (user == null) return ApiResult<UserDto>.Failure("Không tìm thấy người dùng");
            var dto = _mapper.Map<UserDto>(user);
            return ApiResult<UserDto>.Success(dto);
        }

        public async Task<ApiResult<PagedResult<UserDto>>> GetPagedListAsync(int pageNumber, int pageSize, string? searchTerm)
        {
            var query = _unitOfWork.Users.Find(x => !x.IsDeleted);

            if (!string.IsNullOrEmpty(searchTerm))
                query = query.Where(x => x.FullName.Contains(searchTerm) || x.Username.Contains(searchTerm) || x.Email.Contains(searchTerm));

            var totalCount = await query.CountAsync();
            var items = await query
                .OrderByDescending(x => x.CreatedDate)
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return ApiResult<PagedResult<UserDto>>.Success(new PagedResult<UserDto>
            {
                Items = _mapper.Map<List<UserDto>>(items),
                TotalCount = totalCount,
                PageNumber = pageNumber,
                PageSize = pageSize
            });
        }

        public async Task<ApiResult<UserDto>> CreateAsync(UserDto dto)
        {
            var user = _mapper.Map<User>(dto);
            user.PasswordHash = _passwordHasher.HashPassword("123456");
            user.IsActive = true;
            await _unitOfWork.Users.AddAsync(user);
            await _unitOfWork.CompleteAsync();
            return ApiResult<UserDto>.Success(_mapper.Map<UserDto>(user));
        }

        public async Task<ApiResult<UserDto>> UpdateAsync(UserDto dto)
        {
            var user = await _unitOfWork.Users.GetByIdAsync(dto.Id);
            if (user == null) return ApiResult<UserDto>.Failure("Không tìm thấy người dùng");
            _mapper.Map(dto, user);
            _unitOfWork.Users.Update(user);
            await _unitOfWork.CompleteAsync();
            return ApiResult<UserDto>.Success(_mapper.Map<UserDto>(user));
        }

        public async Task<ApiResult<bool>> DeleteAsync(int id)
        {
            var user = await _unitOfWork.Users.GetByIdAsync(id);
            if (user == null) return ApiResult<bool>.Failure("Không tìm thấy người dùng");
            _unitOfWork.Users.Remove(user);
            await _unitOfWork.CompleteAsync();
            return ApiResult<bool>.Success(true);
        }
    }
}
