// Chỉ dùng PostgreSQL nhúng trong bộ nhớ; không đọc connection string của app thật.
import assert from "node:assert/strict";
import { pbkdf2Sync, timingSafeEqual } from "node:crypto";
import { spawn } from "node:child_process";
import { once } from "node:events";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { PGlite } from "@electric-sql/pglite";
import { PGLiteSocketServer } from "@electric-sql/pglite-socket";

const root = fileURLToPath(new URL("../", import.meta.url));
const sql = (name) => readFileSync(resolve(root, "Database", name), "utf8");
const sample = sql("04_can_tho_sample.sql");
const marker = "cantho-demo-v1";
const tables = [
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
  "audit_entries",
];
const scalar = async (db, query) =>
  Object.values((await db.query(query)).rows[0])[0];
const count = (db, table) => scalar(db, `SELECT COUNT(*)::int FROM ${table}`);
const snapshot = async (db) =>
  Object.fromEntries(
    await Promise.all(
      tables.map(async (table) => [
        table,
        (await db.query(`SELECT * FROM ${table} ORDER BY 1, 2`)).rows,
      ]),
    ),
  );
let assertions = 0;
function equal(actual, expected, message) {
  assert.deepEqual(actual, expected, message);
  assertions++;
}
async function noRows(db, query, message) {
  equal((await db.query(query)).rows, [], message);
}
async function validate(db) {
  for (const [table, expected] of Object.entries({
    branches: 6,
    rooms: 36,
    tenants: 42,
    users: 49,
    contracts: 24,
    readings: 48,
    invoices: 54,
    invoice_items: 270,
    incidents: 24,
  })) {
    equal(
      await scalar(
        db,
        `SELECT COUNT(*)::int FROM ${table}${table === "invoice_items" ? "" : ` WHERE "CreatedBy" = '${marker}'`}`,
      ),
      expected,
      table,
    );
  }
  const users = (
    await db.query(`SELECT * FROM users WHERE "CreatedBy" = '${marker}'`)
  ).rows;
  equal(users.filter((u) => u.Role === "Manager").length, 7);
  equal(users.filter((u) => u.Role === "Tenant").length, 42);
  equal(users.filter((u) => u.Role === "Owner").length, 0);
  equal(
    new Set(users.map((u) => u.PasswordHash)).size,
    49,
    "Mỗi tài khoản có salt riêng",
  );
  for (const user of users) {
    const bytes = Buffer.from(user.PasswordHash, "base64");
    equal(bytes[0], 1);
    equal(bytes.readUInt32BE(1), 2);
    const iterations = bytes.readUInt32BE(5);
    const saltLength = bytes.readUInt32BE(9);
    const actual = pbkdf2Sync(
      "CanTho@123456",
      bytes.subarray(13, 13 + saltLength),
      iterations,
      bytes.length - 13 - saltLength,
      "sha512",
    );
    equal(
      timingSafeEqual(actual, bytes.subarray(13 + saltLength)),
      true,
      user.Username,
    );
  }
  await noRows(
    db,
    `SELECT i."Id" FROM invoices i JOIN contracts c ON c."Id"=i."ContractId" WHERE c."CreatedBy"='${marker}' AND i."Total" != (SELECT SUM("Amount") FROM invoice_items WHERE "InvoiceId"=i."Id")`,
    "Tổng hóa đơn bằng tổng chi tiết",
  );
  await noRows(
    db,
    `SELECT ii."Id" FROM invoice_items ii JOIN invoices i ON i."Id"=ii."InvoiceId" WHERE i."CreatedBy"='${marker}' AND ii."Amount" != ROUND(ii."Quantity"*ii."UnitPrice")`,
    "Thành tiền đúng số lượng × đơn giá",
  );
  await noRows(
    db,
    `SELECT i."Id" FROM invoices i WHERE i."CreatedBy"='${marker}' AND COALESCE((SELECT SUM("Amount") FROM payments WHERE "InvoiceId"=i."Id"),0)>i."Total"`,
    "Không thu vượt nợ",
  );
  await noRows(
    db,
    `SELECT i."Id" FROM invoices i JOIN payments p ON p."InvoiceId"=i."Id" WHERE i."CreatedBy"='${marker}' AND i."Status"='Cancelled'`,
    "Hóa đơn hủy chưa thu tiền",
  );
  await noRows(
    db,
    `SELECT c."Id" FROM contracts c WHERE c."CreatedBy"='${marker}' AND ((SELECT COUNT(*) FROM contract_tenants WHERE "ContractId"=c."Id" AND "IsRepresentative") != 1 OR (SELECT COUNT(*) FROM contract_tenants WHERE "ContractId"=c."Id") > (SELECT "Capacity" FROM rooms WHERE "Id"=c."RoomId"))`,
    "Đại diện/sức chứa",
  );
  await noRows(
    db,
    `SELECT ct."TenantId" FROM contract_tenants ct JOIN contracts c ON c."Id"=ct."ContractId" JOIN tenants t ON t."Id"=ct."TenantId" JOIN rooms r ON r."Id"=c."RoomId" WHERE c."CreatedBy"='${marker}' AND t."BranchId"!=r."BranchId"`,
    "Người thuê và phòng cùng khu",
  );
  await noRows(
    db,
    `SELECT ct."TenantId" FROM contract_tenants ct JOIN contracts c ON c."Id"=ct."ContractId" WHERE c."Status"='Active' GROUP BY ct."TenantId" HAVING COUNT(*)>1`,
    "Một người chỉ có một hợp đồng Active",
  );
  await noRows(
    db,
    `SELECT c."Id" FROM contracts c WHERE c."CreatedBy"='${marker}' AND (SELECT COALESCE(SUM(CASE WHEN "Type"='Received' THEN "Amount" ELSE -"Amount" END),0) FROM deposit_entries WHERE "ContractId"=c."Id") < 0`,
    "Số dư cọc không âm",
  );
  await noRows(
    db,
    `SELECT c."Id" FROM contracts c WHERE c."CreatedBy"='${marker}' AND c."Status"='Closed' AND ((SELECT SUM(CASE WHEN "Type"='Received' THEN "Amount" ELSE -"Amount" END) FROM deposit_entries WHERE "ContractId"=c."Id") != 0 OR EXISTS(SELECT 1 FROM invoices i WHERE i."ContractId"=c."Id" AND i."Status"='Issued' AND i."Total" != COALESCE((SELECT SUM("Amount") FROM payments WHERE "InvoiceId"=i."Id"),0)))`,
    "Hợp đồng Closed hết nợ và hoàn/xử lý hết cọc",
  );
  await noRows(
    db,
    `SELECT c."Id" FROM contracts c WHERE c."CreatedBy"='${marker}' AND (SELECT COALESCE(SUM("Amount"),0) FROM deposit_entries WHERE "ContractId"=c."Id" AND "Type"='Applied') != (SELECT COALESCE(SUM(p."Amount"),0) FROM payments p JOIN invoices i ON i."Id"=p."InvoiceId" WHERE i."ContractId"=c."Id" AND p."Method"='Deposit')`,
    "Cọc Applied khớp thanh toán Deposit",
  );
  await noRows(
    db,
    `SELECT cur."Id" FROM readings cur JOIN readings prev ON prev."ContractId"=cur."ContractId" AND make_date(prev."Year",prev."Month",1)=(make_date(cur."Year",cur."Month",1)-INTERVAL '1 month')::date WHERE cur."CreatedBy"='${marker}' AND (cur."ElectricityOld"!=prev."ElectricityNew" OR cur."WaterOld"!=prev."WaterNew")`,
    "Chỉ số liền kỳ",
  );
  await noRows(
    db,
    `SELECT i."Id" FROM incidents i WHERE i."CreatedBy"='${marker}' AND i."ReportedByTenantId" IS NOT NULL AND NOT EXISTS(SELECT 1 FROM contract_tenants ct JOIN contracts c ON c."Id"=ct."ContractId" WHERE ct."TenantId"=i."ReportedByTenantId" AND c."RoomId"=i."RoomId")`,
    "Sự cố đúng người thuê/phòng",
  );
  equal(
    await scalar(
      db,
      `SELECT COUNT(*)::int FROM rooms r WHERE r."CreatedBy"='${marker}' AND NOT r."IsMaintenance" AND NOT EXISTS (SELECT 1 FROM contracts c WHERE c."RoomId"=r."Id" AND c."Status"='Active')`,
    ),
    12,
    "12 phòng trống công khai",
  );
}

