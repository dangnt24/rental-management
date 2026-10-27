-- Thứ tự ảnh/file. Chạy sau schema Source; không xóa file, không đổi quyền công khai.
-- Lần đầu giữ thứ tự cũ theo ID. Chạy lại không đặt lại thứ tự đã chỉnh.
BEGIN;
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='attachments' AND column_name='SortOrder') THEN
        ALTER TABLE attachments ADD COLUMN "SortOrder" integer NOT NULL DEFAULT 0;
        WITH ranked AS (
            SELECT "Id", (row_number() OVER (PARTITION BY "EntityType", "EntityId" ORDER BY "Id") - 1)::integer AS position
            FROM attachments WHERE NOT "IsArchived"
        ) UPDATE attachments a SET "SortOrder"=ranked.position FROM ranked WHERE ranked."Id"=a."Id";
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='ck_attachment_order' AND conrelid='attachments'::regclass) THEN
        ALTER TABLE attachments ADD CONSTRAINT ck_attachment_order CHECK ("SortOrder" >= 0);
    END IF;
END $$;
COMMIT;
