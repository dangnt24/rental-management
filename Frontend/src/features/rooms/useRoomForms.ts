import type { Row, Field } from "../../shared/types";
import { api } from "../../shared/api";
import { amountField } from "../../shared/forms";
import { useWorkspace } from "../../app/WorkspaceContext";
import {
  roomAmenities,
  roomDetailKeys,
  roomTypeLabels,
  sharingLabels,
} from "./roomMetadata";

const choices = (labels: Record<string, string>) =>
  Object.entries(labels).map(([value, label]) => ({ value, label }));
const optionalNumber = (
  key: string,
  label: string,
  max: number,
  min = 0,
): Field => ({
  key,
  label,
  type: "number",
  min,
  max,
  required: false,
  hint: "Để trống nếu chưa xác nhận.",
});
const yesNo = (key: string, label: string): Field => ({
  key,
  label,
  options: [
    { value: "true", label: "Có / Cho phép" },
    { value: "false", label: "Không / Không cho phép" },
  ],
  required: false,
});

export function useRoomForms() {
  const { setForm, branchField, defaultBranch } = useWorkspace();
  function editRoom(row?: Row) {
    const initial: Row = {
      branchId: defaultBranch,
      name: "",
      price: 3000000,
      capacity: 2,
      isMaintenance: false,
      description: "",
      ...row,
    };
    for (const key of roomDetailKeys)
      initial[key] =
        row?.[key] ??
        (key === "amenities" ? [] : key === "amenitiesConfirmed" ? false : "");
    for (const key of [
      "petsAllowed",
      "electricVehiclesAllowed",
      "hasWindow",
      "hasBalcony",
    ])
      initial[key] = row?.[key] == null ? "" : String(row[key]);
    setForm({
      title: row ? "Chỉnh sửa phòng" : "Thêm phòng trọ",
      wide: true,
      description:
        "Thông tin dưới đây hiển thị cho người tìm phòng và người thuê liên quan. Để trống thông tin chưa xác nhận; đơn giá dịch vụ lấy từ Thiết lập của khu trọ.",
      fields: [
        { ...branchField, section: "Thông tin cơ bản" },
        { key: "name", label: "Tên / số phòng" },
        amountField("price", "Giá thuê niêm yết (đ/tháng)"),
        {
          key: "capacity",
          label: "Sức chứa (người)",
          type: "number",
          min: 1,
          max: 50,
        },
        {
          ...optionalNumber("area", "Diện tích (m²)", 5000, 0.001),
          step: "0.001",
        },
        {
          key: "floor",
          label: "Tầng / vị trí",
          required: false,
          hint: "Ví dụ: Trệt, tầng 1, tầng 2.",
        },
        {
          key: "roomType",
          label: "Loại phòng",
          options: choices(roomTypeLabels),
          required: false,
        },
        {
          key: "isMaintenance",
          label: "Phòng đang sửa",
          type: "checkbox",
          required: false,
        },
        {
          key: "amenitiesConfirmed",
          section: "Tiện nghi có sẵn",
          label: "Đã xác nhận danh sách tiện nghi của phòng",
          type: "checkbox",
          required: false,
          hint: "Chọn mục này và để trống danh sách nếu phòng không có các tiện nghi bên dưới.",
        },
        {
          key: "amenities",
          label: "Tiện nghi đi kèm",
          type: "checklist",
          valueType: "string",
          options: roomAmenities.map(({ value, label }) => ({ value, label })),
          required: false,
          hint: "Chỉ chọn đồ có sẵn và bàn giao cho người thuê.",
        },
        {
          key: "toiletType",
          section: "Sinh hoạt & quy định",
          label: "Nhà vệ sinh",
          options: choices({ Private: "Riêng", Shared: "Dùng chung" }),
          required: false,
        },
        {
          key: "accessHours",
          label: "Giờ giấc ra vào",
          required: false,
          hint: "Ví dụ: Tự do; khóa cổng 23:00, báo quản lý khi về muộn.",
        },
        {
          key: "laundryType",
          label: "Máy giặt",
          options: choices(sharingLabels),
          required: false,
        },
        {
          key: "parkingType",
          label: "Chỗ để xe",
          options: choices(sharingLabels),
          required: false,
        },
        optionalNumber("maxVehicles", "Số xe tối đa / phòng", 50),
        yesNo("hasWindow", "Cửa sổ"),
        yesNo("hasBalcony", "Ban công"),
        yesNo("petsAllowed", "Cho phép thú cưng"),
        yesNo("electricVehiclesAllowed", "Cho phép xe điện"),
        {
          ...optionalNumber(
            "suggestedDeposit",
            "Cọc tham khảo (đ)",
            1000000000,
          ),
          section: "Chi phí & điều kiện thuê",
          hint: "Chỉ để giới thiệu. Tiền cọc thực tế vẫn ghi theo hợp đồng.",
        },
        optionalNumber("minimumLeaseMonths", "Thuê tối thiểu (tháng)", 120, 1),
        {
          key: "rentalConditions",
          label: "Điều kiện & lưu ý chi phí",
          type: "textarea",
          required: false,
          hint: "Nêu rõ phí xe, giặt sấy hoặc chi phí khác nếu có; quy định khách đến chơi, báo trước khi trả phòng…",
        },
        {
          key: "description",
          section: "Mô tả & khu vực",
          label: "Mô tả phòng",
          type: "textarea",
          required: false,
        },
        {
          key: "neighborhood",
          label: "Di chuyển & tiện ích xung quanh",
          type: "textarea",
          required: false,
          hint: "Ghi địa điểm thực tế; thời gian di chuyển chỉ nên là ước tính.",
        },
        {
          key: "contactName",
          section: "Liên hệ công khai",
          label: "Tên người tiếp nhận",
          required: false,
        },
        {
          key: "contactPhone",
          label: "Điện thoại liên hệ công khai",
          type: "tel",
          required: false,
          hint: "Số này sẽ hiển thị trên trang tìm phòng. Không dùng số riêng nếu không muốn công khai.",
        },
      ],
      initial,
      onChange: (key, value, values) =>
        key === "amenities" && value.length
          ? { ...values, amenitiesConfirmed: true }
          : key === "amenitiesConfirmed" && !value
            ? { ...values, amenities: [] }
            : key === "parkingType" && value === "None"
              ? { ...values, maxVehicles: 0 }
              : values,
      submit: (values) => {
        const details = Object.fromEntries(
          roomDetailKeys.map((key) => [key, values[key]]),
        );
        for (const key of [
          "area",
          "maxVehicles",
          "suggestedDeposit",
          "minimumLeaseMonths",
        ])
          details[key] = details[key] === "" ? null : Number(details[key]);
        for (const key of [
          "petsAllowed",
          "electricVehiclesAllowed",
          "hasWindow",
          "hasBalcony",
        ])
          details[key] = details[key] === "" ? null : details[key] === "true";
        return api("/rooms" + (row ? "/" + row.id : ""), row ? "PUT" : "POST", {
          branchId: values.branchId,
          name: values.name,
          price: values.price,
          capacity: values.capacity,
          isMaintenance: values.isMaintenance,
          description: values.description,
          details,
        });
      },
    });
  }
  return { editRoom };
}
