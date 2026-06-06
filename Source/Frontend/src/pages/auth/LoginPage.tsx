import React from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hook-form/resolvers/zod';
import * as z from 'zod';
import { Input } from '../../components/common/Input';
import { Button } from '../../components/common/Button';
import api from '../../apis/axiosInstance';
import { useAuthStore } from '../../stores/authStore';
import { useNavigate } from 'react-router-dom';

const loginSchema = z.object({
  username: z.string().min(1, 'Vui lòng nhập tên đăng nhập'),
  password: z.string().min(6, 'Mật khẩu phải từ 6 ký tự'),
});

type LoginFormValues = z.infer<typeof loginSchema>;

/**
 * Trang Đăng nhập.
 */
const LoginPage: React.FC = () => {
  const setAuth = useAuthStore((state) => state.setAuth);
  const navigate = useNavigate();
  const { register, handleSubmit, formState: { errors, isSubmitting } } = useForm<LoginFormValues>({
    resolver: zodResolver(loginSchema),
  });

  const onSubmit = async (data: LoginFormValues) => {
    try {
      const response = await api.post('/auth/login', data);
      const { user, accessToken, refreshToken } = response.data.data;
      setAuth(user, accessToken, refreshToken);
      localStorage.setItem('accessToken', accessToken);
      localStorage.setItem('refreshToken', refreshToken);
      navigate('/dashboard');
    } catch (error) {
      alert('Đăng nhập thất bại. Vui lòng kiểm tra lại!');
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-100">
      <div className="bg-white p-8 rounded-lg shadow-md w-96">
        <h1 className="text-2xl font-bold mb-6 text-center text-gray-800">Đăng Nhập Hệ Thống</h1>
        <form onSubmit={handleSubmit(onSubmit)}>
          <Input 
            label="Tên đăng nhập" 
            {...register('username')} 
            error={errors.username?.message} 
          />
          <Input 
            label="Mật khẩu" 
            type="password" 
            {...register('password')} 
            error={errors.password?.message} 
          />
          <Button type="submit" className="w-full mt-4" loading={isSubmitting}>
            Đăng Nhập
          </Button>
        </form>
      </div>
    </div>
  );
};

export default LoginPage;
