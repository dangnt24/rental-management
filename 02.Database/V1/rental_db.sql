--
-- PostgreSQL database dump
--

\restrict xk6wQ4aX0OWI7c8oZKRmug8h8l5fDbX8VpoJNB3FYrn1FUuyC0xIVNwek8GyLAR

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

-- Started on 2026-06-07 11:18:31

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
-- TOC entry 291 (class 1255 OID 17770)
-- Name: sy_fn_check_exists(text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sy_fn_check_exists(p_table_name text, p_column_name text, p_value text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$
DECLARE
    v_exists BOOLEAN;
    v_sql TEXT;
BEGIN
    -- Sử dụng format để chống SQL Injection cho tên bảng/cột
    v_sql := format('SELECT EXISTS (SELECT 1 FROM %I WHERE %I = $1)', p_table_name, p_column_name);
    EXECUTE v_sql INTO v_exists USING p_value;
    RETURN v_exists;
END;
$_$;


ALTER FUNCTION public.sy_fn_check_exists(p_table_name text, p_column_name text, p_value text) OWNER TO postgres;

--
-- TOC entry 293 (class 1255 OID 17772)
-- Name: sy_fn_check_is_used(text, anyelement); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sy_fn_check_is_used(p_table_name text, p_id_value anyelement) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$
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
$_$;


ALTER FUNCTION public.sy_fn_check_is_used(p_table_name text, p_id_value anyelement) OWNER TO postgres;

--
-- TOC entry 292 (class 1255 OID 17771)
-- Name: sy_fn_get_list_data(text, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sy_fn_get_list_data(p_table_name text, p_limit integer DEFAULT 100, p_offset integer DEFAULT 0) RETURNS SETOF json
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_sql TEXT;
BEGIN
    v_sql := format('SELECT row_to_json(t) FROM (SELECT * FROM %I LIMIT %L OFFSET %L) t', 
                    p_table_name, p_limit, p_offset);
    RETURN QUERY EXECUTE v_sql;
END;
$$;


ALTER FUNCTION public.sy_fn_get_list_data(p_table_name text, p_limit integer, p_offset integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 231 (class 1259 OID 17257)
-- Name: commoncategories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.commoncategories (
    id integer NOT NULL,
    code character varying(100) NOT NULL
);


ALTER TABLE public.commoncategories OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 17256)
-- Name: commoncategories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.commoncategories ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.commoncategories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 235 (class 1259 OID 17274)
-- Name: commontranslations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.commontranslations (
    id integer NOT NULL,
    commonvalueid integer,
    languagecode character varying(10),
    value character varying(255)
);


ALTER TABLE public.commontranslations OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 17273)
-- Name: commontranslations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.commontranslations ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.commontranslations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 233 (class 1259 OID 17267)
-- Name: commonvalues; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.commonvalues (
    id integer NOT NULL,
    categoryid integer,
    code character varying(100),
    value character varying(255),
    orderindex integer
);


ALTER TABLE public.commonvalues OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 17266)
-- Name: commonvalues_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.commonvalues ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.commonvalues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 247 (class 1259 OID 17326)
-- Name: contracts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.contracts (
    id integer NOT NULL,
    roomid integer,
    tenantid integer,
    startdate date,
    enddate date,
    deposit numeric(12,2),
    rentprice numeric(12,2),
    statuscode character varying(50)
);


ALTER TABLE public.contracts OWNER TO postgres;

--
-- TOC entry 246 (class 1259 OID 17325)
-- Name: contracts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.contracts ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.contracts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 251 (class 1259 OID 17340)
-- Name: feetypes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.feetypes (
    id integer NOT NULL,
    code character varying(50),
    name character varying(100),
    calculationtype character varying(50),
    unitprice numeric(12,2)
);


ALTER TABLE public.feetypes OWNER TO postgres;

--
-- TOC entry 250 (class 1259 OID 17339)
-- Name: feetypes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.feetypes ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.feetypes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 255 (class 1259 OID 17355)
-- Name: invoicedetails; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.invoicedetails (
    id integer NOT NULL,
    invoiceid integer,
    feetypeid integer,
    quantity numeric(12,2),
    unitprice numeric(12,2),
    amount numeric(12,2)
);


ALTER TABLE public.invoicedetails OWNER TO postgres;

--
-- TOC entry 254 (class 1259 OID 17354)
-- Name: invoicedetails_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.invoicedetails ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.invoicedetails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 253 (class 1259 OID 17347)
-- Name: invoices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.invoices (
    id integer NOT NULL,
    roomid integer,
    contractid integer,
    month character varying(7),
    totalamount numeric(12,2),
    status character varying(50),
    createdat timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    paidat timestamp without time zone
);


ALTER TABLE public.invoices OWNER TO postgres;

--
-- TOC entry 252 (class 1259 OID 17346)
-- Name: invoices_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.invoices ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.invoices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 237 (class 1259 OID 17281)
-- Name: languages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.languages (
    id integer NOT NULL,
    code character varying(10),
    name character varying(50)
);


ALTER TABLE public.languages OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 17280)
-- Name: languages_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.languages ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.languages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 259 (class 1259 OID 17369)
-- Name: maintenances; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.maintenances (
    id integer NOT NULL,
    roomid integer,
    description text,
    statuscode character varying(50),
    cost numeric(12,2),
    createdat timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    resolvedat timestamp without time zone
);


ALTER TABLE public.maintenances OWNER TO postgres;

--
-- TOC entry 258 (class 1259 OID 17368)
-- Name: maintenances_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.maintenances ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.maintenances_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 229 (class 1259 OID 17249)
-- Name: menupermissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.menupermissions (
    menuid integer NOT NULL,
    permissionid integer NOT NULL
);


ALTER TABLE public.menupermissions OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 17243)
-- Name: menus; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.menus (
    id integer NOT NULL,
    name character varying(100),
    path character varying(255),
    icon character varying(100),
    parentid integer,
    orderindex integer
);


ALTER TABLE public.menus OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 17242)
-- Name: menus_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.menus ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.menus_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 271 (class 1259 OID 17565)
-- Name: ms_branches; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ms_branches (
    id integer NOT NULL,
    branch_name text NOT NULL,
    address text,
    description text,
    is_active boolean DEFAULT true,
    created_by character varying(50),
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(50),
    updated_date timestamp without time zone
);


ALTER TABLE public.ms_branches OWNER TO postgres;

--
-- TOC entry 270 (class 1259 OID 17564)
-- Name: ms_branches_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.ms_branches ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.ms_branches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 277 (class 1259 OID 17613)
-- Name: ms_fee_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ms_fee_types (
    id integer NOT NULL,
    branch_id integer,
    fee_name text NOT NULL,
    unit_price numeric(15,2) NOT NULL,
    calc_method character varying(20),
    is_system boolean DEFAULT false,
    is_active boolean DEFAULT true
);


ALTER TABLE public.ms_fee_types OWNER TO postgres;

