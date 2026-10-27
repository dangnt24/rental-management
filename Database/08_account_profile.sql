-- Hồ sơ tài khoản: chỉ chủ trọ sửa Email/Phone. Người dùng tự sửa tên/ảnh đại diện.
-- Lần đầu sao chép điện thoại người thuê đã liên kết; không sửa hồ sơ thuê hay mật khẩu.
BEGIN;
ALTER TABLE users ADD COLUMN IF NOT EXISTS "Email" varchar(254) NOT NULL DEFAULT '';
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='users' AND column_name='Phone') THEN
        ALTER TABLE users ADD COLUMN "Phone" varchar(20) NOT NULL DEFAULT '';
        UPDATE users u SET "Phone"=t."Phone" FROM tenants t WHERE u."TenantId"=t."Id";
    END IF;
END $$;
ALTER TABLE users ADD COLUMN IF NOT EXISTS "AvatarStoredName" varchar(128) NOT NULL DEFAULT '';
ALTER TABLE users ADD COLUMN IF NOT EXISTS "AvatarVersion" integer NOT NULL DEFAULT 0;
COMMIT;
