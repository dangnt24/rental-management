// Tạo dữ liệu hư cấu và hash tương thích ASP.NET Identity V3 (PBKDF2-SHA512).
import { pbkdf2Sync } from "node:crypto";
import { writeFileSync, mkdirSync } from "node:fs";
import { fileURLToPath } from "node:url";
const output = fileURLToPath(
  new URL("../Database/02_sample.sql", import.meta.url),
);
const sql = [
  "-- Dữ liệu hư cấu cho bản demo tháng 10/2026. Chạy sau 01_schema.sql.",
  "-- Tài khoản: admin / Demo@123456; manager / Demo@123456 (chỉ khu An Cư).",
  "-- manager2 chỉ khu Bình An. Đổi mật khẩu trước khi dùng dữ liệu thực.",
  "-- Chạy bằng psql --single-transaction -v ON_ERROR_STOP=1 -f 02_sample.sql.",
];
const quote = (v) =>
  v === null
    ? "NULL"
    : typeof v === "boolean"
      ? String(v)
      : typeof v === "number"
        ? String(v)
        : "'" + String(v).replaceAll("'", "''") + "'";
const tables = new Set();
function insert(table, rows, entity = true) {
  tables.add(table);
  for (const row of rows) {
    const record = entity
      ? {
          ...row,
          CreatedAt: "2026-10-01T00:00:00Z",
          CreatedBy: "demo",
          IsArchived: false,
        }
      : row;
    sql.push(
      `INSERT INTO "${table}" (${Object.keys(record)
        .map((k) => `"${k}"`)
        .join(
          ", ",
        )}) VALUES (${Object.values(record).map(quote).join(", ")}) ON CONFLICT DO NOTHING;`,
    );
  }
}
const salt = Buffer.from("rental-demo-salt!");
const header = Buffer.alloc(13);
header[0] = 1;
header.writeUInt32BE(2, 1);
header.writeUInt32BE(100000, 5);
header.writeUInt32BE(salt.length, 9);
const hash = Buffer.concat([
  header,
  salt,
  pbkdf2Sync("Demo@123456", salt, 100000, 32, "sha512"),
]).toString("base64");
insert("branches", [
  {
    Id: 1,
    Name: "Khu trọ An Cư",
    Address: "12 Đường Hoa, TP. Hồ Chí Minh (địa chỉ mẫu)",
  },
  {
    Id: 2,
    Name: "Khu trọ Bình An",
    Address: "25 Đường Nắng, TP. Hồ Chí Minh (địa chỉ mẫu)",
  },
]);
insert("users", [
  {
    Id: 1,
    Username: "admin",
    FullName: "Chủ trọ demo",
    PasswordHash: hash,
    Role: "Owner",
    IsActive: true,
  },
  {
    Id: 2,
    Username: "manager",
    FullName: "Quản lý An Cư",
    PasswordHash: hash,
    Role: "Manager",
    IsActive: true,
  },
  {
    Id: 3,
    Username: "manager2",
    FullName: "Quản lý Bình An",
    PasswordHash: hash,
    Role: "Manager",
    IsActive: true,
  },
]);
insert(
  "user_branches",
  [
    { UserId: 2, BranchId: 1 },
    { UserId: 3, BranchId: 2 },
  ],
  false,
);
insert(
  "rooms",
  [
    [1, 1, "P.101", 3000000, 3, false],
    [2, 1, "P.102", 2800000, 2, false],
    [3, 1, "P.103", 2500000, 2, false],
    [4, 1, "P.104", 3200000, 3, true],
    [5, 1, "P.105", 3000000, 2, false],
    [6, 2, "A.01", 2400000, 2, false],
    [7, 2, "A.02", 2600000, 2, false],
    [8, 2, "A.03", 2800000, 3, false],
  ].map(([Id, BranchId, Name, Price, Capacity, IsMaintenance]) => ({
    Id,
    BranchId,
    Name,
    Price,
    Capacity,
    IsMaintenance,
    Description: IsMaintenance
      ? "Đang sơn sửa, chưa nhận khách."
      : "Phòng thoáng, có gác và khu bếp riêng.",
  })),
);
insert(
  "tenants",
  [
    [1, 1, "Nguyễn Minh Anh", "0900000001"],
    [2, 1, "Trần Hoài Nam", "0900000002"],
    [3, 1, "Lê Thanh Thảo", "0900000003"],
    [4, 2, "Phạm Hải Đăng", "0900000004"],
    [5, 1, "Võ Thu Hà", "0900000005"],
    [6, 1, "Đỗ Bảo Ngọc", "0900000006"],
    [7, 2, "Bùi Gia Huy", "0900000007"],
  ].map(([Id, BranchId, FullName, Phone]) => ({
    Id,
    BranchId,
    FullName,
    Phone,
    IdentityNumber: `DEMO-${String(Id).padStart(4, "0")}`,
    Address: "Địa chỉ hư cấu phục vụ chạy thử",
  })),
);
insert("users", [
  {
    Id: 4,
    Username: "tenant",
    FullName: "Nguyễn Minh Anh",
    PasswordHash: hash,
    Role: "Tenant",
    TenantId: 1,
    IsActive: true,
  },
  {
    Id: 5,
    Username: "tenant2",
    FullName: "Phạm Hải Đăng",
    PasswordHash: hash,
    Role: "Tenant",
    TenantId: 4,
    IsActive: true,
  },
]);
insert(
  "contracts",
  [
    [1, 1, "2026-10-01", "2027-09-30", 3000000, 3000000, "Active", null],
    [2, 2, "2026-10-01", "2027-03-31", 2800000, 2800000, "Active", null],
    [3, 6, "2026-10-01", "2026-10-31", 2400000, 2400000, "Active", null],
    [
      4,
      3,
      "2026-08-01",
      "2026-09-30",
      2500000,
      2500000,
      "Closed",
      "2026-09-30",
    ],
  ].map(
    ([Id, RoomId, StartDate, EndDate, Rent, Deposit, Status, ClosedDate]) => ({
      Id,
      RoomId,
      StartDate,
      EndDate,
      Rent,
      Deposit,
      Status,
      ClosedDate,
      Note: "Hợp đồng mẫu; tiền thuê tính đủ tháng.",
    }),
  ),
);
insert(
  "contract_tenants",
  [
    { ContractId: 1, TenantId: 1, IsRepresentative: true },
    { ContractId: 1, TenantId: 2, IsRepresentative: false },
    { ContractId: 2, TenantId: 3, IsRepresentative: true },
    { ContractId: 3, TenantId: 4, IsRepresentative: true },
    { ContractId: 4, TenantId: 5, IsRepresentative: true },
  ],
  false,
);
const fees = [
  [1, 1, "Điện", "Electricity", 3500],
  [2, 1, "Nước", "Water", 15000],
  [3, 1, "Internet", "Fixed", 100000],
  [4, 1, "Vệ sinh", "PerPerson", 20000],
  [5, 2, "Điện", "Electricity", 3500],
  [6, 2, "Nước", "Water", 15000],
  [7, 2, "Internet", "Fixed", 80000],
].map(([Id, BranchId, Name, Method, UnitPrice]) => ({
  Id,
  BranchId,
  Name,
  Method,
  UnitPrice,
}));
insert("fees", fees);
const readings = [
  {
    Id: 1,
    ContractId: 1,
    Year: 2026,
    Month: 10,
    ElectricityOld: 100,
    ElectricityNew: 220,
    WaterOld: 10,
    WaterNew: 18,
  },
  {
    Id: 2,
    ContractId: 2,
    Year: 2026,
    Month: 10,
    ElectricityOld: 200,
    ElectricityNew: 280,
    WaterOld: 20,
    WaterNew: 25,
  },
  {
    Id: 3,
    ContractId: 3,
    Year: 2026,
    Month: 10,
    ElectricityOld: 50,
    ElectricityNew: 120,
    WaterOld: 5,
    WaterNew: 11,
  },
  {
    Id: 4,
    ContractId: 4,
    Year: 2026,
    Month: 8,
    ElectricityOld: 0,
    ElectricityNew: 60,
    WaterOld: 0,
    WaterNew: 3,
  },
  {
    Id: 5,
    ContractId: 4,
    Year: 2026,
    Month: 9,
    ElectricityOld: 60,
    ElectricityNew: 130,
    WaterOld: 3,
    WaterNew: 7,
  },
];
insert("readings", readings);
let itemId = 1;
const allItems = [];
const invoices = [];
for (const r of readings) {
  const rent = [0, 3000000, 2800000, 2400000, 2500000][r.ContractId];
  const items = [
    {
      Description: "Tiền thuê phòng (đủ tháng)",
      Quantity: 1,
      UnitPrice: rent,
      Amount: rent,
    },
  ];
  for (const f of fees.filter(
    (f) => f.BranchId === (r.ContractId === 3 ? 2 : 1),
  )) {
    const quantity =
      f.Method === "Electricity"
        ? r.ElectricityNew - r.ElectricityOld
        : f.Method === "Water"
          ? r.WaterNew - r.WaterOld
          : f.Method === "PerPerson"
            ? r.ContractId === 1
              ? 2
              : 1
            : 1;
    items.push({
      Description: f.Name,
      Quantity: quantity,
      UnitPrice: f.UnitPrice,
      Amount: quantity * f.UnitPrice,
    });
  }
  invoices.push({
    Id: r.Id,
    ContractId: r.ContractId,
    Year: r.Year,
    Month: r.Month,
    DueDate: `${r.Year}-${String(r.Month).padStart(2, "0")}-10`,
    Total: items.reduce((s, x) => s + x.Amount, 0),
    Status: "Issued",
    CancellationReason: "",
  });
  allItems.push(...items.map((x) => ({ Id: itemId++, InvoiceId: r.Id, ...x })));
}
insert("invoices", invoices);
insert("invoice_items", allItems, false);
insert("payments", [
  {
    Id: 1,
    InvoiceId: 1,
    Amount: 3000000,
    Method: "Transfer",
    PaidDate: "2026-10-08",
    Note: "Thanh toán một phần; còn nợ điện nước và dịch vụ.",
  },
  {
    Id: 2,
    InvoiceId: 3,
    Amount: invoices[2].Total,
    Method: "Cash",
    PaidDate: "2026-10-09",
    Note: "Đã thu đủ.",
  },
  {
    Id: 3,
    InvoiceId: 4,
    Amount: invoices[3].Total,
    Method: "Transfer",
    PaidDate: "2026-08-09",
    Note: "Đã thu đủ tháng 8, hợp đồng cũ.",
  },
  {
    Id: 4,
    InvoiceId: 5,
    Amount: invoices[4].Total,
    Method: "Cash",
    PaidDate: "2026-09-09",
    Note: "Đã thu đủ trước khi trả phòng.",
  },
]);
insert("deposit_entries", [
  {
    Id: 1,
    ContractId: 1,
    Type: "Received",
    Amount: 3000000,
    Note: "Nhận đủ cọc",
  },
  {
    Id: 2,
    ContractId: 2,
    Type: "Received",
    Amount: 1500000,
    Note: "Còn thiếu 1.300.000 tiền cọc",
  },
  {
    Id: 3,
    ContractId: 3,
    Type: "Received",
    Amount: 2400000,
    Note: "Nhận đủ cọc",
  },
  {
    Id: 4,
    ContractId: 4,
    Type: "Received",
    Amount: 2500000,
    Note: "Nhận cọc hợp đồng cũ",
  },
  {
    Id: 5,
    ContractId: 4,
    Type: "Deducted",
    Amount: 200000,
    Note: "Sơn lại tường khi trả phòng",
  },
  {
    Id: 6,
    ContractId: 4,
    Type: "Refunded",
    Amount: 2300000,
    Note: "Đã hoàn tiền cọc",
  },
]);
insert("incidents", [
  {
    Id: 1,
    RoomId: 4,
    Description: "Sơn lại tường và kiểm tra đường nước",
    Status: "InProgress",
    Resolution: "Đã hẹn thợ sửa chữa",
    Cost: 400000,
  },
  {
    Id: 2,
    RoomId: 1,
    Description: "Vòi nước bếp bị rò",
    Status: "Open",
    Resolution: "",
    Cost: 0,
  },
  {
    Id: 3,
    RoomId: 6,
    Description: "Đèn hành lang hỏng",
    Status: "Resolved",
    Resolution: "Đã thay bóng đèn",
    Cost: 60000,
  },
]);
insert("audit_entries", [
  {
    Id: 1,
    Action: "demo.seed",
    Detail: "Khởi tạo dữ liệu hư cấu tháng 10/2026.",
  },
]);
sql.push("\n-- Đồng bộ identity PostgreSQL sau khi chèn ID mẫu.");
for (const table of tables) {
  if (["user_branches", "contract_tenants"].includes(table)) continue;
  sql.push(
    `SELECT setval(pg_get_serial_sequence('"${table}"', 'Id'), COALESCE((SELECT MAX("Id") FROM "${table}"), 1), EXISTS (SELECT 1 FROM "${table}"));`,
  );
}
mkdirSync(fileURLToPath(new URL("../Database", import.meta.url)), {
  recursive: true,
});
writeFileSync(output, sql.join("\n") + "\n");
console.log(output);
