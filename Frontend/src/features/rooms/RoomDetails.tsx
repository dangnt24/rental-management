import { useCallback, useState } from "react";
import {
  MapPin,
  Copy,
  Check,
  Phone,
  Maximize2,
  Layers,
  Users,
  Banknote,
  Building2,
  Clock,
  Bike,
  Droplets,
  Zap,
  Wifi,
  ReceiptText,
  CircleHelp,
} from "lucide-react";
import type { Row } from "../../shared/types";
import { money } from "../../shared/formatters";
import { roomAmenities, roomTypeLabels, sharingLabels } from "./roomMetadata";
import { RoomPhotoViewer } from "./RoomPhotoViewer";

const unknown = "Chưa cập nhật";
const booleanLabel = (value: boolean | null | undefined) =>
  value == null ? unknown : value ? "Có" : "Không";
const feeUnit: Record<string, string> = {
  Electricity: "/kWh",
  Water: "/m³",
  PerPerson: "/người/tháng",
  Fixed: "/phòng/tháng",
};

export function RoomDetails({
  room,
  photoUrl,
}: {
  room: Row;
  photoUrl: (id: number) => string;
}) {
  const [copied, setCopied] = useState("");
  const [photo, setPhoto] = useState<number | null>(null);
  const [viewingPhotos, setViewingPhotos] = useState(false);
  const closePhotos = useCallback(() => setViewingPhotos(false), []);
  const photos: Row[] = [...(room.photos || [])].sort(
    (a, b) => (a.sortOrder ?? 0) - (b.sortOrder ?? 0) || a.id - b.id,
  );
  const amenities: string[] = room.amenities || [];
  const fees: Row[] = [...(room.fees || [])];
  for (const [name, matches] of [
    [
      "Điện",
      (fee: Row) => fee.method === "Electricity" || /điện/i.test(fee.name),
    ],
    ["Nước", (fee: Row) => fee.method === "Water" || /nước/i.test(fee.name)],
    ["Wifi", (fee: Row) => /wifi|internet/i.test(fee.name)],
    ["Giữ xe", (fee: Row) => /xe|parking/i.test(fee.name)],
  ] as [string, (fee: Row) => boolean][]) {
    if (!fees.some(matches)) fees.push({ name, unitPrice: null });
  }
  const facts = [
    ["Nhà vệ sinh", sharingLabels[room.toiletType] || unknown],
    ["Giờ giấc", room.accessHours || unknown],
    ["Máy giặt", sharingLabels[room.laundryType] || unknown],
    ["Cửa sổ", booleanLabel(room.hasWindow)],
    ["Ban công", booleanLabel(room.hasBalcony)],
    ["Thú cưng", booleanLabel(room.petsAllowed)],
    ["Chỗ để xe", sharingLabels[room.parkingType] || unknown],
    ["Xe điện", booleanLabel(room.electricVehiclesAllowed)],
  ];
  async function copy() {
    try {
      await navigator.clipboard.writeText(
        [
          `DVP Home · Phòng ${room.name} · ${room.branch?.name || ""}`,
          room.branch?.address || "",
          `Giá niêm yết: ${money(room.price)}/tháng`,
          `Loại phòng: ${roomTypeLabels[room.roomType] || unknown}`,
          `Cọc tham khảo: ${room.suggestedDeposit != null ? money(room.suggestedDeposit) : unknown} · Thuê tối thiểu: ${room.minimumLeaseMonths != null ? `${room.minimumLeaseMonths} tháng` : unknown} · Số xe tối đa: ${room.maxVehicles ?? unknown}`,
          `Diện tích: ${room.area != null ? `${room.area} m²` : unknown} · Vị trí: ${room.floor || unknown} · Tối đa ${room.capacity} người`,
          `Tiện nghi: ${
            room.amenitiesConfirmed
              ? roomAmenities
                  .filter((item) => amenities.includes(item.value))
                  .map((item) => item.label)
                  .join(", ") || "Không có trong danh sách"
              : unknown
          }`,
          ...fees.map(
            (fee) =>
              `${fee.name}: ${fee.unitPrice == null ? "Chưa công bố" : fee.unitPrice === 0 ? "Miễn phí" : money(fee.unitPrice) + (feeUnit[fee.method] || "")}`,
          ),
          ...facts.map(([key, value]) => `${key}: ${value}`),
          room.rentalConditions,
          room.description,
          room.neighborhood,
          room.contactPhone
            ? `Liên hệ: ${room.contactName || "Quản lý"} · ${room.contactPhone}`
            : "",
        ]
          .filter(Boolean)
          .join("\n"),
      );
      setCopied("Đã sao chép thông tin phòng.");
    } catch {
      setCopied(
        "Trình duyệt chưa cho phép sao chép. Bạn có thể chọn nội dung để sao chép thủ công.",
      );
    }
  }
  return (
    <div className="room-detail-view">
      <div className="room-detail-photo">
        {photos.length ? (
          <button
            type="button"
            className="room-photo-expand"
            aria-label={`Phóng to ảnh phòng ${room.name}`}
            onClick={() => setViewingPhotos(true)}
          >
            <img
              src={photoUrl(photo || photos[0].id)}
              alt={`Phòng ${room.name}`}
            />
            <span>
              <Maximize2 size={17} /> Bấm để xem ảnh lớn · {photos.length} ảnh
            </span>
          </button>
        ) : (
          <div className="room-photo-placeholder">
            <Building2 size={64} />
            <span>Ảnh phòng chưa được cập nhật</span>
          </div>
        )}
        {photos.length > 1 && (
          <div className="room-photo-thumbnails">
            {photos.map((item, index) => (
              <button
                type="button"
                key={item.id}
                aria-label={`Xem ảnh phòng ${index + 1}`}
                aria-pressed={(photo || photos[0].id) === item.id}
                onClick={() => {
                  setPhoto(item.id);
                  setViewingPhotos(true);
                }}
              >
                <img src={photoUrl(item.id)} alt={`Ảnh ${index + 1}`} />
              </button>
            ))}
          </div>
        )}
      </div>
      {viewingPhotos && photos.length > 0 && (
        <RoomPhotoViewer
          roomName={room.name}
          photos={photos}
          activeId={photo || photos[0].id}
          photoUrl={photoUrl}
          select={setPhoto}
          close={closePhotos}
        />
      )}
      <section className="room-detail-section">
        <div className="room-detail-heading">
          <div>
            <span className="eyebrow">{room.branch?.name}</span>
            <h2>Thông tin cơ bản</h2>
          </div>
          <button type="button" className="text-button" onClick={copy}>
            <Copy size={16} />
            Sao chép
          </button>
        </div>
        <p className="room-detail-address">
          <MapPin size={18} />
          <span>{room.branch?.address || unknown}</span>
        </p>
        {copied && (
          <p className="room-copy-status" role="status">
            {copied}
          </p>
        )}
        <div className="room-facts-grid">
          {[
            {
              label: "Giá niêm yết / tháng",
              value: money(room.price),
              icon: Banknote,
            },
            {
              label: "Diện tích",
              value:
                room.area != null
                  ? `${Number(room.area).toLocaleString("vi-VN")} m²`
                  : unknown,
              icon: Maximize2,
            },
            {
              label: "Tầng / vị trí",
              value: room.floor || unknown,
              icon: Layers,
            },
            {
              label: "Số người tối đa",
              value: `${room.capacity} người`,
              icon: Users,
            },
          ].map(({ label, value, icon: Icon }) => (
            <div key={label}>
              <Icon size={19} />
              <span>{label}</span>
              <strong>{value}</strong>
            </div>
          ))}
        </div>
      </section>
      <section className="room-detail-section">
        <div className="room-detail-heading">
          <h2>Tiện nghi đi kèm</h2>
          <span>
            {room.amenitiesConfirmed
              ? "Theo thông tin quản lý cung cấp"
              : "Danh sách chưa được xác nhận"}
          </span>
        </div>
        <div className="room-amenities">
          {roomAmenities.map(({ value, label, icon: Icon }) => {
            const included = amenities.includes(value);
            return (
              <div
                className={
                  room.amenitiesConfirmed
                    ? included
                      ? "included"
                      : "not-included"
                    : "unconfirmed"
                }
                key={value}
              >
                <Icon size={21} />
                <div>
                  <strong>{label}</strong>
                  <small>
                    {room.amenitiesConfirmed
                      ? included
                        ? "Có sẵn"
                        : "Không có sẵn"
                      : "Chưa xác nhận"}
                  </small>
                </div>
                {room.amenitiesConfirmed && included ? (
                  <Check size={15} />
                ) : !room.amenitiesConfirmed ? (
                  <CircleHelp size={15} />
                ) : null}
              </div>
            );
          })}
        </div>
      </section>
      <section className="room-detail-section">
        <h2>Chi phí & điều kiện thuê</h2>
        <p className="room-section-caption">
          Đơn giá hiện tại của khu trọ. Hóa đơn tính theo chỉ số, số người hoặc
          số phòng tương ứng.
        </p>
        <div className="room-costs-grid">
          {fees.map((fee, index) => {
            const Icon =
              fee.method === "Electricity"
                ? Zap
                : fee.method === "Water"
                  ? Droplets
                  : /wifi|internet/i.test(fee.name)
                    ? Wifi
                    : /xe|parking/i.test(fee.name)
                      ? Bike
                      : ReceiptText;
            return (
              <div key={index}>
                <Icon size={21} />
                <span>{fee.name}</span>
                <strong>
                  {fee.unitPrice == null
                    ? "Chưa công bố"
                    : fee.unitPrice === 0
                      ? "Miễn phí"
                      : money(fee.unitPrice)}
                  {fee.unitPrice > 0 && <small>{feeUnit[fee.method]}</small>}
                </strong>
              </div>
            );
          })}
        </div>
        <dl className="room-conditions">
          <div>
            <dt>
              <Banknote size={17} />
              Cọc tham khảo
            </dt>
            <dd>
              {room.suggestedDeposit != null
                ? money(room.suggestedDeposit)
                : unknown}
            </dd>
          </div>
          <div>
            <dt>
              <Clock size={17} />
              Thuê tối thiểu
            </dt>
            <dd>
              {room.minimumLeaseMonths != null
                ? `${room.minimumLeaseMonths} tháng`
                : unknown}
            </dd>
          </div>
          <div>
            <dt>
              <Bike size={17} />
              Số xe tối đa
            </dt>
            <dd>
              {room.maxVehicles != null
                ? `${room.maxVehicles} xe/phòng`
                : unknown}
            </dd>
          </div>
        </dl>
        <p className="room-detail-note">
          Giá thuê và tiền cọc thực tế theo hợp đồng. Khoản chưa công bố cần
          được xác nhận trước khi nhận phòng.
        </p>
        {room.rentalConditions && (
          <p className="room-description room-rental-conditions">
            {room.rentalConditions}
          </p>
        )}
      </section>
      <section className="room-detail-section">
        <div className="room-detail-heading">
          <h2>Thông tin chi tiết</h2>
          <span>
            {roomTypeLabels[room.roomType] || "Chưa cập nhật loại phòng"}
          </span>
        </div>
        <dl className="room-detail-facts">
          {facts.map(([label, value]) => (
            <div key={label}>
              <dt>{label}</dt>
              <dd>{value}</dd>
            </div>
          ))}
        </dl>
      </section>
      <section className="room-detail-section">
        <h2>Mô tả phòng</h2>
        <p className="room-description">
          {room.description || "Chưa có mô tả bổ sung."}
        </p>
      </section>
      <section className="room-detail-section">
        <h2>Di chuyển & tiện ích xung quanh</h2>
        <p className="room-description">
          {room.neighborhood ||
            "Quản lý chưa cập nhật thông tin khu vực xung quanh."}
        </p>
      </section>
      <section className="room-detail-contact">
        <div>
          <h3>Liên hệ về phòng này</h3>
          <p>
            {room.contactName ||
              "Quản lý chưa cập nhật người liên hệ công khai."}
          </p>
        </div>
        {room.contactPhone ? (
          <a
            className="button"
            href={`tel:${room.contactPhone.replace(/[^+0-9]/g, "")}`}
          >
            <Phone size={17} />
            {room.contactPhone}
          </a>
        ) : (
          <span>Chưa công bố số điện thoại</span>
        )}
      </section>
    </div>
  );
}
