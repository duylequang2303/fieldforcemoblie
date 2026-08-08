import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import '../utils/logger.dart';
import 'secure_storage.dart';

/// Exception để handle biometric lockout ở UI layer
class BiometricLockoutException implements Exception {
  final bool isPermanent;
  final String message;

  const BiometricLockoutException._({required this.isPermanent, required this.message});

  factory BiometricLockoutException.permanent() => const BiometricLockoutException._(
    isPermanent: true,
    message: 'Biometric bị khóa vĩnh viễn. Vui lòng dùng mật khẩu để đăng nhập.',
  );

  factory BiometricLockoutException.temporary() => const BiometricLockoutException._(
    isPermanent: false,
    message: 'Biometric tạm thời bị khóa. Vui lòng thử lại sau giây lát.',
  );
}

/// Exception khi cấu hình sinh trắc học trên thiết bị thay đổi (A04)
class BiometricCredentialsInvalidatedException implements Exception {
  final String message = 'Xác thực sinh trắc học trên thiết bị đã thay đổi. Vui lòng sử dụng mật khẩu đăng nhập để thiết lập lại.';
  const BiometricCredentialsInvalidatedException();
}

/// Service xử lý xác thực sinh trắc học: FaceID hoặc Vân tay.
class BiometricService {
  BiometricService._();
  static final BiometricService instance = BiometricService._();

  final LocalAuthentication _auth = LocalAuthentication();

  /// Kiểm tra thiết bị có hỗ trợ biometric không.
  Future<bool> get isAvailable async {
    try {
      return await _auth.canCheckBiometrics;
    } catch (e, stack) {
      logger.w('Biometric availability check failed',
          error: e, stackTrace: stack);
      return false;
    }
  }

  /// Lấy danh sách loại biometric thiết bị hỗ trợ.
  Future<List<BiometricType>> get availableTypes async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e, stack) {
      logger.w('Failed to read available biometric types',
          error: e, stackTrace: stack);
      return [];
    }
  }

  /// Thực hiện xác thực sinh trắc học.
  /// Trả về [true] nếu xác thực thành công.
  /// Ném [BiometricLockoutException] nếu bị khóa vĩnh viễn.
  Future<bool> authenticate() async {
    try {
      final available = await isAvailable;
      if (!available) return false;

      return await _auth.authenticate(
        localizedReason: 'Xác thực để đăng nhập Fieldforce Worker',
        options: const AuthenticationOptions(
          biometricOnly: true,   // fix: CHỈ cho phép biometric, không fallback PIN
          stickyAuth: false,     // fix: Không giữ dialog khi app background
        ),
      );
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'PermanentlyLockedOut':
          logger.e('Biometric permanently locked out');
          // Auto-disable biometric login trong app
          await SecureStorageService.instance.setBiometricEnabled(enabled: false);
          throw BiometricLockoutException.permanent();
        case 'LockedOut':
          logger.w('Biometric temporarily locked out');
          throw BiometricLockoutException.temporary();
        case 'KeyPermanentlyInvalidated':
          logger.e('Biometric credentials invalidated due to device changes');
          // Tự động tắt tính năng và yêu cầu login bằng pass
          await SecureStorageService.instance.setBiometricEnabled(enabled: false);
          throw const BiometricCredentialsInvalidatedException();
        case 'UserFallback':
          logger.i('User chose fallback (PIN/Pattern)');
          // Không throw - coi như user cancel
          return false;
        case 'UserCancel':
          logger.i('User cancelled biometric');
          return false;
        default:
          logger.e('Biometric auth error', error: e);
          return false;
      }
    } catch (e, stack) {
      logger.e('Biometric auth unexpected error', error: e, stackTrace: stack);
      return false;
    }
  }
}
