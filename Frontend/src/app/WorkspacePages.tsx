import { RefreshCw } from "lucide-react";
import { useWorkspace } from "./WorkspaceContext";
import { OverviewPage } from "../features/overview/OverviewPage";
import { RoomsPage } from "../features/rooms/RoomsPage";
import { TenantsPage } from "../features/tenants/TenantsPage";
import { ContractsPage } from "../features/contracts/ContractsPage";
import { BillingPage } from "../features/billing/BillingPage";
import { PaymentsPage } from "../features/payments/PaymentsPage";
import { IncidentsPage } from "../features/incidents/IncidentsPage";
import { SettingsPage } from "../features/settings/SettingsPage";

export function WorkspacePages() {
  const { data, refreshing, loadError, reload, page } = useWorkspace();
  if (!data)
    return (
      <div className="empty">
        <RefreshCw size={28} className={refreshing ? "spin" : ""} />
        <p>{loadError || "Đang tải dữ liệu khu trọ…"}</p>
        <button
          className="button secondary"
          onClick={() => reload().catch(() => {})}
        >
          Tải lại
        </button>
      </div>
    );
  switch (page) {
    case "overview":
      return <OverviewPage />;
    case "rooms":
      return <RoomsPage />;
    case "tenants":
      return <TenantsPage />;
    case "contracts":
      return <ContractsPage />;
    case "billing":
      return <BillingPage />;
    case "payments":
      return <PaymentsPage />;
    case "incidents":
      return <IncidentsPage />;
    default:
      return <SettingsPage />;
  }
}
