-- =============================================================================
-- DATABASE REPAIR: ENSURING ALL AUDIT FIELDS EXIST IN ALL TABLES
-- AUTHOR: GEMINI AI EXPERT
-- DESCRIPTION: Khắc phục triệt để lỗi "column s.is_deleted does not exist" 
-- bằng cách thêm đầy đủ các trường audit cho tất cả các bảng.
-- =============================================================================

-- 1. Đảm bảo bảng sy_permissions tồn tại (trước đó bị thiếu trong script Phase 15)
CREATE TABLE IF NOT EXISTS sy_permissions (
    permission_code VARCHAR(50) PRIMARY KEY,
    permission_name TEXT NOT NULL,
    module VARCHAR(50)
);

-- 2. Script thông minh tự động thêm đầy đủ 8 trường Audit cho mọi bảng
DO $$
DECLARE
    t text;
BEGIN
    FOR t IN 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
          AND (table_name LIKE 'sy_%' OR table_name LIKE 'ms_%' OR table_name LIKE 'tr_%')
          AND table_name NOT IN ('sy_role_permissions', 'tr_contract_details') -- Các bảng chỉ có FK thường không cần audit đầy đủ
    LOOP
        -- Thêm is_deleted (Quan trọng nhất cho Global Filter)
        EXECUTE format('ALTER TABLE %I ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT FALSE', t);
        
        -- Thêm các trường audit khác
        EXECUTE format('ALTER TABLE %I ADD COLUMN IF NOT EXISTS created_by VARCHAR(50)', t);
        EXECUTE format('ALTER TABLE %I ADD COLUMN IF NOT EXISTS created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP', t);
        EXECUTE format('ALTER TABLE %I ADD COLUMN IF NOT EXISTS updated_by VARCHAR(50)', t);
        EXECUTE format('ALTER TABLE %I ADD COLUMN IF NOT EXISTS updated_date TIMESTAMP', t);
        EXECUTE format('ALTER TABLE %I ADD COLUMN IF NOT EXISTS deleted_by VARCHAR(50)', t);
        EXECUTE format('ALTER TABLE %I ADD COLUMN IF NOT EXISTS deleted_date TIMESTAMP', t);
        EXECUTE format('ALTER TABLE %I ADD COLUMN IF NOT EXISTS version INT DEFAULT 1', t);
        
        RAISE NOTICE 'Updated table: %', t;
    END LOOP;
END $$;

-- 3. Cập nhật lại dữ liệu mẫu cho sy_users nếu cần (đảm bảo is_deleted = false)
UPDATE sy_users SET is_deleted = false WHERE is_deleted IS NULL;
