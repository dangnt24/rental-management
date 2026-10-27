# DVP Home — Bàn giao cấu trúc source và nghiệp vụ

**Cập nhật: 27/10/2026.** Tài liệu này dùng để chuyển bối cảnh dự án sang một cuộc chat hoặc tài khoản ChatGPT khác. Nội dung mô tả bản source tại thời điểm bàn giao; khi code thay đổi, cần đối chiếu lại các file thực tế.

Đọc tài liệu này trước khi sửa dự án. Nếu chỉ được gửi file Markdown này, có thể hiểu thiết kế và nghiệp vụ nhưng chưa thể kiểm tra hoặc chỉnh sửa source trên máy của chủ dự án. Muốn tiếp tục lập trình cần nhận thêm source hoặc được cấp quyền truy cập môi trường chạy.

Tài liệu không chứa mật khẩu đăng nhập, mật khẩu database, khóa phiên hay dữ liệu cá nhân thực tế. Đây là bản mô tả dự án, không thay thế bản sao source hoặc bản sao lưu database.

## 1. Sản phẩm và mong muốn của chủ dự án

- Tên thương hiệu hiện tại: **DVP Home**. Trước đây giao diện dùng tên **An Cư**; đã đổi thương hiệu và gắn logo do người dùng cung cấp.
- Web app quản lý nhà trọ cho chủ trọ, quản lý và người thuê; khách chưa đăng nhập vẫn tìm phòng trống được.
- Luồng nghiệp vụ chính: **khu trọ → phòng → người thuê → hợp đồng/cọc → điện nước → hóa đơn → thu tiền/công nợ → quyết toán trả phòng**.
- Chủ dự án đang học cách đọc source và cú pháp C#/API. Khi giải thích nên đi từng lớp, dùng ví dụ thực tế trong code, nói ngắn gọn và chỉ rõ file nào làm gì.
- Ưu tiên source rõ ràng, chia theo chức năng. Không tự thêm tầng kiến trúc, hệ thống quyền hoặc loại database ngoài nhu cầu đã chốt.
- SQLite từng dùng cho chạy thử, sau đó **đã loại bỏ theo yêu cầu người dùng**. Bản hiện tại chỉ dùng PostgreSQL.

## 2. Đâu là source chính

Đường dẫn trên máy đang phát triển:

```text
C:\rental-management\
├── Source\                   SOURCE CHÍNH, có Git repository riêng
├── Document\                 Tài liệu và một bộ source/SQL cũ
├── output\                   Logo và các tài liệu xuất cho người dùng
└── logo.png                  Logo gốc người dùng cung cấp
```

**Thư mục làm việc của ứng dụng là `C:\rental-management\Source`.** Các đường dẫn tương đối còn lại trong tài liệu được tính từ thư mục này, trừ khi có chú thích khác.

`Document/Source`, SQL V2 và các file trong `Document/_Archive` là bộ cũ. Không lấy README của bộ cũ để suy luận tính năng bản hiện tại; không chạy chồng SQL cũ vào database của bản mới.

Thư mục cha `C:\rental-management` không phải repository chính. Tại thời điểm bàn giao, repository `Source` có nhiều file đang sửa và nhiều thư mục chưa được Git theo dõi. Nếu chỉ lấy commit cũ hoặc clone repository mà chưa lưu các thay đổi này, có thể thiếu phần lớn ứng dụng. Cần kiểm tra `git status` và mang theo đúng working tree.

## 3. Công nghệ và cách chạy tổng quát

| Phần | Công nghệ thực tế |
| --- | --- |
| Backend | ASP.NET Core 8, C#, Minimal API, một project `Rental.Api` |
| ORM và kết nối DB | Entity Framework Core; Npgsql cho PostgreSQL |
| Database | PostgreSQL; schema hướng tới PostgreSQL 16+ |
| Frontend | React 18, TypeScript, Vite, CSS thuần, icon Lucide |
| Dữ liệu dùng chung phía quản lý | React Context qua `WorkspaceContext` |
| Xác thực | Cookie HttpOnly cùng origin |
| Chạy local | `Start.cmd` gọi `Start.ps1`, mặc định cổng 5247 |
| Docker | Build frontend + backend, chạy cùng PostgreSQL 16 |
| Kiểm thử | Node.js, HTTP checks, PostgreSQL nhúng PGlite qua socket và Npgsql |

Phiên bản tham chiếu trong source: EF Core 8.0.25, Npgsql EF provider 8.0.11, React 18.3.1, TypeScript 5.7.3, Vite 6.4.1. `package.json`, lockfile và `.csproj` là nơi quyết định phiên bản thực tế.

Frontend hiện không dùng React Router, Redux, Zustand, TanStack Query hoặc Tailwind. Backend không có bộ project Domain/Application/Infrastructure tách riêng, không dùng Controller hay Repository riêng cho từng bảng. Các mô tả khác trong source cũ không áp dụng cho bản này.

```text
Trình duyệt
  ├── tải HTML/CSS/JavaScript từ .NET
  └── gọi /api/...
          ↓
      ASP.NET Core
          ↓
      Feature service
          ↓
      RentalDb / EF Core / Npgsql
          ↓
      PostgreSQL
```

Node.js phục vụ tooling/build và các script kiểm thử, không phải server nghiệp vụ của ứng dụng. Sau build, .NET phục vụ cả giao diện và API trên cùng địa chỉ.

## 4. Bản đồ thư mục và vai trò từng file

