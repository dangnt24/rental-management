import { BrandLogo } from "../shared/components/BrandLogo";
import { Login } from "../features/auth/LoginPage";
import { useSession } from "../features/auth/useSession";
import { WorkspaceProvider } from "./WorkspaceContext";
import { AppLayout } from "./AppLayout";
import { WorkspacePages } from "./WorkspacePages";
import { useEffect, useState } from "react";
import { CatalogPage } from "../features/catalog/CatalogPage";
import { TenantPortal } from "../features/tenantPortal/TenantPortal";

export function App() {
  const { user, setUser, loading } = useSession();
  const [route, setRoute] = useState(location.hash.slice(1) || "browse");
  useEffect(() => {
    const changed = () => setRoute(location.hash.slice(1) || "browse");
    window.addEventListener("hashchange", changed);
    return () => window.removeEventListener("hashchange", changed);
  }, []);
  if (loading)
    return (
      <div className="full-loading">
        <BrandLogo />
        <p>Đang mở không gian quản lý…</p>
      </div>
    );
  if (
    route === "browse" ||
    route === "browse/rooms" ||
    (!user && route !== "login")
  )
    return <CatalogPage user={user} focusSearch={route === "browse/rooms"} />;
  if (!user)
    return (
      <Login
        loggedIn={(next) => {
          setUser(next);
          location.hash = next.role === "Tenant" ? "tenant" : "overview";
        }}
      />
    );
  if (user.role === "Tenant")
    return (
      <TenantPortal
        user={user}
        signedOut={() => {
          setUser(null);
          location.hash = "browse";
        }}
      />
    );
  return (
    <WorkspaceProvider user={user} setUser={setUser}>
      <AppLayout>
        <WorkspacePages />
      </AppLayout>
    </WorkspaceProvider>
  );
}
