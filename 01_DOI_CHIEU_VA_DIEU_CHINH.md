# Đối chiếu Source và bản định hướng

Cập nhật 26/10/2026: đã tách source theo chức năng, thay file `RentalService.cs` bằng các service riêng trong `Features` và đưa màn hình/form React vào `Frontend/src/features`. Xem `Source/ARCHITECTURE.md` để tìm file và vị trí đặt breakpoint. Luồng API, quy tắc nghiệp vụ và cấu trúc database được giữ nguyên.

Ngày 24/10/2026. Kiểm tra trực tiếp `C:/rental-management/Source`; đây là thư mục code được chỉnh trong lần này.

## Trước khi chỉnh

`Source` chỉ có project ASP.NET Core 8 với endpoint mẫu `WeatherForecast`, cấu hình Swagger và solution. Chưa có model, kết nối database, đăng nhập, giao diện hoặc nghiệp vụ quản lý trọ.

`Document/Source` là bản code tham khảo khác, chưa nằm trong solution đang làm. Kiểm tra một số module cho thấy còn thiếu chặn trùng hóa đơn, kiểm tra chỉ số, giới hạn số tiền thu và giao dịch nhất quán. Bản này được giữ nguyên để đối chiếu; không ghép nguyên bộ framework nhiều project vào bản mới.

## Sau khi chỉnh

| Nhóm trong định hướng | Bản mới trong Source |
| --- | --- |
| Khu/phòng | Thêm/sửa khu và phòng, giá/sức chứa, trạng thái theo hợp đồng, đang sửa, ngừng sử dụng và ảnh/file. |
| Người thuê | Hồ sơ/liên hệ/giấy tờ, gắn khu, người đại diện và người ở cùng, truy ngược hợp đồng cũ. |
| Hợp đồng/cọc | Lập/gia hạn/trả phòng, chống trùng phòng/người ở; sổ nhận, bù trừ, khấu trừ và hoàn cọc. |
| Điện nước/phí | Nhập/sửa trước khi lập hóa đơn, nối chỉ số kỳ trước, phí theo số dùng/phòng/người. |
| Hóa đơn | Lập theo tháng, chặn trùng, lưu chi tiết và đơn giá; hủy có lý do khi chưa thu; in/lưu PDF bằng trình duyệt. |
| Thu tiền/công nợ | Thu từng lần, chặn thu vượt nợ, tiền mặt/chuyển khoản/bù cọc; lịch sử và trạng thái thanh toán tính từ giao dịch. |
| Sự cố | Tiếp nhận, cập nhật tiến độ/cách xử lý/chi phí và ảnh đính kèm. |
| Tổng quan/nhắc việc | Phòng trống/đang thuê/đang sửa, tiền phải thu/đã nhận/nợ; hóa đơn quá hạn và hợp đồng đến hạn. Chưa gửi email. |
| Tài khoản/quyền | Chủ trọ/quản lý; gán khu, khóa tài khoản, đổi mật khẩu; kiểm tra quyền ở API và khi tải file. |
| Cách chạy | Start.cmd trên Windows mặc định dùng PostgreSQL; cấu hình kết nối riêng của máy nằm trong appsettings.Local.json. SQLite chỉ dùng khi chọn rõ để chạy thử/kiểm thử. Có hai file SQL và Compose dành cho PostgreSQL. |

## Quyết định nghiệp vụ tạm áp dụng

Cho thuê nguyên phòng; tiền thuê đủ tháng đầu/cuối; điện/nước theo chỉ số; phí theo phòng/người; cọc được theo dõi và quyết toán riêng. Chưa áp dụng cho thuê giường, tính tiền theo ngày hoặc tự động thu tiền ngân hàng. Đây là các giả định để có bản chạy được; có thể điều chỉnh sau khi bạn chốt cách vận hành thực tế.

Ưu tiên tiếp theo: dùng dữ liệu thử để chốt quy tắc tính tháng đầu/cuối và gia hạn; bổ sung cơ chế điều chỉnh/hoàn giao dịch đã thu; sau đó mới làm email theo lịch, báo cáo, phân trang API cho dữ liệu lớn và cổng người thuê. Phần framework đa mục đích, T4, đa ngôn ngữ chưa cần kéo vào bản đầu.

## Bộ database mới và nơi chạy

- `Source/Database/01_schema.sql`: schema PostgreSQL xuất từ model EF, khóa ngoại/CHECK/index nghiệp vụ.
- `Source/Database/02_sample.sql`: data hư cấu và tài khoản demo; đồng nhất với dữ liệu SQLite tự nạp.
- Đây là bộ cài mới cho database trống, chưa phải migration từ SQL V2 cũ. File cũ trong Document được giữ nguyên.
- Xem `Source/README.md` để chạy, đăng nhập và biết các giới hạn hiện tại. Không dùng tuyên bố “đã hoàn thiện production” cho bản này.

## Kiểm tra đã thực hiện

Build API thành công với 0 cảnh báo/0 lỗi; TypeScript và Vite production build thành công; chạy toàn bộ Start.ps1 thành công. Có 49 kiểm tra HTTP trên SQLite và cùng 49 kiểm tra qua Npgsql/PostgreSQL nhúng, bao gồm luồng hợp đồng → điện nước → hóa đơn → thu từng phần/đồng thời → bù trừ cọc → trả phòng, cùng kiểm tra phân quyền và file. Schema/data đã nạp thành công và kiểm tra nạp lại data không trùng/identity đúng. Đã mở và kiểm tra trực tiếp giao diện tổng quan, danh sách hóa đơn, chi tiết hóa đơn. Cấu hình Docker được cung cấp nhưng chưa chạy Docker Desktop trên máy này.
