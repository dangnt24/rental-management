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

**Khi sửa code/UI:** nhấp đúp **`Restart.cmd`** (hoặc `powershell -ExecutionPolicy Bypass -File .\Start.ps1 -Restart`). Lệnh dừng đúng server do launcher này chạy, build lại frontend/API và mở trình duyệt khi API sẵn sàng. Dữ liệu được giữ nguyên. `Start.cmd` thấy web đang chạy sẽ mở lại web hiện có, không build thêm; `Restart.cmd` dùng để cập nhật. Nếu tab cũ vẫn hiển thị giao diện trước đó, nhấn **Ctrl+F5**. Launcher từ chối dừng tiến trình khác hoặc server không xác minh được; khi đó dừng cửa sổ web cũ bằng **Ctrl+C**.

Với database mẫu tạo mới, **`tenant` / `Demo@123456`** gắn với Nguyễn Minh Anh (P.101), **`tenant2` / `Demo@123456`** gắn với Phạm Hải Đăng (A.01). Database đã có dữ liệu không tự thêm tài khoản: chủ trọ vào **Tài khoản & phạm vi quản lý → Thêm tài khoản → Người thuê → chọn hồ sơ người thuê**. Mỗi hồ sơ chỉ gắn một tài khoản; không cho tự đăng ký hoặc tự chọn hồ sơ qua trang công khai.

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

## Bộ dữ liệu bổ sung Cần Thơ

File **[Database/04_can_tho_sample.sql](Database/04_can_tho_sample.sql)** tự chứa dữ liệu giả lập kỳ 08–10/2026: 6 khu tại Ninh Kiều, Tân An, Cái Khế, Bình Thủy, Cái Răng, Ô Môn; 36 phòng, 42 hồ sơ/tài khoản người thuê, 7 tài khoản quản lý, 24 hợp đồng và 54 hóa đơn. Có phòng trống, sửa chữa, ở ghép, trả đủ/trả một phần/chưa trả, hóa đơn hủy, thiếu cọc, bù trừ/hoàn cọc và hồ sơ đã trả phòng/chưa thuê. Điện thoại và CCCD dùng mã `CT-DEMO` để tránh nhầm với thông tin thật; giá và địa chỉ cụ thể đều hư cấu.

Đứng trong `Source`, nạp thủ công vào database đã có schema hiện tại:

```powershell
psql -h localhost -U postgres -d rental_management -v ON_ERROR_STOP=1 -f .\Database\04_can_tho_sample.sql
```

Database mới nên nạp `01_schema.sql` rồi `02_sample.sql` trước để có sẵn Owner `admin`; bộ Cần Thơ không tạo thêm Owner. Database Source cũ cần nâng cấp `03_public_tenant.sql` trước nếu chưa có tính năng người thuê. File dùng transaction, tự cấp ID và liên kết đúng ID thực; bổ sung dữ liệu, không ghi đè dữ liệu cũ. Nạp lại sẽ bỏ qua dựa trên audit marker, không reset tài khoản đã sửa. File không được tự nạp bởi launcher/SeedDemo/Docker.

Mật khẩu demo chung **`CanTho@123456`**. Đăng nhập thử:

| Tài khoản | Tình huống |
| --- | --- |
| `ct_ql_nk` | Quản lý một khu Ninh Kiều |
| `ct_ql_bt` | Quản lý một khu Bình Thủy |
| `ct_ql_lienkhu` | Quản lý ba khu Ninh Kiều, Tân An, Cái Khế |
| `ct_nk_01` / `ct_nk_02` | Hai người cùng phòng, cùng xem hợp đồng/hóa đơn; chỉ thấy yêu cầu sửa do chính mình gửi |
| `ct_nk_03` | Trả tiền hai đợt còn nợ, thiếu cọc và có lịch sử hóa đơn hủy |
| `ct_nk_04` | Hợp đồng sắp hết hạn, chưa trả hóa đơn tháng 10 |
| `ct_nk_06` | Đã trả phòng, xem lịch sử thanh toán và xử lý cọc |
| `ct_nk_07` | Có tài khoản/hồ sơ, chưa có hợp đồng |

