# Rental Management System (Enterprise Edition)

Hệ thống quản lý nhà trọ chuyên nghiệp, được xây dựng theo kiến trúc Clean Architecture.

## Tính năng chính
- Quản lý đa chi nhánh, dãy trọ.
- Quản lý phòng, người thuê, hợp đồng.
- Tự động tính hóa đơn điện, nước, dịch vụ.
- Thanh toán và theo dõi công nợ.
- Phân quyền chi tiết (Role-based Access Control).
- Thông báo qua Email (Hangfire).

## Tech Stack
- **Backend**: .NET 8, EF Core, PostgreSQL, Serilog, Hangfire.
- **Frontend**: React, Vite, TailwindCSS, TanStack Query, Zustand.

## Hướng dẫn cài đặt
1. Cấu hình Connection String trong `appsettings.json`.
2. Chạy script SQL trong `Source/Database/db_enterprise.sql`.
3. Mở Solution bằng Visual Studio 2022 và chạy project `Rental.Api`.
4. Di chuyển vào thư mục `Source/Frontend`, chạy `npm install` và `npm run dev`.

## Docker
Chạy `docker-compose up -d` để khởi động toàn bộ hệ thống.
