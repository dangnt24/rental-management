import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import ts from "../Frontend/node_modules/typescript/lib/typescript.js";

const source = readFileSync(
  new URL("../Frontend/src/features/rooms/photoViewport.ts", import.meta.url),
  "utf8",
);
const compiled = ts.transpileModule(source, {
  compilerOptions: {
    module: ts.ModuleKind.ES2022,
    target: ts.ScriptTarget.ES2022,
  },
}).outputText;
const { constrainPhoto, zoomPhoto, initialPhotoTransform } = await import(
  "data:text/javascript;base64," + Buffer.from(compiled).toString("base64")
);
const square = { width: 600, height: 600, imageWidth: 1200, imageHeight: 1200 };
const portrait = {
  width: 800,
  height: 600,
  imageWidth: 600,
  imageHeight: 1200,
};
const approx = (a, b) => assert(Math.abs(a - b) < 0.000001, `${a} ≠ ${b}`);

// Không kéo lạc ảnh khỏi khung, kể cả ảnh dọc/ngang và thay đổi kích thước cửa sổ.
assert.deepEqual(
  constrainPhoto({ scale: 1, x: 300, y: -100 }, square),
  initialPhotoTransform,
);
assert.deepEqual(constrainPhoto({ scale: 10, x: 5000, y: -5000 }, square), {
  scale: 5,
  x: 1200,
  y: -1200,
});
assert.deepEqual(
  constrainPhoto({ scale: 0.1, x: 3, y: 3 }, square),
  initialPhotoTransform,
);
assert.deepEqual(constrainPhoto({ scale: 2, x: 100, y: 1000 }, portrait), {
  scale: 2,
  x: 0,
  y: 300,
});
const landscape = {
  width: 400,
  height: 800,
  imageWidth: 1600,
  imageHeight: 900,
};
assert.deepEqual(constrainPhoto({ scale: 2, x: 1000, y: 1000 }, landscape), {
  scale: 2,
  x: 200,
  y: 0,
});

// Zoom theo vị trí con trỏ: điểm đang nhìn giữ nguyên sau khi phóng to.
const anchor = { x: 120, y: -80 };
const zoomed = zoomPhoto(initialPhotoTransform, 2, anchor, anchor, square);
assert.deepEqual(zoomed, { scale: 2, x: -120, y: 80 });
approx((anchor.x - zoomed.x) / zoomed.scale, anchor.x);
approx((anchor.y - zoomed.y) / zoomed.scale, anchor.y);
assert.deepEqual(
  zoomPhoto(zoomed, 1, anchor, anchor, square),
  initialPhotoTransform,
);

// Hai ngón vừa tách/chụm vừa di chuyển: tỷ lệ khoảng cách và tâm gesture độc lập.
const start = { scale: 2, x: 40, y: -30 };
const from = { x: -50, y: 80 },
  to = { x: 25, y: 35 };
const pinched = zoomPhoto(start, 3, from, to, square);
approx(pinched.scale, 3);
approx((from.x - start.x) / start.scale, (to.x - pinched.x) / pinched.scale);
approx((from.y - start.y) / start.scale, (to.y - pinched.y) / pinched.scale);
const moved = zoomPhoto(start, 2, from, to, square);
assert.deepEqual(moved, { scale: 2, x: 115, y: -75 });
assert.deepEqual(
  zoomPhoto(start, 0.2, from, to, square),
  initialPhotoTransform,
);
assert.equal(zoomPhoto(start, 20, from, to, square).scale, 5);
for (const area of [square, portrait, landscape]) {
  const bounded = constrainPhoto({ scale: 3, x: 9000, y: -9000 }, area);
  const fit = Math.min(
    area.width / area.imageWidth,
    area.height / area.imageHeight,
  );
  assert(
    Math.abs(bounded.x) <=
      Math.max(0, (area.imageWidth * fit * 3 - area.width) / 2),
  );
  assert(
    Math.abs(bounded.y) <=
      Math.max(0, (area.imageHeight * fit * 3 - area.height) / 2),
  );
}
console.log(
  "PASS: wheel/pinch anchor, two-finger translation, zoom limits, drag bounds, portrait/landscape and reset geometry.",
);
