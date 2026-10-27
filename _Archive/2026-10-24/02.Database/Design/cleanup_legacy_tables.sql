-- =============================================================================
-- DATABASE CLEANUP: REMOVING LEGACY TABLES (STANDARDIZATION)
-- AUTHOR: GEMINI AI EXPERT
-- DESCRIPTION: Xóa các bảng cũ (không có tiền tố) để sử dụng duy nhất bộ khung Enterprise (sy_, ms_, tr_).
-- =============================================================================

-- 1. Xóa các bảng liên quan đến Auth/System cũ
DROP TABLE IF EXISTS public.userroles CASCADE;
DROP TABLE IF EXISTS public.rolepermissions CASCADE;
DROP TABLE IF EXISTS public.menupermissions CASCADE;
DROP TABLE IF EXISTS public.menus CASCADE;
DROP TABLE IF EXISTS public.permissions CASCADE;
DROP TABLE IF EXISTS public.roles CASCADE;
DROP TABLE IF EXISTS public.users CASCADE;

-- 2. Xóa các bảng Common/Translation cũ
DROP TABLE IF EXISTS public.commontranslations CASCADE;
DROP TABLE IF EXISTS public.commonvalues CASCADE;
DROP TABLE IF EXISTS public.commoncategories CASCADE;
DROP TABLE IF EXISTS public.translations CASCADE;
DROP TABLE IF EXISTS public.languages CASCADE;

-- 3. Xóa các bảng Master Data cũ
DROP TABLE IF EXISTS public.roomimages CASCADE;
DROP TABLE IF EXISTS public.rooms CASCADE;
DROP TABLE IF EXISTS public.tenants CASCADE;
DROP TABLE IF EXISTS public.feetypes CASCADE;

-- 4. Xóa các bảng Transaction cũ
DROP TABLE IF EXISTS public.utilityrecords CASCADE;
DROP TABLE IF EXISTS public.invoicedetails CASCADE;
DROP TABLE IF EXISTS public.invoices CASCADE;
DROP TABLE IF EXISTS public.payments CASCADE;
DROP TABLE IF EXISTS public.maintenances CASCADE;
DROP TABLE IF EXISTS public.contracts CASCADE;
DROP TABLE IF EXISTS public.notifications CASCADE;

-- =============================================================================
-- BÂY GIỜ DATABASE CỦA BẠN CHỈ CÒN LẠI CÁC BẢNG CHUẨN CORE:
-- sy_users, sy_roles, sy_commons, sy_file_attachments, sy_document_settings
-- ms_branches, ms_rooms, ms_tenants, ms_fee_types
-- tr_contracts, tr_contract_details, tr_utility_readings, tr_invoices, tr_invoice_items, tr_payments, tr_incidents
-- =============================================================================
