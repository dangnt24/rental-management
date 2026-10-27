import { Pencil, Plus } from "lucide-react";
import type { Row } from "../../shared/types";
import { money } from "../../shared/formatters";
import { labels } from "../../shared/labels";
import { IconButton } from "../../shared/components/IconButton";
import { Table } from "../../shared/components/Table";
import { useWorkspace } from "../../app/WorkspaceContext";
import { useSettingsForms } from "./useSettingsForms";
import { EmailRemindersPanel } from "../notifications/EmailRemindersPanel";

export function SettingsPage() {
  const { owner, all, branch, branchName } = useWorkspace();
  const { editBranch, editFee } = useSettingsForms();
  return (
    <>
      <section className="panel">
        <div className="panel-header">
          <div>
            <h2>Khu trọ</h2>
            <p>Danh sách các khu bạn có quyền quản lý.</p>
          </div>
          {owner && (
            <button className="button secondary" onClick={() => editBranch()}>
              <Plus size={16} />
              Thêm khu trọ
            </button>
          )}
        </div>
        <Table
          rows={all("branches")}
          columns={[
            { label: "Tên khu", cell: (r) => <strong>{r.name}</strong> },
            { label: "Địa chỉ", cell: (r) => r.address },
            ...(owner
              ? [
                  {
                    label: "",
                    cell: (r: Row) => (
                      <IconButton
                        title="Sửa khu trọ"
                        onClick={() => editBranch(r)}
                      >
                        <Pencil size={16} />
                      </IconButton>
                    ),
                  },
                ]
              : []),
          ]}
        />
      </section>
      <section className="panel below">
        <div className="panel-header">
          <div>
            <h2>Đơn giá & dịch vụ</h2>
            <p>Đơn giá mới không làm thay đổi hóa đơn đã lập.</p>
          </div>
          {owner && (
            <button className="button secondary" onClick={() => editFee()}>
              <Plus size={16} />
              Thêm loại phí
            </button>
          )}
        </div>
        <Table
          rows={all("fees").filter((x) => !branch || x.branchId === branch)}
          columns={[
            {
              label: "Dịch vụ",
              cell: (r) => (
                <>
                  <strong>{r.name}</strong>
                  <small>{branchName(r.branchId)}</small>
                </>
              ),
            },
            { label: "Cách tính", cell: (r) => labels[r.method] },
            { label: "Đơn giá", cell: (r) => money(r.unitPrice) },
            {
              label: "Áp dụng",
              cell: (r) => (r.isArchived ? "Đã ngừng" : "Đang dùng"),
            },
            ...(owner
              ? [
                  {
                    label: "",
                    cell: (r: Row) => (
                      <IconButton
                        title="Sửa đơn giá"
                        onClick={() => editFee(r)}
                      >
                        <Pencil size={16} />
                      </IconButton>
                    ),
                  },
                ]
              : []),
          ]}
        />
      </section>
      {owner && (
        <>
          <EmailRemindersPanel />
          <section className="panel below">
            <div className="panel-header">
              <div>
                <h2>Nhật ký gần đây</h2>
                <p>30 thao tác mới nhất trong hệ thống.</p>
              </div>
            </div>
            <Table
              rows={all("audit")}
              columns={[
                {
                  label: "Thời điểm",
                  cell: (r) =>
                    new Date(r.createdAt).toLocaleString("vi-VN", {
                      timeZone: "Asia/Ho_Chi_Minh",
                    }),
                },
                { label: "Người thao tác", cell: (r) => r.createdBy },
                { label: "Nội dung", cell: (r) => r.detail },
              ]}
            />
          </section>
        </>
      )}
    </>
  );
}
