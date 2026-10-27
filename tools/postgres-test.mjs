import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { PGlite } from "@electric-sql/pglite";
import { PGLiteSocketServer } from "@electric-sql/pglite-socket";

const db = new PGlite();
await db.exec(
  readFileSync(new URL("../Database/01_schema.sql", import.meta.url), "utf8"),
);
// Mô phỏng schema cũ, giữ một dòng dữ liệu để kiểm tra nâng cấp không làm mất dữ liệu.
await db.exec(`
  ALTER TABLE users DROP CONSTRAINT ck_user_tenant;
  ALTER TABLE users DROP COLUMN "TenantId";
  ALTER TABLE users DROP CONSTRAINT ck_user_role;
  ALTER TABLE users ADD CONSTRAINT ck_user_role CHECK ("Role" IN ('Owner','Manager'));
  ALTER TABLE incidents DROP COLUMN "ReportedByTenantId";
  ALTER TABLE attachments DROP COLUMN "IsPublic";
  INSERT INTO branches ("Id", "Name", "Address", "CreatedAt", "CreatedBy", "IsArchived")
    VALUES (90, 'Giữ dữ liệu khi nâng cấp', '', NOW(), 'test', false);
`);
const upgrade = readFileSync(
  new URL("../Database/03_public_tenant.sql", import.meta.url),
  "utf8",
);
await db.exec(upgrade);
await db.exec(upgrade);
assert.equal(
  (await db.query('SELECT "Name" FROM branches WHERE "Id" = 90')).rows[0].Name,
  "Giữ dữ liệu khi nâng cấp",
);
await db.exec('DELETE FROM branches WHERE "Id" = 90');
await db.exec(
  "BEGIN;\n" +
    readFileSync(
      new URL("../Database/02_sample.sql", import.meta.url),
      "utf8",
    ) +
    "\nCOMMIT;",
);
assert.equal(
  (await db.query("SELECT COUNT(*)::int AS count FROM rooms")).rows[0].count,
  8,
);
assert.equal(
  (
    await db.query(
      'SELECT SUM("Amount")::bigint AS total FROM invoice_items WHERE "InvoiceId" = 1',
    )
  ).rows[0].total,
  3680000,
);
// Hai file phải nạp lại data mà không tạo bản ghi trùng hoặc làm lùi identity.
await db.exec(
  readFileSync(new URL("../Database/02_sample.sql", import.meta.url), "utf8"),
);
assert.equal(
  (await db.query("SELECT COUNT(*)::int AS count FROM rooms")).rows[0].count,
  8,
);
const socket = new PGLiteSocketServer({
  db,
  host: "127.0.0.1",
  port: 5544,
  maxConnections: 20,
});
await socket.start();
process.env.RENTAL_TEST_CONNECTION =
  "Host=127.0.0.1;Port=5544;Database=postgres;Username=postgres;SSL Mode=Disable;Pooling=false;Timeout=15;Command Timeout=30";
try {
  await import("./smoke-test.mjs");
  console.log(
    "PASS: PostgreSQL schema, repeatable upgrade preserving data, sample, identity, and API via Npgsql.",
  );
} finally {
  await socket.stop();
  await db.close();
}
