import assert from "node:assert/strict";
import { readdirSync, existsSync } from "node:fs";
import { resolve } from "node:path";

// Gọi trong smoke-test với database và thư mục file riêng; không chạm dữ liệu thật.
export async function checkUploadsAndProfile({
  base,
  request,
  admin,
  manager,
  manager2,
  tenant,
  tenant2,
  testDir,
}) {
  let checks = 0;
  const png = new Uint8Array([137, 80, 78, 71, 13, 10, 26, 10, 0]);
  const makeFiles = (count = 2, bytes = png) => {
    const form = new FormData();
    for (let i = 0; i < count; i++)
      form.append(
        "files",
        new Blob([bytes], { type: "image/png" }),
        `ảnh-${i + 1}.png`,
      );
    return form;
  };
  const diskFiles = (folder = "uploads") =>
    existsSync(resolve(testDir, folder))
      ? readdirSync(resolve(testDir, folder)).sort()
      : [];
  async function multipart(
    path,
    body,
    cookie = admin,
    status = 200,
    method = "POST",
  ) {
    const response = await fetch(base + path, {
      method,
      headers: {
        ...(cookie ? { Cookie: cookie } : {}),
        "X-Rental-Request": "1",
      },
      body,
    });
    const text = await response.text();
    assert.equal(response.status, status, `${method} ${path}: ${text}`);
    checks++;
    try {
      return JSON.parse(text);
    } catch {
      return text;
    }
  }
  const beforeFiles = diskFiles();
  const invalidBatch = makeFiles();
  invalidBatch.append("files", new Blob(["not a PNG"]), "sai.png");
  await multipart("/attachments/room/8", invalidBatch, admin, 400);
  assert.deepEqual(
    diskFiles(),
    beforeFiles,
    "Invalid batch must write no files",
  );
  await multipart("/attachments/room/8", makeFiles(11), admin, 400);
  await multipart("/attachments/room/8", new FormData(), admin, 400);
  await multipart("/attachments/room/8", makeFiles(), manager, 403);
  await multipart("/attachments/room/8", makeFiles(), tenant, 403);
  await multipart("/attachments/room/8", makeFiles(), null, 401);
  const photos = (await multipart("/attachments/room/8", makeFiles(), manager2))
    .files;
  assert.equal(photos.length, 2);
  assert(photos[1].sortOrder > photos[0].sortOrder);
  for (const photo of photos)
    await request(
      `/attachments/${photo.id}/visibility`,
      "POST",
      { isPublic: true },
      manager2,
      204,
    );
  let ws = (await request("/workspace", "GET", undefined, admin)).data;
  const allPhotos = ws.attachments
    .filter(
      (x) =>
        x.entityType === "room" &&
        x.entityId === 8 &&
        x.contentType.startsWith("image/"),
    )
    .map((x) => x.id);
  const ordered = [...allPhotos].reverse();
  await request(
    "/attachments/room/8/order",
    "POST",
    { photoIds: ordered },
    manager2,
    204,
  );
  assert.deepEqual(
    (await request("/public/rooms")).data.rooms
      .find((x) => x.id === 8)
      .photos.map((x) => x.id),
    photos.map((x) => x.id).reverse(),
  );
  ws = (await request("/workspace", "GET", undefined, admin)).data;
  assert.deepEqual(
    ws.attachments.filter((x) => allPhotos.includes(x.id)).map((x) => x.id),
    ordered,
  );
  await request(
    "/attachments/room/8/order",
    "POST",
    { photoIds: ordered },
    manager,
    403,
  );
  await request(
    "/attachments/room/8/order",
    "POST",
    { photoIds: ordered },
    tenant,
    403,
  );
  await request(
    "/attachments/room/8/order",
    "POST",
    { photoIds: [...ordered, ordered[0]] },
    admin,
    400,
  );
  await request(
    "/attachments/room/8/order",
    "POST",
    { photoIds: [999999] },
    admin,
    409,
  );
  await request(
    "/attachments/room/8/order",
    "POST",
    { photoIds: ordered.slice(1) },
    admin,
    409,
  );
  await multipart("/attachments/room/8", makeFiles(1), admin);
  await request(
    "/attachments/room/8/order",
    "POST",
    { photoIds: ordered },
    admin,
    409,
  );
  await request(`/attachments/${ordered[0]}`, "DELETE", undefined, admin, 204);
  await request(
    "/attachments/room/8/order",
    "POST",
    { photoIds: ordered },
    admin,
    409,
  );
  // Nhận đúng 10 MB/file; tổng 60 MB vượt giới hạn batch 52 MB cũ.
  const large = new Uint8Array(10 * 1024 * 1024);
  large.set(png);
  assert.equal(
    (await multipart("/attachments/room/8", makeFiles(6, large), admin)).files
      .length,
    6,
  );
  const tooLarge = new Uint8Array(10 * 1024 * 1024 + 1);
  tooLarge.set(png);
  const beforeOversize = diskFiles();
  await multipart("/attachments/room/8", makeFiles(1, tooLarge), admin, 400);
  assert.deepEqual(diskFiles(), beforeOversize);
  for (const [type, key] of [
    ["tenant", "tenants"],
    ["contract", "contracts"],
    ["payment", "payments"],
  ]) {
    const id = ws[key][0].id;
    assert.equal(
      (await multipart(`/attachments/${type}/${id}`, makeFiles(), admin)).files
        .length,
      2,
    );
  }
  const ownRoom = (await multipart("/attachments/room/1", makeFiles(), admin))
    .files;
  for (const photo of ownRoom)
    await request(
      `/attachments/${photo.id}/visibility`,
      "POST",
      { isPublic: true },
      admin,
      204,
    );
  await request(
    "/attachments/room/1/order",
    "POST",
    { photoIds: ownRoom.map((x) => x.id).reverse() },
    admin,
    204,
  );
  assert.deepEqual(
    (await request("/tenant/workspace", "GET", undefined, tenant)).data.rooms
      .find((x) => x.id === 1)
      .photos.map((x) => x.id),
    ownRoom.map((x) => x.id).reverse(),
  );
  const self = (await request("/auth/me", "GET", undefined, tenant)).data;
  const newProfile = (extra = {}, image = png) => {
    const form = new FormData();
    form.append("fullName", "Nguyễn Minh – kiểm thử hồ sơ");
    if (image)
      form.append(
        "avatar",
        new Blob([image], { type: "image/png" }),
        "avatar.png",
      );
    for (const [key, value] of Object.entries(extra)) form.append(key, value);
    return form;
  };
  const avatarBefore = diskFiles("avatars");
  for (const extra of [
    { email: "change@example.test" },
    { phone: "0908888888" },
    { role: "Owner" },
    { id: "1" },
  ])
    await multipart("/auth/profile", newProfile(extra), tenant, 400, "PUT");
  await multipart(
    "/auth/profile",
    newProfile({}, new Uint8Array([0, 1, 2])),
    tenant,
    400,
    "PUT",
  );
  assert.deepEqual(diskFiles("avatars"), avatarBefore);
  const updated = await multipart(
    "/auth/profile",
    newProfile(),
    tenant,
    200,
    "PUT",
  );
  assert.equal(updated.email, self.email);
  assert.equal(updated.phone, self.phone);
  assert.equal(updated.role, "Tenant");
  assert.equal(updated.fullName, "Nguyễn Minh – kiểm thử hồ sơ");
  assert(updated.avatarUrl);
  assert(!JSON.stringify(updated).includes("storedName"));
  assert(!JSON.stringify(updated).includes("password"));
  await request(`/auth/avatar/${self.id}`, "GET", undefined, tenant, 200);
  await request(`/auth/avatar/${self.id}`, "GET", undefined, admin, 200);
  await request(`/auth/avatar/${self.id}`, "GET", undefined, tenant2, 403);
  await request(`/auth/avatar/${self.id}`, "GET", undefined, manager, 403);
  await request(`/auth/avatar/${self.id}`, "GET", undefined, undefined, 401);
  await multipart("/auth/profile", newProfile({}, null), manager, 200, "PUT");
  const ownerAccount = ws.users.find((x) => x.username === "manager");
  const managerBody = {
    ...ownerAccount,
    password: "",
    branchIds: [1],
    email: "manager@example.test",
    phone: "0901234567",
  };
  await request(`/users/${ownerAccount.id}`, "PUT", managerBody, manager, 403);
  await request(`/users/${ownerAccount.id}`, "PUT", managerBody, admin, 200);
  const managerProfile = (await request("/auth/me", "GET", undefined, manager))
    .data;
  assert.equal(managerProfile.email, "manager@example.test");
  assert.equal(managerProfile.phone, "0901234567");
  // Đổi mật khẩu bằng HTTP trên tài khoản kiểm thử: phiên cũ hết hiệu lực.
  await request(
    "/auth/password",
    "POST",
    { currentPassword: "incorrect", newPassword: "NewDemo@123456" },
    tenant2,
    400,
  );
  await request(
    "/auth/password",
    "POST",
    { currentPassword: "Demo@123456", newPassword: "NewDemo@123456" },
    tenant2,
    204,
  );
  await request("/auth/me", "GET", undefined, tenant2, 401);
  console.log(
    `PASS: ${checks} multipart checks; batch validation/rollback, large batch, photo order, account profile/avatar privacy and password invalidation.`,
  );
}
