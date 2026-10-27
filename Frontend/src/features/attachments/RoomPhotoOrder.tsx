import type { ReactNode } from "react";
import { ArrowUp, ArrowDown, Pin, Image } from "lucide-react";
import type { Row } from "../../shared/types";
import { IconButton } from "../../shared/components/IconButton";

export function RoomPhotoOrder({
  photos,
  busy,
  dirty,
  move,
  actions,
}: {
  photos: Row[];
  busy: boolean;
  dirty: boolean;
  move: (from: number, to: number) => void;
  actions: (file: Row) => ReactNode;
}) {
  const coverId = photos.find((photo) => photo.isPublic)?.id;
  return (
    <section className="photo-order-section">
      <div className="photo-order-heading">
        <div>
          <h3>
            <Image size={18} />
            Ảnh phòng · {photos.length} ảnh
          </h3>
          <p>
            Ảnh công khai đứng đầu là ảnh đại diện. Dùng nút lên/xuống rồi lưu
            thứ tự.
          </p>
        </div>
      </div>
      {dirty && (
        <p className="photo-order-notice" role="status">
          Bạn đang xem thứ tự mới, chưa lưu.
        </p>
      )}
      <div className="photo-order-grid">
        {photos.map((file, index) => (
          <article className="photo-order-card" key={file.id}>
            <div className="photo-order-preview">
              <img
                src={"/api/attachments/" + file.id}
                alt={file.originalName}
              />
              <span className="photo-number">{index + 1}</span>
              {file.id === coverId && (
                <span className="photo-cover-label">
                  {dirty ? "Đại diện sau khi lưu" : "Ảnh đại diện"}
                </span>
              )}
            </div>
            <div className="photo-order-content">
              <a
                className="photo-file-name"
                href={"/api/attachments/" + file.id}
                download
              >
                {file.originalName}
              </a>
              <small>
                {Math.ceil(file.size / 1024)} KB ·{" "}
                {file.isPublic ? "Đang công khai" : "Riêng tư"}
              </small>
              <div className="photo-reorder-actions">
                <IconButton
                  title={"Lên trên: " + file.originalName}
                  disabled={busy || index === 0}
                  onClick={() => move(index, index - 1)}
                >
                  <ArrowUp size={17} />
                </IconButton>
                <IconButton
                  title={"Xuống dưới: " + file.originalName}
                  disabled={busy || index === photos.length - 1}
                  onClick={() => move(index, index + 1)}
                >
                  <ArrowDown size={17} />
                </IconButton>
                {file.isPublic && file.id !== coverId && (
                  <button
                    type="button"
                    className="text-button"
                    disabled={busy}
                    onClick={() => move(index, 0)}
                  >
                    <Pin size={15} />
                    Đặt làm ảnh đại diện
                  </button>
                )}
              </div>
              {actions(file)}
            </div>
          </article>
        ))}
      </div>
    </section>
  );
}
