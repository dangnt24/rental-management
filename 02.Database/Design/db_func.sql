-- =============================================================================
-- DATABASE FUNCTIONS: COMMON UTILITIES (CORE ARCHITECTURE)
-- AUTHOR: GEMINI AI EXPERT
-- TARGET: POSTGRESQL 15+
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. KIỂM TRA TỒN TẠI (check_exists)
-- Kiểm tra một giá trị đã tồn tại trong cột của bảng hay chưa.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION sy_fn_check_exists(
    p_table_name TEXT, 
    p_column_name TEXT, 
    p_value TEXT
)
RETURNS BOOLEAN AS $$
DECLARE
    v_exists BOOLEAN;
    v_sql TEXT;
BEGIN
    -- Sử dụng format để chống SQL Injection cho tên bảng/cột
    v_sql := format('SELECT EXISTS (SELECT 1 FROM %I WHERE %I = $1)', p_table_name, p_column_name);
    EXECUTE v_sql INTO v_exists USING p_value;
    RETURN v_exists;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------------------------------
-- 2. LẤY DANH SÁCH DỮ LIỆU (getlistdata)
-- Lấy dữ liệu dưới dạng JSON để dễ dàng trả về cho API/Frontend.
-- Hỗ trợ phân trang cơ bản.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION sy_fn_get_list_data(
    p_table_name TEXT,
    p_limit INT DEFAULT 100,
    p_offset INT DEFAULT 0
)
RETURNS SETOF JSON AS $$
DECLARE
    v_sql TEXT;
BEGIN
    v_sql := format('SELECT row_to_json(t) FROM (SELECT * FROM %I LIMIT %L OFFSET %L) t', 
                    p_table_name, p_limit, p_offset);
    RETURN QUERY EXECUTE v_sql;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------------------------------
-- 3. KIỂM TRA DỮ LIỆU ĐANG ĐƯỢC SỬ DỤNG (check_isused)
-- Kiểm tra xem một ID có đang được tham chiếu bởi bất kỳ bảng nào khác (Foreign Key) không.
-- Rất hữu ích khi cần kiểm tra trước khi xóa.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION sy_fn_check_is_used(
    p_table_name TEXT, 
    p_id_value ANYELEMENT
)
RETURNS BOOLEAN AS $$
DECLARE
    v_ref_record RECORD;
    v_count INT;
    v_is_used BOOLEAN := FALSE;
BEGIN
    -- Duyệt qua tất cả các bảng có khóa ngoại trỏ tới bảng hiện tại
    FOR v_ref_record IN
        SELECT
            tc.table_name,
            kcu.column_name
        FROM
            information_schema.table_constraints AS tc
            JOIN information_schema.key_column_usage AS kcu
              ON tc.constraint_name = kcu.constraint_name
            JOIN information_schema.constraint_column_usage AS ccu
              ON ccu.constraint_name = tc.constraint_name
        WHERE tc.constraint_type = 'FOREIGN KEY' 
          AND ccu.table_name = p_table_name
    LOOP
        -- Kiểm tra xem có dòng nào trong bảng tham chiếu đang chứa ID này không
        EXECUTE format('SELECT count(1) FROM %I WHERE %I = $1', v_ref_record.table_name, v_ref_record.column_name)
        INTO v_count
        USING p_id_value;

        IF v_count > 0 THEN
            v_is_used := TRUE;
            EXIT; -- Dừng ngay khi tìm thấy một bản ghi đang sử dụng
        END IF;
    END LOOP;

    RETURN v_is_used;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------------------------------
-- VÍ DỤ CÁCH DÙNG:
-- -----------------------------------------------------------------------------
-- 1. Kiểm tra username 'admin' đã có chưa:
-- SELECT sy_fn_check_exists('sy_users', 'username', 'admin');

-- 2. Lấy 10 phòng đầu tiên dạng JSON:
-- SELECT sy_fn_get_list_data('ms_rooms', 10, 0);

-- 3. Kiểm tra phòng ID = 1 có đang được dùng trong hợp đồng nào không:
-- SELECT sy_fn_check_is_used('ms_rooms', 1);
