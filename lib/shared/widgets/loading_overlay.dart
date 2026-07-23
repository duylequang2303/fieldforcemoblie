import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../core/theme/app_colors.dart';

/// Overlay toàn màn hình hiển thị loading spinner.
/// Sử dụng khi đang gọi API hoặc thực hiện tác vụ nặng.
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key, this.message});

  /// Thông báo hiển thị bên dưới spinner (tuỳ chọn).
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.4),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SpinKitFadingCircle(
              color: AppColors.primaryLight,
              size: 52,
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Mixin tiện ích: bọc một widget với loading overlay khi [isLoading] = true.
class LoadingStack extends StatelessWidget {
  const LoadingStack({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  final bool isLoading;
  final Widget child;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading) LoadingOverlay(message: message),
      ],
    );
  }
}
