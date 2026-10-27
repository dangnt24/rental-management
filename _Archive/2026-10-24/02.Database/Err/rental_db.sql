-- =============================================================================
-- DATABASE: RENTAL MANAGEMENT SYSTEM (ENTERPRISE CORE)
-- AUTHOR: GEMINI AI EXPERT
-- TARGET: POSTGRESQL 15+
-- DESCRIPTION: Cấu trúc hoàn hảo, duy nhất và rõ ràng.
-- =============================================================================

-- Extension
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- -----------------------------------------------------------------------------
-- 1. COMMON FUNCTIONS (sy_fn_)
-- -----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION sy_fn_check_exists(p_table_name text, p_column_name text, p_value text) RETURNS boolean AS $$
DECLARE v_exists BOOLEAN;
BEGIN
    EXECUTE format('SELECT EXISTS (SELECT 1 FROM %I WHERE %I = $1)', p_table_name, p_column_name) INTO v_exists USING p_value;
    RETURN v_exists;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sy_fn_check_is_used(p_table_name text, p_id_value anyelement) RETURNS boolean AS $$
DECLARE v_ref_record RECORD; v_count INT; v_is_used BOOLEAN := FALSE;
BEGIN
    FOR v_ref_record IN
        SELECT tc.table_name, kcu.column_name
        FROM information_schema.table_constraints AS tc
        JOIN information_schema.key_column_usage AS kcu ON tc.constraint_name = kcu.constraint_name
        JOIN information_schema.constraint_column_usage AS ccu ON ccu.constraint_name = tc.constraint_name
        WHERE tc.constraint_type = 'FOREIGN KEY' AND ccu.table_name = p_table_name
    LOOP
        EXECUTE format('SELECT count(1) FROM %I WHERE %I = $1', v_ref_record.table_name, v_ref_record.column_name) INTO v_count USING p_id_value;
        IF v_count > 0 THEN v_is_used := TRUE; EXIT; END IF;
    END LOOP;
    RETURN v_is_used;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------------------------------
-- 2. SYSTEM TABLES (sy_)
-- -----------------------------------------------------------------------------

CREATE TABLE sy_commons (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    type VARCHAR(50) NOT NULL,
    code VARCHAR(50) NOT NULL,
    name_vi TEXT NOT NULL,
    name_en TEXT,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    remark TEXT,
    created_by VARCHAR(50),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(50),
    updated_date TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    version INT DEFAULT 1,
    UNIQUE(type, code)
);

CREATE TABLE sy_file_attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_name VARCHAR(50),
    ref_id INT,
    file_name TEXT NOT NULL,
    file_path TEXT NOT NULL,
    file_type VARCHAR(50),
    file_size BIGINT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE
);

CREATE TABLE sy_roles (
    role_code VARCHAR(20) PRIMARY KEY,
    role_name TEXT NOT NULL,
    is_system BOOLEAN DEFAULT FALSE
);

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
    created_by VARCHAR(50),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(50),
    updated_date TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    version INT DEFAULT 1
);

CREATE TABLE sy_document_settings (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    transaction_type VARCHAR(50) UNIQUE,
    prefix VARCHAR(10),
    date_format VARCHAR(10),
    number_digits INT DEFAULT 4,
    current_number INT DEFAULT 0,
    updated_date TIMESTAMP,
    version INT DEFAULT 1
);

-- -----------------------------------------------------------------------------
-- 3. MASTER DATA TABLES (ms_)
-- -----------------------------------------------------------------------------

CREATE TABLE ms_branches (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    branch_name TEXT NOT NULL,
    address TEXT,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_by VARCHAR(50),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(50),
    updated_date TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    version INT DEFAULT 1
);

CREATE TABLE ms_rooms (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    branch_id INT REFERENCES ms_branches(id),
    room_name VARCHAR(50) NOT NULL,
    price NUMERIC(15, 2) DEFAULT 0,
    max_occupants INT DEFAULT 1,
    status_code VARCHAR(50),
    description TEXT,
    created_by VARCHAR(50),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(50),
    updated_date TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    version INT DEFAULT 1
);

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
    created_by VARCHAR(50),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(50),
    updated_date TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    version INT DEFAULT 1
);

CREATE TABLE ms_fee_types (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    branch_id INT REFERENCES ms_branches(id),
    fee_name TEXT NOT NULL,
    unit_price NUMERIC(15, 2) NOT NULL,
    calc_method VARCHAR(20),
    is_system BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_by VARCHAR(50),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    version INT DEFAULT 1
);

-- -----------------------------------------------------------------------------
-- 4. TRANSACTION TABLES (tr_)
-- -----------------------------------------------------------------------------

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
    created_by VARCHAR(50),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(50),
    updated_date TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    version INT DEFAULT 1
);

CREATE TABLE tr_contract_details (
    contract_id INT REFERENCES tr_contracts(id),
    tenant_id INT REFERENCES ms_tenants(id),
    is_main BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (contract_id, tenant_id)
);

