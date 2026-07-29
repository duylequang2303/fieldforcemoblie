---
name: isar-offline-first
description: Hướng dẫn sử dụng Isar DB (collection, generator, sync strategy)
---
# Isar Offline First Skill

Hướng dẫn phát triển ứng dụng offline-first bằng cách đồng bộ hóa dữ liệu Odoo vào cơ sở dữ liệu local Isar DB.

## Cấu trúc Collection Isar
Mỗi model lưu trữ ngoại tuyến phải được annotate `@collection` và có thuộc tính ID tự tăng của Isar, cùng chỉ mục duy nhất cho ID từ Odoo.

```dart
import 'package:isar_community/isar.dart';

part 'todo.g.dart';

@collection
class Todo {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late int odooId;

  late String name;
  late bool isPendingSync;
  late DateTime lastSyncAt;
}
```

### Chạy Build Runner sinh code (.g.dart)
Để sinh code Isar schema, chạy lệnh:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Chiến lược Đồng Bộ (Sync Strategy)
1. **Lấy dữ liệu (Read/Pull)**:
   - Client fetch dữ liệu từ Odoo API.
   - Lưu trữ dữ liệu nhận được vào Isar DB bằng write transaction:
     ```dart
     await IsarService.instance.db.writeTxn(() async {
       await IsarService.instance.db.fsmOrders.putAll(orders);
     });
     ```
   - UI chỉ đăng ký lắng nghe/read từ Isar DB thông qua Provider.
2. **Ghi dữ liệu (Write/Push)**:
   - Khi user thay đổi dữ liệu khi offline: ghi vào Isar DB với cờ `isPendingSync = true`.
   - `SyncManager.instance` sẽ tự động phát hiện mạng online trở lại hoặc kích hoạt thủ công, duyệt qua các bản ghi có `isPendingSync == true` và gọi service push lên Odoo, sau khi thành công sẽ đặt `isPendingSync = false`.
