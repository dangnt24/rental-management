import { money } from "../../shared/formatters";
import { Table } from "../../shared/components/Table";
import { Toolbar } from "../../shared/components/Toolbar";
import { useWorkspace } from "../../app/WorkspaceContext";
import { useInvoiceColumns } from "../billing/useInvoiceColumns";
import { usePaymentColumns } from "./usePaymentColumns";

export function PaymentsPage() {
  const {
    bills,
    today,
    contracts,
    search,
    setSearch,
    contractRoom,
    representative,
    payments,
  } = useWorkspace();
  const billColumns = useInvoiceColumns();
  const paymentColumns = usePaymentColumns();
  return (
    <>
      <div className="mini-stats">
        <div>
          <span>Công nợ còn lại</span>
          <strong>{money(bills.reduce((s, x) => s + x.outstanding, 0))}</strong>
        </div>
        <div>
          <span>Quá hạn thanh toán</span>
          <strong className="red">
            {money(
              bills
                .filter((x) => x.dueDate < today)
                .reduce((s, x) => s + x.outstanding, 0),
            )}
          </strong>
        </div>
        <div>
          <span>Cọc đang giữ</span>
          <strong>
            {money(contracts.reduce((s, x) => s + x.depositBalance, 0))}
          </strong>
        </div>
      </div>
      <section className="panel">
        <Toolbar title="Hóa đơn còn nợ" search={search} setSearch={setSearch} />
        <Table
          rows={bills
            .filter((x) => x.outstanding > 0)
            .map((x) => ({
              ...x,
              room: contractRoom(x.contractId),
              tenant: representative(x.contractId),
            }))}
          columns={billColumns}
          search={search}
        />
      </section>
      <section className="panel below">
        <div className="panel-header">
          <div>
            <h2>Lịch sử thu tiền</h2>
            <p>Mỗi giao dịch giữ nguyên để dễ đối soát.</p>
          </div>
        </div>
        <Table rows={payments} columns={paymentColumns} />
      </section>
    </>
  );
}
