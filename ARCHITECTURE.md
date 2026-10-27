# Bản đồ source để đọc và debug

Source được tách theo chức năng ngày 26/10/2026. API, dữ liệu PostgreSQL, các quy tắc nghiệp vụ và giao diện được giữ nguyên trong đợt tách này.

## Frontend

```text
Frontend/src/
  main.tsx                        Khởi động React và nạp CSS
  app/
    App.tsx                       Kiểm tra phiên đăng nhập, ghép ứng dụng
    AppLayout.tsx                 Sidebar, thanh trên, tiêu đề và nút chính
    WorkspacePages.tsx            Chọn màn hình theo #overview, #rooms...
    WorkspaceContext.tsx          Dữ liệu đã tải, bộ lọc, trạng thái dialog
    WorkspaceDialogs.tsx          Điều phối form, file, thông báo và hóa đơn
    navigation.ts                 Danh sách menu
  features/
    auth/                         Đăng nhập và useSession
    overview/                     Tổng quan
    rooms/                        Phòng trọ
    tenants/                      Hồ sơ người thuê
    contracts/                    Hợp đồng, nhận cọc, gia hạn, trả phòng
    billing/                      Điện nước, hóa đơn, chi tiết/in hóa đơn
    payments/                     Thu tiền và công nợ
    incidents/                    Sự cố, bảo trì
    settings/                     Khu trọ, đơn giá, tài khoản và nhật ký
    attachments/                  Dialog đính kèm/tải file
    catalog/                      Trang công khai tìm/lọc và xem phòng trống
    tenantPortal/                 Không gian riêng của người thuê
  shared/
    api.ts                        fetch, cookie, header, xử lý lỗi API
    types.ts                      Kiểu dữ liệu dùng chung
    formatters.ts                 Định dạng tiền, ngày, mã chứng từ
    labels.ts                     Nhãn trạng thái và vai trò
    forms.ts                      Các mô tả trường nhập dùng chung
    components/                   Table, EditForm, Modal, Toolbar...
  styles.css                      Giao diện và CSS in hóa đơn
```

Trong mỗi feature, `...Page.tsx` hiển thị dữ liệu; `use...Forms.ts` chuẩn bị trường nhập và gọi API khi lưu. Các bảng hóa đơn/thanh toán có `useInvoiceColumns.tsx` / `usePaymentColumns.tsx` để dùng lại giữa nhiều màn hình.

`WorkspaceContext` là nơi chia sẻ dữ liệu và bộ lọc giữa các màn hình. `reload()` gọi `/api/workspace`; sau khi lưu thành công, `completed()` tải lại dữ liệu và hiển thị thông báo. Context không chứa các form tính năng. Đăng xuất/hết phiên tháo WorkspaceProvider ra khỏi ứng dụng để bỏ dữ liệu của phiên cũ.

## Backend

```text
Rental.Api/
  Program.cs                      Khởi động, DI, đăng nhập, route API, giao dịch
  Features/
    Common/
      BusinessRules.cs            Require, Text, Money và ngày nghiệp vụ
      BusinessError.cs            Lỗi nghiệp vụ kèm mã HTTP
      FeatureService.cs           DbContext, quyền theo khu và ghi audit
    Branches/BranchService.cs     Khu trọ
    Rooms/RoomService.cs          Phòng
    Tenants/TenantService.cs      Người thuê
    Contracts/ContractService.cs  Tạo, gia hạn, trả phòng
    Deposits/DepositService.cs    Nhận cọc và tính số dư cọc
    Fees/FeeService.cs            Loại phí, đơn giá
    Billing/ReadingService.cs     Chỉ số điện nước
    Billing/InvoiceService.cs     Lập/hủy/xem hóa đơn
    Billing/BillingRules.cs       Kiểm tra kỳ thu
    Payments/PaymentService.cs    Thu tiền và bù trừ cọc
    Incidents/IncidentService.cs  Sự cố/bảo trì
    Accounts/UserService.cs       Tài khoản, quyền và mật khẩu
    Attachments/                  Quyền file và endpoint upload/download
    Workspace/WorkspaceService.cs Dữ liệu tổng hợp trả cho giao diện
    Catalog/CatalogService.cs     Phòng trống và ảnh công khai, không trả hồ sơ riêng
    TenantPortal/                 Dữ liệu đúng người thuê và tiếp nhận yêu cầu sửa chữa
  Domain/Entities.cs              Các entity nghiệp vụ
  Data/RentalDb.cs                Mapping EF, quan hệ và ràng buộc
```

Các DTO nhận từ frontend nằm trong `Requests.cs` ở đúng thư mục feature tương ứng. File gom `RentalService.cs` và `Features/Requests.cs` cũ đã được thay bằng các file theo chức năng.

### Một luồng database: PostgreSQL

Đọc theo thứ tự: `Domain/Entities.cs` mô tả dữ liệu C# → `Data/RentalDb.cs` ánh xạ entity sang bảng/cột → `Program.cs` dùng `UseNpgsql` và `ConnectionStrings:Rental` để kết nối PostgreSQL. Không có nhánh chọn database khác.

Khi nhận yêu cầu ghi: endpoint trong `Program.cs` nhận DTO → service kiểm tra quyền/nghiệp vụ → cập nhật entity → `FeatureService.Save` gọi `SaveChangesAsync` → EF Core sinh SQL gửi PostgreSQL. Khi đọc, EF Core chuyển kết quả SQL thành đối tượng C# để API trả JSON.

Build chỉ biên dịch code. Đổi cấu trúc bảng cần SQL cập nhật database và sửa entity/mapping, DTO, service, dữ liệu workspace, giao diện tương ứng; source chưa có EF migrations.

