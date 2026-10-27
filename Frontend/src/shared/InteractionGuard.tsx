import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useLayoutEffect,
  useRef,
  useState,
} from "react";
import type { ReactNode } from "react";
import { AlertTriangle, Check, X } from "lucide-react";

type Confirmation = {
  title: string;
  message: string;
  confirmLabel?: string;
  danger?: boolean;
};
type Draft = { dirty: boolean; busy: boolean };
type Guard = {
  confirm: (options: Confirmation) => Promise<boolean>;
  leave: (
    options?: Partial<Confirmation> & { always?: boolean },
  ) => Promise<boolean>;
  navigate: (next: string) => Promise<boolean>;
  route: string;
  drafts: Map<symbol, Draft>;
};
const Context = createContext<Guard | null>(null);
const currentRoute = () => location.hash.slice(1) || "browse";

// Một nơi xử lý xác nhận thao tác và bảo vệ bản nháp trong toàn ứng dụng.
export function InteractionGuard({ children }: { children: ReactNode }) {
  const drafts = useRef(new Map<symbol, Draft>()).current;
  const [route, setRoute] = useState(currentRoute);
  const acceptedRoute = useRef(currentRoute());
  const [pending, setPending] = useState<Confirmation | null>(null);
  const resolver = useRef<((accepted: boolean) => void) | null>(null);
  const dialog = useRef<HTMLElement>(null);
  const cancelButton = useRef<HTMLButtonElement>(null);
  const confirm = useCallback((options: Confirmation) => {
    if (resolver.current) return Promise.resolve(false);
    return new Promise<boolean>((resolve) => {
      resolver.current = resolve;
      setPending(options);
    });
  }, []);
  const finish = useCallback((accepted: boolean) => {
    const resolve = resolver.current;
    resolver.current = null;
    setPending(null);
    resolve?.(accepted);
  }, []);
  const leave = useCallback(
    async (options: Partial<Confirmation> & { always?: boolean } = {}) => {
      const entries = [...drafts.values()];
      if (entries.some((entry) => entry.busy)) {
        await confirm({
          title: "Thao tác đang được xử lý",
          message: "Vui lòng đợi lưu hoặc tải file hoàn tất trước khi rời đi.",
          confirmLabel: "Đã hiểu",
        });
        return false;
      }
      const dirty = entries.some((entry) => entry.dirty);
      if (!dirty && !options.always) return true;
      return confirm({
        title: options.title || "Bỏ thay đổi chưa lưu?",
        message:
          (options.message ||
            "Những nội dung bạn đang chỉnh sửa chưa được lưu.") +
          (dirty && options.message ? " Các thay đổi chưa lưu sẽ bị bỏ." : ""),
        confirmLabel: options.confirmLabel || "Bỏ thay đổi",
        danger: options.danger ?? true,
      });
    },
    [confirm, drafts],
  );
  const navigate = useCallback(
    async (next: string) => {
      if (next === acceptedRoute.current) return true;
      if (!(await leave())) return false;
      acceptedRoute.current = next;
      location.hash = next;
      setRoute(next);
      return true;
    },
    [leave],
  );
  useEffect(() => {
    const changed = async () => {
      const next = currentRoute();
      if (next === acceptedRoute.current) return;
      // Giữ nguyên hash đã chấp nhận trong lúc chờ, tránh Back/Forward làm mất form.
      history.replaceState(null, "", `#${acceptedRoute.current}`);
      if (await leave()) {
        acceptedRoute.current = next;
        history.replaceState(null, "", `#${next}`);
        setRoute(next);
      }
    };
    const followLink = (event: MouseEvent) => {
      if (
        event.defaultPrevented ||
        event.button !== 0 ||
        event.ctrlKey ||
        event.metaKey ||
        event.shiftKey ||
        event.altKey
      )
        return;
      const anchor = (event.target as Element).closest<HTMLAnchorElement>(
        "a[href^='#']",
      );
      if (
        !anchor ||
        anchor.target === "_blank" ||
        anchor.hasAttribute("download")
      )
        return;
      const next = anchor.hash.slice(1) || "browse";
      if (next === acceptedRoute.current) return;
      event.preventDefault();
      void navigate(next);
    };
    const unload = (event: BeforeUnloadEvent) => {
      if ([...drafts.values()].some((draft) => draft.dirty || draft.busy)) {
        event.preventDefault();
        event.returnValue = "";
      }
    };
    window.addEventListener("hashchange", changed);
    document.addEventListener("click", followLink);
    window.addEventListener("beforeunload", unload);
    return () => {
      window.removeEventListener("hashchange", changed);
      document.removeEventListener("click", followLink);
      window.removeEventListener("beforeunload", unload);
    };
  }, [drafts, leave, navigate]);
  useEffect(() => {
    if (!pending) return;
    const previous = document.activeElement as HTMLElement | null;
    cancelButton.current?.focus();
    const keydown = (event: KeyboardEvent) => {
      if (event.key === "Escape") {
        event.preventDefault();
        event.stopImmediatePropagation();
        finish(false);
      }
      if (event.key === "Tab") {
        const buttons =
          dialog.current?.querySelectorAll<HTMLButtonElement>("button");
        if (!buttons?.length) return;
        const first = buttons[0],
          last = buttons[buttons.length - 1];
        if (event.shiftKey && document.activeElement === first) {
          event.preventDefault();
          last.focus();
        } else if (!event.shiftKey && document.activeElement === last) {
          event.preventDefault();
          first.focus();
        }
      }
    };
    document.addEventListener("keydown", keydown, true);
    return () => {
      document.removeEventListener("keydown", keydown, true);
      if (previous?.isConnected) previous.focus();
    };
  }, [pending, finish]);
  return (
    <Context.Provider value={{ confirm, leave, navigate, route, drafts }}>
      {children}
      {pending && (
        <div className="confirmation-backdrop" data-confirmation="true">
          <section
            className="confirmation-dialog"
            role="alertdialog"
            aria-modal="true"
            aria-labelledby="confirmation-title"
            aria-describedby="confirmation-message"
            ref={dialog}
          >
            <span
              className={
                "confirmation-symbol " + (pending.danger ? "danger" : "")
              }
            >
              <AlertTriangle size={24} />
            </span>
            <h2 id="confirmation-title">{pending.title}</h2>
            <p id="confirmation-message">{pending.message}</p>
            <footer>
              <button
                type="button"
                className="button secondary"
                ref={cancelButton}
                onClick={() => finish(false)}
              >
                <X size={16} />
                Quay lại
              </button>
              <button
                type="button"
                className={"button " + (pending.danger ? "destructive" : "")}
                onClick={() => finish(true)}
              >
                <Check size={16} />
                {pending.confirmLabel || "Xác nhận"}
              </button>
            </footer>
          </section>
        </div>
      )}
    </Context.Provider>
  );
}
export function useInteractionGuard() {
  const value = useContext(Context);
  if (!value) throw new Error("Thiếu InteractionGuard.");
  return value;
}
export function useUnsavedChanges(dirty: boolean, busy = false) {
  const { drafts } = useInteractionGuard();
  const token = useRef(Symbol("draft")).current;
  useLayoutEffect(() => {
    drafts.set(token, { dirty, busy });
    return () => {
      drafts.delete(token);
    };
  }, [drafts, token, dirty, busy]);
}
