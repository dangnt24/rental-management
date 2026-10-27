-- Bổ sung chi tiết HƯ CẤU cho 36 phòng của bộ CT đã nạp bản cũ. Chạy sau 05_room_details.sql.
-- Không sửa giá phòng, hợp đồng, thanh toán hoặc thông tin chi tiết quản lý đã nhập.
-- Chỉ cập nhật phòng/khu có CreatedBy=cantho-demo-v1 và TOÀN BỘ chi tiết đang trống. Chạy lại không reset dữ liệu.
BEGIN;
SELECT pg_advisory_xact_lock(hashtext('demo.cantho.room-details.v1'));
DO $ct_details$
DECLARE rec jsonb; changed integer; total integer := 0;
BEGIN
IF EXISTS(SELECT 1 FROM audit_entries WHERE "Action"='demo.cantho.room-details.v1') THEN RETURN; END IF;
FOR rec IN SELECT value FROM jsonb_array_elements($ct_room_data$[
  {
    "branchName": "DVP Ninh Kiều - Khu trọ mẫu CT",
    "roomName": "P.101",
    "details": {
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
      "ContactPhone": ""
    }
  },
  {
    "branchName": "DVP Ninh Kiều - Khu trọ mẫu CT",
    "roomName": "P.102",
    "details": {
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
      "ContactPhone": ""
    }
  },
  {
    "branchName": "DVP Ninh Kiều - Khu trọ mẫu CT",
    "roomName": "P.103",
    "details": {
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
      "ContactPhone": ""
    }
  },
  {
    "branchName": "DVP Ninh Kiều - Khu trọ mẫu CT",
    "roomName": "P.104",
    "details": {
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
      "ContactPhone": ""
    }
  },
  {
    "branchName": "DVP Ninh Kiều - Khu trọ mẫu CT",
    "roomName": "P.105",
    "details": {
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
      "ContactPhone": ""
    }
  },
  {
    "branchName": "DVP Ninh Kiều - Khu trọ mẫu CT",
    "roomName": "P.106",
    "details": {
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
      "ContactPhone": ""
    }
  },
  {
    "branchName": "DVP Tân An - Khu trọ mẫu CT",
    "roomName": "P.101",
    "details": {
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
      "ContactPhone": ""
    }
  },
  {
    "branchName": "DVP Tân An - Khu trọ mẫu CT",
    "roomName": "P.102",
    "details": {
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
      "ContactPhone": ""
    }
  },
  {
    "branchName": "DVP Tân An - Khu trọ mẫu CT",
    "roomName": "P.103",
    "details": {
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
      "ContactPhone": ""
    }
  },
  {
    "branchName": "DVP Tân An - Khu trọ mẫu CT",
    "roomName": "P.104",
    "details": {
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
      "ContactPhone": ""
    }
  },
  {
    "branchName": "DVP Tân An - Khu trọ mẫu CT",
    "roomName": "P.105",
    "details": {
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
      "ContactPhone": ""
    }
  },
  {
    "branchName": "DVP Tân An - Khu trọ mẫu CT",
    "roomName": "P.106",
    "details": {
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
      "ContactPhone": ""
    }
  },
  {
    "branchName": "DVP Cái Khế - Khu trọ mẫu CT",
    "roomName": "P.101",
    "details": {
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
      "ContactPhone": ""
    }
  },
  {
    "branchName": "DVP Cái Khế - Khu trọ mẫu CT",
    "roomName": "P.102",
    "details": {
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
      "ContactPhone": ""
    }
  },
  {
    "branchName": "DVP Cái Khế - Khu trọ mẫu CT",
    "roomName": "P.103",
    "details": {
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
      "ContactPhone": ""
    }
  },
  {
    "branchName": "DVP Cái Khế - Khu trọ mẫu CT",
    "roomName": "P.104",
    "details": {
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
      "ContactPhone": ""
    }
  },
  {
    "branchName": "DVP Cái Khế - Khu trọ mẫu CT",
    "roomName": "P.105",
    "details": {
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
      "ContactPhone": ""
    }
  },
  {
    "branchName": "DVP Cái Khế - Khu trọ mẫu CT",
    "roomName": "P.106",
    "details": {
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
      "ContactPhone": ""
    }
  },
  {
    "branchName": "DVP Bình Thủy - Khu trọ mẫu CT",
    "roomName": "P.101",
    "details": {
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
      "ContactPhone": ""
    }
  },
  {
    "branchName": "DVP Bình Thủy - Khu trọ mẫu CT",
    "roomName": "P.102",
    "details": {
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
      "ContactPhone": ""
    }
  },
  {
    "branchName": "DVP Bình Thủy - Khu trọ mẫu CT",
    "roomName": "P.103",
    "details": {
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
      "ContactPhone": ""
    }
  },
  {
    "branchName": "DVP Bình Thủy - Khu trọ mẫu CT",
    "roomName": "P.104",
    "details": {
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
      "ContactPhone": ""
    }
  },
  {
    "branchName": "DVP Bình Thủy - Khu trọ mẫu CT",
    "roomName": "P.105",
    "details": {
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
      "ContactPhone": ""
    }
  },
  {
    "branchName": "DVP Bình Thủy - Khu trọ mẫu CT",
    "roomName": "P.106",
    "details": {
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
      "ContactPhone": ""
    }
  },
  {
    "branchName": "DVP Cái Răng - Khu trọ mẫu CT",
    "roomName": "P.101",
    "details": {
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
      "ContactPhone": ""
    }
  },
  {
    "branchName": "DVP Cái Răng - Khu trọ mẫu CT",
    "roomName": "P.102",
    "details": {
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
      "ContactPhone": ""
    }
  },
  {
    "branchName": "DVP Cái Răng - Khu trọ mẫu CT",
    "roomName": "P.103",
    "details": {
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
      "ContactPhone": ""
    }
  },
  {
    "branchName": "DVP Cái Răng - Khu trọ mẫu CT",
    "roomName": "P.104",
    "details": {
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
      "ContactPhone": ""
    }
  },
  {
    "branchName": "DVP Cái Răng - Khu trọ mẫu CT",
    "roomName": "P.105",
    "details": {
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
      "ContactPhone": ""
    }
  },
  {
    "branchName": "DVP Cái Răng - Khu trọ mẫu CT",
    "roomName": "P.106",
    "details": {
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
      "ContactPhone": ""
    }
  },
  {
    "branchName": "DVP Ô Môn - Khu trọ mẫu CT",
    "roomName": "P.101",
    "details": {
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
      "ContactPhone": ""
    }
  },
  {
    "branchName": "DVP Ô Môn - Khu trọ mẫu CT",
    "roomName": "P.102",
    "details": {
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
      "ContactPhone": ""
    }
  },
  {
    "branchName": "DVP Ô Môn - Khu trọ mẫu CT",
    "roomName": "P.103",
    "details": {
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
      "ContactPhone": ""
    }
  },
  {
    "branchName": "DVP Ô Môn - Khu trọ mẫu CT",
    "roomName": "P.104",
    "details": {
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
      "ContactPhone": ""
    }
  },
  {
    "branchName": "DVP Ô Môn - Khu trọ mẫu CT",
    "roomName": "P.105",
    "details": {
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
      "ContactPhone": ""
    }
  },
  {
    "branchName": "DVP Ô Môn - Khu trọ mẫu CT",
    "roomName": "P.106",
    "details": {
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
      "ContactPhone": ""
    }
  }
]$ct_room_data$::jsonb) LOOP
UPDATE rooms r SET "Area"=d."Area", "Floor"=d."Floor", "RoomType"=d."RoomType", "Amenities"=d."Amenities", "AmenitiesConfirmed"=d."AmenitiesConfirmed", "ToiletType"=d."ToiletType", "AccessHours"=d."AccessHours", "LaundryType"=d."LaundryType", "ParkingType"=d."ParkingType", "MaxVehicles"=d."MaxVehicles", "PetsAllowed"=d."PetsAllowed", "ElectricVehiclesAllowed"=d."ElectricVehiclesAllowed", "HasWindow"=d."HasWindow", "HasBalcony"=d."HasBalcony", "SuggestedDeposit"=d."SuggestedDeposit", "MinimumLeaseMonths"=d."MinimumLeaseMonths", "Neighborhood"=d."Neighborhood", "RentalConditions"=d."RentalConditions", "ContactName"=d."ContactName", "ContactPhone"=d."ContactPhone"
FROM branches b, jsonb_populate_record(NULL::rooms, rec->'details') d
WHERE r."BranchId"=b."Id" AND r."CreatedBy"='cantho-demo-v1' AND b."CreatedBy"='cantho-demo-v1' AND b."Name"=rec->>'branchName' AND r."Name"=rec->>'roomName' AND r."Area" IS NULL AND r."Floor"='' AND r."RoomType"='' AND cardinality(r."Amenities")=0 AND NOT r."AmenitiesConfirmed" AND r."ToiletType"='' AND r."AccessHours"='' AND r."LaundryType"='' AND r."ParkingType"='' AND r."MaxVehicles" IS NULL AND r."PetsAllowed" IS NULL AND r."ElectricVehiclesAllowed" IS NULL AND r."HasWindow" IS NULL AND r."HasBalcony" IS NULL AND r."SuggestedDeposit" IS NULL AND r."MinimumLeaseMonths" IS NULL AND r."Neighborhood"='' AND r."RentalConditions"='' AND r."ContactName"='' AND r."ContactPhone"='';
GET DIAGNOSTICS changed = ROW_COUNT; total := total + changed;
END LOOP;
INSERT INTO audit_entries ("Action","Detail","CreatedAt","CreatedBy","IsArchived") VALUES ('demo.cantho.room-details.v1','Bổ sung thông tin phòng mẫu CT: ' || total || ' phòng; không thay đổi hồ sơ đã nhập.',NOW(),'cantho-demo-v1',false);
RAISE NOTICE 'Đã bổ sung chi tiết cho % phòng mẫu CT.', total;
END
$ct_details$;
COMMIT;
