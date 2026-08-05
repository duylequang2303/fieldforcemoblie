import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../models/fsm_order.dart';
import 'order_status_chip.dart';
import 'recurring_badge.dart';
import 'package:go_router/go_router.dart';

/// Card hiển thị thông tin tóm tắt của một đơn dịch vụ trong danh sách.
class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order});

  final FsmOrder order;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shadowColor: AppColors.primary.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: order.isPendingSync
            ? const BorderSide(color: AppColors.warning, width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push(
          RouteNames.orderDetail.replaceFirst(':id', '${order.odooId}'),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: mã đơn + chip trạng thái
              Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            order.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: AppColors.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (order.recurringId != null && order.recurringId! > 0) ...[
                          const SizedBox(width: 6),
                          RecurringBadge(recurringId: order.recurringId!),
                        ],
                      ],
                    ),
                  ),
                  OrderStatusChip(stage: order.stage, isSkipped: order.isSkipped),
                ],
              ),

              if (order.isPendingSync) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.sync_problem,
                        size: 13, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Text(
                      'Chưa đồng bộ',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.warning,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 10),
              const Divider(height: 1, color: AppColors.surfaceVariant),
              const SizedBox(height: 10),

              // Khách hàng
              if (order.partnerName != null && order.partnerName!.isNotEmpty)
                _InfoRow(
                  icon: Icons.person_outline,
                  text: order.partnerName!,
                ),

              // Địa điểm
              if (order.locationName != null && order.locationName!.isNotEmpty)
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  text: order.locationAddress ?? order.locationName!,
                ),

              // Lịch hẹn
              if (order.scheduledDateStart != null)
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  text: _formatDate(order.scheduledDateStart!),
                ),

              // SĐT nhanh
              if (order.partnerPhone != null && order.partnerPhone!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: GestureDetector(
                    onTap: () {}, // launch phone dialer
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.phone_outlined,
                            size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          order.partnerPhone!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return DateFormat('dd/MM/yyyy HH:mm', 'vi').format(dt.toLocal());
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: AppColors.onSurfaceMuted),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.onSurfaceMuted,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
