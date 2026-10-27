# Chức năng theo vai trò của DVP Home

Cập nhật ngày 27/10/2026.

DVP Home có ba role đăng nhập: Tenant, Manager và Owner. Khách chưa đăng nhập là trạng thái truy cập công khai.

## Phạm vi từng vai trò

| Vai trò | Phạm vi dữ liệu |
| --- | --- |
| Khách chưa đăng nhập | Xem thông tin phòng được công khai. Đây là trạng thái truy cập, không phải role tài khoản. |
| Người thuê (Tenant) | Xem các hợp đồng có tên hồ sơ người thuê đã liên kết với tài khoản và dữ liệu phát sinh từ các hợp đồng đó. |
| Quản lý (Manager) | Xem và thực hiện nghiệp vụ trong các khu trọ được chủ trọ phân công. |
| Chủ trọ (Owner) | Xem và quản lý tất cả khu trọ; quản trị tài khoản, phân quyền và đơn giá dịch vụ. |

## Chức năng công khai và theo dõi việc thuê

| Chức năng | Khách | Người thuê | Quản lý | Chủ trọ |
| --- | --- | --- | --- | --- |
| Xem danh sách phòng còn trống | Có | Có | Có | Có |
| Tìm theo tên phòng, khu trọ, địa chỉ hoặc mô tả | Có | Có | Có | Có |
| Lọc theo khu, khoảng giá, số người; sắp xếp giá hoặc tên | Có | Có | Có | Có |
| Xem chi tiết, ảnh công khai và phí dịch vụ của phòng | Có | Có | Có | Có |
| Xem hợp đồng đang thuê và lịch sử hợp đồng | Không | Của mình | Được giao | Tất cả khu |
| Xem hóa đơn, chi tiết khoản thu; in hoặc lưu PDF | Không | Của mình | Được giao | Tất cả khu |
| Xem lịch sử thanh toán và công nợ | Không | Của mình | Được giao | Tất cả khu |
| Xem số dư cọc và lịch sử nhận, bù trừ, khấu trừ, hoàn | Không | Của mình | Được giao | Tất cả khu |
| Gửi yêu cầu sửa chữa | Không | Phòng đang thuê | Được giao | Tất cả khu |
| Theo dõi trạng thái và phản hồi yêu cầu sửa chữa | Không | Yêu cầu tự gửi | Được giao | Tất cả khu |
| Đổi mật khẩu tài khoản đang đăng nhập | Không | Có | Có | Có |

## Chức năng vận hành và quản trị

| Chức năng | Khách | Người thuê | Quản lý | Chủ trọ |
| --- | --- | --- | --- | --- |
| Xem tổng quan vận hành khu trọ | Không | Không | Được giao | Tất cả khu |
| Thêm hoặc sửa phòng, giá thuê tham khảo, sức chứa | Không | Không | Được giao | Tất cả khu |
| Cập nhật tình trạng sửa chữa hoặc ngừng sử dụng phòng | Không | Không | Được giao | Tất cả khu |
| Thêm hoặc sửa hồ sơ người thuê | Không | Không | Được giao | Tất cả khu |
| Lập hợp đồng, chọn người ở và người đại diện | Không | Không | Được giao | Tất cả khu |
| Gia hạn hợp đồng, cập nhật giá thuê khi gia hạn | Không | Không | Được giao | Tất cả khu |
| Nhận cọc, bù trừ cọc vào hóa đơn | Không | Không | Được giao | Tất cả khu |
| Quyết toán trả phòng, khấu trừ và hoàn cọc | Không | Không | Được giao | Tất cả khu |
| Chốt hoặc sửa chỉ số điện nước; lập hóa đơn | Không | Không | Được giao | Tất cả khu |
| Ghi nhận thu tiền mặt hoặc chuyển khoản | Không | Không | Được giao | Tất cả khu |
| Tiếp nhận, cập nhật trạng thái và xử lý sự cố | Không | Không | Được giao | Tất cả khu |
| Tải lên hoặc tải xuống tệp đính kèm riêng tư | Không | Không | Được giao | Tất cả khu |
| Đăng hoặc ẩn ảnh giới thiệu phòng trên trang công khai | Không | Không | Được giao | Tất cả khu |
| Thêm hoặc sửa khu trọ | Không | Không | Không | Có |
| Quản lý loại phí, đơn giá dịch vụ và ngừng áp dụng phí | Không | Không | Không | Có |
| Hủy hóa đơn chưa có thanh toán | Không | Không | Không | Có điều kiện |
| Cấp, sửa, khóa tài khoản; gán khu hoặc hồ sơ người thuê | Không | Không | Không | Có |
| Xem nhật ký thao tác gần đây | Không | Không | Không | Có |

## Điều kiện áp dụng

1. Tài khoản Tenant do chủ trọ cấp và gắn với một hồ sơ người thuê. Mỗi hồ sơ chỉ có một tài khoản; đổi hồ sơ liên kết làm phiên đăng nhập cũ hết hiệu lực.
2. Người thuê xem dữ liệu của hợp đồng có tên mình, kể cả hợp đồng đã đóng. Hóa đơn là hóa đơn chung của hợp đồng; chưa chia công nợ theo từng người ở.
3. Chỉ được gửi yêu cầu sửa chữa cho hợp đồng đang hoạt động. Người thuê không tự sửa chi phí, phản hồi hoặc trạng thái xử lý.
4. Hủy hóa đơn yêu cầu role Owner, hóa đơn còn hiệu lực, chưa có thanh toán, hợp đồng chưa quyết toán và phải nhập lý do. Chỉ số đã có hóa đơn còn hiệu lực sẽ bị khóa.
5. Phòng công khai phải còn trống, thuộc khu đang hoạt động, không sửa chữa hoặc ngừng sử dụng. Chỉ ảnh JPG/PNG được quản lý chọn công khai mới hiển thị; hồ sơ và PDF đính kèm vẫn riêng tư.

## Các chức năng chưa có

Chưa có tự đăng ký tài khoản, đặt phòng trực tuyến, cổng thanh toán ngân hàng tự động hoặc nhắc tiền tự động. Người thuê chưa tự sửa hồ sơ, tự gia hạn hay tự quyết toán trả phòng.

## Vị trí đối chiếu trong source

- `Program.cs`: phân nhóm route công khai, Tenant và Owner/Manager.
- `Features/Common/FeatureService.cs`: kiểm tra chủ trọ và phạm vi khu.
- `Features/Catalog/CatalogService.cs`: điều kiện công khai phòng và ảnh.
- `Features/TenantPortal/TenantPortalService.cs`: phạm vi hợp đồng, yêu cầu sửa chữa của người thuê.
- `Features/Accounts/UserService.cs`: cấp tài khoản, liên kết hồ sơ, đổi mật khẩu.
- `Features/Billing/InvoiceService.cs`: điều kiện lập và hủy hóa đơn.

Các đường dẫn trên tính từ `Source/Rental.Api`.
