--
-- Seed Data cho Hệ thống Quản lý Nhà trọ
-- Database: rental_db
-- Generated: 2026-07-23
--

-- ============================================================
-- 1. DANH MỤC CHUNG (sy_commons) - Dùng cho toàn bộ status codes
-- ============================================================
INSERT INTO public.sy_commons (type, code, name_vi, name_en, sort_order, is_active, remark) VALUES
-- Trạng thái phòng
('ROOM_STATUS', 'EMPTY', 'Phòng trống', 'Empty', 1, true, 'Phòng đang trống, sẵn sàng cho thuê'),
('ROOM_STATUS', 'RENTED', 'Đang cho thuê', 'Rented', 2, true, 'Phòng đang có khách thuê'),
('ROOM_STATUS', 'MAINTENANCE', 'Đang bảo trì', 'Maintenance', 3, true, 'Phòng đang sửa chữa/bảo trì'),

-- Trạng thái hợp đồng
('CONTRACT_STATUS', 'ACTIVE', 'Đang hiệu lực', 'Active', 1, true, 'Hợp đồng đang có hiệu lực'),
('CONTRACT_STATUS', 'TERMINATED', 'Đã chấm dứt', 'Terminated', 2, true, 'Hợp đồng đã kết thúc'),
('CONTRACT_STATUS', 'EXPIRED', 'Đã hết hạn', 'Expired', 3, true, 'Hợp đồng đã hết thời hạn'),

-- Trạng thái hóa đơn
('INVOICE_STATUS', 'UNPAID', 'Chưa thanh toán', 'Unpaid', 1, true, 'Hóa đơn chưa được thanh toán'),
('INVOICE_STATUS', 'PARTIAL', 'Thanh toán một phần', 'Partial', 2, true, 'Hóa đơn đã thanh toán một phần'),
('INVOICE_STATUS', 'PAID', 'Đã thanh toán', 'Paid', 3, true, 'Hóa đơn đã thanh toán đầy đủ'),
('INVOICE_STATUS', 'OVERDUE', 'Quá hạn', 'Overdue', 4, true, 'Hóa đơn đã quá hạn thanh toán'),
('INVOICE_STATUS', 'CANCELLED', 'Đã hủy', 'Cancelled', 5, true, 'Hóa đơn đã bị hủy'),

-- Trạng thái sự cố
('INCIDENT_STATUS', 'PENDING', 'Chờ xử lý', 'Pending', 1, true, 'Sự cố chờ được xử lý'),
('INCIDENT_STATUS', 'IN_PROGRESS', 'Đang xử lý', 'In Progress', 2, true, 'Sự cố đang được xử lý'),
('INCIDENT_STATUS', 'RESOLVED', 'Đã giải quyết', 'Resolved', 3, true, 'Sự cố đã được giải quyết'),

-- Mức độ ưu tiên sự cố
('INCIDENT_PRIORITY', 'LOW', 'Thấp', 'Low', 1, true, 'Mức độ ưu tiên thấp'),
('INCIDENT_PRIORITY', 'MEDIUM', 'Trung bình', 'Medium', 2, true, 'Mức độ ưu tiên trung bình'),
('INCIDENT_PRIORITY', 'HIGH', 'Cao', 'High', 3, true, 'Mức độ ưu tiên cao'),
('INCIDENT_PRIORITY', 'CRITICAL', 'Khẩn cấp', 'Critical', 4, true, 'Mức độ ưu tiên khẩn cấp'),

-- Giới tính
('GENDER', 'MALE', 'Nam', 'Male', 1, true, NULL),
('GENDER', 'FEMALE', 'Nữ', 'Female', 2, true, NULL),
('GENDER', 'OTHER', 'Khác', 'Other', 3, true, NULL),

-- Trạng thái người thuê
('TENANT_STATUS', 'ACTIVE', 'Đang thuê', 'Active', 1, true, 'Người thuê đang ở'),
('TENANT_STATUS', 'INACTIVE', 'Tạm ngưng', 'Inactive', 2, true, 'Người thuê tạm ngưng'),
('TENANT_STATUS', 'LEFT', 'Đã rời đi', 'Left', 3, true, 'Người thuê đã chuyển đi'),

