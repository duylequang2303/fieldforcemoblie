import 'package:connectivity_plus/connectivity_plus.dart';

/// Service giám sát trạng thái mạng (online/offline).
class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  final Connectivity _connectivity = Connectivity();

  Stream<bool> get onStatusChanged => _connectivity.onConnectivityChanged
      .map((results) => _isConnected(results));

  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  Future<bool> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    return _isConnected(results);
  }

  /// Kết nối hiện tại có phải WiFi không — dùng cho tuỳ chọn "chỉ đồng bộ qua WiFi".
  Future<bool> checkIsWifi() async {
    final results = await _connectivity.checkConnectivity();
    return results.contains(ConnectivityResult.wifi);
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