--
-- TOC entry 276 (class 1259 OID 17612)
-- Name: ms_fee_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.ms_fee_types ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.ms_fee_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 273 (class 1259 OID 17577)
-- Name: ms_rooms; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ms_rooms (
    id integer NOT NULL,
    branch_id integer,
    room_name character varying(50) NOT NULL,
    price numeric(15,2) DEFAULT 0,
    max_occupants integer DEFAULT 1,
    status_code character varying(50),
    description text,
    created_by character varying(50),
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(50),
    updated_date timestamp without time zone,
    data_row_version integer DEFAULT 1
);


ALTER TABLE public.ms_rooms OWNER TO postgres;

--
-- TOC entry 272 (class 1259 OID 17576)
-- Name: ms_rooms_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.ms_rooms ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.ms_rooms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 275 (class 1259 OID 17596)
-- Name: ms_tenants; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ms_tenants (
    id integer NOT NULL,
    user_id integer,
    full_name text NOT NULL,
    identity_number character varying(20),
    phone character varying(20),
    email character varying(100),
    dob date,
    gender_code character varying(20),
    hometown text,
    address_temporary text,
    is_representative boolean DEFAULT false,
    status_code character varying(50),
    created_by character varying(50),
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(50),
    updated_date timestamp without time zone
);


ALTER TABLE public.ms_tenants OWNER TO postgres;

--
-- TOC entry 274 (class 1259 OID 17595)
-- Name: ms_tenants_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.ms_tenants ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.ms_tenants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 261 (class 1259 OID 17379)
-- Name: notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifications (
    id integer NOT NULL,
    title character varying(255),
    content text,
    userid integer,
    isread boolean DEFAULT false,
    createdat timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.notifications OWNER TO postgres;

--
-- TOC entry 260 (class 1259 OID 17378)
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.notifications ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 257 (class 1259 OID 17362)
-- Name: payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payments (
    id integer NOT NULL,
    invoiceid integer,
    amount numeric(12,2),
    paymentdate timestamp without time zone,
    method character varying(50)
);


ALTER TABLE public.payments OWNER TO postgres;

--
-- TOC entry 256 (class 1259 OID 17361)
-- Name: payments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.payments ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 225 (class 1259 OID 17226)
-- Name: permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.permissions (
    id integer NOT NULL,
    code character varying(100) NOT NULL,
    name character varying(255)
);


ALTER TABLE public.permissions OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 17225)
-- Name: permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.permissions ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 226 (class 1259 OID 17235)
-- Name: rolepermissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rolepermissions (
    roleid integer NOT NULL,
    permissionid integer NOT NULL
);


ALTER TABLE public.rolepermissions OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 17211)
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 17210)
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.roles ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 243 (class 1259 OID 17307)
-- Name: roomimages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roomimages (
    id integer NOT NULL,
    roomid integer,
    imageurl text
);


ALTER TABLE public.roomimages OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 17306)
-- Name: roomimages_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.roomimages ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.roomimages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 241 (class 1259 OID 17297)
-- Name: rooms; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rooms (
    id integer NOT NULL,
    roomnumber character varying(50),
    price numeric(12,2),
    maxoccupants integer,
    statuscode character varying(50),
    description text,
    createdat timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.rooms OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 17296)
-- Name: rooms_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.rooms ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rooms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 263 (class 1259 OID 17491)
-- Name: sy_commons; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sy_commons (
    id integer NOT NULL,
    type character varying(50) NOT NULL,
    code character varying(50) NOT NULL,
    name_vi text NOT NULL,
    name_en text,
    sort_order integer DEFAULT 0,
    is_active boolean DEFAULT true,
    remark text,
    created_by character varying(50),
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(50),
    updated_date timestamp without time zone,
    data_row_version integer DEFAULT 1
);


ALTER TABLE public.sy_commons OWNER TO postgres;

--
-- TOC entry 262 (class 1259 OID 17490)
-- Name: sy_commons_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.sy_commons ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sy_commons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 269 (class 1259 OID 17554)
-- Name: sy_document_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sy_document_settings (
    id integer NOT NULL,
    transaction_type character varying(50),
    prefix character varying(10),
    date_format character varying(10),
    number_digits integer DEFAULT 4,
    current_number integer DEFAULT 0,
    updated_date timestamp without time zone
);


ALTER TABLE public.sy_document_settings OWNER TO postgres;

--
-- TOC entry 268 (class 1259 OID 17553)
-- Name: sy_document_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.sy_document_settings ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sy_document_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 264 (class 1259 OID 17508)
-- Name: sy_file_attachments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sy_file_attachments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    table_name character varying(50),
    ref_id integer,
    file_name text NOT NULL,
    file_path text NOT NULL,
    file_type character varying(50),
    file_size bigint,
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false
);


ALTER TABLE public.sy_file_attachments OWNER TO postgres;

--
-- TOC entry 265 (class 1259 OID 17521)
-- Name: sy_roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sy_roles (
    role_code character varying(20) NOT NULL,
    role_name text NOT NULL,
    is_system boolean DEFAULT false
);


ALTER TABLE public.sy_roles OWNER TO postgres;

--
-- TOC entry 267 (class 1259 OID 17532)
-- Name: sy_users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sy_users (
    id integer NOT NULL,
    username character varying(50) NOT NULL,
    password_hash text NOT NULL,
    full_name text NOT NULL,
    email character varying(100),
    phone character varying(20),
    role_code character varying(20),
    avatar_id uuid,
    is_active boolean DEFAULT true,
    last_login timestamp without time zone,
    created_by character varying(50),
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(50),
    updated_date timestamp without time zone,
    data_row_version integer DEFAULT 1
);


ALTER TABLE public.sy_users OWNER TO postgres;

--
-- TOC entry 266 (class 1259 OID 17531)
-- Name: sy_users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.sy_users ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sy_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 245 (class 1259 OID 17316)
-- Name: tenants; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tenants (
    id integer NOT NULL,
    fullname character varying(255),
    email character varying(255),
    phone character varying(50),
    cccd character varying(50),
    gendercode character varying(50),
    dateofbirth date,
    address text,
    avatarurl text,
    cccdimageurl text,
    statuscode character varying(50),
    createdat timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.tenants OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 17315)
-- Name: tenants_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tenants ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tenants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 280 (class 1259 OID 17650)
-- Name: tr_contract_details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tr_contract_details (
    contract_id integer NOT NULL,
    tenant_id integer NOT NULL,
    is_main boolean DEFAULT false
);


ALTER TABLE public.tr_contract_details OWNER TO postgres;

--
-- TOC entry 279 (class 1259 OID 17631)
-- Name: tr_contracts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tr_contracts (
    id integer NOT NULL,
    contract_code character varying(50),
    room_id integer,
    start_date date NOT NULL,
    end_date date,
    deposit_amount numeric(15,2) DEFAULT 0,
    actual_rent_price numeric(15,2) NOT NULL,
    status_code character varying(20),
    remark text,
    created_by character varying(50),
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(50),
    updated_date timestamp without time zone
);


