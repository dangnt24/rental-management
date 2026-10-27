import assert from "node:assert/strict";
import { spawn } from "node:child_process";
import { existsSync, mkdirSync, createWriteStream } from "node:fs";
import { resolve } from "node:path";
import { fileURLToPath } from "node:url";

const root = fileURLToPath(new URL("../", import.meta.url));
// postgres-test.mjs cung cấp database riêng; không dùng kết nối của ứng dụng thật.
const testConnection = process.env.RENTAL_TEST_CONNECTION;
if (!testConnection) {
  throw new Error(
    "Chạy node tools/postgres-test.mjs để tạo database kiểm thử riêng.",
  );
}
const sdk =
  process.env.RENTAL_DOTNET ||
  (existsSync(resolve(root, ".tools/dotnet/dotnet.exe"))
    ? resolve(root, ".tools/dotnet/dotnet.exe")
    : "dotnet");
const testDir = resolve(
  root,
  ".tools/test-data",
  new Date().toISOString().replaceAll(/[:.]/g, "-"),
);
mkdirSync(testDir, { recursive: true });
const log = createWriteStream(resolve(testDir, "server.log"));
const server = spawn(
  sdk,
  [
    resolve(root, "Rental.Api/bin/Debug/net8.0/Rental.Api.dll"),
    "--urls",
    "http://localhost:5259",
  ],
  {
    cwd: resolve(root, "Rental.Api"),
    windowsHide: true,
    env: {
      ...process.env,
      ASPNETCORE_ENVIRONMENT: "Development",
      Hangfire__Enabled: "false",
      ConnectionStrings__Rental: testConnection,
      Database__SeedDemo: "true",
      Database__DataDirectory: testDir,
    },
  },
);
server.stdout.pipe(log);
server.stderr.pipe(log);
let passed = 0;
const base = "http://localhost:5259/api";
async function request(
  path,
  method = "GET",
  body,
  cookie,
  expected = 200,
  headers = {},
) {
  const response = await fetch(base + path, {
    method,
    headers: {
      "X-Rental-Request": "1",
      ...(cookie ? { Cookie: cookie } : {}),
      ...(body ? { "Content-Type": "application/json" } : {}),
      ...headers,
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
  assert.equal(response.status, expected, `${method} ${path}: ${text}`);
  passed++;
  return { data, response };
}
async function login(username) {
  const r = await request("/auth/login", "POST", {
    username,
    password: "Demo@123456",
  });
  return r.response.headers.get("set-cookie").split(";")[0];
}
try {
  let ready = false;
  for (let i = 0; i < 60; i++) {
    try {
      if ((await fetch(base + "/health")).ok) {
        ready = true;
        break;
      }
    } catch {}
    await new Promise((r) => setTimeout(r, 500));
  }
  assert(ready, "Server did not start; read " + resolve(testDir, "server.log"));
  assert.equal((await request("/health")).data.database, "PostgreSQL");
  await request("/workspace", "GET", undefined, undefined, 401);
  await request(
    "/auth/login",
    "POST",
    { username: "admin", password: "incorrect" },
    undefined,
    401,
  );
  const admin = await login("admin");
  const manager = await login("manager");
  const manager2 = await login("manager2");
  const emailOverview = (
    await request("/email-reminders", "GET", undefined, admin)
  ).data;
  assert.equal(emailOverview.settings.enabled, false);
  assert.equal(emailOverview.delivery.jobsEnabled, false);
  assert(!JSON.stringify(emailOverview).includes("password"));
  await request("/email-reminders", "GET", undefined, manager, 403);
  await request("/email-reminders/run", "POST", undefined, manager, 403);
  await request(
    "/email-reminders/preview?kind=InvoiceDue&entityId=1",
    "GET",
    undefined,
    manager2,
    403,
  );
  await request(
    "/email-reminders/settings",
    "PUT",
    {
      enabled: true,
      invoiceEnabled: true,
      contractEnabled: true,
      contractDaysBefore: 7,
    },
    admin,
    400,
  );
  let workspace = (await request("/workspace", "GET", undefined, admin)).data;
  assert.equal(workspace.rooms.length, 8);
  assert.equal(workspace.summary.occupiedRooms, 3);
  assert.equal(workspace.summary.outstanding, 3955000);
  assert(!JSON.stringify(workspace).includes("passwordHash"));
  const managerWorkspace = (
    await request("/workspace", "GET", undefined, manager)
  ).data;
  assert.equal(managerWorkspace.branches.length, 1);
  assert(managerWorkspace.rooms.every((x) => x.branchId === 1));
  assert.equal(managerWorkspace.users, null);
  const second = (await request("/workspace", "GET", undefined, manager2)).data;
  assert(second.rooms.every((x) => x.branchId === 2));
  const catalog = (await request("/public/rooms")).data;
  assert.deepEqual(
    catalog.rooms.map((r) => r.id).sort((a, b) => a - b),
    [3, 5, 7, 8],
  );
  assert(!JSON.stringify(catalog).includes("passwordHash"));
  assert(!JSON.stringify(catalog).includes("identityNumber"));
  assert(!JSON.stringify(catalog).includes("createdBy"));
  assert(!JSON.stringify(catalog).includes("contractId"));
  assert.deepEqual(
    (
      await request("/public/rooms?branchId=2&capacity=3&sort=priceAsc")
    ).data.rooms.map((r) => r.id),
    [8],
  );
  assert.equal(
    (await request("/public/rooms?minPrice=2600000&maxPrice=2800000")).data
      .rooms.length,
    2,
  );
  assert.equal(
    (await request("/public/rooms?q=khong-co-phong-nay")).data.rooms.length,
    0,
  );
  await request(
    "/public/rooms?minPrice=3000000&maxPrice=1000000",
    "GET",
    undefined,
    undefined,
    400,
  );
  await request("/public/rooms?capacity=0", "GET", undefined, undefined, 400);
  await request("/public/rooms?sort=unknown", "GET", undefined, undefined, 400);
  await request("/public/rooms/1/photos/1", "GET", undefined, undefined, 404);
  const tenant = await login("tenant");
  const tenant2 = await login("tenant2");
  const portal = (await request("/tenant/workspace", "GET", undefined, tenant))
    .data;
  assert.deepEqual(
    portal.contracts.map((c) => c.id),
    [1],
  );
  assert(portal.invoices.every((i) => i.contractId === 1));
  assert(portal.rooms.every((r) => r.id === 1));
  assert.equal(portal.users, undefined);
  assert.equal(portal.profile.identityNumber, undefined);
  const otherRoomPortal = (
    await request("/tenant/workspace", "GET", undefined, tenant2)
  ).data;
  assert.deepEqual(
    otherRoomPortal.contracts.map((c) => c.id),
    [3],
  );
  await request("/tenant/workspace", "GET", undefined, undefined, 401);
  await request("/tenant/workspace", "GET", undefined, manager, 403);
  for (const path of ["/workspace", "/invoices/1", "/attachments/1"])
    await request(path, "GET", undefined, tenant, 403);
  for (const path of [
    "/rooms",
    "/tenants",
    "/contracts",
    "/fees",
    "/readings",
    "/invoices",
    "/payments",
    "/incidents",
    "/users",
    "/email-reminders/send",
  ])
    await request(path, "POST", {}, tenant, 403);
  await request(
    "/tenant/incidents",
    "POST",
    { contractId: 3, description: "Không được gửi cho phòng khác" },
    tenant,
    403,
  );
  await request(
    "/tenant/incidents",
    "POST",
    { contractId: 1, description: " " },
    tenant,
    400,
  );
  const reported = (
    await request(
      "/tenant/incidents",
      "POST",
      { contractId: 1, description: "Vòi nước cần kiểm tra" },
      tenant,
    )
  ).data;
  assert.equal(reported.status, "Open");
  assert.equal(
    (await request("/tenant/workspace", "GET", undefined, tenant2)).data
      .incidents.length,
    0,
  );
  await request(
    `/incidents/${reported.id}`,
    "PUT",
    {
      roomId: 1,
      description: "Vòi nước cần kiểm tra",
      status: "Resolved",
      resolution: "Đã thay gioăng",
      cost: 10000,
    },
    manager,
  );
  const resolved = (
    await request("/tenant/workspace", "GET", undefined, tenant)
  ).data.incidents.find((i) => i.id === reported.id);
  assert.equal(resolved.resolution, "Đã thay gioăng");
  assert.equal(resolved.status, "Resolved");
  await request(
    `/incidents/${reported.id}`,
    "PUT",
    {
      roomId: 2,
      description: "Không được chuyển sang phòng khác",
      status: "Open",
      resolution: "",
      cost: 0,
    },
    manager,
    400,
  );
  const account = {
    username: "tenant-test",
    fullName: "Người thuê kiểm thử",
    role: "Tenant",
    password: "Demo@123456",
    branchIds: [],
    tenantId: 6,
  };
  await request("/users", "POST", { ...account, tenantId: null }, admin, 400);
  await request("/users", "POST", { ...account, tenantId: 1 }, admin, 400);
  await request("/users", "POST", account, manager, 403);
  const tenantAccount = (await request("/users", "POST", account, admin)).data;
  await request(
    "/users",
    "POST",
    { ...account, username: "tenant-closed", tenantId: 5 },
    admin,
  );
  const closedTenant = await login("tenant-closed");
  const history = (
    await request("/tenant/workspace", "GET", undefined, closedTenant)
  ).data;
  assert.deepEqual(
    history.contracts.map((c) => c.id),
    [4],
  );
  assert.equal(history.contracts[0].status, "Closed");
  await request(
    "/tenant/incidents",
    "POST",
    { contractId: 4, description: "Hợp đồng đã đóng" },
    closedTenant,
    400,
  );
  const newTenant = await login("tenant-test");
  assert.equal(
    (await request("/tenant/workspace", "GET", undefined, newTenant)).data
      .contracts.length,
    0,
  );
  await request(
    `/users/${tenantAccount.id}`,
    "PUT",
    { ...account, password: "", tenantId: 7 },
    admin,
  );
  await request("/tenant/workspace", "GET", undefined, newTenant, 401);
  await request(
    "/rooms/6",
    "PUT",
    {
      branchId: 2,
      name: "A.01",
      price: 2400000,
      capacity: 2,
      isMaintenance: false,
      description: "",
    },
    manager,
    403,
  );
  await request(
    "/fees",
    "POST",
    { branchId: 1, name: "Không được phép", method: "Fixed", unitPrice: 1 },
    manager,
    403,
  );
  await request("/invoices/3", "GET", undefined, manager, 403);
  const csrf = await fetch(base + "/rooms", {
    method: "POST",
    headers: { Cookie: admin, "Content-Type": "application/json" },
    body: "{}",
  });
  assert.equal(csrf.status, 403);
  passed++;
  const roomBody = {
    branchId: 1,
    name: "TEST-P.999",
    price: 2000000,
    capacity: 1,
    isMaintenance: false,
    description: "Integration test only",
  };
  const room = (await request("/rooms", "POST", roomBody, admin)).data;
  await request("/rooms", "POST", roomBody, admin, 409);
  const roomDetails = {
    area: 20.5,
    floor: "Trệt",
    roomType: "Room",
    amenities: ["Bed", "Wifi", "Kitchen"],
    amenitiesConfirmed: true,
    toiletType: "Private",
    accessHours: "Tự do",
    laundryType: "None",
    parkingType: "Shared",
    maxVehicles: 2,
    petsAllowed: false,
    electricVehiclesAllowed: false,
    hasWindow: true,
    hasBalcony: false,
    suggestedDeposit: 3000000,
    minimumLeaseMonths: 6,
    neighborhood: "Khu vực mẫu, không công bố khoảng cách chưa xác nhận.",
    rentalConditions: "Thông tin chi phí mẫu.",
    contactName: "Ban quản lý công khai",
    contactPhone: "+84000000000",
  };
  const oldRoomBody = Object.fromEntries(
    [
      "branchId",
      "name",
      "price",
      "capacity",
      "isMaintenance",
      "description",
    ].map((key) => [key, workspace.rooms.find((r) => r.id === 1)[key]]),
  );
  await request(
    "/rooms/1",
    "PUT",
    { ...oldRoomBody, details: roomDetails },
    tenant,
    403,
  );
  await request(
    "/rooms/1",
    "PUT",
    { ...oldRoomBody, details: roomDetails },
    manager2,
    403,
  );
  await request(
    "/rooms/1",
    "PUT",
    { ...oldRoomBody, details: roomDetails },
    manager,
  );
  const enrichedPortal = (
    await request("/tenant/workspace", "GET", undefined, tenant)
  ).data;
  assert.equal(enrichedPortal.rooms[0].area, 20.5);
  assert.equal(enrichedPortal.rooms[0].petsAllowed, false);
  assert.equal(enrichedPortal.rooms[0].contactName, roomDetails.contactName);
  assert(enrichedPortal.fees.every((f) => f.branchId === 1));
  const publicRoomBody = Object.fromEntries(
    [
      "branchId",
      "name",
      "price",
      "capacity",
      "isMaintenance",
      "description",
    ].map((key) => [key, workspace.rooms.find((r) => r.id === 8)[key]]),
  );
  await request(
    "/rooms/8",
    "PUT",
    { ...publicRoomBody, details: roomDetails },
    admin,
  );
  await request("/rooms/8", "PUT", publicRoomBody, admin); // Client cũ không gửi Details không được xóa thông tin mới.
  const enrichedPublic = (
    await request("/public/rooms?branchId=2")
  ).data.rooms.find((r) => r.id === 8);
  assert.equal(enrichedPublic.area, 20.5);
  assert.deepEqual(enrichedPublic.amenities, roomDetails.amenities);
  assert.equal(enrichedPublic.petsAllowed, false);
  assert.equal(enrichedPublic.suggestedDeposit, 3000000);
  assert.equal(
    (await request("/public/rooms")).data.rooms.some((r) => r.id === 1),
    false,
  );
  const enrichedOtherPortal = (
    await request("/tenant/workspace", "GET", undefined, tenant2)
  ).data;
  assert(enrichedOtherPortal.rooms.every((r) => r.id !== 1));
  assert(enrichedOtherPortal.fees.every((f) => f.branchId === 2));
  for (const invalidDetails of [
    { area: 0 },
    { area: 20.1234 },
    { amenities: ["Unknown"], amenitiesConfirmed: true },
    { amenities: ["Wifi"], amenitiesConfirmed: false },
    { parkingType: "None", maxVehicles: 2 },
    { minimumLeaseMonths: 0 },
    { contactPhone: "javascript:alert(1)" },
    { roomType: "Fake" },
  ]) {
    await request(
      "/rooms/1",
      "PUT",
      { ...oldRoomBody, details: invalidDetails },
      admin,
      400,
    );
  }
  const today = workspace.today;
  const year = +today.slice(0, 4);
  const month = +today.slice(5, 7);
  const contractBody = {
    roomId: room.id,
    tenantIds: [6],
    representativeId: 6,
    startDate: today.slice(0, 8) + "01",
    endDate: `${year + 1}-${today.slice(5)}`,
    rent: 2000000,
    deposit: 1000000,
    depositReceived: 500000,
    note: "Test",
  };
  const contract = (await request("/contracts", "POST", contractBody, admin))
    .data;
  await request("/contracts", "POST", contractBody, admin, 400);
  await request(
    "/contracts",
    "POST",
    { ...contractBody, roomId: 5 },
    admin,
    400,
  );
  const billBody = { contractId: contract.id, year, month, dueDate: today };
  await request("/invoices", "POST", billBody, admin, 400);
  const readingBody = {
    contractId: contract.id,
    year,
    month,
    electricityOld: 0,
    electricityNew: 10,
    waterOld: 0,
    waterNew: 2,
  };
  await request(
    "/readings",
    "POST",
    { ...readingBody, electricityNew: -1 },
    admin,
    400,
  );
  await request("/readings", "POST", readingBody, admin);
  const invoice = (await request("/invoices", "POST", billBody, admin)).data;
  assert.equal(invoice.total, 2185000);
  await request("/invoices", "POST", billBody, admin, 400);
  await request("/readings", "POST", readingBody, admin, 400);
  await request(
    "/fees/1",
    "PUT",
    {
      branchId: 1,
      name: "Điện",
      method: "Electricity",
      unitPrice: 5000,
      isArchived: false,
    },
    admin,
  );
  const detail = (
    await request(`/invoices/${invoice.id}`, "GET", undefined, admin)
  ).data;
  assert.equal(detail.invoice.total, 2185000);
  assert.equal(
    detail.invoice.items.find((x) => x.description.startsWith("Điện"))
      .unitPrice,
    3500,
  );
  const paymentBody = {
    invoiceId: invoice.id,
    amount: 0,
    method: "Transfer",
    paidDate: today,
    note: "Test",
  };
  await request("/payments", "POST", paymentBody, admin, 400);
  await request(
    "/payments",
    "POST",
    { ...paymentBody, amount: 9999999 },
    admin,
    400,
  );
  await request(
    "/payments",
    "POST",
    { ...paymentBody, amount: 1000000 },
    admin,
  );
  const responses = await Promise.all(
    [1, 2].map(() =>
      fetch(base + "/payments", {
        method: "POST",
        headers: {
          Cookie: admin,
          "X-Rental-Request": "1",
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ ...paymentBody, amount: 1000000 }),
      }),
    ),
  );
  assert.deepEqual(responses.map((x) => x.status).sort(), [200, 400]);
  passed += 2;
  await request(
    "/payments",
    "POST",
    { ...paymentBody, amount: 185000, method: "Deposit" },
    admin,
  );
  await request(
    `/invoices/${invoice.id}/cancel`,
    "POST",
    { reason: "Không được hủy khi có thanh toán" },
    admin,
    400,
  );
  await request(
    `/contracts/${contract.id}/close`,
    "POST",
    {
      closedDate: today,
      deduction: 15000,
      note: "Hoàn 300.000, khấu trừ 15.000",
    },
    admin,
    204,
  );
  await request(
    `/contracts/${contract.id}/close`,
    "POST",
    { closedDate: today, deduction: 0, note: "Lần hai" },
    admin,
    400,
  );
  workspace = (await request("/workspace", "GET", undefined, admin)).data;
  assert.equal(
    workspace.contracts.find((x) => x.id === contract.id).depositBalance,
    0,
  );
  assert.equal(
    workspace.contracts.find((x) => x.id === contract.id).status,
    "Closed",
  );
  assert.equal(
    workspace.rooms.find((x) => x.id === room.id).status,
    "Available",
  );
  assert.equal(
    workspace.deposits.filter(
      (x) => x.contractId === contract.id && x.type === "Refunded",
    )[0].amount,
    300000,
  );
  await request(
    "/contracts/2/deposit",
    "POST",
    { amount: 1300000, note: "Nhận cọc còn thiếu" },
    admin,
    204,
  );
  await request(
    "/contracts/2/deposit",
    "POST",
    { amount: 1, note: "Nhận dư" },
    admin,
    400,
  );
  await request(
    "/contracts/2/close",
    "POST",
    { closedDate: today, deduction: 0, note: "Còn nợ" },
    admin,
    400,
  );
  await request(
    "/invoices/2/cancel",
    "POST",
    { reason: "Kiểm tra hủy và lập lại" },
    admin,
    204,
  );
  await request(
    "/readings",
    "POST",
    {
      contractId: 2,
      year: 2026,
      month: 10,
      electricityOld: 200,
      electricityNew: 281,
      waterOld: 20,
      waterNew: 25,
    },
    admin,
  );
  await request(
    "/invoices",
    "POST",
    { contractId: 2, year: 2026, month: 10, dueDate: today },
    admin,
  );
  const incident = (
    await request(
      "/incidents",
      "POST",
      {
        roomId: room.id,
        description: "Test vòi nước",
        status: "Open",
        resolution: "",
        cost: 0,
      },
      manager,
    )
  ).data;
  await request(
    `/incidents/${incident.id}`,
    "PUT",
    {
      roomId: room.id,
      description: "Test vòi nước",
      status: "Resolved",
      resolution: "Đã sửa",
      cost: 50000,
    },
    manager,
  );
  await request("/attachments/room/6", "POST", {}, manager, 403);
  const file = new FormData();
  file.append(
    "file",
    new Blob([new Uint8Array([137, 80, 78, 71, 13, 10, 26, 10, 0])], {
      type: "image/png",
    }),
    "test.png",
  );
  const upload = await fetch(base + `/attachments/room/${room.id}`, {
    method: "POST",
    headers: { Cookie: admin, "X-Rental-Request": "1" },
    body: file,
  });
  assert.equal(upload.status, 200);
  passed++;
  const attachment = await upload.json();
  const publicImage = new FormData();
  publicImage.append(
    "file",
    new Blob([new Uint8Array([137, 80, 78, 71, 13, 10, 26, 10, 0])], {
      type: "image/png",
    }),
    "public.png",
  );
  const photoUpload = await fetch(base + "/attachments/room/8", {
    method: "POST",
    headers: { Cookie: admin, "X-Rental-Request": "1" },
    body: publicImage,
  });
  assert.equal(photoUpload.status, 200);
  passed++;
  const photo = await photoUpload.json();
  await request(
    `/public/rooms/8/photos/${photo.id}`,
    "GET",
    undefined,
    undefined,
    404,
  );
  await request(
    `/attachments/${photo.id}/visibility`,
    "POST",
    { isPublic: true },
    tenant,
    403,
  );
  await request(
    `/attachments/${photo.id}/visibility`,
    "POST",
    { isPublic: true },
    manager,
    403,
  );
  await request(
    `/attachments/${photo.id}/visibility`,
    "POST",
    { isPublic: true },
    manager2,
    204,
  );
  const imageDownload = await fetch(
    base + `/public/rooms/8/photos/${photo.id}`,
  );
  assert.equal(imageDownload.status, 200);
  passed++;
  assert.equal(imageDownload.headers.get("content-type"), "image/png");
  await request(
    `/public/rooms/7/photos/${photo.id}`,
    "GET",
    undefined,
    undefined,
    404,
  );
  assert(
    (await request("/public/rooms?branchId=2")).data.rooms
      .find((r) => r.id === 8)
      .photos.some((p) => p.id === photo.id),
  );
  await request(
    `/attachments/${photo.id}/visibility`,
    "POST",
    { isPublic: false },
    admin,
    204,
  );
  await request(
    `/public/rooms/8/photos/${photo.id}`,
    "GET",
    undefined,
    undefined,
    404,
  );
  await request(
    `/attachments/${attachment.id}`,
    "GET",
    undefined,
    manager2,
    403,
  );
  const download = await fetch(base + `/attachments/${attachment.id}`, {
    headers: { Cookie: admin },
  });
  assert.equal(download.status, 200);
  assert.equal((await download.arrayBuffer()).byteLength, 9);
  passed++;
  const invalid = new FormData();
  invalid.append("file", new Blob(["fake-image"]), "fake.png");
  const bad = await fetch(base + `/attachments/room/${room.id}`, {
    method: "POST",
    headers: { Cookie: admin, "X-Rental-Request": "1" },
    body: invalid,
  });
  assert.equal(bad.status, 400);
  passed++;
  const occupiedPhotoBody = new FormData();
  occupiedPhotoBody.append(
    "file",
    new Blob([new Uint8Array([137, 80, 78, 71, 13, 10, 26, 10, 0])], {
      type: "image/png",
    }),
    "occupied-room.png",
  );
  const occupiedPhotoUpload = await fetch(base + "/attachments/room/1", {
    method: "POST",
    headers: { Cookie: admin, "X-Rental-Request": "1" },
    body: occupiedPhotoBody,
  });
  assert.equal(occupiedPhotoUpload.status, 200);
  passed++;
  const occupiedPhoto = await occupiedPhotoUpload.json();
  await request(
    `/tenant/rooms/1/photos/${occupiedPhoto.id}`,
    "GET",
    undefined,
    tenant,
    404,
  );
  await request(
    `/attachments/${occupiedPhoto.id}/visibility`,
    "POST",
    { isPublic: true },
    admin,
    204,
  );
  const ownPhoto = await fetch(
    base + `/tenant/rooms/1/photos/${occupiedPhoto.id}`,
    { headers: { Cookie: tenant } },
  );
  assert.equal(ownPhoto.status, 200);
  assert.equal((await ownPhoto.arrayBuffer()).byteLength, 9);
  passed++;
  await request(
    `/tenant/rooms/1/photos/${occupiedPhoto.id}`,
    "GET",
    undefined,
    tenant2,
    403,
  );
  await request(
    `/tenant/rooms/1/photos/${occupiedPhoto.id}`,
    "GET",
    undefined,
    undefined,
    401,
  );
  await request(
    `/public/rooms/1/photos/${occupiedPhoto.id}`,
    "GET",
    undefined,
    undefined,
    404,
  );
  assert(
    (await request("/tenant/workspace", "GET", undefined, tenant)).data.rooms
      .find((r) => r.id === 1)
      .photos.some((p) => p.id === occupiedPhoto.id),
  );
  await request(
    `/attachments/${occupiedPhoto.id}`,
    "DELETE",
    undefined,
    admin,
    204,
  );
  await request(
    `/tenant/rooms/1/photos/${occupiedPhoto.id}`,
    "GET",
    undefined,
    tenant,
    404,
  );
  // Xóa file phải theo phạm vi khu; file đã gỡ không còn ở trang công khai hay tải được.
  await request(
    `/attachments/${photo.id}/visibility`,
    "POST",
    { isPublic: true },
    manager2,
    204,
  );
  await request(`/attachments/${photo.id}`, "DELETE", undefined, tenant, 403);
  await request(`/attachments/${photo.id}`, "DELETE", undefined, manager, 403);
  await request(
    `/attachments/${photo.id}`,
    "DELETE",
    undefined,
    undefined,
    401,
  );
  await request(`/attachments/${photo.id}`, "DELETE", undefined, manager2, 204);
  await request(`/attachments/${photo.id}`, "GET", undefined, manager2, 404);
  await request(
    `/public/rooms/8/photos/${photo.id}`,
    "GET",
    undefined,
    undefined,
    404,
  );
  await request(
    `/attachments/${photo.id}/visibility`,
    "POST",
    { isPublic: true },
    admin,
    404,
  );
  await request(`/attachments/${photo.id}`, "DELETE", undefined, admin, 404);
  const afterFileDelete = (await request("/workspace", "GET", undefined, admin))
    .data;
  assert(!afterFileDelete.attachments.some((f) => f.id === photo.id));
  assert(afterFileDelete.audit.some((a) => a.action === "attachment.delete"));
  assert(
    !(await request("/public/rooms?branchId=2")).data.rooms
      .find((r) => r.id === 8)
      .photos.some((p) => p.id === photo.id),
  );
  await request(
    `/attachments/${attachment.id}`,
    "DELETE",
    undefined,
    admin,
    204,
  );
  await request(`/attachments/${attachment.id}`, "GET", undefined, admin, 404);
  const { checkUploadsAndProfile } = await import("./uploads-profile-test.mjs");
  await checkUploadsAndProfile({
    base,
    request,
    admin,
    manager,
    manager2,
    tenant,
    tenant2,
    testDir,
  });
  await request("/auth/logout", "POST", undefined, admin, 204);
  console.log(
    `PASS: ${passed} HTTP checks; contract → reading → invoice → partial/concurrent payment → deposit → close; access control and attachments.`,
  );
  console.log("Isolated test database and log:", testDir);
} finally {
  if (server.exitCode === null) {
    const exited = new Promise((resolve) => server.once("exit", resolve));
    server.kill();
    await exited;
  }
  log.end();
}
