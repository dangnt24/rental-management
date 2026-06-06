-- =============================================================================
-- DATABASE DESIGN: ENTERPRISE RENTAL MANAGEMENT SYSTEM (CORE ARCHITECTURE)
-- AUTHOR: GEMINI AI EXPERT (SENIOR SOLUTION ARCHITECT)
-- TARGET: POSTGRESQL 15+
-- FEATURES: AUDIT FIELDS, SOFT DELETE, VERSIONING, INDEXING, CONSTRAINTS
-- =============================================================================

-- Extension for UUID generation
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- -----------------------------------------------------------------------------
-- 1. SYSTEM TABLES (sy_)
-- -----------------------------------------------------------------------------

-- Bảng quản lý danh mục chung (Trạng thái, Giới tính, Loại phí...)
CREATE TABLE sy_commons (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    type VARCHAR(50) NOT NULL,
    code VARCHAR(50) NOT NULL,
    name_vi TEXT NOT NULL,
    name_en TEXT,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    remark TEXT,
    
    -- Audit Fields
    created_by VARCHAR(50),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(50),
    updated_date TIMESTAMP,
    deleted_by VARCHAR(50),
    deleted_date TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    version INT DEFAULT 1,
    
    UNIQUE(type, code)
);

-- Bảng quản lý file tập trung
CREATE TABLE sy_file_attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_name VARCHAR(50),
    ref_id INT,
    file_name TEXT NOT NULL,
    file_path TEXT NOT NULL,
    file_type VARCHAR(50),
    file_size BIGINT,
    
    -- Audit Fields
    created_by VARCHAR(50),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(50),
    updated_date TIMESTAMP,
    deleted_by VARCHAR(50),
    deleted_date TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    version INT DEFAULT 1
);

-- Bảng phân quyền (Roles)
CREATE TABLE sy_roles (
    role_code VARCHAR(20) PRIMARY KEY,
    role_name TEXT NOT NULL,
    is_system BOOLEAN DEFAULT FALSE,
    
    -- Audit Fields
    created_by VARCHAR(50),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(50),
    updated_date TIMESTAMP,
    deleted_by VARCHAR(50),
    deleted_date TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    version INT DEFAULT 1
);

-- Bảng quyền hạn chi tiết (Permissions)
CREATE TABLE sy_permissions (
    permission_code VARCHAR(50) PRIMARY KEY,
    permission_name TEXT NOT NULL,
    module VARCHAR(50),
    
    -- Audit Fields
    created_by VARCHAR(50),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(50),
    updated_date TIMESTAMP,
    deleted_by VARCHAR(50),
    deleted_date TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    version INT DEFAULT 1
);

-- Bảng liên kết Role - Permission
CREATE TABLE sy_role_permissions (
    role_code VARCHAR(20) REFERENCES sy_roles(role_code),
    permission_code VARCHAR(50) REFERENCES sy_permissions(permission_code),
    PRIMARY KEY (role_code, permission_code)
);

-- Bảng người dùng
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
    refresh_token TEXT,
    refresh_token_expiry TIMESTAMP,
    
    -- Audit Fields
    created_by VARCHAR(50),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(50),
    updated_date TIMESTAMP,
    deleted_by VARCHAR(50),
    deleted_date TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    version INT DEFAULT 1
);

-- Bảng cấu hình sinh mã tự động
CREATE TABLE sy_document_settings (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    transaction_type VARCHAR(50) UNIQUE,
    prefix VARCHAR(10),
    date_format VARCHAR(10),
    number_digits INT DEFAULT 4,
    current_number INT DEFAULT 0,
    
    -- Audit Fields
    updated_date TIMESTAMP,
    version INT DEFAULT 1
);

-- -----------------------------------------------------------------------------
-- 2. MASTER DATA TABLES (ms_)
-- -----------------------------------------------------------------------------

-- Quản lý dãy trọ/chi nhánh
CREATE TABLE ms_branches (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    branch_name TEXT NOT NULL,
    address TEXT,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Audit Fields
    created_by VARCHAR(50),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(50),
    updated_date TIMESTAMP,
    deleted_by VARCHAR(50),
    deleted_date TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    version INT DEFAULT 1
);

-- Quản lý phòng
CREATE TABLE ms_rooms (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    branch_id INT REFERENCES ms_branches(id),
    room_name VARCHAR(50) NOT NULL,
    price NUMERIC(15, 2) DEFAULT 0,
    max_occupants INT DEFAULT 1,
    status_code VARCHAR(50),
    description TEXT,
    
    -- Audit Fields
    created_by VARCHAR(50),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(50),
    updated_date TIMESTAMP,
    deleted_by VARCHAR(50),
    deleted_date TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    version INT DEFAULT 1
);

-- Quản lý người thuê
CREATE TABLE ms_tenants (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id INT REFERENCES sy_users(id),
    full_name TEXT NOT NULL,
    identity_number VARCHAR(20),
    phone VARCHAR(20),
    email VARCHAR(100),
    dob DATE,
    gender_code VARCHAR(20),
    hometown TEXT,
    address_temporary TEXT,
    is_representative BOOLEAN DEFAULT FALSE,
    status_code VARCHAR(50),
    
    -- Audit Fields
    created_by VARCHAR(50),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(50),
    updated_date TIMESTAMP,
    deleted_by VARCHAR(50),
    deleted_date TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    version INT DEFAULT 1
);

