import { CircleHelp, Paperclip } from "lucide-react";
import { money, date, code } from "../../shared/formatters";
import { labels } from "../../shared/labels";
import { Badge } from "../../shared/components/Badge";
import { IconButton } from "../../shared/components/IconButton";
import { Table } from "../../shared/components/Table";
import { Toolbar } from "../../shared/components/Toolbar";
import { useWorkspace } from "../../app/WorkspaceContext";
import { useContractForms } from "./useContractForms";

export function ContractsPage() {
  const {
    contracts,
    search,
    setSearch,
    status,
    setStatus,
    roomName,
    representative,
    today,
    attach,
    all,
    contractIds,
    contractRoom,
  } = useWorkspace();
  const { receiveDeposit, renew, closeContract } = useContractForms();
  return (
    <>
      <div className="notice">
        <CircleHelp size={18} />
        <span>
          Hợp đồng quá hạn vẫn giữ phòng đang thuê cho đến khi trả phòng và
          quyết toán. Tiền cọc được theo dõi riêng với tiền thu hóa đơn.
        </span>
      </div>
      <section className="panel">
        <Toolbar
          title={`${contracts.length} hợp đồng`}
          search={search}
          setSearch={setSearch}
          status={status}
          setStatus={setStatus}
          states={["Active", "Closed"]}
        />
        <Table
          rows={contracts
            .filter((x) => !status || x.status === status)
            .map((x) => ({
              ...x,
              room: roomName(x.roomId),
              representative: representative(x.id),
            }))}
          search={search}
          columns={[
            {
              label: "Hợp đồng / phòng",
              cell: (r) => (
                <>
                  <strong>
                    {code("HĐ", r.id)} · {r.room}
                  </strong>
                  <small>{r.representative}</small>
                </>
              ),
            },
            {
              label: "Thời hạn",
              cell: (r) => (
                <>
                  {date(r.startDate)}
                  <small
                    className={
                      r.endDate < today && r.status === "Active" ? "red" : ""
                    }
                  >
                    đến {date(r.endDate)}
                  </small>
                </>
              ),
            },
            { label: "Giá thuê", cell: (r) => money(r.rent) },
            {
              label: "Cọc đang giữ",
              cell: (r) => (
                <>
                  <strong>{money(r.depositBalance)}</strong>
                  <small>Thỏa thuận {money(r.deposit)}</small>
                </>
              ),
            },
            {
              label: "Trạng thái",
              cell: (r) => <Badge value={r.status} />,
            },
            {
              label: "Thao tác",
              cell: (r) => (
                <div className="row-actions">
                  <IconButton
                    title="File hợp đồng"
                    onClick={() =>
                      attach("contract", r, `File hợp đồng ${code("HĐ", r.id)}`)
                    }
                  >
                    <Paperclip size={16} />
                  </IconButton>
                  {r.status === "Active" && (
                    <>
                      <button
                        className="text-button"
                        onClick={() => receiveDeposit(r)}
                      >
                        Nhận cọc
                      </button>
                      <button className="text-button" onClick={() => renew(r)}>
                        Gia hạn
                      </button>
                      <button
                        className="text-button danger"
                        onClick={() => closeContract(r)}
                      >
                        Trả phòng
                      </button>
                    </>
                  )}
                </div>
              ),
            },
          ]}
        />
      </section>
      <section className="panel below">
        <div className="panel-header">
          <div>
            <h2>Sổ tiền cọc</h2>
            <p>Lịch sử nhận, bù trừ, khấu trừ và hoàn cọc.</p>
          </div>
        </div>
        <Table
          rows={all("deposits")
            .filter((x) => contractIds.has(x.contractId))
            .sort((a, b) => b.id - a.id)}
          columns={[
            {
              label: "Hợp đồng / phòng",
              cell: (r) =>
                `${code("HĐ", r.contractId)} · ${contractRoom(r.contractId)}`,
            },
            { label: "Nghiệp vụ", cell: (r) => labels[r.type] },
            {
              label: "Số tiền",
              cell: (r) => (
                <strong className={r.type === "Received" ? "green" : "amber"}>
                  {r.type === "Received" ? "+" : "−"}
                  {money(r.amount)}
                </strong>
              ),
            },
            { label: "Ghi chú", cell: (r) => r.note },
          ]}
        />
      </section>
    </>
  );
}
