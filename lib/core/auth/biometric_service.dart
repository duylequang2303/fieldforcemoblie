import 'package:local_auth/local_auth.dart';

/// Service xử lý xác thực sinh trắc học: FaceID hoặc Vân tay.
class BiometricService {
  BiometricService._();
  static final BiometricService instance = BiometricService._();

  final LocalAuthentication _auth = LocalAuthentication();

  /// Kiểm tra thiết bị có hỗ trợ biometric không.
  Future<bool> get isAvailable async {
    try {
      return await _auth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  /// Lấy danh sách loại biometric thiết bị hỗ trợ.
  Future<List<BiometricType>> get availableTypes async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  /// Thực hiện xác thực sinh trắc học.
  /// Trả về [true] nếu xác thực thành công.
  Future<bool> authenticate() async {
    try {
      final available = await isAvailable;
      if (!available) return false;

      return await _auth.authenticate(
        localizedReason: 'Xác thực để đăng nhập Fieldforce Worker',
        options: const AuthenticationOptions(
          biometricOnly: false, // Cho phép dùng PIN nếu biometric fail
          stickyAuth: true,     // Giữ auth dialog khi app chuyển nền
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
