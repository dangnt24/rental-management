# DVP Home — Quản lý nhà trọ

Web app cho khách tìm phòng, người thuê, chủ trọ và quản lý. Khách xem phòng trống không cần đăng nhập; người thuê theo dõi hợp đồng/hóa đơn và gửi yêu cầu sửa chữa; nhân sự quản lý vận hành khu/phòng → người thuê → hợp đồng/cọc → điện nước → hóa đơn → thu tiền/công nợ → trả phòng. Backend ASP.NET Core 8, EF Core; frontend React + TypeScript; **chỉ dùng PostgreSQL**.

## Chạy ngay trên máy hiện tại

Kết nối PostgreSQL của máy được lưu trong `Rental.Api/appsettings.Local.json`: host `localhost`, cổng `5432`, database `rental_management`. File chứa mật khẩu được Git và Docker bỏ qua, không chép vào bản build/publish. Trên máy khác, sao chép `appsettings.Local.example.json` thành `appsettings.Local.json`, điền mật khẩu và tạo database theo phần hướng dẫn bên dưới trước khi chạy.

1. Mở thư mục `C:\rental-management\Source`.
2. Nhấp đúp **`Start.cmd`**. Hoặc mở PowerShell tại thư mục này và chạy:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\Start.ps1
   ```

3. Mở **http://localhost:5247**.
4. Trang đầu là **Tìm phòng**: lọc theo địa chỉ/tên, khu trọ, khoảng giá, số người và sắp xếp giá. Chọn **Đăng nhập** để mở không gian theo vai trò. Tài khoản **`admin` / `Demo@123456`** là chủ trọ; **`manager` / `Demo@123456`** quản lý khu An Cư; `manager2` quản lý khu Bình An.

Với database mẫu tạo mới, **`tenant` / `Demo@123456`** gắn với Nguyễn Minh Anh (P.101), **`tenant2` / `Demo@123456`** gắn với Phạm Hải Đăng (A.01). Database đã có dữ liệu không tự thêm tài khoản: chủ trọ vào **Thiết lập → Cấp tài khoản → Người thuê → chọn hồ sơ người thuê**. Mỗi hồ sơ chỉ gắn một tài khoản; không cho tự đăng ký hoặc tự chọn hồ sơ qua trang công khai.

### Cập nhật database đang dùng

Nếu đã chạy bản trước khi có trang công khai/role người thuê, sao lưu PostgreSQL rồi chạy **một lần** trước khi mở bản mới:

```powershell
psql -U postgres -d rental_management -v ON_ERROR_STOP=1 -f .\Database\03_public_tenant.sql
```

Script thêm các cột liên kết tài khoản, người gửi sự cố và cờ ảnh công khai; có thể chạy lại và giữ dữ liệu hiện có. Không nạp lại `01_schema.sql` lên database đang có bảng. Database trống dùng `01_schema.sql` mới đã chứa các cột này.

### Phạm vi quyền

| Người dùng | Quyền |
| --- | --- |
| Khách | Danh sách/chi tiết phòng trống và ảnh được chọn công khai; lọc và sắp xếp. |
| Tenant | Hợp đồng có tên mình, hóa đơn/chi tiết/in PDF, lịch sử thanh toán/cọc, yêu cầu sửa chữa do mình gửi, đổi mật khẩu. |
| Manager | Vận hành trong các khu được gán; chọn công khai ảnh phòng. |
| Owner | Toàn bộ khu, tài khoản, đơn giá, hủy hóa đơn và nhật ký. |

Người thuê không ghi nhận tiền thu hoặc tự sửa trạng thái xử lý sự cố. Hợp đồng đã đóng vẫn xem được lịch sử; chỉ hợp đồng đang hoạt động mới được gửi yêu cầu sửa chữa. API quản lý từ chối role Tenant, không chỉ ẩn nút ở giao diện.

Ảnh đính kèm mặc định riêng tư. Trong **Phòng trọ → File đính kèm**, chọn **Đăng ảnh trên trang tìm phòng** với ảnh JPG/PNG muốn giới thiệu. PDF và hồ sơ/chứng từ không được đăng công khai. Phòng đang thuê, đang sửa hoặc ngừng sử dụng không xuất hiện trên trang tìm phòng; phòng có hợp đồng chưa quyết toán vẫn tính đang thuê.

Lần đầu script tải SDK .NET 8 và dependency nếu thiếu; cần Internet. SDK được đặt trong `.tools`, không yêu cầu cài toàn hệ thống. Script dùng Node sẵn có; nếu chưa có sẽ tải Node 22 LTS từ trang chính thức và kiểm tra checksum. Nếu website đã chạy tại cổng đã chọn, mở lại launcher sẽ dùng website hiện có, không build đè file DLL đang bị khóa. Khi website đã dừng, script build lại vào thư mục riêng trong `.tools/runtime` rồi khởi động.

Chạy nhanh khi đã build: `powershell -ExecutionPolicy Bypass -File .\Start.ps1 -SkipBuild`. Thêm `-NoBrowser` nếu không muốn tự mở trình duyệt, hoặc `-Port 5248` nếu cổng 5247 đang dùng. Đóng cửa sổ chạy hoặc nhấn Ctrl+C để dừng. Chạy lại không xóa dữ liệu.

Sau khi sửa code hoặc đổi cấu hình database, nhấn **Ctrl+C trong cửa sổ đang chạy server**, rồi chạy lại `Start.cmd` để áp dụng. Nếu quên dừng, launcher sẽ báo website đang chạy.

Dữ liệu nghiệp vụ nằm trong PostgreSQL; ảnh/file tải lên và khóa phiên đăng nhập nằm trong `Rental.Api/App_Data/`. Sao lưu cả database và thư mục file khi cần. Bộ dữ liệu mẫu chỉ được nạp khi bật `Database:SeedDemo` và database chưa có tài khoản; không ghi đè dữ liệu đã nhập. Bản demo có 2 khu, 8 phòng, 7 người thuê, 4 hợp đồng, hóa đơn đã trả/chưa trả/trả một phần, lịch sử cọc và sự cố. Kỳ mẫu là **10/2026**, có thêm lịch sử hợp đồng cũ tháng 8–9/2026.

## Hai file database mới

- **`Database/01_schema.sql`**: cấu trúc PostgreSQL được xuất từ chính `RentalDb`, có khóa ngoại, CHECK và các unique index nghiệp vụ.
- **`Database/02_sample.sql`**: dữ liệu hư cấu, tài khoản demo và đồng bộ identity để các bản ghi tiếp theo nhận ID đúng.

Đây là bộ database mới, độc lập với SQL V2 trong `Document`. Hai file trên chạy trên **database trống riêng**. Cập nhật bản Source trước tính năng công khai/người thuê dùng `03_public_tenant.sql`; chưa có chuyển đổi dữ liệu từ bộ SQL V2 trong `Document`.

## Chạy với PostgreSQL

Cách 1, có Docker Desktop: từ `Source` chạy `docker compose up --build -d`, rồi mở http://localhost:5247. Docker tự khởi tạo PostgreSQL 16 bằng hai file SQL trên khi volume database còn trống. Dừng app local trước để giải phóng cổng 5247. Chạy `docker compose down` giữ lại dữ liệu. Không dùng `down -v` nếu muốn giữ database và file.

Cách 2, đã cài PostgreSQL 16+ và `psql`: chỉ chạy ba lệnh tạo/nạp dưới đây khi database chưa được tạo. Máy hiện tại đã có `rental_management` với các bảng và dữ liệu, không cần chạy lại schema.

```powershell
createdb -U postgres rental_management
psql -U postgres -d rental_management -v ON_ERROR_STOP=1 -f .\Database\01_schema.sql
psql -U postgres -d rental_management -v ON_ERROR_STOP=1 --single-transaction -f .\Database\02_sample.sql
if (-not (Test-Path .\Rental.Api\appsettings.Local.json)) {
    Copy-Item .\Rental.Api\appsettings.Local.example.json .\Rental.Api\appsettings.Local.json
}
# Mở appsettings.Local.json, điền mật khẩu PostgreSQL rồi lưu.
.\Start.ps1
```

API yêu cầu schema PostgreSQL đã được tạo; kết nối lỗi thì báo lỗi, không tự xóa/tạo lại database. Thứ tự cấu hình: appsettings → Development → Local → biến môi trường → tham số CLI. Nếu trước đây đã đặt `$env:ConnectionStrings__Rental`, mở PowerShell mới hoặc xóa biến để dùng cấu hình Local đã lưu. Chỉ cần cấu hình `ConnectionStrings:Rental`; không có tùy chọn đổi loại database.

Docker là cấu hình demo trên localhost; chưa được chạy thử bằng Docker Desktop trong môi trường thực hiện vì máy chưa có Docker. Mật khẩu mặc định trong Compose và dữ liệu mẫu phục vụ demo; đổi mật khẩu tài khoản qua **Thiết lập**, đặt mật khẩu database qua `POSTGRES_PASSWORD` trước khi triển khai thật. Cấu hình Local chỉ dành cho chạy từ source trên máy; khi publish/Docker, đặt `ConnectionStrings__Rental` trong môi trường triển khai.

## Nghiệp vụ đã chốt cho bản đầu

- Cho thuê **nguyên phòng**, nhiều người ở, một người đại diện. Mỗi người thuộc một khu trọ; một người không đồng thời có hai hợp đồng đang hoạt động.
- Chỉ tạo hợp đồng đã bắt đầu; không trùng lịch sử thuê cùng phòng và không vượt sức chứa. Phòng đang sửa/ngừng sử dụng không nhận hợp đồng mới.
- Tiền thuê tính **đủ tháng**, kể cả tháng đầu/cuối. Điện/nước theo chênh lệch chỉ số; dịch vụ theo phòng hoặc người. Giá dùng số nguyên đồng, chỉ số tối đa 3 số lẻ, thành tiền làm tròn đến đồng.
- Chốt điện/nước trước khi lập hóa đơn. Không bỏ qua chỉ số khi khu có phí theo điện/nước. Không lập trùng hóa đơn còn hiệu lực cùng hợp đồng/kỳ. Giá hóa đơn cũ được giữ nguyên khi đổi giá phòng/dịch vụ.
- Hóa đơn đã lập khóa chỉ số. Chủ trọ có thể hủy hóa đơn **chưa có thanh toán**, giữ lý do và lịch sử, sau đó sửa chỉ số và lập lại. Không xóa lịch sử thu tiền.
- Thu nhiều lần; số tiền dương và không vượt nợ. Các lần thu, cọc và audit được ghi trong giao dịch database. Công nợ tính từ giao dịch, không cho người dùng sửa số đã thu bằng tay.
- Cọc theo dõi riêng: thỏa thuận, thực nhận, bù trừ vào hóa đơn, khấu trừ, hoàn. Không tính cọc mới nhận là khoản thu hóa đơn. Trả phòng cần đủ hóa đơn và thanh toán các kỳ từ ngày vào đến ngày trả; ghi khấu trừ và khoản cọc hoàn lại.
- Hợp đồng hết hạn chưa quyết toán vẫn giữ phòng đang thuê. Gia hạn giữ audit ngày/giá cũ; giá mới áp dụng cho các hóa đơn lập sau. Chưa quản lý bảng giá hợp đồng theo từng mốc hiệu lực.
- Quản lý chỉ truy cập các khu được gán, gồm file đính kèm. Chỉ chủ trọ sửa tài khoản/quyền, đơn giá, khu trọ và hủy hóa đơn.
- In hóa đơn: mở chi tiết → **In / lưu PDF** → chọn **Save as PDF** của trình duyệt. Đây là phiếu đối soát tiền phòng, không phải hóa đơn thuế.

## Cấu trúc source

Xem **[ARCHITECTURE.md](ARCHITECTURE.md)** để tìm file theo chức năng và vị trí đặt breakpoint. `main.tsx` chỉ khởi động React; mỗi màn hình/form nằm trong `Frontend/src/features`. Backend dùng các service theo feature, thay cho file `RentalService.cs` gom chung.

```text
Source/
  RentalManagement.sln         Mở bằng Visual Studio / dotnet build
  Rental.Api/
    Domain/Entities.cs         Các bảng nghiệp vụ
    Data/RentalDb.cs           Mapping EF, quan hệ và ràng buộc
    Features/                 Mỗi chức năng có service và Requests riêng
    Program.cs                Auth, API, giao dịch, cấu hình
    App_Data/                 Dữ liệu cục bộ; Git bỏ qua
    wwwroot/                  Giao diện sau khi build
  Frontend/src/app/           Điều phối màn hình, layout và dữ liệu dùng chung
  Frontend/src/features/      Màn hình và form theo từng chức năng
  Frontend/src/shared/        API client, kiểu dữ liệu và component dùng chung
  Database/                   Hai file SQL chuẩn mới
  tools/                      Sinh data và kiểm thử tự động
  Start.cmd / Start.ps1        Lệnh chạy trên Windows
  Dockerfile / compose.yaml   Cấu hình chạy với PostgreSQL
