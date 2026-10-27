import type { Row } from "../../shared/types";
import { labels } from "../../shared/labels";
import { api } from "../../shared/api";
import { options, amountField } from "../../shared/forms";
import { useWorkspace } from "../../app/WorkspaceContext";

export function useSettingsForms() {
  const { setForm, branchField, defaultBranch, branches, all } = useWorkspace();
  function editBranch(row?: Row) {
    setForm({
      title: row ? "Chỉnh sửa khu trọ" : "Thêm khu trọ",
      fields: [
        { key: "name", label: "Tên khu trọ" },
        { key: "address", label: "Địa chỉ", type: "textarea" },
      ],
      initial: row || { name: "", address: "" },
      submit: (v) =>
        api("/branches" + (row ? "/" + row.id : ""), row ? "PUT" : "POST", v),
    });
  }

  function editFee(row?: Row) {
    setForm({
      title: row ? "Chỉnh sửa đơn giá dịch vụ" : "Thêm loại phí",
      description:
        "Thay đổi chỉ áp dụng cho hóa đơn lập sau đó. Mỗi khu chỉ có một phí điện và một phí nước đang dùng.",
      fields: [
        branchField,
        { key: "name", label: "Tên phí" },
        {
          key: "method",
          label: "Cách tính",
          options: ["Electricity", "Water", "Fixed", "PerPerson"].map(
            (value) => ({ value, label: labels[value] }),
          ),
        },
        amountField("unitPrice", "Đơn giá (đ)"),
        {
          key: "isArchived",
          label: "Ngừng áp dụng",
          type: "checkbox",
          required: false,
        },
      ],
      initial: row || {
        branchId: defaultBranch,
        name: "",
        method: "Fixed",
        unitPrice: 0,
        isArchived: false,
      },
      submit: (v) =>
        api("/fees" + (row ? "/" + row.id : ""), row ? "PUT" : "POST", v),
    });
  }

  function editUser(row?: Row) {
    setForm({
      title: row ? "Chỉnh sửa tài khoản" : "Cấp tài khoản",
      description:
        "Quản lý cần khu được giao. Người thuê cần gắn với hồ sơ có sẵn; mỗi hồ sơ chỉ có một tài khoản.",
      fields: [
        { key: "username", label: "Tên đăng nhập" },
        { key: "fullName", label: "Họ tên" },
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
            branchIds: all("userBranches")
              .filter((x) => x.userId === row.id)
              .map((x) => x.branchId),
          }
        : {
            username: "",
            fullName: "",
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
  return { editBranch, editFee, editUser };
}