// Database trống: không phụ thuộc 02_sample.sql và không cần Owner mẫu mới.
const fresh = new PGlite();
try {
  await fresh.exec(sql("01_schema.sql"));
  await fresh.exec(sample);
  // Mô phỏng một phòng CT từ file 04 cũ; phòng khác đã được quản lý sửa thì phải giữ nguyên.
  await fresh.exec(
    `UPDATE rooms SET "Area"=NULL,"Floor"='',"RoomType"='',"Amenities"=ARRAY[]::text[],"AmenitiesConfirmed"=false,"ToiletType"='',"AccessHours"='',"LaundryType"='',"ParkingType"='',"MaxVehicles"=NULL,"PetsAllowed"=NULL,"ElectricVehiclesAllowed"=NULL,"HasWindow"=NULL,"HasBalcony"=NULL,"SuggestedDeposit"=NULL,"MinimumLeaseMonths"=NULL,"Neighborhood"='',"RentalConditions"='',"ContactName"='',"ContactPhone"='' WHERE "Id"=1; UPDATE rooms SET "Area"=77 WHERE "Id"=2;`,
  );
  const customRoom = (await fresh.query('SELECT * FROM rooms WHERE "Id"=2'))
    .rows[0];
  const beforeEnrichment = await snapshot(fresh);
  await fresh.exec(sql("06_can_tho_room_details.sql"));
  equal(
    Number(await scalar(fresh, 'SELECT "Area" FROM rooms WHERE "Id"=1')),
    22,
    "Bổ sung phòng CT cũ",
  );
  equal(
    (await fresh.query('SELECT * FROM rooms WHERE "Id"=2')).rows[0],
    customRoom,
    "Giữ chi tiết quản lý đã nhập",
  );
  const afterEnrichment = await snapshot(fresh);
  for (const table of tables.filter(
    (name) => !["rooms", "audit_entries"].includes(name),
  ))
    equal(
      afterEnrichment[table],
      beforeEnrichment[table],
      `Bổ sung chi tiết không sửa ${table}`,
    );
  await fresh.exec(sql("06_can_tho_room_details.sql"));
  equal(
    await snapshot(fresh),
    afterEnrichment,
    "File 06 chạy lại không reset hoặc nhân đôi",
  );
  await validate(fresh);
  const before = await snapshot(fresh);
  await fresh.exec(sample);
  equal(
    await snapshot(fresh),
    before,
    "Nạp lại không nhân đôi/ghi đè/lùi identity",
  );
} finally {
  await fresh.close();
}

