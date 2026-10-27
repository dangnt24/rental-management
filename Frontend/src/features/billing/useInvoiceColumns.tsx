import { FileText, X, Wallet } from "lucide-react";
import type { Column } from "../../shared/types";
import { money, date, code } from "../../shared/formatters";
import { api } from "../../shared/api";
import { Badge } from "../../shared/components/Badge";
import { IconButton } from "../../shared/components/IconButton";
import { useWorkspace } from "../../app/WorkspaceContext";
import { usePaymentForms } from "../payments/usePaymentForms";

export function useInvoiceColumns() {
  const {
    contractRoom,
    representative,
    today,
    billStatus,
    setPrintBill,
    setToast,
    owner,
    setForm,
  } = useWorkspace();
  const { paymentForm } = usePaymentForms();
  const billColumns: Column[] = [
    {
      label: "Hóa đơn",
      cell: (r) => (
        <>
          <strong>{code("HĐN", r.id)}</strong>
          <small>
            Tháng {r.month}/{r.year}
          </small>
        </>
      ),
    },
    {
      label: "Phòng / người thuê",
      cell: (r) => (
        <>
          <strong>{contractRoom(r.contractId)}</strong>
          <small>{representative(r.contractId)}</small>
        </>
      ),
    },
    { label: "Phải thu", cell: (r) => money(r.total) },
    {
      label: "Còn nợ",
      cell: (r) => (
        <strong className={r.outstanding > 0 ? "amber" : "green"}>
          {money(r.outstanding)}
        </strong>
      ),
    },
    {
      label: "Hạn thu",
      cell: (r) => (
        <span className={r.outstanding > 0 && r.dueDate < today ? "red" : ""}>
          {date(r.dueDate)}
        </span>
      ),
    },
    { label: "Trạng thái", cell: (r) => <Badge value={billStatus(r)} /> },
    {
      label: "",
      cell: (r) => (
        <div className="row-actions">
          <IconButton
            title="Xem / in hóa đơn"
            onClick={() =>
              api(`/invoices/${r.id}`)
                .then(setPrintBill)
                .catch((e) => setToast(e.message))
            }
          >
            <FileText size={16} />
          </IconButton>
          {r.outstanding > 0 && (
            <button className="text-button" onClick={() => paymentForm(r)}>
              <Wallet size={15} />
              Thu tiền
            </button>
          )}
          {owner && r.status === "Issued" && r.paid === 0 && (
            <IconButton
              title="Hủy hóa đơn"
              onClick={() =>
                setForm({
                  title: "Hủy hóa đơn",
                  confirmation: {
                    title: "Xác nhận hủy hóa đơn?",
                    message:
                      "Hóa đơn sẽ mất hiệu lực. Lý do và lịch sử hủy vẫn được lưu để đối soát.",
                    confirmLabel: "Hủy hóa đơn",
                    danger: true,
                  },
                  description:
                    "Giữ lại lịch sử hủy; sau đó có thể sửa chỉ số và lập lại kỳ này.",
                  fields: [
                    { key: "reason", label: "Lý do hủy", type: "textarea" },
                  ],
                  initial: { reason: "" },
                  submit: (v) => api(`/invoices/${r.id}/cancel`, "POST", v),
                })
              }
            >
              <X size={16} />
            </IconButton>
          )}
        </div>
      ),
    },
  ];
  return billColumns;
}
