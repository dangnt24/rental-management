import type { Row } from "../../shared/types";
import { money } from "../../shared/formatters";
import { api } from "../../shared/api";
import { options, amountField, dateField } from "../../shared/forms";
import { useWorkspace } from "../../app/WorkspaceContext";

export function useContractForms() {
  const { rooms, tenants, all, setForm, branchName, today, year } =
    useWorkspace();
  function editContract() {
    const available = rooms.filter((x) => x.status === "Available");
    const selectable = tenants.filter(
      (t) =>
        !all("contractTenants").some(
          (ct) =>
            ct.tenantId === t.id &&
            all("contracts").some(
              (c) => c.id === ct.contractId && c.status === "Active",
            ),
        ),
    );
    setForm({
      title: "Lập hợp đồng thuê phòng",
      description:
        "Cho thuê nguyên phòng. Chọn người ở cùng và một người đại diện. Tiền thuê tháng đầu/cuối tính đủ tháng.",
      fields: [
        {
          key: "roomId",
          label: "Phòng còn trống",
          type: "number",
          options: options(
            available,
            (x) => `${x.name} · ${branchName(x.branchId)}`,
          ),
        },
        dateField("startDate", "Ngày nhận phòng"),
        dateField("endDate", "Ngày kết thúc"),
        amountField("rent", "Giá thuê thỏa thuận (đ)"),
        amountField("deposit", "Tiền cọc thỏa thuận (đ)"),
        amountField("depositReceived", "Cọc thực tế đã nhận (đ)"),
        {
          key: "tenantIds",
          label: "Danh sách người ở",
          type: "multi",
          options: options(
            selectable,
            (x) => `${x.fullName} · ${branchName(x.branchId)}`,
          ),
          hint: "Giữ Ctrl để chọn nhiều người. Người thuê phải cùng khu với phòng.",
        },
        {
          key: "representativeId",
          label: "Người đại diện hợp đồng",
          type: "number",
          options: options(selectable, (x) => x.fullName),
        },
        { key: "note", label: "Ghi chú", type: "textarea", required: false },
      ],
      initial: {
        roomId: available[0]?.id || "",
        tenantIds: [],
        representativeId: "",
        startDate: today,
        endDate: `${year + 1}-${today.slice(5)}`,
        rent: available[0]?.price || 0,
        deposit: available[0]?.price || 0,
        depositReceived: 0,
        note: "",
      },
      onChange: (key, value, v) =>
        key === "roomId"
          ? { ...v, rent: available.find((x) => x.id === value)?.price || 0 }
          : v,
      submit: (v) => api("/contracts", "POST", v),
    });
  }

  function closeContract(row: Row) {
    setForm({
      title: "Trả phòng & quyết toán cọc",
      description: `Cọc đang giữ: ${money(row.depositBalance)}. Cần thanh toán hết hóa đơn, gồm kỳ trả phòng. Số cọc còn lại sau khấu trừ được ghi nhận hoàn cho khách.`,
      fields: [
        dateField("closedDate", "Ngày trả phòng"),
        amountField("deduction", "Khấu trừ cọc (đ)"),
        { key: "note", label: "Lý do / xác nhận hoàn tiền", type: "textarea" },
      ],
      initial: { closedDate: today, deduction: 0, note: "" },
      submit: (v) => api(`/contracts/${row.id}/close`, "POST", v),
    });
  }

  function renew(row: Row) {
    setForm({
      title: "Gia hạn hợp đồng",
      description:
        "Giá thuê mới áp dụng cho hóa đơn lập sau thao tác gia hạn. Hóa đơn cũ được giữ nguyên.",
      fields: [
        dateField("endDate", "Ngày kết thúc mới"),
        amountField("rent", "Giá thuê mới (đ)"),
      ],
      initial: {
        endDate: `${Number(row.endDate.slice(0, 4)) + 1}-${row.endDate.slice(5)}`,
        rent: row.rent,
      },
      submit: (v) => api(`/contracts/${row.id}/renew`, "POST", v),
    });
  }

  function receiveDeposit(row: Row) {
    setForm({
      title: "Nhận thêm tiền cọc",
      description: `Cọc thỏa thuận ${money(row.deposit)}; hiện còn giữ ${money(row.depositBalance)}.`,
      fields: [
        amountField("amount", "Số tiền thực nhận (đ)"),
        { key: "note", label: "Ghi chú", type: "textarea", required: false },
      ],
      initial: { amount: 0, note: "" },
      submit: (v) => api(`/contracts/${row.id}/deposit`, "POST", v),
    });
  }
  return { editContract, closeContract, renew, receiveDeposit };
}