```text
Source/
├── DVP_HOME_HANDOFF.md                 File bàn giao này
├── README.md                          Hướng dẫn chạy và quy tắc nghiệp vụ
├── ARCHITECTURE.md                     Bản đồ đọc code/debug chi tiết
├── RentalManagement.sln               Solution mở trong Visual Studio/dotnet
├── Start.cmd                          Gọi PowerShell tại đúng thư mục
├── Start.ps1                          Chuẩn bị công cụ, build, chạy .NET
├── Dockerfile
├── compose.yaml
├── Database/
│   ├── 01_schema.sql                  Tạo schema mới từ model EF
│   ├── 02_sample.sql                  Dữ liệu hư cấu cho database demo
│   └── 03_public_tenant.sql           Nâng cấp DB trước tính năng Tenant/public
├── Rental.Api/
│   ├── Program.cs                     Cấu hình, DI, auth, route, lỗi, transaction
│   ├── Rental.Api.csproj              Target .NET và package references
│   ├── appsettings.json               Cấu hình nền
│   ├── appsettings.Development.json   Cấu hình môi trường phát triển
│   ├── appsettings.Local.example.json Mẫu cấu hình riêng cho từng máy
│   ├── appsettings.Local.json         Cấu hình thật của máy, không chia sẻ
│   ├── Domain/Entities.cs             Model dữ liệu nghiệp vụ
│   ├── Data/RentalDb.cs                DbSet, mapping, quan hệ, ràng buộc
│   ├── Features/                      Service và DTO theo chức năng
│   ├── Properties/launchSettings.json Profile debug, URL local
│   ├── App_Data/                      Uploads và khóa bảo vệ cookie
│   └── wwwroot/                       Giao diện đã build, có thể sinh lại
├── Frontend/
│   ├── public/logo.png                Logo DVP Home dùng thật trên web
│   ├── index.html                     HTML gốc, tiêu đề tab, favicon
│   ├── package.json                   Dependency và lệnh dev/build
│   ├── pnpm-lock.yaml                 Khóa phiên bản dependency
│   ├── vite.config.js                 Output wwwroot, proxy API lúc dev
│   ├── tsconfig.json                  Cấu hình TypeScript
│   └── src/
│       ├── main.tsx                   Mount React và nạp CSS
│       ├── app/                       Ghép ứng dụng, layout, menu, context
│       ├── features/                  Màn hình và form theo tính năng
│       ├── shared/                    API client, types, component dùng chung
│       └── styles.css                 CSS toàn ứng dụng và CSS in hóa đơn
├── tools/
│   ├── generate-sample.mjs            Sinh lại SQL dữ liệu demo
│   ├── postgres-test.mjs              Tạo PostgreSQL riêng và gọi HTTP tests
│   ├── smoke-test.mjs                 Bộ kiểm thử API
│   └── package.json                   Dependency kiểm thử
└── .tools/                            SDK, bản build, log/test data/backup local
```

### Backend chia theo feature

| Thư mục trong `Rental.Api/Features` | Việc xử lý |
| --- | --- |
| `Common` | Validation dùng chung, lỗi nghiệp vụ, quyền theo khu, lưu audit |
| `Branches` | Thêm/sửa khu trọ; chỉ Owner |
| `Rooms` | Thêm/sửa phòng, điều kiện sức chứa, ngừng sử dụng |
| `Tenants` | Hồ sơ người thuê theo khu |
| `Contracts` | Tạo hợp đồng, gia hạn, quyết toán trả phòng |
| `Deposits` | Nhận cọc, tính số dư cọc |
| `Fees` | Loại phí và đơn giá dịch vụ; chỉ Owner được sửa |
| `Billing` | Chỉ số điện nước, quy tắc kỳ thu, hóa đơn |
| `Payments` | Thu tiền nhiều lần và bù trừ cọc |
| `Incidents` | Tiếp nhận/xử lý sự cố của nhân sự quản lý |
| `Accounts` | Tài khoản, gán quyền, liên kết Tenant, đổi mật khẩu |
| `Attachments` | Upload/download tệp và quyền công khai ảnh phòng |
| `Workspace` | Gom dữ liệu và tính tổng quan cho Owner/Manager |
| `Catalog` | Truy vấn phòng trống và ảnh công khai |
| `TenantPortal` | Dữ liệu riêng của người thuê và gửi yêu cầu sửa chữa |

DTO đầu vào thường nằm trong `Requests.cs` của feature tương ứng. DTO yêu cầu sửa chữa của người thuê hiện được khai báo ngay trong `TenantPortalService.cs`.

### Frontend chia theo trách nhiệm

- `app/App.tsx`: chọn trang công khai, đăng nhập, portal Tenant hoặc workspace Owner/Manager.
- `app/AppLayout.tsx`: khung menu, tiêu đề, nút thao tác của nhân sự quản lý.
- `app/WorkspaceContext.tsx`: dữ liệu quản lý dùng chung, khu đang chọn, lọc, modal, thông báo; gọi `/api/workspace` để reload.
- `app/WorkspacePages.tsx`: chọn trang quản lý theo hash.
- `app/WorkspaceDialogs.tsx`: ghép form chung, file đính kèm và dialog hóa đơn.
- `app/navigation.ts`: danh sách menu quản lý.
- `features/*/*Page.tsx`: màn hình/bảng dữ liệu của feature.
- `features/*/use*Forms.ts`: định nghĩa trường nhập, giá trị đầu và hàm gửi API.
- `features/billing/useInvoiceColumns.tsx`, `features/payments/usePaymentColumns.tsx`: cột bảng dùng lại.
- `features/catalog/CatalogPage.tsx`: trang tìm phòng công khai, bộ lọc, danh sách và modal chi tiết.
- `features/tenantPortal/TenantPortal.tsx`: không gian người thuê, không dùng context dữ liệu của nhân sự quản lý.
- `features/auth/useSession.ts`: đọc phiên hiện tại và xử lý sự kiện hết phiên.
- `shared/api.ts`: fetch `/api`, cookie, header ghi, FormData và xử lý lỗi.
- `shared/types.ts`: các kiểu như User, Field, FormDefinition; `Row` hiện là kiểu linh hoạt `Record<string, any>`.
- `shared/components/EditForm.tsx`: render form theo mô tả; hỗ trợ `Field.visible(values)` để hiện trường theo role.
- `shared/components/BrandLogo.tsx`: logo chung; `SiteHeader.tsx`: header trang công khai/Tenant.
- `shared/components/InvoiceContent.tsx`: nội dung hóa đơn dùng chung cho quản lý và Tenant.

## 5. Nguyên lý Entity, mapping và luồng API

### 5.1 Khai báo dữ liệu và kết nối

1. `Domain/Entities.cs` định nghĩa kiểu dữ liệu C#, ví dụ `Room` có tên, giá, sức chứa.
2. `Data/RentalDb.cs` đưa các kiểu vào `DbSet` và cấu hình bảng, cột, quan hệ, index, CHECK.
3. `Program.cs` đăng ký `RentalDb` trong DI, dùng `UseNpgsql` với `ConnectionStrings:Rental`.
4. EF Core dùng model/mapping để sinh SQL khi cần đọc/ghi.

Entity không tự gọi service, không tự tạo bảng và không tự nhận request. `new Room()` chỉ tạo đối tượng trong bộ nhớ. Database PostgreSQL và model trong code phải có cấu trúc tương thích.

Ví dụ mapping rút gọn:

```csharp
public DbSet<Room> Rooms => Set<Room>();
b.Entity<Room>().ToTable("rooms");
b.Entity<Room>().HasOne<Branch>().WithMany().HasForeignKey(x => x.BranchId);
```

PostgreSQL dùng tên bảng chữ thường như `rooms`, nhưng nhiều tên cột được giữ PascalCase như `"Price"`, `"TenantId"`. Khi viết SQL tay phải chú ý dấu nháy kép và tên thật, không tự chuyển tất cả sang snake_case.

### 5.2 Một request thêm phòng