ALTER TABLE public.tr_contracts OWNER TO postgres;

--
-- TOC entry 278 (class 1259 OID 17630)
-- Name: tr_contracts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tr_contracts ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tr_contracts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 290 (class 1259 OID 17745)
-- Name: tr_incidents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tr_incidents (
    id integer NOT NULL,
    room_id integer,
    tenant_id integer,
    description text NOT NULL,
    priority_code character varying(20),
    status_code character varying(20),
    reported_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    resolved_date timestamp without time zone,
    repair_cost numeric(15,2) DEFAULT 0,
    created_by character varying(50)
);


ALTER TABLE public.tr_incidents OWNER TO postgres;

--
-- TOC entry 289 (class 1259 OID 17744)
-- Name: tr_incidents_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tr_incidents ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tr_incidents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 286 (class 1259 OID 17707)
-- Name: tr_invoice_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tr_invoice_items (
    id integer NOT NULL,
    invoice_id integer,
    fee_type_id integer,
    description text,
    quantity numeric(10,2) DEFAULT 1,
    unit_price numeric(15,2) DEFAULT 0,
    amount numeric(15,2) NOT NULL
);


ALTER TABLE public.tr_invoice_items OWNER TO postgres;

--
-- TOC entry 285 (class 1259 OID 17706)
-- Name: tr_invoice_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tr_invoice_items ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tr_invoice_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 284 (class 1259 OID 17683)
-- Name: tr_invoices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tr_invoices (
    id integer NOT NULL,
    invoice_code character varying(50),
    contract_id integer,
    branch_id integer,
    billing_month integer NOT NULL,
    billing_year integer NOT NULL,
    total_amount numeric(15,2) DEFAULT 0,
    paid_amount numeric(15,2) DEFAULT 0,
    status_code character varying(20),
    due_date date,
    created_by character varying(50),
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(50),
    updated_date timestamp without time zone
);


ALTER TABLE public.tr_invoices OWNER TO postgres;

--
-- TOC entry 283 (class 1259 OID 17682)
-- Name: tr_invoices_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tr_invoices ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tr_invoices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 288 (class 1259 OID 17729)
-- Name: tr_payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tr_payments (
    id integer NOT NULL,
    invoice_id integer,
    payment_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    amount numeric(15,2) NOT NULL,
    method_code character varying(20),
    evidence_id uuid,
    remark text,
    created_by character varying(50)
);


ALTER TABLE public.tr_payments OWNER TO postgres;

--
-- TOC entry 287 (class 1259 OID 17728)
-- Name: tr_payments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tr_payments ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tr_payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 282 (class 1259 OID 17669)
-- Name: tr_utility_readings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tr_utility_readings (
    id integer NOT NULL,
    room_id integer,
    reading_date date NOT NULL,
    elec_index_old numeric(10,2),
    elec_index_new numeric(10,2),
    water_index_old numeric(10,2),
    water_index_new numeric(10,2),
    created_by character varying(50),
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.tr_utility_readings OWNER TO postgres;

--
-- TOC entry 281 (class 1259 OID 17668)
-- Name: tr_utility_readings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tr_utility_readings ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tr_utility_readings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 239 (class 1259 OID 17288)
-- Name: translations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.translations (
    id integer NOT NULL,
    key character varying(255),
    languagecode character varying(10),
    value text
);


ALTER TABLE public.translations OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 17287)
-- Name: translations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.translations ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.translations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 223 (class 1259 OID 17218)
-- Name: userroles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.userroles (
    userid integer NOT NULL,
    roleid integer NOT NULL
);


ALTER TABLE public.userroles OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 17197)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(100) NOT NULL,
    passwordhash text NOT NULL,
    tenantid integer,
    isactive boolean DEFAULT true
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 17196)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.users ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 249 (class 1259 OID 17333)
-- Name: utilityrecords; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.utilityrecords (
    id integer NOT NULL,
    roomid integer,
    month character varying(7),
    electricold integer,
    electricnew integer,
    waterold integer,
    waternew integer
);


ALTER TABLE public.utilityrecords OWNER TO postgres;

--
-- TOC entry 248 (class 1259 OID 17332)
-- Name: utilityrecords_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.utilityrecords ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.utilityrecords_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 5275 (class 0 OID 17257)
-- Dependencies: 231
-- Data for Name: commoncategories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.commoncategories (id, code) FROM stdin;
1	ROOM_STATUS
2	GENDER
\.


--
-- TOC entry 5279 (class 0 OID 17274)
-- Dependencies: 235
-- Data for Name: commontranslations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.commontranslations (id, commonvalueid, languagecode, value) FROM stdin;
1	1	vi	Trống
2	2	vi	Đã thuê
3	3	vi	Đang sửa
4	4	vi	Nam
5	5	vi	Nữ
\.


--
-- TOC entry 5277 (class 0 OID 17267)
-- Dependencies: 233
-- Data for Name: commonvalues; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.commonvalues (id, categoryid, code, value, orderindex) FROM stdin;
1	1	AVAILABLE	Available	1
2	1	OCCUPIED	Occupied	2
3	1	MAINTENANCE	Maintenance	3
4	2	MALE	Male	\N
5	2	FEMALE	Female	\N
\.


--
-- TOC entry 5291 (class 0 OID 17326)
-- Dependencies: 247
-- Data for Name: contracts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.contracts (id, roomid, tenantid, startdate, enddate, deposit, rentprice, statuscode) FROM stdin;
\.


--
-- TOC entry 5295 (class 0 OID 17340)
-- Dependencies: 251
-- Data for Name: feetypes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.feetypes (id, code, name, calculationtype, unitprice) FROM stdin;
1	ROOM	Room Fee	FIXED	1500000.00
2	ELECTRIC	Electric Fee	PER_UNIT	3500.00
3	WATER	Water Fee	PER_UNIT	15000.00
4	WIFI	Wifi Fee	FIXED	100000.00
\.


--
-- TOC entry 5299 (class 0 OID 17355)
-- Dependencies: 255
-- Data for Name: invoicedetails; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.invoicedetails (id, invoiceid, feetypeid, quantity, unitprice, amount) FROM stdin;
\.


--
-- TOC entry 5297 (class 0 OID 17347)
-- Dependencies: 253
-- Data for Name: invoices; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.invoices (id, roomid, contractid, month, totalamount, status, createdat, paidat) FROM stdin;
\.


--
-- TOC entry 5281 (class 0 OID 17281)
-- Dependencies: 237
-- Data for Name: languages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.languages (id, code, name) FROM stdin;
1	en	English
2	vi	Tiếng Việt
\.


--
-- TOC entry 5303 (class 0 OID 17369)
-- Dependencies: 259
-- Data for Name: maintenances; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.maintenances (id, roomid, description, statuscode, cost, createdat, resolvedat) FROM stdin;
\.


--
-- TOC entry 5273 (class 0 OID 17249)
-- Dependencies: 229
-- Data for Name: menupermissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.menupermissions (menuid, permissionid) FROM stdin;
\.


