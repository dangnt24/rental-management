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
const detailColumns = [
  "Area",
  "Floor",
  "RoomType",
  "Amenities",
  "AmenitiesConfirmed",
  "ToiletType",
  "AccessHours",
  "LaundryType",
  "ParkingType",
  "MaxVehicles",
  "PetsAllowed",
  "ElectricVehiclesAllowed",
  "HasWindow",
  "HasBalcony",
  "SuggestedDeposit",
  "MinimumLeaseMonths",
  "Neighborhood",
  "RentalConditions",
  "ContactName",
  "ContactPhone",
];
await db.exec(
  `INSERT INTO rooms ("Id","BranchId","Name","Price","Capacity","IsMaintenance","Description","CreatedAt","CreatedBy","IsArchived") VALUES (90,90,'Phòng giữ nguyên',1234567,2,false,'Dữ liệu cũ',NOW(),'test',false); ALTER TABLE rooms DROP CONSTRAINT ck_room_details; ALTER TABLE rooms ${detailColumns.map((column) => `DROP COLUMN "${column}"`).join(", ")};`,
);
const detailUpgrade = readFileSync(
  new URL("../Database/05_room_details.sql", import.meta.url),
  "utf8",
);
await db.exec(detailUpgrade);
await db.exec(detailUpgrade);
const legacyRoom = (await db.query('SELECT * FROM rooms WHERE "Id"=90'))
  .rows[0];
assert.equal(Number(legacyRoom.Price), 1234567);
assert.equal(legacyRoom.Area, null);
assert.equal(legacyRoom.PetsAllowed, null);
assert.equal(legacyRoom.AmenitiesConfirmed, false);
assert.deepEqual(legacyRoom.Amenities, []);
assert.equal(
  (await db.query('SELECT "Name" FROM branches WHERE "Id" = 90')).rows[0].Name,
  "Giữ dữ liệu khi nâng cấp",
);
await db.exec(
  'DELETE FROM rooms WHERE "Id"=90; DELETE FROM branches WHERE "Id" = 90',
);
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
// Nâng cấp thứ tự ảnh và hồ sơ từ schema cũ; chạy lại phải giữ dữ liệu đã sửa.
await db.exec(`
 ALTER TABLE attachments DROP CONSTRAINT ck_attachment_order;
 ALTER TABLE attachments DROP COLUMN "SortOrder";
 INSERT INTO attachments ("EntityType","EntityId","OriginalName","StoredName","ContentType","Size","IsPublic","CreatedAt","CreatedBy","IsArchived")
 VALUES ('room',3,'Ảnh cũ 1','keep-one.png','image/png',9,true,NOW(),'test',false),
 ('room',3,'Ảnh cũ 2','keep-two.png','image/png',9,false,NOW(),'test',false);
 ALTER TABLE users DROP COLUMN "Email", DROP COLUMN "Phone", DROP COLUMN "AvatarStoredName", DROP COLUMN "AvatarVersion";
`);
const orderUpgrade = readFileSync(
  new URL("../Database/07_attachment_order.sql", import.meta.url),
  "utf8",
);
const profileUpgrade = readFileSync(
  new URL("../Database/08_account_profile.sql", import.meta.url),
  "utf8",
);
await db.exec(orderUpgrade);
const migratedPhotos = (
  await db.query('SELECT * FROM attachments ORDER BY "Id"')
).rows;
assert.deepEqual(
  migratedPhotos.map((x) => x.SortOrder),
  [0, 1],
);
assert.deepEqual(
  migratedPhotos.map((x) => x.IsPublic),
  [true, false],
);
assert.deepEqual(
  migratedPhotos.map((x) => x.StoredName),
  ["keep-one.png", "keep-two.png"],
);
await db.exec(
  'UPDATE attachments SET "SortOrder"=7 WHERE "OriginalName"=\'Ảnh cũ 1\'',
);
await db.exec(orderUpgrade);
assert.equal(
  (await db.query('SELECT "SortOrder" FROM attachments ORDER BY "Id" LIMIT 1'))
    .rows[0].SortOrder,
  7,
);
await db.exec(profileUpgrade);
const linkedPhones = (
  await db.query(
    'SELECT u."Phone",t."Phone" AS expected FROM users u JOIN tenants t ON t."Id"=u."TenantId"',
  )
).rows;
assert(linkedPhones.length > 0);
assert(linkedPhones.every((x) => x.Phone === x.expected));
await db.exec(
  `UPDATE users SET "Email"='preserve@example.test',"Phone"='0901234567',"AvatarStoredName"='keep-avatar.png',"AvatarVersion"=3 WHERE "Username"='admin'`,
);
await db.exec(profileUpgrade);
const upgradedAdmin = (
  await db.query(`SELECT * FROM users WHERE "Username"='admin'`)
).rows[0];
assert.equal(upgradedAdmin.Email, "preserve@example.test");
assert.equal(upgradedAdmin.Phone, "0901234567");
assert.equal(upgradedAdmin.AvatarStoredName, "keep-avatar.png");
assert.equal(upgradedAdmin.AvatarVersion, 3);
await db.exec(
  `DELETE FROM attachments; UPDATE users SET "Email"='',"Phone"='',"AvatarStoredName"='',"AvatarVersion"=0 WHERE "Username"='admin'`,
);
const emailUpgrade = readFileSync(
  new URL("../Database/09_email_reminders.sql", import.meta.url),
  "utf8",
);
await db.exec(
  "DROP TABLE email_reminders; DROP TABLE email_reminder_settings;",
);
await db.exec(emailUpgrade);
await db.exec(
  'UPDATE email_reminder_settings SET "ContractDaysBefore"=14 WHERE "Id"=1',
);
await db.exec(emailUpgrade);
assert.equal(
  (await db.query('SELECT "ContractDaysBefore" FROM email_reminder_settings'))
    .rows[0].ContractDaysBefore,
  14,
);
await db.exec(
  'UPDATE email_reminder_settings SET "ContractDaysBefore"=7 WHERE "Id"=1',
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
