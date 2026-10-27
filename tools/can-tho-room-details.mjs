// Thông tin mô phỏng cho các phòng CT; không phải xác minh tiện ích thực tế.
export function canThoRoomDetails(area, roomNumber, price) {
  return {
    Area: [0, 22, 18, 26, 24, 20, 22][roomNumber],
    Floor: [3, 5].includes(roomNumber) ? "Tầng 1" : "Trệt",
    RoomType: "Room",
    Amenities: [
      "Wifi",
      "Kitchen",
      ...([1, 3, 4].includes(roomNumber)
        ? ["Mezzanine", "Wardrobe"]
        : ["Bed", "Mattress"]),
      ...(roomNumber === 4 ? ["AirConditioner", "WaterHeater"] : []),
    ],
    AmenitiesConfirmed: true,
    ToiletType: "Private",
    AccessHours:
      "Tự do; giữ yên tĩnh sau 22:00, báo quản lý khi có khách ở lại (quy định mẫu).",
    LaundryType: "Shared",
    ParkingType: "Shared",
    MaxVehicles: roomNumber === 3 ? 3 : 2,
    PetsAllowed: roomNumber === 5,
    ElectricVehiclesAllowed: false,
    HasWindow: true,
    HasBalcony: roomNumber === 3,
    SuggestedDeposit: price,
    MinimumLeaseMonths: roomNumber === 2 ? 3 : 6,
    Neighborhood: `Khu vực ${area.oldArea}, phường ${area.ward}, TP. Cần Thơ. Mô tả mẫu: kết nối ${area.street}, có nhu cầu ăn uống, mua sắm và đi học/đi làm trong khu vực. Chưa khảo sát khoảng cách hoặc thời gian di chuyển thực tế.`,
    RentalConditions:
      "Dữ liệu giả lập phục vụ demo. Tiền thuê tính đủ tháng. Điện, nước, internet và vệ sinh theo đơn giá được công bố của khu. Phí giữ xe và giặt sấy chưa công bố, cần xác nhận trước khi nhận phòng. Báo trước khi trả phòng theo thỏa thuận trong hợp đồng.",
    ContactName: `Ban quản lý DVP ${area.ward} (mẫu)`,
    ContactPhone: "",
  };
}