--
-- TOC entry 5272 (class 0 OID 17243)
-- Dependencies: 228
-- Data for Name: menus; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.menus (id, name, path, icon, parentid, orderindex) FROM stdin;
1	Dashboard	/dashboard	dashboard	\N	1
2	Rooms	/rooms	home	\N	2
3	Tenants	/tenants	users	\N	3
4	Invoices	/invoices	file	\N	4
\.


--
-- TOC entry 5315 (class 0 OID 17565)
-- Dependencies: 271
-- Data for Name: ms_branches; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ms_branches (id, branch_name, address, description, is_active, created_by, created_date, updated_by, updated_date) FROM stdin;
1	Nhà Trọ Bình Dương	123 Thủ Dầu Một, Bình Dương	\N	t	\N	2026-06-07 01:10:07.389801	\N	\N
\.


--
-- TOC entry 5321 (class 0 OID 17613)
-- Dependencies: 277
-- Data for Name: ms_fee_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ms_fee_types (id, branch_id, fee_name, unit_price, calc_method, is_system, is_active) FROM stdin;
1	1	Tiền phòng	0.00	FIXED	t	t
2	1	Tiền điện	3500.00	UNIT	t	t
3	1	Tiền nước	15000.00	UNIT	t	t
4	1	Rác & Vệ sinh	50000.00	FIXED	t	t
\.


--
-- TOC entry 5317 (class 0 OID 17577)
-- Dependencies: 273
-- Data for Name: ms_rooms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ms_rooms (id, branch_id, room_name, price, max_occupants, status_code, description, created_by, created_date, updated_by, updated_date, data_row_version) FROM stdin;
1	1	Phòng 101	2500000.00	2	EMPTY	\N	\N	2026-06-07 01:10:07.389801	\N	\N	1
2	1	Phòng 102	2500000.00	2	RENTED	\N	\N	2026-06-07 01:10:07.389801	\N	\N	1
\.


--
-- TOC entry 5319 (class 0 OID 17596)
-- Dependencies: 275
-- Data for Name: ms_tenants; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ms_tenants (id, user_id, full_name, identity_number, phone, email, dob, gender_code, hometown, address_temporary, is_representative, status_code, created_by, created_date, updated_by, updated_date) FROM stdin;
1	2	Lê Văn Thuê	0123456789	0909123456	\N	\N	\N	\N	\N	f	ACTIVE	\N	2026-06-07 01:10:07.389801	\N	\N
\.


--
-- TOC entry 5305 (class 0 OID 17379)
-- Dependencies: 261
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notifications (id, title, content, userid, isread, createdat) FROM stdin;
\.


--
-- TOC entry 5301 (class 0 OID 17362)
-- Dependencies: 257
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payments (id, invoiceid, amount, paymentdate, method) FROM stdin;
\.


--
-- TOC entry 5269 (class 0 OID 17226)
-- Dependencies: 225
-- Data for Name: permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.permissions (id, code, name) FROM stdin;
1	ROOM_VIEW	View rooms
2	ROOM_CREATE	Create room
3	ROOM_UPDATE	Update room
4	ROOM_DELETE	Delete room
5	TENANT_VIEW	View tenants
6	TENANT_CREATE	Create tenant
7	INVOICE_VIEW	View invoice
8	INVOICE_CREATE	Create invoice
9	PAYMENT_MANAGE	Manage payment
\.


--
-- TOC entry 5270 (class 0 OID 17235)
-- Dependencies: 226
-- Data for Name: rolepermissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rolepermissions (roleid, permissionid) FROM stdin;
1	1
1	2
1	3
1	4
1	5
1	6
1	7
1	8
1	9
\.


--
-- TOC entry 5266 (class 0 OID 17211)
-- Dependencies: 222
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles (id, name) FROM stdin;
1	ADMIN
2	MANAGER
3	STAFF
4	TENANT
\.


--
-- TOC entry 5287 (class 0 OID 17307)
-- Dependencies: 243
-- Data for Name: roomimages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roomimages (id, roomid, imageurl) FROM stdin;
\.


--
-- TOC entry 5285 (class 0 OID 17297)
-- Dependencies: 241
-- Data for Name: rooms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rooms (id, roomnumber, price, maxoccupants, statuscode, description, createdat) FROM stdin;
1	101	1500000.00	2	AVAILABLE	\N	2026-03-22 17:46:11.972743
2	102	1500000.00	2	AVAILABLE	\N	2026-03-22 17:46:11.972743
3	103	1800000.00	3	MAINTENANCE	\N	2026-03-22 17:46:11.972743
\.


--
-- TOC entry 5307 (class 0 OID 17491)
-- Dependencies: 263
-- Data for Name: sy_commons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sy_commons (id, type, code, name_vi, name_en, sort_order, is_active, remark, created_by, created_date, updated_by, updated_date, data_row_version) FROM stdin;
1	ROOM_STATUS	EMPTY	Trống	Empty	1	t	\N	\N	2026-06-07 01:10:07.389801	\N	\N	1
2	ROOM_STATUS	RENTED	Đang thuê	Rented	2	t	\N	\N	2026-06-07 01:10:07.389801	\N	\N	1
3	ROOM_STATUS	REPAIR	Đang sửa chữa	Maintenance	3	t	\N	\N	2026-06-07 01:10:07.389801	\N	\N	1
4	GENDER	MALE	Nam	Male	1	t	\N	\N	2026-06-07 01:10:07.389801	\N	\N	1
5	GENDER	FEMALE	Nữ	Female	2	t	\N	\N	2026-06-07 01:10:07.389801	\N	\N	1
6	GENDER	OTHER	Khác	Other	3	t	\N	\N	2026-06-07 01:10:07.389801	\N	\N	1
7	FEE_CALC	FIXED	Cố định	Fixed	1	t	\N	\N	2026-06-07 01:10:07.389801	\N	\N	1
8	FEE_CALC	UNIT	Theo chỉ số	Per Unit	2	t	\N	\N	2026-06-07 01:10:07.389801	\N	\N	1
9	FEE_CALC	PERSON	Theo số người	Per Person	3	t	\N	\N	2026-06-07 01:10:07.389801	\N	\N	1
10	INV_STATUS	UNPAID	Chưa thanh toán	Unpaid	1	t	\N	\N	2026-06-07 01:10:07.389801	\N	\N	1
11	INV_STATUS	PAID	Đã thanh toán	Paid	2	t	\N	\N	2026-06-07 01:10:07.389801	\N	\N	1
12	INV_STATUS	PARTIAL	Thanh toán một phần	Partial	3	t	\N	\N	2026-06-07 01:10:07.389801	\N	\N	1
\.


--
-- TOC entry 5313 (class 0 OID 17554)
-- Dependencies: 269
-- Data for Name: sy_document_settings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sy_document_settings (id, transaction_type, prefix, date_format, number_digits, current_number, updated_date) FROM stdin;
\.


