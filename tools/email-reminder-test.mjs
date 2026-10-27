import assert from "node:assert/strict";
import { createServer } from "node:net";
import { spawn, execFileSync } from "node:child_process";
import { mkdirSync, createWriteStream } from "node:fs";
import { resolve } from "node:path";

const root = resolve(import.meta.dirname, "..");
if (
  !/^rental_mail_test_[a-z0-9_]+$/.test(
    process.env.RENTAL_TEST_DATABASE || "",
  ) ||
  !process.env.RENTAL_TEST_CONNECTION
)
  throw new Error(
    "Dùng helper .tools/run-email-integration.ps1 để tạo database riêng.",
  );
const sql = (query) =>
  execFileSync(
    "C:/Program Files/PostgreSQL/18/bin/psql.exe",
    [
      "-X",
      "-q",
      "-At",
      "-v",
      "ON_ERROR_STOP=1",
      "-d",
      process.env.RENTAL_TEST_DATABASE,
      "-c",
      query,
    ],
    { encoding: "utf8", windowsHide: true },
  ).trim();
const messages = [];
let mode = "",
  releaseHeld;
const smtp = createServer((socket) => {
  let buffer = "",
    data = false,
    lines = [],
    recipient = "";
  socket.write("220 localhost test SMTP\r\n");
  socket.on("error", () => {});
  socket.on("data", (chunk) => {
    buffer += chunk.toString("utf8");
    let newline;
    while ((newline = buffer.indexOf("\r\n")) >= 0) {
      const line = buffer.slice(0, newline);
      buffer = buffer.slice(newline + 2);
      if (data) {
        if (line !== ".") {
          lines.push(line);
          continue;
        }
        data = false;
        const mail = { recipient, body: lines.join("\r\n") };
        lines = [];
        const outcome = mode;
        mode = "";
        if (outcome === "reject") {
          socket.write("550 test recipient rejection\r\n");
          continue;
        }
        messages.push(mail);
        if (outcome === "uncertain") {
          socket.destroy();
          continue;
        }
        if (outcome === "hold") {
          releaseHeld = () => socket.write("250 accepted\r\n");
          continue;
        }
        socket.write("250 accepted\r\n");
        continue;
      }
      if (/^EHLO|^HELO/i.test(line))
        socket.write("250-localhost\r\n250 PIPELINING\r\n");
      else if (/^MAIL FROM/i.test(line)) socket.write("250 sender ok\r\n");
      else if (/^RCPT TO/i.test(line)) {
        recipient = line;
        socket.write("250 recipient ok\r\n");
      } else if (/^DATA$/i.test(line)) {
        data = true;
        socket.write("354 end with dot\r\n");
      } else if (/^QUIT$/i.test(line)) {
        socket.end("221 bye\r\n");
      } else socket.write("250 ok\r\n");
    }
  });
});
await new Promise((resolve, reject) =>
  smtp.listen(2526, "127.0.0.1", resolve).once("error", reject),
);
const directory = resolve(
  root,
  ".tools/email-test-data",
  new Date().toISOString().replaceAll(/[:.]/g, "-"),
);
mkdirSync(directory, { recursive: true });
const log = createWriteStream(resolve(directory, "server.log"));
const server = spawn(
  resolve(root, ".tools/dotnet/dotnet.exe"),
  [
    resolve(root, "Rental.Api/bin/Debug/net8.0/Rental.Api.dll"),
    "--urls",
    "http://127.0.0.1:5263",
    "--webroot",
    resolve(root, ".tools/email-preview-web"),
  ],
  {
    cwd: resolve(root, "Rental.Api"),
    windowsHide: true,
    env: {
      ...process.env,
      ASPNETCORE_ENVIRONMENT: "Development",
      ConnectionStrings__Rental: process.env.RENTAL_TEST_CONNECTION,
      Database__SeedDemo: "false",
      Database__DataDirectory: directory,
      Hangfire__Enabled: "true",
      EmailSmtp__Host: "127.0.0.1",
      EmailSmtp__Port: "2526",
      EmailSmtp__Security: "None",
      EmailSmtp__Username: "",
      EmailSmtp__Password: "",
      EmailSmtp__FromAddress: "reminders@example.test",
      EmailSmtp__FromName: "DVP Home",
      EmailSmtp__PublicBaseUrl: "",
    },
  },
);
server.stdout.pipe(log);
server.stderr.pipe(log);
const base = "http://127.0.0.1:5263/api";
let checks = 0;
async function waitFor(check, label) {
  for (let i = 0; i < 150; i++) {
    try {
      const result = await check();
      if (result) return result;
    } catch {}
    await new Promise((r) => setTimeout(r, 100));
  }
  throw new Error(
    "Timeout: " + label + "; xem " + resolve(directory, "server.log"),
  );
}
async function request(path, method = "GET", body, cookie, status = 200) {
  const response = await fetch(base + path, {
    method,
    headers: {
      "X-Rental-Request": "1",
      ...(cookie ? { Cookie: cookie } : {}),
      ...(body ? { "Content-Type": "application/json" } : {}),
    },
    body: body ? JSON.stringify(body) : undefined,
  });
  const text = await response.text();
  let data;
  try {
    data = JSON.parse(text);
  } catch {
    data = text;
  }
  assert.equal(response.status, status, `${method} ${path}: ${text}`);
  checks++;
  return { data, response };
}
async function login(username) {
  return (
    await request("/auth/login", "POST", { username, password: "Demo@123456" })
  ).response.headers
    .get("set-cookie")
    .split(";")[0];
}
let admin;
const overview = async () =>
  (await request("/email-reminders", "GET", undefined, admin)).data;