-- Phương thức thanh toán
('PAYMENT_METHOD', 'CASH', 'Tiền mặt', 'Cash', 1, true, 'Thanh toán bằng tiền mặt'),
('PAYMENT_METHOD', 'BANK_TRANSFER', 'Chuyển khoản', 'Bank Transfer', 2, true, 'Thanh toán qua chuyển khoản ngân hàng'),
('PAYMENT_METHOD', 'MOMO', 'Ví MoMo', 'Momo', 3, true, 'Thanh toán qua ví MoMo'),
('PAYMENT_METHOD', 'VNPAY', 'VNPay', 'VNPay', 4, true, 'Thanh toán qua VNPay'),

-- Loại giao dịch cho Document Settings
('TRANSACTION_TYPE', 'CONTRACT', 'Hợp đồng', 'Contract', 1, true, 'Số hợp đồng'),
('TRANSACTION_TYPE', 'INVOICE', 'Hóa đơn', 'Invoice', 2, true, 'Số hóa đơn'),
('TRANSACTION_TYPE', 'INCIDENT', 'Sự cố', 'Incident', 3, true, 'Mã sự cố'),

-- ============================================================
-- MENU ITEMS (lấy động từ database)
-- ============================================================
('MENU_ITEM', 'dashboard', 'Tổng quan', 'Dashboard', 1, true, 'chart-pie'),
('MENU_ITEM', 'rooms', 'Quản lý phòng', 'Rooms', 2, true, 'door-open'),
('MENU_ITEM', 'tenants', 'Người thuê', 'Tenants', 3, true, 'users'),
('MENU_ITEM', 'contracts', 'Hợp đồng', 'Contracts', 4, true, 'file-contract'),
('MENU_ITEM', 'billing', 'Hóa đơn & Tiền phòng', 'Billing', 5, true, 'receipt'),
('MENU_ITEM', 'payments', 'Thanh toán', 'Payments', 6, true, 'credit-card'),
('MENU_ITEM', 'incidents', 'Sự cố / Bảo trì', 'Incidents', 7, true, 'exclamation-triangle'),
('MENU_ITEM', 'users', 'Người dùng', 'Users', 8, false, 'user-cog'),
('MENU_ITEM', 'branches', 'Chi nhánh', 'Branches', 9, false, 'building'),
('MENU_ITEM', 'fee-types', 'Loại phí', 'Fee Types', 10, false, 'tags')
ON CONFLICT (type, code) DO NOTHING;

-- ============================================================
-- 2. VAI TRÒ (sy_roles)
-- ============================================================
INSERT INTO public.sy_roles (role_code, role_name, is_system, created_by) VALUES
('SYSADMIN', 'Quản trị hệ thống', true, 'system'),
('MANAGER', 'Quản lý', true, 'system'),
('STAFF', 'Nhân viên', true, 'system')
ON CONFLICT (role_code) DO NOTHING;

-- ============================================================
-- 3. QUYỀN HẠN (sy_permissions)
-- ============================================================
INSERT INTO public.sy_permissions (permission_code, permission_name, module, created_by) VALUES
('ROOM_VIEW', 'Xem danh sách phòng', 'ROOM', 'system'),
('ROOM_CREATE', 'Thêm phòng mới', 'ROOM', 'system'),
('ROOM_EDIT', 'Sửa thông tin phòng', 'ROOM', 'system'),
('ROOM_DELETE', 'Xóa phòng', 'ROOM', 'system'),
('TENANT_VIEW', 'Xem người thuê', 'TENANT', 'system'),
('TENANT_CREATE', 'Thêm người thuê', 'TENANT', 'system'),
('TENANT_EDIT', 'Sửa người thuê', 'TENANT', 'system'),
('TENANT_DELETE', 'Xóa người thuê', 'TENANT', 'system'),
('CONTRACT_VIEW', 'Xem hợp đồng', 'CONTRACT', 'system'),
('CONTRACT_CREATE', 'Tạo hợp đồng', 'CONTRACT', 'system'),
('CONTRACT_TERMINATE', 'Chấm dứt hợp đồng', 'CONTRACT', 'system'),
('INVOICE_VIEW', 'Xem hóa đơn', 'INVOICE', 'system'),
('INVOICE_CREATE', 'Tạo hóa đơn', 'INVOICE', 'system'),
('PAYMENT_VIEW', 'Xem thanh toán', 'PAYMENT', 'system'),
('PAYMENT_CREATE', 'Ghi nhận thanh toán', 'PAYMENT', 'system'),
('INCIDENT_VIEW', 'Xem sự cố', 'INCIDENT', 'system'),
('INCIDENT_CREATE', 'Báo sự cố', 'INCIDENT', 'system'),
('INCIDENT_RESOLVE', 'Xử lý sự cố', 'INCIDENT', 'system'),
('USER_VIEW', 'Xem người dùng', 'USER', 'system'),
('USER_CREATE', 'Thêm người dùng', 'USER', 'system'),
('USER_EDIT', 'Sửa người dùng', 'USER', 'system'),
('USER_DELETE', 'Xóa người dùng', 'USER', 'system'),
('REPORT_VIEW', 'Xem báo cáo', 'REPORT', 'system'),
('CONFIG_EDIT', 'Cấu hình hệ thống', 'CONFIG', 'system')
ON CONFLICT (permission_code) DO NOTHING;

