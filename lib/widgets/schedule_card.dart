import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../features/orders/models/fsm_order.dart';
import '../core/utils/formatters.dart';

class ScheduleCard extends StatelessWidget {
  final FsmOrder order;
  final VoidCallback onTap;
  final VoidCallback? onChatTap;
  final VoidCallback? onCallTap;
  final VoidCallback? onDirectionsTap;

  const ScheduleCard({
    super.key,
    required this.order,
    required this.onTap,
    this.onChatTap,
    this.onCallTap,
    this.onDirectionsTap,
  });

  String _formatTime(DateTime? date) {
    if (date == null) return '--:--';
    return AppDateFormat.time(date);
  }

  String _calculateDurationBadge(DateTime? start, DateTime? end) {
    if (start == null || end == null) return '-- hrs';
    final diff = end.difference(start);
    return '${diff.inHours} hrs';
  }

  Future<void> _launch(Uri uri, String errorMsg) async {
    try {
      final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!success) {
        debugPrint('$errorMsg: launchUrl returned false for $uri');
      }
    } on PlatformException catch (e) {
      debugPrint('$errorMsg: $e');
    } catch (e) {
      debugPrint('$errorMsg: unexpected error $e');
    }
  }

  void _handleCall() {
    final phone = order.partnerPhone;
    if (phone == null || phone.isEmpty) return;
    _launch(Uri(scheme: 'tel', path: phone), 'Cannot open Phone');
  }

  void _handleDirections() {
    final lat = order.locationLat;
    final lng = order.locationLng;
    if (lat == null || lng == null) return;
    _launch(
      Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng'),
      'Cannot open Maps',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasActions = onCallTap != null ||
        onDirectionsTap != null;

    return Card(
      key: Key('schedule_card_${order.odooId}'),
      clipBehavior: Clip.antiAlias,
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _calculateDurationBadge(
                                  order.scheduledDateStart,
                                  order.scheduledDateEnd),
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.8),
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
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Due date and Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Due date (12sp, gray)
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_formatTime(order.scheduledDateStart)} - ${_formatTime(order.scheduledDateEnd)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
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
                                const SizedBox(width: 8),
                              ],
                              if (hasActions) ...[
                                _ActionIcon(
                                  icon: Icons.phone_outlined,
                                  color: theme.colorScheme.primary,
                                  onTap: onCallTap ?? _handleCall,
                                ),
                                const SizedBox(width: 4),
                                _ActionIcon(
                                  icon: Icons.chat_bubble_outline,
                                  color: theme.colorScheme.primary,
                                  onTap: onChatTap ?? () {},
                                ),
                                const SizedBox(width: 4),
                                _ActionIcon(
                                  icon: Icons.directions_outlined,
                                  color: theme.colorScheme.primary,
                                  onTap: onDirectionsTap ?? _handleDirections,
                                ),
                              ] else if (onChatTap != null) ...[
                                GestureDetector(
                                  onTap: onChatTap,
                                  child: Icon(
                                    Icons.chat_bubble_outline,
                                    size: 20,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
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

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