--
-- TOC entry 5308 (class 0 OID 17508)
-- Dependencies: 264
-- Data for Name: sy_file_attachments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sy_file_attachments (id, table_name, ref_id, file_name, file_path, file_type, file_size, created_date, is_deleted) FROM stdin;
\.


--
-- TOC entry 5309 (class 0 OID 17521)
-- Dependencies: 265
-- Data for Name: sy_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sy_roles (role_code, role_name, is_system) FROM stdin;
ADMIN	Chủ trọ (Admin)	t
MANAGER	Quản lý dãy trọ	t
TENANT	Khách thuê	t
\.


--
-- TOC entry 5311 (class 0 OID 17532)
-- Dependencies: 267
-- Data for Name: sy_users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sy_users (id, username, password_hash, full_name, email, phone, role_code, avatar_id, is_active, last_login, created_by, created_date, updated_by, updated_date, data_row_version) FROM stdin;
1	admin	$2b$12$KIXpZ2m5U9W5.Vl5v3e1Uu8l0aZ8.v0w5U.5V.5V.5V.5V.5V.5V	Nguyễn Văn Chủ Trọ	\N	\N	ADMIN	\N	t	\N	\N	2026-06-07 01:10:07.389801	\N	\N	1
2	khach01	$2b$12$KIXpZ2m5U9W5.Vl5v3e1Uu8l0aZ8.v0w5U.5V.5V.5V.5V.5V.5V	Lê Văn Thuê	\N	\N	TENANT	\N	t	\N	\N	2026-06-07 01:10:07.389801	\N	\N	1
\.


--
-- TOC entry 5289 (class 0 OID 17316)
-- Dependencies: 245
-- Data for Name: tenants; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tenants (id, fullname, email, phone, cccd, gendercode, dateofbirth, address, avatarurl, cccdimageurl, statuscode, createdat) FROM stdin;
1	Nguyen Van A	a@gmail.com	0900000001	123456789	MALE	\N	\N	\N	\N	ACTIVE	2026-03-22 17:46:11.972743
\.


--
-- TOC entry 5324 (class 0 OID 17650)
-- Dependencies: 280
-- Data for Name: tr_contract_details; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tr_contract_details (contract_id, tenant_id, is_main) FROM stdin;
1	1	t
\.


--
-- TOC entry 5323 (class 0 OID 17631)
-- Dependencies: 279
-- Data for Name: tr_contracts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tr_contracts (id, contract_code, room_id, start_date, end_date, deposit_amount, actual_rent_price, status_code, remark, created_by, created_date, updated_by, updated_date) FROM stdin;
1	HD-2024-0001	2	2024-01-01	\N	2500000.00	2500000.00	ACTIVE	\N	\N	2026-06-07 01:10:07.389801	\N	\N
\.


--
-- TOC entry 5334 (class 0 OID 17745)
-- Dependencies: 290
-- Data for Name: tr_incidents; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tr_incidents (id, room_id, tenant_id, description, priority_code, status_code, reported_date, resolved_date, repair_cost, created_by) FROM stdin;
\.


--
-- TOC entry 5330 (class 0 OID 17707)
-- Dependencies: 286
-- Data for Name: tr_invoice_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tr_invoice_items (id, invoice_id, fee_type_id, description, quantity, unit_price, amount) FROM stdin;
\.


--
-- TOC entry 5328 (class 0 OID 17683)
-- Dependencies: 284
-- Data for Name: tr_invoices; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tr_invoices (id, invoice_code, contract_id, branch_id, billing_month, billing_year, total_amount, paid_amount, status_code, due_date, created_by, created_date, updated_by, updated_date) FROM stdin;
\.


--
-- TOC entry 5332 (class 0 OID 17729)
-- Dependencies: 288
-- Data for Name: tr_payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tr_payments (id, invoice_id, payment_date, amount, method_code, evidence_id, remark, created_by) FROM stdin;
\.


--
-- TOC entry 5326 (class 0 OID 17669)
-- Dependencies: 282
-- Data for Name: tr_utility_readings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tr_utility_readings (id, room_id, reading_date, elec_index_old, elec_index_new, water_index_old, water_index_new, created_by, created_date) FROM stdin;
\.


--
-- TOC entry 5283 (class 0 OID 17288)
-- Dependencies: 239
-- Data for Name: translations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.translations (id, key, languagecode, value) FROM stdin;
\.


--
-- TOC entry 5267 (class 0 OID 17218)
-- Dependencies: 223
-- Data for Name: userroles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.userroles (userid, roleid) FROM stdin;
\.


--
-- TOC entry 5264 (class 0 OID 17197)
-- Dependencies: 220
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, username, passwordhash, tenantid, isactive) FROM stdin;
1	admin	123456	\N	t
\.


--
-- TOC entry 5293 (class 0 OID 17333)
-- Dependencies: 249
-- Data for Name: utilityrecords; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.utilityrecords (id, roomid, month, electricold, electricnew, waterold, waternew) FROM stdin;
\.


--
-- TOC entry 5340 (class 0 OID 0)
-- Dependencies: 230
-- Name: commoncategories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.commoncategories_id_seq', 2, true);


--
-- TOC entry 5341 (class 0 OID 0)
-- Dependencies: 234
-- Name: commontranslations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.commontranslations_id_seq', 5, true);


--
-- TOC entry 5342 (class 0 OID 0)
-- Dependencies: 232
-- Name: commonvalues_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.commonvalues_id_seq', 5, true);


--
-- TOC entry 5343 (class 0 OID 0)
-- Dependencies: 246
-- Name: contracts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.contracts_id_seq', 1, false);


--
-- TOC entry 5344 (class 0 OID 0)
-- Dependencies: 250
-- Name: feetypes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.feetypes_id_seq', 4, true);


--
-- TOC entry 5345 (class 0 OID 0)
-- Dependencies: 254
-- Name: invoicedetails_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.invoicedetails_id_seq', 1, false);


--
-- TOC entry 5346 (class 0 OID 0)
-- Dependencies: 252
-- Name: invoices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.invoices_id_seq', 1, false);


--
-- TOC entry 5347 (class 0 OID 0)
-- Dependencies: 236
-- Name: languages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.languages_id_seq', 2, true);


--
-- TOC entry 5348 (class 0 OID 0)
-- Dependencies: 258
-- Name: maintenances_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.maintenances_id_seq', 1, false);


--
-- TOC entry 5349 (class 0 OID 0)
-- Dependencies: 227
-- Name: menus_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.menus_id_seq', 4, true);


--
-- TOC entry 5350 (class 0 OID 0)
-- Dependencies: 270
-- Name: ms_branches_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ms_branches_id_seq', 1, true);


--
-- TOC entry 5351 (class 0 OID 0)
-- Dependencies: 276
-- Name: ms_fee_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ms_fee_types_id_seq', 4, true);


--
-- TOC entry 5352 (class 0 OID 0)
-- Dependencies: 272
-- Name: ms_rooms_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ms_rooms_id_seq', 2, true);


