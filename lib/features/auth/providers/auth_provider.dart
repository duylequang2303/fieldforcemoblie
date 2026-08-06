import 'package:flutter/material.dart';
import 'dart:async';
import '../../../core/auth/auth_service.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/api/odoo_session_manager.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

/// Provider quản lý trạng thái xác thực toàn app.
class AuthProvider extends ChangeNotifier {
  static final AuthProvider instance = AuthProvider._internal();
  AuthProvider._internal();

  final _authService = AuthService.instance;
  final _sessionManager = OdooSessionManager.instance;
  StreamSubscription<void>? _sessionExpiredSubscription;

  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  bool _isBiometricAvailable = false;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isBiometricAvailable => _isBiometricAvailable;

  Future<void> initialize() async {
    _isBiometricAvailable = await _authService.isBiometricAvailable;
    notifyListeners();

    // Subscribe TRƯỚC khi restore để không bỏ sót session expiry event
    // nếu syncAfterAuth() phát hiện session expired ngay trong lúc restore
    // (Fix CodeRabbit PR#34 Thread #14)
    _sessionExpiredSubscription = _sessionManager.onSessionExpired.listen((_) {
      if (_status == AuthStatus.authenticated) {
        _status = AuthStatus.unauthenticated;
        _errorMessage = 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
        notifyListeners();
      }
    });

    // Thử restore session khi app khởi động
    final restored = await _authService.tryRestoreSession();
    // Sau restore, kiểm tra lại isAuthenticated vì listener có thể đã
    // set unauthenticated nếu session expired ngay trong quá trình restore
    _status = (restored && _sessionManager.isAuthenticated)
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> login({
    required String serverUrl,
    required String database,
    required String username,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.login(
        serverUrl: serverUrl,
        database: database,
        username: username,
        password: password,
      );
      _status = AuthStatus.authenticated;
    } on OdooAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.message;
    } on OdooConnectionException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.message;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Đã xảy ra lỗi không mong muốn.';
    }
    notifyListeners();
  }

  Future<void> loginWithBiometric() async {
    _status = AuthStatus.loading;
    notifyListeners();

    final success = await _authService.loginWithBiometric();
    _status = success ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    if (!success) _errorMessage = 'Xác thực sinh trắc học thất bại.';
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _sessionExpiredSubscription?.cancel();
    super.dispose();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
