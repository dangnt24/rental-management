import type { Row } from "../../shared/types";
import { labels } from "../../shared/labels";
import { api } from "../../shared/api";
import { amountField } from "../../shared/forms";
import { useWorkspace } from "../../app/WorkspaceContext";

export function useSettingsForms() {
  const { setForm, branchField, defaultBranch } = useWorkspace();
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

  return { editBranch, editFee };
}
