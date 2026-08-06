import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/fsm_order.dart';

/// Chip hiển thị trạng thái (stage) của một đơn dịch vụ.
class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({super.key, required this.stage, this.isSkipped = false});

  final FsmOrderStage stage;
  final bool isSkipped;

  @override
  Widget build(BuildContext context) {
    final bgColor = _getBgColor(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.15),
        border: Border.all(color: bgColor, width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 12, color: bgColor),
          const SizedBox(width: 4),
          Text(
            _label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: bgColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBgColor(BuildContext context) {
    if (isSkipped) {
      return Theme.of(context).colorScheme.outline;
    }
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
    if (isSkipped) {
      return Icons.next_plan_outlined;
    }
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
    if (isSkipped) {
      return 'Đã bỏ qua';
    }
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
