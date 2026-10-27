// Sinh một file SQL tự chứa; không kết nối hoặc sửa database đang chạy.
import { pbkdf2Sync, randomBytes } from "node:crypto";
import { writeFileSync } from "node:fs";
import { canThoRoomDetails } from "./can-tho-room-details.mjs";

const password = "CanTho@123456";
const seed = "demo.cantho.2026-10.v1";
const createdBy = "cantho-demo-v1";
const stamp = (date) => `${date}T02:00:00Z`;
const areas = [
  [
    "nk",
    "Ninh Kiều",
    "Xuân Khánh",
    "Nguyễn Thị Thanh Hương",
    2600000,
    "Sinh viên, nhân viên văn phòng",
    "Đường 3 Tháng 2",
  ],
  [
    "ta",
    "Tân An",
    "Hưng Lợi",
    "Trần Quốc Bảo",
    2300000,
    "Sinh viên, người đi làm",
    "Đường 30 Tháng 4",
  ],
  [
    "ck",
    "Cái Khế",
    "Cái Khế",
    "Lê Thị Kim Ngân",
    2800000,
    "Nhân viên dịch vụ, hộ gia đình nhỏ",
    "Đường Trần Văn Khéo",
  ],
  [
    "bt",
    "Bình Thủy",
    "An Thới",
    "Phạm Văn Thành",
    1800000,
    "Công nhân, nhân viên kỹ thuật",
    "Đường Cách Mạng Tháng 8",
  ],
  [
    "cr",
    "Cái Răng",
    "Lê Bình",
    "Võ Thị Mỹ Duyên",
    2200000,
    "Nhân viên bán hàng, vợ chồng trẻ",
    "Đường Võ Tánh",
  ],
  [
    "om",
    "Ô Môn",
    "Châu Văn Liêm",
    "Đặng Minh Tuấn",
    1600000,
    "Công nhân, lao động địa phương",
    "Đường Trần Hưng Đạo",
  ],
].map(([code, ward, oldArea, manager, price, audience, street], index) => ({
  code,
  ward,
  oldArea,
  manager,
  price,
  audience,
  street,
  index,
  name: `DVP ${ward} - Khu trọ mẫu CT`,
}));
const names = [
  [
    "Nguyễn Hoàng Phúc",
    "Trần Ngọc Hân",
    "Lê Minh Khang",
    "Phạm Thị Bích Trâm",
    "Võ Thanh Tùng",
    "Đặng Thị Thu Thảo",
    "Bùi Gia Bảo",
  ],
  [
    "Trần Anh Duy",
    "Nguyễn Thị Quỳnh Như",
    "Võ Minh Tâm",
    "Lê Thị Thanh Trúc",
    "Phạm Quốc Huy",
    "Huỳnh Mỹ Linh",
    "Đỗ Bảo Châu",
  ],
  [
    "Lê Quốc Khánh",
    "Phan Thị Ngọc Ánh",
    "Nguyễn Hữu Đạt",
    "Trần Thị Hải Yến",
    "Võ Đức Hòa",
    "Bùi Thanh Loan",
    "Đặng Nhật Minh",
  ],
  [
    "Phạm Minh Thiện",
    "Nguyễn Thị Kiều Oanh",
    "Trần Thanh Sơn",
    "Huỳnh Thị Hồng Nhung",
    "Lê Anh Kiệt",
    "Võ Thị Thúy An",
    "Phan Tuấn Vũ",
  ],
  [
    "Võ Hoàng Nam",
    "Trần Thị Kim Chi",
    "Nguyễn Thành Đạt",
    "Lê Thị Phương Thảo",
    "Đặng Thanh Bình",
    "Phạm Ngọc Diễm",
    "Huỳnh Gia Hân",
  ],
  [
    "Đặng Hữu Nghĩa",
    "Võ Thị Ngọc Mai",
    "Nguyễn Minh Trí",
    "Trần Thị Cẩm Tú",
    "Lê Văn Hiếu",
    "Phan Thị Mỹ Tiên",
    "Bùi Hoàng Long",
  ],
];
const hometowns = [
  "xã Phong Điền, TP. Cần Thơ",
  "phường Thốt Nốt, TP. Cần Thơ",
  "phường Ô Môn, TP. Cần Thơ",
  "phường Bình Thủy, TP. Cần Thơ",
  "phường Cái Răng, TP. Cần Thơ",
  "phường Ninh Kiều, TP. Cần Thơ",
  "phường Tân An, TP. Cần Thơ",
];
const data = Object.fromEntries(
  [
    "branches",
    "rooms",
    "tenants",
    "users",
    "user_branches",
    "fees",
    "contracts",
    "contract_tenants",
    "readings",
    "invoices",
    "invoice_items",
    "payments",
    "deposit_entries",
    "incidents",
  ].map((name) => [name, []]),
);
const add = (table, record, date = "2026-08-01") => {
  const entity = ![
    "user_branches",
    "contract_tenants",
    "invoice_items",
  ].includes(table);
  data[table].push(
    entity
      ? {
          ...record,
          CreatedAt: stamp(date),
          CreatedBy: createdBy,
          IsArchived: false,
        }
      : record,
  );
};
function hashPassword() {
  const salt = randomBytes(16);
  const header = Buffer.alloc(13);
  header[0] = 1;
  header.writeUInt32BE(2, 1); // ASP.NET Identity V3, HMAC-SHA512.
  header.writeUInt32BE(100000, 5);
  header.writeUInt32BE(salt.length, 9);
  return Buffer.concat([
    header,
    salt,
    pbkdf2Sync(password, salt, 100000, 32, "sha512"),
  ]).toString("base64");
}
function account(username, fullName, role, tenantKey = null) {
  add(
    "users",
    {
      key: username,
      Username: username,
      FullName: fullName,
      PasswordHash: hashPassword(),
      Role: role,
      IsActive: true,
      TenantId: tenantKey,
    },
    "2026-10-27",
  );
}
let serial = 0;
for (const a of areas) {
  const key = a.code;
  add("branches", {
    key,
    Name: a.name,
    Address: `Hẻm mô phỏng CT-${a.index + 1}, khu vực ${a.street}, phường ${a.ward}, TP. Cần Thơ (địa chỉ hư cấu; khu vực ${a.oldArea} trước đây)`,
  });
  account(`ct_ql_${key}`, a.manager, "Manager");
  add("user_branches", { UserId: `ct_ql_${key}`, BranchId: key });
  for (let n = 1; n <= 6; n++) {
    const price = a.price + [0, 0, -200000, 300000, 100000, -100000, 0][n];
    const descriptions = [
      "",
      "Phòng 22 m², có gác lửng và bếp riêng; hai sinh viên ở ghép.",
      "Phòng 18 m², cửa sổ thoáng, nhà vệ sinh riêng; phù hợp ở một người.",
      "Phòng 26 m², có gác, sân phơi dùng chung; hai người đi làm ở cùng.",
      "Phòng 24 m² vừa bàn giao và vệ sinh; có bếp, gác và chỗ để xe.",
      "Phòng 20 m², lối đi riêng, cửa sổ và khu bếp; đang sẵn sàng nhận khách.",
      "Phòng 22 m² đang chống thấm và thay thiết bị vệ sinh, chưa nhận khách.",
    ];
    add("rooms", {
      key: `${key}_p${n}`,
      BranchId: key,
      Name: `P.10${n}`,
      Price: price,
      Capacity: n === 3 ? 3 : 2,
      IsMaintenance: n === 6,
      Description: `${descriptions[n]} Nhóm khách phù hợp: ${a.audience}. Nội dung và tiện ích giả lập.`,
      ...canThoRoomDetails(a, n, price),
    });
  }
  for (let n = 1; n <= 7; n++) {
    const tenantKey = `${key}_t${n}`;
    serial++;
    add("tenants", {
      key: tenantKey,
      BranchId: key,
      FullName: names[a.index][n - 1],
      Phone: `CT-DEMO-${String(serial).padStart(3, "0")}`,
      IdentityNumber: `CT-DEMO-CCCD-${String(serial).padStart(4, "0")}`,
      Address: `Địa chỉ cư trú mô phỏng CT-${serial}, ${hometowns[n - 1]} (hư cấu)`,
    });
    account(
      `ct_${key}_${String(n).padStart(2, "0")}`,
      names[a.index][n - 1],
      "Tenant",
      tenantKey,
    );
  }
  for (const [suffix, Name, Method, UnitPrice] of [
    ["electric", "Điện", "Electricity", 3500],
    ["water", "Nước", "Water", 12000],
    ["internet", "Internet", "Fixed", a.index < 3 ? 80000 : 60000],
    ["garbage", "Rác và vệ sinh", "PerPerson", 15000],
  ])
    add("fees", {
      key: `${key}_${suffix}`,
      BranchId: key,
      Name,
      Method,
      UnitPrice,
    });

  for (let n = 1; n <= 4; n++) {
    const contractKey = `${key}_hd${n}`;
    const rent = data.rooms.find((r) => r.key === `${key}_p${n}`).Price;
    const closed = n === 4;
    const memberNumbers = [null, [1, 2], [3], [4, 5], [6]][n];
    add(
      "contracts",
      {
        key: contractKey,
        RoomId: `${key}_p${n}`,
        StartDate: closed ? "2026-08-01" : "2026-09-01",
        EndDate: closed ? "2026-09-30" : n === 3 ? "2026-10-31" : "2027-08-31",
        ClosedDate: closed ? "2026-09-30" : null,
        Rent: rent,
        Deposit: rent,
        Status: closed ? "Closed" : "Active",
        Note: closed
          ? "Đã trả phòng, thanh toán đủ tháng 8-9, bù trừ 200.000đ từ cọc vào hóa đơn cuối, khấu trừ 150.000đ vệ sinh và hoàn phần cọc còn lại."
          : n === 1
            ? "Hai sinh viên ở ghép; một người đại diện, cả hai có tài khoản để xem cùng hợp đồng."
            : n === 2
              ? "Một người đi làm; đã nộp một phần cọc, hóa đơn tháng 10 trả hai đợt và còn nợ."
              : "Hai người đi làm; hợp đồng sắp hết hạn, hóa đơn tháng 10 chưa thanh toán.",
      },
      closed ? "2026-08-01" : "2026-09-01",
    );
    memberNumbers.forEach((tenant, index) =>
      add("contract_tenants", {
        ContractId: contractKey,
        TenantId: `${key}_t${tenant}`,
        IsRepresentative: index === 0,
      }),
    );
    add(
      "deposit_entries",
      {
        key: `${contractKey}_received`,
        ContractId: contractKey,
        Type: "Received",
        Amount: n === 2 ? rent - 500000 : rent,
        Note:
          n === 2
            ? "Đã nhận một phần tiền cọc, còn thiếu 500.000đ theo thỏa thuận."
            : "Đã nhận đủ tiền cọc lúc nhận phòng.",
      },
      closed ? "2026-08-01" : "2026-09-01",
    );
    let electricity = 250 + a.index * 193 + n * 31;
    let water = 20 + a.index * 17 + n * 3;
    for (const month of closed ? [8, 9] : [9, 10]) {
      const period = `2026-${String(month).padStart(2, "0")}`;
      const billKey = `${contractKey}_${period}`;
      const electricityUse =
        57 + a.index * 7 + n * 17 + (month === 10 ? 11 : 0);
      const waterUse =
        3 + memberNumbers.length * 2 + (a.index % 2) + (month === 10 ? 1 : 0);
      add(
        "readings",
        {
          key: billKey,
          ContractId: contractKey,
          Year: 2026,
          Month: month,
          ElectricityOld: electricity,
          ElectricityNew: electricity + electricityUse,
          WaterOld: water,
          WaterNew: water + waterUse,
        },
        `${period}-25`,
      );
      electricity += electricityUse;
      water += waterUse;
      const items = [
        {
          Description: "Tiền thuê phòng (đủ tháng)",
          Quantity: 1,
          UnitPrice: rent,
          Amount: rent,
        },
      ];
      for (const fee of data.fees.filter((f) => f.BranchId === key)) {
        const quantity =
          fee.Method === "Electricity"
            ? electricityUse
            : fee.Method === "Water"
              ? waterUse
              : fee.Method === "PerPerson"
                ? memberNumbers.length
                : 1;
        items.push({
          Description: fee.Name,
          Quantity: quantity,
          UnitPrice: fee.UnitPrice,
          Amount: quantity * fee.UnitPrice,
        });
      }
      const total = items.reduce((sum, i) => sum + i.Amount, 0);
      // Giữ một hóa đơn hủy và hóa đơn thay thế cùng kỳ để đọc được lịch sử.
      if (!closed && n === 2 && month === 10) {
        add(
          "invoices",
          {
            key: `${billKey}_cancelled`,
            ContractId: contractKey,
            Year: 2026,
            Month: month,
            DueDate: `${period}-26`,
            Total: total + 15000,
            Status: "Cancelled",
            CancellationReason:
              "Nhập nhầm số người tính phí vệ sinh từ 1 thành 2; hủy khi chưa thu tiền và lập hóa đơn thay thế.",
          },
          `${period}-25`,
        );
        items.forEach((item, index) =>
          add("invoice_items", {
            key: `${billKey}_cancelled_${index}`,
            InvoiceId: `${billKey}_cancelled`,
            ...item,
            ...(index === items.length - 1
              ? { Quantity: 2, Amount: 30000 }
              : {}),
          }),
        );
      }
      add(
        "invoices",
        {
          key: billKey,
          ContractId: contractKey,
          Year: 2026,
          Month: month,
          DueDate: `${period}-${n === 2 ? "26" : "28"}`,
          Total: total,
          Status: "Issued",
          CancellationReason: "",
        },
        `${period}-25`,
      );
      items.forEach((item, index) =>
        add("invoice_items", {
          key: `${billKey}_${index}`,
          InvoiceId: billKey,
          ...item,
        }),
      );
      if (closed && month === 9) {
        add(
          "payments",
          {
            key: `${billKey}_cash`,
            InvoiceId: billKey,
            Amount: total - 200000,
            Method: "Transfer",
            PaidDate: "2026-09-29",
            Note: "Thanh toán hóa đơn cuối, phần còn lại bù trừ từ cọc khi trả phòng.",
          },
          "2026-09-29",
        );
        add(
          "payments",
          {
            key: `${billKey}_deposit`,
            InvoiceId: billKey,
            Amount: 200000,
            Method: "Deposit",
            PaidDate: "2026-09-30",
            Note: "Bù trừ 200.000đ tiền cọc vào hóa đơn cuối.",
          },
          "2026-09-30",
        );
        for (const [Type, Amount, Note] of [
          [
            "Applied",
            200000,
            "Bù trừ vào hóa đơn tháng 9; có payment Deposit tương ứng.",
          ],
          [
            "Deducted",
            150000,
            "Khấu trừ vệ sinh khi bàn giao, đã thống nhất với người thuê.",
          ],
          [
            "Refunded",
            rent - 350000,
            "Hoàn phần cọc còn lại sau bù trừ và khấu trừ.",
          ],
        ])
          add(
            "deposit_entries",
            {
              key: `${contractKey}_${Type}`,
              ContractId: contractKey,
              Type,
              Amount,
              Note,
            },
            "2026-09-30",
          );
      } else if (month !== 10 || n === 1) {
        add(
          "payments",
          {
            key: `${billKey}_paid`,
            InvoiceId: billKey,
            Amount: total,
            Method: a.index % 2 ? "Cash" : "Transfer",
            PaidDate: `${period}-26`,
            Note: "Đã thanh toán đủ tiền phòng và dịch vụ của kỳ.",
          },
          `${period}-26`,
        );
      } else if (n === 2) {
        for (const [part, amount, day, method] of [
          [1, 500000, "25", "Cash"],
          [2, rent - 800000, "26", "Transfer"],
        ])
          add(
            "payments",
            {
              key: `${billKey}_part${part}`,
              InvoiceId: billKey,
              Amount: amount,
              Method: method,
              PaidDate: `${period}-${day}`,
              Note: `Thanh toán đợt ${part}; còn công nợ để đối soát.`,
            },
            `${period}-${day}`,
          );
      }
    }
  }
  for (const [n, reporter, status, description, resolution, cost, day] of [
    [
      1,
      1,
      "Open",
      "Vòi rửa chén nhỏ nước liên tục, nhờ quản lý kiểm tra giúp vào buổi chiều.",
      "",
      0,
      "24",
    ],
    [
      2,
      3,
      "InProgress",
      "Ổ điện cạnh bàn làm việc chập chờn khi cắm quạt.",
      "Đã ngắt ổ điện lỗi, hẹn thợ thay ổ vào chiều 28/10.",
      0,
      "25",
    ],
    [
      3,
      4,
      "Resolved",
      "Khóa cửa phòng khó xoay, cần kiểm tra ổ khóa.",
      "Đã vệ sinh, tra dầu và thay ruột khóa; người thuê xác nhận dùng bình thường.",
      120000,
      "20",
    ],
    [
      6,
      null,
      "InProgress",
      "Kiểm tra chống thấm và thay vòi sen trước khi cho thuê lại.",
      "Đã xử lý chống thấm, chờ kiểm tra khô tường trước khi mở phòng.",
      450000,
      "22",
    ],
  ])
    add(
      "incidents",
      {
        key: `${key}_sc${n}`,
        RoomId: `${key}_p${n}`,
        ReportedByTenantId: reporter ? `${key}_t${reporter}` : null,
        Description: description,
        Status: status,
        Resolution: resolution,
        Cost: cost,
      },
      `2026-10-${day}`,
    );
}
account("ct_ql_lienkhu", "Nguyễn Minh Quân", "Manager");
for (const BranchId of ["nk", "ta", "ck"])
  add("user_branches", { UserId: "ct_ql_lienkhu", BranchId });