Danh sách đầy đủ 49 tài khoản và phạm vi từng người nằm trong phần chú thích đầu file SQL. Không tạo thêm tài khoản Owner. Sinh lại file bằng `node tools/generate-can-tho-sample.mjs`; kiểm tra trên PostgreSQL nhúng riêng bằng `node tools/can-tho-sample-test.mjs`, thêm `--api` để thử đăng nhập/phân quyền với DLL đã build. Không dùng kết nối database ứng dụng cho các kiểm tra này.

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

Docker là cấu hình demo trên localhost; chưa được chạy thử bằng Docker Desktop trong môi trường thực hiện vì máy chưa có Docker. Mật khẩu mặc định trong Compose và dữ liệu mẫu phục vụ demo; đổi mật khẩu tài khoản qua **Menu tài khoản → Đổi mật khẩu**, đặt mật khẩu database qua `POSTGRES_PASSWORD` trước khi triển khai thật. Cấu hình Local chỉ dành cho chạy từ source trên máy; khi publish/Docker, đặt `ConnectionStrings__Rental` trong môi trường triển khai.

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

### Thông tin chi tiết phòng

Khách xem tại **Tìm phòng → Chi tiết**. Owner/Manager xem bằng nút mắt hoặc nhấp đúp trong **Phòng trọ**; chọn **Chỉnh sửa thông tin** để nhập diện tích, tầng, loại phòng, 10 tiện nghi, sinh hoạt/quy định, cọc tham khảo, thời hạn thuê tối thiểu, mô tả khu vực và liên hệ công khai. Người thuê có mục **Phòng của tôi**, chỉ xem phòng liên quan đến hợp đồng của mình. Nút **Sao chép** lấy nội dung giới thiệu phòng; ảnh phòng cần được tải lên riêng.

Giá giới thiệu/cọc tham khảo của phòng không thay đổi giá và sổ cọc hợp đồng. Phí đang công bố lấy từ đơn giá thực tế của khu: điện theo kWh, nước theo m³, dịch vụ theo người hoặc phòng; 0 đồng là miễn phí, chưa thiết lập là chưa công bố. Phí xe/giặt sấy chưa có cách tính riêng chỉ được mô tả trong lưu ý, chưa tự tính thêm theo xe/lượt trên hóa đơn. Không tự gắn nhãn xác thực. NULL/rỗng là chưa cập nhật; danh sách tiện nghi chỉ được coi là có/không sau khi quản lý chọn xác nhận.

Database đang có dữ liệu cần chạy **`Database/05_room_details.sql`** (bổ sung cột, chạy lại được, không xóa dữ liệu). **`06_can_tho_room_details.sql`** tùy chọn: chỉ bổ sung chi tiết hư cấu cho các phòng CT từ file 04 cũ có toàn bộ chi tiết đang trống; giữ nguyên dữ liệu quản lý đã sửa và các phòng ngoài bộ CT. Database mới dùng `01_schema.sql` đã có đầy đủ cấu trúc; file 04 sinh mới đã chứa chi tiết. `RoomRequest.Details` nhận cả nhóm thông tin; client cũ không gửi `Details` thì API giữ nguyên chi tiết phòng đã có.

Ảnh của **Phòng của tôi** qua `GET /api/tenant/rooms/{roomId}/photos/{id}` cần đăng nhập Tenant, có hợp đồng liên quan, và ảnh được quản lý đánh dấu công khai. Phòng đang thuê vẫn xem được tại đây; khách công khai chỉ được xem phòng trống. Chi tiết phòng/đơn giá hiển thị là thông tin hiện tại; giá và các dòng hóa đơn lịch sử vẫn theo snapshot hợp đồng/hóa đơn.

