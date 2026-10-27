import { useEffect, useRef, useState } from "react";
import { createPortal } from "react-dom";
import {
  ChevronLeft,
  ChevronRight,
  X,
  ImageOff,
  ZoomIn,
  ZoomOut,
  RotateCcw,
} from "lucide-react";
import type { Row } from "../../shared/types";
import { useBodyScrollLock } from "../../shared/useBodyScrollLock";
import { usePhotoZoom } from "./usePhotoZoom";
import { MAX_PHOTO_SCALE, MIN_PHOTO_SCALE } from "./photoViewport";

// Dùng chung cho phòng công khai, phòng của người thuê và màn hình quản lý.
export function RoomPhotoViewer({
  roomName,
  photos,
  activeId,
  photoUrl,
  select,
  close,
}: {
  roomName: string;
  photos: Row[];
  activeId: number;
  photoUrl: (id: number) => string;
  select: (id: number) => void;
  close: () => void;
}) {
  const root = useRef<HTMLDivElement>(null);
  const closeButton = useRef<HTMLButtonElement>(null);
  const [failedId, setFailedId] = useState<number | null>(null);
  useBodyScrollLock();
  const index = Math.max(
    0,
    photos.findIndex((photo) => photo.id === activeId),
  );
  const current = photos[index];
  const move = (step: number) =>
    select(photos[(index + step + photos.length) % photos.length].id);
  const zoom = usePhotoZoom(current.id, move);
  const navigation = useRef({ move, close });
  navigation.current = { move, close };
  useEffect(() => {
    const previousFocus = document.activeElement as HTMLElement | null;
    closeButton.current?.focus();
    const keydown = (event: KeyboardEvent) => {
      if (["Escape", "ArrowLeft", "ArrowRight"].includes(event.key)) {
        event.preventDefault();
        event.stopPropagation();
        if (event.key === "Escape") navigation.current.close();
        else navigation.current.move(event.key === "ArrowLeft" ? -1 : 1);
      } else if (event.key === "Tab") {
        const buttons = Array.from(
          root.current?.querySelectorAll<HTMLButtonElement>(
            "button:not(:disabled)",
          ) || [],
        );
        const first = buttons[0],
          last = buttons[buttons.length - 1];
        if (event.shiftKey && document.activeElement === first) {
          event.preventDefault();
          last?.focus();
        } else if (!event.shiftKey && document.activeElement === last) {
          event.preventDefault();
          first?.focus();
        }
      }
    };
    // Capture trước listener Esc của modal chi tiết bên dưới.
    document.addEventListener("keydown", keydown, true);
    return () => {
      document.removeEventListener("keydown", keydown, true);
      if (previousFocus?.isConnected) previousFocus.focus();
    };
  }, []);
  return createPortal(
    <div
      className="room-photo-viewer"
      data-photo-viewer
      role="dialog"
      aria-modal="true"
      aria-label={`Ảnh phòng ${roomName}`}
      ref={root}
    >
      <header>
        <div>
          <strong>Phòng {roomName}</strong>
          <span role="status" aria-live="polite">
            Ảnh {index + 1} / {photos.length}
          </span>
        </div>
        <div className="room-photo-viewer-tools">
          <button
            type="button"
            aria-label="Thu nhỏ ảnh"
            title="Thu nhỏ ảnh"
            disabled={
              zoom.transform.scale <= MIN_PHOTO_SCALE || failedId === current.id
            }
            onClick={() => zoom.zoom(zoom.transform.scale / 1.3)}
          >
            <ZoomOut size={20} />
          </button>
          <output aria-label="Mức phóng to" title="100% là ảnh vừa khung">
            {Math.round(zoom.transform.scale * 100)}%
          </output>
          <button
            type="button"
            aria-label="Phóng to ảnh"
            title="Phóng to ảnh"
            disabled={
              zoom.transform.scale >= MAX_PHOTO_SCALE || failedId === current.id
            }
            onClick={() => zoom.zoom(zoom.transform.scale * 1.3)}
          >
            <ZoomIn size={20} />
          </button>
          <button
            type="button"
            aria-label="Ảnh vừa khung"
            title="Đặt lại ảnh vừa khung"
            disabled={zoom.transform.scale === 1}
            onClick={zoom.reset}
          >
            <RotateCcw size={19} />
          </button>
          <button
            type="button"
            ref={closeButton}
            onClick={close}
            aria-label="Đóng ảnh phóng to"
          >
            <X size={23} />
          </button>
        </div>
      </header>
      <div className="room-photo-viewer-stage">
        <div
          ref={zoom.canvas}
          className={
            "room-photo-canvas" +
            (zoom.transform.scale > 1 ? " zoomed" : "") +
            (zoom.dragging ? " dragging" : "")
          }
          {...zoom.handlers}
        >
          {failedId === current.id ? (
            <p className="room-photo-load-error" role="alert">
              <ImageOff size={34} />
              Không tải được ảnh này. Bạn có thể chuyển sang ảnh khác.
            </p>
          ) : (
            <img
              ref={zoom.image}
              key={current.id}
              src={photoUrl(current.id)}
              alt={`Phòng ${roomName} · ảnh ${index + 1} / ${photos.length}`}
              draggable={false}
              style={{
                transform: `translate(${zoom.transform.x}px, ${zoom.transform.y}px) scale(${zoom.transform.scale})`,
              }}
              onError={() => setFailedId(current.id)}
            />
          )}
        </div>
        {photos.length > 1 && (
          <>
            <button
              type="button"
              className="room-photo-previous"
              onClick={() => move(-1)}
              aria-label="Ảnh trước"
            >
              <ChevronLeft size={30} />
            </button>
            <button
              type="button"
              className="room-photo-next"
              onClick={() => move(1)}
              aria-label="Ảnh tiếp theo"
            >
              <ChevronRight size={30} />
            </button>
          </>
        )}
      </div>
      <footer>
        {photos.length > 1 && (
          <div
            className="room-photo-viewer-thumbnails"
            aria-label="Danh sách ảnh phòng"
          >
            {photos.map((photo, position) => (
              <button
                type="button"
                key={photo.id}
                aria-label={`Chọn ảnh ${position + 1}`}
                aria-pressed={photo.id === current.id}
                onClick={() => select(photo.id)}
              >
                <img src={photoUrl(photo.id)} alt="" loading="lazy" />
              </button>
            ))}
          </div>
        )}
        <p>
          Lăn chuột hoặc dùng hai ngón để zoom · Kéo ảnh khi phóng to
          <br />
          {photos.length > 1
            ? "← → để chuyển ảnh · Vuốt khi ảnh vừa khung · Esc để đóng"
            : "Esc để đóng ảnh"}
        </p>
      </footer>
    </div>,
    document.body,
  );
}