```text
RoomsPage → useRoomForms → EditForm
  → shared/api.ts gửi POST /api/rooms
  → middleware xác thực + policy Owner/Manager
  → .NET bind JSON thành RoomRequest
  → Program.cs gọi RoomService.UpsertRoom(null, request)
  → kiểm tra quyền với khu, giá, sức chứa, tên
  → tạo Room và gán dữ liệu request
  → db.Rooms.Add(entity)
  → FeatureService.Save thêm audit và gọi SaveChangesAsync
  → EF Core/Npgsql gửi INSERT xuống PostgreSQL
  → transaction thành công thì commit
  → API trả JSON
  → completed() reload /api/workspace rồi giao diện render lại
```

`Add()` đánh dấu đối tượng cần thêm; `SaveChangesAsync()` mới gửi thay đổi xuống database. Khi đọc, EF chuyển kết quả SQL thành đối tượng C#, sau đó ASP.NET Core trả JSON cho frontend.

`RoomRequest` là dữ liệu đầu vào, `Room` là entity lưu trữ; chúng có mục đích khác nhau dù một số trường giống nhau. Tham số ID `null` trong `UpsertRoom` là tạo mới; có ID là sửa.

### 5.3 DI và transaction

- Các feature service và `RentalDb` được đăng ký theo scope của HTTP request.
- Các service trong cùng request dùng chung `RentalDb`; ví dụ `PaymentService` dùng thêm `DepositService` để tính số dư cọc.
- `FeatureService` cung cấp `OwnerOnly`, `AllowedBranches`, `CheckBranch`, tìm phòng/hợp đồng/hóa đơn theo phạm vi quyền và `Save` kèm audit.
- `WriteTransactionFilter` bao request ghi trong nhóm API đã đăng nhập bằng transaction `Serializable`. Nhiều `SaveChangesAsync` trong một nghiệp vụ vẫn nằm trong transaction chung.
- Có `SemaphoreSlim` để tuần tự hóa ghi trong một tiến trình ứng dụng; đây không phải khóa phân tán giữa nhiều server.
- `GET`/`HEAD` không đi vào transaction ghi này. Lỗi nghiệp vụ hoặc xung đột được trả HTTP phù hợp; không tự sửa dữ liệu để bỏ qua lỗi.

## 6. Các entity và quan hệ chính

| Entity / bảng | Nội dung và liên kết |
| --- | --- |
| `Entity` | Lớp cơ sở: Id, CreatedAt, CreatedBy, IsArchived |
| `Branch` / `branches` | Khu trọ, tên và địa chỉ |
| `Room` / `rooms` | Phòng thuộc Branch; giá tham khảo, sức chứa, trạng thái sửa chữa |
| `Tenant` / `tenants` | Hồ sơ người thuê thuộc một Branch; không tự đồng nghĩa tài khoản |
| `User` / `users` | Tài khoản, hash mật khẩu, Role, IsActive, TenantId tùy role |
| `UserBranch` / `user_branches` | Các khu được giao cho Manager |
| `Contract` / `contracts` | Phòng thuê, ngày, tiền thuê/cọc thỏa thuận, Active/Closed |
| `ContractTenant` / `contract_tenants` | Liên kết hợp đồng với người ở và người đại diện |
| `Fee` / `fees` | Phí của khu: Electricity, Water, Fixed hoặc PerPerson |
| `Reading` / `readings` | Chỉ số điện/nước cũ và mới theo hợp đồng, tháng, năm |
| `Invoice` / `invoices` | Hóa đơn kỳ thu, tổng tiền, hạn trả, Issued/Cancelled |
| `InvoiceItem` / `invoice_items` | Khoản thu, số lượng, đơn giá và thành tiền được chụp lại |
| `Payment` / `payments` | Một lần thanh toán của hóa đơn |
| `DepositEntry` / `deposit_entries` | Sổ cọc: Received, Applied, Deducted, Refunded |
| `Incident` / `incidents` | Sự cố của phòng; ReportedByTenantId nhận diện người thuê gửi |
| `Attachment` / `attachments` | Metadata file; EntityType/EntityId trỏ hồ sơ đính kèm; IsPublic cho ảnh phòng |
| `AuditEntry` / `audit_entries` | Nhật ký thao tác |

```text
Branch → Room → Contract → Invoice → Payment
                  │          └── InvoiceItem
                  ├── ContractTenant → Tenant ← User.TenantId
                  ├── Reading
                  └── DepositEntry

User → UserBranch → Branch       (phạm vi Manager)
Room → Incident → Tenant         (người gửi, nếu là yêu cầu Tenant)
Attachment → EntityType/EntityId  (quyền được kiểm tra bằng service)
```

Một số ràng buộc quan trọng: tên phòng không trùng trong cùng khu; một phòng chỉ có một hợp đồng Active; một người đại diện cho mỗi hợp đồng theo unique index; một chỉ số mỗi hợp đồng/kỳ; một hóa đơn Issued mỗi hợp đồng/kỳ; mỗi TenantId chỉ liên kết một tài khoản. Các khóa ngoại hạn chế xóa dữ liệu liên quan.

Tiền dùng số nguyên đồng (`long`/`bigint`). Chỉ số/số lượng dùng `decimal`, mapping độ chính xác 18 và 3 số lẻ. `CreatedAt` lưu UTC; ngày nghiệp vụ `BusinessRules.Today` tính theo UTC+7.

## 7. Phân quyền và phạm vi dữ liệu

Có **3 role đăng nhập: Owner, Manager, Tenant**. Khách chưa đăng nhập là trạng thái truy cập công khai, không phải một role lưu trong tài khoản.

| Nhóm chức năng | Khách | Tenant | Manager | Owner |
| --- | --- | --- | --- | --- |
| Tìm/lọc/sắp xếp, xem phòng trống và ảnh công khai | Có | Có | Có | Có |
| Xem hợp đồng, hóa đơn, lịch sử thanh toán và cọc | Không | Hợp đồng có tên mình | Khu được giao | Tất cả khu |
| Gửi/theo dõi yêu cầu sửa chữa | Không | Phòng đang thuê / yêu cầu tự gửi | Khu được giao | Tất cả khu |
| Quản lý phòng và hồ sơ người thuê | Không | Không | Khu được giao | Tất cả khu |
| Lập/gia hạn hợp đồng, nhận cọc, quyết toán | Không | Không | Khu được giao | Tất cả khu |
| Chốt chỉ số, lập hóa đơn, thu tiền, xử lý sự cố | Không | Không | Khu được giao | Tất cả khu |
| Upload/download file riêng và chọn ảnh phòng công khai | Không | Không | Khu được giao | Tất cả khu |
| Thêm/sửa khu trọ, loại phí, đơn giá dịch vụ | Không | Không | Không | Có |
| Hủy hóa đơn có đủ điều kiện | Không | Không | Không | Có |
| Cấp/sửa/khóa tài khoản, phân quyền, xem nhật ký | Không | Không | Không | Có |
| Đổi mật khẩu của chính mình | Không | Có | Có | Có |

