import { useState } from "react";
import { Mail } from "lucide-react";
import { api } from "../../shared/api";
import { useWorkspace } from "../../app/WorkspaceContext";
import {
  useInteractionGuard,
  useUnsavedChanges,
} from "../../shared/InteractionGuard";

export function SendReminderButton({
  kind,
  entityId,
  reminderId,
  uncertain = false,
  complete,
  className = "text-button",
}: {
  kind: string;
  entityId: number;
  reminderId?: number;
  uncertain?: boolean;
  complete?: () => void;
  className?: string;
}) {
  const [busy, setBusy] = useState(false);
  const { setToast } = useWorkspace();
  const { confirm } = useInteractionGuard();
  useUnsavedChanges(false, busy);
  return (
    <button
      type="button"
      className={className}
      disabled={busy}
      onClick={async () => {
        try {
          const preview = await api(
            `/email-reminders/preview?kind=${encodeURIComponent(kind)}&entityId=${entityId}`,
          );
          if (!preview.recipient) {
            setToast(
              "Người đại diện chưa có email hợp lệ. Chủ trọ cần cập nhật email tài khoản người thuê.",
            );
            return;
          }
          if (
            !(await confirm({
              title: uncertain
                ? "Đã kiểm tra và muốn gửi lại email?"
                : "Gửi email thông báo?",
              message:
                `${preview.subject}\nNgười nhận: ${preview.recipientName} · ${preview.recipient}` +
                (uncertain
                  ? "\nLượt trước có thể đã gửi thành công. Gửi lại có thể làm người nhận nhận thư trùng."
                  : "\nEmail được đưa vào hàng đợi và kiểm tra lại dữ liệu trước khi gửi."),
              confirmLabel: uncertain ? "Đã kiểm tra, gửi lại" : "Xếp hàng gửi",
              danger: uncertain,
            }))
          )
            return;
          setBusy(true);
          const response = await api("/email-reminders/send", "POST", {
            kind,
            entityId,
            reminderId,
            retryUncertain: uncertain,
          });
          setToast(response.message);
          complete?.();
        } catch (error) {
          setToast((error as Error).message);
        } finally {
          setBusy(false);
        }
      }}
    >
      <Mail size={16} />
      {busy ? "Đang xử lý…" : reminderId ? "Gửi lại" : "Gửi email"}
    </button>
  );
}
