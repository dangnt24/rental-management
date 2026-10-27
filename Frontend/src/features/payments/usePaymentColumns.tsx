import { Paperclip } from "lucide-react";
import type { Column } from "../../shared/types";
import { money, date, code } from "../../shared/formatters";
import { labels } from "../../shared/labels";
import { IconButton } from "../../shared/components/IconButton";
import { useWorkspace } from "../../app/WorkspaceContext";

export function usePaymentColumns() {
  const { contractRoom, all, attach } = useWorkspace();
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
        <IconButton
          title="Chứng từ"
          onClick={() => attach("payment", r, "Chứng từ thanh toán")}
        >
          <Paperclip size={16} />
        </IconButton>
      ),
    },
  ];
  return paymentColumns;
}
