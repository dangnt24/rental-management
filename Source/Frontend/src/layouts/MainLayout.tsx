import React from 'react';
import { LayoutDashboard, Home, Users, Receipt, FileText, CreditCard, AlertTriangle, LogOut, Menu, X } from 'lucide-react';
import { Link, useLocation } from 'react-router-dom';
import { useAuthStore } from '../stores/authStore';

const MainLayout: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const location = useLocation();
  const logout = useAuthStore((state) => state.logout);
  const user = useAuthStore((state) => state.user);
  const [sidebarOpen, setSidebarOpen] = React.useState(false);

  const menuItems = [
    { path: '/dashboard', name: 'Tổng quan', icon: LayoutDashboard },
    { path: '/rooms', name: 'Quản lý phòng', icon: Home },
    { path: '/tenants', name: 'Người thuê', icon: Users },
    { path: '/contracts', name: 'Hợp đồng', icon: FileText },
    { path: '/billing', name: 'Hóa đơn & Tiền phòng', icon: Receipt },
    { path: '/payments', name: 'Thanh toán', icon: CreditCard },
    { path: '/incidents', name: 'Sự cố / Bảo trì', icon: AlertTriangle },
  ];

  return (
    <div className="flex h-screen bg-gray-100">
      {/* Mobile overlay */}
      {sidebarOpen && (
        <div className="fixed inset-0 bg-black bg-opacity-50 z-20 lg:hidden" onClick={() => setSidebarOpen(false)} />
      )}

      {/* Sidebar */}
      <div className={`fixed lg:static inset-y-0 left-0 z-30 w-64 bg-slate-800 text-white flex flex-col transform transition-transform lg:transform-none ${sidebarOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'}`}>
        <div className="flex items-center justify-between p-6 border-b border-slate-700">
          <div className="text-xl font-bold">Rental Manager</div>
          <button className="lg:hidden" onClick={() => setSidebarOpen(false)}>
            <X className="w-5 h-5" />
          </button>
        </div>
        <nav className="flex-1 mt-4 overflow-y-auto">
          {menuItems.map((item) => {
            const Icon = item.icon;
            const isActive = location.pathname === item.path;
            return (
              <Link
                key={item.path}
                to={item.path}
                onClick={() => setSidebarOpen(false)}
                className={`flex items-center px-6 py-3 transition-colors ${isActive ? 'bg-blue-600' : 'hover:bg-slate-700'}`}
              >
                <Icon className="w-5 h-5 mr-3 flex-shrink-0" />
                <span className="truncate">{item.name}</span>
              </Link>
            );
          })}
        </nav>
        <div className="p-4 border-t border-slate-700">
          <div className="flex items-center mb-4 px-2">
            <div className="w-8 h-8 rounded-full bg-blue-500 flex items-center justify-center mr-3 font-bold flex-shrink-0">
              {user?.fullName?.charAt(0) || 'U'}
            </div>
            <div className="text-sm min-w-0">
              <p className="font-medium truncate">{user?.fullName || 'User'}</p>
              <p className="text-xs text-gray-400 truncate">{user?.roleCode}</p>
            </div>
          </div>
          <button onClick={logout} className="flex items-center w-full px-2 py-2 text-sm text-red-400 hover:text-red-300">
            <LogOut className="w-4 h-4 mr-2" /> Đăng xuất
          </button>
        </div>
      </div>

      {/* Content */}
      <div className="flex-1 flex flex-col min-w-0">
        <div className="bg-white border-b border-gray-200 px-6 py-3 flex items-center lg:hidden">
          <button onClick={() => setSidebarOpen(true)} className="mr-4">
            <Menu className="w-6 h-6" />
          </button>
          <h1 className="font-bold text-lg">Rental Manager</h1>
        </div>
        <div className="flex-1 overflow-auto p-4 lg:p-8">
          {children}
        </div>
      </div>
    </div>
  );
};

export default MainLayout;
