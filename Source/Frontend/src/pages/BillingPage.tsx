import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import api from '../apis/axiosInstance';
import { Button } from '../components/common/Button';
import { Receipt, Plus, Search, FileText, Zap, Droplets } from 'lucide-react';

const BillingPage: React.FC = () => {
  const [showGenerate, setShowGenerate] = useState(false);
  const [showReading, setShowReading] = useState(false);
  const [contractId, setContractId] = useState(0);
  const [month, setMonth] = useState(new Date().getMonth() + 1);
  const [year, setYear] = useState(new Date().getFullYear());
  const [readingForm, setReadingForm] = useState({ roomId: 0, readingDate: new Date().toISOString().slice(0, 10), elecIndexOld: 0, elecIndexNew: 0, waterIndexOld: 0, waterIndexNew: 0 });
  const queryClient = useQueryClient();

  const { data, isLoading } = useQuery({
    queryKey: ['unpaid-invoices'],
    queryFn: async () => {
      const res = await api.get('/Billing/unpaid');
      return res.data.data;
    }
  });

  const generateMutation = useMutation({
    mutationFn: async () => {
      const res = await api.post(`/Billing/generate-invoice?contractId=${contractId}&month=${month}&year=${year}`);
      return res.data;
    },
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ['unpaid-invoices'] }); setShowGenerate(false); }
  });

  const readingMutation = useMutation({
    mutationFn: async (data: any) => { const res = await api.post('/Billing/record-reading', data); return res.data; },
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ['unpaid-invoices'] }); setShowReading(false); }
  });

  return (
    <div>
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-8 gap-4">
        <h1 className="text-2xl font-bold">Hóa đơn & Tiền phòng</h1>
        <div className="flex flex-wrap gap-3">
          <Button variant="secondary" className="flex items-center" onClick={() => setShowReading(true)}>
            <Zap className="w-4 h-4 mr-2" /> Nhập chỉ số điện nước
          </Button>
          <Button className="flex items-center" onClick={() => setShowGenerate(true)}>
            <Plus className="w-4 h-4 mr-2" /> Tạo hóa đơn tháng
          </Button>
        </div>
      </div>

      <div className="grid grid-cols-1 gap-6">
        <div className="bg-white rounded-lg shadow-sm border border-gray-100 overflow-hidden">
          <div className="p-4 border-b border-gray-100 bg-gray-50 flex justify-between items-center">
            <h2 className="font-semibold text-gray-700">Danh sách hóa đơn chưa thanh toán</h2>
          </div>

          <table className="w-full text-left">
            <thead className="bg-gray-50 text-gray-600 text-sm uppercase font-semibold">
              <tr>
                <th className="px-6 py-4">Mã HĐ</th>
                <th className="px-6 py-4">Phòng</th>
                <th className="px-6 py-4">Tháng/Năm</th>
                <th className="px-6 py-4">Tổng tiền</th>
                <th className="px-6 py-4">Đã trả</th>
                <th className="px-6 py-4">Còn nợ</th>
                <th className="px-6 py-4">Hạn đóng</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100 text-gray-700">
              {isLoading ? (
                <tr><td colSpan={7} className="px-6 py-8 text-center text-gray-400">Đang tải dữ liệu...</td></tr>
              ) : data?.length > 0 ? (
                data.map((inv: any) => (
                  <tr key={inv.id} className="hover:bg-gray-50 transition-colors">
                    <td className="px-6 py-4 font-mono text-sm">{inv.invoiceCode}</td>
                    <td className="px-6 py-4">{inv.roomName}</td>
                    <td className="px-6 py-4">{inv.billingMonth}/{inv.billingYear}</td>
                    <td className="px-6 py-4 font-bold">{new Intl.NumberFormat('vi-VN').format(inv.totalAmount)} đ</td>
                    <td className="px-6 py-4 text-green-600">{new Intl.NumberFormat('vi-VN').format(inv.paidAmount)} đ</td>
                    <td className="px-6 py-4 text-red-600 font-semibold">{new Intl.NumberFormat('vi-VN').format(inv.remainingAmount)} đ</td>
                    <td className="px-6 py-4 text-sm">{inv.dueDate ? new Date(inv.dueDate).toLocaleDateString('vi-VN') : '--'}</td>
                  </tr>
                ))
              ) : (
                <tr><td colSpan={7} className="px-6 py-8 text-center text-gray-400">Tất cả hóa đơn đã được thanh toán</td></tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      {showGenerate && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white p-6 rounded-lg w-full max-w-md">
            <h2 className="text-xl font-bold mb-4">Tạo hóa đơn tháng</h2>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">ID Hợp đồng</label>
                <input type="number" value={contractId} onChange={e => setContractId(Number(e.target.value))} className="w-full px-3 py-2 border border-gray-300 rounded-md" />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Tháng</label>
                  <input type="number" value={month} onChange={e => setMonth(Number(e.target.value))} className="w-full px-3 py-2 border border-gray-300 rounded-md" />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Năm</label>
                  <input type="number" value={year} onChange={e => setYear(Number(e.target.value))} className="w-full px-3 py-2 border border-gray-300 rounded-md" />
                </div>
              </div>
            </div>
            <div className="flex justify-end space-x-3 mt-6">
              <Button variant="secondary" onClick={() => setShowGenerate(false)}>Hủy</Button>
              <Button onClick={() => generateMutation.mutate()} loading={generateMutation.isPending}>Tạo hóa đơn</Button>
            </div>
          </div>
        </div>
      )}

      {showReading && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white p-6 rounded-lg w-full max-w-lg">
            <h2 className="text-xl font-bold mb-4">Nhập chỉ số điện nước</h2>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">ID Phòng</label>
                <input type="number" value={readingForm.roomId} onChange={e => setReadingForm({ ...readingForm, roomId: Number(e.target.value) })} className="w-full px-3 py-2 border border-gray-300 rounded-md" />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Ngày đọc</label>
                <input type="date" value={readingForm.readingDate} onChange={e => setReadingForm({ ...readingForm, readingDate: e.target.value })} className="w-full px-3 py-2 border border-gray-300 rounded-md" />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Điện cũ</label>
                  <input type="number" value={readingForm.elecIndexOld} onChange={e => setReadingForm({ ...readingForm, elecIndexOld: Number(e.target.value) })} className="w-full px-3 py-2 border border-gray-300 rounded-md" />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Điện mới</label>
                  <input type="number" value={readingForm.elecIndexNew} onChange={e => setReadingForm({ ...readingForm, elecIndexNew: Number(e.target.value) })} className="w-full px-3 py-2 border border-gray-300 rounded-md" />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Nước cũ</label>
                  <input type="number" value={readingForm.waterIndexOld} onChange={e => setReadingForm({ ...readingForm, waterIndexOld: Number(e.target.value) })} className="w-full px-3 py-2 border border-gray-300 rounded-md" />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Nước mới</label>
                  <input type="number" value={readingForm.waterIndexNew} onChange={e => setReadingForm({ ...readingForm, waterIndexNew: Number(e.target.value) })} className="w-full px-3 py-2 border border-gray-300 rounded-md" />
                </div>
              </div>
            </div>
            <div className="flex justify-end space-x-3 mt-6">
              <Button variant="secondary" onClick={() => setShowReading(false)}>Hủy</Button>
              <Button onClick={() => readingMutation.mutate(readingForm)} loading={readingMutation.isPending}>Lưu chỉ số</Button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default BillingPage;