Giao diện dùng **Be Vietnam Pro** với file font đầy đủ ký tự tiếng Việt, lưu tại `Frontend/public/fonts/be-vietnam-pro/` cùng giấy phép OFL. Các độ đậm 400/500/600/700 và italic thường có file riêng, không tải font từ CDN khi sử dụng web. Bộ lọc tìm phòng có **Thu gọn / Mở bộ lọc**, giữ nội dung đang nhập và tóm tắt các điều kiện đã áp dụng. Trên thanh đầu trang xem phòng, khách chỉ thấy **Đăng nhập**; sau đăng nhập, Owner/Manager có nút **Trang quản trị** về `#overview`, Tenant có **Trang người thuê** về `#tenant`, bên cạnh menu tài khoản. Trong không gian người thuê vẫn có nút **Tìm phòng** để quay lại danh sách phòng.

Các thao tác bỏ bản nháp, đặt lại form/bộ lọc, đăng xuất, ngừng sử dụng phòng, hủy hóa đơn, quyết toán trả phòng và xóa file đều có bước xác nhận. Form đang sửa được bảo vệ khi đổi trang/tab; F5/đóng tab dùng cảnh báo gốc của trình duyệt khi có nội dung chưa lưu. Trong lúc gửi dữ liệu hoặc upload, ứng dụng chặn rời form. Tại **Thu tiền & công nợ**, nhấp đúp hoặc nhấn Enter trên dòng hóa đơn/giao dịch để xem chi tiết, bên cạnh các nút xem có sẵn.

`DELETE /api/attachments/{id}` dành cho Owner hoặc Manager đúng khu. File được đánh dấu `IsArchived`, hủy công khai và ghi audit; không còn nằm trong danh sách, không tải được qua API quản lý hoặc trang tìm phòng. Bản lưu trên ổ đĩa vẫn giữ để tránh mất chứng từ. Tính năng dùng cột có sẵn, không cần chạy thêm SQL nâng cấp.

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

## Hồ sơ tài khoản và quản lý người dùng

Owner có menu riêng **Tài khoản & phạm vi quản lý** (`#accounts`): thêm/sửa tài khoản, phân vai trò và khu được giao, liên kết hồ sơ người thuê, khóa/mở và tra cứu theo tên/tài khoản/email/điện thoại (hỗ trợ tìm không dấu), vai trò, trạng thái, khu trọ. Manager không thấy menu và API vẫn chặn thao tác quản lý tài khoản.

Bấm cụm **avatar + tên + vai trò** trên thanh đầu trang để mở dropdown. Cả Owner, Manager và Tenant đều có **Xem thông tin tài khoản**, sửa họ tên/ảnh đại diện và **Đổi mật khẩu**. Email/số điện thoại chỉ đọc trong hồ sơ cá nhân; chỉ Owner cập nhật ở trang quản lý tài khoản. API `PUT /api/auth/profile` nhận multipart `fullName` và tối đa một `avatar` JPG/PNG 2 MB, từ chối trường email/phone/role/id. Avatar lưu riêng trong `App_Data/avatars`; `/api/auth/avatar/{id}` chỉ cho chính người dùng hoặc Owner xem. Đổi ảnh giữ bản cũ để phục hồi; không trả tên file lưu nội bộ. Đổi mật khẩu làm phiên cũ hết hiệu lực.

Database cũ chạy **`08_account_profile.sql`** sau các nâng cấp trước. Lần đầu sao chép điện thoại từ hồ sơ người thuê đã liên kết vào tài khoản; chạy lại không ghi đè. Thông tin liên hệ tài khoản và hồ sơ thuê là hai trường dữ liệu riêng: Owner sửa email/phone tài khoản không tự sửa chứng từ/hồ sơ thuê. Tài khoản cấp mới cần nhập liên hệ nếu muốn có thông tin này.

## Upload nhiều file, thứ tự và xem ảnh lớn

