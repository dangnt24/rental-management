import { useEffect, useState } from "react";
import { Mail, Save, Send, RefreshCw, Clock3 } from "lucide-react";
import { api } from "../../shared/api";
import type { Row } from "../../shared/types";
import { date } from "../../shared/formatters";
import { Table } from "../../shared/components/Table";
import {
  useInteractionGuard,
  useUnsavedChanges,
} from "../../shared/InteractionGuard";
import { useWorkspace } from "../../app/WorkspaceContext";
import { SendReminderButton } from "./SendReminderButton";

const names: Record<string, string> = {
  Ready: "Chưa gửi",
  Pending: "Chờ xử lý",
  Sending: "Đang gửi",
  Sent: "Đã gửi SMTP",
  Failed: "Gửi lỗi",
  Skipped: "Thiếu email",
  Uncertain: "Cần kiểm tra",
  Cancelled: "Đã bỏ qua",
};
const kindName = (kind: string) =>
  kind === "InvoiceDue" ? "Nhắc hóa đơn" : "Hợp đồng sắp hết hạn";
const stamp = (value: string) =>
  value
    ? new Date(value).toLocaleString("vi-VN", { timeZone: "Asia/Ho_Chi_Minh" })
    : "—";
export function EmailRemindersPanel() {
  const [data, setData] = useState<Row | null>(null);
  const [draft, setDraft] = useState<Row | null>(null);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState("");
  const { setToast } = useWorkspace();
  const { confirm, leave } = useInteractionGuard();
  const settings = draft || data?.settings;
  const values = (s: Row | null | undefined) =>
    s && [
      s.enabled,
      s.invoiceEnabled,
      s.contractEnabled,
      Number(s.contractDaysBefore),
    ];
  const dirty =
    !!draft &&
    JSON.stringify(values(draft)) !== JSON.stringify(values(data?.settings));
  useUnsavedChanges(dirty, busy);
  async function load() {
    try {
      const next = await api("/email-reminders");
      setData(next);
      setDraft(null);
      setError("");
    } catch (error) {
      setError((error as Error).message);
    }
  }
  useEffect(() => {
    void load();
  }, []);
  const configured = data?.delivery.configured && data?.delivery.jobsEnabled;
  const ready = (data?.candidates || []).filter(
    (row: Row) =>
      row.recipient && !["Sent", "Sending", "Uncertain"].includes(row.status),
  ).length;
  return (
    <section className="panel below email-reminders-panel">
      <div className="panel-header">
        <div>
          <h2>
            <Mail size={20} /> Email nhắc thanh toán & hợp đồng
          </h2>
          <p>
            <Clock3 size={15} /> Hangfire quét lúc 09:00 hằng ngày · giờ Việt
            Nam
          </p>
        </div>
        <button
          type="button"
          className="text-button"
          disabled={busy}
          onClick={async () => {
            if (
              await leave({
                always: true,
                title: "Tải lại nhật ký email?",
                message: "Lấy trạng thái gửi mới nhất từ máy chủ.",
                confirmLabel: "Tải lại",
              })
            )
              await load();
          }}
        >
          <RefreshCw size={16} />
          Tải lại
        </button>
      </div>
      {error && (
        <div className="error" role="alert">
          {error}
        </div>
      )}
      {!data && !error && (
        <p className="email-reminder-content">Đang tải cấu hình email…</p>
      )}
      {data && settings && (
        <>
          <div className="email-reminder-content">
            <div className={configured ? "notice" : "notice email-setup-note"}>
              <Mail size={19} />
              <div>
                {configured ? (
                  <>
                    SMTP đã cấu hình:{" "}
                    <strong>{data.delivery.fromAddress}</strong> ·{" "}
                    {data.delivery.host}:{data.delivery.port}
                  </>
                ) : (
                  <>
                    Chưa sẵn sàng gửi mail. Cần cấu hình SMTP trong{" "}
                    <strong>appsettings.Local.json</strong> hoặc biến môi
                    trường, rồi chạy Restart.cmd. Mẫu cấu hình:
                    Rental.Api/appsettings.Email.example.json. Không nhập mật
                    khẩu email vào nhật ký hay chia sẻ trong chat.
                  </>
                )}
              </div>
            </div>
            <form
              onSubmit={async (event) => {
                event.preventDefault();
                if (busy) return;
                setBusy(true);
                setError("");
                try {
                  await api("/email-reminders/settings", "PUT", {
                    enabled: settings.enabled,
                    invoiceEnabled: settings.invoiceEnabled,
                    contractEnabled: settings.contractEnabled,
                    contractDaysBefore: Number(settings.contractDaysBefore),
                  });
                  await load();
                  setToast("Đã lưu cấu hình email.");
                } catch (error) {
                  setError((error as Error).message);
                } finally {
                  setBusy(false);
                }
              }}
            >
              <div className="email-reminder-options">
                <label>
                  <input
                    type="checkbox"
                    checked={settings.enabled}
                    disabled={busy || (!configured && !settings.enabled)}
                    onChange={(e) =>
                      setDraft({ ...settings, enabled: e.target.checked })
                    }
                  />{" "}
                  Bật gửi tự động lúc 09:00
                </label>
                <label>
                  <input
                    type="checkbox"
                    checked={settings.invoiceEnabled}
                    disabled={busy}
                    onChange={(e) =>
                      setDraft({
                        ...settings,
                        invoiceEnabled: e.target.checked,
                      })
                    }
                  />{" "}
                  Nhắc hóa đơn đến hạn/quá hạn còn nợ
                </label>
                <label>
                  <input
                    type="checkbox"
                    checked={settings.contractEnabled}
                    disabled={busy}
                    onChange={(e) =>
                      setDraft({
                        ...settings,
                        contractEnabled: e.target.checked,
                      })
                    }
                  />{" "}
                  Nhắc hợp đồng sắp hết hạn
                </label>
                <label className="email-days">
                  Nhắc hợp đồng trước{" "}
                  <input
                    aria-label="Số ngày nhắc trước khi hết hợp đồng"
                    type="number"
                    min={1}
                    max={90}
                    required
                    value={settings.contractDaysBefore}
                    disabled={busy}
                    onChange={(e) =>
                      setDraft({
                        ...settings,
                        contractDaysBefore: e.target.value,
                      })
                    }
                  />{" "}
                  ngày
                </label>
              </div>
              <p className="muted">
                Gửi cho email tài khoản người đại diện hợp đồng. Mỗi hóa
                đơn/ngày hết hạn được nhắc một lần; cập nhật email người nhận
                tại Tài khoản & phạm vi quản lý. Máy chạy web cần bật để job
                hoạt động.
              </p>
              <div className="email-reminder-controls">
                <button className="button secondary" disabled={busy || !dirty}>
                  <Save size={16} /> Lưu cấu hình
                </button>
                <button
                  type="button"
                  className="button"
                  disabled={busy || !configured || dirty || !ready}
                  onClick={async () => {
                    if (
                      !(await confirm({
                        title: "Quét và gửi thông báo đến hạn?",
                        message: `Hiện có ${ready} thông báo có email và chưa gửi. Job sẽ kiểm tra lại dữ liệu rồi gửi. Tác vụ thủ công này chạy ngay cả khi lịch tự động đang tắt.`,
                        confirmLabel: "Xếp hàng quét và gửi",
                      }))
                    )
                      return;
                    setBusy(true);
                    try {
                      const result = await api("/email-reminders/run", "POST");
                      setToast(result.message);
                      await load();
                    } catch (error) {
                      setError((error as Error).message);
                    } finally {
                      setBusy(false);
                    }
                  }}
                >
                  <Send size={16} /> Gửi các thông báo đến hạn
                </button>
              </div>
              <small className="muted">
                Quét gần nhất: {stamp(data.settings.lastScanAt)} · {ready} thông
                báo có thể gửi. SMTP nhận thư chưa đồng nghĩa người nhận đã đọc
                thư.
              </small>
            </form>
          </div>
          <div className="email-reminder-subheading">
            <h3>Thông báo đến hạn</h3>
            <p>
              Hóa đơn chưa trả và hợp đồng trong khoảng nhắc đã cấu hình; dòng
              thiếu email cần chủ trọ cập nhật.
            </p>
          </div>
          <Table
            rows={data.candidates}
            empty="Không có hóa đơn/hợp đồng cần nhắc."
            columns={[
              {
                label: "Nội dung",
                cell: (row) => (
                  <>
                    <strong>
                      {kindName(row.kind)} #{row.entityId}
                    </strong>
                    <small>
                      Phòng {row.roomName} · {row.branchName}
                    </small>
                  </>
                ),
              },
              {
                label: "Người nhận",
                cell: (row) => (
                  <>
                    <span>{row.recipientName}</span>
                    <small>{row.recipient || "Chưa có email hợp lệ"}</small>
                  </>
                ),
              },
              { label: "Ngày đến hạn", cell: (row) => date(row.eventDate) },
              {
                label: "Trạng thái",
                cell: (row) => (
                  <span
                    className={
                      row.status === "Sent"
                        ? "green"
                        : row.status === "Skipped"
                          ? "amber"
                          : ""
                    }
                  >
                    {names[row.status] || row.status}
                  </span>
                ),
              },
              {
                label: "Thao tác",
                cell: (row) =>
                  configured &&
                  row.recipient &&
                  !["Sent", "Sending", "Uncertain"].includes(row.status) && (
                    <SendReminderButton
                      kind={row.kind}
                      entityId={row.entityId}
                      complete={() => {
                        if (!dirty) void load();
                      }}
                    />
                  ),
              },
            ]}
          />
          <div className="email-reminder-subheading">
            <h3>Nhật ký email</h3>
            <p>
              100 thông báo gần nhất. “Cần kiểm tra” có thể đã gửi thành công;
              kiểm tra hộp thư trước khi gửi lại.
            </p>
          </div>
          <Table
            rows={data.history}
            empty="Chưa có lượt gửi email."
            columns={[
              {
                label: "Thông báo",
                cell: (row) => (
                  <>
                    <strong>{row.subject || kindName(row.kind)}</strong>
                    <small>{row.recipient || "Thiếu email"}</small>
                  </>
                ),
              },
              {
                label: "Trạng thái",
                cell: (row) => (
                  <>
                    <span
                      className={
                        row.status === "Sent"
                          ? "green"
                          : ["Failed", "Uncertain"].includes(row.status)
                            ? "red"
                            : ""
                      }
                    >
                      {names[row.status] || row.status}
                    </span>
                    <small>{row.attempts} lượt thử</small>
                  </>
                ),
              },
              {
                label: "Thời điểm",
                cell: (row) =>
                  stamp(row.sentAt || row.lastAttemptAt || row.createdAt),
              },
              {
                label: "Ghi chú",
                cell: (row) => <span className="wrap">{row.error || "—"}</span>,
              },
              {
                label: "Thao tác",
                cell: (row) =>
                  configured &&
                  ["Failed", "Uncertain", "Skipped"].includes(row.status) && (
                    <SendReminderButton
                      kind={row.kind}
                      entityId={row.entityId}
                      reminderId={row.id}
                      uncertain={row.status === "Uncertain"}
                      complete={() => {
                        if (!dirty) void load();
                      }}
                    />
                  ),
              },
            ]}
          />
        </>
      )}
    </section>
  );
}
