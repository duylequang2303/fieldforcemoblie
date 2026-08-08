import 'package:flutter/material.dart';

/// Helper hiển thị SnackBar dùng chung, thay cho việc lặp lại
/// `ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(...)))`
/// ở từng page/widget.
extension AppSnackBar on BuildContext {
  /// Hiển thị SnackBar với nội dung [message].
  ///
  /// [backgroundColor] để nhấn trạng thái (thành công/cảnh báo), bỏ trống thì
  /// dùng màu mặc định của theme.
  void showSnackBarMessage(
    String message, {
    Color? backgroundColor,
    SnackBarBehavior? behavior,
    Duration? duration,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: behavior,
        duration: duration ?? const Duration(seconds: 4),
      ),
    );
  }

  /// Hiển thị SnackBar lỗi với màu `colorScheme.error`.
  void showErrorSnackBar(String message, {SnackBarBehavior? behavior}) {
    showSnackBarMessage(
      message,
      backgroundColor: Theme.of(this).colorScheme.error,
      behavior: behavior,
    );
  }
}
