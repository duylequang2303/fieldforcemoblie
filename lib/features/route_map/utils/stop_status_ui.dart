import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/route_stop.dart';

class StopStatusUI {
  static Color color(StopStatus status) => switch (status) {
    StopStatus.pending => AppColors.onSurfaceMuted,
    StopStatus.current => AppColors.info,
    StopStatus.completed => AppColors.success,
    StopStatus.skipped => AppColors.warning,
  };

  static String label(StopStatus status) => switch (status) {
    StopStatus.pending => 'Sắp tới',
    StopStatus.current => 'Đang làm',
    StopStatus.completed => 'Đã hoàn thành',
    StopStatus.skipped => 'Bỏ qua',
  };
}
