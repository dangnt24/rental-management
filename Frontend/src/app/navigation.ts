import {
  Building2,
  ClipboardList,
  FileText,
  Home,
  LayoutDashboard,
  Settings,
  Users,
  Wallet,
  Wrench,
} from "lucide-react";
import type { Page } from "../shared/types";

export const nav: {
  id: Page;
  label: string;
  icon: typeof Home;
  ownerOnly?: boolean;
}[] = [
  { id: "overview", label: "Tổng quan", icon: LayoutDashboard },
  { id: "rooms", label: "Phòng trọ", icon: Building2 },
  { id: "tenants", label: "Người thuê", icon: Users },
  { id: "contracts", label: "Hợp đồng & cọc", icon: FileText },
  { id: "billing", label: "Điện nước & hóa đơn", icon: ClipboardList },
  { id: "payments", label: "Thu tiền & công nợ", icon: Wallet },
  { id: "incidents", label: "Sự cố & bảo trì", icon: Wrench },
  {
    id: "accounts",
    label: "Tài khoản & phạm vi quản lý",
    icon: Users,
    ownerOnly: true,
  },
  { id: "settings", label: "Thiết lập", icon: Settings },
];
