import 'package:flutter/material.dart';
import '../features/orders/models/fsm_order.dart';

class ScheduleCard extends StatelessWidget {
  final FsmOrder order;
  final VoidCallback onTap;
  final VoidCallback onChatTap;

  const ScheduleCard({
    super.key,
    required this.order,
    required this.onTap,
    required this.onChatTap,
  });

  String _formatTime(DateTime? date) {
    if (date == null) return '--:--';
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _calculateDurationBadge(DateTime? start, DateTime? end) {
    if (start == null || end == null) return '2 hrs'; // Mock fallback
    final diff = end.difference(start);
    return '${diff.inHours} hrs';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias, // Để bo góc cắt luôn cả border bên trong
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left border (4px, primary green)
              Container(
                width: 4,
                color: theme.colorScheme.primary,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Address (bold, 16sp, black) & Duration Badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              order.locationAddress ?? order.name,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Duration badge (right side)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceVariant ?? Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _calculateDurationBadge(order.scheduledDateStart, order.scheduledDateEnd),
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Customer info (14sp, gray)
                      Text(
                        order.partnerName ?? 'Khách hàng ẩn',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Due date and Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Due date (12sp, gray) - (Không dùng italic theo chuẩn Hallmark)
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: theme.colorScheme.onSurface.withOpacity(0.5),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_formatTime(order.scheduledDateStart)} - ${_formatTime(order.scheduledDateEnd)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                          // Actions, right aligned
                          Row(
                            children: [
                              if (order.isPendingSync) ...[
                                Icon(
                                  Icons.sync,
                                  size: 20,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                              ],
                              GestureDetector(
                                onTap: onChatTap,
                                child: Icon(
                                  Icons.chat_bubble_outline,
                                  size: 20,
                                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ],
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
}