// Mã key chỉ tồn tại trong file seed. ID thật do PostgreSQL cấp, liên kết qua bảng tạm.
const refs = {
  rooms: { BranchId: "branches" },
  tenants: { BranchId: "branches" },
  users: { TenantId: "tenants" },
  user_branches: { UserId: "users", BranchId: "branches" },
  fees: { BranchId: "branches" },
  contracts: { RoomId: "rooms" },
  contract_tenants: { ContractId: "contracts", TenantId: "tenants" },
  readings: { ContractId: "contracts" },
  invoices: { ContractId: "contracts" },
  invoice_items: { InvoiceId: "invoices" },
  payments: { InvoiceId: "invoices" },
  deposit_entries: { ContractId: "contracts" },
  incidents: { RoomId: "rooms", ReportedByTenantId: "tenants" },
};
const q = (v) => `'${v.replaceAll("'", "''")}'`;
const qi = (v) => `"${v}"`;
const lines = [
  "-- DVP HOME: DỮ LIỆU MẪU CẦN THƠ, kỳ 08–10/2026; sinh bằng tools/generate-can-tho-sample.mjs.",
  "-- Toàn bộ người, khu trọ, hẻm/số nhà, hồ sơ và mức tiền là HƯ CẤU; không phải giá thị trường/biểu giá điện nước.",
  "-- Tên phường tham chiếu nguồn Cần Thơ; tên khu vực cũ ghi chú để dễ nhận biết, không dùng tên quận cũ trong địa chỉ hành chính.",
  "-- Nguồn địa danh: https://pbgdpl.cantho.gov.vn/chi-tiet-103-don-vi-hanh-chinh-cua-thanh-pho-can-tho-sau-hop-nhat",
  "-- Điện thoại/CCCD dùng mã CT-DEMO cố ý không phải số thật; ảnh/file để trống, không tạo tham chiếu file không tồn tại.",
  "-- Bổ sung 6 khu, 36 phòng (18 đang thuê, 12 trống, 6 sửa), 42 hồ sơ người thuê, 7 Manager + 42 Tenant; không tạo Owner.",
  "-- Có 24 hợp đồng (18 Active, 6 Closed), 54 hóa đơn (48 Issued, 6 Cancelled), 24 sự cố.",
  "-- NẠP: đứng tại thư mục Source, chạy lệnh sau (file tự BEGIN/COMMIT):",
  "-- psql -h localhost -U postgres -d rental_management -v ON_ERROR_STOP=1 -f .\\Database\\04_can_tho_sample.sql",
  "-- Database trống: chạy 01_schema.sql rồi 02_sample.sql để có Owner admin trước; bộ này không tạo Owner.",
  "-- Database Source cũ: chạy 03_public_tenant.sql trước nếu chưa nâng cấp. Không dùng cho SQL V2 trong Document.",
  "-- Bản có chi tiết phòng: database Source hiện có cần chạy 05_room_details.sql trước file này.",
  "-- Nạp bổ sung, không UPDATE/DELETE/TRUNCATE dữ liệu cũ; ID lấy từ sequence, không gán cứng/chỉnh lùi sequence.",
  "-- Nạp lại thấy audit marker thì bỏ qua toàn bộ (không reset mật khẩu/khôi phục demo đã sửa).",
  "-- Nếu trùng tên đăng nhập hoặc tên khu có sẵn mà chưa có marker: báo lỗi và rollback toàn bộ.",
  "-- Đây là file bổ sung thủ công: SeedDemo/Start.ps1/Docker không tự nạp file này. Không thay 02_sample.sql.",
  "-- Chỉ tạo file chưa làm thay đổi database thật. Sau khi nạp: đăng xuất/đăng nhập hoặc tải lại trang.",
  `-- MẬT KHẨU DEMO CHUNG: ${password}; mỗi tài khoản có salt ngẫu nhiên và hash ASP.NET Identity V3 riêng.`,
  "-- DANH SÁCH QUẢN LÝ (mỗi tài khoản chỉ có quyền khu đã gán):",
  ...areas.map(
    (a) =>
      `-- ct_ql_${a.code} | ${a.manager} | ${a.name} (${a.oldArea} trước đây)`,
  ),
  "-- ct_ql_lienkhu | Nguyễn Minh Quân | 3 khu Ninh Kiều + Tân An + Cái Khế.",
  "-- DANH SÁCH NGƯỜI THUÊ (ct_<mã khu>_<số thứ tự>):",
  "-- 01+02: cùng P.101, 01 đại diện; hóa đơn đã trả đủ; 01 có yêu cầu sửa Open.",
  "-- 03: P.102, thiếu 500.000đ cọc, hóa đơn T10 trả 2 đợt còn nợ/quá hạn; có lịch sử hủy hóa đơn; sửa InProgress.",
  "-- 04+05: cùng P.103, 04 đại diện; chưa trả T10, sắp hết hạn 31/10; 04 có sửa chữa Resolved.",
  "-- 06: đã trả P.104 ngày 30/09, xem lịch sử hóa đơn/cọc/hoàn cọc; không được gửi sự cố mới từ hợp đồng Closed.",
  "-- 07: mới tạo hồ sơ, chưa có hợp đồng; portal trống đúng nghiệp vụ.",
  ...areas.flatMap((a) =>
    names[a.index].map(
      (name, i) =>
        `-- ct_${a.code}_${String(i + 1).padStart(2, "0")} | ${name} | ${a.ward} | ${i < 2 ? "P.101" : i === 2 ? "P.102" : i < 5 ? "P.103" : i === 5 ? "đã trả P.104" : "chưa thuê"}`,
    ),
  ),
  "-- Khách chưa đăng nhập: thấy 12 phòng trống của bộ này (cộng phòng trống dữ liệu cũ nếu có).",
  "-- Có thể đăng nhập ngay ct_ql_nk / ct_nk_01 / ct_nk_03 / ct_nk_06 / ct_nk_07 để xem các tình huống khác nhau.",
  "",
  "BEGIN;",
  `SELECT pg_advisory_xact_lock(hashtext(${q(seed)}));`,
  "CREATE TEMP TABLE ct_seed_ids (entity text, seed_key text, actual_id integer, PRIMARY KEY (entity, seed_key)) ON COMMIT DROP;",
  "DO $ct_seed$",
  "DECLARE",
  `  dataset jsonb := $ct_data$${JSON.stringify(data, null, 2)}$ct_data$::jsonb;`,
  "  rec jsonb; new_id integer;",
  "BEGIN",
  `  IF EXISTS (SELECT 1 FROM audit_entries WHERE "Action" = ${q(seed)}) THEN`,
  "    RAISE NOTICE 'Bộ dữ liệu Cần Thơ này đã được nạp; bỏ qua, không ghi đè.';",
  "    RETURN;",
  "  END IF;",
  "  IF EXISTS (SELECT 1 FROM users u JOIN jsonb_array_elements(dataset->'users') d ON lower(u.\"Username\") = lower(d->>'Username')) THEN",
  "    RAISE EXCEPTION 'Tên đăng nhập CT đã tồn tại; không sửa dữ liệu cũ. Kiểm tra danh sách tài khoản trước khi nạp.';",
  "  END IF;",
  "  IF EXISTS (SELECT 1 FROM branches b JOIN jsonb_array_elements(dataset->'branches') d ON b.\"Name\" = d->>'Name') THEN",
  "    RAISE EXCEPTION 'Tên khu trọ mẫu CT đã tồn tại; không ghép nhầm vào khu cũ. Kiểm tra database trước khi nạp.';",
  "  END IF;",
];
for (const [table, rows] of Object.entries(data)) {
  const columns = Object.keys(rows[0]).filter((column) => column !== "key");
  const refValues = Object.entries(refs[table] || {})
    .map(
      ([column, target]) =>
        `${q(column)}, (SELECT actual_id FROM ct_seed_ids WHERE entity = ${q(target)} AND seed_key = rec->>${q(column)})`,
    )
    .join(", ");
  lines.push(
    `  -- ${table}: ${rows.length} dòng.`,
    `  FOR rec IN SELECT value FROM jsonb_array_elements(dataset->${q(table)}) LOOP`,
  );
  const json = `(rec - 'key')${refValues ? ` || jsonb_build_object(${refValues})` : ""}`;
  const identity = columns.includes("CreatedAt") || table === "invoice_items";
  lines.push(
    `    INSERT INTO ${qi(table)} (${columns.map(qi).join(", ")})`,
    `    SELECT ${columns.map((c) => `x.${qi(c)}`).join(", ")} FROM jsonb_populate_record(NULL::${qi(table)}, ${json}) x${identity ? ' RETURNING "Id" INTO new_id' : ""};`,
  );
  if (identity)
    lines.push(
      `    INSERT INTO ct_seed_ids VALUES (${q(table)}, rec->>'key', new_id);`,
    );
  lines.push("  END LOOP;");
}
lines.push(
  `  INSERT INTO audit_entries ("Action", "Detail", "CreatedAt", "CreatedBy", "IsArchived") VALUES (${q(seed)}, 'Nạp dữ liệu hư cấu Cần Thơ: 6 khu, 36 phòng, 42 hồ sơ, 7 Manager, 42 Tenant; kỳ 08–10/2026.', NOW(), ${q(createdBy)}, false);`,
  "  RAISE NOTICE 'Đã nạp xong bộ dữ liệu mẫu Cần Thơ.';",
  "END",
  "$ct_seed$;",
  "COMMIT;",
  "",
  "-- Kiểm tra tài khoản vừa nạp (không xuất hash mật khẩu):",
  `SELECT "Username", "FullName", "Role", "IsActive" FROM users WHERE "CreatedBy" = ${q(createdBy)} ORDER BY "Role", "Username";`,
  "",
);
const output = new URL("../Database/04_can_tho_sample.sql", import.meta.url);
writeFileSync(output, lines.join("\n"), "utf8");
// Bổ sung đúng các phòng CT đã nạp bản cũ, không sửa thông tin quản lý đã nhập.
const detailColumns = Object.keys(canThoRoomDetails(areas[0], 1, 0));
const detailData = data.rooms.map((room) => ({
  branchName: areas.find((area) => area.code === room.BranchId).name,
  roomName: room.Name,
  details: Object.fromEntries(
    detailColumns.map((column) => [column, room[column]]),
  ),
}));
const emptyChecks = detailColumns
  .map((column) =>
    column === "Amenities"
      ? 'cardinality(r."Amenities")=0'
      : column === "AmenitiesConfirmed"
        ? 'NOT r."AmenitiesConfirmed"'
        : typeof detailData[0].details[column] === "string"
          ? `r.${qi(column)}=''`
          : `r.${qi(column)} IS NULL`,
  )
  .join(" AND ");