--
-- TOC entry 5353 (class 0 OID 0)
-- Dependencies: 274
-- Name: ms_tenants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ms_tenants_id_seq', 1, true);


--
-- TOC entry 5354 (class 0 OID 0)
-- Dependencies: 260
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.notifications_id_seq', 1, false);


--
-- TOC entry 5355 (class 0 OID 0)
-- Dependencies: 256
-- Name: payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.payments_id_seq', 1, false);


--
-- TOC entry 5356 (class 0 OID 0)
-- Dependencies: 224
-- Name: permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.permissions_id_seq', 9, true);


--
-- TOC entry 5357 (class 0 OID 0)
-- Dependencies: 221
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.roles_id_seq', 4, true);


--
-- TOC entry 5358 (class 0 OID 0)
-- Dependencies: 242
-- Name: roomimages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.roomimages_id_seq', 1, false);


--
-- TOC entry 5359 (class 0 OID 0)
-- Dependencies: 240
-- Name: rooms_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rooms_id_seq', 3, true);


--
-- TOC entry 5360 (class 0 OID 0)
-- Dependencies: 262
-- Name: sy_commons_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sy_commons_id_seq', 12, true);


--
-- TOC entry 5361 (class 0 OID 0)
-- Dependencies: 268
-- Name: sy_document_settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sy_document_settings_id_seq', 1, false);


--
-- TOC entry 5362 (class 0 OID 0)
-- Dependencies: 266
-- Name: sy_users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sy_users_id_seq', 2, true);


--
-- TOC entry 5363 (class 0 OID 0)
-- Dependencies: 244
-- Name: tenants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tenants_id_seq', 1, true);


--
-- TOC entry 5364 (class 0 OID 0)
-- Dependencies: 278
-- Name: tr_contracts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tr_contracts_id_seq', 1, true);


--
-- TOC entry 5365 (class 0 OID 0)
-- Dependencies: 289
-- Name: tr_incidents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tr_incidents_id_seq', 1, false);


--
-- TOC entry 5366 (class 0 OID 0)
-- Dependencies: 285
-- Name: tr_invoice_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tr_invoice_items_id_seq', 1, false);


--
-- TOC entry 5367 (class 0 OID 0)
-- Dependencies: 283
-- Name: tr_invoices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tr_invoices_id_seq', 1, false);


--
-- TOC entry 5368 (class 0 OID 0)
-- Dependencies: 287
-- Name: tr_payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tr_payments_id_seq', 1, false);


--
-- TOC entry 5369 (class 0 OID 0)
-- Dependencies: 281
-- Name: tr_utility_readings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tr_utility_readings_id_seq', 1, false);


--
-- TOC entry 5370 (class 0 OID 0)
-- Dependencies: 238
-- Name: translations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.translations_id_seq', 1, false);


--
-- TOC entry 5371 (class 0 OID 0)
-- Dependencies: 219
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 1, true);


--
-- TOC entry 5372 (class 0 OID 0)
-- Dependencies: 248
-- Name: utilityrecords_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.utilityrecords_id_seq', 1, false);


--
-- TOC entry 5003 (class 2606 OID 17265)
-- Name: commoncategories commoncategories_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commoncategories
    ADD CONSTRAINT commoncategories_code_key UNIQUE (code);


--
-- TOC entry 5005 (class 2606 OID 17263)
-- Name: commoncategories commoncategories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commoncategories
    ADD CONSTRAINT commoncategories_pkey PRIMARY KEY (id);


--
-- TOC entry 5009 (class 2606 OID 17279)
-- Name: commontranslations commontranslations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commontranslations
    ADD CONSTRAINT commontranslations_pkey PRIMARY KEY (id);


--
-- TOC entry 5007 (class 2606 OID 17272)
-- Name: commonvalues commonvalues_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commonvalues
    ADD CONSTRAINT commonvalues_pkey PRIMARY KEY (id);


--
-- TOC entry 5021 (class 2606 OID 17331)
-- Name: contracts contracts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contracts
    ADD CONSTRAINT contracts_pkey PRIMARY KEY (id);


--
-- TOC entry 5025 (class 2606 OID 17345)
-- Name: feetypes feetypes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feetypes
    ADD CONSTRAINT feetypes_pkey PRIMARY KEY (id);


--
-- TOC entry 5029 (class 2606 OID 17360)
-- Name: invoicedetails invoicedetails_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoicedetails
    ADD CONSTRAINT invoicedetails_pkey PRIMARY KEY (id);


--
-- TOC entry 5027 (class 2606 OID 17353)
-- Name: invoices invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- TOC entry 5011 (class 2606 OID 17286)
-- Name: languages languages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.languages
    ADD CONSTRAINT languages_pkey PRIMARY KEY (id);


--
-- TOC entry 5033 (class 2606 OID 17377)
-- Name: maintenances maintenances_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenances
    ADD CONSTRAINT maintenances_pkey PRIMARY KEY (id);


--
-- TOC entry 5001 (class 2606 OID 17255)
-- Name: menupermissions menupermissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.menupermissions
    ADD CONSTRAINT menupermissions_pkey PRIMARY KEY (menuid, permissionid);


--
-- TOC entry 4999 (class 2606 OID 17248)
-- Name: menus menus_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.menus
    ADD CONSTRAINT menus_pkey PRIMARY KEY (id);


--
-- TOC entry 5054 (class 2606 OID 17575)
-- Name: ms_branches ms_branches_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ms_branches
    ADD CONSTRAINT ms_branches_pkey PRIMARY KEY (id);


--
-- TOC entry 5061 (class 2606 OID 17624)
-- Name: ms_fee_types ms_fee_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ms_fee_types
    ADD CONSTRAINT ms_fee_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5057 (class 2606 OID 17589)
-- Name: ms_rooms ms_rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ms_rooms
    ADD CONSTRAINT ms_rooms_pkey PRIMARY KEY (id);


--
-- TOC entry 5059 (class 2606 OID 17606)
-- Name: ms_tenants ms_tenants_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ms_tenants
    ADD CONSTRAINT ms_tenants_pkey PRIMARY KEY (id);


--
-- TOC entry 5035 (class 2606 OID 17388)
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- TOC entry 5031 (class 2606 OID 17367)
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- TOC entry 4993 (class 2606 OID 17234)
-- Name: permissions permissions_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_code_key UNIQUE (code);


--
-- TOC entry 4995 (class 2606 OID 17232)
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- TOC entry 4997 (class 2606 OID 17241)
-- Name: rolepermissions rolepermissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolepermissions
    ADD CONSTRAINT rolepermissions_pkey PRIMARY KEY (roleid, permissionid);


--
-- TOC entry 4989 (class 2606 OID 17217)
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- TOC entry 5017 (class 2606 OID 17314)
-- Name: roomimages roomimages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roomimages
    ADD CONSTRAINT roomimages_pkey PRIMARY KEY (id);


