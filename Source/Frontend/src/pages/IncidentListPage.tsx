import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import api from '../apis/axiosInstance';
import { Button } from '../components/common/Button';
import { AlertTriangle, Plus, Search, Wrench, CheckCircle } from 'lucide-react';

const IncidentListPage: React.FC = () => {
  const [showCreate, setShowCreate] = useState(false);
  const queryClient = useQueryClient();

  const { data, isLoading } = useQuery({
    queryKey: ['incidents'],
    queryFn: async () => {
      const res = await api.get('/Incident/GetPagedList?pageNumber=1&pageSize=20');
      return res.data.data;
    }
  });

  const updateMutation = useMutation({
    mutationFn: async ({ id, data }: { id: number; data: any }) => {
      await api.put('/Incident', { ...data, id });
    },
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['incidents'] })
  });

  return (
    <div>
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-8 gap-4">
        <h1 className="text-2xl font-bold">Quản lý sự cố / Bảo trì</h1>
        <Button className="flex items-center" onClick={() => setShowCreate(true)}>
          <Plus className="w-4 h-4 mr-2" /> Báo sự cố
        </Button>
      </div>

      <div className="bg-white rounded-lg shadow-sm border border-gray-100 overflow-hidden">
        <table className="w-full text-left">
          <thead className="bg-gray-50 text-gray-600 text-sm uppercase font-semibold">
            <tr>
              <th className="px-6 py-4">Phòng</th>
              <th className="px-6 py-4">Mô tả</th>
              <th className="px-6 py-4">Mức độ</th>
              <th className="px-6 py-4">Chi phí</th>
              <th className="px-6 py-4">Ngày báo</th>
              <th className="px-6 py-4">Trạng thái</th>
              <th className="px-6 py-4 text-right">Thao tác</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-100 text-gray-700">
            {isLoading ? (
              <tr><td colSpan={7} className="px-6 py-8 text-center text-gray-400">Đang tải dữ liệu...</td></tr>
            ) : data?.items?.length > 0 ? (
              data.items.map((incident: any) => (
                <tr key={incident.id} className="hover:bg-gray-50 transition-colors">
                  <td className="px-6 py-4 font-medium">{incident.roomName}</td>
                  <td className="px-6 py-4 max-w-xs truncate">{incident.description}</td>
                  <td className="px-6 py-4">
                    <span className={`px-2 py-1 rounded-full text-xs font-semibold ${
                      incident.priorityCode === 'HIGH' ? 'bg-red-100 text-red-700' : 
                      incident.priorityCode === 'MEDIUM' ? 'bg-yellow-100 text-yellow-700' : 'bg-green-100 text-green-700'
                    }`}>
                      {incident.priorityCode === 'HIGH' ? 'Cao' : incident.priorityCode === 'MEDIUM' ? 'Trung bình' : 'Thấp'}
                    </span>
                  </td>
                  <td className="px-6 py-4">{incident.repairCost ? new Intl.NumberFormat('vi-VN').format(incident.repairCost) + ' đ' : '--'}</td>
                  <td className="px-6 py-4">{new Date(incident.reportedDate).toLocaleDateString('vi-VN')}</td>
                  <td className="px-6 py-4">
                    <span className={`px-2 py-1 rounded-full text-xs font-semibold ${
                      incident.statusCode === 'PENDING' ? 'bg-yellow-100 text-yellow-700' : 
                      incident.statusCode === 'RESOLVED' ? 'bg-green-100 text-green-700' : 'bg-blue-100 text-blue-700'
                    }`}>
                      {incident.statusCode === 'PENDING' ? 'Chờ xử lý' : incident.statusCode === 'RESOLVED' ? 'Đã xử lý' : 'Đang xử lý'}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-right">
                    {incident.statusCode !== 'RESOLVED' && (
                      <button onClick={() => updateMutation.mutate({ id: incident.id, data: { statusCode: 'RESOLVED', resolvedDate: new Date().toISOString() } })}
                        className="text-green-600 hover:text-green-800 flex items-center ml-auto">
                        <CheckCircle className="w-4 h-4 mr-1" /> Hoàn thành
                      </button>
                    )}
                  </td>
                </tr>
              ))
            ) : (
              <tr><td colSpan={7} className="px-6 py-8 text-center text-gray-400">Không có sự cố nào</td></tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default IncidentListPage;
