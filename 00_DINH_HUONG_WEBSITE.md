# Website quản lý nhà trọ — định hướng và tính năng

Ngày tổng hợp: 24/10/2026. Đây là phạm vi định hướng từ tài liệu cũ. Hiện trạng và thay đổi code sau khi triển khai được ghi tại `01_DOI_CHIEU_VA_DIEU_CHINH.md`.

## 1. Mục tiêu

Giúp chủ trọ quản lý một hoặc nhiều khu trọ trên cùng website: biết phòng nào còn trống, ai đang ở, mỗi tháng phải thu bao nhiêu và còn nợ bao nhiêu. Sản phẩm cần dùng được thực tế, dễ thao tác trên điện thoại và đủ hoàn chỉnh để đưa vào CV.

Người dùng chính: **chủ trọ** và **quản lý/nhân viên được phân quyền**. Cổng dành cho người thuê triển khai sau.

## 2. Tính năng và vấn đề giải quyết

| Tính năng | Nội dung chính và vấn đề giải quyết |
| --- | --- |
| Khu trọ và phòng | Giá thuê, sức chứa, ảnh, trạng thái trống/đang thuê/đang sửa; tránh quản lý phòng rời rạc. |
| Người thuê | Hồ sơ, liên hệ, giấy tờ, người đại diện và người ở cùng; tra cứu được lịch sử cư trú. |
| Hợp đồng và tiền cọc | Phòng, danh sách người ở, thời hạn, giá thỏa thuận, tiền cọc, file hợp đồng; theo dõi gia hạn và trả phòng. |
| Điện, nước và dịch vụ | Nhập chỉ số cũ/mới; cấu hình phí theo lượng dùng, phòng hoặc người; giảm tính tay và nhầm đơn giá. |
| Hóa đơn hàng tháng | Lập và kiểm tra tiền thuê + điện nước + dịch vụ; có hạn thanh toán và bản in/PDF rõ từng khoản. |
| Thu tiền và công nợ | Ghi nhận từng lần thu, phương thức, chứng từ; phân biệt chưa trả/trả một phần/đã trả và biết số còn thiếu. |
| Sự cố và bảo trì | Ghi nhận nội dung, ảnh, tiến độ, cách xử lý và chi phí; tránh bỏ sót yêu cầu sửa chữa. |
| Tổng quan và nhắc việc | Phòng trống, tỷ lệ lấp đầy, tiền phải thu/đã thu/còn nợ; danh sách quá hạn và hợp đồng sắp hết hạn. |
| Tài khoản và phân quyền | Chủ trọ cấp quyền theo công việc và khu trọ; hạn chế truy cập hồ sơ, giấy tờ và dữ liệu thu tiền. |

Tìm kiếm, lọc, phân trang và đính kèm ảnh/file là khả năng dùng chung cho các màn hình cần thiết.

## 3. Luồng vận hành cần hoàn thiện trước

**Tạo khu/phòng → nhập người thuê → lập hợp đồng và ghi nhận cọc → chốt điện nước → lập hóa đơn → thu tiền, theo dõi nợ → gia hạn hoặc trả phòng, quyết toán cọc.**

Các quy tắc đề xuất:

- Một phòng không có hai hợp đồng thuê nguyên phòng cùng hiệu lực; một hợp đồng có thể có nhiều người ở và một người đại diện.
- Chỉ số mới không nhỏ hơn chỉ số cũ; không lập trùng hóa đơn cùng hợp đồng và kỳ thu.
- Hóa đơn lưu đơn giá tại thời điểm lập; đổi bảng giá không làm thay đổi hóa đơn cũ.
- Công nợ = số phải thu − các khoản thanh toán hợp lệ; tiền cọc theo dõi riêng, chỉ bù trừ khi quyết toán có ghi nhận.
- Giữ lịch sử hợp đồng, hóa đơn, thanh toán và các điều chỉnh để đối soát.

## 4. Thứ tự triển khai đề xuất

1. **Bản đầu dùng được:** tài khoản và quyền cơ bản, khu/phòng, người thuê, hợp đồng/cọc, điện nước/phí, lập hóa đơn theo tháng bằng thao tác chủ động, thu tiền/công nợ, tổng quan cơ bản.
2. **Hoàn thiện vận hành:** sự cố/bảo trì, PDF, email nhắc tiền/hết hạn, báo cáo tháng và tự động lập hóa đơn sau khi chốt đủ dữ liệu.
3. **Mở rộng:** người thuê đăng nhập xem hóa đơn/lịch sử và báo sự cố; menu động, đa ngôn ngữ, quyền chi tiết; nhiều chủ trọ độc lập trên cùng nền tảng nếu có nhu cầu.

Định hướng kỹ thuật hiện có là ASP.NET Core API + PostgreSQL + React. Ưu tiên cấu trúc rõ ràng và hoàn thiện luồng nghiệp vụ; framework dùng lại cho nhiều dự án, T4 generator và nhiều tầng/project chưa cần là mục tiêu bắt buộc của bản đầu. Docker/CI/CD phục vụ giai đoạn triển khai.

Trước khi sửa Source cần chốt: cho thuê nguyên phòng hay từng giường; tính tiền tháng đầu/cuối; cách tính nước/phí; quy tắc khấu trừ và hoàn cọc. Các mục này là câu hỏi nghiệp vụ còn mở.

## 5. Tài liệu sau khi dọn

- Dùng file này làm điểm bắt đầu trao đổi và chốt phạm vi.
- Giữ `02.Database/V2/` với schema, data và bản cập nhật V3 làm lịch sử tham khảo. Bộ cài mới dùng cho Source hiện tại nằm tại `Source/Database/01_schema.sql` và `Source/Database/02_sample.sql` (đường dẫn tính từ thư mục gốc dự án).
- Chuyển 21 file gồm mô tả/prompt cũ, ghi chú tạm, SQL Design/V1/Err và cache V2 vào `_Archive/2026-10-24/`, giữ nguyên nội dung và đường dẫn tương đối. Hai dump về thể thao và ghi chú cá nhân nằm trong nhóm lưu trữ này. Danh mục và lý do nằm trong `archive-manifest.json`.
- Ở bước dọn tài liệu ban đầu, cả hai thư mục Source được giữ nguyên. Trong bước triển khai tiếp theo theo yêu cầu, chỉ `C:/rental-management/Source` được sửa; `Document/Source` tiếp tục giữ làm bản tham khảo.
