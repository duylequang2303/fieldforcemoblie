# PROJECT RESCUE MODE - DEADLINE

## MỤC TIÊU
- Chỉ sửa lỗi chặn luồng chính: login, danh sách đơn, chi tiết đơn, route, sync, offline.
- Không thêm tính năng mới trừ khi được yêu cầu rõ trong phase hiện tại.
- Không refactor lớn.
- Không đổi cấu trúc thư mục nếu không bắt buộc.
- Không xóa file cũ; chỉ đánh dấu deprecated hoặc redirect nếu cần.
- Không thêm package mới nếu chưa có chấp thuận.
- Không thay đổi schema database/Isar nếu không bắt buộc. Nếu bắt buộc, phải nói rõ migration risk.

## PHẠM VI ƯU TIÊN
1. App mở được, không crash.
2. Đăng nhập được.
3. Load được danh sách đơn.
4. Mở đúng một màn chi tiết đơn duy nhất.
5. Sync/Isar không crash.
6. Không lỗi overflow nghiêm trọng.
7. API không gửi field không tồn tại.
8. AccessError phải được fallback an toàn, không làm chết app.

## NGUYÊN TẮC CODE
- Mọi thay đổi phải giữ app compile được.
- Không hardcode màu, font size, text nếu có thể dùng theme/constant có sẵn.
- Không dùng `!` bừa bãi. Ưu tiên null-safe.
- Không gọi API rồi crash nếu thiếu field. Phải fallback.
- Với Odoo/API field không chắc tồn tại: không gửi, hoặc đọc theo kiểu optional.
- Với Isar: luôn dedupe trước khi put/putAll.
- Với navigation: chỉ có một route chính cho Order Detail.
- Với UI: Text dài phải có Expanded/Flexible/FittedBox.

## ĐẦU RA BẮT BUỘC SAU MỒI LẦN SỬA
1. Danh sách file đã sửa.
2. Tóm tắt thay đổi.
3. Cách test thủ công.
4. Lệnh đã chạy nếu có: flutter analyze, flutter build apk --debug, flutter test.
5. Các rủi ro còn lại.
