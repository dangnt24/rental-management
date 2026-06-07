import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import api from '../apis/axiosInstance';
import { Button } from '../components/common/Button';
import { Users, Plus, Search, Edit3, Trash2 } from 'lucide-react';

const emptyTenant = { fullName: '', phone: '', email: '', identityNumber: '', dateOfBirth: null, genderCode: 'MALE', hometown: '', addressTemporary: '', statusCode: 'ACTIVE' };

const TenantListPage: React.FC = () => {
  const [search, setSearch] = useState('');
  const [showModal, setShowModal] = useState(false);
  const [editItem, setEditItem] = useState<any>(null);
  const [form, setForm] = useState({ ...emptyTenant });
  const queryClient = useQueryClient();

  const { data, isLoading } = useQuery({
    queryKey: ['tenants', search],
    queryFn: async () => {
      const res = await api.get(`/Tenant/GetPagedList?pageNumber=1&pageSize=20&searchTerm=${search}`);
      return res.data.data;
    }
  });

  const createMutation = useMutation({
    mutationFn: async (data: any) => { const res = await api.post('/Tenant', data); return res.data; },
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ['tenants'] }); setShowModal(false); setForm({ ...emptyTenant }); }
  });

  const updateMutation = useMutation({
    mutationFn: async (data: any) => { const res = await api.put('/Tenant', data); return res.data; },
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ['tenants'] }); setShowModal(false); setEditItem(null); }
  });

  const deleteMutation = useMutation({
    mutationFn: async (id: number) => { await api.delete(`/Tenant/${id}`); },
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['tenants'] })
  });

  const openEdit = (tenant: any) => {
    setEditItem(tenant);
    setForm({
      fullName: tenant.fullName, phone: tenant.phone, email: tenant.email || '',
      identityNumber: tenant.identityNumber, dateOfBirth: tenant.dateOfBirth,
      genderCode: tenant.genderCode || 'MALE', hometown: tenant.hometown || '',
      addressTemporary: tenant.addressTemporary || '', statusCode: tenant.statusCode
    });
    setShowModal(true);
  };

  const handleSubmit = () => {
    if (editItem) updateMutation.mutate({ ...form, id: editItem.id });
    else createMutation.mutate(form);
  };

  return (
    <div>
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-8 gap-4">
        <h1 className="text-2xl font-bold">Quản lý người thuê</h1>
        <Button className="flex items-center" onClick={() => { setEditItem(null); setForm({ ...emptyTenant }); setShowModal(true); }}>
          <Plus className="w-4 h-4 mr-2" /> Thêm khách thuê
        </Button>
      </div>

      <div className="bg-white rounded-lg shadow-sm border border-gray-100 overflow-hidden">
        <div className="p-4 border-b border-gray-100 flex items-center bg-gray-50">
          <div className="relative flex-1 max-w-md">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
            <input type="text" placeholder="Tìm kiếm theo tên, SĐT, CCCD..." value={search} onChange={e => setSearch(e.target.value)}
              className="w-full pl-10 pr-4 py-2 border border-gray-200 rounded-md focus:ring-2 focus:ring-blue-500 focus:outline-none" />
          </div>
        </div>

        <table className="w-full text-left">
          <thead className="bg-gray-50 text-gray-600 text-sm uppercase font-semibold">
            <tr>
              <th className="px-6 py-4">Họ và tên</th>
              <th className="px-6 py-4">SĐT</th>
              <th className="px-6 py-4">Email</th>
              <th className="px-6 py-4">CCCD</th>
              <th className="px-6 py-4">Trạng thái</th>
              <th className="px-6 py-4 text-right">Thao tác</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-100 text-gray-700">
            {isLoading ? (
              <tr><td colSpan={6} className="px-6 py-8 text-center text-gray-400">Đang tải dữ liệu...</td></tr>
            ) : data?.items?.length > 0 ? (
              data.items.map((tenant: any) => (
                <tr key={tenant.id} className="hover:bg-gray-50 transition-colors">
                  <td className="px-6 py-4 font-medium">{tenant.fullName}</td>
                  <td className="px-6 py-4">{tenant.phone}</td>
                  <td className="px-6 py-4 text-gray-500">{tenant.email || '--'}</td>
                  <td className="px-6 py-4">{tenant.identityNumber}</td>
                  <td className="px-6 py-4">
                    <span className={`px-2 py-1 rounded-full text-xs font-semibold ${
                      tenant.statusCode === 'ACTIVE' ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'
                    }`}>
                      {tenant.statusCode === 'ACTIVE' ? 'Đang ở' : 'Không hoạt động'}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-right">
                    <button onClick={() => openEdit(tenant)} className="text-blue-600 hover:text-blue-800 mr-3"><Edit3 className="w-4 h-4 inline" /></button>
                    <button onClick={() => { if (confirm('Xóa khách thuê này?')) deleteMutation.mutate(tenant.id); }} className="text-red-600 hover:text-red-800"><Trash2 className="w-4 h-4 inline" /></button>
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
          <div className="bg-white p-6 rounded-lg w-full max-w-lg max-h-[90vh] overflow-y-auto">
            <h2 className="text-xl font-bold mb-4">{editItem ? 'Sửa thông tin' : 'Thêm khách thuê mới'}</h2>
            <div className="grid grid-cols-2 gap-4">
              <div className="col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-1">Họ tên</label>
                <input value={form.fullName} onChange={e => setForm({ ...form, fullName: e.target.value })} className="w-full px-3 py-2 border border-gray-300 rounded-md" />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">SĐT</label>
                <input value={form.phone} onChange={e => setForm({ ...form, phone: e.target.value })} className="w-full px-3 py-2 border border-gray-300 rounded-md" />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Email</label>
                <input value={form.email} onChange={e => setForm({ ...form, email: e.target.value })} className="w-full px-3 py-2 border border-gray-300 rounded-md" />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">CCCD</label>
                <input value={form.identityNumber} onChange={e => setForm({ ...form, identityNumber: e.target.value })} className="w-full px-3 py-2 border border-gray-300 rounded-md" />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Giới tính</label>
                <select value={form.genderCode} onChange={e => setForm({ ...form, genderCode: e.target.value })} className="w-full px-3 py-2 border border-gray-300 rounded-md">
                  <option value="MALE">Nam</option>
                  <option value="FEMALE">Nữ</option>
                </select>
              </div>
              <div className="col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-1">Địa chỉ thường trú</label>
                <input value={form.hometown} onChange={e => setForm({ ...form, hometown: e.target.value })} className="w-full px-3 py-2 border border-gray-300 rounded-md" />
              </div>
              <div className="col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-1">Địa chỉ tạm trú</label>
                <input value={form.addressTemporary} onChange={e => setForm({ ...form, addressTemporary: e.target.value })} className="w-full px-3 py-2 border border-gray-300 rounded-md" />
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

export default TenantListPage;