Control file đính kèm của phòng, người thuê, hợp đồng, thu tiền và sự cố cho chọn **1–10 file/lượt, tối đa 10 MB/file**, JPG/PNG/PDF. Client mới gửi multipart nhiều trường `files`; client cũ gửi một `file` vẫn hoạt động. API kiểm tra toàn bộ lượt trước khi lưu; lỗi ở bất kỳ file nào hủy cả lượt, giao dịch lỗi dọn file mới. Giới hạn riêng của lượt upload là 102 MB (10 × 10 MB và phần multipart), không nới giới hạn các API khác. Avatar là ảnh đơn riêng với giới hạn 2 MB.

Ảnh phòng hiển thị thumbnail, nút lên/xuống, **Đặt làm ảnh đại diện**, **Lưu thứ tự ảnh**. Ảnh mới mặc định riêng tư. Ảnh công khai đứng đầu theo `SortOrder`, rồi `Id` là ảnh đại diện; PDF và ảnh riêng tư không xuất hiện trên trang tìm phòng. Thứ tự dùng chung cho khách, người thuê và quản lý. `POST /api/attachments/room/{id}/order` yêu cầu đủ toàn bộ ID ảnh đang có (kể cả riêng tư), chặn ID trùng, ảnh phòng khác và danh sách cũ; chỉ Owner/Manager đúng khu được đổi. Database cũ chạy **`07_attachment_order.sql`**; lần đầu giữ thứ tự ID, chạy lại không reset thứ tự đã lưu.

Trong chi tiết phòng, bấm ảnh chính hoặc thumbnail để xem ảnh lớn vừa màn hình; có nút trước/sau, thumbnail, phím ←/→ và Esc/Đóng. Lăn chuột để zoom theo vị trí con trỏ, kéo ảnh đã zoom để xem từng vùng; trên điện thoại chụm/tách hai ngón để thu nhỏ/phóng to, một ngón kéo ảnh khi đã zoom hoặc vuốt chuyển ảnh khi ảnh vừa khung. Zoom từ 100% (vừa khung) đến 500%, có nút +/−, đặt lại vừa khung và nhấp đúp để zoom/đặt lại. Giới hạn kéo theo kích thước ảnh thực, không kéo lạc ảnh khỏi khung; kết thúc pinch không chuyển nhầm ảnh. Đổi ảnh tự reset zoom, đổi kích thước cửa sổ kiểm tra lại giới hạn kéo. Esc chỉ đóng khung ảnh, giữ trang chi tiết bên dưới. Áp dụng chung cho trang tìm phòng, phòng của người thuê và màn quản lý.

`Frontend/src/features/rooms/usePhotoZoom.ts` xử lý chuột/cảm ứng bằng Pointer Events và wheel không passive trong vùng ảnh; `photoViewport.ts` tính tỷ lệ, tâm zoom và giới hạn kéo. Chạy `node tools/photo-viewport-test.mjs` (hoặc `pnpm test:photos` trong `tools`) để kiểm tra giữ điểm ảnh dưới con trỏ/tâm hai ngón, di chuyển tâm pinch, giới hạn zoom/kéo và ảnh ngang/dọc.

Kiểm thử upload/profile nằm trong `tools/uploads-profile-test.mjs`, được gọi từ bộ `postgres-test.mjs`; kiểm tra nâng cấp 07/08 giữ dữ liệu, upload nhiều file đúng 10 MB/file và tổng 60 MB, từ chối file vượt 10 MB, hủy lượt lỗi, thứ tự ảnh/phân quyền, avatar riêng tư, trường liên hệ tự sửa bị chặn và phiên hết hiệu lực khi đổi mật khẩu.

## Email hóa đơn và hợp đồng qua Hangfire

Hangfire Core + Hangfire.PostgreSql chạy trong API, lưu job ở schema riêng **`hangfire`** của PostgreSQL. Recurring job **`dvp-daily-email-reminders`**, cron **`0 9 * * *`**, múi giờ Việt Nam: 09:00 hằng ngày. Máy/server và tiến trình API phải chạy để xử lý job; dừng terminal chạy API hoặc tắt máy thì không gửi được đúng giờ. Không cần giữ trình duyệt mở. Không cần Hangfire Pro cho tính năng này. `Hangfire:Enabled=false` dành cho môi trường kiểm thử PostgreSQL nhúng; web thật mặc định bật worker.

