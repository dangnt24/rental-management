import type { Row } from "../../shared/types";
import { api } from "../../shared/api";
import { amountField } from "../../shared/forms";
import { useWorkspace } from "../../app/WorkspaceContext";

export function useRoomForms() {
  const { setForm, branchField, defaultBranch } = useWorkspace();
  function editRoom(row?: Row) {
    setForm({
      title: row ? "Chỉnh sửa phòng" : "Thêm phòng trọ",
      fields: [
        branchField,
        { key: "name", label: "Tên / số phòng" },
        amountField("price", "Giá thuê tham khảo (đ)"),
        {
          key: "capacity",
          label: "Sức chứa (người)",
          type: "number",
          min: 1,
          max: 50,
        },
        {
          key: "isMaintenance",
          label: "Phòng đang sửa",
          type: "checkbox",
          required: false,
        },
        {
          key: "description",
          label: "Mô tả phòng (hiển thị trên trang tìm phòng)",
          type: "textarea",
          required: false,
        },
      ],
      initial: row || {
        branchId: defaultBranch,
        name: "",
        price: 3000000,
        capacity: 2,
        isMaintenance: false,
        description: "",
      },
      submit: (v) =>
        api("/rooms" + (row ? "/" + row.id : ""), row ? "PUT" : "POST", v),
    });
  }
  return { editRoom };
}
