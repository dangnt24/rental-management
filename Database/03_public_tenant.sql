-- Cập nhật database hiện có: trang phòng công khai và tài khoản người thuê.
-- Có thể chạy lại; không xóa bảng hay dữ liệu nghiệp vụ.
BEGIN;
ALTER TABLE users ADD COLUMN IF NOT EXISTS "TenantId" integer;
ALTER TABLE incidents ADD COLUMN IF NOT EXISTS "ReportedByTenantId" integer;
ALTER TABLE attachments ADD COLUMN IF NOT EXISTS "IsPublic" boolean NOT NULL DEFAULT false;
ALTER TABLE users DROP CONSTRAINT IF EXISTS ck_user_role;
ALTER TABLE users ADD CONSTRAINT ck_user_role CHECK ("Role" IN ('Owner','Manager','Tenant'));
ALTER TABLE users DROP CONSTRAINT IF EXISTS ck_user_tenant;
ALTER TABLE users ADD CONSTRAINT ck_user_tenant CHECK (("Role" = 'Tenant' AND "TenantId" IS NOT NULL) OR ("Role" <> 'Tenant' AND "TenantId" IS NULL));
CREATE UNIQUE INDEX IF NOT EXISTS "IX_users_TenantId" ON users ("TenantId");
CREATE INDEX IF NOT EXISTS "IX_incidents_ReportedByTenantId" ON incidents ("ReportedByTenantId");
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'FK_users_tenants_TenantId' AND conrelid = 'users'::regclass) THEN
        ALTER TABLE users ADD CONSTRAINT "FK_users_tenants_TenantId" FOREIGN KEY ("TenantId") REFERENCES tenants ("Id") ON DELETE RESTRICT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'FK_incidents_tenants_ReportedByTenantId' AND conrelid = 'incidents'::regclass) THEN
        ALTER TABLE incidents ADD CONSTRAINT "FK_incidents_tenants_ReportedByTenantId" FOREIGN KEY ("ReportedByTenantId") REFERENCES tenants ("Id") ON DELETE RESTRICT;
    END IF;
END $$;
COMMIT;
