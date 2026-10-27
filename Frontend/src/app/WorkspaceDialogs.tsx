import { Check, X } from "lucide-react";
import { EditForm } from "../shared/components/EditForm";
import { AttachmentModal } from "../features/attachments/AttachmentModal";
import { useWorkspace } from "./WorkspaceContext";
import { InvoiceDialog } from "../features/billing/InvoiceDialog";
import { PaymentDialog } from "../features/payments/PaymentDialog";

export function WorkspaceDialogs() {
  const {
    toast,
    setToast,
    form,
    setForm,
    completed,
    fileTarget,
    all,
    setFileTarget,
  } = useWorkspace();
  return (
    <>
      {toast && (
        <div className="toast" role="status">
          <Check size={18} />
          {toast}
          <button onClick={() => setToast("")} aria-label="Đóng thông báo">
            <X size={15} />
          </button>
        </div>
      )}
      {form && (
        <EditForm
          definition={form}
          close={() => setForm(null)}
          complete={completed}
        />
      )}
      {fileTarget && (
        <AttachmentModal
          target={fileTarget}
          files={all("attachments").filter(
            (x) =>
              x.entityType === fileTarget.type && x.entityId === fileTarget.id,
          )}
          close={() => setFileTarget(null)}
          complete={completed}
        />
      )}
      <InvoiceDialog />
      <PaymentDialog />
    </>
  );
}