### Tenant cần hiểu đúng

- Chủ trọ cấp tài khoản và gắn `User.TenantId` với hồ sơ có sẵn; mỗi hồ sơ có tối đa một tài khoản.
- `UserBranch` không quyết định quyền đọc của Tenant. Portal suy ra TenantId từ tài khoản đã xác thực, sau đó truy vấn hợp đồng qua `ContractTenant`.
- Tenant không được tự gửi TenantId để chọn dữ liệu người khác.
- Người cùng hợp đồng xem hóa đơn chung của hợp đồng; hiện chưa phân bổ công nợ riêng cho từng người ở.
- Hợp đồng Closed vẫn xem lịch sử được. Chỉ hợp đồng Active mới gửi yêu cầu sửa chữa mới được.
- Người thuê chỉ xem các sự cố do mình gửi; không tự chọn chi phí, phản hồi hay trạng thái xử lý.
- Khi Owner sửa một sự cố do Tenant gửi, không được chuyển sự cố đó sang phòng khác.
- Tenant bị chặn tại API quản lý, không chỉ bị ẩn menu.

## 8. Danh sách API để tìm code

Route được khai báo chủ yếu trong `Rental.Api/Program.cs`; upload/download và cờ ảnh trong `Features/Attachments/AttachmentEndpoints.cs`.

### Công khai

| Method và URL | Việc làm |
| --- | --- |
| `GET /api/health` | Nhận diện ứng dụng và thông tin trạng thái phục vụ |
| `GET /api/public/rooms` | Danh sách phòng trống và thông tin giới thiệu an toàn |
| `GET /api/public/rooms/{roomId}/photos/{id}` | Ảnh đã được chọn công khai của phòng còn được đăng |
| `POST /api/auth/login` | Đăng nhập và nhận cookie |

Bộ lọc phòng: `q`, `branchId`, `minPrice`, `maxPrice`, `capacity`, `sort`. `capacity` nghĩa là phòng có sức chứa **ít nhất** bằng số người cần ở. `sort` nhận `priceAsc`, `priceDesc`, `name`. Tìm kiếm gồm tên phòng, mô tả, tên khu và địa chỉ.

### Mọi tài khoản đã đăng nhập

| Method và URL | Việc làm |
| --- | --- |
| `GET /api/auth/me` | Người dùng hiện tại |
| `POST /api/auth/logout` | Đăng xuất |
| `POST /api/auth/password` | Đổi mật khẩu của chính mình |

### Chỉ Tenant

| Method và URL | Việc làm |
| --- | --- |
| `GET /api/tenant/workspace` | Hồ sơ giới hạn, phòng/khu liên quan, hợp đồng, hóa đơn/items, thu tiền, cọc, yêu cầu tự gửi |
| `POST /api/tenant/incidents` | Gửi `{ contractId, description }`; backend xác minh hợp đồng thuộc Tenant và còn Active |

### Chỉ Owner hoặc Manager

| Method và URL | Service / việc làm |
| --- | --- |
| `GET /api/workspace` | WorkspaceService: dữ liệu quản lý trong phạm vi quyền |
| `POST /api/branches`, `PUT /api/branches/{id}` | BranchService; thêm điều kiện OwnerOnly |
| `POST /api/rooms`, `PUT /api/rooms/{id}`, `DELETE /api/rooms/{id}` | RoomService; DELETE là ngừng sử dụng, không xóa lịch sử |
| `POST /api/tenants`, `PUT /api/tenants/{id}` | TenantService |
| `POST /api/fees`, `PUT /api/fees/{id}` | FeeService; OwnerOnly |
| `POST /api/contracts` | Tạo hợp đồng |
| `POST /api/contracts/{id}/renew` | Gia hạn |
| `POST /api/contracts/{id}/deposit` | Nhận thêm cọc |
| `POST /api/contracts/{id}/close` | Quyết toán trả phòng |
| `POST /api/readings` | Ghi/sửa chỉ số nếu đủ điều kiện |
| `POST /api/invoices`, `GET /api/invoices/{id}` | Lập/xem chi tiết hóa đơn |
| `POST /api/invoices/{id}/cancel` | Hủy hóa đơn; OwnerOnly và kiểm tra nghiệp vụ |
| `POST /api/payments` | Ghi nhận một lần thanh toán |
| `POST /api/incidents`, `PUT /api/incidents/{id}` | Tiếp nhận/xử lý sự cố |
| `POST /api/users`, `PUT /api/users/{id}` | UserService; OwnerOnly |
| `POST /api/attachments/{type}/{id}` | Upload file của entity trong phạm vi quyền |
| `GET /api/attachments/{id}` | Download file riêng tư trong phạm vi quyền |
| `POST /api/attachments/{id}/visibility` | Chọn công khai/ẩn ảnh phòng với `{ isPublic }` |

Owner/Manager không tự động được gọi nhóm API Tenant. Có quyền đăng nhập không đồng nghĩa có quyền đọc `/api/workspace`.

## 9. Quy tắc nghiệp vụ cần giữ khi sửa code

### Phòng và người thuê

- Cho thuê nguyên phòng, không cho thuê theo giường.
- Một phòng có nhiều người ở nhưng phải trong sức chứa; một người đại diện thuộc danh sách người ở.
- Người thuê phải thuộc cùng khu với phòng; không thuộc đồng thời hai hợp đồng Active.
- Không nhận hợp đồng mới cho phòng sửa chữa hoặc ngừng sử dụng.
- Không giảm sức chứa xuống thấp hơn số người của hợp đồng Active.
- Không chuyển phòng đã tạo sang khu khác qua thao tác sửa phòng.
- Phòng có hợp đồng Active vẫn đang thuê dù ngày kết thúc đã qua; phải quyết toán thì mới giải phóng.
- Giá tham khảo trên Room khác giá đã chốt tại Contract. Đổi giá phòng không tự thay giá hợp đồng/hóa đơn cũ.

### Hợp đồng và gia hạn

- Chỉ tạo hợp đồng đã bắt đầu; không hỗ trợ đặt lịch hợp đồng tương lai.
- Không trùng lịch sử thuê của cùng phòng; tạo mới kiểm tra cả Active và khoảng lịch sử.
- Gia hạn chỉ với hợp đồng Active và ngày kết thúc mới lớn hơn ngày cũ.
- Gia hạn cập nhật tiền thuê và lưu audit giá/ngày trước đó. Chưa có bảng giá hợp đồng theo từng mốc hiệu lực.

