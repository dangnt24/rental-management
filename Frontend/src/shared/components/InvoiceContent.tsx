import type { Row } from "../types";
import { money, date, code } from "../formatters";
import { BrandLogo } from "./BrandLogo";

export function InvoiceContent({ bill }: { bill: Row }) {
  return (
    <div className="print-invoice">
      <div className="invoice-brand">
        <BrandLogo />
        <span>PHIẾU THU TIỀN PHÒNG</span>
      </div>
      {bill.invoice.status === "Cancelled" && (
        <div className="error">
          HÓA ĐƠN ĐÃ HỦY · {bill.invoice.cancellationReason}
        </div>
      )}
      <h1>
        Hóa đơn tháng {bill.invoice.month}/{bill.invoice.year}
      </h1>
      <p>
        {code("HĐN", bill.invoice.id)} · Hạn thanh toán:{" "}
        {date(bill.invoice.dueDate)}
      </p>
      <div className="invoice-parties">
        <div>
          <small>KHU TRỌ</small>
          <strong>{bill.branch}</strong>
          <span>{bill.address}</span>
        </div>
        <div>
          <small>NGƯỜI THUÊ</small>
          <strong>{bill.tenant}</strong>
          <span>Phòng {bill.room}</span>
        </div>
      </div>
      <table>
        <thead>
          <tr>
            <th>Khoản thu</th>
            <th>Số lượng</th>
            <th>Đơn giá</th>
            <th>Thành tiền</th>
          </tr>
        </thead>
        <tbody>
          {bill.invoice.items.map((x: Row) => (
            <tr key={x.id}>
              <td>{x.description}</td>
              <td>{x.quantity}</td>
              <td>{money(x.unitPrice)}</td>
              <td>{money(x.amount)}</td>
            </tr>
          ))}
        </tbody>
      </table>
      <div className="invoice-totals">
        <p>
          <span>Tổng phải thu</span>
          <strong>{money(bill.invoice.total)}</strong>
        </p>
        <p>
          <span>Đã thanh toán</span>
          <strong>{money(bill.paid)}</strong>
        </p>
        <p>
          <span>Còn phải thanh toán</span>
          <strong>
            {money(bill.invoice.status === "Cancelled" ? 0 : bill.outstanding)}
          </strong>
        </p>
      </div>
      <small className="muted">
        Tiền cọc được theo dõi riêng. Phiếu này phục vụ đối soát tiền phòng,
        không phải hóa đơn thuế.
      </small>
    </div>
  );
}