--
-- TOC entry 5015 (class 2606 OID 17305)
-- Name: rooms rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_pkey PRIMARY KEY (id);


--
-- TOC entry 5038 (class 2606 OID 17505)
-- Name: sy_commons sy_commons_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sy_commons
    ADD CONSTRAINT sy_commons_pkey PRIMARY KEY (id);


--
-- TOC entry 5040 (class 2606 OID 17507)
-- Name: sy_commons sy_commons_type_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sy_commons
    ADD CONSTRAINT sy_commons_type_code_key UNIQUE (type, code);


--
-- TOC entry 5050 (class 2606 OID 17561)
-- Name: sy_document_settings sy_document_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sy_document_settings
    ADD CONSTRAINT sy_document_settings_pkey PRIMARY KEY (id);


--
-- TOC entry 5052 (class 2606 OID 17563)
-- Name: sy_document_settings sy_document_settings_transaction_type_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sy_document_settings
    ADD CONSTRAINT sy_document_settings_transaction_type_key UNIQUE (transaction_type);


--
-- TOC entry 5042 (class 2606 OID 17520)
-- Name: sy_file_attachments sy_file_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sy_file_attachments
    ADD CONSTRAINT sy_file_attachments_pkey PRIMARY KEY (id);


--
-- TOC entry 5044 (class 2606 OID 17530)
-- Name: sy_roles sy_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sy_roles
    ADD CONSTRAINT sy_roles_pkey PRIMARY KEY (role_code);


--
-- TOC entry 5046 (class 2606 OID 17545)
-- Name: sy_users sy_users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sy_users
    ADD CONSTRAINT sy_users_pkey PRIMARY KEY (id);


--
-- TOC entry 5048 (class 2606 OID 17547)
-- Name: sy_users sy_users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sy_users
    ADD CONSTRAINT sy_users_username_key UNIQUE (username);


--
-- TOC entry 5019 (class 2606 OID 17324)
-- Name: tenants tenants_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tenants
    ADD CONSTRAINT tenants_pkey PRIMARY KEY (id);


--
-- TOC entry 5067 (class 2606 OID 17657)
-- Name: tr_contract_details tr_contract_details_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tr_contract_details
    ADD CONSTRAINT tr_contract_details_pkey PRIMARY KEY (contract_id, tenant_id);


--
-- TOC entry 5063 (class 2606 OID 17644)
-- Name: tr_contracts tr_contracts_contract_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tr_contracts
    ADD CONSTRAINT tr_contracts_contract_code_key UNIQUE (contract_code);


--
-- TOC entry 5065 (class 2606 OID 17642)
-- Name: tr_contracts tr_contracts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tr_contracts
    ADD CONSTRAINT tr_contracts_pkey PRIMARY KEY (id);


--
-- TOC entry 5080 (class 2606 OID 17755)
-- Name: tr_incidents tr_incidents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tr_incidents
    ADD CONSTRAINT tr_incidents_pkey PRIMARY KEY (id);


--
-- TOC entry 5076 (class 2606 OID 17717)
-- Name: tr_invoice_items tr_invoice_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tr_invoice_items
    ADD CONSTRAINT tr_invoice_items_pkey PRIMARY KEY (id);


--
-- TOC entry 5072 (class 2606 OID 17695)
-- Name: tr_invoices tr_invoices_invoice_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tr_invoices
    ADD CONSTRAINT tr_invoices_invoice_code_key UNIQUE (invoice_code);


--
-- TOC entry 5074 (class 2606 OID 17693)
-- Name: tr_invoices tr_invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tr_invoices
    ADD CONSTRAINT tr_invoices_pkey PRIMARY KEY (id);


--
-- TOC entry 5078 (class 2606 OID 17738)
-- Name: tr_payments tr_payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tr_payments
    ADD CONSTRAINT tr_payments_pkey PRIMARY KEY (id);


--
-- TOC entry 5069 (class 2606 OID 17676)
-- Name: tr_utility_readings tr_utility_readings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tr_utility_readings
    ADD CONSTRAINT tr_utility_readings_pkey PRIMARY KEY (id);


--
-- TOC entry 5013 (class 2606 OID 17295)
-- Name: translations translations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.translations
    ADD CONSTRAINT translations_pkey PRIMARY KEY (id);


--
-- TOC entry 4991 (class 2606 OID 17224)
-- Name: userroles userroles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.userroles
    ADD CONSTRAINT userroles_pkey PRIMARY KEY (userid, roleid);


--
-- TOC entry 4985 (class 2606 OID 17207)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 4987 (class 2606 OID 17209)
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- TOC entry 5023 (class 2606 OID 17338)
-- Name: utilityrecords utilityrecords_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.utilityrecords
    ADD CONSTRAINT utilityrecords_pkey PRIMARY KEY (id);


--
-- TOC entry 5036 (class 1259 OID 17768)
-- Name: idx_common_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_common_type ON public.sy_commons USING btree (type);


--
-- TOC entry 5070 (class 1259 OID 17767)
-- Name: idx_invoice_contract; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_invoice_contract ON public.tr_invoices USING btree (contract_id);


--
-- TOC entry 5055 (class 1259 OID 17766)
-- Name: idx_room_branch; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_room_branch ON public.ms_rooms USING btree (branch_id);


--
-- TOC entry 5089 (class 2606 OID 17429)
-- Name: commontranslations commontranslations_commonvalueid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commontranslations
    ADD CONSTRAINT commontranslations_commonvalueid_fkey FOREIGN KEY (commonvalueid) REFERENCES public.commonvalues(id);


--
-- TOC entry 5088 (class 2606 OID 17424)
-- Name: commonvalues commonvalues_categoryid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commonvalues
    ADD CONSTRAINT commonvalues_categoryid_fkey FOREIGN KEY (categoryid) REFERENCES public.commoncategories(id);


--
-- TOC entry 5091 (class 2606 OID 17439)
-- Name: contracts contracts_roomid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contracts
    ADD CONSTRAINT contracts_roomid_fkey FOREIGN KEY (roomid) REFERENCES public.rooms(id);


--
-- TOC entry 5092 (class 2606 OID 17444)
-- Name: contracts contracts_tenantid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contracts
    ADD CONSTRAINT contracts_tenantid_fkey FOREIGN KEY (tenantid) REFERENCES public.tenants(id);


--
-- TOC entry 5096 (class 2606 OID 17469)
-- Name: invoicedetails invoicedetails_feetypeid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoicedetails
    ADD CONSTRAINT invoicedetails_feetypeid_fkey FOREIGN KEY (feetypeid) REFERENCES public.feetypes(id);


--
-- TOC entry 5097 (class 2606 OID 17464)
-- Name: invoicedetails invoicedetails_invoiceid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoicedetails
    ADD CONSTRAINT invoicedetails_invoiceid_fkey FOREIGN KEY (invoiceid) REFERENCES public.invoices(id);


--
-- TOC entry 5094 (class 2606 OID 17459)
-- Name: invoices invoices_contractid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_contractid_fkey FOREIGN KEY (contractid) REFERENCES public.contracts(id);


