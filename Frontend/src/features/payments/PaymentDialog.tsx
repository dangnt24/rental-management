import { FileText, Paperclip, X } from "lucide-react";
import { useWorkspace } from "../../app/WorkspaceContext";
import { api } from "../../shared/api";
import { date, money, code } from "../../shared/formatters";
import { labels } from "../../shared/labels";
import { Modal } from "../../shared/components/Modal";

export function PaymentDialog() {
  const {
    paymentDetail: payment,
    setPaymentDetail,
    setPrintBill,
    setToast,
    all,
    contractRoom,
    representative,
    attach,
  } = useWorkspace();
  if (!payment) return null;
  const invoice = all("invoices").find((i) => i.id === payment.invoiceId);
  return (
    <Modal title="Chi tiết thanh toán" close={() => setPaymentDetail(null)}>
      <div className="payment-summary">
        <span className="eyebrow">ĐÃ GHI NHẬN THU TIỀN</span>
        <strong>{money(payment.amount)}</strong>
        <span>
          {labels[payment.method]} · {date(payment.paidDate)}
        </span>
      </div>
      <dl className="detail-list">
        <div>
          <dt>Mã giao dịch</dt>
          <dd>{code("TT", payment.id)}</dd>
        </div>
        <div>
          <dt>Hóa đơn</dt>
          <dd>
            {code("HĐN", payment.invoiceId)} · {invoice?.month}/{invoice?.year}
          </dd>
        </div>
        <div>
          <dt>Phòng / người thuê</dt>
          <dd>
            {contractRoom(invoice?.contractId)} ·{" "}
            {representative(invoice?.contractId)}
          </dd>
        </div>
        <div>
          <dt>Người ghi nhận</dt>
          <dd>{payment.createdBy || "—"}</dd>
        </div>
        <div>
          <dt>Ghi chú</dt>
          <dd>{payment.note || "Không có ghi chú."}</dd>
        </div>
      </dl>
      <footer>
        <button
          className="button secondary"
          onClick={() => setPaymentDetail(null)}
        >
          <X size={16} />
          Đóng
        </button>
        <button
          className="button secondary"
          onClick={() => {
            attach("payment", payment, "Chứng từ thanh toán");
            setPaymentDetail(null);
          }}
        >
          <Paperclip size={16} />
          Chứng từ
        </button>
        <button
          className="button"
          onClick={() => {
            api(`/invoices/${payment.invoiceId}`)
              .then((bill) => {
                setPrintBill(bill);
                setPaymentDetail(null);
              })
              .catch((error) => setToast(error.message));
          }}
        >
          <FileText size={16} />
          Xem hóa đơn
        </button>
      </footer>
    </Modal>
  );
}
