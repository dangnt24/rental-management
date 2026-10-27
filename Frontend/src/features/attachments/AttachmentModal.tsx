import { useState } from "react";
import { Download, Paperclip, Plus } from "lucide-react";
import type { Row } from "../../shared/types";
import { api } from "../../shared/api";
import { Modal } from "../../shared/components/Modal";

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
  const [busy, setBusy] = useState(false);
  return (
    <Modal title={target.title} close={close}>
      <p className="form-description">
        Ảnh JPG/PNG hoặc tài liệu PDF, tối đa 5 MB. File chỉ được tải bởi người
        có quyền quản lý khu trọ. Riêng ảnh phòng có thể được chọn đăng công
        khai trên trang tìm phòng.
      </p>
      <div className="attachment-list">
        {files.map((file) => (
          <div className="attachment-row" key={file.id}>
            <a href={`/api/attachments/${file.id}`} download>
              <Paperclip size={18} />
              <span>
                {file.originalName}
                <small>{(file.size / 1024).toFixed(0)} KB</small>
              </span>
              <Download size={18} />
            </a>
            {target.type === "room" &&
              ["image/png", "image/jpeg"].includes(file.contentType) && (
                <button
                  className="text-button"
                  disabled={busy}
                  onClick={async () => {
                    setBusy(true);
                    setError("");
                    try {
                      await api(`/attachments/${file.id}/visibility`, "POST", {
                        isPublic: !file.isPublic,
                      });
                      await complete();
                    } catch (e) {
                      setError((e as Error).message);
                    } finally {
                      setBusy(false);
                    }
                  }}
                >
                  {file.isPublic
                    ? "Ẩn khỏi trang tìm phòng"
                    : "Đăng ảnh trên trang tìm phòng"}
                </button>
              )}
          </div>
        ))}
        {!files.length && <p className="muted">Chưa có file đính kèm.</p>}
      </div>
      <label className="upload-box">
        <Plus size={22} />
        <strong>{busy ? "Đang tải lên…" : "Chọn file để tải lên"}</strong>
        <span>JPG, PNG, PDF · Tối đa 5 MB</span>
        <input
          type="file"
          accept="image/jpeg,image/png,application/pdf"
          disabled={busy}
          onChange={async (e) => {
            const file = e.target.files?.[0];
            if (!file) return;
            setBusy(true);
            setError("");
            try {
              const body = new FormData();
              body.append("file", file);
              await api(
                `/attachments/${target.type}/${target.id}`,
                "POST",
                body,
              );
              await complete();
            } catch (e) {
              setError((e as Error).message);
            } finally {
              setBusy(false);
            }
          }}
        />
      </label>
      {error && <div className="error">{error}</div>}
      <footer>
        <button className="button secondary" onClick={close}>
          Đóng
        </button>
      </footer>
    </Modal>
  );
}
