# Fieldforce Mobile App (Flutter)

Ứng dụng di động dành cho Nhân viên Thực địa (Worker) kết nối trực tiếp với backend **Odoo Field Service Management (FSM)**.

## 📌 Tính năng chính
1. **Lịch trình & Đơn dịch vụ (`fsm.order`):** Xem danh sách đơn công việc, nhận thông báo, điều hướng bản đồ GPS (`fsm_route_map`).
2. **Offline Mode:** Đồng bộ dữ liệu ngoại tuyến khi không có kết nối internet qua Isar Database.
3. **Quản lý Vật tư & Thiết bị (`fieldservice_stock`):** Quét mã vạch Barcode/QR vật tư xe dịch vụ, tạo phiếu xuất kho.
4. **Nghiệm thu & Chữ ký:** Chụp ảnh nghiệm thu công trình, lấy chữ ký trực tiếp trên ứng dụng.
5. **Thời gian & Chi phí:** Ghi nhận Timesheet (`fieldservice_timesheet`), tạo đề nghị thanh toán chi phí (`fieldservice_expense`).

## 📁 Cấu trúc Thư mục

```text
fieldforce_mobile/
├── assets/                  # Hình ảnh, font chữ, icon
├── lib/
│   ├── main.dart            # File chạy chính ứng dụng
│   ├── core/                # Kết nối Odoo API, Database, Authentication
│   └── features/            # Phân hệ chức năng (Orders, Routes, Stock, Expense, Timesheet)
├── references/              # Kho nguồn mã mẫu tham khảo từ Mobo Open Source
│   ├── mobo_delivery/      # Tham khảo định vị & giao hàng
│   ├── mobo_inventory/     # Tham khảo kho bãi & mã vạch
│   └── mobo_expense/       # Tham khảo chi phí & hóa đơn
└── pubspec.yaml             # Cấu hình thư viện Flutter
```

## 🚀 Hướng dẫn Chạy ứng dụng

```bash
# Lấy các thư viện phụ thuộc
flutter pub get

# Chạy ứng dụng trên thiết bị/emulator
flutter run
```