--
-- TOC entry 5095 (class 2606 OID 17454)
-- Name: invoices invoices_roomid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_roomid_fkey FOREIGN KEY (roomid) REFERENCES public.rooms(id);


--
-- TOC entry 5099 (class 2606 OID 17479)
-- Name: maintenances maintenances_roomid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenances
    ADD CONSTRAINT maintenances_roomid_fkey FOREIGN KEY (roomid) REFERENCES public.rooms(id);


--
-- TOC entry 5086 (class 2606 OID 17414)
-- Name: menupermissions menupermissions_menuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.menupermissions
    ADD CONSTRAINT menupermissions_menuid_fkey FOREIGN KEY (menuid) REFERENCES public.menus(id);


--
-- TOC entry 5087 (class 2606 OID 17419)
-- Name: menupermissions menupermissions_permissionid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.menupermissions
    ADD CONSTRAINT menupermissions_permissionid_fkey FOREIGN KEY (permissionid) REFERENCES public.permissions(id);


--
-- TOC entry 5104 (class 2606 OID 17625)
-- Name: ms_fee_types ms_fee_types_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ms_fee_types
    ADD CONSTRAINT ms_fee_types_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.ms_branches(id);


--
-- TOC entry 5102 (class 2606 OID 17590)
-- Name: ms_rooms ms_rooms_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ms_rooms
    ADD CONSTRAINT ms_rooms_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.ms_branches(id);


--
-- TOC entry 5103 (class 2606 OID 17607)
-- Name: ms_tenants ms_tenants_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ms_tenants
    ADD CONSTRAINT ms_tenants_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.sy_users(id);


--
-- TOC entry 5100 (class 2606 OID 17484)
-- Name: notifications notifications_userid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_userid_fkey FOREIGN KEY (userid) REFERENCES public.users(id);


--
-- TOC entry 5098 (class 2606 OID 17474)
-- Name: payments payments_invoiceid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_invoiceid_fkey FOREIGN KEY (invoiceid) REFERENCES public.invoices(id);


--
-- TOC entry 5084 (class 2606 OID 17409)
-- Name: rolepermissions rolepermissions_permissionid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolepermissions
    ADD CONSTRAINT rolepermissions_permissionid_fkey FOREIGN KEY (permissionid) REFERENCES public.permissions(id);


--
-- TOC entry 5085 (class 2606 OID 17404)
-- Name: rolepermissions rolepermissions_roleid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolepermissions
    ADD CONSTRAINT rolepermissions_roleid_fkey FOREIGN KEY (roleid) REFERENCES public.roles(id);


--
-- TOC entry 5090 (class 2606 OID 17434)
-- Name: roomimages roomimages_roomid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roomimages
    ADD CONSTRAINT roomimages_roomid_fkey FOREIGN KEY (roomid) REFERENCES public.rooms(id);


--
-- TOC entry 5101 (class 2606 OID 17548)
-- Name: sy_users sy_users_role_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sy_users
    ADD CONSTRAINT sy_users_role_code_fkey FOREIGN KEY (role_code) REFERENCES public.sy_roles(role_code);


--
-- TOC entry 5106 (class 2606 OID 17658)
-- Name: tr_contract_details tr_contract_details_contract_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tr_contract_details
    ADD CONSTRAINT tr_contract_details_contract_id_fkey FOREIGN KEY (contract_id) REFERENCES public.tr_contracts(id);


--
-- TOC entry 5107 (class 2606 OID 17663)
-- Name: tr_contract_details tr_contract_details_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tr_contract_details
    ADD CONSTRAINT tr_contract_details_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.ms_tenants(id);


--
-- TOC entry 5105 (class 2606 OID 17645)
-- Name: tr_contracts tr_contracts_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tr_contracts
    ADD CONSTRAINT tr_contracts_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.ms_rooms(id);


--
-- TOC entry 5114 (class 2606 OID 17756)
-- Name: tr_incidents tr_incidents_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tr_incidents
    ADD CONSTRAINT tr_incidents_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.ms_rooms(id);


--
-- TOC entry 5115 (class 2606 OID 17761)
-- Name: tr_incidents tr_incidents_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tr_incidents
    ADD CONSTRAINT tr_incidents_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.ms_tenants(id);


--
-- TOC entry 5111 (class 2606 OID 17723)
-- Name: tr_invoice_items tr_invoice_items_fee_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tr_invoice_items
    ADD CONSTRAINT tr_invoice_items_fee_type_id_fkey FOREIGN KEY (fee_type_id) REFERENCES public.ms_fee_types(id);


--
-- TOC entry 5112 (class 2606 OID 17718)
-- Name: tr_invoice_items tr_invoice_items_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tr_invoice_items
    ADD CONSTRAINT tr_invoice_items_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.tr_invoices(id) ON DELETE CASCADE;


--
-- TOC entry 5109 (class 2606 OID 17701)
-- Name: tr_invoices tr_invoices_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tr_invoices
    ADD CONSTRAINT tr_invoices_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.ms_branches(id);


--
-- TOC entry 5110 (class 2606 OID 17696)
-- Name: tr_invoices tr_invoices_contract_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tr_invoices
    ADD CONSTRAINT tr_invoices_contract_id_fkey FOREIGN KEY (contract_id) REFERENCES public.tr_contracts(id);


--
-- TOC entry 5113 (class 2606 OID 17739)
-- Name: tr_payments tr_payments_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tr_payments
    ADD CONSTRAINT tr_payments_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.tr_invoices(id);


--
-- TOC entry 5108 (class 2606 OID 17677)
-- Name: tr_utility_readings tr_utility_readings_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tr_utility_readings
    ADD CONSTRAINT tr_utility_readings_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.ms_rooms(id);


--
-- TOC entry 5082 (class 2606 OID 17399)
-- Name: userroles userroles_roleid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.userroles
    ADD CONSTRAINT userroles_roleid_fkey FOREIGN KEY (roleid) REFERENCES public.roles(id);


--
-- TOC entry 5083 (class 2606 OID 17394)
-- Name: userroles userroles_userid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.userroles
    ADD CONSTRAINT userroles_userid_fkey FOREIGN KEY (userid) REFERENCES public.users(id);


--
-- TOC entry 5081 (class 2606 OID 17389)
-- Name: users users_tenantid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_tenantid_fkey FOREIGN KEY (tenantid) REFERENCES public.tenants(id);


--
-- TOC entry 5093 (class 2606 OID 17449)
-- Name: utilityrecords utilityrecords_roomid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.utilityrecords
    ADD CONSTRAINT utilityrecords_roomid_fkey FOREIGN KEY (roomid) REFERENCES public.rooms(id);


-- Completed on 2026-06-07 11:18:31

--
-- PostgreSQL database dump complete
--

\unrestrict xk6wQ4aX0OWI7c8oZKRmug8h8l5fDbX8VpoJNB3FYrn1FUuyC0xIVNwek8GyLAR

