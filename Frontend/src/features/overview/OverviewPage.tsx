import {
  ArrowDownLeft,
  ArrowUpRight,
  Building2,
  FileText,
  Home,
  Wallet,
  Wrench,
} from "lucide-react";
import { money, date } from "../../shared/formatters";
import { Table } from "../../shared/components/Table";
import { Stat } from "../../shared/components/Stat";
import { useWorkspace } from "../../app/WorkspaceContext";
import { useInvoiceColumns } from "../billing/useInvoiceColumns";

export function OverviewPage() {
  const {
    contracts,
    rooms,
    bills,
    year,
    month,
    payments,
    today,
    navigate,
    roomName,
    incidents,
  } = useWorkspace();
  const billColumns = useInvoiceColumns();
  const active = contracts.filter((x) => x.status === "Active");
  const liveRooms = rooms.filter((x) => !x.isArchived);
  const available = liveRooms.filter((x) => x.status === "Available").length;
  const balance = bills.reduce((s, x) => s + x.outstanding, 0);
  const periodBills = bills.filter(
    (x) => x.year === year && x.month === month && x.status === "Issued",
  );
  const collected = payments
    .filter((x) => x.paidDate.startsWith(today.slice(0, 7)))
    .reduce((s, x) => s + x.amount, 0);
  const ratio = liveRooms.length
    ? Math.round((active.length / liveRooms.length) * 100)
    : 0;
  const overdue = bills.filter((x) => x.outstanding > 0 && x.dueDate < today);
  return (
    <>
      <section className="welcome">
        <div>
          <span className="eyebrow">KHÔNG GIAN QUẢN LÝ CỦA BẠN</span>
          <h1>Mọi căn phòng, trong tầm tay.</h1>
          <p>
            Hôm nay có {available} phòng còn trống và {overdue.length} hóa đơn
            cần nhắc thu.
          </p>
          <button className="button light" onClick={() => navigate("payments")}>
            Xem các khoản cần thu
            <ArrowUpRight size={17} />
          </button>
        </div>
        <div className="welcome-graphic">
          <Home size={108} strokeWidth={0.8} />
          <span>AN CƯ / {year}</span>
        </div>
      </section>
      <div className="stats">
        <Stat
          label="Phòng đang thuê"
          value={`${active.length} / ${liveRooms.length}`}
          note={`${available} phòng còn trống`}
          icon={<Building2 size={19} />}
        />
        <Stat
          label={`Phải thu tháng ${month}`}
          value={money(periodBills.reduce((s, x) => s + x.total, 0))}
          note={`${periodBills.length} hóa đơn đã lập`}
          icon={<FileText size={19} />}
        />
        <Stat
          label={`Đã thanh toán tháng ${month}`}
          value={money(collected)}
          note="Theo ngày thu, gồm bù trừ cọc"
          icon={<ArrowDownLeft size={19} />}
        />
        <Stat
          label="Công nợ còn lại"
          value={money(balance)}
          note={`${overdue.length} hóa đơn quá hạn`}
          icon={<Wallet size={19} />}
        />
      </div>
      <div className="overview-grid">
        <section className="panel">
          <div className="panel-header">
            <div>
              <h2>Các khoản cần thu</h2>
              <p>Ưu tiên đối soát các hóa đơn quá hạn.</p>
            </div>
            <button
              className="text-button"
              onClick={() => navigate("payments")}
            >
              Xem tất cả <ArrowUpRight size={15} />
            </button>
          </div>
          <Table
            rows={bills
              .filter((x) => x.outstanding > 0)
              .sort((a, b) => a.dueDate.localeCompare(b.dueDate))}
            columns={billColumns.slice(0, 6)}
            empty="Các hóa đơn đã được thanh toán đủ."
          />
        </section>
        <div className="side-panels">
          <section className="panel occupancy">
            <span className="eyebrow">TÌNH HÌNH PHÒNG</span>
            <div className="occupancy-value">
              {ratio}
              <span>%</span>
            </div>
            <p>Tỷ lệ phòng đang cho thuê</p>
            <div className="progress">
              <i style={{ width: ratio + "%" }} />
            </div>
            <div className="legend">
              <span>
                <i className="dot green-dot" />
                Đang thuê <b>{active.length}</b>
              </span>
              <span>
                <i className="dot pale-dot" />
                Còn trống <b>{available}</b>
              </span>
              <span>
                <i className="dot amber-dot" />
                Đang sửa{" "}
                <b>{liveRooms.filter((x) => x.isMaintenance).length}</b>
              </span>
            </div>
          </section>
          <section className="panel reminders">
            <h2>Cần chú ý</h2>
            {active
              .filter(
                (x) =>
                  x.endDate <=
                  new Date(Date.parse(today) + 30 * 86400000)
                    .toISOString()
                    .slice(0, 10),
              )
              .map((x) => (
                <button key={x.id} onClick={() => navigate("contracts")}>
                  <FileText size={18} />
                  <span>
                    {roomName(x.roomId)} · Hợp đồng đến hạn
                    <small>{date(x.endDate)}</small>
                  </span>
                  <ArrowUpRight size={15} />
                </button>
              ))}
            <button onClick={() => navigate("incidents")}>
              <Wrench size={18} />
              <span>
                {incidents.filter((x) => x.status !== "Resolved").length} sự cố
                chưa hoàn tất<small>Kiểm tra tiến độ sửa chữa</small>
              </span>
              <ArrowUpRight size={15} />
            </button>
          </section>
        </div>
      </div>
    </>
  );
}
