import {
  BedDouble,
  Sofa,
  Shirt,
  ArrowUpDown,
  Wifi,
  AirVent,
  CookingPot,
  Flame,
  Refrigerator,
  Layers,
} from "lucide-react";

export const roomAmenities = [
  { value: "Bed", label: "Giường", icon: BedDouble },
  { value: "Mattress", label: "Nệm", icon: Sofa },
  { value: "Wardrobe", label: "Tủ quần áo", icon: Shirt },
  { value: "Elevator", label: "Thang máy", icon: ArrowUpDown },
  { value: "Wifi", label: "Wifi", icon: Wifi },
  { value: "AirConditioner", label: "Máy lạnh", icon: AirVent },
  { value: "Kitchen", label: "Khu bếp", icon: CookingPot },
  { value: "WaterHeater", label: "Nước nóng", icon: Flame },
  { value: "Refrigerator", label: "Tủ lạnh", icon: Refrigerator },
  { value: "Mezzanine", label: "Gác lửng", icon: Layers },
];
export const roomTypeLabels: Record<string, string> = {
  Room: "Phòng thường",
  Studio: "Studio",
  Apartment: "Căn hộ mini",
};
export const sharingLabels: Record<string, string> = {
  Private: "Riêng",
  Shared: "Dùng chung",
  None: "Không có",
};
export const roomDetailKeys = [
  "area",
  "floor",
  "roomType",
  "amenities",
  "amenitiesConfirmed",
  "toiletType",
  "accessHours",
  "laundryType",
  "parkingType",
  "maxVehicles",
  "petsAllowed",
  "electricVehiclesAllowed",
  "hasWindow",
  "hasBalcony",
  "suggestedDeposit",
  "minimumLeaseMonths",
  "neighborhood",
  "rentalConditions",
  "contactName",
  "contactPhone",
];
