--
-- PostgreSQL database dump
--

\restrict byxwXDyzFRuJlueUQWKDDSnVa3tv50y4A2ephlupZsTpxoSujWfxCfqOVoJVxCm

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

-- Started on 2026-07-24 10:39:03

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
-- TOC entry 5042 (class 0 OID 26469)
-- Dependencies: 219
-- Data for Name: ms_branches; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.ms_branches (id, branch_name, address, description, is_active, created_by, created_date, updated_by, updated_date, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (13, 'Cơ sở 1 - Nguyễn Huệ', '123 Nguyễn Huệ, Quận 1, TP.HCM', 'Dãy trọ trung tâm Quận 1', true, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.ms_branches (id, branch_name, address, description, is_active, created_by, created_date, updated_by, updated_date, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (14, 'Cơ sở 2 - Lê Lợi', '456 Lê Lợi, Quận Bình Thạnh, TP.HCM', 'Dãy trọ gần trường ĐH', true, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.ms_branches (id, branch_name, address, description, is_active, created_by, created_date, updated_by, updated_date, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (15, 'Cơ sở 3 - CMT8', '789 CMT8, Quận Tân Bình, TP.HCM', 'Dãy trọ khu vực sân bay', true, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, NULL, NULL, false, 1);


--
-- TOC entry 5044 (class 0 OID 26481)
-- Dependencies: 221
-- Data for Name: ms_fee_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.ms_fee_types (id, branch_id, fee_name, unit_price, calc_method, is_system, is_active, deleted_by, deleted_date, is_deleted, created_by, created_date, updated_by, updated_date, version) OVERRIDING SYSTEM VALUE VALUES (1, 13, 'PHI_XE', 150000.00, 'FIXED', true, true, NULL, NULL, false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, 1);
INSERT INTO public.ms_fee_types (id, branch_id, fee_name, unit_price, calc_method, is_system, is_active, deleted_by, deleted_date, is_deleted, created_by, created_date, updated_by, updated_date, version) OVERRIDING SYSTEM VALUE VALUES (2, 13, 'PHI_WIFI', 100000.00, 'FIXED', true, true, NULL, NULL, false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, 1);
INSERT INTO public.ms_fee_types (id, branch_id, fee_name, unit_price, calc_method, is_system, is_active, deleted_by, deleted_date, is_deleted, created_by, created_date, updated_by, updated_date, version) OVERRIDING SYSTEM VALUE VALUES (3, 13, 'PHI_RAC', 50000.00, 'FIXED', true, true, NULL, NULL, false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, 1);
INSERT INTO public.ms_fee_types (id, branch_id, fee_name, unit_price, calc_method, is_system, is_active, deleted_by, deleted_date, is_deleted, created_by, created_date, updated_by, updated_date, version) OVERRIDING SYSTEM VALUE VALUES (4, 13, 'TIEN_NUOC', 25000.00, 'PER_UNIT', true, true, NULL, NULL, false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, 1);
INSERT INTO public.ms_fee_types (id, branch_id, fee_name, unit_price, calc_method, is_system, is_active, deleted_by, deleted_date, is_deleted, created_by, created_date, updated_by, updated_date, version) OVERRIDING SYSTEM VALUE VALUES (5, 13, 'TIEN_DIEN', 4000.00, 'PER_UNIT', true, true, NULL, NULL, false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, 1);
INSERT INTO public.ms_fee_types (id, branch_id, fee_name, unit_price, calc_method, is_system, is_active, deleted_by, deleted_date, is_deleted, created_by, created_date, updated_by, updated_date, version) OVERRIDING SYSTEM VALUE VALUES (6, 13, 'TIEN_PHONG', 0.00, 'FIXED', true, true, NULL, NULL, false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, 1);
INSERT INTO public.ms_fee_types (id, branch_id, fee_name, unit_price, calc_method, is_system, is_active, deleted_by, deleted_date, is_deleted, created_by, created_date, updated_by, updated_date, version) OVERRIDING SYSTEM VALUE VALUES (7, 14, 'PHI_XE', 120000.00, 'FIXED', true, true, NULL, NULL, false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, 1);
INSERT INTO public.ms_fee_types (id, branch_id, fee_name, unit_price, calc_method, is_system, is_active, deleted_by, deleted_date, is_deleted, created_by, created_date, updated_by, updated_date, version) OVERRIDING SYSTEM VALUE VALUES (8, 14, 'PHI_WIFI', 80000.00, 'FIXED', true, true, NULL, NULL, false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, 1);
INSERT INTO public.ms_fee_types (id, branch_id, fee_name, unit_price, calc_method, is_system, is_active, deleted_by, deleted_date, is_deleted, created_by, created_date, updated_by, updated_date, version) OVERRIDING SYSTEM VALUE VALUES (9, 14, 'PHI_RAC', 40000.00, 'FIXED', true, true, NULL, NULL, false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, 1);
INSERT INTO public.ms_fee_types (id, branch_id, fee_name, unit_price, calc_method, is_system, is_active, deleted_by, deleted_date, is_deleted, created_by, created_date, updated_by, updated_date, version) OVERRIDING SYSTEM VALUE VALUES (10, 14, 'TIEN_NUOC', 20000.00, 'PER_UNIT', true, true, NULL, NULL, false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, 1);
INSERT INTO public.ms_fee_types (id, branch_id, fee_name, unit_price, calc_method, is_system, is_active, deleted_by, deleted_date, is_deleted, created_by, created_date, updated_by, updated_date, version) OVERRIDING SYSTEM VALUE VALUES (11, 14, 'TIEN_DIEN', 3500.00, 'PER_UNIT', true, true, NULL, NULL, false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, 1);
INSERT INTO public.ms_fee_types (id, branch_id, fee_name, unit_price, calc_method, is_system, is_active, deleted_by, deleted_date, is_deleted, created_by, created_date, updated_by, updated_date, version) OVERRIDING SYSTEM VALUE VALUES (12, 14, 'TIEN_PHONG', 0.00, 'FIXED', true, true, NULL, NULL, false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, 1);
INSERT INTO public.ms_fee_types (id, branch_id, fee_name, unit_price, calc_method, is_system, is_active, deleted_by, deleted_date, is_deleted, created_by, created_date, updated_by, updated_date, version) OVERRIDING SYSTEM VALUE VALUES (13, 15, 'PHI_WIFI', 90000.00, 'FIXED', true, true, NULL, NULL, false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, 1);
INSERT INTO public.ms_fee_types (id, branch_id, fee_name, unit_price, calc_method, is_system, is_active, deleted_by, deleted_date, is_deleted, created_by, created_date, updated_by, updated_date, version) OVERRIDING SYSTEM VALUE VALUES (14, 15, 'PHI_RAC', 45000.00, 'FIXED', true, true, NULL, NULL, false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, 1);
INSERT INTO public.ms_fee_types (id, branch_id, fee_name, unit_price, calc_method, is_system, is_active, deleted_by, deleted_date, is_deleted, created_by, created_date, updated_by, updated_date, version) OVERRIDING SYSTEM VALUE VALUES (15, 15, 'TIEN_NUOC', 22000.00, 'PER_UNIT', true, true, NULL, NULL, false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, 1);
INSERT INTO public.ms_fee_types (id, branch_id, fee_name, unit_price, calc_method, is_system, is_active, deleted_by, deleted_date, is_deleted, created_by, created_date, updated_by, updated_date, version) OVERRIDING SYSTEM VALUE VALUES (16, 15, 'TIEN_DIEN', 3800.00, 'PER_UNIT', true, true, NULL, NULL, false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, 1);
INSERT INTO public.ms_fee_types (id, branch_id, fee_name, unit_price, calc_method, is_system, is_active, deleted_by, deleted_date, is_deleted, created_by, created_date, updated_by, updated_date, version) OVERRIDING SYSTEM VALUE VALUES (17, 15, 'TIEN_PHONG', 0.00, 'FIXED', true, true, NULL, NULL, false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, 1);


--
-- TOC entry 5046 (class 0 OID 26495)
-- Dependencies: 223
-- Data for Name: ms_rooms; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.ms_rooms (id, branch_id, room_name, price, max_occupants, status_code, description, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (13, 13, 'P301', 4000000.00, 4, 'EMPTY', 'Phòng tầng 3, diện tích 35m2, phòng gia đình', 'system', '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.ms_rooms (id, branch_id, room_name, price, max_occupants, status_code, description, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (14, 13, 'P202', 2800000.00, 2, 'EMPTY', 'Phòng tầng 2, diện tích 22m2', 'system', '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.ms_rooms (id, branch_id, room_name, price, max_occupants, status_code, description, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (15, 13, 'P201', 3500000.00, 3, 'EMPTY', 'Phòng tầng 2, diện tích 30m2, thoáng mát', 'system', '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.ms_rooms (id, branch_id, room_name, price, max_occupants, status_code, description, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (16, 13, 'P102', 3200000.00, 2, 'EMPTY', 'Phòng tầng 1, diện tích 28m2, có ban công', 'system', '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.ms_rooms (id, branch_id, room_name, price, max_occupants, status_code, description, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (17, 13, 'P101', 3000000.00, 2, 'EMPTY', 'Phòng tầng 1, diện tích 25m2, có cửa sổ', 'system', '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.ms_rooms (id, branch_id, room_name, price, max_occupants, status_code, description, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (18, 14, 'P201', 3500000.00, 4, 'EMPTY', 'Phòng gia đình, diện tích 40m2', 'system', '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.ms_rooms (id, branch_id, room_name, price, max_occupants, status_code, description, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (19, 14, 'P103', 3000000.00, 3, 'EMPTY', 'Phòng rộng, diện tích 30m2', 'system', '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.ms_rooms (id, branch_id, room_name, price, max_occupants, status_code, description, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (20, 14, 'P102', 2700000.00, 2, 'EMPTY', 'Phòng có gác lửng, diện tích 25m2', 'system', '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.ms_rooms (id, branch_id, room_name, price, max_occupants, status_code, description, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (21, 14, 'P101', 2500000.00, 2, 'EMPTY', 'Phòng đơn giản, diện tích 20m2', 'system', '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.ms_rooms (id, branch_id, room_name, price, max_occupants, status_code, description, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (22, 15, 'P201', 3000000.00, 3, 'EMPTY', 'Phòng rộng, diện tích 28m2, có máy lạnh', 'system', '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.ms_rooms (id, branch_id, room_name, price, max_occupants, status_code, description, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (23, 15, 'P102', 2500000.00, 2, 'EMPTY', 'Phòng tiện nghi, diện tích 22m2', 'system', '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.ms_rooms (id, branch_id, room_name, price, max_occupants, status_code, description, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (24, 15, 'P101', 2200000.00, 2, 'EMPTY', 'Phòng cơ bản, diện tích 18m2', 'system', '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);


--
-- TOC entry 5063 (class 0 OID 26757)
-- Dependencies: 240
-- Data for Name: ms_tenants; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5048 (class 0 OID 26509)
-- Dependencies: 225
-- Data for Name: sy_commons; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.sy_commons (id, type, code, name_vi, name_en, sort_order, is_active, remark, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (124, 'ROOM_STATUS', 'EMPTY', 'Phòng trống', 'Empty', 1, true, 'Phòng đang trống, sẵn sàng cho thuê', NULL, '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.sy_commons (id, type, code, name_vi, name_en, sort_order, is_active, remark, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (125, 'ROOM_STATUS', 'RENTED', 'Đang cho thuê', 'Rented', 2, true, 'Phòng đang có khách thuê', NULL, '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.sy_commons (id, type, code, name_vi, name_en, sort_order, is_active, remark, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (126, 'ROOM_STATUS', 'MAINTENANCE', 'Đang bảo trì', 'Maintenance', 3, true, 'Phòng đang sửa chữa/bảo trì', NULL, '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.sy_commons (id, type, code, name_vi, name_en, sort_order, is_active, remark, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (127, 'CONTRACT_STATUS', 'ACTIVE', 'Đang hiệu lực', 'Active', 1, true, 'Hợp đồng đang có hiệu lực', NULL, '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.sy_commons (id, type, code, name_vi, name_en, sort_order, is_active, remark, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (128, 'CONTRACT_STATUS', 'TERMINATED', 'Đã chấm dứt', 'Terminated', 2, true, 'Hợp đồng đã kết thúc', NULL, '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.sy_commons (id, type, code, name_vi, name_en, sort_order, is_active, remark, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (129, 'CONTRACT_STATUS', 'EXPIRED', 'Đã hết hạn', 'Expired', 3, true, 'Hợp đồng đã hết thời hạn', NULL, '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.sy_commons (id, type, code, name_vi, name_en, sort_order, is_active, remark, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (130, 'INVOICE_STATUS', 'UNPAID', 'Chưa thanh toán', 'Unpaid', 1, true, 'Hóa đơn chưa được thanh toán', NULL, '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.sy_commons (id, type, code, name_vi, name_en, sort_order, is_active, remark, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (131, 'INVOICE_STATUS', 'PARTIAL', 'Thanh toán một phần', 'Partial', 2, true, 'Hóa đơn đã thanh toán một phần', NULL, '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.sy_commons (id, type, code, name_vi, name_en, sort_order, is_active, remark, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (132, 'INVOICE_STATUS', 'PAID', 'Đã thanh toán', 'Paid', 3, true, 'Hóa đơn đã thanh toán đầy đủ', NULL, '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.sy_commons (id, type, code, name_vi, name_en, sort_order, is_active, remark, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (133, 'INVOICE_STATUS', 'OVERDUE', 'Quá hạn', 'Overdue', 4, true, 'Hóa đơn đã quá hạn thanh toán', NULL, '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.sy_commons (id, type, code, name_vi, name_en, sort_order, is_active, remark, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (134, 'INVOICE_STATUS', 'CANCELLED', 'Đã hủy', 'Cancelled', 5, true, 'Hóa đơn đã bị hủy', NULL, '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.sy_commons (id, type, code, name_vi, name_en, sort_order, is_active, remark, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (135, 'INCIDENT_STATUS', 'PENDING', 'Chờ xử lý', 'Pending', 1, true, 'Sự cố chờ được xử lý', NULL, '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.sy_commons (id, type, code, name_vi, name_en, sort_order, is_active, remark, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (136, 'INCIDENT_STATUS', 'IN_PROGRESS', 'Đang xử lý', 'In Progress', 2, true, 'Sự cố đang được xử lý', NULL, '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.sy_commons (id, type, code, name_vi, name_en, sort_order, is_active, remark, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (137, 'INCIDENT_STATUS', 'RESOLVED', 'Đã giải quyết', 'Resolved', 3, true, 'Sự cố đã được giải quyết', NULL, '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.sy_commons (id, type, code, name_vi, name_en, sort_order, is_active, remark, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (138, 'INCIDENT_PRIORITY', 'LOW', 'Thấp', 'Low', 1, true, 'Mức độ ưu tiên thấp', NULL, '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.sy_commons (id, type, code, name_vi, name_en, sort_order, is_active, remark, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (139, 'INCIDENT_PRIORITY', 'MEDIUM', 'Trung bình', 'Medium', 2, true, 'Mức độ ưu tiên trung bình', NULL, '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.sy_commons (id, type, code, name_vi, name_en, sort_order, is_active, remark, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (140, 'INCIDENT_PRIORITY', 'HIGH', 'Cao', 'High', 3, true, 'Mức độ ưu tiên cao', NULL, '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.sy_commons (id, type, code, name_vi, name_en, sort_order, is_active, remark, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (141, 'INCIDENT_PRIORITY', 'CRITICAL', 'Khẩn cấp', 'Critical', 4, true, 'Mức độ ưu tiên khẩn cấp', NULL, '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.sy_commons (id, type, code, name_vi, name_en, sort_order, is_active, remark, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (142, 'GENDER', 'MALE', 'Nam', 'Male', 1, true, NULL, NULL, '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.sy_commons (id, type, code, name_vi, name_en, sort_order, is_active, remark, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (143, 'GENDER', 'FEMALE', 'Nữ', 'Female', 2, true, NULL, NULL, '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.sy_commons (id, type, code, name_vi, name_en, sort_order, is_active, remark, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (144, 'GENDER', 'OTHER', 'Khác', 'Other', 3, true, NULL, NULL, '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.sy_commons (id, type, code, name_vi, name_en, sort_order, is_active, remark, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (145, 'TENANT_STATUS', 'ACTIVE', 'Đang thuê', 'Active', 1, true, 'Người thuê đang ở', NULL, '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.sy_commons (id, type, code, name_vi, name_en, sort_order, is_active, remark, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (146, 'TENANT_STATUS', 'INACTIVE', 'Tạm ngưng', 'Inactive', 2, true, 'Người thuê tạm ngưng', NULL, '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.sy_commons (id, type, code, name_vi, name_en, sort_order, is_active, remark, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (147, 'TENANT_STATUS', 'LEFT', 'Đã rời đi', 'Left', 3, true, 'Người thuê đã chuyển đi', NULL, '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.sy_commons (id, type, code, name_vi, name_en, sort_order, is_active, remark, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (148, 'PAYMENT_METHOD', 'CASH', 'Tiền mặt', 'Cash', 1, true, 'Thanh toán bằng tiền mặt', NULL, '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.sy_commons (id, type, code, name_vi, name_en, sort_order, is_active, remark, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (149, 'PAYMENT_METHOD', 'BANK_TRANSFER', 'Chuyển khoản', 'Bank Transfer', 2, true, 'Thanh toán qua chuyển khoản ngân hàng', NULL, '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.sy_commons (id, type, code, name_vi, name_en, sort_order, is_active, remark, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (150, 'PAYMENT_METHOD', 'MOMO', 'Ví MoMo', 'Momo', 3, true, 'Thanh toán qua ví MoMo', NULL, '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.sy_commons (id, type, code, name_vi, name_en, sort_order, is_active, remark, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (151, 'PAYMENT_METHOD', 'VNPAY', 'VNPay', 'VNPay', 4, true, 'Thanh toán qua VNPay', NULL, '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.sy_commons (id, type, code, name_vi, name_en, sort_order, is_active, remark, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (152, 'TRANSACTION_TYPE', 'CONTRACT', 'Hợp đồng', 'Contract', 1, true, 'Số hợp đồng', NULL, '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.sy_commons (id, type, code, name_vi, name_en, sort_order, is_active, remark, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (153, 'TRANSACTION_TYPE', 'INVOICE', 'Hóa đơn', 'Invoice', 2, true, 'Số hóa đơn', NULL, '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.sy_commons (id, type, code, name_vi, name_en, sort_order, is_active, remark, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (154, 'TRANSACTION_TYPE', 'INCIDENT', 'Sự cố', 'Incident', 3, true, 'Mã sự cố', NULL, '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.sy_commons (id, type, code, name_vi, name_en, sort_order, is_active, remark, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (155, 'MENU_ITEM', 'dashboard', 'Tổng quan', 'Dashboard', 1, true, 'LayoutDashboard', NULL, '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.sy_commons (id, type, code, name_vi, name_en, sort_order, is_active, remark, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (156, 'MENU_ITEM', 'rooms', 'Quản lý phòng', 'Rooms', 2, true, 'DoorOpen', NULL, '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.sy_commons (id, type, code, name_vi, name_en, sort_order, is_active, remark, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (157, 'MENU_ITEM', 'tenants', 'Người thuê', 'Tenants', 3, true, 'Users', NULL, '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.sy_commons (id, type, code, name_vi, name_en, sort_order, is_active, remark, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (158, 'MENU_ITEM', 'contracts', 'Hợp đồng', 'Contracts', 4, true, 'FileText', NULL, '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.sy_commons (id, type, code, name_vi, name_en, sort_order, is_active, remark, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (159, 'MENU_ITEM', 'billing', 'Hóa đơn & Tiền phòng', 'Billing', 5, true, 'Receipt', NULL, '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.sy_commons (id, type, code, name_vi, name_en, sort_order, is_active, remark, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (160, 'MENU_ITEM', 'payments', 'Thanh toán', 'Payments', 6, true, 'CreditCard', NULL, '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.sy_commons (id, type, code, name_vi, name_en, sort_order, is_active, remark, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (161, 'MENU_ITEM', 'incidents', 'Sự cố / Bảo trì', 'Incidents', 7, true, 'AlertTriangle', NULL, '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.sy_commons (id, type, code, name_vi, name_en, sort_order, is_active, remark, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (162, 'MENU_ITEM', 'users', 'Người dùng', 'Users', 8, false, 'UserCog', NULL, '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.sy_commons (id, type, code, name_vi, name_en, sort_order, is_active, remark, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (163, 'MENU_ITEM', 'branches', 'Chi nhánh', 'Branches', 9, false, 'Building2', NULL, '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);
INSERT INTO public.sy_commons (id, type, code, name_vi, name_en, sort_order, is_active, remark, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version) OVERRIDING SYSTEM VALUE VALUES (164, 'MENU_ITEM', 'fee-types', 'Loại phí', 'Fee Types', 10, false, 'Tag', NULL, '2026-07-24 01:21:10.349216', NULL, NULL, 1, NULL, NULL, false, 1);


--
-- TOC entry 5050 (class 0 OID 26525)
-- Dependencies: 227
-- Data for Name: sy_document_settings; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.sy_document_settings (id, transaction_type, prefix, date_format, number_digits, current_number, updated_date, deleted_by, deleted_date, is_deleted, created_by, created_date, updated_by, version) OVERRIDING SYSTEM VALUE VALUES (13, 'CONTRACT', 'HD', 'yyyyMM', 4, 0, NULL, NULL, NULL, false, 'system', '2026-07-24 01:21:10.349216', NULL, 1);
INSERT INTO public.sy_document_settings (id, transaction_type, prefix, date_format, number_digits, current_number, updated_date, deleted_by, deleted_date, is_deleted, created_by, created_date, updated_by, version) OVERRIDING SYSTEM VALUE VALUES (14, 'INVOICE', 'INV', 'yyyyMM', 4, 0, NULL, NULL, NULL, false, 'system', '2026-07-24 01:21:10.349216', NULL, 1);
INSERT INTO public.sy_document_settings (id, transaction_type, prefix, date_format, number_digits, current_number, updated_date, deleted_by, deleted_date, is_deleted, created_by, created_date, updated_by, version) OVERRIDING SYSTEM VALUE VALUES (15, 'INCIDENT', 'SC', 'yyyyMMdd', 3, 0, NULL, NULL, NULL, false, 'system', '2026-07-24 01:21:10.349216', NULL, 1);


--
-- TOC entry 5052 (class 0 OID 26535)
-- Dependencies: 229
-- Data for Name: sy_file_attachments; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5053 (class 0 OID 26547)
-- Dependencies: 230
-- Data for Name: sy_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.sy_permissions (permission_code, permission_name, module, is_deleted, created_by, created_date, updated_by, updated_date, deleted_by, deleted_date, version) VALUES ('ROOM_VIEW', 'Xem danh sách phòng', 'ROOM', false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, NULL, NULL, 1);
INSERT INTO public.sy_permissions (permission_code, permission_name, module, is_deleted, created_by, created_date, updated_by, updated_date, deleted_by, deleted_date, version) VALUES ('ROOM_CREATE', 'Thêm phòng mới', 'ROOM', false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, NULL, NULL, 1);
INSERT INTO public.sy_permissions (permission_code, permission_name, module, is_deleted, created_by, created_date, updated_by, updated_date, deleted_by, deleted_date, version) VALUES ('ROOM_EDIT', 'Sửa thông tin phòng', 'ROOM', false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, NULL, NULL, 1);
INSERT INTO public.sy_permissions (permission_code, permission_name, module, is_deleted, created_by, created_date, updated_by, updated_date, deleted_by, deleted_date, version) VALUES ('ROOM_DELETE', 'Xóa phòng', 'ROOM', false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, NULL, NULL, 1);
INSERT INTO public.sy_permissions (permission_code, permission_name, module, is_deleted, created_by, created_date, updated_by, updated_date, deleted_by, deleted_date, version) VALUES ('TENANT_VIEW', 'Xem người thuê', 'TENANT', false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, NULL, NULL, 1);
INSERT INTO public.sy_permissions (permission_code, permission_name, module, is_deleted, created_by, created_date, updated_by, updated_date, deleted_by, deleted_date, version) VALUES ('TENANT_CREATE', 'Thêm người thuê', 'TENANT', false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, NULL, NULL, 1);
INSERT INTO public.sy_permissions (permission_code, permission_name, module, is_deleted, created_by, created_date, updated_by, updated_date, deleted_by, deleted_date, version) VALUES ('TENANT_EDIT', 'Sửa người thuê', 'TENANT', false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, NULL, NULL, 1);
INSERT INTO public.sy_permissions (permission_code, permission_name, module, is_deleted, created_by, created_date, updated_by, updated_date, deleted_by, deleted_date, version) VALUES ('TENANT_DELETE', 'Xóa người thuê', 'TENANT', false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, NULL, NULL, 1);
INSERT INTO public.sy_permissions (permission_code, permission_name, module, is_deleted, created_by, created_date, updated_by, updated_date, deleted_by, deleted_date, version) VALUES ('CONTRACT_VIEW', 'Xem hợp đồng', 'CONTRACT', false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, NULL, NULL, 1);
INSERT INTO public.sy_permissions (permission_code, permission_name, module, is_deleted, created_by, created_date, updated_by, updated_date, deleted_by, deleted_date, version) VALUES ('CONTRACT_CREATE', 'Tạo hợp đồng', 'CONTRACT', false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, NULL, NULL, 1);
INSERT INTO public.sy_permissions (permission_code, permission_name, module, is_deleted, created_by, created_date, updated_by, updated_date, deleted_by, deleted_date, version) VALUES ('CONTRACT_TERMINATE', 'Chấm dứt hợp đồng', 'CONTRACT', false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, NULL, NULL, 1);
INSERT INTO public.sy_permissions (permission_code, permission_name, module, is_deleted, created_by, created_date, updated_by, updated_date, deleted_by, deleted_date, version) VALUES ('INVOICE_VIEW', 'Xem hóa đơn', 'INVOICE', false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, NULL, NULL, 1);
INSERT INTO public.sy_permissions (permission_code, permission_name, module, is_deleted, created_by, created_date, updated_by, updated_date, deleted_by, deleted_date, version) VALUES ('INVOICE_CREATE', 'Tạo hóa đơn', 'INVOICE', false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, NULL, NULL, 1);
INSERT INTO public.sy_permissions (permission_code, permission_name, module, is_deleted, created_by, created_date, updated_by, updated_date, deleted_by, deleted_date, version) VALUES ('PAYMENT_VIEW', 'Xem thanh toán', 'PAYMENT', false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, NULL, NULL, 1);
INSERT INTO public.sy_permissions (permission_code, permission_name, module, is_deleted, created_by, created_date, updated_by, updated_date, deleted_by, deleted_date, version) VALUES ('PAYMENT_CREATE', 'Ghi nhận thanh toán', 'PAYMENT', false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, NULL, NULL, 1);
INSERT INTO public.sy_permissions (permission_code, permission_name, module, is_deleted, created_by, created_date, updated_by, updated_date, deleted_by, deleted_date, version) VALUES ('INCIDENT_VIEW', 'Xem sự cố', 'INCIDENT', false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, NULL, NULL, 1);
INSERT INTO public.sy_permissions (permission_code, permission_name, module, is_deleted, created_by, created_date, updated_by, updated_date, deleted_by, deleted_date, version) VALUES ('INCIDENT_CREATE', 'Báo sự cố', 'INCIDENT', false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, NULL, NULL, 1);
INSERT INTO public.sy_permissions (permission_code, permission_name, module, is_deleted, created_by, created_date, updated_by, updated_date, deleted_by, deleted_date, version) VALUES ('INCIDENT_RESOLVE', 'Xử lý sự cố', 'INCIDENT', false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, NULL, NULL, 1);
INSERT INTO public.sy_permissions (permission_code, permission_name, module, is_deleted, created_by, created_date, updated_by, updated_date, deleted_by, deleted_date, version) VALUES ('USER_VIEW', 'Xem người dùng', 'USER', false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, NULL, NULL, 1);
INSERT INTO public.sy_permissions (permission_code, permission_name, module, is_deleted, created_by, created_date, updated_by, updated_date, deleted_by, deleted_date, version) VALUES ('USER_CREATE', 'Thêm người dùng', 'USER', false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, NULL, NULL, 1);
INSERT INTO public.sy_permissions (permission_code, permission_name, module, is_deleted, created_by, created_date, updated_by, updated_date, deleted_by, deleted_date, version) VALUES ('USER_EDIT', 'Sửa người dùng', 'USER', false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, NULL, NULL, 1);
INSERT INTO public.sy_permissions (permission_code, permission_name, module, is_deleted, created_by, created_date, updated_by, updated_date, deleted_by, deleted_date, version) VALUES ('USER_DELETE', 'Xóa người dùng', 'USER', false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, NULL, NULL, 1);
INSERT INTO public.sy_permissions (permission_code, permission_name, module, is_deleted, created_by, created_date, updated_by, updated_date, deleted_by, deleted_date, version) VALUES ('REPORT_VIEW', 'Xem báo cáo', 'REPORT', false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, NULL, NULL, 1);
INSERT INTO public.sy_permissions (permission_code, permission_name, module, is_deleted, created_by, created_date, updated_by, updated_date, deleted_by, deleted_date, version) VALUES ('CONFIG_EDIT', 'Cấu hình hệ thống', 'CONFIG', false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, NULL, NULL, 1);


--
-- TOC entry 5054 (class 0 OID 26557)
-- Dependencies: 231
-- Data for Name: sy_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.sy_roles (role_code, role_name, is_system, deleted_by, deleted_date, is_deleted, created_by, created_date, updated_by, updated_date, version) VALUES ('SYSADMIN', 'Quản trị hệ thống', true, NULL, NULL, false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, 1);
INSERT INTO public.sy_roles (role_code, role_name, is_system, deleted_by, deleted_date, is_deleted, created_by, created_date, updated_by, updated_date, version) VALUES ('MANAGER', 'Quản lý', true, NULL, NULL, false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, 1);
INSERT INTO public.sy_roles (role_code, role_name, is_system, deleted_by, deleted_date, is_deleted, created_by, created_date, updated_by, updated_date, version) VALUES ('STAFF', 'Nhân viên', true, NULL, NULL, false, 'system', '2026-07-24 01:21:10.349216', NULL, NULL, 1);


--
-- TOC entry 5055 (class 0 OID 26568)
-- Dependencies: 232
-- Data for Name: sy_users; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.sy_users (id, username, password_hash, full_name, email, phone, role_code, avatar_id, is_active, last_login, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version, refresh_token, refresh_token_expiry) OVERRIDING SYSTEM VALUE VALUES (8, 'manager', '$2a$11$9LWeFQBtqOJEb23u32D41uoExmIH1IhbeU3lYK5Y/vemDzfZKTMFC', 'Nguyễn Văn A', 'manager@rental.local', '0900000002', 'MANAGER', NULL, true, NULL, 'system', '2026-07-24 01:21:10.349216', 'system', NULL, 1, NULL, NULL, false, 1, NULL, NULL);
INSERT INTO public.sy_users (id, username, password_hash, full_name, email, phone, role_code, avatar_id, is_active, last_login, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version, refresh_token, refresh_token_expiry) OVERRIDING SYSTEM VALUE VALUES (9, 'staff', '$2a$11$9LWeFQBtqOJEb23u32D41uoExmIH1IhbeU3lYK5Y/vemDzfZKTMFC', 'Trần Thị B', 'staff@rental.local', '0900000003', 'STAFF', NULL, true, NULL, 'system', '2026-07-24 01:21:10.349216', 'system', NULL, 1, NULL, NULL, false, 1, NULL, NULL);
INSERT INTO public.sy_users (id, username, password_hash, full_name, email, phone, role_code, avatar_id, is_active, last_login, created_by, created_date, updated_by, updated_date, data_row_version, deleted_by, deleted_date, is_deleted, version, refresh_token, refresh_token_expiry) OVERRIDING SYSTEM VALUE VALUES (7, 'admin', '$2b$12$FSzjWl.zRnIrCDi.1VdweOLhl1vXBBauJVsA0LlNsiUqNDQIMW1py', 'Quản trị viên', 'admin@rental.local', '0900000001', 'SYSADMIN', NULL, true, '2026-07-24 02:00:35.758307', 'system', '2026-07-24 22:21:10.349216', 'System', '2026-07-24 02:00:35.790234', 1, NULL, NULL, false, 4, 'fkhVVq3tYx2F73yEiHCfNLO5HpMy4OHISjEzmRTCZ3g=', '2026-07-31 02:00:35.758185');


--
-- TOC entry 5058 (class 0 OID 26589)
-- Dependencies: 235
-- Data for Name: tr_contracts; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5057 (class 0 OID 26583)
-- Dependencies: 234
-- Data for Name: tr_contract_details; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5060 (class 0 OID 26602)
-- Dependencies: 237
-- Data for Name: tr_incidents; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5066 (class 0 OID 26975)
-- Dependencies: 243
-- Data for Name: tr_invoices; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5062 (class 0 OID 26615)
-- Dependencies: 239
-- Data for Name: tr_invoice_items; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5068 (class 0 OID 26987)
-- Dependencies: 245
-- Data for Name: tr_payments; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5070 (class 0 OID 26999)
-- Dependencies: 247
-- Data for Name: tr_utility_readings; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5077 (class 0 OID 0)
-- Dependencies: 220
-- Name: ms_branches_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ms_branches_id_seq', 15, true);


--
-- TOC entry 5078 (class 0 OID 0)
-- Dependencies: 222
-- Name: ms_fee_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ms_fee_types_id_seq', 17, true);


--
-- TOC entry 5079 (class 0 OID 0)
-- Dependencies: 224
-- Name: ms_rooms_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ms_rooms_id_seq', 24, true);


--
-- TOC entry 5080 (class 0 OID 0)
-- Dependencies: 241
-- Name: ms_tenants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ms_tenants_id_seq', 1, false);


--
-- TOC entry 5081 (class 0 OID 0)
-- Dependencies: 226
-- Name: sy_commons_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sy_commons_id_seq', 164, true);


--
-- TOC entry 5082 (class 0 OID 0)
-- Dependencies: 228
-- Name: sy_document_settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sy_document_settings_id_seq', 15, true);


--
-- TOC entry 5083 (class 0 OID 0)
-- Dependencies: 233
-- Name: sy_users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sy_users_id_seq', 9, true);


--
-- TOC entry 5084 (class 0 OID 0)
-- Dependencies: 236
-- Name: tr_contracts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tr_contracts_id_seq', 1, false);


--
-- TOC entry 5085 (class 0 OID 0)
-- Dependencies: 238
-- Name: tr_incidents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tr_incidents_id_seq', 1, false);


--
-- TOC entry 5086 (class 0 OID 0)
-- Dependencies: 242
-- Name: tr_invoice_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tr_invoice_items_id_seq', 1, false);


--
-- TOC entry 5087 (class 0 OID 0)
-- Dependencies: 244
-- Name: tr_invoices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tr_invoices_id_seq', 1, false);


--
-- TOC entry 5088 (class 0 OID 0)
-- Dependencies: 246
-- Name: tr_payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tr_payments_id_seq', 1, false);


--
-- TOC entry 5089 (class 0 OID 0)
-- Dependencies: 248
-- Name: tr_utility_readings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tr_utility_readings_id_seq', 1, false);


-- Completed on 2026-07-24 10:39:03

--
-- PostgreSQL database dump complete
--

\unrestrict byxwXDyzFRuJlueUQWKDDSnVa3tv50y4A2ephlupZsTpxoSujWfxCfqOVoJVxCm

