# Giới thiệu

Bạn đã bao giờ lỡ tay xóa nhầm một tệp quan trọng, rồi nhận ra bản sao lưu của mình cũng đã xóa nó theo chưa?

Đó là nghịch lý cốt lõi của mọi phần mềm sao lưu kiểu "gương phản chiếu" (mirror backup): càng đồng bộ tốt, càng dễ mất dữ liệu vĩnh viễn khi có sự cố.

**SaoLuuMini** giải quyết nghịch lý này bằng cơ chế dự phòng hai cấp.

## Cấp 1. Sao lưu liên tục, trung thực

SaoLuuMini theo dõi thư mục Nguồn của bạn và liên tục phản chiếu mọi thay đổi sang thư mục Đích: tệp mới được sao chép, tệp đổi tên được đổi tên theo, tệp bị xóa cũng bị xóa theo. Toàn bộ thuộc tính, thời gian, phân quyền đều được giữ nguyên. Đây là bản sao trung thực nhất có thể, bạn mở thư mục Đích ra là thấy y chang thư mục Nguồn tại thời điểm đó.

## Cấp 2. Lưới an toàn khi lỡ tay

Trước khi xóa hoặc ghi đè bất cứ thứ gì ở Đích, SaoLuuMini không vứt thẳng vào hư không. Tùy vào lựa chọn của bạn.

- **Thùng rác hệ thống**: Tệp bị loại khỏi Đích sẽ vào thùng rác, có thể khôi phục trong vài cú nhấp chuột.
- **Thư mục Dự phòng**: Mọi phiên bản cũ bị thay thế đều được gom vào một thư mục bạn chỉ định, tạo thành kho lịch sử phiên bản thủ công.

Chỉ khi bạn chủ động tắt cả hai tùy chọn này, dữ liệu mới thực sự bị xóa cứng.

Kết quả: thư mục Đích luôn phản chiếu chính xác thư mục Nguồn, nhưng bạn không bao giờ mất hoàn toàn thứ mình lỡ xóa. Sao lưu mà vẫn có lưới đỡ - đó là SaoLuuMini.
