import 'package:connectivity_plus/connectivity_plus.dart';

/// Service giám sát trạng thái mạng (online/offline).
/// Sử dụng [Connectivity.onConnectivityChanged] để lắng nghe thay đổi.
class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  final Connectivity _connectivity = Connectivity();

  /// Stream bool: true = online, false = offline.
  Stream<bool> get onStatusChanged => _connectivity.onConnectivityChanged
      .map((results) => _isConnected(results));

  /// Stream gốc từ connectivity_plus.
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  /// Kiểm tra trạng thái mạng ngay lập tức. Trả về true nếu online.
  Future<bool> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    return _isConnected(results);
  }

  /// Deprecated helper — dùng checkConnectivity() thay thế.
  Future<bool> get isOnline async => checkConnectivity();

  bool _isConnected(List<ConnectivityResult> results) {
    return results.any((r) =>
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.ethernet);
  }
}
