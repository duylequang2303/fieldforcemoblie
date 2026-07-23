import 'package:permission_handler/permission_handler.dart';

/// Service xin quyền truy cập Camera, Location, Biometrics.
/// Gọi các hàm này trước khi dùng tính năng tương ứng.
class PermissionService {
  PermissionService._();
  static final PermissionService instance = PermissionService._();

  /// Xin quyền Camera (dùng cho quét barcode và chụp ảnh nghiệm thu).
  Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Xin quyền Location (dùng cho GPS tracking).
  Future<bool> requestLocation() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  /// Xin quyền Location luôn bật (khi cần tracking nền - tuỳ chọn).
  Future<bool> requestLocationAlways() async {
    final status = await Permission.locationAlways.request();
    return status.isGranted;
  }

  /// Kiểm tra quyền Camera hiện tại mà không xin.
  Future<bool> get isCameraGranted async =>
      (await Permission.camera.status).isGranted;

  /// Kiểm tra quyền Location hiện tại.
  Future<bool> get isLocationGranted async =>
      (await Permission.locationWhenInUse.status).isGranted;

  /// Hiển thị dialog hướng dẫn vào Settings nếu user từ chối vĩnh viễn.
  Future<void> openAppSettings() => openAppSettings();
}
