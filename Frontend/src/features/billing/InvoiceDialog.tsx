import { InvoiceContent } from "../../shared/components/InvoiceContent";
import { Download, X } from "lucide-react";
import { Modal } from "../../shared/components/Modal";
import { useWorkspace } from "../../app/WorkspaceContext";
import { SendReminderButton } from "../notifications/SendReminderButton";

export function InvoiceDialog() {
  const { printBill, setPrintBill } = useWorkspace();
  if (!printBill) return null;
  return (
    <Modal title="Chi tiết hóa đơn" wide close={() => setPrintBill(null)}>
      <InvoiceContent bill={printBill} />
      <footer>
        {printBill.invoice.status === "Issued" && printBill.outstanding > 0 && (
          <SendReminderButton
            kind="InvoiceDue"
            entityId={printBill.invoice.id}
            className="button secondary"
          />
        )}
        <button className="button secondary" onClick={() => setPrintBill(null)}>
          <X size={16} />
          Đóng
        </button>
        <button className="button" onClick={() => window.print()}>
          <Download size={16} />
          In / lưu PDF
        </button>
      </footer>
    </Modal>
  );
}