const status = async (id, target) =>
  waitFor(async () => {
    const row = (await overview()).history.find((x) => x.id === id);
    return row?.status === target && row;
  }, `email ${id}: ${target}`);
const send = async (entityId, kind = "InvoiceDue", extra = {}) =>
  (
    await request(
      "/email-reminders/send",
      "POST",
      { kind, entityId, ...extra },
      admin,
    )
  ).data;
const idle = () =>
  waitFor(
    () =>
      sql(
        `SELECT count(*) FROM hangfire.job WHERE statename IN ('Enqueued','Processing')`,
      ) === "0",
    "Hangfire idle",
  );
function addInvoice(month) {
  return Number(
    sql(
      `INSERT INTO invoices ("ContractId","Year","Month","DueDate","Total","Status","CancellationReason","CreatedAt","CreatedBy","IsArchived") VALUES (1,2026,${month},(NOW() AT TIME ZONE 'Asia/Ho_Chi_Minh')::date,1000,'Issued','',NOW(),'mail-test',false) RETURNING "Id"`,
    ),
  );
}
async function close() {
  if (server.exitCode === null) {
    const exited = new Promise((r) => server.once("exit", r));
    server.kill();
    await exited;
  }
  await new Promise((r) => smtp.close(r));
  log.end();
}
try {
  await waitFor(async () => (await fetch(base + "/health")).ok, "API startup");
  admin = await login("admin");
  const manager = await login("manager"),
    manager2 = await login("manager2"),
    tenant = await login("tenant");
  await request("/email-reminders", "GET", undefined, undefined, 401);
  await request("/email-reminders", "GET", undefined, manager, 403);
  await request("/email-reminders", "GET", undefined, tenant, 403);
  await request("/email-reminders/run", "POST", undefined, manager, 403);
  assert.equal((await overview()).settings.enabled, false);
  assert.equal((await overview()).delivery.configured, true);
  const settings = {
    enabled: true,
    invoiceEnabled: true,
    contractEnabled: true,
    contractDaysBefore: 7,
  };
  await request(
    "/email-reminders/settings",
    "PUT",
    { ...settings, contractDaysBefore: 0 },
    admin,
    400,
  );
  await request("/email-reminders/settings", "PUT", settings, admin, 204);
  const schedule = JSON.parse(
    sql(
      `SELECT json_agg(t) FROM hangfire.hash t WHERE key='recurring-job:dvp-daily-email-reminders'`,
    ),
  );
  assert.equal(schedule.find((x) => x.field === "Cron").value, "0 9 * * *");
  assert.match(
    schedule.find((x) => x.field === "TimeZoneId").value,
    /SE Asia Standard Time|Asia\/Ho_Chi_Minh/,
  );
  await request(
    "/email-reminders/send",
    "POST",
    { kind: "InvoiceDue", entityId: 1 },
    manager2,
    403,
  );
  const invoice = (
    await request(
      "/email-reminders/send",
      "POST",
      { kind: "InvoiceDue", entityId: 1 },
      manager,
    )
  ).data;
  await status(invoice.id, "Sent");
  assert.equal(messages.length, 1);
  assert.match(messages[0].recipient, /tenant-one@example.test/);
  const decoded = messages[0].body.replace(/=\r\n/g, "");
  assert.match(decoded, /text\/html/);
  assert.match(decoded, /3\.680\.000/);
  assert(!decoded.includes("<img src=x onerror="));
  await request(
    "/email-reminders/send",
    "POST",
    { kind: "InvoiceDue", entityId: 1 },
    admin,
    400,
  );
  await request("/email-reminders/run", "POST", undefined, admin);
  await waitFor(async () => {
    const rows = (await overview()).history;
    return rows.filter((x) => x.status === "Sent").length === 3;
  }, "daily eligibility");
  await idle();
  assert.equal(messages.length, 3);
  // Hai scan đồng thời không gửi lại thư đã gửi; bỏ qua hợp đồng ngoài khoảng 7 ngày.
  await Promise.all([
    request("/email-reminders/run", "POST", undefined, admin),
    request("/email-reminders/run", "POST", undefined, admin),
  ]);
  await idle();
  assert.equal(messages.length, 3);
  assert(
    !(await overview()).history.some(
      (x) => x.kind === "ContractExpiry" && x.entityId === 2,
    ),
  );
  // Payment đến sau enqueue nhưng trước Send: recheck số dư và không gửi.
  mode = "hold";
  const held = await send(3, "ContractExpiry");
  await waitFor(() => releaseHeld, "held SMTP");
  const paidInvoice = addInvoice(9);
  const paidQueued = await send(paidInvoice);
  await request(
    "/payments",
    "POST",
    {
      invoiceId: paidInvoice,
      amount: 1000,
      method: "Cash",
      paidDate: new Date(Date.now() + 7 * 3600000).toISOString().slice(0, 10),
      note: "mail recheck test",
    },
    admin,
  );
  releaseHeld();
  releaseHeld = null;
  await status(held.id, "Sent");
  await status(paidQueued.id, "Cancelled");
  assert.equal(messages.length, 4);
  // SMTP từ chối chắc chắn -> Failed, cho phép retry mà không gửi trùng Sent.
  mode = "reject";
  const rejectInvoice = addInvoice(8);
  const rejected = await send(rejectInvoice);
  await status(rejected.id, "Failed");
  await send(rejectInvoice);
  await status(rejected.id, "Sent");
  assert.equal(messages.length, 5);
  // SMTP nhận DATA rồi mất kết nối: không auto retry; chỉ gửi lại khi xác nhận rõ.
  mode = "uncertain";
  const unknownInvoice = addInvoice(7);
  const unknown = await send(unknownInvoice);
  await status(unknown.id, "Uncertain");
  assert.equal(messages.length, 6);
  await request(
    "/email-reminders/send",
    "POST",
    { kind: "InvoiceDue", entityId: unknownInvoice },
    admin,
    409,
  );
  await send(unknownInvoice, "InvoiceDue", {
    retryUncertain: true,
    reminderId: unknown.id,
  });
  await status(unknown.id, "Sent");
  assert.equal(messages.length, 7);
  // Đổi ngày hết hạn trong khi đang chờ queue: hủy thông báo cũ.
  mode = "hold";
  const blocker = await send(addInvoice(6));
  await waitFor(() => releaseHeld, "held SMTP 2");
  const changed = await send(2, "ContractExpiry");
  sql(`UPDATE contracts SET "EndDate"="EndDate"+1 WHERE "Id"=2`);
  releaseHeld();
  releaseHeld = null;
  await status(blocker.id, "Sent");
  await status(changed.id, "Cancelled");
  assert.equal(messages.length, 8);
  // Email thiếu: không gửi; bổ sung email rồi scan lại vẫn gửi được đúng một lần.
  sql(
    `UPDATE users SET "Email"='' WHERE "TenantId"=3; UPDATE contracts SET "EndDate"=(NOW() AT TIME ZONE 'Asia/Ho_Chi_Minh')::date+5 WHERE "Id"=2`,
  );
  await request(
    "/email-reminders/send",
    "POST",
    { kind: "ContractExpiry", entityId: 2 },
    admin,
    400,
  );
  await request("/email-reminders/run", "POST", undefined, admin);
  const missing = await waitFor(
    async () =>
      (await overview()).history.find(
        (x) =>
          x.kind === "ContractExpiry" &&
          x.entityId === 2 &&
          x.status === "Skipped",
      ),
    "missing recipient",
  );
  await idle();
  assert.equal(messages.length, 8);
  sql(
    `UPDATE users SET "Email"='tenant-three@example.test' WHERE "TenantId"=3`,
  );
  await request("/email-reminders/run", "POST", undefined, admin);
  await status(missing.id, "Sent");
  await idle();
  assert.equal(messages.length, 9);
  const before = (await overview()).history.length;
  execFileSync(
    "C:/Program Files/PostgreSQL/18/bin/psql.exe",
    [
      "-X",
      "-q",
      "-v",
      "ON_ERROR_STOP=1",
      "-d",
      process.env.RENTAL_TEST_DATABASE,
      "-f",
      resolve(root, "Database/09_email_reminders.sql"),
    ],
    { windowsHide: true, stdio: "ignore" },
  );
  assert.equal((await overview()).history.length, before);
  assert.equal((await overview()).settings.enabled, true);
  console.log(
    `PASS: ${checks} HTTP assertions + real PostgreSQL/Hangfire/SMTP; 09:00 Vietnam, manual sends, duplicate scans, recheck paid/renewed records, rejected/uncertain SMTP, guarded retries and repeat migration.`,
  );
  if (process.argv.includes("--preview")) {
    console.log(
      "Preview kiểm thử riêng: http://127.0.0.1:5263/#settings; admin / Demo@123456. Gõ stop để kết thúc.",
    );
    await new Promise((resolve) =>
      process.stdin.on("data", (data) => {
        if (data.toString().trim() === "stop") resolve();
      }),
    );
    process.stdin.removeAllListeners("data");
    process.stdin.pause();
  }
} finally {
  await close();
}
