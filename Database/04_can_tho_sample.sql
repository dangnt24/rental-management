-- DVP HOME: DỮ LIỆU MẪU CẦN THƠ, kỳ 08–10/2026; sinh bằng tools/generate-can-tho-sample.mjs.
-- Toàn bộ người, khu trọ, hẻm/số nhà, hồ sơ và mức tiền là HƯ CẤU; không phải giá thị trường/biểu giá điện nước.
-- Tên phường tham chiếu nguồn Cần Thơ; tên khu vực cũ ghi chú để dễ nhận biết, không dùng tên quận cũ trong địa chỉ hành chính.
-- Nguồn địa danh: https://pbgdpl.cantho.gov.vn/chi-tiet-103-don-vi-hanh-chinh-cua-thanh-pho-can-tho-sau-hop-nhat
-- Điện thoại/CCCD dùng mã CT-DEMO cố ý không phải số thật; ảnh/file để trống, không tạo tham chiếu file không tồn tại.
-- Bổ sung 6 khu, 36 phòng (18 đang thuê, 12 trống, 6 sửa), 42 hồ sơ người thuê, 7 Manager + 42 Tenant; không tạo Owner.
-- Có 24 hợp đồng (18 Active, 6 Closed), 54 hóa đơn (48 Issued, 6 Cancelled), 24 sự cố.
-- NẠP: đứng tại thư mục Source, chạy lệnh sau (file tự BEGIN/COMMIT):
-- psql -h localhost -U postgres -d rental_management -v ON_ERROR_STOP=1 -f .\Database\04_can_tho_sample.sql
-- Database trống: chạy 01_schema.sql rồi 02_sample.sql để có Owner admin trước; bộ này không tạo Owner.
-- Database Source cũ: chạy 03_public_tenant.sql trước nếu chưa nâng cấp. Không dùng cho SQL V2 trong Document.
-- Bản có chi tiết phòng: database Source hiện có cần chạy 05_room_details.sql trước file này.
-- Nạp bổ sung, không UPDATE/DELETE/TRUNCATE dữ liệu cũ; ID lấy từ sequence, không gán cứng/chỉnh lùi sequence.
-- Nạp lại thấy audit marker thì bỏ qua toàn bộ (không reset mật khẩu/khôi phục demo đã sửa).
-- Nếu trùng tên đăng nhập hoặc tên khu có sẵn mà chưa có marker: báo lỗi và rollback toàn bộ.
-- Đây là file bổ sung thủ công: SeedDemo/Start.ps1/Docker không tự nạp file này. Không thay 02_sample.sql.
-- Chỉ tạo file chưa làm thay đổi database thật. Sau khi nạp: đăng xuất/đăng nhập hoặc tải lại trang.
-- MẬT KHẨU DEMO CHUNG: CanTho@123456; mỗi tài khoản có salt ngẫu nhiên và hash ASP.NET Identity V3 riêng.
-- DANH SÁCH QUẢN LÝ (mỗi tài khoản chỉ có quyền khu đã gán):
-- ct_ql_nk | Nguyễn Thị Thanh Hương | DVP Ninh Kiều - Khu trọ mẫu CT (Xuân Khánh trước đây)
-- ct_ql_ta | Trần Quốc Bảo | DVP Tân An - Khu trọ mẫu CT (Hưng Lợi trước đây)
-- ct_ql_ck | Lê Thị Kim Ngân | DVP Cái Khế - Khu trọ mẫu CT (Cái Khế trước đây)
-- ct_ql_bt | Phạm Văn Thành | DVP Bình Thủy - Khu trọ mẫu CT (An Thới trước đây)
-- ct_ql_cr | Võ Thị Mỹ Duyên | DVP Cái Răng - Khu trọ mẫu CT (Lê Bình trước đây)
-- ct_ql_om | Đặng Minh Tuấn | DVP Ô Môn - Khu trọ mẫu CT (Châu Văn Liêm trước đây)
-- ct_ql_lienkhu | Nguyễn Minh Quân | 3 khu Ninh Kiều + Tân An + Cái Khế.
-- DANH SÁCH NGƯỜI THUÊ (ct_<mã khu>_<số thứ tự>):
-- 01+02: cùng P.101, 01 đại diện; hóa đơn đã trả đủ; 01 có yêu cầu sửa Open.
-- 03: P.102, thiếu 500.000đ cọc, hóa đơn T10 trả 2 đợt còn nợ/quá hạn; có lịch sử hủy hóa đơn; sửa InProgress.
-- 04+05: cùng P.103, 04 đại diện; chưa trả T10, sắp hết hạn 31/10; 04 có sửa chữa Resolved.
-- 06: đã trả P.104 ngày 30/09, xem lịch sử hóa đơn/cọc/hoàn cọc; không được gửi sự cố mới từ hợp đồng Closed.
-- 07: mới tạo hồ sơ, chưa có hợp đồng; portal trống đúng nghiệp vụ.
-- ct_nk_01 | Nguyễn Hoàng Phúc | Ninh Kiều | P.101
-- ct_nk_02 | Trần Ngọc Hân | Ninh Kiều | P.101
-- ct_nk_03 | Lê Minh Khang | Ninh Kiều | P.102
-- ct_nk_04 | Phạm Thị Bích Trâm | Ninh Kiều | P.103
-- ct_nk_05 | Võ Thanh Tùng | Ninh Kiều | P.103
-- ct_nk_06 | Đặng Thị Thu Thảo | Ninh Kiều | đã trả P.104
-- ct_nk_07 | Bùi Gia Bảo | Ninh Kiều | chưa thuê
-- ct_ta_01 | Trần Anh Duy | Tân An | P.101
-- ct_ta_02 | Nguyễn Thị Quỳnh Như | Tân An | P.101
-- ct_ta_03 | Võ Minh Tâm | Tân An | P.102
-- ct_ta_04 | Lê Thị Thanh Trúc | Tân An | P.103
-- ct_ta_05 | Phạm Quốc Huy | Tân An | P.103
-- ct_ta_06 | Huỳnh Mỹ Linh | Tân An | đã trả P.104
-- ct_ta_07 | Đỗ Bảo Châu | Tân An | chưa thuê
-- ct_ck_01 | Lê Quốc Khánh | Cái Khế | P.101
-- ct_ck_02 | Phan Thị Ngọc Ánh | Cái Khế | P.101
-- ct_ck_03 | Nguyễn Hữu Đạt | Cái Khế | P.102
-- ct_ck_04 | Trần Thị Hải Yến | Cái Khế | P.103
-- ct_ck_05 | Võ Đức Hòa | Cái Khế | P.103
-- ct_ck_06 | Bùi Thanh Loan | Cái Khế | đã trả P.104
-- ct_ck_07 | Đặng Nhật Minh | Cái Khế | chưa thuê
-- ct_bt_01 | Phạm Minh Thiện | Bình Thủy | P.101
-- ct_bt_02 | Nguyễn Thị Kiều Oanh | Bình Thủy | P.101
-- ct_bt_03 | Trần Thanh Sơn | Bình Thủy | P.102
-- ct_bt_04 | Huỳnh Thị Hồng Nhung | Bình Thủy | P.103
-- ct_bt_05 | Lê Anh Kiệt | Bình Thủy | P.103
-- ct_bt_06 | Võ Thị Thúy An | Bình Thủy | đã trả P.104
-- ct_bt_07 | Phan Tuấn Vũ | Bình Thủy | chưa thuê
-- ct_cr_01 | Võ Hoàng Nam | Cái Răng | P.101
-- ct_cr_02 | Trần Thị Kim Chi | Cái Răng | P.101
-- ct_cr_03 | Nguyễn Thành Đạt | Cái Răng | P.102
-- ct_cr_04 | Lê Thị Phương Thảo | Cái Răng | P.103
-- ct_cr_05 | Đặng Thanh Bình | Cái Răng | P.103
-- ct_cr_06 | Phạm Ngọc Diễm | Cái Răng | đã trả P.104
-- ct_cr_07 | Huỳnh Gia Hân | Cái Răng | chưa thuê
-- ct_om_01 | Đặng Hữu Nghĩa | Ô Môn | P.101
-- ct_om_02 | Võ Thị Ngọc Mai | Ô Môn | P.101
-- ct_om_03 | Nguyễn Minh Trí | Ô Môn | P.102
-- ct_om_04 | Trần Thị Cẩm Tú | Ô Môn | P.103
-- ct_om_05 | Lê Văn Hiếu | Ô Môn | P.103
-- ct_om_06 | Phan Thị Mỹ Tiên | Ô Môn | đã trả P.104
-- ct_om_07 | Bùi Hoàng Long | Ô Môn | chưa thuê
-- Khách chưa đăng nhập: thấy 12 phòng trống của bộ này (cộng phòng trống dữ liệu cũ nếu có).
-- Có thể đăng nhập ngay ct_ql_nk / ct_nk_01 / ct_nk_03 / ct_nk_06 / ct_nk_07 để xem các tình huống khác nhau.