// Database có mẫu cũ: giữ nguyên mọi dòng cũ, không phụ thuộc ID cố định.
const db = new PGlite();
try {
  await db.exec(sql("01_schema.sql"));
  await db.exec(sql("02_sample.sql"));
  const old = await snapshot(db);
  await db.exec(sample);
  const afterLoad = await snapshot(db);
  for (const table of tables) {
    equal(
      afterLoad[table].slice(0, old[table].length),
      old[table],
      `Giữ nguyên ${table} cũ`,
    );
  }
  equal(await count(db, "users"), 54);
  equal(await count(db, "rooms"), 44);
  await db.exec(
    `UPDATE users SET "FullName"='Tên đã sửa sau khi nạp' WHERE "Username"='ct_nk_07'`,
  );
  const beforeRepeat = await snapshot(db);
  await db.exec(sample);
  equal(
    await snapshot(db),
    beforeRepeat,
    "Nạp lại không reset thay đổi người dùng",
  );
  if (process.argv.includes("--api")) await apiChecks(db);
} finally {
  await db.close();
}

// Trùng tên có sẵn phải rollback toàn bộ, không để dữ liệu dang dở.
for (const collision of ["username", "branch"]) {
  const conflict = new PGlite();
  try {
    await conflict.exec(sql("01_schema.sql"));
    await conflict.exec(sql("02_sample.sql"));
    if (collision === "username")
      await conflict.exec(
        `UPDATE users SET "Username"='ct_ql_nk' WHERE "Id"=2`,
      );
    else
      await conflict.exec(
        `UPDATE branches SET "Name"='DVP Ninh Kiều - Khu trọ mẫu CT' WHERE "Id"=1`,
      );
    const before = await snapshot(conflict);
    await assert.rejects(conflict.exec(sample), /đã tồn tại/);
    assertions++;
    await conflict.exec("ROLLBACK;");
    equal(await snapshot(conflict), before, `Rollback khi trùng ${collision}`);
  } finally {
    await conflict.close();
  }
}
console.log(
  `PASS: ${assertions} kiểm tra data Cần Thơ${process.argv.includes("--api") ? " + HTTP API" : ""}; không sửa database ứng dụng.`,
);

