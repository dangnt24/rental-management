import { Home, Paperclip, Pencil, X } from "lucide-react";
import { money } from "../../shared/formatters";
import { labels } from "../../shared/labels";
import { api } from "../../shared/api";
import { Badge } from "../../shared/components/Badge";
import { IconButton } from "../../shared/components/IconButton";
import { Table } from "../../shared/components/Table";
import { Toolbar } from "../../shared/components/Toolbar";
import { useWorkspace } from "../../app/WorkspaceContext";
import { useRoomForms } from "./useRoomForms";

export function RoomsPage() {
  const {
    rooms,
    search,
    setSearch,
    status,
    setStatus,
    branchName,
    attach,
    setForm,
  } = useWorkspace();
  const { editRoom } = useRoomForms();
  return (
    <section className="panel">
      <Toolbar
        title={`${rooms.filter((x) => !x.isArchived).length} phòng trong danh sách`}
        search={search}
        setSearch={setSearch}
        status={status}
        setStatus={setStatus}
        states={["Available", "Occupied", "Maintenance", "Archived"]}
      />
      <Table
        search={search}
        rows={rooms
          .filter((x) => !status || x.status === status)
          .map((x) => ({
            ...x,
            branchName: branchName(x.branchId),
            statusLabel: labels[x.status],
          }))}
        columns={[
          {
            label: "Phòng",
            cell: (r) => (
              <div className="room-cell">
                <span>
                  <Home size={20} />
                </span>
                <div>
                  <strong>{r.name}</strong>
                  <small>{branchName(r.branchId)}</small>
                </div>
              </div>
            ),
          },
          {
            label: "Giá thuê",
            cell: (r) => (
              <>
                {money(r.price)}
                <small>/ tháng</small>
              </>
            ),
          },
          { label: "Sức chứa", cell: (r) => `${r.capacity} người` },
          { label: "Trạng thái", cell: (r) => <Badge value={r.status} /> },
          {
            label: "Mô tả",
            cell: (r) => (
              <span className="truncate">{r.description || "—"}</span>
            ),
          },
          {
            label: "",
            cell: (r) => (
              <div className="row-actions">
                <IconButton title="Sửa phòng" onClick={() => editRoom(r)}>
                  <Pencil size={16} />
                </IconButton>
                <IconButton
                  title="Ảnh phòng"
                  onClick={() => attach("room", r, `Ảnh / tài liệu ${r.name}`)}
                >
                  <Paperclip size={16} />
                </IconButton>
                {r.status === "Available" && (
                  <IconButton
                    title="Ngừng sử dụng"
                    onClick={() =>
                      setForm({
                        title: "Ngừng sử dụng phòng",
                        description: `${r.name} sẽ được lưu lịch sử và không thể lập hợp đồng mới.`,
                        fields: [],
                        initial: {},
                        submit: () => api(`/rooms/${r.id}`, "DELETE"),
                      })
                    }
                  >
                    <X size={16} />
                  </IconButton>
                )}
              </div>
            ),
          },
        ]}
      />
    </section>
  );
}
