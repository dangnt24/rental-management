export type Point = { x: number; y: number };
export type PhotoTransform = Point & { scale: number };
export type PhotoBounds = {
  width: number;
  height: number;
  imageWidth: number;
  imageHeight: number;
};
export const MIN_PHOTO_SCALE = 1;
export const MAX_PHOTO_SCALE = 5;
export const initialPhotoTransform: PhotoTransform = { scale: 1, x: 0, y: 0 };

export function constrainPhoto(
  transform: PhotoTransform,
  bounds: PhotoBounds,
): PhotoTransform {
  const scale = Math.min(
    MAX_PHOTO_SCALE,
    Math.max(MIN_PHOTO_SCALE, transform.scale),
  );
  const fit = Math.min(
    bounds.width / bounds.imageWidth,
    bounds.height / bounds.imageHeight,
  );
  const limitX = Math.max(
    0,
    (bounds.imageWidth * fit * scale - bounds.width) / 2,
  );
  const limitY = Math.max(
    0,
    (bounds.imageHeight * fit * scale - bounds.height) / 2,
  );
  return {
    scale,
    x: limitX === 0 ? 0 : Math.max(-limitX, Math.min(limitX, transform.x)),
    y: limitY === 0 ? 0 : Math.max(-limitY, Math.min(limitY, transform.y)),
  };
}

// Giữ điểm ảnh dưới con trỏ/tâm hai ngón, đồng thời cho tâm hai ngón di chuyển.
export function zoomPhoto(
  start: PhotoTransform,
  scale: number,
  from: Point,
  to: Point,
  bounds: PhotoBounds,
): PhotoTransform {
  const nextScale = Math.min(MAX_PHOTO_SCALE, Math.max(MIN_PHOTO_SCALE, scale));
  const ratio = nextScale / start.scale;
  return constrainPhoto(
    {
      scale: nextScale,
      x: to.x - (from.x - start.x) * ratio,
      y: to.y - (from.y - start.y) * ratio,
    },
    bounds,
  );
}
