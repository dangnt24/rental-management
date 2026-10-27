import { useEffect, useLayoutEffect, useRef, useState } from "react";
import type { PointerEvent as ReactPointerEvent } from "react";
import {
  constrainPhoto,
  initialPhotoTransform,
  zoomPhoto,
} from "./photoViewport";
import type { Point, PhotoTransform } from "./photoViewport";

type Drag = {
  start: Point;
  transform: PhotoTransform;
  started: number;
  type: string;
};
type Pinch = { center: Point; distance: number; transform: PhotoTransform };
const distance = (a: Point, b: Point) => Math.hypot(a.x - b.x, a.y - b.y);
const midpoint = (a: Point, b: Point) => ({
  x: (a.x + b.x) / 2,
  y: (a.y + b.y) / 2,
});

export function usePhotoZoom(photoId: number, move: (step: number) => void) {
  const canvas = useRef<HTMLDivElement>(null);
  const image = useRef<HTMLImageElement>(null);
  const value = useRef<PhotoTransform>(initialPhotoTransform);
  const [transform, setTransform] = useState(initialPhotoTransform);
  const [dragging, setDragging] = useState(false);
  const pointers = useRef(new Map<number, Point>());
  const drag = useRef<Drag | null>(null);
  const pinch = useRef<Pinch | null>(null);
  const usedTwoFingers = useRef(false);
  const actions = useRef({ move });
  actions.current = { move };

  function bounds() {
    const rect = canvas.current?.getBoundingClientRect();
    const img = image.current;
    if (
      !rect?.width ||
      !rect.height ||
      !img?.naturalWidth ||
      !img.naturalHeight
    )
      return null;
    return {
      width: rect.width,
      height: rect.height,
      imageWidth: img.naturalWidth,
      imageHeight: img.naturalHeight,
    };
  }
  function point(clientX: number, clientY: number): Point {
    const rect = canvas.current!.getBoundingClientRect();
    return {
      x: clientX - rect.left - rect.width / 2,
      y: clientY - rect.top - rect.height / 2,
    };
  }
  function apply(next: PhotoTransform) {
    value.current = next;
    setTransform(next);
  }
  function clearGesture() {
    const ids = [...pointers.current.keys()];
    pointers.current.clear();
    drag.current = null;
    pinch.current = null;
    usedTwoFingers.current = false;
    setDragging(false);
    for (const id of ids)
      if (canvas.current?.hasPointerCapture(id))
        canvas.current.releasePointerCapture(id);
  }
  function reset() {
    clearGesture();
    apply(initialPhotoTransform);
  }
  function zoom(scale: number, anchor: Point = { x: 0, y: 0 }) {
    const area = bounds();
    if (!area) return;
    apply(zoomPhoto(value.current, scale, anchor, anchor, area));
  }
  const wheel = useRef((event: WheelEvent) => {});
  wheel.current = (event) => {
    event.preventDefault();
    if (pointers.current.size) return;
    const delta =
      event.deltaY *
      (event.deltaMode === 1
        ? 16
        : event.deltaMode === 2
          ? canvas.current!.clientHeight
          : 1);
    zoom(
      value.current.scale *
        Math.exp(-Math.max(-1000, Math.min(1000, delta)) * 0.0015),
      point(event.clientX, event.clientY),
    );
  };
  useEffect(() => {
    const element = canvas.current;
    if (!element) return;
    const onWheel = (event: WheelEvent) => wheel.current(event);
    // React onWheel có thể passive: phải chặn cuộn trang/zoom trình duyệt tại vùng ảnh.
    element.addEventListener("wheel", onWheel, { passive: false });
    return () => element.removeEventListener("wheel", onWheel);
  }, []);
  useLayoutEffect(() => {
    reset();
    const observer = new ResizeObserver(() => {
      const area = bounds();
      if (area) apply(constrainPhoto(value.current, area));
      clearGesture();
    });
    if (canvas.current) observer.observe(canvas.current);
    return () => observer.disconnect();
  }, [photoId]);

  function onPointerDown(event: ReactPointerEvent<HTMLDivElement>) {
    if (event.button !== 0 || !bounds()) return;
    if (pointers.current.size >= 2) {
      usedTwoFingers.current = true;
      return;
    }
    event.preventDefault();
    const p = point(event.clientX, event.clientY);
    pointers.current.set(event.pointerId, p);
    event.currentTarget.setPointerCapture(event.pointerId);
    if (pointers.current.size === 1) {
      usedTwoFingers.current = false;
      drag.current = {
        start: p,
        transform: value.current,
        started: performance.now(),
        type: event.pointerType,
      };
      setDragging(value.current.scale > 1);
    } else {
      usedTwoFingers.current = true;
      const [a, b] = [...pointers.current.values()];
      pinch.current = {
        center: midpoint(a, b),
        distance: Math.max(1, distance(a, b)),
        transform: value.current,
      };
      setDragging(true);
    }
  }
  function onPointerMove(event: ReactPointerEvent<HTMLDivElement>) {
    if (!pointers.current.has(event.pointerId)) return;
    const area = bounds();
    if (!area) return;
    const p = point(event.clientX, event.clientY);
    pointers.current.set(event.pointerId, p);
    if (pointers.current.size === 2 && pinch.current) {
      const [a, b] = [...pointers.current.values()];
      const start = pinch.current;
      apply(
        zoomPhoto(
          start.transform,
          (start.transform.scale * distance(a, b)) / start.distance,
          start.center,
          midpoint(a, b),
          area,
        ),
      );
    } else if (drag.current && value.current.scale > 1) {
      const start = drag.current;
      apply(
        constrainPhoto(
          {
            ...start.transform,
            x: start.transform.x + p.x - start.start.x,
            y: start.transform.y + p.y - start.start.y,
          },
          area,
        ),
      );
    }
  }
  function finish(
    event: ReactPointerEvent<HTMLDivElement>,
    cancelled: boolean,
  ) {
    if (!pointers.current.has(event.pointerId)) return;
    const start = drag.current;
    pointers.current.delete(event.pointerId);
    if (event.currentTarget.hasPointerCapture(event.pointerId))
      event.currentTarget.releasePointerCapture(event.pointerId);
    if (pointers.current.size === 1) {
      pinch.current = null;
      drag.current = {
        start: [...pointers.current.values()][0],
        transform: value.current,
        started: performance.now(),
        type: event.pointerType,
      };
      setDragging(value.current.scale > 1);
    } else if (!pointers.current.size) {
      setDragging(false);
      drag.current = null;
      pinch.current = null;
      // Sau pinch hoặc kéo ảnh đã zoom, không được hiểu nhầm thành chuyển ảnh.
      if (
        !cancelled &&
        !usedTwoFingers.current &&
        start &&
        start.type !== "mouse" &&
        start.transform.scale === 1 &&
        value.current.scale === 1 &&
        performance.now() - start.started < 700
      ) {
        const end = point(event.clientX, event.clientY);
        const dx = end.x - start.start.x,
          dy = end.y - start.start.y;
        if (Math.abs(dx) > 48 && Math.abs(dx) > Math.abs(dy) * 1.3)
          actions.current.move(dx < 0 ? 1 : -1);
      }
      usedTwoFingers.current = false;
    }
  }
  return {
    canvas,
    image,
    transform,
    dragging,
    reset,
    zoom,
    handlers: {
      onPointerDown,
      onPointerMove,
      onPointerUp: (event: ReactPointerEvent<HTMLDivElement>) =>
        finish(event, false),
      onPointerCancel: (event: ReactPointerEvent<HTMLDivElement>) =>
        finish(event, true),
      onLostPointerCapture: (event: ReactPointerEvent<HTMLDivElement>) =>
        finish(event, true),
      onDoubleClick: (event: React.MouseEvent<HTMLDivElement>) =>
        zoom(
          value.current.scale > 1 ? 1 : 2.5,
          point(event.clientX, event.clientY),
        ),
    },
  };
}