-- ============================================================
-- 4. NGƯỜI DÙNG (sy_users) - Password mặc định: admin123
-- ============================================================
INSERT INTO public.sy_users (username, password_hash, full_name, email, phone, role_code, is_active, created_by) VALUES
('admin', '$2a$11$9LWeFQBtqOJEb23u32D41uoExmIH1IhbeU3lYK5Y/vemDzfZKTMFC', 'Quản trị viên', 'admin@rental.local', '0900000001', 'SYSADMIN', true, 'system'),
('manager', '$2a$11$9LWeFQBtqOJEb23u32D41uoExmIH1IhbeU3lYK5Y/vemDzfZKTMFC', 'Nguyễn Văn A', 'manager@rental.local', '0900000002', 'MANAGER', true, 'system'),
('staff', '$2a$11$9LWeFQBtqOJEb23u32D41uoExmIH1IhbeU3lYK5Y/vemDzfZKTMFC', 'Trần Thị B', 'staff@rental.local', '0900000003', 'STAFF', true, 'system')
ON CONFLICT (username) DO NOTHING;

-- ============================================================
-- 5. CẤU HÌNH SINH MÃ TỰ ĐỘNG (sy_document_settings)
-- ============================================================
INSERT INTO public.sy_document_settings (transaction_type, prefix, date_format, number_digits, current_number, created_by) VALUES
('CONTRACT', 'HD', 'yyyyMM', 4, 0, 'system'),
('INVOICE', 'INV', 'yyyyMM', 4, 0, 'system'),
('INCIDENT', 'SC', 'yyyyMMdd', 3, 0, 'system')
ON CONFLICT (transaction_type) DO NOTHING;

-- ============================================================
-- 6. CHI NHÁNH / DÃY TRỌ MẪU (ms_branches)
-- ============================================================
INSERT INTO public.ms_branches (branch_name, address, description, is_active, created_by) VALUES
('Cơ sở 1 - Nguyễn Huệ', '123 Nguyễn Huệ, Quận 1, TP.HCM', 'Dãy trọ trung tâm Quận 1', true, 'system'),
('Cơ sở 2 - Lê Lợi', '456 Lê Lợi, Quận Bình Thạnh, TP.HCM', 'Dãy trọ gần trường ĐH', true, 'system'),
('Cơ sở 3 - CMT8', '789 CMT8, Quận Tân Bình, TP.HCM', 'Dãy trọ khu vực sân bay', true, 'system');

