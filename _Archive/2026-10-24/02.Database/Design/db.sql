-- =============================================================================
-- DATABASE DESIGN: RENTAL MANAGEMENT SYSTEM (CORE ARCHITECTURE)
-- AUTHOR: GEMINI AI EXPERT
-- TARGET: POSTGRESQL 15+
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. SYSTEM TABLES (sy_)
-- -----------------------------------------------------------------------------

-- Bảng quản lý danh mục chung (Trạng thái, Giới tính, Loại phí...)
CREATE TABLE sy_commons (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    type VARCHAR(50) NOT NULL,          -- VD: 'ROOM_STATUS', 'GENDER', 'PAYMENT_METHOD'
    code VARCHAR(50) NOT NULL,          -- VD: 'AVAILABLE', 'MALE', 'CASH'
    name_vi TEXT NOT NULL,
    name_en TEXT,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    remark TEXT,
    created_by VARCHAR(50),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(50),
    updated_date TIMESTAMP,
    data_row_version INT DEFAULT 1,
    UNIQUE(type, code)
);

-- Bảng quản lý file tập trung
CREATE TABLE sy_file_attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_name VARCHAR(50),             -- Bảng liên kết (VD: ms_rooms)
    ref_id INT,                         -- ID của dòng trong bảng đó
    file_name TEXT NOT NULL,
    file_path TEXT NOT NULL,
    file_type VARCHAR(50),
    file_size BIGINT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE
);

-- Bảng phân quyền (Roles)
CREATE TABLE sy_roles (
    role_code VARCHAR(20) PRIMARY KEY,
    role_name TEXT NOT NULL,
    is_system BOOLEAN DEFAULT FALSE
);

-- Bảng người dùng (Chủ trọ, Nhân viên, Khách thuê)
CREATE TABLE sy_users (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    full_name TEXT NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    role_code VARCHAR(20) REFERENCES sy_roles(role_code),
    avatar_id UUID,
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP,
    created_by VARCHAR(50),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(50),
    updated_date TIMESTAMP,
    data_row_version INT DEFAULT 1
);

