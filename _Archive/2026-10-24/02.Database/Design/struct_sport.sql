--
-- PostgreSQL database dump
--

\restrict Na16n1eba87EdGvkasqrcZeJAAvw359VgAqk5pBYY5AbdP1PJTHXdcp0ZAW5vmc

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.2

-- Started on 2026-05-26 09:16:40

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 200 (class 2615 OID 24256)
-- Name: hangfire; Type: SCHEMA; Schema: -; Owner: sportevent
--

CREATE SCHEMA hangfire;


ALTER SCHEMA hangfire OWNER TO sportevent;

--
-- TOC entry 3 (class 3079 OID 46000)
-- Name: postgres_fdw; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgres_fdw WITH SCHEMA public;


--
-- TOC entry 6581 (class 0 OID 0)
-- Dependencies: 3
-- Name: EXTENSION postgres_fdw; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgres_fdw IS 'foreign-data wrapper for remote PostgreSQL servers';


--
-- TOC entry 2 (class 3079 OID 28362)
-- Name: vector; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS vector WITH SCHEMA public;


--
-- TOC entry 6582 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION vector; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION vector IS 'vector data type and ivfflat and hnsw access methods';


--
-- TOC entry 926 (class 1255 OID 16874)
-- Name: fn_check_data_exist(character varying, character varying, character varying, text); Type: FUNCTION; Schema: public; Owner: sportevent
--

CREATE FUNCTION public.fn_check_data_exist(p_table_name character varying, p_column_name character varying DEFAULT NULL::character varying, p_value character varying DEFAULT NULL::character varying, p_conditions text DEFAULT NULL::text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_count_row INTEGER := 0;
    v_query TEXT;
BEGIN
	-- function name: hàm common kiểm tra dữ liệu tồn tại trên table hay chưa
	-- create by: tmtam - 01/04/2026
	-- last modify by: xxx - xx/xx/xxxx
	
    -- 1. Xây dựng câu lệnh SQL động
    v_query := 'SELECT count(1) FROM ' || quote_ident(p_table_name) || ' WHERE 1=1';

    -- 2. Kiểm tra và nối điều kiện cột (sử dụng quote_literal để chống SQL Injection cho giá trị)
    IF p_column_name IS NOT NULL AND p_column_name <> '' THEN
        v_query := v_query || ' AND ' || quote_ident(p_column_name) || ' = ' || quote_literal(p_value);
    END IF;

    -- 3. Nối điều kiện tùy chỉnh
    IF p_conditions IS NOT NULL AND p_conditions <> '' THEN
        v_query := v_query || ' AND ' || p_conditions;
    END IF;

    -- 4. Thực thi SQL động và gán kết quả vào biến
    EXECUTE v_query INTO v_count_row;

    -- 5. Trả về kết quả
    RETURN v_count_row;
END;
$$;


ALTER FUNCTION public.fn_check_data_exist(p_table_name character varying, p_column_name character varying, p_value character varying, p_conditions text) OWNER TO sportevent;

--
-- TOC entry 850 (class 1255 OID 16873)
-- Name: fn_check_data_used(bigint[], character varying); Type: FUNCTION; Schema: public; Owner: sportevent
--

CREATE FUNCTION public.fn_check_data_used(p_id_array bigint[], p_screen_code character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_count INTEGER := 0;
BEGIN
    IF p_screen_code = 'SyRole' THEN
        SELECT COUNT(1) INTO v_count
        FROM sy_roles r
        WHERE r.id = ANY(p_id_array)
          AND EXISTS (
              SELECT 1 FROM sy_user_roles ur
              WHERE ur.userrolecode = r.code
          );
          
    ELSIF p_screen_code = 'MsSports' THEN
        SELECT COUNT(1) INTO v_count
        FROM ms_sports s
        WHERE s.id = ANY(p_id_array)
          AND (
            EXISTS (SELECT 1 FROM ms_contents ct WHERE ct.sport_code = s.sport_code)
            OR EXISTS (SELECT 1 FROM ms_teams t WHERE t.sport_code = s.sport_code)
            OR EXISTS (SELECT 1 FROM ms_sport_events se WHERE se.sport_code = s.sport_code)
            OR EXISTS (SELECT 1 FROM sr_match_schedules ms WHERE ms.sport_code = s.sport_code)
            OR EXISTS (SELECT 1 FROM ms_employees emp WHERE emp.sport_code = s.sport_code)
            OR EXISTS (SELECT 1 FROM ms_sport_detail sd WHERE sd.sport_code = s.sport_code)
          );
    ELSIF p_screen_code = 'MsTeams' THEN -- Bổ sung MsTeams
        SELECT COUNT(1) INTO v_count
        FROM ms_teams t
        WHERE t.id = ANY(p_id_array)
          AND (
            EXISTS (SELECT 1 FROM sr_match_teams smt WHERE smt.team_code = t.team_code)
            OR EXISTS (SELECT 1 FROM ms_team_coachs mtc WHERE mtc.team_code = t.team_code)
            OR EXISTS (SELECT 1 FROM ms_athlete_coach_notes acn WHERE acn.team_code = t.team_code)
            OR EXISTS (SELECT 1 FROM ms_competition_team_list ctl WHERE ctl.team_code = t.team_code)
            OR EXISTS (SELECT 1 FROM sr_match_athletes sma WHERE sma.team_code = t.team_code)
          );
    ELSIF p_screen_code = 'MsEmployees' THEN -- Bổ sung MsEmployees
        SELECT COUNT(1) INTO v_count
        FROM ms_employees e
        WHERE e.id = ANY(p_id_array)
          AND (
            EXISTS (SELECT 1 FROM sy_users u WHERE u.referenceobjectcode = e.employee_code)
            OR EXISTS (SELECT 1 FROM ms_team_coachs mtc WHERE mtc.emp_coach_code = e.employee_code)
            OR EXISTS (SELECT 1 FROM sr_match_athletes sma WHERE sma.emp_athlete_code = e.employee_code)
            OR EXISTS (SELECT 1 FROM sr_match_participating_referees mpr WHERE mpr.emp_referee_code = e.employee_code)
            OR EXISTS (SELECT 1 FROM sr_match_volunteer smv WHERE smv.emp_volunteer_code = e.employee_code)
          );
    ELSIF p_screen_code = 'MsLocation' THEN
        SELECT COUNT(1) INTO v_count
        FROM ms_locations lc
        WHERE lc.id = ANY(p_id_array)
          AND (
            EXISTS (SELECT 1 FROM sr_match_schedules ms WHERE ms.location_code = lc.location_code)
            OR EXISTS (SELECT 1 FROM ms_location_detail ld WHERE ld.location_code = lc.location_code)
            OR EXISTS (SELECT 1 FROM ms_sport_events se WHERE se.location_code = lc.location_code)
            OR EXISTS (SELECT 1 FROM io_inout_card_detail icd WHERE icd.location_code = lc.location_code)
            OR EXISTS (SELECT 1 FROM io_inout_barcode_history ibh WHERE ibh.location_code = lc.location_code)
          );
    ELSIF p_screen_code = 'MsEvent' THEN
        SELECT COUNT(1) INTO v_count
        FROM ms_competition_events ce
        WHERE ce.id = ANY(p_id_array)
          AND (
            EXISTS (SELECT 1 FROM ti_ticket_price tp WHERE tp.competition_code = ce.competition_code)
            OR EXISTS (SELECT 1 FROM ms_ticket_categories tc WHERE tc.competition_code = ce.competition_code)
            OR EXISTS (SELECT 1 FROM ms_discounts dc WHERE dc.competition_code = ce.competition_code)
            OR EXISTS (SELECT 1 FROM sr_match_schedules ms WHERE ms.competition_code = ce.competition_code)
            OR EXISTS (SELECT 1 FROM ms_sport_events mse WHERE mse.competition_code = ce.competition_code)
          );
    ELSIF p_screen_code = 'MsDiscount' THEN
        SELECT COUNT(1) INTO v_count
        FROM ms_discounts dc
        WHERE dc.id = ANY(p_id_array)
          AND EXISTS (
              SELECT 1 FROM ti_ticket_sold ts
              WHERE ts.discount_code = dc.discount_code
          );
    ELSIF p_screen_code = 'SrMatchSchedule' THEN
        SELECT COUNT(1) INTO v_count
        FROM sr_match_schedules smc
        WHERE smc.id = ANY(p_id_array)
          AND (
            smc.status NOT IN('NEW')
            OR EXISTS (SELECT 1 FROM sr_match_result smr WHERE smc.match_code = smr.match_code)
          );
    ELSIF p_screen_code = 'SrMatchResult' THEN
        SELECT COUNT(1) INTO v_count
        FROM sr_match_result smr
        WHERE smr.id = ANY(p_id_array)
          AND EXISTS (
              SELECT 1 FROM sr_match_prediction_result spr
              WHERE smr.match_code = spr.match_code AND spr.submit_status = '1'
          );
    END IF;
    RETURN v_count;
END;
$$;


ALTER FUNCTION public.fn_check_data_used(p_id_array bigint[], p_screen_code character varying) OWNER TO sportevent;

--
-- TOC entry 843 (class 1255 OID 37458)
-- Name: fn_import_ioaccesscardmanagement(jsonb, character varying, character varying); Type: FUNCTION; Schema: public; Owner: sportevent
--

CREATE FUNCTION public.fn_import_ioaccesscardmanagement(p_json_data jsonb, p_user_name character varying, p_ip_address character varying) RETURNS TABLE(p_return_code integer, p_message text, p_error_data jsonb)
    LANGUAGE plpgsql
    AS $_$
DECLARE
    v_err_master   jsonb := NULL;
    v_err_detail   jsonb := NULL;
	v_is_override boolean := false;

BEGIN
	-- function name: import access card management
	-- create by: xxx - xx/xx/xxxx
	-- last modify by: xxx - xx/xx/xxxx
	
    -- 1. Khởi tạo mặc định
    p_return_code := 0;
    p_message := 'Common_msg_ImportSuccess';
    p_error_data := '[]'::jsonb;
	
	v_is_override := COALESCE((p_json_data->>'is_override')::boolean, false);

    -- 2. Parse JSON vào bảng tạm
    DROP TABLE IF EXISTS tb_ioaccesscard_temp;
    CREATE TEMP TABLE tb_ioaccesscard_temp AS
    SELECT
        row_number() OVER (ORDER BY (j->>'no')) AS row_number,
        j->>'card_code'             AS card_code,
        j->>'employee_type'         AS employee_type,
        j->>'user_name'             AS user_name,
		CASE
			WHEN j->>'effective_date_from' ~ '^\d+\.?\d*$'
				THEN TO_CHAR(DATE '1899-12-30' + FLOOR((j->>'effective_date_from')::NUMERIC)::INTEGER, 'DD/MM/YYYY')
			ELSE j->>'effective_date_from'
		END AS effective_date_from,
		
		CASE
			WHEN j->>'effective_date_to' ~ '^\d+\.?\d*$'
				THEN TO_CHAR(DATE '1899-12-30' + FLOOR((j->>'effective_date_to')::NUMERIC)::INTEGER, 'DD/MM/YYYY')
			ELSE j->>'effective_date_to'
		END AS effective_date_to,
		        
		COALESCE(NULLIF(TRIM(j->>'status'), ''), '1') AS status,
        j->>'description'           AS description,		
        CAST('' AS TEXT)            AS errordata
    FROM jsonb_array_elements(COALESCE(p_json_data->'sheets'->'Import_General', '[]'::jsonb)) AS j;

    DROP TABLE IF EXISTS tb_ioaccesscard_detail_temp;
    CREATE TEMP TABLE tb_ioaccesscard_detail_temp AS
    SELECT
        row_number() OVER (ORDER BY (j->>'no')) AS row_number,
        j->>'card_code'        	 AS card_code,
        j->>'location_code'      AS location_code,
        j->>'area_code'      	 AS area_code,
        CAST('' AS TEXT)         AS errordata
    FROM jsonb_array_elements(COALESCE(p_json_data->'sheets'->'Import_Detail', '[]'::jsonb)) AS j;

    -- 3. Validate
    IF (SELECT COUNT(1) FROM tb_ioaccesscard_temp) = 0 THEN
        p_return_code := 1;
        p_message := 'Common_msg_MustHaveOneRow,[General]';	
    ELSE
        UPDATE tb_ioaccesscard_temp ms
        SET errordata = CONCAT_WS('',
            -- card_code
            fn_utils_validate_value('card_code', ms.card_code, 50, 'Required', 'IsCode'),
            CASE 
				WHEN io.id IS NOT NULL AND v_is_override = false
				THEN ';Common_msg_DataAlreadyExist,card_code' 
			END,
			
            CASE WHEN dup.cnt > 1 THEN ';Common_msg_DataDuplicate,card_code' END,

            -- employee_type (EMPLOYEE_TYPE)
            fn_utils_validate_value('employee_type', ms.employee_type, 50, 'Required'),
            CASE WHEN sy_pos.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,employee_type' END,

            -- user_name (phải tồn tại trong ms_employees)
            fn_utils_validate_value('user_name', ms.user_name, 50, 'Required'),
            CASE WHEN syu.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,user_name' END,
            CASE WHEN mse.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,user_name' END,

			-- effective_date
			fn_utils_validate_value('effective_date_from',  ms.effective_date_from,  10, 'IsDate'),
			fn_utils_validate_value('effective_date_to', ms.effective_date_to, 10, 'IsDate'),
			
			-- effective_date_from có thì effective_date_to bắt buộc
		    CASE 
		        WHEN (ms.effective_date_from IS NOT NULL AND TRIM(ms.effective_date_from) <> '')
		             AND (ms.effective_date_to IS NULL OR TRIM(ms.effective_date_to) = '')
		        THEN ';Common_msg_MustBeFilledIn,effective_date_to'
		    END,
			
		    -- effective_date_to có thì effective_date_from bắt buộc
		    CASE 
		        WHEN (ms.effective_date_to IS NOT NULL AND TRIM(ms.effective_date_to) <> '')
		             AND (ms.effective_date_from IS NULL OR TRIM(ms.effective_date_from) = '')
		        THEN ';Common_msg_MustBeFilledIn,effective_date_from'
		    END,			
		    
	  		CASE
			  WHEN ms.effective_date_from ~ '^\d{2}/\d{2}/\d{4}$'
			  	AND ms.effective_date_to ~ '^\d{2}/\d{2}/\d{4}$'
				  AND TO_DATE(ms.effective_date_from, 'DD/MM/YYYY') > TO_DATE(ms.effective_date_to, 'DD/MM/YYYY')
			  THEN ';Common_msg_MustBeLessOrEqual,effective_date_from,effective_date_to'
		  END,
		  
		  CASE WHEN COALESCE(ms.status, '') <> '' AND sy_st.id IS NULL
		  	THEN ';Common_msg_DataNotExistOnSystem,status' END,

            -- description
            fn_utils_validate_value('description', ms.description, 500)
        )
        FROM tb_ioaccesscard_temp tp
        LEFT JOIN io_inout_card io ON tp.card_code = io.card_code
        LEFT JOIN sy_users syu ON tp.user_name = syu.username
        LEFT JOIN sy_commons sy_pos ON tp.employee_type = sy_pos.value AND sy_pos.type = 'EMPLOYEE_TYPE'
		LEFT JOIN ms_employees mse ON syu.referenceobjectcode = mse.employee_code AND tp.employee_type = mse.employee_type
        LEFT JOIN sy_commons sy_st ON tp.status = sy_st.value AND sy_st.type = 'COMMON_STATUS'
        LEFT JOIN (
            SELECT card_code, COUNT(1) AS cnt 
            FROM tb_ioaccesscard_temp 
            GROUP BY card_code
        ) dup ON tp.card_code = dup.card_code
        WHERE ms.row_number = tp.row_number;

        SELECT jsonb_agg(t) INTO v_err_master
        FROM (
            SELECT *
            FROM tb_ioaccesscard_temp
            WHERE COALESCE(errordata, '') <> ''
            ORDER BY row_number
        ) t;
    END IF;

	    IF (SELECT COUNT(1) FROM tb_ioaccesscard_detail_temp) = 0 THEN
        p_return_code := 1;
        p_message := 'Common_msg_MustHaveOneRow,[General]';	
    ELSE
        UPDATE tb_ioaccesscard_detail_temp dt
        SET errordata = CONCAT_WS('',
            -- card_code
            fn_utils_validate_value('card_code', tdt.card_code, 50, 'Required', 'IsCode'),
            CASE WHEN ms.card_code IS NULL THEN ';Common_msg_DataNotExistOnSystem,card_code' END,

            -- location_code
            fn_utils_validate_value('location_code', tdt.location_code, 50, 'Required'),
            CASE WHEN msl.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,location_code' END,

            -- area_code
            fn_utils_validate_value('area_code', tdt.area_code, 50, 'Required'),
            CASE WHEN msld.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,area_code' END,
			
            -- Check duplicate
            CASE WHEN dup.cnt > 1 THEN ';Common_msg_DataDuplicate,card_code' END
        )
        FROM tb_ioaccesscard_detail_temp tdt
        LEFT JOIN tb_ioaccesscard_temp ms ON tdt.card_code = ms.card_code
        LEFT JOIN ms_locations msl ON tdt.location_code = msl.location_code
        LEFT JOIN ms_location_detail msld ON msl.location_code = msld.location_code AND tdt.area_code = msld.area_code
        LEFT JOIN (
            SELECT card_code, location_code, area_code, COUNT(1) AS cnt 
            FROM tb_ioaccesscard_detail_temp 
            GROUP BY card_code, location_code, area_code
        ) dup ON tdt.card_code = dup.card_code AND tdt.location_code = dup.location_code AND tdt.area_code = dup.area_code
        WHERE dt.row_number = tdt.row_number;

        SELECT jsonb_agg(t) INTO v_err_detail
        FROM (
            SELECT *
            FROM tb_ioaccesscard_detail_temp
            WHERE COALESCE(errordata, '') <> ''
            ORDER BY row_number
        ) t;
    END IF;

    -- 4. Kiểm tra lỗi
    IF p_return_code = 0 THEN
	    IF v_err_master IS NOT NULL OR v_err_detail IS NOT NULL THEN
	        p_return_code := 1;
	        p_message := 'Common_msg_ImportInvalid';
	        p_error_data := jsonb_strip_nulls(
	            jsonb_build_object(
	                'General', v_err_master,
	                'Detail', v_err_detail
	            )
	        );
	    ELSE	        
	   -- =========================
		-- OVERRIDE MODE
		-- =========================
		IF v_is_override = true THEN
		
		-- Xóa detail cũ của các card_code trong file
			DELETE FROM io_inout_card_detail
			WHERE card_code IN (SELECT DISTINCT card_code FROM tb_ioaccesscard_temp);
			
			-- UPDATE master nếu đã tồn tại
			UPDATE io_inout_card SET
				employee_type = m.employee_type,
				user_name = m.user_name,
				status = m.status,
				effective_date_from = CASE WHEN m.effective_date_from IS NOT NULL AND TRIM(m.effective_date_from) <> ''
												THEN TO_DATE(m.effective_date_from, 'DD/MM/YYYY') ELSE NULL END,
				effective_date_to = CASE WHEN m.effective_date_to IS NOT NULL AND TRIM(m.effective_date_to) <> ''
												THEN TO_DATE(m.effective_date_to, 'DD/MM/YYYY') ELSE NULL END,
				description = m.description,
				updated_by = p_user_name, 
				updated_date = NOW()
			FROM tb_ioaccesscard_temp m
			WHERE io_inout_card.card_code = m.card_code;
			
			-- INSERT master nếu chưa tồn tại
			INSERT INTO io_inout_card (
				card_code,
				employee_type,
				user_name, status,			
				effective_date_from,
				effective_date_to,
				description,
				created_by,
				created_date,
				updated_by,
				updated_date
			)
			SELECT
				m.card_code,
				m.employee_type,
				m.user_name,
				m.status,
				CASE WHEN m.effective_date_from IS NOT NULL AND TRIM(m.effective_date_from) <> ''
						THEN TO_DATE(m.effective_date_from, 'DD/MM/YYYY') ELSE NULL END,
				CASE WHEN m.effective_date_to IS NOT NULL AND TRIM(m.effective_date_to) <> ''
						THEN TO_DATE(m.effective_date_to, 'DD/MM/YYYY') ELSE NULL END,
				m.description,
				p_user_name, 
				NOW(), 
				p_user_name,
				NOW()
			FROM tb_ioaccesscard_temp m
			WHERE NOT EXISTS (
				SELECT 1 FROM io_inout_card io WHERE io.card_code = m.card_code
			)
			ORDER BY m.row_number;		
		-- =========================
		-- NORMAL INSERT MODE
		-- =========================
		ELSE
		INSERT INTO io_inout_card (
			card_code,
			employee_type,
			user_name,
			status,
			effective_date_from,
			effective_date_to,
			description,
			created_by, 
			created_date,
			updated_by,
			updated_date
		)
			SELECT
				m.card_code,
				m.employee_type,
				m.user_name,
				m.status,
				CASE WHEN m.effective_date_from IS NOT NULL AND TRIM(m.effective_date_from) <> ''
						THEN TO_DATE(m.effective_date_from, 'DD/MM/YYYY') ELSE NULL END,
				CASE WHEN m.effective_date_to IS NOT NULL AND TRIM(m.effective_date_to) <> ''
						THEN TO_DATE(m.effective_date_to, 'DD/MM/YYYY') ELSE NULL END,
				m.description,
				p_user_name,
				NOW(),
				p_user_name,
				NOW()
			FROM tb_ioaccesscard_temp m
			ORDER BY m.row_number;
		END IF;		
		-- =========================
		-- INSERT DETAIL (COMMON - cả 2 mode)
		-- =========================
		IF (SELECT COUNT(1) FROM tb_ioaccesscard_detail_temp) > 0 THEN
			INSERT INTO io_inout_card_detail (
				card_code,
				location_code,
				area_code,
				created_by,
				created_date,
				updated_by,
				updated_date
		)
		SELECT
			d.card_code,
			d.location_code,
			d.area_code,
			p_user_name, 
			NOW(), 
			p_user_name,
			NOW()
		FROM tb_ioaccesscard_detail_temp d
		ORDER BY d.row_number;
		END IF;
	        -- HISTORY
	        INSERT INTO public.sy_journals(
	            module_code,
	            function_code,
	            user_name,
	            data_id,
	            action_code,
	            action_date,
	            ip_address,
	            json_before,
	            json_after
	        )
	        VALUES (
	            'InOutAccessControl',
	            'IoAccessCardManagement',
	            p_user_name,
	            NULL,
	            'IMPORT',
	            CURRENT_TIMESTAMP,
	            p_ip_address,
	            NULL,
	            p_json_data
	        );
	    END IF;
	END IF;

    -- Xóa bảng tạm
    DROP TABLE IF EXISTS tb_ioaccesscard_temp;
    DROP TABLE IF EXISTS tb_ioaccesscard_detail_temp;

    RETURN NEXT;

EXCEPTION WHEN OTHERS THEN
    p_return_code := 1;
    p_message := SQLERRM;
    p_error_data := '[]'::jsonb;
    RETURN NEXT;
END;
$_$;


ALTER FUNCTION public.fn_import_ioaccesscardmanagement(p_json_data jsonb, p_user_name character varying, p_ip_address character varying) OWNER TO sportevent;

--
-- TOC entry 872 (class 1255 OID 18294)
-- Name: fn_import_msbackground(jsonb, character varying, character varying); Type: FUNCTION; Schema: public; Owner: sportevent
--

CREATE FUNCTION public.fn_import_msbackground(p_json_data jsonb, p_user_name character varying, p_ip_address character varying) RETURNS TABLE(p_return_code integer, p_message text, p_error_data jsonb)
    LANGUAGE plpgsql
    AS $$
	-- function name: import thông tin background
	-- create by: lthngoc - 01/04/2026
	-- last modify by: xxx - xx/xx/xxxx
DECLARE
    v_err_master jsonb := '[]'::jsonb;
BEGIN
    -- 1. Khởi tạo giá trị mặc định cho các cột trả về
    p_return_code := 0;
    p_message := 'Common_msg_ImportSuccess';
    p_error_data := '[]'::jsonb;

    -- 2. Parse JSON vào bảng tạm
  
	-- Lưu ý: Sử dụng CREATE TEMP TABLE trong function cần cẩn thận với việc gọi nhiều lần trong 1 session
	-- Dùng DROP TABLE IF EXISTS để tránh lỗi "table already exists"
	DROP TABLE IF EXISTS tb_master_temp;
	CREATE TEMP TABLE tb_master_temp AS
	SELECT
		row_number() OVER (ORDER BY (j->>'no')) AS row_number,
		j->>'background_code' as background_code,
		j->>'type' as type,
		j->>'status' as status,
		j->>'information_description' as information_description,
		CAST('' AS TEXT) AS errordata
	FROM jsonb_array_elements(p_json_data->'sheets'->'Data') AS j;
	
	-- 3. Validate
	IF (SELECT COUNT(1) FROM tb_master_temp) = 0 THEN
		-- validate không có data
		p_return_code := 1;
		p_message := 'Common_msg_MustHaveOneRow,[Data]';
	ELSE
		-- Gán mặc định status = '1' nếu không nhập
		UPDATE tb_master_temp
	    SET status = '1'
	    WHERE status IS NULL;
		-- validate nghiệp vụ
		UPDATE tb_master_temp ms
		SET 
			errordata = CONCAT_WS('',
				fn_utils_validate_value('background_code', ms.background_code, 50, 'Required'),
				CASE WHEN msog.id IS NOT NULL THEN ';Common_msg_DataAlreadyExist,background_code' END,
								
				fn_utils_validate_value('type', ms.type, 1, 'Required'),
				CASE WHEN syst_type.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,type' END,

				fn_utils_validate_value('Trạng thái', ms.status, 1, 'Required'),
       			CASE WHEN syst_status.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,status' END,
				
				fn_utils_validate_value('information_description', ms.information_description, 500)
			)
		FROM tb_master_temp mst
		LEFT JOIN ms_background msog ON mst.background_code = msog.background_code
		LEFT JOIN sy_commons syst_type ON syst_type.value = mst.type AND syst_type.type = 'BACKGROUND_TYPE'
		LEFT JOIN sy_commons syst_status ON syst_status.value = mst.status AND syst_status.type = 'COMMON_STATUS'
		WHERE ms.row_number = mst.row_number;
		
		SELECT jsonb_agg(t) INTO v_err_master 
		FROM (SELECT * FROM tb_master_temp WHERE errordata <> '') t;
	END IF;
	
	-- 4. Kiểm tra nếu có lỗi
	IF p_return_code = 0 THEN
		-- trả lỗi
		IF v_err_master IS NOT NULL THEN
			p_return_code := 1;
			p_message := 'Common_msg_ImportInvalid';
			p_error_data := jsonb_build_object('Sheet1', v_err_master);
		-- không lỗi thực hiện insert
		ELSE 
			INSERT INTO ms_background(
				background_code,
				type,
				status,
				information_description,
				created_by,
				created_date,
				updated_by,
				updated_date
			) SELECT
				background_code,
				type,
				status,
				information_description,
				p_user_name,
				NOW(),
				p_user_name,
				NOW()
			FROM tb_master_temp
			ORDER BY row_number;
			-- [HISTORY] Lưu lịch sử system history cho Import
            INSERT INTO public.sy_journals(module_code, function_code, user_name, data_id, action_code, action_date, ip_address, json_before, json_after)
            VALUES ('Master', 'MsBackground', p_user_name, NULL, 'IMPORT', CURRENT_TIMESTAMP, p_ip_address, NULL, p_json_data);
		END IF;
	END IF;
	
	-- Xóa bảng tạm sau khi dùng xong (tùy chọn vì có ON COMMIT DROP nếu bọc trong transaction)
	DROP TABLE IF EXISTS tb_master_temp;
	
    -- Trả về dòng dữ liệu kết quả
    RETURN NEXT;

EXCEPTION WHEN OTHERS THEN
    -- Bẫy lỗi hệ thống
    p_return_code := 1;
    p_message := SQLERRM; --'Common_msg_AnErrorOccurred';
    p_error_data := '[]'::jsonb;
    RETURN NEXT;
END;
$$;


ALTER FUNCTION public.fn_import_msbackground(p_json_data jsonb, p_user_name character varying, p_ip_address character varying) OWNER TO sportevent;

--
-- TOC entry 961 (class 1255 OID 18838)
-- Name: fn_import_msdiscount(jsonb, character varying, character varying); Type: FUNCTION; Schema: public; Owner: sportevent
--

CREATE FUNCTION public.fn_import_msdiscount(p_json_data jsonb, p_user_name character varying, p_ip_address character varying) RETURNS TABLE(p_return_code integer, p_message text, p_error_data jsonb)
    LANGUAGE plpgsql
    AS $_$
DECLARE
    v_err_master jsonb := '[]'::jsonb;
BEGIN
    -- 1. Khởi tạo giá trị mặc định cho các cột trả về
    p_return_code := 0;
    p_message := 'Common_msg_ImportSuccess';
    p_error_data := '[]'::jsonb;

    -- 2. Parse JSON vào bảng tạm
  
	-- Lưu ý: Sử dụng CREATE TEMP TABLE trong function cần cẩn thận với việc gọi nhiều lần trong 1 session
	-- Dùng DROP TABLE IF EXISTS để tránh lỗi "table already exists"
	DROP TABLE IF EXISTS tb_master_temp;
	CREATE TEMP TABLE tb_master_temp AS
	SELECT
		row_number() OVER (ORDER BY (j->>'no')) AS row_number,
		j->>'discount_code' as discount_code,
		j->>'discount_name_vi' as discount_name_vi,
		j->>'discount_name_en' as discount_name_en,
		j->>'competition_code' as competition_code,
		j->>'effective_date_from' as effective_date_from,
		j->>'effective_date_to' as effective_date_to,
		j->>'status' as status,
		j->>'discount_type' as discount_type,
		j->>'discount_value' as discount_value,
		j->>'max_discount_value' as max_discount_value,
		j->>'min_discount_value' as min_discount_value,
		j->>'total_discount' as total_discount,
		CAST('' AS TEXT) AS errordata
	FROM jsonb_array_elements(p_json_data->'sheets'->'Data') AS j;
	
	-- 3. Validate
	IF (SELECT COUNT(1) FROM tb_master_temp) = 0 THEN
		-- validate không có data
		p_return_code := 1;
		p_message := 'Common_msg_MustHaveOneRow,[Data]';
	ELSE
		-- validate nghiệp vụ
		UPDATE tb_master_temp ms
		SET 
			errordata = CONCAT_WS('',
				fn_utils_validate_value('discount_code', ms.discount_code, 50, 'Required', 'IsCode'),
				CASE WHEN msog.id IS NOT NULL THEN ';Common_msg_DataAlreadyExist,discount_code' END,
				
				fn_utils_validate_value('discount_name_vi', ms.discount_name_vi, 255, 'Required'),
				fn_utils_validate_value('discount_name_en', ms.discount_name_en, 255),

				fn_utils_validate_value('competition_code', ms.competition_code, 50, 'Required', 'IsCode'),
				CASE WHEN ms.competition_code IS NOT NULL AND comp.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,competition_code' END,
				
				CASE WHEN ms.status IS NOT NULL AND TRIM(ms.status) <> '' AND syst.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,status' END,

				fn_utils_validate_value('discount_type', ms.competition_code, 50, 'Required'),
				CASE WHEN ms.discount_type IS NOT NULL AND dtype.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,discount_type' END,
				
				fn_utils_validate_value('effective_date_from', ms.effective_date_from, 10, 'IsDate'),
				fn_utils_validate_value('effective_date_to', ms.effective_date_to, 10, 'IsDate'),
				CASE 
					WHEN ms.effective_date_from IS NOT NULL AND TRIM(ms.effective_date_from) <> ''
					  AND ms.effective_date_to IS NOT NULL AND TRIM(ms.effective_date_to) <> ''
					  AND TO_DATE(ms.effective_date_from, 'DD/MM/YYYY') > TO_DATE(ms.effective_date_to, 'DD/MM/YYYY')
					THEN ';Common_msg_MustBeLessOrEqual,effective_date_from,effective_date_to'
				END,
				
				fn_utils_validate_value('discount_value', ms.discount_value, NULL, 'Required', 'IsNumber'),
				CASE WHEN ms.discount_value ~ '^-?[0-9]+$' AND CAST(ms.discount_value AS BIGINT) <= 0 THEN ';Common_msg_MustBeGreaterThan,discount_value,0' END,
				CASE WHEN ms.discount_type = '1' AND ms.discount_value ~ '^-?[0-9]+$' AND CAST(ms.discount_value AS BIGINT) > 100 THEN ';Common_msg_MustBeLessOrEqual,discount_value,100' END,
				
				fn_utils_validate_value('max_discount_value', ms.max_discount_value, NULL, 'Required', 'IsNumber'),
				CASE WHEN ms.max_discount_value ~ '^-?[0-9]+$' AND CAST(ms.max_discount_value AS BIGINT) <= 0 THEN ';Common_msg_MustBeGreaterThan,max_discount_value,0' END,
				
				fn_utils_validate_value('min_discount_value', ms.min_discount_value, NULL, 'Required', 'IsNumber'),
				CASE WHEN ms.min_discount_value ~ '^-?[0-9]+$' AND CAST(ms.min_discount_value AS BIGINT) <= 0 THEN ';Common_msg_MustBeGreaterThan,min_discount_value,0' END,
				CASE WHEN ms.max_discount_value ~ '^-?[0-9]+$' AND ms.min_discount_value ~ '^-?[0-9]+$' AND CAST(ms.max_discount_value AS BIGINT) < CAST(ms.min_discount_value AS BIGINT) THEN ';Common_msg_MustBeGreaterThanOrEquals,max_discount_value,min_discount_value' END,
				
				fn_utils_validate_value('total_discount', ms.total_discount, NULL, 'Required', 'IsNumber'),
				CASE WHEN ms.total_discount ~ '^-?[0-9]+$' AND CAST(ms.total_discount AS BIGINT) <= 0 THEN ';Common_msg_MustBeGreaterThan,total_discount,0' END
			)
		FROM tb_master_temp mst
		LEFT JOIN ms_discounts msog ON mst.discount_code = msog.discount_code
		LEFT JOIN ms_competition_events comp ON mst.competition_code = comp.competition_code
		LEFT JOIN sy_commons syst ON syst.value = mst.status AND syst.type = 'COMMON_STATUS'
		LEFT JOIN sy_commons dtype ON dtype.value = mst.discount_type AND dtype.type = 'DISCOUNT_TYPE'
		WHERE ms.row_number = mst.row_number;
		
		SELECT jsonb_agg(t) INTO v_err_master 
		FROM (SELECT * FROM tb_master_temp WHERE errordata <> '') t;
	END IF;
	
	-- 4. Kiểm tra nếu có lỗi
	IF p_return_code = 0 THEN
		-- trả lỗi
		IF v_err_master IS NOT NULL THEN
			p_return_code := 1;
			p_message := 'Common_msg_ImportInvalid';
			p_error_data := jsonb_build_object('Sheet1', v_err_master);
		-- không lỗi thực hiện insert
		ELSE 
			INSERT INTO ms_discounts(
				discount_code,
				discount_name_vi,
				discount_name_en,
				competition_code,
				effective_date_from,
				effective_date_to,
				status,
				discount_type,
				discount_value,
				max_discount_value,
				min_discount_value,
				total_discount,
				total_discount_used,
				created_by,
				created_date,
				updated_by,
				updated_date
			) SELECT
				discount_code,
				discount_name_vi,
				COALESCE(NULLIF(TRIM(discount_name_en), ''), discount_name_vi),
				competition_code,
				TO_DATE(effective_date_from, 'DD/MM/YYYY'),
				TO_DATE(effective_date_to, 'DD/MM/YYYY'),
				COALESCE(NULLIF(TRIM(status), ''), '1'),
				discount_type,
				CAST(discount_value AS NUMERIC),
				CAST(max_discount_value AS NUMERIC),
				CAST(min_discount_value AS NUMERIC),
				CAST(total_discount AS INTEGER),
				0,
				p_user_name,
				NOW(),
				p_user_name,
				NOW()
			FROM tb_master_temp
			ORDER BY row_number;
			-- [HISTORY] Lưu lịch sử system history cho Import
            INSERT INTO public.sy_journals(module_code, function_code, user_name, data_id, action_code, action_date, ip_address, json_before, json_after)
            VALUES ('Master', 'MsDiscount', p_user_name, NULL, 'IMPORT', CURRENT_TIMESTAMP, p_ip_address, NULL, p_json_data);
		END IF;
	END IF;
	
	-- Xóa bảng tạm sau khi dùng xong (tùy chọn vì có ON COMMIT DROP nếu bọc trong transaction)
	DROP TABLE IF EXISTS tb_master_temp;
	
    -- Trả về dòng dữ liệu kết quả
    RETURN NEXT;

EXCEPTION WHEN OTHERS THEN
    -- Bẫy lỗi hệ thống
    p_return_code := 1;
    p_message := SQLERRM; --'Common_msg_AnErrorOccurred';
    p_error_data := '[]'::jsonb;
    RETURN NEXT;
END;
$_$;


ALTER FUNCTION public.fn_import_msdiscount(p_json_data jsonb, p_user_name character varying, p_ip_address character varying) OWNER TO sportevent;

--
-- TOC entry 925 (class 1255 OID 19530)
-- Name: fn_import_msemployees(jsonb, character varying, character varying); Type: FUNCTION; Schema: public; Owner: sportevent
--

CREATE FUNCTION public.fn_import_msemployees(p_json_data jsonb, p_user_name character varying, p_ip_address character varying) RETURNS TABLE(p_return_code integer, p_message text, p_error_data jsonb)
    LANGUAGE plpgsql
    AS $_$
DECLARE
    v_err_general jsonb := NULL;
    v_err_injury jsonb := NULL;
    v_err_achievement jsonb := NULL;
    v_err_athleteviolat jsonb := NULL;
    v_err_certificates jsonb := NULL;
    v_err_experiences jsonb := NULL;
    v_err_competition_profile jsonb := NULL;
BEGIN
    -- 1. Khởi tạo giá trị mặc định cho các cột trả về
    p_return_code := 0;
    p_message := 'Common_msg_ImportSuccess';
    p_error_data := '[]'::jsonb;

    -- 2. Parse JSON vào bảng tạm
  
	-- Lưu ý: Sử dụng CREATE TEMP TABLE trong function cần cẩn thận với việc gọi nhiều lần trong 1 session
	-- Dùng DROP TABLE IF EXISTS để tránh lỗi "table already exists"
	-- Thông tin thành viên
	DROP TABLE IF EXISTS tb_general_temp;
	CREATE TEMP TABLE tb_general_temp AS
	SELECT
		row_number() OVER (ORDER BY (j->>'no')) AS row_number,
		j->>'employee_type' as employee_type,
		j->>'employee_code' as employee_code,
		j->>'employee_name_vi' as employee_name_vi,
		-- Nếu không nhập tên EN thì hệ thống mặc định lấy tên VI
		COALESCE(NULLIF(BTRIM(j->>'employee_name_en'), ''), j->>'employee_name_vi') as employee_name_en,
		j->>'gender' as gender,
		j->>'nationality' as nationality,
		j->>'date_of_birth' as date_of_birth,
		j->>'email' as email,
		j->>'phone_number' as phone_number,
		j->>'sport_code' as sport_code,
		COALESCE(NULLIF(j->>'status', ''), '1') as status,
		j->>'position_code' as position_code,
		CASE WHEN j->>'employee_type' = 'ATH' THEN j->>'blood_type' ELSE NULL END as blood_type,
		CASE WHEN j->>'employee_type' = 'ATH' THEN j->>'height' ELSE NULL END as height,
		CASE WHEN j->>'employee_type' = 'ATH' THEN j->>'weight' ELSE NULL END as weight,
		j->>'employee_status' as employee_status,
		j->>'identity_card' as identity_card,
		j->>'address' as address,
		j->>'emergency_contact' as emergency_contact,
		j->>'skill' as skill,
		CASE WHEN j->>'employee_type' = 'ATH' THEN j->>'allergy' ELSE NULL END as allergy,
		CASE WHEN j->>'employee_type' = 'ATH' THEN j->>'latest_effective_date' ELSE NULL END as latest_effective_date,
		CASE WHEN j->>'employee_type' = 'ATH' THEN j->>'doping_test_date' ELSE NULL END as doping_test_date,
		CASE WHEN j->>'employee_type' = 'ATH' THEN j->>'doping_test_result' ELSE NULL END as doping_test_result,
		CAST('' AS TEXT) AS errordata
	FROM jsonb_array_elements(COALESCE(p_json_data->'sheets'->'General', '[]'::jsonb)) AS j;

	-- Lịch sử chấn thương (VĐV)
	DROP TABLE IF EXISTS tb_injury_temp;
	CREATE TEMP TABLE tb_injury_temp AS
	SELECT
		row_number() OVER (ORDER BY (j->>'no')) AS row_number,
		j->>'employee_code' as employee_code,
		j->>'injury_date' as injury_date,
		j->>'injury_position' as injury_position,
		j->>'level_of_injury' as level_of_injury,
		j->>'injury_recovery_time' as injury_recovery_time,
		j->>'description' as description,
		CAST('' AS TEXT) AS errordata
	FROM jsonb_array_elements(COALESCE(p_json_data->'sheets'->'Injury', '[]'::jsonb)) AS j;

	-- Lịch đào tạo (VĐV)
	DROP TABLE IF EXISTS tb_achievement_temp;
	CREATE TEMP TABLE tb_achievement_temp AS
	SELECT
		row_number() OVER (ORDER BY (j->>'no')) AS row_number,
		j->>'employee_code' as employee_code,
		j->>'tournament' as tournament,
		j->>'playing_position' as playing_position,
		j->>'experience' as experience,
		j->>'from_date' as from_date,
		j->>'to_date' as to_date,
		j->>'description' as description,
		CAST('' AS TEXT) AS errordata
	FROM jsonb_array_elements(COALESCE(p_json_data->'sheets'->'Achievement', '[]'::jsonb)) AS j;

	-- Lịch vi phạm (VĐV)
	DROP TABLE IF EXISTS tb_athleteviolat_temp;
	CREATE TEMP TABLE tb_athleteviolat_temp AS
	SELECT
		row_number() OVER (ORDER BY (j->>'no')) AS row_number,
		j->>'employee_code' as employee_code,
		j->>'tournament' as tournament,
		j->>'violation_date' as violation_date,
		j->>'description' as description,
		CAST('' AS TEXT) AS errordata
	FROM jsonb_array_elements(COALESCE(p_json_data->'sheets'->'AthleteViolat', '[]'::jsonb)) AS j;

	-- Chứng chỉ (HLV, TT)
	DROP TABLE IF EXISTS tb_certificates_temp;
	CREATE TEMP TABLE tb_certificates_temp AS
	SELECT
		row_number() OVER (ORDER BY (j->>'no')) AS row_number,
		j->>'employee_code' as employee_code,
		j->>'certificate_name_vi' as certificate_name_vi,
		-- Nếu không nhập tên EN thì hệ thống mặc định lấy tên VI
		COALESCE(NULLIF(BTRIM(j->>'certificate_name_en'), ''), j->>'certificate_name_vi') as certificate_name_en,
		j->>'issued_by' as issued_by,
		j->>'specialty' as specialty,
		j->>'issue_date' as issue_date,
		j->>'expiry_date' as expiry_date,
		j->>'description' as description,
		CAST('' AS TEXT) AS errordata
	FROM jsonb_array_elements(COALESCE(p_json_data->'sheets'->'Certificates', '[]'::jsonb)) AS j;

	-- Kinh nghiệm (HLV, TT)
	DROP TABLE IF EXISTS tb_experiences_temp;
	CREATE TEMP TABLE tb_experiences_temp AS
	SELECT
		row_number() OVER (ORDER BY (j->>'no')) AS row_number,
		j->>'employee_code' as employee_code,
		j->>'from_date' as from_date,
		j->>'to_date' as to_date,
		j->>'role' as role,
		j->>'organization' as organization,
		j->>'description' as description,
		CAST('' AS TEXT) AS errordata
	FROM jsonb_array_elements(COALESCE(p_json_data->'sheets'->'Experiences', '[]'::jsonb)) AS j;

	-- Hồ sơ thi đấu
	DROP TABLE IF EXISTS tb_competition_profile_temp;
	CREATE TEMP TABLE tb_competition_profile_temp AS
	SELECT
		row_number() OVER (ORDER BY (j->>'no')) AS row_number,
		j->>'employee_code' as employee_code,
		j->>'team_code' as team_code,
		j->>'sport_code' as sport_code,
		j->>'certificate_name_vi' as certificate_name_vi,
		j->>'certificate_name_en' as certificate_name_en,
		j->>'valid_from_date' as valid_from_date,
		j->>'valid_to_date' as valid_to_date,
		CAST('' AS TEXT) AS errordata
	FROM jsonb_array_elements(COALESCE(p_json_data->'sheets'->'CompetitionProfile', '[]'::jsonb)) AS j;
	
	-- 3. Validate thông tin thành viên
	IF (SELECT COUNT(1) FROM tb_general_temp) = 0 THEN
		-- validate không có data
		p_return_code := 1;
		p_message := 'Common_msg_MustHaveOneRow,[General]';
	ELSE
		-- validate nghiệp vụ
		UPDATE tb_general_temp ms
		SET 
			errordata = CONCAT_WS('',
				fn_utils_validate_value('employee_type', ms.employee_type, 20, 'Required'),
				fn_utils_validate_value('employee_code', ms.employee_code, 50, 'Required'),				
				fn_utils_validate_value('employee_name_vi', ms.employee_name_vi, 255, 'Required'),
				fn_utils_validate_value('employee_name_en', ms.employee_name_en, 255),
				fn_utils_validate_value('identity_card', ms.identity_card, 12, 'Required', 'IsNumber'),
				fn_utils_validate_value('email', ms.email, 150, 'Required', 'IsEmail'),
				fn_utils_validate_value('date_of_birth', ms.date_of_birth, 10, 'IsDate'),
				fn_utils_validate_value('phone_number', ms.phone_number, 10, 'IsNumber'),
				
				fn_utils_validate_value('blood_type', ms.blood_type, 255),
				fn_utils_validate_value('height', ms.height, 255, 'IsNumber'),
				fn_utils_validate_value('weight', ms.weight, 255, 'IsNumber'),
				fn_utils_validate_value('address', ms.address, 255),
				fn_utils_validate_value('emergency_contact', ms.emergency_contact, 255),
				fn_utils_validate_value('skill', ms.skill, 500),
				fn_utils_validate_value('allergy', ms.allergy, 255),
				fn_utils_validate_value('latest_effective_date', ms.latest_effective_date, 10, 'IsDate'),
				fn_utils_validate_value('doping_test_date', ms.doping_test_date, 10, 'IsDate'),
				
				CASE WHEN emp.id IS NOT NULL THEN ';Common_msg_DataAlreadyExist,employee_code' END,
				CASE WHEN empem.id IS NOT NULL THEN ';Common_msg_DataAlreadyExist,email' END,
				CASE WHEN empic.id IS NOT NULL THEN ';Common_msg_DataAlreadyExist,identity_card' END,

				-- validate dữ liệu trùng trong file import
				CASE WHEN dup_employee_code.employee_code IS NOT NULL THEN ';Common_msg_DuplicateData,employee_code' END,
				CASE WHEN dup_email.email IS NOT NULL THEN ';Common_msg_DuplicateData,email' END,
				CASE WHEN dup_identity_card.identity_card IS NOT NULL THEN ';Common_msg_DuplicateData,identity_card' END,

				-- validate số CCCD/Hộ chiếu phải có đúng 9 hoặc 12 chữ số
				CASE
					WHEN NULLIF(BTRIM(mst.identity_card), '') IS NOT NULL
						AND BTRIM(mst.identity_card) ~ '^[0-9]+$'
						AND LENGTH(BTRIM(mst.identity_card)) NOT IN (9, 12)
					THEN ';MsEmployees_msg_InvalidIdentityCardLength,identity_card,9,12'
				END,

				-- validate ngày sinh không được lớn hơn ngày hiện tại
				CASE
					WHEN NULLIF(BTRIM(mst.date_of_birth), '') IS NOT NULL
						AND mst.date_of_birth ~ '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
						AND TO_DATE(mst.date_of_birth, 'DD/MM/YYYY') > CURRENT_DATE
					THEN ';Common_msg_MustBeLessOrEqual,date_of_birth,Common_lbl_ToDay'
				END,
				
				CASE WHEN NULLIF(BTRIM(mst.employee_type), '') IS NOT NULL AND syemt.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,employee_type' END,
				CASE WHEN NULLIF(BTRIM(mst.gender), '') IS NOT NULL AND sygd.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,gender' END,
				CASE WHEN NULLIF(BTRIM(mst.nationality), '') IS NOT NULL AND synt.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,nationality' END,
				CASE WHEN syst.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,status' END,
				CASE WHEN NULLIF(BTRIM(mst.position_code), '') IS NOT NULL AND syps.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,position_code' END,
				CASE WHEN NULLIF(BTRIM(mst.sport_code), '') IS NOT NULL AND msp.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,sport_code' END,
				CASE WHEN NULLIF(BTRIM(mst.employee_status), '') IS NOT NULL AND syept.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,employee_status' END,
				CASE WHEN NULLIF(BTRIM(mst.doping_test_result), '') IS NOT NULL AND sydp.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,doping_test_result' END,
				
				''
			)
		FROM tb_general_temp mst
		LEFT JOIN (
			SELECT employee_code
			FROM tb_general_temp
			WHERE NULLIF(BTRIM(employee_code), '') IS NOT NULL
			GROUP BY employee_code
			HAVING COUNT(1) > 1
		) dup_employee_code ON dup_employee_code.employee_code = mst.employee_code
		LEFT JOIN (
			SELECT email
			FROM tb_general_temp
			WHERE NULLIF(BTRIM(email), '') IS NOT NULL
			GROUP BY email
			HAVING COUNT(1) > 1
		) dup_email ON dup_email.email = mst.email
		LEFT JOIN (
			SELECT identity_card
			FROM tb_general_temp
			WHERE NULLIF(BTRIM(identity_card), '') IS NOT NULL
			GROUP BY identity_card
			HAVING COUNT(1) > 1
		) dup_identity_card ON dup_identity_card.identity_card = mst.identity_card
		LEFT JOIN ms_employees emp ON NULLIF(BTRIM(mst.employee_code), '') IS NOT NULL AND emp.employee_code = mst.employee_code
		LEFT JOIN ms_employees empem ON NULLIF(BTRIM(mst.email), '') IS NOT NULL AND empem.email = mst.email
		LEFT JOIN ms_employees empic ON NULLIF(BTRIM(mst.identity_card), '') IS NOT NULL
			AND BTRIM(mst.identity_card) ~ '^[0-9]+$'
			AND LENGTH(BTRIM(mst.identity_card)) IN (9, 12)
			AND empic.identity_card = mst.identity_card
		
		LEFT JOIN sy_commons syemt ON syemt.value = mst.employee_type AND syemt.type = 'EMPLOYEE_TYPE'
		LEFT JOIN sy_commons sygd ON sygd.value = mst.gender AND sygd.type = 'GENDER'
		LEFT JOIN sy_commons synt ON synt.value = mst.nationality AND synt.type = 'NATIONALITY'
		LEFT JOIN sy_commons syst ON syst.value = mst.status AND syst.type = 'COMMON_STATUS'
		LEFT JOIN sy_commons syept ON syept.value = mst.employee_status AND syept.type = 'EMPLOYEE_STATUS'
		LEFT JOIN sy_commons sydp ON sydp.value = mst.doping_test_result AND sydp.type = 'DOPING_RESULT'
		LEFT JOIN sy_commons syps ON syps.value = mst.position_code AND syps.type IN ('REFEREE_POSITION', 'ATHLETE_POSITION', 'COACH_ROLE', 'PERSONINCHARGE_ROLE')
		
		LEFT JOIN ms_sports msp ON msp.sport_code = mst.sport_code
		WHERE ms.row_number = mst.row_number;
		
		SELECT jsonb_agg(t) INTO v_err_general 
		FROM (SELECT * FROM tb_general_temp WHERE errordata <> '') t;
	END IF;

	-- validate lịch sử chấn thương
	IF (SELECT COUNT(1) FROM tb_injury_temp) > 0 THEN
		-- validate nghiệp vụ
		UPDATE tb_injury_temp ms
		SET 
			errordata = CONCAT_WS('',
				fn_utils_validate_value('employee_code', ms.employee_code, 50, 'Required'),
				fn_utils_validate_value('injury_date', ms.injury_date, 10, 'Required', 'IsDate'),
				fn_utils_validate_value('injury_position', ms.injury_position, 500, 'Required'),
				fn_utils_validate_value('level_of_injury', ms.level_of_injury, 20, 'Required'),
				fn_utils_validate_value('injury_recovery_time', ms.injury_recovery_time, 255, 'Required'),
				fn_utils_validate_value('description', ms.description, 500),
				CASE WHEN NULLIF(BTRIM(mst.level_of_injury), '') IS NOT NULL AND syloj.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,level_of_injury' END,

				-- validate mã thành viên ở sheet chi tiết phải tồn tại trên sheet General và đúng loại VĐV
				CASE
					WHEN NULLIF(BTRIM(mst.employee_code), '') IS NOT NULL AND emp.employee_code IS NULL
					THEN ';Common_msg_DataNotExistOnSystem,employee_code'
				END,
				''
			)
		FROM tb_injury_temp mst
		LEFT JOIN tb_general_temp emp ON emp.employee_code = mst.employee_code AND emp.employee_type = 'ATH'
		LEFT JOIN sy_commons syloj ON syloj.value = mst.level_of_injury AND syloj.type = 'LEVELOFINJURY'
		WHERE ms.row_number = mst.row_number;
		
		SELECT jsonb_agg(t) INTO v_err_injury 
		FROM (SELECT * FROM tb_injury_temp WHERE errordata <> '') t;
	END IF;

	-- validate lịch sử đào tạo
	IF (SELECT COUNT(1) FROM tb_achievement_temp) > 0 THEN
		-- validate nghiệp vụ
		UPDATE tb_achievement_temp ms
		SET 
			errordata = CONCAT_WS('',
				fn_utils_validate_value('employee_code', ms.employee_code, 50, 'Required'),
				fn_utils_validate_value('tournament', ms.tournament, 255, 'Required'),
				fn_utils_validate_value('playing_position', ms.playing_position, 255, 'Required'),
				fn_utils_validate_value('experience', ms.experience, 255, 'Required'),
				fn_utils_validate_value('from_date', ms.from_date, 10, 'Required', 'IsDate'),
				fn_utils_validate_value('to_date', ms.to_date, 10, 'Required', 'IsDate'),
				fn_utils_validate_value('description', ms.description, 500),

				-- validate mã thành viên ở sheet chi tiết phải tồn tại trên sheet General và đúng loại VĐV
				CASE
					WHEN NULLIF(BTRIM(mst.employee_code), '') IS NOT NULL AND emp.employee_code IS NULL
					THEN ';Common_msg_DataNotExistOnSystem,employee_code'
				END,

				-- validate từ ngày không được lớn hơn đến ngày
				CASE
					WHEN NULLIF(BTRIM(mst.from_date), '') IS NOT NULL
						AND NULLIF(BTRIM(mst.to_date), '') IS NOT NULL
						AND mst.from_date ~ '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
						AND mst.to_date ~ '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
						AND TO_DATE(mst.from_date, 'DD/MM/YYYY') > TO_DATE(mst.to_date, 'DD/MM/YYYY')
					THEN ';Common_msg_MustBeLessOrEqual,from_date,to_date'
				END,
				''
			)
		FROM tb_achievement_temp mst
		LEFT JOIN tb_general_temp emp ON emp.employee_code = mst.employee_code AND emp.employee_type = 'ATH'
		WHERE ms.row_number = mst.row_number;
		
		SELECT jsonb_agg(t) INTO v_err_achievement 
		FROM (SELECT * FROM tb_achievement_temp WHERE errordata <> '') t;
	END IF;

	-- validate lịch sử vi phạm
	IF (SELECT COUNT(1) FROM tb_athleteviolat_temp) > 0 THEN
		-- validate nghiệp vụ
		UPDATE tb_athleteviolat_temp ms
		SET 
			errordata = CONCAT_WS('',
				fn_utils_validate_value('employee_code', ms.employee_code, 50, 'Required'),
				fn_utils_validate_value('tournament', ms.tournament, 255, 'Required'),
				fn_utils_validate_value('violation_date', ms.violation_date, 10, 'Required', 'IsDate'),
				fn_utils_validate_value('description', ms.description, 500),

				-- validate mã thành viên ở sheet chi tiết phải tồn tại trên sheet General và đúng loại VĐV
				CASE
					WHEN NULLIF(BTRIM(mst.employee_code), '') IS NOT NULL AND emp.employee_code IS NULL
					THEN ';Common_msg_DataNotExistOnSystem,employee_code'
				END,
				''
			)
		FROM tb_athleteviolat_temp mst
		LEFT JOIN tb_general_temp emp ON emp.employee_code = mst.employee_code AND emp.employee_type = 'ATH'
		WHERE ms.row_number = mst.row_number;
		
		SELECT jsonb_agg(t) INTO v_err_athleteviolat
		FROM (SELECT * FROM tb_athleteviolat_temp WHERE errordata <> '') t;
	END IF;

	-- validate chứng chỉ
	IF (SELECT COUNT(1) FROM tb_certificates_temp) > 0 THEN
		-- validate nghiệp vụ
		UPDATE tb_certificates_temp ms
		SET 
			errordata = CONCAT_WS('',
				fn_utils_validate_value('employee_code', ms.employee_code, 50, 'Required'),
				fn_utils_validate_value('certificate_name_vi', ms.certificate_name_vi, 255, 'Required'),
				fn_utils_validate_value('certificate_name_en', ms.certificate_name_en, 255),
				fn_utils_validate_value('issued_by', ms.issued_by, 255, 'Required'),
				fn_utils_validate_value('specialty', ms.specialty, 255, 'Required'),
				fn_utils_validate_value('issue_date', ms.issue_date, 10, 'Required', 'IsDate'),
				fn_utils_validate_value('expiry_date', ms.expiry_date, 10, 'Required', 'IsDate'),
				fn_utils_validate_value('description', ms.description, 500),

				-- validate mã thành viên ở sheet chi tiết phải tồn tại trên sheet General và đúng loại HLV/TT
				CASE
					WHEN NULLIF(BTRIM(mst.employee_code), '') IS NOT NULL AND emp.employee_code IS NULL
					THEN ';Common_msg_DataNotExistOnSystem,employee_code'
				END,

				-- validate ngày cấp không được lớn hơn ngày hết hạn
				CASE
					WHEN NULLIF(BTRIM(mst.issue_date), '') IS NOT NULL
						AND NULLIF(BTRIM(mst.expiry_date), '') IS NOT NULL
						AND mst.issue_date ~ '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
						AND mst.expiry_date ~ '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
						AND TO_DATE(mst.issue_date, 'DD/MM/YYYY') > TO_DATE(mst.expiry_date, 'DD/MM/YYYY')
					THEN ';Common_msg_MustBeLessOrEqual,issue_date,expiry_date'
				END,
				''
			)
		FROM tb_certificates_temp mst
		LEFT JOIN tb_general_temp emp ON emp.employee_code = mst.employee_code AND emp.employee_type IN ('COA', 'REF')
		WHERE ms.row_number = mst.row_number;
		
		SELECT jsonb_agg(t) INTO v_err_certificates
		FROM (SELECT * FROM tb_certificates_temp WHERE errordata <> '') t;
	END IF;

	-- validate kinh nghiệm
	IF (SELECT COUNT(1) FROM tb_experiences_temp) > 0 THEN
		-- validate nghiệp vụ
		UPDATE tb_experiences_temp ms
		SET 
			errordata = CONCAT_WS('',
				fn_utils_validate_value('employee_code', ms.employee_code, 50, 'Required'),
				fn_utils_validate_value('from_date', ms.from_date, 10, 'Required', 'IsDate'),
				fn_utils_validate_value('to_date', ms.to_date, 10, 'Required', 'IsDate'),
				fn_utils_validate_value('organization', ms.organization, 255, 'Required'),
				fn_utils_validate_value('role', ms.role, 20, 'Required'),
				fn_utils_validate_value('description', ms.description, 500),
				CASE WHEN NULLIF(BTRIM(mst.role), '') IS NOT NULL AND syps.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,role' END,

				-- validate mã thành viên ở sheet chi tiết phải tồn tại trên sheet General và đúng loại HLV/TT
				CASE
					WHEN NULLIF(BTRIM(mst.employee_code), '') IS NOT NULL AND emp.employee_code IS NULL
					THEN ';Common_msg_DataNotExistOnSystem,employee_code'
				END,

				-- validate từ ngày không được lớn hơn đến ngày
				CASE
					WHEN NULLIF(BTRIM(mst.from_date), '') IS NOT NULL
						AND NULLIF(BTRIM(mst.to_date), '') IS NOT NULL
						AND mst.from_date ~ '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
						AND mst.to_date ~ '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
						AND TO_DATE(mst.from_date, 'DD/MM/YYYY') > TO_DATE(mst.to_date, 'DD/MM/YYYY')
					THEN ';Common_msg_MustBeLessOrEqual,from_date,to_date'
				END,
				''
			)
		FROM tb_experiences_temp mst
		LEFT JOIN tb_general_temp emp ON emp.employee_code = mst.employee_code AND emp.employee_type IN ('COA', 'REF')
		LEFT JOIN sy_commons syps ON syps.value = mst.role AND syps.type IN ('REFEREE_POSITION','COACH_ROLE')
		WHERE ms.row_number = mst.row_number;
		
		SELECT jsonb_agg(t) INTO v_err_experiences
		FROM (SELECT * FROM tb_experiences_temp WHERE errordata <> '') t;
	END IF;
	
	-- validate hồ sơ thi đấu
	IF (SELECT COUNT(1) FROM tb_competition_profile_temp) > 0 THEN
		-- validate hồ sơ thi đấu
		UPDATE tb_competition_profile_temp ms
		SET 
			errordata = CONCAT_WS('',
				-- fn_utils_validate_value('employee_code', mst.employee_code, 50, 'Required'),
				
				-- validate mã thành viên ở sheet chi tiết phải tồn tại trên sheet General và đúng loại VDV
				CASE
					WHEN NULLIF(BTRIM(mst.employee_code), '') IS NOT NULL AND emp.employee_code IS NULL
					THEN ';Common_msg_DataNotExistOnSystem,employee_code'
				END,
				
				-- validate đội phải tồn tại trên hệ thống
           		CASE WHEN ms.team_code <> '' AND team.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,team_code' END,
				   
				-- validate môn thi đấu phải tồn tại trên hệ thống
           		CASE WHEN ms.sport_code <> '' AND sport.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,sport_code' END,

				-- validate từ ngày không được lớn hơn đến ngày
				CASE
					WHEN NULLIF(BTRIM(mst.valid_from_date), '') IS NOT NULL
						AND NULLIF(BTRIM(mst.valid_to_date), '') IS NOT NULL
						AND mst.valid_from_date ~ '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
						AND mst.valid_to_date ~ '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
						AND TO_DATE(mst.valid_from_date, 'DD/MM/YYYY') > TO_DATE(mst.valid_to_date, 'DD/MM/YYYY')
					THEN ';Common_msg_MustBeLessOrEqual,valid_from_date,valid_to_date'
				END,
				''
			)
		FROM tb_competition_profile_temp mst
		LEFT JOIN tb_general_temp emp ON emp.employee_code = mst.employee_code AND emp.employee_type IN ('ATH')
		LEFT JOIN ms_teams team ON mst.team_code = team.team_code
		LEFT JOIN ms_sports sport ON mst.sport_code = sport.sport_code
		WHERE ms.row_number = mst.row_number;
		
		SELECT jsonb_agg(t) INTO v_err_competition_profile
		FROM (SELECT * FROM tb_competition_profile_temp WHERE errordata <> '') t;
	END IF;
	
	-- 4. Kiểm tra nếu có lỗi
	IF p_return_code = 0 THEN
		-- trả lỗi
		IF v_err_general IS NOT NULL
			OR v_err_injury IS NOT NULL
			OR v_err_achievement IS NOT NULL
			OR v_err_athleteviolat IS NOT NULL
			OR v_err_certificates IS NOT NULL
			OR v_err_experiences IS NOT NULL
			OR v_err_competition_profile IS NOT NULL THEN
			p_return_code := 1;
			p_message := 'Common_msg_ImportInvalid';
			p_error_data := jsonb_build_object(
				'General', v_err_general
				,'Injury', v_err_injury
				,'Achievement', v_err_achievement
				,'AthleteViolat', v_err_athleteviolat
				,'Certificates', v_err_certificates
				,'Experiences', v_err_experiences
				,'CompetitionProfile', v_err_competition_profile
			);
		-- không lỗi thực hiện insert
		ELSE 
			-- insert thông tin thành viên
			INSERT INTO ms_employees(
				employee_type,
				employee_code,
				employee_name_vi,
				employee_name_en,
				identity_card,
				gender,
				nationality,
				date_of_birth,
				address,
				email,
				phone_number,
				sport_code,
				status,
				position_code,
				skill,
				emergency_contact,
				allergy,
				employee_status,
				blood_type,
				weight,
				height,
				latest_effective_date,
				doping_test_date,
				doping_test_result,
				created_by,
				created_date,
				updated_by,
				updated_date
			)
			SELECT
				employee_type,
				employee_code,
				employee_name_vi,
				employee_name_en,
				identity_card,
				gender,
				nationality,
				TO_DATE(NULLIF(BTRIM(date_of_birth), ''), 'DD/MM/YYYY'),
				address,
				email,
				phone_number,
				sport_code,
				status,
				position_code,
				skill,
				emergency_contact,
				allergy,
				employee_status,
				blood_type,
				CAST(NULLIF(BTRIM(weight), '') AS NUMERIC(25, 10)),
				CAST(NULLIF(BTRIM(height), '') AS NUMERIC(25, 10)),
				TO_DATE(NULLIF(BTRIM(latest_effective_date), ''), 'DD/MM/YYYY'),
				TO_DATE(NULLIF(BTRIM(doping_test_date), ''), 'DD/MM/YYYY'),
				doping_test_result,
				p_user_name,
				NOW(),
				p_user_name,
				NOW()
			FROM tb_general_temp;

			-- insert lịch sử chấn thương
			INSERT INTO ms_injury_history(
				employee_code,
				injury_date,
				injury_position,
				injury_recovery_time,
				level_of_injury,
				description,
				created_by,
				created_date,
				updated_by,
				updated_date
			)
			SELECT
				employee_code,
				TO_DATE(NULLIF(BTRIM(injury_date), ''), 'DD/MM/YYYY'),
				injury_position,
				injury_recovery_time,
				level_of_injury,
				description,
				p_user_name,
				NOW(),
				p_user_name,
				NOW()
			FROM tb_injury_temp;

			-- insert lịch sử đào tạo
			INSERT INTO ms_achievement_history(
				employee_code,
				tournament,
				playing_position,
				experience,
				from_date,
				to_date,
				description,
				created_by,
				created_date,
				updated_by,
				updated_date
			)
			SELECT
				employee_code,
				tournament,
				playing_position,
				experience,
				TO_DATE(NULLIF(BTRIM(from_date), ''), 'DD/MM/YYYY'),
				TO_DATE(NULLIF(BTRIM(to_date), ''), 'DD/MM/YYYY'),
				description,
				p_user_name,
				NOW(),
				p_user_name,
				NOW()
			FROM tb_achievement_temp;

			-- insert lịch sử vi phạm
			INSERT INTO ms_athlete_violation_history(
				employee_code,
				tournament,
				violation_date,
				description,
				created_by,
				created_date,
				updated_by,
				updated_date
			)
			SELECT 
				employee_code,
				tournament,
				TO_DATE(NULLIF(BTRIM(violation_date), ''), 'DD/MM/YYYY'),
				description,
				p_user_name,
				NOW(),
				p_user_name,
				NOW()
			FROM tb_athleteviolat_temp;

			-- insert chứng chỉ
			INSERT INTO ms_certificates(
				employee_code,
				certificate_name_vi,
				certificate_name_en,
				issued_by,
				specialty,
				issue_date,
				expiry_date,
				description,
				created_by,
				created_date,
				updated_by,
				updated_date
			)
			SELECT
				employee_code,
				certificate_name_vi,
				certificate_name_en,
				issued_by,
				specialty,
				TO_DATE(NULLIF(BTRIM(issue_date), ''), 'DD/MM/YYYY'),
				TO_DATE(NULLIF(BTRIM(expiry_date), ''), 'DD/MM/YYYY'),
				description,
				p_user_name,
				NOW(),
				p_user_name,
				NOW()
			FROM tb_certificates_temp;

			-- insert kinh nghiệm
			INSERT INTO ms_experiences(
				employee_code,
				from_date,
				to_date,
				role,
				organization,
				description,
				created_by,
				created_date,
				updated_by,
				updated_date
			)
			SELECT
				employee_code,
				TO_DATE(NULLIF(BTRIM(from_date), ''), 'DD/MM/YYYY'),
				TO_DATE(NULLIF(BTRIM(to_date), ''), 'DD/MM/YYYY'),
				role,
				organization,
				description,
				p_user_name,
				NOW(),
				p_user_name,
				NOW()
			FROM tb_experiences_temp;

			-- insert hồ sơ thi đấu
			INSERT INTO ms_competition_profile(
				employee_code,
				team_code,
				sport_code,
				certificate_name_vi,
				certificate_name_en,
				valid_from_date,
				valid_to_date,
				created_by,
				created_date,
				updated_by,
				updated_date
			)
			SELECT
				employee_code,
				team_code,
				sport_code,
				certificate_name_vi,
				certificate_name_en,
				TO_DATE(NULLIF(BTRIM(valid_from_date), ''), 'DD/MM/YYYY'),
				TO_DATE(NULLIF(BTRIM(valid_to_date), ''), 'DD/MM/YYYY'),
				p_user_name,
				NOW(),
				p_user_name,
				NOW()
			FROM tb_competition_profile_temp;
			-- [HISTORY] Lưu lịch sử system history cho Import
			INSERT INTO public.sy_journals(module_code, function_code, user_name, data_id, action_code, action_date, ip_address, json_before, json_after)
			VALUES ('Master', 'MsEmployees', p_user_name, NULL, 'IMPORT', CURRENT_TIMESTAMP, p_ip_address, NULL, p_json_data);
		END IF;
	END IF;
	
	-- Xóa bảng tạm sau khi dùng xong (tùy chọn vì có ON COMMIT DROP nếu bọc trong transaction)
	DROP TABLE IF EXISTS tb_general_temp, tb_injury_temp, tb_achievement_temp, tb_athleteviolat_temp, tb_certificates_temp, tb_experiences_temp;
	
    -- Trả về dòng dữ liệu kết quả
    RETURN NEXT;

EXCEPTION WHEN OTHERS THEN
    -- Bẫy lỗi hệ thống
    p_return_code := 1;
    p_message := SQLERRM; --'Common_msg_AnErrorOccurred';
    p_error_data := '[]'::jsonb;
    RETURN NEXT;
END;
$_$;


ALTER FUNCTION public.fn_import_msemployees(p_json_data jsonb, p_user_name character varying, p_ip_address character varying) OWNER TO sportevent;

--
-- TOC entry 917 (class 1255 OID 19778)
-- Name: fn_import_msevent(jsonb, character varying, character varying); Type: FUNCTION; Schema: public; Owner: sportevent
--

CREATE FUNCTION public.fn_import_msevent(p_json_data jsonb, p_user_name character varying, p_ip_address character varying) RETURNS TABLE(p_return_code integer, p_message text, p_error_data jsonb)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_err_general jsonb := NULL;
    v_err_sport_event jsonb := NULL;
    v_err_team jsonb := NULL;
    v_is_override boolean := false;
    v_used_codes text;
BEGIN
    -- 1. Khởi tạo giá trị mặc định cho các cột trả về
    p_return_code := 0;
    p_message := 'Common_msg_ImportSuccess';
    p_error_data := '[]'::jsonb;

    -- 2. Parse JSON vào bảng tạm
	v_is_override := COALESCE((p_json_data->>'is_override')::boolean, false);

	-- Lưu ý: Sử dụng CREATE TEMP TABLE trong function cần cẩn thận với việc gọi nhiều lần trong 1 session
	-- Dùng DROP TABLE IF EXISTS để tránh lỗi "table already exists"
	DROP TABLE IF EXISTS tb_general_temp;
	CREATE TEMP TABLE tb_general_temp AS
	SELECT
		row_number() OVER (ORDER BY (j->>'no')) AS row_number,
		j->>'competition_code' AS competition_code,
		j->>'competition_name_vi' AS competition_name_vi,
		j->>'competition_name_en' AS competition_name_en,
		j->>'host' AS host,
		j->>'status' AS status,
		j->>'start_date' AS start_date,
		j->>'end_date' AS end_date,
		CAST('' AS TEXT) AS errordata
	FROM jsonb_array_elements(p_json_data->'sheets'->'General') AS j;
	
	DROP TABLE IF EXISTS tb_sport_event_temp;
	CREATE TEMP TABLE tb_sport_event_temp AS
	SELECT
		row_number() OVER (ORDER BY (k->>'no')) AS row_number,
		k->>'competition_code' AS competition_code,
		k->>'sport_code' AS sport_code,
		k->>'sport_event_code' AS sport_event_code,
		k->>'location_code' AS location_code,
		CAST('' AS TEXT) AS errordata
	FROM jsonb_array_elements(p_json_data->'sheets'->'SportEvent') AS k;
	
	DROP TABLE IF EXISTS tb_team_temp;
	CREATE TEMP TABLE tb_team_temp AS
	SELECT
		row_number() OVER (ORDER BY (l->>'no')) AS row_number,
		l->>'competition_code' AS competition_code,
		l->>'team_code' AS team_code,
		CAST('' AS TEXT) AS errordata
	FROM jsonb_array_elements(p_json_data->'sheets'->'Team') AS l;
	
	-- Kiểm tra ràng buộc nếu override = true
	IF v_is_override = true THEN
        SELECT STRING_AGG(DISTINCT g.competition_code, ' | ' ORDER BY g.competition_code)
        INTO v_used_codes
        FROM tb_general_temp g
        JOIN ms_competition_events ce ON ce.competition_code = g.competition_code
        WHERE EXISTS (
            SELECT 1 FROM ti_ticket_price tp WHERE tp.competition_code = ce.competition_code
        )
        OR EXISTS (
            SELECT 1 FROM ms_ticket_categories tc WHERE tc.competition_code = ce.competition_code
        )
        OR EXISTS (
            SELECT 1 FROM ms_discounts dc WHERE dc.competition_code = ce.competition_code
        )
        OR EXISTS (
            SELECT 1 FROM sr_match_schedules ms WHERE ms.competition_code = ce.competition_code
        );
        
        IF v_used_codes IS NOT NULL THEN
            p_return_code := 1;
            p_message := 'Common_msg_OverrideDataIsUsed,competition_code,' || v_used_codes;
		    RETURN NEXT;
        END IF;
	END IF;
	-- 3. Validate
	IF (SELECT COUNT(1) FROM tb_general_temp) = 0 THEN
		-- validate không có data
		p_return_code := 1;
		p_message := 'Common_msg_MustHaveOneRow,[General]';
	ELSE
		-- validate nghiệp vụ General
		UPDATE tb_general_temp gs
		SET 
			errordata = CONCAT_WS('',
				fn_utils_validate_value('competition_code', gs.competition_code, 50, 'Required', 'IsCode'),
				CASE 
				    WHEN mse.id IS NOT NULL 
				         AND v_is_override = false 
				    THEN ';Common_msg_DataAlreadyExist,competition_code' 
				END,
				
				fn_utils_validate_value('competition_name_vi', gs.competition_name_vi, 255, 'Required'),
				fn_utils_validate_value('competition_name_en', gs.competition_name_en, 255),
				fn_utils_validate_value('host', gs.host, 255, 'Required'),

				fn_utils_validate_value('status', gs.status, 1),
				CASE WHEN gs.status IS NOT NULL AND TRIM(gs.status) <> '' AND syst.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,status' END,
				
				fn_utils_validate_value('start_date',  gs.start_date,  10, 'IsDate'),
				fn_utils_validate_value('end_date', gs.end_date, 10, 'IsDate'),
				-- start_date có thì end_date bắt buộc
		        CASE 
		            WHEN (gs.start_date IS NOT NULL AND TRIM(gs.start_date) <> '')
		                 AND (gs.end_date IS NULL OR TRIM(gs.end_date) = '')
		            THEN ';Common_msg_MustBeFilledIn,end_date'
		        END,

		        -- end_date có thì start_date bắt buộc
		        CASE 
		            WHEN (gs.end_date IS NOT NULL AND TRIM(gs.end_date) <> '')
		                 AND (gs.start_date IS NULL OR TRIM(gs.start_date) = '')
		            THEN ';Common_msg_MustBeFilledIn,start_date'
		        END,

		        -- start_date <= end_date
		        CASE 
		            WHEN (gs.start_date IS NOT NULL AND TRIM(gs.start_date) <> '')
		                 AND (gs.end_date IS NOT NULL AND TRIM(gs.end_date) <> '')
		                 AND (TO_DATE(gs.start_date, 'DD/MM/YYYY') > TO_DATE(gs.end_date, 'DD/MM/YYYY'))
		            THEN ';Common_msg_MustBeLessOrEqual,start_date,end_date'
		        END
			)
		FROM tb_general_temp mst
		LEFT JOIN ms_competition_events mse ON mst.competition_code = mse.competition_code
		LEFT JOIN sy_commons syst ON syst.value = mst.status AND syst.type = 'COMMON_STATUS'
		WHERE gs.row_number = mst.row_number;
		
		SELECT jsonb_agg(t) INTO v_err_general 
		FROM (SELECT * FROM tb_general_temp WHERE errordata <> '') t;

		-- Validate SportEvent
		IF (SELECT COUNT(1) FROM tb_sport_event_temp) = 0 THEN
			-- validate không có data
			p_return_code := 1;
			p_message := 'Common_msg_MustHaveOneRow,[SportEvent]';
		ELSE		
			UPDATE tb_sport_event_temp ses
			SET errordata = CONCAT_WS('',
			    fn_utils_validate_value('competition_code', dst.competition_code, 50, 'Required', 'IsCode'),
			    CASE WHEN mst.competition_code IS NULL THEN ';Common_msg_KeyNotFoundInSheet,competition_code,General' END,
			    
			    fn_utils_validate_value('sport_code', dst.sport_code, 50, 'Required'),
			    CASE WHEN s.id IS NULL AND dst.sport_code IS NOT NULL THEN ';Common_msg_DataNotExistOnSystem,sport_code' END,
			    
			    fn_utils_validate_value('sport_event_code', dst.sport_event_code, 500, 'Required'),
			    CASE 
			        WHEN dst.sport_event_code IS NOT NULL AND TRIM(dst.sport_event_code) <> '' AND invalid_codes.codes IS NOT NULL 
			        THEN ';Common_msg_DataNotExistOnSystem,sport_event_code: "' || invalid_codes.codes || '"'
			        ELSE ''
			    END,
			    
			    fn_utils_validate_value('location_code', dst.location_code, 50, 'Required'),
			    CASE WHEN (lc.id IS NULL AND dst.location_code IS NOT NULL) THEN ';Common_msg_DataNotExistOnSystem,location_code' END
			)
			FROM tb_sport_event_temp dst
			LEFT JOIN tb_general_temp mst ON dst.competition_code = mst.competition_code
			LEFT JOIN ms_sports s ON dst.sport_code = s.sport_code
			LEFT JOIN ms_locations lc ON dst.location_code = lc.location_code
			LEFT JOIN LATERAL (
			    SELECT STRING_AGG(TRIM(code_item), ' | ' ORDER BY TRIM(code_item)) as codes
			    FROM regexp_split_to_table(dst.sport_event_code, ',') as code_item
			    WHERE TRIM(code_item) <> ''
			      AND NOT EXISTS (
			          SELECT 1 FROM ms_sport_detail 
			          WHERE sport_event_code = TRIM(code_item)
			      )
			) invalid_codes ON true
			WHERE ses.row_number = dst.row_number;

			-- Check duplicate
			WITH src AS (
			    SELECT 
			        dst.*,
			        COUNT(*) OVER (
			            PARTITION BY 
			                TRIM(COALESCE(dst.competition_code, '')),
			                TRIM(COALESCE(dst.sport_code, '')),
			                TRIM(COALESCE(dst.sport_event_code, ''))
			        ) AS dup_count
			    FROM tb_sport_event_temp dst
			)
			UPDATE tb_sport_event_temp ses
			SET errordata = CONCAT_WS(ses.errordata,
			    CASE 
			        WHEN src.dup_count > 1 
			        THEN ';Common_msg_DuplicateData,competition_code & sport_code & sport_event_code'
			    END
			)
			FROM src
			WHERE ses.row_number = src.row_number;
			
			SELECT jsonb_agg(t) INTO v_err_sport_event 
			FROM (SELECT * FROM tb_sport_event_temp WHERE errordata <> '') t;

			-- Validate Team
			IF (SELECT COUNT(1) FROM tb_team_temp) = 0 THEN
				-- validate không có data
				p_return_code := 1;
				p_message := 'Common_msg_MustHaveOneRow,[Team]';
			ELSE
				UPDATE tb_team_temp ts
				SET errordata = CONCAT_WS('',
					fn_utils_validate_value('competition_code', ts.competition_code, 50, 'Required', 'IsCode'),
					CASE WHEN gst.competition_code IS NULL THEN ';Common_msg_KeyNotFoundInSheet,competition_code,General' END,
					
					fn_utils_validate_value('team_code', ts.team_code, 50, 'Required'),
					CASE WHEN (t.id IS NULL AND ts.team_code IS NOT NULL) THEN ';Common_msg_DataNotExistOnSystem,team_code' END,

					CASE WHEN dup.team_code IS NOT NULL THEN ';Common_msg_DuplicateData,competition_code & team_code' END
				)
				FROM tb_team_temp tst
				LEFT JOIN tb_general_temp gst ON tst.competition_code = gst.competition_code
				LEFT JOIN ms_teams t ON t.team_code = tst.team_code
			    LEFT JOIN (
			        SELECT competition_code, team_code
			        FROM tb_team_temp
			        GROUP BY competition_code, team_code
			        HAVING COUNT(*) > 1
			    ) dup 
			        ON dup.competition_code = tst.competition_code
			       AND dup.team_code = tst.team_code
				WHERE ts.row_number = tst.row_number;
				
				SELECT jsonb_agg(t) INTO v_err_team 
				FROM (SELECT * FROM tb_team_temp WHERE errordata <> '') t;
			END IF;
		END IF;
	END IF;
	
	-- 4. Kiểm tra nếu có lỗi
	IF p_return_code = 0 THEN
		-- trả lỗi
		IF v_err_general IS NOT NULL OR v_err_sport_event IS NOT NULL OR v_err_team IS NOT NULL THEN
			p_return_code := 1;
			p_message := 'Common_msg_ImportInvalid';
			p_error_data := jsonb_strip_nulls(jsonb_build_object(
				'General', v_err_general,
				'SportEvent', v_err_sport_event,
				'Team', v_err_team
			));
		-- không lỗi thực hiện insert
		ELSE 
		    -- =========================
		    -- OVERRIDE MODE
		    -- =========================
		    IF v_is_override = true THEN

		        -- DELETE DETAIL TRƯỚC
		        DELETE FROM ms_sport_events se
		        USING tb_general_temp g
		        WHERE se.competition_code = g.competition_code;

		        DELETE FROM ms_competition_team_list tl
		        USING tb_general_temp g
		        WHERE tl.competition_code = g.competition_code;

		        -- UPDATE MASTER (nếu tồn tại)
		        UPDATE ms_competition_events mse
		        SET 
		            competition_name_vi = g.competition_name_vi,
		            competition_name_en = COALESCE(NULLIF(TRIM(g.competition_name_en), ''), g.competition_name_vi),
		            host = g.host,
		            status = COALESCE(NULLIF(TRIM(g.status), ''), '1'),
		            start_date = CASE 
		                            WHEN g.start_date IS NOT NULL AND TRIM(g.start_date) <> '' 
		                            THEN TO_DATE(g.start_date, 'DD/MM/YYYY') 
		                            ELSE NULL 
		                         END,
		            end_date = CASE 
		                            WHEN g.end_date IS NOT NULL AND TRIM(g.end_date) <> '' 
		                            THEN TO_DATE(g.end_date, 'DD/MM/YYYY') 
		                            ELSE NULL 
		                       END,
		            updated_by = p_user_name,
		            updated_date = NOW()
		        FROM tb_general_temp g
		        WHERE mse.competition_code = g.competition_code;

		        -- INSERT MASTER nếu chưa tồn tại
		        INSERT INTO ms_competition_events(
		            competition_code,
		            competition_name_vi,
		            competition_name_en,
		            host,
		            status,
		            start_date,
		            end_date,
		            created_by,
		            created_date,
		            updated_by,
		            updated_date
		        )
		        SELECT
		            g.competition_code,
		            g.competition_name_vi,
		            COALESCE(NULLIF(TRIM(g.competition_name_en), ''), g.competition_name_vi),
		            g.host,
		            COALESCE(NULLIF(TRIM(g.status), ''), '1'),
		            CASE WHEN g.start_date IS NOT NULL AND TRIM(g.start_date) <> '' 
		                 THEN TO_DATE(g.start_date, 'DD/MM/YYYY') 
		                 ELSE NULL END,
		            CASE WHEN g.end_date IS NOT NULL AND TRIM(g.end_date) <> '' 
		                 THEN TO_DATE(g.end_date, 'DD/MM/YYYY') 
		                 ELSE NULL END,
		            p_user_name,
		            NOW(),
		            p_user_name,
		            NOW()
		        FROM tb_general_temp g
		        WHERE NOT EXISTS (
		            SELECT 1 
		            FROM ms_competition_events mse 
		            WHERE mse.competition_code = g.competition_code
		        );

		    -- =========================
		    -- NORMAL INSERT MODE
		    -- =========================
		    ELSE

		        INSERT INTO ms_competition_events(
		            competition_code,
		            competition_name_vi,
		            competition_name_en,
		            host,
		            status,
		            start_date,
		            end_date,
		            created_by,
		            created_date,
		            updated_by,
		            updated_date
		        )
		        SELECT
		            competition_code,
		            competition_name_vi,
		            COALESCE(NULLIF(TRIM(competition_name_en), ''), competition_name_vi),
		            host,
		            COALESCE(NULLIF(TRIM(status), ''), '1'),
		            CASE WHEN start_date IS NOT NULL AND TRIM(start_date) <> '' 
		                 THEN TO_DATE(start_date, 'DD/MM/YYYY') 
		                 ELSE NULL END,
		            CASE WHEN end_date IS NOT NULL AND TRIM(end_date) <> '' 
		                 THEN TO_DATE(end_date, 'DD/MM/YYYY') 
		                 ELSE NULL END,
		            p_user_name,
		            NOW(),
		            p_user_name,
		            NOW()
		        FROM tb_general_temp
		        ORDER BY row_number;

		    END IF;

		    -- =========================
		    -- INSERT DETAIL (COMMON)
		    -- =========================

		    -- SportEvent
		    IF (SELECT COUNT(1) FROM tb_sport_event_temp) > 0 THEN
		        INSERT INTO ms_sport_events(
		            competition_code,
		            sport_code,
		            sport_event_code,
		            location_code,
		            created_by,
		            created_date,
		            updated_by,
		            updated_date
		        )
		        SELECT
		            competition_code,
		            sport_code,
		            sport_event_code,
		            location_code,
		            p_user_name,
		            NOW(),
		            p_user_name,
		            NOW()
		        FROM tb_sport_event_temp
		        ORDER BY row_number;
		    END IF;

		    -- Team
		    IF (SELECT COUNT(1) FROM tb_team_temp) > 0 THEN
		        INSERT INTO ms_competition_team_list(
		            competition_code,
		            team_code,
		            created_by,
		            created_date,
		            updated_by,
		            updated_date
		        )
		        SELECT
		            competition_code,
		            team_code,
		            p_user_name,
		            NOW(),
		            p_user_name,
		            NOW()
		        FROM tb_team_temp
		        ORDER BY row_number;
				 -- [HISTORY] Lưu lịch sử system history cho Import
            	INSERT INTO public.sy_journals(module_code, function_code, user_name, data_id, action_code, action_date, ip_address, json_before, json_after)
            	VALUES ('Master', 'MsEvent', p_user_name, NULL, 'IMPORT', CURRENT_TIMESTAMP, p_ip_address, NULL, p_json_data);
		    END IF;
		END IF;
	END IF;
	
	-- Xóa bảng tạm sau khi dùng xong
	DROP TABLE IF EXISTS tb_general_temp;
	DROP TABLE IF EXISTS tb_sport_event_temp;
	DROP TABLE IF EXISTS tb_team_temp;
	
    -- Trả về dòng dữ liệu kết quả
    RETURN NEXT;

EXCEPTION WHEN OTHERS THEN
    -- Bẫy lỗi hệ thống
    p_return_code := 1;
    p_message := SQLERRM; --'Common_msg_AnErrorOccurred';
    p_error_data := '[]'::jsonb;
    RETURN NEXT;
END;
$$;


ALTER FUNCTION public.fn_import_msevent(p_json_data jsonb, p_user_name character varying, p_ip_address character varying) OWNER TO sportevent;

--
-- TOC entry 997 (class 1255 OID 19152)
-- Name: fn_import_mslocation(jsonb, character varying, character varying); Type: FUNCTION; Schema: public; Owner: sportevent
--

CREATE FUNCTION public.fn_import_mslocation(p_json_data jsonb, p_user_name character varying, p_ip_address character varying) RETURNS TABLE(p_return_code integer, p_message text, p_error_data jsonb)
    LANGUAGE plpgsql
    AS $_$
DECLARE
    v_err_master jsonb := NULL;
    v_err_detail jsonb := NULL;
BEGIN
    -- 1. Khởi tạo giá trị mặc định cho các cột trả về
    p_return_code := 0;
    p_message := 'Common_msg_ImportSuccess';
    p_error_data := '[]'::jsonb;

    -- 2. Parse JSON vào bảng tạm
  
	-- Lưu ý: Sử dụng CREATE TEMP TABLE trong function cần cẩn thận với việc gọi nhiều lần trong 1 session
	-- Dùng DROP TABLE IF EXISTS để tránh lỗi "table already exists"
	DROP TABLE IF EXISTS tb_master_temp;
	CREATE TEMP TABLE tb_master_temp AS
	SELECT
		row_number() OVER (ORDER BY (j->>'no')) AS row_number,
		j->>'location_code'    as location_code,
		j->>'location_name_vi' as location_name_vi,
		j->>'location_name_en' as location_name_en,
		j->>'province'         as province,
		j->>'address'          as address,
		j->>'open_time'        as open_time,
		j->>'close_time'       as close_time,
		j->>'location_size'    as location_size,
		j->>'status'           as status,
		j->>'description'      as description,
		CAST('' AS TEXT) AS errordata
	FROM jsonb_array_elements(p_json_data->'sheets'->'Master') AS j;
	
	DROP TABLE IF EXISTS tb_detail_temp;
	CREATE TEMP TABLE tb_detail_temp AS
	SELECT
		row_number() OVER (ORDER BY (j->>'no')) AS row_number,
		j->>'location_code'    as location_code,
		j->>'area_code'        as area_code,
		j->>'area_name_vi'     as area_name_vi,
		j->>'area_name_en'     as area_name_en,
		CAST('' AS TEXT) AS errordata
	FROM jsonb_array_elements(p_json_data->'sheets'->'Detail') AS j;
	
	-- 3. Validate
	IF (SELECT COUNT(1) FROM tb_master_temp) = 0 THEN
		-- validate không có data
		p_return_code := 1;
		p_message := 'Common_msg_MustHaveOneRow,[Master]';
	ELSE
		-- validate nghiệp vụ Master
		UPDATE tb_master_temp ms
		SET 
			errordata = CONCAT_WS('',
				fn_utils_validate_value('location_code', ms.location_code, 50, 'Required', 'IsCode'),
				CASE WHEN msog.id IS NOT NULL THEN ';Common_msg_DataAlreadyExist,location_code' END,
				
				fn_utils_validate_value('location_name_vi', ms.location_name_vi, 255, 'Required'),
				fn_utils_validate_value('location_name_en', ms.location_name_en, 255),
				
				fn_utils_validate_value('province', ms.province, 50, 'Required'),
				CASE WHEN syp.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,province' END,
				
				fn_utils_validate_value('address', ms.address, 500, 'Required'),
				
				fn_utils_validate_value('open_time',  ms.open_time,  5, 'IsTime'),
				fn_utils_validate_value('close_time', ms.close_time, 5, 'IsTime'),
				
				fn_utils_validate_value('location_size', ms.location_size, NULL, 'IsNumber'),
				CASE WHEN ms.location_size IS NOT NULL AND TRIM(ms.location_size) <> ''
				          AND ms.location_size ~ '^-?[0-9]+$'
				          AND CAST(ms.location_size AS BIGINT) <= 0
				     THEN ';Common_msg_MustBeGreaterThan,location_size,0' END,
				
				fn_utils_validate_value('status', ms.status, 1),
				CASE WHEN ms.status IS NOT NULL AND TRIM(ms.status) <> '' AND syst.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,status' END,
				
				fn_utils_validate_value('description', ms.description, 500)
			)
		FROM tb_master_temp mst
		LEFT JOIN ms_locations msog ON mst.location_code = msog.location_code
		LEFT JOIN sy_commons syp  ON syp.value  = mst.province AND syp.type  = 'PROVINCE'
		LEFT JOIN sy_commons syst ON syst.value = mst.status   AND syst.type = 'COMMON_STATUS'
		WHERE ms.row_number = mst.row_number;
		
		SELECT jsonb_agg(t) INTO v_err_master 
		FROM (SELECT * FROM tb_master_temp WHERE errordata <> '') t;

		-- Validate Detail
		IF (SELECT COUNT(1) FROM tb_detail_temp) > 0 THEN
			UPDATE tb_detail_temp ds
			SET errordata = CONCAT_WS('',
				fn_utils_validate_value('location_code', ds.location_code, 50, 'Required', 'IsCode'),
				CASE WHEN mst.location_code IS NULL THEN ';Common_msg_DataNotExistOnSystem,location_code' END,
				
				-- Check area_code không trùng nhau trong cùng 1 location, khác location vẫn cho trùng bình thường
				fn_utils_validate_value('area_code', ds.area_code, 50, 'Required', 'IsCode'),
				CASE WHEN (SELECT COUNT(1) FROM tb_detail_temp chk WHERE chk.location_code = ds.location_code AND chk.area_code = ds.area_code) > 1 THEN ';Common_msg_MustNotOverlapAn,area_code' END,
				
				fn_utils_validate_value('area_name_vi', ds.area_name_vi, 255, 'Required'),
				fn_utils_validate_value('area_name_en', ds.area_name_en, 255)
			)
			FROM tb_detail_temp dst
			LEFT JOIN tb_master_temp mst ON dst.location_code = mst.location_code
			WHERE ds.row_number = dst.row_number;
			
			SELECT jsonb_agg(t) INTO v_err_detail 
			FROM (SELECT * FROM tb_detail_temp WHERE errordata <> '') t;
		END IF;
	END IF;
	
	-- 4. Kiểm tra nếu có lỗi
	IF p_return_code = 0 THEN
		-- trả lỗi
		IF v_err_master IS NOT NULL OR v_err_detail IS NOT NULL THEN
			p_return_code := 1;
			p_message := 'Common_msg_ImportInvalid';
			p_error_data := jsonb_strip_nulls(jsonb_build_object(
				'Master', v_err_master,
				'Detail', v_err_detail
			));
		-- không lỗi thực hiện insert
		ELSE 
			-- INSERT Master
			INSERT INTO ms_locations(
				location_code,
				location_name_vi,
				location_name_en,
				province,
				address,
				open_time,
				close_time,
				location_size,
				status,
				description,
				created_by,
				created_date,
				updated_by,
				updated_date
			) SELECT
				location_code,
				location_name_vi,
				COALESCE(NULLIF(TRIM(location_name_en), ''), location_name_vi),
				province,
				address,
				CASE WHEN open_time  IS NOT NULL AND TRIM(open_time)  <> '' THEN CAST(open_time  AS TIME) ELSE NULL END,
				CASE WHEN close_time IS NOT NULL AND TRIM(close_time) <> '' THEN CAST(close_time AS TIME) ELSE NULL END,
				CASE WHEN location_size IS NOT NULL AND TRIM(location_size) <> '' THEN CAST(location_size AS INTEGER) ELSE NULL END,
				COALESCE(NULLIF(TRIM(status), ''), '1'),
				NULLIF(TRIM(description), ''),
				p_user_name,
				NOW(),
				p_user_name,
				NOW()
			FROM tb_master_temp
			ORDER BY row_number;

			-- INSERT Detail
			IF (SELECT COUNT(1) FROM tb_detail_temp) > 0 THEN
				INSERT INTO ms_location_detail(
					location_code,
					area_code,
					area_name_vi,
					area_name_en,
					created_by,
					created_date,
					updated_by,
					updated_date
				) SELECT
					location_code,
					area_code,
					area_name_vi,
					COALESCE(NULLIF(TRIM(area_name_en), ''), area_name_vi),
					p_user_name,
					NOW(),
					p_user_name,
					NOW()
				FROM tb_detail_temp
				ORDER BY row_number;
				-- [HISTORY] Lưu lịch sử system history cho Import
            	INSERT INTO public.sy_journals(module_code, function_code, user_name, data_id, action_code, action_date, ip_address, json_before, json_after)
            	VALUES ('Master', 'MsLocation', p_user_name, NULL, 'IMPORT', CURRENT_TIMESTAMP, p_ip_address, NULL, p_json_data);
			END IF;
		END IF;
	END IF;
	
	-- Xóa bảng tạm sau khi dùng xong
	DROP TABLE IF EXISTS tb_master_temp;
	DROP TABLE IF EXISTS tb_detail_temp;
	
    -- Trả về dòng dữ liệu kết quả
    RETURN NEXT;

EXCEPTION WHEN OTHERS THEN
    -- Bẫy lỗi hệ thống
    p_return_code := 1;
    p_message := SQLERRM; --'Common_msg_AnErrorOccurred';
    p_error_data := '[]'::jsonb;
    RETURN NEXT;
END;
$_$;


ALTER FUNCTION public.fn_import_mslocation(p_json_data jsonb, p_user_name character varying, p_ip_address character varying) OWNER TO sportevent;

--
-- TOC entry 992 (class 1255 OID 18588)
-- Name: fn_import_mssponsors(jsonb, character varying, character varying); Type: FUNCTION; Schema: public; Owner: sportevent
--

CREATE FUNCTION public.fn_import_mssponsors(p_json_data jsonb, p_user_name character varying, p_ip_address character varying) RETURNS TABLE(p_return_code integer, p_message text, p_error_data jsonb)
    LANGUAGE plpgsql
    AS $_$
DECLARE
    v_err_master jsonb := '[]'::jsonb;
BEGIN
	-- function name: import nhà tài trợ
	-- create by: tmtam - 01/04/2026
	-- last modify by: fix bugs - 23/04/2026
	
    -- 1. Khởi tạo giá trị mặc định cho các cột trả về
    p_return_code := 0;
    p_message := 'Common_msg_ImportSuccess';
    p_error_data := '[]'::jsonb;
    -- 2. Parse JSON vào bảng tạm
	DROP TABLE IF EXISTS tb_master_temp;
	CREATE TEMP TABLE tb_master_temp AS
	SELECT
		row_number() OVER (ORDER BY (j->>'no')) AS row_number,
		j->>'sponsor_code' as sponsor_code,
		j->>'sponsor_name_vi' as sponsor_name_vi,
		j->>'sponsor_name_en' as sponsor_name_en,
		
		-- [FIX Bug 3] Xử lý ngày: nếu là số Excel serial → convert sang DD/MM/YYYY
		CASE 
			WHEN j->>'effective_date_from' ~ '^\d+\.?\d*$' 
			THEN TO_CHAR(DATE '1899-12-30' + FLOOR((j->>'effective_date_from')::NUMERIC)::INTEGER, 'DD/MM/YYYY')
			ELSE j->>'effective_date_from'
		END as effective_date_from,
		
		CASE 
			WHEN j->>'effective_date_to' ~ '^\d+\.?\d*$' 
			THEN TO_CHAR(DATE '1899-12-30' + FLOOR((j->>'effective_date_to')::NUMERIC)::INTEGER, 'DD/MM/YYYY')
			ELSE j->>'effective_date_to'
		END as effective_date_to,
		
		-- [FIX Bug 1] Status rỗng → default '1'
		COALESCE(NULLIF(TRIM(j->>'status'), ''), '1') as status,
		
		j->>'description' as description,
		CAST('' AS TEXT) AS errordata
	FROM jsonb_array_elements(p_json_data->'sheets'->'Data') AS j;
	
	-- 3. Validate
	IF (SELECT COUNT(1) FROM tb_master_temp) = 0 THEN
		p_return_code := 1;
		p_message := 'Common_msg_MustHaveOneRow,[Data]';
	ELSE
		UPDATE tb_master_temp ms
		SET 
			errordata = CONCAT_WS('',
				fn_utils_validate_value('sponsor_code', ms.sponsor_code, 50, 'Required', 'IsCode'),
				CASE WHEN msps.id IS NOT NULL THEN ';Common_msg_DataAlreadyExist,sponsor_code' END,
				
				fn_utils_validate_value('sponsor_name_vi', ms.sponsor_name_vi, 255, 'Required'),
				fn_utils_validate_value('sponsor_name_en', ms.sponsor_name_en, 255, 'Required'),
				
				fn_utils_validate_value('effective_date_from', ms.effective_date_from, 10, 'Required', 'IsDate'),
				fn_utils_validate_value('effective_date_to', ms.effective_date_to, 10, 'Required', 'IsDate'),
				
				-- [FIX Bug 2] Guard check trước TO_DATE
				CASE 
					WHEN ms.effective_date_from ~ '^\d{2}/\d{2}/\d{4}$' 
						 AND ms.effective_date_to ~ '^\d{2}/\d{2}/\d{4}$'
						 AND TO_DATE(ms.effective_date_from, 'DD/MM/YYYY') > TO_DATE(ms.effective_date_to, 'DD/MM/YYYY') 
					THEN ';Common_msg_MustBeLessOrEqual,effective_date_from,effective_date_to' 
				END,
				
				fn_utils_validate_value('status', ms.status, 1, 'Required'),
				CASE WHEN syst.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,status' END,
				
				fn_utils_validate_value('description', ms.description, 500)
			)
		FROM tb_master_temp mst
		LEFT JOIN ms_sponsors msps ON mst.sponsor_code = msps.sponsor_code
		LEFT JOIN sy_commons syst ON syst.value = mst.status AND syst.type = 'COMMON_STATUS'
		WHERE ms.row_number = mst.row_number;
		
		SELECT jsonb_agg(t) INTO v_err_master 
		FROM (SELECT * FROM tb_master_temp WHERE errordata <> '') t;
	END IF;
	
	-- 4. Kiểm tra nếu có lỗi
	IF p_return_code = 0 THEN
		IF v_err_master IS NOT NULL THEN
			p_return_code := 1;
			p_message := 'Common_msg_ImportInvalid';
			p_error_data := jsonb_build_object('Sheet1', v_err_master);
		ELSE 
			INSERT INTO ms_sponsors(
				logo_file,
				sponsor_code,
				sponsor_name_vi,
				sponsor_name_en,
				effective_date_from,
				effective_date_to,
				status,
				image_file_1,
				image_file_2,
				image_file_3,
				created_by,
				created_date,
				updated_by,
				updated_date
			) SELECT
				'',
				sponsor_code,
				sponsor_name_vi,
				sponsor_name_en,
				TO_DATE(effective_date_from, 'DD/MM/YYYY'),
				TO_DATE(effective_date_to, 'DD/MM/YYYY'),
				status,
				'',
				'',
				'',
				p_user_name,
				NOW(),
				p_user_name,
				NOW()
			FROM tb_master_temp
			ORDER BY row_number;
			-- [HISTORY] Lưu lịch sử system history cho Import
            INSERT INTO public.sy_journals(module_code, function_code, user_name, data_id, action_code, action_date, ip_address, json_before, json_after)
            VALUES ('Master', 'MsSponsors', p_user_name, NULL, 'IMPORT', CURRENT_TIMESTAMP, p_ip_address, NULL, p_json_data);
		END IF;
	END IF;
	
	DROP TABLE IF EXISTS tb_master_temp;
	
    RETURN NEXT;
EXCEPTION WHEN OTHERS THEN
    p_return_code := 1;
    p_message := SQLERRM;
    p_error_data := '[]'::jsonb;
    RETURN NEXT;
END;
$_$;


ALTER FUNCTION public.fn_import_mssponsors(p_json_data jsonb, p_user_name character varying, p_ip_address character varying) OWNER TO sportevent;

--
-- TOC entry 965 (class 1255 OID 17924)
-- Name: fn_import_mssportdetail(jsonb, character varying, character varying); Type: FUNCTION; Schema: public; Owner: sportevent
--

CREATE FUNCTION public.fn_import_mssportdetail(p_json_data jsonb, p_user_name character varying, p_ip_address character varying) RETURNS TABLE(p_return_code integer, p_message text, p_error_data jsonb)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_err_master jsonb := '[]'::jsonb;
BEGIN
	-- function name: import nội dung thi đấu
	-- create by: tmtam - 01/04/2026
	-- last modify by: Codex - 24/04/2026

    p_return_code := 0;
    p_message := 'Common_msg_ImportSuccess';
    p_error_data := '[]'::jsonb;

    DROP TABLE IF EXISTS tb_master_temp;
    CREATE TEMP TABLE tb_master_temp AS
    SELECT
        row_number() OVER (ORDER BY (j->>'no')) AS row_number,
        j->>'sport_event_code' AS sport_event_code,
        j->>'sport_event_name_vi' AS sport_event_name_vi,
        j->>'sport_event_name_en' AS sport_event_name_en,
        j->>'sport_code' AS sport_code,
        j->>'status' AS status,
        j->>'description' AS description,
        CAST('' AS TEXT) AS errordata
    FROM jsonb_array_elements(p_json_data->'sheets'->'Data') AS j;

    -- mặc định Tên nội dung (EN) bằng Tên nội dung (VI) nếu file import không nhập
    UPDATE tb_master_temp
    SET sport_event_name_en = COALESCE(NULLIF(BTRIM(sport_event_name_en), ''), sport_event_name_vi);

    -- mặc định trạng thái là Hoạt động nếu file import không nhập
    UPDATE tb_master_temp
    SET status = COALESCE(NULLIF(BTRIM(status), ''), '1');

    IF (SELECT COUNT(1) FROM tb_master_temp) = 0 THEN
        p_return_code := 1;
        p_message := 'Common_msg_MustHaveOneRow,[Data]';
    ELSE
        UPDATE tb_master_temp ms
        SET
            errordata = CONCAT_WS('',
                fn_utils_validate_value('sport_event_code', ms.sport_event_code, 50, 'Required', 'IsCode'),
                CASE WHEN msdog.id IS NOT NULL THEN ';Common_msg_DataAlreadyExist,sport_event_code' END,

                fn_utils_validate_value('sport_event_name_vi', ms.sport_event_name_vi, 255, 'Required'),
                fn_utils_validate_value('sport_event_name_en', ms.sport_event_name_en, 255),

                fn_utils_validate_value('sport_code', ms.sport_code, 255, 'Required'),
                CASE WHEN msp.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,sport_code' END,

                fn_utils_validate_value('status', ms.status, 1),
                CASE WHEN syst.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,status' END,

                fn_utils_validate_value('description', ms.description, 500)
            )
        FROM tb_master_temp mst
        LEFT JOIN ms_sport_detail msdog ON mst.sport_event_code = msdog.sport_event_code
        LEFT JOIN ms_sports msp ON msp.sport_code = mst.sport_code
        LEFT JOIN sy_commons syst ON syst.value = mst.status AND syst.type = 'COMMON_STATUS'
        WHERE ms.row_number = mst.row_number;

        SELECT jsonb_agg(t) INTO v_err_master
        FROM (SELECT * FROM tb_master_temp WHERE errordata <> '') t;
    END IF;

    IF p_return_code = 0 THEN
        IF v_err_master IS NOT NULL THEN
            p_return_code := 1;
            p_message := 'Common_msg_ImportInvalid';
            p_error_data := jsonb_build_object('Sheet1', v_err_master);
        ELSE
            INSERT INTO ms_sport_detail(
                sport_event_code,
                sport_event_name_vi,
                sport_event_name_en,
                sport_code,
                status,
                description,
                created_by,
                created_date,
                updated_by,
                updated_date
            ) SELECT
                sport_event_code,
                sport_event_name_vi,
                sport_event_name_en,
                sport_code,
                status,
                description,
                p_user_name,
                NOW(),
                p_user_name,
                NOW()
            FROM tb_master_temp
            ORDER BY row_number;
			-- [HISTORY] Lưu lịch sử system history cho Import
            INSERT INTO public.sy_journals(module_code, function_code, user_name, data_id, action_code, action_date, ip_address, json_before, json_after)
            VALUES ('Master', 'MsSportDetail', p_user_name, NULL, 'IMPORT', CURRENT_TIMESTAMP, p_ip_address, NULL, p_json_data);
        END IF;
    END IF;

    DROP TABLE IF EXISTS tb_master_temp;

    RETURN NEXT;

EXCEPTION WHEN OTHERS THEN
    p_return_code := 1;
    p_message := SQLERRM;
    p_error_data := '[]'::jsonb;
    RETURN NEXT;
END;
$$;


ALTER FUNCTION public.fn_import_mssportdetail(p_json_data jsonb, p_user_name character varying, p_ip_address character varying) OWNER TO sportevent;

--
-- TOC entry 841 (class 1255 OID 17297)
-- Name: fn_import_mssports(jsonb, character varying, character varying); Type: FUNCTION; Schema: public; Owner: sportevent
--

CREATE FUNCTION public.fn_import_mssports(p_json_data jsonb, p_user_name character varying, p_ip_address character varying) RETURNS TABLE(p_return_code integer, p_message text, p_error_data jsonb)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_err_master jsonb := '[]'::jsonb;
BEGIN
	-- function name: import môn thi đấu
	-- create by: tmtam - 01/04/2026
	-- last modify by: xxx - xx/xx/xxxx
	
    -- 1. Khởi tạo giá trị mặc định cho các cột trả về
    p_return_code := 0;
    p_message := 'Common_msg_ImportSuccess';
    p_error_data := '[]'::jsonb;
    -- 2. Parse JSON vào bảng tạm
  
	-- Lưu ý: Sử dụng CREATE TEMP TABLE trong function cần cẩn thận với việc gọi nhiều lần trong 1 session
	-- Dùng DROP TABLE IF EXISTS để tránh lỗi "table already exists"
	DROP TABLE IF EXISTS tb_master_temp;
	CREATE TEMP TABLE tb_master_temp AS
	SELECT
		row_number() OVER (ORDER BY (j->>'no')) AS row_number,
		j->>'sport_code' as sport_code,
		j->>'sport_name_vi' as sport_name_vi,
		j->>'sport_name_en' as sport_name_en,
		
		-- UPDATE: Trạng thái nếu không nhập (rỗng hoặc null) thì mặc định gán là '1' (Hoạt động)
		COALESCE(NULLIF(TRIM(j->>'status'), ''), '1') as status,
		
		j->>'description' as description,
		CAST('' AS TEXT) AS errordata
	FROM jsonb_array_elements(p_json_data->'sheets'->'Data') AS j;
	
	-- 3. Validate
	IF (SELECT COUNT(1) FROM tb_master_temp) = 0 THEN
		-- validate không có data
		p_return_code := 1;
		p_message := 'Common_msg_MustHaveOneRow,[Data]';
	ELSE
		-- validate nghiệp vụ
		UPDATE tb_master_temp ms
		SET 
			errordata = CONCAT_WS('',
				fn_utils_validate_value('sport_code', ms.sport_code, 50, 'Required', 'IsCode'),
				CASE WHEN msog.id IS NOT NULL THEN ';Common_msg_DataAlreadyExist,sport_code' END,
				
				fn_utils_validate_value('sport_name_vi', ms.sport_name_vi, 255, 'Required'),
				fn_utils_validate_value('sport_name_en', ms.sport_name_en, 255),
				
				fn_utils_validate_value('status', ms.status, 1, 'Required'),
				CASE WHEN syst.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,status' END,
				
				fn_utils_validate_value('description', ms.description, 500)
			)
		FROM tb_master_temp mst
		LEFT JOIN ms_sports msog ON mst.sport_code = msog.sport_code
		LEFT JOIN sy_commons syst ON syst.value = mst.status AND syst.type = 'COMMON_STATUS'
		WHERE ms.row_number = mst.row_number;
		
		SELECT jsonb_agg(t) INTO v_err_master 
		FROM (SELECT * FROM tb_master_temp WHERE errordata <> '') t;
	END IF;
	
	-- 4. Kiểm tra nếu có lỗi
	IF p_return_code = 0 THEN
		-- trả lỗi
		IF v_err_master IS NOT NULL THEN
			p_return_code := 1;
			p_message := 'Common_msg_ImportInvalid';
			p_error_data := jsonb_build_object('Sheet1', v_err_master);
		-- không lỗi thực hiện insert
		ELSE 
			INSERT INTO ms_sports(
				sport_code,
				sport_name_vi,
				sport_name_en,
				logo,           -- Bổ sung thêm trường logo
				status,
				description,
				created_by,
				created_date,
				updated_by,
				updated_date
			) SELECT
				sport_code,
				sport_name_vi,
				COALESCE(NULLIF(TRIM(sport_name_en), ''), sport_name_vi),
				'',             -- Chèn mặc định giá trị rỗng cho logo
				status,
				description,
				p_user_name,
				NOW(),
				p_user_name,
				NOW()
			FROM tb_master_temp
			ORDER BY row_number;
			-- [HISTORY] Lưu lịch sử system history cho Import
            INSERT INTO public.sy_journals(module_code, function_code, user_name, data_id, action_code, action_date, ip_address, json_before, json_after)
            VALUES ('Master', 'MsSports', p_user_name, NULL, 'IMPORT', CURRENT_TIMESTAMP, p_ip_address, NULL, p_json_data);
		END IF;
	END IF;
	
	-- Xóa bảng tạm sau khi dùng xong (tùy chọn vì có ON COMMIT DROP nếu bọc trong transaction)
	DROP TABLE IF EXISTS tb_master_temp;
	
    -- Trả về dòng dữ liệu kết quả
    RETURN NEXT;
EXCEPTION WHEN OTHERS THEN
    -- Bẫy lỗi hệ thống
    p_return_code := 1;
    p_message := SQLERRM; --'Common_msg_AnErrorOccurred';
    p_error_data := '[]'::jsonb;
    RETURN NEXT;
END;
$$;


ALTER FUNCTION public.fn_import_mssports(p_json_data jsonb, p_user_name character varying, p_ip_address character varying) OWNER TO sportevent;

--
-- TOC entry 849 (class 1255 OID 19526)
-- Name: fn_import_msteams(jsonb, character varying, character varying); Type: FUNCTION; Schema: public; Owner: sportevent
--

CREATE FUNCTION public.fn_import_msteams(p_json_data jsonb, p_user_name character varying, p_ip_address character varying) RETURNS TABLE(p_return_code integer, p_message text, p_error_data jsonb)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_err_master   jsonb := NULL;
    v_err_coachs   jsonb := NULL;
    v_err_athletes jsonb := NULL;
BEGIN
	-- function name: import thông tin đội tuyển
	-- create by: lthngoc - 03/04/2026
	-- last modify by: xxx - xx/xx/xxxx
	
    -- 1. Khởi tạo mặc định
    p_return_code := 0;
    p_message := 'Common_msg_ImportSuccess';
    p_error_data := '[]'::jsonb;

    -- 2. Parse JSON vào bảng tạm
    DROP TABLE IF EXISTS tb_master_temp;
    CREATE TEMP TABLE tb_master_temp AS
    SELECT
        row_number() OVER (ORDER BY (j->>'no')) AS row_number,
        j->>'team_code'          AS team_code,
        j->>'team_name_vi'       AS team_name_vi,
        j->>'team_name_en'       AS team_name_en,
        j->>'sports_delegation'  AS sports_delegation,
        j->>'sport_code'         AS sport_code,
        j->>'team_size'          AS team_size,
        j->>'regist_date'        AS regist_date,
        j->>'status'             AS status,
        j->>'description'        AS description,
        CAST('' AS TEXT)         AS errordata
    FROM jsonb_array_elements(COALESCE(p_json_data->'sheets'->'Data', '[]'::jsonb)) AS j;

    DROP TABLE IF EXISTS tb_coachs_temp;
    CREATE TEMP TABLE tb_coachs_temp AS
    SELECT
        row_number() OVER (ORDER BY (j->>'no')) AS row_number,
        j->>'team_code'           AS team_code,
        j->>'emp_coach_code'      AS emp_coach_code,
        j->>'emp_coach_role'      AS emp_coach_role,
        j->>'effective_date_from' AS effective_date_from,
        j->>'effective_date_to'   AS effective_date_to,
        CAST('' AS TEXT)          AS errordata
    FROM jsonb_array_elements(COALESCE(p_json_data->'sheets'->'Coachs', '[]'::jsonb)) AS j;

    DROP TABLE IF EXISTS tb_athletes_temp;
    CREATE TEMP TABLE tb_athletes_temp AS
    SELECT
        row_number() OVER (ORDER BY (j->>'no')) AS row_number,
        j->>'team_code'             AS team_code,
        j->>'emp_athlete_code'      AS emp_athlete_code,
        j->>'effective_date_from'   AS effective_date_from,
        j->>'effective_date_to'     AS effective_date_to,
        CAST('' AS TEXT)            AS errordata
    FROM jsonb_array_elements(COALESCE(p_json_data->'sheets'->'Atheles', '[]'::jsonb)) AS j;

    -- 3. Validate
    IF (SELECT COUNT(1) FROM tb_master_temp) = 0 THEN
        p_return_code := 1;
        p_message := 'Common_msg_MustHaveOneRow,[Data]';	
    ELSE
        -- validate data
        UPDATE tb_master_temp ms
        SET errordata = CONCAT_WS('',
            fn_utils_validate_value('team_code', ms.team_code, 50, 'Required', 'IsCode'),
            CASE WHEN mst_ex.id IS NOT NULL THEN ';Common_msg_DataAlreadyExist,team_code' END,
            CASE WHEN dup.cnt > 1 THEN ';Common_msg_DataDuplicate,team_code' END,

            fn_utils_validate_value('team_name_vi', ms.team_name_vi, 255, 'Required'),
            fn_utils_validate_value('team_name_en', ms.team_name_en, 255),
            fn_utils_validate_value('sports_delegation', ms.sports_delegation, 255, 'Required'),

            fn_utils_validate_value('sport_code', ms.sport_code, 50, 'Required', 'IsCode'),
            CASE WHEN ms.sport_code IS NOT NULL AND sp.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,sport_code' END,
			
			fn_utils_validate_value('regist_date', ms.regist_date, 50, 'IsDate'),

            CASE WHEN ms.status IS NOT NULL AND TRIM(ms.status) <> '' AND syst_status.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,status' END,
				
			fn_utils_validate_value('description', ms.description, 500)
        )
        FROM tb_master_temp mst
        LEFT JOIN ms_teams mst_ex ON mst.team_code = mst_ex.team_code
        LEFT JOIN ms_sports sp ON mst.sport_code = sp.sport_code AND COALESCE(sp.status, '1') = '1'
        LEFT JOIN sy_commons syst_status ON syst_status.value = mst.status AND syst_status.type = 'COMMON_STATUS'
        LEFT JOIN ( SELECT team_code, COUNT(1) AS cnt FROM tb_master_temp GROUP BY team_code ) dup ON mst.team_code = dup.team_code
        WHERE ms.row_number = mst.row_number;
		
		SELECT jsonb_agg(t) INTO v_err_master
            FROM (
                SELECT *
                FROM tb_master_temp
                WHERE COALESCE(errordata, '') <> ''
                ORDER BY row_number
            ) t;
    END IF;
	
	IF (SELECT COUNT(1) FROM tb_coachs_temp) = 0 THEN
	    p_return_code := 1;
	    p_message := 'Common_msg_MustHaveOneRow,[Coachs]';
	ELSE
		UPDATE tb_coachs_temp cs
            SET errordata = CONCAT_WS('',
                fn_utils_validate_value('team_code', cs.team_code, 50, 'Required', 'IsCode'),
                CASE WHEN mst.team_code IS NULL THEN ';Common_msg_DataNotExistOnSystem,team_code' END,

                fn_utils_validate_value('emp_coach_code', cs.emp_coach_code, 50, 'Required', 'IsCode'),
				CASE WHEN me.employee_code IS NOT NULL AND sy.id IS NULL THEN ';MsTeams_msg_emp_coach_code,emp_coach_code' END,
				
                fn_utils_validate_value('emp_coach_role', cs.emp_coach_role, 50, 'Required', 'IsCode'),
				CASE WHEN cst.emp_coach_role IS NOT NULL AND syr.id IS NULL THEN ';MsTeams_msg_emp_coach_role,emp_coach_role' END,
				
				fn_utils_validate_value('effective_date_from', cs.effective_date_from, 50, 'Required', 'IsDate'),
			    fn_utils_validate_value('effective_date_to', cs.effective_date_to, 50, 'IsDate'),
			    		
				-- dates
				fn_utils_validate_value('effective_date_from', cs.effective_date_from, 10, 'Required', 'IsDate'),
				fn_utils_validate_value('effective_date_to', cs.effective_date_to, 10, 'IsDate'),
				CASE WHEN cs.effective_date_from IS NOT NULL AND TRIM(cs.effective_date_from) <> ''
				      AND cs.effective_date_to IS NOT NULL AND TRIM(cs.effective_date_to) <> ''
				      AND TO_DATE(cs.effective_date_from, 'DD/MM/YYYY') > TO_DATE(cs.effective_date_to, 'DD/MM/YYYY')
				     THEN ';Common_msg_MustBeLessOrEqual,effective_date_from,effective_date_to' END,
					 
                CASE WHEN dup.cnt > 1 THEN ';Common_msg_AlreadyExists,emp_coach_code' END
            )
            FROM tb_coachs_temp cst
            LEFT JOIN tb_master_temp mst ON cst.team_code = mst.team_code
            LEFT JOIN ms_employees me ON UPPER(TRIM(cst.emp_coach_code)) = UPPER(TRIM(me.employee_code))
			LEFT JOIN sy_commons sy ON sy.value = me.employee_type AND sy.type = 'EMPLOYEE_TYPE' AND sy.value = 'COA'
			LEFT JOIN sy_commons syr ON syr.value = cst.emp_coach_role AND syr.type = 'COACH_ROLE'
            LEFT JOIN ( SELECT team_code, emp_coach_code, COUNT(1) AS cnt FROM tb_coachs_temp GROUP BY team_code, emp_coach_code ) dup ON cst.team_code = dup.team_code AND cst.emp_coach_code = dup.emp_coach_code
            WHERE cs.row_number = cst.row_number;

            SELECT jsonb_agg(t) INTO v_err_coachs
            FROM (
                SELECT *
                FROM tb_coachs_temp
                WHERE COALESCE(errordata, '') <> ''
                ORDER BY row_number
            ) t;
	END IF;
	
	IF (SELECT COUNT(1) FROM tb_athletes_temp) = 0 THEN
	    p_return_code := 1;
	    p_message := 'Common_msg_MustHaveOneRow,[Atheles]';
	ELSE
		UPDATE tb_athletes_temp ats
            SET errordata = CONCAT_WS('',
                fn_utils_validate_value('team_code', ats.team_code, 50, 'Required', 'IsCode'),
                CASE WHEN mst.team_code IS NULL THEN ';Common_msg_DataNotExistOnSystem,team_code' END,

                fn_utils_validate_value('emp_athlete_code', ats.emp_athlete_code, 20, 'Required', 'IsCode'),
				CASE WHEN me.employee_code IS NOT NULL AND sy.id IS NULL THEN ';MsTeams_msg_emp_athlete_code,emp_athlete_code' END,

                fn_utils_validate_value('effective_date_from', ats.effective_date_from, 50, 'Required', 'IsDate'),
			    fn_utils_validate_value('effective_date_to', ats.effective_date_to, 50, 'IsDate'),
			
			  	-- dates
				fn_utils_validate_value('effective_date_from', ats.effective_date_from, 10, 'Required', 'IsDate'),
				fn_utils_validate_value('effective_date_to', ats.effective_date_to, 10, 'IsDate'),
				CASE WHEN ats.effective_date_from IS NOT NULL AND TRIM(ats.effective_date_from) <> ''
				      AND ats.effective_date_to IS NOT NULL AND TRIM(ats.effective_date_to) <> ''
				      AND TO_DATE(ats.effective_date_from, 'DD/MM/YYYY') > TO_DATE(ats.effective_date_to, 'DD/MM/YYYY')
				     THEN ';Common_msg_MustBeLessOrEqual,effective_date_from,effective_date_to' END,
					 
				CASE WHEN dup.cnt > 1 THEN ';Common_msg_AlreadyExists,emp_athlete_code' END
            )
            FROM tb_athletes_temp att
            LEFT JOIN tb_master_temp mst  ON att.team_code = mst.team_code
			LEFT JOIN ms_employees me ON UPPER(TRIM(att.emp_athlete_code)) = UPPER(TRIM(me.employee_code))
			LEFT JOIN sy_commons sy ON sy.value = me.employee_type AND sy.type = 'EMPLOYEE_TYPE' AND sy.value = 'ATH'
			LEFT JOIN sy_commons syc ON me.position_code = syc.value AND syc.type = 'ATHLETE_POSITION'
			LEFT JOIN sy_commons sycs ON me.employee_status = sycs.value AND sycs.type = 'EMPLOYEE_STATUS'
            LEFT JOIN (
                SELECT team_code, emp_athlete_code, COUNT(1) AS cnt
                FROM tb_athletes_temp
                GROUP BY team_code, emp_athlete_code
            ) dup
                ON att.team_code = dup.team_code
               AND att.emp_athlete_code = dup.emp_athlete_code
            WHERE ats.row_number = att.row_number;

            SELECT jsonb_agg(t) INTO v_err_athletes
            FROM (
                SELECT *
                FROM tb_athletes_temp
                WHERE COALESCE(errordata, '') <> ''
                ORDER BY row_number
            ) t;
	END IF;
	
    -- 4. Kiểm tra lỗi
    IF p_return_code = 0 THEN
        IF v_err_master IS NOT NULL OR v_err_coachs IS NOT NULL OR v_err_athletes IS NOT NULL THEN
            p_return_code := 1;
            p_message := 'Common_msg_ImportInvalid';
            p_error_data := jsonb_strip_nulls(
                jsonb_build_object(
                    'Data', v_err_master,
                    'Coachs', v_err_coachs,
                    'Atheles', v_err_athletes
                )
            );
        ELSE
            -- insert master
			INSERT INTO ms_teams (
				team_code,
				team_name_vi,
				team_name_en,
				sports_delegation,
				sport_code,
				team_size,
				regist_date,
				status,
				description,
				created_by,
				created_date,
				updated_by,
				updated_date
			)
			SELECT
				m.team_code,
				m.team_name_vi,
				COALESCE(NULLIF(TRIM(m.team_name_en), ''), m.team_name_vi),
				m.sports_delegation,
				m.sport_code,
				COALESCE(
					CASE
						WHEN m.team_size IS NOT NULL AND TRIM(m.team_size) <> '' THEN CAST(m.team_size AS INTEGER)
						ELSE NULL
					END,
					ath.athlete_count,
					0
				) AS team_size,
				CASE
					WHEN m.regist_date IS NOT NULL AND TRIM(m.regist_date) <> ''
					THEN to_date(m.regist_date, 'DD/MM/YYYY')
					ELSE NULL
				END,
				COALESCE(NULLIF(TRIM(m.status), ''), '1'),
				NULLIF(TRIM(m.description), ''),
				p_user_name,
				NOW(),
				p_user_name,
				NOW()
			FROM tb_master_temp m
			LEFT JOIN (
				SELECT a.team_code, COUNT(1) AS athlete_count
				FROM tb_athletes_temp a
				GROUP BY a.team_code
			) ath
				ON m.team_code = ath.team_code
			ORDER BY m.row_number;

            -- insert coachs
            IF (SELECT COUNT(1) FROM tb_coachs_temp) > 0 THEN
                INSERT INTO ms_team_coachs (
                    team_code,
                    emp_coach_code,
                    emp_coach_role,
                    effective_date_from,
                    effective_date_to,
                    created_by,
                    created_date,
                    updated_by,
                    updated_date
                )
				SELECT
					c.team_code,
					c.emp_coach_code,
					NULLIF(TRIM(c.emp_coach_role), ''),
					to_date(c.effective_date_from, 'DD/MM/YYYY'),
					to_date(NULLIF(TRIM(c.effective_date_to), ''), 'DD/MM/YYYY'),
					p_user_name,
					NOW(),
					p_user_name,
					NOW()
				FROM tb_coachs_temp c
				ORDER BY c.row_number;
            END IF;

            -- insert athletes
            IF (SELECT COUNT(1) FROM tb_athletes_temp) > 0 THEN
                INSERT INTO ms_team_athletes (
                    team_code,
                    emp_athlete_code,
					emp_athlete_position,
                    effective_date_from,
                    effective_date_to,
                    created_by,
                    created_date,
                    updated_by,
                    updated_date
                )
                SELECT
					a.team_code,
					a.emp_athlete_code,
					me.position_code,
					to_date(a.effective_date_from, 'DD/MM/YYYY'),
					to_date(NULLIF(TRIM(a.effective_date_to), ''), 'DD/MM/YYYY'),
					p_user_name,
					NOW(),
					p_user_name,
					NOW()
				FROM tb_athletes_temp a
				LEFT JOIN ms_employees me ON UPPER(TRIM(a.emp_athlete_code)) = UPPER(TRIM(me.employee_code))
				ORDER BY a.row_number;
				-- [HISTORY] Lưu lịch sử system history cho Import
            	INSERT INTO public.sy_journals(module_code, function_code, user_name, data_id, action_code, action_date, ip_address, json_before, json_after)
            	VALUES ('Master', 'MsTeams', p_user_name, NULL, 'IMPORT', CURRENT_TIMESTAMP, p_ip_address, NULL, p_json_data);
            END IF;
        END IF;
    END IF;

    -- xóa bảng tạm
    DROP TABLE IF EXISTS tb_master_temp;
    DROP TABLE IF EXISTS tb_coachs_temp;
    DROP TABLE IF EXISTS tb_athletes_temp;

    RETURN NEXT;

EXCEPTION WHEN OTHERS THEN
    p_return_code := 1;
    p_message := SQLERRM;
    p_error_data := '[]'::jsonb;
    RETURN NEXT;
END;
$$;


ALTER FUNCTION public.fn_import_msteams(p_json_data jsonb, p_user_name character varying, p_ip_address character varying) OWNER TO sportevent;

--
-- TOC entry 840 (class 1255 OID 18149)
-- Name: fn_import_msticketcategory(jsonb, character varying, character varying); Type: FUNCTION; Schema: public; Owner: sportevent
--

CREATE FUNCTION public.fn_import_msticketcategory(p_json_data jsonb, p_user_name character varying, p_ip_address character varying) RETURNS TABLE(p_return_code integer, p_message text, p_error_data jsonb)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_err_master jsonb := '[]'::jsonb;
BEGIN
	-- function name: import hạng mục vé
	-- create by: tmtam - 01/04/2026
	-- last modify by: xxx - xx/xx/xxxx
	
    -- 1. Khởi tạo giá trị mặc định cho các cột trả về
    p_return_code := 0;
    p_message := 'Common_msg_ImportSuccess';
    p_error_data := '[]'::jsonb;

    -- 2. Parse JSON vào bảng tạm (GIỮ NGUYÊN BẢN GỐC - KHÔNG ĐẮP DATA Ở ĐÂY)
    DROP TABLE IF EXISTS tb_master_temp;
    CREATE TEMP TABLE tb_master_temp AS
    SELECT
        row_number() OVER (ORDER BY (j->>'no')) AS row_number,
        j->>'category_code' as category_code,
        j->>'category_name_vi' as category_name_vi,
        j->>'category_name_en' as category_name_en,
        j->>'competition_code' as competition_code,
        j->>'status' as status,
        j->>'description' as description,
        CAST('' AS TEXT) AS errordata
    FROM jsonb_array_elements(p_json_data->'sheets'->'Data') AS j;
	
    -- 3. Validate
    IF (SELECT COUNT(1) FROM tb_master_temp) = 0 THEN
        -- validate không có data
        p_return_code := 1;
        p_message := 'Common_msg_MustHaveOneRow,[Data]';
    ELSE
        -- validate nghiệp vụ
        UPDATE tb_master_temp ms
        SET 
            errordata = CONCAT_WS('',
                fn_utils_validate_value('category_code', ms.category_code, 50, 'Required', 'IsCode'),
                fn_utils_validate_value('category_name_vi', ms.category_name_vi, 255, 'Required'),
                
                -- : Bỏ chữ 'Required' để cho phép để trống
                fn_utils_validate_value('category_name_en', ms.category_name_en, 255),

                CASE WHEN msce.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,competition_code' END,
				
                -- : Bỏ chữ 'Required' để cho phép để trống
                fn_utils_validate_value('status', ms.status, 1),
                
                -- : Chỉ check Tồn tại trạng thái khi người dùng có nhập (nếu trống bỏ qua)
                CASE WHEN ms.status IS NOT NULL AND TRIM(ms.status) <> '' AND syst.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,status' END,
				
                fn_utils_validate_value('description', ms.description, 500)
            )
        FROM tb_master_temp mst
        LEFT JOIN ms_competition_events msce on msce.competition_code = mst.competition_code
        LEFT JOIN sy_commons syst ON syst.value = mst.status AND syst.type = 'COMMON_STATUS'
        WHERE ms.row_number = mst.row_number;
		
        SELECT jsonb_agg(t) INTO v_err_master 
        FROM (SELECT * FROM tb_master_temp WHERE errordata <> '') t;
    END IF;
	
    -- 4. Kiểm tra nếu có lỗi
    IF p_return_code = 0 THEN
        -- trả lỗi
        IF v_err_master IS NOT NULL THEN
            p_return_code := 1;
            p_message := 'Common_msg_ImportInvalid';
            p_error_data := jsonb_build_object('Sheet1', v_err_master);
        -- không lỗi thực hiện insert
        ELSE 
            INSERT INTO ms_ticket_categories(
                category_code,
                category_name_vi,
                category_name_en,
                competition_code,
                status,
                description,
                created_by,
                created_date,
                updated_by,
                updated_date
            ) SELECT
                category_code,
                category_name_vi,
                
               
                COALESCE(NULLIF(TRIM(category_name_en), ''), category_name_vi),
                
                competition_code,
                
                
                COALESCE(NULLIF(TRIM(status), ''), '1'),
                
                description,
                p_user_name,
                NOW(),
                p_user_name,
                NOW()
            FROM tb_master_temp
            ORDER BY row_number;
        END IF;
    END IF;
	
    -- Xóa bảng tạm sau khi dùng xong (tùy chọn vì có ON COMMIT DROP nếu bọc trong transaction)
    DROP TABLE IF EXISTS tb_master_temp;
	
    -- Trả về dòng dữ liệu kết quả
    RETURN NEXT;

EXCEPTION WHEN OTHERS THEN
    -- Bẫy lỗi hệ thống
    p_return_code := 1;
    p_message := SQLERRM; --'Common_msg_AnErrorOccurred';
    p_error_data := '[]'::jsonb;
    RETURN NEXT;
END;
$$;


ALTER FUNCTION public.fn_import_msticketcategory(p_json_data jsonb, p_user_name character varying, p_ip_address character varying) OWNER TO sportevent;

--
-- TOC entry 955 (class 1255 OID 24729)
-- Name: fn_import_srmatchresult(jsonb, character varying, character varying); Type: FUNCTION; Schema: public; Owner: sportevent
--

CREATE FUNCTION public.fn_import_srmatchresult(p_json_data jsonb, p_user_name character varying, p_ip_address character varying) RETURNS TABLE(p_return_code integer, p_message text, p_error_data jsonb)
    LANGUAGE plpgsql
    AS $_$
DECLARE
    v_err_general jsonb := NULL;
    v_err_detail jsonb := NULL;
	v_is_override boolean := false;
    v_used_codes text;
BEGIN
    -- 1. Khởi tạo giá trị mặc định cho các cột trả về
    p_return_code := 0;
    p_message := 'Common_msg_ImportSuccess';
    p_error_data := '[]'::jsonb;

    -- 2. Parse JSON vào bảng tạm
  
	-- Lưu ý: Sử dụng CREATE TEMP TABLE trong function cần cẩn thận với việc gọi nhiều lần trong 1 session
	-- Dùng DROP TABLE IF EXISTS để tránh lỗi "table already exists"
	DROP TABLE IF EXISTS tb_general_temp;
	CREATE TEMP TABLE tb_general_temp AS
	SELECT
		row_number() OVER (ORDER BY (j->>'no')) AS row_number,
		j->>'match_code' AS match_code,
		CASE 
			WHEN (j->>'is_finished') IS NULL 
				THEN 0
		    WHEN (j->>'is_finished') ~ '^[01]$' 
			    THEN (j->>'is_finished')::int
		    ELSE NULL
		END AS is_finished,
		j->>'result1' AS result1,
		j->>'result2' AS result2,
		j->>'ranking_criteria' AS ranking_criteria,
		j->>'result_unit' AS result_unit,
		CASE 
			WHEN (j->>'is_match_period') IS NULL 
				THEN 0
		    WHEN (j->>'is_match_period') ~ '^[01]$' 
			    THEN (j->>'is_match_period')::int
		    ELSE NULL
		END AS is_match_period,
		j->>'description' AS description,
		CAST('' AS TEXT) AS errordata
	FROM jsonb_array_elements(p_json_data->'sheets'->'General') AS j;
	
	DROP TABLE IF EXISTS tb_detail_temp;
	CREATE TEMP TABLE tb_detail_temp AS
	SELECT
		row_number() OVER (ORDER BY (k->>'no')) AS row_number,
		k->>'match_code' AS match_code,
		k->>'team_code' AS team_code,
		k->>'emp_athlete_code' AS emp_athlete_code,
		k->>'result_score' AS result_score,
		k->>'match_round' AS match_round,
		k->>'result_by_round1' AS result_by_round1,
		k->>'result_by_round2' AS result_by_round2,
		k->>'remark' AS remark,
		CAST('' AS TEXT) AS errordata
	FROM jsonb_array_elements(p_json_data->'sheets'->'Detail') AS k;

	-- =========================================
	-- Tạo index
	-- =========================================
	IF jsonb_array_length(p_json_data->'sheets'->'General') > 50 THEN
	    EXECUTE 'CREATE INDEX idx_tb_general_match_code ON tb_general_temp(match_code)';
	    EXECUTE 'CREATE INDEX idx_tb_detail_match_code ON tb_detail_temp(match_code)';
	END IF;

	-- Override
	v_is_override := COALESCE((p_json_data->>'is_override')::boolean, false);
	
	-- Kiểm tra ràng buộc nếu override = true
	IF v_is_override = true THEN
        SELECT STRING_AGG(DISTINCT g.match_code, ' | ' ORDER BY g.match_code)
        INTO v_used_codes
        FROM tb_general_temp g
        JOIN sr_match_schedules ms ON ms.match_code = g.match_code
        WHERE EXISTS (
			  -- đã gửi kết quả bình chọn cho KG thì không được xóa
              SELECT 1 FROM sr_match_prediction_result spr
              WHERE ms.match_code = spr.match_code AND spr.submit_status = '1'
	        );
        
        IF v_used_codes IS NOT NULL THEN
            p_return_code := 1;
            p_message := 'Common_msg_OverrideDataIsUsed,' || v_used_codes;
		    RETURN NEXT;
        END IF;
	END IF;
	-- 3. Validate
	IF (SELECT COUNT(1) FROM tb_general_temp) = 0 THEN
		-- validate không có data
		p_return_code := 1;
		p_message := 'Common_msg_MustHaveOneRow,[General]';
	ELSE
		-- =========================================
		-- 1. VALIDATE GENERAL
		-- =========================================
		UPDATE tb_general_temp g
		SET errordata = CONCAT_WS('',

		    fn_utils_validate_value('match_code', g.match_code, 50, 'Required', 'IsCode'),

		    -- đã có result
		    CASE 
			    WHEN mr.match_code IS NOT NULL 
			         AND v_is_override = false 
			    THEN ';Common_msg_DataAlreadyExist,match_code' 
			END,

		     -- duplicate match_code
		    CASE 
		        WHEN dup.match_code IS NOT NULL
		        THEN ';Common_msg_DuplicateData,match_code'
		    END,

		    -- không tồn tại match
		    CASE WHEN ms.match_code IS NULL THEN ';Common_msg_DataNotExistOnSystem,match_code' END,

		    -- validate is_finished (0/1)
		    CASE 
		        WHEN g.is_finished IS NULL
		        THEN ';Common_msg_FieldIsInvalid,is_finished'
		    END,

		    fn_utils_validate_value('description', g.description, 500),

		    -- ===== CASE LOGIC =====
            -- TEAM_VS / SINGLE_VS
            CASE 
				WHEN ms.match_type IN ('TEAM_VS','SINGLE_VS') THEN
					CONCAT_WS('',
					    fn_utils_validate_value('result1', g.result1, 50, 'Required', 'IsNumber'),
					    fn_utils_validate_value('result2', g.result2, 50, 'Required', 'IsNumber'),

					    -- validate is_match_period (0/1)
					    CASE 
					        WHEN g.is_match_period IS NULL
					        THEN ';Common_msg_FieldIsInvalid,is_match_period'
					    END,

					    CASE WHEN g.ranking_criteria IS NOT NULL THEN ';SrMatchResult_msg_NotAllow,ranking_criteria' END,
					    CASE WHEN g.result_unit IS NOT NULL THEN ';SrMatchResult_msg_NotAllow,result_unit' END
					)
            END,

            -- MULTI_TEAM
            CASE 
                WHEN ms.match_type IN ('MULTI_TEAM', 'MULTI_MEMBER') THEN
                    CONCAT_WS('',
                        fn_utils_validate_value('ranking_criteria', g.ranking_criteria, 50, 'Required'),
                        fn_utils_validate_value('result_unit', g.result_unit, 50, 'Required'),

                        CASE WHEN g.result1 IS NOT NULL THEN ';SrMatchResult_msg_NotAllow,result1' END,
                        CASE WHEN g.result2 IS NOT NULL THEN ';SrMatchResult_msg_NotAllow,result2' END,
                        CASE WHEN g.is_match_period <> 0 OR g.is_match_period IS NULL THEN ';SrMatchResult_msg_NotAllow,is_match_period' END,

					    -- không tồn tại ranking_criteria
					    CASE WHEN g.ranking_criteria IS NOT NULL AND scr.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,ranking_criteria' END,

					    -- không tồn tại result_unit
					    CASE WHEN g.result_unit IS NOT NULL AND scu.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,result_unit' END
                    )
            END,

            CASE 
	            WHEN COALESCE(dcnt.cnt, 0) = 0
	            	AND (
		            	(
		            		ms.match_type IN ('TEAM_VS','SINGLE_VS') 
		            		AND gst.is_match_period = 1
	            		)
		            	OR (
		            		ms.match_type IN ('MULTI_TEAM','MULTI_MEMBER')
	            		)
	            	)
	        	THEN ';Common_msg_RequireDetail,Detail,match_code,' || gst.match_code
	        END
		)
		FROM tb_general_temp gst
		LEFT JOIN sr_match_result mr
			ON mr.match_code = gst.match_code
		LEFT JOIN sr_match_schedules ms
			ON ms.match_code = gst.match_code
		LEFT JOIN sy_commons scr
            ON scr.value = gst.ranking_criteria
            AND scr.type = 'RANKING_CRITERIA'
        LEFT JOIN sy_commons scu
            ON scu.value = gst.result_unit
            AND scu.type = 'RESULT_UNIT'
		-- ===== DUPLICATE JOIN =====
		LEFT JOIN (
		    SELECT match_code
		    FROM tb_general_temp
		    GROUP BY match_code
		    HAVING COUNT(*) > 1
		) dup
		    ON dup.match_code = gst.match_code
	    LEFT JOIN (
		    SELECT match_code, COUNT(*) AS cnt
		    FROM tb_detail_temp
		    GROUP BY match_code
		) dcnt ON dcnt.match_code = gst.match_code
		WHERE g.row_number = gst.row_number;

		SELECT jsonb_agg(t) INTO v_err_general 
		FROM (SELECT * FROM tb_general_temp WHERE errordata <> '') t;

		-- =========================================
		-- 2. VALIDATE DETAIL
		-- =========================================
		UPDATE tb_detail_temp d
		SET errordata = CONCAT_WS('',

        	CASE 
        		WHEN dst.match_code IS NOT NULL 
	            	AND (
		            	(
		            		ms.match_type IN ('TEAM_VS','SINGLE_VS') 
		            		AND gst.is_match_period = 0
	            		)
	            	)
	        	THEN ';SrMatchResult_msg_NotAllowDetail,match_code'

        		WHEN (
		            	ms.match_type IN ('MULTI_TEAM','MULTI_MEMBER')
	            		OR (
		            		ms.match_type IN ('TEAM_VS','SINGLE_VS') 
		            		AND gst.is_match_period = 1            			
	        			)
	            	)
	        	THEN fn_utils_validate_value('match_code', dst.match_code, 50, 'Required', 'IsCode')
	        END,
            CASE WHEN dst.match_code IS NOT NULL AND gst.match_code IS NULL THEN ';Common_msg_KeyNotFoundInSheet,match_code,General' END,

		    fn_utils_validate_value('remark', dst.remark, 255),

		    CONCAT_WS('',
	            -- TEAM_VS / SINGLE_VS có hiệp
	            CASE 
	                WHEN ms.match_type IN ('TEAM_VS','SINGLE_VS')
	                     AND gst.is_match_period = 1
	                THEN
	                    CONCAT_WS('',
	                    	fn_utils_validate_value('match_round', dst.match_round, 50, 'Required', 'IsNumber'),
	                        fn_utils_validate_value('result_by_round1', dst.result_by_round1, 50, 'Required', 'IsNumber'),
	                        fn_utils_validate_value('result_by_round2', dst.result_by_round2, 50, 'Required', 'IsNumber'),

	                        -- duplicate round
		                    CASE 
		                        WHEN dupr.match_round IS NOT NULL
		                        THEN ';Common_msg_DuplicateData,match_round'
		                    END,

	                        CASE WHEN dst.team_code IS NOT NULL THEN ';SrMatchResult_msg_NotAllow,team_code' END,
	                        CASE WHEN dst.emp_athlete_code IS NOT NULL THEN ';SrMatchResult_msg_NotAllow,emp_athlete_code' END,
	                        CASE WHEN dst.result_score IS NOT NULL THEN ';SrMatchResult_msg_NotAllow,result_score' END
	                    )
	            END,

	            -- MULTI_TEAM
	            CASE 
	                WHEN ms.match_type = 'MULTI_TEAM' THEN
	                    CONCAT_WS('',
	                    	fn_utils_validate_value('team_code', dst.team_code, 50, 'Required'),
	                        fn_utils_validate_value('result_score', dst.result_score, 150, 'Required'),

	                        -- duplicate team
		                   CASE 
		                        WHEN dupt.team_code IS NOT NULL
		                        THEN ';Common_msg_DuplicateData,team_code'
		                    END,

	                        CASE WHEN dst.emp_athlete_code IS NOT NULL THEN ';SrMatchResult_msg_NotAllow,emp_athlete_code' END,
	                        CASE WHEN dst.match_round IS NOT NULL THEN ';SrMatchResult_msg_NotAllow,match_round' END,
	                        CASE WHEN dst.result_by_round1 IS NOT NULL THEN ';SrMatchResult_msg_NotAllow,result_by_round1' END,
	                        CASE WHEN dst.result_by_round2 IS NOT NULL THEN ';SrMatchResult_msg_NotAllow,result_by_round2' END,
							CASE 
							    WHEN misst.match_code IS NOT NULL
							    THEN ';SrMatchResult_msg_NotEnoughTeamInMatch,match_code'
							END,
	                        -- =========================================
							-- TEAM: exist -> then check in match
							-- =========================================
						    CASE WHEN dst.team_code IS NOT NULL AND t.id IS NULL THEN ';SrMatchResult_msg_InvalidTeamInMatch,team_code'END,

						    -- Check dst.result_score không phải là HH:mm:ss khi đơn vị là thời gian
						    CASE 
							    WHEN scu.value IS NOT NULL 
							        AND scu.value = 'TIME'
							        AND dst.result_score IS NOT NULL
							        AND dst.result_score !~ '^(?:[01]\d|2[0-3]):[0-5]\d:[0-5]\d$'
							    THEN ';Common_msg_FieldWrongFormatData,result_score,hh:mm:ss'
							    WHEN scu.value IS NOT NULL 
							        AND scu.value = 'SCORE'
							        AND dst.result_score IS NOT NULL
							        AND dst.result_score !~ '^[0-9]+(\.[0-9]+)?$'
							    THEN ';Common_msg_FieldWrongFormatData,result_score,number'
							END
	                    )
	            END,

	            -- MULTI_MEMBER
	            CASE 
	                WHEN ms.match_type = 'MULTI_MEMBER' THEN
	                    CONCAT_WS('',
	                    	fn_utils_validate_value('emp_athlete_code', dst.emp_athlete_code, 50, 'Required'),
	                        fn_utils_validate_value('result_score', dst.result_score, 150, 'Required'),

                        	-- duplicate athlete
		                    CASE 
		                        WHEN dupa.emp_athlete_code IS NOT NULL
		                        THEN ';Common_msg_DuplicateData,emp_athlete_code'
		                    END,

	                        CASE WHEN dst.team_code IS NOT NULL THEN ';SrMatchResult_msg_NotAllow_multi_member,team_code' END,
	                        CASE WHEN dst.match_round IS NOT NULL THEN ';SrMatchResult_msg_NotAllow_multi_member,match_round' END,
	                        CASE WHEN dst.result_by_round1 IS NOT NULL THEN ';SrMatchResult_msg_NotAllow_multi_member,result_by_round1' END,
	                        CASE WHEN dst.result_by_round2 IS NOT NULL THEN ';SrMatchResult_msg_NotAllow_multi_member,result_by_round2' END,
							CASE 
							    WHEN miss.match_code IS NOT NULL
							    THEN ';SrMatchResult_msg_NotEnoughAthleteInMatch,match_code'
							END,
	                        -- =========================================
							-- ATHLETE: exist -> then check in team
							-- =========================================
						    CASE WHEN dst.emp_athlete_code IS NOT NULL AND ta.id IS NULL THEN ';SrMatchResult_msg_InvalidAthleteInMatch,emp_athlete_code' END,

						    -- Check dst.result_score không phải là HH:mm:ss khi đơn vị là thời gian
						    CASE 
							    WHEN scu.value IS NOT NULL 
							         AND scu.value = 'TIME'
							         AND dst.result_score IS NOT NULL
							         AND dst.result_score !~ '^(?:[01]\d|2[0-3]):[0-5]\d:[0-5]\d$'
						    THEN ';Common_msg_FieldWrongFormatData,result_score,hh:mm:ss'END
	                    )
	            END
            )
		)
		FROM tb_detail_temp dst
		LEFT JOIN sr_match_schedules ms
		    ON ms.match_code = dst.match_code
		LEFT JOIN tb_general_temp gst
		    ON gst.match_code = ms.match_code
	    LEFT JOIN sr_match_teams mt
            ON mt.match_code = ms.match_code
	        AND mt.team_code = dst.team_code
	    LEFT JOIN ms_teams t 
            ON t.team_code = mt.team_code
        LEFT JOIN sr_match_athletes ma
	        ON ma.match_code = ms.match_code
	        AND ma.emp_athlete_code = dst.emp_athlete_code
        LEFT JOIN ms_team_athletes ta 
            ON ta.emp_athlete_code = ma.emp_athlete_code
        LEFT JOIN sy_commons scu
            ON scu.value = gst.result_unit
            AND scu.type = 'RESULT_UNIT'
		LEFT JOIN (
		    SELECT mt.match_code
		    FROM sr_match_teams mt
		    LEFT JOIN tb_detail_temp x
		        ON x.match_code = mt.match_code
		       AND x.team_code = mt.team_code
		    WHERE x.team_code IS NULL
		    GROUP BY mt.match_code
		) misst
		ON misst.match_code = dst.match_code
		LEFT JOIN (
		    SELECT ma.match_code
		    FROM sr_match_athletes ma
		    GROUP BY ma.match_code
		    HAVING COUNT(DISTINCT ma.emp_athlete_code) >
		    (
		        SELECT COUNT(DISTINCT x.emp_athlete_code)
		        FROM tb_detail_temp x
		        WHERE x.match_code = ma.match_code
		          AND x.emp_athlete_code IS NOT NULL
		    )
		) miss
		ON miss.match_code = dst.match_code
        -- ===== DUPLICATE JOIN =====
		LEFT JOIN (
		    SELECT match_code, match_round AS match_round
		    FROM tb_detail_temp
		    WHERE match_round ~ '^\d+$'
		    GROUP BY match_code, match_round
		    HAVING COUNT(*) > 1
		) dupr
		    ON dupr.match_code = ms.match_code
		   AND dst.match_round ~ '^\d+$'
		   AND dupr.match_round = dst.match_round
		LEFT JOIN (
		    SELECT match_code, team_code
		    FROM tb_detail_temp
		    WHERE team_code IS NOT NULL
		    GROUP BY match_code, team_code
		    HAVING COUNT(*) > 1
		) dupt
		    ON dupt.match_code = dst.match_code
		   AND dupt.team_code = dst.team_code

		LEFT JOIN (
		    SELECT match_code, emp_athlete_code
		    FROM tb_detail_temp
		    WHERE emp_athlete_code IS NOT NULL
		    GROUP BY match_code, emp_athlete_code
		    HAVING COUNT(*) > 1
		) dupa
		    ON dupa.match_code = ms.match_code
		   AND dupa.emp_athlete_code = dst.emp_athlete_code
		WHERE d.row_number = dst.row_number;

		SELECT jsonb_agg(t) INTO v_err_detail 
		FROM (SELECT * FROM tb_detail_temp WHERE errordata <> '') t;
	END IF;
	
	-- 4. Kiểm tra nếu có lỗi
	IF p_return_code = 0 THEN
		-- trả lỗi
		IF v_err_general IS NOT NULL OR v_err_detail IS NOT NULL THEN
			p_return_code := 1;
			p_message := 'Common_msg_ImportInvalid';
			p_error_data := jsonb_strip_nulls(jsonb_build_object(
				'General', v_err_general,
				'Detail', v_err_detail
			));
		-- không lỗi thực hiện insert
		ELSE 
			-- INSERT GENERAL
			DROP TABLE IF EXISTS tb_result_map;

			-- Nếu override = true, xóa dữ liệu cũ của những match_code đã tồn tại
			IF v_is_override = true THEN
			    -- Xóa chi tiết trước
			    DELETE FROM sr_match_result_detail
			    WHERE match_result_id IN (
			        SELECT mr.id 
			        FROM sr_match_result mr
			        JOIN tb_general_temp g ON g.match_code = mr.match_code
			    );
			    
			    -- Xóa result chính
			    DELETE FROM sr_match_result
			    WHERE match_code IN (
			        SELECT match_code 
			        FROM tb_general_temp
			    );
			END IF;

			-- Insert mới (cho cả trường hợp override và không override)			
			CREATE TEMP TABLE tb_result_map AS
			WITH ins AS (
			    INSERT INTO sr_match_result(
			        competition_code,
			        match_code,
			        is_finished,
			        is_match_period,
			        ranking_criteria,
			        result_unit,
			        description,
			        created_by,
			        created_date,
			        updated_by,
			        updated_date
			    )
			    SELECT
			        ms.competition_code,
			        g.match_code,
			        is_finished::boolean,
			        g.is_match_period::boolean,
			        g.ranking_criteria,
			        g.result_unit,
			        g.description,
			        p_user_name,
			        NOW(),
			        p_user_name,
			        NOW()
			    FROM tb_general_temp g
			    JOIN sr_match_schedules ms ON ms.match_code = g.match_code
			    RETURNING id, match_code
			)
			SELECT * FROM ins;

			-- INSERT Detail
			-- =========================================
			-- 1. TEAM_VS - FINAL RESULT (LUÔN INSERT)
			-- =========================================
			WITH team_map AS (
			    SELECT 
			        mt.match_code,
			        mt.team_code,
			        ROW_NUMBER() OVER (PARTITION BY mt.match_code ORDER BY mt.team_code) AS pos
			    FROM sr_match_teams mt
			)
			INSERT INTO sr_match_result_detail(
			    match_result_id,
			    team_code,
			    result_value,
			    is_final_result,
			    created_by,
			    created_date,
			    updated_by,
			    updated_date,
			    order_by
			)
			SELECT
			    rm.id,
			    tm.team_code,
			    CASE 
			        WHEN tm.pos = 1 THEN g.result1
			        WHEN tm.pos = 2 THEN g.result2
			    END,
			    true,
			    p_user_name,
			    NOW(),
			    p_user_name,
			    NOW(),
			    tm.pos
			FROM tb_general_temp g
			JOIN tb_result_map rm ON rm.match_code = g.match_code
			JOIN sr_match_schedules ms ON ms.match_code = g.match_code
			JOIN team_map tm ON tm.match_code = g.match_code
			WHERE ms.match_type = 'TEAM_VS'
			  AND (
			        (tm.pos = 1 AND g.result1 IS NOT NULL)
			     OR (tm.pos = 2 AND g.result2 IS NOT NULL)
			  );

			-- =========================================
			-- 2. SINGLE_VS - FINAL RESULT
			-- =========================================
			WITH athlete_map AS (
			    SELECT 
			        ma.match_code,
			        ma.emp_athlete_code,
			        ROW_NUMBER() OVER (PARTITION BY ma.match_code ORDER BY ma.emp_athlete_code) AS pos
			    FROM sr_match_athletes ma
			)
			INSERT INTO sr_match_result_detail(
			    match_result_id,
			    team_code,
			    emp_athlete_code,
			    result_value,
			    is_final_result,
			    created_by,
			    created_date,
			    updated_by,
			    updated_date,
			    order_by
			)
			SELECT
			    rm.id,
			    msa.team_code,
			    am.emp_athlete_code,
			    CASE 
			        WHEN am.pos = 1 THEN g.result1
			        WHEN am.pos = 2 THEN g.result2
			    END,
			    true,
			    p_user_name,
			    NOW(),
			    p_user_name,
			    NOW(),
			    am.pos
			FROM tb_general_temp g
			JOIN tb_result_map rm ON rm.match_code = g.match_code
			JOIN sr_match_schedules ms ON ms.match_code = g.match_code
			JOIN athlete_map am ON am.match_code = ms.match_code
			JOIN sr_match_athletes msa 
			    ON msa.match_code = g.match_code
			   AND msa.emp_athlete_code = am.emp_athlete_code
			WHERE ms.match_type = 'SINGLE_VS'
			  AND (
			        (am.pos = 1 AND g.result1 IS NOT NULL)
			     OR (am.pos = 2 AND g.result2 IS NOT NULL)
			  );

			-- =========================================
			-- 3. TEAM_VS - ROUND (is_match_period = 1)
			-- =========================================
			WITH team_map AS (
			    SELECT 
			        mt.match_code,
			        mt.team_code,
			        ROW_NUMBER() OVER (PARTITION BY mt.match_code ORDER BY mt.team_code) AS pos
			    FROM sr_match_teams mt
			)
			INSERT INTO sr_match_result_detail(
			    match_result_id,
			    team_code,
			    match_round,
			    result_by_round,
			    created_by,
			    created_date,
			    updated_by,
			    updated_date,
			    order_by
			)
			SELECT
			    rm.id,
			    tm.team_code,
			    d.match_round::int,
			    v.result_value::numeric,
			    p_user_name,
			    NOW(),
			    p_user_name,
			    NOW(),
			    tm.pos
			FROM tb_detail_temp d
			JOIN tb_result_map rm ON rm.match_code = d.match_code
			JOIN sr_match_schedules ms ON ms.match_code = d.match_code
			JOIN tb_general_temp g ON g.match_code = d.match_code
			JOIN team_map tm ON tm.match_code = d.match_code

			CROSS JOIN LATERAL (
			    VALUES
			        (1, d.result_by_round1),
			        (2, d.result_by_round2)
			) AS v(pos, result_value)

			WHERE ms.match_type = 'TEAM_VS'
			  AND g.is_match_period = 1
			  AND tm.pos = v.pos
			  AND d.match_round IS NOT NULL
			  AND v.result_value IS NOT NULL;

			-- =========================================
			-- 4. SINGLE_VS - ROUND
			-- =========================================
			WITH athlete_map AS (
			    SELECT 
			        ma.match_code,
			        ma.emp_athlete_code,
			        ROW_NUMBER() OVER (PARTITION BY ma.match_code ORDER BY ma.emp_athlete_code) AS pos
			    FROM sr_match_athletes ma
			)
			INSERT INTO sr_match_result_detail(
			    match_result_id,
			    team_code,
			    emp_athlete_code,
			    match_round,
			    result_by_round,
			    remark,
			    created_by,
			    created_date,
			    updated_by,
			    updated_date,
			    order_by
			)
			SELECT
			    rm.id,
			    msa.team_code,
			    am.emp_athlete_code,
			    d.match_round::int,
			    v.result_value::numeric,
			    remark,
			    p_user_name,
			    NOW(),
			    p_user_name,
			    NOW(),
			    am.pos
			FROM tb_detail_temp d
			JOIN tb_result_map rm ON rm.match_code = d.match_code
			JOIN sr_match_schedules ms ON ms.match_code = d.match_code
			JOIN tb_general_temp g ON g.match_code = ms.match_code
			JOIN athlete_map am ON am.match_code = ms.match_code
			JOIN sr_match_athletes msa 
			    ON msa.match_code = d.match_code
			   AND msa.emp_athlete_code = am.emp_athlete_code

			CROSS JOIN LATERAL (
			    VALUES
			        (1, d.result_by_round1),
			        (2, d.result_by_round2)
			) AS v(pos, result_value)

			WHERE ms.match_type = 'SINGLE_VS'
			  AND g.is_match_period = 1
			  AND am.pos = v.pos
			  AND d.match_round IS NOT NULL
			  AND v.result_value IS NOT NULL;

			-- =========================================
			-- 5. MULTI_TEAM
			-- =========================================
			INSERT INTO sr_match_result_detail(
			    match_result_id,
			    team_code,
			    result_value,
			    remark,
			    created_by,
			    created_date,
			    updated_by,
			    updated_date
			)
			SELECT
			    rm.id,
			    d.team_code,
			    d.result_score,
			    remark,
			    p_user_name,
			    NOW(),
			    p_user_name,
			    NOW()
			FROM tb_detail_temp d
			JOIN tb_result_map rm ON rm.match_code = d.match_code
			JOIN sr_match_schedules ms ON ms.match_code = d.match_code
			WHERE ms.match_type = 'MULTI_TEAM'
			  AND d.team_code IS NOT NULL
			  AND d.result_score IS NOT NULL;

			-- =========================================
			-- 6. MULTI_MEMBER
			-- =========================================
			INSERT INTO sr_match_result_detail(
			    match_result_id,
			    team_code,
			    emp_athlete_code,
			    result_value,
			    remark,
			    created_by,
			    created_date,
			    updated_by,
			    updated_date
			)
			SELECT
			    rm.id,
			    msa.team_code,
			    d.emp_athlete_code,
			    d.result_score,
			    remark,
			    p_user_name,
			    NOW(),
			    p_user_name,
			    NOW()
			FROM tb_detail_temp d
			JOIN tb_result_map rm ON rm.match_code = d.match_code
			JOIN sr_match_schedules ms ON ms.match_code = d.match_code
			JOIN sr_match_athletes msa 
			    ON msa.match_code = d.match_code
			   AND msa.emp_athlete_code = d.emp_athlete_code
			WHERE ms.match_type = 'MULTI_MEMBER'
			  AND d.emp_athlete_code IS NOT NULL
			  AND d.result_score IS NOT NULL;
			
			-- =========================================
			-- 7. AUTO RANK ONLY MULTI_TEAM + MULTI_MEMBER
			-- =========================================
			WITH target_match AS (
			    SELECT DISTINCT match_code
			    FROM tb_detail_temp
			),

			base AS (
			    SELECT
			        d.id,
			        d.match_result_id,
			        m.result_unit,
			        m.ranking_criteria,

			        -- Chuẩn hoá giá trị để ranking
			        CASE 
			            -- TIME luôn dạng hh:mm:ss
			            WHEN m.result_unit = 'TIME'
			                 AND d.result_value ~ '^(?:[01]\d|2[0-3]):[0-5]\d:[0-5]\d$'
			            THEN EXTRACT(EPOCH FROM d.result_value::interval)

			            -- SCORE
			            WHEN m.result_unit = 'SCORE'
			                 AND d.result_value ~ '^-?\d+(\.\d+)?$'
			            THEN d.result_value::numeric

			            ELSE NULL
			        END AS norm_value

			    FROM sr_match_result_detail d
			    JOIN sr_match_result m 
			        ON m.id = d.match_result_id
			    JOIN sr_match_schedules ms 
			        ON ms.match_code = m.match_code
			    WHERE ms.match_type IN ('MULTI_TEAM', 'MULTI_MEMBER')
			      AND ms.match_code IN (SELECT match_code FROM target_match)
			),

			ranked AS (
			    SELECT
			        id,
			        ROW_NUMBER() OVER (
			            PARTITION BY match_result_id
			            ORDER BY
			                -- LOWEST => tăng dần
			                CASE 
			                    WHEN ranking_criteria = 'LOWEST' 
			                    THEN norm_value 
			                END ASC,

			                -- HIGHEST => giảm dần
			                CASE 
			                    WHEN ranking_criteria = 'HIGHEST' 
			                    THEN norm_value 
			                END DESC
			        ) AS rnk
			    FROM base
			    WHERE norm_value IS NOT NULL
			)

			UPDATE sr_match_result_detail d
			SET result_rank = r.rnk
			FROM ranked r
			WHERE d.id = r.id;
			-- [HISTORY] Lưu lịch sử system history cho Import
            INSERT INTO public.sy_journals(module_code, function_code, user_name, data_id, action_code, action_date, ip_address, json_before, json_after)
            VALUES ('ScheduleResult', 'SrMatchResult', p_user_name, NULL, 'IMPORT', CURRENT_TIMESTAMP, p_ip_address, NULL, p_json_data);
		END IF;
	END IF;
	
	-- Xóa bảng tạm sau khi dùng xong
	DROP TABLE IF EXISTS tb_general_temp;
	DROP TABLE IF EXISTS tb_detail_temp;
	
    -- Trả về dòng dữ liệu kết quả
    RETURN NEXT;

EXCEPTION WHEN OTHERS THEN
    -- Bẫy lỗi hệ thống
    p_return_code := 1;
    p_message := SQLERRM; --'Common_msg_AnErrorOccurred';
    p_error_data := '[]'::jsonb;
    RETURN NEXT;
END;
$_$;


ALTER FUNCTION public.fn_import_srmatchresult(p_json_data jsonb, p_user_name character varying, p_ip_address character varying) OWNER TO sportevent;

--
-- TOC entry 839 (class 1255 OID 28789)
-- Name: fn_import_srmatchschedule(jsonb, character varying, character varying); Type: FUNCTION; Schema: public; Owner: sportevent
--

CREATE FUNCTION public.fn_import_srmatchschedule(p_json_data jsonb, p_user_name character varying, p_ip_address character varying) RETURNS TABLE(p_return_code integer, p_message text, p_error_data jsonb)
    LANGUAGE plpgsql
    AS $_$
DECLARE
    v_err_general jsonb := NULL;
    v_err_teams jsonb := NULL;
    v_err_athletes jsonb := NULL;
    v_err_referees jsonb := NULL;
    v_err_volunteers jsonb := NULL;
	v_is_override boolean := false;
    v_used_codes text;
    v_first_code text;
BEGIN
    -- 1. Khởi tạo giá trị mặc định cho các cột trả về
    p_return_code := 0;
    p_message := 'Common_msg_ImportSuccess';
    p_error_data := '[]'::jsonb;

    -- 2. Parse JSON vào bảng tạm
  
	-- Lưu ý: Sử dụng CREATE TEMP TABLE trong function cần cẩn thận với việc gọi nhiều lần trong 1 session
	-- Dùng DROP TABLE IF EXISTS để tránh lỗi "table already exists"
	DROP TABLE IF EXISTS tb_general_temp;
	CREATE TEMP TABLE tb_general_temp AS
	SELECT
		row_number() OVER (ORDER BY (j->>'no')) AS row_number,
		j->>'match_code' AS match_code,
		j->>'competition_code' AS competition_code,
		j->>'sport_code' AS sport_code,
		j->>'sport_event_code' AS sport_event_code,
		j->>'match_name_vi' AS match_name_vi,
		j->>'match_name_en' AS match_name_en,
		j->>'match_type' AS match_type,
		j->>'location_code' AS location_code,
		j->>'match_start_date' AS match_start_date,
		j->>'match_end_date' AS match_end_date,
		j->>'match_start_time' AS match_start_time,
		j->>'match_end_time' AS match_end_time,
		j->>'match_round' AS match_round,
		j->>'link_online' AS link_online,
		j->>'is_vote' AS is_vote,
		j->>'description' AS description,
		CAST('' AS TEXT) AS errordata
	FROM jsonb_array_elements(p_json_data->'sheets'->'General') AS j;
	
	DROP TABLE IF EXISTS tb_team_temp;
	CREATE TEMP TABLE tb_team_temp AS
	SELECT
		row_number() OVER (ORDER BY (k->>'no')) AS row_number,
		k->>'match_code' AS match_code,
		k->>'team_code' AS team_code,
		CAST('' AS TEXT) AS errordata
	FROM jsonb_array_elements(p_json_data->'sheets'->'Teams') AS k;
	
	DROP TABLE IF EXISTS tb_athletes_temp;
	CREATE TEMP TABLE tb_athletes_temp AS
	SELECT
		row_number() OVER (ORDER BY (l->>'no')) AS row_number,
		l->>'match_code' AS match_code,
		l->>'team_code' AS team_code,
		l->>'emp_athlete_code' AS emp_athlete_code,
		l->>'position_code' AS position_code,
		CAST('' AS TEXT) AS errordata
	FROM jsonb_array_elements(p_json_data->'sheets'->'Athletes') AS l;
	
	DROP TABLE IF EXISTS tb_referees_temp;
	CREATE TEMP TABLE tb_referees_temp AS
	SELECT
		row_number() OVER (ORDER BY (m->>'no')) AS row_number,
		m->>'match_code' AS match_code,
		m->>'emp_referee_code' AS emp_referee_code,
		m->>'position_code' AS position_code,
		CAST('' AS TEXT) AS errordata
	FROM jsonb_array_elements(p_json_data->'sheets'->'Referees') AS m;
	
	DROP TABLE IF EXISTS tb_volunteers_temp;
	CREATE TEMP TABLE tb_volunteers_temp AS
	SELECT
		row_number() OVER (ORDER BY (n->>'no')) AS row_number,
		n->>'match_code' AS match_code,
		n->>'emp_volunteer_code' AS emp_volunteer_code,
		CAST('' AS TEXT) AS errordata
	FROM jsonb_array_elements(p_json_data->'sheets'->'Volunteers') AS n;

	-- =========================
	-- Tạo index
	-- =========================
	IF jsonb_array_length(p_json_data->'sheets'->'General') > 50 THEN
	    EXECUTE 'CREATE INDEX idx_tmp_general_match_code ON tb_general_temp(match_code)';
	    EXECUTE 'CREATE INDEX idx_tmp_team_match_code ON tb_team_temp(match_code)';
	END IF;

	-- Override
	v_is_override := COALESCE((p_json_data->>'is_override')::boolean, false);
	
	-- 3. Validate
	IF (SELECT COUNT(1) FROM tb_general_temp WHERE match_code IS NOT NULL) = 0 THEN
		-- validate không có data
		p_return_code := 1;
		p_message := 'Common_msg_MustHaveOneRow,[General]';
	ELSE
		-- Kiểm tra ràng buộc nếu override = true
		IF v_is_override = true THEN
	        SELECT STRING_AGG(DISTINCT g.match_code, ' | ' ORDER BY g.match_code)
	        INTO v_used_codes
	        FROM tb_general_temp g
	        JOIN sr_match_schedules ms ON ms.match_code = g.match_code
	        WHERE EXISTS (
				SELECT 1 FROM sr_match_result smr
				WHERE ms.match_code = smr.match_code
				AND ms.status != 'NEW'
			);
	        
	        IF v_used_codes IS NOT NULL THEN
	            p_return_code := 1;
	            p_message := 'Common_msg_OverrideDataIsUsed,' || v_used_codes;
			    RETURN NEXT;
	        END IF;
		END IF;
		
		-- =========================================
		-- 1. VALIDATE GENERAL
		-- =========================================
		UPDATE tb_general_temp g
		SET errordata = CONCAT_WS('',

		    fn_utils_validate_value('match_code', gst.match_code, 50, 'Required', 'IsCode'),
		    -- đã có match_code
		    CASE WHEN gst.match_code IS NOT NULL 
			    AND v_is_override = false
			    AND ms.id IS NOT NULL
		    THEN ';Common_msg_DataAlreadyExist,match_code' END,

		    -- duplicate match_code
		    CASE 
		        WHEN dup.match_code IS NOT NULL
		        THEN ';Common_msg_DuplicateData,match_code'
		    END,

		    fn_utils_validate_value('competition_code', gst.competition_code, 50, 'Required', 'IsCode'),
		    CASE WHEN gst.competition_code IS NOT NULL AND ce.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,competition_code' END,

		    fn_utils_validate_value('sport_code', gst.sport_code, 50, 'Required', 'IsCode'),
		    fn_utils_validate_value('sport_event_code', gst.sport_event_code, 50, 'Required', 'IsCode'),
		    CASE 
		    	WHEN gst.competition_code IS NOT NULL AND gst.sport_code IS NOT NULL AND se.id IS NULL 
		    		THEN ';SrMatchSchedule_lbl_NotExistIn,sport_code,competition_code,' || gst.competition_code 
    			WHEN gst.sport_event_code IS NOT NULL 
				    AND (se.sport_event_code IS NULL 
				        OR gst.sport_event_code != ALL(string_to_array(se.sport_event_code, ',')))
    				THEN';SrMatchSchedule_lbl_NotExistIn,sport_event_code,competition_code,' || gst.competition_code
	    	END,

		    fn_utils_validate_value('match_name_vi', gst.match_name_vi, 255, 'Required'),

		    fn_utils_validate_value('match_type', gst.match_type, 50, 'Required', 'IsCode'),
		    CASE WHEN gst.match_type IS NOT NULL AND smt.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,match_type' END,

		    fn_utils_validate_value('location_code', gst.location_code, 50, 'Required', 'IsCode'),
		    CASE WHEN gst.location_code IS NOT NULL AND lc.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,location_code' END,

		    CASE 
			    WHEN fn_utils_validate_value('match_start_date', gst.match_start_date, 10, 'Required', 'IsDate') IS NOT NULL
				    THEN fn_utils_validate_value('match_start_date', gst.match_start_date, 10, 'Required', 'IsDate')
			    WHEN fn_utils_validate_value('match_end_date', gst.match_end_date, 10, 'Required', 'IsDate') IS NOT NULL
			    	THEN fn_utils_validate_value('match_end_date', gst.match_end_date, 10, 'Required', 'IsDate')
			    WHEN TO_DATE(gst.match_start_date, 'DD/MM/YYYY') 
			         > TO_DATE(gst.match_end_date, 'DD/MM/YYYY')
				    THEN ';Common_msg_MustBeLessOrEqual,match_start_date,match_end_date'
			END,

			CASE
				WHEN fn_utils_validate_value('match_start_time', gst.match_start_time, 5, 'Required') IS NOT NULL
					THEN fn_utils_validate_value('match_start_time', gst.match_start_time, 5, 'Required')
				WHEN fn_utils_validate_value('match_end_time', gst.match_end_time, 5, 'Required') IS NOT NULL
					THEN fn_utils_validate_value('match_end_time', gst.match_end_time, 5, 'Required')
				WHEN gst.match_start_time IS NOT NULL AND gst.match_start_time !~ '^(?:[01]\d|2[0-3]):[0-5]\d$'
				    THEN ';Common_msg_FieldWrongFormatData,match_start_time,hh:mm'
			    WHEN gst.match_end_time IS NOT NULL AND gst.match_end_time !~ '^(?:[01]\d|2[0-3]):[0-5]\d$'
				    THEN ';Common_msg_FieldWrongFormatData,match_end_time,hh:mm'
			    WHEN fn_utils_validate_value('match_start_date', gst.match_start_date, 10, 'Required', 'IsDate') IS NULL 
			    		AND fn_utils_validate_value('match_end_date', gst.match_end_date, 10, 'Required', 'IsDate') IS NULL
			    	THEN (
			    		CASE WHEN TO_DATE(gst.match_start_date, 'DD/MM/YYYY') = TO_DATE(gst.match_end_date, 'DD/MM/YYYY')
			    			AND TO_TIMESTAMP(gst.match_start_time, 'HH24:MI') > TO_TIMESTAMP(gst.match_end_time, 'HH24:MI')
				        THEN ';SyParameter_msg_MinlessMax,match_start_time,match_end_time' END
			        )
			END,

		    fn_utils_validate_value('match_round', gst.match_round, 50, 'Required'),
		    CASE WHEN gst.match_round IS NOT NULL AND smr.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,match_round' END,

		    fn_utils_validate_value('link_online', gst.link_online, 255),
		    CASE WHEN gst.is_vote IS NOT NULL AND gst.is_vote !~ '^[01]$' THEN ';Common_msg_FieldWrongFormat,[is_vote]' END,
		    fn_utils_validate_value('description', gst.description, 500),

	        -- TEAM_VS: bắt buộc ĐÚNG 2 dòng Teams, không nhập Athletes
			CASE 
			    WHEN gst.match_type = 'TEAM_VS' THEN
			        CONCAT_WS('',
			            CASE 
			                WHEN COALESCE(tst.cnt_team, 0) != 2 
			                THEN ';SrMatchSchedule_lbl_RequireExactRowsWithCondition,Teams,2,match_code,' || gst.match_code
			            END,
			            CASE 
			                WHEN COALESCE(ast.cnt_athlete, 0) > 0 
			                THEN ';SrMatchResult_msg_NotAllow,Sheet [Athletes] match_code="' || gst.match_code || '"'
			            END
			        )
			END,
	        -- SINGLE_VS: bắt buộc ĐÚNG 2 dòng Teams & Athletes
			CASE 
			    WHEN gst.match_type = 'SINGLE_VS' THEN
			        CONCAT_WS('',
			            CASE 
			                WHEN COALESCE(tst.cnt_team, 0) != 2 
			                THEN ';SrMatchSchedule_lbl_RequireExactRowsWithCondition,Teams,2,match_code,' || gst.match_code
			            END,
			            CASE 
			                WHEN COALESCE(ast.cnt_athlete, 0) != 2 
			                THEN ';SrMatchSchedule_lbl_RequireExactRowsWithCondition,Athletes,2,match_code,' || gst.match_code
			            END
			        )
			END,

			-- MULTI_TEAM: ít nhất 1 dòng Teams, không nhập Athletes
			CASE 
			    WHEN gst.match_type = 'MULTI_TEAM' THEN
			        CONCAT_WS('',
			            CASE 
			                WHEN COALESCE(tst.cnt_team, 0) = 0
			                THEN ';Common_msg_RequireDetail,Teams,match_code,' || gst.match_code
			            END,
			            CASE 
			                WHEN COALESCE(ast.cnt_athlete, 0) > 0 
			                THEN ';SrMatchResult_msg_NotAllow,Sheet [Athletes] match_code="' || gst.match_code || '"'
			            END
			        )
			END,

			-- MULTI_MEMBER: ít nhất 1 dòng Teams & Athletes
			CASE 
			    WHEN gst.match_type = 'MULTI_MEMBER' THEN
			        CONCAT_WS('',
			            CASE 
			                WHEN COALESCE(tst.cnt_team, 0) = 0
			                THEN ';Common_msg_RequireDetail,Teams,match_code,' || gst.match_code
			            END,
			            CASE 
			                WHEN COALESCE(ast.cnt_athlete, 0) = 0
			                THEN ';Common_msg_RequireDetail,Athletes,match_code,' || gst.match_code
			            END
			        )
			END,

			-- Referee: ít nhất 1 dòng
			CASE 
			    WHEN COALESCE(rst.cnt_referee, 0) < 1 
			    THEN ';Common_msg_RequireDetail,Referees,match_code,' || gst.match_code
			END
		)
		FROM tb_general_temp gst
		LEFT JOIN sr_match_schedules ms
			ON ms.match_code = gst.match_code
		LEFT JOIN ms_competition_events ce
			ON ce.competition_code = gst.competition_code
		LEFT JOIN ms_sport_events se
			ON se.competition_code = gst.competition_code
			AND se.sport_code = gst.sport_code
		LEFT JOIN ms_locations lc
			ON lc.location_code = gst.location_code
		LEFT JOIN sy_commons smt
            ON smt.value = gst.match_type
            AND smt.type = 'MATCH_TYPE'
        LEFT JOIN sy_commons smr
            ON smr.value = gst.match_round
            AND smr.type = 'MATCH_ROUND'
		-- ===== DUPLICATE JOIN =====
		LEFT JOIN (
		    SELECT match_code
		    FROM tb_general_temp
		    GROUP BY match_code
		    HAVING COUNT(*) > 1
		) dup
		    ON dup.match_code = gst.match_code
	    -- ===== DETAIL COUNT JOINS =====
		LEFT JOIN (
			SELECT match_code, COUNT(*) AS cnt_team FROM tb_team_temp GROUP BY match_code
		) tst ON tst.match_code = gst.match_code
		LEFT JOIN (
			SELECT match_code, COUNT(*) AS cnt_athlete FROM tb_athletes_temp GROUP BY match_code
		) ast ON ast.match_code = gst.match_code
		LEFT JOIN (
			SELECT match_code, COUNT(*) AS cnt_referee FROM tb_referees_temp GROUP BY match_code
		) rst ON rst.match_code = gst.match_code
		WHERE g.row_number = gst.row_number;

		SELECT jsonb_agg(t) INTO v_err_general 
		FROM (SELECT * FROM tb_general_temp WHERE errordata <> '') t;

		-- =========================================
		-- 2. VALIDATE DETAIL - Teams
		-- =========================================
		UPDATE tb_team_temp ts
		SET errordata = CONCAT_WS('',
        	fn_utils_validate_value('match_code', tst.match_code, 50, 'Required', 'IsCode'),
        	CASE WHEN tst.match_code IS NOT NULL AND gst.match_code IS NULL THEN ';Common_msg_KeyNotFoundInSheet,match_code,General' END,

        	fn_utils_validate_value('team_code', tst.team_code, 50, 'Required', 'IsCode'),
        	CASE
        		WHEN tst.team_code IS NOT NULL AND t.id IS NULL 
        			THEN ';Common_msg_DataNotExistOnSystem,team_code'
                WHEN dup.team_code IS NOT NULL
	                THEN ';Common_msg_DuplicateData,team_code'
			    WHEN NOT EXISTS (
			        SELECT 1
			        FROM tb_athletes_temp att
			        WHERE att.match_code = tst.match_code
			          AND att.team_code  = tst.team_code
			    )
				    THEN ';Common_msg_RequireDetail,Sheet [Athletes], team_code,"' || tst.team_code || '"'
            END
		)
		FROM tb_team_temp tst
		LEFT JOIN tb_general_temp gst
		    ON gst.match_code = tst.match_code
	    LEFT JOIN ms_teams t
            ON t.team_code = tst.team_code
        -- ===== DUPLICATE JOIN =====
		LEFT JOIN (
		    SELECT match_code, team_code
		    FROM tb_team_temp
		    WHERE match_code IS NOT NULL 
		    	AND team_code IS NOT NULL
		    GROUP BY match_code, team_code
		    HAVING COUNT(*) > 1
		) dup
		    ON dup.match_code = tst.match_code
		   AND dup.team_code = tst.team_code
		WHERE ts.row_number = tst.row_number;

		SELECT jsonb_agg(t) INTO v_err_teams 
		FROM (SELECT * FROM tb_team_temp WHERE errordata <> '') t;

		-- =========================================
		-- 3. VALIDATE DETAIL - Athletes
		-- =========================================
		UPDATE tb_athletes_temp asu
		SET errordata = COALESCE(
			CASE WHEN gst.match_type IN ('SINGLE_VS', 'MULTI_MEMBER') THEN CONCAT_WS('',
	        	fn_utils_validate_value('match_code', ast.match_code, 50, 'Required', 'IsCode'),
	        	fn_utils_validate_value('team_code', ast.team_code, 50, 'Required', 'IsCode'),
	            fn_utils_validate_value('emp_athlete_code', ast.emp_athlete_code, 50, 'Required', 'IsCode'),

	        	CASE 
	        		WHEN ast.match_code IS NOT NULL AND gst.match_code IS NULL 
	        			THEN ';Common_msg_KeyNotFoundInSheet,match_code,General'

	        		WHEN ast.team_code IS NOT NULL AND tst.team_code IS NULL
		                THEN ';Common_msg_KeyNotFoundInSheet,team_code,Teams'

	                WHEN ast.emp_athlete_code IS NOT NULL AND ta.id IS NULL
		                THEN ';SrMatchSchedule_lbl_NotExistIn,emp_athlete_code,team_code,' || ast.team_code

	                WHEN dup.emp_athlete_code IS NOT NULL
		                THEN ';Common_msg_DuplicateData,team_code & emp_athlete_code'

	                WHEN ast.position_code IS NULL AND scpemp.id IS NULL
	                	THEN fn_utils_validate_value('position_code', ast.position_code, 50, 'Required', 'IsCode')
	            	WHEN ast.position_code IS NOT NULL AND scp.id IS NULL
	            		THEN ';Common_msg_DataNotExistOnSystem,position_code'
	            END
			)
			END
		, '')
		FROM tb_athletes_temp ast
		LEFT JOIN tb_general_temp gst
		    ON gst.match_code = ast.match_code
	    LEFT JOIN tb_team_temp tst
            ON tst.match_code = ast.match_code 
            AND tst.team_code = ast.team_code
        LEFT JOIN ms_team_athletes ta
            ON ta.emp_athlete_code = ast.emp_athlete_code 
            AND ta.team_code = ast.team_code
        LEFT JOIN ms_employees emp
            ON emp.employee_code = ast.emp_athlete_code
		LEFT JOIN sy_commons scpemp
            ON scpemp.value = emp.position_code
            AND scpemp.type = 'ATHLETE_POSITION'
		LEFT JOIN sy_commons scp
            ON scp.value = ast.position_code
            AND scp.type = 'ATHLETE_POSITION'
        -- ===== DUPLICATE JOIN =====
		LEFT JOIN (
		    SELECT match_code, team_code, emp_athlete_code
		    FROM tb_athletes_temp
		    WHERE match_code IS NOT NULL 
		    	AND team_code IS NOT NULL
			    AND emp_athlete_code IS NOT NULL
		    GROUP BY match_code, team_code, emp_athlete_code
		    HAVING COUNT(*) > 1
		) dup
		    ON dup.match_code = ast.match_code
			AND dup.team_code = ast.team_code
			AND dup.emp_athlete_code = ast.emp_athlete_code
		WHERE asu.row_number = ast.row_number;

		SELECT jsonb_agg(t) INTO v_err_athletes 
		FROM (SELECT * FROM tb_athletes_temp WHERE errordata <> '') t;

		-- =========================================
		-- 4. VALIDATE DETAIL - Referees
		-- =========================================
		UPDATE tb_referees_temp rsu
		SET errordata = CONCAT_WS('',
        	fn_utils_validate_value('match_code', rst.match_code, 50, 'Required', 'IsCode'),
        	fn_utils_validate_value('emp_referee_code', rst.emp_referee_code, 50, 'Required', 'IsCode'),
        	CASE 
        		WHEN rst.match_code IS NOT NULL AND gst.match_code IS NULL 
        			THEN ';Common_msg_KeyNotFoundInSheet,match_code,General'

    			WHEN rst.emp_referee_code IS NOT NULL AND empr.id IS NULL
	                THEN ';SrMatchSchedule_msg_InvalidRefereeType,emp_referee_code'

            	WHEN dup.emp_referee_code IS NOT NULL
	                THEN ';Common_msg_DuplicateData,emp_referee_code'
	            
	            WHEN rst.emp_referee_code IS NOT NULL 
                	AND rst.position_code IS NULL AND scre.id IS NULL
		            	THEN fn_utils_validate_value('position_code', rst.position_code, 50, 'Required', 'IsCode')

            	WHEN rst.position_code IS NOT NULL 
            		AND scr.id IS NULL 
		        		THEN ';Common_msg_DataNotExistOnSystem,position_code'
            END
		)
		FROM tb_referees_temp rst
		LEFT JOIN tb_general_temp gst
		    ON gst.match_code = rst.match_code
	    LEFT JOIN ms_employees empr
		    ON empr.employee_code = rst.emp_referee_code
		    AND empr.employee_type = 'REF'
		LEFT JOIN sy_commons scre
		    ON scre.value = empr.position_code
		   AND scre.type = 'REFEREE_POSITION'
		LEFT JOIN sy_commons scr
            ON scr.value = rst.position_code
            AND scr.type = 'REFEREE_POSITION'
        -- ===== DUPLICATE JOIN =====
		LEFT JOIN (
		    SELECT match_code, emp_referee_code
		    FROM tb_referees_temp
		    WHERE match_code IS NOT NULL 
		    	AND emp_referee_code IS NOT NULL
		    GROUP BY match_code, emp_referee_code
		    HAVING COUNT(*) > 1
		) dup
		    ON dup.match_code = rst.match_code
			AND dup.emp_referee_code = rst.emp_referee_code
		WHERE rsu.row_number = rst.row_number;

		SELECT jsonb_agg(t) INTO v_err_referees
		FROM (SELECT * FROM tb_referees_temp WHERE errordata <> '') t;

		-- =========================================
		-- 4. VALIDATE DETAIL - Volunteers
		-- =========================================
		UPDATE tb_volunteers_temp vsu
		SET errordata = CONCAT_WS('',
        	fn_utils_validate_value('match_code', vst.match_code, 50, 'IsCode'),
        	fn_utils_validate_value('emp_volunteer_code', vst.emp_volunteer_code, 50, 'IsCode'),
        	
        	CASE
        		WHEN vst.match_code IS NOT NULL AND gst.match_code IS NULL
        			THEN ';Common_msg_KeyNotFoundInSheet,match_code,General'

    			WHEN vst.match_code IS NOT NULL AND vst.emp_volunteer_code IS NULL
    				THEN fn_utils_validate_value('emp_volunteer_code', vst.emp_volunteer_code, 50, 'Required')

    			WHEN vst.emp_volunteer_code IS NOT NULL AND empv.id IS NULL
		            THEN ';SrMatchSchedule_msg_InvalidVolunteerType,emp_volunteer_code'

	            WHEN dup.emp_volunteer_code IS NOT NULL
	                THEN ';Common_msg_DuplicateData,emp_volunteer_code'
            END
		)
		FROM tb_volunteers_temp vst
		LEFT JOIN tb_general_temp gst
		    ON gst.match_code = vst.match_code
	    LEFT JOIN ms_employees empv
		    ON empv.employee_code = vst.emp_volunteer_code
		    AND empv.employee_type = 'VOL'
        -- ===== DUPLICATE JOIN =====
		LEFT JOIN (
		    SELECT match_code, emp_volunteer_code
		    FROM tb_volunteers_temp
		    WHERE match_code IS NOT NULL 
		    	AND emp_volunteer_code IS NOT NULL
		    GROUP BY match_code, emp_volunteer_code
		    HAVING COUNT(*) > 1
		) dup
		    ON dup.match_code = vst.match_code
			AND dup.emp_volunteer_code = vst.emp_volunteer_code
		WHERE vsu.row_number = vst.row_number;

		SELECT jsonb_agg(t) INTO v_err_volunteers
		FROM (SELECT * FROM tb_volunteers_temp WHERE errordata <> '') t;

	END IF;
	
	-- 4. Kiểm tra nếu có lỗi
	IF p_return_code = 0 THEN
		-- trả lỗi
		IF v_err_general IS NOT NULL 
		   OR v_err_teams IS NOT NULL
		   OR v_err_athletes IS NOT NULL
		   OR v_err_referees IS NOT NULL
		   OR v_err_volunteers IS NOT NULL
	    THEN
			p_return_code := 1;
			p_message := 'Common_msg_ImportInvalid';
			p_error_data := jsonb_strip_nulls(jsonb_build_object(
				'General', v_err_general,
				'Teams', v_err_teams,
				'Athletes', v_err_athletes,
				'Referees', v_err_referees,
				'Volunteers', v_err_volunteers
			));
		-- không lỗi thực hiện insert
		ELSE
			-- =========================================
		    -- GEN match_code
		    -- =========================================
			-- thêm cột
			ALTER TABLE tb_general_temp ADD COLUMN new_match_code text;

			SELECT new_transaction_no
			INTO v_first_code
			FROM public.fn_utils_generate_transaction_no(
			    'SrMatchSchedule',
			    NOW()::timestamp,
			    1
			)
			LIMIT 1;

			UPDATE tb_general_temp g
			SET new_match_code =
			    regexp_replace(v_first_code, '[0-9]+$', '') ||
			    lpad(
			        (
			            regexp_replace(v_first_code, '^.*?([0-9]+)$', '\1')::bigint
			            + g.row_number - 1
			        )::text,
			        length(regexp_replace(v_first_code, '^.*?([0-9]+)$', '\1')),
			        '0'
			    );

		    -- =========================================
		    -- OVERRIDE MODE
		    -- =========================================
		    IF v_is_override = true THEN

		        -- DELETE DETAIL TRƯỚC
		        DELETE FROM sr_match_teams t
		        USING tb_general_temp g
		        WHERE t.match_code = g.match_code;

		        DELETE FROM sr_match_athletes a
		        USING tb_general_temp g
		        WHERE a.match_code = g.match_code;

		        DELETE FROM sr_match_participating_referees r
		        USING tb_general_temp g
		        WHERE r.match_code = g.match_code;

		        DELETE FROM sr_match_volunteer v
		        USING tb_general_temp g
		        WHERE v.match_code = g.match_code;

		        -- UPDATE MASTER nếu tồn tại
		        UPDATE sr_match_schedules ms
		        SET
		            competition_code = g.competition_code,
		            sport_code = g.sport_code,
		            sport_event_code = g.sport_event_code,
		            match_name_vi = g.match_name_vi,
		            match_name_en = CASE WHEN g.match_name_en IS NOT NULL THEN g.match_name_en ELSE g.match_name_vi END,
		            match_type = g.match_type,
		            location_code = g.location_code,
		            match_start_date = TO_DATE(g.match_start_date, 'DD/MM/YYYY'),
		            match_end_date   = TO_DATE(g.match_end_date, 'DD/MM/YYYY'),
		            match_start_time = g.match_start_time::time,
		            match_end_time   = g.match_end_time::time,
		            match_round = g.match_round,
		            is_vote = CASE WHEN g.is_vote = '1' THEN true ELSE false END,
		            link_online = g.link_online,
		            description = g.description,
		            updated_by = p_user_name,
		            updated_date = NOW()
		        FROM tb_general_temp g
		        WHERE ms.match_code = g.match_code;

		        -- INSERT MASTER nếu chưa tồn tại
		        INSERT INTO sr_match_schedules(
		            match_code,
		            competition_code,
		            sport_code,
		            sport_event_code,
		            match_name_vi,
		            match_name_en,
		            match_type,
		            location_code,
		            match_start_date,
		            match_end_date,
		            match_start_time,
		            match_end_time,
		            match_round,
		            is_vote,
		            link_online,
		            description,
		            created_by,
		            created_date,
		            updated_by,
		            updated_date
		        )
		        SELECT
		            g.new_match_code,
		            g.competition_code,
		            g.sport_code,
		            g.sport_event_code,
		            g.match_name_vi,
		            CASE WHEN g.match_name_en IS NOT NULL THEN g.match_name_en ELSE g.match_name_vi END,
		            g.match_type,
		            g.location_code,
		            TO_DATE(g.match_start_date, 'DD/MM/YYYY'),
		            TO_DATE(g.match_end_date, 'DD/MM/YYYY'),
		            g.match_start_time::time,
		            g.match_end_time::time,
		            g.match_round,
		            CASE WHEN g.is_vote = '1' THEN true ELSE false END,
		            g.link_online,
		            g.description,
		            p_user_name,
		            NOW(),
		            p_user_name,
		            NOW()
		        FROM tb_general_temp g
		        WHERE NOT EXISTS (
		            SELECT 1
		            FROM sr_match_schedules ms
		            WHERE ms.match_code = g.match_code
		        );

		    -- =========================================
		    -- NORMAL INSERT MODE
		    -- =========================================
		    ELSE

		        INSERT INTO sr_match_schedules(
		            match_code,
		            competition_code,
		            sport_code,
		            sport_event_code,
		            match_name_vi,
		            match_name_en,
		            match_type,
		            location_code,
		            match_start_date,
		            match_end_date,
		            match_start_time,
		            match_end_time,
		            match_round,
		            is_vote,
		            link_online,
		            description,
		            created_by,
		            created_date,
		            updated_by,
		            updated_date
		        )
		        SELECT
		            g.new_match_code,
		            g.competition_code,
		            g.sport_code,
		            g.sport_event_code,
		            g.match_name_vi,
		            CASE WHEN g.match_name_en IS NOT NULL THEN g.match_name_en ELSE g.match_name_vi END,
		            g.match_type,
		            g.location_code,
		            TO_DATE(g.match_start_date, 'DD/MM/YYYY'),
		            TO_DATE(g.match_end_date, 'DD/MM/YYYY'),
		            g.match_start_time::time,
		            g.match_end_time::time,
		            g.match_round,
		            CASE WHEN g.is_vote = '1' THEN true ELSE false END,
		            g.link_online,
		            g.description,
		            p_user_name,
		            NOW(),
		            p_user_name,
		            NOW()
		        FROM tb_general_temp g
		        ORDER BY g.row_number;

		    END IF;

		    -- =========================================
		    -- INSERT DETAIL (COMMON CHO CẢ 2 MODE)
		    -- =========================================

		    -- TEAMS
		    INSERT INTO sr_match_teams(
		        match_code,
		        team_code,
		        created_by,
		        created_date,
		        updated_by,
		        updated_date
		    )
		    SELECT
		        g.new_match_code,
		        t.team_code,
		        p_user_name,
		        NOW(),
		        p_user_name,
		        NOW()
		    FROM tb_team_temp t
			JOIN tb_general_temp g
			    ON g.match_code = t.match_code
		    ORDER BY g.row_number;

		    -- ATHLETES
		    IF EXISTS (SELECT 1 FROM tb_athletes_temp) THEN
		        INSERT INTO sr_match_athletes(
		            match_code,
		            team_code,
		            emp_athlete_code,
		            position_code,
		            created_by,
		            created_date,
		            updated_by,
		            updated_date
		        )
		        SELECT
		            g.new_match_code,
		            a.team_code,
		            a.emp_athlete_code,
		            CASE WHEN a.position_code IS NOT NULL THEN a.position_code ELSE emp.position_code END,
		            p_user_name,
		            NOW(),
		            p_user_name,
		            NOW()
		        FROM tb_athletes_temp a
				JOIN tb_general_temp g
				    ON g.match_code = a.match_code
		        JOIN ms_employees emp
		            ON emp.employee_code = a.emp_athlete_code
		        ORDER BY g.row_number;
		    END IF;

		    -- REFEREES
		    INSERT INTO sr_match_participating_referees(
		        match_code,
		        emp_referee_code,
		        position_code,
		        created_by,
		        created_date,
		        updated_by,
		        updated_date
		    )
		    SELECT
		        g.new_match_code,
		        r.emp_referee_code,
		        CASE WHEN R.position_code IS NOT NULL THEN R.position_code ELSE emp.position_code END,
		        p_user_name,
		        NOW(),
		        p_user_name,
		        NOW()
		    FROM tb_referees_temp r
			JOIN tb_general_temp g
			    ON g.match_code = r.match_code
	        JOIN ms_employees emp
	            ON emp.employee_code = r.emp_referee_code
		    ORDER BY g.row_number;

		    -- VOLUNTEERS
		    IF (SELECT COUNT(1) FROM tb_volunteers_temp) > 0 THEN
		        INSERT INTO sr_match_volunteer(
		            match_code,
		            emp_volunteer_code,
		            created_by,
		            created_date,
		            updated_by,
		            updated_date
		        )
		        SELECT
		            g.new_match_code,
		            v.emp_volunteer_code,
		            p_user_name,
		            NOW(),
		            p_user_name,
		            NOW()
		        FROM tb_volunteers_temp v
				JOIN tb_general_temp g
				    ON g.match_code = v.match_code
		        ORDER BY g.row_number;
				-- [HISTORY] Lưu lịch sử system history cho Import
            	INSERT INTO public.sy_journals(module_code, function_code, user_name, data_id, action_code, action_date, ip_address, json_before, json_after)
            	VALUES ('ScheduleResult', 'SrMatchSchedule', p_user_name, NULL, 'IMPORT', CURRENT_TIMESTAMP, p_ip_address, NULL, p_json_data);
		    END IF;
		END IF;
	END IF;
	
	-- Xóa bảng tạm sau khi dùng xong
	DROP TABLE IF EXISTS tb_general_temp;
	DROP TABLE IF EXISTS tb_team_temp;
	DROP TABLE IF EXISTS tb_athletes_temp;
	DROP TABLE IF EXISTS tb_referees_temp;
	DROP TABLE IF EXISTS tb_volunteers_temp;
	
    -- Trả về dòng dữ liệu kết quả
    RETURN NEXT;

EXCEPTION WHEN OTHERS THEN
    -- Bẫy lỗi hệ thống
    p_return_code := 1;
    p_message := SQLERRM; --'Common_msg_AnErrorOccurred';
    p_error_data := '[]'::jsonb;
    RETURN NEXT;
END;
$_$;


ALTER FUNCTION public.fn_import_srmatchschedule(p_json_data jsonb, p_user_name character varying, p_ip_address character varying) OWNER TO sportevent;

--
-- TOC entry 868 (class 1255 OID 18909)
-- Name: fn_import_syuser(jsonb, character varying, character varying); Type: FUNCTION; Schema: public; Owner: sportevent
--

CREATE FUNCTION public.fn_import_syuser(p_json_data jsonb, p_user_name character varying, p_ip_address character varying) RETURNS TABLE(p_return_code integer, p_message text, p_error_data jsonb)
    LANGUAGE plpgsql
    AS $$
	-- function name: import thông tin quản lý người dùng
	-- create by: lthngoc - 01/04/2026
	-- last modify by: xxx - xx/xx/xxxx
DECLARE
    v_err_master jsonb := '[]'::jsonb;
BEGIN
    -- 1. Khởi tạo giá trị mặc định cho các cột trả về
    p_return_code := 0;
    p_message := 'Common_msg_ImportSuccess';
    p_error_data := '[]'::jsonb;

    -- 2. Parse JSON vào bảng tạm
  
	-- Lưu ý: Sử dụng CREATE TEMP TABLE trong function cần cẩn thận với việc gọi nhiều lần trong 1 session
	-- Dùng DROP TABLE IF EXISTS để tránh lỗi "table already exists"
	DROP TABLE IF EXISTS tb_master_temp;
	CREATE TEMP TABLE tb_master_temp AS
	SELECT
		row_number() OVER (ORDER BY (j->>'no')) AS row_number,
		j->>'username' as username,
		j->>'referenceobjectcode' as referenceobjectcode,
		j->>'password' as password,
		j->>'confirmpassword' as confirmpassword,
		j->>'userrolecode' as userrolecode,
		COALESCE(j->>'status', '1') as status,
		CAST('' AS TEXT) AS errordata
	FROM jsonb_array_elements(p_json_data->'sheets'->'Data') AS j;
	
	-- 3. Validate
	IF (SELECT COUNT(1) FROM tb_master_temp) = 0 THEN
		-- validate không có data
		p_return_code := 1;
		p_message := 'Common_msg_MustHaveOneRow,[Data]';
	ELSE
		-- validate nghiệp vụ
		UPDATE tb_master_temp ms
		SET 
			errordata = CONCAT_WS('',
				fn_utils_validate_value('username', ms.username, 50, 'Required', 'IsCode'),
		        CASE WHEN sy.id IS NOT NULL THEN ';Common_msg_DataAlreadyExist,username' END,
		
		        fn_utils_validate_value('referenceobjectcode', ms.referenceobjectcode, 50, 'Required', 'IsCode'),
				CASE WHEN ms.referenceobjectcode IS NOT NULL AND mse.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,referenceobjectcode' END,
				CASE WHEN sy_ref.id IS NOT NULL THEN ';Common_msg_DataAlreadyExist,referenceobjectcode' END,
				CASE 
				    WHEN dup_ref.cnt > 1 THEN ';Common_msg_DuplicateDataInFile,referenceobjectcode'
				END,
				
		        fn_utils_validate_value('password', ms.password, 255, 'Required', 'IsPassword'),
		        fn_utils_validate_value('confirmpassword', ms.confirmpassword, 255, 'Required', 'IsPassword'),
		        CASE 
		            WHEN COALESCE(ms.password, '') <> COALESCE(ms.confirmpassword, '') 
		            THEN ';Common_msg_PasswordAndConfirmPasswordNotMatch,confirmpassword' 
		        END,

		        fn_utils_validate_value('status', ms.status, 1, 'Required'),
		        CASE WHEN syst.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,status' END,
		
		        CASE 
		            WHEN NULLIF(ms.userrolecode, '') IS NOT NULL AND role_chk.invalid_roles IS NOT NULL
		            THEN ';Common_msg_DataNotExistOnSystem,userrolecode'
		        END
			)
		FROM tb_master_temp mst
		LEFT JOIN sy_users sy 
		    ON mst.username = sy.username
		LEFT JOIN ms_employees mse 
		    ON mst.referenceobjectcode = mse.employee_code
		LEFT JOIN sy_users sy_ref
		    ON mst.referenceobjectcode = sy_ref.referenceobjectcode
		LEFT JOIN sy_commons syst 
		    ON syst.value = mst.status AND syst.type = 'COMMON_STATUS'
		LEFT JOIN (
		    SELECT username, COUNT(*) AS cnt
		    FROM tb_master_temp
		    WHERE COALESCE(username, '') <> ''
		    GROUP BY username
		) dup_user 
		    ON mst.username = dup_user.username
		LEFT JOIN (
		    SELECT referenceobjectcode, COUNT(*) AS cnt
		    FROM tb_master_temp
		    WHERE COALESCE(referenceobjectcode, '') <> ''
		    GROUP BY referenceobjectcode
		) dup_ref 
		    ON mst.referenceobjectcode = dup_ref.referenceobjectcode
		LEFT JOIN LATERAL (
		    SELECT string_agg(x.role_code, ',') AS invalid_roles
		    FROM (
		        SELECT trim(value) AS role_code
		        FROM regexp_split_to_table(COALESCE(mst.userrolecode, ''), ',') AS value
		    ) x
		    LEFT JOIN sy_roles r ON r.code = x.role_code
		    WHERE x.role_code <> '' AND r.code IS NULL
		) role_chk ON TRUE
		WHERE ms.row_number = mst.row_number;
		
		SELECT jsonb_agg(t) INTO v_err_master 
		FROM (SELECT * FROM tb_master_temp WHERE errordata <> '') t;
	END IF;
	
	-- 4. Kiểm tra nếu có lỗi
	IF p_return_code = 0 THEN
		-- trả lỗi
		IF v_err_master IS NOT NULL THEN
			p_return_code := 1;
			p_message := 'Common_msg_ImportInvalid';
			p_error_data := jsonb_build_object('Sheet1', v_err_master);
		-- không lỗi thực hiện insert
		ELSE 
			INSERT INTO sy_users(
			    username,
			    referenceobjectcode,
			    password,
			    email,
			    status,
			    createdby,
			    createddate,
			    updatedby,
			    updateddate
			)
			SELECT
			    t.username,
			    t.referenceobjectcode,
			    md5(t.password),
			    mse.email,
			    t.status,
			    p_user_name,
			    NOW(),
			    p_user_name,
			    NOW()
			FROM tb_master_temp t
			JOIN ms_employees mse 
			    ON mse.employee_code = t.referenceobjectcode
			ORDER BY t.row_number;

			INSERT INTO sy_user_roles(
		        username,
		        userrolecode,
		        createdby,
		        createddate,
		        updatedby,
		        updateddate
		    )
		    SELECT
		        t.username,
		        trim(r.role_code),
		        p_user_name,
		        NOW(),
		        p_user_name,
		        NOW()
		    FROM tb_master_temp t
		    CROSS JOIN LATERAL regexp_split_to_table(COALESCE(t.userrolecode, ''), ',') AS r(role_code)
		    WHERE trim(r.role_code) <> '';
			-- [HISTORY] Lưu lịch sử system history cho Import
            INSERT INTO public.sy_journals(module_code, function_code, user_name, data_id, action_code, action_date, ip_address, json_before, json_after)
            VALUES ('System', 'SyUser', p_user_name, NULL, 'IMPORT', CURRENT_TIMESTAMP, p_ip_address, NULL, p_json_data);
		END IF;
	END IF;
	
	-- Xóa bảng tạm sau khi dùng xong (tùy chọn vì có ON COMMIT DROP nếu bọc trong transaction)
	DROP TABLE IF EXISTS tb_master_temp;
	
    -- Trả về dòng dữ liệu kết quả
    RETURN NEXT;

EXCEPTION WHEN OTHERS THEN
    -- Bẫy lỗi hệ thống
    p_return_code := 1;
    p_message := SQLERRM; --'Common_msg_AnErrorOccurred';
    p_error_data := '[]'::jsonb;
    RETURN NEXT;
END;
$$;


ALTER FUNCTION public.fn_import_syuser(p_json_data jsonb, p_user_name character varying, p_ip_address character varying) OWNER TO sportevent;

--
-- TOC entry 969 (class 1255 OID 21725)
-- Name: fn_import_tataskassignment(jsonb, character varying, character varying); Type: FUNCTION; Schema: public; Owner: sportevent
--

CREATE FUNCTION public.fn_import_tataskassignment(p_json_data jsonb, p_user_name character varying, p_ip_address character varying) RETURNS TABLE(p_return_code integer, p_message text, p_error_data jsonb)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_err_master jsonb := NULL;
    v_err_detail jsonb := NULL;
BEGIN
    -- 1. Khởi tạo giá trị mặc định cho các cột trả về
    p_return_code := 0;
    p_message := 'Common_msg_ImportSuccess';
    p_error_data := '[]'::jsonb;

    -- 2. Parse JSON vào bảng tạm
  
	-- Lưu ý: Sử dụng CREATE TEMP TABLE trong function cần cẩn thận với việc gọi nhiều lần trong 1 session
	-- Dùng DROP TABLE IF EXISTS để tránh lỗi "table already exists"
	DROP TABLE IF EXISTS tb_master_temp;
	CREATE TEMP TABLE tb_master_temp AS
	SELECT
		row_number() OVER (ORDER BY (j->>'no')) AS row_number,
		j->>'competition_code'  as competition_code,
		j->>'match_code'        as match_code,
		j->>'task_code'         as task_code,
		j->>'area_code'         as area_code,
		j->>'task_name_vi'      as task_name_vi,
		j->>'task_name_en'      as task_name_en,
		j->>'match_start_date'  as match_start_date,
		j->>'match_end_date'    as match_end_date,
		j->>'match_start_time'  as match_start_time,
		j->>'match_end_time'    as match_end_time,
		j->>'contents'          as contents,
		j->>'important_note'    as important_note,
		CAST('' AS TEXT) AS errordata
	FROM jsonb_array_elements(p_json_data->'sheets'->'Master') AS j;
	
	DROP TABLE IF EXISTS tb_detail_temp;
	CREATE TEMP TABLE tb_detail_temp AS
	SELECT
		row_number() OVER (ORDER BY (j->>'no')) AS row_number,
		j->>'task_code'              as task_code,
		j->>'person_in_charge_role'  as person_in_charge_role,
		j->>'person_in_charge'       as person_in_charge,
		j->>'phone_number'           as phone_number,
		j->>'task_description'       as task_description,
		CAST('' AS TEXT) AS errordata
	FROM jsonb_array_elements(p_json_data->'sheets'->'Detail') AS j;
	
	-- 3. Validate
	IF (SELECT COUNT(1) FROM tb_master_temp) = 0 THEN
		-- validate không có data Master
		p_return_code := 1;
		p_message := 'Common_msg_MustHaveOneRow,[Master]';
	ELSIF (SELECT COUNT(1) FROM tb_detail_temp) = 0 THEN
		-- validate không có data Detail
		p_return_code := 1;
		p_message := 'Common_msg_MustHaveOneRow,[Detail]';
	ELSE
		-- validate nghiệp vụ Master
		UPDATE tb_master_temp ms
		SET 
			errordata = CONCAT_WS('',
				-- competition_code: Required, phải tồn tại trong ms_competition_events
				fn_utils_validate_value('competition_code', ms.competition_code, 50, 'Required'),
				CASE WHEN ms.competition_code IS NOT NULL AND comp.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,competition_code' END,
				
				-- match_code: Required, phải tồn tại trong sr_match_schedules VÀ thuộc competition_code
				fn_utils_validate_value('match_code', ms.match_code, 50, 'Required'),
				CASE WHEN ms.match_code IS NOT NULL AND mtch.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,match_code' END,
				
				-- task_code: Required, IsCode, không trùng trong DB, không trùng trong file
				fn_utils_validate_value('task_code', ms.task_code, 50, 'Required', 'IsCode'),
				CASE WHEN exist.id IS NOT NULL THEN ';Common_msg_DataAlreadyExist,task_code' END,
				CASE WHEN (SELECT COUNT(1) FROM tb_master_temp chk WHERE chk.task_code = mst.task_code) > 1
				     THEN ';Common_msg_DataAlreadyExist,task_code' END,
				
				-- area_code: Optional, nếu nhập phải thuộc location của match
				fn_utils_validate_value('area_code', ms.area_code, 50),
				CASE WHEN ms.area_code IS NOT NULL AND TRIM(ms.area_code) <> '' AND locdt.id IS NULL
				     THEN ';Common_msg_DataNotExistOnSystem,area_code' END,
				
				-- task_name
				fn_utils_validate_value('task_name_vi', ms.task_name_vi, 255, 'Required'),
				fn_utils_validate_value('task_name_en', ms.task_name_en, 255),
				
				-- dates
				fn_utils_validate_value('match_start_date', ms.match_start_date, 10, 'IsDate'),
				fn_utils_validate_value('match_end_date', ms.match_end_date, 10, 'IsDate'),
				CASE WHEN ms.match_start_date IS NOT NULL AND TRIM(ms.match_start_date) <> ''
				      AND ms.match_end_date IS NOT NULL AND TRIM(ms.match_end_date) <> ''
				      AND TO_DATE(ms.match_start_date, 'DD/MM/YYYY') > TO_DATE(ms.match_end_date, 'DD/MM/YYYY')
				     THEN ';Common_msg_MustBeLessOrEqual,match_start_date,match_end_date' END,
				
				-- times
				fn_utils_validate_value('match_start_time', ms.match_start_time, 5, 'IsTime'),
				fn_utils_validate_value('match_end_time', ms.match_end_time, 5, 'IsTime'),
				-- Check time khi start_date = end_date
				CASE WHEN ms.match_start_date IS NOT NULL AND TRIM(ms.match_start_date) <> ''
				      AND ms.match_end_date IS NOT NULL AND TRIM(ms.match_end_date) <> ''
				      AND TO_DATE(ms.match_start_date, 'DD/MM/YYYY') = TO_DATE(ms.match_end_date, 'DD/MM/YYYY')
				      AND ms.match_start_time IS NOT NULL AND TRIM(ms.match_start_time) <> ''
				      AND ms.match_end_time IS NOT NULL AND TRIM(ms.match_end_time) <> ''
				      AND CAST(ms.match_start_time AS TIME) > CAST(ms.match_end_time AS TIME)
				     THEN ';Common_msg_MustBeLessOrEqual,match_start_time,match_end_time' END,
				
				-- other
				fn_utils_validate_value('contents', ms.contents, 500),
				fn_utils_validate_value('important_note', ms.important_note, 500)
			)
		FROM tb_master_temp mst
		LEFT JOIN ta_task_assignment exist    ON mst.task_code = exist.task_code
		LEFT JOIN ms_competition_events comp  ON mst.competition_code = comp.competition_code
		LEFT JOIN sr_match_schedules mtch     ON mst.match_code = mtch.match_code
		                                     AND mst.competition_code = mtch.competition_code
		LEFT JOIN ms_location_detail locdt   ON mtch.location_code = locdt.location_code
		                                     AND mst.area_code = locdt.area_code
		WHERE ms.row_number = mst.row_number;
		
		SELECT jsonb_agg(t) INTO v_err_master 
		FROM (SELECT * FROM tb_master_temp WHERE errordata <> '') t;

		-- Validate Detail
		UPDATE tb_detail_temp ds
		SET errordata = CONCAT_WS('',
			-- task_code: Required, phải tồn tại trong sheet Master
			fn_utils_validate_value('task_code', ds.task_code, 50, 'Required'),
			CASE WHEN mst.task_code IS NULL THEN ';Common_msg_DataNotExistOnSystem,task_code' END,
			
			-- person_in_charge_role: Optional (default '1'), validate sy_commons
			fn_utils_validate_value('person_in_charge_role', ds.person_in_charge_role, 50),
			CASE WHEN ds.person_in_charge_role IS NOT NULL AND TRIM(ds.person_in_charge_role) <> ''
			      AND syrole.id IS NULL
			     THEN ';Common_msg_DataNotExistOnSystem,person_in_charge_role' END,
			
			-- person_in_charge: Required, phải tồn tại trong ms_employees
			fn_utils_validate_value('person_in_charge', ds.person_in_charge, 50, 'Required'),
			CASE WHEN ds.person_in_charge IS NOT NULL AND emp.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,person_in_charge' END,
			
			-- phone_number
			fn_utils_validate_value('phone_number', ds.phone_number, 50),
			
			-- task_description
			fn_utils_validate_value('task_description', ds.task_description, 500)
		)
		FROM tb_detail_temp dst
		LEFT JOIN tb_master_temp mst   ON dst.task_code = mst.task_code
		LEFT JOIN ms_employees emp     ON dst.person_in_charge = emp.employee_code
		LEFT JOIN sy_commons syrole    ON syrole.value = dst.person_in_charge_role
		                              AND syrole.type = 'PERSONINCHARGE_ROLE'
		WHERE ds.row_number = dst.row_number;
		
		SELECT jsonb_agg(t) INTO v_err_detail 
		FROM (SELECT * FROM tb_detail_temp WHERE errordata <> '') t;
	END IF;
	
	-- 4. Kiểm tra nếu có lỗi
	IF p_return_code = 0 THEN
		-- trả lỗi
		IF v_err_master IS NOT NULL OR v_err_detail IS NOT NULL THEN
			p_return_code := 1;
			p_message := 'Common_msg_ImportInvalid';
			p_error_data := jsonb_strip_nulls(jsonb_build_object(
				'Master', v_err_master,
				'Detail', v_err_detail
			));
		-- không lỗi thực hiện insert
		ELSE 
			-- INSERT Master
			INSERT INTO ta_task_assignment(
				competition_code,
				match_code,
				task_code,
				area_code,
				task_name_vi,
				task_name_en,
				match_start_date,
				match_end_date,
				match_start_time,
				match_end_time,
				status,
				contents,
				important_note,
				created_by,
				created_date,
				updated_by,
				updated_date
			) SELECT
				competition_code,
				match_code,
				task_code,
				NULLIF(TRIM(area_code), ''),
				task_name_vi,
				COALESCE(NULLIF(TRIM(task_name_en), ''), task_name_vi),
				CASE WHEN match_start_date IS NOT NULL AND TRIM(match_start_date) <> '' THEN TO_DATE(match_start_date, 'DD/MM/YYYY') ELSE NULL END,
				CASE WHEN match_end_date IS NOT NULL AND TRIM(match_end_date) <> '' THEN TO_DATE(match_end_date, 'DD/MM/YYYY') ELSE NULL END,
				CASE WHEN match_start_time IS NOT NULL AND TRIM(match_start_time) <> '' THEN CAST(match_start_time AS TIME) ELSE NULL END,
				CASE WHEN match_end_time IS NOT NULL AND TRIM(match_end_time) <> '' THEN CAST(match_end_time AS TIME) ELSE NULL END,
				'1',
				NULLIF(TRIM(contents), ''),
				NULLIF(TRIM(important_note), ''),
				p_user_name,
				NOW(),
				p_user_name,
				NOW()
			FROM tb_master_temp
			ORDER BY row_number;

			-- INSERT Detail
			INSERT INTO ta_task_assignment_detail(
				task_code,
				person_in_charge,
				person_in_charge_role,
				phone_number,
				task_description,
				status,
				created_by,
				created_date,
				updated_by,
				updated_date
			) SELECT
				task_code,
				person_in_charge,
				COALESCE(NULLIF(TRIM(person_in_charge_role), ''), '1'),
				COALESCE(NULLIF(TRIM(dst.phone_number), ''), emp.phone_number) AS phone_number,
				COALESCE(NULLIF(TRIM(task_description), ''), ''),
				'1',
				p_user_name,
				NOW(),
				p_user_name,
				NOW()
			FROM tb_detail_temp dst
			LEFT JOIN ms_employees emp ON dst.person_in_charge = emp.employee_code
			ORDER BY dst.row_number;
			-- [HISTORY] Lưu lịch sử system history cho Import
            INSERT INTO public.sy_journals(module_code, function_code, user_name, data_id, action_code, action_date, ip_address, json_before, json_after)
            VALUES ('TaskTracking', 'TaTaskAssignment', p_user_name, NULL, 'IMPORT', CURRENT_TIMESTAMP, p_ip_address, NULL, p_json_data);
		END IF;
	END IF;
	
	-- Xóa bảng tạm sau khi dùng xong
	DROP TABLE IF EXISTS tb_master_temp;
	DROP TABLE IF EXISTS tb_detail_temp;
	
    -- Trả về dòng dữ liệu kết quả
    RETURN NEXT;

EXCEPTION WHEN OTHERS THEN
    -- Bẫy lỗi hệ thống
    p_return_code := 1;
    p_message := SQLERRM; --'Common_msg_AnErrorOccurred';
    p_error_data := '[]'::jsonb;
    RETURN NEXT;
END;
$$;


ALTER FUNCTION public.fn_import_tataskassignment(p_json_data jsonb, p_user_name character varying, p_ip_address character varying) OWNER TO sportevent;

--
-- TOC entry 985 (class 1255 OID 21738)
-- Name: fn_import_titicketprice(jsonb, character varying, character varying); Type: FUNCTION; Schema: public; Owner: sportevent
--

CREATE FUNCTION public.fn_import_titicketprice(p_json_data jsonb, p_user_name character varying, p_ip_address character varying) RETURNS TABLE(p_return_code integer, p_message text, p_error_data jsonb)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_err_master   jsonb := NULL;
    v_err_detail   jsonb := NULL;
BEGIN
	-- function name: import ticket price
	-- create by: tvtduy - 06/04/2026
	-- last modify by: xxx - xx/xx/xxxx
	
    -- 1. Khởi tạo mặc định
    p_return_code := 0;
    p_message := 'Common_msg_ImportSuccess';
    p_error_data := '[]'::jsonb;

    -- 2. Parse JSON vào bảng tạm
    DROP TABLE IF EXISTS tb_ticket_price_master_temp;
    CREATE TEMP TABLE tb_ticket_price_master_temp AS
    SELECT
        row_number() OVER (ORDER BY (j->>'no')) AS row_number,
        j->>'ticket_code'          AS ticket_code,
        j->>'competition_code'       AS competition_code,
        j->>'match_code'       AS match_code,
        j->>'status'  AS status,
        j->>'terms_and_conditions'          AS terms_and_conditions,
        j->>'is_highlights'          AS is_highlights,
        CAST('' AS TEXT)         AS errordata
    FROM jsonb_array_elements(COALESCE(p_json_data->'sheets'->'Import_General', '[]'::jsonb)) AS j;

    DROP TABLE IF EXISTS tb_ticket_price_detail_temp;
    CREATE TEMP TABLE tb_ticket_price_detail_temp AS
    SELECT
        row_number() OVER (ORDER BY (j->>'no')) AS row_number,
        j->>'ticket_code'           AS ticket_code,
        j->>'category_code'      AS category_code,
        j->>'total_tickets'      AS total_tickets,
        j->>'prices' AS prices,
        CAST('' AS TEXT)          AS errordata
    FROM jsonb_array_elements(COALESCE(p_json_data->'sheets'->'Import_Detail', '[]'::jsonb)) AS j;
    
    -- 3. Validate
    IF (SELECT COUNT(1) FROM tb_ticket_price_master_temp) = 0 THEN
        p_return_code := 1;
        p_message := 'Common_msg_MustHaveOneRow,[General]';	
    ELSE
        -- validate data
        UPDATE tb_ticket_price_master_temp ms
        SET errordata = CONCAT_WS('',
            fn_utils_validate_value('ticket_code', ms.ticket_code, 50, 'Required', 'IsCode'),
            CASE WHEN ti.id IS NOT NULL THEN ';Common_msg_DataAlreadyExist,ticket_code' END,
            CASE WHEN dup.cnt > 1 THEN ';Common_msg_DataDuplicate,ticket_code' END,

            fn_utils_validate_value('competition_code', ms.competition_code, 50, 'Required', 'IsCode'),
            CASE WHEN msc.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,competition_code' END,
            
            fn_utils_validate_value('match_code', ms.match_code, 50, 'Required', 'IsCode'),
            CASE WHEN srm.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,match_code' END,

			CASE WHEN COALESCE(ms.status,'') <> '' AND ms.status NOT IN ('0','1') THEN ';Common_msg_DataNotExistOnSystem,status' END,

            CASE WHEN msl.id IS NOT NULL AND COALESCE(NULLIF(ms.status, ''), '1') = '1' AND msl.location_size <= 0 THEN ';TiTicketPrice_msg_location_must_has_location_size, match_code' END,
			
            CASE WHEN msl.id IS NOT NULL AND COALESCE(NULLIF(ms.status, ''), '1') = '1' AND msl.location_file_1 IS NULL THEN ';TiTicketPrice_msg_location_must_has_image, match_code' END,

			CASE WHEN COALESCE(ms.is_highlights,'') <> '' AND ms.is_highlights NOT IN ('0','1') THEN ';Common_msg_DataNotExistOnSystem,is_highlights' END,
				
	    	fn_utils_validate_value('terms_and_conditions', ms.terms_and_conditions, 500)
        )
        FROM tb_ticket_price_master_temp tp
        LEFT JOIN ti_ticket_price ti ON tp.ticket_code = ti.ticket_code
        LEFT JOIN ms_competition_events msc ON tp.competition_code = msc.competition_code
        LEFT JOIN sr_match_schedules srm ON tp.match_code = srm.match_code AND msc.competition_code = srm.competition_code
        LEFT JOIN ms_locations msl ON srm.location_code = msl.location_code
        LEFT JOIN sy_commons sy ON tp.status = sy.value AND sy.type = 'COMMON_STATUS'
        LEFT JOIN ( SELECT ticket_code, COUNT(1) AS cnt FROM tb_ticket_price_master_temp GROUP BY ticket_code ) dup ON tp.ticket_code = dup.ticket_code
        WHERE ms.row_number = tp.row_number;	
        
            SELECT jsonb_agg(t) INTO v_err_master
            FROM (
                SELECT *
                FROM tb_ticket_price_master_temp
                WHERE COALESCE(errordata, '') <> ''
                ORDER BY row_number
            ) t;
    END IF;
	
	IF (SELECT COUNT(1) FROM tb_ticket_price_detail_temp) = 0 THEN
	    p_return_code := 1;
	    p_message := 'Common_msg_MustHaveOneRow,[Detail]';
	ELSE
	    UPDATE tb_ticket_price_detail_temp dt
            SET errordata = CONCAT_WS('',
                fn_utils_validate_value('ticket_code', dt.ticket_code, 50, 'Required', 'IsCode'),
                CASE WHEN tpd.ticket_code IS NULL THEN ';Common_msg_DataNotExistOnSystem,ticket_code' END,

	            fn_utils_validate_value('category_code', dt.category_code, 50, 'Required', 'IsCode'),
	            CASE WHEN mst.id IS NULL THEN ';Common_msg_DataNotExistOnSystem,category_code' END,
				
	            fn_utils_validate_value('total_tickets', dt.total_tickets, 11, 'Required', 'IsNumber'),
				CASE WHEN (dt.total_tickets::integer) < 0 THEN ';Common_msg_MustBeGreaterThan,total_tickets,0' END,
				
	            fn_utils_validate_value('prices', dt.prices, 15, 'Required', 'IsNumber'),
				CASE WHEN (dt.prices::numeric) < 0 THEN ';Common_msg_MustBeGreaterThan,prices,0' END,
				
                CASE WHEN dup.cnt > 1 THEN ';Common_msg_AlreadyExists,category_code' END
            )
            FROM tb_ticket_price_detail_temp tpd
            LEFT JOIN tb_ticket_price_master_temp tp ON tpd.ticket_code = tp.ticket_code
            LEFT JOIN ms_ticket_categories mst ON tpd.category_code = mst.category_code AND tp.competition_code = mst.competition_code
            LEFT JOIN ( SELECT ticket_code, category_code, COUNT(1) AS cnt FROM tb_ticket_price_detail_temp GROUP BY ticket_code, category_code ) dup ON tpd.ticket_code = dup.ticket_code AND tpd.category_code = dup.category_code
            WHERE dt.row_number = tpd.row_number;

            SELECT jsonb_agg(t) INTO v_err_detail
            FROM (
                SELECT *
                FROM tb_ticket_price_detail_temp
                WHERE COALESCE(errordata, '') <> ''
                ORDER BY row_number
            ) t;
	END IF;
    -- 4. Kiểm tra lỗi
    IF p_return_code = 0 THEN
        IF v_err_master IS NOT NULL OR v_err_detail IS NOT NULL THEN
            p_return_code := 1;
            p_message := 'Common_msg_ImportInvalid';
            p_error_data := jsonb_strip_nulls(
                jsonb_build_object(
                    'General', v_err_master,
                    'Detail', v_err_detail
                )
            );
        ELSE
            -- insert master
			INSERT INTO ti_ticket_price (
				ticket_code,
				competition_code,
				match_code,
				status,
				terms_and_conditions,
				is_highlights,
				created_by,
				created_date,
				updated_by,
				updated_date
			)
			SELECT
				m.ticket_code,
				m.competition_code,
				m.match_code,
				COALESCE(NULLIF(m.status, ''), '1'),
				m.terms_and_conditions,
				CASE WHEN m.is_highlights = '1' THEN TRUE ELSE FALSE END,
				p_user_name,
				NOW(),
				p_user_name,
				NOW()
			FROM tb_ticket_price_master_temp m
			ORDER BY m.row_number;

            -- insert detail
            IF (SELECT COUNT(1) FROM tb_ticket_price_detail_temp) > 0 THEN
                INSERT INTO ti_ticket_detail (
                    ticket_code,
                    category_code,
                    total_tickets,
                    prices,
                    created_by,
                    created_date,
                    updated_by,
                    updated_date
                )
				SELECT
					d.ticket_code,
					d.category_code,
                    (d.total_tickets::integer),
                    (d.prices::numeric),
					p_user_name,
					NOW(),
					p_user_name,
					NOW()
				FROM tb_ticket_price_detail_temp d
				ORDER BY d.row_number;
				-- [HISTORY] Lưu lịch sử system history cho Import
            	INSERT INTO public.sy_journals(module_code, function_code, user_name, data_id, action_code, action_date, ip_address, json_before, json_after)
            	VALUES ('TicketManagement', 'TiTicketPrice', p_user_name, NULL, 'IMPORT', CURRENT_TIMESTAMP, p_ip_address, NULL, p_json_data);
            END IF;
        END IF;
    END IF;

    -- xóa bảng tạm
    DROP TABLE IF EXISTS tb_ticket_price_master_temp;
    DROP TABLE IF EXISTS tb_ticket_price_detail_temp;

    RETURN NEXT;

EXCEPTION WHEN OTHERS THEN
    p_return_code := 1;
    p_message := SQLERRM;
    p_error_data := '[]'::jsonb;
    RETURN NEXT;
END;
$$;


ALTER FUNCTION public.fn_import_titicketprice(p_json_data jsonb, p_user_name character varying, p_ip_address character varying) OWNER TO sportevent;

--
-- TOC entry 848 (class 1255 OID 22635)
-- Name: fn_listdata_action(character varying, character varying, json, character varying, integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: sportevent
--

CREATE FUNCTION public.fn_listdata_action(p_search_text character varying, p_search_code character varying, p_option_json json, p_lang_code character varying, p_from_row integer, p_take_row integer, p_username character varying) RETURNS json
    LANGUAGE sql
    AS $$
	-- fn_listdata_action: lấy danh sách dữ liệu action
	-- create by: vdthanh - 09/04/2026
	-- last modify by: vdthanh - 21/04/2026: thêm localize theo p_lang_code
WITH filtered_data AS (
    SELECT
        sfa.code AS code,
        COALESCE(translated.languagevalue, origin.defaultvalue, sfa.description) AS display_name
    FROM sy_function_actions sfa
    LEFT JOIN sy_res_resourcecontrols origin
        ON origin.name = sfa.resourcecontrolname
    LEFT JOIN sy_res_resourcecontrols_translated translated
        ON translated.languagename = sfa.resourcecontrolname
        AND translated.languagecode = p_lang_code
    WHERE (
            NULLIF(p_search_text, '') IS NULL
            OR COALESCE(translated.languagevalue, origin.defaultvalue, sfa.description) ILIKE '%' || p_search_text || '%'
          )
      AND (
            NULLIF(p_search_code, '') IS NULL
            OR sfa.code = p_search_code
          )
),
total_count AS (
    SELECT COUNT(*) AS total_row
    FROM filtered_data
),
paged_data AS (
    SELECT *
    FROM filtered_data
    ORDER BY code
    OFFSET GREATEST(COALESCE(p_from_row, 0), 0)
    LIMIT GREATEST(COALESCE(p_take_row, 20), 1)
)
SELECT json_build_object(
    'item1', COALESCE((
        SELECT json_agg(
            json_build_object(
                'code', code,
                'name', display_name
            )
        )
        FROM paged_data
    ), '[]'::json),
    'item2', (
        SELECT json_build_object(
            'pageSize', GREATEST(COALESCE(p_take_row, 20), 1),
            'totalRow', total_row
        )
        FROM total_count
    )
);
$$;


ALTER FUNCTION public.fn_listdata_action(p_search_text character varying, p_search_code character varying, p_option_json json, p_lang_code character varying, p_from_row integer, p_take_row integer, p_username character varying) OWNER TO sportevent;

--
-- TOC entry 1003 (class 1255 OID 16871)
-- Name: fn_listdata_common(character varying, character varying, character varying, json, character varying, integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: sportevent
--

CREATE FUNCTION public.fn_listdata_common(p_data_type character varying, p_search_text character varying, p_search_code character varying, p_option_json json, p_lang_code character varying, p_from_row integer, p_take_row integer, p_username character varying) RETURNS json
    LANGUAGE sql
    AS $$
	-- function name: lấy danh sách dữ liệu trên bảng common dựa vào type
	-- create by: tmtam - 01/04/2026
	-- last modify by: xxx - xx/xx/xxxx
WITH filtered_data AS (
    SELECT
        sc.value,
        CASE
            WHEN COALESCE(p_lang_code, 'vi') = 'en' THEN COALESCE(sc.name_en, sc.name_vi)
            ELSE sc.name_vi
        END AS display_name,
		sc.sort
    FROM sy_commons sc
    WHERE sc.type = p_data_type
      AND (
            NULLIF(p_search_text, '') IS NULL
            OR sc.name_vi ILIKE '%' || p_search_text || '%'
            OR sc.name_en ILIKE '%' || p_search_text || '%'
          )
      AND (
            NULLIF (p_search_code, '') IS NULL
            OR sc.value = p_search_code
          )
),
total_count AS (
    SELECT COUNT(*) AS total_row
    FROM filtered_data
),
paged_data AS (
    SELECT *
    FROM filtered_data
    ORDER BY sort
    OFFSET GREATEST(COALESCE(p_from_row, 0), 0)
    LIMIT GREATEST(COALESCE(p_take_row, 20), 1)
)
SELECT json_build_object(
    'item1', COALESCE((
        SELECT json_agg(
            json_build_object(
                'code', value,
                'name', display_name
            )
        )
        FROM paged_data
    ), '[]'::json),
    'item2', (
        SELECT json_build_object(
            'pageSize', GREATEST(COALESCE(p_take_row, 20), 1),
            'totalRow', total_row
        )
        FROM total_count
    )
);
$$;


ALTER FUNCTION public.fn_listdata_common(p_data_type character varying, p_search_text character varying, p_search_code character varying, p_option_json json, p_lang_code character varying, p_from_row integer, p_take_row integer, p_username character varying) OWNER TO sportevent;

--
-- TOC entry 914 (class 1255 OID 22634)
-- Name: fn_listdata_function(character varying, character varying, json, character varying, integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: sportevent
--

CREATE FUNCTION public.fn_listdata_function(p_search_text character varying, p_search_code character varying, p_option_json json, p_lang_code character varying, p_from_row integer, p_take_row integer, p_username character varying) RETURNS json
    LANGUAGE sql
    AS $$
	-- fn_listdata_function: lấy danh sách dữ liệu function
	-- create by: vdthanh - 09/04/2026
	-- last modify by: vdthanh - 21/04/2026: thêm localize theo p_lang_code
WITH filtered_data AS (
    SELECT
        sf.code AS code,
        COALESCE(translated.languagevalue, origin.defaultvalue, sf.description) AS display_name
    FROM sy_functions sf
    LEFT JOIN sy_res_resourcecontrols origin
        ON origin.name = sf.resourcecontrolname
    LEFT JOIN sy_res_resourcecontrols_translated translated
        ON translated.languagename = sf.resourcecontrolname
        AND translated.languagecode = p_lang_code
    WHERE (
            NULLIF(p_search_text, '') IS NULL
            OR COALESCE(translated.languagevalue, origin.defaultvalue, sf.description) ILIKE '%' || p_search_text || '%'
          )
      AND (
            NULLIF(p_search_code, '') IS NULL
            OR sf.code = p_search_code
          )
),
total_count AS (
    SELECT COUNT(*) AS total_row
    FROM filtered_data
),
paged_data AS (
    SELECT *
    FROM filtered_data
    ORDER BY code
    OFFSET GREATEST(COALESCE(p_from_row, 0), 0)
    LIMIT GREATEST(COALESCE(p_take_row, 20), 1)
)
SELECT json_build_object(
    'item1', COALESCE((
        SELECT json_agg(
            json_build_object(
                'code', code,
                'name', display_name
            )
        )
        FROM paged_data
    ), '[]'::json),
    'item2', (
        SELECT json_build_object(
            'pageSize', GREATEST(COALESCE(p_take_row, 20), 1),
            'totalRow', total_row
        )
        FROM total_count
    )
);
$$;


ALTER FUNCTION public.fn_listdata_function(p_search_text character varying, p_search_code character varying, p_option_json json, p_lang_code character varying, p_from_row integer, p_take_row integer, p_username character varying) OWNER TO sportevent;

--
-- TOC entry 865 (class 1255 OID 18217)
-- Name: fn_listdata_mscompetitionevents(character varying, character varying, json, character varying, integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: sportevent
--

CREATE FUNCTION public.fn_listdata_mscompetitionevents(p_search_text character varying, p_search_code character varying, p_option_json json, p_lang_code character varying, p_from_row integer, p_take_row integer, p_username character varying) RETURNS json
    LANGUAGE sql
    AS $$
WITH filtered_data AS (
    SELECT
        ms.competition_code as code,
        CASE
            WHEN COALESCE(p_lang_code, 'vi') = 'en' THEN COALESCE(ms.competition_name_en, ms.competition_name_vi)
            ELSE ms.competition_name_vi
        END AS display_name
    FROM ms_competition_events ms
    WHERE (
            NULLIF(p_search_text, '') IS NULL
            OR ms.competition_name_en ILIKE '%' || p_search_text || '%'
            OR ms.competition_name_vi ILIKE '%' || p_search_text || '%'
          )
      AND (
            NULLIF (p_search_code, '') IS NULL
            OR ms.competition_code = p_search_code
          )
),
total_count AS (
    SELECT COUNT(*) AS total_row
    FROM filtered_data
),
paged_data AS (
    SELECT *
    FROM filtered_data
    ORDER BY code
    OFFSET GREATEST(COALESCE(p_from_row, 0), 0)
    LIMIT GREATEST(COALESCE(p_take_row, 20), 1)
)
SELECT json_build_object(
    'item1', COALESCE((
        SELECT json_agg(
            json_build_object(
                'code', code,
                'name', display_name
            )
        )
        FROM paged_data
    ), '[]'::json),
    'item2', (
        SELECT json_build_object(
            'pageSize', GREATEST(COALESCE(p_take_row, 20), 1),
            'totalRow', total_row
        )
        FROM total_count
    )
);
$$;


ALTER FUNCTION public.fn_listdata_mscompetitionevents(p_search_text character varying, p_search_code character varying, p_option_json json, p_lang_code character varying, p_from_row integer, p_take_row integer, p_username character varying) OWNER TO sportevent;

--
-- TOC entry 1000 (class 1255 OID 18779)
-- Name: fn_listdata_msemployees(character varying, character varying, json, character varying, integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: sportevent
--

CREATE FUNCTION public.fn_listdata_msemployees(p_search_text character varying, p_search_code character varying, p_option_json json, p_lang_code character varying, p_from_row integer, p_take_row integer, p_username character varying) RETURNS json
    LANGUAGE sql
    AS $$
	-- function name: lấy danh sách thông tin email thành viên
	-- create by: lthngoc - 01/04/2026
	-- last modify by: lthngoc - 03/04/2026
WITH filtered_data AS (
    SELECT
        ms.employee_code as code,
        CASE
            WHEN COALESCE(p_lang_code, 'vi') = 'en' THEN COALESCE(ms.employee_name_vi, ms.employee_name_en)
            ELSE ms.employee_name_vi
        END AS display_name,
		COALESCE(ms.email, '') AS email,
		
		CASE
            WHEN COALESCE(p_lang_code, 'vi') = 'en' THEN COALESCE(sy.name_vi, sy.name_en)
            ELSE sy.name_vi
        END AS employee_status,
		
		CASE
            WHEN COALESCE(p_lang_code, 'vi') = 'en' THEN COALESCE(syp.name_vi, syp.name_en)
            ELSE syp.name_vi
        END AS position_code,
		
		ms.phone_number
    FROM ms_employees ms
	LEFT JOIN sy_commons sy ON sy.value = ms.employee_status AND sy.type = 'EMPLOYEE_STATUS'
	LEFT JOIN sy_commons syp ON syp.value = ms.position_code AND syp.type = 'ATHLETE_POSITION'
    WHERE (
            NULLIF(p_search_text, '') IS NULL
            OR ms.employee_name_vi ILIKE '%' || p_search_text || '%'
            OR ms.employee_name_en ILIKE '%' || p_search_text || '%'
          )
      AND (
            NULLIF (p_search_code, '') IS NULL
            OR ms.employee_code = p_search_code
          )
      AND (
            NULLIF (p_option_json ->> 'employee_type', '') IS NULL
            OR ms.employee_type = p_option_json ->> 'employee_type'
          )
),
total_count AS (
    SELECT COUNT(*) AS total_row
    FROM filtered_data
),
paged_data AS (
    SELECT *
    FROM filtered_data
    ORDER BY code
    OFFSET GREATEST(COALESCE(p_from_row, 0), 0)
    LIMIT GREATEST(COALESCE(p_take_row, 20), 1)
)
SELECT json_build_object(
    'item1', COALESCE((
        SELECT json_agg(
            json_build_object(
                'code', code,
                'name', display_name,
				'email', email,
				'phone_number', phone_number,
				'employee_status', employee_status,
				'position_code' , position_code
            )
        )
        FROM paged_data
    ), '[]'::json),
    'item2', (
        SELECT json_build_object(
            'pageSize', GREATEST(COALESCE(p_take_row, 20), 1),
            'totalRow', total_row
        )
        FROM total_count
    )
);
$$;


ALTER FUNCTION public.fn_listdata_msemployees(p_search_text character varying, p_search_code character varying, p_option_json json, p_lang_code character varying, p_from_row integer, p_take_row integer, p_username character varying) OWNER TO sportevent;

--
-- TOC entry 943 (class 1255 OID 19777)
-- Name: fn_listdata_mslocationdetail(character varying, character varying, json, character varying, integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: sportevent
--

CREATE FUNCTION public.fn_listdata_mslocationdetail(p_search_text character varying, p_search_code character varying, p_option_json json, p_lang_code character varying, p_from_row integer, p_take_row integer, p_username character varying) RETURNS json
    LANGUAGE sql
    AS $$
WITH filtered_data AS (
    SELECT
        lc.area_code AS code,
        CASE
        	WHEN COALESCE(p_lang_code, 'vi') = 'en' THEN COALESCE(lc.area_name_en, lc.area_name_vi)
            ELSE lc.area_name_vi
        END AS display_name
    FROM ms_location_detail lc
    WHERE (
            NULLIF(p_search_text, '') IS NULL
            OR lc.area_name_vi ILIKE '%' || p_search_text || '%'
            OR lc.area_name_en ILIKE '%' || p_search_text || '%'
          )
      AND (
            NULLIF(p_search_code, '') IS NULL
            OR lc.area_code = p_search_code
          )
	  AND (
	  		p_option_json ->> 'location_code' IS NULL
            OR lc.location_code = p_option_json ->> 'location_code'
          )
),
total_count AS (
    SELECT COUNT(*) AS total_row
    FROM filtered_data
),
paged_data AS (
    SELECT *
    FROM filtered_data
    ORDER BY code
    OFFSET GREATEST(COALESCE(p_from_row, 0), 0)
    LIMIT GREATEST(COALESCE(p_take_row, 20), 1)
)
SELECT json_build_object(
    'item1', COALESCE((
        SELECT json_agg(
            json_build_object(
                'code', code,
                'name', display_name
            )
        )
        FROM paged_data
    ), '[]'::json),
    'item2', (
        SELECT json_build_object(
            'pageSize', GREATEST(COALESCE(p_take_row, 20), 1),
            'totalRow', total_row
        )
        FROM total_count
    )
);
$$;


ALTER FUNCTION public.fn_listdata_mslocationdetail(p_search_text character varying, p_search_code character varying, p_option_json json, p_lang_code character varying, p_from_row integer, p_take_row integer, p_username character varying) OWNER TO sportevent;

--
-- TOC entry 857 (class 1255 OID 19534)
-- Name: fn_listdata_mslocations(character varying, character varying, json, character varying, integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: sportevent
--

CREATE FUNCTION public.fn_listdata_mslocations(p_search_text character varying, p_search_code character varying, p_option_json json, p_lang_code character varying, p_from_row integer, p_take_row integer, p_username character varying) RETURNS json
    LANGUAGE sql
    AS $$
WITH filtered_data AS (
    SELECT
        lc.location_code AS code,
        CASE
        	WHEN COALESCE(p_lang_code, 'vi') = 'en' THEN COALESCE(lc.location_name_en, lc.location_name_vi)
            ELSE lc.location_name_vi
        END AS display_name,
		lc.address AS address,
		lc.location_size AS location_size,
		lc.open_time || ' ~ ' || lc.close_time AS location_time
    FROM ms_locations lc
    WHERE (
            NULLIF(p_search_text, '') IS NULL
            OR lc.location_name_vi ILIKE '%' || p_search_text || '%'
            OR lc.location_name_en ILIKE '%' || p_search_text || '%'
          )
      AND (
            NULLIF(p_search_code, '') IS NULL
            OR lc.location_code = p_search_code
          )
),
total_count AS (
    SELECT COUNT(*) AS total_row
    FROM filtered_data
),
paged_data AS (
    SELECT *
    FROM filtered_data
    ORDER BY code
    OFFSET GREATEST(COALESCE(p_from_row, 0), 0)
    LIMIT GREATEST(COALESCE(p_take_row, 20), 1)
)
SELECT json_build_object(
    'item1', COALESCE((
        SELECT json_agg(
            json_build_object(
                'code', code,
                'name', display_name,
				'address', address,
				'location_size', location_size,
				'open_time', location_time
            )
        )
        FROM paged_data
    ), '[]'::json),
    'item2', (
        SELECT json_build_object(
            'pageSize', GREATEST(COALESCE(p_take_row, 20), 1),
            'totalRow', total_row
        )
        FROM total_count
    )
);
$$;


ALTER FUNCTION public.fn_listdata_mslocations(p_search_text character varying, p_search_code character varying, p_option_json json, p_lang_code character varying, p_from_row integer, p_take_row integer, p_username character varying) OWNER TO sportevent;

--
-- TOC entry 927 (class 1255 OID 19674)
-- Name: fn_listdata_msposition(character varying, character varying, json, character varying, integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: sportevent
--

CREATE FUNCTION public.fn_listdata_msposition(p_search_text character varying, p_search_code character varying, p_option_json json, p_lang_code character varying, p_from_row integer, p_take_row integer, p_username character varying) RETURNS json
    LANGUAGE sql
    AS $$
	-- function name: lấy danh sách dữ liệu chức vụ/vị trí từ sy_commons
	-- create by: tmtam - 03/04/2026
	-- last modify by: xxx - xx/xx/xxxx
WITH filtered_data AS (
    SELECT
        ms.value as code,
        CASE
            WHEN COALESCE(p_lang_code, 'vi') = 'en' THEN COALESCE(ms.name_en, ms.name_vi)
            ELSE ms.name_vi
        END AS display_name,
		sort
    FROM sy_commons ms
    WHERE ms.type IN ('REFEREE_POSITION', 'ATHLETE_POSITION', 'COACH_ROLE', 'PERSONINCHARGE_ROLE')
		AND (
			NULLIF(p_search_text, '') IS NULL
			OR ms.name_vi ILIKE '%' || p_search_text || '%'
			OR ms.name_en ILIKE '%' || p_search_text || '%'
			)
		AND (
			NULLIF (p_search_code, '') IS NULL
			OR ms.value = p_search_code
		  )
      AND (
           NULLIF (p_option_json ->> 'position_type', '') IS NULL

		    OR ms.type = ANY(
		        string_to_array(
		            p_option_json ->> 'position_type',
		            ','
		        )
		    )
          )
),
total_count AS (
    SELECT COUNT(*) AS total_row
    FROM filtered_data
),
paged_data AS (
    SELECT *
    FROM filtered_data
    ORDER BY sort
    OFFSET GREATEST(COALESCE(p_from_row, 0), 0)
    LIMIT GREATEST(COALESCE(p_take_row, 20), 1)
)
SELECT json_build_object(
    'item1', COALESCE((
        SELECT json_agg(
            json_build_object(
                'code', code,
                'name', display_name
            )
        )
        FROM paged_data
    ), '[]'::json),
    'item2', (
        SELECT json_build_object(
            'pageSize', GREATEST(COALESCE(p_take_row, 20), 1),
            'totalRow', total_row
        )
        FROM total_count
    )
);
$$;


ALTER FUNCTION public.fn_listdata_msposition(p_search_text character varying, p_search_code character varying, p_option_json json, p_lang_code character varying, p_from_row integer, p_take_row integer, p_username character varying) OWNER TO sportevent;

--
-- TOC entry 988 (class 1255 OID 19535)
-- Name: fn_listdata_mssportdetail(character varying, character varying, json, character varying, integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: sportevent
--

CREATE FUNCTION public.fn_listdata_mssportdetail(p_search_text character varying, p_search_code character varying, p_option_json json, p_lang_code character varying, p_from_row integer, p_take_row integer, p_username character varying) RETURNS json
    LANGUAGE sql
    AS $$
    -- function name: lấy danh sách dữ liệu nội dung thi đấu
    -- create by: tmtam - 01/04/2026
    -- last modify by: Codex - 24/04/2026
WITH filtered_data AS (
    SELECT
        sd.sport_event_code AS code,
        CASE
            WHEN COALESCE(NULLIF(p_lang_code, ''), 'vi') = 'en'
                THEN COALESCE(NULLIF(BTRIM(sd.sport_event_name_en), ''), sd.sport_event_name_vi)
            ELSE sd.sport_event_name_vi
        END AS display_name
    FROM ms_sport_detail sd
    WHERE (
            NULLIF(p_search_text, '') IS NULL
            OR sd.sport_event_name_vi ILIKE '%' || p_search_text || '%'
            OR COALESCE(NULLIF(BTRIM(sd.sport_event_name_en), ''), sd.sport_event_name_vi) ILIKE '%' || p_search_text || '%'
          )
      AND (
            NULLIF(p_search_code, '') IS NULL
            OR sd.sport_event_code = p_search_code
          )
      AND (
            NULLIF(p_option_json ->> 'sport_code', '') IS NULL
            OR sd.sport_code = p_option_json ->> 'sport_code'
          )
),
total_count AS (
    SELECT COUNT(*) AS total_row
    FROM filtered_data
),
paged_data AS (
    SELECT *
    FROM filtered_data
    ORDER BY code
    OFFSET GREATEST(COALESCE(p_from_row, 0), 0)
    LIMIT GREATEST(COALESCE(p_take_row, 20), 1)
)
SELECT json_build_object(
    'item1', COALESCE((
        SELECT json_agg(
            json_build_object(
                'code', code,
                'name', display_name
            )
        )
        FROM paged_data
    ), '[]'::json),
    'item2', (
        SELECT json_build_object(
            'pageSize', GREATEST(COALESCE(p_take_row, 20), 1),
            'totalRow', total_row
        )
        FROM total_count
    )
);
$$;


ALTER FUNCTION public.fn_listdata_mssportdetail(p_search_text character varying, p_search_code character varying, p_option_json json, p_lang_code character varying, p_from_row integer, p_take_row integer, p_username character varying) OWNER TO sportevent;

--
-- TOC entry 902 (class 1255 OID 17923)
-- Name: fn_listdata_mssports(character varying, character varying, json, character varying, integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: sportevent
--

CREATE FUNCTION public.fn_listdata_mssports(p_search_text character varying, p_search_code character varying, p_option_json json, p_lang_code character varying, p_from_row integer, p_take_row integer, p_username character varying) RETURNS json
    LANGUAGE sql
    AS $$
    -- function name: get list data sports
    -- create by: tmtam - 01/04/2026
WITH filtered_data AS (
    SELECT
        ms.sport_code as code,
        CASE
            WHEN COALESCE(p_lang_code, 'vi') = 'en' THEN COALESCE(ms.sport_name_en, ms.sport_name_vi)
            ELSE ms.sport_name_vi
        END AS display_name
    FROM ms_sports ms
    WHERE (
            NULLIF(p_search_text, '') IS NULL
            OR ms.sport_name_vi ILIKE '%' || p_search_text || '%'
            OR ms.sport_name_en ILIKE '%' || p_search_text || '%'
          )
      AND (
            NULLIF (p_search_code, '') IS NULL
            OR ms.sport_code = p_search_code
          )
      AND (
            NULLIF(p_option_json ->> 'competition_code', '') IS NULL
            OR ms.sport_code IN (
                SELECT DISTINCT se.sport_code
                FROM ms_sport_events se
                WHERE se.competition_code = p_option_json ->> 'competition_code'
            )
          )
),
total_count AS (
    SELECT COUNT(*) AS total_row
    FROM filtered_data
),
paged_data AS (
    SELECT *
    FROM filtered_data
    ORDER BY display_name
    OFFSET GREATEST(COALESCE(p_from_row, 0), 0)
    LIMIT GREATEST(COALESCE(p_take_row, 20), 1)
)
SELECT json_build_object(
    'item1', COALESCE((
        SELECT json_agg(
            json_build_object(
                'code', code,
                'name', display_name
            )
        )
        FROM paged_data
    ), '[]'::json),
    'item2', (
        SELECT json_build_object(
            'pageSize', GREATEST(COALESCE(p_take_row, 20), 1),
            'totalRow', total_row
        )
        FROM total_count
    )
);
$$;


ALTER FUNCTION public.fn_listdata_mssports(p_search_text character varying, p_search_code character varying, p_option_json json, p_lang_code character varying, p_from_row integer, p_take_row integer, p_username character varying) OWNER TO sportevent;

--
-- TOC entry 968 (class 1255 OID 19533)
-- Name: fn_listdata_msteams(character varying, character varying, json, character varying, integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: sportevent
--

CREATE FUNCTION public.fn_listdata_msteams(p_search_text character varying, p_search_code character varying, p_option_json json, p_lang_code character varying, p_from_row integer, p_take_row integer, p_username character varying) RETURNS json
    LANGUAGE sql
    AS $$
	-- function name: lấy danh sách dữ liệu tên đội tuyển
	-- create by: lthngoc - 01/04/2026
	-- last modify by: xxx - xx/xx/xxxx
WITH filtered_data AS (
    SELECT
        mt.team_code AS code,
        CASE
        	WHEN COALESCE(p_lang_code, 'vi') = 'en' THEN COALESCE(mt.team_name_en, mt.team_name_vi)
            ELSE mt.team_name_vi
        END AS display_name,
		mt.sports_delegation,
		mtc.coach_names
    FROM ms_teams mt
	LEFT JOIN (
		SELECT 
			tc.team_code,
			CASE
	        	WHEN COALESCE(p_lang_code, 'vi') = 'en' THEN 
					STRING_AGG(DISTINCT e.employee_name_en, ', ')
	            ELSE STRING_AGG(DISTINCT e.employee_name_vi, ', ')
	        END AS coach_names
		FROM ms_team_coachs tc
		LEFT JOIN ms_employees e ON tc.emp_coach_code = e.employee_code
		GROUP BY tc.team_code
	) mtc ON mt.team_code = mtc.team_code
    WHERE (
            NULLIF(p_search_text, '') IS NULL
            OR mt.team_name_vi ILIKE '%' || p_search_text || '%'
            OR mt.team_name_en ILIKE '%' || p_search_text || '%'
          )
      AND (
            NULLIF(p_search_code, '') IS NULL
            OR mt.team_code = p_search_code
          )
),
total_count AS (
    SELECT COUNT(*) AS total_row
    FROM filtered_data
),
paged_data AS (
    SELECT *
    FROM filtered_data
    ORDER BY code
    OFFSET GREATEST(COALESCE(p_from_row, 0), 0)
    LIMIT GREATEST(COALESCE(p_take_row, 20), 1)
)
SELECT json_build_object(
    'item1', COALESCE((
        SELECT json_agg(
            json_build_object(
                'code', code,
                'name', display_name,
				'sports_delegation', sports_delegation,
				'coachs', coach_names
            )
        )
        FROM paged_data
    ), '[]'::json),
    'item2', (
        SELECT json_build_object(
            'pageSize', GREATEST(COALESCE(p_take_row, 20), 1),
            'totalRow', total_row
        )
        FROM total_count
    )
);
$$;


ALTER FUNCTION public.fn_listdata_msteams(p_search_text character varying, p_search_code character varying, p_option_json json, p_lang_code character varying, p_from_row integer, p_take_row integer, p_username character varying) OWNER TO sportevent;

--
-- TOC entry 987 (class 1255 OID 19973)
-- Name: fn_listdata_msticketcategories(character varying, character varying, json, character varying, integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: sportevent
--

CREATE FUNCTION public.fn_listdata_msticketcategories(p_search_text character varying, p_search_code character varying, p_option_json json, p_lang_code character varying, p_from_row integer, p_take_row integer, p_username character varying) RETURNS json
    LANGUAGE sql
    AS $$
	-- function name: lấy danh sách dữ liệu hạng mục vé
	-- create by: tvtduy - 05/04/2026
	-- last modify by: xxx - xx/xx/xxxx
WITH filtered_data AS (
    SELECT
        ms.category_code AS CODE,
        CASE
            WHEN COALESCE(p_lang_code, 'vi') = 'en' THEN COALESCE(ms.category_name_en, ms.category_name_vi)
            ELSE ms.category_name_vi
        END AS display_name
    FROM ms_ticket_categories ms
    WHERE (
            NULLIF(p_search_text, '') IS NULL
            OR ms.category_name_vi ILIKE '%' || p_search_text || '%'
            OR ms.category_name_en ILIKE '%' || p_search_text || '%'
          )
      AND (
            NULLIF (p_search_code, '') IS NULL
            OR ms.category_code = p_search_code
          )
      AND (
            p_option_json->>'competition_code' IS NULL
            OR ms.competition_code = p_option_json->>'competition_code'
          )
),
total_count AS (
    SELECT COUNT(*) AS total_row
    FROM filtered_data
),
paged_data AS (
    SELECT *
    FROM filtered_data
    ORDER BY CODE
    OFFSET GREATEST(COALESCE(p_from_row, 0), 0)
    LIMIT GREATEST(COALESCE(p_take_row, 20), 1)
)
SELECT json_build_object(
    'item1', COALESCE((
        SELECT json_agg(
            json_build_object(
                'code', CODE,
                'name', display_name
            )
        )
        FROM paged_data
    ), '[]'::JSON),
    'item2', (
        SELECT json_build_object(
            'pageSize', GREATEST(COALESCE(p_take_row, 20), 1),
            'totalRow', total_row
        )
        FROM total_count
    )
);
$$;


ALTER FUNCTION public.fn_listdata_msticketcategories(p_search_text character varying, p_search_code character varying, p_option_json json, p_lang_code character varying, p_from_row integer, p_take_row integer, p_username character varying) OWNER TO sportevent;

--
-- TOC entry 911 (class 1255 OID 18837)
-- Name: fn_listdata_roles(character varying, character varying, json, character varying, integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: sportevent
--

CREATE FUNCTION public.fn_listdata_roles(p_search_text character varying, p_search_code character varying, p_option_json json, p_lang_code character varying, p_from_row integer, p_take_row integer, p_username character varying) RETURNS json
    LANGUAGE sql
    AS $$
	-- function name: lấy danh sách dữ liệu phân quyền
	-- create by: lthngoc - 01/04/2026
	-- last modify by: xxx - xx/xx/xxxx
WITH filtered_data AS (
    SELECT
        sy.code as code,
        CASE
            WHEN COALESCE(p_lang_code, 'vi') = 'en' THEN COALESCE(sy.namevi, sy.nameen)
            ELSE sy.namevi
        END AS display_name
    FROM sy_roles sy
    WHERE (
            NULLIF(p_search_text, '') IS NULL
            OR sy.namevi ILIKE '%' || p_search_text || '%'
            OR sy.nameen ILIKE '%' || p_search_text || '%'
          )
      AND (
            NULLIF (p_search_code, '') IS NULL
            OR sy.code = p_search_code
          )
),
total_count AS (
    SELECT COUNT(*) AS total_row
    FROM filtered_data
),
paged_data AS (
    SELECT *
    FROM filtered_data
    ORDER BY code
    OFFSET GREATEST(COALESCE(p_from_row, 0), 0)
    LIMIT GREATEST(COALESCE(p_take_row, 20), 1)
)
SELECT json_build_object(
    'item1', COALESCE((
        SELECT json_agg(
            json_build_object(
                'code', code,
                'name', display_name
            )
        )
        FROM paged_data
    ), '[]'::json),
    'item2', (
        SELECT json_build_object(
            'pageSize', GREATEST(COALESCE(p_take_row, 20), 1),
            'totalRow', total_row
        )
        FROM total_count
    )
);
$$;


ALTER FUNCTION public.fn_listdata_roles(p_search_text character varying, p_search_code character varying, p_option_json json, p_lang_code character varying, p_from_row integer, p_take_row integer, p_username character varying) OWNER TO sportevent;

--
-- TOC entry 905 (class 1255 OID 16756)
-- Name: fn_listdata_screen(character varying, character varying, json, character varying, integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: sportevent
--

CREATE FUNCTION public.fn_listdata_screen("searchText" character varying, "searchCode" character varying, "optionJson" json, "langCode" character varying, "fromRow" integer, "takeRow" integer, username character varying) RETURNS json
    LANGUAGE sql
    AS $$
	-- function name: lấy danh sách dữ liệu các màn hình trên hệ thống
	-- create by: tmtam - 01/04/2026
	-- last modify by: xxx - xx/xx/xxxx
SELECT json_build_object(
    'item1', (
        SELECT json_agg(
            json_build_object('code', a.Code, 'name', b.DefaultValue)
        ) 
        FROM sy_functions a
		LEFT JOIN sy_res_resourcecontrols b ON a.ResourceControlName = b.Name
	
	
    ),
	'item2', json_build_object(
		'pageSize', 1,
		'totalRow', 20
	)
)
$$;


ALTER FUNCTION public.fn_listdata_screen("searchText" character varying, "searchCode" character varying, "optionJson" json, "langCode" character varying, "fromRow" integer, "takeRow" integer, username character varying) OWNER TO sportevent;

--
-- TOC entry 981 (class 1255 OID 19582)
-- Name: fn_listdata_srmatchschedules(character varying, character varying, json, character varying, integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: sportevent
--

CREATE FUNCTION public.fn_listdata_srmatchschedules(p_search_text character varying, p_search_code character varying, p_option_json json, p_lang_code character varying, p_from_row integer, p_take_row integer, p_username character varying) RETURNS json
    LANGUAGE sql
    AS $$
	-- fn_listdata_srmatchschedules: lấy danh sách dữ liệu lịch thi đấu
	-- create by: lmgiau - 03/04/2026
	-- last modify by: xxx - xx/xx/xxxx
WITH filtered_data AS (
    SELECT
        ms.match_code AS CODE,
        CASE
            WHEN COALESCE(p_lang_code, 'vi') = 'en' THEN COALESCE(ms.match_name_en, ms.match_name_vi)
            ELSE ms.match_name_vi
        END AS display_name,
        ms.sport_code,
        ms.location_code,
		ms.sport_event_code,
		ms.match_start_date,
		ms.match_end_date,
		ms.match_start_time,
		ms.match_end_time,
    	json_build_object('fileKey', msl.location_file_1)::text AS location_image
    FROM sr_match_schedules ms
	LEFT JOIN ms_locations msl ON ms.location_code = msl.location_code
    WHERE (
            NULLIF(p_search_text, '') IS NULL
            OR ms.match_name_vi ILIKE '%' || p_search_text || '%'
            OR ms.match_name_en ILIKE '%' || p_search_text || '%'
          )
      AND (
            NULLIF(p_search_code, '') IS NULL
            OR ms.match_code = p_search_code
          )
      AND (
            NULLIF (p_option_json ->> 'competition_code', '') IS NULL
            OR ms.competition_code = p_option_json->>'competition_code'
          )
),
total_count AS (
    SELECT COUNT(*) AS total_row
    FROM filtered_data
),
paged_data AS (
    SELECT *
    FROM filtered_data
    ORDER BY CODE
    OFFSET GREATEST(COALESCE(p_from_row, 0), 0)
    LIMIT GREATEST(COALESCE(p_take_row, 20), 1)
)
SELECT json_build_object(
    'item1', COALESCE((
        SELECT json_agg(
            json_build_object(
                'code', CODE,
                'name', display_name,
                'sport_code', sport_code,
                'location_code', location_code,
				'sport_event_code', sport_event_code,
				'match_start_date', match_start_date,
				'match_end_date', match_end_date,
				'match_start_time', match_start_time,
				'match_end_time', match_end_time,
				'location_image', location_image
            )
        )
        FROM paged_data
    ), '[]'::json),
    'item2', (
        SELECT json_build_object(
            'pageSize', GREATEST(COALESCE(p_take_row, 20), 1),
            'totalRow', total_row
        )
        FROM total_count
    )
);
$$;


ALTER FUNCTION public.fn_listdata_srmatchschedules(p_search_text character varying, p_search_code character varying, p_option_json json, p_lang_code character varying, p_from_row integer, p_take_row integer, p_username character varying) OWNER TO sportevent;

--
-- TOC entry 1006 (class 1255 OID 24731)
-- Name: fn_listdata_srmatchschedules_titicketprice(character varying, character varying, json, character varying, integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: sportevent
--

CREATE FUNCTION public.fn_listdata_srmatchschedules_titicketprice(p_search_text character varying, p_search_code character varying, p_option_json json, p_lang_code character varying, p_from_row integer, p_take_row integer, p_username character varying) RETURNS json
    LANGUAGE sql
    AS $$
	-- fn_listdata_srmatchschedules_titicketprice: lấy danh sách dữ liệu lịch thi đấu
	-- create by: lmgiau - 03/04/2026
	-- last modify by: xxx - xx/xx/xxxx
WITH filtered_data AS (
    SELECT
        ms.match_code AS CODE,
        CASE
            WHEN COALESCE(p_lang_code, 'vi') = 'en' THEN COALESCE(ms.match_name_en, ms.match_name_vi)
            ELSE ms.match_name_vi
        END AS display_name,
        ms.sport_code,
        ms.location_code,
		ms.sport_event_code,
		ms.match_start_date,
		ms.match_end_date,
		ms.match_start_time,
		ms.match_end_time
    FROM sr_match_schedules ms
    WHERE (
            NULLIF(p_search_text, '') IS NULL
            OR ms.match_name_vi ILIKE '%' || p_search_text || '%'
            OR ms.match_name_en ILIKE '%' || p_search_text || '%'
          )
      AND (
            NULLIF(p_search_code, '') IS NULL
            OR ms.match_code = p_search_code
          )
      AND (
            p_option_json->>'competition_code' IS NULL
            OR ms.competition_code = p_option_json->>'competition_code'
          )
),
total_count AS (
    SELECT COUNT(*) AS total_row
    FROM filtered_data
),
paged_data AS (
    SELECT *
    FROM filtered_data
    ORDER BY CODE
    OFFSET GREATEST(COALESCE(p_from_row, 0), 0)
    LIMIT GREATEST(COALESCE(p_take_row, 20), 1)
)
SELECT json_build_object(
    'item1', COALESCE((
        SELECT json_agg(
            json_build_object(
                'code', CODE,
                'name', display_name,
                'sport_code', sport_code,
                'location_code', location_code
            )
        )
        FROM paged_data
    ), '[]'::json),
    'item2', (
        SELECT json_build_object(
            'pageSize', GREATEST(COALESCE(p_take_row, 20), 1),
            'totalRow', total_row
        )
        FROM total_count
    )
);
$$;


ALTER FUNCTION public.fn_listdata_srmatchschedules_titicketprice(p_search_text character varying, p_search_code character varying, p_option_json json, p_lang_code character varying, p_from_row integer, p_take_row integer, p_username character varying) OWNER TO sportevent;

--
-- TOC entry 900 (class 1255 OID 20232)
-- Name: fn_listdata_syusers(character varying, character varying, json, character varying, integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: sportevent
--

CREATE FUNCTION public.fn_listdata_syusers(p_search_text character varying, p_search_code character varying, p_option_json json, p_lang_code character varying, p_from_row integer, p_take_row integer, p_username character varying) RETURNS json
    LANGUAGE sql
    AS $$
	-- function name: lấy danh sách dữ liệu người dùng
	-- create by: ddkhanh - 06/04/2026
	-- last modify by: xxx - xx/xx/xxxx
WITH filtered_data AS (
    SELECT
        sy.username AS code,
        sy.username AS display_name,
		CASE
        	WHEN COALESCE(p_lang_code, 'vi') = 'en' THEN COALESCE(emp.employee_name_en, emp.employee_name_vi)
            ELSE emp.employee_name_vi
        END AS full_name
    FROM sy_users sy
	JOIN ms_employees emp ON emp.employee_code = sy.referenceobjectcode
    WHERE (
            NULLIF(p_search_text, '') IS NULL
            OR sy.username ILIKE '%' || p_search_text || '%'
          )
      AND (
            NULLIF(p_search_code, '') IS NULL
            OR sy.username = p_search_code
          )
      AND (
            NULLIF (p_option_json ->> 'employee_type', '') IS NULL
            OR emp.employee_type = p_option_json ->> 'employee_type'
          )
),
total_count AS (
    SELECT COUNT(*) AS total_row
    FROM filtered_data
),
paged_data AS (
    SELECT *
    FROM filtered_data
    ORDER BY code
    OFFSET GREATEST(COALESCE(p_from_row, 0), 0)
    LIMIT GREATEST(COALESCE(p_take_row, 20), 1)
)
SELECT json_build_object(
    'item1', COALESCE((
        SELECT json_agg(
            json_build_object(
                'code', code,
                'name', display_name,
				'full_name', full_name
            )
        )
        FROM paged_data
    ), '[]'::json),
    'item2', (
        SELECT json_build_object(
            'pageSize', GREATEST(COALESCE(p_take_row, 20), 1),
            'totalRow', total_row
        )
        FROM total_count
    )
);
$$;


ALTER FUNCTION public.fn_listdata_syusers(p_search_text character varying, p_search_code character varying, p_option_json json, p_lang_code character varying, p_from_row integer, p_take_row integer, p_username character varying) OWNER TO sportevent;

--
-- TOC entry 984 (class 1255 OID 20233)
-- Name: fn_utils_generate_transaction_no(character varying, timestamp without time zone, smallint); Type: FUNCTION; Schema: public; Owner: sportevent
--

CREATE FUNCTION public.fn_utils_generate_transaction_no(p_transaction_type character varying, p_transaction_date timestamp without time zone, p_method smallint DEFAULT 0) RETURNS TABLE(return_code smallint, message character varying, new_transaction_no character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
    -- Message mặc định
    v_message VARCHAR(100) := 'Common_msg_DataNotFound';
    v_return_code SMALLINT := 0;
    
    -- Xử lý ngày tháng cho Reset logic
    v_day VARCHAR(2) := TO_CHAR(p_transaction_date, 'DD');
    v_month VARCHAR(2) := TO_CHAR(p_transaction_date, 'MM');
    v_year VARCHAR(4) := TO_CHAR(p_transaction_date, 'YYYY');
    
    -- Tham số từ sy_document_settings
    v_is_auto_increment BOOLEAN;
    v_start_at INTEGER;
    v_number_digits INTEGER;
    v_is_reset_by_day BOOLEAN;
    v_is_reset_by_month BOOLEAN;
    v_is_reset_by_year BOOLEAN;
    v_date_format VARCHAR(50);
    v_prefix VARCHAR(50);
    
    -- Biến trung gian
    v_reset_day_val VARCHAR(2);
    v_reset_month_val VARCHAR(2);
    v_reset_year_val VARCHAR(4);
    v_prefix_no VARCHAR(100);
    v_new_start_at BIGINT;
    v_full_code VARCHAR(100);
    v_format_code VARCHAR(100);
    
    -- Check lũng mã
    v_i_max_check INT := 100;
    v_check_code VARCHAR(100);
    v_check_index BIGINT;
BEGIN
    -- 1. Lấy cấu hình từ sy_document_settings
    SELECT 
        is_auto_increment, start_at, number_digits, 
        is_reset_by_day, is_reset_by_month, is_reset_by_year,
        "date", prefix
    INTO 
        v_is_auto_increment, v_start_at, v_number_digits, 
        v_is_reset_by_day, v_is_reset_by_month, v_is_reset_by_year,
        v_date_format, v_prefix
    FROM sy_document_settings
    WHERE transaction_type = p_transaction_type;

    -- Nếu không tìm thấy cấu hình
    IF v_is_auto_increment IS NULL THEN
        RETURN QUERY SELECT v_return_code, v_message, NULL::VARCHAR;
        RETURN;
    END IF;

    IF (v_is_auto_increment = TRUE) THEN
        -- Xác định giá trị reset để tạo FormatCode
        v_reset_day_val   := CASE WHEN v_is_reset_by_day THEN v_day ELSE '0' END;
        v_reset_month_val := CASE WHEN v_is_reset_by_month THEN v_month ELSE '0' END;
        v_reset_year_val  := CASE WHEN v_is_reset_by_year THEN v_year ELSE '0' END;
        
        v_format_code := CONCAT(v_reset_year_val, '_', v_reset_month_val, '_', v_reset_day_val, '_', p_transaction_type);
        
        -- Tạo prefix mã (Prefix + Chuỗi ngày tháng)
        -- Lưu ý: Nếu trs.date trong DB là 'yyyyMMdd', PostgreSQL cần 'YYYYMMDD'
        v_prefix_no := CONCAT(v_prefix, TO_CHAR(p_transaction_date, UPPER(COALESCE(v_date_format, 'YYYYMMDD'))));

        -- 2. Lấy số tiếp theo từ sy_document_formatter_current
        SELECT next_number INTO v_new_start_at 
        FROM sy_document_formatter_current 
        WHERE format_code = v_format_code;

        -- Nếu chưa tồn tại formatter cho kỳ này thì tạo mới
        IF v_new_start_at IS NULL THEN
            v_new_start_at := v_start_at;
            v_full_code := CONCAT(v_prefix_no, LPAD(v_new_start_at::text, v_number_digits, '0'));
            
            INSERT INTO sy_document_formatter_current (
                transaction_type, format_code, next_number, current_document_code, created_by, updated_by, updated_date
            )
            VALUES (
                p_transaction_type, v_format_code, v_new_start_at, v_full_code, 'admin', 'admin', CURRENT_TIMESTAMP
            );
        END IF;

        -- 3. Kiểm tra overload dựa trên số lượng chữ số (number_digits)
        IF (v_new_start_at < POWER(10, v_number_digits)::BIGINT) THEN
            
            -- ▼ LOGIC CHECK LŨNG MÃ (Tìm mã lớn nhất thực tế đã dùng trong 100 mã gần nhất)
            v_check_index := v_new_start_at - 1;
            
            WHILE v_i_max_check > 0 AND v_check_index >= v_start_at LOOP
                v_check_code := CONCAT(v_prefix_no, LPAD(v_check_index::text, v_number_digits, '0'));
                
                -- Check tồn tại trong các bảng nghiệp vụ (Mẫu 1 bảng, bạn copy thêm cho các bảng khác)
                IF p_transaction_type = '20002' THEN
                     IF EXISTS (SELECT 1 FROM st_transactionmasters WHERE transaction_no = v_check_code) THEN
                        v_new_start_at := v_check_index + 1;
                        EXIT;
                     END IF;
                -- ELSE IF p_transaction_type IN ('...') THEN ...
                END IF;

                v_check_index := v_check_index - 1;
                v_i_max_check := v_i_max_check - 1;
            END LOOP;
            -- ▲ KẾT THÚC CHECK LŨNG MÃ

            v_full_code := CONCAT(v_prefix_no, LPAD(v_new_start_at::text, v_number_digits, '0'));

            -- 4. Cập nhật database nếu method = 1 (Xác nhận lấy mã)
            IF (p_method = 1) THEN
                UPDATE sy_document_formatter_current 
                SET next_number = v_new_start_at + 1, 
                    current_document_code = v_full_code,
                    updated_date = CURRENT_TIMESTAMP
                WHERE format_code = v_format_code;
            END IF;

            v_return_code := 1;
            v_message := 'Common_msg_Success';
            
        ELSE
            v_return_code := 2;
            v_message := 'Common_msg_GenerateCodeOverload';
        END IF;
    END IF;

    RETURN QUERY SELECT v_return_code, v_message, v_full_code;
END;
$$;


ALTER FUNCTION public.fn_utils_generate_transaction_no(p_transaction_type character varying, p_transaction_date timestamp without time zone, p_method smallint) OWNER TO sportevent;

--
-- TOC entry 871 (class 1255 OID 20268)
-- Name: fn_utils_generate_transaction_no(character varying, timestamp without time zone, integer); Type: FUNCTION; Schema: public; Owner: sportevent
--

CREATE FUNCTION public.fn_utils_generate_transaction_no(p_transaction_type character varying, p_transaction_date timestamp without time zone, p_method integer DEFAULT 0) RETURNS TABLE(return_code smallint, message character varying, new_transaction_no character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
    -- Message mặc định
    v_message VARCHAR(100) := 'Common_msg_DataNotFound';
    v_return_code SMALLINT := 0;
    
    -- Xử lý ngày tháng cho Reset logic
    v_day VARCHAR(2) := TO_CHAR(p_transaction_date, 'DD');
    v_month VARCHAR(2) := TO_CHAR(p_transaction_date, 'MM');
    v_year VARCHAR(4) := TO_CHAR(p_transaction_date, 'YYYY');
    
    -- Tham số từ sy_document_settings
    v_is_auto_increment BOOLEAN;
    v_start_at INTEGER;
    v_number_digits INTEGER;
    v_is_reset_by_day BOOLEAN;
    v_is_reset_by_month BOOLEAN;
    v_is_reset_by_year BOOLEAN;
    v_date_format VARCHAR(50);
    v_prefix VARCHAR(50);
    
    -- Biến trung gian
    v_reset_day_val VARCHAR(2);
    v_reset_month_val VARCHAR(2);
    v_reset_year_val VARCHAR(4);
    v_prefix_no VARCHAR(100);
    v_new_start_at BIGINT;
    v_full_code VARCHAR(100);
    v_format_code VARCHAR(100);
    
    -- Check lũng mã
    v_i_max_check INT := 100;
    v_check_code VARCHAR(100);
    v_check_index BIGINT;
BEGIN
    -- 1. Lấy cấu hình từ sy_document_settings
    SELECT 
        is_auto_increment, start_at, number_digits, 
        is_reset_by_day, is_reset_by_month, is_reset_by_year,
        "date", prefix
    INTO 
        v_is_auto_increment, v_start_at, v_number_digits, 
        v_is_reset_by_day, v_is_reset_by_month, v_is_reset_by_year,
        v_date_format, v_prefix
    FROM sy_document_settings
    WHERE transaction_type = p_transaction_type;

    -- Nếu không tìm thấy cấu hình
    IF v_is_auto_increment IS NULL THEN
        RETURN QUERY SELECT v_return_code, v_message, NULL::VARCHAR;
        RETURN;
    END IF;

    IF (v_is_auto_increment = TRUE) THEN
        -- Xác định giá trị reset để tạo FormatCode
        v_reset_day_val   := CASE WHEN v_is_reset_by_day THEN v_day ELSE '0' END;
        v_reset_month_val := CASE WHEN v_is_reset_by_month THEN v_month ELSE '0' END;
        v_reset_year_val  := CASE WHEN v_is_reset_by_year THEN v_year ELSE '0' END;
        
        v_format_code := CONCAT(v_reset_year_val, '_', v_reset_month_val, '_', v_reset_day_val, '_', p_transaction_type);
        
        -- Tạo prefix mã (Prefix + Chuỗi ngày tháng)
        -- Lưu ý: Nếu trs.date trong DB là 'yyyyMMdd', PostgreSQL cần 'YYYYMMDD'
        v_prefix_no := CONCAT(v_prefix, TO_CHAR(p_transaction_date, UPPER(COALESCE(v_date_format, 'YYYYMMDD'))));

        -- 2. Lấy số tiếp theo từ sy_document_formatter_current
        SELECT next_number INTO v_new_start_at 
        FROM sy_document_formatter_current 
        WHERE format_code = v_format_code;

        -- Nếu chưa tồn tại formatter cho kỳ này thì tạo mới
        IF v_new_start_at IS NULL THEN
            v_new_start_at := v_start_at;
            v_full_code := CONCAT(v_prefix_no, LPAD(v_new_start_at::text, v_number_digits, '0'));
            
            INSERT INTO sy_document_formatter_current (
                transaction_type, format_code, next_number, current_document_code, created_by, updated_by, updated_date
            )
            VALUES (
                p_transaction_type, v_format_code, v_new_start_at, v_full_code, 'admin', 'admin', CURRENT_TIMESTAMP
            );
        END IF;

        -- 3. Kiểm tra overload dựa trên số lượng chữ số (number_digits)
        IF (v_new_start_at < POWER(10, v_number_digits)::BIGINT) THEN
            
            -- ▼ LOGIC CHECK LŨNG MÃ (Tìm mã lớn nhất thực tế đã dùng trong 100 mã gần nhất)
            v_check_index := v_new_start_at - 1;
            
            WHILE v_i_max_check > 0 AND v_check_index >= v_start_at LOOP
                v_check_code := CONCAT(v_prefix_no, LPAD(v_check_index::text, v_number_digits, '0'));
                
                -- Check tồn tại trong các bảng nghiệp vụ (Mẫu 1 bảng, bạn copy thêm cho các bảng khác)
                IF p_transaction_type = '20002' THEN
                     IF EXISTS (SELECT 1 FROM st_transactionmasters WHERE transaction_no = v_check_code) THEN
                        v_new_start_at := v_check_index + 1;
                        EXIT;
                     END IF;
                -- ELSE IF p_transaction_type IN ('...') THEN ...
                END IF;

                v_check_index := v_check_index - 1;
                v_i_max_check := v_i_max_check - 1;
            END LOOP;
            -- ▲ KẾT THÚC CHECK LŨNG MÃ

            v_full_code := CONCAT(v_prefix_no, LPAD(v_new_start_at::text, v_number_digits, '0'));

            -- 4. Cập nhật database nếu method = 1 (Xác nhận lấy mã)
            IF (p_method = 1) THEN
                UPDATE sy_document_formatter_current 
                SET next_number = v_new_start_at + 1, 
                    current_document_code = v_full_code,
                    updated_date = CURRENT_TIMESTAMP
                WHERE format_code = v_format_code;
            END IF;

            v_return_code := 1;
            v_message := 'Common_msg_Success';
            
        ELSE
            v_return_code := 2;
            v_message := 'Common_msg_GenerateCodeOverload';
        END IF;
    END IF;

    RETURN QUERY SELECT v_return_code, v_message, v_full_code;
END;
$$;


ALTER FUNCTION public.fn_utils_generate_transaction_no(p_transaction_type character varying, p_transaction_date timestamp without time zone, p_method integer) OWNER TO sportevent;

--
-- TOC entry 912 (class 1255 OID 18711)
-- Name: fn_utils_get_mail_template(character varying, jsonb, character varying); Type: FUNCTION; Schema: public; Owner: sportevent
--

CREATE FUNCTION public.fn_utils_get_mail_template(p_template_code character varying, p_json_data jsonb, p_user_name character varying) RETURNS TABLE(mailsubject character varying, mailbody text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    r_template RECORD;
    v_key text;
    v_value text;
BEGIN
	-- function name: hàm gen template mail với tham số
	-- create by: tmtam - 01/04/2026
	-- last modify by: xxx - xx/xx/xxxx
	
    -- 1. Lấy thông tin template gốc
    SELECT subject, body INTO r_template
    FROM public.sy_mailtemplate
    WHERE code = p_template_code;

    -- Nếu không tìm thấy template, có thể trả về NULL hoặc báo lỗi
    IF NOT FOUND THEN
        RETURN;
    END IF;

    mailsubject := r_template.subject;
    mailbody := r_template.body;

    -- 2. Lặp qua từng cặp key/value trong json_data để replace
    -- Sử dụng jsonb_each_text để lấy key và value dưới dạng text
    FOR v_key, v_value IN SELECT * FROM jsonb_each_text(p_json_data)
    LOOP
        -- Thay thế {key} bằng value trong cả subject và body
        -- Chú ý: dùng format '{%s}' để tạo chuỗi cần tìm ví dụ '{ten_khach_hang}'
        mailsubject := REPLACE(mailsubject, '{' || v_key || '}', COALESCE(v_value, ''));
        mailbody := REPLACE(mailbody, '{' || v_key || '}', COALESCE(v_value, ''));
    END LOOP;

    -- 3. Trả về dòng dữ liệu kết quả
    RETURN NEXT;
END;
$$;


ALTER FUNCTION public.fn_utils_get_mail_template(p_template_code character varying, p_json_data jsonb, p_user_name character varying) OWNER TO sportevent;

--
-- TOC entry 941 (class 1255 OID 16876)
-- Name: fn_utils_validate_value(character varying, text, integer, text[]); Type: FUNCTION; Schema: public; Owner: sportevent
--

CREATE FUNCTION public.fn_utils_validate_value(p_field_name character varying, p_field_value text, p_field_maxlength integer, VARIADIC p_validate_rules text[] DEFAULT '{}'::text[]) RETURNS text
    LANGUAGE plpgsql
    AS $_$
DECLARE
    v_msg TEXT := '';
BEGIN
	-- function name: hàm validate giá trị đầu vào
	-- create by: tmtam - 01/04/2026
	-- last modify by: lthngoc - 02/04/2026
	/*
		Tất cả validate trả về định dạng: ResourceNameValidate,Parameter1,Parameter2,
		vd: Common_msg_FieldMaxLength,Code,50
		=> để trên code string.format resource và truyền tham số vào gen ra nội dung validate
		=>> filed có nhiều validate cách bởi dấu chấm phẩy, vd: Common_msg_MustBeFilledIn,Code;Common_msg_FieldMaxLength,Code,50
	*/
    -- 1. Luôn kiểm tra Max Length
    IF LENGTH(COALESCE(p_field_value, '')) > p_field_maxlength THEN
        v_msg := v_msg || ';Common_msg_FieldMaxLength,' || p_field_name || ',' || p_field_maxlength;
    END IF;

    -- 2. Kiểm tra Required
    IF 'Required' = ANY(p_validate_rules) AND (p_field_value IS NULL OR TRIM(p_field_value) = '') THEN
        v_msg := v_msg || ';Common_msg_MustBeFilledIn,' || p_field_name;
    END IF;

    -- 3. Kiểm tra IsDate (dd/MM/yyyy)
    IF 'IsDate' = ANY(p_validate_rules) AND p_field_value IS NOT NULL AND p_field_value <> '' THEN
        -- Bước 1: Dùng Regex kiểm tra format dd/mm/yyyy
        IF p_field_value !~ '^\d{1,2}/\d{1,2}/\d{4}$' THEN
            v_msg := v_msg || ';Common_msg_FieldWrongFormatData,' || p_field_name || ',dd/MM/yyyy';
        ELSE
            -- Bước 2: Kiểm tra tính hợp lệ của ngày tháng (ví dụ tránh ngày 31/04)
            BEGIN
                -- Ép kiểu sang DATE, nếu ngày không tồn tại (30/02) nó sẽ văng lỗi vào EXCEPTION
                PERFORM p_field_value::DATE; 
            EXCEPTION WHEN OTHERS THEN
                -- Nếu lỗi, thử dùng TO_DATE lần cuối để chắc chắn format
                BEGIN
                    PERFORM TO_DATE(p_field_value, 'DD/MM/YYYY');
                EXCEPTION WHEN OTHERS THEN
                    v_msg := v_msg || ';Common_msg_FieldWrongFormatData,' || p_field_name || ',dd/MM/yyyy';
                END;
            END;
        END IF;
    END IF;
	
    -- 4. Kiểm tra IsCode (Chữ, số, ., _, -)
    IF 'IsCode' = ANY(p_validate_rules) AND p_field_value IS NOT NULL AND p_field_value <> '' THEN
        IF p_field_value !~ '^[a-zA-Z0-9._-]*$' THEN
            v_msg := v_msg || ';Common_msg_OnlyEnterCharOrNumberAndAllowSpecial,' || p_field_name;
        END IF;
    END IF;

    -- 5. Kiểm tra IsNumber và số thập phân
    IF 'IsNumber' = ANY(p_validate_rules) AND p_field_value IS NOT NULL AND p_field_value <> '' THEN
        IF p_field_value !~ '^-?[0-9]+(\.[0-9]+)?$' THEN
            v_msg := v_msg || ';Common_msg_MustBeIsNumber,' || p_field_name;
        ELSIF LENGTH(SPLIT_PART(p_field_value, '.', 2)) > 10 THEN
            v_msg := v_msg || ';FieldMaxLengthDecimalPlaces,' || p_field_name;
        END IF;
    END IF;

	-- 6. Kiểm tra Password
	IF 'IsPassword' = ANY(p_validate_rules) AND p_field_value IS NOT NULL AND p_field_value <> '' THEN
	    IF LENGTH(p_field_value) < 8 THEN
	        v_msg := v_msg || ';Common_msg_PasswordMinLength,' || p_field_name;
	    ELSIF p_field_value !~ '[A-Z]' THEN
	        v_msg := v_msg || ';Common_msg_PasswordMustHaveUppercase,' || p_field_name;
	    ELSIF p_field_value !~ '[a-z]' THEN
	        v_msg := v_msg || ';Common_msg_PasswordMustHaveLowercase,' || p_field_name;
	    ELSIF p_field_value !~ '[0-9]' THEN
	        v_msg := v_msg || ';Common_msg_PasswordMustHaveNumber,' || p_field_name;
	    ELSIF p_field_value !~ '[^A-Za-z0-9]' THEN
	        v_msg := v_msg || ';Common_msg_PasswordMustHaveSpecialCharacter,' || p_field_name;
	    END IF;
	END IF;

	-- 7. Kiểm tra IsEmail
    IF 'IsEmail' = ANY(p_validate_rules) AND p_field_value IS NOT NULL AND p_field_value <> '' THEN
        -- Regex chuẩn cho email (đảm bảo có @, có dấu chấm và không có ký tự đặc biệt lạ)
        IF p_field_value !~ '^[a-zA-Z0-9.!#$%&''*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$' THEN
            v_msg := v_msg || ';Common_msg_FieldWrongFormatData,' || p_field_name || ',Email';
        END IF;
    END IF;
	
    RETURN NULLIF(v_msg, '');
END;
$_$;


ALTER FUNCTION public.fn_utils_validate_value(p_field_name character varying, p_field_value text, p_field_maxlength integer, VARIADIC p_validate_rules text[]) OWNER TO sportevent;

--
-- TOC entry 3181 (class 1417 OID 46019)
-- Name: log_server; Type: SERVER; Schema: -; Owner: postgres
--

CREATE SERVER log_server FOREIGN DATA WRAPPER postgres_fdw OPTIONS (
    dbname 'sport_event_log',
    host 'localhost',
    port '5432'
);


ALTER SERVER log_server OWNER TO postgres;

--
-- TOC entry 6584 (class 0 OID 0)
-- Name: USER MAPPING postgres SERVER log_server; Type: USER MAPPING; Schema: -; Owner: postgres
--

CREATE USER MAPPING FOR postgres SERVER log_server;


--
-- TOC entry 6585 (class 0 OID 0)
-- Name: USER MAPPING sportevent SERVER log_server; Type: USER MAPPING; Schema: -; Owner: postgres
--

CREATE USER MAPPING FOR sportevent SERVER log_server OPTIONS (
    password 'sportevent',
    "user" 'sportevent'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 804 (class 1259 OID 24264)
-- Name: counter; Type: TABLE; Schema: hangfire; Owner: sportevent
--

CREATE TABLE hangfire.counter (
    id bigint NOT NULL,
    key text NOT NULL,
    value bigint NOT NULL,
    expireat timestamp without time zone
);


ALTER TABLE hangfire.counter OWNER TO sportevent;

--
-- TOC entry 803 (class 1259 OID 24263)
-- Name: counter_id_seq; Type: SEQUENCE; Schema: hangfire; Owner: sportevent
--

CREATE SEQUENCE hangfire.counter_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE hangfire.counter_id_seq OWNER TO sportevent;

--
-- TOC entry 6586 (class 0 OID 0)
-- Dependencies: 803
-- Name: counter_id_seq; Type: SEQUENCE OWNED BY; Schema: hangfire; Owner: sportevent
--

ALTER SEQUENCE hangfire.counter_id_seq OWNED BY hangfire.counter.id;


--
-- TOC entry 806 (class 1259 OID 24275)
-- Name: hash; Type: TABLE; Schema: hangfire; Owner: sportevent
--

CREATE TABLE hangfire.hash (
    id bigint NOT NULL,
    key text NOT NULL,
    field text NOT NULL,
    value text,
    expireat timestamp without time zone,
    updatecount integer DEFAULT 0 NOT NULL
);


ALTER TABLE hangfire.hash OWNER TO sportevent;

--
-- TOC entry 805 (class 1259 OID 24274)
-- Name: hash_id_seq; Type: SEQUENCE; Schema: hangfire; Owner: sportevent
--

CREATE SEQUENCE hangfire.hash_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE hangfire.hash_id_seq OWNER TO sportevent;

--
-- TOC entry 6587 (class 0 OID 0)
-- Dependencies: 805
-- Name: hash_id_seq; Type: SEQUENCE OWNED BY; Schema: hangfire; Owner: sportevent
--

ALTER SEQUENCE hangfire.hash_id_seq OWNED BY hangfire.hash.id;


--
-- TOC entry 808 (class 1259 OID 24289)
-- Name: job; Type: TABLE; Schema: hangfire; Owner: sportevent
--

CREATE TABLE hangfire.job (
    id bigint NOT NULL,
    stateid bigint,
    statename text,
    invocationdata text NOT NULL,
    arguments text NOT NULL,
    createdat timestamp without time zone NOT NULL,
    expireat timestamp without time zone,
    updatecount integer DEFAULT 0 NOT NULL
);


ALTER TABLE hangfire.job OWNER TO sportevent;

--
-- TOC entry 807 (class 1259 OID 24288)
-- Name: job_id_seq; Type: SEQUENCE; Schema: hangfire; Owner: sportevent
--

CREATE SEQUENCE hangfire.job_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE hangfire.job_id_seq OWNER TO sportevent;

--
-- TOC entry 6588 (class 0 OID 0)
-- Dependencies: 807
-- Name: job_id_seq; Type: SEQUENCE OWNED BY; Schema: hangfire; Owner: sportevent
--

ALTER SEQUENCE hangfire.job_id_seq OWNED BY hangfire.job.id;


--
-- TOC entry 819 (class 1259 OID 24368)
-- Name: jobparameter; Type: TABLE; Schema: hangfire; Owner: sportevent
--

CREATE TABLE hangfire.jobparameter (
    id bigint NOT NULL,
    jobid bigint NOT NULL,
    name text NOT NULL,
    value text,
    updatecount integer DEFAULT 0 NOT NULL
);


ALTER TABLE hangfire.jobparameter OWNER TO sportevent;

--
-- TOC entry 818 (class 1259 OID 24367)
-- Name: jobparameter_id_seq; Type: SEQUENCE; Schema: hangfire; Owner: sportevent
--

CREATE SEQUENCE hangfire.jobparameter_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE hangfire.jobparameter_id_seq OWNER TO sportevent;

--
-- TOC entry 6589 (class 0 OID 0)
-- Dependencies: 818
-- Name: jobparameter_id_seq; Type: SEQUENCE OWNED BY; Schema: hangfire; Owner: sportevent
--

ALTER SEQUENCE hangfire.jobparameter_id_seq OWNED BY hangfire.jobparameter.id;


--
-- TOC entry 812 (class 1259 OID 24322)
-- Name: jobqueue; Type: TABLE; Schema: hangfire; Owner: sportevent
--

CREATE TABLE hangfire.jobqueue (
    id bigint NOT NULL,
    jobid bigint NOT NULL,
    queue text NOT NULL,
    fetchedat timestamp without time zone,
    updatecount integer DEFAULT 0 NOT NULL
);


ALTER TABLE hangfire.jobqueue OWNER TO sportevent;

--
-- TOC entry 811 (class 1259 OID 24321)
-- Name: jobqueue_id_seq; Type: SEQUENCE; Schema: hangfire; Owner: sportevent
--

CREATE SEQUENCE hangfire.jobqueue_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE hangfire.jobqueue_id_seq OWNER TO sportevent;

--
-- TOC entry 6590 (class 0 OID 0)
-- Dependencies: 811
-- Name: jobqueue_id_seq; Type: SEQUENCE OWNED BY; Schema: hangfire; Owner: sportevent
--

ALTER SEQUENCE hangfire.jobqueue_id_seq OWNED BY hangfire.jobqueue.id;


--
-- TOC entry 814 (class 1259 OID 24333)
-- Name: list; Type: TABLE; Schema: hangfire; Owner: sportevent
--

CREATE TABLE hangfire.list (
    id bigint NOT NULL,
    key text NOT NULL,
    value text,
    expireat timestamp without time zone,
    updatecount integer DEFAULT 0 NOT NULL
);


ALTER TABLE hangfire.list OWNER TO sportevent;

--
-- TOC entry 813 (class 1259 OID 24332)
-- Name: list_id_seq; Type: SEQUENCE; Schema: hangfire; Owner: sportevent
--

CREATE SEQUENCE hangfire.list_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE hangfire.list_id_seq OWNER TO sportevent;

--
-- TOC entry 6591 (class 0 OID 0)
-- Dependencies: 813
-- Name: list_id_seq; Type: SEQUENCE OWNED BY; Schema: hangfire; Owner: sportevent
--

ALTER SEQUENCE hangfire.list_id_seq OWNED BY hangfire.list.id;


--
-- TOC entry 820 (class 1259 OID 24385)
-- Name: lock; Type: TABLE; Schema: hangfire; Owner: sportevent
--

CREATE TABLE hangfire.lock (
    resource text NOT NULL,
    updatecount integer DEFAULT 0 NOT NULL,
    acquired timestamp without time zone
);


ALTER TABLE hangfire.lock OWNER TO sportevent;

--
-- TOC entry 802 (class 1259 OID 24257)
-- Name: schema; Type: TABLE; Schema: hangfire; Owner: sportevent
--

CREATE TABLE hangfire.schema (
    version integer NOT NULL
);


ALTER TABLE hangfire.schema OWNER TO sportevent;

--
-- TOC entry 815 (class 1259 OID 24343)
-- Name: server; Type: TABLE; Schema: hangfire; Owner: sportevent
--

CREATE TABLE hangfire.server (
    id text NOT NULL,
    data text,
    lastheartbeat timestamp without time zone NOT NULL,
    updatecount integer DEFAULT 0 NOT NULL
);


ALTER TABLE hangfire.server OWNER TO sportevent;

--
-- TOC entry 817 (class 1259 OID 24353)
-- Name: set; Type: TABLE; Schema: hangfire; Owner: sportevent
--

CREATE TABLE hangfire.set (
    id bigint NOT NULL,
    key text NOT NULL,
    score double precision NOT NULL,
    value text NOT NULL,
    expireat timestamp without time zone,
    updatecount integer DEFAULT 0 NOT NULL
);


ALTER TABLE hangfire.set OWNER TO sportevent;

--
-- TOC entry 816 (class 1259 OID 24352)
-- Name: set_id_seq; Type: SEQUENCE; Schema: hangfire; Owner: sportevent
--

CREATE SEQUENCE hangfire.set_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE hangfire.set_id_seq OWNER TO sportevent;

--
-- TOC entry 6592 (class 0 OID 0)
-- Dependencies: 816
-- Name: set_id_seq; Type: SEQUENCE OWNED BY; Schema: hangfire; Owner: sportevent
--

ALTER SEQUENCE hangfire.set_id_seq OWNED BY hangfire.set.id;


--
-- TOC entry 810 (class 1259 OID 24303)
-- Name: state; Type: TABLE; Schema: hangfire; Owner: sportevent
--

CREATE TABLE hangfire.state (
    id bigint NOT NULL,
    jobid bigint NOT NULL,
    name text NOT NULL,
    reason text,
    createdat timestamp without time zone NOT NULL,
    data text,
    updatecount integer DEFAULT 0 NOT NULL
);


ALTER TABLE hangfire.state OWNER TO sportevent;

--
-- TOC entry 809 (class 1259 OID 24302)
-- Name: state_id_seq; Type: SEQUENCE; Schema: hangfire; Owner: sportevent
--

CREATE SEQUENCE hangfire.state_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE hangfire.state_id_seq OWNER TO sportevent;

--
-- TOC entry 6593 (class 0 OID 0)
-- Dependencies: 809
-- Name: state_id_seq; Type: SEQUENCE OWNED BY; Schema: hangfire; Owner: sportevent
--

ALTER SEQUENCE hangfire.state_id_seq OWNED BY hangfire.state.id;


--
-- TOC entry 793 (class 1259 OID 22439)
-- Name: io_inout_barcode_history; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.io_inout_barcode_history (
    id integer NOT NULL,
    qr_code character varying(255) NOT NULL,
    location_code character varying(50) NOT NULL,
    area_code character varying(50) NOT NULL,
    access_date timestamp(6) without time zone NOT NULL,
    access_result character varying(50) NOT NULL,
    created_by character varying(50) NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(50) NOT NULL,
    updated_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data_row_version bigint DEFAULT 1 NOT NULL
);


ALTER TABLE public.io_inout_barcode_history OWNER TO sportevent;

--
-- TOC entry 6594 (class 0 OID 0)
-- Dependencies: 793
-- Name: TABLE io_inout_barcode_history; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON TABLE public.io_inout_barcode_history IS 'Bảng ghi lại lịch sử quét mã Barcode/QRCode ra vào các khu vực';


--
-- TOC entry 6595 (class 0 OID 0)
-- Dependencies: 793
-- Name: COLUMN io_inout_barcode_history.qr_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.io_inout_barcode_history.qr_code IS 'Mã vé lấy từ ti_ticket_sold: ticket_auto_code';


--
-- TOC entry 6596 (class 0 OID 0)
-- Dependencies: 793
-- Name: COLUMN io_inout_barcode_history.location_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.io_inout_barcode_history.location_code IS 'Mã địa điểm ms_locations: location_code';


--
-- TOC entry 6597 (class 0 OID 0)
-- Dependencies: 793
-- Name: COLUMN io_inout_barcode_history.area_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.io_inout_barcode_history.area_code IS 'Mã khu vực ms_location_detail: area_code';


--
-- TOC entry 6598 (class 0 OID 0)
-- Dependencies: 793
-- Name: COLUMN io_inout_barcode_history.access_date; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.io_inout_barcode_history.access_date IS 'Thời điểm thực hiện quét mã';


--
-- TOC entry 6599 (class 0 OID 0)
-- Dependencies: 793
-- Name: COLUMN io_inout_barcode_history.access_result; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.io_inout_barcode_history.access_result IS 'Kết quả truy cập (Thành công/Thất bại) - sy_commons: Type = ''ACCESS_RESULT''';


--
-- TOC entry 6600 (class 0 OID 0)
-- Dependencies: 793
-- Name: COLUMN io_inout_barcode_history.created_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.io_inout_barcode_history.created_by IS 'Tài khoản thực hiện quét mã hoặc hệ thống';


--
-- TOC entry 792 (class 1259 OID 22438)
-- Name: io_inout_barcode_history_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.io_inout_barcode_history ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.io_inout_barcode_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 795 (class 1259 OID 22464)
-- Name: io_inout_card; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.io_inout_card (
    id integer NOT NULL,
    card_code character varying(50) NOT NULL,
    user_name character varying(50) NOT NULL,
    status character varying(1) NOT NULL,
    effective_date_from date NOT NULL,
    effective_date_to date NOT NULL,
    description character varying(500),
    created_by character varying(50) NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(50) NOT NULL,
    updated_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data_row_version bigint DEFAULT 1 NOT NULL,
    employee_type character varying(10)
);


ALTER TABLE public.io_inout_card OWNER TO sportevent;

--
-- TOC entry 6601 (class 0 OID 0)
-- Dependencies: 795
-- Name: TABLE io_inout_card; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON TABLE public.io_inout_card IS 'Bảng quản lý danh sách thẻ ra vào hệ thống';


--
-- TOC entry 6602 (class 0 OID 0)
-- Dependencies: 795
-- Name: COLUMN io_inout_card.card_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.io_inout_card.card_code IS 'Mã số thẻ vật lý hoặc mã định danh thẻ';


--
-- TOC entry 6603 (class 0 OID 0)
-- Dependencies: 795
-- Name: COLUMN io_inout_card.user_name; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.io_inout_card.user_name IS 'Người sở hữu thẻ - sy_users: user_name';


--
-- TOC entry 6604 (class 0 OID 0)
-- Dependencies: 795
-- Name: COLUMN io_inout_card.status; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.io_inout_card.status IS 'Trạng thái thẻ - sy_commons: Type = ''COMMON_STATUS''';


--
-- TOC entry 6605 (class 0 OID 0)
-- Dependencies: 795
-- Name: COLUMN io_inout_card.effective_date_from; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.io_inout_card.effective_date_from IS 'Ngày thẻ bắt đầu có hiệu lực';


--
-- TOC entry 6606 (class 0 OID 0)
-- Dependencies: 795
-- Name: COLUMN io_inout_card.effective_date_to; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.io_inout_card.effective_date_to IS 'Ngày thẻ hết hạn';


--
-- TOC entry 6607 (class 0 OID 0)
-- Dependencies: 795
-- Name: COLUMN io_inout_card.description; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.io_inout_card.description IS 'Ghi chú bổ sung';


--
-- TOC entry 797 (class 1259 OID 22486)
-- Name: io_inout_card_detail; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.io_inout_card_detail (
    id integer NOT NULL,
    card_code character varying(50) NOT NULL,
    location_code character varying(50) NOT NULL,
    area_code character varying(50) NOT NULL,
    created_by character varying(50) NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(50) NOT NULL,
    updated_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data_row_version bigint DEFAULT 1 NOT NULL
);


ALTER TABLE public.io_inout_card_detail OWNER TO sportevent;

--
-- TOC entry 6608 (class 0 OID 0)
-- Dependencies: 797
-- Name: TABLE io_inout_card_detail; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON TABLE public.io_inout_card_detail IS 'Bảng chi tiết phân quyền ra vào của từng thẻ theo địa điểm và khu vực';


--
-- TOC entry 6609 (class 0 OID 0)
-- Dependencies: 797
-- Name: COLUMN io_inout_card_detail.card_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.io_inout_card_detail.card_code IS 'Mã thẻ - Tham chiếu io_inout_card: card_code';


--
-- TOC entry 6610 (class 0 OID 0)
-- Dependencies: 797
-- Name: COLUMN io_inout_card_detail.location_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.io_inout_card_detail.location_code IS 'Mã địa điểm - Tham chiếu ms_location_detail: location_code';


--
-- TOC entry 6611 (class 0 OID 0)
-- Dependencies: 797
-- Name: COLUMN io_inout_card_detail.area_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.io_inout_card_detail.area_code IS 'Mã khu vực - Tham chiếu ms_location_detail: area_code';


--
-- TOC entry 6612 (class 0 OID 0)
-- Dependencies: 797
-- Name: COLUMN io_inout_card_detail.created_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.io_inout_card_detail.created_by IS 'Người thiết lập quyền';


--
-- TOC entry 796 (class 1259 OID 22485)
-- Name: io_inout_card_detail_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.io_inout_card_detail ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.io_inout_card_detail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 799 (class 1259 OID 22507)
-- Name: io_inout_card_history; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.io_inout_card_history (
    id integer NOT NULL,
    card_code character varying(50) NOT NULL,
    access_date timestamp(6) without time zone NOT NULL,
    access_result character varying(50) NOT NULL,
    in_out_type character varying(1) NOT NULL,
    location_code character varying(50) NOT NULL,
    area_code character varying(50) NOT NULL,
    created_by character varying(50) NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(50) NOT NULL,
    updated_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data_row_version bigint DEFAULT 1 NOT NULL
);


ALTER TABLE public.io_inout_card_history OWNER TO sportevent;

--
-- TOC entry 6613 (class 0 OID 0)
-- Dependencies: 799
-- Name: TABLE io_inout_card_history; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON TABLE public.io_inout_card_history IS 'Bảng ghi lại lịch sử quẹt thẻ vật lý ra vào các khu vực';


--
-- TOC entry 6614 (class 0 OID 0)
-- Dependencies: 799
-- Name: COLUMN io_inout_card_history.card_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.io_inout_card_history.card_code IS 'Mã thẻ tham chiếu từ io_inout_card: card_code';


--
-- TOC entry 6615 (class 0 OID 0)
-- Dependencies: 799
-- Name: COLUMN io_inout_card_history.access_date; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.io_inout_card_history.access_date IS 'Thời gian thực hiện quẹt thẻ';


--
-- TOC entry 6616 (class 0 OID 0)
-- Dependencies: 799
-- Name: COLUMN io_inout_card_history.access_result; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.io_inout_card_history.access_result IS 'Kết quả quẹt thẻ (Thành công/Thất bại) - sy_commons: Type = ''ACCESS_RESULT''';


--
-- TOC entry 6617 (class 0 OID 0)
-- Dependencies: 799
-- Name: COLUMN io_inout_card_history.in_out_type; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.io_inout_card_history.in_out_type IS 'Loại ra/vào (I: Vào, O: Ra) - sy_commons: Type = ''INOUT_TYPE''';


--
-- TOC entry 6618 (class 0 OID 0)
-- Dependencies: 799
-- Name: COLUMN io_inout_card_history.location_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.io_inout_card_history.location_code IS 'Địa điểm quẹt thẻ - ms_location_detail: location_code';


--
-- TOC entry 6619 (class 0 OID 0)
-- Dependencies: 799
-- Name: COLUMN io_inout_card_history.area_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.io_inout_card_history.area_code IS 'Khu vực quẹt thẻ - ms_location_detail: area_code';


--
-- TOC entry 798 (class 1259 OID 22506)
-- Name: io_inout_card_history_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.io_inout_card_history ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.io_inout_card_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 794 (class 1259 OID 22463)
-- Name: io_inout_card_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.io_inout_card ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.io_inout_card_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 745 (class 1259 OID 19036)
-- Name: ms_achievement_history; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.ms_achievement_history (
    id integer NOT NULL,
    employee_code character varying(50) NOT NULL,
    tournament character varying(255) NOT NULL,
    playing_position character varying(255),
    experience character varying(255),
    from_date date,
    to_date date,
    description character varying(500),
    created_by character varying(50) NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(50) NOT NULL,
    updated_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data_row_version bigint DEFAULT 1 NOT NULL
);


ALTER TABLE public.ms_achievement_history OWNER TO sportevent;

--
-- TOC entry 6620 (class 0 OID 0)
-- Dependencies: 745
-- Name: COLUMN ms_achievement_history.employee_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_achievement_history.employee_code IS 'ms_employees: employee_code';


--
-- TOC entry 6621 (class 0 OID 0)
-- Dependencies: 745
-- Name: COLUMN ms_achievement_history.tournament; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_achievement_history.tournament IS 'Giải đấu';


--
-- TOC entry 6622 (class 0 OID 0)
-- Dependencies: 745
-- Name: COLUMN ms_achievement_history.playing_position; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_achievement_history.playing_position IS 'Vị trí thi đấu';


--
-- TOC entry 6623 (class 0 OID 0)
-- Dependencies: 745
-- Name: COLUMN ms_achievement_history.experience; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_achievement_history.experience IS 'Kinh nghiệm';


--
-- TOC entry 6624 (class 0 OID 0)
-- Dependencies: 745
-- Name: COLUMN ms_achievement_history.from_date; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_achievement_history.from_date IS 'Thời gian tham gia từ';


--
-- TOC entry 6625 (class 0 OID 0)
-- Dependencies: 745
-- Name: COLUMN ms_achievement_history.to_date; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_achievement_history.to_date IS 'Thời gian tham gia đến';


--
-- TOC entry 6626 (class 0 OID 0)
-- Dependencies: 745
-- Name: COLUMN ms_achievement_history.description; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_achievement_history.description IS 'Ghi chú/Thành tích chi tiết';


--
-- TOC entry 6627 (class 0 OID 0)
-- Dependencies: 745
-- Name: COLUMN ms_achievement_history.created_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_achievement_history.created_by IS 'sy_users: user_name';


--
-- TOC entry 6628 (class 0 OID 0)
-- Dependencies: 745
-- Name: COLUMN ms_achievement_history.updated_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_achievement_history.updated_by IS 'sy_users: user_name';


--
-- TOC entry 744 (class 1259 OID 19035)
-- Name: ms_achievement_history_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.ms_achievement_history ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ms_achievement_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 830 (class 1259 OID 44561)
-- Name: ms_athlete_coach_notes; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.ms_athlete_coach_notes (
    id integer NOT NULL,
    team_code character varying(50) NOT NULL,
    emp_athlete_code character varying(50) NOT NULL,
    emp_coach_code character varying(50) NOT NULL,
    description character varying(500),
    created_by character varying(50) NOT NULL,
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(50) NOT NULL,
    updated_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data_row_version bytea
);


ALTER TABLE public.ms_athlete_coach_notes OWNER TO sportevent;

--
-- TOC entry 829 (class 1259 OID 44560)
-- Name: ms_athlete_coach_notes_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.ms_athlete_coach_notes ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.ms_athlete_coach_notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 747 (class 1259 OID 19061)
-- Name: ms_athlete_violation_history; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.ms_athlete_violation_history (
    id integer NOT NULL,
    employee_code character varying(50) NOT NULL,
    tournament character varying(255),
    violation_date date,
    description character varying(500),
    created_by character varying(50) NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(50) NOT NULL,
    updated_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data_row_version bigint DEFAULT 1 NOT NULL
);


ALTER TABLE public.ms_athlete_violation_history OWNER TO sportevent;

--
-- TOC entry 6629 (class 0 OID 0)
-- Dependencies: 747
-- Name: COLUMN ms_athlete_violation_history.employee_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_athlete_violation_history.employee_code IS 'ms_employees: employee_code';


--
-- TOC entry 6630 (class 0 OID 0)
-- Dependencies: 747
-- Name: COLUMN ms_athlete_violation_history.tournament; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_athlete_violation_history.tournament IS 'Giải đấu';


--
-- TOC entry 6631 (class 0 OID 0)
-- Dependencies: 747
-- Name: COLUMN ms_athlete_violation_history.violation_date; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_athlete_violation_history.violation_date IS 'Ngày vi phạm';


--
-- TOC entry 6632 (class 0 OID 0)
-- Dependencies: 747
-- Name: COLUMN ms_athlete_violation_history.description; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_athlete_violation_history.description IS 'Ghi chú/Nội dung vi phạm';


--
-- TOC entry 6633 (class 0 OID 0)
-- Dependencies: 747
-- Name: COLUMN ms_athlete_violation_history.created_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_athlete_violation_history.created_by IS 'sy_users: user_name';


--
-- TOC entry 6634 (class 0 OID 0)
-- Dependencies: 747
-- Name: COLUMN ms_athlete_violation_history.updated_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_athlete_violation_history.updated_by IS 'sy_users: user_name';


--
-- TOC entry 746 (class 1259 OID 19060)
-- Name: ms_athlete_violation_history_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.ms_athlete_violation_history ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ms_athlete_violation_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 725 (class 1259 OID 18194)
-- Name: ms_background; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.ms_background (
    id integer NOT NULL,
    background_code character varying(50) NOT NULL,
    type character varying(50) NOT NULL,
    status character varying(1) NOT NULL,
    information_description character varying(500) NOT NULL,
    image_file character varying(255),
    created_by character varying(50) NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(50) NOT NULL,
    updated_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data_row_version bigint DEFAULT 1 NOT NULL
);


ALTER TABLE public.ms_background OWNER TO sportevent;

--
-- TOC entry 6635 (class 0 OID 0)
-- Dependencies: 725
-- Name: COLUMN ms_background.background_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_background.background_code IS 'Mã Background';


--
-- TOC entry 6636 (class 0 OID 0)
-- Dependencies: 725
-- Name: COLUMN ms_background.type; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_background.type IS 'Mục Hiển thị sy_commons: Type = "BACKGROUND_TYPE"';


--
-- TOC entry 6637 (class 0 OID 0)
-- Dependencies: 725
-- Name: COLUMN ms_background.status; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_background.status IS 'Trạng thái sy_commons: Type = "COMMON_STATUS"';


--
-- TOC entry 6638 (class 0 OID 0)
-- Dependencies: 725
-- Name: COLUMN ms_background.information_description; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_background.information_description IS 'Thông tin';


--
-- TOC entry 6639 (class 0 OID 0)
-- Dependencies: 725
-- Name: COLUMN ms_background.image_file; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_background.image_file IS 'Đường dẫn file hình ảnh';


--
-- TOC entry 6640 (class 0 OID 0)
-- Dependencies: 725
-- Name: COLUMN ms_background.created_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_background.created_by IS 'sy_users: user_name';


--
-- TOC entry 6641 (class 0 OID 0)
-- Dependencies: 725
-- Name: COLUMN ms_background.updated_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_background.updated_by IS 'sy_users: user_name';


--
-- TOC entry 724 (class 1259 OID 18193)
-- Name: ms_background_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.ms_background ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ms_background_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 763 (class 1259 OID 19473)
-- Name: ms_certificates; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.ms_certificates (
    id integer NOT NULL,
    employee_code character varying(50) NOT NULL,
    certificate_name_vi character varying(255),
    certificate_name_en character varying(255),
    issued_by character varying(255),
    issue_date date,
    expiry_date date,
    description character varying(500),
    created_by character varying(50) NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(50) NOT NULL,
    updated_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data_row_version bigint DEFAULT 1 NOT NULL,
    specialty character varying(255),
    employee_type character varying(50) NOT NULL
);


ALTER TABLE public.ms_certificates OWNER TO sportevent;

--
-- TOC entry 6642 (class 0 OID 0)
-- Dependencies: 763
-- Name: COLUMN ms_certificates.employee_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_certificates.employee_code IS 'ms_employees: employee_code';


--
-- TOC entry 6643 (class 0 OID 0)
-- Dependencies: 763
-- Name: COLUMN ms_certificates.certificate_name_vi; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_certificates.certificate_name_vi IS 'Tên chứng chỉ VN';


--
-- TOC entry 6644 (class 0 OID 0)
-- Dependencies: 763
-- Name: COLUMN ms_certificates.certificate_name_en; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_certificates.certificate_name_en IS 'Tên chứng chỉ EN';


--
-- TOC entry 6645 (class 0 OID 0)
-- Dependencies: 763
-- Name: COLUMN ms_certificates.issued_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_certificates.issued_by IS 'Đơn vị cấp chứng chỉ';


--
-- TOC entry 6646 (class 0 OID 0)
-- Dependencies: 763
-- Name: COLUMN ms_certificates.expiry_date; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_certificates.expiry_date IS 'Ngày hết hạn';


--
-- TOC entry 6647 (class 0 OID 0)
-- Dependencies: 763
-- Name: COLUMN ms_certificates.description; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_certificates.description IS 'Ghi chú';


--
-- TOC entry 6648 (class 0 OID 0)
-- Dependencies: 763
-- Name: COLUMN ms_certificates.created_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_certificates.created_by IS 'sy_users: user_name';


--
-- TOC entry 6649 (class 0 OID 0)
-- Dependencies: 763
-- Name: COLUMN ms_certificates.updated_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_certificates.updated_by IS 'sy_users: user_name';


--
-- TOC entry 6650 (class 0 OID 0)
-- Dependencies: 763
-- Name: COLUMN ms_certificates.specialty; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_certificates.specialty IS 'chuyên môn';


--
-- TOC entry 762 (class 1259 OID 19472)
-- Name: ms_certificates_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.ms_certificates ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ms_certificates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 721 (class 1259 OID 18012)
-- Name: ms_competition_events; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.ms_competition_events (
    id integer NOT NULL,
    competition_code character varying(50) NOT NULL,
    competition_name_vi character varying(255) NOT NULL,
    competition_name_en character varying(255),
    host character varying(255) NOT NULL,
    status character varying(1) NOT NULL,
    start_date date,
    end_date date,
    created_by character varying(50) NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(50) NOT NULL,
    updated_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data_row_version bigint DEFAULT 1 NOT NULL
);


ALTER TABLE public.ms_competition_events OWNER TO sportevent;

--
-- TOC entry 6651 (class 0 OID 0)
-- Dependencies: 721
-- Name: COLUMN ms_competition_events.competition_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_competition_events.competition_code IS 'Mã sự kiện';


--
-- TOC entry 6652 (class 0 OID 0)
-- Dependencies: 721
-- Name: COLUMN ms_competition_events.competition_name_vi; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_competition_events.competition_name_vi IS 'Tên sự kiện VN';


--
-- TOC entry 6653 (class 0 OID 0)
-- Dependencies: 721
-- Name: COLUMN ms_competition_events.competition_name_en; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_competition_events.competition_name_en IS 'Tên sự kiện EN';


--
-- TOC entry 6654 (class 0 OID 0)
-- Dependencies: 721
-- Name: COLUMN ms_competition_events.host; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_competition_events.host IS 'Người đăng cai';


--
-- TOC entry 6655 (class 0 OID 0)
-- Dependencies: 721
-- Name: COLUMN ms_competition_events.status; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_competition_events.status IS 'Trạng thái';


--
-- TOC entry 6656 (class 0 OID 0)
-- Dependencies: 721
-- Name: COLUMN ms_competition_events.start_date; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_competition_events.start_date IS 'Ngày bắt đầu';


--
-- TOC entry 6657 (class 0 OID 0)
-- Dependencies: 721
-- Name: COLUMN ms_competition_events.end_date; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_competition_events.end_date IS 'Ngày kết thúc';


--
-- TOC entry 6658 (class 0 OID 0)
-- Dependencies: 721
-- Name: COLUMN ms_competition_events.created_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_competition_events.created_by IS 'sy_users: user_name';


--
-- TOC entry 6659 (class 0 OID 0)
-- Dependencies: 721
-- Name: COLUMN ms_competition_events.updated_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_competition_events.updated_by IS 'sy_users: user_name';


--
-- TOC entry 720 (class 1259 OID 18011)
-- Name: ms_competition_events_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.ms_competition_events ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ms_competition_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 835 (class 1259 OID 54908)
-- Name: ms_competition_profile; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.ms_competition_profile (
    id integer NOT NULL,
    employee_code character varying(50) NOT NULL,
    team_code character varying(50),
    sport_code character varying(50),
    certificate_name_vi character varying(255),
    certificate_name_en character varying(255),
    valid_from_date date,
    valid_to_date date,
    created_by character varying(50) NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(50) NOT NULL,
    updated_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data_row_version bigint DEFAULT 1 NOT NULL
);


ALTER TABLE public.ms_competition_profile OWNER TO sportevent;

--
-- TOC entry 6660 (class 0 OID 0)
-- Dependencies: 835
-- Name: TABLE ms_competition_profile; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON TABLE public.ms_competition_profile IS 'Bảng quản lý hồ sơ năng lực và chứng chỉ thi đấu của nhân sự/vận động viên';


--
-- TOC entry 6661 (class 0 OID 0)
-- Dependencies: 835
-- Name: COLUMN ms_competition_profile.id; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_competition_profile.id IS 'Khóa chính tự tăng';


--
-- TOC entry 6662 (class 0 OID 0)
-- Dependencies: 835
-- Name: COLUMN ms_competition_profile.employee_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_competition_profile.employee_code IS 'Mã thành viên - ms_employee: employee_code';


--
-- TOC entry 6663 (class 0 OID 0)
-- Dependencies: 835
-- Name: COLUMN ms_competition_profile.team_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_competition_profile.team_code IS 'Mã đội tuyển - ms_team: team_code';


--
-- TOC entry 6664 (class 0 OID 0)
-- Dependencies: 835
-- Name: COLUMN ms_competition_profile.sport_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_competition_profile.sport_code IS 'Mã môn thể thao - ms_sport: sport_code';


--
-- TOC entry 6665 (class 0 OID 0)
-- Dependencies: 835
-- Name: COLUMN ms_competition_profile.certificate_name_vi; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_competition_profile.certificate_name_vi IS 'Tên chứng chỉ/bằng cấp (Tiếng Việt)';


--
-- TOC entry 6666 (class 0 OID 0)
-- Dependencies: 835
-- Name: COLUMN ms_competition_profile.certificate_name_en; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_competition_profile.certificate_name_en IS 'Tên chứng chỉ/bằng cấp (Tiếng Anh)';


--
-- TOC entry 6667 (class 0 OID 0)
-- Dependencies: 835
-- Name: COLUMN ms_competition_profile.valid_to_date; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_competition_profile.valid_to_date IS 'Ngày hết hạn của chứng chỉ';


--
-- TOC entry 6668 (class 0 OID 0)
-- Dependencies: 835
-- Name: COLUMN ms_competition_profile.created_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_competition_profile.created_by IS 'Người tạo bản ghi';


--
-- TOC entry 6669 (class 0 OID 0)
-- Dependencies: 835
-- Name: COLUMN ms_competition_profile.updated_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_competition_profile.updated_by IS 'Người cập nhật bản ghi cuối cùng';


--
-- TOC entry 6670 (class 0 OID 0)
-- Dependencies: 835
-- Name: COLUMN ms_competition_profile.data_row_version; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_competition_profile.data_row_version IS 'Phiên bản dòng dữ liệu (Tăng dần mỗi khi Update)';


--
-- TOC entry 834 (class 1259 OID 54907)
-- Name: ms_competition_profile_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.ms_competition_profile ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ms_competition_profile_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 777 (class 1259 OID 19748)
-- Name: ms_competition_team_list; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.ms_competition_team_list (
    id integer NOT NULL,
    competition_code character varying(50) NOT NULL,
    team_code character varying(50) NOT NULL,
    created_by character varying(50) NOT NULL,
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(50) NOT NULL,
    updated_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data_row_version bigint DEFAULT 1 NOT NULL
);


ALTER TABLE public.ms_competition_team_list OWNER TO sportevent;

--
-- TOC entry 776 (class 1259 OID 19747)
-- Name: ms_competition_team_list_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.ms_competition_team_list ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ms_competition_team_list_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 837 (class 1259 OID 55434)
-- Name: ms_contents; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.ms_contents (
    id integer NOT NULL,
    content_code character varying(50) NOT NULL,
    title_vi character varying(255) NOT NULL,
    introductory_title_vi character varying(500) NOT NULL,
    title_en character varying(255),
    introductory_title_en character varying(500),
    sport_code character varying(50) NOT NULL,
    effective_date_from date NOT NULL,
    effective_date_to date NOT NULL,
    create_by_role character varying(255),
    viewer integer DEFAULT 0 NOT NULL,
    contents_vi text NOT NULL,
    contents_en text,
    thumbnail character varying(255) NOT NULL,
    file_image_1 character varying(255),
    file_image_2 character varying(255),
    file_image_3 character varying(255),
    approval_status character varying(50) NOT NULL,
    approval_by character varying(50) NOT NULL,
    approval_date date NOT NULL,
    created_by character varying(50) NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(50) NOT NULL,
    updated_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data_row_version bigint DEFAULT 1 NOT NULL,
    is_highlights boolean DEFAULT false NOT NULL,
    is_hot_content boolean DEFAULT false NOT NULL,
    is_home_page boolean DEFAULT false NOT NULL,
    slugs character varying
);


ALTER TABLE public.ms_contents OWNER TO sportevent;

--
-- TOC entry 6671 (class 0 OID 0)
-- Dependencies: 837
-- Name: COLUMN ms_contents.content_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_contents.content_code IS 'Mã tin tức';


--
-- TOC entry 6672 (class 0 OID 0)
-- Dependencies: 837
-- Name: COLUMN ms_contents.title_vi; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_contents.title_vi IS 'Tiêu đề tin tức';


--
-- TOC entry 6673 (class 0 OID 0)
-- Dependencies: 837
-- Name: COLUMN ms_contents.title_en; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_contents.title_en IS 'News title EN';


--
-- TOC entry 6674 (class 0 OID 0)
-- Dependencies: 837
-- Name: COLUMN ms_contents.introductory_title_en; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_contents.introductory_title_en IS 'Introductory title EN';


--
-- TOC entry 6675 (class 0 OID 0)
-- Dependencies: 837
-- Name: COLUMN ms_contents.sport_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_contents.sport_code IS 'Bộ môn ms_sports: sport_code';


--
-- TOC entry 6676 (class 0 OID 0)
-- Dependencies: 837
-- Name: COLUMN ms_contents.effective_date_from; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_contents.effective_date_from IS 'Hiệu lực từ ngày';


--
-- TOC entry 6677 (class 0 OID 0)
-- Dependencies: 837
-- Name: COLUMN ms_contents.effective_date_to; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_contents.effective_date_to IS 'Hiệu lực đến ngày';


--
-- TOC entry 6678 (class 0 OID 0)
-- Dependencies: 837
-- Name: COLUMN ms_contents.create_by_role; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_contents.create_by_role IS 'Vai trò người tạo';


--
-- TOC entry 6679 (class 0 OID 0)
-- Dependencies: 837
-- Name: COLUMN ms_contents.viewer; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_contents.viewer IS 'Số lượt xem';


--
-- TOC entry 6680 (class 0 OID 0)
-- Dependencies: 837
-- Name: COLUMN ms_contents.contents_vi; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_contents.contents_vi IS 'Nội dung';


--
-- TOC entry 6681 (class 0 OID 0)
-- Dependencies: 837
-- Name: COLUMN ms_contents.contents_en; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_contents.contents_en IS 'News content EN';


--
-- TOC entry 6682 (class 0 OID 0)
-- Dependencies: 837
-- Name: COLUMN ms_contents.file_image_1; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_contents.file_image_1 IS 'Hình ảnh 1';


--
-- TOC entry 6683 (class 0 OID 0)
-- Dependencies: 837
-- Name: COLUMN ms_contents.file_image_2; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_contents.file_image_2 IS 'Hình ảnh 2';


--
-- TOC entry 6684 (class 0 OID 0)
-- Dependencies: 837
-- Name: COLUMN ms_contents.file_image_3; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_contents.file_image_3 IS 'Hình ảnh 3';


--
-- TOC entry 6685 (class 0 OID 0)
-- Dependencies: 837
-- Name: COLUMN ms_contents.approval_status; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_contents.approval_status IS 'Trạng thái phê duyệt sy_commons: Type = "APPROVAL_STATUS"';


--
-- TOC entry 6686 (class 0 OID 0)
-- Dependencies: 837
-- Name: COLUMN ms_contents.approval_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_contents.approval_by IS 'Người phê duyệt';


--
-- TOC entry 6687 (class 0 OID 0)
-- Dependencies: 837
-- Name: COLUMN ms_contents.approval_date; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_contents.approval_date IS 'Ngày phê duyệt';


--
-- TOC entry 6688 (class 0 OID 0)
-- Dependencies: 837
-- Name: COLUMN ms_contents.created_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_contents.created_by IS 'sy_users: user_name';


--
-- TOC entry 6689 (class 0 OID 0)
-- Dependencies: 837
-- Name: COLUMN ms_contents.updated_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_contents.updated_by IS 'sy_users: user_name';


--
-- TOC entry 6690 (class 0 OID 0)
-- Dependencies: 837
-- Name: COLUMN ms_contents.slugs; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_contents.slugs IS 'slug cho web';


--
-- TOC entry 836 (class 1259 OID 55433)
-- Name: ms_contents_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.ms_contents ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ms_contents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 737 (class 1259 OID 18750)
-- Name: ms_discounts; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.ms_discounts (
    id integer NOT NULL,
    discount_code character varying(50) NOT NULL,
    discount_name_vi character varying(255) NOT NULL,
    discount_name_en character varying(255) NOT NULL,
    competition_code character varying(50) NOT NULL,
    effective_date_from date,
    effective_date_to date,
    status character varying(1) NOT NULL,
    discount_type character varying(60) NOT NULL,
    discount_value numeric(25,10) NOT NULL,
    max_discount_value numeric(25,10),
    min_discount_value numeric(25,10),
    total_discount integer NOT NULL,
    total_discount_used integer DEFAULT 0 NOT NULL,
    condition_discount character varying(50),
    created_by character varying(50) NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(50) NOT NULL,
    updated_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data_row_version bigint DEFAULT 1 NOT NULL
);


ALTER TABLE public.ms_discounts OWNER TO sportevent;

--
-- TOC entry 6691 (class 0 OID 0)
-- Dependencies: 737
-- Name: COLUMN ms_discounts.discount_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_discounts.discount_code IS 'Mã chương trình';


--
-- TOC entry 6692 (class 0 OID 0)
-- Dependencies: 737
-- Name: COLUMN ms_discounts.discount_name_vi; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_discounts.discount_name_vi IS 'Tên chương trình VN';


--
-- TOC entry 6693 (class 0 OID 0)
-- Dependencies: 737
-- Name: COLUMN ms_discounts.discount_name_en; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_discounts.discount_name_en IS 'Tên chương trình EN';


--
-- TOC entry 6694 (class 0 OID 0)
-- Dependencies: 737
-- Name: COLUMN ms_discounts.competition_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_discounts.competition_code IS 'Sự kiện ms_competition_events: competition_code';


--
-- TOC entry 6695 (class 0 OID 0)
-- Dependencies: 737
-- Name: COLUMN ms_discounts.effective_date_from; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_discounts.effective_date_from IS 'Hiệu lực từ ngày';


--
-- TOC entry 6696 (class 0 OID 0)
-- Dependencies: 737
-- Name: COLUMN ms_discounts.effective_date_to; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_discounts.effective_date_to IS 'Hiệu lực đến ngày';


--
-- TOC entry 6697 (class 0 OID 0)
-- Dependencies: 737
-- Name: COLUMN ms_discounts.status; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_discounts.status IS 'Trạng thái sy_commons: Type = "COMMON_STATUS"';


--
-- TOC entry 6698 (class 0 OID 0)
-- Dependencies: 737
-- Name: COLUMN ms_discounts.discount_type; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_discounts.discount_type IS 'Loại giảm giá sy_commons: Type = "DISCOUNT_TYPE"';


--
-- TOC entry 6699 (class 0 OID 0)
-- Dependencies: 737
-- Name: COLUMN ms_discounts.discount_value; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_discounts.discount_value IS 'Giá trị giảm';


--
-- TOC entry 6700 (class 0 OID 0)
-- Dependencies: 737
-- Name: COLUMN ms_discounts.max_discount_value; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_discounts.max_discount_value IS 'Giảm tối đa';


--
-- TOC entry 6701 (class 0 OID 0)
-- Dependencies: 737
-- Name: COLUMN ms_discounts.min_discount_value; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_discounts.min_discount_value IS 'Giảm tối thiểu';


--
-- TOC entry 6702 (class 0 OID 0)
-- Dependencies: 737
-- Name: COLUMN ms_discounts.total_discount; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_discounts.total_discount IS 'Tổng số lượt';


--
-- TOC entry 6703 (class 0 OID 0)
-- Dependencies: 737
-- Name: COLUMN ms_discounts.total_discount_used; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_discounts.total_discount_used IS 'Tổng số lượt đã dùng';


--
-- TOC entry 6704 (class 0 OID 0)
-- Dependencies: 737
-- Name: COLUMN ms_discounts.condition_discount; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_discounts.condition_discount IS 'Điều kiện áp dụng sy_commons: Type = "CONDITION_DISCOUNT"';


--
-- TOC entry 736 (class 1259 OID 18749)
-- Name: ms_discounts_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.ms_discounts ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ms_discounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 735 (class 1259 OID 18713)
-- Name: ms_employees; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.ms_employees (
    id integer NOT NULL,
    employee_code character varying(50) NOT NULL,
    employee_name_vi character varying(255) NOT NULL,
    employee_name_en character varying(255) NOT NULL,
    gender character varying(50),
    nationality character varying(50),
    address character varying(255),
    identity_card character varying(12) NOT NULL,
    emergency_contact character varying(255),
    allergy character varying(255),
    latest_effective_date timestamp(6) without time zone,
    health_check_certificate character varying(255),
    sports_insurance character varying(255),
    doping_test_date timestamp(6) without time zone,
    doping_test_result character varying(50),
    email character varying(150) NOT NULL,
    phone_number character varying(50),
    date_of_birth timestamp(6) without time zone,
    employee_type character varying(10),
    sport_code character varying(50),
    employee_status character varying(50),
    position_code character varying(50),
    status character varying(1) NOT NULL,
    skill character varying(255),
    height numeric(25,10),
    weight numeric(25,10),
    blood_type character varying(50),
    profile_picture character varying(255),
    created_by character varying(50) NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(50) NOT NULL,
    updated_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data_row_version bigint DEFAULT 1 NOT NULL,
    employee_types character varying[]
);


ALTER TABLE public.ms_employees OWNER TO sportevent;

--
-- TOC entry 6705 (class 0 OID 0)
-- Dependencies: 735
-- Name: TABLE ms_employees; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON TABLE public.ms_employees IS 'Bảng danh mục thành viên, nhân viên và vận động viên';


--
-- TOC entry 6706 (class 0 OID 0)
-- Dependencies: 735
-- Name: COLUMN ms_employees.employee_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_employees.employee_code IS 'Mã Thành viên';


--
-- TOC entry 6707 (class 0 OID 0)
-- Dependencies: 735
-- Name: COLUMN ms_employees.employee_name_vi; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_employees.employee_name_vi IS 'Tên thành viên VN';


--
-- TOC entry 6708 (class 0 OID 0)
-- Dependencies: 735
-- Name: COLUMN ms_employees.employee_name_en; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_employees.employee_name_en IS 'Tên thành viên EN';


--
-- TOC entry 6709 (class 0 OID 0)
-- Dependencies: 735
-- Name: COLUMN ms_employees.gender; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_employees.gender IS 'Giới tính sy_commons: Type = "GENDER"';


--
-- TOC entry 6710 (class 0 OID 0)
-- Dependencies: 735
-- Name: COLUMN ms_employees.nationality; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_employees.nationality IS 'Quốc tịch sy_commons: Type = "NATIONALITY"';


--
-- TOC entry 6711 (class 0 OID 0)
-- Dependencies: 735
-- Name: COLUMN ms_employees.address; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_employees.address IS 'Địa chỉ';


--
-- TOC entry 6712 (class 0 OID 0)
-- Dependencies: 735
-- Name: COLUMN ms_employees.identity_card; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_employees.identity_card IS 'CCCD';


--
-- TOC entry 6713 (class 0 OID 0)
-- Dependencies: 735
-- Name: COLUMN ms_employees.emergency_contact; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_employees.emergency_contact IS 'Liên hệ khẩn cấp';


--
-- TOC entry 6714 (class 0 OID 0)
-- Dependencies: 735
-- Name: COLUMN ms_employees.allergy; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_employees.allergy IS 'Dị ứng';


--
-- TOC entry 6715 (class 0 OID 0)
-- Dependencies: 735
-- Name: COLUMN ms_employees.latest_effective_date; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_employees.latest_effective_date IS 'Ngày hiệu lực mới nhất';


--
-- TOC entry 6716 (class 0 OID 0)
-- Dependencies: 735
-- Name: COLUMN ms_employees.health_check_certificate; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_employees.health_check_certificate IS 'Giấy khám sức khỏe';


--
-- TOC entry 6717 (class 0 OID 0)
-- Dependencies: 735
-- Name: COLUMN ms_employees.sports_insurance; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_employees.sports_insurance IS 'Bảo hiểm thể thao';


--
-- TOC entry 6718 (class 0 OID 0)
-- Dependencies: 735
-- Name: COLUMN ms_employees.doping_test_date; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_employees.doping_test_date IS 'Ngày kiểm tra Doping';


--
-- TOC entry 6719 (class 0 OID 0)
-- Dependencies: 735
-- Name: COLUMN ms_employees.doping_test_result; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_employees.doping_test_result IS 'Kết quả Doping';


--
-- TOC entry 6720 (class 0 OID 0)
-- Dependencies: 735
-- Name: COLUMN ms_employees.email; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_employees.email IS 'Email';


--
-- TOC entry 6721 (class 0 OID 0)
-- Dependencies: 735
-- Name: COLUMN ms_employees.phone_number; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_employees.phone_number IS 'Số điện thoại';


--
-- TOC entry 6722 (class 0 OID 0)
-- Dependencies: 735
-- Name: COLUMN ms_employees.date_of_birth; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_employees.date_of_birth IS 'Ngày sinh';


--
-- TOC entry 6723 (class 0 OID 0)
-- Dependencies: 735
-- Name: COLUMN ms_employees.employee_type; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_employees.employee_type IS 'Loại thành viên sy_commons: Type = "EMPLOYEE_TYPE"';


--
-- TOC entry 6724 (class 0 OID 0)
-- Dependencies: 735
-- Name: COLUMN ms_employees.sport_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_employees.sport_code IS 'Mã bộ môn ms_sports: sport_code';


--
-- TOC entry 6725 (class 0 OID 0)
-- Dependencies: 735
-- Name: COLUMN ms_employees.employee_status; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_employees.employee_status IS 'Tình trạng thi đấu sy_commons: Type = "EMPLOYEE_STATUS"';


--
-- TOC entry 6726 (class 0 OID 0)
-- Dependencies: 735
-- Name: COLUMN ms_employees.position_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_employees.position_code IS 'Chức vụ sy_commons: Type = "EMPLOYEE_POSITION"';


--
-- TOC entry 6727 (class 0 OID 0)
-- Dependencies: 735
-- Name: COLUMN ms_employees.status; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_employees.status IS 'Trạng thái sy_commons: Type = "COMMON_STATUS"';


--
-- TOC entry 6728 (class 0 OID 0)
-- Dependencies: 735
-- Name: COLUMN ms_employees.skill; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_employees.skill IS 'Kỹ năng';


--
-- TOC entry 6729 (class 0 OID 0)
-- Dependencies: 735
-- Name: COLUMN ms_employees.height; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_employees.height IS 'Chiều cao';


--
-- TOC entry 6730 (class 0 OID 0)
-- Dependencies: 735
-- Name: COLUMN ms_employees.weight; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_employees.weight IS 'Cân nặng';


--
-- TOC entry 6731 (class 0 OID 0)
-- Dependencies: 735
-- Name: COLUMN ms_employees.blood_type; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_employees.blood_type IS 'Nhóm máu';


--
-- TOC entry 6732 (class 0 OID 0)
-- Dependencies: 735
-- Name: COLUMN ms_employees.profile_picture; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_employees.profile_picture IS 'Ảnh đại diện';


--
-- TOC entry 6733 (class 0 OID 0)
-- Dependencies: 735
-- Name: COLUMN ms_employees.created_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_employees.created_by IS 'sy_users: user_name';


--
-- TOC entry 6734 (class 0 OID 0)
-- Dependencies: 735
-- Name: COLUMN ms_employees.updated_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_employees.updated_by IS 'sy_users: user_name';


--
-- TOC entry 6735 (class 0 OID 0)
-- Dependencies: 735
-- Name: COLUMN ms_employees.data_row_version; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_employees.data_row_version IS 'Phiên bản dữ liệu (Optimistic Concurrency Control)';


--
-- TOC entry 734 (class 1259 OID 18712)
-- Name: ms_employees_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.ms_employees ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ms_employees_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 787 (class 1259 OID 22025)
-- Name: ms_event_organizing; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.ms_event_organizing (
    id integer NOT NULL,
    event_title_vi character varying(255),
    event_title_en character varying(255),
    host_vi character varying(255),
    host_en character varying(255),
    open_ceremony_location_vi character varying(255) DEFAULT 'Sân vận động Thống Nhất'::character varying,
    open_ceremony_location_en character varying(255) DEFAULT 'Thong Nhat Stadium'::character varying,
    close_ceremony_location_vi character varying(255) DEFAULT 'Nhà Thi đấu Phú Thọ'::character varying,
    close_ceremony_location_en character varying(255) DEFAULT 'Phu Tho Indoor Stadium'::character varying,
    match_location_vi character varying(500),
    match_location_en character varying(500),
    start_date date DEFAULT '2026-11-15'::date NOT NULL,
    end_date date DEFAULT '2026-12-05'::date NOT NULL,
    email character varying(150) DEFAULT 'info@daihoidtt.gov.vn'::character varying,
    hotline character varying(50) DEFAULT '1900 1234'::character varying,
    link_facebook character varying(255),
    link_youtube character varying(255),
    link_tiktok character varying(255),
    image_file character varying(255)
);


ALTER TABLE public.ms_event_organizing OWNER TO sportevent;

--
-- TOC entry 6736 (class 0 OID 0)
-- Dependencies: 787
-- Name: COLUMN ms_event_organizing.event_title_vi; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_event_organizing.event_title_vi IS 'Tên sự kiện (Tiếng Việt)';


--
-- TOC entry 6737 (class 0 OID 0)
-- Dependencies: 787
-- Name: COLUMN ms_event_organizing.host_vi; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_event_organizing.host_vi IS 'Đơn vị chủ quản/tổ chức';


--
-- TOC entry 6738 (class 0 OID 0)
-- Dependencies: 787
-- Name: COLUMN ms_event_organizing.image_file; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_event_organizing.image_file IS 'Đường dẫn ảnh đại diện/Logo sự kiện';


--
-- TOC entry 786 (class 1259 OID 22024)
-- Name: ms_event_organizing_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.ms_event_organizing ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ms_event_organizing_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 765 (class 1259 OID 19501)
-- Name: ms_experiences; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.ms_experiences (
    id integer NOT NULL,
    employee_code character varying(50) NOT NULL,
    tournament character varying(255),
    total_matches integer,
    from_date date,
    to_date date,
    role character varying(50),
    organization character varying(255),
    description character varying(500),
    created_by character varying(50) NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(50) NOT NULL,
    updated_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data_row_version bigint DEFAULT 1 NOT NULL,
    employee_type character varying(50) NOT NULL
);


ALTER TABLE public.ms_experiences OWNER TO sportevent;

--
-- TOC entry 6739 (class 0 OID 0)
-- Dependencies: 765
-- Name: COLUMN ms_experiences.employee_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_experiences.employee_code IS 'ms_employees: employee_code';


--
-- TOC entry 6740 (class 0 OID 0)
-- Dependencies: 765
-- Name: COLUMN ms_experiences.tournament; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_experiences.tournament IS 'Giải đấu';


--
-- TOC entry 6741 (class 0 OID 0)
-- Dependencies: 765
-- Name: COLUMN ms_experiences.total_matches; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_experiences.total_matches IS 'Số trận';


--
-- TOC entry 6742 (class 0 OID 0)
-- Dependencies: 765
-- Name: COLUMN ms_experiences.from_date; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_experiences.from_date IS 'Thời gian từ';


--
-- TOC entry 6743 (class 0 OID 0)
-- Dependencies: 765
-- Name: COLUMN ms_experiences.to_date; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_experiences.to_date IS 'Thời gian đến';


--
-- TOC entry 6744 (class 0 OID 0)
-- Dependencies: 765
-- Name: COLUMN ms_experiences.role; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_experiences.role IS 'Vai trò';


--
-- TOC entry 6745 (class 0 OID 0)
-- Dependencies: 765
-- Name: COLUMN ms_experiences.organization; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_experiences.organization IS 'Đơn vị';


--
-- TOC entry 6746 (class 0 OID 0)
-- Dependencies: 765
-- Name: COLUMN ms_experiences.description; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_experiences.description IS 'Ghi chú';


--
-- TOC entry 6747 (class 0 OID 0)
-- Dependencies: 765
-- Name: COLUMN ms_experiences.created_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_experiences.created_by IS 'sy_users: user_name';


--
-- TOC entry 6748 (class 0 OID 0)
-- Dependencies: 765
-- Name: COLUMN ms_experiences.updated_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_experiences.updated_by IS 'sy_users: user_name';


--
-- TOC entry 764 (class 1259 OID 19500)
-- Name: ms_experiences_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.ms_experiences ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ms_experiences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 743 (class 1259 OID 19012)
-- Name: ms_injury_history; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.ms_injury_history (
    id integer NOT NULL,
    employee_code character varying(50) NOT NULL,
    injury_date date,
    injury_position character varying(255),
    injury_recovery_time character varying(255),
    level_of_injury character varying(50),
    description character varying(500),
    created_by character varying(50) NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(50) NOT NULL,
    updated_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data_row_version bigint DEFAULT 1 NOT NULL
);


ALTER TABLE public.ms_injury_history OWNER TO sportevent;

--
-- TOC entry 6749 (class 0 OID 0)
-- Dependencies: 743
-- Name: COLUMN ms_injury_history.employee_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_injury_history.employee_code IS 'Mã nhân viên (ms_employees: employee_code)';


--
-- TOC entry 6750 (class 0 OID 0)
-- Dependencies: 743
-- Name: COLUMN ms_injury_history.injury_date; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_injury_history.injury_date IS 'Ngày chấn thương';


--
-- TOC entry 6751 (class 0 OID 0)
-- Dependencies: 743
-- Name: COLUMN ms_injury_history.injury_position; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_injury_history.injury_position IS 'Vị trí';


--
-- TOC entry 6752 (class 0 OID 0)
-- Dependencies: 743
-- Name: COLUMN ms_injury_history.injury_recovery_time; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_injury_history.injury_recovery_time IS 'Thời gian hồi phục';


--
-- TOC entry 6753 (class 0 OID 0)
-- Dependencies: 743
-- Name: COLUMN ms_injury_history.level_of_injury; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_injury_history.level_of_injury IS 'Mức độ sy_commons: Type = "LEVELOFINJURY"';


--
-- TOC entry 6754 (class 0 OID 0)
-- Dependencies: 743
-- Name: COLUMN ms_injury_history.description; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_injury_history.description IS 'Ghi chú';


--
-- TOC entry 6755 (class 0 OID 0)
-- Dependencies: 743
-- Name: COLUMN ms_injury_history.created_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_injury_history.created_by IS 'sy_users: user_name';


--
-- TOC entry 6756 (class 0 OID 0)
-- Dependencies: 743
-- Name: COLUMN ms_injury_history.updated_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_injury_history.updated_by IS 'sy_users: user_name';


--
-- TOC entry 742 (class 1259 OID 19011)
-- Name: ms_injury_history_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.ms_injury_history ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ms_injury_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 731 (class 1259 OID 18545)
-- Name: ms_location_detail; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.ms_location_detail (
    id integer NOT NULL,
    location_code character varying(50) NOT NULL,
    area_code character varying(50) NOT NULL,
    area_name_vi character varying(255) NOT NULL,
    area_name_en character varying(255) NOT NULL,
    created_by character varying(50) NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(50) NOT NULL,
    updated_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data_row_version bigint DEFAULT 1 NOT NULL
);


ALTER TABLE public.ms_location_detail OWNER TO sportevent;

--
-- TOC entry 6757 (class 0 OID 0)
-- Dependencies: 731
-- Name: COLUMN ms_location_detail.location_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_location_detail.location_code IS 'Mã địa điểm ms_locations: location_code';


--
-- TOC entry 6758 (class 0 OID 0)
-- Dependencies: 731
-- Name: COLUMN ms_location_detail.area_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_location_detail.area_code IS 'Mã khu vực';


--
-- TOC entry 6759 (class 0 OID 0)
-- Dependencies: 731
-- Name: COLUMN ms_location_detail.area_name_vi; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_location_detail.area_name_vi IS 'Tên khu vực VN';


--
-- TOC entry 6760 (class 0 OID 0)
-- Dependencies: 731
-- Name: COLUMN ms_location_detail.area_name_en; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_location_detail.area_name_en IS 'Tên khu vực EN';


--
-- TOC entry 6761 (class 0 OID 0)
-- Dependencies: 731
-- Name: COLUMN ms_location_detail.created_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_location_detail.created_by IS 'sy_users: user_name';


--
-- TOC entry 6762 (class 0 OID 0)
-- Dependencies: 731
-- Name: COLUMN ms_location_detail.updated_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_location_detail.updated_by IS 'sy_users: user_name';


--
-- TOC entry 730 (class 1259 OID 18544)
-- Name: ms_location_detail_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.ms_location_detail ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ms_location_detail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 729 (class 1259 OID 18520)
-- Name: ms_locations; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.ms_locations (
    id integer NOT NULL,
    location_code character varying(50) NOT NULL,
    location_name_vi character varying(255) NOT NULL,
    location_name_en character varying(255) NOT NULL,
    province character varying(50) NOT NULL,
    address character varying(500) NOT NULL,
    status character varying(1) NOT NULL,
    open_time time without time zone,
    close_time time without time zone,
    description character varying(500),
    location_size integer,
    location_file_1 character varying(255),
    location_file_2 character varying(255),
    created_by character varying(50) NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(50) NOT NULL,
    updated_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data_row_version bigint DEFAULT 1 NOT NULL
);


ALTER TABLE public.ms_locations OWNER TO sportevent;

--
-- TOC entry 6763 (class 0 OID 0)
-- Dependencies: 729
-- Name: COLUMN ms_locations.location_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_locations.location_code IS 'Mã địa điểm';


--
-- TOC entry 6764 (class 0 OID 0)
-- Dependencies: 729
-- Name: COLUMN ms_locations.location_name_vi; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_locations.location_name_vi IS 'Tên điểm thi đấu VN';


--
-- TOC entry 6765 (class 0 OID 0)
-- Dependencies: 729
-- Name: COLUMN ms_locations.location_name_en; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_locations.location_name_en IS 'Tên điểm thi đấu EN';


--
-- TOC entry 6766 (class 0 OID 0)
-- Dependencies: 729
-- Name: COLUMN ms_locations.province; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_locations.province IS 'Tỉnh thành phố sy_commons: Type = "PROVINCE"';


--
-- TOC entry 6767 (class 0 OID 0)
-- Dependencies: 729
-- Name: COLUMN ms_locations.address; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_locations.address IS 'Địa chỉ';


--
-- TOC entry 6768 (class 0 OID 0)
-- Dependencies: 729
-- Name: COLUMN ms_locations.status; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_locations.status IS 'Trạng thái sy_commons: Type = "COMMON_STATUS"';


--
-- TOC entry 6769 (class 0 OID 0)
-- Dependencies: 729
-- Name: COLUMN ms_locations.open_time; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_locations.open_time IS 'Giờ mở cửa';


--
-- TOC entry 6770 (class 0 OID 0)
-- Dependencies: 729
-- Name: COLUMN ms_locations.close_time; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_locations.close_time IS 'Giờ đóng cửa';


--
-- TOC entry 6771 (class 0 OID 0)
-- Dependencies: 729
-- Name: COLUMN ms_locations.description; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_locations.description IS 'Ghi chú';


--
-- TOC entry 6772 (class 0 OID 0)
-- Dependencies: 729
-- Name: COLUMN ms_locations.location_size; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_locations.location_size IS 'Sức chứa';


--
-- TOC entry 6773 (class 0 OID 0)
-- Dependencies: 729
-- Name: COLUMN ms_locations.location_file_1; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_locations.location_file_1 IS 'Sơ đồ địa điểm';


--
-- TOC entry 6774 (class 0 OID 0)
-- Dependencies: 729
-- Name: COLUMN ms_locations.location_file_2; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_locations.location_file_2 IS 'Hình ảnh địa điểm';


--
-- TOC entry 6775 (class 0 OID 0)
-- Dependencies: 729
-- Name: COLUMN ms_locations.created_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_locations.created_by IS 'sy_users: user_name';


--
-- TOC entry 6776 (class 0 OID 0)
-- Dependencies: 729
-- Name: COLUMN ms_locations.updated_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_locations.updated_by IS 'sy_users: user_name';


--
-- TOC entry 728 (class 1259 OID 18519)
-- Name: ms_locations_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.ms_locations ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ms_locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 789 (class 1259 OID 22044)
-- Name: ms_publisher; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.ms_publisher (
    id integer NOT NULL,
    company_name_vi character varying(255) NOT NULL,
    company_name_en character varying(255),
    head_office_vi character varying(255) NOT NULL,
    head_office_en character varying(255),
    email character varying(150) NOT NULL,
    phone_number character varying(50) NOT NULL,
    image_file character varying(255) NOT NULL
);


ALTER TABLE public.ms_publisher OWNER TO sportevent;

--
-- TOC entry 6777 (class 0 OID 0)
-- Dependencies: 789
-- Name: COLUMN ms_publisher.company_name_vi; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_publisher.company_name_vi IS 'Tên công ty (Tiếng Việt)';


--
-- TOC entry 6778 (class 0 OID 0)
-- Dependencies: 789
-- Name: COLUMN ms_publisher.head_office_vi; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_publisher.head_office_vi IS 'Địa chỉ trụ sở chính (Tiếng Việt)';


--
-- TOC entry 6779 (class 0 OID 0)
-- Dependencies: 789
-- Name: COLUMN ms_publisher.image_file; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_publisher.image_file IS 'Đường dẫn tập tin logo/hình ảnh';


--
-- TOC entry 788 (class 1259 OID 22043)
-- Name: ms_publisher_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.ms_publisher ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ms_publisher_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 727 (class 1259 OID 18219)
-- Name: ms_sponsors; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.ms_sponsors (
    id integer NOT NULL,
    sponsor_code character varying(50) NOT NULL,
    sponsor_name_vi character varying(255) NOT NULL,
    sponsor_name_en character varying(255),
    effective_date_from date NOT NULL,
    effective_date_to date NOT NULL,
    logo_file character varying(255) NOT NULL,
    image_file_1 character varying(255) NOT NULL,
    image_file_2 character varying(255) NOT NULL,
    image_file_3 character varying(255) NOT NULL,
    status character varying(1) NOT NULL,
    created_by character varying(50) NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(50) NOT NULL,
    updated_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data_row_version bigint DEFAULT 1 NOT NULL
);


ALTER TABLE public.ms_sponsors OWNER TO sportevent;

--
-- TOC entry 6780 (class 0 OID 0)
-- Dependencies: 727
-- Name: COLUMN ms_sponsors.sponsor_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_sponsors.sponsor_code IS 'Mã nhà tài trợ';


--
-- TOC entry 6781 (class 0 OID 0)
-- Dependencies: 727
-- Name: COLUMN ms_sponsors.sponsor_name_vi; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_sponsors.sponsor_name_vi IS 'Tên nhà tài trợ VN';


--
-- TOC entry 6782 (class 0 OID 0)
-- Dependencies: 727
-- Name: COLUMN ms_sponsors.sponsor_name_en; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_sponsors.sponsor_name_en IS 'Tên nhà tài trợ EN';


--
-- TOC entry 6783 (class 0 OID 0)
-- Dependencies: 727
-- Name: COLUMN ms_sponsors.effective_date_from; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_sponsors.effective_date_from IS 'Hiệu lực từ ngày';


--
-- TOC entry 6784 (class 0 OID 0)
-- Dependencies: 727
-- Name: COLUMN ms_sponsors.effective_date_to; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_sponsors.effective_date_to IS 'Hiệu lực đến ngày';


--
-- TOC entry 6785 (class 0 OID 0)
-- Dependencies: 727
-- Name: COLUMN ms_sponsors.logo_file; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_sponsors.logo_file IS 'Logo nhà tài trợ';


--
-- TOC entry 6786 (class 0 OID 0)
-- Dependencies: 727
-- Name: COLUMN ms_sponsors.image_file_1; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_sponsors.image_file_1 IS 'Hình quảng cáo 1';


--
-- TOC entry 6787 (class 0 OID 0)
-- Dependencies: 727
-- Name: COLUMN ms_sponsors.image_file_2; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_sponsors.image_file_2 IS 'Hình quảng cáo 2';


--
-- TOC entry 6788 (class 0 OID 0)
-- Dependencies: 727
-- Name: COLUMN ms_sponsors.image_file_3; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_sponsors.image_file_3 IS 'Hình quảng cáo 3';


--
-- TOC entry 6789 (class 0 OID 0)
-- Dependencies: 727
-- Name: COLUMN ms_sponsors.status; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_sponsors.status IS 'Trạng thái sy_commons: Type = "COMMON_STATUS"';


--
-- TOC entry 6790 (class 0 OID 0)
-- Dependencies: 727
-- Name: COLUMN ms_sponsors.created_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_sponsors.created_by IS 'sy_users: user_name';


--
-- TOC entry 6791 (class 0 OID 0)
-- Dependencies: 727
-- Name: COLUMN ms_sponsors.updated_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_sponsors.updated_by IS 'sy_users: user_name';


--
-- TOC entry 726 (class 1259 OID 18218)
-- Name: ms_sponsors_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.ms_sponsors ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ms_sponsors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 717 (class 1259 OID 17901)
-- Name: ms_sport_detail; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.ms_sport_detail (
    id integer NOT NULL,
    sport_code character varying(50) NOT NULL,
    sport_event_code character varying(50) NOT NULL,
    sport_event_name_vi character varying(255) NOT NULL,
    sport_event_name_en character varying(255) NOT NULL,
    status character varying(1) NOT NULL,
    description character varying(500),
    created_by character varying(50) NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(50) NOT NULL,
    updated_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data_row_version bigint DEFAULT 1 NOT NULL
);


ALTER TABLE public.ms_sport_detail OWNER TO sportevent;

--
-- TOC entry 6792 (class 0 OID 0)
-- Dependencies: 717
-- Name: COLUMN ms_sport_detail.sport_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_sport_detail.sport_code IS 'Mã bộ môn';


--
-- TOC entry 6793 (class 0 OID 0)
-- Dependencies: 717
-- Name: COLUMN ms_sport_detail.sport_event_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_sport_detail.sport_event_code IS 'Mã nội dung';


--
-- TOC entry 6794 (class 0 OID 0)
-- Dependencies: 717
-- Name: COLUMN ms_sport_detail.sport_event_name_vi; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_sport_detail.sport_event_name_vi IS 'Tên nội dung VN';


--
-- TOC entry 6795 (class 0 OID 0)
-- Dependencies: 717
-- Name: COLUMN ms_sport_detail.sport_event_name_en; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_sport_detail.sport_event_name_en IS 'Tên nội dung EN';


--
-- TOC entry 6796 (class 0 OID 0)
-- Dependencies: 717
-- Name: COLUMN ms_sport_detail.status; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_sport_detail.status IS 'Trạng thái sy_commons: Type = "COMMON_STATUS"';


--
-- TOC entry 6797 (class 0 OID 0)
-- Dependencies: 717
-- Name: COLUMN ms_sport_detail.description; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_sport_detail.description IS 'Mô tả';


--
-- TOC entry 6798 (class 0 OID 0)
-- Dependencies: 717
-- Name: COLUMN ms_sport_detail.created_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_sport_detail.created_by IS 'sy_users: UserName';


--
-- TOC entry 6799 (class 0 OID 0)
-- Dependencies: 717
-- Name: COLUMN ms_sport_detail.updated_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_sport_detail.updated_by IS 'sy_users: UserName';


--
-- TOC entry 716 (class 1259 OID 17900)
-- Name: ms_sport_detail_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.ms_sport_detail ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ms_sport_detail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 775 (class 1259 OID 19714)
-- Name: ms_sport_events; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.ms_sport_events (
    id integer NOT NULL,
    competition_code character varying(50) NOT NULL,
    sport_code character varying(50) NOT NULL,
    sport_event_code character varying(500) NOT NULL,
    location_code character varying(255) NOT NULL,
    created_by character varying(50) NOT NULL,
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(50) NOT NULL,
    updated_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data_row_version bigint DEFAULT 1 NOT NULL
);


ALTER TABLE public.ms_sport_events OWNER TO sportevent;

--
-- TOC entry 774 (class 1259 OID 19713)
-- Name: ms_sport_events_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.ms_sport_events ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ms_sport_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 715 (class 1259 OID 16850)
-- Name: ms_sports; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.ms_sports (
    id integer NOT NULL,
    sport_code character varying(50) CONSTRAINT ms_sports_sportcode_not_null NOT NULL,
    sport_name_vi character varying(255) CONSTRAINT ms_sports_sportnamevi_not_null NOT NULL,
    sport_name_en character varying(255) NOT NULL,
    status character varying(1) NOT NULL,
    description character varying(500),
    created_by character varying(50) CONSTRAINT ms_sports_createdby_not_null NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP CONSTRAINT ms_sports_createddate_not_null NOT NULL,
    updated_by character varying(50) CONSTRAINT ms_sports_updatedby_not_null NOT NULL,
    updated_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP CONSTRAINT ms_sports_updateddate_not_null NOT NULL,
    data_row_version bigint DEFAULT 1 CONSTRAINT ms_sports_datarowversion_not_null NOT NULL,
    logo character varying(255) NOT NULL
);


ALTER TABLE public.ms_sports OWNER TO sportevent;

--
-- TOC entry 6800 (class 0 OID 0)
-- Dependencies: 715
-- Name: COLUMN ms_sports.sport_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_sports.sport_code IS 'Mã môn';


--
-- TOC entry 6801 (class 0 OID 0)
-- Dependencies: 715
-- Name: COLUMN ms_sports.sport_name_vi; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_sports.sport_name_vi IS 'Tên môn VN';


--
-- TOC entry 6802 (class 0 OID 0)
-- Dependencies: 715
-- Name: COLUMN ms_sports.sport_name_en; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_sports.sport_name_en IS 'Tên Môn EN';


--
-- TOC entry 6803 (class 0 OID 0)
-- Dependencies: 715
-- Name: COLUMN ms_sports.status; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_sports.status IS 'Trạng thái sy_commons: Type = "COMMON_STATUS"';


--
-- TOC entry 6804 (class 0 OID 0)
-- Dependencies: 715
-- Name: COLUMN ms_sports.description; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_sports.description IS 'Mô tả';


--
-- TOC entry 6805 (class 0 OID 0)
-- Dependencies: 715
-- Name: COLUMN ms_sports.created_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_sports.created_by IS 'sy_users: UserName';


--
-- TOC entry 6806 (class 0 OID 0)
-- Dependencies: 715
-- Name: COLUMN ms_sports.updated_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_sports.updated_by IS 'sy_users: UserName';


--
-- TOC entry 6807 (class 0 OID 0)
-- Dependencies: 715
-- Name: COLUMN ms_sports.logo; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_sports.logo IS 'Logo môn thi đấu';


--
-- TOC entry 714 (class 1259 OID 16849)
-- Name: ms_sports_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.ms_sports ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ms_sports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 749 (class 1259 OID 19094)
-- Name: ms_team_athletes; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.ms_team_athletes (
    id integer NOT NULL,
    team_code character varying(50) NOT NULL,
    emp_athlete_code character varying(50) CONSTRAINT ms_team_athletes_employee_code_not_null NOT NULL,
    effective_date_from date NOT NULL,
    effective_date_to date,
    created_by character varying(50) NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(50) NOT NULL,
    updated_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data_row_version bigint DEFAULT 1 NOT NULL,
    emp_athlete_position character varying(50)
);


ALTER TABLE public.ms_team_athletes OWNER TO sportevent;

--
-- TOC entry 6808 (class 0 OID 0)
-- Dependencies: 749
-- Name: COLUMN ms_team_athletes.team_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_team_athletes.team_code IS 'Mã đội tuyển ms_teams: team_code';


--
-- TOC entry 6809 (class 0 OID 0)
-- Dependencies: 749
-- Name: COLUMN ms_team_athletes.emp_athlete_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_team_athletes.emp_athlete_code IS 'Mã vận động viên ms_employees: employee_code';


--
-- TOC entry 6810 (class 0 OID 0)
-- Dependencies: 749
-- Name: COLUMN ms_team_athletes.effective_date_from; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_team_athletes.effective_date_from IS 'Ngày hiệu lực từ';


--
-- TOC entry 6811 (class 0 OID 0)
-- Dependencies: 749
-- Name: COLUMN ms_team_athletes.effective_date_to; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_team_athletes.effective_date_to IS 'Ngày hiệu lực đến';


--
-- TOC entry 6812 (class 0 OID 0)
-- Dependencies: 749
-- Name: COLUMN ms_team_athletes.created_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_team_athletes.created_by IS 'sy_users: user_name';


--
-- TOC entry 6813 (class 0 OID 0)
-- Dependencies: 749
-- Name: COLUMN ms_team_athletes.updated_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_team_athletes.updated_by IS 'sy_users: user_name';


--
-- TOC entry 748 (class 1259 OID 19093)
-- Name: ms_team_athletes_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.ms_team_athletes ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ms_team_athletes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 751 (class 1259 OID 19122)
-- Name: ms_team_coachs; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.ms_team_coachs (
    id integer NOT NULL,
    team_code character varying(50) NOT NULL,
    emp_coach_code character varying(50) NOT NULL,
    emp_coach_role character varying(50),
    effective_date_from date NOT NULL,
    effective_date_to date,
    created_by character varying(50) NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(50) NOT NULL,
    updated_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data_row_version bigint DEFAULT 1 NOT NULL
);


ALTER TABLE public.ms_team_coachs OWNER TO sportevent;

--
-- TOC entry 6814 (class 0 OID 0)
-- Dependencies: 751
-- Name: COLUMN ms_team_coachs.team_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_team_coachs.team_code IS 'Mã đội tuyển ms_teams: team_code';


--
-- TOC entry 6815 (class 0 OID 0)
-- Dependencies: 751
-- Name: COLUMN ms_team_coachs.emp_coach_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_team_coachs.emp_coach_code IS 'Mã huấn luyện viên ms_employees: employee_code';


--
-- TOC entry 6816 (class 0 OID 0)
-- Dependencies: 751
-- Name: COLUMN ms_team_coachs.emp_coach_role; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_team_coachs.emp_coach_role IS 'Vai trò của huấn luyện viên trong đội sy_commons: Type = "COACH_ROLE"';


--
-- TOC entry 6817 (class 0 OID 0)
-- Dependencies: 751
-- Name: COLUMN ms_team_coachs.effective_date_from; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_team_coachs.effective_date_from IS 'Ngày hiệu lực từ';


--
-- TOC entry 6818 (class 0 OID 0)
-- Dependencies: 751
-- Name: COLUMN ms_team_coachs.effective_date_to; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_team_coachs.effective_date_to IS 'Ngày hiệu lực đến';


--
-- TOC entry 6819 (class 0 OID 0)
-- Dependencies: 751
-- Name: COLUMN ms_team_coachs.created_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_team_coachs.created_by IS 'sy_users: user_name';


--
-- TOC entry 6820 (class 0 OID 0)
-- Dependencies: 751
-- Name: COLUMN ms_team_coachs.updated_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_team_coachs.updated_by IS 'sy_users: user_name';


--
-- TOC entry 750 (class 1259 OID 19121)
-- Name: ms_team_coachs_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.ms_team_coachs ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ms_team_coachs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 719 (class 1259 OID 17986)
-- Name: ms_teams; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.ms_teams (
    id integer NOT NULL,
    team_code character varying(50) NOT NULL,
    team_name_vi character varying(255) NOT NULL,
    team_name_en character varying(255) NOT NULL,
    sports_delegation character varying(255) NOT NULL,
    sport_code character varying(50) NOT NULL,
    team_size integer,
    regist_date date,
    status character varying(1) NOT NULL,
    logo character varying(255),
    description character varying(500),
    created_by character varying(50) NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(50) NOT NULL,
    updated_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data_row_version bigint DEFAULT 1 NOT NULL
);


ALTER TABLE public.ms_teams OWNER TO sportevent;

--
-- TOC entry 6821 (class 0 OID 0)
-- Dependencies: 719
-- Name: COLUMN ms_teams.team_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_teams.team_code IS 'Mã đội tuyển';


--
-- TOC entry 6822 (class 0 OID 0)
-- Dependencies: 719
-- Name: COLUMN ms_teams.team_name_vi; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_teams.team_name_vi IS 'Tên đội tuyển VN';


--
-- TOC entry 6823 (class 0 OID 0)
-- Dependencies: 719
-- Name: COLUMN ms_teams.team_name_en; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_teams.team_name_en IS 'Tên đội tuyển EN';


--
-- TOC entry 6824 (class 0 OID 0)
-- Dependencies: 719
-- Name: COLUMN ms_teams.sports_delegation; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_teams.sports_delegation IS 'Đoàn thể thao';


--
-- TOC entry 6825 (class 0 OID 0)
-- Dependencies: 719
-- Name: COLUMN ms_teams.sport_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_teams.sport_code IS 'Bộ môn ms_sports: sport_code';


--
-- TOC entry 6826 (class 0 OID 0)
-- Dependencies: 719
-- Name: COLUMN ms_teams.team_size; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_teams.team_size IS 'Số lượng vận động viên';


--
-- TOC entry 6827 (class 0 OID 0)
-- Dependencies: 719
-- Name: COLUMN ms_teams.regist_date; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_teams.regist_date IS 'Ngày đăng ký';


--
-- TOC entry 6828 (class 0 OID 0)
-- Dependencies: 719
-- Name: COLUMN ms_teams.status; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_teams.status IS 'Trạng thái sy_commons: Type = "COMMON_STATUS"';


--
-- TOC entry 6829 (class 0 OID 0)
-- Dependencies: 719
-- Name: COLUMN ms_teams.logo; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_teams.logo IS 'Logo';


--
-- TOC entry 6830 (class 0 OID 0)
-- Dependencies: 719
-- Name: COLUMN ms_teams.description; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_teams.description IS 'Ghi chú';


--
-- TOC entry 6831 (class 0 OID 0)
-- Dependencies: 719
-- Name: COLUMN ms_teams.created_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_teams.created_by IS 'sy_users: user_name';


--
-- TOC entry 6832 (class 0 OID 0)
-- Dependencies: 719
-- Name: COLUMN ms_teams.updated_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_teams.updated_by IS 'sy_users: user_name';


--
-- TOC entry 718 (class 1259 OID 17985)
-- Name: ms_teams_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.ms_teams ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ms_teams_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 723 (class 1259 OID 18035)
-- Name: ms_ticket_categories; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.ms_ticket_categories (
    id integer NOT NULL,
    category_code character varying(50) NOT NULL,
    category_name_vi character varying(255) NOT NULL,
    category_name_en character varying(255) NOT NULL,
    competition_code character varying(50) NOT NULL,
    status character varying(1) NOT NULL,
    description character varying(500),
    created_by character varying(50) NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(50) NOT NULL,
    updated_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data_row_version bigint DEFAULT 1 NOT NULL
);


ALTER TABLE public.ms_ticket_categories OWNER TO sportevent;

--
-- TOC entry 6833 (class 0 OID 0)
-- Dependencies: 723
-- Name: COLUMN ms_ticket_categories.category_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_ticket_categories.category_code IS 'Mã hạng mục';


--
-- TOC entry 6834 (class 0 OID 0)
-- Dependencies: 723
-- Name: COLUMN ms_ticket_categories.category_name_vi; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_ticket_categories.category_name_vi IS 'Tên hạng mục VN';


--
-- TOC entry 6835 (class 0 OID 0)
-- Dependencies: 723
-- Name: COLUMN ms_ticket_categories.category_name_en; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_ticket_categories.category_name_en IS 'Tên hạng mục EN';


--
-- TOC entry 6836 (class 0 OID 0)
-- Dependencies: 723
-- Name: COLUMN ms_ticket_categories.competition_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_ticket_categories.competition_code IS 'Sự kiện ms_competition_events: competition_code';


--
-- TOC entry 6837 (class 0 OID 0)
-- Dependencies: 723
-- Name: COLUMN ms_ticket_categories.status; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_ticket_categories.status IS 'Trạng thái sy_commons: Type = "COMMON_STATUS"';


--
-- TOC entry 6838 (class 0 OID 0)
-- Dependencies: 723
-- Name: COLUMN ms_ticket_categories.description; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_ticket_categories.description IS 'Ghi chú';


--
-- TOC entry 6839 (class 0 OID 0)
-- Dependencies: 723
-- Name: COLUMN ms_ticket_categories.created_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_ticket_categories.created_by IS 'sy_users: user_name';


--
-- TOC entry 6840 (class 0 OID 0)
-- Dependencies: 723
-- Name: COLUMN ms_ticket_categories.updated_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ms_ticket_categories.updated_by IS 'sy_users: user_name';


--
-- TOC entry 722 (class 1259 OID 18034)
-- Name: ms_ticket_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.ms_ticket_categories ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ms_ticket_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 739 (class 1259 OID 18781)
-- Name: se_chatbot; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.se_chatbot (
    id integer NOT NULL,
    document_code character varying(50) NOT NULL,
    document_name character varying(255) NOT NULL,
    document_file character varying(500) NOT NULL,
    status character varying(1) NOT NULL,
    created_by character varying(50) NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(50) NOT NULL,
    updated_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data_row_version bigint DEFAULT 1 NOT NULL
);


ALTER TABLE public.se_chatbot OWNER TO sportevent;

--
-- TOC entry 6841 (class 0 OID 0)
-- Dependencies: 739
-- Name: COLUMN se_chatbot.document_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.se_chatbot.document_code IS 'Mã tài liệu';


--
-- TOC entry 6842 (class 0 OID 0)
-- Dependencies: 739
-- Name: COLUMN se_chatbot.document_name; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.se_chatbot.document_name IS 'Tên tài liệu';


--
-- TOC entry 6843 (class 0 OID 0)
-- Dependencies: 739
-- Name: COLUMN se_chatbot.document_file; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.se_chatbot.document_file IS 'Đính kèm các File Upload (Đường dẫn file)';


--
-- TOC entry 6844 (class 0 OID 0)
-- Dependencies: 739
-- Name: COLUMN se_chatbot.status; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.se_chatbot.status IS 'Trạng thái sy_commons: Type = "COMMON_STATUS"';


--
-- TOC entry 6845 (class 0 OID 0)
-- Dependencies: 739
-- Name: COLUMN se_chatbot.created_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.se_chatbot.created_by IS 'sy_users: user_name';


--
-- TOC entry 6846 (class 0 OID 0)
-- Dependencies: 739
-- Name: COLUMN se_chatbot.updated_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.se_chatbot.updated_by IS 'sy_users: user_name';


--
-- TOC entry 738 (class 1259 OID 18780)
-- Name: se_chatbot_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.se_chatbot ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.se_chatbot_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 833 (class 1259 OID 54665)
-- Name: se_chatbot_message; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.se_chatbot_message (
    id integer NOT NULL,
    room_id character varying(100) NOT NULL,
    sender_employee_code character varying(50) NOT NULL,
    receive_employee_code character varying(50) NOT NULL,
    message text,
    message_plain character varying(500),
    time_stamp timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.se_chatbot_message OWNER TO sportevent;

--
-- TOC entry 6847 (class 0 OID 0)
-- Dependencies: 833
-- Name: TABLE se_chatbot_message; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON TABLE public.se_chatbot_message IS 'Bảng lưu trữ lịch sử tin nhắn trao đổi (Chat Log) giữa nhân viên và Chatbot';


--
-- TOC entry 6848 (class 0 OID 0)
-- Dependencies: 833
-- Name: COLUMN se_chatbot_message.id; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.se_chatbot_message.id IS 'Khóa chính tự tăng của bản ghi tin nhắn';


--
-- TOC entry 6849 (class 0 OID 0)
-- Dependencies: 833
-- Name: COLUMN se_chatbot_message.room_id; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.se_chatbot_message.room_id IS 'Mã định danh phòng chat (Dùng để nhóm cuộc hội thoại)';


--
-- TOC entry 6850 (class 0 OID 0)
-- Dependencies: 833
-- Name: COLUMN se_chatbot_message.sender_employee_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.se_chatbot_message.sender_employee_code IS 'Mã nhân viên người gửi tin nhắn';


--
-- TOC entry 6851 (class 0 OID 0)
-- Dependencies: 833
-- Name: COLUMN se_chatbot_message.receive_employee_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.se_chatbot_message.receive_employee_code IS 'Mã nhân viên người nhận tin nhắn';


--
-- TOC entry 6852 (class 0 OID 0)
-- Dependencies: 833
-- Name: COLUMN se_chatbot_message.message; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.se_chatbot_message.message IS 'Nội dung tin nhắn gốc (Có thể bao gồm định dạng HTML/Markdown)';


--
-- TOC entry 6853 (class 0 OID 0)
-- Dependencies: 833
-- Name: COLUMN se_chatbot_message.message_plain; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.se_chatbot_message.message_plain IS 'Nội dung tin nhắn dạng văn bản thuần (Dùng cho tìm kiếm nhanh)';


--
-- TOC entry 6854 (class 0 OID 0)
-- Dependencies: 833
-- Name: COLUMN se_chatbot_message.time_stamp; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.se_chatbot_message.time_stamp IS 'Thời điểm tin nhắn được gửi hệ thống';


--
-- TOC entry 832 (class 1259 OID 54664)
-- Name: se_chatbot_message_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.se_chatbot_message ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.se_chatbot_message_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 822 (class 1259 OID 28691)
-- Name: se_file_embeddings; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.se_file_embeddings (
    id bigint NOT NULL,
    file_name character varying(255) NOT NULL,
    page_no integer,
    chunk_text text,
    chunk_embed public.vector(1024),
    modality character varying(100) DEFAULT 'text'::character varying,
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by character varying(100)
);


ALTER TABLE public.se_file_embeddings OWNER TO sportevent;

--
-- TOC entry 821 (class 1259 OID 28690)
-- Name: se_file_embeddings_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.se_file_embeddings ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.se_file_embeddings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 769 (class 1259 OID 19610)
-- Name: sr_match_athletes; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.sr_match_athletes (
    id integer NOT NULL,
    match_code character varying(50) NOT NULL,
    emp_athlete_code character varying(50) NOT NULL,
    position_code character varying(50),
    created_by character varying(50) NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(50) NOT NULL,
    updated_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    team_code character varying(50)
);


ALTER TABLE public.sr_match_athletes OWNER TO sportevent;

--
-- TOC entry 6855 (class 0 OID 0)
-- Dependencies: 769
-- Name: COLUMN sr_match_athletes.match_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_athletes.match_code IS 'Mã trận đấu sr_match_athletes: match_code';


--
-- TOC entry 6856 (class 0 OID 0)
-- Dependencies: 769
-- Name: COLUMN sr_match_athletes.emp_athlete_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_athletes.emp_athlete_code IS 'Mã vận động viên ms_employees: employee_code';


--
-- TOC entry 6857 (class 0 OID 0)
-- Dependencies: 769
-- Name: COLUMN sr_match_athletes.position_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_athletes.position_code IS 'Chức vụ/vị trí ms_employees: position_code';


--
-- TOC entry 6858 (class 0 OID 0)
-- Dependencies: 769
-- Name: COLUMN sr_match_athletes.created_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_athletes.created_by IS 'sy_users: user_name';


--
-- TOC entry 6859 (class 0 OID 0)
-- Dependencies: 769
-- Name: COLUMN sr_match_athletes.updated_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_athletes.updated_by IS 'sy_users: user_name';


--
-- TOC entry 6860 (class 0 OID 0)
-- Dependencies: 769
-- Name: COLUMN sr_match_athletes.team_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_athletes.team_code IS 'Mã đội tuyển sr_match_teams: team_code';


--
-- TOC entry 768 (class 1259 OID 19609)
-- Name: sr_match_athletes_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.sr_match_athletes ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.sr_match_athletes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 771 (class 1259 OID 19635)
-- Name: sr_match_participating_referees; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.sr_match_participating_referees (
    id integer NOT NULL,
    match_code character varying(50) NOT NULL,
    emp_referee_code character varying(50) NOT NULL,
    created_by character varying(50) NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(50) NOT NULL,
    updated_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    position_code character varying(50) NOT NULL
);


ALTER TABLE public.sr_match_participating_referees OWNER TO sportevent;

--
-- TOC entry 6861 (class 0 OID 0)
-- Dependencies: 771
-- Name: COLUMN sr_match_participating_referees.match_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_participating_referees.match_code IS 'Mã trận đấu sr_match_schedules: match_code';


--
-- TOC entry 6862 (class 0 OID 0)
-- Dependencies: 771
-- Name: COLUMN sr_match_participating_referees.emp_referee_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_participating_referees.emp_referee_code IS 'Mã trọng tài ms_employees: employee_code';


--
-- TOC entry 6863 (class 0 OID 0)
-- Dependencies: 771
-- Name: COLUMN sr_match_participating_referees.created_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_participating_referees.created_by IS 'sy_users: user_name';


--
-- TOC entry 6864 (class 0 OID 0)
-- Dependencies: 771
-- Name: COLUMN sr_match_participating_referees.updated_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_participating_referees.updated_by IS 'sy_users: user_name';


--
-- TOC entry 770 (class 1259 OID 19634)
-- Name: sr_match_participating_referees_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.sr_match_participating_referees ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.sr_match_participating_referees_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 779 (class 1259 OID 20683)
-- Name: sr_match_prediction_result; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.sr_match_prediction_result (
    id integer NOT NULL,
    match_code character varying(50) NOT NULL,
    email character varying(255) NOT NULL,
    team_code character varying(50) NOT NULL,
    emp_athlete_code character varying(50),
    prediction_result_rank integer,
    prediction_result_value character varying(150),
    created_by character varying(50) NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(50) NOT NULL,
    updated_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    submit_status character varying(1) DEFAULT 0 CONSTRAINT "sr_match_prediction_result_SubmitStatus_not_null" NOT NULL
);


ALTER TABLE public.sr_match_prediction_result OWNER TO sportevent;

--
-- TOC entry 6865 (class 0 OID 0)
-- Dependencies: 779
-- Name: COLUMN sr_match_prediction_result.match_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_prediction_result.match_code IS 'Mã trận đấu được bình chọn';


--
-- TOC entry 6866 (class 0 OID 0)
-- Dependencies: 779
-- Name: COLUMN sr_match_prediction_result.email; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_prediction_result.email IS 'Email người bình chọn';


--
-- TOC entry 6867 (class 0 OID 0)
-- Dependencies: 779
-- Name: COLUMN sr_match_prediction_result.team_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_prediction_result.team_code IS 'Đội tham gia ms_teams: team_code';


--
-- TOC entry 6868 (class 0 OID 0)
-- Dependencies: 779
-- Name: COLUMN sr_match_prediction_result.emp_athlete_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_prediction_result.emp_athlete_code IS 'VĐV tham gia ms_employees: employee_code';


--
-- TOC entry 6869 (class 0 OID 0)
-- Dependencies: 779
-- Name: COLUMN sr_match_prediction_result.prediction_result_rank; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_prediction_result.prediction_result_rank IS 'Dự đoán theo hạng';


--
-- TOC entry 6870 (class 0 OID 0)
-- Dependencies: 779
-- Name: COLUMN sr_match_prediction_result.prediction_result_value; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_prediction_result.prediction_result_value IS 'Dự đoán theo giá trị';


--
-- TOC entry 6871 (class 0 OID 0)
-- Dependencies: 779
-- Name: COLUMN sr_match_prediction_result.submit_status; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_prediction_result.submit_status IS 'Trạng Thái gửi sy_commons: Type = "PREDICTION_SUBMIT_STATUS"';


--
-- TOC entry 778 (class 1259 OID 20682)
-- Name: sr_match_prediction_result_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.sr_match_prediction_result ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.sr_match_prediction_result_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 826 (class 1259 OID 37395)
-- Name: sr_match_referee_notes; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.sr_match_referee_notes (
    id integer NOT NULL,
    match_id integer CONSTRAINT sr_match_referee_notes_matchid_not_null NOT NULL,
    team_code character varying(50),
    emp_athlete_code character varying(50),
    emp_referee_code character varying(50) CONSTRAINT sr_match_referee_notes_emprefereecode_not_null NOT NULL,
    description character varying(500) NOT NULL,
    created_by character varying(50) CONSTRAINT sr_match_referee_notes_createdby_not_null NOT NULL,
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP CONSTRAINT sr_match_referee_notes_createddate_not_null NOT NULL,
    updated_by character varying(50) CONSTRAINT sr_match_referee_notes_updatedby_not_null NOT NULL,
    updated_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP CONSTRAINT sr_match_referee_notes_updateddate_not_null NOT NULL,
    datarowversion bytea
);


ALTER TABLE public.sr_match_referee_notes OWNER TO sportevent;

--
-- TOC entry 825 (class 1259 OID 37394)
-- Name: sr_match_referee_notes_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

CREATE SEQUENCE public.sr_match_referee_notes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sr_match_referee_notes_id_seq OWNER TO sportevent;

--
-- TOC entry 6872 (class 0 OID 0)
-- Dependencies: 825
-- Name: sr_match_referee_notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sportevent
--

ALTER SEQUENCE public.sr_match_referee_notes_id_seq OWNED BY public.sr_match_referee_notes.id;


--
-- TOC entry 781 (class 1259 OID 21452)
-- Name: sr_match_result; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.sr_match_result (
    id integer NOT NULL,
    competition_code character varying(50) NOT NULL,
    match_code character varying(50) NOT NULL,
    is_match_period boolean,
    ranking_criteria character varying(50),
    result_unit character varying(50),
    description character varying(500),
    created_by character varying(50) NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(50) NOT NULL,
    updated_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    is_finished boolean DEFAULT false NOT NULL
);


ALTER TABLE public.sr_match_result OWNER TO sportevent;

--
-- TOC entry 6873 (class 0 OID 0)
-- Dependencies: 781
-- Name: COLUMN sr_match_result.competition_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_result.competition_code IS 'Sự kiện ms_competition_events: competition_code';


--
-- TOC entry 6874 (class 0 OID 0)
-- Dependencies: 781
-- Name: COLUMN sr_match_result.match_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_result.match_code IS 'Mã trận đấu sr_match_result: match_code';


--
-- TOC entry 6875 (class 0 OID 0)
-- Dependencies: 781
-- Name: COLUMN sr_match_result.is_match_period; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_result.is_match_period IS 'Quản lý hiệp đấu';


--
-- TOC entry 6876 (class 0 OID 0)
-- Dependencies: 781
-- Name: COLUMN sr_match_result.ranking_criteria; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_result.ranking_criteria IS 'Xếp hạng theo tiêu chí';


--
-- TOC entry 6877 (class 0 OID 0)
-- Dependencies: 781
-- Name: COLUMN sr_match_result.result_unit; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_result.result_unit IS 'Đơn vị tính điểm';


--
-- TOC entry 6878 (class 0 OID 0)
-- Dependencies: 781
-- Name: COLUMN sr_match_result.description; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_result.description IS 'Ghi chú';


--
-- TOC entry 6879 (class 0 OID 0)
-- Dependencies: 781
-- Name: COLUMN sr_match_result.is_finished; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_result.is_finished IS 'Trận đấu đã kết thúc chưa';


--
-- TOC entry 783 (class 1259 OID 21517)
-- Name: sr_match_result_detail; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.sr_match_result_detail (
    id integer NOT NULL,
    match_result_id integer NOT NULL,
    team_code character varying(50) NOT NULL,
    emp_athlete_code character varying(50),
    is_final_result boolean DEFAULT false NOT NULL,
    result_rank integer,
    match_round integer,
    result_by_round numeric(25,10),
    result_value character varying(150),
    remark character varying(255),
    created_by character varying(50) NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(50) NOT NULL,
    updated_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    order_by integer
);


ALTER TABLE public.sr_match_result_detail OWNER TO sportevent;

--
-- TOC entry 6880 (class 0 OID 0)
-- Dependencies: 783
-- Name: COLUMN sr_match_result_detail.match_result_id; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_result_detail.match_result_id IS 'ID Header KQ trận đấu sr_match_result: id';


--
-- TOC entry 6881 (class 0 OID 0)
-- Dependencies: 783
-- Name: COLUMN sr_match_result_detail.team_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_result_detail.team_code IS 'Đội tham gia ms_teams: team_code';


--
-- TOC entry 6882 (class 0 OID 0)
-- Dependencies: 783
-- Name: COLUMN sr_match_result_detail.emp_athlete_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_result_detail.emp_athlete_code IS 'VĐV tham gia ms_employees: employee_code';


--
-- TOC entry 6883 (class 0 OID 0)
-- Dependencies: 783
-- Name: COLUMN sr_match_result_detail.is_final_result; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_result_detail.is_final_result IS 'Kết quả cuối cùng';


--
-- TOC entry 6884 (class 0 OID 0)
-- Dependencies: 783
-- Name: COLUMN sr_match_result_detail.result_rank; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_result_detail.result_rank IS 'Kết quả theo hạng';


--
-- TOC entry 6885 (class 0 OID 0)
-- Dependencies: 783
-- Name: COLUMN sr_match_result_detail.match_round; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_result_detail.match_round IS 'Hiệp đấu';


--
-- TOC entry 6886 (class 0 OID 0)
-- Dependencies: 783
-- Name: COLUMN sr_match_result_detail.result_by_round; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_result_detail.result_by_round IS 'Kết quả theo hiệp';


--
-- TOC entry 6887 (class 0 OID 0)
-- Dependencies: 783
-- Name: COLUMN sr_match_result_detail.result_value; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_result_detail.result_value IS 'Kết quả theo giá trị';


--
-- TOC entry 782 (class 1259 OID 21516)
-- Name: sr_match_result_detail_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.sr_match_result_detail ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.sr_match_result_detail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 780 (class 1259 OID 21451)
-- Name: sr_match_result_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.sr_match_result ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.sr_match_result_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 753 (class 1259 OID 19178)
-- Name: sr_match_schedules; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.sr_match_schedules (
    id integer NOT NULL,
    match_code character varying(50) NOT NULL,
    competition_code character varying(50) NOT NULL,
    sport_code character varying(50) NOT NULL,
    sport_event_code character varying(50) NOT NULL,
    location_code character varying(50) NOT NULL,
    match_type character varying(50) NOT NULL,
    match_name_vi character varying(255) NOT NULL,
    match_name_en character varying(255) NOT NULL,
    match_start_date date NOT NULL,
    match_end_date date NOT NULL,
    match_start_time time(6) without time zone NOT NULL,
    match_end_time time(6) without time zone NOT NULL,
    match_round character varying(255) NOT NULL,
    link_online character varying(255),
    description character varying(500),
    created_by character varying(50) NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(50) NOT NULL,
    updated_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data_row_version bigint DEFAULT 1 NOT NULL,
    status character varying(50),
    is_vote boolean,
    slugs character varying(250)
);


ALTER TABLE public.sr_match_schedules OWNER TO sportevent;

--
-- TOC entry 6888 (class 0 OID 0)
-- Dependencies: 753
-- Name: COLUMN sr_match_schedules.match_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_schedules.match_code IS 'Mã trận đấu';


--
-- TOC entry 6889 (class 0 OID 0)
-- Dependencies: 753
-- Name: COLUMN sr_match_schedules.competition_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_schedules.competition_code IS 'Sự kiện ms_competition_events: competition_code';


--
-- TOC entry 6890 (class 0 OID 0)
-- Dependencies: 753
-- Name: COLUMN sr_match_schedules.sport_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_schedules.sport_code IS 'Môn thể thao ms_sports: sport_code';


--
-- TOC entry 6891 (class 0 OID 0)
-- Dependencies: 753
-- Name: COLUMN sr_match_schedules.sport_event_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_schedules.sport_event_code IS 'Nội dung thi đấu ms_sport_detail: sport_event_code';


--
-- TOC entry 6892 (class 0 OID 0)
-- Dependencies: 753
-- Name: COLUMN sr_match_schedules.location_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_schedules.location_code IS 'Địa điểm thi đấu ms_locations: location_code';


--
-- TOC entry 6893 (class 0 OID 0)
-- Dependencies: 753
-- Name: COLUMN sr_match_schedules.match_type; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_schedules.match_type IS 'Thể thức thi đấu sy_commons: Type = "MATCH_TYPE"';


--
-- TOC entry 6894 (class 0 OID 0)
-- Dependencies: 753
-- Name: COLUMN sr_match_schedules.match_name_vi; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_schedules.match_name_vi IS 'Tên trận đấu VN';


--
-- TOC entry 6895 (class 0 OID 0)
-- Dependencies: 753
-- Name: COLUMN sr_match_schedules.match_name_en; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_schedules.match_name_en IS 'Tên trận đấu EN';


--
-- TOC entry 6896 (class 0 OID 0)
-- Dependencies: 753
-- Name: COLUMN sr_match_schedules.match_start_date; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_schedules.match_start_date IS 'Ngày bắt đầu';


--
-- TOC entry 6897 (class 0 OID 0)
-- Dependencies: 753
-- Name: COLUMN sr_match_schedules.match_end_date; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_schedules.match_end_date IS 'Ngày kết thúc';


--
-- TOC entry 6898 (class 0 OID 0)
-- Dependencies: 753
-- Name: COLUMN sr_match_schedules.match_start_time; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_schedules.match_start_time IS 'Giờ bắt đầu';


--
-- TOC entry 6899 (class 0 OID 0)
-- Dependencies: 753
-- Name: COLUMN sr_match_schedules.match_end_time; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_schedules.match_end_time IS 'Giờ kết thúc';


--
-- TOC entry 6900 (class 0 OID 0)
-- Dependencies: 753
-- Name: COLUMN sr_match_schedules.match_round; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_schedules.match_round IS 'Vòng loại sy_commons: Type = "MATCH_ROUND"';


--
-- TOC entry 6901 (class 0 OID 0)
-- Dependencies: 753
-- Name: COLUMN sr_match_schedules.link_online; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_schedules.link_online IS 'Link trực tuyến';


--
-- TOC entry 6902 (class 0 OID 0)
-- Dependencies: 753
-- Name: COLUMN sr_match_schedules.description; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_schedules.description IS 'Ghi chú';


--
-- TOC entry 6903 (class 0 OID 0)
-- Dependencies: 753
-- Name: COLUMN sr_match_schedules.created_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_schedules.created_by IS 'sy_users: user_name';


--
-- TOC entry 6904 (class 0 OID 0)
-- Dependencies: 753
-- Name: COLUMN sr_match_schedules.updated_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_schedules.updated_by IS 'sy_users: user_name';


--
-- TOC entry 6905 (class 0 OID 0)
-- Dependencies: 753
-- Name: COLUMN sr_match_schedules.status; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_schedules.status IS 'Thể thức thi đấu sy_commons: Type = "MATCH_STATUS"';


--
-- TOC entry 6906 (class 0 OID 0)
-- Dependencies: 753
-- Name: COLUMN sr_match_schedules.slugs; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_schedules.slugs IS 'slug cho web';


--
-- TOC entry 752 (class 1259 OID 19177)
-- Name: sr_match_schedules_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.sr_match_schedules ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.sr_match_schedules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 767 (class 1259 OID 19585)
-- Name: sr_match_teams; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.sr_match_teams (
    id integer NOT NULL,
    match_code character varying(50) NOT NULL,
    team_code character varying(50) NOT NULL,
    created_by character varying(50) NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(50) NOT NULL,
    updated_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.sr_match_teams OWNER TO sportevent;

--
-- TOC entry 6907 (class 0 OID 0)
-- Dependencies: 767
-- Name: COLUMN sr_match_teams.match_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_teams.match_code IS 'Mã trận đấu sr_match_schedules: match_code';


--
-- TOC entry 6908 (class 0 OID 0)
-- Dependencies: 767
-- Name: COLUMN sr_match_teams.team_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_teams.team_code IS 'Mã đội tuyển ms_teams: team_code';


--
-- TOC entry 6909 (class 0 OID 0)
-- Dependencies: 767
-- Name: COLUMN sr_match_teams.created_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_teams.created_by IS 'sy_users: user_name';


--
-- TOC entry 6910 (class 0 OID 0)
-- Dependencies: 767
-- Name: COLUMN sr_match_teams.updated_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_teams.updated_by IS 'sy_users: user_name';


--
-- TOC entry 766 (class 1259 OID 19584)
-- Name: sr_match_teams_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.sr_match_teams ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.sr_match_teams_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 773 (class 1259 OID 19655)
-- Name: sr_match_volunteer; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.sr_match_volunteer (
    id integer NOT NULL,
    match_code character varying(50) NOT NULL,
    emp_volunteer_code character varying(50) NOT NULL,
    created_by character varying(50) NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(50) NOT NULL,
    updated_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.sr_match_volunteer OWNER TO sportevent;

--
-- TOC entry 6911 (class 0 OID 0)
-- Dependencies: 773
-- Name: COLUMN sr_match_volunteer.match_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_volunteer.match_code IS 'Mã trận đấu sr_match_schedules: match_code';


--
-- TOC entry 6912 (class 0 OID 0)
-- Dependencies: 773
-- Name: COLUMN sr_match_volunteer.emp_volunteer_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_volunteer.emp_volunteer_code IS 'Mã tình nguyện viên ms_employees: employee_code';


--
-- TOC entry 6913 (class 0 OID 0)
-- Dependencies: 773
-- Name: COLUMN sr_match_volunteer.created_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_volunteer.created_by IS 'sy_users: user_name';


--
-- TOC entry 6914 (class 0 OID 0)
-- Dependencies: 773
-- Name: COLUMN sr_match_volunteer.updated_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sr_match_volunteer.updated_by IS 'sy_users: user_name';


--
-- TOC entry 772 (class 1259 OID 19654)
-- Name: sr_match_volunteer_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.sr_match_volunteer ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.sr_match_volunteer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 675 (class 1259 OID 16391)
-- Name: sy_commons; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.sy_commons (
    id integer NOT NULL,
    type character varying(50) NOT NULL,
    field_name character varying(50) CONSTRAINT sy_commons_fieldname_not_null NOT NULL,
    value character varying(20) NOT NULL,
    name_vi character varying(150) CONSTRAINT sy_commons_namevi_not_null NOT NULL,
    name_en character varying(150) CONSTRAINT sy_commons_nameen_not_null NOT NULL,
    name_ja character varying(150) CONSTRAINT sy_commons_nameja_not_null NOT NULL,
    description character varying(250) NOT NULL,
    sort integer,
    status character varying(2) DEFAULT '1'::character varying,
    data_row_version bigint DEFAULT 1
);


ALTER TABLE public.sy_commons OWNER TO sportevent;

--
-- TOC entry 6915 (class 0 OID 0)
-- Dependencies: 675
-- Name: COLUMN sy_commons.type; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_commons.type IS 'Loại data';


--
-- TOC entry 6916 (class 0 OID 0)
-- Dependencies: 675
-- Name: COLUMN sy_commons.field_name; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_commons.field_name IS 'Field name: mục đích cho gen common ra file code .cs';


--
-- TOC entry 6917 (class 0 OID 0)
-- Dependencies: 675
-- Name: COLUMN sy_commons.value; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_commons.value IS 'Giá trị';


--
-- TOC entry 6918 (class 0 OID 0)
-- Dependencies: 675
-- Name: COLUMN sy_commons.name_vi; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_commons.name_vi IS 'Tên hiển thị VN';


--
-- TOC entry 6919 (class 0 OID 0)
-- Dependencies: 675
-- Name: COLUMN sy_commons.name_en; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_commons.name_en IS 'Tên hiển thị EN';


--
-- TOC entry 6920 (class 0 OID 0)
-- Dependencies: 675
-- Name: COLUMN sy_commons.name_ja; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_commons.name_ja IS 'Tên hiển thị JP';


--
-- TOC entry 6921 (class 0 OID 0)
-- Dependencies: 675
-- Name: COLUMN sy_commons.description; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_commons.description IS 'Mô tả loại dữ liệu';


--
-- TOC entry 6922 (class 0 OID 0)
-- Dependencies: 675
-- Name: COLUMN sy_commons.sort; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_commons.sort IS 'Trường hợp muốn sort lại dữ liệu khi select thì thêm vào';


--
-- TOC entry 6923 (class 0 OID 0)
-- Dependencies: 675
-- Name: COLUMN sy_commons.status; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_commons.status IS '0: Inactive, 1: Active =>Khi lấy dữ liệu chỉ lấy những theo Status=1';


--
-- TOC entry 674 (class 1259 OID 16390)
-- Name: sy_commons_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.sy_commons ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.sy_commons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 677 (class 1259 OID 16411)
-- Name: sy_document_formatter_current; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.sy_document_formatter_current (
    id bigint NOT NULL,
    transaction_type character varying(50) CONSTRAINT sy_document_formatter_current_transactiontype_not_null NOT NULL,
    format_code character varying(100) CONSTRAINT sy_document_formatter_current_formatcode_not_null NOT NULL,
    next_number character varying(10) CONSTRAINT sy_document_formatter_current_nextnumber_not_null NOT NULL,
    current_document_code character varying(100) CONSTRAINT sy_document_formatter_current_currentdocumentcode_not_null NOT NULL,
    created_by character varying(50) CONSTRAINT sy_document_formatter_current_createdby_not_null NOT NULL,
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(50) CONSTRAINT sy_document_formatter_current_updatedby_not_null NOT NULL,
    updated_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    data_row_version bigint DEFAULT 1 CONSTRAINT sy_document_formatter_current_datarowversion_not_null NOT NULL
);


ALTER TABLE public.sy_document_formatter_current OWNER TO sportevent;

--
-- TOC entry 676 (class 1259 OID 16410)
-- Name: sy_document_formatter_current_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.sy_document_formatter_current ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.sy_document_formatter_current_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 679 (class 1259 OID 16429)
-- Name: sy_document_settings; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.sy_document_settings (
    id integer NOT NULL,
    transaction_type character varying(50) CONSTRAINT sy_document_settings_transactiontype_not_null NOT NULL,
    is_auto_increment boolean DEFAULT false,
    prefix character varying(50),
    date character varying(50),
    number_digits integer,
    start_at integer,
    is_reset_by_day boolean DEFAULT false,
    is_reset_by_month boolean DEFAULT true,
    is_reset_by_year boolean DEFAULT false,
    is_transaction boolean DEFAULT true,
    remark character varying(255),
    created_by character varying(50) CONSTRAINT sy_document_settings_createdby_not_null NOT NULL,
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(50) CONSTRAINT sy_document_settings_updatedby_not_null NOT NULL,
    updated_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    data_row_version bigint DEFAULT 1 CONSTRAINT sy_document_settings_datarowversion_not_null NOT NULL
);


ALTER TABLE public.sy_document_settings OWNER TO sportevent;

--
-- TOC entry 6924 (class 0 OID 0)
-- Dependencies: 679
-- Name: COLUMN sy_document_settings.transaction_type; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_document_settings.transaction_type IS 'Loại giao dịch ms_transaction_types: Value';


--
-- TOC entry 6925 (class 0 OID 0)
-- Dependencies: 679
-- Name: COLUMN sy_document_settings.is_auto_increment; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_document_settings.is_auto_increment IS 'Mã tăng tự động';


--
-- TOC entry 6926 (class 0 OID 0)
-- Dependencies: 679
-- Name: COLUMN sy_document_settings.prefix; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_document_settings.prefix IS 'Tiền tố của mã tự tăng';


--
-- TOC entry 6927 (class 0 OID 0)
-- Dependencies: 679
-- Name: COLUMN sy_document_settings.date; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_document_settings.date IS 'Thêm ngày chứng từ vào tiền tố (format: yyyymm)';


--
-- TOC entry 6928 (class 0 OID 0)
-- Dependencies: 679
-- Name: COLUMN sy_document_settings.number_digits; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_document_settings.number_digits IS 'Số chữ số của số tự tăng';


--
-- TOC entry 6929 (class 0 OID 0)
-- Dependencies: 679
-- Name: COLUMN sy_document_settings.start_at; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_document_settings.start_at IS 'Bắt đầu từ';


--
-- TOC entry 6930 (class 0 OID 0)
-- Dependencies: 679
-- Name: COLUMN sy_document_settings.is_reset_by_day; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_document_settings.is_reset_by_day IS 'Thiếp lập reset số tự tăng theo ngày';


--
-- TOC entry 6931 (class 0 OID 0)
-- Dependencies: 679
-- Name: COLUMN sy_document_settings.is_reset_by_month; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_document_settings.is_reset_by_month IS 'Thiếp lập reset số tự tăng theo tháng';


--
-- TOC entry 6932 (class 0 OID 0)
-- Dependencies: 679
-- Name: COLUMN sy_document_settings.is_reset_by_year; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_document_settings.is_reset_by_year IS 'Thiếp lập reset số tự tăng theo năm';


--
-- TOC entry 6933 (class 0 OID 0)
-- Dependencies: 679
-- Name: COLUMN sy_document_settings.is_transaction; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_document_settings.is_transaction IS 'true: là transaction type cho các chứng từ; false: thiết lập khác';


--
-- TOC entry 6934 (class 0 OID 0)
-- Dependencies: 679
-- Name: COLUMN sy_document_settings.remark; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_document_settings.remark IS 'Mô tả';


--
-- TOC entry 678 (class 1259 OID 16428)
-- Name: sy_document_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.sy_document_settings ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.sy_document_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 791 (class 1259 OID 22088)
-- Name: sy_file_attachments; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.sy_file_attachments (
    id bigint NOT NULL,
    category_file character varying(100) NOT NULL,
    file_group character varying(250) NOT NULL,
    file_key character varying(250) NOT NULL,
    file_name character varying(250) NOT NULL,
    file_size bigint NOT NULL,
    file_relative_path character varying(1000) CONSTRAINT sy_file_attachments_file_path_not_null NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    origin_file_name character varying(250) NOT NULL
);


ALTER TABLE public.sy_file_attachments OWNER TO sportevent;

--
-- TOC entry 6935 (class 0 OID 0)
-- Dependencies: 791
-- Name: TABLE sy_file_attachments; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON TABLE public.sy_file_attachments IS 'Bảng quản lý tập tin đính kèm của hệ thống';


--
-- TOC entry 6936 (class 0 OID 0)
-- Dependencies: 791
-- Name: COLUMN sy_file_attachments.category_file; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_file_attachments.category_file IS 'Phân loại theo tên chức năng (VD: ConstructionProfile, Contract, DesignDrawing...)';


--
-- TOC entry 6937 (class 0 OID 0)
-- Dependencies: 791
-- Name: COLUMN sy_file_attachments.file_group; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_file_attachments.file_group IS 'Nhóm tập tin (thường dùng để nhóm các file thuộc cùng một đối tượng như Id khách hàng hoặc mã công trình)';


--
-- TOC entry 6938 (class 0 OID 0)
-- Dependencies: 791
-- Name: COLUMN sy_file_attachments.file_key; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_file_attachments.file_key IS 'Khóa duy nhất định danh file trên Cloud Storage hoặc hệ thống lưu trữ vật lý';


--
-- TOC entry 6939 (class 0 OID 0)
-- Dependencies: 791
-- Name: COLUMN sy_file_attachments.file_name; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_file_attachments.file_name IS 'Tên hiển thị của tập tin';


--
-- TOC entry 6940 (class 0 OID 0)
-- Dependencies: 791
-- Name: COLUMN sy_file_attachments.file_size; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_file_attachments.file_size IS 'Dung lượng tập tin tính bằng Byte';


--
-- TOC entry 6941 (class 0 OID 0)
-- Dependencies: 791
-- Name: COLUMN sy_file_attachments.file_relative_path; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_file_attachments.file_relative_path IS 'Đường dẫn tương đối (Combie với tham số SystemConfig -> FolderFileDocumentPath)';


--
-- TOC entry 6942 (class 0 OID 0)
-- Dependencies: 791
-- Name: COLUMN sy_file_attachments.is_deleted; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_file_attachments.is_deleted IS 'Cờ đánh dấu xóa logic (True: đã xóa, False: đang sử dụng)';


--
-- TOC entry 790 (class 1259 OID 22087)
-- Name: sy_file_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.sy_file_attachments ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.sy_file_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 681 (class 1259 OID 16451)
-- Name: sy_function_actions; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.sy_function_actions (
    id integer NOT NULL,
    code character varying(50) NOT NULL,
    resourcecontrolname character varying(100) NOT NULL,
    description character varying(500) NOT NULL,
    sortorder integer NOT NULL,
    issavehistory boolean
);


ALTER TABLE public.sy_function_actions OWNER TO sportevent;

--
-- TOC entry 6943 (class 0 OID 0)
-- Dependencies: 681
-- Name: COLUMN sy_function_actions.code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_function_actions.code IS 'Mã hành động';


--
-- TOC entry 6944 (class 0 OID 0)
-- Dependencies: 681
-- Name: COLUMN sy_function_actions.resourcecontrolname; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_function_actions.resourcecontrolname IS 'Tên hiển thị, lấy từ resource ra';


--
-- TOC entry 6945 (class 0 OID 0)
-- Dependencies: 681
-- Name: COLUMN sy_function_actions.description; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_function_actions.description IS 'Mô tả';


--
-- TOC entry 6946 (class 0 OID 0)
-- Dependencies: 681
-- Name: COLUMN sy_function_actions.sortorder; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_function_actions.sortorder IS 'Sắp xếp thứ tự khi hiển thị ở chức năng phân quyền';


--
-- TOC entry 680 (class 1259 OID 16450)
-- Name: sy_function_actions_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.sy_function_actions ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.sy_function_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 683 (class 1259 OID 16464)
-- Name: sy_functions; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.sy_functions (
    id integer NOT NULL,
    code character varying(50) NOT NULL,
    resourcecontrolname character varying(100) NOT NULL,
    description character varying(150) NOT NULL,
    actions character varying(250),
    icon character varying(50),
    issyncfromothersystem boolean DEFAULT false,
    syncactions character varying(250)
);


ALTER TABLE public.sy_functions OWNER TO sportevent;

--
-- TOC entry 6947 (class 0 OID 0)
-- Dependencies: 683
-- Name: COLUMN sy_functions.code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_functions.code IS 'Mã chức năng';


--
-- TOC entry 6948 (class 0 OID 0)
-- Dependencies: 683
-- Name: COLUMN sy_functions.resourcecontrolname; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_functions.resourcecontrolname IS 'Tên hiển thị, lấy từ resource ra';


--
-- TOC entry 6949 (class 0 OID 0)
-- Dependencies: 683
-- Name: COLUMN sy_functions.description; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_functions.description IS 'Mô tả';


--
-- TOC entry 6950 (class 0 OID 0)
-- Dependencies: 683
-- Name: COLUMN sy_functions.actions; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_functions.actions IS 'Hành động của 1 màn hình: Vd: Search,View,Add,Edit,Delete...';


--
-- TOC entry 6951 (class 0 OID 0)
-- Dependencies: 683
-- Name: COLUMN sy_functions.issyncfromothersystem; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_functions.issyncfromothersystem IS 'true: bật chức năng đồng bộ dữ liệu từ hệ thống khác, false: tắt chức năng đồng bộ';


--
-- TOC entry 6952 (class 0 OID 0)
-- Dependencies: 683
-- Name: COLUMN sy_functions.syncactions; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_functions.syncactions IS 'Hành động của 1 màn hình: Vd: Search,View,Add,Edit,Delete... (áp khi IsSyncFromOtherSystem = true)';


--
-- TOC entry 682 (class 1259 OID 16463)
-- Name: sy_functions_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.sy_functions ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.sy_functions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 831 (class 1259 OID 46222)
-- Name: sy_journals; Type: FOREIGN TABLE; Schema: public; Owner: sportevent
--

CREATE FOREIGN TABLE public.sy_journals (
    module_code character varying(50) NOT NULL,
    function_code character varying(50) NOT NULL,
    action_code character varying(20) NOT NULL,
    user_name character varying(50) NOT NULL,
    action_date timestamp(6) without time zone,
    data_id bigint,
    json_before jsonb,
    json_after jsonb,
    ip_address character varying(32)
)
SERVER log_server
OPTIONS (
    schema_name 'public',
    table_name 'sy_journals'
);
ALTER FOREIGN TABLE ONLY public.sy_journals ALTER COLUMN module_code OPTIONS (
    column_name 'module_code'
);
ALTER FOREIGN TABLE ONLY public.sy_journals ALTER COLUMN function_code OPTIONS (
    column_name 'function_code'
);
ALTER FOREIGN TABLE ONLY public.sy_journals ALTER COLUMN action_code OPTIONS (
    column_name 'action_code'
);
ALTER FOREIGN TABLE ONLY public.sy_journals ALTER COLUMN user_name OPTIONS (
    column_name 'user_name'
);
ALTER FOREIGN TABLE ONLY public.sy_journals ALTER COLUMN action_date OPTIONS (
    column_name 'action_date'
);
ALTER FOREIGN TABLE ONLY public.sy_journals ALTER COLUMN data_id OPTIONS (
    column_name 'data_id'
);
ALTER FOREIGN TABLE ONLY public.sy_journals ALTER COLUMN json_before OPTIONS (
    column_name 'json_before'
);
ALTER FOREIGN TABLE ONLY public.sy_journals ALTER COLUMN json_after OPTIONS (
    column_name 'json_after'
);
ALTER FOREIGN TABLE ONLY public.sy_journals ALTER COLUMN ip_address OPTIONS (
    column_name 'ip_address'
);


ALTER FOREIGN TABLE public.sy_journals OWNER TO sportevent;

--
-- TOC entry 801 (class 1259 OID 22601)
-- Name: sy_mail_queues; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.sy_mail_queues (
    id integer NOT NULL,
    mail_to jsonb DEFAULT '[]'::jsonb NOT NULL,
    mail_cc jsonb DEFAULT '[]'::jsonb,
    mail_bcc jsonb DEFAULT '[]'::jsonb,
    mail_template_code character varying(50) NOT NULL,
    mail_parameters jsonb,
    screen_code character varying(50) NOT NULL,
    status character varying(1) DEFAULT '0'::character varying NOT NULL,
    retry_time integer DEFAULT 0 NOT NULL,
    created_by character varying(50) NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(50) NOT NULL,
    updated_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    ref_id integer
);


ALTER TABLE public.sy_mail_queues OWNER TO sportevent;

--
-- TOC entry 6953 (class 0 OID 0)
-- Dependencies: 801
-- Name: TABLE sy_mail_queues; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON TABLE public.sy_mail_queues IS 'Hàng đợi gửi mail';


--
-- TOC entry 6954 (class 0 OID 0)
-- Dependencies: 801
-- Name: COLUMN sy_mail_queues.id; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_mail_queues.id IS 'Khóa chính tự tăng';


--
-- TOC entry 6955 (class 0 OID 0)
-- Dependencies: 801
-- Name: COLUMN sy_mail_queues.mail_to; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_mail_queues.mail_to IS 'Danh sách mail TO, dạng JSON ["email1","email2"]';


--
-- TOC entry 6956 (class 0 OID 0)
-- Dependencies: 801
-- Name: COLUMN sy_mail_queues.mail_cc; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_mail_queues.mail_cc IS 'Danh sách mail CC, dạng JSON ["email1","email2"]';


--
-- TOC entry 6957 (class 0 OID 0)
-- Dependencies: 801
-- Name: COLUMN sy_mail_queues.mail_bcc; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_mail_queues.mail_bcc IS 'Danh sách mail BCC, dạng JSON ["email1","email2"]';


--
-- TOC entry 6958 (class 0 OID 0)
-- Dependencies: 801
-- Name: COLUMN sy_mail_queues.mail_template_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_mail_queues.mail_template_code IS 'Mã template mail, FK tới sy_mailtemplate.code';


--
-- TOC entry 6959 (class 0 OID 0)
-- Dependencies: 801
-- Name: COLUMN sy_mail_queues.mail_parameters; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_mail_queues.mail_parameters IS 'Dữ liệu truyền vào template (JSON object)';


--
-- TOC entry 6960 (class 0 OID 0)
-- Dependencies: 801
-- Name: COLUMN sy_mail_queues.screen_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_mail_queues.screen_code IS 'Mã màn hình gọi';


--
-- TOC entry 6961 (class 0 OID 0)
-- Dependencies: 801
-- Name: COLUMN sy_mail_queues.status; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_mail_queues.status IS 'Trạng thái (0: Init, 1: Sent, 2: Fail,...)';


--
-- TOC entry 6962 (class 0 OID 0)
-- Dependencies: 801
-- Name: COLUMN sy_mail_queues.retry_time; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_mail_queues.retry_time IS 'Số lần retry gửi mail';


--
-- TOC entry 6963 (class 0 OID 0)
-- Dependencies: 801
-- Name: COLUMN sy_mail_queues.ref_id; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_mail_queues.ref_id IS 'ref id đến data của bảng khác nếu có';


--
-- TOC entry 800 (class 1259 OID 22600)
-- Name: sy_mail_queues_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.sy_mail_queues ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.sy_mail_queues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 685 (class 1259 OID 16477)
-- Name: sy_mailtemplate; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.sy_mailtemplate (
    id integer NOT NULL,
    code character varying(50) CONSTRAINT sy_mailtemplate_type_not_null NOT NULL,
    subject character varying(200),
    body text,
    remark character varying(250),
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by character varying(50),
    updated_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(50),
    data_row_version bigint DEFAULT 1 CONSTRAINT sy_mailtemplate_datarowversion_not_null NOT NULL
);


ALTER TABLE public.sy_mailtemplate OWNER TO sportevent;

--
-- TOC entry 684 (class 1259 OID 16476)
-- Name: sy_mailtemplate_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.sy_mailtemplate ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.sy_mailtemplate_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 687 (class 1259 OID 16490)
-- Name: sy_menu; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.sy_menu (
    id integer NOT NULL,
    code character varying(50) NOT NULL,
    resourcecontrolname character varying(100),
    description character varying(150) NOT NULL,
    parentcode character varying(50),
    screencode character varying(50),
    menulevel smallint DEFAULT 1,
    url character varying(150),
    modulecode character varying(50),
    statuscode character varying(20) DEFAULT '1'::character varying,
    sortorder smallint DEFAULT 1,
    isshow integer DEFAULT 0,
    icon character varying(50),
    createddate timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    menutype character varying(20) DEFAULT 'System'::character varying
);


ALTER TABLE public.sy_menu OWNER TO sportevent;

--
-- TOC entry 6964 (class 0 OID 0)
-- Dependencies: 687
-- Name: COLUMN sy_menu.menutype; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_menu.menutype IS 'Menu loại Mobile hay BTC: sy_commons: Type = "RoleType"';


--
-- TOC entry 686 (class 1259 OID 16489)
-- Name: sy_menu_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.sy_menu ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.sy_menu_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 689 (class 1259 OID 16506)
-- Name: sy_modules; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.sy_modules (
    id smallint NOT NULL,
    code character varying(50) NOT NULL,
    resourcecontrolname character varying(100) NOT NULL,
    description character varying(500)
);


ALTER TABLE public.sy_modules OWNER TO sportevent;

--
-- TOC entry 6965 (class 0 OID 0)
-- Dependencies: 689
-- Name: COLUMN sy_modules.code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_modules.code IS 'Mã phân hệ';


--
-- TOC entry 6966 (class 0 OID 0)
-- Dependencies: 689
-- Name: COLUMN sy_modules.resourcecontrolname; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_modules.resourcecontrolname IS 'Tên hiển thị, lấy từ resource ra';


--
-- TOC entry 6967 (class 0 OID 0)
-- Dependencies: 689
-- Name: COLUMN sy_modules.description; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_modules.description IS 'Mô tả';


--
-- TOC entry 688 (class 1259 OID 16505)
-- Name: sy_modules_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.sy_modules ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.sy_modules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 824 (class 1259 OID 37315)
-- Name: sy_notification; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.sy_notification (
    id integer NOT NULL,
    user_name character varying(50) CONSTRAINT sy_notification_username_not_null NOT NULL,
    title_vi text NOT NULL,
    title_en text NOT NULL,
    message_vi text NOT NULL,
    message_en text NOT NULL,
    is_read boolean DEFAULT false NOT NULL,
    created_by character varying(50) NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(50) NOT NULL,
    updated_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.sy_notification OWNER TO sportevent;

--
-- TOC entry 6968 (class 0 OID 0)
-- Dependencies: 824
-- Name: TABLE sy_notification; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON TABLE public.sy_notification IS 'Bảng lưu trữ thông báo nội bộ gửi cho người dùng';


--
-- TOC entry 6969 (class 0 OID 0)
-- Dependencies: 824
-- Name: COLUMN sy_notification.id; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_notification.id IS 'Khóa chính tự tăng (Identity)';


--
-- TOC entry 6970 (class 0 OID 0)
-- Dependencies: 824
-- Name: COLUMN sy_notification.user_name; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_notification.user_name IS 'Người nhận thông báo - sy_users: username';


--
-- TOC entry 6971 (class 0 OID 0)
-- Dependencies: 824
-- Name: COLUMN sy_notification.title_vi; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_notification.title_vi IS 'Tiêu đề thông báo bằng tiếng Việt';


--
-- TOC entry 6972 (class 0 OID 0)
-- Dependencies: 824
-- Name: COLUMN sy_notification.title_en; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_notification.title_en IS 'Tiêu đề thông báo bằng tiếng Anh';


--
-- TOC entry 6973 (class 0 OID 0)
-- Dependencies: 824
-- Name: COLUMN sy_notification.message_vi; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_notification.message_vi IS 'Nội dung chi tiết thông báo bằng tiếng Việt (Hỗ trợ văn bản dài)';


--
-- TOC entry 6974 (class 0 OID 0)
-- Dependencies: 824
-- Name: COLUMN sy_notification.message_en; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_notification.message_en IS 'Nội dung chi tiết thông báo bằng tiếng Anh (Hỗ trợ văn bản dài)';


--
-- TOC entry 6975 (class 0 OID 0)
-- Dependencies: 824
-- Name: COLUMN sy_notification.is_read; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_notification.is_read IS 'Trạng thái đã đọc (True: Đã đọc, False: Chưa đọc)';


--
-- TOC entry 6976 (class 0 OID 0)
-- Dependencies: 824
-- Name: COLUMN sy_notification.created_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_notification.created_by IS 'Người tạo thông báo (User hoặc System)';


--
-- TOC entry 6977 (class 0 OID 0)
-- Dependencies: 824
-- Name: COLUMN sy_notification.created_date; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_notification.created_date IS 'Thời điểm khởi tạo thông báo';


--
-- TOC entry 6978 (class 0 OID 0)
-- Dependencies: 824
-- Name: COLUMN sy_notification.updated_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_notification.updated_by IS 'Người thực hiện cập nhật cuối cùng (sy_users: username)';


--
-- TOC entry 6979 (class 0 OID 0)
-- Dependencies: 824
-- Name: COLUMN sy_notification.updated_date; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_notification.updated_date IS 'Thời điểm cập nhật thông báo cuối cùng';


--
-- TOC entry 823 (class 1259 OID 37314)
-- Name: sy_notification_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.sy_notification ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.sy_notification_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 741 (class 1259 OID 18995)
-- Name: sy_notification_settings; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.sy_notification_settings (
    id integer NOT NULL,
    employee_type character varying(50) NOT NULL,
    screen_code character varying(50) NOT NULL,
    is_insert boolean DEFAULT false,
    is_update boolean DEFAULT false,
    is_delete boolean DEFAULT false,
    created_by character varying(50) NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(50) NOT NULL,
    updated_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data_row_version bigint DEFAULT 1 NOT NULL
);


ALTER TABLE public.sy_notification_settings OWNER TO sportevent;

--
-- TOC entry 6980 (class 0 OID 0)
-- Dependencies: 741
-- Name: COLUMN sy_notification_settings.employee_type; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_notification_settings.employee_type IS 'Loại thành viên sy_commons: Type = "EMPLOYEE_TYPE"';


--
-- TOC entry 6981 (class 0 OID 0)
-- Dependencies: 741
-- Name: COLUMN sy_notification_settings.screen_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_notification_settings.screen_code IS 'Mã màn hình sy_menu: screen_code';


--
-- TOC entry 6982 (class 0 OID 0)
-- Dependencies: 741
-- Name: COLUMN sy_notification_settings.is_insert; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_notification_settings.is_insert IS 'Cho phép thông báo khi Thêm';


--
-- TOC entry 6983 (class 0 OID 0)
-- Dependencies: 741
-- Name: COLUMN sy_notification_settings.is_update; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_notification_settings.is_update IS 'Cho phép thông báo khi Sửa';


--
-- TOC entry 6984 (class 0 OID 0)
-- Dependencies: 741
-- Name: COLUMN sy_notification_settings.is_delete; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_notification_settings.is_delete IS 'Cho phép thông báo khi Xóa';


--
-- TOC entry 6985 (class 0 OID 0)
-- Dependencies: 741
-- Name: COLUMN sy_notification_settings.created_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_notification_settings.created_by IS 'sy_users: user_name';


--
-- TOC entry 6986 (class 0 OID 0)
-- Dependencies: 741
-- Name: COLUMN sy_notification_settings.updated_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_notification_settings.updated_by IS 'sy_users: user_name';


--
-- TOC entry 740 (class 1259 OID 18994)
-- Name: sy_notification_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.sy_notification_settings ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.sy_notification_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 691 (class 1259 OID 16517)
-- Name: sy_parameters; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.sy_parameters (
    id integer NOT NULL,
    type character varying(50) NOT NULL,
    name character varying(50) NOT NULL,
    value character varying(250),
    description character varying(500) NOT NULL,
    createdby character varying(50) NOT NULL,
    createddate timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updatedby character varying(50) NOT NULL,
    updateddate timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    datarowversion bigint DEFAULT 1 NOT NULL,
    isencrypt boolean DEFAULT false
);


ALTER TABLE public.sy_parameters OWNER TO sportevent;

--
-- TOC entry 6987 (class 0 OID 0)
-- Dependencies: 691
-- Name: COLUMN sy_parameters.type; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_parameters.type IS 'Mã nhóm thiết lập';


--
-- TOC entry 6988 (class 0 OID 0)
-- Dependencies: 691
-- Name: COLUMN sy_parameters.name; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_parameters.name IS 'Cột cần thiết lập';


--
-- TOC entry 6989 (class 0 OID 0)
-- Dependencies: 691
-- Name: COLUMN sy_parameters.value; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_parameters.value IS 'Giá trị';


--
-- TOC entry 6990 (class 0 OID 0)
-- Dependencies: 691
-- Name: COLUMN sy_parameters.description; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_parameters.description IS 'Diễn giải';


--
-- TOC entry 6991 (class 0 OID 0)
-- Dependencies: 691
-- Name: COLUMN sy_parameters.isencrypt; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_parameters.isencrypt IS 'false(0): không mã hóa; true(1): có mã hóa';


--
-- TOC entry 690 (class 1259 OID 16516)
-- Name: sy_parameters_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.sy_parameters ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.sy_parameters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 693 (class 1259 OID 16537)
-- Name: sy_report_settings; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.sy_report_settings (
    id integer NOT NULL,
    reportname character varying(100),
    description character varying(250) NOT NULL,
    landscape boolean NOT NULL,
    marginleft numeric(5,2) NOT NULL,
    marginright numeric(5,2) NOT NULL,
    margintop numeric(5,2) NOT NULL,
    marginbottom numeric(5,2) NOT NULL,
    status character varying(20) NOT NULL,
    createdby character varying(50) NOT NULL,
    createddate timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updatedby character varying(50) NOT NULL,
    updateddate timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    datarowversion bigint DEFAULT 1 NOT NULL
);


ALTER TABLE public.sy_report_settings OWNER TO sportevent;

--
-- TOC entry 6992 (class 0 OID 0)
-- Dependencies: 693
-- Name: COLUMN sy_report_settings.id; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_report_settings.id IS 'Khóa chính';


--
-- TOC entry 6993 (class 0 OID 0)
-- Dependencies: 693
-- Name: COLUMN sy_report_settings.reportname; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_report_settings.reportname IS 'Tên report: file name của report';


--
-- TOC entry 6994 (class 0 OID 0)
-- Dependencies: 693
-- Name: COLUMN sy_report_settings.description; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_report_settings.description IS 'Mô tả report';


--
-- TOC entry 6995 (class 0 OID 0)
-- Dependencies: 693
-- Name: COLUMN sy_report_settings.landscape; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_report_settings.landscape IS 'Chuyển từ dọc sang ngang, 1: Landscape, 0: Portrait';


--
-- TOC entry 6996 (class 0 OID 0)
-- Dependencies: 693
-- Name: COLUMN sy_report_settings.marginleft; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_report_settings.marginleft IS 'In cách lề trái';


--
-- TOC entry 6997 (class 0 OID 0)
-- Dependencies: 693
-- Name: COLUMN sy_report_settings.marginright; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_report_settings.marginright IS 'In cách lề phải';


--
-- TOC entry 6998 (class 0 OID 0)
-- Dependencies: 693
-- Name: COLUMN sy_report_settings.margintop; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_report_settings.margintop IS 'In cách lề trên';


--
-- TOC entry 6999 (class 0 OID 0)
-- Dependencies: 693
-- Name: COLUMN sy_report_settings.marginbottom; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_report_settings.marginbottom IS 'In cách lề dưới';


--
-- TOC entry 7000 (class 0 OID 0)
-- Dependencies: 693
-- Name: COLUMN sy_report_settings.status; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_report_settings.status IS 'Trạng thái sy_commons: CommonStatus';


--
-- TOC entry 7001 (class 0 OID 0)
-- Dependencies: 693
-- Name: COLUMN sy_report_settings.createdby; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_report_settings.createdby IS 'sy_users: UserName';


--
-- TOC entry 7002 (class 0 OID 0)
-- Dependencies: 693
-- Name: COLUMN sy_report_settings.updatedby; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_report_settings.updatedby IS 'sy_users: UserName';


--
-- TOC entry 692 (class 1259 OID 16536)
-- Name: sy_report_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.sy_report_settings ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.sy_report_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 695 (class 1259 OID 16556)
-- Name: sy_res_language; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.sy_res_language (
    id integer NOT NULL,
    displayname character varying(100) NOT NULL,
    languagecode character varying(3) NOT NULL,
    status boolean DEFAULT true,
    isdefault boolean NOT NULL,
    icon text,
    datarowversion bigint DEFAULT 1 NOT NULL
);


ALTER TABLE public.sy_res_language OWNER TO sportevent;

--
-- TOC entry 694 (class 1259 OID 16555)
-- Name: sy_res_language_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.sy_res_language ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.sy_res_language_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 697 (class 1259 OID 16570)
-- Name: sy_res_resourcecontrols; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.sy_res_resourcecontrols (
    controlid bigint NOT NULL,
    name character varying(100) NOT NULL,
    defaultvalue text,
    datarowversion bigint DEFAULT 1
);


ALTER TABLE public.sy_res_resourcecontrols OWNER TO sportevent;

--
-- TOC entry 838 (class 1259 OID 56449)
-- Name: sy_res_resourcecontrols_compares; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.sy_res_resourcecontrols_compares (
    resource_name character varying(255) NOT NULL
);


ALTER TABLE public.sy_res_resourcecontrols_compares OWNER TO sportevent;

--
-- TOC entry 7003 (class 0 OID 0)
-- Dependencies: 838
-- Name: TABLE sy_res_resourcecontrols_compares; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON TABLE public.sy_res_resourcecontrols_compares IS 'Bảng này dùng để compare resource giữa database và code';


--
-- TOC entry 696 (class 1259 OID 16569)
-- Name: sy_res_resourcecontrols_controlid_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.sy_res_resourcecontrols ALTER COLUMN controlid ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.sy_res_resourcecontrols_controlid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 699 (class 1259 OID 16582)
-- Name: sy_res_resourcecontrols_translated; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.sy_res_resourcecontrols_translated (
    id bigint NOT NULL,
    languagecode character varying(3) NOT NULL,
    languagename character varying(100) NOT NULL,
    languagevalue text,
    datarowversion bigint DEFAULT 1 NOT NULL
);


ALTER TABLE public.sy_res_resourcecontrols_translated OWNER TO sportevent;

--
-- TOC entry 698 (class 1259 OID 16581)
-- Name: sy_res_resourcecontrols_translated_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.sy_res_resourcecontrols_translated ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.sy_res_resourcecontrols_translated_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 701 (class 1259 OID 16596)
-- Name: sy_reset_password; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.sy_reset_password (
    id integer CONSTRAINT sy_resetpassword_id_not_null NOT NULL,
    key_reset character varying(50) CONSTRAINT sy_resetpassword_keyreset_not_null NOT NULL,
    email character varying(50) CONSTRAINT sy_resetpassword_email_not_null NOT NULL,
    expired_date timestamp without time zone CONSTRAINT sy_resetpassword_expireddate_not_null NOT NULL,
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP CONSTRAINT sy_resetpassword_created_date_not_null NOT NULL,
    updated_date timestamp without time zone,
    status smallint CONSTRAINT sy_resetpassword_status_not_null NOT NULL,
    user_name character varying(50) NOT NULL
);


ALTER TABLE public.sy_reset_password OWNER TO sportevent;

--
-- TOC entry 7004 (class 0 OID 0)
-- Dependencies: 701
-- Name: COLUMN sy_reset_password.status; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_reset_password.status IS 'Trạng thái key: 0 chưa sử dụng; 1; đã sử dụng; 2 đã hủy';


--
-- TOC entry 700 (class 1259 OID 16595)
-- Name: sy_resetpassword_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.sy_reset_password ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.sy_resetpassword_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 703 (class 1259 OID 16608)
-- Name: sy_role_details; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.sy_role_details (
    id integer NOT NULL,
    rolecode character varying(50) NOT NULL,
    roletype character varying(20) NOT NULL,
    refercode character varying(50) NOT NULL,
    allowactions character varying(250),
    createdby character varying(50) NOT NULL,
    createddate timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updatedby character varying(50),
    updateddate timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    datarowversion bigint DEFAULT 1 NOT NULL
);


ALTER TABLE public.sy_role_details OWNER TO sportevent;

--
-- TOC entry 7005 (class 0 OID 0)
-- Dependencies: 703
-- Name: COLUMN sy_role_details.rolecode; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_role_details.rolecode IS 'Mã nhóm quyền sy_roles: Code';


--
-- TOC entry 7006 (class 0 OID 0)
-- Dependencies: 703
-- Name: COLUMN sy_role_details.roletype; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_role_details.roletype IS 'Phân loại quyền sy_common: RoleType';


--
-- TOC entry 7007 (class 0 OID 0)
-- Dependencies: 703
-- Name: COLUMN sy_role_details.refercode; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_role_details.refercode IS 'Refer đến mã chức năng cần phân quyền...';


--
-- TOC entry 7008 (class 0 OID 0)
-- Dependencies: 703
-- Name: COLUMN sy_role_details.allowactions; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_role_details.allowactions IS 'Hành động được phép thao tác. Vd: Search,View,Add,Edit,Delete sy_function_actions: Code';


--
-- TOC entry 702 (class 1259 OID 16607)
-- Name: sy_role_details_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.sy_role_details ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.sy_role_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 705 (class 1259 OID 16622)
-- Name: sy_roles; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.sy_roles (
    id integer NOT NULL,
    code character varying(50) NOT NULL,
    namevi character varying(250) NOT NULL,
    nameen character varying(250) NOT NULL,
    description character varying(500),
    status character varying(20),
    createdby character varying(50) NOT NULL,
    createddate timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updatedby character varying(50),
    updateddate timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    datarowversion bigint DEFAULT 1 NOT NULL,
    nameja character varying(250) DEFAULT ''::character varying,
    isviewmonitoringdashboard boolean DEFAULT false,
    user_type character varying(20)
);


ALTER TABLE public.sy_roles OWNER TO sportevent;

--
-- TOC entry 7009 (class 0 OID 0)
-- Dependencies: 705
-- Name: COLUMN sy_roles.code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_roles.code IS 'Mã nhóm quyền';


--
-- TOC entry 7010 (class 0 OID 0)
-- Dependencies: 705
-- Name: COLUMN sy_roles.namevi; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_roles.namevi IS 'Tên nhóm quyền VN';


--
-- TOC entry 7011 (class 0 OID 0)
-- Dependencies: 705
-- Name: COLUMN sy_roles.nameen; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_roles.nameen IS 'Tên nhóm quyền EN';


--
-- TOC entry 7012 (class 0 OID 0)
-- Dependencies: 705
-- Name: COLUMN sy_roles.description; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_roles.description IS 'Ghi chú';


--
-- TOC entry 7013 (class 0 OID 0)
-- Dependencies: 705
-- Name: COLUMN sy_roles.status; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_roles.status IS 'Trạng thái: sy_common: CommonStatus';


--
-- TOC entry 7014 (class 0 OID 0)
-- Dependencies: 705
-- Name: COLUMN sy_roles.nameja; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_roles.nameja IS 'Tên nhóm quyền (JP)';


--
-- TOC entry 7015 (class 0 OID 0)
-- Dependencies: 705
-- Name: COLUMN sy_roles.isviewmonitoringdashboard; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_roles.isviewmonitoringdashboard IS 'Xem Dashboard theo dõi sử dụng hệ thống';


--
-- TOC entry 7016 (class 0 OID 0)
-- Dependencies: 705
-- Name: COLUMN sy_roles.user_type; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_roles.user_type IS 'Role áp dụng cho loại thành viên sy_common: Type = "EMPLOYEE_TYPE". BTC thì không bắt buộc chọn';


--
-- TOC entry 704 (class 1259 OID 16621)
-- Name: sy_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.sy_roles ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.sy_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 707 (class 1259 OID 16642)
-- Name: sy_theme_settings; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.sy_theme_settings (
    id integer NOT NULL,
    themecode character varying(100) NOT NULL,
    themename character varying(100) NOT NULL,
    isdefault boolean NOT NULL,
    isdevexpress boolean NOT NULL,
    customize character varying(500),
    status character varying(20) NOT NULL,
    createdby character varying(50) NOT NULL,
    createddate timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updatedby character varying(50) NOT NULL,
    updateddate timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    datarowversion bigint DEFAULT 1 NOT NULL
);


ALTER TABLE public.sy_theme_settings OWNER TO sportevent;

--
-- TOC entry 7017 (class 0 OID 0)
-- Dependencies: 707
-- Name: COLUMN sy_theme_settings.id; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_theme_settings.id IS 'Khóa chính';


--
-- TOC entry 7018 (class 0 OID 0)
-- Dependencies: 707
-- Name: COLUMN sy_theme_settings.themecode; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_theme_settings.themecode IS 'Mã mẫu giao diện';


--
-- TOC entry 7019 (class 0 OID 0)
-- Dependencies: 707
-- Name: COLUMN sy_theme_settings.themename; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_theme_settings.themename IS 'Tên mẫu giao diện';


--
-- TOC entry 7020 (class 0 OID 0)
-- Dependencies: 707
-- Name: COLUMN sy_theme_settings.isdefault; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_theme_settings.isdefault IS 'Bật cờ mặc định';


--
-- TOC entry 7021 (class 0 OID 0)
-- Dependencies: 707
-- Name: COLUMN sy_theme_settings.isdevexpress; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_theme_settings.isdevexpress IS 'Mẫu có sẵn của devexpress: 1 có; 0: không';


--
-- TOC entry 7022 (class 0 OID 0)
-- Dependencies: 707
-- Name: COLUMN sy_theme_settings.customize; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_theme_settings.customize IS 'Tùy chỉnh giao diện riêng nếu IsDevExpress = 0';


--
-- TOC entry 7023 (class 0 OID 0)
-- Dependencies: 707
-- Name: COLUMN sy_theme_settings.status; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_theme_settings.status IS 'Trạng thái sy_commons: CommonStatus';


--
-- TOC entry 7024 (class 0 OID 0)
-- Dependencies: 707
-- Name: COLUMN sy_theme_settings.createdby; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_theme_settings.createdby IS 'sy_users: UserName';


--
-- TOC entry 7025 (class 0 OID 0)
-- Dependencies: 707
-- Name: COLUMN sy_theme_settings.updatedby; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_theme_settings.updatedby IS 'sy_users: UserName';


--
-- TOC entry 706 (class 1259 OID 16641)
-- Name: sy_theme_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.sy_theme_settings ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.sy_theme_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 709 (class 1259 OID 16661)
-- Name: sy_user_quick_access; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.sy_user_quick_access (
    id integer NOT NULL,
    username character varying(50) NOT NULL,
    functioncode character varying(50) NOT NULL,
    actioncode character varying(50),
    path character varying(200) NOT NULL
);


ALTER TABLE public.sy_user_quick_access OWNER TO sportevent;

--
-- TOC entry 708 (class 1259 OID 16660)
-- Name: sy_user_quick_access_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.sy_user_quick_access ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.sy_user_quick_access_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 711 (class 1259 OID 16671)
-- Name: sy_user_roles; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.sy_user_roles (
    id integer NOT NULL,
    username character varying(50) NOT NULL,
    userrolecode character varying(50) NOT NULL,
    createdby character varying(50) NOT NULL,
    createddate timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updatedby character varying(50) NOT NULL,
    updateddate timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    datarowversion bigint DEFAULT 1 NOT NULL
);


ALTER TABLE public.sy_user_roles OWNER TO sportevent;

--
-- TOC entry 710 (class 1259 OID 16670)
-- Name: sy_user_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.sy_user_roles ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.sy_user_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 733 (class 1259 OID 18687)
-- Name: sy_user_send_otps; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.sy_user_send_otps (
    id integer NOT NULL,
    user_name character varying(50) NOT NULL,
    email character varying(150) NOT NULL,
    otp_hash character varying(32) NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    expired_date timestamp(6) without time zone NOT NULL,
    is_used boolean DEFAULT false NOT NULL,
    data_row_version bigint DEFAULT 1 NOT NULL,
    updated_date time(6) with time zone,
    otp_status smallint DEFAULT 0 NOT NULL,
    next_send_otp_date timestamp with time zone NOT NULL,
    otp_type character varying(50)
);


ALTER TABLE public.sy_user_send_otps OWNER TO sportevent;

--
-- TOC entry 7026 (class 0 OID 0)
-- Dependencies: 733
-- Name: COLUMN sy_user_send_otps.email; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_user_send_otps.email IS 'Email ms_employees: email';


--
-- TOC entry 7027 (class 0 OID 0)
-- Dependencies: 733
-- Name: COLUMN sy_user_send_otps.otp_hash; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_user_send_otps.otp_hash IS 'Mã OTP đã mã hóa';


--
-- TOC entry 7028 (class 0 OID 0)
-- Dependencies: 733
-- Name: COLUMN sy_user_send_otps.created_date; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_user_send_otps.created_date IS 'Thời gian gửi';


--
-- TOC entry 7029 (class 0 OID 0)
-- Dependencies: 733
-- Name: COLUMN sy_user_send_otps.expired_date; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_user_send_otps.expired_date IS 'Thời gian hết hạn';


--
-- TOC entry 7030 (class 0 OID 0)
-- Dependencies: 733
-- Name: COLUMN sy_user_send_otps.is_used; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_user_send_otps.is_used IS 'Trạng thái đã sử dụng hay chưa';


--
-- TOC entry 7031 (class 0 OID 0)
-- Dependencies: 733
-- Name: COLUMN sy_user_send_otps.otp_status; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_user_send_otps.otp_status IS 'Trạng thái otp: 0 chưa dùng; 1 đã dùng; 2 đã hủy';


--
-- TOC entry 7032 (class 0 OID 0)
-- Dependencies: 733
-- Name: COLUMN sy_user_send_otps.otp_type; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_user_send_otps.otp_type IS 'Loại otp (áp dụng cho chức năng)';


--
-- TOC entry 732 (class 1259 OID 18686)
-- Name: sy_user_send_otps_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.sy_user_send_otps ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.sy_user_send_otps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 713 (class 1259 OID 16685)
-- Name: sy_users; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.sy_users (
    id integer NOT NULL,
    username character varying(50) NOT NULL,
    password character varying(250) NOT NULL,
    fullname character varying(250),
    email character varying(150),
    status character varying(20) NOT NULL,
    avatarfilepath character varying(250),
    lastupdatepassword timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    createdby character varying(50) NOT NULL,
    createddate timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updatedby character varying(50) NOT NULL,
    updateddate timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    datarowversion bigint DEFAULT 1 NOT NULL,
    referenceobjectcode character varying(50) NOT NULL
);


ALTER TABLE public.sy_users OWNER TO sportevent;

--
-- TOC entry 7033 (class 0 OID 0)
-- Dependencies: 713
-- Name: COLUMN sy_users.username; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_users.username IS 'Tên đăng nhập';


--
-- TOC entry 7034 (class 0 OID 0)
-- Dependencies: 713
-- Name: COLUMN sy_users.password; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_users.password IS 'Mật khẩu (mã hóa)';


--
-- TOC entry 7035 (class 0 OID 0)
-- Dependencies: 713
-- Name: COLUMN sy_users.fullname; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_users.fullname IS 'Họ và tên';


--
-- TOC entry 7036 (class 0 OID 0)
-- Dependencies: 713
-- Name: COLUMN sy_users.email; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_users.email IS 'Địa chỉ mail';


--
-- TOC entry 7037 (class 0 OID 0)
-- Dependencies: 713
-- Name: COLUMN sy_users.status; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_users.status IS 'Trạng thái (sy_common: CommonStatus)';


--
-- TOC entry 7038 (class 0 OID 0)
-- Dependencies: 713
-- Name: COLUMN sy_users.lastupdatepassword; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_users.lastupdatepassword IS 'Ngày cập nhật mật khẩu cuối cùng';


--
-- TOC entry 7039 (class 0 OID 0)
-- Dependencies: 713
-- Name: COLUMN sy_users.referenceobjectcode; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.sy_users.referenceobjectcode IS 'Mã đối tượng ms_objects: Code, Type = EMP';


--
-- TOC entry 712 (class 1259 OID 16684)
-- Name: sy_users_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.sy_users ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.sy_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 755 (class 1259 OID 19222)
-- Name: ta_task_assignment; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.ta_task_assignment (
    id integer NOT NULL,
    competition_code character varying(50) NOT NULL,
    match_code character varying(50) NOT NULL,
    task_code character varying(50) NOT NULL,
    area_code character varying(50),
    task_name_vi character varying(255) NOT NULL,
    task_name_en character varying(255) NOT NULL,
    match_start_date date,
    match_end_date date,
    match_start_time time(6) without time zone,
    match_end_time time(6) without time zone,
    status character varying(1) NOT NULL,
    contents text,
    important_note text,
    created_by character varying(50) NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(50) NOT NULL,
    updated_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data_row_version bigint DEFAULT 1 NOT NULL
);


ALTER TABLE public.ta_task_assignment OWNER TO sportevent;

--
-- TOC entry 7040 (class 0 OID 0)
-- Dependencies: 755
-- Name: COLUMN ta_task_assignment.competition_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ta_task_assignment.competition_code IS 'Mã sự kiện ms_competition_events: competition_code';


--
-- TOC entry 7041 (class 0 OID 0)
-- Dependencies: 755
-- Name: COLUMN ta_task_assignment.match_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ta_task_assignment.match_code IS 'Trận đấu sr_match_schedules: match_code';


--
-- TOC entry 7042 (class 0 OID 0)
-- Dependencies: 755
-- Name: COLUMN ta_task_assignment.task_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ta_task_assignment.task_code IS 'Mã nhiệm vụ';


--
-- TOC entry 7043 (class 0 OID 0)
-- Dependencies: 755
-- Name: COLUMN ta_task_assignment.area_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ta_task_assignment.area_code IS 'Khu vực ms_location_detail: area_code';


--
-- TOC entry 7044 (class 0 OID 0)
-- Dependencies: 755
-- Name: COLUMN ta_task_assignment.task_name_vi; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ta_task_assignment.task_name_vi IS 'Tên nhiệm vụ VN';


--
-- TOC entry 7045 (class 0 OID 0)
-- Dependencies: 755
-- Name: COLUMN ta_task_assignment.task_name_en; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ta_task_assignment.task_name_en IS 'Tên nhiệm vụ EN';


--
-- TOC entry 7046 (class 0 OID 0)
-- Dependencies: 755
-- Name: COLUMN ta_task_assignment.match_start_date; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ta_task_assignment.match_start_date IS 'Ngày bắt đầu';


--
-- TOC entry 7047 (class 0 OID 0)
-- Dependencies: 755
-- Name: COLUMN ta_task_assignment.match_end_date; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ta_task_assignment.match_end_date IS 'Ngày kết thúc';


--
-- TOC entry 7048 (class 0 OID 0)
-- Dependencies: 755
-- Name: COLUMN ta_task_assignment.match_start_time; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ta_task_assignment.match_start_time IS 'Thời gian bắt đầu';


--
-- TOC entry 7049 (class 0 OID 0)
-- Dependencies: 755
-- Name: COLUMN ta_task_assignment.match_end_time; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ta_task_assignment.match_end_time IS 'Thời gian kết thúc';


--
-- TOC entry 7050 (class 0 OID 0)
-- Dependencies: 755
-- Name: COLUMN ta_task_assignment.status; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ta_task_assignment.status IS 'Trạng Thái sy_commons: Type = "TASK_STATUS"';


--
-- TOC entry 7051 (class 0 OID 0)
-- Dependencies: 755
-- Name: COLUMN ta_task_assignment.contents; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ta_task_assignment.contents IS 'Nội dung';


--
-- TOC entry 7052 (class 0 OID 0)
-- Dependencies: 755
-- Name: COLUMN ta_task_assignment.important_note; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ta_task_assignment.important_note IS 'Lưu ý';


--
-- TOC entry 7053 (class 0 OID 0)
-- Dependencies: 755
-- Name: COLUMN ta_task_assignment.created_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ta_task_assignment.created_by IS 'sy_users: user_name';


--
-- TOC entry 7054 (class 0 OID 0)
-- Dependencies: 755
-- Name: COLUMN ta_task_assignment.updated_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ta_task_assignment.updated_by IS 'sy_users: user_name';


--
-- TOC entry 757 (class 1259 OID 19258)
-- Name: ta_task_assignment_detail; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.ta_task_assignment_detail (
    id integer NOT NULL,
    task_code character varying(50) NOT NULL,
    person_in_charge character varying(50) NOT NULL,
    person_in_charge_role character varying(50) NOT NULL,
    phone_number character varying(50),
    task_description character varying(500),
    status character varying(1) NOT NULL,
    created_by character varying(50) NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(50) NOT NULL,
    updated_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data_row_version bigint DEFAULT 1 NOT NULL
);


ALTER TABLE public.ta_task_assignment_detail OWNER TO sportevent;

--
-- TOC entry 7055 (class 0 OID 0)
-- Dependencies: 757
-- Name: COLUMN ta_task_assignment_detail.task_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ta_task_assignment_detail.task_code IS 'Mã nhiệm vụ ta_task_assignment_detail: task_code';


--
-- TOC entry 7056 (class 0 OID 0)
-- Dependencies: 757
-- Name: COLUMN ta_task_assignment_detail.person_in_charge; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ta_task_assignment_detail.person_in_charge IS 'Người phụ trách ms_employees: employee_code';


--
-- TOC entry 7057 (class 0 OID 0)
-- Dependencies: 757
-- Name: COLUMN ta_task_assignment_detail.person_in_charge_role; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ta_task_assignment_detail.person_in_charge_role IS 'Vai trò sy_commons: Type = "PERSONINCHARE_ROLE"';


--
-- TOC entry 7058 (class 0 OID 0)
-- Dependencies: 757
-- Name: COLUMN ta_task_assignment_detail.phone_number; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ta_task_assignment_detail.phone_number IS 'Số điện thoại';


--
-- TOC entry 7059 (class 0 OID 0)
-- Dependencies: 757
-- Name: COLUMN ta_task_assignment_detail.task_description; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ta_task_assignment_detail.task_description IS 'Nhiệm vụ';


--
-- TOC entry 7060 (class 0 OID 0)
-- Dependencies: 757
-- Name: COLUMN ta_task_assignment_detail.status; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ta_task_assignment_detail.status IS 'Trạng thái sy_commons: Type = "TASK_STATUS"';


--
-- TOC entry 7061 (class 0 OID 0)
-- Dependencies: 757
-- Name: COLUMN ta_task_assignment_detail.created_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ta_task_assignment_detail.created_by IS 'sy_users: user_name';


--
-- TOC entry 7062 (class 0 OID 0)
-- Dependencies: 757
-- Name: COLUMN ta_task_assignment_detail.updated_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ta_task_assignment_detail.updated_by IS 'sy_users: user_name';


--
-- TOC entry 756 (class 1259 OID 19257)
-- Name: ta_task_assignment_detail_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.ta_task_assignment_detail ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ta_task_assignment_detail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 754 (class 1259 OID 19221)
-- Name: ta_task_assignment_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.ta_task_assignment ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ta_task_assignment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 761 (class 1259 OID 19368)
-- Name: ti_ticket_detail; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.ti_ticket_detail (
    id integer NOT NULL,
    ticket_code character varying(50) NOT NULL,
    category_code character varying(50) NOT NULL,
    total_tickets integer NOT NULL,
    prices numeric(25,10) NOT NULL,
    created_by character varying(50) NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(50) NOT NULL,
    updated_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data_row_version bigint DEFAULT 1 NOT NULL,
    sold_tickets integer DEFAULT 0
);


ALTER TABLE public.ti_ticket_detail OWNER TO sportevent;

--
-- TOC entry 7063 (class 0 OID 0)
-- Dependencies: 761
-- Name: COLUMN ti_ticket_detail.ticket_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ti_ticket_detail.ticket_code IS 'Mã vé ti_ticket_price: ticket_code';


--
-- TOC entry 7064 (class 0 OID 0)
-- Dependencies: 761
-- Name: COLUMN ti_ticket_detail.category_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ti_ticket_detail.category_code IS 'Hạng mục ms_ticket_category: category_code';


--
-- TOC entry 7065 (class 0 OID 0)
-- Dependencies: 761
-- Name: COLUMN ti_ticket_detail.total_tickets; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ti_ticket_detail.total_tickets IS 'Tổng số vé';


--
-- TOC entry 7066 (class 0 OID 0)
-- Dependencies: 761
-- Name: COLUMN ti_ticket_detail.prices; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ti_ticket_detail.prices IS 'Giá vé';


--
-- TOC entry 7067 (class 0 OID 0)
-- Dependencies: 761
-- Name: COLUMN ti_ticket_detail.created_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ti_ticket_detail.created_by IS 'sy_users: user_name';


--
-- TOC entry 7068 (class 0 OID 0)
-- Dependencies: 761
-- Name: COLUMN ti_ticket_detail.updated_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ti_ticket_detail.updated_by IS 'sy_users: user_name';


--
-- TOC entry 7069 (class 0 OID 0)
-- Dependencies: 761
-- Name: COLUMN ti_ticket_detail.sold_tickets; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ti_ticket_detail.sold_tickets IS 'Số vé đã bán';


--
-- TOC entry 760 (class 1259 OID 19367)
-- Name: ti_ticket_detail_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.ti_ticket_detail ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ti_ticket_detail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 759 (class 1259 OID 19327)
-- Name: ti_ticket_price; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.ti_ticket_price (
    id integer NOT NULL,
    ticket_code character varying(50) NOT NULL,
    competition_code character varying(50) NOT NULL,
    match_code character varying(50) NOT NULL,
    terms_and_conditions character varying(500),
    status character varying(1) DEFAULT 1 NOT NULL,
    image character varying(255),
    created_by character varying(50) NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(50) NOT NULL,
    updated_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data_row_version bigint DEFAULT 1 NOT NULL,
    is_highlights boolean DEFAULT false
);


ALTER TABLE public.ti_ticket_price OWNER TO sportevent;

--
-- TOC entry 7070 (class 0 OID 0)
-- Dependencies: 759
-- Name: COLUMN ti_ticket_price.ticket_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ti_ticket_price.ticket_code IS 'Mã vé';


--
-- TOC entry 7071 (class 0 OID 0)
-- Dependencies: 759
-- Name: COLUMN ti_ticket_price.competition_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ti_ticket_price.competition_code IS 'Sự kiện ms_competition_event: competition_code';


--
-- TOC entry 7072 (class 0 OID 0)
-- Dependencies: 759
-- Name: COLUMN ti_ticket_price.match_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ti_ticket_price.match_code IS 'Trận đấu sr_match_schedule: match_code';


--
-- TOC entry 7073 (class 0 OID 0)
-- Dependencies: 759
-- Name: COLUMN ti_ticket_price.terms_and_conditions; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ti_ticket_price.terms_and_conditions IS 'Điều khoản & Điều kiện';


--
-- TOC entry 7074 (class 0 OID 0)
-- Dependencies: 759
-- Name: COLUMN ti_ticket_price.status; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ti_ticket_price.status IS 'Trạng thái vé sy_commons: Type = "COMMON_STATUS"';


--
-- TOC entry 7075 (class 0 OID 0)
-- Dependencies: 759
-- Name: COLUMN ti_ticket_price.image; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ti_ticket_price.image IS 'Ảnh hiển thị';


--
-- TOC entry 7076 (class 0 OID 0)
-- Dependencies: 759
-- Name: COLUMN ti_ticket_price.created_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ti_ticket_price.created_by IS 'sy_users: user_name';


--
-- TOC entry 7077 (class 0 OID 0)
-- Dependencies: 759
-- Name: COLUMN ti_ticket_price.updated_by; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ti_ticket_price.updated_by IS 'sy_users: user_name';


--
-- TOC entry 7078 (class 0 OID 0)
-- Dependencies: 759
-- Name: COLUMN ti_ticket_price.is_highlights; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ti_ticket_price.is_highlights IS 'Vé nổi bật';


--
-- TOC entry 758 (class 1259 OID 19326)
-- Name: ti_ticket_price_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.ti_ticket_price ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ti_ticket_price_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 785 (class 1259 OID 21620)
-- Name: ti_ticket_sold; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.ti_ticket_sold (
    id integer NOT NULL,
    tickets_detail_id integer NOT NULL,
    ticket_auto_code character varying(50),
    status character varying(1) NOT NULL,
    discount_code character varying(50),
    discount_amount numeric(25,10),
    pay_amount numeric(25,10),
    buyer_name character varying(255),
    buyer_email character varying(150),
    buyer_phone character varying(50),
    created_by character varying(20) NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(20) NOT NULL,
    updated_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    payment_refer_id character varying(100),
    cancel_reason character varying(255),
    qr_code character varying(255)
);


ALTER TABLE public.ti_ticket_sold OWNER TO sportevent;

--
-- TOC entry 7079 (class 0 OID 0)
-- Dependencies: 785
-- Name: COLUMN ti_ticket_sold.tickets_detail_id; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ti_ticket_sold.tickets_detail_id IS 'ti_ticket_detail: id';


--
-- TOC entry 7080 (class 0 OID 0)
-- Dependencies: 785
-- Name: COLUMN ti_ticket_sold.ticket_auto_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ti_ticket_sold.ticket_auto_code IS 'Mã vé tự động sau khi được đặt';


--
-- TOC entry 7081 (class 0 OID 0)
-- Dependencies: 785
-- Name: COLUMN ti_ticket_sold.status; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ti_ticket_sold.status IS 'Trạng thái vé sy_commons: Type = ''PAYMENT_STATUS''';


--
-- TOC entry 7082 (class 0 OID 0)
-- Dependencies: 785
-- Name: COLUMN ti_ticket_sold.discount_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ti_ticket_sold.discount_code IS 'Mã giảm giá ms_discounts: discount_code';


--
-- TOC entry 7083 (class 0 OID 0)
-- Dependencies: 785
-- Name: COLUMN ti_ticket_sold.discount_amount; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ti_ticket_sold.discount_amount IS 'Số tiền giảm';


--
-- TOC entry 7084 (class 0 OID 0)
-- Dependencies: 785
-- Name: COLUMN ti_ticket_sold.pay_amount; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ti_ticket_sold.pay_amount IS 'Số tiền thanh toán';


--
-- TOC entry 7085 (class 0 OID 0)
-- Dependencies: 785
-- Name: COLUMN ti_ticket_sold.buyer_name; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ti_ticket_sold.buyer_name IS 'Tên người mua';


--
-- TOC entry 7086 (class 0 OID 0)
-- Dependencies: 785
-- Name: COLUMN ti_ticket_sold.buyer_email; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ti_ticket_sold.buyer_email IS 'Email người mua';


--
-- TOC entry 7087 (class 0 OID 0)
-- Dependencies: 785
-- Name: COLUMN ti_ticket_sold.payment_refer_id; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ti_ticket_sold.payment_refer_id IS 'Mã giao dịch tham chiếu';


--
-- TOC entry 7088 (class 0 OID 0)
-- Dependencies: 785
-- Name: COLUMN ti_ticket_sold.qr_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.ti_ticket_sold.qr_code IS 'Mã QR vé tự sinh khi thanh toán thành công';


--
-- TOC entry 784 (class 1259 OID 21619)
-- Name: ti_ticket_sold_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.ti_ticket_sold ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ti_ticket_sold_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 828 (class 1259 OID 39391)
-- Name: vnpay_payment_histories; Type: TABLE; Schema: public; Owner: sportevent
--

CREATE TABLE public.vnpay_payment_histories (
    id integer NOT NULL,
    vnp_tmn_code character varying(20) NOT NULL,
    vnp_amount bigint NOT NULL,
    vnp_bank_code character varying(20) NOT NULL,
    vnp_bank_tran_no character varying(255),
    vnp_card_type character varying(50),
    vnp_pay_date character varying(14),
    vnp_order_info character varying(255) NOT NULL,
    vnp_transaction_no character varying(50) NOT NULL,
    vnp_response_code character varying(2) NOT NULL,
    vnp_transaction_status character varying(2) NOT NULL,
    vnp_txn_ref character varying(100) NOT NULL,
    vnp_secure_hash character varying(255) NOT NULL,
    created_by character varying(50) NOT NULL,
    created_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(50) NOT NULL,
    updated_date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.vnpay_payment_histories OWNER TO sportevent;

--
-- TOC entry 7089 (class 0 OID 0)
-- Dependencies: 828
-- Name: TABLE vnpay_payment_histories; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON TABLE public.vnpay_payment_histories IS 'Bảng lưu trữ lịch sử phản hồi giao dịch từ cổng thanh toán VNPAY';


--
-- TOC entry 7090 (class 0 OID 0)
-- Dependencies: 828
-- Name: COLUMN vnpay_payment_histories.vnp_tmn_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.vnpay_payment_histories.vnp_tmn_code IS 'Mã website (Terminal ID) đăng ký tại VNPAY';


--
-- TOC entry 7091 (class 0 OID 0)
-- Dependencies: 828
-- Name: COLUMN vnpay_payment_histories.vnp_amount; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.vnpay_payment_histories.vnp_amount IS 'Số tiền thanh toán (Số tiền gốc * 100)';


--
-- TOC entry 7092 (class 0 OID 0)
-- Dependencies: 828
-- Name: COLUMN vnpay_payment_histories.vnp_bank_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.vnpay_payment_histories.vnp_bank_code IS 'Mã ngân hàng thực hiện thanh toán';


--
-- TOC entry 7093 (class 0 OID 0)
-- Dependencies: 828
-- Name: COLUMN vnpay_payment_histories.vnp_bank_tran_no; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.vnpay_payment_histories.vnp_bank_tran_no IS 'Mã giao dịch ghi nhận tại ngân hàng';


--
-- TOC entry 7094 (class 0 OID 0)
-- Dependencies: 828
-- Name: COLUMN vnpay_payment_histories.vnp_card_type; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.vnpay_payment_histories.vnp_card_type IS 'Loại thẻ/tài khoản (ATM, VISA, MASTERCARD...)';


--
-- TOC entry 7095 (class 0 OID 0)
-- Dependencies: 828
-- Name: COLUMN vnpay_payment_histories.vnp_pay_date; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.vnpay_payment_histories.vnp_pay_date IS 'Thời gian thanh toán từ VNPAY (yyyyMMddHHmmss)';


--
-- TOC entry 7096 (class 0 OID 0)
-- Dependencies: 828
-- Name: COLUMN vnpay_payment_histories.vnp_order_info; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.vnpay_payment_histories.vnp_order_info IS 'Nội dung mô tả đơn hàng';


--
-- TOC entry 7097 (class 0 OID 0)
-- Dependencies: 828
-- Name: COLUMN vnpay_payment_histories.vnp_transaction_no; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.vnpay_payment_histories.vnp_transaction_no IS 'Mã giao dịch duy nhất tại hệ thống VNPAY';


--
-- TOC entry 7098 (class 0 OID 0)
-- Dependencies: 828
-- Name: COLUMN vnpay_payment_histories.vnp_response_code; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.vnpay_payment_histories.vnp_response_code IS 'Mã phản hồi kết quả (00: Thành công)';


--
-- TOC entry 7099 (class 0 OID 0)
-- Dependencies: 828
-- Name: COLUMN vnpay_payment_histories.vnp_transaction_status; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.vnpay_payment_histories.vnp_transaction_status IS 'Trạng thái giao dịch (00: Thành công, 01: Chưa hoàn thành...)';


--
-- TOC entry 7100 (class 0 OID 0)
-- Dependencies: 828
-- Name: COLUMN vnpay_payment_histories.vnp_txn_ref; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.vnpay_payment_histories.vnp_txn_ref IS 'Mã tham chiếu đơn hàng của hệ thống mình (Merchant Order ID)';


--
-- TOC entry 7101 (class 0 OID 0)
-- Dependencies: 828
-- Name: COLUMN vnpay_payment_histories.vnp_secure_hash; Type: COMMENT; Schema: public; Owner: sportevent
--

COMMENT ON COLUMN public.vnpay_payment_histories.vnp_secure_hash IS 'Chữ ký kiểm tra tính toàn vẹn dữ liệu';


--
-- TOC entry 827 (class 1259 OID 39390)
-- Name: vnpay_payment_histories_id_seq; Type: SEQUENCE; Schema: public; Owner: sportevent
--

ALTER TABLE public.vnpay_payment_histories ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.vnpay_payment_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 6101 (class 2604 OID 24433)
-- Name: counter id; Type: DEFAULT; Schema: hangfire; Owner: sportevent
--

ALTER TABLE ONLY hangfire.counter ALTER COLUMN id SET DEFAULT nextval('hangfire.counter_id_seq'::regclass);


--
-- TOC entry 6102 (class 2604 OID 24443)
-- Name: hash id; Type: DEFAULT; Schema: hangfire; Owner: sportevent
--

ALTER TABLE ONLY hangfire.hash ALTER COLUMN id SET DEFAULT nextval('hangfire.hash_id_seq'::regclass);


--
-- TOC entry 6104 (class 2604 OID 24454)
-- Name: job id; Type: DEFAULT; Schema: hangfire; Owner: sportevent
--

ALTER TABLE ONLY hangfire.job ALTER COLUMN id SET DEFAULT nextval('hangfire.job_id_seq'::regclass);


--
-- TOC entry 6115 (class 2604 OID 24507)
-- Name: jobparameter id; Type: DEFAULT; Schema: hangfire; Owner: sportevent
--

ALTER TABLE ONLY hangfire.jobparameter ALTER COLUMN id SET DEFAULT nextval('hangfire.jobparameter_id_seq'::regclass);


--
-- TOC entry 6108 (class 2604 OID 24532)
-- Name: jobqueue id; Type: DEFAULT; Schema: hangfire; Owner: sportevent
--

ALTER TABLE ONLY hangfire.jobqueue ALTER COLUMN id SET DEFAULT nextval('hangfire.jobqueue_id_seq'::regclass);


--
-- TOC entry 6110 (class 2604 OID 24554)
-- Name: list id; Type: DEFAULT; Schema: hangfire; Owner: sportevent
--

ALTER TABLE ONLY hangfire.list ALTER COLUMN id SET DEFAULT nextval('hangfire.list_id_seq'::regclass);


--
-- TOC entry 6113 (class 2604 OID 24564)
-- Name: set id; Type: DEFAULT; Schema: hangfire; Owner: sportevent
--

ALTER TABLE ONLY hangfire.set ALTER COLUMN id SET DEFAULT nextval('hangfire.set_id_seq'::regclass);


--
-- TOC entry 6106 (class 2604 OID 24482)
-- Name: state id; Type: DEFAULT; Schema: hangfire; Owner: sportevent
--

ALTER TABLE ONLY hangfire.state ALTER COLUMN id SET DEFAULT nextval('hangfire.state_id_seq'::regclass);


--
-- TOC entry 6123 (class 2604 OID 37398)
-- Name: sr_match_referee_notes id; Type: DEFAULT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sr_match_referee_notes ALTER COLUMN id SET DEFAULT nextval('public.sr_match_referee_notes_id_seq'::regclass);


--
-- TOC entry 6329 (class 2606 OID 24435)
-- Name: counter counter_pkey; Type: CONSTRAINT; Schema: hangfire; Owner: sportevent
--

ALTER TABLE ONLY hangfire.counter
    ADD CONSTRAINT counter_pkey PRIMARY KEY (id);


--
-- TOC entry 6333 (class 2606 OID 24583)
-- Name: hash hash_key_field_key; Type: CONSTRAINT; Schema: hangfire; Owner: sportevent
--

ALTER TABLE ONLY hangfire.hash
    ADD CONSTRAINT hash_key_field_key UNIQUE (key, field);


--
-- TOC entry 6335 (class 2606 OID 24445)
-- Name: hash hash_pkey; Type: CONSTRAINT; Schema: hangfire; Owner: sportevent
--

ALTER TABLE ONLY hangfire.hash
    ADD CONSTRAINT hash_pkey PRIMARY KEY (id);


--
-- TOC entry 6338 (class 2606 OID 24456)
-- Name: job job_pkey; Type: CONSTRAINT; Schema: hangfire; Owner: sportevent
--

ALTER TABLE ONLY hangfire.job
    ADD CONSTRAINT job_pkey PRIMARY KEY (id);


--
-- TOC entry 6356 (class 2606 OID 24509)
-- Name: jobparameter jobparameter_pkey; Type: CONSTRAINT; Schema: hangfire; Owner: sportevent
--

ALTER TABLE ONLY hangfire.jobparameter
    ADD CONSTRAINT jobparameter_pkey PRIMARY KEY (id);


--
-- TOC entry 6345 (class 2606 OID 24534)
-- Name: jobqueue jobqueue_pkey; Type: CONSTRAINT; Schema: hangfire; Owner: sportevent
--

ALTER TABLE ONLY hangfire.jobqueue
    ADD CONSTRAINT jobqueue_pkey PRIMARY KEY (id);


--
-- TOC entry 6347 (class 2606 OID 24556)
-- Name: list list_pkey; Type: CONSTRAINT; Schema: hangfire; Owner: sportevent
--

ALTER TABLE ONLY hangfire.list
    ADD CONSTRAINT list_pkey PRIMARY KEY (id);


--
-- TOC entry 6358 (class 2606 OID 24424)
-- Name: lock lock_resource_key; Type: CONSTRAINT; Schema: hangfire; Owner: sportevent
--

ALTER TABLE ONLY hangfire.lock
    ADD CONSTRAINT lock_resource_key UNIQUE (resource);


--
-- TOC entry 6327 (class 2606 OID 24262)
-- Name: schema schema_pkey; Type: CONSTRAINT; Schema: hangfire; Owner: sportevent
--

ALTER TABLE ONLY hangfire.schema
    ADD CONSTRAINT schema_pkey PRIMARY KEY (version);


--
-- TOC entry 6349 (class 2606 OID 24588)
-- Name: server server_pkey; Type: CONSTRAINT; Schema: hangfire; Owner: sportevent
--

ALTER TABLE ONLY hangfire.server
    ADD CONSTRAINT server_pkey PRIMARY KEY (id);


--
-- TOC entry 6351 (class 2606 OID 24591)
-- Name: set set_key_value_key; Type: CONSTRAINT; Schema: hangfire; Owner: sportevent
--

ALTER TABLE ONLY hangfire.set
    ADD CONSTRAINT set_key_value_key UNIQUE (key, value);


--
-- TOC entry 6353 (class 2606 OID 24566)
-- Name: set set_pkey; Type: CONSTRAINT; Schema: hangfire; Owner: sportevent
--

ALTER TABLE ONLY hangfire.set
    ADD CONSTRAINT set_pkey PRIMARY KEY (id);


--
-- TOC entry 6341 (class 2606 OID 24484)
-- Name: state state_pkey; Type: CONSTRAINT; Schema: hangfire; Owner: sportevent
--

ALTER TABLE ONLY hangfire.state
    ADD CONSTRAINT state_pkey PRIMARY KEY (id);


--
-- TOC entry 6315 (class 2606 OID 22457)
-- Name: io_inout_barcode_history io_inout_barcode_history_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.io_inout_barcode_history
    ADD CONSTRAINT io_inout_barcode_history_pkey PRIMARY KEY (id);


--
-- TOC entry 6321 (class 2606 OID 22500)
-- Name: io_inout_card_detail io_inout_card_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.io_inout_card_detail
    ADD CONSTRAINT io_inout_card_detail_pkey PRIMARY KEY (id);


--
-- TOC entry 6323 (class 2606 OID 22524)
-- Name: io_inout_card_history io_inout_card_history_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.io_inout_card_history
    ADD CONSTRAINT io_inout_card_history_pkey PRIMARY KEY (id);


--
-- TOC entry 6317 (class 2606 OID 22482)
-- Name: io_inout_card io_inout_card_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.io_inout_card
    ADD CONSTRAINT io_inout_card_pkey PRIMARY KEY (id);


--
-- TOC entry 6248 (class 2606 OID 19054)
-- Name: ms_achievement_history ms_achievement_history_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_achievement_history
    ADD CONSTRAINT ms_achievement_history_pkey PRIMARY KEY (id);


--
-- TOC entry 6370 (class 2606 OID 44578)
-- Name: ms_athlete_coach_notes ms_athlete_coach_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_athlete_coach_notes
    ADD CONSTRAINT ms_athlete_coach_notes_pkey PRIMARY KEY (id);


--
-- TOC entry 6250 (class 2606 OID 19079)
-- Name: ms_athlete_violation_history ms_athlete_violation_history_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_athlete_violation_history
    ADD CONSTRAINT ms_athlete_violation_history_pkey PRIMARY KEY (id);


--
-- TOC entry 6216 (class 2606 OID 18214)
-- Name: ms_background ms_background_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_background
    ADD CONSTRAINT ms_background_pkey PRIMARY KEY (id);


--
-- TOC entry 6272 (class 2606 OID 19494)
-- Name: ms_certificates ms_certificates_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_certificates
    ADD CONSTRAINT ms_certificates_pkey PRIMARY KEY (id);


--
-- TOC entry 6208 (class 2606 OID 18031)
-- Name: ms_competition_events ms_competition_events_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_competition_events
    ADD CONSTRAINT ms_competition_events_pkey PRIMARY KEY (id);


--
-- TOC entry 6375 (class 2606 OID 54924)
-- Name: ms_competition_profile ms_competition_profile_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_competition_profile
    ADD CONSTRAINT ms_competition_profile_pkey PRIMARY KEY (id);


--
-- TOC entry 6294 (class 2606 OID 19763)
-- Name: ms_competition_team_list ms_competition_team_list_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_competition_team_list
    ADD CONSTRAINT ms_competition_team_list_pkey PRIMARY KEY (id);


--
-- TOC entry 6377 (class 2606 OID 55468)
-- Name: ms_contents ms_contents_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_contents
    ADD CONSTRAINT ms_contents_pkey PRIMARY KEY (id);


--
-- TOC entry 6236 (class 2606 OID 18776)
-- Name: ms_discounts ms_discounts_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_discounts
    ADD CONSTRAINT ms_discounts_pkey PRIMARY KEY (id);


--
-- TOC entry 6232 (class 2606 OID 18734)
-- Name: ms_employees ms_employees_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_employees
    ADD CONSTRAINT ms_employees_pkey PRIMARY KEY (id);


--
-- TOC entry 6307 (class 2606 OID 22042)
-- Name: ms_event_organizing ms_event_organizing_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_event_organizing
    ADD CONSTRAINT ms_event_organizing_pkey PRIMARY KEY (id);


--
-- TOC entry 6274 (class 2606 OID 19520)
-- Name: ms_experiences ms_experiences_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_experiences
    ADD CONSTRAINT ms_experiences_pkey PRIMARY KEY (id);


--
-- TOC entry 6246 (class 2606 OID 19029)
-- Name: ms_injury_history ms_injury_history_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_injury_history
    ADD CONSTRAINT ms_injury_history_pkey PRIMARY KEY (id);


--
-- TOC entry 6228 (class 2606 OID 18564)
-- Name: ms_location_detail ms_location_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_location_detail
    ADD CONSTRAINT ms_location_detail_pkey PRIMARY KEY (id);


--
-- TOC entry 6224 (class 2606 OID 18541)
-- Name: ms_locations ms_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_locations
    ADD CONSTRAINT ms_locations_pkey PRIMARY KEY (id);


--
-- TOC entry 6309 (class 2606 OID 22056)
-- Name: ms_publisher ms_publisher_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_publisher
    ADD CONSTRAINT ms_publisher_pkey PRIMARY KEY (id);


--
-- TOC entry 6220 (class 2606 OID 18244)
-- Name: ms_sponsors ms_sponsors_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_sponsors
    ADD CONSTRAINT ms_sponsors_pkey PRIMARY KEY (id);


--
-- TOC entry 6202 (class 2606 OID 17920)
-- Name: ms_sport_detail ms_sport_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_sport_detail
    ADD CONSTRAINT ms_sport_detail_pkey PRIMARY KEY (id);


--
-- TOC entry 6290 (class 2606 OID 19733)
-- Name: ms_sport_events ms_sport_events_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_sport_events
    ADD CONSTRAINT ms_sport_events_pkey PRIMARY KEY (id);


--
-- TOC entry 6198 (class 2606 OID 16868)
-- Name: ms_sports ms_sports_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_sports
    ADD CONSTRAINT ms_sports_pkey PRIMARY KEY (id);


--
-- TOC entry 6252 (class 2606 OID 19110)
-- Name: ms_team_athletes ms_team_athletes_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_team_athletes
    ADD CONSTRAINT ms_team_athletes_pkey PRIMARY KEY (id);


--
-- TOC entry 6254 (class 2606 OID 19138)
-- Name: ms_team_coachs ms_team_coachs_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_team_coachs
    ADD CONSTRAINT ms_team_coachs_pkey PRIMARY KEY (id);


--
-- TOC entry 6204 (class 2606 OID 18008)
-- Name: ms_teams ms_teams_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_teams
    ADD CONSTRAINT ms_teams_pkey PRIMARY KEY (id);


--
-- TOC entry 6212 (class 2606 OID 18054)
-- Name: ms_ticket_categories ms_ticket_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_ticket_categories
    ADD CONSTRAINT ms_ticket_categories_pkey PRIMARY KEY (id);


--
-- TOC entry 6373 (class 2606 OID 54677)
-- Name: se_chatbot_message se_chatbot_message_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.se_chatbot_message
    ADD CONSTRAINT se_chatbot_message_pkey PRIMARY KEY (id);


--
-- TOC entry 6240 (class 2606 OID 18800)
-- Name: se_chatbot se_chatbot_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.se_chatbot
    ADD CONSTRAINT se_chatbot_pkey PRIMARY KEY (id);


--
-- TOC entry 6360 (class 2606 OID 28701)
-- Name: se_file_embeddings se_file_embeddings_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.se_file_embeddings
    ADD CONSTRAINT se_file_embeddings_pkey PRIMARY KEY (id);


--
-- TOC entry 6280 (class 2606 OID 19623)
-- Name: sr_match_athletes sr_match_athletes_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sr_match_athletes
    ADD CONSTRAINT sr_match_athletes_pkey PRIMARY KEY (id);


--
-- TOC entry 6284 (class 2606 OID 19648)
-- Name: sr_match_participating_referees sr_match_participating_referees_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sr_match_participating_referees
    ADD CONSTRAINT sr_match_participating_referees_pkey PRIMARY KEY (id);


--
-- TOC entry 6297 (class 2606 OID 20701)
-- Name: sr_match_prediction_result sr_match_prediction_result_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sr_match_prediction_result
    ADD CONSTRAINT sr_match_prediction_result_pkey PRIMARY KEY (id);


--
-- TOC entry 6365 (class 2606 OID 37412)
-- Name: sr_match_referee_notes sr_match_referee_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sr_match_referee_notes
    ADD CONSTRAINT sr_match_referee_notes_pkey PRIMARY KEY (id);


--
-- TOC entry 6301 (class 2606 OID 21534)
-- Name: sr_match_result_detail sr_match_result_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sr_match_result_detail
    ADD CONSTRAINT sr_match_result_detail_pkey PRIMARY KEY (id);


--
-- TOC entry 6299 (class 2606 OID 21467)
-- Name: sr_match_result sr_match_result_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sr_match_result
    ADD CONSTRAINT sr_match_result_pkey PRIMARY KEY (id);


--
-- TOC entry 6256 (class 2606 OID 19203)
-- Name: sr_match_schedules sr_match_schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sr_match_schedules
    ADD CONSTRAINT sr_match_schedules_pkey PRIMARY KEY (id);


--
-- TOC entry 6276 (class 2606 OID 19598)
-- Name: sr_match_teams sr_match_teams_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sr_match_teams
    ADD CONSTRAINT sr_match_teams_pkey PRIMARY KEY (id);


--
-- TOC entry 6286 (class 2606 OID 19668)
-- Name: sr_match_volunteer sr_match_volunteer_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sr_match_volunteer
    ADD CONSTRAINT sr_match_volunteer_pkey PRIMARY KEY (id);


--
-- TOC entry 6142 (class 2606 OID 16407)
-- Name: sy_commons sy_commons_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sy_commons
    ADD CONSTRAINT sy_commons_pkey PRIMARY KEY (id);


--
-- TOC entry 6146 (class 2606 OID 16427)
-- Name: sy_document_formatter_current sy_document_formatter_current_formatcode_key; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sy_document_formatter_current
    ADD CONSTRAINT sy_document_formatter_current_formatcode_key UNIQUE (format_code);


--
-- TOC entry 6148 (class 2606 OID 16425)
-- Name: sy_document_formatter_current sy_document_formatter_current_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sy_document_formatter_current
    ADD CONSTRAINT sy_document_formatter_current_pkey PRIMARY KEY (id);


--
-- TOC entry 6150 (class 2606 OID 16447)
-- Name: sy_document_settings sy_document_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sy_document_settings
    ADD CONSTRAINT sy_document_settings_pkey PRIMARY KEY (id);


--
-- TOC entry 6152 (class 2606 OID 16449)
-- Name: sy_document_settings sy_document_settings_transactiontype_key; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sy_document_settings
    ADD CONSTRAINT sy_document_settings_transactiontype_key UNIQUE (transaction_type);


--
-- TOC entry 6311 (class 2606 OID 55525)
-- Name: sy_file_attachments sy_file_attachments_file_key_key; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sy_file_attachments
    ADD CONSTRAINT sy_file_attachments_file_key_key UNIQUE (file_key);


--
-- TOC entry 6313 (class 2606 OID 22100)
-- Name: sy_file_attachments sy_file_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sy_file_attachments
    ADD CONSTRAINT sy_file_attachments_pkey PRIMARY KEY (id);


--
-- TOC entry 6154 (class 2606 OID 16462)
-- Name: sy_function_actions sy_function_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sy_function_actions
    ADD CONSTRAINT sy_function_actions_pkey PRIMARY KEY (id);


--
-- TOC entry 6156 (class 2606 OID 16475)
-- Name: sy_functions sy_functions_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sy_functions
    ADD CONSTRAINT sy_functions_pkey PRIMARY KEY (id);


--
-- TOC entry 6325 (class 2606 OID 22624)
-- Name: sy_mail_queues sy_mail_queues_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sy_mail_queues
    ADD CONSTRAINT sy_mail_queues_pkey PRIMARY KEY (id);


--
-- TOC entry 6158 (class 2606 OID 16488)
-- Name: sy_mailtemplate sy_mailtemplate_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sy_mailtemplate
    ADD CONSTRAINT sy_mailtemplate_pkey PRIMARY KEY (id);


--
-- TOC entry 6160 (class 2606 OID 16504)
-- Name: sy_menu sy_menu_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sy_menu
    ADD CONSTRAINT sy_menu_pkey PRIMARY KEY (id);


--
-- TOC entry 6162 (class 2606 OID 16515)
-- Name: sy_modules sy_modules_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sy_modules
    ADD CONSTRAINT sy_modules_pkey PRIMARY KEY (id);


--
-- TOC entry 6362 (class 2606 OID 37334)
-- Name: sy_notification sy_notification_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sy_notification
    ADD CONSTRAINT sy_notification_pkey PRIMARY KEY (id);


--
-- TOC entry 6244 (class 2606 OID 19010)
-- Name: sy_notification_settings sy_notification_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sy_notification_settings
    ADD CONSTRAINT sy_notification_settings_pkey PRIMARY KEY (id);


--
-- TOC entry 6164 (class 2606 OID 16533)
-- Name: sy_parameters sy_parameters_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sy_parameters
    ADD CONSTRAINT sy_parameters_pkey PRIMARY KEY (id);


--
-- TOC entry 6168 (class 2606 OID 16554)
-- Name: sy_report_settings sy_report_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sy_report_settings
    ADD CONSTRAINT sy_report_settings_pkey PRIMARY KEY (id);


--
-- TOC entry 6170 (class 2606 OID 16568)
-- Name: sy_res_language sy_res_language_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sy_res_language
    ADD CONSTRAINT sy_res_language_pkey PRIMARY KEY (id);


--
-- TOC entry 6381 (class 2606 OID 56456)
-- Name: sy_res_resourcecontrols_compares sy_res_resourcecontrols_compares_resource_name_key; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sy_res_resourcecontrols_compares
    ADD CONSTRAINT sy_res_resourcecontrols_compares_resource_name_key UNIQUE (resource_name);


--
-- TOC entry 6172 (class 2606 OID 16580)
-- Name: sy_res_resourcecontrols sy_res_resourcecontrols_name_key; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sy_res_resourcecontrols
    ADD CONSTRAINT sy_res_resourcecontrols_name_key UNIQUE (name);


--
-- TOC entry 6174 (class 2606 OID 16578)
-- Name: sy_res_resourcecontrols sy_res_resourcecontrols_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sy_res_resourcecontrols
    ADD CONSTRAINT sy_res_resourcecontrols_pkey PRIMARY KEY (controlid);


--
-- TOC entry 6176 (class 2606 OID 16592)
-- Name: sy_res_resourcecontrols_translated sy_res_resourcecontrols_translated_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sy_res_resourcecontrols_translated
    ADD CONSTRAINT sy_res_resourcecontrols_translated_pkey PRIMARY KEY (id);


--
-- TOC entry 6180 (class 2606 OID 16606)
-- Name: sy_reset_password sy_resetpassword_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sy_reset_password
    ADD CONSTRAINT sy_resetpassword_pkey PRIMARY KEY (id);


--
-- TOC entry 6182 (class 2606 OID 16620)
-- Name: sy_role_details sy_role_details_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sy_role_details
    ADD CONSTRAINT sy_role_details_pkey PRIMARY KEY (id);


--
-- TOC entry 6184 (class 2606 OID 16640)
-- Name: sy_roles sy_roles_code_key; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sy_roles
    ADD CONSTRAINT sy_roles_code_key UNIQUE (code);


--
-- TOC entry 6186 (class 2606 OID 16638)
-- Name: sy_roles sy_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sy_roles
    ADD CONSTRAINT sy_roles_pkey PRIMARY KEY (id);


--
-- TOC entry 6188 (class 2606 OID 16659)
-- Name: sy_theme_settings sy_theme_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sy_theme_settings
    ADD CONSTRAINT sy_theme_settings_pkey PRIMARY KEY (id);


--
-- TOC entry 6190 (class 2606 OID 16669)
-- Name: sy_user_quick_access sy_user_quick_access_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sy_user_quick_access
    ADD CONSTRAINT sy_user_quick_access_pkey PRIMARY KEY (id);


--
-- TOC entry 6192 (class 2606 OID 16683)
-- Name: sy_user_roles sy_user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sy_user_roles
    ADD CONSTRAINT sy_user_roles_pkey PRIMARY KEY (id);


--
-- TOC entry 6230 (class 2606 OID 18702)
-- Name: sy_user_send_otps sy_user_send_otps_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sy_user_send_otps
    ADD CONSTRAINT sy_user_send_otps_pkey PRIMARY KEY (id);


--
-- TOC entry 6194 (class 2606 OID 16702)
-- Name: sy_users sy_users_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sy_users
    ADD CONSTRAINT sy_users_pkey PRIMARY KEY (id);


--
-- TOC entry 6196 (class 2606 OID 16704)
-- Name: sy_users sy_users_referenceobjectcode_key; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sy_users
    ADD CONSTRAINT sy_users_referenceobjectcode_key UNIQUE (referenceobjectcode);


--
-- TOC entry 6264 (class 2606 OID 19279)
-- Name: ta_task_assignment_detail ta_task_assignment_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ta_task_assignment_detail
    ADD CONSTRAINT ta_task_assignment_detail_pkey PRIMARY KEY (id);


--
-- TOC entry 6260 (class 2606 OID 19244)
-- Name: ta_task_assignment ta_task_assignment_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ta_task_assignment
    ADD CONSTRAINT ta_task_assignment_pkey PRIMARY KEY (id);


--
-- TOC entry 6270 (class 2606 OID 19385)
-- Name: ti_ticket_detail ti_ticket_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ti_ticket_detail
    ADD CONSTRAINT ti_ticket_detail_pkey PRIMARY KEY (id);


--
-- TOC entry 6266 (class 2606 OID 19348)
-- Name: ti_ticket_price ti_ticket_price_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ti_ticket_price
    ADD CONSTRAINT ti_ticket_price_pkey PRIMARY KEY (id);


--
-- TOC entry 6303 (class 2606 OID 21640)
-- Name: ti_ticket_sold ti_ticket_sold_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ti_ticket_sold
    ADD CONSTRAINT ti_ticket_sold_pkey PRIMARY KEY (id);


--
-- TOC entry 6178 (class 2606 OID 16594)
-- Name: sy_res_resourcecontrols_translated uc_res_resourcecontrols_translated; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sy_res_resourcecontrols_translated
    ADD CONSTRAINT uc_res_resourcecontrols_translated UNIQUE (languagecode, languagename);


--
-- TOC entry 6282 (class 2606 OID 23907)
-- Name: sr_match_athletes uc_sr_match_athletes; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sr_match_athletes
    ADD CONSTRAINT uc_sr_match_athletes UNIQUE (match_code, team_code, emp_athlete_code);


--
-- TOC entry 6144 (class 2606 OID 16409)
-- Name: sy_commons uc_typye_fieldname_sy_commons; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sy_commons
    ADD CONSTRAINT uc_typye_fieldname_sy_commons UNIQUE (type, field_name);


--
-- TOC entry 6166 (class 2606 OID 16535)
-- Name: sy_parameters uc_unique_sy_parameters; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sy_parameters
    ADD CONSTRAINT uc_unique_sy_parameters UNIQUE (type, name);


--
-- TOC entry 6319 (class 2606 OID 22484)
-- Name: io_inout_card uq_io_inout_card_code; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.io_inout_card
    ADD CONSTRAINT uq_io_inout_card_code UNIQUE (card_code);


--
-- TOC entry 6278 (class 2606 OID 30739)
-- Name: sr_match_teams uq_match_code_team_code; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sr_match_teams
    ADD CONSTRAINT uq_match_code_team_code UNIQUE (match_code, team_code);


--
-- TOC entry 6218 (class 2606 OID 18216)
-- Name: ms_background uq_ms_background_code; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_background
    ADD CONSTRAINT uq_ms_background_code UNIQUE (background_code);


--
-- TOC entry 6210 (class 2606 OID 18033)
-- Name: ms_competition_events uq_ms_competition_events_code; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_competition_events
    ADD CONSTRAINT uq_ms_competition_events_code UNIQUE (competition_code);


--
-- TOC entry 6379 (class 2606 OID 55470)
-- Name: ms_contents uq_ms_contents_content_code; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_contents
    ADD CONSTRAINT uq_ms_contents_content_code UNIQUE (content_code);


--
-- TOC entry 6238 (class 2606 OID 18778)
-- Name: ms_discounts uq_ms_discounts_code; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_discounts
    ADD CONSTRAINT uq_ms_discounts_code UNIQUE (discount_code);


--
-- TOC entry 6234 (class 2606 OID 18736)
-- Name: ms_employees uq_ms_employees_employee_code; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_employees
    ADD CONSTRAINT uq_ms_employees_employee_code UNIQUE (employee_code);


--
-- TOC entry 6226 (class 2606 OID 18543)
-- Name: ms_locations uq_ms_locations_code; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_locations
    ADD CONSTRAINT uq_ms_locations_code UNIQUE (location_code);


--
-- TOC entry 6222 (class 2606 OID 18246)
-- Name: ms_sponsors uq_ms_sponsors_code; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_sponsors
    ADD CONSTRAINT uq_ms_sponsors_code UNIQUE (sponsor_code);


--
-- TOC entry 6200 (class 2606 OID 16870)
-- Name: ms_sports uq_ms_sports_sportcode; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_sports
    ADD CONSTRAINT uq_ms_sports_sportcode UNIQUE (sport_code);


--
-- TOC entry 6206 (class 2606 OID 18010)
-- Name: ms_teams uq_ms_teams_team_code; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_teams
    ADD CONSTRAINT uq_ms_teams_team_code UNIQUE (team_code);


--
-- TOC entry 6214 (class 2606 OID 18056)
-- Name: ms_ticket_categories uq_ms_ticket_categories_code; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_ticket_categories
    ADD CONSTRAINT uq_ms_ticket_categories_code UNIQUE (category_code);


--
-- TOC entry 6242 (class 2606 OID 18802)
-- Name: se_chatbot uq_se_chatbot_document_code; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.se_chatbot
    ADD CONSTRAINT uq_se_chatbot_document_code UNIQUE (document_code);


--
-- TOC entry 6258 (class 2606 OID 19205)
-- Name: sr_match_schedules uq_sr_match_schedules_match_code; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sr_match_schedules
    ADD CONSTRAINT uq_sr_match_schedules_match_code UNIQUE (match_code);


--
-- TOC entry 6262 (class 2606 OID 19246)
-- Name: ta_task_assignment uq_ta_task_assignment_task_code; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ta_task_assignment
    ADD CONSTRAINT uq_ta_task_assignment_task_code UNIQUE (task_code);


--
-- TOC entry 6268 (class 2606 OID 19350)
-- Name: ti_ticket_price uq_ti_ticket_price_ticket_code; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ti_ticket_price
    ADD CONSTRAINT uq_ti_ticket_price_ticket_code UNIQUE (ticket_code);


--
-- TOC entry 6305 (class 2606 OID 21642)
-- Name: ti_ticket_sold uq_ti_ticket_sold_auto; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ti_ticket_sold
    ADD CONSTRAINT uq_ti_ticket_sold_auto UNIQUE (ticket_auto_code);


--
-- TOC entry 6367 (class 2606 OID 39413)
-- Name: vnpay_payment_histories vnpay_payment_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.vnpay_payment_histories
    ADD CONSTRAINT vnpay_payment_histories_pkey PRIMARY KEY (id);


--
-- TOC entry 6330 (class 1259 OID 24414)
-- Name: ix_hangfire_counter_expireat; Type: INDEX; Schema: hangfire; Owner: sportevent
--

CREATE INDEX ix_hangfire_counter_expireat ON hangfire.counter USING btree (expireat);


--
-- TOC entry 6331 (class 1259 OID 24575)
-- Name: ix_hangfire_counter_key; Type: INDEX; Schema: hangfire; Owner: sportevent
--

CREATE INDEX ix_hangfire_counter_key ON hangfire.counter USING btree (key);


--
-- TOC entry 6336 (class 1259 OID 24585)
-- Name: ix_hangfire_job_statename; Type: INDEX; Schema: hangfire; Owner: sportevent
--

CREATE INDEX ix_hangfire_job_statename ON hangfire.job USING btree (statename);


--
-- TOC entry 6354 (class 1259 OID 24593)
-- Name: ix_hangfire_jobparameter_jobidandname; Type: INDEX; Schema: hangfire; Owner: sportevent
--

CREATE INDEX ix_hangfire_jobparameter_jobidandname ON hangfire.jobparameter USING btree (jobid, name);


--
-- TOC entry 6342 (class 1259 OID 24544)
-- Name: ix_hangfire_jobqueue_jobidandqueue; Type: INDEX; Schema: hangfire; Owner: sportevent
--

CREATE INDEX ix_hangfire_jobqueue_jobidandqueue ON hangfire.jobqueue USING btree (jobid, queue);


--
-- TOC entry 6343 (class 1259 OID 24428)
-- Name: ix_hangfire_jobqueue_queueandfetchedat; Type: INDEX; Schema: hangfire; Owner: sportevent
--

CREATE INDEX ix_hangfire_jobqueue_queueandfetchedat ON hangfire.jobqueue USING btree (queue, fetchedat);


--
-- TOC entry 6339 (class 1259 OID 24493)
-- Name: ix_hangfire_state_jobid; Type: INDEX; Schema: hangfire; Owner: sportevent
--

CREATE INDEX ix_hangfire_state_jobid ON hangfire.state USING btree (jobid);


--
-- TOC entry 6371 (class 1259 OID 54678)
-- Name: idx_se_chatbot_message_room_id; Type: INDEX; Schema: public; Owner: sportevent
--

CREATE INDEX idx_se_chatbot_message_room_id ON public.se_chatbot_message USING btree (room_id);


--
-- TOC entry 6368 (class 1259 OID 44594)
-- Name: ix_acn_coach; Type: INDEX; Schema: public; Owner: sportevent
--

CREATE INDEX ix_acn_coach ON public.ms_athlete_coach_notes USING btree (emp_coach_code);


--
-- TOC entry 6363 (class 1259 OID 37438)
-- Name: ix_mrn_referee; Type: INDEX; Schema: public; Owner: sportevent
--

CREATE INDEX ix_mrn_referee ON public.sr_match_referee_notes USING btree (emp_referee_code);


--
-- TOC entry 6291 (class 1259 OID 19765)
-- Name: ix_ms_competition_team_list_competition; Type: INDEX; Schema: public; Owner: sportevent
--

CREATE INDEX ix_ms_competition_team_list_competition ON public.ms_competition_team_list USING btree (competition_code);


--
-- TOC entry 6292 (class 1259 OID 19766)
-- Name: ix_ms_competition_team_list_team; Type: INDEX; Schema: public; Owner: sportevent
--

CREATE INDEX ix_ms_competition_team_list_team ON public.ms_competition_team_list USING btree (team_code);


--
-- TOC entry 6287 (class 1259 OID 19735)
-- Name: ix_ms_sport_events_competition; Type: INDEX; Schema: public; Owner: sportevent
--

CREATE INDEX ix_ms_sport_events_competition ON public.ms_sport_events USING btree (competition_code);


--
-- TOC entry 6288 (class 1259 OID 19736)
-- Name: ix_ms_sport_events_location; Type: INDEX; Schema: public; Owner: sportevent
--

CREATE INDEX ix_ms_sport_events_location ON public.ms_sport_events USING btree (location_code);


--
-- TOC entry 6295 (class 1259 OID 19764)
-- Name: ux_ms_competition_team_list; Type: INDEX; Schema: public; Owner: sportevent
--

CREATE UNIQUE INDEX ux_ms_competition_team_list ON public.ms_competition_team_list USING btree (competition_code, team_code);


--
-- TOC entry 6420 (class 2606 OID 24520)
-- Name: jobparameter jobparameter_jobid_fkey; Type: FK CONSTRAINT; Schema: hangfire; Owner: sportevent
--

ALTER TABLE ONLY hangfire.jobparameter
    ADD CONSTRAINT jobparameter_jobid_fkey FOREIGN KEY (jobid) REFERENCES hangfire.job(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 6419 (class 2606 OID 24495)
-- Name: state state_jobid_fkey; Type: FK CONSTRAINT; Schema: hangfire; Owner: sportevent
--

ALTER TABLE ONLY hangfire.state
    ADD CONSTRAINT state_jobid_fkey FOREIGN KEY (jobid) REFERENCES hangfire.job(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 6385 (class 2606 OID 19055)
-- Name: ms_achievement_history fk_achievement_history_employee; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_achievement_history
    ADD CONSTRAINT fk_achievement_history_employee FOREIGN KEY (employee_code) REFERENCES public.ms_employees(employee_code);


--
-- TOC entry 6425 (class 2606 OID 44584)
-- Name: ms_athlete_coach_notes fk_acn_athlete; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_athlete_coach_notes
    ADD CONSTRAINT fk_acn_athlete FOREIGN KEY (emp_athlete_code) REFERENCES public.ms_employees(employee_code);


--
-- TOC entry 6426 (class 2606 OID 44589)
-- Name: ms_athlete_coach_notes fk_acn_coach; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_athlete_coach_notes
    ADD CONSTRAINT fk_acn_coach FOREIGN KEY (emp_coach_code) REFERENCES public.ms_employees(employee_code);


--
-- TOC entry 6427 (class 2606 OID 44579)
-- Name: ms_athlete_coach_notes fk_acn_team; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_athlete_coach_notes
    ADD CONSTRAINT fk_acn_team FOREIGN KEY (team_code) REFERENCES public.ms_teams(team_code);


--
-- TOC entry 6384 (class 2606 OID 19030)
-- Name: ms_injury_history fk_injury_history_employee; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_injury_history
    ADD CONSTRAINT fk_injury_history_employee FOREIGN KEY (employee_code) REFERENCES public.ms_employees(employee_code);


--
-- TOC entry 6417 (class 2606 OID 22458)
-- Name: io_inout_barcode_history fk_io_inout_barcode_history_location; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.io_inout_barcode_history
    ADD CONSTRAINT fk_io_inout_barcode_history_location FOREIGN KEY (location_code) REFERENCES public.ms_locations(location_code);


--
-- TOC entry 6418 (class 2606 OID 53527)
-- Name: io_inout_card_detail fk_io_inout_card_detail_card; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.io_inout_card_detail
    ADD CONSTRAINT fk_io_inout_card_detail_card FOREIGN KEY (card_code) REFERENCES public.io_inout_card(card_code) ON UPDATE CASCADE;


--
-- TOC entry 6391 (class 2606 OID 19206)
-- Name: sr_match_schedules fk_match_schedules_competition; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sr_match_schedules
    ADD CONSTRAINT fk_match_schedules_competition FOREIGN KEY (competition_code) REFERENCES public.ms_competition_events(competition_code);


--
-- TOC entry 6392 (class 2606 OID 19211)
-- Name: sr_match_schedules fk_match_schedules_location; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sr_match_schedules
    ADD CONSTRAINT fk_match_schedules_location FOREIGN KEY (location_code) REFERENCES public.ms_locations(location_code);


--
-- TOC entry 6393 (class 2606 OID 19216)
-- Name: sr_match_schedules fk_match_schedules_sport; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sr_match_schedules
    ADD CONSTRAINT fk_match_schedules_sport FOREIGN KEY (sport_code) REFERENCES public.ms_sports(sport_code);


--
-- TOC entry 6421 (class 2606 OID 37428)
-- Name: sr_match_referee_notes fk_mrn_athlete; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sr_match_referee_notes
    ADD CONSTRAINT fk_mrn_athlete FOREIGN KEY (emp_athlete_code) REFERENCES public.ms_employees(employee_code);


--
-- TOC entry 6422 (class 2606 OID 37418)
-- Name: sr_match_referee_notes fk_mrn_match; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sr_match_referee_notes
    ADD CONSTRAINT fk_mrn_match FOREIGN KEY (match_id) REFERENCES public.sr_match_schedules(id);


--
-- TOC entry 6423 (class 2606 OID 37433)
-- Name: sr_match_referee_notes fk_mrn_referee; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sr_match_referee_notes
    ADD CONSTRAINT fk_mrn_referee FOREIGN KEY (emp_referee_code) REFERENCES public.ms_employees(employee_code);


--
-- TOC entry 6424 (class 2606 OID 37423)
-- Name: sr_match_referee_notes fk_mrn_team; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sr_match_referee_notes
    ADD CONSTRAINT fk_mrn_team FOREIGN KEY (team_code) REFERENCES public.ms_teams(team_code);


--
-- TOC entry 6402 (class 2606 OID 19495)
-- Name: ms_certificates fk_ms_certificates_employee; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_certificates
    ADD CONSTRAINT fk_ms_certificates_employee FOREIGN KEY (employee_code) REFERENCES public.ms_employees(employee_code);


--
-- TOC entry 6412 (class 2606 OID 19767)
-- Name: ms_competition_team_list fk_ms_competition_team_list_competition; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_competition_team_list
    ADD CONSTRAINT fk_ms_competition_team_list_competition FOREIGN KEY (competition_code) REFERENCES public.ms_competition_events(competition_code);


--
-- TOC entry 6413 (class 2606 OID 19772)
-- Name: ms_competition_team_list fk_ms_competition_team_list_team; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_competition_team_list
    ADD CONSTRAINT fk_ms_competition_team_list_team FOREIGN KEY (team_code) REFERENCES public.ms_teams(team_code);


--
-- TOC entry 6428 (class 2606 OID 55471)
-- Name: ms_contents fk_ms_contents_sport; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_contents
    ADD CONSTRAINT fk_ms_contents_sport FOREIGN KEY (sport_code) REFERENCES public.ms_sports(sport_code);


--
-- TOC entry 6403 (class 2606 OID 19521)
-- Name: ms_experiences fk_ms_experiences_employee; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_experiences
    ADD CONSTRAINT fk_ms_experiences_employee FOREIGN KEY (employee_code) REFERENCES public.ms_employees(employee_code);


--
-- TOC entry 6383 (class 2606 OID 18565)
-- Name: ms_location_detail fk_ms_location_detail_location; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_location_detail
    ADD CONSTRAINT fk_ms_location_detail_location FOREIGN KEY (location_code) REFERENCES public.ms_locations(location_code);


--
-- TOC entry 6410 (class 2606 OID 19737)
-- Name: ms_sport_events fk_ms_sport_events_competition; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_sport_events
    ADD CONSTRAINT fk_ms_sport_events_competition FOREIGN KEY (competition_code) REFERENCES public.ms_competition_events(competition_code);


--
-- TOC entry 6411 (class 2606 OID 19742)
-- Name: ms_sport_events fk_ms_sport_events_location; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_sport_events
    ADD CONSTRAINT fk_ms_sport_events_location FOREIGN KEY (location_code) REFERENCES public.ms_locations(location_code);


--
-- TOC entry 6382 (class 2606 OID 18057)
-- Name: ms_ticket_categories fk_ms_ticket_categories_competition; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_ticket_categories
    ADD CONSTRAINT fk_ms_ticket_categories_competition FOREIGN KEY (competition_code) REFERENCES public.ms_competition_events(competition_code);


--
-- TOC entry 6406 (class 2606 OID 19624)
-- Name: sr_match_athletes fk_sr_match_athletes_employee; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sr_match_athletes
    ADD CONSTRAINT fk_sr_match_athletes_employee FOREIGN KEY (emp_athlete_code) REFERENCES public.ms_employees(employee_code);


--
-- TOC entry 6407 (class 2606 OID 53537)
-- Name: sr_match_athletes fk_sr_match_athletes_match; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sr_match_athletes
    ADD CONSTRAINT fk_sr_match_athletes_match FOREIGN KEY (match_code) REFERENCES public.sr_match_schedules(match_code) ON UPDATE CASCADE;


--
-- TOC entry 6414 (class 2606 OID 53552)
-- Name: sr_match_prediction_result fk_sr_match_prediction_result; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sr_match_prediction_result
    ADD CONSTRAINT fk_sr_match_prediction_result FOREIGN KEY (match_code) REFERENCES public.sr_match_schedules(match_code) ON UPDATE CASCADE;


--
-- TOC entry 6408 (class 2606 OID 53542)
-- Name: sr_match_participating_referees fk_sr_match_referees_match; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sr_match_participating_referees
    ADD CONSTRAINT fk_sr_match_referees_match FOREIGN KEY (match_code) REFERENCES public.sr_match_schedules(match_code) ON UPDATE CASCADE;


--
-- TOC entry 6415 (class 2606 OID 21535)
-- Name: sr_match_result_detail fk_sr_match_result_detail_header; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sr_match_result_detail
    ADD CONSTRAINT fk_sr_match_result_detail_header FOREIGN KEY (match_result_id) REFERENCES public.sr_match_result(id) ON DELETE CASCADE;


--
-- TOC entry 6404 (class 2606 OID 53532)
-- Name: sr_match_teams fk_sr_match_teams_match; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sr_match_teams
    ADD CONSTRAINT fk_sr_match_teams_match FOREIGN KEY (match_code) REFERENCES public.sr_match_schedules(match_code) ON UPDATE CASCADE;


--
-- TOC entry 6405 (class 2606 OID 19604)
-- Name: sr_match_teams fk_sr_match_teams_team; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sr_match_teams
    ADD CONSTRAINT fk_sr_match_teams_team FOREIGN KEY (team_code) REFERENCES public.ms_teams(team_code);


--
-- TOC entry 6409 (class 2606 OID 53547)
-- Name: sr_match_volunteer fk_sr_match_volunteer_match; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.sr_match_volunteer
    ADD CONSTRAINT fk_sr_match_volunteer_match FOREIGN KEY (match_code) REFERENCES public.sr_match_schedules(match_code) ON UPDATE CASCADE;


--
-- TOC entry 6394 (class 2606 OID 19247)
-- Name: ta_task_assignment fk_task_assignment_competition; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ta_task_assignment
    ADD CONSTRAINT fk_task_assignment_competition FOREIGN KEY (competition_code) REFERENCES public.ms_competition_events(competition_code);


--
-- TOC entry 6396 (class 2606 OID 19285)
-- Name: ta_task_assignment_detail fk_task_assignment_detail_employee; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ta_task_assignment_detail
    ADD CONSTRAINT fk_task_assignment_detail_employee FOREIGN KEY (person_in_charge) REFERENCES public.ms_employees(employee_code);


--
-- TOC entry 6397 (class 2606 OID 53522)
-- Name: ta_task_assignment_detail fk_task_assignment_detail_task; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ta_task_assignment_detail
    ADD CONSTRAINT fk_task_assignment_detail_task FOREIGN KEY (task_code) REFERENCES public.ta_task_assignment(task_code) ON UPDATE CASCADE;


--
-- TOC entry 6395 (class 2606 OID 53557)
-- Name: ta_task_assignment fk_task_assignment_match; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ta_task_assignment
    ADD CONSTRAINT fk_task_assignment_match FOREIGN KEY (match_code) REFERENCES public.sr_match_schedules(match_code) ON UPDATE CASCADE;


--
-- TOC entry 6387 (class 2606 OID 19111)
-- Name: ms_team_athletes fk_team_athletes_employee; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_team_athletes
    ADD CONSTRAINT fk_team_athletes_employee FOREIGN KEY (emp_athlete_code) REFERENCES public.ms_employees(employee_code);


--
-- TOC entry 6388 (class 2606 OID 19116)
-- Name: ms_team_athletes fk_team_athletes_team; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_team_athletes
    ADD CONSTRAINT fk_team_athletes_team FOREIGN KEY (team_code) REFERENCES public.ms_teams(team_code);


--
-- TOC entry 6389 (class 2606 OID 19139)
-- Name: ms_team_coachs fk_team_coachs_employee; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_team_coachs
    ADD CONSTRAINT fk_team_coachs_employee FOREIGN KEY (emp_coach_code) REFERENCES public.ms_employees(employee_code);


--
-- TOC entry 6390 (class 2606 OID 19144)
-- Name: ms_team_coachs fk_team_coachs_team; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_team_coachs
    ADD CONSTRAINT fk_team_coachs_team FOREIGN KEY (team_code) REFERENCES public.ms_teams(team_code);


--
-- TOC entry 6400 (class 2606 OID 19391)
-- Name: ti_ticket_detail fk_ti_ticket_detail_category; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ti_ticket_detail
    ADD CONSTRAINT fk_ti_ticket_detail_category FOREIGN KEY (category_code) REFERENCES public.ms_ticket_categories(category_code);


--
-- TOC entry 6401 (class 2606 OID 53493)
-- Name: ti_ticket_detail fk_ti_ticket_detail_ticket; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ti_ticket_detail
    ADD CONSTRAINT fk_ti_ticket_detail_ticket FOREIGN KEY (ticket_code) REFERENCES public.ti_ticket_price(ticket_code) ON UPDATE CASCADE;


--
-- TOC entry 6416 (class 2606 OID 21643)
-- Name: ti_ticket_sold fk_ti_ticket_sold_detail; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ti_ticket_sold
    ADD CONSTRAINT fk_ti_ticket_sold_detail FOREIGN KEY (tickets_detail_id) REFERENCES public.ti_ticket_detail(id);


--
-- TOC entry 6398 (class 2606 OID 19351)
-- Name: ti_ticket_price fk_ticket_price_competition; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ti_ticket_price
    ADD CONSTRAINT fk_ticket_price_competition FOREIGN KEY (competition_code) REFERENCES public.ms_competition_events(competition_code);


--
-- TOC entry 6399 (class 2606 OID 53562)
-- Name: ti_ticket_price fk_ticket_price_match; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ti_ticket_price
    ADD CONSTRAINT fk_ticket_price_match FOREIGN KEY (match_code) REFERENCES public.sr_match_schedules(match_code) ON UPDATE CASCADE;


--
-- TOC entry 6386 (class 2606 OID 19080)
-- Name: ms_athlete_violation_history fk_violation_history_employee; Type: FK CONSTRAINT; Schema: public; Owner: sportevent
--

ALTER TABLE ONLY public.ms_athlete_violation_history
    ADD CONSTRAINT fk_violation_history_employee FOREIGN KEY (employee_code) REFERENCES public.ms_employees(employee_code);


--
-- TOC entry 6583 (class 0 OID 0)
-- Dependencies: 3181
-- Name: FOREIGN SERVER log_server; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON FOREIGN SERVER log_server TO sportevent;


-- Completed on 2026-05-26 09:16:42

--
-- PostgreSQL database dump complete
--

\unrestrict Na16n1eba87EdGvkasqrcZeJAAvw359VgAqk5pBYY5AbdP1PJTHXdcp0ZAW5vmc