### Điện nước và hóa đơn

- Tiền thuê tính đủ tháng, kể cả tháng đầu/cuối; không tự đổi thành tính theo ngày.
- Chỉ số không âm, mới không nhỏ hơn cũ, tối đa 3 số lẻ; phải khớp chuỗi kỳ trước/kỳ tiếp theo đã ghi.
- Kỳ thu phải giao với thời gian hợp đồng Active và không vượt kỳ hiện tại; hết hạn thì cần gia hạn phù hợp.
- Có phí điện/nước thì phải có chỉ số trước khi lập hóa đơn.
- Phí điện/nước tính theo chênh lệch; PerPerson theo số người trong hợp đồng; Fixed theo phòng.
- Thành tiền làm tròn tới đồng; giữ số lượng, đơn giá, mô tả, thành tiền trong InvoiceItem để giữ lịch sử.
- Một hợp đồng/kỳ chỉ có một hóa đơn Issued. Hóa đơn Cancelled vẫn giữ lại.
- Hóa đơn Issued khóa chỉ số kỳ đó. Chỉ Owner hủy hóa đơn chưa có thanh toán, khi hợp đồng chưa quyết toán và có lý do.
- Hủy rồi mới có thể sửa chỉ số/lập lại nếu đủ điều kiện. Không xóa lịch sử thu tiền để lách điều kiện hủy.

### Thu tiền và cọc

- Cho thu nhiều lần; mỗi lần phải dương và không vượt số còn nợ.
- Công nợ tính từ hóa đơn và các giao dịch Payment, không cho sửa tay số đã thu.
- Method thanh toán: Cash, Transfer, Deposit. Transfer hiện là ghi nhận thủ công, không phải kết nối ngân hàng.
- Cọc được theo dõi riêng: Received tăng số dư; Applied, Deducted, Refunded giảm số dư.
- Tổng cọc nhận không vượt cọc thỏa thuận. Nhận cọc không tự tính là tiền thanh toán hóa đơn.
- Dùng cọc thanh toán cần hợp đồng Active và đủ số dư; ghi cả Payment lẫn DepositEntry trong cùng transaction.
- Các trường tiền đầu vào chính được kiểm tra trong khoảng 0 đến 1 tỷ đồng; các lần thu/nhận cọc còn yêu cầu lớn hơn 0.

### Trả phòng

- Hợp đồng phải Active; ngày trả không trước ngày vào và không sau hôm nay.
- Phải đủ hóa đơn Issued cho mọi kỳ từ tháng vào đến tháng trả, và đã thanh toán đủ.
- Không để hóa đơn còn hiệu lực sau ngày trả phòng.
- Khấu trừ không vượt cọc còn giữ; cần lý do quyết toán; phần cọc còn lại được ghi hoàn.
- Kết thúc bằng Contract.Status = Closed và ClosedDate, giữ lịch sử liên quan.

### Trang công khai, ảnh và sự cố

- Phòng công khai phải thuộc khu chưa archive, bản thân chưa archive/maintenance và không có hợp đồng Active.
- API công khai chỉ trả thông tin giới thiệu, phí dịch vụ và ID ảnh được công khai; không trả hồ sơ người thuê, hợp đồng, tài khoản, audit hoặc đường dẫn lưu file.
- File upload mặc định riêng tư; chỉ ảnh JPG/PNG của phòng mới có thể đánh dấu IsPublic. PDF không được công khai qua cơ chế này.
- Mỗi lần lấy ảnh công khai, backend kiểm tra lại trạng thái phòng và quyền công khai của ảnh.
- Upload hiện tối đa 5 MB, chấp nhận JPG/JPEG/PNG/PDF và kiểm tra chữ ký định dạng. File thật có tên ngẫu nhiên, metadata nằm trong database.
- `EntityType` đính kèm hiện hỗ trợ `room`, `tenant`, `contract`, `incident`, `payment`; không tự thêm loại mới ở frontend mà bỏ qua kiểm tra phía backend.
- Sự cố có Open, InProgress, Resolved. Tenant gửi mới luôn do backend gán trạng thái ban đầu; nhân sự quản lý cập nhật cách xử lý.

## 10. Luồng giao diện và điều hướng

Ứng dụng điều hướng bằng `location.hash` và React state, không dùng React Router.

| Hash | Màn hình |
| --- | --- |
| Không có hash hoặc `#browse` | Catalog tìm phòng công khai |
| `#browse/rooms` | Catalog và cuộn tới bộ lọc tìm phòng |
| `#login` | Đăng nhập khi chưa có user |
| `#tenant` | Portal khi đăng nhập role Tenant |
| `#overview`, `#rooms`, `#tenants`, `#contracts` | Các màn quản lý tương ứng |
| `#billing`, `#payments`, `#incidents`, `#settings` | Các màn quản lý tương ứng |

- Sau login, Tenant được chuyển về `#tenant`; Owner/Manager về `#overview`.
- `useSession` gọi `/api/auth/me`; API client phát sự kiện `session-expired` khi gặp 401 phù hợp, làm user trở về null.
- Mất phiên sẽ tháo không gian riêng ra khỏi cây React, bỏ dữ liệu phiên cũ.
- Workspace quản lý tải gói dữ liệu qua `/api/workspace`; sau thao tác thành công, `completed()` reload và báo lưu.
- Public Catalog có query lọc/sắp xếp phía server. Các bảng quản lý vẫn chủ yếu lọc/tìm/phân trang trên client.

**Lỗi điều hướng đã sửa:** link “Tìm phòng” cạnh “Đăng nhập” từng chỉ trỏ `#browse`, nên bấm ngay trên trang này không thấy thay đổi. Bản mới dùng `#browse/rooms`, `App.tsx` nhận diện route đó, `CatalogPage` dùng ref cuộn tới form `room-search`. Header có callback để bấm lại cùng hash vẫn cuộn được. Khi sửa routing cần giữ hành vi này cho cả trạng thái đã đăng nhập.

## 11. Thương hiệu và logo

- Tên hiển thị, title trình duyệt và footer hiện là DVP Home.
- Asset chuẩn: `Frontend/public/logo.png`; Vite tự copy ra `Rental.Api/wwwroot/logo.png` khi build.
- Logo là asset tĩnh của frontend, không phải bản ghi Attachment và không phụ thuộc cờ IsPublic của ảnh phòng.
- `BrandLogo.tsx` dùng chung tại header public/Tenant, trang đăng nhập, menu quản lý, màn loading và nội dung phiếu thu.
- Favicon dùng `/logo.png`; `Frontend/index.html` chứa title và description.
- Logo gốc PNG 2172 × 724, có nền trong suốt và khoảng trống quanh nội dung. CSS `.brand-logo` xử lý khung hiển thị, không chỉnh sửa file gốc.
- Trang login nền xanh dùng nền sáng dưới logo để giữ chữ rõ; không đảo màu logo tùy tiện.
- Chữ “An Cư” còn xuất hiện trong tên khu dữ liệu mẫu hoặc câu “an cư” không có nghĩa là chưa đổi tên thương hiệu. Không thay tên khu/người thuê trong database bằng thao tác đổi thương hiệu.
- Các icon Home/Building2 ở card phòng và minh họa là icon giao diện, không phải mọi icon đó đều là logo cần thay.