-- Bảng cấu hình sinh mã tự động (VD: HD-2024-0001)
CREATE TABLE sy_document_settings (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    transaction_type VARCHAR(50) UNIQUE, -- VD: 'INVOICE', 'CONTRACT'
    prefix VARCHAR(10),
    date_format VARCHAR(10),            -- VD: 'YYYYMM'
    number_digits INT DEFAULT 4,
    current_number INT DEFAULT 0,
    updated_date TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- 2. MASTER DATA TABLES (ms_)
-- -----------------------------------------------------------------------------

-- Quản lý dãy trọ/chi nhánh (Dành cho chủ có nhiều nhà)
CREATE TABLE ms_branches (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    branch_name TEXT NOT NULL,
    address TEXT,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_by VARCHAR(50),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(50),
    updated_date TIMESTAMP
);

-- Quản lý phòng
CREATE TABLE ms_rooms (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    branch_id INT REFERENCES ms_branches(id),
    room_name VARCHAR(50) NOT NULL,
    price NUMERIC(15, 2) DEFAULT 0,
    max_occupants INT DEFAULT 1,
    status_code VARCHAR(50),            -- Liên kết sy_commons (ROOM_STATUS)
    description TEXT,
    created_by VARCHAR(50),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(50),
    updated_date TIMESTAMP,
    data_row_version INT DEFAULT 1
);

-- Quản lý người thuê
CREATE TABLE ms_tenants (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id INT REFERENCES sy_users(id), -- Link nếu cho khách login
    full_name TEXT NOT NULL,
    identity_number VARCHAR(20),        -- CCCD
    phone VARCHAR(20),
    email VARCHAR(100),
    dob DATE,
    gender_code VARCHAR(20),
    hometown TEXT,
    address_temporary TEXT,             -- Địa chỉ thường trú
    is_representative BOOLEAN DEFAULT FALSE, -- Là người đại diện thuê
    status_code VARCHAR(50),            -- ACTIVE, INACTIVE
    created_by VARCHAR(50),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(50),
    updated_date TIMESTAMP
);

-- Danh mục loại phí (Điện, Nước, Wifi, Rác...)
CREATE TABLE ms_fee_types (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    branch_id INT REFERENCES ms_branches(id),
    fee_name TEXT NOT NULL,
    unit_price NUMERIC(15, 2) NOT NULL,
    calc_method VARCHAR(20),            -- FIXED (Cố định), UNIT (Theo số), PERSON (Theo người)
    is_system BOOLEAN DEFAULT FALSE,    -- Loại phí mặc định hệ thống
    is_active BOOLEAN DEFAULT TRUE
);

-- -----------------------------------------------------------------------------
-- 3. TRANSACTION TABLES (tr_)
-- -----------------------------------------------------------------------------

-- Hợp đồng thuê phòng
CREATE TABLE tr_contracts (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    contract_code VARCHAR(50) UNIQUE,
    room_id INT REFERENCES ms_rooms(id),
    start_date DATE NOT NULL,
    end_date DATE,
    deposit_amount NUMERIC(15, 2) DEFAULT 0,
    actual_rent_price NUMERIC(15, 2) NOT NULL, -- Giá thuê thực tế lúc ký
    status_code VARCHAR(20),            -- ACTIVE, EXPIRED, TERMINATED
    remark TEXT,
    created_by VARCHAR(50),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(50),
    updated_date TIMESTAMP
);

-- Chi tiết khách thuê trong hợp đồng (1 phòng nhiều người)
CREATE TABLE tr_contract_details (
    contract_id INT REFERENCES tr_contracts(id),
    tenant_id INT REFERENCES ms_tenants(id),
    is_main BOOLEAN DEFAULT FALSE,      -- Người chịu trách nhiệm chính
    PRIMARY KEY (contract_id, tenant_id)
);

-- Chốt chỉ số điện nước hàng tháng
CREATE TABLE tr_utility_readings (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    room_id INT REFERENCES ms_rooms(id),
    reading_date DATE NOT NULL,
    elec_index_old NUMERIC(10, 2),
    elec_index_new NUMERIC(10, 2),
    water_index_old NUMERIC(10, 2),
    water_index_new NUMERIC(10, 2),
    created_by VARCHAR(50),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Hóa đơn tiền phòng hàng tháng
CREATE TABLE tr_invoices (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    invoice_code VARCHAR(50) UNIQUE,
    contract_id INT REFERENCES tr_contracts(id),
    branch_id INT REFERENCES ms_branches(id),
    billing_month INT NOT NULL,
    billing_year INT NOT NULL,
    total_amount NUMERIC(15, 2) DEFAULT 0,
    paid_amount NUMERIC(15, 2) DEFAULT 0,
    status_code VARCHAR(20),            -- UNPAID, PARTIAL, PAID, CANCELLED
    due_date DATE,
    created_by VARCHAR(50),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(50),
    updated_date TIMESTAMP
);

-- Chi tiết hóa đơn (Tiền phòng, tiền điện, nước, dịch vụ...)
CREATE TABLE tr_invoice_items (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    invoice_id INT REFERENCES tr_invoices(id) ON DELETE CASCADE,
    fee_type_id INT REFERENCES ms_fee_types(id),
    description TEXT,                   -- VD: Tiền điện (100 -> 150 kWh)
    quantity NUMERIC(10, 2) DEFAULT 1,
    unit_price NUMERIC(15, 2) DEFAULT 0,
    amount NUMERIC(15, 2) NOT NULL
);

-- Lịch sử thanh toán
CREATE TABLE tr_payments (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    invoice_id INT REFERENCES tr_invoices(id),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount NUMERIC(15, 2) NOT NULL,
    method_code VARCHAR(20),            -- CASH, BANK_TRANSFER
    evidence_id UUID,                   -- Link tới ảnh bill chuyển khoản trong sy_file_attachments
    remark TEXT,
    created_by VARCHAR(50)
);

-- Quản lý sự cố/Sửa chữa
CREATE TABLE tr_incidents (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    room_id INT REFERENCES ms_rooms(id),
    tenant_id INT REFERENCES ms_tenants(id),
    description TEXT NOT NULL,
    priority_code VARCHAR(20),          -- LOW, MEDIUM, HIGH
    status_code VARCHAR(20),            -- NEW, PROCESSING, FIXED, CANCELLED
    reported_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_date TIMESTAMP,
    repair_cost NUMERIC(15, 2) DEFAULT 0,
    created_by VARCHAR(50)
);

-- -----------------------------------------------------------------------------
-- 4. INDEXES FOR PERFORMANCE
-- -----------------------------------------------------------------------------
CREATE INDEX idx_room_branch ON ms_rooms(branch_id);
CREATE INDEX idx_invoice_contract ON tr_invoices(contract_id);
CREATE INDEX idx_common_type ON sy_commons(type);

-- -----------------------------------------------------------------------------
-- 5. SEED DATA
-- -----------------------------------------------------------------------------

-- 5.1 Cấu hình Common dữ liệu lõi
INSERT INTO sy_commons (type, code, name_vi, name_en, sort_order) VALUES
('ROOM_STATUS', 'EMPTY', 'Trống', 'Empty', 1),
('ROOM_STATUS', 'RENTED', 'Đang thuê', 'Rented', 2),
('ROOM_STATUS', 'REPAIR', 'Đang sửa chữa', 'Maintenance', 3),

('GENDER', 'MALE', 'Nam', 'Male', 1),
('GENDER', 'FEMALE', 'Nữ', 'Female', 2),
('GENDER', 'OTHER', 'Khác', 'Other', 3),

('FEE_CALC', 'FIXED', 'Cố định', 'Fixed', 1),
('FEE_CALC', 'UNIT', 'Theo chỉ số', 'Per Unit', 2),
('FEE_CALC', 'PERSON', 'Theo số người', 'Per Person', 3),

('INV_STATUS', 'UNPAID', 'Chưa thanh toán', 'Unpaid', 1),
('INV_STATUS', 'PAID', 'Đã thanh toán', 'Paid', 2),
('INV_STATUS', 'PARTIAL', 'Thanh toán một phần', 'Partial', 3);

-- 5.2 Tạo vai trò hệ thống
INSERT INTO sy_roles (role_code, role_name, is_system) VALUES
('ADMIN', 'Chủ trọ (Admin)', true),
('MANAGER', 'Quản lý dãy trọ', true),
('TENANT', 'Khách thuê', true);

-- 5.3 Tạo tài khoản mẫu (Password: 123456 - thực tế sẽ dùng hash)
INSERT INTO sy_users (username, password_hash, full_name, role_code) VALUES
('admin', '$2b$12$KIXpZ2m5U9W5.Vl5v3e1Uu8l0aZ8.v0w5U.5V.5V.5V.5V.5V.5V', 'Nguyễn Văn Chủ Trọ', 'ADMIN'),
('khach01', '$2b$12$KIXpZ2m5U9W5.Vl5v3e1Uu8l0aZ8.v0w5U.5V.5V.5V.5V.5V.5V', 'Lê Văn Thuê', 'TENANT');

-- 5.4 Tạo chi nhánh & phòng mẫu
INSERT INTO ms_branches (branch_name, address) VALUES 
('Nhà Trọ Bình Dương', '123 Thủ Dầu Một, Bình Dương');

INSERT INTO ms_rooms (branch_id, room_name, price, max_occupants, status_code) VALUES
(1, 'Phòng 101', 2500000, 2, 'EMPTY'),
(1, 'Phòng 102', 2500000, 2, 'RENTED');

-- 5.5 Tạo phí mẫu
INSERT INTO ms_fee_types (branch_id, fee_name, unit_price, calc_method, is_system) VALUES
(1, 'Tiền phòng', 0, 'FIXED', true),
(1, 'Tiền điện', 3500, 'UNIT', true),
(1, 'Tiền nước', 15000, 'UNIT', true),
(1, 'Rác & Vệ sinh', 50000, 'FIXED', true);

-- 5.6 Tạo người thuê & Hợp đồng mẫu
INSERT INTO ms_tenants (user_id, full_name, identity_number, phone, status_code) VALUES
(2, 'Lê Văn Thuê', '0123456789', '0909123456', 'ACTIVE');

INSERT INTO tr_contracts (contract_code, room_id, start_date, deposit_amount, actual_rent_price, status_code) VALUES
('HD-2024-0001', 2, '2024-01-01', 2500000, 2500000, 'ACTIVE');

INSERT INTO tr_contract_details (contract_id, tenant_id, is_main) VALUES (1, 1, true);
