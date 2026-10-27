import { Paperclip, Pencil } from "lucide-react";
import { money } from "../../shared/formatters";
import { Badge } from "../../shared/components/Badge";
import { IconButton } from "../../shared/components/IconButton";
import { Table } from "../../shared/components/Table";
import { Toolbar } from "../../shared/components/Toolbar";
import { useWorkspace } from "../../app/WorkspaceContext";
import { useIncidentForms } from "./useIncidentForms";

export function IncidentsPage() {
  const { incidents, search, setSearch, status, setStatus, roomName, attach } =
    useWorkspace();
  const { editIncident } = useIncidentForms();
  return (
    <section className="panel">
      <Toolbar
        title={`${incidents.filter((x) => x.status !== "Resolved").length} sự cố chưa hoàn tất`}
        search={search}
        setSearch={setSearch}
        status={status}
        setStatus={setStatus}
        states={["Open", "InProgress", "Resolved"]}
      />
      <Table
        rows={incidents
          .filter((x) => !status || x.status === status)
          .map((x) => ({ ...x, room: roomName(x.roomId) }))}
        search={search}
        columns={[
          {
            label: "Phòng / nội dung",
            cell: (r) => (
              <>
                <strong>{r.room}</strong>
                <small className="wrap">{r.description}</small>
              </>
            ),
          },
          { label: "Trạng thái", cell: (r) => <Badge value={r.status} /> },
          { label: "Chi phí", cell: (r) => money(r.cost) },
          {
            label: "Cách xử lý",
            cell: (r) => (
              <span className="truncate">
                {r.resolution || "Chưa cập nhật"}
              </span>
            ),
          },
          {
            label: "",
            cell: (r) => (
              <div className="row-actions">
                <IconButton
                  title="Cập nhật xử lý"
                  onClick={() => editIncident(r)}
                >
                  <Pencil size={16} />
                </IconButton>
                <IconButton
                  title="Ảnh sự cố"
                  onClick={() => attach("incident", r, "Ảnh / file sự cố")}
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
