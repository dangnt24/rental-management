--
-- PostgreSQL database dump
--

\restrict o22hNadVOMHMZwpo71r1V4P6Jau3flWORzBHSLYIlNeo7sal2tQ2fFpE56W0BKk

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

-- Started on 2026-07-23 16:36:27

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
-- TOC entry 249 (class 1255 OID 17770)
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
-- TOC entry 251 (class 1255 OID 17772)
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
-- TOC entry 250 (class 1255 OID 17771)
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
-- TOC entry 228 (class 1259 OID 17565)
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
    updated_date timestamp without time zone,
    deleted_by character varying(50),
    deleted_date timestamp without time zone,
    is_deleted boolean DEFAULT false,
    version integer DEFAULT 1
);


ALTER TABLE public.ms_branches OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 17564)
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
-- TOC entry 234 (class 1259 OID 17613)
-- Name: ms_fee_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ms_fee_types (
    id integer NOT NULL,
    branch_id integer,
    fee_name text NOT NULL,
    unit_price numeric(15,2) NOT NULL,
    calc_method character varying(20),
    is_system boolean DEFAULT false,
    is_active boolean DEFAULT true,
    deleted_by character varying(50),
    deleted_date timestamp without time zone,
    is_deleted boolean DEFAULT false,
    created_by character varying(50),
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(50),
    updated_date timestamp without time zone,
    version integer DEFAULT 1
);


ALTER TABLE public.ms_fee_types OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 17612)
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
-- TOC entry 230 (class 1259 OID 17577)
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
    data_row_version integer DEFAULT 1,
    deleted_by character varying(50),
    deleted_date timestamp without time zone,
    is_deleted boolean DEFAULT false,
    version integer DEFAULT 1
);


ALTER TABLE public.ms_rooms OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 17576)
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
-- TOC entry 232 (class 1259 OID 17596)
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
    updated_date timestamp without time zone,
    deleted_by character varying(50),
    deleted_date timestamp without time zone,
    is_deleted boolean DEFAULT false,
    version integer DEFAULT 1
);


ALTER TABLE public.ms_tenants OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 17595)
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
-- TOC entry 220 (class 1259 OID 17491)
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
    data_row_version integer DEFAULT 1,
    deleted_by character varying(50),
    deleted_date timestamp without time zone,
    is_deleted boolean DEFAULT false,
    version integer DEFAULT 1
);


ALTER TABLE public.sy_commons OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 17490)
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
-- TOC entry 226 (class 1259 OID 17554)
-- Name: sy_document_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sy_document_settings (
    id integer NOT NULL,
    transaction_type character varying(50),
    prefix character varying(10),
    date_format character varying(10),
    number_digits integer DEFAULT 4,
    current_number integer DEFAULT 0,
    updated_date timestamp without time zone,
    deleted_by character varying(50),
    deleted_date timestamp without time zone,
    is_deleted boolean DEFAULT false,
    created_by character varying(50),
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(50),
    version integer DEFAULT 1
);


ALTER TABLE public.sy_document_settings OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 17553)
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
-- TOC entry 221 (class 1259 OID 17508)
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
    is_deleted boolean DEFAULT false,
    deleted_by character varying(50),
    deleted_date timestamp without time zone,
    created_by character varying(50),
    updated_by character varying(50),
    updated_date timestamp without time zone,
    version integer DEFAULT 1
);


ALTER TABLE public.sy_file_attachments OWNER TO postgres;

--
-- TOC entry 248 (class 1259 OID 17774)
-- Name: sy_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sy_permissions (
    permission_code character varying(50) NOT NULL,
    permission_name text NOT NULL,
    module character varying(50),
    is_deleted boolean DEFAULT false,
    created_by character varying(50),
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(50),
    updated_date timestamp without time zone,
    deleted_by character varying(50),
    deleted_date timestamp without time zone,
    version integer DEFAULT 1
);


ALTER TABLE public.sy_permissions OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 17521)
-- Name: sy_roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sy_roles (
    role_code character varying(20) NOT NULL,
    role_name text NOT NULL,
    is_system boolean DEFAULT false,
    deleted_by character varying(50),
    deleted_date timestamp without time zone,
    is_deleted boolean DEFAULT false,
    created_by character varying(50),
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(50),
    updated_date timestamp without time zone,
    version integer DEFAULT 1
);


