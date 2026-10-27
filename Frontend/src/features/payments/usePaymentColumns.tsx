import { Paperclip, Eye } from "lucide-react";
import type { Column } from "../../shared/types";
import { money, date, code } from "../../shared/formatters";
import { labels } from "../../shared/labels";
import { IconButton } from "../../shared/components/IconButton";
import { useWorkspace } from "../../app/WorkspaceContext";

export function usePaymentColumns() {
  const { contractRoom, all, attach, setPaymentDetail } = useWorkspace();
  const paymentColumns: Column[] = [
    { label: "Ngày thu", cell: (r) => date(r.paidDate) },
    {
      label: "Hóa đơn / phòng",
      cell: (r) => (
        <>
          <strong>{code("HĐN", r.invoiceId)}</strong>
          <small>
            {contractRoom(
              all("invoices").find((x) => x.id === r.invoiceId)?.contractId,
            )}
          </small>
        </>
      ),
    },
    {
      label: "Số tiền",
      cell: (r) => <strong className="green">+{money(r.amount)}</strong>,
    },
    { label: "Phương thức", cell: (r) => labels[r.method] },
    { label: "Ghi chú", cell: (r) => r.note || "—" },
    {
      label: "",
      cell: (r) => (
        <div className="row-actions">
          <IconButton
            title="Xem chi tiết thanh toán"
            onClick={() => setPaymentDetail(r)}
          >
            <Eye size={16} />
          </IconButton>
          <IconButton
            title="Chứng từ"
            onClick={() => attach("payment", r, "Chứng từ thanh toán")}
          >
            <Paperclip size={16} />
          </IconButton>
        </div>
      ),
    },
  ];
  return paymentColumns;
}
