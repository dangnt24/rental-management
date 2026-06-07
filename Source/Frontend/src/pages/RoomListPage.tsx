import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import api from '../apis/axiosInstance';
import { Button } from '../components/common/Button';
import { Home, Plus, Search, Edit3, Trash2 } from 'lucide-react';

const emptyRoom = { roomName: '', price: 0, maxOccupants: 1, description: '', statusCode: 'EMPTY', branchId: 1 };

const RoomListPage: React.FC = () => {
  const [search, setSearch] = useState('');
  const [showModal, setShowModal] = useState(false);
  const [editItem, setEditItem] = useState<any>(null);
  const [form, setForm] = useState({ ...emptyRoom });
  const queryClient = useQueryClient();

  const { data, isLoading } = useQuery({
    queryKey: ['rooms', search],
    queryFn: async () => {
      const res = await api.get(`/Room/GetPagedList?pageNumber=1&pageSize=20&searchTerm=${search}`);
      return res.data.data;
    }
  });

  const createMutation = useMutation({
    mutationFn: async (data: any) => { const res = await api.post('/Room', data); return res.data; },
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ['rooms'] }); setShowModal(false); setForm({ ...emptyRoom }); }
  });

  const updateMutation = useMutation({
    mutationFn: async (data: any) => { const res = await api.put('/Room', data); return res.data; },
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ['rooms'] }); setShowModal(false); setEditItem(null); }
  });

  const deleteMutation = useMutation({
    mutationFn: async (id: number) => { await api.delete(`/Room/${id}`); },
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['rooms'] })
  });

  const openEdit = (room: any) => {
    setEditItem(room);
    setForm({ roomName: room.roomName, price: room.price, maxOccupants: room.maxOccupants, description: room.description || '', statusCode: room.statusCode, branchId: room.branchId });
    setShowModal(true);
  };

  const handleSubmit = () => {
    if (editItem) updateMutation.mutate({ ...form, id: editItem.id });
    else createMutation.mutate(form);
  };

  return (
    <div>
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-8 gap-4">
        <h1 className="text-2xl font-bold">Quản lý phòng</h1>
        <Button className="flex items-center" onClick={() => { setEditItem(null); setForm({ ...emptyRoom }); setShowModal(true); }}>
          <Plus className="w-4 h-4 mr-2" /> Thêm phòng
        </Button>
      </div>

      <div className="bg-white rounded-lg shadow-sm border border-gray-100 overflow-hidden">
        <div className="p-4 border-b border-gray-100 flex items-center bg-gray-50">
          <div className="relative flex-1 max-w-md">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
            <input type="text" placeholder="Tìm kiếm tên phòng..." value={search} onChange={e => setSearch(e.target.value)}
              className="w-full pl-10 pr-4 py-2 border border-gray-200 rounded-md focus:ring-2 focus:ring-blue-500 focus:outline-none" />
          </div>
        </div>

        <table className="w-full text-left">
          <thead className="bg-gray-50 text-gray-600 text-sm uppercase font-semibold">
            <tr>
              <th className="px-6 py-4">Tên phòng</th>
              <th className="px-6 py-4">Giá thuê</th>
              <th className="px-6 py-4">Số người</th>
              <th className="px-6 py-4">Mô tả</th>
              <th className="px-6 py-4">Trạng thái</th>
              <th className="px-6 py-4 text-right">Thao tác</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-100 text-gray-700">
            {isLoading ? (
              <tr><td colSpan={6} className="px-6 py-8 text-center text-gray-400">Đang tải dữ liệu...</td></tr>
            ) : data?.items?.length > 0 ? (
              data.items.map((room: any) => (
                <tr key={room.id} className="hover:bg-gray-50 transition-colors">
                  <td className="px-6 py-4 font-medium">{room.roomName}</td>
                  <td className="px-6 py-4">{new Intl.NumberFormat('vi-VN').format(room.price)} đ</td>
                  <td className="px-6 py-4">{room.maxOccupants}</td>
                  <td className="px-6 py-4 max-w-xs truncate text-gray-500">{room.description || '--'}</td>
                  <td className="px-6 py-4">
                    <span className={`px-2 py-1 rounded-full text-xs font-semibold ${
                      room.statusCode === 'EMPTY' ? 'bg-green-100 text-green-700' : 
                      room.statusCode === 'RENTED' ? 'bg-blue-100 text-blue-700' : 'bg-yellow-100 text-yellow-700'
                    }`}>
                      {room.statusCode === 'EMPTY' ? 'Trống' : room.statusCode === 'RENTED' ? 'Đang thuê' : 'Đang sửa'}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-right">
                    <button onClick={() => openEdit(room)} className="text-blue-600 hover:text-blue-800 mr-3"><Edit3 className="w-4 h-4 inline" /></button>
                    <button onClick={() => { if (confirm('Xóa phòng này?')) deleteMutation.mutate(room.id); }} className="text-red-600 hover:text-red-800"><Trash2 className="w-4 h-4 inline" /></button>
                  </td>
                </tr>
              ))
            ) : (
              <tr><td colSpan={6} className="px-6 py-8 text-center text-gray-400">Không có dữ liệu</td></tr>
            )}
          </tbody>
        </table>
      </div>

      {showModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white p-6 rounded-lg w-full max-w-lg">
            <h2 className="text-xl font-bold mb-4">{editItem ? 'Sửa phòng' : 'Thêm phòng mới'}</h2>
            <div className="grid grid-cols-2 gap-4">
              <div className="col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-1">Tên phòng</label>
                <input value={form.roomName} onChange={e => setForm({ ...form, roomName: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md" />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Giá thuê</label>
                <input type="number" value={form.price} onChange={e => setForm({ ...form, price: Number(e.target.value) })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md" />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Số người tối đa</label>
                <input type="number" value={form.maxOccupants} onChange={e => setForm({ ...form, maxOccupants: Number(e.target.value) })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md" />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Trạng thái</label>
                <select value={form.statusCode} onChange={e => setForm({ ...form, statusCode: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md">
                  <option value="EMPTY">Trống</option>
                  <option value="RENTED">Đang thuê</option>
                  <option value="MAINTENANCE">Đang sửa</option>
                </select>
              </div>
              <div className="col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-1">Mô tả</label>
                <textarea value={form.description} onChange={e => setForm({ ...form, description: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md" rows={2} />
              </div>
            </div>
            <div className="flex justify-end space-x-3 mt-6">
              <Button variant="secondary" onClick={() => { setShowModal(false); setEditItem(null); }}>Hủy</Button>
              <Button onClick={handleSubmit} loading={createMutation.isPending || updateMutation.isPending}>
                {editItem ? 'Cập nhật' : 'Thêm mới'}
              </Button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default RoomListPage;