ALTER TABLE public.sy_roles OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 17532)
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
    data_row_version integer DEFAULT 1,
    deleted_by character varying(50),
    deleted_date timestamp without time zone,
    is_deleted boolean DEFAULT false,
    version integer DEFAULT 1,
    refresh_token text,
    refresh_token_expiry timestamp without time zone
);


ALTER TABLE public.sy_users OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 17531)
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
-- TOC entry 237 (class 1259 OID 17650)
-- Name: tr_contract_details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tr_contract_details (
    contract_id integer NOT NULL,
    tenant_id integer NOT NULL,
    is_main boolean DEFAULT false
);


ALTER TABLE public.tr_contract_details OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 17631)
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
    updated_date timestamp without time zone,
    deleted_by character varying(50),
    deleted_date timestamp without time zone,
    is_deleted boolean DEFAULT false,
    version integer DEFAULT 1
);


ALTER TABLE public.tr_contracts OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 17630)
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
-- TOC entry 247 (class 1259 OID 17745)
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
    created_by character varying(50),
    deleted_by character varying(50),
    deleted_date timestamp without time zone,
    is_deleted boolean DEFAULT false,
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(50),
    updated_date timestamp without time zone,
    version integer DEFAULT 1
);


ALTER TABLE public.tr_incidents OWNER TO postgres;

--
-- TOC entry 246 (class 1259 OID 17744)
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
-- TOC entry 243 (class 1259 OID 17707)
-- Name: tr_invoice_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tr_invoice_items (
    id integer NOT NULL,
    invoice_id integer,
    fee_type_id integer,
    description text,
    quantity numeric(10,2) DEFAULT 1,
    unit_price numeric(15,2) DEFAULT 0,
    amount numeric(15,2) NOT NULL,
    is_deleted boolean DEFAULT false,
    created_by character varying(50),
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(50),
    updated_date timestamp without time zone,
    deleted_by character varying(50),
    deleted_date timestamp without time zone,
    version integer DEFAULT 1
);


ALTER TABLE public.tr_invoice_items OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 17706)
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
-- TOC entry 241 (class 1259 OID 17683)
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
    updated_date timestamp without time zone,
    deleted_by character varying(50),
    deleted_date timestamp without time zone,
    is_deleted boolean DEFAULT false,
    version integer DEFAULT 1
);


ALTER TABLE public.tr_invoices OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 17682)
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
-- TOC entry 245 (class 1259 OID 17729)
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
    created_by character varying(50),
    deleted_by character varying(50),
    deleted_date timestamp without time zone,
    is_deleted boolean DEFAULT false,
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(50),
    updated_date timestamp without time zone,
    version integer DEFAULT 1
);


ALTER TABLE public.tr_payments OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 17728)
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
-- TOC entry 239 (class 1259 OID 17669)
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
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    deleted_by character varying(50),
    deleted_date timestamp without time zone,
    is_deleted boolean DEFAULT false,
    updated_by character varying(50),
    updated_date timestamp without time zone,
    version integer DEFAULT 1
);


ALTER TABLE public.tr_utility_readings OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 17668)
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
-- TOC entry 4925 (class 2606 OID 17575)
-- Name: ms_branches ms_branches_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ms_branches
    ADD CONSTRAINT ms_branches_pkey PRIMARY KEY (id);


--
-- TOC entry 4932 (class 2606 OID 17624)
-- Name: ms_fee_types ms_fee_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ms_fee_types
    ADD CONSTRAINT ms_fee_types_pkey PRIMARY KEY (id);


--
-- TOC entry 4928 (class 2606 OID 17589)
-- Name: ms_rooms ms_rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ms_rooms
    ADD CONSTRAINT ms_rooms_pkey PRIMARY KEY (id);


--
-- TOC entry 4930 (class 2606 OID 17606)
-- Name: ms_tenants ms_tenants_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ms_tenants
    ADD CONSTRAINT ms_tenants_pkey PRIMARY KEY (id);


