import { Search } from "lucide-react";
import { labels } from "../labels";

export function Toolbar({
  title,
  search,
  setSearch,
  status,
  setStatus,
  states,
}: {
  title: string;
  search: string;
  setSearch: (x: string) => void;
  status?: string;
  setStatus?: (x: string) => void;
  states?: string[];
}) {
  return (
    <div className="table-toolbar">
      <h2>{title}</h2>
      <div>
        <label className="search">
          <Search size={16} />
          <input
            placeholder="Tìm kiếm…"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            aria-label="Tìm kiếm trong danh sách"
          />
        </label>
        {states && (
          <select
            value={status}
            onChange={(e) => setStatus?.(e.target.value)}
            aria-label="Lọc trạng thái"
          >
            <option value="">Mọi trạng thái</option>
            {states.map((x) => (
              <option key={x} value={x}>
                {labels[x]}
              </option>
            ))}
          </select>
        )}
      </div>
    </div>
  );
}
