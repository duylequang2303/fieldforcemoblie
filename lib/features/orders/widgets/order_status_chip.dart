import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/fsm_order.dart';

/// Chip hiển thị trạng thái (stage) của một đơn dịch vụ.
class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({super.key, required this.stage});

  final FsmOrderStage stage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor.withValues(alpha: 0.15),
        border: Border.all(color: _bgColor, width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 12, color: _bgColor),
          const SizedBox(width: 4),
          Text(
            _label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _bgColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Color get _bgColor {
    switch (stage) {
      case FsmOrderStage.draft:
        return AppColors.stageNew;
      case FsmOrderStage.inProgress:
        return AppColors.stageInProgress;
      case FsmOrderStage.done:
        return AppColors.stageDone;
      case FsmOrderStage.cancelled:
        return AppColors.stageCancelled;
    }
  }

  IconData get _icon {
    switch (stage) {
      case FsmOrderStage.draft:
        return Icons.schedule_outlined;
      case FsmOrderStage.inProgress:
        return Icons.play_circle_outline;
      case FsmOrderStage.done:
        return Icons.check_circle_outline;
      case FsmOrderStage.cancelled:
        return Icons.cancel_outlined;
    }
  }

  String get _label {
    switch (stage) {
      case FsmOrderStage.draft:
        return 'Mới';
      case FsmOrderStage.inProgress:
        return 'Đang thực hiện';
      case FsmOrderStage.done:
        return 'Hoàn thành';
      case FsmOrderStage.cancelled:
        return 'Đã huỷ';
    }
  }
}