Job quét **hóa đơn đã lập**, trạng thái Issued, đã đến hạn/quá hạn và còn tiền chưa thanh toán; không tự tạo hóa đơn mới. Email có các khoản thu, tổng, đã trả và còn nợ. Đồng thời quét hợp đồng Active còn từ 0 đến N ngày, mặc định **7 ngày**, chỉnh được từ 1–90 trong **Thiết lập → Email nhắc thanh toán & hợp đồng**. Không tự gia hạn, đóng hợp đồng hay ghi nhận thanh toán.

Người nhận là email tài khoản Tenant hoạt động liên kết với **người đại diện hợp đồng**. Chủ trọ cập nhật email ở **Tài khoản & phạm vi quản lý**. Người thuê chưa có tài khoản/email không nhận được; danh sách đến hạn hiển thị rõ trường hợp này. Không đưa CCCD/mật khẩu vào thư. Nếu cấu hình `PublicBaseUrl` HTTPS công khai thì email có link về tài khoản người thuê; bỏ trống khi dùng localhost.

Owner quản lý lịch tự động, số ngày báo trước, danh sách đến hạn và 100 nhật ký gần nhất. **Gửi các thông báo đến hạn** quét ngay, kể cả khi lịch tự động đang tắt. Owner/Manager đúng khu có nút **Gửi email** trong chi tiết hóa đơn còn nợ và trên hợp đồng đang thuê chưa hết hạn; gửi thủ công được cả trước hạn. Hộp xác nhận hiển thị người nhận và tiêu đề trước khi xếp hàng. API vẫn kiểm tra quyền và kiểm tra lại thanh toán/ngày hết hạn/người đại diện trước lúc gửi.

Outbox `email_reminders` có khóa duy nhất theo loại + ID + ngày đến hạn + người đại diện, trạng thái gửi và số lượt thử. Hangfire chỉ nhận ID thông báo; không serialize thông tin SMTP/mật khẩu vào job. Claim trạng thái trong DB trước SMTP giúp job trùng/retry bỏ qua thư đã gửi/đang gửi. SMTP từ chối rõ ràng được Hangfire thử lại sau 1/5/15 phút; mất kết nối khi gửi có thể đã được SMTP nhận thì đánh dấu **Cần kiểm tra**, không tự gửi lại. Lượt Sending bị gián đoạn quá 10 phút cũng cần xác nhận kiểm tra trước khi gửi lại. Sent nghĩa SMTP đã nhận, không đảm bảo đã vào Inbox/được đọc. Email là HTML/text trong nội dung thư, chưa đính kèm PDF.

Database Source đang dùng: sao lưu rồi chạy **`Database/09_email_reminders.sql`** trước bản mới; chạy lại giữ cấu hình và nhật ký cũ. Database mới dùng `01_schema.sql` đã có cấu trúc. SMTP chưa cấu hình thì lịch tự động mặc định tắt và nút gửi hàng loạt không hoạt động; không tự gửi thư thật từ bộ dữ liệu demo.

### Cấu hình SMTP miễn phí

