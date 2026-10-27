import { useState } from "react";
import { Pencil, Search, RotateCcw, ShieldCheck } from "lucide-react";
import { useWorkspace } from "../../app/WorkspaceContext";
import { labels } from "../../shared/labels";
import { Table } from "../../shared/components/Table";
import { IconButton } from "../../shared/components/IconButton";
import { useInteractionGuard } from "../../shared/InteractionGuard";
import { useAccountForms } from "./useAccountForms";
import { UserAvatar } from "./AccountProvider";
import type { Row } from "../../shared/types";

const normalize = (value: string) =>
  value
    .toLocaleLowerCase("vi")
    .normalize("NFD")
    .replace(/\p{M}/gu, "")
    .replaceAll("đ", "d");
export function AccountsPage() {
  const { owner, all, branchName } = useWorkspace();
  const { editUser } = useAccountForms();
  const { confirm } = useInteractionGuard();
  const [query, setQuery] = useState("");
  const [role, setRole] = useState("");
  const [status, setStatus] = useState("");
  const [scope, setScope] = useState(0);
  if (!owner)
    return (
      <div className="notice">
        <ShieldCheck size={18} />
        Chỉ chủ trọ có quyền quản lý tài khoản và phạm vi truy cập.
      </div>
    );
  const branchIds = (user: Row) =>
    user.role === "Owner"
      ? all("branches").map((branch) => branch.id)
      : user.role === "Manager"
        ? all("userBranches")
            .filter((link) => link.userId === user.id)
            .map((link) => link.branchId)
        : [
            all("tenants").find((tenant) => tenant.id === user.tenantId)
              ?.branchId,
          ];
  const access = (user: Row) =>
    user.role === "Owner"
      ? "Tất cả khu trọ"
      : user.role === "Tenant"
        ? "Người thuê: " +
          (all("tenants").find((tenant) => tenant.id === user.tenantId)
            ?.fullName || "Chưa liên kết")
        : branchIds(user).map(branchName).join(", ");
  const users = all("users");
  const visible = users.filter(
    (user) =>
      (!role || user.role === role) &&
      (!status || user.isActive === (status === "active")) &&
      (!scope || branchIds(user).includes(scope)) &&
      normalize(
        [
          user.fullName,
          user.username,
          user.email || "",
          user.phone || "",
          access(user),
          ...branchIds(user).map(branchName),
        ].join(" "),
      ).includes(normalize(query.trim())),
  );
  return (
    <section className="panel accounts-panel">
      <div className="panel-header">
        <div>
          <h2>
            {visible.length} / {users.length} tài khoản
          </h2>
          <p>
            Tra cứu người dùng, thông tin liên hệ, trạng thái và các khu được
            phân quyền.
          </p>
        </div>
      </div>
      <div className="account-filters">
        <label>
          Tìm tài khoản
          <div className="account-search">
            <Search size={17} />
            <input
              value={query}
              onChange={(event) => setQuery(event.target.value)}
              placeholder="Tên, tài khoản, email, điện thoại…"
              aria-label="Tìm tài khoản"
            />
          </div>
        </label>
        <label>
          Vai trò
          <select
            value={role}
            onChange={(event) => setRole(event.target.value)}
          >
            <option value="">Tất cả vai trò</option>
            {["Owner", "Manager", "Tenant"].map((value) => (
              <option key={value} value={value}>
                {labels[value]}
              </option>
            ))}
          </select>
        </label>
        <label>
          Trạng thái
          <select
            value={status}
            onChange={(event) => setStatus(event.target.value)}
          >
            <option value="">Tất cả trạng thái</option>
            <option value="active">Hoạt động</option>
            <option value="locked">Đã khóa</option>
          </select>
        </label>
        <label>
          Phạm vi khu trọ
          <select
            value={scope}
            onChange={(event) => setScope(Number(event.target.value))}
          >
            <option value={0}>Tất cả khu</option>
            {all("branches").map((branch) => (
              <option key={branch.id} value={branch.id}>
                {branch.name}
              </option>
            ))}
          </select>
        </label>
        <button
          type="button"
          className="text-button"
          onClick={async () => {
            if (
              await confirm({
                title: "Xóa bộ lọc tài khoản?",
                message: "Đặt lại các điều kiện tra cứu về mặc định.",
                confirmLabel: "Xóa bộ lọc",
                danger: true,
              })
            ) {
              setQuery("");
              setRole("");
              setStatus("");
              setScope(0);
            }
          }}
        >
          <RotateCcw size={16} />
          Xóa bộ lọc
        </button>
      </div>
      <Table
        rows={visible}
        resetKey={[query, role, status, scope].join("|")}
        onRowOpen={editUser}
        empty="Không có tài khoản phù hợp."
        columns={[
          {
            label: "Tài khoản",
            cell: (user) => (
              <div className="person-cell">
                <UserAvatar
                  user={{ fullName: user.fullName, avatarUrl: user.avatarUrl }}
                />
                <div>
                  <strong>{user.fullName}</strong>
                  <small>{user.username}</small>
                </div>
              </div>
            ),
          },
          {
            label: "Liên hệ",
            cell: (user) => (
              <>
                <span>{user.email || "Chưa có email"}</span>
                <small>{user.phone || "Chưa có số điện thoại"}</small>
              </>
            ),
          },
          { label: "Vai trò", cell: (user) => labels[user.role] },
          {
            label: "Phạm vi truy cập",
            cell: (user) => <span className="wrap">{access(user)}</span>,
          },
          {
            label: "Trạng thái",
            cell: (user) => (
              <span className={user.isActive ? "green" : "red"}>
                {user.isActive ? "Hoạt động" : "Đã khóa"}
              </span>
            ),
          },
          {
            label: "Thao tác",
            cell: (user) => (
              <IconButton
                title="Chỉnh sửa tài khoản"
                onClick={() => editUser(user)}
              >
                <Pencil size={16} />
              </IconButton>
            ),
          },
        ]}
      />
    </section>
  );
}