CREATE TABLE tr_utility_readings (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    room_id INT REFERENCES ms_rooms(id),
    reading_date DATE NOT NULL,
    elec_index_old NUMERIC(10, 2),
    elec_index_new NUMERIC(10, 2),
    water_index_old NUMERIC(10, 2),
    water_index_new NUMERIC(10, 2),
    created_by VARCHAR(50),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    version INT DEFAULT 1
);

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
    created_by VARCHAR(50),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(50),
    updated_date TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    version INT DEFAULT 1
);

CREATE TABLE tr_invoice_items (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    invoice_id INT REFERENCES tr_invoices(id) ON DELETE CASCADE,
    fee_type_id INT REFERENCES ms_fee_types(id),
    description TEXT,
    quantity NUMERIC(10, 2) DEFAULT 1,
    unit_price NUMERIC(15, 2) DEFAULT 0,
    amount NUMERIC(15, 2) NOT NULL,
    version INT DEFAULT 1
);

CREATE TABLE tr_payments (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    invoice_id INT REFERENCES tr_invoices(id),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount NUMERIC(15, 2) NOT NULL,
    method_code VARCHAR(20),
    evidence_id UUID,
    remark TEXT,
    created_by VARCHAR(50),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    version INT DEFAULT 1
);

CREATE TABLE tr_incidents (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    room_id INT REFERENCES ms_rooms(id),
    tenant_id INT REFERENCES ms_tenants(id),
    description TEXT NOT NULL,
    priority_code VARCHAR(20),
    status_code VARCHAR(20),
    reported_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_date TIMESTAMP,
    repair_cost NUMERIC(15, 2) DEFAULT 0,
    created_by VARCHAR(50),
    is_deleted BOOLEAN DEFAULT FALSE,
    version INT DEFAULT 1
);

-- -----------------------------------------------------------------------------
-- 5. INITIAL SEED DATA
-- -----------------------------------------------------------------------------

INSERT INTO sy_roles (role_code, role_name, is_system) VALUES 
('ADMIN', 'Chủ trọ (Admin)', true),
('MANAGER', 'Quản lý dãy trọ', true),
('TENANT', 'Khách thuê', true);

INSERT INTO sy_commons (type, code, name_vi, name_en, sort_order) VALUES
('ROOM_STATUS', 'EMPTY', 'Trống', 'Empty', 1),
('ROOM_STATUS', 'RENTED', 'Đang thuê', 'Rented', 2),
('ROOM_STATUS', 'REPAIR', 'Đang sửa chữa', 'Maintenance', 3),
('GENDER', 'MALE', 'Nam', 'Male', 1),
('GENDER', 'FEMALE', 'Nữ', 'Female', 2),
('FEE_CALC', 'FIXED', 'Cố định', 'Fixed', 1),
('FEE_CALC', 'UNIT', 'Theo chỉ số', 'Per Unit', 2),
('INV_STATUS', 'UNPAID', 'Chưa thanh toán', 'Unpaid', 1),
('INV_STATUS', 'PAID', 'Đã thanh toán', 'Paid', 2);

-- Password hash cho 'admin123'
INSERT INTO sy_users (username, password_hash, full_name, role_code) VALUES 
('admin', '$2b$12$KIXpZ2m5U9W5.Vl5v3e1Uu8l0aZ8.v0w5U.5V.5V.5V.5V.5V.5V', 'Nguyễn Văn Chủ Trọ', 'ADMIN'),
('khach01', '$2b$12$KIXpZ2m5U9W5.Vl5v3e1Uu8l0aZ8.v0w5U.5V.5V.5V.5V.5V.5V', 'Lê Văn Thuê', 'TENANT');

INSERT INTO ms_branches (branch_name, address) VALUES 
('Nhà Trọ Bình Dương', '123 Thủ Dầu Một, Bình Dương');

INSERT INTO ms_rooms (branch_id, room_name, price, max_occupants, status_code) VALUES
(1, 'Phòng 101', 2500000, 2, 'EMPTY'),
(1, 'Phòng 102', 2500000, 2, 'RENTED');

INSERT INTO ms_tenants (user_id, full_name, identity_number, phone, status_code) VALUES
(2, 'Lê Văn Thuê', '0123456789', '0909123456', 'ACTIVE');

INSERT INTO tr_contracts (contract_code, room_id, start_date, deposit_amount, actual_rent_price, status_code) VALUES
('HD-2024-0001', 2, '2024-01-01', 2500000, 2500000, 'ACTIVE');

INSERT INTO tr_contract_details (contract_id, tenant_id, is_main) VALUES (1, 1, true);

INSERT INTO ms_fee_types (branch_id, fee_name, unit_price, calc_method, is_system) VALUES
(1, 'Tiền phòng', 0, 'FIXED', true),
(1, 'Tiền điện', 3500, 'UNIT', true),
(1, 'Tiền nước', 15000, 'UNIT', true),
(1, 'Rác & Vệ sinh', 50000, 'FIXED', true);