BEGIN;
SELECT pg_advisory_xact_lock(hashtext('demo.cantho.2026-10.v1'));
CREATE TEMP TABLE ct_seed_ids (entity text, seed_key text, actual_id integer, PRIMARY KEY (entity, seed_key)) ON COMMIT DROP;
DO $ct_seed$
DECLARE
  dataset jsonb := $ct_data${
  "branches": [
    {
      "key": "nk",
      "Name": "DVP Ninh Kiều - Khu trọ mẫu CT",
      "Address": "Hẻm mô phỏng CT-1, khu vực Đường 3 Tháng 2, phường Ninh Kiều, TP. Cần Thơ (địa chỉ hư cấu; khu vực Xuân Khánh trước đây)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta",
      "Name": "DVP Tân An - Khu trọ mẫu CT",
      "Address": "Hẻm mô phỏng CT-2, khu vực Đường 30 Tháng 4, phường Tân An, TP. Cần Thơ (địa chỉ hư cấu; khu vực Hưng Lợi trước đây)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck",
      "Name": "DVP Cái Khế - Khu trọ mẫu CT",
      "Address": "Hẻm mô phỏng CT-3, khu vực Đường Trần Văn Khéo, phường Cái Khế, TP. Cần Thơ (địa chỉ hư cấu; khu vực Cái Khế trước đây)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt",
      "Name": "DVP Bình Thủy - Khu trọ mẫu CT",
      "Address": "Hẻm mô phỏng CT-4, khu vực Đường Cách Mạng Tháng 8, phường Bình Thủy, TP. Cần Thơ (địa chỉ hư cấu; khu vực An Thới trước đây)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr",
      "Name": "DVP Cái Răng - Khu trọ mẫu CT",
      "Address": "Hẻm mô phỏng CT-5, khu vực Đường Võ Tánh, phường Cái Răng, TP. Cần Thơ (địa chỉ hư cấu; khu vực Lê Bình trước đây)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om",
      "Name": "DVP Ô Môn - Khu trọ mẫu CT",
      "Address": "Hẻm mô phỏng CT-6, khu vực Đường Trần Hưng Đạo, phường Ô Môn, TP. Cần Thơ (địa chỉ hư cấu; khu vực Châu Văn Liêm trước đây)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    }
  ],
  "rooms": [
    {
      "key": "nk_p1",
      "BranchId": "nk",
      "Name": "P.101",
      "Price": 2600000,
      "Capacity": 2,
      "IsMaintenance": false,
      "Description": "Phòng 22 m², có gác lửng và bếp riêng; hai sinh viên ở ghép. Nhóm khách phù hợp: Sinh viên, nhân viên văn phòng. Nội dung và tiện ích giả lập.",
      "Area": 22,
      "Floor": "Trệt",
      "RoomType": "Room",
      "Amenities": [
        "Wifi",
        "Kitchen",
        "Mezzanine",
        "Wardrobe"
      ],
      "AmenitiesConfirmed": true,
      "ToiletType": "Private",
      "AccessHours": "Tự do; giữ yên tĩnh sau 22:00, báo quản lý khi có khách ở lại (quy định mẫu).",
      "LaundryType": "Shared",
      "ParkingType": "Shared",
      "MaxVehicles": 2,
      "PetsAllowed": false,
      "ElectricVehiclesAllowed": false,
      "HasWindow": true,
      "HasBalcony": false,
      "SuggestedDeposit": 2600000,
      "MinimumLeaseMonths": 6,
      "Neighborhood": "Khu vực Xuân Khánh, phường Ninh Kiều, TP. Cần Thơ. Mô tả mẫu: kết nối Đường 3 Tháng 2, có nhu cầu ăn uống, mua sắm và đi học/đi làm trong khu vực. Chưa khảo sát khoảng cách hoặc thời gian di chuyển thực tế.",
      "RentalConditions": "Dữ liệu giả lập phục vụ demo. Tiền thuê tính đủ tháng. Điện, nước, internet và vệ sinh theo đơn giá được công bố của khu. Phí giữ xe và giặt sấy chưa công bố, cần xác nhận trước khi nhận phòng. Báo trước khi trả phòng theo thỏa thuận trong hợp đồng.",
      "ContactName": "Ban quản lý DVP Ninh Kiều (mẫu)",
      "ContactPhone": "",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_p2",
      "BranchId": "nk",
      "Name": "P.102",
      "Price": 2400000,
      "Capacity": 2,
      "IsMaintenance": false,
      "Description": "Phòng 18 m², cửa sổ thoáng, nhà vệ sinh riêng; phù hợp ở một người. Nhóm khách phù hợp: Sinh viên, nhân viên văn phòng. Nội dung và tiện ích giả lập.",
      "Area": 18,
      "Floor": "Trệt",
      "RoomType": "Room",
      "Amenities": [
        "Wifi",
        "Kitchen",
        "Bed",
        "Mattress"
      ],
      "AmenitiesConfirmed": true,
      "ToiletType": "Private",
      "AccessHours": "Tự do; giữ yên tĩnh sau 22:00, báo quản lý khi có khách ở lại (quy định mẫu).",
      "LaundryType": "Shared",
      "ParkingType": "Shared",
      "MaxVehicles": 2,
      "PetsAllowed": false,
      "ElectricVehiclesAllowed": false,
      "HasWindow": true,
      "HasBalcony": false,
      "SuggestedDeposit": 2400000,
      "MinimumLeaseMonths": 3,
      "Neighborhood": "Khu vực Xuân Khánh, phường Ninh Kiều, TP. Cần Thơ. Mô tả mẫu: kết nối Đường 3 Tháng 2, có nhu cầu ăn uống, mua sắm và đi học/đi làm trong khu vực. Chưa khảo sát khoảng cách hoặc thời gian di chuyển thực tế.",
      "RentalConditions": "Dữ liệu giả lập phục vụ demo. Tiền thuê tính đủ tháng. Điện, nước, internet và vệ sinh theo đơn giá được công bố của khu. Phí giữ xe và giặt sấy chưa công bố, cần xác nhận trước khi nhận phòng. Báo trước khi trả phòng theo thỏa thuận trong hợp đồng.",
      "ContactName": "Ban quản lý DVP Ninh Kiều (mẫu)",
      "ContactPhone": "",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_p3",
      "BranchId": "nk",
      "Name": "P.103",
      "Price": 2900000,
      "Capacity": 3,
      "IsMaintenance": false,
      "Description": "Phòng 26 m², có gác, sân phơi dùng chung; hai người đi làm ở cùng. Nhóm khách phù hợp: Sinh viên, nhân viên văn phòng. Nội dung và tiện ích giả lập.",
      "Area": 26,
      "Floor": "Tầng 1",
      "RoomType": "Room",
      "Amenities": [
        "Wifi",
        "Kitchen",
        "Mezzanine",
        "Wardrobe"
      ],
      "AmenitiesConfirmed": true,
      "ToiletType": "Private",
      "AccessHours": "Tự do; giữ yên tĩnh sau 22:00, báo quản lý khi có khách ở lại (quy định mẫu).",
      "LaundryType": "Shared",
      "ParkingType": "Shared",
      "MaxVehicles": 3,
      "PetsAllowed": false,
      "ElectricVehiclesAllowed": false,
      "HasWindow": true,
      "HasBalcony": true,
      "SuggestedDeposit": 2900000,
      "MinimumLeaseMonths": 6,
      "Neighborhood": "Khu vực Xuân Khánh, phường Ninh Kiều, TP. Cần Thơ. Mô tả mẫu: kết nối Đường 3 Tháng 2, có nhu cầu ăn uống, mua sắm và đi học/đi làm trong khu vực. Chưa khảo sát khoảng cách hoặc thời gian di chuyển thực tế.",
      "RentalConditions": "Dữ liệu giả lập phục vụ demo. Tiền thuê tính đủ tháng. Điện, nước, internet và vệ sinh theo đơn giá được công bố của khu. Phí giữ xe và giặt sấy chưa công bố, cần xác nhận trước khi nhận phòng. Báo trước khi trả phòng theo thỏa thuận trong hợp đồng.",
      "ContactName": "Ban quản lý DVP Ninh Kiều (mẫu)",
      "ContactPhone": "",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_p4",
      "BranchId": "nk",
      "Name": "P.104",
      "Price": 2700000,
      "Capacity": 2,
      "IsMaintenance": false,
      "Description": "Phòng 24 m² vừa bàn giao và vệ sinh; có bếp, gác và chỗ để xe. Nhóm khách phù hợp: Sinh viên, nhân viên văn phòng. Nội dung và tiện ích giả lập.",
      "Area": 24,
      "Floor": "Trệt",
      "RoomType": "Room",
      "Amenities": [
        "Wifi",
        "Kitchen",
        "Mezzanine",
        "Wardrobe",
        "AirConditioner",
        "WaterHeater"
      ],
      "AmenitiesConfirmed": true,
      "ToiletType": "Private",
      "AccessHours": "Tự do; giữ yên tĩnh sau 22:00, báo quản lý khi có khách ở lại (quy định mẫu).",
      "LaundryType": "Shared",
      "ParkingType": "Shared",
      "MaxVehicles": 2,
      "PetsAllowed": false,
      "ElectricVehiclesAllowed": false,
      "HasWindow": true,
      "HasBalcony": false,
      "SuggestedDeposit": 2700000,
      "MinimumLeaseMonths": 6,
      "Neighborhood": "Khu vực Xuân Khánh, phường Ninh Kiều, TP. Cần Thơ. Mô tả mẫu: kết nối Đường 3 Tháng 2, có nhu cầu ăn uống, mua sắm và đi học/đi làm trong khu vực. Chưa khảo sát khoảng cách hoặc thời gian di chuyển thực tế.",
      "RentalConditions": "Dữ liệu giả lập phục vụ demo. Tiền thuê tính đủ tháng. Điện, nước, internet và vệ sinh theo đơn giá được công bố của khu. Phí giữ xe và giặt sấy chưa công bố, cần xác nhận trước khi nhận phòng. Báo trước khi trả phòng theo thỏa thuận trong hợp đồng.",
      "ContactName": "Ban quản lý DVP Ninh Kiều (mẫu)",
      "ContactPhone": "",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_p5",
      "BranchId": "nk",
      "Name": "P.105",
      "Price": 2500000,
      "Capacity": 2,
      "IsMaintenance": false,
      "Description": "Phòng 20 m², lối đi riêng, cửa sổ và khu bếp; đang sẵn sàng nhận khách. Nhóm khách phù hợp: Sinh viên, nhân viên văn phòng. Nội dung và tiện ích giả lập.",
      "Area": 20,
      "Floor": "Tầng 1",
      "RoomType": "Room",
      "Amenities": [
        "Wifi",
        "Kitchen",
        "Bed",
        "Mattress"
      ],
      "AmenitiesConfirmed": true,
      "ToiletType": "Private",
      "AccessHours": "Tự do; giữ yên tĩnh sau 22:00, báo quản lý khi có khách ở lại (quy định mẫu).",
      "LaundryType": "Shared",
      "ParkingType": "Shared",
      "MaxVehicles": 2,
      "PetsAllowed": true,
      "ElectricVehiclesAllowed": false,
      "HasWindow": true,
      "HasBalcony": false,
      "SuggestedDeposit": 2500000,
      "MinimumLeaseMonths": 6,
      "Neighborhood": "Khu vực Xuân Khánh, phường Ninh Kiều, TP. Cần Thơ. Mô tả mẫu: kết nối Đường 3 Tháng 2, có nhu cầu ăn uống, mua sắm và đi học/đi làm trong khu vực. Chưa khảo sát khoảng cách hoặc thời gian di chuyển thực tế.",
      "RentalConditions": "Dữ liệu giả lập phục vụ demo. Tiền thuê tính đủ tháng. Điện, nước, internet và vệ sinh theo đơn giá được công bố của khu. Phí giữ xe và giặt sấy chưa công bố, cần xác nhận trước khi nhận phòng. Báo trước khi trả phòng theo thỏa thuận trong hợp đồng.",
      "ContactName": "Ban quản lý DVP Ninh Kiều (mẫu)",
      "ContactPhone": "",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_p6",
      "BranchId": "nk",
      "Name": "P.106",
      "Price": 2600000,
      "Capacity": 2,
      "IsMaintenance": true,
      "Description": "Phòng 22 m² đang chống thấm và thay thiết bị vệ sinh, chưa nhận khách. Nhóm khách phù hợp: Sinh viên, nhân viên văn phòng. Nội dung và tiện ích giả lập.",
      "Area": 22,
      "Floor": "Trệt",
      "RoomType": "Room",
      "Amenities": [
        "Wifi",
        "Kitchen",
        "Bed",
        "Mattress"
      ],
      "AmenitiesConfirmed": true,
      "ToiletType": "Private",
      "AccessHours": "Tự do; giữ yên tĩnh sau 22:00, báo quản lý khi có khách ở lại (quy định mẫu).",
      "LaundryType": "Shared",
      "ParkingType": "Shared",
      "MaxVehicles": 2,
      "PetsAllowed": false,
      "ElectricVehiclesAllowed": false,
      "HasWindow": true,
      "HasBalcony": false,
      "SuggestedDeposit": 2600000,
      "MinimumLeaseMonths": 6,
      "Neighborhood": "Khu vực Xuân Khánh, phường Ninh Kiều, TP. Cần Thơ. Mô tả mẫu: kết nối Đường 3 Tháng 2, có nhu cầu ăn uống, mua sắm và đi học/đi làm trong khu vực. Chưa khảo sát khoảng cách hoặc thời gian di chuyển thực tế.",
      "RentalConditions": "Dữ liệu giả lập phục vụ demo. Tiền thuê tính đủ tháng. Điện, nước, internet và vệ sinh theo đơn giá được công bố của khu. Phí giữ xe và giặt sấy chưa công bố, cần xác nhận trước khi nhận phòng. Báo trước khi trả phòng theo thỏa thuận trong hợp đồng.",
      "ContactName": "Ban quản lý DVP Ninh Kiều (mẫu)",
      "ContactPhone": "",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_p1",
      "BranchId": "ta",
      "Name": "P.101",
      "Price": 2300000,
      "Capacity": 2,
      "IsMaintenance": false,
      "Description": "Phòng 22 m², có gác lửng và bếp riêng; hai sinh viên ở ghép. Nhóm khách phù hợp: Sinh viên, người đi làm. Nội dung và tiện ích giả lập.",
      "Area": 22,
      "Floor": "Trệt",
      "RoomType": "Room",
      "Amenities": [
        "Wifi",
        "Kitchen",
        "Mezzanine",
        "Wardrobe"
      ],
      "AmenitiesConfirmed": true,
      "ToiletType": "Private",
      "AccessHours": "Tự do; giữ yên tĩnh sau 22:00, báo quản lý khi có khách ở lại (quy định mẫu).",
      "LaundryType": "Shared",
      "ParkingType": "Shared",
      "MaxVehicles": 2,
      "PetsAllowed": false,
      "ElectricVehiclesAllowed": false,
      "HasWindow": true,
      "HasBalcony": false,
      "SuggestedDeposit": 2300000,
      "MinimumLeaseMonths": 6,
      "Neighborhood": "Khu vực Hưng Lợi, phường Tân An, TP. Cần Thơ. Mô tả mẫu: kết nối Đường 30 Tháng 4, có nhu cầu ăn uống, mua sắm và đi học/đi làm trong khu vực. Chưa khảo sát khoảng cách hoặc thời gian di chuyển thực tế.",
      "RentalConditions": "Dữ liệu giả lập phục vụ demo. Tiền thuê tính đủ tháng. Điện, nước, internet và vệ sinh theo đơn giá được công bố của khu. Phí giữ xe và giặt sấy chưa công bố, cần xác nhận trước khi nhận phòng. Báo trước khi trả phòng theo thỏa thuận trong hợp đồng.",
      "ContactName": "Ban quản lý DVP Tân An (mẫu)",
      "ContactPhone": "",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_p2",
      "BranchId": "ta",
      "Name": "P.102",
      "Price": 2100000,
      "Capacity": 2,
      "IsMaintenance": false,
      "Description": "Phòng 18 m², cửa sổ thoáng, nhà vệ sinh riêng; phù hợp ở một người. Nhóm khách phù hợp: Sinh viên, người đi làm. Nội dung và tiện ích giả lập.",
      "Area": 18,
      "Floor": "Trệt",
      "RoomType": "Room",
      "Amenities": [
        "Wifi",
        "Kitchen",
        "Bed",
        "Mattress"
      ],
      "AmenitiesConfirmed": true,
      "ToiletType": "Private",
      "AccessHours": "Tự do; giữ yên tĩnh sau 22:00, báo quản lý khi có khách ở lại (quy định mẫu).",
      "LaundryType": "Shared",
      "ParkingType": "Shared",
      "MaxVehicles": 2,
      "PetsAllowed": false,
      "ElectricVehiclesAllowed": false,
      "HasWindow": true,
      "HasBalcony": false,
      "SuggestedDeposit": 2100000,
      "MinimumLeaseMonths": 3,
      "Neighborhood": "Khu vực Hưng Lợi, phường Tân An, TP. Cần Thơ. Mô tả mẫu: kết nối Đường 30 Tháng 4, có nhu cầu ăn uống, mua sắm và đi học/đi làm trong khu vực. Chưa khảo sát khoảng cách hoặc thời gian di chuyển thực tế.",
      "RentalConditions": "Dữ liệu giả lập phục vụ demo. Tiền thuê tính đủ tháng. Điện, nước, internet và vệ sinh theo đơn giá được công bố của khu. Phí giữ xe và giặt sấy chưa công bố, cần xác nhận trước khi nhận phòng. Báo trước khi trả phòng theo thỏa thuận trong hợp đồng.",
      "ContactName": "Ban quản lý DVP Tân An (mẫu)",
      "ContactPhone": "",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_p3",
      "BranchId": "ta",
      "Name": "P.103",
      "Price": 2600000,
      "Capacity": 3,
      "IsMaintenance": false,
      "Description": "Phòng 26 m², có gác, sân phơi dùng chung; hai người đi làm ở cùng. Nhóm khách phù hợp: Sinh viên, người đi làm. Nội dung và tiện ích giả lập.",
      "Area": 26,
      "Floor": "Tầng 1",
      "RoomType": "Room",
      "Amenities": [
        "Wifi",
        "Kitchen",
        "Mezzanine",
        "Wardrobe"
      ],
      "AmenitiesConfirmed": true,
      "ToiletType": "Private",
      "AccessHours": "Tự do; giữ yên tĩnh sau 22:00, báo quản lý khi có khách ở lại (quy định mẫu).",
      "LaundryType": "Shared",
      "ParkingType": "Shared",
      "MaxVehicles": 3,
      "PetsAllowed": false,
      "ElectricVehiclesAllowed": false,
      "HasWindow": true,
      "HasBalcony": true,
      "SuggestedDeposit": 2600000,
      "MinimumLeaseMonths": 6,
      "Neighborhood": "Khu vực Hưng Lợi, phường Tân An, TP. Cần Thơ. Mô tả mẫu: kết nối Đường 30 Tháng 4, có nhu cầu ăn uống, mua sắm và đi học/đi làm trong khu vực. Chưa khảo sát khoảng cách hoặc thời gian di chuyển thực tế.",
      "RentalConditions": "Dữ liệu giả lập phục vụ demo. Tiền thuê tính đủ tháng. Điện, nước, internet và vệ sinh theo đơn giá được công bố của khu. Phí giữ xe và giặt sấy chưa công bố, cần xác nhận trước khi nhận phòng. Báo trước khi trả phòng theo thỏa thuận trong hợp đồng.",
      "ContactName": "Ban quản lý DVP Tân An (mẫu)",
      "ContactPhone": "",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_p4",
      "BranchId": "ta",
      "Name": "P.104",
      "Price": 2400000,
      "Capacity": 2,
      "IsMaintenance": false,
      "Description": "Phòng 24 m² vừa bàn giao và vệ sinh; có bếp, gác và chỗ để xe. Nhóm khách phù hợp: Sinh viên, người đi làm. Nội dung và tiện ích giả lập.",
      "Area": 24,
      "Floor": "Trệt",
      "RoomType": "Room",
      "Amenities": [
        "Wifi",
        "Kitchen",
        "Mezzanine",
        "Wardrobe",
        "AirConditioner",
        "WaterHeater"
      ],
      "AmenitiesConfirmed": true,
      "ToiletType": "Private",
      "AccessHours": "Tự do; giữ yên tĩnh sau 22:00, báo quản lý khi có khách ở lại (quy định mẫu).",
      "LaundryType": "Shared",
      "ParkingType": "Shared",
      "MaxVehicles": 2,
      "PetsAllowed": false,
      "ElectricVehiclesAllowed": false,
      "HasWindow": true,
      "HasBalcony": false,
      "SuggestedDeposit": 2400000,
      "MinimumLeaseMonths": 6,
      "Neighborhood": "Khu vực Hưng Lợi, phường Tân An, TP. Cần Thơ. Mô tả mẫu: kết nối Đường 30 Tháng 4, có nhu cầu ăn uống, mua sắm và đi học/đi làm trong khu vực. Chưa khảo sát khoảng cách hoặc thời gian di chuyển thực tế.",
      "RentalConditions": "Dữ liệu giả lập phục vụ demo. Tiền thuê tính đủ tháng. Điện, nước, internet và vệ sinh theo đơn giá được công bố của khu. Phí giữ xe và giặt sấy chưa công bố, cần xác nhận trước khi nhận phòng. Báo trước khi trả phòng theo thỏa thuận trong hợp đồng.",
      "ContactName": "Ban quản lý DVP Tân An (mẫu)",
      "ContactPhone": "",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_p5",
      "BranchId": "ta",
      "Name": "P.105",
      "Price": 2200000,
      "Capacity": 2,
      "IsMaintenance": false,
      "Description": "Phòng 20 m², lối đi riêng, cửa sổ và khu bếp; đang sẵn sàng nhận khách. Nhóm khách phù hợp: Sinh viên, người đi làm. Nội dung và tiện ích giả lập.",
      "Area": 20,
      "Floor": "Tầng 1",
      "RoomType": "Room",
      "Amenities": [
        "Wifi",
        "Kitchen",
        "Bed",
        "Mattress"
      ],
      "AmenitiesConfirmed": true,
      "ToiletType": "Private",
      "AccessHours": "Tự do; giữ yên tĩnh sau 22:00, báo quản lý khi có khách ở lại (quy định mẫu).",
      "LaundryType": "Shared",
      "ParkingType": "Shared",
      "MaxVehicles": 2,
      "PetsAllowed": true,
      "ElectricVehiclesAllowed": false,
      "HasWindow": true,
      "HasBalcony": false,
      "SuggestedDeposit": 2200000,
      "MinimumLeaseMonths": 6,
      "Neighborhood": "Khu vực Hưng Lợi, phường Tân An, TP. Cần Thơ. Mô tả mẫu: kết nối Đường 30 Tháng 4, có nhu cầu ăn uống, mua sắm và đi học/đi làm trong khu vực. Chưa khảo sát khoảng cách hoặc thời gian di chuyển thực tế.",
      "RentalConditions": "Dữ liệu giả lập phục vụ demo. Tiền thuê tính đủ tháng. Điện, nước, internet và vệ sinh theo đơn giá được công bố của khu. Phí giữ xe và giặt sấy chưa công bố, cần xác nhận trước khi nhận phòng. Báo trước khi trả phòng theo thỏa thuận trong hợp đồng.",
      "ContactName": "Ban quản lý DVP Tân An (mẫu)",
      "ContactPhone": "",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_p6",
      "BranchId": "ta",
      "Name": "P.106",
      "Price": 2300000,
      "Capacity": 2,
      "IsMaintenance": true,
      "Description": "Phòng 22 m² đang chống thấm và thay thiết bị vệ sinh, chưa nhận khách. Nhóm khách phù hợp: Sinh viên, người đi làm. Nội dung và tiện ích giả lập.",
      "Area": 22,
      "Floor": "Trệt",
      "RoomType": "Room",
      "Amenities": [
        "Wifi",
        "Kitchen",
        "Bed",
        "Mattress"
      ],
      "AmenitiesConfirmed": true,
      "ToiletType": "Private",
      "AccessHours": "Tự do; giữ yên tĩnh sau 22:00, báo quản lý khi có khách ở lại (quy định mẫu).",
      "LaundryType": "Shared",
      "ParkingType": "Shared",
      "MaxVehicles": 2,
      "PetsAllowed": false,
      "ElectricVehiclesAllowed": false,
      "HasWindow": true,
      "HasBalcony": false,
      "SuggestedDeposit": 2300000,
      "MinimumLeaseMonths": 6,
      "Neighborhood": "Khu vực Hưng Lợi, phường Tân An, TP. Cần Thơ. Mô tả mẫu: kết nối Đường 30 Tháng 4, có nhu cầu ăn uống, mua sắm và đi học/đi làm trong khu vực. Chưa khảo sát khoảng cách hoặc thời gian di chuyển thực tế.",
      "RentalConditions": "Dữ liệu giả lập phục vụ demo. Tiền thuê tính đủ tháng. Điện, nước, internet và vệ sinh theo đơn giá được công bố của khu. Phí giữ xe và giặt sấy chưa công bố, cần xác nhận trước khi nhận phòng. Báo trước khi trả phòng theo thỏa thuận trong hợp đồng.",
      "ContactName": "Ban quản lý DVP Tân An (mẫu)",
      "ContactPhone": "",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_p1",
      "BranchId": "ck",
      "Name": "P.101",
      "Price": 2800000,
      "Capacity": 2,
      "IsMaintenance": false,
      "Description": "Phòng 22 m², có gác lửng và bếp riêng; hai sinh viên ở ghép. Nhóm khách phù hợp: Nhân viên dịch vụ, hộ gia đình nhỏ. Nội dung và tiện ích giả lập.",
      "Area": 22,
      "Floor": "Trệt",
      "RoomType": "Room",
      "Amenities": [
        "Wifi",
        "Kitchen",
        "Mezzanine",
        "Wardrobe"
      ],
      "AmenitiesConfirmed": true,
      "ToiletType": "Private",
      "AccessHours": "Tự do; giữ yên tĩnh sau 22:00, báo quản lý khi có khách ở lại (quy định mẫu).",
      "LaundryType": "Shared",
      "ParkingType": "Shared",
      "MaxVehicles": 2,
      "PetsAllowed": false,
      "ElectricVehiclesAllowed": false,
      "HasWindow": true,
      "HasBalcony": false,
      "SuggestedDeposit": 2800000,
      "MinimumLeaseMonths": 6,
      "Neighborhood": "Khu vực Cái Khế, phường Cái Khế, TP. Cần Thơ. Mô tả mẫu: kết nối Đường Trần Văn Khéo, có nhu cầu ăn uống, mua sắm và đi học/đi làm trong khu vực. Chưa khảo sát khoảng cách hoặc thời gian di chuyển thực tế.",
      "RentalConditions": "Dữ liệu giả lập phục vụ demo. Tiền thuê tính đủ tháng. Điện, nước, internet và vệ sinh theo đơn giá được công bố của khu. Phí giữ xe và giặt sấy chưa công bố, cần xác nhận trước khi nhận phòng. Báo trước khi trả phòng theo thỏa thuận trong hợp đồng.",
      "ContactName": "Ban quản lý DVP Cái Khế (mẫu)",
      "ContactPhone": "",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_p2",
      "BranchId": "ck",
      "Name": "P.102",
      "Price": 2600000,
      "Capacity": 2,
      "IsMaintenance": false,
      "Description": "Phòng 18 m², cửa sổ thoáng, nhà vệ sinh riêng; phù hợp ở một người. Nhóm khách phù hợp: Nhân viên dịch vụ, hộ gia đình nhỏ. Nội dung và tiện ích giả lập.",
      "Area": 18,
      "Floor": "Trệt",
      "RoomType": "Room",
      "Amenities": [
        "Wifi",
        "Kitchen",
        "Bed",
        "Mattress"
      ],
      "AmenitiesConfirmed": true,
      "ToiletType": "Private",
      "AccessHours": "Tự do; giữ yên tĩnh sau 22:00, báo quản lý khi có khách ở lại (quy định mẫu).",
      "LaundryType": "Shared",
      "ParkingType": "Shared",
      "MaxVehicles": 2,
      "PetsAllowed": false,
      "ElectricVehiclesAllowed": false,
      "HasWindow": true,
      "HasBalcony": false,
      "SuggestedDeposit": 2600000,
      "MinimumLeaseMonths": 3,
      "Neighborhood": "Khu vực Cái Khế, phường Cái Khế, TP. Cần Thơ. Mô tả mẫu: kết nối Đường Trần Văn Khéo, có nhu cầu ăn uống, mua sắm và đi học/đi làm trong khu vực. Chưa khảo sát khoảng cách hoặc thời gian di chuyển thực tế.",
      "RentalConditions": "Dữ liệu giả lập phục vụ demo. Tiền thuê tính đủ tháng. Điện, nước, internet và vệ sinh theo đơn giá được công bố của khu. Phí giữ xe và giặt sấy chưa công bố, cần xác nhận trước khi nhận phòng. Báo trước khi trả phòng theo thỏa thuận trong hợp đồng.",
      "ContactName": "Ban quản lý DVP Cái Khế (mẫu)",
      "ContactPhone": "",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_p3",
      "BranchId": "ck",
      "Name": "P.103",
      "Price": 3100000,
      "Capacity": 3,
      "IsMaintenance": false,
      "Description": "Phòng 26 m², có gác, sân phơi dùng chung; hai người đi làm ở cùng. Nhóm khách phù hợp: Nhân viên dịch vụ, hộ gia đình nhỏ. Nội dung và tiện ích giả lập.",
      "Area": 26,
      "Floor": "Tầng 1",
      "RoomType": "Room",
      "Amenities": [
        "Wifi",
        "Kitchen",
        "Mezzanine",
        "Wardrobe"
      ],
      "AmenitiesConfirmed": true,
      "ToiletType": "Private",
      "AccessHours": "Tự do; giữ yên tĩnh sau 22:00, báo quản lý khi có khách ở lại (quy định mẫu).",
      "LaundryType": "Shared",
      "ParkingType": "Shared",
      "MaxVehicles": 3,
      "PetsAllowed": false,
      "ElectricVehiclesAllowed": false,
      "HasWindow": true,
      "HasBalcony": true,
      "SuggestedDeposit": 3100000,
      "MinimumLeaseMonths": 6,
      "Neighborhood": "Khu vực Cái Khế, phường Cái Khế, TP. Cần Thơ. Mô tả mẫu: kết nối Đường Trần Văn Khéo, có nhu cầu ăn uống, mua sắm và đi học/đi làm trong khu vực. Chưa khảo sát khoảng cách hoặc thời gian di chuyển thực tế.",
      "RentalConditions": "Dữ liệu giả lập phục vụ demo. Tiền thuê tính đủ tháng. Điện, nước, internet và vệ sinh theo đơn giá được công bố của khu. Phí giữ xe và giặt sấy chưa công bố, cần xác nhận trước khi nhận phòng. Báo trước khi trả phòng theo thỏa thuận trong hợp đồng.",
      "ContactName": "Ban quản lý DVP Cái Khế (mẫu)",
      "ContactPhone": "",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_p4",
      "BranchId": "ck",
      "Name": "P.104",
      "Price": 2900000,
      "Capacity": 2,
      "IsMaintenance": false,
      "Description": "Phòng 24 m² vừa bàn giao và vệ sinh; có bếp, gác và chỗ để xe. Nhóm khách phù hợp: Nhân viên dịch vụ, hộ gia đình nhỏ. Nội dung và tiện ích giả lập.",
      "Area": 24,
      "Floor": "Trệt",
      "RoomType": "Room",
      "Amenities": [
        "Wifi",
        "Kitchen",
        "Mezzanine",
        "Wardrobe",
        "AirConditioner",
        "WaterHeater"
      ],
      "AmenitiesConfirmed": true,
      "ToiletType": "Private",
      "AccessHours": "Tự do; giữ yên tĩnh sau 22:00, báo quản lý khi có khách ở lại (quy định mẫu).",
      "LaundryType": "Shared",
      "ParkingType": "Shared",
      "MaxVehicles": 2,
      "PetsAllowed": false,
      "ElectricVehiclesAllowed": false,
      "HasWindow": true,
      "HasBalcony": false,
      "SuggestedDeposit": 2900000,
      "MinimumLeaseMonths": 6,
      "Neighborhood": "Khu vực Cái Khế, phường Cái Khế, TP. Cần Thơ. Mô tả mẫu: kết nối Đường Trần Văn Khéo, có nhu cầu ăn uống, mua sắm và đi học/đi làm trong khu vực. Chưa khảo sát khoảng cách hoặc thời gian di chuyển thực tế.",
      "RentalConditions": "Dữ liệu giả lập phục vụ demo. Tiền thuê tính đủ tháng. Điện, nước, internet và vệ sinh theo đơn giá được công bố của khu. Phí giữ xe và giặt sấy chưa công bố, cần xác nhận trước khi nhận phòng. Báo trước khi trả phòng theo thỏa thuận trong hợp đồng.",
      "ContactName": "Ban quản lý DVP Cái Khế (mẫu)",
      "ContactPhone": "",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_p5",
      "BranchId": "ck",
      "Name": "P.105",
      "Price": 2700000,
      "Capacity": 2,
      "IsMaintenance": false,
      "Description": "Phòng 20 m², lối đi riêng, cửa sổ và khu bếp; đang sẵn sàng nhận khách. Nhóm khách phù hợp: Nhân viên dịch vụ, hộ gia đình nhỏ. Nội dung và tiện ích giả lập.",
      "Area": 20,
      "Floor": "Tầng 1",
      "RoomType": "Room",
      "Amenities": [
        "Wifi",
        "Kitchen",
        "Bed",
        "Mattress"
      ],
      "AmenitiesConfirmed": true,
      "ToiletType": "Private",
      "AccessHours": "Tự do; giữ yên tĩnh sau 22:00, báo quản lý khi có khách ở lại (quy định mẫu).",
      "LaundryType": "Shared",
      "ParkingType": "Shared",
      "MaxVehicles": 2,
      "PetsAllowed": true,
      "ElectricVehiclesAllowed": false,
      "HasWindow": true,
      "HasBalcony": false,
      "SuggestedDeposit": 2700000,
      "MinimumLeaseMonths": 6,
      "Neighborhood": "Khu vực Cái Khế, phường Cái Khế, TP. Cần Thơ. Mô tả mẫu: kết nối Đường Trần Văn Khéo, có nhu cầu ăn uống, mua sắm và đi học/đi làm trong khu vực. Chưa khảo sát khoảng cách hoặc thời gian di chuyển thực tế.",
      "RentalConditions": "Dữ liệu giả lập phục vụ demo. Tiền thuê tính đủ tháng. Điện, nước, internet và vệ sinh theo đơn giá được công bố của khu. Phí giữ xe và giặt sấy chưa công bố, cần xác nhận trước khi nhận phòng. Báo trước khi trả phòng theo thỏa thuận trong hợp đồng.",
      "ContactName": "Ban quản lý DVP Cái Khế (mẫu)",
      "ContactPhone": "",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_p6",
      "BranchId": "ck",
      "Name": "P.106",
      "Price": 2800000,
      "Capacity": 2,
      "IsMaintenance": true,
      "Description": "Phòng 22 m² đang chống thấm và thay thiết bị vệ sinh, chưa nhận khách. Nhóm khách phù hợp: Nhân viên dịch vụ, hộ gia đình nhỏ. Nội dung và tiện ích giả lập.",
      "Area": 22,
      "Floor": "Trệt",
      "RoomType": "Room",
      "Amenities": [
        "Wifi",
        "Kitchen",
        "Bed",
        "Mattress"
      ],
      "AmenitiesConfirmed": true,
      "ToiletType": "Private",
      "AccessHours": "Tự do; giữ yên tĩnh sau 22:00, báo quản lý khi có khách ở lại (quy định mẫu).",
      "LaundryType": "Shared",
      "ParkingType": "Shared",
      "MaxVehicles": 2,
      "PetsAllowed": false,
      "ElectricVehiclesAllowed": false,
      "HasWindow": true,
      "HasBalcony": false,
      "SuggestedDeposit": 2800000,
      "MinimumLeaseMonths": 6,
      "Neighborhood": "Khu vực Cái Khế, phường Cái Khế, TP. Cần Thơ. Mô tả mẫu: kết nối Đường Trần Văn Khéo, có nhu cầu ăn uống, mua sắm và đi học/đi làm trong khu vực. Chưa khảo sát khoảng cách hoặc thời gian di chuyển thực tế.",
      "RentalConditions": "Dữ liệu giả lập phục vụ demo. Tiền thuê tính đủ tháng. Điện, nước, internet và vệ sinh theo đơn giá được công bố của khu. Phí giữ xe và giặt sấy chưa công bố, cần xác nhận trước khi nhận phòng. Báo trước khi trả phòng theo thỏa thuận trong hợp đồng.",
      "ContactName": "Ban quản lý DVP Cái Khế (mẫu)",
      "ContactPhone": "",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_p1",
      "BranchId": "bt",
      "Name": "P.101",
      "Price": 1800000,
      "Capacity": 2,
      "IsMaintenance": false,
      "Description": "Phòng 22 m², có gác lửng và bếp riêng; hai sinh viên ở ghép. Nhóm khách phù hợp: Công nhân, nhân viên kỹ thuật. Nội dung và tiện ích giả lập.",
      "Area": 22,
      "Floor": "Trệt",
      "RoomType": "Room",
      "Amenities": [
        "Wifi",
        "Kitchen",
        "Mezzanine",
        "Wardrobe"
      ],
      "AmenitiesConfirmed": true,
      "ToiletType": "Private",
      "AccessHours": "Tự do; giữ yên tĩnh sau 22:00, báo quản lý khi có khách ở lại (quy định mẫu).",
      "LaundryType": "Shared",
      "ParkingType": "Shared",
      "MaxVehicles": 2,
      "PetsAllowed": false,
      "ElectricVehiclesAllowed": false,
      "HasWindow": true,
      "HasBalcony": false,
      "SuggestedDeposit": 1800000,
      "MinimumLeaseMonths": 6,
      "Neighborhood": "Khu vực An Thới, phường Bình Thủy, TP. Cần Thơ. Mô tả mẫu: kết nối Đường Cách Mạng Tháng 8, có nhu cầu ăn uống, mua sắm và đi học/đi làm trong khu vực. Chưa khảo sát khoảng cách hoặc thời gian di chuyển thực tế.",
      "RentalConditions": "Dữ liệu giả lập phục vụ demo. Tiền thuê tính đủ tháng. Điện, nước, internet và vệ sinh theo đơn giá được công bố của khu. Phí giữ xe và giặt sấy chưa công bố, cần xác nhận trước khi nhận phòng. Báo trước khi trả phòng theo thỏa thuận trong hợp đồng.",
      "ContactName": "Ban quản lý DVP Bình Thủy (mẫu)",
      "ContactPhone": "",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_p2",
      "BranchId": "bt",
      "Name": "P.102",
      "Price": 1600000,
      "Capacity": 2,
      "IsMaintenance": false,
      "Description": "Phòng 18 m², cửa sổ thoáng, nhà vệ sinh riêng; phù hợp ở một người. Nhóm khách phù hợp: Công nhân, nhân viên kỹ thuật. Nội dung và tiện ích giả lập.",
      "Area": 18,
      "Floor": "Trệt",
      "RoomType": "Room",
      "Amenities": [
        "Wifi",
        "Kitchen",
        "Bed",
        "Mattress"
      ],
      "AmenitiesConfirmed": true,
      "ToiletType": "Private",
      "AccessHours": "Tự do; giữ yên tĩnh sau 22:00, báo quản lý khi có khách ở lại (quy định mẫu).",
      "LaundryType": "Shared",
      "ParkingType": "Shared",
      "MaxVehicles": 2,
      "PetsAllowed": false,
      "ElectricVehiclesAllowed": false,
      "HasWindow": true,
      "HasBalcony": false,
      "SuggestedDeposit": 1600000,
      "MinimumLeaseMonths": 3,
      "Neighborhood": "Khu vực An Thới, phường Bình Thủy, TP. Cần Thơ. Mô tả mẫu: kết nối Đường Cách Mạng Tháng 8, có nhu cầu ăn uống, mua sắm và đi học/đi làm trong khu vực. Chưa khảo sát khoảng cách hoặc thời gian di chuyển thực tế.",
      "RentalConditions": "Dữ liệu giả lập phục vụ demo. Tiền thuê tính đủ tháng. Điện, nước, internet và vệ sinh theo đơn giá được công bố của khu. Phí giữ xe và giặt sấy chưa công bố, cần xác nhận trước khi nhận phòng. Báo trước khi trả phòng theo thỏa thuận trong hợp đồng.",
      "ContactName": "Ban quản lý DVP Bình Thủy (mẫu)",
      "ContactPhone": "",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_p3",
      "BranchId": "bt",
      "Name": "P.103",
      "Price": 2100000,
      "Capacity": 3,
      "IsMaintenance": false,
      "Description": "Phòng 26 m², có gác, sân phơi dùng chung; hai người đi làm ở cùng. Nhóm khách phù hợp: Công nhân, nhân viên kỹ thuật. Nội dung và tiện ích giả lập.",
      "Area": 26,
      "Floor": "Tầng 1",
      "RoomType": "Room",
      "Amenities": [
        "Wifi",
        "Kitchen",
        "Mezzanine",
        "Wardrobe"
      ],
      "AmenitiesConfirmed": true,
      "ToiletType": "Private",
      "AccessHours": "Tự do; giữ yên tĩnh sau 22:00, báo quản lý khi có khách ở lại (quy định mẫu).",
      "LaundryType": "Shared",
      "ParkingType": "Shared",
      "MaxVehicles": 3,
      "PetsAllowed": false,
      "ElectricVehiclesAllowed": false,
      "HasWindow": true,
      "HasBalcony": true,
      "SuggestedDeposit": 2100000,
      "MinimumLeaseMonths": 6,
      "Neighborhood": "Khu vực An Thới, phường Bình Thủy, TP. Cần Thơ. Mô tả mẫu: kết nối Đường Cách Mạng Tháng 8, có nhu cầu ăn uống, mua sắm và đi học/đi làm trong khu vực. Chưa khảo sát khoảng cách hoặc thời gian di chuyển thực tế.",
      "RentalConditions": "Dữ liệu giả lập phục vụ demo. Tiền thuê tính đủ tháng. Điện, nước, internet và vệ sinh theo đơn giá được công bố của khu. Phí giữ xe và giặt sấy chưa công bố, cần xác nhận trước khi nhận phòng. Báo trước khi trả phòng theo thỏa thuận trong hợp đồng.",
      "ContactName": "Ban quản lý DVP Bình Thủy (mẫu)",
      "ContactPhone": "",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_p4",
      "BranchId": "bt",
      "Name": "P.104",
      "Price": 1900000,
      "Capacity": 2,
      "IsMaintenance": false,
      "Description": "Phòng 24 m² vừa bàn giao và vệ sinh; có bếp, gác và chỗ để xe. Nhóm khách phù hợp: Công nhân, nhân viên kỹ thuật. Nội dung và tiện ích giả lập.",
      "Area": 24,
      "Floor": "Trệt",
      "RoomType": "Room",
      "Amenities": [
        "Wifi",
        "Kitchen",
        "Mezzanine",
        "Wardrobe",
        "AirConditioner",
        "WaterHeater"
      ],
      "AmenitiesConfirmed": true,
      "ToiletType": "Private",
      "AccessHours": "Tự do; giữ yên tĩnh sau 22:00, báo quản lý khi có khách ở lại (quy định mẫu).",
      "LaundryType": "Shared",
      "ParkingType": "Shared",
      "MaxVehicles": 2,
      "PetsAllowed": false,
      "ElectricVehiclesAllowed": false,
      "HasWindow": true,
      "HasBalcony": false,
      "SuggestedDeposit": 1900000,
      "MinimumLeaseMonths": 6,
      "Neighborhood": "Khu vực An Thới, phường Bình Thủy, TP. Cần Thơ. Mô tả mẫu: kết nối Đường Cách Mạng Tháng 8, có nhu cầu ăn uống, mua sắm và đi học/đi làm trong khu vực. Chưa khảo sát khoảng cách hoặc thời gian di chuyển thực tế.",
      "RentalConditions": "Dữ liệu giả lập phục vụ demo. Tiền thuê tính đủ tháng. Điện, nước, internet và vệ sinh theo đơn giá được công bố của khu. Phí giữ xe và giặt sấy chưa công bố, cần xác nhận trước khi nhận phòng. Báo trước khi trả phòng theo thỏa thuận trong hợp đồng.",
      "ContactName": "Ban quản lý DVP Bình Thủy (mẫu)",
      "ContactPhone": "",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_p5",
      "BranchId": "bt",
      "Name": "P.105",
      "Price": 1700000,
      "Capacity": 2,
      "IsMaintenance": false,
      "Description": "Phòng 20 m², lối đi riêng, cửa sổ và khu bếp; đang sẵn sàng nhận khách. Nhóm khách phù hợp: Công nhân, nhân viên kỹ thuật. Nội dung và tiện ích giả lập.",
      "Area": 20,
      "Floor": "Tầng 1",
      "RoomType": "Room",
      "Amenities": [
        "Wifi",
        "Kitchen",
        "Bed",
        "Mattress"
      ],
      "AmenitiesConfirmed": true,
      "ToiletType": "Private",
      "AccessHours": "Tự do; giữ yên tĩnh sau 22:00, báo quản lý khi có khách ở lại (quy định mẫu).",
      "LaundryType": "Shared",
      "ParkingType": "Shared",
      "MaxVehicles": 2,
      "PetsAllowed": true,
      "ElectricVehiclesAllowed": false,
      "HasWindow": true,
      "HasBalcony": false,
      "SuggestedDeposit": 1700000,
      "MinimumLeaseMonths": 6,
      "Neighborhood": "Khu vực An Thới, phường Bình Thủy, TP. Cần Thơ. Mô tả mẫu: kết nối Đường Cách Mạng Tháng 8, có nhu cầu ăn uống, mua sắm và đi học/đi làm trong khu vực. Chưa khảo sát khoảng cách hoặc thời gian di chuyển thực tế.",
      "RentalConditions": "Dữ liệu giả lập phục vụ demo. Tiền thuê tính đủ tháng. Điện, nước, internet và vệ sinh theo đơn giá được công bố của khu. Phí giữ xe và giặt sấy chưa công bố, cần xác nhận trước khi nhận phòng. Báo trước khi trả phòng theo thỏa thuận trong hợp đồng.",
      "ContactName": "Ban quản lý DVP Bình Thủy (mẫu)",
      "ContactPhone": "",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_p6",
      "BranchId": "bt",
      "Name": "P.106",
      "Price": 1800000,
      "Capacity": 2,
      "IsMaintenance": true,
      "Description": "Phòng 22 m² đang chống thấm và thay thiết bị vệ sinh, chưa nhận khách. Nhóm khách phù hợp: Công nhân, nhân viên kỹ thuật. Nội dung và tiện ích giả lập.",
      "Area": 22,
      "Floor": "Trệt",
      "RoomType": "Room",
      "Amenities": [
        "Wifi",
        "Kitchen",
        "Bed",
        "Mattress"
      ],
      "AmenitiesConfirmed": true,
      "ToiletType": "Private",
      "AccessHours": "Tự do; giữ yên tĩnh sau 22:00, báo quản lý khi có khách ở lại (quy định mẫu).",
      "LaundryType": "Shared",
      "ParkingType": "Shared",
      "MaxVehicles": 2,
      "PetsAllowed": false,
      "ElectricVehiclesAllowed": false,
      "HasWindow": true,
      "HasBalcony": false,
      "SuggestedDeposit": 1800000,
      "MinimumLeaseMonths": 6,
      "Neighborhood": "Khu vực An Thới, phường Bình Thủy, TP. Cần Thơ. Mô tả mẫu: kết nối Đường Cách Mạng Tháng 8, có nhu cầu ăn uống, mua sắm và đi học/đi làm trong khu vực. Chưa khảo sát khoảng cách hoặc thời gian di chuyển thực tế.",
      "RentalConditions": "Dữ liệu giả lập phục vụ demo. Tiền thuê tính đủ tháng. Điện, nước, internet và vệ sinh theo đơn giá được công bố của khu. Phí giữ xe và giặt sấy chưa công bố, cần xác nhận trước khi nhận phòng. Báo trước khi trả phòng theo thỏa thuận trong hợp đồng.",
      "ContactName": "Ban quản lý DVP Bình Thủy (mẫu)",
      "ContactPhone": "",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_p1",
      "BranchId": "cr",
      "Name": "P.101",
      "Price": 2200000,
      "Capacity": 2,
      "IsMaintenance": false,
      "Description": "Phòng 22 m², có gác lửng và bếp riêng; hai sinh viên ở ghép. Nhóm khách phù hợp: Nhân viên bán hàng, vợ chồng trẻ. Nội dung và tiện ích giả lập.",
      "Area": 22,
      "Floor": "Trệt",
      "RoomType": "Room",
      "Amenities": [
        "Wifi",
        "Kitchen",
        "Mezzanine",
        "Wardrobe"
      ],
      "AmenitiesConfirmed": true,
      "ToiletType": "Private",
      "AccessHours": "Tự do; giữ yên tĩnh sau 22:00, báo quản lý khi có khách ở lại (quy định mẫu).",
      "LaundryType": "Shared",
      "ParkingType": "Shared",
      "MaxVehicles": 2,
      "PetsAllowed": false,
      "ElectricVehiclesAllowed": false,
      "HasWindow": true,
      "HasBalcony": false,
      "SuggestedDeposit": 2200000,
      "MinimumLeaseMonths": 6,
      "Neighborhood": "Khu vực Lê Bình, phường Cái Răng, TP. Cần Thơ. Mô tả mẫu: kết nối Đường Võ Tánh, có nhu cầu ăn uống, mua sắm và đi học/đi làm trong khu vực. Chưa khảo sát khoảng cách hoặc thời gian di chuyển thực tế.",
      "RentalConditions": "Dữ liệu giả lập phục vụ demo. Tiền thuê tính đủ tháng. Điện, nước, internet và vệ sinh theo đơn giá được công bố của khu. Phí giữ xe và giặt sấy chưa công bố, cần xác nhận trước khi nhận phòng. Báo trước khi trả phòng theo thỏa thuận trong hợp đồng.",
      "ContactName": "Ban quản lý DVP Cái Răng (mẫu)",
      "ContactPhone": "",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_p2",
      "BranchId": "cr",
      "Name": "P.102",
      "Price": 2000000,
      "Capacity": 2,
      "IsMaintenance": false,
      "Description": "Phòng 18 m², cửa sổ thoáng, nhà vệ sinh riêng; phù hợp ở một người. Nhóm khách phù hợp: Nhân viên bán hàng, vợ chồng trẻ. Nội dung và tiện ích giả lập.",
      "Area": 18,
      "Floor": "Trệt",
      "RoomType": "Room",
      "Amenities": [
        "Wifi",
        "Kitchen",
        "Bed",
        "Mattress"
      ],
      "AmenitiesConfirmed": true,
      "ToiletType": "Private",
      "AccessHours": "Tự do; giữ yên tĩnh sau 22:00, báo quản lý khi có khách ở lại (quy định mẫu).",
      "LaundryType": "Shared",
      "ParkingType": "Shared",
      "MaxVehicles": 2,
      "PetsAllowed": false,
      "ElectricVehiclesAllowed": false,
      "HasWindow": true,
      "HasBalcony": false,
      "SuggestedDeposit": 2000000,
      "MinimumLeaseMonths": 3,
      "Neighborhood": "Khu vực Lê Bình, phường Cái Răng, TP. Cần Thơ. Mô tả mẫu: kết nối Đường Võ Tánh, có nhu cầu ăn uống, mua sắm và đi học/đi làm trong khu vực. Chưa khảo sát khoảng cách hoặc thời gian di chuyển thực tế.",
      "RentalConditions": "Dữ liệu giả lập phục vụ demo. Tiền thuê tính đủ tháng. Điện, nước, internet và vệ sinh theo đơn giá được công bố của khu. Phí giữ xe và giặt sấy chưa công bố, cần xác nhận trước khi nhận phòng. Báo trước khi trả phòng theo thỏa thuận trong hợp đồng.",
      "ContactName": "Ban quản lý DVP Cái Răng (mẫu)",
      "ContactPhone": "",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_p3",
      "BranchId": "cr",
      "Name": "P.103",
      "Price": 2500000,
      "Capacity": 3,
      "IsMaintenance": false,
      "Description": "Phòng 26 m², có gác, sân phơi dùng chung; hai người đi làm ở cùng. Nhóm khách phù hợp: Nhân viên bán hàng, vợ chồng trẻ. Nội dung và tiện ích giả lập.",
      "Area": 26,
      "Floor": "Tầng 1",
      "RoomType": "Room",
      "Amenities": [
        "Wifi",
        "Kitchen",
        "Mezzanine",
        "Wardrobe"
      ],
      "AmenitiesConfirmed": true,
      "ToiletType": "Private",
      "AccessHours": "Tự do; giữ yên tĩnh sau 22:00, báo quản lý khi có khách ở lại (quy định mẫu).",
      "LaundryType": "Shared",
      "ParkingType": "Shared",
      "MaxVehicles": 3,
      "PetsAllowed": false,
      "ElectricVehiclesAllowed": false,
      "HasWindow": true,
      "HasBalcony": true,
      "SuggestedDeposit": 2500000,
      "MinimumLeaseMonths": 6,
      "Neighborhood": "Khu vực Lê Bình, phường Cái Răng, TP. Cần Thơ. Mô tả mẫu: kết nối Đường Võ Tánh, có nhu cầu ăn uống, mua sắm và đi học/đi làm trong khu vực. Chưa khảo sát khoảng cách hoặc thời gian di chuyển thực tế.",
      "RentalConditions": "Dữ liệu giả lập phục vụ demo. Tiền thuê tính đủ tháng. Điện, nước, internet và vệ sinh theo đơn giá được công bố của khu. Phí giữ xe và giặt sấy chưa công bố, cần xác nhận trước khi nhận phòng. Báo trước khi trả phòng theo thỏa thuận trong hợp đồng.",
      "ContactName": "Ban quản lý DVP Cái Răng (mẫu)",
      "ContactPhone": "",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_p4",
      "BranchId": "cr",
      "Name": "P.104",
      "Price": 2300000,
      "Capacity": 2,
      "IsMaintenance": false,
      "Description": "Phòng 24 m² vừa bàn giao và vệ sinh; có bếp, gác và chỗ để xe. Nhóm khách phù hợp: Nhân viên bán hàng, vợ chồng trẻ. Nội dung và tiện ích giả lập.",
      "Area": 24,
      "Floor": "Trệt",
      "RoomType": "Room",
      "Amenities": [
        "Wifi",
        "Kitchen",
        "Mezzanine",
        "Wardrobe",
        "AirConditioner",
        "WaterHeater"
      ],
      "AmenitiesConfirmed": true,
      "ToiletType": "Private",
      "AccessHours": "Tự do; giữ yên tĩnh sau 22:00, báo quản lý khi có khách ở lại (quy định mẫu).",
      "LaundryType": "Shared",
      "ParkingType": "Shared",
      "MaxVehicles": 2,
      "PetsAllowed": false,
      "ElectricVehiclesAllowed": false,
      "HasWindow": true,
      "HasBalcony": false,
      "SuggestedDeposit": 2300000,
      "MinimumLeaseMonths": 6,
      "Neighborhood": "Khu vực Lê Bình, phường Cái Răng, TP. Cần Thơ. Mô tả mẫu: kết nối Đường Võ Tánh, có nhu cầu ăn uống, mua sắm và đi học/đi làm trong khu vực. Chưa khảo sát khoảng cách hoặc thời gian di chuyển thực tế.",
      "RentalConditions": "Dữ liệu giả lập phục vụ demo. Tiền thuê tính đủ tháng. Điện, nước, internet và vệ sinh theo đơn giá được công bố của khu. Phí giữ xe và giặt sấy chưa công bố, cần xác nhận trước khi nhận phòng. Báo trước khi trả phòng theo thỏa thuận trong hợp đồng.",
      "ContactName": "Ban quản lý DVP Cái Răng (mẫu)",
      "ContactPhone": "",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_p5",
      "BranchId": "cr",
      "Name": "P.105",
      "Price": 2100000,
      "Capacity": 2,
      "IsMaintenance": false,
      "Description": "Phòng 20 m², lối đi riêng, cửa sổ và khu bếp; đang sẵn sàng nhận khách. Nhóm khách phù hợp: Nhân viên bán hàng, vợ chồng trẻ. Nội dung và tiện ích giả lập.",
      "Area": 20,
      "Floor": "Tầng 1",
      "RoomType": "Room",
      "Amenities": [
        "Wifi",
        "Kitchen",
        "Bed",
        "Mattress"
      ],
      "AmenitiesConfirmed": true,
      "ToiletType": "Private",
      "AccessHours": "Tự do; giữ yên tĩnh sau 22:00, báo quản lý khi có khách ở lại (quy định mẫu).",
      "LaundryType": "Shared",
      "ParkingType": "Shared",
      "MaxVehicles": 2,
      "PetsAllowed": true,
      "ElectricVehiclesAllowed": false,
      "HasWindow": true,
      "HasBalcony": false,
      "SuggestedDeposit": 2100000,
      "MinimumLeaseMonths": 6,
      "Neighborhood": "Khu vực Lê Bình, phường Cái Răng, TP. Cần Thơ. Mô tả mẫu: kết nối Đường Võ Tánh, có nhu cầu ăn uống, mua sắm và đi học/đi làm trong khu vực. Chưa khảo sát khoảng cách hoặc thời gian di chuyển thực tế.",
      "RentalConditions": "Dữ liệu giả lập phục vụ demo. Tiền thuê tính đủ tháng. Điện, nước, internet và vệ sinh theo đơn giá được công bố của khu. Phí giữ xe và giặt sấy chưa công bố, cần xác nhận trước khi nhận phòng. Báo trước khi trả phòng theo thỏa thuận trong hợp đồng.",
      "ContactName": "Ban quản lý DVP Cái Răng (mẫu)",
      "ContactPhone": "",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_p6",
      "BranchId": "cr",
      "Name": "P.106",
      "Price": 2200000,
      "Capacity": 2,
      "IsMaintenance": true,
      "Description": "Phòng 22 m² đang chống thấm và thay thiết bị vệ sinh, chưa nhận khách. Nhóm khách phù hợp: Nhân viên bán hàng, vợ chồng trẻ. Nội dung và tiện ích giả lập.",
      "Area": 22,
      "Floor": "Trệt",
      "RoomType": "Room",
      "Amenities": [
        "Wifi",
        "Kitchen",
        "Bed",
        "Mattress"
      ],
      "AmenitiesConfirmed": true,
      "ToiletType": "Private",
      "AccessHours": "Tự do; giữ yên tĩnh sau 22:00, báo quản lý khi có khách ở lại (quy định mẫu).",
      "LaundryType": "Shared",
      "ParkingType": "Shared",
      "MaxVehicles": 2,
      "PetsAllowed": false,
      "ElectricVehiclesAllowed": false,
      "HasWindow": true,
      "HasBalcony": false,
      "SuggestedDeposit": 2200000,
      "MinimumLeaseMonths": 6,
      "Neighborhood": "Khu vực Lê Bình, phường Cái Răng, TP. Cần Thơ. Mô tả mẫu: kết nối Đường Võ Tánh, có nhu cầu ăn uống, mua sắm và đi học/đi làm trong khu vực. Chưa khảo sát khoảng cách hoặc thời gian di chuyển thực tế.",
      "RentalConditions": "Dữ liệu giả lập phục vụ demo. Tiền thuê tính đủ tháng. Điện, nước, internet và vệ sinh theo đơn giá được công bố của khu. Phí giữ xe và giặt sấy chưa công bố, cần xác nhận trước khi nhận phòng. Báo trước khi trả phòng theo thỏa thuận trong hợp đồng.",
      "ContactName": "Ban quản lý DVP Cái Răng (mẫu)",
      "ContactPhone": "",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_p1",
      "BranchId": "om",
      "Name": "P.101",
      "Price": 1600000,
      "Capacity": 2,
      "IsMaintenance": false,
      "Description": "Phòng 22 m², có gác lửng và bếp riêng; hai sinh viên ở ghép. Nhóm khách phù hợp: Công nhân, lao động địa phương. Nội dung và tiện ích giả lập.",
      "Area": 22,
      "Floor": "Trệt",
      "RoomType": "Room",
      "Amenities": [
        "Wifi",
        "Kitchen",
        "Mezzanine",
        "Wardrobe"
      ],
      "AmenitiesConfirmed": true,
      "ToiletType": "Private",
      "AccessHours": "Tự do; giữ yên tĩnh sau 22:00, báo quản lý khi có khách ở lại (quy định mẫu).",
      "LaundryType": "Shared",
      "ParkingType": "Shared",
      "MaxVehicles": 2,
      "PetsAllowed": false,
      "ElectricVehiclesAllowed": false,
      "HasWindow": true,
      "HasBalcony": false,
      "SuggestedDeposit": 1600000,
      "MinimumLeaseMonths": 6,
      "Neighborhood": "Khu vực Châu Văn Liêm, phường Ô Môn, TP. Cần Thơ. Mô tả mẫu: kết nối Đường Trần Hưng Đạo, có nhu cầu ăn uống, mua sắm và đi học/đi làm trong khu vực. Chưa khảo sát khoảng cách hoặc thời gian di chuyển thực tế.",
      "RentalConditions": "Dữ liệu giả lập phục vụ demo. Tiền thuê tính đủ tháng. Điện, nước, internet và vệ sinh theo đơn giá được công bố của khu. Phí giữ xe và giặt sấy chưa công bố, cần xác nhận trước khi nhận phòng. Báo trước khi trả phòng theo thỏa thuận trong hợp đồng.",
      "ContactName": "Ban quản lý DVP Ô Môn (mẫu)",
      "ContactPhone": "",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_p2",
      "BranchId": "om",
      "Name": "P.102",
      "Price": 1400000,
      "Capacity": 2,
      "IsMaintenance": false,
      "Description": "Phòng 18 m², cửa sổ thoáng, nhà vệ sinh riêng; phù hợp ở một người. Nhóm khách phù hợp: Công nhân, lao động địa phương. Nội dung và tiện ích giả lập.",
      "Area": 18,
      "Floor": "Trệt",
      "RoomType": "Room",
      "Amenities": [
        "Wifi",
        "Kitchen",
        "Bed",
        "Mattress"
      ],
      "AmenitiesConfirmed": true,
      "ToiletType": "Private",
      "AccessHours": "Tự do; giữ yên tĩnh sau 22:00, báo quản lý khi có khách ở lại (quy định mẫu).",
      "LaundryType": "Shared",
      "ParkingType": "Shared",
      "MaxVehicles": 2,
      "PetsAllowed": false,
      "ElectricVehiclesAllowed": false,
      "HasWindow": true,
      "HasBalcony": false,
      "SuggestedDeposit": 1400000,
      "MinimumLeaseMonths": 3,
      "Neighborhood": "Khu vực Châu Văn Liêm, phường Ô Môn, TP. Cần Thơ. Mô tả mẫu: kết nối Đường Trần Hưng Đạo, có nhu cầu ăn uống, mua sắm và đi học/đi làm trong khu vực. Chưa khảo sát khoảng cách hoặc thời gian di chuyển thực tế.",
      "RentalConditions": "Dữ liệu giả lập phục vụ demo. Tiền thuê tính đủ tháng. Điện, nước, internet và vệ sinh theo đơn giá được công bố của khu. Phí giữ xe và giặt sấy chưa công bố, cần xác nhận trước khi nhận phòng. Báo trước khi trả phòng theo thỏa thuận trong hợp đồng.",
      "ContactName": "Ban quản lý DVP Ô Môn (mẫu)",
      "ContactPhone": "",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_p3",
      "BranchId": "om",
      "Name": "P.103",
      "Price": 1900000,
      "Capacity": 3,
      "IsMaintenance": false,
      "Description": "Phòng 26 m², có gác, sân phơi dùng chung; hai người đi làm ở cùng. Nhóm khách phù hợp: Công nhân, lao động địa phương. Nội dung và tiện ích giả lập.",
      "Area": 26,
      "Floor": "Tầng 1",
      "RoomType": "Room",
      "Amenities": [
        "Wifi",
        "Kitchen",
        "Mezzanine",
        "Wardrobe"
      ],
      "AmenitiesConfirmed": true,
      "ToiletType": "Private",
      "AccessHours": "Tự do; giữ yên tĩnh sau 22:00, báo quản lý khi có khách ở lại (quy định mẫu).",
      "LaundryType": "Shared",
      "ParkingType": "Shared",
      "MaxVehicles": 3,
      "PetsAllowed": false,
      "ElectricVehiclesAllowed": false,
      "HasWindow": true,
      "HasBalcony": true,
      "SuggestedDeposit": 1900000,
      "MinimumLeaseMonths": 6,
      "Neighborhood": "Khu vực Châu Văn Liêm, phường Ô Môn, TP. Cần Thơ. Mô tả mẫu: kết nối Đường Trần Hưng Đạo, có nhu cầu ăn uống, mua sắm và đi học/đi làm trong khu vực. Chưa khảo sát khoảng cách hoặc thời gian di chuyển thực tế.",
      "RentalConditions": "Dữ liệu giả lập phục vụ demo. Tiền thuê tính đủ tháng. Điện, nước, internet và vệ sinh theo đơn giá được công bố của khu. Phí giữ xe và giặt sấy chưa công bố, cần xác nhận trước khi nhận phòng. Báo trước khi trả phòng theo thỏa thuận trong hợp đồng.",
      "ContactName": "Ban quản lý DVP Ô Môn (mẫu)",
      "ContactPhone": "",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_p4",
      "BranchId": "om",
      "Name": "P.104",
      "Price": 1700000,
      "Capacity": 2,
      "IsMaintenance": false,
      "Description": "Phòng 24 m² vừa bàn giao và vệ sinh; có bếp, gác và chỗ để xe. Nhóm khách phù hợp: Công nhân, lao động địa phương. Nội dung và tiện ích giả lập.",
      "Area": 24,
      "Floor": "Trệt",
      "RoomType": "Room",
      "Amenities": [
        "Wifi",
        "Kitchen",
        "Mezzanine",
        "Wardrobe",
        "AirConditioner",
        "WaterHeater"
      ],
      "AmenitiesConfirmed": true,
      "ToiletType": "Private",
      "AccessHours": "Tự do; giữ yên tĩnh sau 22:00, báo quản lý khi có khách ở lại (quy định mẫu).",
      "LaundryType": "Shared",
      "ParkingType": "Shared",
      "MaxVehicles": 2,
      "PetsAllowed": false,
      "ElectricVehiclesAllowed": false,
      "HasWindow": true,
      "HasBalcony": false,
      "SuggestedDeposit": 1700000,
      "MinimumLeaseMonths": 6,
      "Neighborhood": "Khu vực Châu Văn Liêm, phường Ô Môn, TP. Cần Thơ. Mô tả mẫu: kết nối Đường Trần Hưng Đạo, có nhu cầu ăn uống, mua sắm và đi học/đi làm trong khu vực. Chưa khảo sát khoảng cách hoặc thời gian di chuyển thực tế.",
      "RentalConditions": "Dữ liệu giả lập phục vụ demo. Tiền thuê tính đủ tháng. Điện, nước, internet và vệ sinh theo đơn giá được công bố của khu. Phí giữ xe và giặt sấy chưa công bố, cần xác nhận trước khi nhận phòng. Báo trước khi trả phòng theo thỏa thuận trong hợp đồng.",
      "ContactName": "Ban quản lý DVP Ô Môn (mẫu)",
      "ContactPhone": "",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_p5",
      "BranchId": "om",
      "Name": "P.105",
      "Price": 1500000,
      "Capacity": 2,
      "IsMaintenance": false,
      "Description": "Phòng 20 m², lối đi riêng, cửa sổ và khu bếp; đang sẵn sàng nhận khách. Nhóm khách phù hợp: Công nhân, lao động địa phương. Nội dung và tiện ích giả lập.",
      "Area": 20,
      "Floor": "Tầng 1",
      "RoomType": "Room",
      "Amenities": [
        "Wifi",
        "Kitchen",
        "Bed",
        "Mattress"
      ],
      "AmenitiesConfirmed": true,
      "ToiletType": "Private",
      "AccessHours": "Tự do; giữ yên tĩnh sau 22:00, báo quản lý khi có khách ở lại (quy định mẫu).",
      "LaundryType": "Shared",
      "ParkingType": "Shared",
      "MaxVehicles": 2,
      "PetsAllowed": true,
      "ElectricVehiclesAllowed": false,
      "HasWindow": true,
      "HasBalcony": false,
      "SuggestedDeposit": 1500000,
      "MinimumLeaseMonths": 6,
      "Neighborhood": "Khu vực Châu Văn Liêm, phường Ô Môn, TP. Cần Thơ. Mô tả mẫu: kết nối Đường Trần Hưng Đạo, có nhu cầu ăn uống, mua sắm và đi học/đi làm trong khu vực. Chưa khảo sát khoảng cách hoặc thời gian di chuyển thực tế.",
      "RentalConditions": "Dữ liệu giả lập phục vụ demo. Tiền thuê tính đủ tháng. Điện, nước, internet và vệ sinh theo đơn giá được công bố của khu. Phí giữ xe và giặt sấy chưa công bố, cần xác nhận trước khi nhận phòng. Báo trước khi trả phòng theo thỏa thuận trong hợp đồng.",
      "ContactName": "Ban quản lý DVP Ô Môn (mẫu)",
      "ContactPhone": "",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_p6",
      "BranchId": "om",
      "Name": "P.106",
      "Price": 1600000,
      "Capacity": 2,
      "IsMaintenance": true,
      "Description": "Phòng 22 m² đang chống thấm và thay thiết bị vệ sinh, chưa nhận khách. Nhóm khách phù hợp: Công nhân, lao động địa phương. Nội dung và tiện ích giả lập.",
      "Area": 22,
      "Floor": "Trệt",
      "RoomType": "Room",
      "Amenities": [
        "Wifi",
        "Kitchen",
        "Bed",
        "Mattress"
      ],
      "AmenitiesConfirmed": true,
      "ToiletType": "Private",
      "AccessHours": "Tự do; giữ yên tĩnh sau 22:00, báo quản lý khi có khách ở lại (quy định mẫu).",
      "LaundryType": "Shared",
      "ParkingType": "Shared",
      "MaxVehicles": 2,
      "PetsAllowed": false,
      "ElectricVehiclesAllowed": false,
      "HasWindow": true,
      "HasBalcony": false,
      "SuggestedDeposit": 1600000,
      "MinimumLeaseMonths": 6,
      "Neighborhood": "Khu vực Châu Văn Liêm, phường Ô Môn, TP. Cần Thơ. Mô tả mẫu: kết nối Đường Trần Hưng Đạo, có nhu cầu ăn uống, mua sắm và đi học/đi làm trong khu vực. Chưa khảo sát khoảng cách hoặc thời gian di chuyển thực tế.",
      "RentalConditions": "Dữ liệu giả lập phục vụ demo. Tiền thuê tính đủ tháng. Điện, nước, internet và vệ sinh theo đơn giá được công bố của khu. Phí giữ xe và giặt sấy chưa công bố, cần xác nhận trước khi nhận phòng. Báo trước khi trả phòng theo thỏa thuận trong hợp đồng.",
      "ContactName": "Ban quản lý DVP Ô Môn (mẫu)",
      "ContactPhone": "",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    }
  ],
  "tenants": [
    {
      "key": "nk_t1",
      "BranchId": "nk",
      "FullName": "Nguyễn Hoàng Phúc",
      "Phone": "CT-DEMO-001",
      "IdentityNumber": "CT-DEMO-CCCD-0001",
      "Address": "Địa chỉ cư trú mô phỏng CT-1, xã Phong Điền, TP. Cần Thơ (hư cấu)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_t2",
      "BranchId": "nk",
      "FullName": "Trần Ngọc Hân",
      "Phone": "CT-DEMO-002",
      "IdentityNumber": "CT-DEMO-CCCD-0002",
      "Address": "Địa chỉ cư trú mô phỏng CT-2, phường Thốt Nốt, TP. Cần Thơ (hư cấu)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_t3",
      "BranchId": "nk",
      "FullName": "Lê Minh Khang",
      "Phone": "CT-DEMO-003",
      "IdentityNumber": "CT-DEMO-CCCD-0003",
      "Address": "Địa chỉ cư trú mô phỏng CT-3, phường Ô Môn, TP. Cần Thơ (hư cấu)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_t4",
      "BranchId": "nk",
      "FullName": "Phạm Thị Bích Trâm",
      "Phone": "CT-DEMO-004",
      "IdentityNumber": "CT-DEMO-CCCD-0004",
      "Address": "Địa chỉ cư trú mô phỏng CT-4, phường Bình Thủy, TP. Cần Thơ (hư cấu)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_t5",
      "BranchId": "nk",
      "FullName": "Võ Thanh Tùng",
      "Phone": "CT-DEMO-005",
      "IdentityNumber": "CT-DEMO-CCCD-0005",
      "Address": "Địa chỉ cư trú mô phỏng CT-5, phường Cái Răng, TP. Cần Thơ (hư cấu)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_t6",
      "BranchId": "nk",
      "FullName": "Đặng Thị Thu Thảo",
      "Phone": "CT-DEMO-006",
      "IdentityNumber": "CT-DEMO-CCCD-0006",
      "Address": "Địa chỉ cư trú mô phỏng CT-6, phường Ninh Kiều, TP. Cần Thơ (hư cấu)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_t7",
      "BranchId": "nk",
      "FullName": "Bùi Gia Bảo",
      "Phone": "CT-DEMO-007",
      "IdentityNumber": "CT-DEMO-CCCD-0007",
      "Address": "Địa chỉ cư trú mô phỏng CT-7, phường Tân An, TP. Cần Thơ (hư cấu)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_t1",
      "BranchId": "ta",
      "FullName": "Trần Anh Duy",
      "Phone": "CT-DEMO-008",
      "IdentityNumber": "CT-DEMO-CCCD-0008",
      "Address": "Địa chỉ cư trú mô phỏng CT-8, xã Phong Điền, TP. Cần Thơ (hư cấu)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_t2",
      "BranchId": "ta",
      "FullName": "Nguyễn Thị Quỳnh Như",
      "Phone": "CT-DEMO-009",
      "IdentityNumber": "CT-DEMO-CCCD-0009",
      "Address": "Địa chỉ cư trú mô phỏng CT-9, phường Thốt Nốt, TP. Cần Thơ (hư cấu)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_t3",
      "BranchId": "ta",
      "FullName": "Võ Minh Tâm",
      "Phone": "CT-DEMO-010",
      "IdentityNumber": "CT-DEMO-CCCD-0010",
      "Address": "Địa chỉ cư trú mô phỏng CT-10, phường Ô Môn, TP. Cần Thơ (hư cấu)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_t4",
      "BranchId": "ta",
      "FullName": "Lê Thị Thanh Trúc",
      "Phone": "CT-DEMO-011",
      "IdentityNumber": "CT-DEMO-CCCD-0011",
      "Address": "Địa chỉ cư trú mô phỏng CT-11, phường Bình Thủy, TP. Cần Thơ (hư cấu)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_t5",
      "BranchId": "ta",
      "FullName": "Phạm Quốc Huy",
      "Phone": "CT-DEMO-012",
      "IdentityNumber": "CT-DEMO-CCCD-0012",
      "Address": "Địa chỉ cư trú mô phỏng CT-12, phường Cái Răng, TP. Cần Thơ (hư cấu)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_t6",
      "BranchId": "ta",
      "FullName": "Huỳnh Mỹ Linh",
      "Phone": "CT-DEMO-013",
      "IdentityNumber": "CT-DEMO-CCCD-0013",
      "Address": "Địa chỉ cư trú mô phỏng CT-13, phường Ninh Kiều, TP. Cần Thơ (hư cấu)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_t7",
      "BranchId": "ta",
      "FullName": "Đỗ Bảo Châu",
      "Phone": "CT-DEMO-014",
      "IdentityNumber": "CT-DEMO-CCCD-0014",
      "Address": "Địa chỉ cư trú mô phỏng CT-14, phường Tân An, TP. Cần Thơ (hư cấu)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_t1",
      "BranchId": "ck",
      "FullName": "Lê Quốc Khánh",
      "Phone": "CT-DEMO-015",
      "IdentityNumber": "CT-DEMO-CCCD-0015",
      "Address": "Địa chỉ cư trú mô phỏng CT-15, xã Phong Điền, TP. Cần Thơ (hư cấu)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_t2",
      "BranchId": "ck",
      "FullName": "Phan Thị Ngọc Ánh",
      "Phone": "CT-DEMO-016",
      "IdentityNumber": "CT-DEMO-CCCD-0016",
      "Address": "Địa chỉ cư trú mô phỏng CT-16, phường Thốt Nốt, TP. Cần Thơ (hư cấu)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_t3",
      "BranchId": "ck",
      "FullName": "Nguyễn Hữu Đạt",
      "Phone": "CT-DEMO-017",
      "IdentityNumber": "CT-DEMO-CCCD-0017",
      "Address": "Địa chỉ cư trú mô phỏng CT-17, phường Ô Môn, TP. Cần Thơ (hư cấu)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_t4",
      "BranchId": "ck",
      "FullName": "Trần Thị Hải Yến",
      "Phone": "CT-DEMO-018",
      "IdentityNumber": "CT-DEMO-CCCD-0018",
      "Address": "Địa chỉ cư trú mô phỏng CT-18, phường Bình Thủy, TP. Cần Thơ (hư cấu)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_t5",
      "BranchId": "ck",
      "FullName": "Võ Đức Hòa",
      "Phone": "CT-DEMO-019",
      "IdentityNumber": "CT-DEMO-CCCD-0019",
      "Address": "Địa chỉ cư trú mô phỏng CT-19, phường Cái Răng, TP. Cần Thơ (hư cấu)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_t6",
      "BranchId": "ck",
      "FullName": "Bùi Thanh Loan",
      "Phone": "CT-DEMO-020",
      "IdentityNumber": "CT-DEMO-CCCD-0020",
      "Address": "Địa chỉ cư trú mô phỏng CT-20, phường Ninh Kiều, TP. Cần Thơ (hư cấu)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_t7",
      "BranchId": "ck",
      "FullName": "Đặng Nhật Minh",
      "Phone": "CT-DEMO-021",
      "IdentityNumber": "CT-DEMO-CCCD-0021",
      "Address": "Địa chỉ cư trú mô phỏng CT-21, phường Tân An, TP. Cần Thơ (hư cấu)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_t1",
      "BranchId": "bt",
      "FullName": "Phạm Minh Thiện",
      "Phone": "CT-DEMO-022",
      "IdentityNumber": "CT-DEMO-CCCD-0022",
      "Address": "Địa chỉ cư trú mô phỏng CT-22, xã Phong Điền, TP. Cần Thơ (hư cấu)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_t2",
      "BranchId": "bt",
      "FullName": "Nguyễn Thị Kiều Oanh",
      "Phone": "CT-DEMO-023",
      "IdentityNumber": "CT-DEMO-CCCD-0023",
      "Address": "Địa chỉ cư trú mô phỏng CT-23, phường Thốt Nốt, TP. Cần Thơ (hư cấu)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_t3",
      "BranchId": "bt",
      "FullName": "Trần Thanh Sơn",
      "Phone": "CT-DEMO-024",
      "IdentityNumber": "CT-DEMO-CCCD-0024",
      "Address": "Địa chỉ cư trú mô phỏng CT-24, phường Ô Môn, TP. Cần Thơ (hư cấu)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_t4",
      "BranchId": "bt",
      "FullName": "Huỳnh Thị Hồng Nhung",
      "Phone": "CT-DEMO-025",
      "IdentityNumber": "CT-DEMO-CCCD-0025",
      "Address": "Địa chỉ cư trú mô phỏng CT-25, phường Bình Thủy, TP. Cần Thơ (hư cấu)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_t5",
      "BranchId": "bt",
      "FullName": "Lê Anh Kiệt",
      "Phone": "CT-DEMO-026",
      "IdentityNumber": "CT-DEMO-CCCD-0026",
      "Address": "Địa chỉ cư trú mô phỏng CT-26, phường Cái Răng, TP. Cần Thơ (hư cấu)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_t6",
      "BranchId": "bt",
      "FullName": "Võ Thị Thúy An",
      "Phone": "CT-DEMO-027",
      "IdentityNumber": "CT-DEMO-CCCD-0027",
      "Address": "Địa chỉ cư trú mô phỏng CT-27, phường Ninh Kiều, TP. Cần Thơ (hư cấu)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_t7",
      "BranchId": "bt",
      "FullName": "Phan Tuấn Vũ",
      "Phone": "CT-DEMO-028",
      "IdentityNumber": "CT-DEMO-CCCD-0028",
      "Address": "Địa chỉ cư trú mô phỏng CT-28, phường Tân An, TP. Cần Thơ (hư cấu)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_t1",
      "BranchId": "cr",
      "FullName": "Võ Hoàng Nam",
      "Phone": "CT-DEMO-029",
      "IdentityNumber": "CT-DEMO-CCCD-0029",
      "Address": "Địa chỉ cư trú mô phỏng CT-29, xã Phong Điền, TP. Cần Thơ (hư cấu)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_t2",
      "BranchId": "cr",
      "FullName": "Trần Thị Kim Chi",
      "Phone": "CT-DEMO-030",
      "IdentityNumber": "CT-DEMO-CCCD-0030",
      "Address": "Địa chỉ cư trú mô phỏng CT-30, phường Thốt Nốt, TP. Cần Thơ (hư cấu)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_t3",
      "BranchId": "cr",
      "FullName": "Nguyễn Thành Đạt",
      "Phone": "CT-DEMO-031",
      "IdentityNumber": "CT-DEMO-CCCD-0031",
      "Address": "Địa chỉ cư trú mô phỏng CT-31, phường Ô Môn, TP. Cần Thơ (hư cấu)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_t4",
      "BranchId": "cr",
      "FullName": "Lê Thị Phương Thảo",
      "Phone": "CT-DEMO-032",
      "IdentityNumber": "CT-DEMO-CCCD-0032",
      "Address": "Địa chỉ cư trú mô phỏng CT-32, phường Bình Thủy, TP. Cần Thơ (hư cấu)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_t5",
      "BranchId": "cr",
      "FullName": "Đặng Thanh Bình",
      "Phone": "CT-DEMO-033",
      "IdentityNumber": "CT-DEMO-CCCD-0033",
      "Address": "Địa chỉ cư trú mô phỏng CT-33, phường Cái Răng, TP. Cần Thơ (hư cấu)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_t6",
      "BranchId": "cr",
      "FullName": "Phạm Ngọc Diễm",
      "Phone": "CT-DEMO-034",
      "IdentityNumber": "CT-DEMO-CCCD-0034",
      "Address": "Địa chỉ cư trú mô phỏng CT-34, phường Ninh Kiều, TP. Cần Thơ (hư cấu)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_t7",
      "BranchId": "cr",
      "FullName": "Huỳnh Gia Hân",
      "Phone": "CT-DEMO-035",
      "IdentityNumber": "CT-DEMO-CCCD-0035",
      "Address": "Địa chỉ cư trú mô phỏng CT-35, phường Tân An, TP. Cần Thơ (hư cấu)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_t1",
      "BranchId": "om",
      "FullName": "Đặng Hữu Nghĩa",
      "Phone": "CT-DEMO-036",
      "IdentityNumber": "CT-DEMO-CCCD-0036",
      "Address": "Địa chỉ cư trú mô phỏng CT-36, xã Phong Điền, TP. Cần Thơ (hư cấu)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_t2",
      "BranchId": "om",
      "FullName": "Võ Thị Ngọc Mai",
      "Phone": "CT-DEMO-037",
      "IdentityNumber": "CT-DEMO-CCCD-0037",
      "Address": "Địa chỉ cư trú mô phỏng CT-37, phường Thốt Nốt, TP. Cần Thơ (hư cấu)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_t3",
      "BranchId": "om",
      "FullName": "Nguyễn Minh Trí",
      "Phone": "CT-DEMO-038",
      "IdentityNumber": "CT-DEMO-CCCD-0038",
      "Address": "Địa chỉ cư trú mô phỏng CT-38, phường Ô Môn, TP. Cần Thơ (hư cấu)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_t4",
      "BranchId": "om",
      "FullName": "Trần Thị Cẩm Tú",
      "Phone": "CT-DEMO-039",
      "IdentityNumber": "CT-DEMO-CCCD-0039",
      "Address": "Địa chỉ cư trú mô phỏng CT-39, phường Bình Thủy, TP. Cần Thơ (hư cấu)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_t5",
      "BranchId": "om",
      "FullName": "Lê Văn Hiếu",
      "Phone": "CT-DEMO-040",
      "IdentityNumber": "CT-DEMO-CCCD-0040",
      "Address": "Địa chỉ cư trú mô phỏng CT-40, phường Cái Răng, TP. Cần Thơ (hư cấu)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_t6",
      "BranchId": "om",
      "FullName": "Phan Thị Mỹ Tiên",
      "Phone": "CT-DEMO-041",
      "IdentityNumber": "CT-DEMO-CCCD-0041",
      "Address": "Địa chỉ cư trú mô phỏng CT-41, phường Ninh Kiều, TP. Cần Thơ (hư cấu)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_t7",
      "BranchId": "om",
      "FullName": "Bùi Hoàng Long",
      "Phone": "CT-DEMO-042",
      "IdentityNumber": "CT-DEMO-CCCD-0042",
      "Address": "Địa chỉ cư trú mô phỏng CT-42, phường Tân An, TP. Cần Thơ (hư cấu)",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    }
  ],
  "users": [
    {
      "key": "ct_ql_nk",
      "Username": "ct_ql_nk",
      "FullName": "Nguyễn Thị Thanh Hương",
      "PasswordHash": "AQAAAAIAAYagAAAAEIrUxE9xZtXNDy1PxO2hoHQoGH0MDDpIaEfDJSCCDfUGoFu1T6fVlz8IQoIN8CzT/w==",
      "Role": "Manager",
      "IsActive": true,
      "TenantId": null,
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_nk_01",
      "Username": "ct_nk_01",
      "FullName": "Nguyễn Hoàng Phúc",
      "PasswordHash": "AQAAAAIAAYagAAAAEDf5ugGQ7SJV46HxND0x2uR+yKtXpVW3lidMUbQq8OcS/k/iCgtOs5kbWHGEUIcg3A==",
      "Role": "Tenant",
      "IsActive": true,
      "TenantId": "nk_t1",
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_nk_02",
      "Username": "ct_nk_02",
      "FullName": "Trần Ngọc Hân",
      "PasswordHash": "AQAAAAIAAYagAAAAEKv6h76RMFRBSroNbRHa9SkENdKm/Oo9Qm5Fd8RHoqJHXtR6woSwXVGNEUF4cyjCTA==",
      "Role": "Tenant",
      "IsActive": true,
      "TenantId": "nk_t2",
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_nk_03",
      "Username": "ct_nk_03",
      "FullName": "Lê Minh Khang",
      "PasswordHash": "AQAAAAIAAYagAAAAEBF20ipLxMP57P3pR4s180tLAD+V2+9dvFxUuGln8nxCoeO49INoYzxrCeQOA7v1Bg==",
      "Role": "Tenant",
      "IsActive": true,
      "TenantId": "nk_t3",
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_nk_04",
      "Username": "ct_nk_04",
      "FullName": "Phạm Thị Bích Trâm",
      "PasswordHash": "AQAAAAIAAYagAAAAEB+4vB1w28Y5SE7CyeKpP+Pq0cUoy482kLRcGFDCzuwdt6ORCTdysq7WBqYlAsw6aQ==",
      "Role": "Tenant",
      "IsActive": true,
      "TenantId": "nk_t4",
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_nk_05",
      "Username": "ct_nk_05",
      "FullName": "Võ Thanh Tùng",
      "PasswordHash": "AQAAAAIAAYagAAAAEECRffQ8uIE9EhKCKtq2dKFhSsRr6rgFUlfcrRxDp5zczX5knfuuNhcr2fH5urx85A==",
      "Role": "Tenant",
      "IsActive": true,
      "TenantId": "nk_t5",
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_nk_06",
      "Username": "ct_nk_06",
      "FullName": "Đặng Thị Thu Thảo",
      "PasswordHash": "AQAAAAIAAYagAAAAEJJmneiXjxBBLqNUZE+1EVo0j8QVjC42kLcNGkWTSciYPxOhqi/7+pZDSBb8pUEQTQ==",
      "Role": "Tenant",
      "IsActive": true,
      "TenantId": "nk_t6",
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_nk_07",
      "Username": "ct_nk_07",
      "FullName": "Bùi Gia Bảo",
      "PasswordHash": "AQAAAAIAAYagAAAAEGgDyfpmploMBhNGA3GBo/bHtMYUpzcFGz7wDOMAlu1pwYNbH4i0ok1SN6LmS+aCPQ==",
      "Role": "Tenant",
      "IsActive": true,
      "TenantId": "nk_t7",
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_ql_ta",
      "Username": "ct_ql_ta",
      "FullName": "Trần Quốc Bảo",
      "PasswordHash": "AQAAAAIAAYagAAAAEDxDc8jqA16+jFCYwe6PUgoM0u/FAULhX5ZABG6yCHuDsnPd4LylkQwSlRdnXhV2fg==",
      "Role": "Manager",
      "IsActive": true,
      "TenantId": null,
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_ta_01",
      "Username": "ct_ta_01",
      "FullName": "Trần Anh Duy",
      "PasswordHash": "AQAAAAIAAYagAAAAEOQm+hnSrQx0Z2UfGIP2XKk9HOy5KbIocRLBqL1ytFFK3QfNEe/jNGTM9aErQQK8BA==",
      "Role": "Tenant",
      "IsActive": true,
      "TenantId": "ta_t1",
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_ta_02",
      "Username": "ct_ta_02",
      "FullName": "Nguyễn Thị Quỳnh Như",
      "PasswordHash": "AQAAAAIAAYagAAAAEFbnv3er1qZyskeyyAa2LcOTq8sbLDzHQgpWE8HS+oV3/nUBRKiPDT3JwZODFuWZFA==",
      "Role": "Tenant",
      "IsActive": true,
      "TenantId": "ta_t2",
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_ta_03",
      "Username": "ct_ta_03",
      "FullName": "Võ Minh Tâm",
      "PasswordHash": "AQAAAAIAAYagAAAAEP7ScoQXHdTCWMX7lQp8K2RZ4m5Vwa5laJdCVRzVyadMqmxpKtMHh7X9M8TUHHeYrQ==",
      "Role": "Tenant",
      "IsActive": true,
      "TenantId": "ta_t3",
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_ta_04",
      "Username": "ct_ta_04",
      "FullName": "Lê Thị Thanh Trúc",
      "PasswordHash": "AQAAAAIAAYagAAAAECODpKt4ssTFyJ1wFC+hFqEHFbElHBr0xhtq128KAEkCDS2EhS73YL04s/sBs0Xo/Q==",
      "Role": "Tenant",
      "IsActive": true,
      "TenantId": "ta_t4",
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_ta_05",
      "Username": "ct_ta_05",
      "FullName": "Phạm Quốc Huy",
      "PasswordHash": "AQAAAAIAAYagAAAAENuOihCLNK6ueecZHrIRPubvze33DsWcpZTlJmdpttYhCGqji5yDXkzkmb3UzKBepw==",
      "Role": "Tenant",
      "IsActive": true,
      "TenantId": "ta_t5",
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_ta_06",
      "Username": "ct_ta_06",
      "FullName": "Huỳnh Mỹ Linh",
      "PasswordHash": "AQAAAAIAAYagAAAAEMG6msAh+1qXV72Oc0FBSX29S/vWRO94BvGFkiQBsQr4cHHvDhO3P+w1wNIpLqZYvg==",
      "Role": "Tenant",
      "IsActive": true,
      "TenantId": "ta_t6",
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_ta_07",
      "Username": "ct_ta_07",
      "FullName": "Đỗ Bảo Châu",
      "PasswordHash": "AQAAAAIAAYagAAAAEJ1XhjVlbPwW3tasxstK8j50E0u31MWqg6xrDZ/Kp/b7J6YCruF5CaUQDKjSd6z41g==",
      "Role": "Tenant",
      "IsActive": true,
      "TenantId": "ta_t7",
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_ql_ck",
      "Username": "ct_ql_ck",
      "FullName": "Lê Thị Kim Ngân",
      "PasswordHash": "AQAAAAIAAYagAAAAEKbLoHK15mR1z+aSPQrq8lPS3m9mKtiyGVXDWzPe4Wx6LhJKMbYwY2J+68aavzjLDg==",
      "Role": "Manager",
      "IsActive": true,
      "TenantId": null,
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_ck_01",
      "Username": "ct_ck_01",
      "FullName": "Lê Quốc Khánh",
      "PasswordHash": "AQAAAAIAAYagAAAAENb2osUEWSI89AoofW9qm4FWqit7avFjH6Ru8mQiGwF7Q8hzSOboyPhoy4svgG66gA==",
      "Role": "Tenant",
      "IsActive": true,
      "TenantId": "ck_t1",
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_ck_02",
      "Username": "ct_ck_02",
      "FullName": "Phan Thị Ngọc Ánh",
      "PasswordHash": "AQAAAAIAAYagAAAAEMkRAgP7gGeOsbmo2SK4YjrImboWruxRLnhO9bukcVnvPIViTd+Glg+ty/pUmH581w==",
      "Role": "Tenant",
      "IsActive": true,
      "TenantId": "ck_t2",
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_ck_03",
      "Username": "ct_ck_03",
      "FullName": "Nguyễn Hữu Đạt",
      "PasswordHash": "AQAAAAIAAYagAAAAEKBDBr70rHevGmTXCY3lWGvpt+zpmZAiBDM7zxI9fOtaeNWu0qaPGrPasejrxP3YdA==",
      "Role": "Tenant",
      "IsActive": true,
      "TenantId": "ck_t3",
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_ck_04",
      "Username": "ct_ck_04",
      "FullName": "Trần Thị Hải Yến",
      "PasswordHash": "AQAAAAIAAYagAAAAENpmArFb3SYQH7mLJlG1hgABuql68LWqPWUatO//F5sBLSTi6i7PX+5PKLBYhurNkg==",
      "Role": "Tenant",
      "IsActive": true,
      "TenantId": "ck_t4",
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_ck_05",
      "Username": "ct_ck_05",
      "FullName": "Võ Đức Hòa",
      "PasswordHash": "AQAAAAIAAYagAAAAELVFByxOzvIoAgulTNa0NkPUOLhGR1n+XIYK7CPw8sy+bumfzJAIW3sEsHP1QCzDIQ==",
      "Role": "Tenant",
      "IsActive": true,
      "TenantId": "ck_t5",
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_ck_06",
      "Username": "ct_ck_06",
      "FullName": "Bùi Thanh Loan",
      "PasswordHash": "AQAAAAIAAYagAAAAEIevXX9IJPVPYDOhnXINhDvkEkIu8whD4vwCxm50nxJluTGoLad3v6fr9BI915yjfg==",
      "Role": "Tenant",
      "IsActive": true,
      "TenantId": "ck_t6",
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_ck_07",
      "Username": "ct_ck_07",
      "FullName": "Đặng Nhật Minh",
      "PasswordHash": "AQAAAAIAAYagAAAAEI5bH7kjRfyyrpK0ANAz+DRRPpGFvH7XzlRYtARJ7ZnU/m4LdRsM5rvrvObSg/EYzA==",
      "Role": "Tenant",
      "IsActive": true,
      "TenantId": "ck_t7",
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_ql_bt",
      "Username": "ct_ql_bt",
      "FullName": "Phạm Văn Thành",
      "PasswordHash": "AQAAAAIAAYagAAAAELqUXPwJZ3jTtlrmW5hK+A/JvdizeRDPaCIC1Gjhmt073dcMeNoXNJupPW53OENAEw==",
      "Role": "Manager",
      "IsActive": true,
      "TenantId": null,
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_bt_01",
      "Username": "ct_bt_01",
      "FullName": "Phạm Minh Thiện",
      "PasswordHash": "AQAAAAIAAYagAAAAEFfeW2uDv8PNfFkCNeJQQu4F7OTUFMBuMVpPNcIVdhutzL+qO/fuuzKm1YXp1mkYTQ==",
      "Role": "Tenant",
      "IsActive": true,
      "TenantId": "bt_t1",
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_bt_02",
      "Username": "ct_bt_02",
      "FullName": "Nguyễn Thị Kiều Oanh",
      "PasswordHash": "AQAAAAIAAYagAAAAEFn8dWffcsZxWu2EV5n1BMPhVdaCIGSonWps3/b0gLnhbU/uRdvaN5B1hGsq9+rJ1Q==",
      "Role": "Tenant",
      "IsActive": true,
      "TenantId": "bt_t2",
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_bt_03",
      "Username": "ct_bt_03",
      "FullName": "Trần Thanh Sơn",
      "PasswordHash": "AQAAAAIAAYagAAAAEMWORLNPD3mHaLWpweEKchbl4S0YUv6Ikxyfh7BBWl9uKQD+sfLaeiQO5O57/eiK5A==",
      "Role": "Tenant",
      "IsActive": true,
      "TenantId": "bt_t3",
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_bt_04",
      "Username": "ct_bt_04",
      "FullName": "Huỳnh Thị Hồng Nhung",
      "PasswordHash": "AQAAAAIAAYagAAAAEJsfsuHD8Z6zoQHHI2zivngH73FfxFQyzNuMAgc8R7TNxYiQffvGch6e3YoDqPMxUQ==",
      "Role": "Tenant",
      "IsActive": true,
      "TenantId": "bt_t4",
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_bt_05",
      "Username": "ct_bt_05",
      "FullName": "Lê Anh Kiệt",
      "PasswordHash": "AQAAAAIAAYagAAAAECi2HO82qoQqP7G8G/W32hy63HZWoW82tJTrhLgjXCWnzWeyT38YG6r4+oVCs8IkMA==",
      "Role": "Tenant",
      "IsActive": true,
      "TenantId": "bt_t5",
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_bt_06",
      "Username": "ct_bt_06",
      "FullName": "Võ Thị Thúy An",
      "PasswordHash": "AQAAAAIAAYagAAAAEKFvjqxDTCBdmUz6OqqGuUF/EZFzW5rMH3yCytpgO4Xe7MXqrgKXnzZjKLsjWA7+ug==",
      "Role": "Tenant",
      "IsActive": true,
      "TenantId": "bt_t6",
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_bt_07",
      "Username": "ct_bt_07",
      "FullName": "Phan Tuấn Vũ",
      "PasswordHash": "AQAAAAIAAYagAAAAEAleZ6CDxfXEWWUUWzsO8DEdZVCLIGnU0mlOmd3NnxXmEtg4yu/dMnLWTNJIYed/rA==",
      "Role": "Tenant",
      "IsActive": true,
      "TenantId": "bt_t7",
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_ql_cr",
      "Username": "ct_ql_cr",
      "FullName": "Võ Thị Mỹ Duyên",
      "PasswordHash": "AQAAAAIAAYagAAAAEGRTTqd9yPAKxmKyK2cQtlXofiWR9ZjcmRgeMerjWF1EFVe8kTg8LYQ2wqQ0kzHZyA==",
      "Role": "Manager",
      "IsActive": true,
      "TenantId": null,
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_cr_01",
      "Username": "ct_cr_01",
      "FullName": "Võ Hoàng Nam",
      "PasswordHash": "AQAAAAIAAYagAAAAEBQ7FIf/EIftqVr8LeptMOA3NcQMOcz2qIyVpJusDpT8+2Dk3G2Q20+hJsNJOqno2Q==",
      "Role": "Tenant",
      "IsActive": true,
      "TenantId": "cr_t1",
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_cr_02",
      "Username": "ct_cr_02",
      "FullName": "Trần Thị Kim Chi",
      "PasswordHash": "AQAAAAIAAYagAAAAELxGE9DBFnle4YiVsxbVnEM8QRXhIj+iybuNnbgZQ66wMqaGa6usyafJ4plu4XKcSg==",
      "Role": "Tenant",
      "IsActive": true,
      "TenantId": "cr_t2",
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_cr_03",
      "Username": "ct_cr_03",
      "FullName": "Nguyễn Thành Đạt",
      "PasswordHash": "AQAAAAIAAYagAAAAEEmt6Q4rxP4sg1lg9pKM/kVQ5jfSevKSEpbMtSxSrIfbfgZsGfc0IknjG1FuVTh5dA==",
      "Role": "Tenant",
      "IsActive": true,
      "TenantId": "cr_t3",
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_cr_04",
      "Username": "ct_cr_04",
      "FullName": "Lê Thị Phương Thảo",
      "PasswordHash": "AQAAAAIAAYagAAAAEA45Z+m0xV9BcyB+nukgxH0A0hq7dgzjuaNY6mJsdZxl9kAdGO/2cUWuCMUthhXBIA==",
      "Role": "Tenant",
      "IsActive": true,
      "TenantId": "cr_t4",
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_cr_05",
      "Username": "ct_cr_05",
      "FullName": "Đặng Thanh Bình",
      "PasswordHash": "AQAAAAIAAYagAAAAEDZCRE5oQA9imCfhu9zNegtWIA7Em7des6gOCW7v+V+Kt48Hkb28qpcXUU5n2cGBJQ==",
      "Role": "Tenant",
      "IsActive": true,
      "TenantId": "cr_t5",
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_cr_06",
      "Username": "ct_cr_06",
      "FullName": "Phạm Ngọc Diễm",
      "PasswordHash": "AQAAAAIAAYagAAAAECFRM9Dqn5lUk/sj+h6FzAHDPI5dRz1DGf/eZmJyLMnQQn5ozGGDtpZC4/VRK486pQ==",
      "Role": "Tenant",
      "IsActive": true,
      "TenantId": "cr_t6",
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_cr_07",
      "Username": "ct_cr_07",
      "FullName": "Huỳnh Gia Hân",
      "PasswordHash": "AQAAAAIAAYagAAAAEArzIPvzrQi+W8liLTLGaqYrsJWiVrMpXq6wriFQWJr8X/ZU6Os9q4/igK4NVFlyzQ==",
      "Role": "Tenant",
      "IsActive": true,
      "TenantId": "cr_t7",
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_ql_om",
      "Username": "ct_ql_om",
      "FullName": "Đặng Minh Tuấn",
      "PasswordHash": "AQAAAAIAAYagAAAAEDvTSpHg2YddhUvHnU92SSO4W7ni71x2eKA9pu90R1LRsvfLgztNRtMmoZB8wnQtPw==",
      "Role": "Manager",
      "IsActive": true,
      "TenantId": null,
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_om_01",
      "Username": "ct_om_01",
      "FullName": "Đặng Hữu Nghĩa",
      "PasswordHash": "AQAAAAIAAYagAAAAEO2rc0PydiGCmRH0VJPzk+QF/+yrE/c2HYnWVr4UVjHrqWPfXOY0UdnxySQiTsLEeA==",
      "Role": "Tenant",
      "IsActive": true,
      "TenantId": "om_t1",
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_om_02",
      "Username": "ct_om_02",
      "FullName": "Võ Thị Ngọc Mai",
      "PasswordHash": "AQAAAAIAAYagAAAAELrgy3M5O3AeFMtNrpDFIIfSC6lkwjaB50WrbsTVrTUm5s2GUfk7R1LvAYtfMa0MZw==",
      "Role": "Tenant",
      "IsActive": true,
      "TenantId": "om_t2",
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_om_03",
      "Username": "ct_om_03",
      "FullName": "Nguyễn Minh Trí",
      "PasswordHash": "AQAAAAIAAYagAAAAEClXtwcWGwTw9bHTlmGLs+sohepgmmkYaWMMBT586L1O+rkfMjL9WFOY1wJ8rSh6hw==",
      "Role": "Tenant",
      "IsActive": true,
      "TenantId": "om_t3",
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_om_04",
      "Username": "ct_om_04",
      "FullName": "Trần Thị Cẩm Tú",
      "PasswordHash": "AQAAAAIAAYagAAAAEKuXKrPcGxvVXGv8J3GPetJ84Cg8EZ2/5vLIbGoTXqt+H2c2oVCa/VW63WIlMjPOvA==",
      "Role": "Tenant",
      "IsActive": true,
      "TenantId": "om_t4",
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_om_05",
      "Username": "ct_om_05",
      "FullName": "Lê Văn Hiếu",
      "PasswordHash": "AQAAAAIAAYagAAAAEJDU7+mHt1j7R6UDtxbic7luaH4Zfawe+n7EsQK/MIdBeWSQROqGjDdNpR5aygYOEg==",
      "Role": "Tenant",
      "IsActive": true,
      "TenantId": "om_t5",
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_om_06",
      "Username": "ct_om_06",
      "FullName": "Phan Thị Mỹ Tiên",
      "PasswordHash": "AQAAAAIAAYagAAAAEEhNL7xL3H1rDCl7Bqj4Q35CrfHfpyvIkokMZetjQkepHmfbVb/ZVwJligqcxkvAeQ==",
      "Role": "Tenant",
      "IsActive": true,
      "TenantId": "om_t6",
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_om_07",
      "Username": "ct_om_07",
      "FullName": "Bùi Hoàng Long",
      "PasswordHash": "AQAAAAIAAYagAAAAEMRD7mIRSGcfyCoxiuUuWjXb6IQyuZBI4cnrvtVLxNMQaLhohUXtUaF9Qmqtr9iscQ==",
      "Role": "Tenant",
      "IsActive": true,
      "TenantId": "om_t7",
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ct_ql_lienkhu",
      "Username": "ct_ql_lienkhu",
      "FullName": "Nguyễn Minh Quân",
      "PasswordHash": "AQAAAAIAAYagAAAAEEsJrTdhDADpX51BtfDwlDAozuQU9bU6rLHI/QomQSIp1yVcPqeD6UCTLw7gf7YXLg==",
      "Role": "Manager",
      "IsActive": true,
      "TenantId": null,
      "CreatedAt": "2026-10-27T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    }
  ],
  "user_branches": [
    {
      "UserId": "ct_ql_nk",
      "BranchId": "nk"
    },
    {
      "UserId": "ct_ql_ta",
      "BranchId": "ta"
    },
    {
      "UserId": "ct_ql_ck",
      "BranchId": "ck"
    },
    {
      "UserId": "ct_ql_bt",
      "BranchId": "bt"
    },
    {
      "UserId": "ct_ql_cr",
      "BranchId": "cr"
    },
    {
      "UserId": "ct_ql_om",
      "BranchId": "om"
    },
    {
      "UserId": "ct_ql_lienkhu",
      "BranchId": "nk"
    },
    {
      "UserId": "ct_ql_lienkhu",
      "BranchId": "ta"
    },
    {
      "UserId": "ct_ql_lienkhu",
      "BranchId": "ck"
    }
  ],
  "fees": [
    {
      "key": "nk_electric",
      "BranchId": "nk",
      "Name": "Điện",
      "Method": "Electricity",
      "UnitPrice": 3500,
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_water",
      "BranchId": "nk",
      "Name": "Nước",
      "Method": "Water",
      "UnitPrice": 12000,
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_internet",
      "BranchId": "nk",
      "Name": "Internet",
      "Method": "Fixed",
      "UnitPrice": 80000,
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_garbage",
      "BranchId": "nk",
      "Name": "Rác và vệ sinh",
      "Method": "PerPerson",
      "UnitPrice": 15000,
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_electric",
      "BranchId": "ta",
      "Name": "Điện",
      "Method": "Electricity",
      "UnitPrice": 3500,
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_water",
      "BranchId": "ta",
      "Name": "Nước",
      "Method": "Water",
      "UnitPrice": 12000,
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_internet",
      "BranchId": "ta",
      "Name": "Internet",
      "Method": "Fixed",
      "UnitPrice": 80000,
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_garbage",
      "BranchId": "ta",
      "Name": "Rác và vệ sinh",
      "Method": "PerPerson",
      "UnitPrice": 15000,
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_electric",
      "BranchId": "ck",
      "Name": "Điện",
      "Method": "Electricity",
      "UnitPrice": 3500,
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_water",
      "BranchId": "ck",
      "Name": "Nước",
      "Method": "Water",
      "UnitPrice": 12000,
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_internet",
      "BranchId": "ck",
      "Name": "Internet",
      "Method": "Fixed",
      "UnitPrice": 80000,
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_garbage",
      "BranchId": "ck",
      "Name": "Rác và vệ sinh",
      "Method": "PerPerson",
      "UnitPrice": 15000,
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_electric",
      "BranchId": "bt",
      "Name": "Điện",
      "Method": "Electricity",
      "UnitPrice": 3500,
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_water",
      "BranchId": "bt",
      "Name": "Nước",
      "Method": "Water",
      "UnitPrice": 12000,
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_internet",
      "BranchId": "bt",
      "Name": "Internet",
      "Method": "Fixed",
      "UnitPrice": 60000,
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_garbage",
      "BranchId": "bt",
      "Name": "Rác và vệ sinh",
      "Method": "PerPerson",
      "UnitPrice": 15000,
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_electric",
      "BranchId": "cr",
      "Name": "Điện",
      "Method": "Electricity",
      "UnitPrice": 3500,
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_water",
      "BranchId": "cr",
      "Name": "Nước",
      "Method": "Water",
      "UnitPrice": 12000,
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_internet",
      "BranchId": "cr",
      "Name": "Internet",
      "Method": "Fixed",
      "UnitPrice": 60000,
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_garbage",
      "BranchId": "cr",
      "Name": "Rác và vệ sinh",
      "Method": "PerPerson",
      "UnitPrice": 15000,
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_electric",
      "BranchId": "om",
      "Name": "Điện",
      "Method": "Electricity",
      "UnitPrice": 3500,
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_water",
      "BranchId": "om",
      "Name": "Nước",
      "Method": "Water",
      "UnitPrice": 12000,
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_internet",
      "BranchId": "om",
      "Name": "Internet",
      "Method": "Fixed",
      "UnitPrice": 60000,
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_garbage",
      "BranchId": "om",
      "Name": "Rác và vệ sinh",
      "Method": "PerPerson",
      "UnitPrice": 15000,
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    }
  ],
  "contracts": [
    {
      "key": "nk_hd1",
      "RoomId": "nk_p1",
      "StartDate": "2026-09-01",
      "EndDate": "2027-08-31",
      "ClosedDate": null,
      "Rent": 2600000,
      "Deposit": 2600000,
      "Status": "Active",
      "Note": "Hai sinh viên ở ghép; một người đại diện, cả hai có tài khoản để xem cùng hợp đồng.",
      "CreatedAt": "2026-09-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_hd2",
      "RoomId": "nk_p2",
      "StartDate": "2026-09-01",
      "EndDate": "2027-08-31",
      "ClosedDate": null,
      "Rent": 2400000,
      "Deposit": 2400000,
      "Status": "Active",
      "Note": "Một người đi làm; đã nộp một phần cọc, hóa đơn tháng 10 trả hai đợt và còn nợ.",
      "CreatedAt": "2026-09-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_hd3",
      "RoomId": "nk_p3",
      "StartDate": "2026-09-01",
      "EndDate": "2026-10-31",
      "ClosedDate": null,
      "Rent": 2900000,
      "Deposit": 2900000,
      "Status": "Active",
      "Note": "Hai người đi làm; hợp đồng sắp hết hạn, hóa đơn tháng 10 chưa thanh toán.",
      "CreatedAt": "2026-09-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_hd4",
      "RoomId": "nk_p4",
      "StartDate": "2026-08-01",
      "EndDate": "2026-09-30",
      "ClosedDate": "2026-09-30",
      "Rent": 2700000,
      "Deposit": 2700000,
      "Status": "Closed",
      "Note": "Đã trả phòng, thanh toán đủ tháng 8-9, bù trừ 200.000đ từ cọc vào hóa đơn cuối, khấu trừ 150.000đ vệ sinh và hoàn phần cọc còn lại.",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_hd1",
      "RoomId": "ta_p1",
      "StartDate": "2026-09-01",
      "EndDate": "2027-08-31",
      "ClosedDate": null,
      "Rent": 2300000,
      "Deposit": 2300000,
      "Status": "Active",
      "Note": "Hai sinh viên ở ghép; một người đại diện, cả hai có tài khoản để xem cùng hợp đồng.",
      "CreatedAt": "2026-09-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_hd2",
      "RoomId": "ta_p2",
      "StartDate": "2026-09-01",
      "EndDate": "2027-08-31",
      "ClosedDate": null,
      "Rent": 2100000,
      "Deposit": 2100000,
      "Status": "Active",
      "Note": "Một người đi làm; đã nộp một phần cọc, hóa đơn tháng 10 trả hai đợt và còn nợ.",
      "CreatedAt": "2026-09-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_hd3",
      "RoomId": "ta_p3",
      "StartDate": "2026-09-01",
      "EndDate": "2026-10-31",
      "ClosedDate": null,
      "Rent": 2600000,
      "Deposit": 2600000,
      "Status": "Active",
      "Note": "Hai người đi làm; hợp đồng sắp hết hạn, hóa đơn tháng 10 chưa thanh toán.",
      "CreatedAt": "2026-09-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_hd4",
      "RoomId": "ta_p4",
      "StartDate": "2026-08-01",
      "EndDate": "2026-09-30",
      "ClosedDate": "2026-09-30",
      "Rent": 2400000,
      "Deposit": 2400000,
      "Status": "Closed",
      "Note": "Đã trả phòng, thanh toán đủ tháng 8-9, bù trừ 200.000đ từ cọc vào hóa đơn cuối, khấu trừ 150.000đ vệ sinh và hoàn phần cọc còn lại.",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_hd1",
      "RoomId": "ck_p1",
      "StartDate": "2026-09-01",
      "EndDate": "2027-08-31",
      "ClosedDate": null,
      "Rent": 2800000,
      "Deposit": 2800000,
      "Status": "Active",
      "Note": "Hai sinh viên ở ghép; một người đại diện, cả hai có tài khoản để xem cùng hợp đồng.",
      "CreatedAt": "2026-09-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_hd2",
      "RoomId": "ck_p2",
      "StartDate": "2026-09-01",
      "EndDate": "2027-08-31",
      "ClosedDate": null,
      "Rent": 2600000,
      "Deposit": 2600000,
      "Status": "Active",
      "Note": "Một người đi làm; đã nộp một phần cọc, hóa đơn tháng 10 trả hai đợt và còn nợ.",
      "CreatedAt": "2026-09-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_hd3",
      "RoomId": "ck_p3",
      "StartDate": "2026-09-01",
      "EndDate": "2026-10-31",
      "ClosedDate": null,
      "Rent": 3100000,
      "Deposit": 3100000,
      "Status": "Active",
      "Note": "Hai người đi làm; hợp đồng sắp hết hạn, hóa đơn tháng 10 chưa thanh toán.",
      "CreatedAt": "2026-09-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_hd4",
      "RoomId": "ck_p4",
      "StartDate": "2026-08-01",
      "EndDate": "2026-09-30",
      "ClosedDate": "2026-09-30",
      "Rent": 2900000,
      "Deposit": 2900000,
      "Status": "Closed",
      "Note": "Đã trả phòng, thanh toán đủ tháng 8-9, bù trừ 200.000đ từ cọc vào hóa đơn cuối, khấu trừ 150.000đ vệ sinh và hoàn phần cọc còn lại.",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_hd1",
      "RoomId": "bt_p1",
      "StartDate": "2026-09-01",
      "EndDate": "2027-08-31",
      "ClosedDate": null,
      "Rent": 1800000,
      "Deposit": 1800000,
      "Status": "Active",
      "Note": "Hai sinh viên ở ghép; một người đại diện, cả hai có tài khoản để xem cùng hợp đồng.",
      "CreatedAt": "2026-09-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_hd2",
      "RoomId": "bt_p2",
      "StartDate": "2026-09-01",
      "EndDate": "2027-08-31",
      "ClosedDate": null,
      "Rent": 1600000,
      "Deposit": 1600000,
      "Status": "Active",
      "Note": "Một người đi làm; đã nộp một phần cọc, hóa đơn tháng 10 trả hai đợt và còn nợ.",
      "CreatedAt": "2026-09-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_hd3",
      "RoomId": "bt_p3",
      "StartDate": "2026-09-01",
      "EndDate": "2026-10-31",
      "ClosedDate": null,
      "Rent": 2100000,
      "Deposit": 2100000,
      "Status": "Active",
      "Note": "Hai người đi làm; hợp đồng sắp hết hạn, hóa đơn tháng 10 chưa thanh toán.",
      "CreatedAt": "2026-09-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_hd4",
      "RoomId": "bt_p4",
      "StartDate": "2026-08-01",
      "EndDate": "2026-09-30",
      "ClosedDate": "2026-09-30",
      "Rent": 1900000,
      "Deposit": 1900000,
      "Status": "Closed",
      "Note": "Đã trả phòng, thanh toán đủ tháng 8-9, bù trừ 200.000đ từ cọc vào hóa đơn cuối, khấu trừ 150.000đ vệ sinh và hoàn phần cọc còn lại.",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_hd1",
      "RoomId": "cr_p1",
      "StartDate": "2026-09-01",
      "EndDate": "2027-08-31",
      "ClosedDate": null,
      "Rent": 2200000,
      "Deposit": 2200000,
      "Status": "Active",
      "Note": "Hai sinh viên ở ghép; một người đại diện, cả hai có tài khoản để xem cùng hợp đồng.",
      "CreatedAt": "2026-09-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_hd2",
      "RoomId": "cr_p2",
      "StartDate": "2026-09-01",
      "EndDate": "2027-08-31",
      "ClosedDate": null,
      "Rent": 2000000,
      "Deposit": 2000000,
      "Status": "Active",
      "Note": "Một người đi làm; đã nộp một phần cọc, hóa đơn tháng 10 trả hai đợt và còn nợ.",
      "CreatedAt": "2026-09-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_hd3",
      "RoomId": "cr_p3",
      "StartDate": "2026-09-01",
      "EndDate": "2026-10-31",
      "ClosedDate": null,
      "Rent": 2500000,
      "Deposit": 2500000,
      "Status": "Active",
      "Note": "Hai người đi làm; hợp đồng sắp hết hạn, hóa đơn tháng 10 chưa thanh toán.",
      "CreatedAt": "2026-09-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_hd4",
      "RoomId": "cr_p4",
      "StartDate": "2026-08-01",
      "EndDate": "2026-09-30",
      "ClosedDate": "2026-09-30",
      "Rent": 2300000,
      "Deposit": 2300000,
      "Status": "Closed",
      "Note": "Đã trả phòng, thanh toán đủ tháng 8-9, bù trừ 200.000đ từ cọc vào hóa đơn cuối, khấu trừ 150.000đ vệ sinh và hoàn phần cọc còn lại.",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_hd1",
      "RoomId": "om_p1",
      "StartDate": "2026-09-01",
      "EndDate": "2027-08-31",
      "ClosedDate": null,
      "Rent": 1600000,
      "Deposit": 1600000,
      "Status": "Active",
      "Note": "Hai sinh viên ở ghép; một người đại diện, cả hai có tài khoản để xem cùng hợp đồng.",
      "CreatedAt": "2026-09-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_hd2",
      "RoomId": "om_p2",
      "StartDate": "2026-09-01",
      "EndDate": "2027-08-31",
      "ClosedDate": null,
      "Rent": 1400000,
      "Deposit": 1400000,
      "Status": "Active",
      "Note": "Một người đi làm; đã nộp một phần cọc, hóa đơn tháng 10 trả hai đợt và còn nợ.",
      "CreatedAt": "2026-09-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_hd3",
      "RoomId": "om_p3",
      "StartDate": "2026-09-01",
      "EndDate": "2026-10-31",
      "ClosedDate": null,
      "Rent": 1900000,
      "Deposit": 1900000,
      "Status": "Active",
      "Note": "Hai người đi làm; hợp đồng sắp hết hạn, hóa đơn tháng 10 chưa thanh toán.",
      "CreatedAt": "2026-09-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_hd4",
      "RoomId": "om_p4",
      "StartDate": "2026-08-01",
      "EndDate": "2026-09-30",
      "ClosedDate": "2026-09-30",
      "Rent": 1700000,
      "Deposit": 1700000,
      "Status": "Closed",
      "Note": "Đã trả phòng, thanh toán đủ tháng 8-9, bù trừ 200.000đ từ cọc vào hóa đơn cuối, khấu trừ 150.000đ vệ sinh và hoàn phần cọc còn lại.",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    }
  ],
  "contract_tenants": [
    {
      "ContractId": "nk_hd1",
      "TenantId": "nk_t1",
      "IsRepresentative": true
    },
    {
      "ContractId": "nk_hd1",
      "TenantId": "nk_t2",
      "IsRepresentative": false
    },
    {
      "ContractId": "nk_hd2",
      "TenantId": "nk_t3",
      "IsRepresentative": true
    },
    {
      "ContractId": "nk_hd3",
      "TenantId": "nk_t4",
      "IsRepresentative": true
    },
    {
      "ContractId": "nk_hd3",
      "TenantId": "nk_t5",
      "IsRepresentative": false
    },
    {
      "ContractId": "nk_hd4",
      "TenantId": "nk_t6",
      "IsRepresentative": true
    },
    {
      "ContractId": "ta_hd1",
      "TenantId": "ta_t1",
      "IsRepresentative": true
    },
    {
      "ContractId": "ta_hd1",
      "TenantId": "ta_t2",
      "IsRepresentative": false
    },
    {
      "ContractId": "ta_hd2",
      "TenantId": "ta_t3",
      "IsRepresentative": true
    },
    {
      "ContractId": "ta_hd3",
      "TenantId": "ta_t4",
      "IsRepresentative": true
    },
    {
      "ContractId": "ta_hd3",
      "TenantId": "ta_t5",
      "IsRepresentative": false
    },
    {
      "ContractId": "ta_hd4",
      "TenantId": "ta_t6",
      "IsRepresentative": true
    },
    {
      "ContractId": "ck_hd1",
      "TenantId": "ck_t1",
      "IsRepresentative": true
    },
    {
      "ContractId": "ck_hd1",
      "TenantId": "ck_t2",
      "IsRepresentative": false
    },
    {
      "ContractId": "ck_hd2",
      "TenantId": "ck_t3",
      "IsRepresentative": true
    },
    {
      "ContractId": "ck_hd3",
      "TenantId": "ck_t4",
      "IsRepresentative": true
    },
    {
      "ContractId": "ck_hd3",
      "TenantId": "ck_t5",
      "IsRepresentative": false
    },
    {
      "ContractId": "ck_hd4",
      "TenantId": "ck_t6",
      "IsRepresentative": true
    },
    {
      "ContractId": "bt_hd1",
      "TenantId": "bt_t1",
      "IsRepresentative": true
    },
    {
      "ContractId": "bt_hd1",
      "TenantId": "bt_t2",
      "IsRepresentative": false
    },
    {
      "ContractId": "bt_hd2",
      "TenantId": "bt_t3",
      "IsRepresentative": true
    },
    {
      "ContractId": "bt_hd3",
      "TenantId": "bt_t4",
      "IsRepresentative": true
    },
    {
      "ContractId": "bt_hd3",
      "TenantId": "bt_t5",
      "IsRepresentative": false
    },
    {
      "ContractId": "bt_hd4",
      "TenantId": "bt_t6",
      "IsRepresentative": true
    },
    {
      "ContractId": "cr_hd1",
      "TenantId": "cr_t1",
      "IsRepresentative": true
    },
    {
      "ContractId": "cr_hd1",
      "TenantId": "cr_t2",
      "IsRepresentative": false
    },
    {
      "ContractId": "cr_hd2",
      "TenantId": "cr_t3",
      "IsRepresentative": true
    },
    {
      "ContractId": "cr_hd3",
      "TenantId": "cr_t4",
      "IsRepresentative": true
    },
    {
      "ContractId": "cr_hd3",
      "TenantId": "cr_t5",
      "IsRepresentative": false
    },
    {
      "ContractId": "cr_hd4",
      "TenantId": "cr_t6",
      "IsRepresentative": true
    },
    {
      "ContractId": "om_hd1",
      "TenantId": "om_t1",
      "IsRepresentative": true
    },
    {
      "ContractId": "om_hd1",
      "TenantId": "om_t2",
      "IsRepresentative": false
    },
    {
      "ContractId": "om_hd2",
      "TenantId": "om_t3",
      "IsRepresentative": true
    },
    {
      "ContractId": "om_hd3",
      "TenantId": "om_t4",
      "IsRepresentative": true
    },
    {
      "ContractId": "om_hd3",
      "TenantId": "om_t5",
      "IsRepresentative": false
    },
    {
      "ContractId": "om_hd4",
      "TenantId": "om_t6",
      "IsRepresentative": true
    }
  ],
  "readings": [
    {
      "key": "nk_hd1_2026-09",
      "ContractId": "nk_hd1",
      "Year": 2026,
      "Month": 9,
      "ElectricityOld": 281,
      "ElectricityNew": 355,
      "WaterOld": 23,
      "WaterNew": 30,
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_hd1_2026-10",
      "ContractId": "nk_hd1",
      "Year": 2026,
      "Month": 10,
      "ElectricityOld": 355,
      "ElectricityNew": 440,
      "WaterOld": 30,
      "WaterNew": 38,
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_hd2_2026-09",
      "ContractId": "nk_hd2",
      "Year": 2026,
      "Month": 9,
      "ElectricityOld": 312,
      "ElectricityNew": 403,
      "WaterOld": 26,
      "WaterNew": 31,
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_hd2_2026-10",
      "ContractId": "nk_hd2",
      "Year": 2026,
      "Month": 10,
      "ElectricityOld": 403,
      "ElectricityNew": 505,
      "WaterOld": 31,
      "WaterNew": 37,
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_hd3_2026-09",
      "ContractId": "nk_hd3",
      "Year": 2026,
      "Month": 9,
      "ElectricityOld": 343,
      "ElectricityNew": 451,
      "WaterOld": 29,
      "WaterNew": 36,
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_hd3_2026-10",
      "ContractId": "nk_hd3",
      "Year": 2026,
      "Month": 10,
      "ElectricityOld": 451,
      "ElectricityNew": 570,
      "WaterOld": 36,
      "WaterNew": 44,
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_hd4_2026-08",
      "ContractId": "nk_hd4",
      "Year": 2026,
      "Month": 8,
      "ElectricityOld": 374,
      "ElectricityNew": 499,
      "WaterOld": 32,
      "WaterNew": 37,
      "CreatedAt": "2026-08-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_hd4_2026-09",
      "ContractId": "nk_hd4",
      "Year": 2026,
      "Month": 9,
      "ElectricityOld": 499,
      "ElectricityNew": 624,
      "WaterOld": 37,
      "WaterNew": 42,
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_hd1_2026-09",
      "ContractId": "ta_hd1",
      "Year": 2026,
      "Month": 9,
      "ElectricityOld": 474,
      "ElectricityNew": 555,
      "WaterOld": 40,
      "WaterNew": 48,
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_hd1_2026-10",
      "ContractId": "ta_hd1",
      "Year": 2026,
      "Month": 10,
      "ElectricityOld": 555,
      "ElectricityNew": 647,
      "WaterOld": 48,
      "WaterNew": 57,
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_hd2_2026-09",
      "ContractId": "ta_hd2",
      "Year": 2026,
      "Month": 9,
      "ElectricityOld": 505,
      "ElectricityNew": 603,
      "WaterOld": 43,
      "WaterNew": 49,
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_hd2_2026-10",
      "ContractId": "ta_hd2",
      "Year": 2026,
      "Month": 10,
      "ElectricityOld": 603,
      "ElectricityNew": 712,
      "WaterOld": 49,
      "WaterNew": 56,
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_hd3_2026-09",
      "ContractId": "ta_hd3",
      "Year": 2026,
      "Month": 9,
      "ElectricityOld": 536,
      "ElectricityNew": 651,
      "WaterOld": 46,
      "WaterNew": 54,
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_hd3_2026-10",
      "ContractId": "ta_hd3",
      "Year": 2026,
      "Month": 10,
      "ElectricityOld": 651,
      "ElectricityNew": 777,
      "WaterOld": 54,
      "WaterNew": 63,
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_hd4_2026-08",
      "ContractId": "ta_hd4",
      "Year": 2026,
      "Month": 8,
      "ElectricityOld": 567,
      "ElectricityNew": 699,
      "WaterOld": 49,
      "WaterNew": 55,
      "CreatedAt": "2026-08-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_hd4_2026-09",
      "ContractId": "ta_hd4",
      "Year": 2026,
      "Month": 9,
      "ElectricityOld": 699,
      "ElectricityNew": 831,
      "WaterOld": 55,
      "WaterNew": 61,
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_hd1_2026-09",
      "ContractId": "ck_hd1",
      "Year": 2026,
      "Month": 9,
      "ElectricityOld": 667,
      "ElectricityNew": 755,
      "WaterOld": 57,
      "WaterNew": 64,
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_hd1_2026-10",
      "ContractId": "ck_hd1",
      "Year": 2026,
      "Month": 10,
      "ElectricityOld": 755,
      "ElectricityNew": 854,
      "WaterOld": 64,
      "WaterNew": 72,
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_hd2_2026-09",
      "ContractId": "ck_hd2",
      "Year": 2026,
      "Month": 9,
      "ElectricityOld": 698,
      "ElectricityNew": 803,
      "WaterOld": 60,
      "WaterNew": 65,
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_hd2_2026-10",
      "ContractId": "ck_hd2",
      "Year": 2026,
      "Month": 10,
      "ElectricityOld": 803,
      "ElectricityNew": 919,
      "WaterOld": 65,
      "WaterNew": 71,
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_hd3_2026-09",
      "ContractId": "ck_hd3",
      "Year": 2026,
      "Month": 9,
      "ElectricityOld": 729,
      "ElectricityNew": 851,
      "WaterOld": 63,
      "WaterNew": 70,
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_hd3_2026-10",
      "ContractId": "ck_hd3",
      "Year": 2026,
      "Month": 10,
      "ElectricityOld": 851,
      "ElectricityNew": 984,
      "WaterOld": 70,
      "WaterNew": 78,
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_hd4_2026-08",
      "ContractId": "ck_hd4",
      "Year": 2026,
      "Month": 8,
      "ElectricityOld": 760,
      "ElectricityNew": 899,
      "WaterOld": 66,
      "WaterNew": 71,
      "CreatedAt": "2026-08-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_hd4_2026-09",
      "ContractId": "ck_hd4",
      "Year": 2026,
      "Month": 9,
      "ElectricityOld": 899,
      "ElectricityNew": 1038,
      "WaterOld": 71,
      "WaterNew": 76,
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_hd1_2026-09",
      "ContractId": "bt_hd1",
      "Year": 2026,
      "Month": 9,
      "ElectricityOld": 860,
      "ElectricityNew": 955,
      "WaterOld": 74,
      "WaterNew": 82,
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_hd1_2026-10",
      "ContractId": "bt_hd1",
      "Year": 2026,
      "Month": 10,
      "ElectricityOld": 955,
      "ElectricityNew": 1061,
      "WaterOld": 82,
      "WaterNew": 91,
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_hd2_2026-09",
      "ContractId": "bt_hd2",
      "Year": 2026,
      "Month": 9,
      "ElectricityOld": 891,
      "ElectricityNew": 1003,
      "WaterOld": 77,
      "WaterNew": 83,
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_hd2_2026-10",
      "ContractId": "bt_hd2",
      "Year": 2026,
      "Month": 10,
      "ElectricityOld": 1003,
      "ElectricityNew": 1126,
      "WaterOld": 83,
      "WaterNew": 90,
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_hd3_2026-09",
      "ContractId": "bt_hd3",
      "Year": 2026,
      "Month": 9,
      "ElectricityOld": 922,
      "ElectricityNew": 1051,
      "WaterOld": 80,
      "WaterNew": 88,
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_hd3_2026-10",
      "ContractId": "bt_hd3",
      "Year": 2026,
      "Month": 10,
      "ElectricityOld": 1051,
      "ElectricityNew": 1191,
      "WaterOld": 88,
      "WaterNew": 97,
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_hd4_2026-08",
      "ContractId": "bt_hd4",
      "Year": 2026,
      "Month": 8,
      "ElectricityOld": 953,
      "ElectricityNew": 1099,
      "WaterOld": 83,
      "WaterNew": 89,
      "CreatedAt": "2026-08-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_hd4_2026-09",
      "ContractId": "bt_hd4",
      "Year": 2026,
      "Month": 9,
      "ElectricityOld": 1099,
      "ElectricityNew": 1245,
      "WaterOld": 89,
      "WaterNew": 95,
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_hd1_2026-09",
      "ContractId": "cr_hd1",
      "Year": 2026,
      "Month": 9,
      "ElectricityOld": 1053,
      "ElectricityNew": 1155,
      "WaterOld": 91,
      "WaterNew": 98,
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_hd1_2026-10",
      "ContractId": "cr_hd1",
      "Year": 2026,
      "Month": 10,
      "ElectricityOld": 1155,
      "ElectricityNew": 1268,
      "WaterOld": 98,
      "WaterNew": 106,
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_hd2_2026-09",
      "ContractId": "cr_hd2",
      "Year": 2026,
      "Month": 9,
      "ElectricityOld": 1084,
      "ElectricityNew": 1203,
      "WaterOld": 94,
      "WaterNew": 99,
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_hd2_2026-10",
      "ContractId": "cr_hd2",
      "Year": 2026,
      "Month": 10,
      "ElectricityOld": 1203,
      "ElectricityNew": 1333,
      "WaterOld": 99,
      "WaterNew": 105,
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_hd3_2026-09",
      "ContractId": "cr_hd3",
      "Year": 2026,
      "Month": 9,
      "ElectricityOld": 1115,
      "ElectricityNew": 1251,
      "WaterOld": 97,
      "WaterNew": 104,
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_hd3_2026-10",
      "ContractId": "cr_hd3",
      "Year": 2026,
      "Month": 10,
      "ElectricityOld": 1251,
      "ElectricityNew": 1398,
      "WaterOld": 104,
      "WaterNew": 112,
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_hd4_2026-08",
      "ContractId": "cr_hd4",
      "Year": 2026,
      "Month": 8,
      "ElectricityOld": 1146,
      "ElectricityNew": 1299,
      "WaterOld": 100,
      "WaterNew": 105,
      "CreatedAt": "2026-08-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_hd4_2026-09",
      "ContractId": "cr_hd4",
      "Year": 2026,
      "Month": 9,
      "ElectricityOld": 1299,
      "ElectricityNew": 1452,
      "WaterOld": 105,
      "WaterNew": 110,
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_hd1_2026-09",
      "ContractId": "om_hd1",
      "Year": 2026,
      "Month": 9,
      "ElectricityOld": 1246,
      "ElectricityNew": 1355,
      "WaterOld": 108,
      "WaterNew": 116,
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_hd1_2026-10",
      "ContractId": "om_hd1",
      "Year": 2026,
      "Month": 10,
      "ElectricityOld": 1355,
      "ElectricityNew": 1475,
      "WaterOld": 116,
      "WaterNew": 125,
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_hd2_2026-09",
      "ContractId": "om_hd2",
      "Year": 2026,
      "Month": 9,
      "ElectricityOld": 1277,
      "ElectricityNew": 1403,
      "WaterOld": 111,
      "WaterNew": 117,
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_hd2_2026-10",
      "ContractId": "om_hd2",
      "Year": 2026,
      "Month": 10,
      "ElectricityOld": 1403,
      "ElectricityNew": 1540,
      "WaterOld": 117,
      "WaterNew": 124,
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_hd3_2026-09",
      "ContractId": "om_hd3",
      "Year": 2026,
      "Month": 9,
      "ElectricityOld": 1308,
      "ElectricityNew": 1451,
      "WaterOld": 114,
      "WaterNew": 122,
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_hd3_2026-10",
      "ContractId": "om_hd3",
      "Year": 2026,
      "Month": 10,
      "ElectricityOld": 1451,
      "ElectricityNew": 1605,
      "WaterOld": 122,
      "WaterNew": 131,
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_hd4_2026-08",
      "ContractId": "om_hd4",
      "Year": 2026,
      "Month": 8,
      "ElectricityOld": 1339,
      "ElectricityNew": 1499,
      "WaterOld": 117,
      "WaterNew": 123,
      "CreatedAt": "2026-08-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_hd4_2026-09",
      "ContractId": "om_hd4",
      "Year": 2026,
      "Month": 9,
      "ElectricityOld": 1499,
      "ElectricityNew": 1659,
      "WaterOld": 123,
      "WaterNew": 129,
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    }
  ],
  "invoices": [
    {
      "key": "nk_hd1_2026-09",
      "ContractId": "nk_hd1",
      "Year": 2026,
      "Month": 9,
      "DueDate": "2026-09-28",
      "Total": 3053000,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_hd1_2026-10",
      "ContractId": "nk_hd1",
      "Year": 2026,
      "Month": 10,
      "DueDate": "2026-10-28",
      "Total": 3103500,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_hd2_2026-09",
      "ContractId": "nk_hd2",
      "Year": 2026,
      "Month": 9,
      "DueDate": "2026-09-26",
      "Total": 2873500,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_hd2_2026-10_cancelled",
      "ContractId": "nk_hd2",
      "Year": 2026,
      "Month": 10,
      "DueDate": "2026-10-26",
      "Total": 2939000,
      "Status": "Cancelled",
      "CancellationReason": "Nhập nhầm số người tính phí vệ sinh từ 1 thành 2; hủy khi chưa thu tiền và lập hóa đơn thay thế.",
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_hd2_2026-10",
      "ContractId": "nk_hd2",
      "Year": 2026,
      "Month": 10,
      "DueDate": "2026-10-26",
      "Total": 2924000,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_hd3_2026-09",
      "ContractId": "nk_hd3",
      "Year": 2026,
      "Month": 9,
      "DueDate": "2026-09-28",
      "Total": 3472000,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_hd3_2026-10",
      "ContractId": "nk_hd3",
      "Year": 2026,
      "Month": 10,
      "DueDate": "2026-10-28",
      "Total": 3522500,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_hd4_2026-08",
      "ContractId": "nk_hd4",
      "Year": 2026,
      "Month": 8,
      "DueDate": "2026-08-28",
      "Total": 3292500,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-08-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_hd4_2026-09",
      "ContractId": "nk_hd4",
      "Year": 2026,
      "Month": 9,
      "DueDate": "2026-09-28",
      "Total": 3292500,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_hd1_2026-09",
      "ContractId": "ta_hd1",
      "Year": 2026,
      "Month": 9,
      "DueDate": "2026-09-28",
      "Total": 2789500,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_hd1_2026-10",
      "ContractId": "ta_hd1",
      "Year": 2026,
      "Month": 10,
      "DueDate": "2026-10-28",
      "Total": 2840000,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_hd2_2026-09",
      "ContractId": "ta_hd2",
      "Year": 2026,
      "Month": 9,
      "DueDate": "2026-09-26",
      "Total": 2610000,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_hd2_2026-10_cancelled",
      "ContractId": "ta_hd2",
      "Year": 2026,
      "Month": 10,
      "DueDate": "2026-10-26",
      "Total": 2675500,
      "Status": "Cancelled",
      "CancellationReason": "Nhập nhầm số người tính phí vệ sinh từ 1 thành 2; hủy khi chưa thu tiền và lập hóa đơn thay thế.",
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_hd2_2026-10",
      "ContractId": "ta_hd2",
      "Year": 2026,
      "Month": 10,
      "DueDate": "2026-10-26",
      "Total": 2660500,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_hd3_2026-09",
      "ContractId": "ta_hd3",
      "Year": 2026,
      "Month": 9,
      "DueDate": "2026-09-28",
      "Total": 3208500,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_hd3_2026-10",
      "ContractId": "ta_hd3",
      "Year": 2026,
      "Month": 10,
      "DueDate": "2026-10-28",
      "Total": 3259000,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_hd4_2026-08",
      "ContractId": "ta_hd4",
      "Year": 2026,
      "Month": 8,
      "DueDate": "2026-08-28",
      "Total": 3029000,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-08-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_hd4_2026-09",
      "ContractId": "ta_hd4",
      "Year": 2026,
      "Month": 9,
      "DueDate": "2026-09-28",
      "Total": 3029000,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_hd1_2026-09",
      "ContractId": "ck_hd1",
      "Year": 2026,
      "Month": 9,
      "DueDate": "2026-09-28",
      "Total": 3302000,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_hd1_2026-10",
      "ContractId": "ck_hd1",
      "Year": 2026,
      "Month": 10,
      "DueDate": "2026-10-28",
      "Total": 3352500,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_hd2_2026-09",
      "ContractId": "ck_hd2",
      "Year": 2026,
      "Month": 9,
      "DueDate": "2026-09-26",
      "Total": 3122500,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_hd2_2026-10_cancelled",
      "ContractId": "ck_hd2",
      "Year": 2026,
      "Month": 10,
      "DueDate": "2026-10-26",
      "Total": 3188000,
      "Status": "Cancelled",
      "CancellationReason": "Nhập nhầm số người tính phí vệ sinh từ 1 thành 2; hủy khi chưa thu tiền và lập hóa đơn thay thế.",
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_hd2_2026-10",
      "ContractId": "ck_hd2",
      "Year": 2026,
      "Month": 10,
      "DueDate": "2026-10-26",
      "Total": 3173000,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_hd3_2026-09",
      "ContractId": "ck_hd3",
      "Year": 2026,
      "Month": 9,
      "DueDate": "2026-09-28",
      "Total": 3721000,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_hd3_2026-10",
      "ContractId": "ck_hd3",
      "Year": 2026,
      "Month": 10,
      "DueDate": "2026-10-28",
      "Total": 3771500,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_hd4_2026-08",
      "ContractId": "ck_hd4",
      "Year": 2026,
      "Month": 8,
      "DueDate": "2026-08-28",
      "Total": 3541500,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-08-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_hd4_2026-09",
      "ContractId": "ck_hd4",
      "Year": 2026,
      "Month": 9,
      "DueDate": "2026-09-28",
      "Total": 3541500,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_hd1_2026-09",
      "ContractId": "bt_hd1",
      "Year": 2026,
      "Month": 9,
      "DueDate": "2026-09-28",
      "Total": 2318500,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_hd1_2026-10",
      "ContractId": "bt_hd1",
      "Year": 2026,
      "Month": 10,
      "DueDate": "2026-10-28",
      "Total": 2369000,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_hd2_2026-09",
      "ContractId": "bt_hd2",
      "Year": 2026,
      "Month": 9,
      "DueDate": "2026-09-26",
      "Total": 2139000,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_hd2_2026-10_cancelled",
      "ContractId": "bt_hd2",
      "Year": 2026,
      "Month": 10,
      "DueDate": "2026-10-26",
      "Total": 2204500,
      "Status": "Cancelled",
      "CancellationReason": "Nhập nhầm số người tính phí vệ sinh từ 1 thành 2; hủy khi chưa thu tiền và lập hóa đơn thay thế.",
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_hd2_2026-10",
      "ContractId": "bt_hd2",
      "Year": 2026,
      "Month": 10,
      "DueDate": "2026-10-26",
      "Total": 2189500,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_hd3_2026-09",
      "ContractId": "bt_hd3",
      "Year": 2026,
      "Month": 9,
      "DueDate": "2026-09-28",
      "Total": 2737500,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_hd3_2026-10",
      "ContractId": "bt_hd3",
      "Year": 2026,
      "Month": 10,
      "DueDate": "2026-10-28",
      "Total": 2788000,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_hd4_2026-08",
      "ContractId": "bt_hd4",
      "Year": 2026,
      "Month": 8,
      "DueDate": "2026-08-28",
      "Total": 2558000,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-08-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_hd4_2026-09",
      "ContractId": "bt_hd4",
      "Year": 2026,
      "Month": 9,
      "DueDate": "2026-09-28",
      "Total": 2558000,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_hd1_2026-09",
      "ContractId": "cr_hd1",
      "Year": 2026,
      "Month": 9,
      "DueDate": "2026-09-28",
      "Total": 2731000,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_hd1_2026-10",
      "ContractId": "cr_hd1",
      "Year": 2026,
      "Month": 10,
      "DueDate": "2026-10-28",
      "Total": 2781500,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_hd2_2026-09",
      "ContractId": "cr_hd2",
      "Year": 2026,
      "Month": 9,
      "DueDate": "2026-09-26",
      "Total": 2551500,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_hd2_2026-10_cancelled",
      "ContractId": "cr_hd2",
      "Year": 2026,
      "Month": 10,
      "DueDate": "2026-10-26",
      "Total": 2617000,
      "Status": "Cancelled",
      "CancellationReason": "Nhập nhầm số người tính phí vệ sinh từ 1 thành 2; hủy khi chưa thu tiền và lập hóa đơn thay thế.",
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_hd2_2026-10",
      "ContractId": "cr_hd2",
      "Year": 2026,
      "Month": 10,
      "DueDate": "2026-10-26",
      "Total": 2602000,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_hd3_2026-09",
      "ContractId": "cr_hd3",
      "Year": 2026,
      "Month": 9,
      "DueDate": "2026-09-28",
      "Total": 3150000,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_hd3_2026-10",
      "ContractId": "cr_hd3",
      "Year": 2026,
      "Month": 10,
      "DueDate": "2026-10-28",
      "Total": 3200500,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_hd4_2026-08",
      "ContractId": "cr_hd4",
      "Year": 2026,
      "Month": 8,
      "DueDate": "2026-08-28",
      "Total": 2970500,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-08-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_hd4_2026-09",
      "ContractId": "cr_hd4",
      "Year": 2026,
      "Month": 9,
      "DueDate": "2026-09-28",
      "Total": 2970500,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_hd1_2026-09",
      "ContractId": "om_hd1",
      "Year": 2026,
      "Month": 9,
      "DueDate": "2026-09-28",
      "Total": 2167500,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_hd1_2026-10",
      "ContractId": "om_hd1",
      "Year": 2026,
      "Month": 10,
      "DueDate": "2026-10-28",
      "Total": 2218000,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_hd2_2026-09",
      "ContractId": "om_hd2",
      "Year": 2026,
      "Month": 9,
      "DueDate": "2026-09-26",
      "Total": 1988000,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_hd2_2026-10_cancelled",
      "ContractId": "om_hd2",
      "Year": 2026,
      "Month": 10,
      "DueDate": "2026-10-26",
      "Total": 2053500,
      "Status": "Cancelled",
      "CancellationReason": "Nhập nhầm số người tính phí vệ sinh từ 1 thành 2; hủy khi chưa thu tiền và lập hóa đơn thay thế.",
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_hd2_2026-10",
      "ContractId": "om_hd2",
      "Year": 2026,
      "Month": 10,
      "DueDate": "2026-10-26",
      "Total": 2038500,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_hd3_2026-09",
      "ContractId": "om_hd3",
      "Year": 2026,
      "Month": 9,
      "DueDate": "2026-09-28",
      "Total": 2586500,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_hd3_2026-10",
      "ContractId": "om_hd3",
      "Year": 2026,
      "Month": 10,
      "DueDate": "2026-10-28",
      "Total": 2637000,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_hd4_2026-08",
      "ContractId": "om_hd4",
      "Year": 2026,
      "Month": 8,
      "DueDate": "2026-08-28",
      "Total": 2407000,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-08-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_hd4_2026-09",
      "ContractId": "om_hd4",
      "Year": 2026,
      "Month": 9,
      "DueDate": "2026-09-28",
      "Total": 2407000,
      "Status": "Issued",
      "CancellationReason": "",
      "CreatedAt": "2026-09-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    }
  ],
  "invoice_items": [
    {
      "key": "nk_hd1_2026-09_0",
      "InvoiceId": "nk_hd1_2026-09",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 2600000,
      "Amount": 2600000
    },
    {
      "key": "nk_hd1_2026-09_1",
      "InvoiceId": "nk_hd1_2026-09",
      "Description": "Điện",
      "Quantity": 74,
      "UnitPrice": 3500,
      "Amount": 259000
    },
    {
      "key": "nk_hd1_2026-09_2",
      "InvoiceId": "nk_hd1_2026-09",
      "Description": "Nước",
      "Quantity": 7,
      "UnitPrice": 12000,
      "Amount": 84000
    },
    {
      "key": "nk_hd1_2026-09_3",
      "InvoiceId": "nk_hd1_2026-09",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 80000,
      "Amount": 80000
    },
    {
      "key": "nk_hd1_2026-09_4",
      "InvoiceId": "nk_hd1_2026-09",
      "Description": "Rác và vệ sinh",
      "Quantity": 2,
      "UnitPrice": 15000,
      "Amount": 30000
    },
    {
      "key": "nk_hd1_2026-10_0",
      "InvoiceId": "nk_hd1_2026-10",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 2600000,
      "Amount": 2600000
    },
    {
      "key": "nk_hd1_2026-10_1",
      "InvoiceId": "nk_hd1_2026-10",
      "Description": "Điện",
      "Quantity": 85,
      "UnitPrice": 3500,
      "Amount": 297500
    },
    {
      "key": "nk_hd1_2026-10_2",
      "InvoiceId": "nk_hd1_2026-10",
      "Description": "Nước",
      "Quantity": 8,
      "UnitPrice": 12000,
      "Amount": 96000
    },
    {
      "key": "nk_hd1_2026-10_3",
      "InvoiceId": "nk_hd1_2026-10",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 80000,
      "Amount": 80000
    },
    {
      "key": "nk_hd1_2026-10_4",
      "InvoiceId": "nk_hd1_2026-10",
      "Description": "Rác và vệ sinh",
      "Quantity": 2,
      "UnitPrice": 15000,
      "Amount": 30000
    },
    {
      "key": "nk_hd2_2026-09_0",
      "InvoiceId": "nk_hd2_2026-09",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 2400000,
      "Amount": 2400000
    },
    {
      "key": "nk_hd2_2026-09_1",
      "InvoiceId": "nk_hd2_2026-09",
      "Description": "Điện",
      "Quantity": 91,
      "UnitPrice": 3500,
      "Amount": 318500
    },
    {
      "key": "nk_hd2_2026-09_2",
      "InvoiceId": "nk_hd2_2026-09",
      "Description": "Nước",
      "Quantity": 5,
      "UnitPrice": 12000,
      "Amount": 60000
    },
    {
      "key": "nk_hd2_2026-09_3",
      "InvoiceId": "nk_hd2_2026-09",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 80000,
      "Amount": 80000
    },
    {
      "key": "nk_hd2_2026-09_4",
      "InvoiceId": "nk_hd2_2026-09",
      "Description": "Rác và vệ sinh",
      "Quantity": 1,
      "UnitPrice": 15000,
      "Amount": 15000
    },
    {
      "key": "nk_hd2_2026-10_cancelled_0",
      "InvoiceId": "nk_hd2_2026-10_cancelled",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 2400000,
      "Amount": 2400000
    },
    {
      "key": "nk_hd2_2026-10_cancelled_1",
      "InvoiceId": "nk_hd2_2026-10_cancelled",
      "Description": "Điện",
      "Quantity": 102,
      "UnitPrice": 3500,
      "Amount": 357000
    },
    {
      "key": "nk_hd2_2026-10_cancelled_2",
      "InvoiceId": "nk_hd2_2026-10_cancelled",
      "Description": "Nước",
      "Quantity": 6,
      "UnitPrice": 12000,
      "Amount": 72000
    },
    {
      "key": "nk_hd2_2026-10_cancelled_3",
      "InvoiceId": "nk_hd2_2026-10_cancelled",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 80000,
      "Amount": 80000
    },
    {
      "key": "nk_hd2_2026-10_cancelled_4",
      "InvoiceId": "nk_hd2_2026-10_cancelled",
      "Description": "Rác và vệ sinh",
      "Quantity": 2,
      "UnitPrice": 15000,
      "Amount": 30000
    },
    {
      "key": "nk_hd2_2026-10_0",
      "InvoiceId": "nk_hd2_2026-10",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 2400000,
      "Amount": 2400000
    },
    {
      "key": "nk_hd2_2026-10_1",
      "InvoiceId": "nk_hd2_2026-10",
      "Description": "Điện",
      "Quantity": 102,
      "UnitPrice": 3500,
      "Amount": 357000
    },
    {
      "key": "nk_hd2_2026-10_2",
      "InvoiceId": "nk_hd2_2026-10",
      "Description": "Nước",
      "Quantity": 6,
      "UnitPrice": 12000,
      "Amount": 72000
    },
    {
      "key": "nk_hd2_2026-10_3",
      "InvoiceId": "nk_hd2_2026-10",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 80000,
      "Amount": 80000
    },
    {
      "key": "nk_hd2_2026-10_4",
      "InvoiceId": "nk_hd2_2026-10",
      "Description": "Rác và vệ sinh",
      "Quantity": 1,
      "UnitPrice": 15000,
      "Amount": 15000
    },
    {
      "key": "nk_hd3_2026-09_0",
      "InvoiceId": "nk_hd3_2026-09",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 2900000,
      "Amount": 2900000
    },
    {
      "key": "nk_hd3_2026-09_1",
      "InvoiceId": "nk_hd3_2026-09",
      "Description": "Điện",
      "Quantity": 108,
      "UnitPrice": 3500,
      "Amount": 378000
    },
    {
      "key": "nk_hd3_2026-09_2",
      "InvoiceId": "nk_hd3_2026-09",
      "Description": "Nước",
      "Quantity": 7,
      "UnitPrice": 12000,
      "Amount": 84000
    },
    {
      "key": "nk_hd3_2026-09_3",
      "InvoiceId": "nk_hd3_2026-09",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 80000,
      "Amount": 80000
    },
    {
      "key": "nk_hd3_2026-09_4",
      "InvoiceId": "nk_hd3_2026-09",
      "Description": "Rác và vệ sinh",
      "Quantity": 2,
      "UnitPrice": 15000,
      "Amount": 30000
    },
    {
      "key": "nk_hd3_2026-10_0",
      "InvoiceId": "nk_hd3_2026-10",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 2900000,
      "Amount": 2900000
    },
    {
      "key": "nk_hd3_2026-10_1",
      "InvoiceId": "nk_hd3_2026-10",
      "Description": "Điện",
      "Quantity": 119,
      "UnitPrice": 3500,
      "Amount": 416500
    },
    {
      "key": "nk_hd3_2026-10_2",
      "InvoiceId": "nk_hd3_2026-10",
      "Description": "Nước",
      "Quantity": 8,
      "UnitPrice": 12000,
      "Amount": 96000
    },
    {
      "key": "nk_hd3_2026-10_3",
      "InvoiceId": "nk_hd3_2026-10",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 80000,
      "Amount": 80000
    },
    {
      "key": "nk_hd3_2026-10_4",
      "InvoiceId": "nk_hd3_2026-10",
      "Description": "Rác và vệ sinh",
      "Quantity": 2,
      "UnitPrice": 15000,
      "Amount": 30000
    },
    {
      "key": "nk_hd4_2026-08_0",
      "InvoiceId": "nk_hd4_2026-08",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 2700000,
      "Amount": 2700000
    },
    {
      "key": "nk_hd4_2026-08_1",
      "InvoiceId": "nk_hd4_2026-08",
      "Description": "Điện",
      "Quantity": 125,
      "UnitPrice": 3500,
      "Amount": 437500
    },
    {
      "key": "nk_hd4_2026-08_2",
      "InvoiceId": "nk_hd4_2026-08",
      "Description": "Nước",
      "Quantity": 5,
      "UnitPrice": 12000,
      "Amount": 60000
    },
    {
      "key": "nk_hd4_2026-08_3",
      "InvoiceId": "nk_hd4_2026-08",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 80000,
      "Amount": 80000
    },
    {
      "key": "nk_hd4_2026-08_4",
      "InvoiceId": "nk_hd4_2026-08",
      "Description": "Rác và vệ sinh",
      "Quantity": 1,
      "UnitPrice": 15000,
      "Amount": 15000
    },
    {
      "key": "nk_hd4_2026-09_0",
      "InvoiceId": "nk_hd4_2026-09",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 2700000,
      "Amount": 2700000
    },
    {
      "key": "nk_hd4_2026-09_1",
      "InvoiceId": "nk_hd4_2026-09",
      "Description": "Điện",
      "Quantity": 125,
      "UnitPrice": 3500,
      "Amount": 437500
    },
    {
      "key": "nk_hd4_2026-09_2",
      "InvoiceId": "nk_hd4_2026-09",
      "Description": "Nước",
      "Quantity": 5,
      "UnitPrice": 12000,
      "Amount": 60000
    },
    {
      "key": "nk_hd4_2026-09_3",
      "InvoiceId": "nk_hd4_2026-09",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 80000,
      "Amount": 80000
    },
    {
      "key": "nk_hd4_2026-09_4",
      "InvoiceId": "nk_hd4_2026-09",
      "Description": "Rác và vệ sinh",
      "Quantity": 1,
      "UnitPrice": 15000,
      "Amount": 15000
    },
    {
      "key": "ta_hd1_2026-09_0",
      "InvoiceId": "ta_hd1_2026-09",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 2300000,
      "Amount": 2300000
    },
    {
      "key": "ta_hd1_2026-09_1",
      "InvoiceId": "ta_hd1_2026-09",
      "Description": "Điện",
      "Quantity": 81,
      "UnitPrice": 3500,
      "Amount": 283500
    },
    {
      "key": "ta_hd1_2026-09_2",
      "InvoiceId": "ta_hd1_2026-09",
      "Description": "Nước",
      "Quantity": 8,
      "UnitPrice": 12000,
      "Amount": 96000
    },
    {
      "key": "ta_hd1_2026-09_3",
      "InvoiceId": "ta_hd1_2026-09",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 80000,
      "Amount": 80000
    },
    {
      "key": "ta_hd1_2026-09_4",
      "InvoiceId": "ta_hd1_2026-09",
      "Description": "Rác và vệ sinh",
      "Quantity": 2,
      "UnitPrice": 15000,
      "Amount": 30000
    },
    {
      "key": "ta_hd1_2026-10_0",
      "InvoiceId": "ta_hd1_2026-10",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 2300000,
      "Amount": 2300000
    },
    {
      "key": "ta_hd1_2026-10_1",
      "InvoiceId": "ta_hd1_2026-10",
      "Description": "Điện",
      "Quantity": 92,
      "UnitPrice": 3500,
      "Amount": 322000
    },
    {
      "key": "ta_hd1_2026-10_2",
      "InvoiceId": "ta_hd1_2026-10",
      "Description": "Nước",
      "Quantity": 9,
      "UnitPrice": 12000,
      "Amount": 108000
    },
    {
      "key": "ta_hd1_2026-10_3",
      "InvoiceId": "ta_hd1_2026-10",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 80000,
      "Amount": 80000
    },
    {
      "key": "ta_hd1_2026-10_4",
      "InvoiceId": "ta_hd1_2026-10",
      "Description": "Rác và vệ sinh",
      "Quantity": 2,
      "UnitPrice": 15000,
      "Amount": 30000
    },
    {
      "key": "ta_hd2_2026-09_0",
      "InvoiceId": "ta_hd2_2026-09",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 2100000,
      "Amount": 2100000
    },
    {
      "key": "ta_hd2_2026-09_1",
      "InvoiceId": "ta_hd2_2026-09",
      "Description": "Điện",
      "Quantity": 98,
      "UnitPrice": 3500,
      "Amount": 343000
    },
    {
      "key": "ta_hd2_2026-09_2",
      "InvoiceId": "ta_hd2_2026-09",
      "Description": "Nước",
      "Quantity": 6,
      "UnitPrice": 12000,
      "Amount": 72000
    },
    {
      "key": "ta_hd2_2026-09_3",
      "InvoiceId": "ta_hd2_2026-09",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 80000,
      "Amount": 80000
    },
    {
      "key": "ta_hd2_2026-09_4",
      "InvoiceId": "ta_hd2_2026-09",
      "Description": "Rác và vệ sinh",
      "Quantity": 1,
      "UnitPrice": 15000,
      "Amount": 15000
    },
    {
      "key": "ta_hd2_2026-10_cancelled_0",
      "InvoiceId": "ta_hd2_2026-10_cancelled",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 2100000,
      "Amount": 2100000
    },
    {
      "key": "ta_hd2_2026-10_cancelled_1",
      "InvoiceId": "ta_hd2_2026-10_cancelled",
      "Description": "Điện",
      "Quantity": 109,
      "UnitPrice": 3500,
      "Amount": 381500
    },
    {
      "key": "ta_hd2_2026-10_cancelled_2",
      "InvoiceId": "ta_hd2_2026-10_cancelled",
      "Description": "Nước",
      "Quantity": 7,
      "UnitPrice": 12000,
      "Amount": 84000
    },
    {
      "key": "ta_hd2_2026-10_cancelled_3",
      "InvoiceId": "ta_hd2_2026-10_cancelled",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 80000,
      "Amount": 80000
    },
    {
      "key": "ta_hd2_2026-10_cancelled_4",
      "InvoiceId": "ta_hd2_2026-10_cancelled",
      "Description": "Rác và vệ sinh",
      "Quantity": 2,
      "UnitPrice": 15000,
      "Amount": 30000
    },
    {
      "key": "ta_hd2_2026-10_0",
      "InvoiceId": "ta_hd2_2026-10",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 2100000,
      "Amount": 2100000
    },
    {
      "key": "ta_hd2_2026-10_1",
      "InvoiceId": "ta_hd2_2026-10",
      "Description": "Điện",
      "Quantity": 109,
      "UnitPrice": 3500,
      "Amount": 381500
    },
    {
      "key": "ta_hd2_2026-10_2",
      "InvoiceId": "ta_hd2_2026-10",
      "Description": "Nước",
      "Quantity": 7,
      "UnitPrice": 12000,
      "Amount": 84000
    },
    {
      "key": "ta_hd2_2026-10_3",
      "InvoiceId": "ta_hd2_2026-10",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 80000,
      "Amount": 80000
    },
    {
      "key": "ta_hd2_2026-10_4",
      "InvoiceId": "ta_hd2_2026-10",
      "Description": "Rác và vệ sinh",
      "Quantity": 1,
      "UnitPrice": 15000,
      "Amount": 15000
    },
    {
      "key": "ta_hd3_2026-09_0",
      "InvoiceId": "ta_hd3_2026-09",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 2600000,
      "Amount": 2600000
    },
    {
      "key": "ta_hd3_2026-09_1",
      "InvoiceId": "ta_hd3_2026-09",
      "Description": "Điện",
      "Quantity": 115,
      "UnitPrice": 3500,
      "Amount": 402500
    },
    {
      "key": "ta_hd3_2026-09_2",
      "InvoiceId": "ta_hd3_2026-09",
      "Description": "Nước",
      "Quantity": 8,
      "UnitPrice": 12000,
      "Amount": 96000
    },
    {
      "key": "ta_hd3_2026-09_3",
      "InvoiceId": "ta_hd3_2026-09",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 80000,
      "Amount": 80000
    },
    {
      "key": "ta_hd3_2026-09_4",
      "InvoiceId": "ta_hd3_2026-09",
      "Description": "Rác và vệ sinh",
      "Quantity": 2,
      "UnitPrice": 15000,
      "Amount": 30000
    },
    {
      "key": "ta_hd3_2026-10_0",
      "InvoiceId": "ta_hd3_2026-10",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 2600000,
      "Amount": 2600000
    },
    {
      "key": "ta_hd3_2026-10_1",
      "InvoiceId": "ta_hd3_2026-10",
      "Description": "Điện",
      "Quantity": 126,
      "UnitPrice": 3500,
      "Amount": 441000
    },
    {
      "key": "ta_hd3_2026-10_2",
      "InvoiceId": "ta_hd3_2026-10",
      "Description": "Nước",
      "Quantity": 9,
      "UnitPrice": 12000,
      "Amount": 108000
    },
    {
      "key": "ta_hd3_2026-10_3",
      "InvoiceId": "ta_hd3_2026-10",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 80000,
      "Amount": 80000
    },
    {
      "key": "ta_hd3_2026-10_4",
      "InvoiceId": "ta_hd3_2026-10",
      "Description": "Rác và vệ sinh",
      "Quantity": 2,
      "UnitPrice": 15000,
      "Amount": 30000
    },
    {
      "key": "ta_hd4_2026-08_0",
      "InvoiceId": "ta_hd4_2026-08",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 2400000,
      "Amount": 2400000
    },
    {
      "key": "ta_hd4_2026-08_1",
      "InvoiceId": "ta_hd4_2026-08",
      "Description": "Điện",
      "Quantity": 132,
      "UnitPrice": 3500,
      "Amount": 462000
    },
    {
      "key": "ta_hd4_2026-08_2",
      "InvoiceId": "ta_hd4_2026-08",
      "Description": "Nước",
      "Quantity": 6,
      "UnitPrice": 12000,
      "Amount": 72000
    },
    {
      "key": "ta_hd4_2026-08_3",
      "InvoiceId": "ta_hd4_2026-08",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 80000,
      "Amount": 80000
    },
    {
      "key": "ta_hd4_2026-08_4",
      "InvoiceId": "ta_hd4_2026-08",
      "Description": "Rác và vệ sinh",
      "Quantity": 1,
      "UnitPrice": 15000,
      "Amount": 15000
    },
    {
      "key": "ta_hd4_2026-09_0",
      "InvoiceId": "ta_hd4_2026-09",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 2400000,
      "Amount": 2400000
    },
    {
      "key": "ta_hd4_2026-09_1",
      "InvoiceId": "ta_hd4_2026-09",
      "Description": "Điện",
      "Quantity": 132,
      "UnitPrice": 3500,
      "Amount": 462000
    },
    {
      "key": "ta_hd4_2026-09_2",
      "InvoiceId": "ta_hd4_2026-09",
      "Description": "Nước",
      "Quantity": 6,
      "UnitPrice": 12000,
      "Amount": 72000
    },
    {
      "key": "ta_hd4_2026-09_3",
      "InvoiceId": "ta_hd4_2026-09",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 80000,
      "Amount": 80000
    },
    {
      "key": "ta_hd4_2026-09_4",
      "InvoiceId": "ta_hd4_2026-09",
      "Description": "Rác và vệ sinh",
      "Quantity": 1,
      "UnitPrice": 15000,
      "Amount": 15000
    },
    {
      "key": "ck_hd1_2026-09_0",
      "InvoiceId": "ck_hd1_2026-09",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 2800000,
      "Amount": 2800000
    },
    {
      "key": "ck_hd1_2026-09_1",
      "InvoiceId": "ck_hd1_2026-09",
      "Description": "Điện",
      "Quantity": 88,
      "UnitPrice": 3500,
      "Amount": 308000
    },
    {
      "key": "ck_hd1_2026-09_2",
      "InvoiceId": "ck_hd1_2026-09",
      "Description": "Nước",
      "Quantity": 7,
      "UnitPrice": 12000,
      "Amount": 84000
    },
    {
      "key": "ck_hd1_2026-09_3",
      "InvoiceId": "ck_hd1_2026-09",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 80000,
      "Amount": 80000
    },
    {
      "key": "ck_hd1_2026-09_4",
      "InvoiceId": "ck_hd1_2026-09",
      "Description": "Rác và vệ sinh",
      "Quantity": 2,
      "UnitPrice": 15000,
      "Amount": 30000
    },
    {
      "key": "ck_hd1_2026-10_0",
      "InvoiceId": "ck_hd1_2026-10",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 2800000,
      "Amount": 2800000
    },
    {
      "key": "ck_hd1_2026-10_1",
      "InvoiceId": "ck_hd1_2026-10",
      "Description": "Điện",
      "Quantity": 99,
      "UnitPrice": 3500,
      "Amount": 346500
    },
    {
      "key": "ck_hd1_2026-10_2",
      "InvoiceId": "ck_hd1_2026-10",
      "Description": "Nước",
      "Quantity": 8,
      "UnitPrice": 12000,
      "Amount": 96000
    },
    {
      "key": "ck_hd1_2026-10_3",
      "InvoiceId": "ck_hd1_2026-10",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 80000,
      "Amount": 80000
    },
    {
      "key": "ck_hd1_2026-10_4",
      "InvoiceId": "ck_hd1_2026-10",
      "Description": "Rác và vệ sinh",
      "Quantity": 2,
      "UnitPrice": 15000,
      "Amount": 30000
    },
    {
      "key": "ck_hd2_2026-09_0",
      "InvoiceId": "ck_hd2_2026-09",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 2600000,
      "Amount": 2600000
    },
    {
      "key": "ck_hd2_2026-09_1",
      "InvoiceId": "ck_hd2_2026-09",
      "Description": "Điện",
      "Quantity": 105,
      "UnitPrice": 3500,
      "Amount": 367500
    },
    {
      "key": "ck_hd2_2026-09_2",
      "InvoiceId": "ck_hd2_2026-09",
      "Description": "Nước",
      "Quantity": 5,
      "UnitPrice": 12000,
      "Amount": 60000
    },
    {
      "key": "ck_hd2_2026-09_3",
      "InvoiceId": "ck_hd2_2026-09",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 80000,
      "Amount": 80000
    },
    {
      "key": "ck_hd2_2026-09_4",
      "InvoiceId": "ck_hd2_2026-09",
      "Description": "Rác và vệ sinh",
      "Quantity": 1,
      "UnitPrice": 15000,
      "Amount": 15000
    },
    {
      "key": "ck_hd2_2026-10_cancelled_0",
      "InvoiceId": "ck_hd2_2026-10_cancelled",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 2600000,
      "Amount": 2600000
    },
    {
      "key": "ck_hd2_2026-10_cancelled_1",
      "InvoiceId": "ck_hd2_2026-10_cancelled",
      "Description": "Điện",
      "Quantity": 116,
      "UnitPrice": 3500,
      "Amount": 406000
    },
    {
      "key": "ck_hd2_2026-10_cancelled_2",
      "InvoiceId": "ck_hd2_2026-10_cancelled",
      "Description": "Nước",
      "Quantity": 6,
      "UnitPrice": 12000,
      "Amount": 72000
    },
    {
      "key": "ck_hd2_2026-10_cancelled_3",
      "InvoiceId": "ck_hd2_2026-10_cancelled",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 80000,
      "Amount": 80000
    },
    {
      "key": "ck_hd2_2026-10_cancelled_4",
      "InvoiceId": "ck_hd2_2026-10_cancelled",
      "Description": "Rác và vệ sinh",
      "Quantity": 2,
      "UnitPrice": 15000,
      "Amount": 30000
    },
    {
      "key": "ck_hd2_2026-10_0",
      "InvoiceId": "ck_hd2_2026-10",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 2600000,
      "Amount": 2600000
    },
    {
      "key": "ck_hd2_2026-10_1",
      "InvoiceId": "ck_hd2_2026-10",
      "Description": "Điện",
      "Quantity": 116,
      "UnitPrice": 3500,
      "Amount": 406000
    },
    {
      "key": "ck_hd2_2026-10_2",
      "InvoiceId": "ck_hd2_2026-10",
      "Description": "Nước",
      "Quantity": 6,
      "UnitPrice": 12000,
      "Amount": 72000
    },
    {
      "key": "ck_hd2_2026-10_3",
      "InvoiceId": "ck_hd2_2026-10",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 80000,
      "Amount": 80000
    },
    {
      "key": "ck_hd2_2026-10_4",
      "InvoiceId": "ck_hd2_2026-10",
      "Description": "Rác và vệ sinh",
      "Quantity": 1,
      "UnitPrice": 15000,
      "Amount": 15000
    },
    {
      "key": "ck_hd3_2026-09_0",
      "InvoiceId": "ck_hd3_2026-09",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 3100000,
      "Amount": 3100000
    },
    {
      "key": "ck_hd3_2026-09_1",
      "InvoiceId": "ck_hd3_2026-09",
      "Description": "Điện",
      "Quantity": 122,
      "UnitPrice": 3500,
      "Amount": 427000
    },
    {
      "key": "ck_hd3_2026-09_2",
      "InvoiceId": "ck_hd3_2026-09",
      "Description": "Nước",
      "Quantity": 7,
      "UnitPrice": 12000,
      "Amount": 84000
    },
    {
      "key": "ck_hd3_2026-09_3",
      "InvoiceId": "ck_hd3_2026-09",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 80000,
      "Amount": 80000
    },
    {
      "key": "ck_hd3_2026-09_4",
      "InvoiceId": "ck_hd3_2026-09",
      "Description": "Rác và vệ sinh",
      "Quantity": 2,
      "UnitPrice": 15000,
      "Amount": 30000
    },
    {
      "key": "ck_hd3_2026-10_0",
      "InvoiceId": "ck_hd3_2026-10",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 3100000,
      "Amount": 3100000
    },
    {
      "key": "ck_hd3_2026-10_1",
      "InvoiceId": "ck_hd3_2026-10",
      "Description": "Điện",
      "Quantity": 133,
      "UnitPrice": 3500,
      "Amount": 465500
    },
    {
      "key": "ck_hd3_2026-10_2",
      "InvoiceId": "ck_hd3_2026-10",
      "Description": "Nước",
      "Quantity": 8,
      "UnitPrice": 12000,
      "Amount": 96000
    },
    {
      "key": "ck_hd3_2026-10_3",
      "InvoiceId": "ck_hd3_2026-10",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 80000,
      "Amount": 80000
    },
    {
      "key": "ck_hd3_2026-10_4",
      "InvoiceId": "ck_hd3_2026-10",
      "Description": "Rác và vệ sinh",
      "Quantity": 2,
      "UnitPrice": 15000,
      "Amount": 30000
    },
    {
      "key": "ck_hd4_2026-08_0",
      "InvoiceId": "ck_hd4_2026-08",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 2900000,
      "Amount": 2900000
    },
    {
      "key": "ck_hd4_2026-08_1",
      "InvoiceId": "ck_hd4_2026-08",
      "Description": "Điện",
      "Quantity": 139,
      "UnitPrice": 3500,
      "Amount": 486500
    },
    {
      "key": "ck_hd4_2026-08_2",
      "InvoiceId": "ck_hd4_2026-08",
      "Description": "Nước",
      "Quantity": 5,
      "UnitPrice": 12000,
      "Amount": 60000
    },
    {
      "key": "ck_hd4_2026-08_3",
      "InvoiceId": "ck_hd4_2026-08",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 80000,
      "Amount": 80000
    },
    {
      "key": "ck_hd4_2026-08_4",
      "InvoiceId": "ck_hd4_2026-08",
      "Description": "Rác và vệ sinh",
      "Quantity": 1,
      "UnitPrice": 15000,
      "Amount": 15000
    },
    {
      "key": "ck_hd4_2026-09_0",
      "InvoiceId": "ck_hd4_2026-09",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 2900000,
      "Amount": 2900000
    },
    {
      "key": "ck_hd4_2026-09_1",
      "InvoiceId": "ck_hd4_2026-09",
      "Description": "Điện",
      "Quantity": 139,
      "UnitPrice": 3500,
      "Amount": 486500
    },
    {
      "key": "ck_hd4_2026-09_2",
      "InvoiceId": "ck_hd4_2026-09",
      "Description": "Nước",
      "Quantity": 5,
      "UnitPrice": 12000,
      "Amount": 60000
    },
    {
      "key": "ck_hd4_2026-09_3",
      "InvoiceId": "ck_hd4_2026-09",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 80000,
      "Amount": 80000
    },
    {
      "key": "ck_hd4_2026-09_4",
      "InvoiceId": "ck_hd4_2026-09",
      "Description": "Rác và vệ sinh",
      "Quantity": 1,
      "UnitPrice": 15000,
      "Amount": 15000
    },
    {
      "key": "bt_hd1_2026-09_0",
      "InvoiceId": "bt_hd1_2026-09",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 1800000,
      "Amount": 1800000
    },
    {
      "key": "bt_hd1_2026-09_1",
      "InvoiceId": "bt_hd1_2026-09",
      "Description": "Điện",
      "Quantity": 95,
      "UnitPrice": 3500,
      "Amount": 332500
    },
    {
      "key": "bt_hd1_2026-09_2",
      "InvoiceId": "bt_hd1_2026-09",
      "Description": "Nước",
      "Quantity": 8,
      "UnitPrice": 12000,
      "Amount": 96000
    },
    {
      "key": "bt_hd1_2026-09_3",
      "InvoiceId": "bt_hd1_2026-09",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 60000,
      "Amount": 60000
    },
    {
      "key": "bt_hd1_2026-09_4",
      "InvoiceId": "bt_hd1_2026-09",
      "Description": "Rác và vệ sinh",
      "Quantity": 2,
      "UnitPrice": 15000,
      "Amount": 30000
    },
    {
      "key": "bt_hd1_2026-10_0",
      "InvoiceId": "bt_hd1_2026-10",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 1800000,
      "Amount": 1800000
    },
    {
      "key": "bt_hd1_2026-10_1",
      "InvoiceId": "bt_hd1_2026-10",
      "Description": "Điện",
      "Quantity": 106,
      "UnitPrice": 3500,
      "Amount": 371000
    },
    {
      "key": "bt_hd1_2026-10_2",
      "InvoiceId": "bt_hd1_2026-10",
      "Description": "Nước",
      "Quantity": 9,
      "UnitPrice": 12000,
      "Amount": 108000
    },
    {
      "key": "bt_hd1_2026-10_3",
      "InvoiceId": "bt_hd1_2026-10",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 60000,
      "Amount": 60000
    },
    {
      "key": "bt_hd1_2026-10_4",
      "InvoiceId": "bt_hd1_2026-10",
      "Description": "Rác và vệ sinh",
      "Quantity": 2,
      "UnitPrice": 15000,
      "Amount": 30000
    },
    {
      "key": "bt_hd2_2026-09_0",
      "InvoiceId": "bt_hd2_2026-09",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 1600000,
      "Amount": 1600000
    },
    {
      "key": "bt_hd2_2026-09_1",
      "InvoiceId": "bt_hd2_2026-09",
      "Description": "Điện",
      "Quantity": 112,
      "UnitPrice": 3500,
      "Amount": 392000
    },
    {
      "key": "bt_hd2_2026-09_2",
      "InvoiceId": "bt_hd2_2026-09",
      "Description": "Nước",
      "Quantity": 6,
      "UnitPrice": 12000,
      "Amount": 72000
    },
    {
      "key": "bt_hd2_2026-09_3",
      "InvoiceId": "bt_hd2_2026-09",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 60000,
      "Amount": 60000
    },
    {
      "key": "bt_hd2_2026-09_4",
      "InvoiceId": "bt_hd2_2026-09",
      "Description": "Rác và vệ sinh",
      "Quantity": 1,
      "UnitPrice": 15000,
      "Amount": 15000
    },
    {
      "key": "bt_hd2_2026-10_cancelled_0",
      "InvoiceId": "bt_hd2_2026-10_cancelled",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 1600000,
      "Amount": 1600000
    },
    {
      "key": "bt_hd2_2026-10_cancelled_1",
      "InvoiceId": "bt_hd2_2026-10_cancelled",
      "Description": "Điện",
      "Quantity": 123,
      "UnitPrice": 3500,
      "Amount": 430500
    },
    {
      "key": "bt_hd2_2026-10_cancelled_2",
      "InvoiceId": "bt_hd2_2026-10_cancelled",
      "Description": "Nước",
      "Quantity": 7,
      "UnitPrice": 12000,
      "Amount": 84000
    },
    {
      "key": "bt_hd2_2026-10_cancelled_3",
      "InvoiceId": "bt_hd2_2026-10_cancelled",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 60000,
      "Amount": 60000
    },
    {
      "key": "bt_hd2_2026-10_cancelled_4",
      "InvoiceId": "bt_hd2_2026-10_cancelled",
      "Description": "Rác và vệ sinh",
      "Quantity": 2,
      "UnitPrice": 15000,
      "Amount": 30000
    },
    {
      "key": "bt_hd2_2026-10_0",
      "InvoiceId": "bt_hd2_2026-10",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 1600000,
      "Amount": 1600000
    },
    {
      "key": "bt_hd2_2026-10_1",
      "InvoiceId": "bt_hd2_2026-10",
      "Description": "Điện",
      "Quantity": 123,
      "UnitPrice": 3500,
      "Amount": 430500
    },
    {
      "key": "bt_hd2_2026-10_2",
      "InvoiceId": "bt_hd2_2026-10",
      "Description": "Nước",
      "Quantity": 7,
      "UnitPrice": 12000,
      "Amount": 84000
    },
    {
      "key": "bt_hd2_2026-10_3",
      "InvoiceId": "bt_hd2_2026-10",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 60000,
      "Amount": 60000
    },
    {
      "key": "bt_hd2_2026-10_4",
      "InvoiceId": "bt_hd2_2026-10",
      "Description": "Rác và vệ sinh",
      "Quantity": 1,
      "UnitPrice": 15000,
      "Amount": 15000
    },
    {
      "key": "bt_hd3_2026-09_0",
      "InvoiceId": "bt_hd3_2026-09",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 2100000,
      "Amount": 2100000
    },
    {
      "key": "bt_hd3_2026-09_1",
      "InvoiceId": "bt_hd3_2026-09",
      "Description": "Điện",
      "Quantity": 129,
      "UnitPrice": 3500,
      "Amount": 451500
    },
    {
      "key": "bt_hd3_2026-09_2",
      "InvoiceId": "bt_hd3_2026-09",
      "Description": "Nước",
      "Quantity": 8,
      "UnitPrice": 12000,
      "Amount": 96000
    },
    {
      "key": "bt_hd3_2026-09_3",
      "InvoiceId": "bt_hd3_2026-09",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 60000,
      "Amount": 60000
    },
    {
      "key": "bt_hd3_2026-09_4",
      "InvoiceId": "bt_hd3_2026-09",
      "Description": "Rác và vệ sinh",
      "Quantity": 2,
      "UnitPrice": 15000,
      "Amount": 30000
    },
    {
      "key": "bt_hd3_2026-10_0",
      "InvoiceId": "bt_hd3_2026-10",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 2100000,
      "Amount": 2100000
    },
    {
      "key": "bt_hd3_2026-10_1",
      "InvoiceId": "bt_hd3_2026-10",
      "Description": "Điện",
      "Quantity": 140,
      "UnitPrice": 3500,
      "Amount": 490000
    },
    {
      "key": "bt_hd3_2026-10_2",
      "InvoiceId": "bt_hd3_2026-10",
      "Description": "Nước",
      "Quantity": 9,
      "UnitPrice": 12000,
      "Amount": 108000
    },
    {
      "key": "bt_hd3_2026-10_3",
      "InvoiceId": "bt_hd3_2026-10",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 60000,
      "Amount": 60000
    },
    {
      "key": "bt_hd3_2026-10_4",
      "InvoiceId": "bt_hd3_2026-10",
      "Description": "Rác và vệ sinh",
      "Quantity": 2,
      "UnitPrice": 15000,
      "Amount": 30000
    },
    {
      "key": "bt_hd4_2026-08_0",
      "InvoiceId": "bt_hd4_2026-08",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 1900000,
      "Amount": 1900000
    },
    {
      "key": "bt_hd4_2026-08_1",
      "InvoiceId": "bt_hd4_2026-08",
      "Description": "Điện",
      "Quantity": 146,
      "UnitPrice": 3500,
      "Amount": 511000
    },
    {
      "key": "bt_hd4_2026-08_2",
      "InvoiceId": "bt_hd4_2026-08",
      "Description": "Nước",
      "Quantity": 6,
      "UnitPrice": 12000,
      "Amount": 72000
    },
    {
      "key": "bt_hd4_2026-08_3",
      "InvoiceId": "bt_hd4_2026-08",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 60000,
      "Amount": 60000
    },
    {
      "key": "bt_hd4_2026-08_4",
      "InvoiceId": "bt_hd4_2026-08",
      "Description": "Rác và vệ sinh",
      "Quantity": 1,
      "UnitPrice": 15000,
      "Amount": 15000
    },
    {
      "key": "bt_hd4_2026-09_0",
      "InvoiceId": "bt_hd4_2026-09",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 1900000,
      "Amount": 1900000
    },
    {
      "key": "bt_hd4_2026-09_1",
      "InvoiceId": "bt_hd4_2026-09",
      "Description": "Điện",
      "Quantity": 146,
      "UnitPrice": 3500,
      "Amount": 511000
    },
    {
      "key": "bt_hd4_2026-09_2",
      "InvoiceId": "bt_hd4_2026-09",
      "Description": "Nước",
      "Quantity": 6,
      "UnitPrice": 12000,
      "Amount": 72000
    },
    {
      "key": "bt_hd4_2026-09_3",
      "InvoiceId": "bt_hd4_2026-09",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 60000,
      "Amount": 60000
    },
    {
      "key": "bt_hd4_2026-09_4",
      "InvoiceId": "bt_hd4_2026-09",
      "Description": "Rác và vệ sinh",
      "Quantity": 1,
      "UnitPrice": 15000,
      "Amount": 15000
    },
    {
      "key": "cr_hd1_2026-09_0",
      "InvoiceId": "cr_hd1_2026-09",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 2200000,
      "Amount": 2200000
    },
    {
      "key": "cr_hd1_2026-09_1",
      "InvoiceId": "cr_hd1_2026-09",
      "Description": "Điện",
      "Quantity": 102,
      "UnitPrice": 3500,
      "Amount": 357000
    },
    {
      "key": "cr_hd1_2026-09_2",
      "InvoiceId": "cr_hd1_2026-09",
      "Description": "Nước",
      "Quantity": 7,
      "UnitPrice": 12000,
      "Amount": 84000
    },
    {
      "key": "cr_hd1_2026-09_3",
      "InvoiceId": "cr_hd1_2026-09",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 60000,
      "Amount": 60000
    },
    {
      "key": "cr_hd1_2026-09_4",
      "InvoiceId": "cr_hd1_2026-09",
      "Description": "Rác và vệ sinh",
      "Quantity": 2,
      "UnitPrice": 15000,
      "Amount": 30000
    },
    {
      "key": "cr_hd1_2026-10_0",
      "InvoiceId": "cr_hd1_2026-10",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 2200000,
      "Amount": 2200000
    },
    {
      "key": "cr_hd1_2026-10_1",
      "InvoiceId": "cr_hd1_2026-10",
      "Description": "Điện",
      "Quantity": 113,
      "UnitPrice": 3500,
      "Amount": 395500
    },
    {
      "key": "cr_hd1_2026-10_2",
      "InvoiceId": "cr_hd1_2026-10",
      "Description": "Nước",
      "Quantity": 8,
      "UnitPrice": 12000,
      "Amount": 96000
    },
    {
      "key": "cr_hd1_2026-10_3",
      "InvoiceId": "cr_hd1_2026-10",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 60000,
      "Amount": 60000
    },
    {
      "key": "cr_hd1_2026-10_4",
      "InvoiceId": "cr_hd1_2026-10",
      "Description": "Rác và vệ sinh",
      "Quantity": 2,
      "UnitPrice": 15000,
      "Amount": 30000
    },
    {
      "key": "cr_hd2_2026-09_0",
      "InvoiceId": "cr_hd2_2026-09",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 2000000,
      "Amount": 2000000
    },
    {
      "key": "cr_hd2_2026-09_1",
      "InvoiceId": "cr_hd2_2026-09",
      "Description": "Điện",
      "Quantity": 119,
      "UnitPrice": 3500,
      "Amount": 416500
    },
    {
      "key": "cr_hd2_2026-09_2",
      "InvoiceId": "cr_hd2_2026-09",
      "Description": "Nước",
      "Quantity": 5,
      "UnitPrice": 12000,
      "Amount": 60000
    },
    {
      "key": "cr_hd2_2026-09_3",
      "InvoiceId": "cr_hd2_2026-09",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 60000,
      "Amount": 60000
    },
    {
      "key": "cr_hd2_2026-09_4",
      "InvoiceId": "cr_hd2_2026-09",
      "Description": "Rác và vệ sinh",
      "Quantity": 1,
      "UnitPrice": 15000,
      "Amount": 15000
    },
    {
      "key": "cr_hd2_2026-10_cancelled_0",
      "InvoiceId": "cr_hd2_2026-10_cancelled",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 2000000,
      "Amount": 2000000
    },
    {
      "key": "cr_hd2_2026-10_cancelled_1",
      "InvoiceId": "cr_hd2_2026-10_cancelled",
      "Description": "Điện",
      "Quantity": 130,
      "UnitPrice": 3500,
      "Amount": 455000
    },
    {
      "key": "cr_hd2_2026-10_cancelled_2",
      "InvoiceId": "cr_hd2_2026-10_cancelled",
      "Description": "Nước",
      "Quantity": 6,
      "UnitPrice": 12000,
      "Amount": 72000
    },
    {
      "key": "cr_hd2_2026-10_cancelled_3",
      "InvoiceId": "cr_hd2_2026-10_cancelled",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 60000,
      "Amount": 60000
    },
    {
      "key": "cr_hd2_2026-10_cancelled_4",
      "InvoiceId": "cr_hd2_2026-10_cancelled",
      "Description": "Rác và vệ sinh",
      "Quantity": 2,
      "UnitPrice": 15000,
      "Amount": 30000
    },
    {
      "key": "cr_hd2_2026-10_0",
      "InvoiceId": "cr_hd2_2026-10",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 2000000,
      "Amount": 2000000
    },
    {
      "key": "cr_hd2_2026-10_1",
      "InvoiceId": "cr_hd2_2026-10",
      "Description": "Điện",
      "Quantity": 130,
      "UnitPrice": 3500,
      "Amount": 455000
    },
    {
      "key": "cr_hd2_2026-10_2",
      "InvoiceId": "cr_hd2_2026-10",
      "Description": "Nước",
      "Quantity": 6,
      "UnitPrice": 12000,
      "Amount": 72000
    },
    {
      "key": "cr_hd2_2026-10_3",
      "InvoiceId": "cr_hd2_2026-10",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 60000,
      "Amount": 60000
    },
    {
      "key": "cr_hd2_2026-10_4",
      "InvoiceId": "cr_hd2_2026-10",
      "Description": "Rác và vệ sinh",
      "Quantity": 1,
      "UnitPrice": 15000,
      "Amount": 15000
    },
    {
      "key": "cr_hd3_2026-09_0",
      "InvoiceId": "cr_hd3_2026-09",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 2500000,
      "Amount": 2500000
    },
    {
      "key": "cr_hd3_2026-09_1",
      "InvoiceId": "cr_hd3_2026-09",
      "Description": "Điện",
      "Quantity": 136,
      "UnitPrice": 3500,
      "Amount": 476000
    },
    {
      "key": "cr_hd3_2026-09_2",
      "InvoiceId": "cr_hd3_2026-09",
      "Description": "Nước",
      "Quantity": 7,
      "UnitPrice": 12000,
      "Amount": 84000
    },
    {
      "key": "cr_hd3_2026-09_3",
      "InvoiceId": "cr_hd3_2026-09",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 60000,
      "Amount": 60000
    },
    {
      "key": "cr_hd3_2026-09_4",
      "InvoiceId": "cr_hd3_2026-09",
      "Description": "Rác và vệ sinh",
      "Quantity": 2,
      "UnitPrice": 15000,
      "Amount": 30000
    },
    {
      "key": "cr_hd3_2026-10_0",
      "InvoiceId": "cr_hd3_2026-10",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 2500000,
      "Amount": 2500000
    },
    {
      "key": "cr_hd3_2026-10_1",
      "InvoiceId": "cr_hd3_2026-10",
      "Description": "Điện",
      "Quantity": 147,
      "UnitPrice": 3500,
      "Amount": 514500
    },
    {
      "key": "cr_hd3_2026-10_2",
      "InvoiceId": "cr_hd3_2026-10",
      "Description": "Nước",
      "Quantity": 8,
      "UnitPrice": 12000,
      "Amount": 96000
    },
    {
      "key": "cr_hd3_2026-10_3",
      "InvoiceId": "cr_hd3_2026-10",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 60000,
      "Amount": 60000
    },
    {
      "key": "cr_hd3_2026-10_4",
      "InvoiceId": "cr_hd3_2026-10",
      "Description": "Rác và vệ sinh",
      "Quantity": 2,
      "UnitPrice": 15000,
      "Amount": 30000
    },
    {
      "key": "cr_hd4_2026-08_0",
      "InvoiceId": "cr_hd4_2026-08",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 2300000,
      "Amount": 2300000
    },
    {
      "key": "cr_hd4_2026-08_1",
      "InvoiceId": "cr_hd4_2026-08",
      "Description": "Điện",
      "Quantity": 153,
      "UnitPrice": 3500,
      "Amount": 535500
    },
    {
      "key": "cr_hd4_2026-08_2",
      "InvoiceId": "cr_hd4_2026-08",
      "Description": "Nước",
      "Quantity": 5,
      "UnitPrice": 12000,
      "Amount": 60000
    },
    {
      "key": "cr_hd4_2026-08_3",
      "InvoiceId": "cr_hd4_2026-08",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 60000,
      "Amount": 60000
    },
    {
      "key": "cr_hd4_2026-08_4",
      "InvoiceId": "cr_hd4_2026-08",
      "Description": "Rác và vệ sinh",
      "Quantity": 1,
      "UnitPrice": 15000,
      "Amount": 15000
    },
    {
      "key": "cr_hd4_2026-09_0",
      "InvoiceId": "cr_hd4_2026-09",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 2300000,
      "Amount": 2300000
    },
    {
      "key": "cr_hd4_2026-09_1",
      "InvoiceId": "cr_hd4_2026-09",
      "Description": "Điện",
      "Quantity": 153,
      "UnitPrice": 3500,
      "Amount": 535500
    },
    {
      "key": "cr_hd4_2026-09_2",
      "InvoiceId": "cr_hd4_2026-09",
      "Description": "Nước",
      "Quantity": 5,
      "UnitPrice": 12000,
      "Amount": 60000
    },
    {
      "key": "cr_hd4_2026-09_3",
      "InvoiceId": "cr_hd4_2026-09",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 60000,
      "Amount": 60000
    },
    {
      "key": "cr_hd4_2026-09_4",
      "InvoiceId": "cr_hd4_2026-09",
      "Description": "Rác và vệ sinh",
      "Quantity": 1,
      "UnitPrice": 15000,
      "Amount": 15000
    },
    {
      "key": "om_hd1_2026-09_0",
      "InvoiceId": "om_hd1_2026-09",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 1600000,
      "Amount": 1600000
    },
    {
      "key": "om_hd1_2026-09_1",
      "InvoiceId": "om_hd1_2026-09",
      "Description": "Điện",
      "Quantity": 109,
      "UnitPrice": 3500,
      "Amount": 381500
    },
    {
      "key": "om_hd1_2026-09_2",
      "InvoiceId": "om_hd1_2026-09",
      "Description": "Nước",
      "Quantity": 8,
      "UnitPrice": 12000,
      "Amount": 96000
    },
    {
      "key": "om_hd1_2026-09_3",
      "InvoiceId": "om_hd1_2026-09",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 60000,
      "Amount": 60000
    },
    {
      "key": "om_hd1_2026-09_4",
      "InvoiceId": "om_hd1_2026-09",
      "Description": "Rác và vệ sinh",
      "Quantity": 2,
      "UnitPrice": 15000,
      "Amount": 30000
    },
    {
      "key": "om_hd1_2026-10_0",
      "InvoiceId": "om_hd1_2026-10",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 1600000,
      "Amount": 1600000
    },
    {
      "key": "om_hd1_2026-10_1",
      "InvoiceId": "om_hd1_2026-10",
      "Description": "Điện",
      "Quantity": 120,
      "UnitPrice": 3500,
      "Amount": 420000
    },
    {
      "key": "om_hd1_2026-10_2",
      "InvoiceId": "om_hd1_2026-10",
      "Description": "Nước",
      "Quantity": 9,
      "UnitPrice": 12000,
      "Amount": 108000
    },
    {
      "key": "om_hd1_2026-10_3",
      "InvoiceId": "om_hd1_2026-10",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 60000,
      "Amount": 60000
    },
    {
      "key": "om_hd1_2026-10_4",
      "InvoiceId": "om_hd1_2026-10",
      "Description": "Rác và vệ sinh",
      "Quantity": 2,
      "UnitPrice": 15000,
      "Amount": 30000
    },
    {
      "key": "om_hd2_2026-09_0",
      "InvoiceId": "om_hd2_2026-09",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 1400000,
      "Amount": 1400000
    },
    {
      "key": "om_hd2_2026-09_1",
      "InvoiceId": "om_hd2_2026-09",
      "Description": "Điện",
      "Quantity": 126,
      "UnitPrice": 3500,
      "Amount": 441000
    },
    {
      "key": "om_hd2_2026-09_2",
      "InvoiceId": "om_hd2_2026-09",
      "Description": "Nước",
      "Quantity": 6,
      "UnitPrice": 12000,
      "Amount": 72000
    },
    {
      "key": "om_hd2_2026-09_3",
      "InvoiceId": "om_hd2_2026-09",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 60000,
      "Amount": 60000
    },
    {
      "key": "om_hd2_2026-09_4",
      "InvoiceId": "om_hd2_2026-09",
      "Description": "Rác và vệ sinh",
      "Quantity": 1,
      "UnitPrice": 15000,
      "Amount": 15000
    },
    {
      "key": "om_hd2_2026-10_cancelled_0",
      "InvoiceId": "om_hd2_2026-10_cancelled",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 1400000,
      "Amount": 1400000
    },
    {
      "key": "om_hd2_2026-10_cancelled_1",
      "InvoiceId": "om_hd2_2026-10_cancelled",
      "Description": "Điện",
      "Quantity": 137,
      "UnitPrice": 3500,
      "Amount": 479500
    },
    {
      "key": "om_hd2_2026-10_cancelled_2",
      "InvoiceId": "om_hd2_2026-10_cancelled",
      "Description": "Nước",
      "Quantity": 7,
      "UnitPrice": 12000,
      "Amount": 84000
    },
    {
      "key": "om_hd2_2026-10_cancelled_3",
      "InvoiceId": "om_hd2_2026-10_cancelled",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 60000,
      "Amount": 60000
    },
    {
      "key": "om_hd2_2026-10_cancelled_4",
      "InvoiceId": "om_hd2_2026-10_cancelled",
      "Description": "Rác và vệ sinh",
      "Quantity": 2,
      "UnitPrice": 15000,
      "Amount": 30000
    },
    {
      "key": "om_hd2_2026-10_0",
      "InvoiceId": "om_hd2_2026-10",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 1400000,
      "Amount": 1400000
    },
    {
      "key": "om_hd2_2026-10_1",
      "InvoiceId": "om_hd2_2026-10",
      "Description": "Điện",
      "Quantity": 137,
      "UnitPrice": 3500,
      "Amount": 479500
    },
    {
      "key": "om_hd2_2026-10_2",
      "InvoiceId": "om_hd2_2026-10",
      "Description": "Nước",
      "Quantity": 7,
      "UnitPrice": 12000,
      "Amount": 84000
    },
    {
      "key": "om_hd2_2026-10_3",
      "InvoiceId": "om_hd2_2026-10",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 60000,
      "Amount": 60000
    },
    {
      "key": "om_hd2_2026-10_4",
      "InvoiceId": "om_hd2_2026-10",
      "Description": "Rác và vệ sinh",
      "Quantity": 1,
      "UnitPrice": 15000,
      "Amount": 15000
    },
    {
      "key": "om_hd3_2026-09_0",
      "InvoiceId": "om_hd3_2026-09",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 1900000,
      "Amount": 1900000
    },
    {
      "key": "om_hd3_2026-09_1",
      "InvoiceId": "om_hd3_2026-09",
      "Description": "Điện",
      "Quantity": 143,
      "UnitPrice": 3500,
      "Amount": 500500
    },
    {
      "key": "om_hd3_2026-09_2",
      "InvoiceId": "om_hd3_2026-09",
      "Description": "Nước",
      "Quantity": 8,
      "UnitPrice": 12000,
      "Amount": 96000
    },
    {
      "key": "om_hd3_2026-09_3",
      "InvoiceId": "om_hd3_2026-09",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 60000,
      "Amount": 60000
    },
    {
      "key": "om_hd3_2026-09_4",
      "InvoiceId": "om_hd3_2026-09",
      "Description": "Rác và vệ sinh",
      "Quantity": 2,
      "UnitPrice": 15000,
      "Amount": 30000
    },
    {
      "key": "om_hd3_2026-10_0",
      "InvoiceId": "om_hd3_2026-10",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 1900000,
      "Amount": 1900000
    },
    {
      "key": "om_hd3_2026-10_1",
      "InvoiceId": "om_hd3_2026-10",
      "Description": "Điện",
      "Quantity": 154,
      "UnitPrice": 3500,
      "Amount": 539000
    },
    {
      "key": "om_hd3_2026-10_2",
      "InvoiceId": "om_hd3_2026-10",
      "Description": "Nước",
      "Quantity": 9,
      "UnitPrice": 12000,
      "Amount": 108000
    },
    {
      "key": "om_hd3_2026-10_3",
      "InvoiceId": "om_hd3_2026-10",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 60000,
      "Amount": 60000
    },
    {
      "key": "om_hd3_2026-10_4",
      "InvoiceId": "om_hd3_2026-10",
      "Description": "Rác và vệ sinh",
      "Quantity": 2,
      "UnitPrice": 15000,
      "Amount": 30000
    },
    {
      "key": "om_hd4_2026-08_0",
      "InvoiceId": "om_hd4_2026-08",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 1700000,
      "Amount": 1700000
    },
    {
      "key": "om_hd4_2026-08_1",
      "InvoiceId": "om_hd4_2026-08",
      "Description": "Điện",
      "Quantity": 160,
      "UnitPrice": 3500,
      "Amount": 560000
    },
    {
      "key": "om_hd4_2026-08_2",
      "InvoiceId": "om_hd4_2026-08",
      "Description": "Nước",
      "Quantity": 6,
      "UnitPrice": 12000,
      "Amount": 72000
    },
    {
      "key": "om_hd4_2026-08_3",
      "InvoiceId": "om_hd4_2026-08",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 60000,
      "Amount": 60000
    },
    {
      "key": "om_hd4_2026-08_4",
      "InvoiceId": "om_hd4_2026-08",
      "Description": "Rác và vệ sinh",
      "Quantity": 1,
      "UnitPrice": 15000,
      "Amount": 15000
    },
    {
      "key": "om_hd4_2026-09_0",
      "InvoiceId": "om_hd4_2026-09",
      "Description": "Tiền thuê phòng (đủ tháng)",
      "Quantity": 1,
      "UnitPrice": 1700000,
      "Amount": 1700000
    },
    {
      "key": "om_hd4_2026-09_1",
      "InvoiceId": "om_hd4_2026-09",
      "Description": "Điện",
      "Quantity": 160,
      "UnitPrice": 3500,
      "Amount": 560000
    },
    {
      "key": "om_hd4_2026-09_2",
      "InvoiceId": "om_hd4_2026-09",
      "Description": "Nước",
      "Quantity": 6,
      "UnitPrice": 12000,
      "Amount": 72000
    },
    {
      "key": "om_hd4_2026-09_3",
      "InvoiceId": "om_hd4_2026-09",
      "Description": "Internet",
      "Quantity": 1,
      "UnitPrice": 60000,
      "Amount": 60000
    },
    {
      "key": "om_hd4_2026-09_4",
      "InvoiceId": "om_hd4_2026-09",
      "Description": "Rác và vệ sinh",
      "Quantity": 1,
      "UnitPrice": 15000,
      "Amount": 15000
    }
  ],
  "payments": [
    {
      "key": "nk_hd1_2026-09_paid",
      "InvoiceId": "nk_hd1_2026-09",
      "Amount": 3053000,
      "Method": "Transfer",
      "PaidDate": "2026-09-26",
      "Note": "Đã thanh toán đủ tiền phòng và dịch vụ của kỳ.",
      "CreatedAt": "2026-09-26T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_hd1_2026-10_paid",
      "InvoiceId": "nk_hd1_2026-10",
      "Amount": 3103500,
      "Method": "Transfer",
      "PaidDate": "2026-10-26",
      "Note": "Đã thanh toán đủ tiền phòng và dịch vụ của kỳ.",
      "CreatedAt": "2026-10-26T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_hd2_2026-09_paid",
      "InvoiceId": "nk_hd2_2026-09",
      "Amount": 2873500,
      "Method": "Transfer",
      "PaidDate": "2026-09-26",
      "Note": "Đã thanh toán đủ tiền phòng và dịch vụ của kỳ.",
      "CreatedAt": "2026-09-26T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_hd2_2026-10_part1",
      "InvoiceId": "nk_hd2_2026-10",
      "Amount": 500000,
      "Method": "Cash",
      "PaidDate": "2026-10-25",
      "Note": "Thanh toán đợt 1; còn công nợ để đối soát.",
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_hd2_2026-10_part2",
      "InvoiceId": "nk_hd2_2026-10",
      "Amount": 1600000,
      "Method": "Transfer",
      "PaidDate": "2026-10-26",
      "Note": "Thanh toán đợt 2; còn công nợ để đối soát.",
      "CreatedAt": "2026-10-26T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_hd3_2026-09_paid",
      "InvoiceId": "nk_hd3_2026-09",
      "Amount": 3472000,
      "Method": "Transfer",
      "PaidDate": "2026-09-26",
      "Note": "Đã thanh toán đủ tiền phòng và dịch vụ của kỳ.",
      "CreatedAt": "2026-09-26T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_hd4_2026-08_paid",
      "InvoiceId": "nk_hd4_2026-08",
      "Amount": 3292500,
      "Method": "Transfer",
      "PaidDate": "2026-08-26",
      "Note": "Đã thanh toán đủ tiền phòng và dịch vụ của kỳ.",
      "CreatedAt": "2026-08-26T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_hd4_2026-09_cash",
      "InvoiceId": "nk_hd4_2026-09",
      "Amount": 3092500,
      "Method": "Transfer",
      "PaidDate": "2026-09-29",
      "Note": "Thanh toán hóa đơn cuối, phần còn lại bù trừ từ cọc khi trả phòng.",
      "CreatedAt": "2026-09-29T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_hd4_2026-09_deposit",
      "InvoiceId": "nk_hd4_2026-09",
      "Amount": 200000,
      "Method": "Deposit",
      "PaidDate": "2026-09-30",
      "Note": "Bù trừ 200.000đ tiền cọc vào hóa đơn cuối.",
      "CreatedAt": "2026-09-30T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_hd1_2026-09_paid",
      "InvoiceId": "ta_hd1_2026-09",
      "Amount": 2789500,
      "Method": "Cash",
      "PaidDate": "2026-09-26",
      "Note": "Đã thanh toán đủ tiền phòng và dịch vụ của kỳ.",
      "CreatedAt": "2026-09-26T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_hd1_2026-10_paid",
      "InvoiceId": "ta_hd1_2026-10",
      "Amount": 2840000,
      "Method": "Cash",
      "PaidDate": "2026-10-26",
      "Note": "Đã thanh toán đủ tiền phòng và dịch vụ của kỳ.",
      "CreatedAt": "2026-10-26T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_hd2_2026-09_paid",
      "InvoiceId": "ta_hd2_2026-09",
      "Amount": 2610000,
      "Method": "Cash",
      "PaidDate": "2026-09-26",
      "Note": "Đã thanh toán đủ tiền phòng và dịch vụ của kỳ.",
      "CreatedAt": "2026-09-26T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_hd2_2026-10_part1",
      "InvoiceId": "ta_hd2_2026-10",
      "Amount": 500000,
      "Method": "Cash",
      "PaidDate": "2026-10-25",
      "Note": "Thanh toán đợt 1; còn công nợ để đối soát.",
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_hd2_2026-10_part2",
      "InvoiceId": "ta_hd2_2026-10",
      "Amount": 1300000,
      "Method": "Transfer",
      "PaidDate": "2026-10-26",
      "Note": "Thanh toán đợt 2; còn công nợ để đối soát.",
      "CreatedAt": "2026-10-26T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_hd3_2026-09_paid",
      "InvoiceId": "ta_hd3_2026-09",
      "Amount": 3208500,
      "Method": "Cash",
      "PaidDate": "2026-09-26",
      "Note": "Đã thanh toán đủ tiền phòng và dịch vụ của kỳ.",
      "CreatedAt": "2026-09-26T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_hd4_2026-08_paid",
      "InvoiceId": "ta_hd4_2026-08",
      "Amount": 3029000,
      "Method": "Cash",
      "PaidDate": "2026-08-26",
      "Note": "Đã thanh toán đủ tiền phòng và dịch vụ của kỳ.",
      "CreatedAt": "2026-08-26T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_hd4_2026-09_cash",
      "InvoiceId": "ta_hd4_2026-09",
      "Amount": 2829000,
      "Method": "Transfer",
      "PaidDate": "2026-09-29",
      "Note": "Thanh toán hóa đơn cuối, phần còn lại bù trừ từ cọc khi trả phòng.",
      "CreatedAt": "2026-09-29T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_hd4_2026-09_deposit",
      "InvoiceId": "ta_hd4_2026-09",
      "Amount": 200000,
      "Method": "Deposit",
      "PaidDate": "2026-09-30",
      "Note": "Bù trừ 200.000đ tiền cọc vào hóa đơn cuối.",
      "CreatedAt": "2026-09-30T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_hd1_2026-09_paid",
      "InvoiceId": "ck_hd1_2026-09",
      "Amount": 3302000,
      "Method": "Transfer",
      "PaidDate": "2026-09-26",
      "Note": "Đã thanh toán đủ tiền phòng và dịch vụ của kỳ.",
      "CreatedAt": "2026-09-26T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_hd1_2026-10_paid",
      "InvoiceId": "ck_hd1_2026-10",
      "Amount": 3352500,
      "Method": "Transfer",
      "PaidDate": "2026-10-26",
      "Note": "Đã thanh toán đủ tiền phòng và dịch vụ của kỳ.",
      "CreatedAt": "2026-10-26T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_hd2_2026-09_paid",
      "InvoiceId": "ck_hd2_2026-09",
      "Amount": 3122500,
      "Method": "Transfer",
      "PaidDate": "2026-09-26",
      "Note": "Đã thanh toán đủ tiền phòng và dịch vụ của kỳ.",
      "CreatedAt": "2026-09-26T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_hd2_2026-10_part1",
      "InvoiceId": "ck_hd2_2026-10",
      "Amount": 500000,
      "Method": "Cash",
      "PaidDate": "2026-10-25",
      "Note": "Thanh toán đợt 1; còn công nợ để đối soát.",
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_hd2_2026-10_part2",
      "InvoiceId": "ck_hd2_2026-10",
      "Amount": 1800000,
      "Method": "Transfer",
      "PaidDate": "2026-10-26",
      "Note": "Thanh toán đợt 2; còn công nợ để đối soát.",
      "CreatedAt": "2026-10-26T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_hd3_2026-09_paid",
      "InvoiceId": "ck_hd3_2026-09",
      "Amount": 3721000,
      "Method": "Transfer",
      "PaidDate": "2026-09-26",
      "Note": "Đã thanh toán đủ tiền phòng và dịch vụ của kỳ.",
      "CreatedAt": "2026-09-26T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_hd4_2026-08_paid",
      "InvoiceId": "ck_hd4_2026-08",
      "Amount": 3541500,
      "Method": "Transfer",
      "PaidDate": "2026-08-26",
      "Note": "Đã thanh toán đủ tiền phòng và dịch vụ của kỳ.",
      "CreatedAt": "2026-08-26T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_hd4_2026-09_cash",
      "InvoiceId": "ck_hd4_2026-09",
      "Amount": 3341500,
      "Method": "Transfer",
      "PaidDate": "2026-09-29",
      "Note": "Thanh toán hóa đơn cuối, phần còn lại bù trừ từ cọc khi trả phòng.",
      "CreatedAt": "2026-09-29T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_hd4_2026-09_deposit",
      "InvoiceId": "ck_hd4_2026-09",
      "Amount": 200000,
      "Method": "Deposit",
      "PaidDate": "2026-09-30",
      "Note": "Bù trừ 200.000đ tiền cọc vào hóa đơn cuối.",
      "CreatedAt": "2026-09-30T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_hd1_2026-09_paid",
      "InvoiceId": "bt_hd1_2026-09",
      "Amount": 2318500,
      "Method": "Cash",
      "PaidDate": "2026-09-26",
      "Note": "Đã thanh toán đủ tiền phòng và dịch vụ của kỳ.",
      "CreatedAt": "2026-09-26T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_hd1_2026-10_paid",
      "InvoiceId": "bt_hd1_2026-10",
      "Amount": 2369000,
      "Method": "Cash",
      "PaidDate": "2026-10-26",
      "Note": "Đã thanh toán đủ tiền phòng và dịch vụ của kỳ.",
      "CreatedAt": "2026-10-26T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_hd2_2026-09_paid",
      "InvoiceId": "bt_hd2_2026-09",
      "Amount": 2139000,
      "Method": "Cash",
      "PaidDate": "2026-09-26",
      "Note": "Đã thanh toán đủ tiền phòng và dịch vụ của kỳ.",
      "CreatedAt": "2026-09-26T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_hd2_2026-10_part1",
      "InvoiceId": "bt_hd2_2026-10",
      "Amount": 500000,
      "Method": "Cash",
      "PaidDate": "2026-10-25",
      "Note": "Thanh toán đợt 1; còn công nợ để đối soát.",
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_hd2_2026-10_part2",
      "InvoiceId": "bt_hd2_2026-10",
      "Amount": 800000,
      "Method": "Transfer",
      "PaidDate": "2026-10-26",
      "Note": "Thanh toán đợt 2; còn công nợ để đối soát.",
      "CreatedAt": "2026-10-26T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_hd3_2026-09_paid",
      "InvoiceId": "bt_hd3_2026-09",
      "Amount": 2737500,
      "Method": "Cash",
      "PaidDate": "2026-09-26",
      "Note": "Đã thanh toán đủ tiền phòng và dịch vụ của kỳ.",
      "CreatedAt": "2026-09-26T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_hd4_2026-08_paid",
      "InvoiceId": "bt_hd4_2026-08",
      "Amount": 2558000,
      "Method": "Cash",
      "PaidDate": "2026-08-26",
      "Note": "Đã thanh toán đủ tiền phòng và dịch vụ của kỳ.",
      "CreatedAt": "2026-08-26T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_hd4_2026-09_cash",
      "InvoiceId": "bt_hd4_2026-09",
      "Amount": 2358000,
      "Method": "Transfer",
      "PaidDate": "2026-09-29",
      "Note": "Thanh toán hóa đơn cuối, phần còn lại bù trừ từ cọc khi trả phòng.",
      "CreatedAt": "2026-09-29T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_hd4_2026-09_deposit",
      "InvoiceId": "bt_hd4_2026-09",
      "Amount": 200000,
      "Method": "Deposit",
      "PaidDate": "2026-09-30",
      "Note": "Bù trừ 200.000đ tiền cọc vào hóa đơn cuối.",
      "CreatedAt": "2026-09-30T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_hd1_2026-09_paid",
      "InvoiceId": "cr_hd1_2026-09",
      "Amount": 2731000,
      "Method": "Transfer",
      "PaidDate": "2026-09-26",
      "Note": "Đã thanh toán đủ tiền phòng và dịch vụ của kỳ.",
      "CreatedAt": "2026-09-26T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_hd1_2026-10_paid",
      "InvoiceId": "cr_hd1_2026-10",
      "Amount": 2781500,
      "Method": "Transfer",
      "PaidDate": "2026-10-26",
      "Note": "Đã thanh toán đủ tiền phòng và dịch vụ của kỳ.",
      "CreatedAt": "2026-10-26T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_hd2_2026-09_paid",
      "InvoiceId": "cr_hd2_2026-09",
      "Amount": 2551500,
      "Method": "Transfer",
      "PaidDate": "2026-09-26",
      "Note": "Đã thanh toán đủ tiền phòng và dịch vụ của kỳ.",
      "CreatedAt": "2026-09-26T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_hd2_2026-10_part1",
      "InvoiceId": "cr_hd2_2026-10",
      "Amount": 500000,
      "Method": "Cash",
      "PaidDate": "2026-10-25",
      "Note": "Thanh toán đợt 1; còn công nợ để đối soát.",
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_hd2_2026-10_part2",
      "InvoiceId": "cr_hd2_2026-10",
      "Amount": 1200000,
      "Method": "Transfer",
      "PaidDate": "2026-10-26",
      "Note": "Thanh toán đợt 2; còn công nợ để đối soát.",
      "CreatedAt": "2026-10-26T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_hd3_2026-09_paid",
      "InvoiceId": "cr_hd3_2026-09",
      "Amount": 3150000,
      "Method": "Transfer",
      "PaidDate": "2026-09-26",
      "Note": "Đã thanh toán đủ tiền phòng và dịch vụ của kỳ.",
      "CreatedAt": "2026-09-26T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_hd4_2026-08_paid",
      "InvoiceId": "cr_hd4_2026-08",
      "Amount": 2970500,
      "Method": "Transfer",
      "PaidDate": "2026-08-26",
      "Note": "Đã thanh toán đủ tiền phòng và dịch vụ của kỳ.",
      "CreatedAt": "2026-08-26T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_hd4_2026-09_cash",
      "InvoiceId": "cr_hd4_2026-09",
      "Amount": 2770500,
      "Method": "Transfer",
      "PaidDate": "2026-09-29",
      "Note": "Thanh toán hóa đơn cuối, phần còn lại bù trừ từ cọc khi trả phòng.",
      "CreatedAt": "2026-09-29T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_hd4_2026-09_deposit",
      "InvoiceId": "cr_hd4_2026-09",
      "Amount": 200000,
      "Method": "Deposit",
      "PaidDate": "2026-09-30",
      "Note": "Bù trừ 200.000đ tiền cọc vào hóa đơn cuối.",
      "CreatedAt": "2026-09-30T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_hd1_2026-09_paid",
      "InvoiceId": "om_hd1_2026-09",
      "Amount": 2167500,
      "Method": "Cash",
      "PaidDate": "2026-09-26",
      "Note": "Đã thanh toán đủ tiền phòng và dịch vụ của kỳ.",
      "CreatedAt": "2026-09-26T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_hd1_2026-10_paid",
      "InvoiceId": "om_hd1_2026-10",
      "Amount": 2218000,
      "Method": "Cash",
      "PaidDate": "2026-10-26",
      "Note": "Đã thanh toán đủ tiền phòng và dịch vụ của kỳ.",
      "CreatedAt": "2026-10-26T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_hd2_2026-09_paid",
      "InvoiceId": "om_hd2_2026-09",
      "Amount": 1988000,
      "Method": "Cash",
      "PaidDate": "2026-09-26",
      "Note": "Đã thanh toán đủ tiền phòng và dịch vụ của kỳ.",
      "CreatedAt": "2026-09-26T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_hd2_2026-10_part1",
      "InvoiceId": "om_hd2_2026-10",
      "Amount": 500000,
      "Method": "Cash",
      "PaidDate": "2026-10-25",
      "Note": "Thanh toán đợt 1; còn công nợ để đối soát.",
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_hd2_2026-10_part2",
      "InvoiceId": "om_hd2_2026-10",
      "Amount": 600000,
      "Method": "Transfer",
      "PaidDate": "2026-10-26",
      "Note": "Thanh toán đợt 2; còn công nợ để đối soát.",
      "CreatedAt": "2026-10-26T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_hd3_2026-09_paid",
      "InvoiceId": "om_hd3_2026-09",
      "Amount": 2586500,
      "Method": "Cash",
      "PaidDate": "2026-09-26",
      "Note": "Đã thanh toán đủ tiền phòng và dịch vụ của kỳ.",
      "CreatedAt": "2026-09-26T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_hd4_2026-08_paid",
      "InvoiceId": "om_hd4_2026-08",
      "Amount": 2407000,
      "Method": "Cash",
      "PaidDate": "2026-08-26",
      "Note": "Đã thanh toán đủ tiền phòng và dịch vụ của kỳ.",
      "CreatedAt": "2026-08-26T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_hd4_2026-09_cash",
      "InvoiceId": "om_hd4_2026-09",
      "Amount": 2207000,
      "Method": "Transfer",
      "PaidDate": "2026-09-29",
      "Note": "Thanh toán hóa đơn cuối, phần còn lại bù trừ từ cọc khi trả phòng.",
      "CreatedAt": "2026-09-29T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_hd4_2026-09_deposit",
      "InvoiceId": "om_hd4_2026-09",
      "Amount": 200000,
      "Method": "Deposit",
      "PaidDate": "2026-09-30",
      "Note": "Bù trừ 200.000đ tiền cọc vào hóa đơn cuối.",
      "CreatedAt": "2026-09-30T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    }
  ],
  "deposit_entries": [
    {
      "key": "nk_hd1_received",
      "ContractId": "nk_hd1",
      "Type": "Received",
      "Amount": 2600000,
      "Note": "Đã nhận đủ tiền cọc lúc nhận phòng.",
      "CreatedAt": "2026-09-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_hd2_received",
      "ContractId": "nk_hd2",
      "Type": "Received",
      "Amount": 1900000,
      "Note": "Đã nhận một phần tiền cọc, còn thiếu 500.000đ theo thỏa thuận.",
      "CreatedAt": "2026-09-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_hd3_received",
      "ContractId": "nk_hd3",
      "Type": "Received",
      "Amount": 2900000,
      "Note": "Đã nhận đủ tiền cọc lúc nhận phòng.",
      "CreatedAt": "2026-09-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_hd4_received",
      "ContractId": "nk_hd4",
      "Type": "Received",
      "Amount": 2700000,
      "Note": "Đã nhận đủ tiền cọc lúc nhận phòng.",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_hd4_Applied",
      "ContractId": "nk_hd4",
      "Type": "Applied",
      "Amount": 200000,
      "Note": "Bù trừ vào hóa đơn tháng 9; có payment Deposit tương ứng.",
      "CreatedAt": "2026-09-30T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_hd4_Deducted",
      "ContractId": "nk_hd4",
      "Type": "Deducted",
      "Amount": 150000,
      "Note": "Khấu trừ vệ sinh khi bàn giao, đã thống nhất với người thuê.",
      "CreatedAt": "2026-09-30T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_hd4_Refunded",
      "ContractId": "nk_hd4",
      "Type": "Refunded",
      "Amount": 2350000,
      "Note": "Hoàn phần cọc còn lại sau bù trừ và khấu trừ.",
      "CreatedAt": "2026-09-30T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_hd1_received",
      "ContractId": "ta_hd1",
      "Type": "Received",
      "Amount": 2300000,
      "Note": "Đã nhận đủ tiền cọc lúc nhận phòng.",
      "CreatedAt": "2026-09-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_hd2_received",
      "ContractId": "ta_hd2",
      "Type": "Received",
      "Amount": 1600000,
      "Note": "Đã nhận một phần tiền cọc, còn thiếu 500.000đ theo thỏa thuận.",
      "CreatedAt": "2026-09-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_hd3_received",
      "ContractId": "ta_hd3",
      "Type": "Received",
      "Amount": 2600000,
      "Note": "Đã nhận đủ tiền cọc lúc nhận phòng.",
      "CreatedAt": "2026-09-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_hd4_received",
      "ContractId": "ta_hd4",
      "Type": "Received",
      "Amount": 2400000,
      "Note": "Đã nhận đủ tiền cọc lúc nhận phòng.",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_hd4_Applied",
      "ContractId": "ta_hd4",
      "Type": "Applied",
      "Amount": 200000,
      "Note": "Bù trừ vào hóa đơn tháng 9; có payment Deposit tương ứng.",
      "CreatedAt": "2026-09-30T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_hd4_Deducted",
      "ContractId": "ta_hd4",
      "Type": "Deducted",
      "Amount": 150000,
      "Note": "Khấu trừ vệ sinh khi bàn giao, đã thống nhất với người thuê.",
      "CreatedAt": "2026-09-30T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_hd4_Refunded",
      "ContractId": "ta_hd4",
      "Type": "Refunded",
      "Amount": 2050000,
      "Note": "Hoàn phần cọc còn lại sau bù trừ và khấu trừ.",
      "CreatedAt": "2026-09-30T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_hd1_received",
      "ContractId": "ck_hd1",
      "Type": "Received",
      "Amount": 2800000,
      "Note": "Đã nhận đủ tiền cọc lúc nhận phòng.",
      "CreatedAt": "2026-09-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_hd2_received",
      "ContractId": "ck_hd2",
      "Type": "Received",
      "Amount": 2100000,
      "Note": "Đã nhận một phần tiền cọc, còn thiếu 500.000đ theo thỏa thuận.",
      "CreatedAt": "2026-09-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_hd3_received",
      "ContractId": "ck_hd3",
      "Type": "Received",
      "Amount": 3100000,
      "Note": "Đã nhận đủ tiền cọc lúc nhận phòng.",
      "CreatedAt": "2026-09-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_hd4_received",
      "ContractId": "ck_hd4",
      "Type": "Received",
      "Amount": 2900000,
      "Note": "Đã nhận đủ tiền cọc lúc nhận phòng.",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_hd4_Applied",
      "ContractId": "ck_hd4",
      "Type": "Applied",
      "Amount": 200000,
      "Note": "Bù trừ vào hóa đơn tháng 9; có payment Deposit tương ứng.",
      "CreatedAt": "2026-09-30T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_hd4_Deducted",
      "ContractId": "ck_hd4",
      "Type": "Deducted",
      "Amount": 150000,
      "Note": "Khấu trừ vệ sinh khi bàn giao, đã thống nhất với người thuê.",
      "CreatedAt": "2026-09-30T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_hd4_Refunded",
      "ContractId": "ck_hd4",
      "Type": "Refunded",
      "Amount": 2550000,
      "Note": "Hoàn phần cọc còn lại sau bù trừ và khấu trừ.",
      "CreatedAt": "2026-09-30T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_hd1_received",
      "ContractId": "bt_hd1",
      "Type": "Received",
      "Amount": 1800000,
      "Note": "Đã nhận đủ tiền cọc lúc nhận phòng.",
      "CreatedAt": "2026-09-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_hd2_received",
      "ContractId": "bt_hd2",
      "Type": "Received",
      "Amount": 1100000,
      "Note": "Đã nhận một phần tiền cọc, còn thiếu 500.000đ theo thỏa thuận.",
      "CreatedAt": "2026-09-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_hd3_received",
      "ContractId": "bt_hd3",
      "Type": "Received",
      "Amount": 2100000,
      "Note": "Đã nhận đủ tiền cọc lúc nhận phòng.",
      "CreatedAt": "2026-09-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_hd4_received",
      "ContractId": "bt_hd4",
      "Type": "Received",
      "Amount": 1900000,
      "Note": "Đã nhận đủ tiền cọc lúc nhận phòng.",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_hd4_Applied",
      "ContractId": "bt_hd4",
      "Type": "Applied",
      "Amount": 200000,
      "Note": "Bù trừ vào hóa đơn tháng 9; có payment Deposit tương ứng.",
      "CreatedAt": "2026-09-30T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_hd4_Deducted",
      "ContractId": "bt_hd4",
      "Type": "Deducted",
      "Amount": 150000,
      "Note": "Khấu trừ vệ sinh khi bàn giao, đã thống nhất với người thuê.",
      "CreatedAt": "2026-09-30T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_hd4_Refunded",
      "ContractId": "bt_hd4",
      "Type": "Refunded",
      "Amount": 1550000,
      "Note": "Hoàn phần cọc còn lại sau bù trừ và khấu trừ.",
      "CreatedAt": "2026-09-30T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_hd1_received",
      "ContractId": "cr_hd1",
      "Type": "Received",
      "Amount": 2200000,
      "Note": "Đã nhận đủ tiền cọc lúc nhận phòng.",
      "CreatedAt": "2026-09-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_hd2_received",
      "ContractId": "cr_hd2",
      "Type": "Received",
      "Amount": 1500000,
      "Note": "Đã nhận một phần tiền cọc, còn thiếu 500.000đ theo thỏa thuận.",
      "CreatedAt": "2026-09-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_hd3_received",
      "ContractId": "cr_hd3",
      "Type": "Received",
      "Amount": 2500000,
      "Note": "Đã nhận đủ tiền cọc lúc nhận phòng.",
      "CreatedAt": "2026-09-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_hd4_received",
      "ContractId": "cr_hd4",
      "Type": "Received",
      "Amount": 2300000,
      "Note": "Đã nhận đủ tiền cọc lúc nhận phòng.",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_hd4_Applied",
      "ContractId": "cr_hd4",
      "Type": "Applied",
      "Amount": 200000,
      "Note": "Bù trừ vào hóa đơn tháng 9; có payment Deposit tương ứng.",
      "CreatedAt": "2026-09-30T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_hd4_Deducted",
      "ContractId": "cr_hd4",
      "Type": "Deducted",
      "Amount": 150000,
      "Note": "Khấu trừ vệ sinh khi bàn giao, đã thống nhất với người thuê.",
      "CreatedAt": "2026-09-30T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_hd4_Refunded",
      "ContractId": "cr_hd4",
      "Type": "Refunded",
      "Amount": 1950000,
      "Note": "Hoàn phần cọc còn lại sau bù trừ và khấu trừ.",
      "CreatedAt": "2026-09-30T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_hd1_received",
      "ContractId": "om_hd1",
      "Type": "Received",
      "Amount": 1600000,
      "Note": "Đã nhận đủ tiền cọc lúc nhận phòng.",
      "CreatedAt": "2026-09-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_hd2_received",
      "ContractId": "om_hd2",
      "Type": "Received",
      "Amount": 900000,
      "Note": "Đã nhận một phần tiền cọc, còn thiếu 500.000đ theo thỏa thuận.",
      "CreatedAt": "2026-09-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_hd3_received",
      "ContractId": "om_hd3",
      "Type": "Received",
      "Amount": 1900000,
      "Note": "Đã nhận đủ tiền cọc lúc nhận phòng.",
      "CreatedAt": "2026-09-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_hd4_received",
      "ContractId": "om_hd4",
      "Type": "Received",
      "Amount": 1700000,
      "Note": "Đã nhận đủ tiền cọc lúc nhận phòng.",
      "CreatedAt": "2026-08-01T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_hd4_Applied",
      "ContractId": "om_hd4",
      "Type": "Applied",
      "Amount": 200000,
      "Note": "Bù trừ vào hóa đơn tháng 9; có payment Deposit tương ứng.",
      "CreatedAt": "2026-09-30T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_hd4_Deducted",
      "ContractId": "om_hd4",
      "Type": "Deducted",
      "Amount": 150000,
      "Note": "Khấu trừ vệ sinh khi bàn giao, đã thống nhất với người thuê.",
      "CreatedAt": "2026-09-30T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_hd4_Refunded",
      "ContractId": "om_hd4",
      "Type": "Refunded",
      "Amount": 1350000,
      "Note": "Hoàn phần cọc còn lại sau bù trừ và khấu trừ.",
      "CreatedAt": "2026-09-30T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    }
  ],
  "incidents": [
    {
      "key": "nk_sc1",
      "RoomId": "nk_p1",
      "ReportedByTenantId": "nk_t1",
      "Description": "Vòi rửa chén nhỏ nước liên tục, nhờ quản lý kiểm tra giúp vào buổi chiều.",
      "Status": "Open",
      "Resolution": "",
      "Cost": 0,
      "CreatedAt": "2026-10-24T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_sc2",
      "RoomId": "nk_p2",
      "ReportedByTenantId": "nk_t3",
      "Description": "Ổ điện cạnh bàn làm việc chập chờn khi cắm quạt.",
      "Status": "InProgress",
      "Resolution": "Đã ngắt ổ điện lỗi, hẹn thợ thay ổ vào chiều 28/10.",
      "Cost": 0,
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_sc3",
      "RoomId": "nk_p3",
      "ReportedByTenantId": "nk_t4",
      "Description": "Khóa cửa phòng khó xoay, cần kiểm tra ổ khóa.",
      "Status": "Resolved",
      "Resolution": "Đã vệ sinh, tra dầu và thay ruột khóa; người thuê xác nhận dùng bình thường.",
      "Cost": 120000,
      "CreatedAt": "2026-10-20T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "nk_sc6",
      "RoomId": "nk_p6",
      "ReportedByTenantId": null,
      "Description": "Kiểm tra chống thấm và thay vòi sen trước khi cho thuê lại.",
      "Status": "InProgress",
      "Resolution": "Đã xử lý chống thấm, chờ kiểm tra khô tường trước khi mở phòng.",
      "Cost": 450000,
      "CreatedAt": "2026-10-22T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_sc1",
      "RoomId": "ta_p1",
      "ReportedByTenantId": "ta_t1",
      "Description": "Vòi rửa chén nhỏ nước liên tục, nhờ quản lý kiểm tra giúp vào buổi chiều.",
      "Status": "Open",
      "Resolution": "",
      "Cost": 0,
      "CreatedAt": "2026-10-24T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_sc2",
      "RoomId": "ta_p2",
      "ReportedByTenantId": "ta_t3",
      "Description": "Ổ điện cạnh bàn làm việc chập chờn khi cắm quạt.",
      "Status": "InProgress",
      "Resolution": "Đã ngắt ổ điện lỗi, hẹn thợ thay ổ vào chiều 28/10.",
      "Cost": 0,
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_sc3",
      "RoomId": "ta_p3",
      "ReportedByTenantId": "ta_t4",
      "Description": "Khóa cửa phòng khó xoay, cần kiểm tra ổ khóa.",
      "Status": "Resolved",
      "Resolution": "Đã vệ sinh, tra dầu và thay ruột khóa; người thuê xác nhận dùng bình thường.",
      "Cost": 120000,
      "CreatedAt": "2026-10-20T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ta_sc6",
      "RoomId": "ta_p6",
      "ReportedByTenantId": null,
      "Description": "Kiểm tra chống thấm và thay vòi sen trước khi cho thuê lại.",
      "Status": "InProgress",
      "Resolution": "Đã xử lý chống thấm, chờ kiểm tra khô tường trước khi mở phòng.",
      "Cost": 450000,
      "CreatedAt": "2026-10-22T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_sc1",
      "RoomId": "ck_p1",
      "ReportedByTenantId": "ck_t1",
      "Description": "Vòi rửa chén nhỏ nước liên tục, nhờ quản lý kiểm tra giúp vào buổi chiều.",
      "Status": "Open",
      "Resolution": "",
      "Cost": 0,
      "CreatedAt": "2026-10-24T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_sc2",
      "RoomId": "ck_p2",
      "ReportedByTenantId": "ck_t3",
      "Description": "Ổ điện cạnh bàn làm việc chập chờn khi cắm quạt.",
      "Status": "InProgress",
      "Resolution": "Đã ngắt ổ điện lỗi, hẹn thợ thay ổ vào chiều 28/10.",
      "Cost": 0,
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_sc3",
      "RoomId": "ck_p3",
      "ReportedByTenantId": "ck_t4",
      "Description": "Khóa cửa phòng khó xoay, cần kiểm tra ổ khóa.",
      "Status": "Resolved",
      "Resolution": "Đã vệ sinh, tra dầu và thay ruột khóa; người thuê xác nhận dùng bình thường.",
      "Cost": 120000,
      "CreatedAt": "2026-10-20T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "ck_sc6",
      "RoomId": "ck_p6",
      "ReportedByTenantId": null,
      "Description": "Kiểm tra chống thấm và thay vòi sen trước khi cho thuê lại.",
      "Status": "InProgress",
      "Resolution": "Đã xử lý chống thấm, chờ kiểm tra khô tường trước khi mở phòng.",
      "Cost": 450000,
      "CreatedAt": "2026-10-22T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_sc1",
      "RoomId": "bt_p1",
      "ReportedByTenantId": "bt_t1",
      "Description": "Vòi rửa chén nhỏ nước liên tục, nhờ quản lý kiểm tra giúp vào buổi chiều.",
      "Status": "Open",
      "Resolution": "",
      "Cost": 0,
      "CreatedAt": "2026-10-24T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_sc2",
      "RoomId": "bt_p2",
      "ReportedByTenantId": "bt_t3",
      "Description": "Ổ điện cạnh bàn làm việc chập chờn khi cắm quạt.",
      "Status": "InProgress",
      "Resolution": "Đã ngắt ổ điện lỗi, hẹn thợ thay ổ vào chiều 28/10.",
      "Cost": 0,
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_sc3",
      "RoomId": "bt_p3",
      "ReportedByTenantId": "bt_t4",
      "Description": "Khóa cửa phòng khó xoay, cần kiểm tra ổ khóa.",
      "Status": "Resolved",
      "Resolution": "Đã vệ sinh, tra dầu và thay ruột khóa; người thuê xác nhận dùng bình thường.",
      "Cost": 120000,
      "CreatedAt": "2026-10-20T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "bt_sc6",
      "RoomId": "bt_p6",
      "ReportedByTenantId": null,
      "Description": "Kiểm tra chống thấm và thay vòi sen trước khi cho thuê lại.",
      "Status": "InProgress",
      "Resolution": "Đã xử lý chống thấm, chờ kiểm tra khô tường trước khi mở phòng.",
      "Cost": 450000,
      "CreatedAt": "2026-10-22T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_sc1",
      "RoomId": "cr_p1",
      "ReportedByTenantId": "cr_t1",
      "Description": "Vòi rửa chén nhỏ nước liên tục, nhờ quản lý kiểm tra giúp vào buổi chiều.",
      "Status": "Open",
      "Resolution": "",
      "Cost": 0,
      "CreatedAt": "2026-10-24T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_sc2",
      "RoomId": "cr_p2",
      "ReportedByTenantId": "cr_t3",
      "Description": "Ổ điện cạnh bàn làm việc chập chờn khi cắm quạt.",
      "Status": "InProgress",
      "Resolution": "Đã ngắt ổ điện lỗi, hẹn thợ thay ổ vào chiều 28/10.",
      "Cost": 0,
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_sc3",
      "RoomId": "cr_p3",
      "ReportedByTenantId": "cr_t4",
      "Description": "Khóa cửa phòng khó xoay, cần kiểm tra ổ khóa.",
      "Status": "Resolved",
      "Resolution": "Đã vệ sinh, tra dầu và thay ruột khóa; người thuê xác nhận dùng bình thường.",
      "Cost": 120000,
      "CreatedAt": "2026-10-20T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "cr_sc6",
      "RoomId": "cr_p6",
      "ReportedByTenantId": null,
      "Description": "Kiểm tra chống thấm và thay vòi sen trước khi cho thuê lại.",
      "Status": "InProgress",
      "Resolution": "Đã xử lý chống thấm, chờ kiểm tra khô tường trước khi mở phòng.",
      "Cost": 450000,
      "CreatedAt": "2026-10-22T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_sc1",
      "RoomId": "om_p1",
      "ReportedByTenantId": "om_t1",
      "Description": "Vòi rửa chén nhỏ nước liên tục, nhờ quản lý kiểm tra giúp vào buổi chiều.",
      "Status": "Open",
      "Resolution": "",
      "Cost": 0,
      "CreatedAt": "2026-10-24T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_sc2",
      "RoomId": "om_p2",
      "ReportedByTenantId": "om_t3",
      "Description": "Ổ điện cạnh bàn làm việc chập chờn khi cắm quạt.",
      "Status": "InProgress",
      "Resolution": "Đã ngắt ổ điện lỗi, hẹn thợ thay ổ vào chiều 28/10.",
      "Cost": 0,
      "CreatedAt": "2026-10-25T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_sc3",
      "RoomId": "om_p3",
      "ReportedByTenantId": "om_t4",
      "Description": "Khóa cửa phòng khó xoay, cần kiểm tra ổ khóa.",
      "Status": "Resolved",
      "Resolution": "Đã vệ sinh, tra dầu và thay ruột khóa; người thuê xác nhận dùng bình thường.",
      "Cost": 120000,
      "CreatedAt": "2026-10-20T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    },
    {
      "key": "om_sc6",
      "RoomId": "om_p6",
      "ReportedByTenantId": null,
      "Description": "Kiểm tra chống thấm và thay vòi sen trước khi cho thuê lại.",
      "Status": "InProgress",
      "Resolution": "Đã xử lý chống thấm, chờ kiểm tra khô tường trước khi mở phòng.",
      "Cost": 450000,
      "CreatedAt": "2026-10-22T02:00:00Z",
      "CreatedBy": "cantho-demo-v1",
      "IsArchived": false
    }
  ]
}$ct_data$::jsonb;
  rec jsonb; new_id integer;
BEGIN
  IF EXISTS (SELECT 1 FROM audit_entries WHERE "Action" = 'demo.cantho.2026-10.v1') THEN
    RAISE NOTICE 'Bộ dữ liệu Cần Thơ này đã được nạp; bỏ qua, không ghi đè.';
    RETURN;
  END IF;
  IF EXISTS (SELECT 1 FROM users u JOIN jsonb_array_elements(dataset->'users') d ON lower(u."Username") = lower(d->>'Username')) THEN
    RAISE EXCEPTION 'Tên đăng nhập CT đã tồn tại; không sửa dữ liệu cũ. Kiểm tra danh sách tài khoản trước khi nạp.';
  END IF;
  IF EXISTS (SELECT 1 FROM branches b JOIN jsonb_array_elements(dataset->'branches') d ON b."Name" = d->>'Name') THEN
    RAISE EXCEPTION 'Tên khu trọ mẫu CT đã tồn tại; không ghép nhầm vào khu cũ. Kiểm tra database trước khi nạp.';
  END IF;
  -- branches: 6 dòng.
  FOR rec IN SELECT value FROM jsonb_array_elements(dataset->'branches') LOOP
    INSERT INTO "branches" ("Name", "Address", "CreatedAt", "CreatedBy", "IsArchived")
    SELECT x."Name", x."Address", x."CreatedAt", x."CreatedBy", x."IsArchived" FROM jsonb_populate_record(NULL::"branches", (rec - 'key')) x RETURNING "Id" INTO new_id;
    INSERT INTO ct_seed_ids VALUES ('branches', rec->>'key', new_id);
  END LOOP;
  -- rooms: 36 dòng.
  FOR rec IN SELECT value FROM jsonb_array_elements(dataset->'rooms') LOOP
    INSERT INTO "rooms" ("BranchId", "Name", "Price", "Capacity", "IsMaintenance", "Description", "Area", "Floor", "RoomType", "Amenities", "AmenitiesConfirmed", "ToiletType", "AccessHours", "LaundryType", "ParkingType", "MaxVehicles", "PetsAllowed", "ElectricVehiclesAllowed", "HasWindow", "HasBalcony", "SuggestedDeposit", "MinimumLeaseMonths", "Neighborhood", "RentalConditions", "ContactName", "ContactPhone", "CreatedAt", "CreatedBy", "IsArchived")
    SELECT x."BranchId", x."Name", x."Price", x."Capacity", x."IsMaintenance", x."Description", x."Area", x."Floor", x."RoomType", x."Amenities", x."AmenitiesConfirmed", x."ToiletType", x."AccessHours", x."LaundryType", x."ParkingType", x."MaxVehicles", x."PetsAllowed", x."ElectricVehiclesAllowed", x."HasWindow", x."HasBalcony", x."SuggestedDeposit", x."MinimumLeaseMonths", x."Neighborhood", x."RentalConditions", x."ContactName", x."ContactPhone", x."CreatedAt", x."CreatedBy", x."IsArchived" FROM jsonb_populate_record(NULL::"rooms", (rec - 'key') || jsonb_build_object('BranchId', (SELECT actual_id FROM ct_seed_ids WHERE entity = 'branches' AND seed_key = rec->>'BranchId'))) x RETURNING "Id" INTO new_id;
    INSERT INTO ct_seed_ids VALUES ('rooms', rec->>'key', new_id);
  END LOOP;
  -- tenants: 42 dòng.
  FOR rec IN SELECT value FROM jsonb_array_elements(dataset->'tenants') LOOP
    INSERT INTO "tenants" ("BranchId", "FullName", "Phone", "IdentityNumber", "Address", "CreatedAt", "CreatedBy", "IsArchived")
    SELECT x."BranchId", x."FullName", x."Phone", x."IdentityNumber", x."Address", x."CreatedAt", x."CreatedBy", x."IsArchived" FROM jsonb_populate_record(NULL::"tenants", (rec - 'key') || jsonb_build_object('BranchId', (SELECT actual_id FROM ct_seed_ids WHERE entity = 'branches' AND seed_key = rec->>'BranchId'))) x RETURNING "Id" INTO new_id;
    INSERT INTO ct_seed_ids VALUES ('tenants', rec->>'key', new_id);
  END LOOP;
  -- users: 49 dòng.
  FOR rec IN SELECT value FROM jsonb_array_elements(dataset->'users') LOOP
    INSERT INTO "users" ("Username", "FullName", "PasswordHash", "Role", "IsActive", "TenantId", "CreatedAt", "CreatedBy", "IsArchived")
    SELECT x."Username", x."FullName", x."PasswordHash", x."Role", x."IsActive", x."TenantId", x."CreatedAt", x."CreatedBy", x."IsArchived" FROM jsonb_populate_record(NULL::"users", (rec - 'key') || jsonb_build_object('TenantId', (SELECT actual_id FROM ct_seed_ids WHERE entity = 'tenants' AND seed_key = rec->>'TenantId'))) x RETURNING "Id" INTO new_id;
    INSERT INTO ct_seed_ids VALUES ('users', rec->>'key', new_id);
  END LOOP;
  -- user_branches: 9 dòng.
  FOR rec IN SELECT value FROM jsonb_array_elements(dataset->'user_branches') LOOP
    INSERT INTO "user_branches" ("UserId", "BranchId")
    SELECT x."UserId", x."BranchId" FROM jsonb_populate_record(NULL::"user_branches", (rec - 'key') || jsonb_build_object('UserId', (SELECT actual_id FROM ct_seed_ids WHERE entity = 'users' AND seed_key = rec->>'UserId'), 'BranchId', (SELECT actual_id FROM ct_seed_ids WHERE entity = 'branches' AND seed_key = rec->>'BranchId'))) x;
  END LOOP;
  -- fees: 24 dòng.
  FOR rec IN SELECT value FROM jsonb_array_elements(dataset->'fees') LOOP
    INSERT INTO "fees" ("BranchId", "Name", "Method", "UnitPrice", "CreatedAt", "CreatedBy", "IsArchived")
    SELECT x."BranchId", x."Name", x."Method", x."UnitPrice", x."CreatedAt", x."CreatedBy", x."IsArchived" FROM jsonb_populate_record(NULL::"fees", (rec - 'key') || jsonb_build_object('BranchId', (SELECT actual_id FROM ct_seed_ids WHERE entity = 'branches' AND seed_key = rec->>'BranchId'))) x RETURNING "Id" INTO new_id;
    INSERT INTO ct_seed_ids VALUES ('fees', rec->>'key', new_id);
  END LOOP;
  -- contracts: 24 dòng.
  FOR rec IN SELECT value FROM jsonb_array_elements(dataset->'contracts') LOOP
    INSERT INTO "contracts" ("RoomId", "StartDate", "EndDate", "ClosedDate", "Rent", "Deposit", "Status", "Note", "CreatedAt", "CreatedBy", "IsArchived")
    SELECT x."RoomId", x."StartDate", x."EndDate", x."ClosedDate", x."Rent", x."Deposit", x."Status", x."Note", x."CreatedAt", x."CreatedBy", x."IsArchived" FROM jsonb_populate_record(NULL::"contracts", (rec - 'key') || jsonb_build_object('RoomId', (SELECT actual_id FROM ct_seed_ids WHERE entity = 'rooms' AND seed_key = rec->>'RoomId'))) x RETURNING "Id" INTO new_id;
    INSERT INTO ct_seed_ids VALUES ('contracts', rec->>'key', new_id);
  END LOOP;
  -- contract_tenants: 36 dòng.
  FOR rec IN SELECT value FROM jsonb_array_elements(dataset->'contract_tenants') LOOP
    INSERT INTO "contract_tenants" ("ContractId", "TenantId", "IsRepresentative")
    SELECT x."ContractId", x."TenantId", x."IsRepresentative" FROM jsonb_populate_record(NULL::"contract_tenants", (rec - 'key') || jsonb_build_object('ContractId', (SELECT actual_id FROM ct_seed_ids WHERE entity = 'contracts' AND seed_key = rec->>'ContractId'), 'TenantId', (SELECT actual_id FROM ct_seed_ids WHERE entity = 'tenants' AND seed_key = rec->>'TenantId'))) x;
  END LOOP;
  -- readings: 48 dòng.
  FOR rec IN SELECT value FROM jsonb_array_elements(dataset->'readings') LOOP
    INSERT INTO "readings" ("ContractId", "Year", "Month", "ElectricityOld", "ElectricityNew", "WaterOld", "WaterNew", "CreatedAt", "CreatedBy", "IsArchived")
    SELECT x."ContractId", x."Year", x."Month", x."ElectricityOld", x."ElectricityNew", x."WaterOld", x."WaterNew", x."CreatedAt", x."CreatedBy", x."IsArchived" FROM jsonb_populate_record(NULL::"readings", (rec - 'key') || jsonb_build_object('ContractId', (SELECT actual_id FROM ct_seed_ids WHERE entity = 'contracts' AND seed_key = rec->>'ContractId'))) x RETURNING "Id" INTO new_id;
    INSERT INTO ct_seed_ids VALUES ('readings', rec->>'key', new_id);
  END LOOP;
  -- invoices: 54 dòng.
  FOR rec IN SELECT value FROM jsonb_array_elements(dataset->'invoices') LOOP
    INSERT INTO "invoices" ("ContractId", "Year", "Month", "DueDate", "Total", "Status", "CancellationReason", "CreatedAt", "CreatedBy", "IsArchived")
    SELECT x."ContractId", x."Year", x."Month", x."DueDate", x."Total", x."Status", x."CancellationReason", x."CreatedAt", x."CreatedBy", x."IsArchived" FROM jsonb_populate_record(NULL::"invoices", (rec - 'key') || jsonb_build_object('ContractId', (SELECT actual_id FROM ct_seed_ids WHERE entity = 'contracts' AND seed_key = rec->>'ContractId'))) x RETURNING "Id" INTO new_id;
    INSERT INTO ct_seed_ids VALUES ('invoices', rec->>'key', new_id);
  END LOOP;
  -- invoice_items: 270 dòng.
  FOR rec IN SELECT value FROM jsonb_array_elements(dataset->'invoice_items') LOOP
    INSERT INTO "invoice_items" ("InvoiceId", "Description", "Quantity", "UnitPrice", "Amount")
    SELECT x."InvoiceId", x."Description", x."Quantity", x."UnitPrice", x."Amount" FROM jsonb_populate_record(NULL::"invoice_items", (rec - 'key') || jsonb_build_object('InvoiceId', (SELECT actual_id FROM ct_seed_ids WHERE entity = 'invoices' AND seed_key = rec->>'InvoiceId'))) x RETURNING "Id" INTO new_id;
    INSERT INTO ct_seed_ids VALUES ('invoice_items', rec->>'key', new_id);
  END LOOP;
  -- payments: 54 dòng.
  FOR rec IN SELECT value FROM jsonb_array_elements(dataset->'payments') LOOP
    INSERT INTO "payments" ("InvoiceId", "Amount", "Method", "PaidDate", "Note", "CreatedAt", "CreatedBy", "IsArchived")
    SELECT x."InvoiceId", x."Amount", x."Method", x."PaidDate", x."Note", x."CreatedAt", x."CreatedBy", x."IsArchived" FROM jsonb_populate_record(NULL::"payments", (rec - 'key') || jsonb_build_object('InvoiceId', (SELECT actual_id FROM ct_seed_ids WHERE entity = 'invoices' AND seed_key = rec->>'InvoiceId'))) x RETURNING "Id" INTO new_id;
    INSERT INTO ct_seed_ids VALUES ('payments', rec->>'key', new_id);
  END LOOP;
  -- deposit_entries: 42 dòng.
  FOR rec IN SELECT value FROM jsonb_array_elements(dataset->'deposit_entries') LOOP
    INSERT INTO "deposit_entries" ("ContractId", "Type", "Amount", "Note", "CreatedAt", "CreatedBy", "IsArchived")
    SELECT x."ContractId", x."Type", x."Amount", x."Note", x."CreatedAt", x."CreatedBy", x."IsArchived" FROM jsonb_populate_record(NULL::"deposit_entries", (rec - 'key') || jsonb_build_object('ContractId', (SELECT actual_id FROM ct_seed_ids WHERE entity = 'contracts' AND seed_key = rec->>'ContractId'))) x RETURNING "Id" INTO new_id;
    INSERT INTO ct_seed_ids VALUES ('deposit_entries', rec->>'key', new_id);
  END LOOP;
  -- incidents: 24 dòng.
  FOR rec IN SELECT value FROM jsonb_array_elements(dataset->'incidents') LOOP
    INSERT INTO "incidents" ("RoomId", "ReportedByTenantId", "Description", "Status", "Resolution", "Cost", "CreatedAt", "CreatedBy", "IsArchived")
    SELECT x."RoomId", x."ReportedByTenantId", x."Description", x."Status", x."Resolution", x."Cost", x."CreatedAt", x."CreatedBy", x."IsArchived" FROM jsonb_populate_record(NULL::"incidents", (rec - 'key') || jsonb_build_object('RoomId', (SELECT actual_id FROM ct_seed_ids WHERE entity = 'rooms' AND seed_key = rec->>'RoomId'), 'ReportedByTenantId', (SELECT actual_id FROM ct_seed_ids WHERE entity = 'tenants' AND seed_key = rec->>'ReportedByTenantId'))) x RETURNING "Id" INTO new_id;
    INSERT INTO ct_seed_ids VALUES ('incidents', rec->>'key', new_id);
  END LOOP;
  INSERT INTO audit_entries ("Action", "Detail", "CreatedAt", "CreatedBy", "IsArchived") VALUES ('demo.cantho.2026-10.v1', 'Nạp dữ liệu hư cấu Cần Thơ: 6 khu, 36 phòng, 42 hồ sơ, 7 Manager, 42 Tenant; kỳ 08–10/2026.', NOW(), 'cantho-demo-v1', false);
  RAISE NOTICE 'Đã nạp xong bộ dữ liệu mẫu Cần Thơ.';
END
$ct_seed$;
COMMIT;

-- Kiểm tra tài khoản vừa nạp (không xuất hash mật khẩu):
SELECT "Username", "FullName", "Role", "IsActive" FROM users WHERE "CreatedBy" = 'cantho-demo-v1' ORDER BY "Role", "Username";