```

Xác thực hiện dùng cookie HttpOnly cùng origin, kiểm tra header cho thao tác ghi, giới hạn số lần đăng nhập và hash mật khẩu ASP.NET Identity PBKDF2. Cách này phù hợp web/API được phục vụ cùng địa chỉ, giảm phần quản lý token ở trình duyệt. Chưa triển khai JWT/refresh token cho ứng dụng bên thứ ba. Không bật CORS tùy tiện. Khi triển khai ra Internet cần cấu hình HTTPS, host thực tế trong `AllowedHosts`, sao lưu database/file và quản lý khóa/mật khẩu.

## Build và kiểm thử

Sau khi chạy `Start.ps1` ít nhất một lần:

```powershell
# Có thể thay đường dẫn dưới bằng dotnet nếu SDK đã cài trên máy.
$env:DOTNET_CLI_HOME = "$PWD\.tools\cli-home"
.\.tools\dotnet\dotnet.exe build .\RentalManagement.sln --no-restore
# Kiểm thử schema + dữ liệu + API qua Npgsql với PostgreSQL nhúng:
cd tools
pnpm install --frozen-lockfile
node postgres-test.mjs
```

`postgres-test.mjs` tạo PostgreSQL nhúng riêng rồi gọi các kiểm tra HTTP trong `smoke-test.mjs`; chạy `pnpm test` trong `tools` cũng dùng luồng này. Dữ liệu kiểm thử ở bộ nhớ của PostgreSQL nhúng; file và log nằm trong `.tools/test-data`, không sửa demo đang mở. Kiểm tra cả thanh toán đồng thời, khóa chỉ số, snapshot đơn giá, hoàn cọc và phân quyền khu/file. Bộ PostgreSQL nhúng dùng [PGlite và socket PostgreSQL](https://pglite.dev/docs/pglite-socket), chưa thay thế kiểm thử hạ tầng trên server PostgreSQL/Docker đích.

Sinh lại schema sau khi sửa model: `dotnet run --project Rental.Api -- --export-schema` (chạy khi chưa có app giữ file build). Sinh lại dữ liệu mẫu: `node tools/generate-sample.mjs`. Không sửa tay tên cột SQL riêng với model EF.

## Chưa thuộc bản đầu

Email tự động/nhắc tiền theo lịch, đăng ký tài khoản công khai, đặt phòng trực tuyến, đa ngôn ngữ, menu cấu hình trong DB, báo cáo thu chi/lợi nhuận đầy đủ, thanh toán ngân hàng tự động, điều chỉnh/hoàn giao dịch thu tiền, cho thuê theo giường và nền tảng nhiều chủ trọ độc lập. Trang tìm phòng lọc/sắp xếp ở server; các bảng quản lý vẫn lọc/phân trang trên giao diện và cần phân trang phía server trước khi dùng cho số lượng hồ sơ lớn.
