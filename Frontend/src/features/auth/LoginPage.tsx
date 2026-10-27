import { useState } from "react";
import { ArrowUpRight, Building2, Check, ShieldCheck } from "lucide-react";
import type { User } from "../../shared/types";
import { api } from "../../shared/api";
import { BrandLogo } from "../../shared/components/BrandLogo";

export function Login({ loggedIn }: { loggedIn: (user: User) => void }) {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);
  return (
    <div className="login-page">
      <section className="login-story">
        <div className="brand">
          <BrandLogo />
        </div>
        <div>
          <span className="eyebrow">MỖI NGÀY, GỌN GÀNG HƠN</span>
          <h1>
            Chăm ngôi nhà.
            <br />
            An tâm quản lý.
          </h1>
          <p>
            Phòng trọ, người thuê và các khoản thu —<br />
            mọi thứ ở cùng một nơi.
          </p>
          <div className="house-illustration">
            <Building2 size={150} strokeWidth={0.8} />
            <span>
              <Check size={18} /> Rõ từng phòng, đủ từng khoản
            </span>
          </div>
        </div>
        <small>DVP Home · Không gian quản lý của bạn</small>
      </section>
      <section className="login-form">
        <a className="mobile-brand" href="#browse">
          <BrandLogo />
        </a>
        <span className="eyebrow">CHÀO MỪNG TRỞ LẠI</span>
        <h2>Đăng nhập</h2>
        <p>Truy cập không gian dành cho chủ trọ, quản lý và người thuê.</p>
        <form
          onSubmit={async (e) => {
            e.preventDefault();
            setBusy(true);
            setError("");
            try {
              loggedIn(
                await api("/auth/login", "POST", { username, password }),
              );
            } catch (e) {
              setError((e as Error).message);
            } finally {
              setBusy(false);
            }
          }}
        >
          <label>
            Tên đăng nhập
            <input
              autoFocus
              autoComplete="username"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              required
              maxLength={50}
              placeholder="Nhập tên đăng nhập"
            />
          </label>
          <label>
            Mật khẩu
            <input
              type="password"
              autoComplete="current-password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              maxLength={128}
              placeholder="Nhập mật khẩu"
            />
          </label>
          {error && (
            <div className="error" role="alert">
              {error}
            </div>
          )}
          <button className="button" disabled={busy}>
            {busy ? (
              "Đang đăng nhập…"
            ) : (
              <>
                Đăng nhập
                <ArrowUpRight size={18} />
              </>
            )}
          </button>
        </form>
        <a className="text-button" href="#browse">
          ← Quay lại tìm phòng trống
        </a>
        <p className="login-note">
          <ShieldCheck size={17} /> Chỉ người được cấp quyền mới có thể truy
          cập.
        </p>
      </section>
    </div>
  );
}
