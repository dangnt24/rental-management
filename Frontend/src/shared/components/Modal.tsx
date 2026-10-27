import { useEffect } from "react";
import type { ReactNode } from "react";
import { X } from "lucide-react";
import { IconButton } from "./IconButton";
import { useBodyScrollLock } from "../useBodyScrollLock";

export function Modal({
  title,
  children,
  close,
  wide = false,
}: {
  title: string;
  children: ReactNode;
  close: () => void;
  wide?: boolean;
}) {
  useBodyScrollLock();
  useEffect(() => {
    const f = (e: KeyboardEvent) => {
      if (
        e.key === "Escape" &&
        !e.defaultPrevented &&
        !document.querySelector("[data-confirmation], [data-photo-viewer]")
      )
        close();
    };
    document.addEventListener("keydown", f);
    return () => {
      document.removeEventListener("keydown", f);
    };
  }, [close]);
  return (
    <div
      className="modal-backdrop"
      onMouseDown={(e) => {
        if (e.target === e.currentTarget) close();
      }}
    >
      <section
        className={"modal " + (wide ? "wide" : "")}
        role="dialog"
        aria-modal="true"
        aria-label={title}
      >
        <header>
          <h2>{title}</h2>
          <IconButton title="Đóng" onClick={close}>
            <X size={20} />
          </IconButton>
        </header>
        {children}
      </section>
    </div>
  );
}
