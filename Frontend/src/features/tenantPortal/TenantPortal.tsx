import { useEffect, useState } from "react";
import {
  FileText,
  Home,
  LogOut,
  RefreshCw,
  Wallet,
  Wrench,
} from "lucide-react";
import type { Row, User } from "../../shared/types";
import { api } from "../../shared/api";
import { money, date, code } from "../../shared/formatters";
import { labels } from "../../shared/labels";
import { SiteHeader } from "../../shared/components/SiteHeader";
import { Table } from "../../shared/components/Table";
import { Modal } from "../../shared/components/Modal";
import { InvoiceContent } from "../../shared/components/InvoiceContent";

export function TenantPortal({
  user,
  signedOut,
}: {
  user: User;
  signedOut: () => void;
}) {
  const [data, setData] = useState<Row | null>(null);
  const [tab, setTab] = useState("contracts");
  const [error, setError] = useState("");
  const [notice, setNotice] = useState("");
  const [loading, setLoading] = useState(true);
  const [busy, setBusy] = useState(false);
  const [contractId, setContractId] = useState("");
  const [description, setDescription] = useState("");
  const [bill, setBill] = useState<Row | null>(null);
  const [currentPassword, setCurrentPassword] = useState("");
  const [newPassword, setNewPassword] = useState("");
  async function reload() {
    setLoading(true);
    setError("");
    try {
      setData(await api("/tenant/workspace"));
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setLoading(false);
    }
  }
  useEffect(() => {
    reload();
  }, []);
  async function logout() {
    setBusy(true);
    setError("");
    try {
      await api("/auth/logout", "POST");
      signedOut();
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setBusy(false);
    }
  }
  const rows = (name: string): Row[] => data?.[name] || [];
  const roomName = (id: number) =>
    rows("rooms").find((r) => r.id === id)?.name || "—";
  const contractRoom = (id: number) =>
    roomName(rows("contracts").find((c) => c.id === id)?.roomId);
  const active = rows("contracts").filter((c) => c.status === "Active");
  const outstanding = rows("invoices").reduce(
    (sum, i) => sum + i.outstanding,
    0,
  );
  function openInvoice(invoice: Row) {
    const contract = rows("contracts").find((c) => c.id === invoice.contractId);
    const room = rows("rooms").find((r) => r.id === contract?.roomId);
    const branch = rows("branches").find((b) => b.id === room?.branchId);
    setBill({
      invoice: { ...invoice, items: invoice.items },
      room: room?.name,
      branch: branch?.name,
      address: branch?.address,
      tenant: data?.profile.fullName,
      paid: invoice.paid,
      outstanding: invoice.outstanding,
    });
  }
  return (
    <div className="public-site">
      <SiteHeader user={user} />
      <main className="tenant-main">
        <div className="tenant-heading">
          <div>
            <span className="eyebrow">KHÔNG GIAN NGƯỜI THUÊ</span>
            <h1>Chào {user.fullName}.</h1>
            <p>Hợp đồng, khoản thu và yêu cầu của bạn trong cùng một nơi.</p>
          </div>
          <div className="heading-actions">
            <button
              className="button secondary"
              disabled={loading}
              onClick={reload}
            >
              <RefreshCw size={16} />
              Làm mới
            </button>
            <button
              className="button secondary"
              disabled={busy}
              onClick={logout}
            >
              <LogOut size={16} />
              Đăng xuất
            </button>
          </div>
        </div>
        {error && (
          <div className="error" role="alert">
            {error}
          </div>
        )}
        {notice && (
          <div className="tenant-notice" role="status">
            {notice}
          </div>
        )}
        {!data ? (
          <section className="panel empty">
            {loading
              ? "Đang tải thông tin của bạn…"
              : "Chưa tải được dữ liệu. Hãy nhấn Làm mới để thử lại."}
          </section>
        ) : (
          <>
            <div className="tenant-stats">
              <div className="panel">
                <Home size={22} />
                <span>Hợp đồng đang thuê</span>
                <strong>{active.length}</strong>
              </div>
              <div className="panel">
                <FileText size={22} />
                <span>Còn phải thanh toán</span>
                <strong>{money(outstanding)}</strong>
              </div>
              <div className="panel">
                <Wallet size={22} />
                <span>Số dư cọc đang thuê</span>
                <strong>
                  {money(active.reduce((sum, c) => sum + c.depositBalance, 0))}
                </strong>
              </div>
              <div className="panel">
                <Wrench size={22} />
                <span>Yêu cầu đang xử lý</span>
                <strong>
                  {
                    rows("incidents").filter((i) => i.status !== "Resolved")
                      .length
                  }
                </strong>
              </div>
            </div>
            <nav className="tenant-tabs" aria-label="Chức năng người thuê">
              {[
                ["contracts", "Hợp đồng"],
                ["invoices", "Hóa đơn"],
                ["payments", "Thanh toán"],
                ["deposits", "Tiền cọc"],
                ["incidents", "Yêu cầu sửa chữa"],
                ["account", "Tài khoản"],
              ].map(([id, label]) => (
                <button
                  key={id}
                  aria-current={tab === id ? "page" : undefined}
                  className={tab === id ? "active" : ""}
                  onClick={() => {
                    setTab(id);
                    setNotice("");
                  }}
                >
                  {label}
                </button>
              ))}
            </nav>
            <section className="panel tenant-panel">
              {tab === "contracts" && (
                <>
                  <div className="panel-header">
                    <div>
                      <h2>Hợp đồng của bạn</h2>
                      <p>Bao gồm hợp đồng hiện tại và lịch sử thuê.</p>
                    </div>
                  </div>
                  <Table
                    rows={rows("contracts")}
                    columns={[
                      { label: "Hợp đồng", cell: (c) => code("HĐ", c.id) },
                      { label: "Phòng", cell: (c) => roomName(c.roomId) },
                      {
                        label: "Thời hạn",
                        cell: (c) =>
                          `${date(c.startDate)} – ${date(c.closedDate || c.endDate)}`,
                      },
                      { label: "Tiền thuê/tháng", cell: (c) => money(c.rent) },
                      {
                        label: "Cọc thỏa thuận",
                        cell: (c) => money(c.deposit),
                      },
                      { label: "Trạng thái", cell: (c) => labels[c.status] },
                    ]}
                  />
                </>
              )}
              {tab === "invoices" && (
                <>
                  <div className="panel-header">
                    <div>
                      <h2>Hóa đơn tiền phòng</h2>
                      <p>Xem chi tiết, điện nước và in/lưu PDF từng hóa đơn.</p>
                    </div>
                  </div>
                  <Table
                    rows={rows("invoices")}
                    columns={[
                      { label: "Kỳ thu", cell: (i) => `${i.month}/${i.year}` },
                      {
                        label: "Phòng",
                        cell: (i) => contractRoom(i.contractId),
                      },
                      { label: "Hạn trả", cell: (i) => date(i.dueDate) },
                      { label: "Tổng", cell: (i) => money(i.total) },
                      { label: "Đã trả", cell: (i) => money(i.paid) },
                      { label: "Còn lại", cell: (i) => money(i.outstanding) },
                      {
                        label: "Trạng thái",
                        cell: (i) =>
                          i.status === "Cancelled"
                            ? "Đã hủy"
                            : i.outstanding === 0
                              ? "Đã thanh toán"
                              : i.paid > 0
                                ? "Thanh toán một phần"
                                : "Chưa thanh toán",
                      },
                      {
                        label: "",
                        cell: (i) => (
                          <button
                            className="text-button"
                            onClick={() => openInvoice(i)}
                          >
                            Chi tiết
                          </button>
                        ),
                      },
                    ]}
                  />
                </>
              )}
              {tab === "payments" && (
                <>
                  <div className="panel-header">
                    <div>
                      <h2>Lịch sử thanh toán</h2>
                      <p>
                        Các khoản chủ trọ/quản lý đã ghi nhận cho hợp đồng của
                        bạn.
                      </p>
                    </div>
                  </div>
                  <Table
                    rows={rows("payments")}
                    columns={[
                      { label: "Phiếu thu", cell: (p) => code("PT", p.id) },
                      {
                        label: "Hóa đơn",
                        cell: (p) => code("HĐN", p.invoiceId),
                      },
                      { label: "Ngày thu", cell: (p) => date(p.paidDate) },
                      { label: "Phương thức", cell: (p) => labels[p.method] },
                      { label: "Số tiền", cell: (p) => money(p.amount) },
                    ]}
                  />
                </>
              )}
              {tab === "deposits" && (
                <>
                  <div className="panel-header">
                    <div>
                      <h2>Lịch sử tiền cọc</h2>
                      <p>
                        Tiền nhận, bù trừ, khấu trừ và hoàn cọc theo hợp đồng.
                      </p>
                    </div>
                  </div>
                  <Table
                    rows={rows("deposits")}
                    columns={[
                      { label: "Ngày", cell: (d) => date(d.createdAt) },
                      {
                        label: "Phòng",
                        cell: (d) => contractRoom(d.contractId),
                      },
                      { label: "Nghiệp vụ", cell: (d) => labels[d.type] },
                      { label: "Số tiền", cell: (d) => money(d.amount) },
                      { label: "Ghi chú", cell: (d) => d.note || "—" },
                    ]}
                  />
                </>
              )}
              {tab === "incidents" && (
                <>
                  <div className="panel-header">
                    <div>
                      <h2>Yêu cầu sửa chữa</h2>
                      <p>
                        Gửi sự cố phòng đang thuê và theo dõi phản hồi của quản
                        lý.
                      </p>
                    </div>
                  </div>
                  {active.length ? (
                    <form
                      className="tenant-request-form"
                      onSubmit={async (e) => {
                        e.preventDefault();
                        setBusy(true);
                        setError("");
                        setNotice("");
                        try {
                          await api("/tenant/incidents", "POST", {
                            contractId: Number(contractId || active[0].id),
                            description,
                          });
                          setDescription("");
                          await reload();
                          setNotice(
                            "Đã gửi yêu cầu. Quản lý sẽ tiếp nhận và cập nhật tại đây.",
                          );
                        } catch (e) {
                          setError((e as Error).message);
                        } finally {
                          setBusy(false);
                        }
                      }}
                    >
                      <label>
                        Phòng đang thuê
                        <select
                          value={contractId || active[0].id}
                          onChange={(e) => setContractId(e.target.value)}
                        >
                          {active.map((c) => (
                            <option key={c.id} value={c.id}>
                              {roomName(c.roomId)} · {code("HĐ", c.id)}
                            </option>
                          ))}
                        </select>
                      </label>
                      <label>
                        Nội dung cần hỗ trợ
                        <textarea
                          required
                          maxLength={2000}
                          value={description}
                          onChange={(e) => setDescription(e.target.value)}
                          placeholder="Mô tả vị trí và tình trạng cần sửa chữa…"
                        />
                      </label>
                      <button className="button" disabled={busy}>
                        {busy ? "Đang gửi…" : "Gửi yêu cầu"}
                      </button>
                    </form>
                  ) : (
                    <p className="form-description">
                      Bạn chưa có hợp đồng đang thuê để gửi yêu cầu mới.
                    </p>
                  )}
                  <Table
                    rows={rows("incidents")}
                    columns={[
                      { label: "Ngày gửi", cell: (i) => date(i.createdAt) },
                      { label: "Phòng", cell: (i) => roomName(i.roomId) },
                      {
                        label: "Nội dung",
                        cell: (i) => (
                          <span className="wrap">{i.description}</span>
                        ),
                      },
                      { label: "Trạng thái", cell: (i) => labels[i.status] },
                      {
                        label: "Phản hồi",
                        cell: (i) => (
                          <span className="wrap">
                            {i.resolution || "Chưa có phản hồi"}
                          </span>
                        ),
                      },
                    ]}
                  />
                </>
              )}
              {tab === "account" && (
                <>
                  <div className="panel-header">
                    <div>
                      <h2>Tài khoản của bạn</h2>
                      <p>
                        {data.profile.fullName} · {user.username} ·{" "}
                        {data.profile.phone}
                      </p>
                    </div>
                  </div>
                  <form
                    className="tenant-request-form"
                    onSubmit={async (e) => {
                      e.preventDefault();
                      setBusy(true);
                      setError("");
                      try {
                        await api("/auth/password", "POST", {
                          currentPassword,
                          newPassword,
                        });
                        signedOut();
                      } catch (e) {
                        setError((e as Error).message);
                      } finally {
                        setBusy(false);
                      }
                    }}
                  >
                    <label>
                      Mật khẩu hiện tại
                      <input
                        type="password"
                        autoComplete="current-password"
                        required
                        maxLength={128}
                        value={currentPassword}
                        onChange={(e) => setCurrentPassword(e.target.value)}
                      />
                    </label>
                    <label>
                      Mật khẩu mới (ít nhất 10 ký tự)
                      <input
                        type="password"
                        autoComplete="new-password"
                        required
                        minLength={10}
                        maxLength={128}
                        value={newPassword}
                        onChange={(e) => setNewPassword(e.target.value)}
                      />
                    </label>
                    <p className="muted">
                      Sau khi đổi mật khẩu, bạn cần đăng nhập lại.
                    </p>
                    <button className="button" disabled={busy}>
                      Đổi mật khẩu
                    </button>
                  </form>
                </>
              )}
            </section>
          </>
        )}
      </main>
      {bill && (
        <Modal title="Chi tiết hóa đơn" wide close={() => setBill(null)}>
          <InvoiceContent bill={bill} />
          <footer>
            <button className="button secondary" onClick={() => setBill(null)}>
              Đóng
            </button>
            <button className="button" onClick={() => window.print()}>
              In / lưu PDF
            </button>
          </footer>
        </Modal>
      )}
    </div>
  );
}
