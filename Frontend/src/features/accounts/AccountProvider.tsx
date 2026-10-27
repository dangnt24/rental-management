import { createContext, useContext, useEffect, useState } from "react";
import type { ReactNode, Dispatch, SetStateAction } from "react";
import { Camera, Check, KeyRound, LockKeyhole, Save, X } from "lucide-react";
import type { User } from "../../shared/types";
import { api } from "../../shared/api";
import { labels } from "../../shared/labels";
import { Modal } from "../../shared/components/Modal";
import {
  useInteractionGuard,
  useUnsavedChanges,
} from "../../shared/InteractionGuard";

type ProfileTab = "profile" | "password";
const AccountContext = createContext<{
  user: User | null;
  setUser: Dispatch<SetStateAction<User | null>>;
  openProfile: (tab?: ProfileTab) => Promise<void>;
  logout: () => Promise<void>;
} | null>(null);
export function useAccount() {
  const value = useContext(AccountContext);
  if (!value) throw new Error("Thiếu AccountProvider.");
  return value;
}

export function UserAvatar({
  user,
  preview,
  large = false,
}: {
  user: Pick<User, "fullName" | "avatarUrl">;
  preview?: string;
  large?: boolean;
}) {
  const src = preview || user.avatarUrl;
  return (
    <span className={"avatar user-avatar" + (large ? " large" : "")}>
      {src ? (
        <img src={src} alt={"Ảnh đại diện " + user.fullName} />
      ) : (
        user.fullName
          .trim()
          .split(/\s+/)
          .filter(Boolean)
          .map((part) => Array.from(part)[0])
          .slice(-2)
          .join("")
          .toUpperCase() || "?"
      )}
    </span>
  );
}
export function AccountProvider({
  user,
  setUser,
  children,
}: {
  user: User | null;
  setUser: Dispatch<SetStateAction<User | null>>;
  children: ReactNode;
}) {
  const [tab, setTab] = useState<ProfileTab | null>(null);
  const { route, leave } = useInteractionGuard();
  useEffect(() => setTab(null), [route]);
  async function openProfile(next: ProfileTab = "profile") {
    setUser(await api("/auth/me"));
    setTab(next);
  }
  async function logout() {
    if (
      !(await leave({
        always: true,
        title: "Đăng xuất khỏi DVP Home?",
        message: "Bạn cần đăng nhập lại để tiếp tục sử dụng tài khoản.",
        confirmLabel: "Đăng xuất",
      }))
    )
      return;
    await api("/auth/logout", "POST");
    setUser(null);
    location.hash = "browse";
  }
  return (
    <AccountContext.Provider value={{ user, setUser, openProfile, logout }}>
      {children}
      {user && tab && (
        <ProfileDialog
          key={user.id}
          initialTab={tab}
          close={() => setTab(null)}
        />
      )}
    </AccountContext.Provider>
  );
}
function ProfileDialog({
  initialTab,
  close,
}: {
  initialTab: ProfileTab;
  close: () => void;
}) {
  const { user: currentUser, setUser } = useAccount();
  const user = currentUser!;
  const [tab, setTab] = useState(initialTab);
  const [name, setName] = useState(user.fullName);
  const [avatar, setAvatar] = useState<File | null>(null);
  const [preview, setPreview] = useState("");
  const [currentPassword, setCurrentPassword] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [repeatPassword, setRepeatPassword] = useState("");
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState("");
  const [notice, setNotice] = useState("");
  const { leave, confirm } = useInteractionGuard();
  const dirty =
    tab === "profile"
      ? name !== user.fullName || !!avatar
      : !!(currentPassword || newPassword || repeatPassword);
  useUnsavedChanges(dirty, busy);
  useEffect(() => {
    if (!avatar) {
      setPreview("");
      return;
    }
    const url = URL.createObjectURL(avatar);
    setPreview(url);
    return () => URL.revokeObjectURL(url);
  }, [avatar]);
  async function requestClose() {
    if (!busy && (await leave())) close();
  }
  async function changeTab(next: ProfileTab) {
    if (next === tab || !(await leave())) return;
    setTab(next);
    setName(user.fullName);
    setAvatar(null);
    setCurrentPassword("");
    setNewPassword("");
    setRepeatPassword("");
    setError("");
    setNotice("");
  }
  return (
    <Modal
      title="Thông tin tài khoản"
      close={() => {
        void requestClose();
      }}
    >
      <div className="profile-tabs">
        <button
          className={tab === "profile" ? "active" : ""}
          onClick={() => {
            void changeTab("profile");
          }}
          disabled={busy}
        >
          <Camera size={16} />
          Hồ sơ cá nhân
        </button>
        <button
          className={tab === "password" ? "active" : ""}
          onClick={() => {
            void changeTab("password");
          }}
          disabled={busy}
        >
          <KeyRound size={16} />
          Đổi mật khẩu
        </button>
      </div>
      {tab === "profile" ? (
        <form
          onSubmit={async (event) => {
            event.preventDefault();
            if (busy) return;
            setBusy(true);
            setError("");
            setNotice("");
            try {
              const body = new FormData();
              body.append("fullName", name.trim());
              if (avatar) body.append("avatar", avatar);
              const updated = await api("/auth/profile", "PUT", body);
              setUser(updated);
              setName(updated.fullName);
              setAvatar(null);
              setNotice("Đã cập nhật thông tin tài khoản.");
              window.dispatchEvent(new Event("account-profile-updated"));
            } catch (error) {
              setError((error as Error).message);
            } finally {
              setBusy(false);
            }
          }}
        >
          <div className="profile-editor">
            <div className="profile-avatar-editor">
              <UserAvatar user={user} preview={preview} large />
              <div>
                <strong>{user.username}</strong>
                <small>{labels[user.role]}</small>
                <label className="text-button avatar-upload-control">
                  <Camera size={15} />
                  Chọn ảnh đại diện
                  <input
                    aria-label="Chọn ảnh đại diện"
                    type="file"
                    accept="image/jpeg,image/png"
                    disabled={busy}
                    onChange={(event) => {
                      const file = event.target.files?.[0];
                      event.target.value = "";
                      if (!file) return;
                      if (
                        file.size === 0 ||
                        file.size > 2 * 1024 * 1024 ||
                        !/\.(png|jpe?g)$/i.test(file.name)
                      ) {
                        setError("Chọn một ảnh JPG/PNG, tối đa 2 MB.");
                        return;
                      }
                      setAvatar(file);
                      setError("");
                      setNotice("");
                    }}
                  />
                </label>
                <small>JPG/PNG · Tối đa 2 MB · Áp dụng khi lưu</small>
                {avatar && (
                  <button
                    className="text-button"
                    type="button"
                    disabled={busy}
                    onClick={async () => {
                      if (
                        await confirm({
                          title: "Bỏ ảnh đang chọn?",
                          message: "Ảnh đại diện đã lưu vẫn được giữ.",
                          confirmLabel: "Bỏ ảnh đang chọn",
                          danger: true,
                        })
                      )
                        setAvatar(null);
                    }}
                  >
                    <X size={14} />
                    Bỏ ảnh đang chọn
                  </button>
                )}
              </div>
            </div>
            <label>
              Họ tên hiển thị
              <input
                value={name}
                maxLength={100}
                required
                disabled={busy}
                onChange={(event) => setName(event.target.value)}
                autoComplete="name"
              />
            </label>
            <label>
              Email
              <input
                value={user.email || ""}
                readOnly
                placeholder="Chưa cập nhật"
                aria-describedby="contact-admin-note"
              />
            </label>
            <label>
              Số điện thoại
              <input
                value={user.phone || ""}
                readOnly
                placeholder="Chưa cập nhật"
                aria-describedby="contact-admin-note"
              />
            </label>
            <p className="profile-contact-note" id="contact-admin-note">
              <LockKeyhole size={17} />
              Email và số điện thoại do quản trị viên quản lý. Vui lòng liên hệ
              quản trị viên nếu cần thay đổi.
            </p>
            {error && (
              <div className="error" role="alert">
                {error}
              </div>
            )}
            {notice && (
              <p className="profile-success" role="status">
                <Check size={16} />
                {notice}
              </p>
            )}
          </div>
          <footer>
            <button
              className="button secondary"
              type="button"
              onClick={() => {
                void requestClose();
              }}
              disabled={busy}
            >
              <X size={16} />
              Đóng
            </button>
            <button className="button" disabled={busy || !dirty}>
              <Save size={16} />
              {busy ? "Đang lưu…" : "Lưu hồ sơ"}
            </button>
          </footer>
        </form>
      ) : (
        <form
          onSubmit={async (event) => {
            event.preventDefault();
            if (busy) return;
            setError("");
            if (newPassword !== repeatPassword) {
              setError("Mật khẩu nhập lại không khớp.");
              return;
            }
            if (
              !(await confirm({
                title: "Đổi mật khẩu và đăng nhập lại?",
                message:
                  "Bạn cần đăng nhập lại bằng mật khẩu mới sau khi lưu thành công.",
                confirmLabel: "Đổi mật khẩu",
              }))
            )
              return;
            setBusy(true);
            try {
              await api("/auth/password", "POST", {
                currentPassword,
                newPassword,
              });
              close();
              setUser(null);
              location.hash = "login";
            } catch (error) {
              setError((error as Error).message);
            } finally {
              setBusy(false);
            }
          }}
        >
          <div className="profile-editor">
            <p className="muted">
              Mật khẩu mới từ 10 đến 128 ký tự. Sau khi đổi thành công, bạn cần
              đăng nhập lại.
            </p>
            <label>
              Mật khẩu hiện tại
              <input
                type="password"
                value={currentPassword}
                onChange={(event) => setCurrentPassword(event.target.value)}
                required
                maxLength={128}
                autoComplete="current-password"
                disabled={busy}
              />
            </label>
            <label>
              Mật khẩu mới
              <input
                type="password"
                value={newPassword}
                onChange={(event) => setNewPassword(event.target.value)}
                required
                minLength={10}
                maxLength={128}
                autoComplete="new-password"
                disabled={busy}
              />
            </label>
            <label>
              Nhập lại mật khẩu mới
              <input
                type="password"
                value={repeatPassword}
                onChange={(event) => setRepeatPassword(event.target.value)}
                required
                minLength={10}
                maxLength={128}
                autoComplete="new-password"
                disabled={busy}
              />
            </label>
            {error && (
              <div className="error" role="alert">
                {error}
              </div>
            )}
          </div>
          <footer>
            <button
              type="button"
              className="button secondary"
              disabled={busy}
              onClick={() => {
                void requestClose();
              }}
            >
              <X size={16} />
              Đóng
            </button>
            <button className="button" disabled={busy}>
              <KeyRound size={16} />
              Đổi mật khẩu
            </button>
          </footer>
        </form>
      )}
    </Modal>
  );
}
