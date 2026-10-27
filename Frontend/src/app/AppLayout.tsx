import type { ReactNode } from "react";
import { LogOut, Menu, Plus, RefreshCw, ShieldCheck } from "lucide-react";
import type { Page } from "../shared/types";
import { labels } from "../shared/labels";
import { nav } from "./navigation";
import { api } from "../shared/api";
import { IconButton } from "../shared/components/IconButton";
import { BrandLogo } from "../shared/components/BrandLogo";
import { useWorkspace } from "./WorkspaceContext";
import { WorkspaceDialogs } from "./WorkspaceDialogs";
import { useRoomForms } from "../features/rooms/useRoomForms";
import { useTenantForms } from "../features/tenants/useTenantForms";
import { useContractForms } from "../features/contracts/useContractForms";
import { useBillingForms } from "../features/billing/useBillingForms";
import { usePaymentForms } from "../features/payments/usePaymentForms";
import { useIncidentForms } from "../features/incidents/useIncidentForms";

export function AppLayout({ children }: { children: ReactNode }) {
  const {
    page,
    showMenu,
    navigate,
    incidents,
    action,
    setUser,
    setData,
    setShowMenu,
    branch,
    setBranch,
    setSearch,
    setStatus,
    branches,
    user,
    today,
    reload,
    refreshing,
    data,
    loadError,
    all,
  } = useWorkspace();
  const { editRoom } = useRoomForms();
  const { editTenant } = useTenantForms();
  const { editContract } = useContractForms();
  const { invoiceForm, readingForm } = useBillingForms();
  const { paymentForm } = usePaymentForms();
  const { editIncident } = useIncidentForms();
  const pageInfo = nav.find((x) => x.id === page) || nav[0];
  const mainAction: Partial<Record<Page, { title: string; run: () => void }>> =
    {
      rooms: { title: "Thêm phòng", run: () => editRoom() },
      tenants: { title: "Thêm người thuê", run: () => editTenant() },
      contracts: { title: "Lập hợp đồng", run: editContract },
      billing: { title: "Lập hóa đơn", run: invoiceForm },
      payments: { title: "Ghi nhận thu tiền", run: () => paymentForm() },
      incidents: { title: "Tiếp nhận sự cố", run: () => editIncident() },
    };
  return (
    <div className="app-shell">
      <aside className={"sidebar " + (showMenu ? "shown" : "")}>
        <a
          href="#overview"
          className="brand"
          onClick={() => navigate("overview")}
        >
          <BrandLogo />
        </a>
        <span className="nav-caption">KHÔNG GIAN LÀM VIỆC</span>
        <nav>
          {nav.map((x) => (
            <button
              key={x.id}
              className={page === x.id ? "active" : ""}
              onClick={() => navigate(x.id)}
            >
              <x.icon size={19} />
              <span>{x.label}</span>
              {x.id === "incidents" &&
                incidents.filter((x) => x.status !== "Resolved").length > 0 && (
                  <b>
                    {incidents.filter((x) => x.status !== "Resolved").length}
                  </b>
                )}
            </button>
          ))}
        </nav>
        <div className="sidebar-bottom">
          <a className="button secondary" href="#browse">
            Xem trang tìm phòng
          </a>
          <div className="sidebar-tip">
            <ShieldCheck size={20} />
            <p>
              Rõ từng khoản thu.
              <br />
              <strong>An tâm mỗi tháng.</strong>
            </p>
          </div>
          <button
            onClick={() =>
              action(async () => {
                await api("/auth/logout", "POST");
                setUser(null);
                setData(null);
              })
            }
          >
            <LogOut size={17} />
            Đăng xuất
          </button>
          <small>DVP HOME · QUẢN LÝ NHÀ TRỌ</small>
        </div>
      </aside>
      {showMenu && (
        <div className="menu-scrim" onClick={() => setShowMenu(false)} />
      )}
      <div className="main-shell">
        <header className="topbar">
          <div>
            <IconButton title="Mở menu" onClick={() => setShowMenu(!showMenu)}>
              <Menu size={21} />
            </IconButton>
            <span>
              Không gian quản lý <b>/</b> <strong>{pageInfo.label}</strong>
            </span>
          </div>
          <div className="topbar-right">
            <select
              aria-label="Chọn khu trọ"
              value={branch}
              onChange={(e) => {
                setBranch(Number(e.target.value));
                setSearch("");
                setStatus("");
              }}
            >
              <option value={0}>Tất cả khu trọ</option>
              {branches.map((x) => (
                <option key={x.value} value={x.value}>
                  {x.label}
                </option>
              ))}
            </select>
            <div className="profile">
              <span className="avatar">{user.fullName.slice(0, 1)}</span>
              <div>
                <strong>{user.fullName}</strong>
                <small>{labels[user.role]}</small>
              </div>
            </div>
          </div>
        </header>
        <main>
          <div className="page-heading">
            <div>
              <div className="eyebrow">
                {page === "overview"
                  ? new Date(today + "T12:00:00").toLocaleDateString("vi-VN", {
                      weekday: "long",
                      day: "2-digit",
                      month: "long",
                      year: "numeric",
                    })
                  : "VẬN HÀNH NHÀ TRỌ"}
              </div>
              <h1>{pageInfo.label}</h1>
              <p>
                {
                  (
                    {
                      overview:
                        "Nhìn lại hoạt động và những việc cần làm hôm nay.",
                      rooms:
                        "Theo dõi tình trạng phòng và sẵn sàng đón người thuê.",
                      tenants:
                        "Hồ sơ người ở và thông tin liên hệ trong cùng một nơi.",
                      contracts:
                        "Theo dõi thời hạn thuê, tiền cọc và lịch sử trả phòng.",
                      billing:
                        "Từ chỉ số tiêu thụ đến hóa đơn rõ ràng từng khoản.",
                      payments: "Thu đủ, ghi đúng và đối soát từng giao dịch.",
                      incidents: "Tiếp nhận nhanh, theo dõi đến khi hoàn tất.",
                      settings: "Thiết lập khu trọ, đơn giá và quyền truy cập.",
                    } as Record<Page, string>
                  )[page]
                }
              </p>
            </div>
            <div className="heading-actions">
              <IconButton
                title="Làm mới dữ liệu"
                onClick={() => reload().catch(() => {})}
              >
                <RefreshCw size={18} className={refreshing ? "spin" : ""} />
              </IconButton>
              {page === "billing" && (
                <button className="button secondary" onClick={readingForm}>
                  <Plus size={16} />
                  Chốt điện nước
                </button>
              )}
              {mainAction[page] && (
                <button
                  className="button"
                  disabled={!data}
                  onClick={mainAction[page]!.run}
                >
                  <Plus size={17} />
                  {mainAction[page]!.title}
                </button>
              )}
            </div>
          </div>
          {loadError && data && <div className="error">{loadError}</div>}
          {children}
          <div className="page-footer">
            <span>DVP Home · Mọi thứ gọn gàng, mỗi ngày.</span>
            <span>{all("branches").length} khu trọ trong phạm vi quản lý</span>
          </div>
        </main>
      </div>

      <WorkspaceDialogs />
    </div>
  );
}
