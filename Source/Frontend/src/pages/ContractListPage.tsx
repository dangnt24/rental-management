import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import api from '../apis/axiosInstance';
import { Button } from '../components/common/Button';
import { FileText, Plus, Search, X, CheckCircle, Ban } from 'lucide-react';

const ContractListPage: React.FC = () => {
  const [search, setSearch] = useState('');
  const [showCreate, setShowCreate] = useState(false);
  const queryClient = useQueryClient();

  const { data, isLoading } = useQuery({
    queryKey: ['contracts', search],
    queryFn: async () => {
      const res = await api.get(`/Contract/GetPagedList?pageNumber=1&pageSize=20&statusCode=${search}`);
      return res.data.data;
    }
  });

  const terminateMutation = useMutation({
    mutationFn: async (id: number) => {
      await api.post(`/Contract/${id}/terminate`);
    },
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['contracts'] })
  });

  return (
    <div>
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-8 gap-4">
        <h1 className="text-2xl font-bold">Hợp đồng thuê phòng</h1>
        <Button className="flex items-center" onClick={() => setShowCreate(true)}>
          <Plus className="w-4 h-4 mr-2" /> Tạo hợp đồng
        </Button>
      </div>

      <div className="bg-white rounded-lg shadow-sm border border-gray-100 overflow-hidden">
        <div className="p-4 border-b border-gray-100 flex items-center bg-gray-50">
          <div className="relative flex-1 max-w-md">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
            <input type="text" placeholder="Lọc theo trạng thái..." value={search} onChange={e => setSearch(e.target.value)} className="w-full pl-10 pr-4 py-2 border border-gray-200 rounded-md focus:ring-2 focus:ring-blue-500 focus:outline-none" />
          </div>
        </div>

        <table className="w-full text-left">
          <thead className="bg-gray-50 text-gray-600 text-sm uppercase font-semibold">
            <tr>
              <th className="px-6 py-4">Mã HĐ</th>
              <th className="px-6 py-4">Phòng</th>
              <th className="px-6 py-4">Ngày bắt đầu</th>
              <th className="px-6 py-4">Ngày kết thúc</th>
              <th className="px-6 py-4">Tiền cọc</th>
              <th className="px-6 py-4">Giá thuê</th>
              <th className="px-6 py-4">Trạng thái</th>
              <th className="px-6 py-4 text-right">Thao tác</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-100 text-gray-700">
            {isLoading ? (
              <tr><td colSpan={8} className="px-6 py-8 text-center text-gray-400">Đang tải dữ liệu...</td></tr>
            ) : data?.items?.length > 0 ? (
              data.items.map((contract: any) => (
                <tr key={contract.id} className="hover:bg-gray-50 transition-colors">
                  <td className="px-6 py-4 font-mono text-sm">{contract.contractCode}</td>
                  <td className="px-6 py-4 font-medium">{contract.roomName}</td>
                  <td className="px-6 py-4">{new Date(contract.startDate).toLocaleDateString('vi-VN')}</td>
                  <td className="px-6 py-4">{contract.endDate ? new Date(contract.endDate).toLocaleDateString('vi-VN') : '--'}</td>
                  <td className="px-6 py-4">{new Intl.NumberFormat('vi-VN').format(contract.depositAmount)} đ</td>
                  <td className="px-6 py-4 font-bold">{new Intl.NumberFormat('vi-VN').format(contract.actualRentPrice)} đ</td>
                  <td className="px-6 py-4">
                    <span className={`px-2 py-1 rounded-full text-xs font-semibold ${
                      contract.statusCode === 'ACTIVE' ? 'bg-green-100 text-green-700' : 
                      contract.statusCode === 'TERMINATED' ? 'bg-red-100 text-red-700' : 'bg-yellow-100 text-yellow-700'
                    }`}>
                      {contract.statusCode === 'ACTIVE' ? 'Còn hiệu lực' : contract.statusCode === 'TERMINATED' ? 'Đã kết thúc' : contract.statusCode}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-right">
                    {contract.statusCode === 'ACTIVE' && (
                      <button onClick={() => terminateMutation.mutate(contract.id)} className="text-red-600 hover:text-red-800 flex items-center ml-auto">
                        <Ban className="w-4 h-4 mr-1" /> Kết thúc
                      </button>
                    )}
                  </td>
                </tr>
              ))
            ) : (
              <tr><td colSpan={8} className="px-6 py-8 text-center text-gray-400">Không có hợp đồng nào</td></tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default ContractListPage;
