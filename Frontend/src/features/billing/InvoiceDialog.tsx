import { InvoiceContent } from "../../shared/components/InvoiceContent";
import { Download } from "lucide-react";
import { Modal } from "../../shared/components/Modal";
import { useWorkspace } from "../../app/WorkspaceContext";

export function InvoiceDialog() {
  const { printBill, setPrintBill } = useWorkspace();
  if (!printBill) return null;
  return (
    <Modal title="Chi tiết hóa đơn" wide close={() => setPrintBill(null)}>
      <InvoiceContent bill={printBill} />
      <footer>
        <button className="button secondary" onClick={() => setPrintBill(null)}>
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
