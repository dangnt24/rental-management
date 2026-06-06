using AutoMapper;
using Rental.Application.DTOs;
using Rental.Application.Interfaces.Services;
using Rental.Core;
using Rental.Domain.Entities;
using Rental.Persistence.UnitOfWork;
using Rental.Security.Jwt;
using Rental.Security.Password;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;

namespace Rental.Application.Services
{
    /// <summary>
    /// Triển khai dịch vụ xác thực.
    /// </summary>
    public class AuthService : IAuthService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IJwtHelper _jwtHelper;
        private readonly IPasswordHasher _passwordHasher;
        private readonly IMapper _mapper;

        public AuthService(IUnitOfWork unitOfWork, IJwtHelper jwtHelper, IPasswordHasher passwordHasher, IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _jwtHelper = jwtHelper;
            _passwordHasher = passwordHasher;
            _mapper = mapper;
        }

        public async Task<ApiResult<LoginResponse>> LoginAsync(LoginRequest request)
        {
            var user = _unitOfWork.Users.Find(u => u.Username == request.Username).FirstOrDefault();
            if (user == null || !_passwordHasher.VerifyPassword(request.Password, user.PasswordHash))
            {
                return ApiResult<LoginResponse>.Failure("Tên đăng nhập hoặc mật khẩu không chính xác", null, 401);
            }

            if (!user.IsActive)
            {
                return ApiResult<LoginResponse>.Failure("Tài khoản đã bị khóa", null, 403);
            }

            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                new Claim(ClaimTypes.Name, user.Username),
                new Claim(ClaimTypes.Role, user.RoleCode)
            };

            var accessToken = _jwtHelper.GenerateAccessToken(claims);
            var refreshToken = _jwtHelper.GenerateRefreshToken();

            user.RefreshToken = refreshToken;
            user.RefreshTokenExpiry = DateTime.Now.AddDays(7);
            user.LastLogin = DateTime.Now;

            _unitOfWork.Users.Update(user);
            await _unitOfWork.CompleteAsync();

            return ApiResult<LoginResponse>.Success(new LoginResponse
            {
                AccessToken = accessToken,
                RefreshToken = refreshToken,
                User = _mapper.Map<UserDto>(user)
            });
        }

        public async Task<ApiResult<LoginResponse>> RefreshTokenAsync(string refreshToken)
        {
            var user = _unitOfWork.Users.Find(u => u.RefreshToken == refreshToken).FirstOrDefault();
            if (user == null || user.RefreshTokenExpiry < DateTime.Now)
            {
                return ApiResult<LoginResponse>.Failure("Refresh Token không hợp lệ hoặc đã hết hạn", null, 401);
            }

            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                new Claim(ClaimTypes.Name, user.Username),
                new Claim(ClaimTypes.Role, user.RoleCode)
            };

            var newAccessToken = _jwtHelper.GenerateAccessToken(claims);
            var newRefreshToken = _jwtHelper.GenerateRefreshToken();

            user.RefreshToken = newRefreshToken;
            _unitOfWork.Users.Update(user);
            await _unitOfWork.CompleteAsync();

            return ApiResult<LoginResponse>.Success(new LoginResponse
            {
                AccessToken = newAccessToken,
                RefreshToken = newRefreshToken,
                User = _mapper.Map<UserDto>(user)
            });
        }

        public async Task<ApiResult<bool>> LogoutAsync(int userId)
        {
            var user = await _unitOfWork.Users.GetByIdAsync(userId);
            if (user != null)
            {
                user.RefreshToken = null;
                user.RefreshTokenExpiry = null;
                _unitOfWork.Users.Update(user);
                await _unitOfWork.CompleteAsync();
            }
            return ApiResult<bool>.Success(true);
        }
    }
}
