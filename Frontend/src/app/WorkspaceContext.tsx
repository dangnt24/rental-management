import { useState, useEffect, createContext, useContext } from "react";
import type { ReactNode, Dispatch, SetStateAction } from "react";
import type { Row, User, Page, Field, FormDefinition } from "../shared/types";
import { nav } from "./navigation";
import { api } from "../shared/api";
import { options } from "../shared/forms";

// Dữ liệu đã tải, bộ lọc và trạng thái dialog; nghiệp vụ form nằm ở từng feature.
function useWorkspaceState(
  user: User,
  setUser: Dispatch<SetStateAction<User | null>>,
) {
  const [data, setData] = useState<Row | null>(null);
  const [page, setPage] = useState<Page>(
    (location.hash.slice(1) as Page) || "overview",
  );
  const [branch, setBranch] = useState(0);
  const [search, setSearch] = useState("");
  const [status, setStatus] = useState("");
  const [form, setForm] = useState<FormDefinition | null>(null);
  const [toast, setToast] = useState("");
  const [loadError, setLoadError] = useState("");
  const [fileTarget, setFileTarget] = useState<{
    type: string;
    id: number;
    title: string;
  } | null>(null);
  const [printBill, setPrintBill] = useState<Row | null>(null);
  const [showMenu, setShowMenu] = useState(false);
  const [refreshing, setRefreshing] = useState(false);
  async function reload() {
    setRefreshing(true);
    try {
      setData(await api("/workspace"));
      setLoadError("");
    } catch (e) {
      setLoadError((e as Error).message);
      throw e;
    } finally {
      setRefreshing(false);
    }
  }
  async function completed() {
    await reload();
    setToast("Đã lưu thông tin.");
  }
  useEffect(() => {
    if (user) {
      setData(null);
      setBranch(0);
      reload().catch(() => {});
    }
  }, [user?.id]);
  useEffect(() => {
    if (toast) {
      const id = setTimeout(() => setToast(""), 4000);
      return () => clearTimeout(id);
    }
  }, [toast]);
  function navigate(next: Page) {
    setPage(next);
    location.hash = next;
    setSearch("");
    setStatus("");
    setShowMenu(false);
  }
  useEffect(() => {
    const change = () => {
      const hash = location.hash.slice(1) as Page;
      if (nav.some((x) => x.id === hash)) {
        setPage(hash);
        setSearch("");
        setStatus("");
      }
    };
    window.addEventListener("hashchange", change);
    return () => window.removeEventListener("hashchange", change);
  }, []);
  const owner = user.role === "Owner";
  const all = (name: string): Row[] => data?.[name] || [];
  const rooms = all("rooms").filter((x) => !branch || x.branchId === branch);
  const roomIds = new Set(rooms.map((x) => x.id));
  const contracts = all("contracts").filter((x) => roomIds.has(x.roomId));
  const contractIds = new Set(contracts.map((x) => x.id));
  const bills = all("invoices").filter((x) => contractIds.has(x.contractId));
  const billIds = new Set(bills.map((x) => x.id));
  const payments = all("payments").filter((x) => billIds.has(x.invoiceId));
  const tenants = all("tenants").filter(
    (x) => !branch || x.branchId === branch,
  );
  const incidents = all("incidents").filter((x) => roomIds.has(x.roomId));
  const roomName = (id: number) =>
    all("rooms").find((x) => x.id === id)?.name || "—";
  const contractRoom = (id: number) =>
    roomName(all("contracts").find((x) => x.id === id)?.roomId);
  const branchName = (id: number) =>
    all("branches").find((x) => x.id === id)?.name || "—";
  const representative = (id: number) =>
    all("tenants").find(
      (t) =>
        t.id ===
        all("contractTenants").find(
          (x) => x.contractId === id && x.isRepresentative,
        )?.tenantId,
    )?.fullName || "—";
  const billStatus = (r: Row) =>
    r.status === "Cancelled"
      ? "Cancelled"
      : r.outstanding === 0
        ? "Paid"
        : r.paid > 0
          ? "Partial"
          : "Unpaid";
  const today = data?.today || new Date().toISOString().slice(0, 10);
  const month = Number(today.slice(5, 7));
  const year = Number(today.slice(0, 4));
  const branches = options(
    all("branches").filter((x) => !x.isArchived),
    (x) => x.name,
  );
  const branchField: Field = {
    key: "branchId",
    label: "Khu trọ",
    type: "number",
    options: branches,
  };
  const defaultBranch = branch || all("branches")[0]?.id || 0;
  const attach = (type: string, r: Row, title: string) =>
    setFileTarget({ type, id: r.id, title });
  const action = async (fn: () => Promise<unknown>) => {
    try {
      await fn();
      await completed();
    } catch (e) {
      setToast((e as Error).message);
    }
  };
  return {
    user,
    setUser,
    data,
    setData,
    page,
    setPage,
    branch,
    setBranch,
    search,
    setSearch,
    status,
    setStatus,
    form,
    setForm,
    toast,
    setToast,
    loadError,
    setLoadError,
    fileTarget,
    setFileTarget,
    printBill,
    setPrintBill,
    showMenu,
    setShowMenu,
    refreshing,
    setRefreshing,
    reload,
    completed,
    navigate,
    owner,
    all,
    rooms,
    roomIds,
    contracts,
    contractIds,
    bills,
    billIds,
    payments,
    tenants,
    incidents,
    roomName,
    contractRoom,
    branchName,
    representative,
    billStatus,
    today,
    month,
    year,
    branches,
    branchField,
    defaultBranch,
    attach,
    action,
  };
}
type WorkspaceContextValue = ReturnType<typeof useWorkspaceState>;
const WorkspaceContext = createContext<WorkspaceContextValue | null>(null);
export function WorkspaceProvider({
  user,
  setUser,
  children,
}: {
  user: User;
  setUser: Dispatch<SetStateAction<User | null>>;
  children: ReactNode;
}) {
  const value = useWorkspaceState(user, setUser);
  return (
    <WorkspaceContext.Provider value={value}>
      {children}
    </WorkspaceContext.Provider>
  );
}
export function useWorkspace() {
  const value = useContext(WorkspaceContext);
  if (!value)
    throw new Error("useWorkspace phải được dùng trong WorkspaceProvider.");
  return value;
}