async function apiChecks(database) {
  const dll = resolve(root, "Rental.Api/bin/Debug/net8.0/Rental.Api.dll");
  assert(existsSync(dll), "Cần build API trước khi dùng --api.");
  const sdk =
    process.env.RENTAL_DOTNET ||
    (existsSync(resolve(root, ".tools/dotnet/dotnet.exe"))
      ? resolve(root, ".tools/dotnet/dotnet.exe")
      : "dotnet");
  const directory = resolve(root, ".tools/test-data", `cantho-${Date.now()}`);
  mkdirSync(directory, { recursive: true });
  const socket = new PGLiteSocketServer({
    db: database,
    host: "127.0.0.1",
    port: 5546,
    maxConnections: 20,
  });
  await socket.start();
  let server;
  let logs = "";
  try {
    server = spawn(sdk, [dll, "--urls", "http://localhost:5261"], {
      cwd: resolve(root, "Rental.Api"),
      windowsHide: true,
      env: {
        ...process.env,
        ASPNETCORE_ENVIRONMENT: "Development",
        Hangfire__Enabled: "false",
        ConnectionStrings__Rental:
          "Host=127.0.0.1;Port=5546;Database=postgres;Username=postgres;SSL Mode=Disable;Pooling=false;Timeout=15;Command Timeout=30",
        Database__SeedDemo: "false",
        Database__DataDirectory: directory,
      },
    });
    let spawnError;
    server.on("error", (error) => {
      spawnError = error;
    });
    server.stdout.on("data", (chunk) => {
      logs += chunk;
    });
    server.stderr.on("data", (chunk) => {
      logs += chunk;
    });
    const base = "http://localhost:5261/api";
    let ready = false;
    for (let i = 0; i < 60; i++) {
      if (spawnError) throw spawnError;
      try {
        if ((await fetch(base + "/health")).ok) {
          ready = true;
          break;
        }
      } catch {}
      await new Promise((r) => setTimeout(r, 500));
    }
    assert(ready, "API chưa chạy: " + logs);
    async function request(path, cookie, expected = 200, body) {
      const response = await fetch(base + path, {
        method: body ? "POST" : "GET",
        headers: {
          "X-Rental-Request": "1",
          ...(cookie ? { Cookie: cookie } : {}),
          ...(body ? { "Content-Type": "application/json" } : {}),
        },
        body: body ? JSON.stringify(body) : undefined,
      });
      const bodyText = await response.text();
      let data = bodyText;
      if (bodyText) {
        try {
          data = JSON.parse(bodyText);
        } catch {
          /* 403 của middleware có thể không có JSON. */
        }
      }
      equal(response.status, expected, `${path}: ${JSON.stringify(data)}`);
      return { data, response };
    }
    async function login(username) {
      return (
        await request("/auth/login", null, 200, {
          username,
          password: "CanTho@123456",
        })
      ).response.headers
        .get("set-cookie")
        .split(";")[0];
    }
    for (const [username, expectedBranches] of [
      ["ct_ql_nk", 1],
      ["ct_ql_bt", 1],
      ["ct_ql_lienkhu", 3],
    ]) {
      const cookie = await login(username);
      const workspace = (await request("/workspace", cookie)).data;
      equal(workspace.branches.length, expectedBranches);
      equal(workspace.rooms.length, expectedBranches * 6);
      equal(workspace.tenants.length, expectedBranches * 7);
      equal(workspace.users, null);
      const ids = workspace.branches.map((b) => b.id);
      equal(
        workspace.rooms.every((r) => ids.includes(r.branchId)),
        true,
      );
    }
    const catalog = (await request("/public/rooms")).data;
    equal(
      catalog.rooms.filter((r) => r.branch.name.startsWith("DVP ")).length,
      12,
    );
    for (const [username, contractCount] of [
      ["ct_nk_01", 1],
      ["ct_nk_02", 1],
      ["ct_nk_03", 1],
      ["ct_nk_06", 1],
      ["ct_nk_07", 0],
    ]) {
      const cookie = await login(username);
      const portal = (await request("/tenant/workspace", cookie)).data;
      equal(portal.contracts.length, contractCount);
      await request("/workspace", cookie, 403);
      if (username === "ct_nk_01" || username === "ct_nk_02") {
        equal(
          portal.invoices.every((i) => i.outstanding === 0),
          true,
        );
        equal(portal.incidents.length, username === "ct_nk_01" ? 1 : 0);
      }
      if (username === "ct_nk_03") {
        equal(
          portal.invoices.filter((i) => i.status === "Cancelled").length,
          1,
        );
        equal(
          portal.invoices.some((i) => i.outstanding > 0),
          true,
        );
        equal(
          portal.contracts[0].deposit - portal.contracts[0].depositBalance,
          500000,
        );
      }
      if (username === "ct_nk_06") {
        equal(portal.contracts[0].status, "Closed");
        equal(portal.contracts[0].depositBalance, 0);
        equal(
          portal.invoices.every((i) => i.outstanding === 0),
          true,
        );
        await request("/tenant/incidents", cookie, 400, {
          contractId: portal.contracts[0].id,
          description: "Không được gửi vì hợp đồng đã đóng",
        });
      }
      if (username === "ct_nk_07") equal(portal.invoices.length, 0);
    }
  } finally {
    if (server && server.exitCode === null && server.pid) {
      const done = once(server, "exit");
      server.kill();
      await done;
    }
    writeFileSync(resolve(directory, "server.log"), logs);
    await socket.stop();
  }
}
