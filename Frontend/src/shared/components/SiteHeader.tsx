import type { User } from "../types";
import { BrandLogo } from "./BrandLogo";
import { Search, LogIn, LayoutDashboard } from "lucide-react";
import { AccountMenu } from "../../features/accounts/AccountMenu";

export function SiteHeader({
  user,
  roomListing = false,
}: {
  user: User | null;
  roomListing?: boolean;
}) {
  return (
    <header className="site-header">
      <a className="brand" href="#browse">
        <BrandLogo />
      </a>
      <nav aria-label="Điều hướng chính">
        {roomListing ? (
          user && (
            <a href={user.role === "Tenant" ? "#tenant" : "#overview"}>
              <LayoutDashboard size={16} />
              {user.role === "Tenant" ? "Trang người thuê" : "Trang quản trị"}
            </a>
          )
        ) : (
          <a href="#browse/rooms">
            <Search size={16} />
            Tìm phòng
          </a>
        )}
        {user ? (
          <AccountMenu />
        ) : (
          <a className="button" href="#login">
            <LogIn size={16} />
            Đăng nhập
          </a>
        )}
      </nav>
    </header>
  );
}
