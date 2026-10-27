import { useState } from "react";
import { Pencil, KeyRound, Mail, Phone } from "lucide-react";
import { useAccount, UserAvatar } from "./AccountProvider";

export function AccountPanel() {
  const { user, openProfile } = useAccount();
  const [error, setError] = useState("");
  if (!user) return null;
  async function open(password = false) {
    setError("");
    try {
      await openProfile(password ? "password" : "profile");
    } catch (error) {
      setError((error as Error).message);
    }
  }
  return (
    <div className="account-overview">
      <div className="account-overview-heading">
        <UserAvatar user={user} large />
        <div>
          <h2>{user.fullName}</h2>
          <p>{user.username}</p>
        </div>
      </div>
      <p>
        <Mail size={17} />
        {user.email || "Email chưa được cập nhật"}
      </p>
      <p>
        <Phone size={17} />
        {user.phone || "Số điện thoại chưa được cập nhật"}
      </p>
      <p className="muted">
        Liên hệ quản trị viên nếu cần đổi email hoặc số điện thoại.
      </p>
      <div className="heading-actions">
        <button
          className="button"
          onClick={() => {
            void open();
          }}
        >
          <Pencil size={16} />
          Chỉnh sửa thông tin & ảnh
        </button>
        <button
          className="button secondary"
          onClick={() => {
            void open(true);
          }}
        >
          <KeyRound size={16} />
          Đổi mật khẩu
        </button>
      </div>
      {error && (
        <div className="error" role="alert">
          {error}
        </div>
      )}
    </div>
  );
}