--
-- TOC entry 4909 (class 2606 OID 17505)
-- Name: sy_commons sy_commons_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sy_commons
    ADD CONSTRAINT sy_commons_pkey PRIMARY KEY (id);


--
-- TOC entry 4911 (class 2606 OID 17507)
-- Name: sy_commons sy_commons_type_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sy_commons
    ADD CONSTRAINT sy_commons_type_code_key UNIQUE (type, code);


--
-- TOC entry 4921 (class 2606 OID 17561)
-- Name: sy_document_settings sy_document_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sy_document_settings
    ADD CONSTRAINT sy_document_settings_pkey PRIMARY KEY (id);


--
-- TOC entry 4923 (class 2606 OID 17563)
-- Name: sy_document_settings sy_document_settings_transaction_type_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sy_document_settings
    ADD CONSTRAINT sy_document_settings_transaction_type_key UNIQUE (transaction_type);


--
-- TOC entry 4913 (class 2606 OID 17520)
-- Name: sy_file_attachments sy_file_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sy_file_attachments
    ADD CONSTRAINT sy_file_attachments_pkey PRIMARY KEY (id);


--
-- TOC entry 4953 (class 2606 OID 17782)
-- Name: sy_permissions sy_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sy_permissions
    ADD CONSTRAINT sy_permissions_pkey PRIMARY KEY (permission_code);


--
-- TOC entry 4915 (class 2606 OID 17530)
-- Name: sy_roles sy_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sy_roles
    ADD CONSTRAINT sy_roles_pkey PRIMARY KEY (role_code);


--
-- TOC entry 4917 (class 2606 OID 17545)
-- Name: sy_users sy_users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sy_users
    ADD CONSTRAINT sy_users_pkey PRIMARY KEY (id);


--
-- TOC entry 4919 (class 2606 OID 17547)
-- Name: sy_users sy_users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sy_users
    ADD CONSTRAINT sy_users_username_key UNIQUE (username);


--
-- TOC entry 4938 (class 2606 OID 17657)
-- Name: tr_contract_details tr_contract_details_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tr_contract_details
    ADD CONSTRAINT tr_contract_details_pkey PRIMARY KEY (contract_id, tenant_id);


--
-- TOC entry 4934 (class 2606 OID 17644)
-- Name: tr_contracts tr_contracts_contract_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tr_contracts
    ADD CONSTRAINT tr_contracts_contract_code_key UNIQUE (contract_code);


--
-- TOC entry 4936 (class 2606 OID 17642)
-- Name: tr_contracts tr_contracts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tr_contracts
    ADD CONSTRAINT tr_contracts_pkey PRIMARY KEY (id);


--
-- TOC entry 4951 (class 2606 OID 17755)
-- Name: tr_incidents tr_incidents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tr_incidents
    ADD CONSTRAINT tr_incidents_pkey PRIMARY KEY (id);


--
-- TOC entry 4947 (class 2606 OID 17717)
-- Name: tr_invoice_items tr_invoice_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tr_invoice_items
    ADD CONSTRAINT tr_invoice_items_pkey PRIMARY KEY (id);


--
-- TOC entry 4943 (class 2606 OID 17695)
-- Name: tr_invoices tr_invoices_invoice_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tr_invoices
    ADD CONSTRAINT tr_invoices_invoice_code_key UNIQUE (invoice_code);


--
-- TOC entry 4945 (class 2606 OID 17693)
-- Name: tr_invoices tr_invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tr_invoices
    ADD CONSTRAINT tr_invoices_pkey PRIMARY KEY (id);


--
-- TOC entry 4949 (class 2606 OID 17738)
-- Name: tr_payments tr_payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tr_payments
    ADD CONSTRAINT tr_payments_pkey PRIMARY KEY (id);


--
-- TOC entry 4940 (class 2606 OID 17676)
-- Name: tr_utility_readings tr_utility_readings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tr_utility_readings
    ADD CONSTRAINT tr_utility_readings_pkey PRIMARY KEY (id);


--
-- TOC entry 4907 (class 1259 OID 17768)
-- Name: idx_common_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_common_type ON public.sy_commons USING btree (type);