## 12. Database và cập nhật cấu trúc

### Ba file SQL

| File | Dùng khi nào |
| --- | --- |
| `Database/01_schema.sql` | Database trống; tạo bảng từ model RentalDb hiện tại |
| `Database/02_sample.sql` | Nạp dữ liệu hư cấu và đồng bộ identity cho demo/test |
| `Database/03_public_tenant.sql` | Nâng cấp bản Source trước khi có Tenant/public; thêm các cột và ràng buộc liên quan |

Script 03 thêm `users.TenantId`, `incidents.ReportedByTenantId`, `attachments.IsPublic`, cập nhật role/check/index/FK. Script có transaction và có thể chạy lại. Schema 01 mới đã có cấu trúc này, database mới không cần nâng cấp từ bản cũ.

**Hiện chưa có hệ thống EF migrations tự động.** Build không cập nhật schema. Không chạy lại script tạo bảng lên database đang có dữ liệu để “đồng bộ”. Không dùng EnsureDeleted/EnsureCreated để sửa database thật.

Khi thêm một trường, ví dụ tầng phòng:

```text
Entity Room
  + mapping/index/constraint nếu cần
  + SQL ALTER TABLE cho database hiện có
  + Request DTO
  + Service kiểm tra và gán dữ liệu
  + projection dữ liệu trả về (Workspace/Catalog/TenantPortal nếu liên quan)
  + types/form/table ở frontend
  + kiểm thử và cập nhật tài liệu
```

Xuất lại schema cho **lần cài mới**, chạy từ Source khi không có tiến trình giữ build:

```powershell
dotnet run --project Rental.Api -- --export-schema
```

Lệnh trên ghi file SQL từ model; nó không áp dụng thay đổi vào database đang dùng. Sinh lại dữ liệu mẫu bằng `node tools/generate-sample.mjs` cũng chỉ ghi file SQL, không tự nạp database.

### Cấu hình và lưu trữ

- Kết nối: `ConnectionStrings:Rental`, lấy từ cấu hình; không còn `Database:Provider` để chọn loại DB.
- Thứ tự override: cấu hình nền → Development nếu đúng môi trường → Local → biến môi trường → tham số CLI.
- Local file: `Rental.Api/appsettings.Local.json`, được Git/Docker bỏ qua và không chép khi publish.
- Một số file cấu hình nền hoặc Compose có thể vẫn chứa giá trị mặc định phát triển: kiểm tra và thay bằng placeholder trước khi gửi source cho bên khác. Không chỉ kiểm tra mỗi Local file.
- `Database:SeedDemo` chỉ nạp khi bật và chưa có tài khoản. Development hiện có bật seed; Production/Docker đặt false.
- Database cũ có sẵn user sẽ không tự nhận tài khoản Tenant demo. Owner phải cấp và liên kết hồ sơ bằng UI.
- `App_Data/uploads` chứa file upload; `App_Data/keys` chứa Data Protection keys bảo vệ cookie.
- `Database:DataDirectory` có thể override nơi lưu file/key; không phải đường dẫn database PostgreSQL.
- Sao lưu dữ liệu cần cả PostgreSQL và file upload. Khóa phiên cũng cần quản lý phù hợp khi triển khai.
- Lỗi kết nối PostgreSQL báo lỗi; không fallback sang database khác. Startup có kiểm tra cột TenantId để báo cần script 03 nếu DB quá cũ.

Trên máy đang phát triển, script 03 đã được áp dụng sau khi sao lưu vào `.tools/backups`. Bản sao lưu đó thuộc máy hiện tại, không nằm trong file bàn giao này và không nên đính kèm vào cuộc chat khác một cách mặc định.

## 13. Cách dựng và chạy trên máy khác

### 13.1 Local Windows

1. Nhận đầy đủ thư mục Source hiện tại, gồm frontend/public/logo.png và các lockfile.
2. Chuẩn bị PostgreSQL 16+ và công cụ `createdb`/`psql` nếu dùng cách tạo DB bằng CLI. Launcher không tự cài hoặc mở PostgreSQL.
3. Nếu database mới, tạo DB trống và nạp schema; muốn demo thì nạp dữ liệu hư cấu.
4. Sao chép mẫu Local, nhập cấu hình kết nối của máy mới.
5. Chạy Start.cmd hoặc Start.ps1.

Ví dụ chạy **tại Source**, chỉ dùng với database mới:

```powershell
createdb -U postgres rental_management
psql -U postgres -d rental_management -v ON_ERROR_STOP=1 -f .\Database\01_schema.sql
# Tùy chọn: dữ liệu hư cấu cho demo
psql -U postgres -d rental_management -v ON_ERROR_STOP=1 --single-transaction -f .\Database\02_sample.sql
Copy-Item .\Rental.Api\appsettings.Local.example.json .\Rental.Api\appsettings.Local.json
# Điền cấu hình kết nối riêng trong Local trước khi chạy.
powershell -ExecutionPolicy Bypass -File .\Start.ps1
```

Không chép đè Local file đã cấu hình; không thực hiện các bước tạo/nạp trên nếu database đã có dữ liệu cần giữ. Với DB từ bản cũ phù hợp, sao lưu và dùng script nâng cấp 03.

URL mặc định: `http://localhost:5247`. Thông tin tài khoản demo được mô tả trong README/seed của source, không ghi lại mật khẩu trong file bàn giao này.

### 13.2 Start.ps1 làm gì

```text
Start.cmd → Start.ps1
  → tìm app đã chạy ở cổng được chọn; nếu có thì dùng lại và kết thúc
  → kiểm tra xung đột cổng
  → tìm .NET 8 SDK; thiếu thì tải vào .tools
  → nếu không SkipBuild: tìm Node, tải nếu thiếu
  → cài dependency frontend khi thiếu
  → tsc --noEmit rồi Vite build
  → frontend ra Rental.Api/wwwroot
  → dotnet restore và build API ra .tools/runtime/<thời gian>-<mã>/
  → lưu đường dẫn DLL trong .tools/last-build.json
  → mở trình duyệt nếu không NoBrowser
  → chạy dotnet Rental.Api.dll --urls <URL>
```

