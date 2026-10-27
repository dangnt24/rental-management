import { useEffect } from "react";

let locks = 0;
let previousOverflow = "";

// Modal chi tiết và khung ảnh có thể cùng mở/cùng đóng khi đổi trang.
export function useBodyScrollLock() {
  useEffect(() => {
    if (locks++ === 0) {
      previousOverflow = document.body.style.overflow;
      document.body.style.overflow = "hidden";
    }
    return () => {
      if (--locks === 0) document.body.style.overflow = previousOverflow;
    };
  }, []);
}
