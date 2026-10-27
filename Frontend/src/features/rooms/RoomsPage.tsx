import { Home, Paperclip, Pencil, X, Eye } from "lucide-react";
import { useState } from "react";
import type { Row } from "../../shared/types";
import { Modal } from "../../shared/components/Modal";
import { RoomDetails } from "./RoomDetails";
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
  const [detail, setDetail] = useState<Row | null>(null);
  const {
    rooms,
    search,
    setSearch,
    status,
    setStatus,
    branchName,
    attach,
    setForm,
    all,
  } = useWorkspace();
  const { editRoom } = useRoomForms();
  return (
    <>
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
          onRowOpen={setDetail}
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
                    {r.area != null && (
                      <small>
                        {Number(r.area).toLocaleString("vi-VN")} m²
                        {r.floor ? ` · ${r.floor}` : ""}
                      </small>
                    )}
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
                  <IconButton
                    title="Xem chi tiết phòng"
                    onClick={() => setDetail(r)}
                  >
                    <Eye size={16} />
                  </IconButton>
                  <IconButton title="Sửa phòng" onClick={() => editRoom(r)}>
                    <Pencil size={16} />
                  </IconButton>
                  <IconButton
                    title="Ảnh phòng"
                    onClick={() =>
                      attach("room", r, `Ảnh / tài liệu ${r.name}`)
                    }
                  >
                    <Paperclip size={16} />
                  </IconButton>
                  {r.status === "Available" && (
                    <IconButton
                      title="Ngừng sử dụng"
                      onClick={() =>
                        setForm({
                          title: "Ngừng sử dụng phòng",
                          confirmation: {
                            title: `Ngừng sử dụng ${r.name}?`,
                            message:
                              "Phòng sẽ được gỡ khỏi danh sách cho thuê. Lịch sử vẫn được giữ lại.",
                            confirmLabel: "Ngừng sử dụng",
                            danger: true,
                          },
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
      {detail && (
        <Modal
          title={`Chi tiết phòng ${detail.name}`}
          wide
          close={() => setDetail(null)}
        >
          <RoomDetails
            room={{
              ...detail,
              branch: all("branches").find(
                (branch) => branch.id === detail.branchId,
              ),
              fees: all("fees").filter(
                (fee) => fee.branchId === detail.branchId && !fee.isArchived,
              ),
              photos: all("attachments").filter(
                (file) =>
                  file.entityType === "room" &&
                  file.entityId === detail.id &&
                  ["image/jpeg", "image/png"].includes(file.contentType),
              ),
            }}
            photoUrl={(id) => `/api/attachments/${id}`}
          />
          <footer>
            <button
              className="button secondary"
              onClick={() => setDetail(null)}
            >
              <X size={16} />
              Đóng
            </button>
            <button
              className="button"
              onClick={() => {
                editRoom(detail);
                setDetail(null);
              }}
            >
              <Pencil size={16} />
              Chỉnh sửa thông tin
            </button>
          </footer>
        </Modal>
      )}
    </>
  );
}
