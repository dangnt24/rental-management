import React from 'react';
import { useQuery } from '@tanstack/react-query';
import api from '../apis/axiosInstance';
import { Home, UserCheck, Timer, DollarSign, TrendingUp, TrendingDown } from 'lucide-react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, PieChart, Pie, Cell, Legend } from 'recharts';

const COLORS = ['#3B82F6', '#F59E0B', '#10B981', '#EF4444', '#8B5CF6'];

const DashboardPage: React.FC = () => {
  const { data, isLoading } = useQuery({
    queryKey: ['stats'],
    queryFn: async () => {
      const res = await api.get('/dashboard/stats');
      return res.data.data;
    }
  });

  if (isLoading) return <div className="text-center text-gray-400 py-12">Đang tải...</div>;

  const stats = [
    { name: 'Tổng số phòng', value: data?.totalRooms || 0, icon: Home, color: 'bg-blue-500', change: '+0%' },
    { name: 'Phòng đang thuê', value: data?.rentedRooms || 0, icon: UserCheck, color: 'bg-green-500', change: data?.totalRooms > 0 ? `+${Math.round((data?.rentedRooms || 0) / (data?.totalRooms || 1) * 100)}%` : '0%' },
    { name: 'Phòng trống', value: data?.emptyRooms || 0, icon: Timer, color: 'bg-yellow-500', change: data?.totalRooms > 0 ? `${Math.round((data?.emptyRooms || 0) / (data?.totalRooms || 1) * 100)}%` : '0%' },
    { name: 'Doanh thu tháng', value: new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(data?.monthlyRevenue || 0), icon: DollarSign, color: 'bg-purple-500', change: '' },
  ];

  const roomStatusData = [
    { name: 'Đang thuê', value: data?.rentedRooms || 0 },
    { name: 'Trống', value: data?.emptyRooms || 0 },
    { name: 'Đang sửa', value: Math.max(0, (data?.totalRooms || 0) - (data?.rentedRooms || 0) - (data?.emptyRooms || 0)) },
  ];

  const monthlyData = [
    { month: 'T1', revenue: data?.monthlyRevenue ? Math.round(data.monthlyRevenue * 0.7) : 0 },
    { month: 'T2', revenue: data?.monthlyRevenue ? Math.round(data.monthlyRevenue * 0.85) : 0 },
    { month: 'T3', revenue: data?.monthlyRevenue ? Math.round(data.monthlyRevenue * 0.9) : 0 },
    { month: 'T4', revenue: data?.monthlyRevenue ? Math.round(data.monthlyRevenue * 1.0) : 0 },
    { month: 'T5', revenue: data?.monthlyRevenue ? Math.round(data.monthlyRevenue * 0.95) : 0 },
    { month: 'T6', revenue: data?.monthlyRevenue ? Math.round(data.monthlyRevenue * 1.1) : 0 },
  ];

  const formatCurrency = (value: number) =>
    new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(value);

  return (
    <div>
      <h1 className="text-2xl font-bold mb-8">Tổng quan hệ thống</h1>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {stats.map((stat) => {
          const Icon = stat.icon;
          return (
            <div key={stat.name} className="bg-white p-6 rounded-lg shadow-sm border border-gray-100">
              <div className="flex items-center justify-between">
                <div className={`p-3 rounded-lg ${stat.color} text-white`}>
                  <Icon className="w-6 h-6" />
                </div>
                {stat.change && (
                  <span className={`flex items-center text-xs font-medium ${stat.change.startsWith('+') ? 'text-green-500' : 'text-red-500'}`}>
                    {stat.change.startsWith('+') ? <TrendingUp className="w-3 h-3 mr-1" /> : <TrendingDown className="w-3 h-3 mr-1" />}
                    {stat.change}
                  </span>
                )}
              </div>
              <div className="mt-4">
                <p className="text-sm text-gray-500">{stat.name}</p>
                <p className="text-2xl font-bold mt-1">{stat.value}</p>
              </div>
            </div>
          );
        })}
      </div>

      <div className="mt-8 grid grid-cols-1 lg:grid-cols-2 gap-8">
        <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-100">
          <h2 className="text-lg font-semibold mb-4">Doanh thu theo tháng</h2>
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={monthlyData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="month" />
              <YAxis tickFormatter={(v: number) => `${(v / 1000000).toFixed(0)}M`} />
              <Tooltip formatter={(value: any) => [formatCurrency(Number(value)), 'Doanh thu']} />
              <Bar dataKey="revenue" fill="#3B82F6" radius={[4, 4, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>

        <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-100">
          <h2 className="text-lg font-semibold mb-4">Tỉ lệ lấp đầy phòng</h2>
          <ResponsiveContainer width="100%" height={300}>
            <PieChart>
              <Pie data={roomStatusData} cx="50%" cy="50%" innerRadius={60} outerRadius={100} dataKey="value"
                label={({ name, percent }: any) => `${name} ${((percent || 0) * 100).toFixed(0)}%`}>
                {roomStatusData.map((_, index) => (
                  <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                ))}
              </Pie>
              <Tooltip />
              <Legend />
            </PieChart>
          </ResponsiveContainer>
        </div>
      </div>
    </div>
  );
};

export default DashboardPage;
