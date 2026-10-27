import type { Row } from "../../shared/types";
import { money, code } from "../../shared/formatters";
import { labels } from "../../shared/labels";
import { api } from "../../shared/api";
import { options, amountField, dateField } from "../../shared/forms";
import { useWorkspace } from "../../app/WorkspaceContext";

export function usePaymentForms() {
  const { bills, setForm, contractRoom, today } = useWorkspace();
  function paymentForm(row?: Row) {
    const unpaid = bills.filter(
      (x) => x.status === "Issued" && x.outstanding > 0,
    );
    const selected = row || unpaid[0];
    setForm({
      title: "Ghi nhận thu tiền",
      description:
        "Mỗi lần thu được lưu riêng. Chỉ chọn bù trừ cọc khi đã thống nhất với người thuê.",
      fields: [
        {
          key: "invoiceId",
          label: "Hóa đơn còn nợ",
          type: "number",
          options: options(
            unpaid,
            (x) =>
              `${code("HĐN", x.id)} · ${contractRoom(x.contractId)} · còn ${money(x.outstanding)}`,
          ),
        },
        amountField("amount", "Số tiền thu (đ)"),
        {
          key: "method",
          label: "Phương thức",
          options: ["Cash", "Transfer", "Deposit"].map((value) => ({
            value,
            label: labels[value],
          })),
        },
        dateField("paidDate", "Ngày nhận tiền"),
        { key: "note", label: "Ghi chú", type: "textarea", required: false },
      ],
      initial: {
        invoiceId: selected?.id || "",
        amount: selected?.outstanding || 0,
        method: "Transfer",
        paidDate: today,
        note: "",
      },
      onChange: (key, value, v) =>
        key === "invoiceId"
          ? {
              ...v,
              amount: unpaid.find((x) => x.id === value)?.outstanding || 0,
            }
          : v,
      submit: (v) => api("/payments", "POST", v),
    });
  }
  return { paymentForm };
}
