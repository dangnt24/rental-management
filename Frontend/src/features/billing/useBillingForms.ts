import { code } from "../../shared/formatters";
import { api } from "../../shared/api";
import { options, dateField } from "../../shared/forms";
import { useWorkspace } from "../../app/WorkspaceContext";

export function useBillingForms() {
  const {
    contracts,
    year,
    month,
    all,
    setForm,
    contractRoom,
    representative,
    today,
  } = useWorkspace();
  function readingForm() {
    const active = contracts.filter((x) => x.status === "Active");
    const first = active[0];
    const defaults = (
      id: number,
      selectedYear = year,
      selectedMonth = month,
    ) => {
      const existing = all("readings").find(
        (x) =>
          x.contractId === id &&
          x.year === selectedYear &&
          x.month === selectedMonth,
      );
      if (existing)
        return {
          electricityOld: existing.electricityOld,
          electricityNew: existing.electricityNew,
          waterOld: existing.waterOld,
          waterNew: existing.waterNew,
        };
      const r = all("readings").find(
        (x) =>
          x.contractId === id &&
          x.year * 12 + x.month < selectedYear * 12 + selectedMonth,
      );
      return {
        electricityOld: r?.electricityNew || 0,
        electricityNew: r?.electricityNew || 0,
        waterOld: r?.waterNew || 0,
        waterNew: r?.waterNew || 0,
      };
    };
    setForm({
      title: "Chốt chỉ số điện nước",
      description:
        "Chỉ số cũ phải khớp lần ghi trước. Kỳ đã có hóa đơn sẽ bị khóa. Nhập lại cùng kỳ để cập nhật trước khi xuất hóa đơn.",
      fields: [
        {
          key: "contractId",
          label: "Hợp đồng / phòng",
          type: "number",
          options: options(
            active,
            (x) => `${contractRoom(x.id)} · ${code("HĐ", x.id)}`,
          ),
        },
        { key: "month", label: "Tháng", type: "number", min: 1, max: 12 },
        { key: "year", label: "Năm", type: "number", min: 2000, max: 2100 },
        ...["electricityOld", "electricityNew", "waterOld", "waterNew"].map(
          (key, i) => ({
            key,
            label: [
              "Điện cũ (kWh)",
              "Điện mới (kWh)",
              "Nước cũ (m³)",
              "Nước mới (m³)",
            ][i],
            type: "number",
            step: "0.001",
          }),
        ),
      ],
      initial: {
        contractId: first?.id || "",
        month,
        year,
        ...defaults(first?.id),
      },
      onChange: (key, value, v) =>
        ["contractId", "year", "month"].includes(key)
          ? { ...v, ...defaults(v.contractId, v.year, v.month) }
          : v,
      submit: (v) => api("/readings", "POST", v),
    });
  }

  function invoiceForm() {
    setForm({
      title: "Lập hóa đơn tháng",
      description:
        "Chốt điện nước trước, sau đó lập hóa đơn. Đơn giá được lưu theo thời điểm lập; không thể lập trùng kỳ.",
      fields: [
        {
          key: "contractId",
          label: "Hợp đồng / phòng",
          type: "number",
          options: options(
            contracts.filter((x) => x.status === "Active"),
            (x) => `${contractRoom(x.id)} · ${representative(x.id)}`,
          ),
        },
        { key: "month", label: "Tháng thu", type: "number", min: 1, max: 12 },
        { key: "year", label: "Năm", type: "number", min: 2000, max: 2100 },
        dateField("dueDate", "Hạn thanh toán"),
      ],
      initial: {
        contractId: contracts.find((x) => x.status === "Active")?.id || "",
        month,
        year,
        dueDate: today,
      },
      submit: (v) => api("/invoices", "POST", v),
    });
  }
  return { readingForm, invoiceForm };
}