### Khách, người thuê và nhân sự quản lý

`App.tsx` mở `CatalogPage` khi vào trang gốc hoặc `#browse`; `#login` mở đăng nhập. Sau đăng nhập, Tenant dùng `TenantPortal`, Owner/Manager dùng workspace quản lý. Không gian người thuê không dùng `WorkspaceContext` của nhân sự quản lý.

`Program.cs` chia route: `/api/public/*` không cần đăng nhập, `/api/tenant/*` chỉ Tenant, nhóm quản lý chỉ Owner/Manager. Các endpoint `/api/auth/me`, `/api/auth/password`, `/api/auth/logout` dùng cho cả ba role. `User.TenantId` liên kết duy nhất với hồ sơ người thuê; portal suy ra hồ sơ từ tài khoản đã xác thực và chỉ truy vấn hợp đồng có tên hồ sơ đó. Không nhận TenantId từ trình duyệt để chọn phạm vi đọc.

`Attachment.IsPublic` chỉ công khai ảnh phòng được nhân sự quản lý chọn. API công khai vẫn kiểm tra phòng còn trống mỗi lần tải ảnh. `Incident.ReportedByTenantId` dùng theo dõi đúng yêu cầu do người thuê gửi; người thuê không chọn trạng thái, chi phí hoặc cách xử lý. Cập nhật database hiện có bằng `Database/03_public_tenant.sql`; database trống dùng schema mới.

Các service kế thừa `FeatureService` để cùng dùng kiểm tra quyền, tìm phòng/hợp đồng/hóa đơn trong phạm vi quyền và lưu audit. Các service trong cùng HTTP request dùng chung một `RentalDb` do DI cấp. `ContractService` và `PaymentService` dùng thêm `DepositService` khi cần đọc số dư cọc; không tạo DbContext hay giao dịch riêng cho thao tác này.

`WriteTransactionFilter` ở Program vẫn bao toàn bộ request ghi trong giao dịch serializable. `SaveChangesAsync()` ghi trong giao dịch; filter chỉ commit khi nghiệp vụ hoàn tất. Phân quyền, số tiền, chỉ số và điều kiện hợp đồng vẫn được kiểm tra ở backend.

## Mở file nào khi sửa chức năng?

| Việc cần sửa | Giao diện / form | Backend |
| --- | --- | --- |
| Phòng | `features/rooms/RoomsPage.tsx`, `useRoomForms.ts` | `Features/Rooms/RoomService.cs`, `Requests.cs` |
| Người thuê | `features/tenants/` | `Features/Tenants/` |
| Hợp đồng/gia hạn/trả phòng | `features/contracts/` | `Features/Contracts/`, `Features/Deposits/` |
| Điện nước/hóa đơn | `features/billing/` | `Features/Billing/` |
| Thu tiền | `features/payments/` | `Features/Payments/`, `Features/Deposits/` |
| Sự cố | `features/incidents/` | `Features/Incidents/` |
| Khu trọ/đơn giá/tài khoản | `features/settings/` | `Features/Branches/`, `Features/Fees/`, `Features/Accounts/` |
| Tổng quan/dữ liệu trả về | `features/overview/`, `app/WorkspaceContext.tsx` | `Features/Workspace/WorkspaceService.cs` |
| Lỗi HTTP dùng chung | `shared/api.ts` | Middleware trong `Program.cs` |

Các đường dẫn trong bảng tính từ `Frontend/src` hoặc `Rental.Api` theo cột. Điểm khởi đầu để debug một thao tác là tìm URL trong `Program.cs`, đặt breakpoint ở service được endpoint gọi, đồng thời xem request trong F12 → Network.

Ví dụ thêm phòng:

```text
RoomsPage → useRoomForms.editRoom → EditForm
→ shared/api.ts: POST /api/rooms
→ Program.cs → RoomService.UpsertRoom
→ FeatureService.Save → RentalDb → PostgreSQL
→ completed → reload workspace → render lại RoomsPage
```

Để đổi cách tính hóa đơn, đặt breakpoint ở `InvoiceService.GenerateInvoice`; đổi cách thu tiền ở `PaymentService.RecordPayment`. Khi thêm cột mới, sửa Entity, mapping, DTO, service, phần dữ liệu trả về của Workspace và form/bảng tương ứng. PostgreSQL hiện vẫn cần script cập nhật schema; tách file không tự thay đổi cấu trúc database.

## Chạy và kiểm tra

Vẫn dùng `Start.cmd` như trước. Khi debug bằng Visual Studio, mở `RentalManagement.sln`, chọn profile `http` và nhấn F5; dừng server đang chiếm cổng 5247 trước hoặc attach debugger vào đúng tiến trình.

Build frontend: chạy `tsc --noEmit` và Vite build qua `Start.ps1` hoặc script `build` trong `Frontend/package.json`. Build API: `dotnet build RentalManagement.sln`. Chạy kiểm thử bằng `node tools/postgres-test.mjs` hoặc `pnpm test` trong `tools`. Script tạo PostgreSQL nhúng riêng rồi gọi `smoke-test.mjs`; file và log kiểm thử nằm trong `.tools/test-data`.

Bộ kiểm thử kiểm tra hợp đồng, chỉ số điện nước, hóa đơn, thu tiền đồng thời, cọc, trả phòng và quyền truy cập qua Npgsql/PostgreSQL nhúng. Bản sao các file gốc trước khi tách được giữ trong `.tools/refactor-before-2026-10-26/` để đối chiếu khi cần.
