---
name: flutter-verify
description: Quy trình verify code Flutter/Dart trước khi commit (analyze, format, test, build_runner)
---

# Flutter Verify Skill

Quy trình bắt buộc để xác nhận code Dart/Flutter hợp lệ trước khi commit, tránh lỗi trên CI và giữ chất lượng code.

## Thứ tự thực thi

### 1. Code Generation (nếu đổi model Isar)

Khi thêm/sửa model có `@collection` (Isar) hoặc `@JsonSerializable`:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Bắt buộc chạy khi đổi schema, nếu không các file `.g.dart` sẽ thiếu/lỗi thời.

### 2. Format code

```bash
dart format lib/ test/
```

Đảm bảo đúng style chuẩn, tránh fail trên `flutter analyze` vì formatting.

### 3. Analyze (bắt buộc)

```bash
flutter analyze
```

**Quy tắc:** Mọi lỗi `error •` bắt buộc phải sửa triệt để trước khi commit. Không dùng `// ignore:` để né lỗi mà không có lý do chính đáng.

### 4. Test (bắt buộc nếu có test liên quan)

```bash
flutter test
```

Chạy toàn bộ test, hoặc giới hạn vào feature đã sửa:

```bash
flutter test test/features/orders/
```

Nếu code sửa có test liên quan → chạy test đó. Nếu không có test → nên cân nhắc thêm test cho logic nghiệp vụ mới.

## Checklist trước khi commit

- [ ] `dart run build_runner build --delete-conflicting-outputs` (nếu đổi model)
- [ ] `dart format lib/ test/`
- [ ] `flutter analyze` — 0 lỗi error
- [ ] `flutter test` — tất cả pass
- [ ] REVIEW workflow (`.opencode/agent/reviewer.md`) — không có BLOCKER/HIGH

## Lưu ý

- Trong môi trường không có Flutter SDK, dùng `flutter analyze`/`flutter test` khi môi trường cho phép; nếu không, báo User về giới hạn.
- Không commit code khi `flutter analyze` còn lỗi `error •` — trừ khi được User yêu cầu rõ ràng và có lý do.
- Nếu lệnh bị chặn vì quyền (permission), gom các lệnh verify vào một lần thực thi duy nhất.