-- ============================================================
-- 7. PHÒNG MẪU (ms_rooms)
-- ============================================================
INSERT INTO public.ms_rooms (branch_id, room_name, price, max_occupants, status_code, description, created_by)
SELECT b.id, x.room_name, x.price, x.max_occupants, x.status_code, x.description, 'system'
FROM (VALUES
    -- Cơ sở 1
    ('Cơ sở 1 - Nguyễn Huệ', 'P101', 3000000, 2, 'EMPTY', 'Phòng tầng 1, diện tích 25m2, có cửa sổ'),
    ('Cơ sở 1 - Nguyễn Huệ', 'P102', 3200000, 2, 'EMPTY', 'Phòng tầng 1, diện tích 28m2, có ban công'),
    ('Cơ sở 1 - Nguyễn Huệ', 'P201', 3500000, 3, 'EMPTY', 'Phòng tầng 2, diện tích 30m2, thoáng mát'),
    ('Cơ sở 1 - Nguyễn Huệ', 'P202', 2800000, 2, 'EMPTY', 'Phòng tầng 2, diện tích 22m2'),
    ('Cơ sở 1 - Nguyễn Huệ', 'P301', 4000000, 4, 'EMPTY', 'Phòng tầng 3, diện tích 35m2, phòng gia đình'),
    -- Cơ sở 2
    ('Cơ sở 2 - Lê Lợi', 'P101', 2500000, 2, 'EMPTY', 'Phòng đơn giản, diện tích 20m2'),
    ('Cơ sở 2 - Lê Lợi', 'P102', 2700000, 2, 'EMPTY', 'Phòng có gác lửng, diện tích 25m2'),
    ('Cơ sở 2 - Lê Lợi', 'P103', 3000000, 3, 'EMPTY', 'Phòng rộng, diện tích 30m2'),
    ('Cơ sở 2 - Lê Lợi', 'P201', 3500000, 4, 'EMPTY', 'Phòng gia đình, diện tích 40m2'),
    -- Cơ sở 3
    ('Cơ sở 3 - CMT8', 'P101', 2200000, 2, 'EMPTY', 'Phòng cơ bản, diện tích 18m2'),
    ('Cơ sở 3 - CMT8', 'P102', 2500000, 2, 'EMPTY', 'Phòng tiện nghi, diện tích 22m2'),
    ('Cơ sở 3 - CMT8', 'P201', 3000000, 3, 'EMPTY', 'Phòng rộng, diện tích 28m2, có máy lạnh')
) AS x(branch_name, room_name, price, max_occupants, status_code, description)
JOIN public.ms_branches b ON b.branch_name = x.branch_name;

-- ============================================================
-- 8. LOẠI PHÍ MẪU (ms_fee_types)
-- ============================================================
INSERT INTO public.ms_fee_types (branch_id, fee_name, unit_price, calc_method, is_system, is_active, created_by)
SELECT b.id, x.fee_name, x.unit_price, x.calc_method, x.is_system, x.is_active, 'system'
FROM (VALUES
    -- Cơ sở 1
    ('Cơ sở 1 - Nguyễn Huệ', 'TIEN_PHONG', 0, 'FIXED', true, true),
    ('Cơ sở 1 - Nguyễn Huệ', 'TIEN_DIEN', 4000, 'PER_UNIT', true, true),
    ('Cơ sở 1 - Nguyễn Huệ', 'TIEN_NUOC', 25000, 'PER_UNIT', true, true),
    ('Cơ sở 1 - Nguyễn Huệ', 'PHI_RAC', 50000, 'FIXED', true, true),
    ('Cơ sở 1 - Nguyễn Huệ', 'PHI_WIFI', 100000, 'FIXED', true, true),
    ('Cơ sở 1 - Nguyễn Huệ', 'PHI_XE', 150000, 'FIXED', true, true),
    -- Cơ sở 2
    ('Cơ sở 2 - Lê Lợi', 'TIEN_PHONG', 0, 'FIXED', true, true),
    ('Cơ sở 2 - Lê Lợi', 'TIEN_DIEN', 3500, 'PER_UNIT', true, true),
    ('Cơ sở 2 - Lê Lợi', 'TIEN_NUOC', 20000, 'PER_UNIT', true, true),
    ('Cơ sở 2 - Lê Lợi', 'PHI_RAC', 40000, 'FIXED', true, true),
    ('Cơ sở 2 - Lê Lợi', 'PHI_WIFI', 80000, 'FIXED', true, true),
    ('Cơ sở 2 - Lê Lợi', 'PHI_XE', 120000, 'FIXED', true, true),
    -- Cơ sở 3
    ('Cơ sở 3 - CMT8', 'TIEN_PHONG', 0, 'FIXED', true, true),
    ('Cơ sở 3 - CMT8', 'TIEN_DIEN', 3800, 'PER_UNIT', true, true),
    ('Cơ sở 3 - CMT8', 'TIEN_NUOC', 22000, 'PER_UNIT', true, true),
    ('Cơ sở 3 - CMT8', 'PHI_RAC', 45000, 'FIXED', true, true),
    ('Cơ sở 3 - CMT8', 'PHI_WIFI', 90000, 'FIXED', true, true)
) AS x(branch_name, fee_name, unit_price, calc_method, is_system, is_active)
JOIN public.ms_branches b ON b.branch_name = x.branch_name;