-- Danh mục loại phí
CREATE TABLE ms_fee_types (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    branch_id INT REFERENCES ms_branches(id),
    fee_name TEXT NOT NULL,
    unit_price NUMERIC(15, 2) NOT NULL,
    calc_method VARCHAR(20),
    is_system BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Audit Fields
    created_by VARCHAR(50),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(50),
    updated_date TIMESTAMP,
    deleted_by VARCHAR(50),
    deleted_date TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    version INT DEFAULT 1
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
    actual_rent_price NUMERIC(15, 2) NOT NULL,
    status_code VARCHAR(20),
    remark TEXT,
    
    -- Audit Fields
    created_by VARCHAR(50),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(50),
    updated_date TIMESTAMP,
    deleted_by VARCHAR(50),
    deleted_date TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    version INT DEFAULT 1
);

-- Chi tiết khách thuê trong hợp đồng
CREATE TABLE tr_contract_details (
    contract_id INT REFERENCES tr_contracts(id),
    tenant_id INT REFERENCES ms_tenants(id),
    is_main BOOLEAN DEFAULT FALSE,
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
    
    -- Audit Fields
    created_by VARCHAR(50),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(50),
    updated_date TIMESTAMP,
    deleted_by VARCHAR(50),
    deleted_date TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    version INT DEFAULT 1
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
    status_code VARCHAR(20),
    due_date DATE,
    
    -- Audit Fields
    created_by VARCHAR(50),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(50),
    updated_date TIMESTAMP,
    deleted_by VARCHAR(50),
    deleted_date TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    version INT DEFAULT 1
);

-- Chi tiết hóa đơn
CREATE TABLE tr_invoice_items (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    invoice_id INT REFERENCES tr_invoices(id) ON DELETE CASCADE,
    fee_type_id INT REFERENCES ms_fee_types(id),
    description TEXT,
    quantity NUMERIC(10, 2) DEFAULT 1,
    unit_price NUMERIC(15, 2) DEFAULT 0,
    amount NUMERIC(15, 2) NOT NULL,
    
    -- Audit Fields
    created_by VARCHAR(50),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    version INT DEFAULT 1
);

-- Lịch sử thanh toán
CREATE TABLE tr_payments (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    invoice_id INT REFERENCES tr_invoices(id),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount NUMERIC(15, 2) NOT NULL,
    method_code VARCHAR(20),
    evidence_id UUID,
    remark TEXT,
    
    -- Audit Fields
    created_by VARCHAR(50),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(50),
    updated_date TIMESTAMP,
    deleted_by VARCHAR(50),
    deleted_date TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    version INT DEFAULT 1
);

-- -----------------------------------------------------------------------------
-- 4. PERFORMANCE & INTEGRITY
-- -----------------------------------------------------------------------------

-- Indexes
CREATE INDEX idx_sy_users_username ON sy_users(username);
CREATE INDEX idx_ms_rooms_branch_status ON ms_rooms(branch_id, status_code);
CREATE INDEX idx_tr_contracts_room_status ON tr_contracts(room_id, status_code);
CREATE INDEX idx_tr_invoices_month_year ON tr_invoices(billing_month, billing_year);
CREATE INDEX idx_tr_invoices_status ON tr_invoices(status_code);

-- -----------------------------------------------------------------------------
-- 5. INITIAL SEED DATA (ENTERPRISE)
-- -----------------------------------------------------------------------------

INSERT INTO sy_roles (role_code, role_name, is_system) VALUES 
('SUPER_ADMIN', 'Quản trị tối cao', true),
('ADMIN', 'Chủ trọ / Quản trị viên', true),
('MANAGER', 'Quản lý dãy trọ', true),
('TENANT', 'Khách thuê', true);

INSERT INTO sy_commons (type, code, name_vi, name_en, sort_order) VALUES
('ROOM_STATUS', 'EMPTY', 'Trống', 'Empty', 1),
('ROOM_STATUS', 'RENTED', 'Đang thuê', 'Rented', 2),
('ROOM_STATUS', 'REPAIR', 'Đang sửa chữa', 'Maintenance', 3),
('GENDER', 'MALE', 'Nam', 'Male', 1),
('GENDER', 'FEMALE', 'Nữ', 'Female', 2),
('INV_STATUS', 'UNPAID', 'Chưa thanh toán', 'Unpaid', 1),
('INV_STATUS', 'PAID', 'Đã thanh toán', 'Paid', 2);

-- Default admin user (pass: admin123 - hash needed in app)
INSERT INTO sy_users (username, password_hash, full_name, role_code) VALUES 
('admin', '$2b$12$KIXpZ2m5U9W5.Vl5v3e1Uu8l0aZ8.v0w5U.5V.5V.5V.5V.5V.5V', 'Hệ Thống Admin', 'SUPER_ADMIN');
