import 'package:isar_community/isar.dart';

part 'user_session.g.dart';

/// Model lưu thông tin session đăng nhập vào Isar DB.
/// Dùng để restore session sau khi app restart.
@collection
class UserSession {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String serverUrl;

  late String database;
  late String username;
  late String sessionId;
  late int userId;
  late DateTime loginAt;

  /// Tên hiển thị của user (lấy từ Odoo sau khi login).
  String? displayName;
}
