import { useEffect, useRef, useState } from "react";
import {
  ChevronDown,
  KeyRound,
  LogOut,
  UserRound,
  LayoutDashboard,
  Users,
} from "lucide-react";
import { useAccount, UserAvatar } from "./AccountProvider";
import { useInteractionGuard } from "../../shared/InteractionGuard";
import { labels } from "../../shared/labels";

export function AccountMenu({ sidebar = false }: { sidebar?: boolean }) {
  const { user, openProfile, logout } = useAccount();
  const [open, setOpen] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState("");
  const root = useRef<HTMLDivElement>(null);
  const { navigate } = useInteractionGuard();
  useEffect(() => {
    if (!open) return;
    const outside = (event: MouseEvent) => {
      if (!root.current?.contains(event.target as Node)) setOpen(false);
    };
    const escape = (event: KeyboardEvent) => {
      if (event.key === "Escape") {
        event.stopPropagation();
        setOpen(false);
      }
    };
    document.addEventListener("mousedown", outside);
    document.addEventListener("keydown", escape);
    return () => {
      document.removeEventListener("mousedown", outside);
      document.removeEventListener("keydown", escape);
    };
  }, [open]);
  if (!user) return null;
  async function profile(password = false) {
    setOpen(false);
    setError("");
    try {
      await openProfile(password ? "password" : "profile");
    } catch (error) {
      setError((error as Error).message);
    }
  }
  return (
    <div className={"account-menu " + (sidebar ? "in-sidebar" : "")} ref={root}>
      <button
        type="button"
        className="account-menu-trigger"
        aria-label="Menu tài khoản"
        aria-expanded={open}
        aria-haspopup="menu"
        disabled={busy}
        onClick={() => setOpen((value) => !value)}
      >
        <UserAvatar user={user} />
        <span>
          <strong>{user.fullName}</strong>
          <small>{labels[user.role]}</small>
        </span>
        <ChevronDown size={16} />
      </button>
      {open && (
        <div
          className="account-menu-panel"
          role="menu"
          aria-label="Tài khoản của tôi"
        >
          {/* {!sidebar && (
            <button
              role="menuitem"
              onClick={async () => {
                setOpen(false);
                await navigate(user.role === "Tenant" ? "tenant" : "overview");
              }}
            >
              <LayoutDashboard size={17} />
              Không gian của tôi
            </button>
          )} */}
          <button
            role="menuitem"
            onClick={() => {
              void profile();
            }}
          >
            <UserRound size={17} />
            Xem thông tin tài khoản
          </button>
          <button
            role="menuitem"
            onClick={() => {
              void profile(true);
            }}
          >
            <KeyRound size={17} />
            Đổi mật khẩu
          </button>
          {/* {user.role === "Owner" && (
            <button
              role="menuitem"
              onClick={async () => {
                setOpen(false);
                await navigate("accounts");
              }}
            >
              <Users size={17} />
              Quản lý tài khoản
            </button>
          )} */}
          <button
            role="menuitem"
            className="danger"
            onClick={async () => {
              setOpen(false);
              setBusy(true);
              setError("");
              try {
                await logout();
              } catch (error) {
                setError((error as Error).message);
              } finally {
                setBusy(false);
              }
            }}
          >
            <LogOut size={17} />
            Đăng xuất
          </button>
        </div>
      )}
      {error && (
        <p className="account-menu-error" role="alert">
          {error}
        </p>
      )}
    </div>
  );
}
