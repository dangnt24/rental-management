import type { User } from "../types";
import { BrandLogo } from "./BrandLogo";

export function SiteHeader({
  user,
  onFindRooms,
}: {
  user: User | null;
  onFindRooms?: () => void;
}) {
  return (
    <header className="site-header">
      <a className="brand" href="#browse">
        <BrandLogo />
      </a>
      <nav aria-label="Điều hướng chính">
        <a
          href="#browse/rooms"
          onClick={() => {
            if (location.hash === "#browse/rooms") onFindRooms?.();
          }}
        >
          Tìm phòng
        </a>
        <a
          className="button"
          href={
            user ? (user.role === "Tenant" ? "#tenant" : "#overview") : "#login"
          }
        >
          {user ? "Không gian của tôi" : "Đăng nhập"}
        </a>
      </nav>
    </header>
  );
}
