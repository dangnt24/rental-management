import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import api from '../apis/axiosInstance';
import { Button } from '../components/common/Button';
import { CreditCard, DollarSign, Search } from 'lucide-react';

const PaymentPage: React.FC = () => {
  const [showPay, setShowPay] = useState(false);
  const [selectedInvoice, setSelectedInvoice] = useState<any>(null);
  const [amount, setAmount] = useState(0);
  const queryClient = useQueryClient();

  const { data, isLoading } = useQuery({
    queryKey: ['invoices'],
    queryFn: async () => {
      const res = await api.get('/Invoice/GetPagedList?pageNumber=1&pageSize=50');
      return res.data.data;
    }
  });

  const payMutation = useMutation({
    mutationFn: async (payment: any) => {
      const res = await api.post('/Payment', payment);
      return res.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['invoices'] });
      setShowPay(false);
      setSelectedInvoice(null);
    }
  });

  return (
    <div>
      <div className="flex justify-between items-center mb-8">
        <h1 className="text-2xl font-bold">Quản lý thanh toán</h1>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
        {data?.items?.filter((i: any) => i.statusCode !== 'PAID').reduce((acc: any, inv: any) => {
          const totalRemaining = (acc.totalRemaining || 0) + (inv.totalAmount - inv.paidAmount);
          return { totalUnpaid: (acc.totalUnpaid || 0) + 1, totalRemaining };
        }, { totalUnpaid: 0, totalRemaining: 0 }) && (
          <>
            <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-100">
              <p className="text-sm text-gray-500">Tổng hóa đơn</p>
              <p className="text-2xl font-bold">{data?.items?.length || 0}</p>
            </div>
            <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-100">
              <p className="text-sm text-gray-500">Chưa thanh toán</p>
              <p className="text-2xl font-bold text-red-600">
                {data?.items?.filter((i: any) => i.statusCode !== 'PAID').length || 0}
              </p>
            </div>
            <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-100">
              <p className="text-sm text-gray-500">Tổng tiền chưa thu</p>
              <p className="text-2xl font-bold text-yellow-600">
                {new Intl.NumberFormat('vi-VN').format(
                  data?.items?.filter((i: any) => i.statusCode !== 'PAID')
                    .reduce((s: number, i: any) => s + (i.totalAmount - i.paidAmount), 0) || 0
                )} đ
              </p>
            </div>
          </>
        )}
      </div>

      <div className="bg-white rounded-lg shadow-sm border border-gray-100 overflow-hidden">
        <div className="p-4 border-b border-gray-100 bg-gray-50">
          <h2 className="font-semibold text-gray-700">Danh sách hóa đơn</h2>
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
              <th className="px-6 py-4">Trạng thái</th>
              <th className="px-6 py-4 text-right">Thao tác</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-100 text-gray-700">
            {isLoading ? (
              <tr><td colSpan={8} className="px-6 py-8 text-center text-gray-400">Đang tải dữ liệu...</td></tr>
            ) : data?.items?.length > 0 ? (
              data.items.map((inv: any) => (
                <tr key={inv.id} className="hover:bg-gray-50 transition-colors">
                  <td className="px-6 py-4 font-mono text-sm">{inv.invoiceCode}</td>
                  <td className="px-6 py-4">{inv.roomName}</td>
                  <td className="px-6 py-4">{inv.billingMonth}/{inv.billingYear}</td>
                  <td className="px-6 py-4 font-bold">{new Intl.NumberFormat('vi-VN').format(inv.totalAmount)} đ</td>
                  <td className="px-6 py-4 text-green-600">{new Intl.NumberFormat('vi-VN').format(inv.paidAmount)} đ</td>
                  <td className="px-6 py-4 text-red-600">{new Intl.NumberFormat('vi-VN').format(inv.totalAmount - inv.paidAmount)} đ</td>
                  <td className="px-6 py-4">
                    <span className={`px-2 py-1 rounded-full text-xs font-semibold ${
                      inv.statusCode === 'PAID' ? 'bg-green-100 text-green-700' : 
                      inv.statusCode === 'PARTIAL' ? 'bg-yellow-100 text-yellow-700' : 'bg-red-100 text-red-700'
                    }`}>
                      {inv.statusCode === 'PAID' ? 'Đã trả' : inv.statusCode === 'PARTIAL' ? 'Trả một phần' : 'Chưa trả'}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-right">
                    {inv.statusCode !== 'PAID' && (
                      <button onClick={() => { setSelectedInvoice(inv); setShowPay(true); setAmount(inv.totalAmount - inv.paidAmount); }}
                        className="text-blue-600 hover:text-blue-800 flex items-center ml-auto">
                        <DollarSign className="w-4 h-4 mr-1" /> Thanh toán
                      </button>
                    )}
                  </td>
                </tr>
              ))
            ) : (
              <tr><td colSpan={8} className="px-6 py-8 text-center text-gray-400">Không có dữ liệu</td></tr>
            )}
          </tbody>
        </table>
      </div>

      {showPay && selectedInvoice && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white p-6 rounded-lg w-full max-w-md">
            <h2 className="text-xl font-bold mb-4">Xác nhận thanh toán</h2>
            <p className="mb-4 text-gray-600">
              Hóa đơn: <strong>{selectedInvoice.invoiceCode}</strong><br />
              Còn nợ: <strong className="text-red-600">{new Intl.NumberFormat('vi-VN').format(selectedInvoice.totalAmount - selectedInvoice.paidAmount)} đ</strong>
            </p>
            <div className="mb-4">
              <label className="block text-sm font-medium text-gray-700 mb-1">Số tiền thanh toán</label>
              <input type="number" value={amount} onChange={e => setAmount(Number(e.target.value))}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:outline-none" />
            </div>
            <div className="flex justify-end space-x-3">
              <Button variant="secondary" onClick={() => { setShowPay(false); setSelectedInvoice(null); }}>Hủy</Button>
              <Button onClick={() => payMutation.mutate({ invoiceId: selectedInvoice.id, amount, paymentDate: new Date().toISOString(), methodCode: 'CASH' })}
                loading={payMutation.isPending}>Xác nhận thanh toán</Button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default PaymentPage;
