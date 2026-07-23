import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../core/connectivity/connectivity_service.dart';

/// Banner hiển thị ở đầu màn hình khi thiết bị đang offline.
/// Có thể dùng như Wrapper bọc `child` hoặc đặt độc lập ở trên cùng UI.
class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key, this.child});

  final Widget? child;

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  final _connectivity = ConnectivityService.instance;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _checkInitial();
    _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
  }

  Future<void> _checkInitial() async {
    final online = await _connectivity.checkConnectivity();
    if (mounted) setState(() => _isOffline = !online);
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) async {
    final online = await _connectivity.checkConnectivity();
    if (mounted) setState(() => _isOffline = !online);
  }

  @override
  Widget build(BuildContext context) {
    final bannerWidget = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isOffline ? 36 : 0,
      color: AppColors.offlineBanner,
      child: _isOffline
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text(
                  'Không có kết nối mạng — Đang dùng dữ liệu offline',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            )
          : const SizedBox.shrink(),
    );

    if (widget.child == null) {
      return SafeArea(child: bannerWidget);
    }

    return Column(
      children: [
        bannerWidget,
        Expanded(child: widget.child!),
      ],
    );
  }
}
