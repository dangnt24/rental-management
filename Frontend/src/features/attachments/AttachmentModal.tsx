import { useState } from "react";
import {
  Download,
  Paperclip,
  Plus,
  Trash2,
  Eye,
  EyeOff,
  X,
  Save,
  RotateCcw,
  RefreshCw,
} from "lucide-react";
import {
  useInteractionGuard,
  useUnsavedChanges,
} from "../../shared/InteractionGuard";
import type { Row } from "../../shared/types";
import { api } from "../../shared/api";
import { Modal } from "../../shared/components/Modal";
import { RoomPhotoOrder } from "./RoomPhotoOrder";

const imageFile = (file: Row) =>
  ["image/png", "image/jpeg"].includes(file.contentType);
export function AttachmentModal({
  target,
  files,
  close,
  complete,
}: {
  target: { type: string; id: number; title: string };
  files: Row[];
  close: () => void;
  complete: () => Promise<void>;
}) {
  const [error, setError] = useState("");
  const [notice, setNotice] = useState("");
  const [busy, setBusy] = useState(false);
  const [uploadCount, setUploadCount] = useState(0);
  const [photoOrder, setPhotoOrder] = useState<number[] | null>(null);
  const { confirm, leave } = useInteractionGuard();
  const sorted = [...files].sort(
    (a, b) => (a.sortOrder || 0) - (b.sortOrder || 0) || a.id - b.id,
  );
  const canonical = target.type === "room" ? sorted.filter(imageFile) : [];
  const byId = new Map(canonical.map((file) => [file.id, file]));
  const photos = photoOrder
    ? [
        ...photoOrder.filter((id) => byId.has(id)).map((id) => byId.get(id)!),
        ...canonical.filter((file) => !photoOrder.includes(file.id)),
      ]
    : canonical;
  const dirty = photos.some((file, index) => file.id !== canonical[index]?.id);
  const documents =
    target.type === "room" ? sorted.filter((file) => !imageFile(file)) : sorted;
  useUnsavedChanges(dirty, busy);
  async function requestClose() {
    if (!busy && (await leave())) close();
  }
  function move(from: number, to: number) {
    if (busy || to < 0 || to >= photos.length) return;
    const next = photos.map((file) => file.id);
    next.splice(to, 0, next.splice(from, 1)[0]);
    setPhotoOrder(next);
    setNotice("");
  }
  async function saveOrder() {
    if (busy || !dirty) return;
    setBusy(true);
    setError("");
    setNotice("");
    try {
      await api("/attachments/room/" + target.id + "/order", "POST", {
        photoIds: photos.map((file) => file.id),
      });
      await complete();
      setPhotoOrder(null);
      setNotice("Đã lưu thứ tự ảnh.");
    } catch (error) {
      setError((error as Error).message);
    } finally {
      setBusy(false);
    }
  }
  async function refresh() {
    if (
      !(await leave({
        always: true,
        title: "Tải lại danh sách file?",
        message: "Lấy danh sách file và thứ tự đã lưu mới nhất.",
        confirmLabel: "Tải lại",
        danger: false,
      }))
    )
      return;
    setBusy(true);
    setError("");
    try {
      await complete();
      setPhotoOrder(null);
      setNotice("");
    } catch (error) {
      setError((error as Error).message);
    } finally {
      setBusy(false);
    }
  }
  async function mutate(action: () => Promise<unknown>, message: string) {
    setBusy(true);
    setError("");
    setNotice("");
    try {
      await action();
      await complete();
      setNotice(message);
    } catch (error) {
      setError((error as Error).message);
    } finally {
      setBusy(false);
    }
  }
  function actions(file: Row) {
    return (
      <div className="attachment-actions">
        {target.type === "room" && imageFile(file) && (
          <button
            type="button"
            className="text-button"
            disabled={busy}
            onClick={async () => {
              if (
                file.isPublic &&
                !(await confirm({
                  title: "Ẩn ảnh khỏi trang tìm phòng?",
                  message:
                    "Khách truy cập sẽ không còn thấy ảnh này. File vẫn nằm trong hồ sơ phòng.",
                  confirmLabel: "Ẩn ảnh",
                }))
              )
                return;
              await mutate(
                () =>
                  api("/attachments/" + file.id + "/visibility", "POST", {
                    isPublic: !file.isPublic,
                  }),
                file.isPublic ? "Đã ẩn ảnh." : "Đã đăng ảnh công khai.",
              );
            }}
          >
            {file.isPublic ? <EyeOff size={15} /> : <Eye size={15} />}
            {file.isPublic ? "Ẩn khỏi trang tìm phòng" : "Đăng ảnh công khai"}
          </button>
        )}
        <button
          type="button"
          className="text-button danger"
          disabled={busy}
          onClick={async () => {
            if (
              !(await confirm({
                title: "Xóa file đính kèm?",
                message:
                  "Gỡ “" +
                  file.originalName +
                  "” khỏi hồ sơ" +
                  (file.isPublic ? " và trang tìm phòng" : "") +
                  "?",
                confirmLabel: "Xóa file",
                danger: true,
              }))
            )
              return;
            await mutate(
              () => api("/attachments/" + file.id, "DELETE"),
              "Đã xóa file.",
            );
          }}
        >
          <Trash2 size={15} />
          Xóa file
        </button>
      </div>
    );
  }
  return (
    <Modal
      title={target.title}
      close={() => {
        void requestClose();
      }}
      wide={target.type === "room"}
    >
      <p className="form-description">
        Chọn cùng lúc tối đa 10 file JPG/PNG/PDF, mỗi file không quá 10 MB. File
        mới mặc định riêng tư; chọn đăng công khai với ảnh phòng muốn giới
        thiệu.
      </p>
      <div className="attachment-manager-toolbar">
        <button
          type="button"
          className="text-button"
          disabled={busy}
          onClick={refresh}
        >
          <RefreshCw size={15} />
          Tải lại danh sách
        </button>
      </div>
      {target.type === "room" && photos.length > 0 && (
        <RoomPhotoOrder
          photos={photos}
          busy={busy}
          dirty={dirty}
          move={move}
          actions={actions}
        />
      )}
      <div className="attachment-list">
        {documents.map((file) => (
          <div className="attachment-row" key={file.id}>
            <a href={"/api/attachments/" + file.id} download>
              <Paperclip size={18} />
              <span>
                {file.originalName}
                <small>{Math.ceil(file.size / 1024)} KB</small>
              </span>
              <Download size={18} />
            </a>
            {actions(file)}
          </div>
        ))}
        {!files.length && <p className="muted">Chưa có file đính kèm.</p>}
      </div>
      <label className="upload-box">
        <Plus size={22} />
        <strong>
          {busy
            ? uploadCount
              ? "Đang tải " + uploadCount + " file…"
              : "Đang xử lý…"
            : "Chọn nhiều file để tải lên"}
        </strong>
        <span>JPG, PNG, PDF · 10 file/lượt · 10 MB/file</span>
        <input
          type="file"
          multiple
          accept="image/jpeg,image/png,application/pdf"
          disabled={busy}
          onChange={async (event) => {
            const selected = Array.from(event.target.files || []);
            event.target.value = "";
            if (!selected.length) return;
            setError("");
            setNotice("");
            if (selected.length > 10) {
              setError("Mỗi lượt chỉ chọn tối đa 10 file.");
              return;
            }
            const invalid = selected.find(
              (file) =>
                file.size === 0 ||
                file.size > 10 * 1024 * 1024 ||
                !/\.(jpe?g|png|pdf)$/i.test(file.name),
            );
            if (invalid) {
              setError(
                "File “" +
                  invalid.name +
                  "” không đúng định dạng hoặc vượt 10 MB. Chưa tải file nào trong lượt này.",
              );
              return;
            }
            setUploadCount(selected.length);
            await mutate(
              async () => {
                const body = new FormData();
                selected.forEach((file) => body.append("files", file));
                await api(
                  "/attachments/" + target.type + "/" + target.id,
                  "POST",
                  body,
                );
              },
              "Đã tải lên " + selected.length + " file.",
            );
            setUploadCount(0);
          }}
        />
      </label>
      {notice && (
        <p className="attachment-notice" role="status">
          {notice}
        </p>
      )}
      {error && (
        <div className="error" role="alert">
          {error}
        </div>
      )}
      <footer className="attachment-manager-footer">
        <button
          type="button"
          className="button secondary"
          onClick={() => {
            void requestClose();
          }}
          disabled={busy}
        >
          <X size={16} />
          Đóng
        </button>
        {dirty && (
          <>
            <button
              type="button"
              className="button secondary"
              disabled={busy}
              onClick={async () => {
                if (
                  await confirm({
                    title: "Bỏ thứ tự ảnh đang chỉnh?",
                    message:
                      "Danh sách sẽ trở về thứ tự đã lưu. Các file vẫn được giữ.",
                    confirmLabel: "Đặt lại thứ tự",
                    danger: true,
                  })
                ) {
                  setPhotoOrder(null);
                  setNotice("");
                }
              }}
            >
              <RotateCcw size={16} />
              Đặt lại thứ tự
            </button>
            <button
              type="button"
              className="button"
              disabled={busy}
              onClick={saveOrder}
            >
              <Save size={16} />
              Lưu thứ tự ảnh
            </button>
          </>
        )}
      </footer>
    </Modal>
  );
}