--
-- TOC entry 4941 (class 1259 OID 17767)
-- Name: idx_invoice_contract; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_invoice_contract ON public.tr_invoices USING btree (contract_id);


--
-- TOC entry 4926 (class 1259 OID 17766)
-- Name: idx_room_branch; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_room_branch ON public.ms_rooms USING btree (branch_id);


--
-- TOC entry 4957 (class 2606 OID 17625)
-- Name: ms_fee_types ms_fee_types_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ms_fee_types
    ADD CONSTRAINT ms_fee_types_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.ms_branches(id);


--
-- TOC entry 4955 (class 2606 OID 17590)
-- Name: ms_rooms ms_rooms_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ms_rooms
    ADD CONSTRAINT ms_rooms_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.ms_branches(id);


--
-- TOC entry 4956 (class 2606 OID 17607)
-- Name: ms_tenants ms_tenants_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ms_tenants
    ADD CONSTRAINT ms_tenants_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.sy_users(id);


--
-- TOC entry 4954 (class 2606 OID 17548)
-- Name: sy_users sy_users_role_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sy_users
    ADD CONSTRAINT sy_users_role_code_fkey FOREIGN KEY (role_code) REFERENCES public.sy_roles(role_code);


--
-- TOC entry 4959 (class 2606 OID 17658)
-- Name: tr_contract_details tr_contract_details_contract_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tr_contract_details
    ADD CONSTRAINT tr_contract_details_contract_id_fkey FOREIGN KEY (contract_id) REFERENCES public.tr_contracts(id);


--
-- TOC entry 4960 (class 2606 OID 17663)
-- Name: tr_contract_details tr_contract_details_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tr_contract_details
    ADD CONSTRAINT tr_contract_details_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.ms_tenants(id);


--
-- TOC entry 4958 (class 2606 OID 17645)
-- Name: tr_contracts tr_contracts_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tr_contracts
    ADD CONSTRAINT tr_contracts_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.ms_rooms(id);


--
-- TOC entry 4967 (class 2606 OID 17756)
-- Name: tr_incidents tr_incidents_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tr_incidents
    ADD CONSTRAINT tr_incidents_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.ms_rooms(id);


--
-- TOC entry 4968 (class 2606 OID 17761)
-- Name: tr_incidents tr_incidents_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tr_incidents
    ADD CONSTRAINT tr_incidents_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.ms_tenants(id);


--
-- TOC entry 4964 (class 2606 OID 17723)
-- Name: tr_invoice_items tr_invoice_items_fee_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tr_invoice_items
    ADD CONSTRAINT tr_invoice_items_fee_type_id_fkey FOREIGN KEY (fee_type_id) REFERENCES public.ms_fee_types(id);


--
-- TOC entry 4965 (class 2606 OID 17718)
-- Name: tr_invoice_items tr_invoice_items_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tr_invoice_items
    ADD CONSTRAINT tr_invoice_items_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.tr_invoices(id) ON DELETE CASCADE;


--
-- TOC entry 4962 (class 2606 OID 17701)
-- Name: tr_invoices tr_invoices_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tr_invoices
    ADD CONSTRAINT tr_invoices_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.ms_branches(id);


--
-- TOC entry 4963 (class 2606 OID 17696)
-- Name: tr_invoices tr_invoices_contract_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tr_invoices
    ADD CONSTRAINT tr_invoices_contract_id_fkey FOREIGN KEY (contract_id) REFERENCES public.tr_contracts(id);


--
-- TOC entry 4966 (class 2606 OID 17739)
-- Name: tr_payments tr_payments_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tr_payments
    ADD CONSTRAINT tr_payments_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.tr_invoices(id);


--
-- TOC entry 4961 (class 2606 OID 17677)
-- Name: tr_utility_readings tr_utility_readings_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tr_utility_readings
    ADD CONSTRAINT tr_utility_readings_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.ms_rooms(id);


-- Completed on 2026-07-23 16:36:28

--
-- PostgreSQL database dump complete
--

\unrestrict o22hNadVOMHMZwpo71r1V4P6Jau3flWORzBHSLYIlNeo7sal2tQ2fFpE56W0BKk