const detailSql = [
  "-- Bổ sung chi tiết HƯ CẤU cho 36 phòng của bộ CT đã nạp bản cũ. Chạy sau 05_room_details.sql.",
  "-- Không sửa giá phòng, hợp đồng, thanh toán hoặc thông tin chi tiết quản lý đã nhập.",
  "-- Chỉ cập nhật phòng/khu có CreatedBy=cantho-demo-v1 và TOÀN BỘ chi tiết đang trống. Chạy lại không reset dữ liệu.",
  "BEGIN;",
  "SELECT pg_advisory_xact_lock(hashtext('demo.cantho.room-details.v1'));",
  "DO $ct_details$",
  "DECLARE rec jsonb; changed integer; total integer := 0;",
  "BEGIN",
  "IF EXISTS(SELECT 1 FROM audit_entries WHERE \"Action\"='demo.cantho.room-details.v1') THEN RETURN; END IF;",
  `FOR rec IN SELECT value FROM jsonb_array_elements($ct_room_data$${JSON.stringify(detailData, null, 2)}$ct_room_data$::jsonb) LOOP`,
  `UPDATE rooms r SET ${detailColumns.map((column) => `${qi(column)}=d.${qi(column)}`).join(", ")}`,
  "FROM branches b, jsonb_populate_record(NULL::rooms, rec->'details') d",
  `WHERE r."BranchId"=b."Id" AND r."CreatedBy"='cantho-demo-v1' AND b."CreatedBy"='cantho-demo-v1' AND b."Name"=rec->>'branchName' AND r."Name"=rec->>'roomName' AND ${emptyChecks};`,
  "GET DIAGNOSTICS changed = ROW_COUNT; total := total + changed;",
  "END LOOP;",
  'INSERT INTO audit_entries ("Action","Detail","CreatedAt","CreatedBy","IsArchived") VALUES (\'demo.cantho.room-details.v1\',\'Bổ sung thông tin phòng mẫu CT: \' || total || \' phòng; không thay đổi hồ sơ đã nhập.\',NOW(),\'cantho-demo-v1\',false);',
  "RAISE NOTICE 'Đã bổ sung chi tiết cho % phòng mẫu CT.', total;",
  "END",
  "$ct_details$;",
  "COMMIT;",
  "",
];
writeFileSync(
  new URL("../Database/06_can_tho_room_details.sql", import.meta.url),
  detailSql.join("\n"),
  "utf8",
);
console.log(
  `Đã sinh ${output.pathname}: ${data.users.length} tài khoản, ${data.rooms.length} phòng, ${data.invoices.length} hóa đơn.`,
);
