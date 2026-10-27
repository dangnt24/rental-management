import type { Row } from "../../shared/types";
import { api } from "../../shared/api";
import { useWorkspace } from "../../app/WorkspaceContext";

export function useTenantForms() {
  const { setForm, branchField, defaultBranch } = useWorkspace();
  function editTenant(row?: Row) {
    setForm({
      title: row ? "Chỉnh sửa người thuê" : "Thêm người thuê",
      fields: [
        branchField,
        { key: "fullName", label: "Họ tên" },
        { key: "phone", label: "Số điện thoại", type: "tel" },
        { key: "identityNumber", label: "Số CCCD / giấy tờ", required: false },
        {
          key: "address",
          label: "Địa chỉ thường trú",
          type: "textarea",
          required: false,
        },
      ],
      initial: row || {
        branchId: defaultBranch,
        fullName: "",
        phone: "",
        identityNumber: "",
        address: "",
      },
      submit: (v) =>
        api("/tenants" + (row ? "/" + row.id : ""), row ? "PUT" : "POST", v),
    });
  }
  return { editTenant };
}