Gợi ý ban đầu: Gmail cá nhân cho quy mô nhỏ (Google công bố giới hạn khoảng 500 email/ngày); hoặc Brevo Free (300 email/ngày). Đây là hạn mức gửi miễn phí, không gồm chi phí máy chủ/đường truyền và không phải gửi không giới hạn. Xem [Gmail limits](https://support.google.com/mail/answer/22839), [Brevo Free](https://help.brevo.com/hc/en-us/articles/208580669-FAQs-What-are-the-limits-of-the-Free-plan), [Hangfire licensing](https://www.hangfire.io/pricing/).

Mẫu **`Rental.Api/appsettings.Email.example.json`**. Thêm hai nhóm `Hangfire` và `EmailSmtp` trong mẫu vào **appsettings.Local.json đang có**, giữ nguyên `ConnectionStrings`; không chép đè cả file Local. Hoặc cấu hình các biến môi trường `EmailSmtp__Host`, `EmailSmtp__Port`, `EmailSmtp__Security`, `EmailSmtp__Username`, `EmailSmtp__Password`, `EmailSmtp__FromAddress`, `EmailSmtp__FromName`, `EmailSmtp__PublicBaseUrl`.

Gmail: host `smtp.gmail.com`, cổng `587`, `Security=StartTls`, Username/FromAddress là tài khoản gửi; Password là **mật khẩu ứng dụng**, không dùng mật khẩu đăng nhập thường. Tài khoản cần bật xác minh hai bước và hỗ trợ app password theo [hướng dẫn Google](https://support.google.com/accounts/answer/185833). Brevo dùng thông tin SMTP login/key từ trang SMTP của tài khoản. MailKit hỗ trợ StartTls hoặc SslOnConnect (thường 465); plaintext chỉ được phép với SMTP localhost để kiểm thử. Không tắt xác thực chứng chỉ TLS. Không đưa mật khẩu vào Git, nhật ký, screenshot hoặc gửi qua chat.

Sau khi cấu hình: chạy **Restart.cmd**, vào **Thiết lập**, kiểm tra SMTP đã sẵn sàng, cập nhật email người thuê, thử một hóa đơn bằng nút gửi thủ công và xem nhật ký, rồi bật lịch tự động. Dùng tài khoản gửi riêng để dễ theo dõi hạn mức và thư bị trả lại. Chưa có chức năng ghi đè địa chỉ người nhận bằng dữ liệu tùy ý ở nút gửi.

### Luồng source và kiểm thử mail

`Program.cs` đăng ký Hangfire/SMTP và lịch 9h → `EmailReminderJob.ScanAndQueue` tìm thông báo phù hợp → `ReminderComposer` lấy người đại diện, số dư và dựng email → `EmailReminderQueue` lưu outbox rồi enqueue → `EmailReminderJob.Send` kiểm tra lại/claim → `SmtpEmailSender` gửi bằng MailKit → cập nhật nhật ký. API quản trị ở `EmailReminderService`, UI tại `features/notifications/`; không gửi SMTP trong transaction của API nghiệp vụ.

`tools/postgres-test.mjs` kiểm tra nâng cấp 09 lặp lại và quyền API mới. `tools/email-reminder-test.mjs` kiểm tra trên **PostgreSQL thật + Hangfire + SMTP giả lập localhost**, với kết nối trỏ database riêng có tên `rental_mail_test_...` qua `RENTAL_TEST_CONNECTION`/`RENTAL_TEST_DATABASE` và biến PGHOST/PGPORT/PGUSER/PGPASSWORD cho psql. Không chạy test này trên database ứng dụng. Bộ test xác nhận cron/múi giờ, gửi thủ công, scan trùng, thanh toán/gia hạn khi đang chờ, SMTP từ chối/mất phản hồi và retry có kiểm soát; không gửi thư ra ngoài. Kết nối/authentication với Gmail/Brevo thật cần thông tin SMTP của bạn để kiểm tra sau.

## Chưa thuộc bản đầu

Đăng ký tài khoản công khai, đặt phòng trực tuyến, đa ngôn ngữ, menu cấu hình trong DB, báo cáo thu chi/lợi nhuận đầy đủ, thanh toán ngân hàng tự động, điều chỉnh/hoàn giao dịch thu tiền, cho thuê theo giường và nền tảng nhiều chủ trọ độc lập. Trang tìm phòng lọc/sắp xếp ở server; các bảng quản lý vẫn lọc/phân trang trên giao diện và cần phân trang phía server trước khi dùng cho số lượng hồ sơ lớn.