`-SkipBuild` dùng bản DLL đã build; không áp dụng code backend mới. `-NoBrowser` không tự mở trình duyệt; `-Port 5248` đổi cổng. Muốn áp dụng code/config backend mới, dừng server cũ rồi chạy lại. Nếu website đang chạy, launcher không tự build đè hoặc restart.

Frontend có thể được build riêng vào wwwroot để cập nhật asset, sau đó tải lại trình duyệt. Muốn tránh dùng nhầm bản cũ, kiểm tra kết quả build và tiến trình thực sự đang chạy. DLL từ launcher trong `.tools/runtime` khác DLL Debug mà HTTP tests dùng.

### 13.3 Chạy frontend dev riêng

```powershell
# Terminal backend, tại Source; đã có cấu hình và schema phù hợp
dotnet run --project Rental.Api --launch-profile http

# Terminal frontend, tại Source/Frontend
pnpm install --frozen-lockfile
pnpm dev
```

Vite proxy `/api` sang `http://localhost:5247`, nên trình duyệt vẫn gọi cùng origin Vite. Không tự bật CORS rộng để thay proxy nếu không có yêu cầu triển khai khác.

### 13.4 Docker

```powershell
# Tại Source, sau khi chuẩn bị cấu hình và Docker Desktop
docker compose up --build -d
```

Compose tạo PostgreSQL và web, map localhost:5247, giữ volume database và file. Hai SQL init chỉ chạy khi volume PostgreSQL trống; đổi source không tự cập nhật schema volume đã có. Không dùng `down -v` nếu cần giữ dữ liệu. Docker đã có cấu hình nhưng chưa được kiểm thử chạy Docker Desktop trong các lượt thực hiện được ghi nhận ở đây.

Compose hiện là cấu hình local/demo, bind cổng về localhost. Nếu triển khai ra Internet cần cấu hình HTTPS, AllowedHosts theo tên miền thực tế, thông tin kết nối qua môi trường triển khai và quy trình sao lưu; không coi cấu hình demo là bản triển khai production đã được xác minh.

## 14. Xác thực, lỗi và chẩn đoán

- Cookie tên `rental.session`, HttpOnly, SameSite Strict, hạn 8 giờ, không sliding expiration; SecurePolicy theo request.
- Cookie lưu claim user/role/liên kết Tenant và dấu kiểm tra hash mật khẩu. Mỗi request xác minh tài khoản còn active, role/liên kết/mật khẩu chưa thay đổi; thay đổi các thông tin đó có thể làm phiên cũ mất hiệu lực.
- Quyền Manager đọc lại từ UserBranch; quyền Tenant suy ra từ User.TenantId và ContractTenant.
- Mọi request ghi `/api` phải có header `X-Rental-Request: 1`, gồm cả login. `shared/api.ts` tự thêm header, cookie và JSON/FormData phù hợp.
- Login giới hạn 10 request/phút theo IP; khi test nhiều tài khoản liên tục có thể gặp 429.
- Auth dùng PasswordHasher của ASP.NET Identity; không lưu mật khẩu thuần cho tài khoản. Chưa triển khai JWT/refresh token cho client bên thứ ba.
- API không bật CORS tùy tiện; có các header bảo vệ nội dung và cache no-store cho API.

| HTTP | Ý nghĩa thường gặp |
| --- | --- |
| 400 | Dữ liệu hoặc điều kiện nghiệp vụ không hợp lệ |
| 401 | Chưa đăng nhập, hết phiên hoặc credential không còn hợp lệ |
| 403 | Sai role/phạm vi khu/hợp đồng; hoặc request ghi thiếu header |
| 404 | Không có entity/file/ảnh công khai hoặc không có API |
| 409 | Trùng/ràng buộc DB hoặc ghi đồng thời xung đột |
| 429 | Vượt giới hạn login |
| 500 | Lỗi server, cần đọc log |
| 503 | Chưa có giao diện build tại fallback |

Swagger chỉ bật trong Development. `/api/health` hữu ích để nhận diện đúng ứng dụng và loại DB; không nên coi riêng endpoint này là kiểm tra đầy đủ sức khỏe database theo thời gian thực.

## 15. Kiểm thử và mức độ đã xác minh

Các lệnh backend dưới đây cần SDK/dependency đã cài/restore. Có thể dùng dotnet trên PATH hoặc SDK local do launcher tải:

```powershell
# Tại Source
$env:DOTNET_CLI_HOME = "$PWD\.tools\cli-home"
.\.tools\dotnet\dotnet.exe build .\RentalManagement.sln --no-restore

# Tại Source/Frontend
pnpm install --frozen-lockfile
pnpm build

# Tại Source/tools
pnpm install --frozen-lockfile
node postgres-test.mjs
# hoặc pnpm test
```

- `postgres-test.mjs` tạo PostgreSQL nhúng riêng, nạp schema, mô phỏng nâng cấp schema cũ, chạy lại script nâng cấp, kiểm tra giữ dữ liệu và nạp seed lặp.
- Sau đó mở socket PostgreSQL ở 5544 và chạy các HTTP checks qua API riêng ở 5259.
- `smoke-test.mjs` là bộ test được runner gọi. Không chạy trực tiếp với connection database thật; script yêu cầu `RENTAL_TEST_CONNECTION` do runner cung cấp.
- Runner mặc định chạy DLL Debug tại `Rental.Api/bin/Debug/net8.0/Rental.Api.dll`, nên phải build backend trước.
- File, key và log kiểm thử nằm trong `.tools/test-data`, không dùng App_Data của app thật.
- Các cổng trên cần trống; socket PostgreSQL nhúng không thay thế kiểm thử hạ tầng PostgreSQL/Docker đích.

**Kết quả được ghi nhận trong quá trình phát triển:** backend đã build và bộ kiểm thử PostgreSQL đã qua **105 HTTP checks** sau khi thêm public/Tenant, gồm chống truy cập chéo, cấp/liên kết tài khoản, hóa đơn, thu tiền đồng thời, cọc, trả phòng, ảnh công khai và hợp đồng Closed. Sau thay logo và sửa điều hướng Tìm phòng, TypeScript/Vite build đã qua và có kiểm tra trực tiếp trên trình duyệt. Không được coi các kết quả lịch sử này là bằng chứng rằng một thay đổi tương lai đã được test.

Có thể gặp warning NuGet `NU1900` khi môi trường không truy cập được dịch vụ lấy dữ liệu lỗ hổng; warning này đã xuất hiện cùng các lần build thành công. Cần phân biệt warning mạng với lỗi compile.

## 16. Các thay đổi gần nhất và phần chưa triển khai

### Đã làm

