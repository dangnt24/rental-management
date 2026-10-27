import { ClipboardList, Plus } from "lucide-react";
import { Table } from "../../shared/components/Table";
import { Toolbar } from "../../shared/components/Toolbar";
import { useWorkspace } from "../../app/WorkspaceContext";
import { useBillingForms } from "./useBillingForms";
import { useInvoiceColumns } from "./useInvoiceColumns";

export function BillingPage() {
  const {
    search,
    setSearch,
    status,
    setStatus,
    bills,
    billStatus,
    contractRoom,
    representative,
    all,
    contractIds,
  } = useWorkspace();
  const billColumns = useInvoiceColumns();
  const { readingForm } = useBillingForms();
  return (
    <>
      <div className="notice">
        <ClipboardList size={18} />
        <span>
          1. Chốt chỉ số điện nước &nbsp; → &nbsp; 2. Lập hóa đơn tháng &nbsp; →
          &nbsp; 3. Ghi nhận thu tiền.
        </span>
      </div>
      <section className="panel">
        <Toolbar
          title="Hóa đơn theo kỳ thu"
          search={search}
          setSearch={setSearch}
          status={status}
          setStatus={setStatus}
          states={["Unpaid", "Partial", "Paid", "Cancelled"]}
        />
        <Table
          rows={bills
            .filter((x) => !status || billStatus(x) === status)
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
            <h2>Chỉ số điện nước đã chốt</h2>
            <p>Dữ liệu gốc để kiểm tra các khoản thu.</p>
          </div>
          <button className="button secondary" onClick={readingForm}>
            <Plus size={16} />
            Nhập chỉ số
          </button>
        </div>
        <Table
          rows={all("readings").filter((x) => contractIds.has(x.contractId))}
          columns={[
            {
              label: "Kỳ / phòng",
              cell: (r) => (
                <>
                  <strong>
                    {r.month}/{r.year}
                  </strong>
                  <small>{contractRoom(r.contractId)}</small>
                </>
              ),
            },
            {
              label: "Điện (cũ → mới)",
              cell: (r) => `${r.electricityOld} → ${r.electricityNew}`,
            },
            {
              label: "Tiêu thụ điện",
              cell: (r) => `${r.electricityNew - r.electricityOld} kWh`,
            },
            {
              label: "Nước (cũ → mới)",
              cell: (r) => `${r.waterOld} → ${r.waterNew}`,
            },
            {
              label: "Tiêu thụ nước",
              cell: (r) => `${+(r.waterNew - r.waterOld).toFixed(3)} m³`,
            },
          ]}
        />
      </section>
    </>
  );
}
