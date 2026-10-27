export async function api(path: string, method = "GET", body?: unknown) {
  const multipart = body instanceof FormData;
  const response = await fetch("/api" + path, {
    method,
    credentials: "same-origin",
    headers: {
      "X-Rental-Request": "1",
      ...(!multipart && body !== undefined
        ? { "Content-Type": "application/json" }
        : {}),
    },
    body:
      body === undefined ? undefined : multipart ? body : JSON.stringify(body),
  });
  if (!response.ok) {
    let message =
      response.status === 401
        ? "Phiên đăng nhập đã hết hạn."
        : response.status === 429
          ? "Bạn thao tác quá nhiều lần. Hãy thử lại sau một phút."
          : "Không thể hoàn tất yêu cầu.";
    try {
      const error = await response.json();
      message = error.error || error.detail || error.title || message;
    } catch {
      /* Phản hồi không có JSON. */
    }
    if (response.status === 401 && path !== "/auth/login")
      window.dispatchEvent(new Event("session-expired"));
    throw new Error(message);
  }
  return response.status === 204 ? undefined : response.json();
}