1. Chia frontend/backend theo feature để dễ đọc.
2. Bỏ SQLite và các nhánh chọn provider; chỉ còn PostgreSQL, kể cả luồng kiểm thử.
3. Thêm Catalog công khai, bộ lọc server, chi tiết phòng và ảnh được chọn công khai.
4. Thêm role Tenant, liên kết tài khoản–hồ sơ, portal riêng và gửi/theo dõi sửa chữa.
5. Bảo vệ nhóm API quản lý bằng policy Owner/Manager; API Tenant có policy riêng.
6. Thêm script SQL 03; đã sao lưu và nâng cấp database local mà giữ số lượng bản ghi nghiệp vụ.
7. Dùng thương hiệu/logo DVP Home ở giao diện, title/favicon và phiếu thu.
8. Sửa nút Tìm phòng để đến `#browse/rooms` và cuộn đến bộ lọc kể cả khi bấm lại.
9. Đã xuất bảng chức năng theo role vào `C:\rental-management\output\pdf` dưới dạng PDF và Markdown; file bàn giao này đã nhắc lại nội dung quan trọng để không phụ thuộc báo cáo đó.

### Chưa làm hoặc có giới hạn

- Chưa có tự đăng ký tài khoản, đặt phòng/giữ chỗ trực tuyến.
- Tenant chưa tự sửa hồ sơ, gia hạn/trả phòng hoặc tự xác nhận đã thanh toán.
- Chưa có cổng ngân hàng, tự đối soát chuyển khoản, hoàn/điều chỉnh giao dịch thu tiền.
- Chưa có email/nhắc tiền tự động hoặc báo cáo lợi nhuận đầy đủ.
- Chưa có bảng giá hợp đồng theo từng mốc hiệu lực; tiền thuê vẫn đủ tháng.
- Chưa có thuê theo giường, nền tảng nhiều chủ trọ độc lập hoặc đa ngôn ngữ.
- Chưa có EF migrations tổng quát và chuyển dữ liệu từ SQL V2 trong Document.
- Bảng quản lý còn tải nhiều dữ liệu theo phạm vi rồi lọc/phân trang phía client; cần cải tiến nếu dữ liệu lớn.
- Type Row ở frontend còn linh hoạt, chưa có DTO trả về TypeScript chặt cho tất cả feature.
- Không suy luận có tính năng chỉ vì README của source cũ hoặc thư viện từng xuất hiện trong lịch sử.

## 17. Cách tiếp tục sửa một tính năng

1. Kiểm tra `git status`, các hướng dẫn repository hiện có và đọc file feature liên quan; giữ nguyên thay đổi chưa commit của chủ dự án.
2. Tìm route tại Program.cs để xác định role, DTO và service thực sự được gọi.
3. Theo luồng service → FeatureService/BusinessRules → RentalDb/Entity nếu là backend; theo Page → useForms → api.ts nếu là frontend.
4. Nếu đổi dữ liệu, cập nhật cả model, SQL nâng cấp, dữ liệu trả về và UI liên quan. Không chỉ thêm cột bằng SQL rồi bỏ qua mapping, hoặc chỉ sửa model mà không cập nhật DB.
5. Giữ kiểm tra quyền ở backend; với tính năng mới phải có kiểm tra đọc/ghi dữ liệu không thuộc quyền.
6. Build/kiểm thử phù hợp. Trước khi kết luận lỗi build đã sửa, xác nhận lệnh thực sự hoàn tất thành công.
7. Cập nhật README/ARCHITECTURE/file bàn giao khi thay đổi kiến trúc, nghiệp vụ, route, cấu hình hoặc cách chạy.

Ví dụ nếu sửa cách tính hóa đơn: bắt đầu tại `Features/Billing/InvoiceService.cs` và `BillingRules.cs`, đối chiếu Readings/Fees/Contracts. Nếu sửa quyền Tenant: bắt đầu tại policy route trong Program.cs, UserService và TenantPortalService, không tái sử dụng toàn bộ workspace nhân sự quản lý cho người thuê.

## 18. Mang gì sang cuộc chat hoặc tài khoản khác

### Tối thiểu để hiểu

- Upload chính file `DVP_HOME_HANDOFF.md` này.
- Nêu yêu cầu tiếp theo, ví dụ giải thích luồng thêm phòng, sửa tính hóa đơn hoặc tiếp tục một tính năng.

### Để tiếp tục lập trình

- Gửi thêm thư mục Source đầy đủ hoặc ZIP của working tree hiện tại: backend, frontend, Database, tools, config mẫu, solution, launcher, Docker, lockfile và logo public.
- Giữ các file chưa được Git theo dõi nhưng là source cần thiết; không chỉ gửi diff hoặc commit cũ.
- Thường bỏ khỏi ZIP: `.git`, `.vs`, `.tools`, `node_modules`, `bin`, `obj`, `App_Data`, `.env`, Local config thật, log, backup/dump thật và `wwwroot` sinh từ build. Source frontend/public cần được giữ.
- Trước khi gửi, kiểm tra cả config nền và Compose, thay giá trị kết nối/mật khẩu thật bằng placeholder. File này không tự làm sạch source thay bạn.
- Chỉ chuyển database/ảnh người thuê riêng khi thật sự cần và đã xử lý thông tin cần bảo mật; file bàn giao không yêu cầu dữ liệu thật để bắt đầu đọc code.
- `localhost:5247` và đường dẫn ổ C trên máy này không tự truy cập được từ tài khoản ChatGPT hoặc máy khác. Cần upload file hoặc mở source trong môi trường mà cuộc chat mới có thể làm việc.
- Bỏ qua `.tools` vẫn dựng lại được công cụ/build/test; nếu cần giữ dữ liệu thật, sao lưu PostgreSQL và uploads bằng quy trình riêng thay vì coi việc copy source là backup dữ liệu.

### Tin nhắn gợi ý cho ChatGPT mới

```text
Đây là dự án DVP Home của tôi. Hãy đọc DVP_HOME_HANDOFF.md trước,
sau đó đối chiếu với source tôi gửi để hiểu đúng phiên bản hiện tại.
Source chính là thư mục Source, không phải Document/Source.
Ứng dụng chỉ dùng PostgreSQL và có Owner, Manager, Tenant cùng trang công khai.
Tôi đang học C#/API nên hãy giải thích rõ từng file và luồng xử lý, ngắn gọn.
Khi sửa code, giữ nghiệp vụ và phạm vi quyền đã mô tả, kiểm tra thay đổi hiện có,
và nêu rõ phần đã kiểm thử cùng phần còn chưa xác minh.
Yêu cầu tiếp theo của tôi là: [điền việc muốn làm].
```

Nếu source nhận được khác tài liệu này, cần chỉ ra điểm lệch và hỏi/đối chiếu phiên bản phù hợp thay vì giả định mọi chi tiết trong bản bàn giao luôn còn đúng.
