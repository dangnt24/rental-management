import { Pencil, Plus } from "lucide-react";
import type { Row } from "../../shared/types";
import { money } from "../../shared/formatters";
import { labels } from "../../shared/labels";
import { api } from "../../shared/api";
import { IconButton } from "../../shared/components/IconButton";
import { Table } from "../../shared/components/Table";
import { useWorkspace } from "../../app/WorkspaceContext";
import { useSettingsForms } from "./useSettingsForms";

export function SettingsPage() {
  const { user, setForm, setUser, setData, owner, all, branch, branchName } =
    useWorkspace();
  const { editBranch, editFee, editUser } = useSettingsForms();
  return (
    <>
      <section className="panel">
        <div className="panel-header">
          <div>
            <h2>Tài khoản của bạn</h2>
            <p>
              {user.fullName} · {labels[user.role]}
            </p>
          </div>
          <button
            className="button secondary"
            onClick={() =>
              setForm({
                title: "Đổi mật khẩu",
                description:
                  "Sau khi đổi mật khẩu, đăng nhập lại bằng mật khẩu mới.",
                fields: [
                  {
                    key: "currentPassword",
                    label: "Mật khẩu hiện tại",
                    type: "password",
                  },
                  {
                    key: "newPassword",
                    label: "Mật khẩu mới (ít nhất 10 ký tự)",
                    type: "password",
                  },
                ],
                initial: { currentPassword: "", newPassword: "" },
                submit: async (v) => {
                  await api("/auth/password", "POST", v);
                  setUser(null);
                  setData(null);
                },
              })
            }
          >
            Đổi mật khẩu
          </button>
        </div>
      </section>
      <section className="panel below">
        <div className="panel-header">
          <div>
            <h2>Khu trọ</h2>
            <p>Danh sách các khu bạn có quyền quản lý.</p>
          </div>
          {owner && (
            <button className="button secondary" onClick={() => editBranch()}>
              <Plus size={16} />
              Thêm khu trọ
            </button>
          )}
        </div>
        <Table
          rows={all("branches")}
          columns={[
            { label: "Tên khu", cell: (r) => <strong>{r.name}</strong> },
            { label: "Địa chỉ", cell: (r) => r.address },
            ...(owner
              ? [
                  {
                    label: "",
                    cell: (r: Row) => (
                      <IconButton
                        title="Sửa khu trọ"
                        onClick={() => editBranch(r)}
                      >
                        <Pencil size={16} />
                      </IconButton>
                    ),
                  },
                ]
              : []),
          ]}
        />
      </section>
      <section className="panel below">
        <div className="panel-header">
          <div>
            <h2>Đơn giá & dịch vụ</h2>
            <p>Đơn giá mới không làm thay đổi hóa đơn đã lập.</p>
          </div>
          {owner && (
            <button className="button secondary" onClick={() => editFee()}>
              <Plus size={16} />
              Thêm loại phí
            </button>
          )}
        </div>
        <Table
          rows={all("fees").filter((x) => !branch || x.branchId === branch)}
          columns={[
            {
              label: "Dịch vụ",
              cell: (r) => (
                <>
                  <strong>{r.name}</strong>
                  <small>{branchName(r.branchId)}</small>
                </>
              ),
            },
            { label: "Cách tính", cell: (r) => labels[r.method] },
            { label: "Đơn giá", cell: (r) => money(r.unitPrice) },
            {
              label: "Áp dụng",
              cell: (r) => (r.isArchived ? "Đã ngừng" : "Đang dùng"),
            },
            ...(owner
              ? [
                  {
                    label: "",
                    cell: (r: Row) => (
                      <IconButton
                        title="Sửa đơn giá"
                        onClick={() => editFee(r)}
                      >
                        <Pencil size={16} />
                      </IconButton>
                    ),
                  },
                ]
              : []),
          ]}
        />
      </section>
      {owner && (
        <>
          <section className="panel below">
            <div className="panel-header">
              <div>
                <h2>Tài khoản & phạm vi quản lý</h2>
                <p>
                  Quản lý theo khu được giao; người thuê theo hồ sơ được liên
                  kết.
                </p>
              </div>
              <button className="button secondary" onClick={() => editUser()}>
                <Plus size={16} />
                Cấp tài khoản
              </button>
            </div>
            <Table
              rows={all("users")}
              columns={[
                {
                  label: "Tài khoản",
                  cell: (r) => (
                    <>
                      <strong>{r.fullName}</strong>
                      <small>{r.username}</small>
                    </>
                  ),
                },
                { label: "Vai trò", cell: (r) => labels[r.role] },
                {
                  label: "Phạm vi truy cập",
                  cell: (r) =>
                    r.role === "Tenant"
                      ? `Người thuê: ${all("tenants").find((t) => t.id === r.tenantId)?.fullName || "—"}`
                      : r.role === "Owner"
                        ? "Tất cả khu"
                        : all("userBranches")
                            .filter((x) => x.userId === r.id)
                            .map((x) => branchName(x.branchId))
                            .join(", "),
                },
                {
                  label: "Trạng thái",
                  cell: (r) => (r.isActive ? "Hoạt động" : "Đã khóa"),
                },
                {
                  label: "",
                  cell: (r) => (
                    <IconButton
                      title="Sửa quyền tài khoản"
                      onClick={() => editUser(r)}
                    >
                      <Pencil size={16} />
                    </IconButton>
                  ),
                },
              ]}
            />
          </section>
          <section className="panel below">
            <div className="panel-header">
              <div>
                <h2>Nhật ký gần đây</h2>
                <p>30 thao tác mới nhất trong hệ thống.</p>
              </div>
            </div>
            <Table
              rows={all("audit")}
              columns={[
                {
                  label: "Thời điểm",
                  cell: (r) =>
                    new Date(r.createdAt).toLocaleString("vi-VN", {
                      timeZone: "Asia/Ho_Chi_Minh",
                    }),
                },
                { label: "Người thao tác", cell: (r) => r.createdBy },
                { label: "Nội dung", cell: (r) => r.detail },
              ]}
            />
          </section>
        </>
      )}
    </>
  );
}
