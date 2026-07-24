-- ============================================================
-- Database Update V3 - NhaTro Rental Management
-- Date: 2026-07-24
-- Changes:
--   1. ALTER ms_rooms add images column (JSON array of file UUIDs)
--   2. ALTER ms_tenants add avatar and id_card_image columns (UUID FK)
--   3. ALTER sy_file_attachments add category column
--   4. ALTER tr_contracts add file_id column (UUID FK)
--   5. Seed data: add FILE_CATEGORY commons
--   6. Add missing indexes
-- ============================================================

BEGIN;

-- ============================================================
-- 1. ms_rooms - Add images column (JSON array)
-- ============================================================
ALTER TABLE public.ms_rooms
    ADD COLUMN IF NOT EXISTS images jsonb DEFAULT '[]'::jsonb;

-- ============================================================
-- 2. ms_tenants - Add avatar and id_card_image columns
-- ============================================================
ALTER TABLE public.ms_tenants
    ADD COLUMN IF NOT EXISTS avatar_id uuid,
    ADD COLUMN IF NOT EXISTS id_card_image_id uuid;

-- ============================================================
-- 3. sy_file_attachments - Add category column
-- ============================================================
ALTER TABLE public.sy_file_attachments
    ADD COLUMN IF NOT EXISTS category character varying(50);

-- ============================================================
-- 4. tr_contracts - Add file_id column for contract document
-- ============================================================
ALTER TABLE public.tr_contracts
    ADD COLUMN IF NOT EXISTS contract_file_id uuid;

-- ============================================================
-- 5. Seed data: File category common types
-- ============================================================
INSERT INTO public.sy_commons (type, code, name_vi, name_en, sort_order, is_active, remark)
VALUES
    ('FILE_CATEGORY', 'CONTRACT', 'Hợp đồng', 'Contract', 1, true, null),
    ('FILE_CATEGORY', 'INVOICE', 'Hóa đơn', 'Invoice', 2, true, null),
    ('FILE_CATEGORY', 'PAYMENT_EVIDENCE', 'Chứng từ thanh toán', 'Payment Evidence', 3, true, null),
    ('FILE_CATEGORY', 'ROOM_IMAGE', 'Hình ảnh phòng', 'Room Image', 4, true, null),
    ('FILE_CATEGORY', 'TENANT_ID_CARD', 'CMND/CCCD người thuê', 'Tenant ID Card', 5, true, null),
    ('FILE_CATEGORY', 'TENANT_AVATAR', 'Ảnh đại diện người thuê', 'Tenant Avatar', 6, true, null),
    ('FILE_CATEGORY', 'INCIDENT_IMAGE', 'Hình ảnh sự cố', 'Incident Image', 7, true, null)
ON CONFLICT (type, code) DO NOTHING;

-- ============================================================
-- 6. Missing indexes for performance
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_file_attachments_ref
    ON public.sy_file_attachments (table_name, ref_id);

CREATE INDEX IF NOT EXISTS idx_tenants_status
    ON public.ms_tenants (status_code);

CREATE INDEX IF NOT EXISTS idx_contracts_status
    ON public.tr_contracts (status_code);

CREATE INDEX IF NOT EXISTS idx_invoices_status
    ON public.tr_invoices (status_code);

CREATE INDEX IF NOT EXISTS idx_incidents_status
    ON public.tr_incidents (status_code);

COMMIT;