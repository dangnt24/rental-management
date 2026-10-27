import { useState, useEffect } from "react";
import { ChevronLeft, ChevronRight, Search } from "lucide-react";
import type { Row, Column } from "../types";
import { IconButton } from "./IconButton";

export function Table({
  rows,
  columns,
  search = "",
  empty = "Chưa có dữ liệu phù hợp.",
}: {
  rows: Row[];
  columns: Column[];
  search?: string;
  empty?: string;
}) {
  const [page, setPage] = useState(1);
  const pageSize = 8;
  const filtered = rows.filter((row) =>
    JSON.stringify(row)
      .toLocaleLowerCase("vi")
      .includes(search.toLocaleLowerCase("vi")),
  );
  const totalPages = Math.max(1, Math.ceil(filtered.length / pageSize));
  const current = Math.min(page, totalPages);
  useEffect(() => setPage(1), [search]);
  return (
    <>
      <div className="table-scroll">
        <table>
          <thead>
            <tr>
              {columns.map((col, i) => (
                <th key={i}>{col.label}</th>
              ))}
            </tr>
          </thead>
          <tbody>
            {filtered
              .slice((current - 1) * pageSize, current * pageSize)
              .map((row, i) => (
                <tr key={row.id ?? i}>
                  {columns.map((col, j) => (
                    <td key={j}>{col.cell(row)}</td>
                  ))}
                </tr>
              ))}
          </tbody>
        </table>
        {filtered.length === 0 && (
          <div className="empty">
            <Search size={26} />
            <p>{empty}</p>
          </div>
        )}
      </div>
      <div className="pagination">
        <span>
          {filtered.length
            ? `${(current - 1) * pageSize + 1}–${Math.min(current * pageSize, filtered.length)}`
            : 0}{" "}
          / {filtered.length} mục
        </span>
        <div>
          <IconButton
            title="Trang trước"
            onClick={() => setPage(Math.max(1, current - 1))}
          >
            <ChevronLeft size={16} />
          </IconButton>
          <span>
            {current} / {totalPages}
          </span>
          <IconButton
            title="Trang sau"
            onClick={() => setPage(Math.min(totalPages, current + 1))}
          >
            <ChevronRight size={16} />
          </IconButton>
        </div>
      </div>
    </>
  );
}
