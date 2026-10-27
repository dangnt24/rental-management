export const money = (value: number) =>
  new Intl.NumberFormat("vi-VN", {
    style: "currency",
    currency: "VND",
    maximumFractionDigits: 0,
  }).format(value || 0);

export const date = (value: string) =>
  value
    ? new Date(value.slice(0, 10) + "T12:00:00").toLocaleDateString("vi-VN")
    : "—";

export const code = (prefix: string, id: number) =>
  `${prefix}-${String(id).padStart(4, "0")}`;
