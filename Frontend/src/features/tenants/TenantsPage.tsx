import { Paperclip, Pencil } from "lucide-react";
import { IconButton } from "../../shared/components/IconButton";
import { Table } from "../../shared/components/Table";
import { Toolbar } from "../../shared/components/Toolbar";
import { useWorkspace } from "../../app/WorkspaceContext";
import { useTenantForms } from "./useTenantForms";

export function TenantsPage() {
  const {
    tenants,
    search,
    setSearch,
    branchName,
    all,
    contracts,
    contractRoom,
    attach,
  } = useWorkspace();
  const { editTenant } = useTenantForms();
  return (
    <section className="panel">
      <Toolbar
        title={`${tenants.length} hồ sơ người thuê`}
        search={search}
        setSearch={setSearch}
      />
      <Table
        rows={tenants}
        search={search}
        columns={[
          {
            label: "Người thuê",
            cell: (r) => (
              <div className="person-cell">
                <span className="avatar">
                  {r.fullName.split(" ").slice(-1)[0].slice(0, 1)}
                </span>
                <div>
                  <strong>{r.fullName}</strong>
                  <small>{branchName(r.branchId)}</small>
                </div>
              </div>
            ),
          },
          { label: "Liên hệ", cell: (r) => r.phone },
          {
            label: "Giấy tờ",
            cell: (r) => r.identityNumber || "Chưa nhập",
          },
          {
            label: "Phòng đang ở",
            cell: (r) => {
              const ct = all("contractTenants").find(
                (x) =>
                  x.tenantId === r.id &&
                  contracts.some(
                    (c) => c.id === x.contractId && c.status === "Active",
                  ),
              );
              return ct ? (
                contractRoom(ct.contractId)
              ) : (
                <span className="muted">Chưa có hợp đồng hiện tại</span>
              );
            },
          },
          {
            label: "",
            cell: (r) => (
              <div className="row-actions">
                <IconButton title="Sửa hồ sơ" onClick={() => editTenant(r)}>
                  <Pencil size={16} />
                </IconButton>
                <IconButton
                  title="Giấy tờ / ảnh"
                  onClick={() => attach("tenant", r, `Giấy tờ · ${r.fullName}`)}
                >
                  <Paperclip size={16} />
                </IconButton>
              </div>
            ),
          },
        ]}
      />
    </section>
  );
}
