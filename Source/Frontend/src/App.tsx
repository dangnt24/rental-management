import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import LoginPage from './pages/auth/LoginPage';
import DashboardPage from './pages/DashboardPage';
import RoomListPage from './pages/RoomListPage';
import TenantListPage from './pages/TenantListPage';
import BillingPage from './pages/BillingPage';
import ContractListPage from './pages/ContractListPage';
import PaymentPage from './pages/PaymentPage';
import IncidentListPage from './pages/IncidentListPage';
import MainLayout from './layouts/MainLayout';
import { useAuthStore } from './stores/authStore';

function App() {
  const { accessToken } = useAuthStore();

  return (
    <Router>
      <Routes>
        <Route path="/login" element={<LoginPage />} />
        
        <Route path="/dashboard" element={accessToken ? <MainLayout><DashboardPage /></MainLayout> : <Navigate to="/login" />} />
        <Route path="/rooms" element={accessToken ? <MainLayout><RoomListPage /></MainLayout> : <Navigate to="/login" />} />
        <Route path="/tenants" element={accessToken ? <MainLayout><TenantListPage /></MainLayout> : <Navigate to="/login" />} />
        <Route path="/billing" element={accessToken ? <MainLayout><BillingPage /></MainLayout> : <Navigate to="/login" />} />
        <Route path="/contracts" element={accessToken ? <MainLayout><ContractListPage /></MainLayout> : <Navigate to="/login" />} />
        <Route path="/payments" element={accessToken ? <MainLayout><PaymentPage /></MainLayout> : <Navigate to="/login" />} />
        <Route path="/incidents" element={accessToken ? <MainLayout><IncidentListPage /></MainLayout> : <Navigate to="/login" />} />

        <Route path="/" element={<Navigate to="/dashboard" />} />
      </Routes>
    </Router>
  );
}

export default App;
