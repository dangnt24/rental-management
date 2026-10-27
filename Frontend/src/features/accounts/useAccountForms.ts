import type { Row } from "../../shared/types";
import { labels } from "../../shared/labels";
import { api } from "../../shared/api";
import { options } from "../../shared/forms";
import { useWorkspace } from "../../app/WorkspaceContext";
export function useAccountForms() {
  const { setForm, branches, all, defaultBranch } = useWorkspace();
  function editUser(row?: Row) {
    setForm({
      title: row ? "Chỉnh sửa tài khoản" : "Cấp tài khoản",
      description:
        "Quản lý cần khu được giao. Người thuê cần gắn với hồ sơ có sẵn; mỗi hồ sơ chỉ có một tài khoản.",
      fields: [
        { key: "username", label: "Tên đăng nhập" },
        { key: "fullName", label: "Họ tên" },
        {
          key: "email",
          label: "Email tài khoản",
          type: "email",
          required: false,
          hint: "Chỉ chủ trọ được cập nhật thông tin liên hệ này.",
        },
        {
          key: "phone",
          label: "Số điện thoại tài khoản",
          type: "tel",
          required: false,
        },
        {
          key: "role",
          label: "Vai trò",
          options: ["Owner", "Manager", "Tenant"].map((value) => ({
            value,
            label: labels[value],
          })),
        },
        {
          key: "password",
          label: row
            ? "Mật khẩu mới (để trống nếu giữ)"
            : "Mật khẩu (tối thiểu 10 ký tự)",
          type: "password",
          required: !row,
        },
        {
          key: "branchIds",
          label: "Các khu trọ được quản lý",
          type: "multi",
          options: branches,
          required: true,
          visible: (values) => values.role === "Manager",
          hint: "Chỉ áp dụng cho vai trò Quản lý.",
        },
        {
          key: "tenantId",
          label: "Hồ sơ người thuê (cho vai trò Người thuê)",
          type: "number",
          options: options(
            all("tenants").filter(
              (t) =>
                !t.isArchived &&
                !all("users").some(
                  (u) => u.tenantId === t.id && u.id !== row?.id,
                ),
            ),
            (t) =>
              `${t.fullName} · ${all("branches").find((b) => b.id === t.branchId)?.name || ""} · #${t.id}`,
          ),
          required: true,
          visible: (values) => values.role === "Tenant",
        },
        {
          key: "isActive",
          label: "Tài khoản hoạt động",
          type: "checkbox",
          required: false,
        },
      ],
      initial: row
        ? {
            ...row,
            tenantId: row.tenantId || "",
            password: "",
            email: row.email || "",
            phone: row.phone || "",
            branchIds: all("userBranches")
              .filter((x) => x.userId === row.id)
              .map((x) => x.branchId),
          }
        : {
            username: "",
            fullName: "",
            email: "",
            phone: "",
            role: "Manager",
            tenantId: "",
            password: "",
            branchIds: [defaultBranch],
            isActive: true,
          },
      submit: (v) =>
        api("/users" + (row ? "/" + row.id : ""), row ? "PUT" : "POST", {
          ...v,
          branchIds: v.role === "Manager" ? v.branchIds : [],
          tenantId:
            v.role === "Tenant" && v.tenantId ? Number(v.tenantId) : null,
        }),
    });
  }
  return { editUser };
}
