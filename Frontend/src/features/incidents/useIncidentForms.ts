import type { Row } from "../../shared/types";
import { labels } from "../../shared/labels";
import { api } from "../../shared/api";
import { options, amountField } from "../../shared/forms";
import { useWorkspace } from "../../app/WorkspaceContext";

export function useIncidentForms() {
  const { setForm, rooms } = useWorkspace();
  function editIncident(row?: Row) {
    setForm({
      title: row ? "Cập nhật xử lý sự cố" : "Tiếp nhận sự cố",
      fields: [
        {
          key: "roomId",
          label: "Phòng",
          type: "number",
          options: options(
            rooms.filter((x) => !x.isArchived),
            (x) => x.name,
          ),
        },
        { key: "description", label: "Nội dung", type: "textarea" },
        {
          key: "status",
          label: "Trạng thái",
          options: ["Open", "InProgress", "Resolved"].map((value) => ({
            value,
            label: labels[value],
          })),
        },
        amountField("cost", "Chi phí sửa chữa (đ)"),
        {
          key: "resolution",
          label: "Cách xử lý / kết quả",
          type: "textarea",
          required: false,
        },
      ],
      initial: row || {
        roomId: rooms.find((x) => !x.isArchived)?.id || "",
        description: "",
        status: "Open",
        cost: 0,
        resolution: "",
      },
      submit: (v) =>
        api("/incidents" + (row ? "/" + row.id : ""), row ? "PUT" : "POST", v),
    });
  }
  return { editIncident };
}
