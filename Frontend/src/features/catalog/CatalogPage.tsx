import { useEffect, useRef, useState } from "react";
import {
  Building2,
  MapPin,
  Search,
  Users,
  ArrowUpRight,
  SlidersHorizontal,
  RotateCcw,
  X,
  ChevronUp,
  ChevronDown,
  Maximize2,
} from "lucide-react";
import type { Row, User } from "../../shared/types";
import { api } from "../../shared/api";
import { money } from "../../shared/formatters";
import { SiteHeader } from "../../shared/components/SiteHeader";
import { Modal } from "../../shared/components/Modal";
import { useInteractionGuard } from "../../shared/InteractionGuard";
import { RoomDetails } from "../rooms/RoomDetails";

export function CatalogPage({
  user,
  focusSearch = false,
}: {
  user: User | null;
  focusSearch?: boolean;
}) {
  const { confirm } = useInteractionGuard();
  const searchForm = useRef<HTMLFormElement>(null);
  const [filtersCollapsed, setFiltersCollapsed] = useState(false);
  function showSearch() {
    setFiltersCollapsed(false);
    searchForm.current?.scrollIntoView({ behavior: "smooth", block: "start" });
  }
  useEffect(() => {
    if (focusSearch) showSearch();
  }, [focusSearch]);
  const empty = {
    q: "",
    branchId: "",
    minPrice: "",
    maxPrice: "",
    capacity: "",
    sort: "priceAsc",
  };
  const [filters, setFilters] = useState(empty);
  const [query, setQuery] = useState("sort=priceAsc");
  const [data, setData] = useState<Row | null>(null);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(true);
  const [selected, setSelected] = useState<Row | null>(null);
  const [retry, setRetry] = useState(0);
  useEffect(() => {
    let current = true;
    setLoading(true);
    setError("");
    api("/public/rooms?" + query)
      .then((next) => {
        if (current) setData(next);
      })
      .catch((e) => {
        if (current) setError(e.message);
      })
      .finally(() => {
        if (current) setLoading(false);
      });
    return () => {
      current = false;
    };
  }, [query, retry]);
  function field(key: keyof typeof empty, value: string) {
    setFilters((old) => ({ ...old, [key]: value }));
  }
  function queryFor(values: typeof empty) {
    const params = new URLSearchParams();
    Object.entries(values).forEach(([key, value]) => {
      if (value.trim()) params.set(key, value.trim());
    });
    return params.toString();
  }
  const applied = new URLSearchParams(query);
  const summary = [
    applied.get("q") ? `“${applied.get("q")}”` : "",
    data?.branches.find(
      (branch: Row) => String(branch.id) === applied.get("branchId"),
    )?.name || "Tất cả khu trọ",
    applied.get("minPrice") || applied.get("maxPrice")
      ? `${applied.get("minPrice") ? money(Number(applied.get("minPrice"))) : "0 ₫"} – ${applied.get("maxPrice") ? money(Number(applied.get("maxPrice"))) : "không giới hạn"}/tháng`
      : "Không giới hạn giá",
    applied.get("capacity") ? `Từ ${applied.get("capacity")} người` : "",
    applied.get("sort") === "priceDesc"
      ? "Giá cao đến thấp"
      : applied.get("sort") === "name"
        ? "Theo tên phòng"
        : "Giá thấp đến cao",
  ]
    .filter(Boolean)
    .join(" · ");
  const photo = (room: Row, id: number) =>
    `/api/public/rooms/${room.id}/photos/${id}`;
  return (
    <div className="public-site">
      <SiteHeader user={user} roomListing />
      <main className="catalog-main">
        <section className="catalog-hero">
          <div>
            <span className="eyebrow">MỘT KHÔNG GIAN, MỘT KHỞI ĐẦU MỚI</span>
            <h1>
              Tìm một nơi ở.
              <br />
              <em>Thấy mình an cư.</em>
            </h1>
            <p>
              Khám phá phòng còn trống, so sánh giá và chọn không gian phù hợp
              với bạn.
            </p>
            <a
              className="button light"
              href="#room-list"
              onClick={(e) => {
                e.preventDefault();
                document
                  .getElementById("room-list")
                  ?.scrollIntoView({ behavior: "smooth" });
              }}
            >
              Khám phá phòng trống <ArrowUpRight size={17} />
            </a>
          </div>
          <div className="catalog-hero-art" aria-hidden="true">
            <Building2 size={150} strokeWidth={1} />
            <span>
              Chọn phòng vừa ý.
              <br />
              Bắt đầu cuộc sống mới.
            </span>
          </div>
        </section>
        <form
          id="room-search"
          ref={searchForm}
          className="catalog-filters panel"
          onSubmit={(e) => {
            e.preventDefault();
            setQuery(queryFor(filters));
            setRetry((x) => x + 1);
          }}
        >
          <div className="filter-heading">
            <div className="filter-heading-copy">
              <div>
                <SlidersHorizontal size={18} />
                <h2>Tìm phòng phù hợp</h2>
              </div>
              <p className="filter-summary" aria-live="polite">
                {summary}
              </p>
              {filtersCollapsed && queryFor(filters) !== query && (
                <p className="filter-draft-note">
                  Bạn có thay đổi bộ lọc chưa áp dụng.
                </p>
              )}
            </div>
            <button
              type="button"
              className="text-button"
              aria-expanded={!filtersCollapsed}
              aria-controls="room-filter-fields"
              onClick={() => setFiltersCollapsed((value) => !value)}
            >
              {filtersCollapsed ? (
                <ChevronDown size={16} />
              ) : (
                <ChevronUp size={16} />
              )}
              {filtersCollapsed ? "Mở bộ lọc" : "Thu gọn"}
            </button>
          </div>
          <div
            id="room-filter-fields"
            className="catalog-filter-body"
            hidden={filtersCollapsed}
          >
            <div className="catalog-filter-grid">
              <label className="catalog-search">
                Khu vực hoặc tên phòng
                <input
                  placeholder="Nhập địa chỉ, khu trọ, tên phòng…"
                  value={filters.q}
                  maxLength={200}
                  onChange={(e) => field("q", e.target.value)}
                />
              </label>
              <label>
                Khu trọ
                <select
                  value={filters.branchId}
                  onChange={(e) => field("branchId", e.target.value)}
                >
                  <option value="">Tất cả khu</option>
                  {data?.branches.map((b: Row) => (
                    <option key={b.id} value={b.id}>
                      {b.name}
                    </option>
                  ))}
                </select>
              </label>
              <label>
                Giá từ (đ/tháng)
                <input
                  type="number"
                  min={0}
                  step={100000}
                  value={filters.minPrice}
                  onChange={(e) => field("minPrice", e.target.value)}
                  placeholder="Không giới hạn"
                />
              </label>
              <label>
                Giá đến (đ/tháng)
                <input
                  type="number"
                  min={filters.minPrice || 0}
                  step={100000}
                  value={filters.maxPrice}
                  onChange={(e) => field("maxPrice", e.target.value)}
                  placeholder="Không giới hạn"
                />
              </label>
              <label>
                Số người ở
                <input
                  type="number"
                  min={1}
                  max={50}
                  value={filters.capacity}
                  onChange={(e) => field("capacity", e.target.value)}
                  placeholder="Bất kỳ"
                />
              </label>
              <label>
                Sắp xếp
                <select
                  value={filters.sort}
                  onChange={(e) => field("sort", e.target.value)}
                >
                  <option value="priceAsc">Giá thấp đến cao</option>
                  <option value="priceDesc">Giá cao đến thấp</option>
                  <option value="name">Tên phòng</option>
                </select>
              </label>
            </div>
            <div className="catalog-filter-actions">
              <button
                type="button"
                className="text-button"
                onClick={async () => {
                  if (
                    !(await confirm({
                      title: "Xóa toàn bộ bộ lọc?",
                      message:
                        "Các điều kiện tìm phòng sẽ được đặt lại về mặc định.",
                      confirmLabel: "Xóa bộ lọc",
                      danger: true,
                    }))
                  )
                    return;
                  setFilters(empty);
                  setQuery("sort=priceAsc");
                  setRetry((x) => x + 1);
                }}
              >
                <RotateCcw size={16} />
                Xóa bộ lọc
              </button>
              <button className="button" disabled={loading}>
                <Search size={17} />
                Tìm phòng
              </button>
            </div>
          </div>
        </form>
        <section id="room-list" aria-live="polite">
          <div className="catalog-results-heading">
            <div>
              <span className="eyebrow">CHỌN KHÔNG GIAN CỦA BẠN</span>
              <h2>Phòng đang sẵn sàng</h2>
            </div>
            <span>
              {loading
                ? "Đang tìm phòng…"
                : error
                  ? "Chưa tải được danh sách"
                  : `${data?.rooms.length || 0} phòng phù hợp`}
            </span>
          </div>
          {error ? (
            <div className="panel empty">
              <p className="error">{error}</p>
              <button
                className="button secondary"
                onClick={() => setRetry((x) => x + 1)}
              >
                Thử lại
              </button>
            </div>
          ) : loading ? (
            <div className="panel empty">Đang tải danh sách phòng…</div>
          ) : !data?.rooms.length ? (
            <div className="panel empty">
              <Search size={30} />
              <p>
                Chưa có phòng phù hợp. Hãy thử khu khác hoặc thay đổi khoảng
                giá.
              </p>
            </div>
          ) : (
            <div className="room-card-grid">
              {data.rooms.map((room: Row) => (
                <article className="room-card" key={room.id}>
                  <button
                    className="room-card-cover"
                    onClick={() => setSelected(room)}
                    aria-label={`Xem phòng ${room.name}`}
                  >
                    {room.photos.length ? (
                      <img
                        src={photo(room, room.photos[0].id)}
                        alt={`Phòng ${room.name}`}
                        loading="lazy"
                      />
                    ) : (
                      <div className="room-photo-placeholder">
                        <Building2 size={64} strokeWidth={1} />
                        <span>{room.branch.name}</span>
                      </div>
                    )}
                    <span className="availability-dot">Còn trống</span>
                  </button>
                  <div className="room-card-content">
                    <span className="eyebrow">{room.branch.name}</span>
                    <h3>Phòng {room.name}</h3>
                    <p className="room-address">
                      <MapPin size={15} />
                      {room.branch.address}
                    </p>
                    <p>
                      <Users size={15} />
                      Tối đa {room.capacity} người
                      {room.area != null && (
                        <>
                          <span>·</span>
                          <Maximize2 size={15} />
                          {Number(room.area).toLocaleString("vi-VN")} m²
                        </>
                      )}
                    </p>
                    <div className="room-card-footer">
                      <strong>
                        {money(room.price)}
                        <small>/tháng</small>
                      </strong>
                      <button
                        className="text-button"
                        onClick={() => setSelected(room)}
                      >
                        Chi tiết <ArrowUpRight size={17} />
                      </button>
                    </div>
                  </div>
                </article>
              ))}
            </div>
          )}
        </section>
        <footer className="catalog-footer">
          DVP Home · Từ một căn phòng, bắt đầu những ngày an tâm.
        </footer>
      </main>
      {selected && (
        <Modal
          title={`Phòng ${selected.name}`}
          wide
          close={() => setSelected(null)}
        >
          <RoomDetails room={selected} photoUrl={(id) => photo(selected, id)} />
          <footer>
            <button
              className="button secondary"
              onClick={() => setSelected(null)}
            >
              <X size={16} />
              Đóng
            </button>
          </footer>
        </Modal>
      )}
    </div>
  );
}
