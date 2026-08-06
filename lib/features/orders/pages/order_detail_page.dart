import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../models/fsm_order.dart';
import '../providers/orders_provider.dart';
import '../widgets/recurring_badge.dart';
import '../../route_map/providers/route_provider.dart';
import '../../work_order/providers/work_order_provider.dart';
import '../widgets/order_status_chip.dart';

/// Strip HTML tags khỏi chuỗi text trả về từ Odoo (VD: <p>...</p>).
String _stripHtml(String html) {
  // Strip HTML tags and decode common entities
  final withoutTags = html.replaceAll(RegExp(r'<[^>]*>'), '');
  return withoutTags
      .replaceAll(RegExp(r'&[a-z]+;'), ' ')
      .replaceAll(RegExp(r'&#[0-9]+;'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

/// Trang chi tiết một đơn dịch vụ.
/// orderId: ID Odoo của đơn (truyền qua go_router path param).
class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key, required this.orderId});

  final int orderId;

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<OrdersProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Scaffold(
            body: LoadingOverlay(message: 'Đang tải...'),
          );
        }

        final order = provider.orders
            .where((o) => o.odooId == widget.orderId)
            .firstOrNull;

        if (order == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Chi tiết đơn')),
            body: ErrorView(
              message: 'Không tìm thấy đơn dịch vụ #${widget.orderId}',
              onRetry: () => context.pop(),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  _buildAppBar(context, order),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        if (provider.errorMessage != null &&
                            !provider.isOffline)
                          ErrorView(
                            message: provider.errorMessage!,
                            onRetry: provider.clearError,
                          ),
                        _buildInfoCard(order),
                        _buildScheduleCard(order),
                        _buildActionsCard(context, provider, order),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ],
              ),
              if (provider.isOffline) const OfflineBanner(),
            ],
          ),
          bottomNavigationBar: _buildBottomActions(context, provider, order),
        );
      },
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, FsmOrder order) {
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.accentDark,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.white),
          onPressed: () {
            // TODO: Edit action
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 56, right: 56, bottom: 16),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OrderStatusChip(stage: order.stage, isSkipped: order.isSkipped),
                if (order.recurringId != null && order.recurringId! > 0)
                  RecurringBadge(recurringId: order.recurringId!, showText: true),
              ],
            ),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.accentDark, AppColors.accent],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(FsmOrder order) {
    return _SectionCard(
      title: 'THÔNG TIN ĐƠN',
      icon: Icons.assignment_outlined,
      children: [
        if (order.partnerName != null && order.partnerName!.isNotEmpty) ...[
          _CustomerRow(
            name: order.partnerName!,
            phone: order.partnerPhone,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
        ],
        if (order.locationName != null && order.locationName!.isNotEmpty) ...[
          _DetailRow(
            label: 'ĐỊA ĐIỂM',
            value: order.locationAddress ?? order.locationName!,
            icon: Icons.location_on_outlined,
            iconColor: AppColors.error,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
        ],
        if (order.personName != null && order.personName!.isNotEmpty) ...[
          _DetailRow(
            label: 'KỸ THUẬT VIÊN',
            value: order.personName!,
            icon: Icons.engineering_outlined,
            iconColor: AppColors.info,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
        ],
        if (order.description != null && order.description!.isNotEmpty)
          _DetailRow(
            label: 'MÔ TẢ CÔNG VIỆC',
            value: _stripHtml(order.description!),
            icon: Icons.notes_outlined,
            iconColor: AppColors.warning,
          ),
      ],
    );
  }

  Widget _buildScheduleCard(FsmOrder order) {
    return _SectionCard(
      title: 'LỊCH HẸN & THỜI GIAN',
      icon: Icons.schedule_outlined,
      children: [
        if (order.scheduledDateStart != null) ...[
          _DetailRow(
            label: 'BẮT ĐẦU DỰ KIẾN',
            value: _fmt(order.scheduledDateStart!),
            icon: Icons.calendar_today_outlined,
            iconColor: AppColors.info,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
        ],
        if (order.scheduledDateEnd != null) ...[
          _DetailRow(
            label: 'KẾT THÚC DỰ KIẾN',
            value: _fmt(order.scheduledDateEnd!),
            icon: Icons.event_outlined,
            iconColor: AppColors.info,
          ),
          if (order.dateStart != null)
            const Divider(height: 1, indent: 16, endIndent: 16),
        ],
        if (order.dateStart != null)
          _DetailRow(
            label: 'CHECK-IN THỰC TẾ',
            value: _fmt(order.dateStart!),
            icon: Icons.login_outlined,
            iconColor: AppColors.success,
            highlight: true,
            trailing: order.isPendingSync
                ? const Tooltip(
                    message: 'Đang chờ đồng bộ lên Odoo',
                    child: Icon(Icons.sync_problem,
                        color: AppColors.warning, size: 18),
                  )
                : null,
          ),
      ],
    );
  }

  Widget _buildActionsCard(
      Widget _buildRelatedActions(
      BuildContext context, OrdersProvider provider, FsmOrder order) {
    final isClosed = order.stage == FsmOrderStage.done ||
        order.stage == FsmOrderStage.cancelled ||
        order.isSkipped ||
        order.isRecurringProcessed;
    final theme = Theme.of(context);

    return _SectionCard(
      title: 'CÔNG VIỆC LIÊN QUAN',
      icon: Icons.work_outline,
      children: [
        _ActionTile(
          icon: Icons.map_outlined,
          label: 'Xem bản đồ tuyến đường',
          subtitle: 'Xem vị trí và chỉ đường',
          onTap: () => context.push(RouteNames.routeMap),
          color: theme.colorScheme.secondary,
        ),
        const Divider(height: 1, indent: 68),
        _ActionTile(
          icon: Icons.qr_code_scanner_outlined,
          label: 'Quét vật tư / Stock',
          subtitle: isClosed
              ? 'Đơn đã đóng/bỏ qua - Không thể thực hiện'
              : 'Quản lý vật tư và thiết bị',
          onTap: isClosed
              ? null
              : () => context.push(
                    RouteNames.stockMoves.replaceFirst(':orderId', '${order.odooId}'),
                  ),
          color: theme.colorScheme.tertiary,
        ),
        const Divider(height: 1, indent: 68),
        _ActionTile(
          icon: Icons.access_time_outlined,
          label: 'Ghi nhận giờ công',
          subtitle: isClosed
              ? 'Đơn đã đóng/bỏ qua - Không thể thực hiện'
              : 'Thêm timesheet cho đơn',
          onTap: isClosed
              ? null
              : () => context.push(
                    RouteNames.timesheet.replaceFirst(':orderId', '${order.odooId}'),
                  ),
          color: theme.colorScheme.secondary,
        ),
        const Divider(height: 1, indent: 68),
        _ActionTile(
          icon: Icons.receipt_long_outlined,
          label: 'Thêm khoản chi',
          subtitle: isClosed
              ? 'Đơn đã đóng/bỏ qua - Không thể thực hiện'
              : 'Ghi nhận chi phí phát sinh',
          onTap: isClosed
              ? null
              : () => context.push(
                    RouteNames.expense.replaceFirst(':orderId', '${order.odooId}'),
                  ),
          color: theme.colorScheme.error,
        ),
        const Divider(height: 1, indent: 68),
        _ActionTile(
          icon: Icons.fact_check_outlined,
          label: 'Nghiệm thu & Chữ ký',
          subtitle: isClosed
              ? 'Đơn đã đóng/bỏ qua - Không thể thực hiện'
              : 'Hoàn tất và ký xác nhận',
          onTap: isClosed
              ? null
              : () => context.push(
                    RouteNames.workOrder.replaceFirst(':orderId', '${order.odooId}'),
                  ),
          color: theme.colorScheme.primary,
          highlight: !isClosed,
        ),
        if (order.isRecurringInstance && !isClosed && !order.isRecurringProcessed) ...[
          const Divider(height: 1, indent: 68),
          _ActionTile(
            icon: Icons.skip_next_outlined,
            label: 'Bỏ qua kỳ này (Skip)',
            subtitle: 'Bỏ qua lần định kỳ này và lên lịch kỳ sau',
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Xác nhận bỏ qua'),
                  content: const Text(
                      'Bạn có chắc chắn muốn bỏ qua kỳ thực hiện dịch vụ định kỳ này không?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Hủy'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Đồng ý'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                final success = await provider.skipOccurrence(order);
                if (context.mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Đã đánh dấu bỏ qua kỳ định kỳ này.')),
                    );
                    context.pop(); // Quay lại trang trước
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(provider.errorMessage ?? 'Không thể bỏ qua kỳ định kỳ này.'),
                        backgroundColor: theme.colorScheme.error,
                      ),
                    );
                  }
                }
              }
            },
            color: theme.colorScheme.error,
          ),
        ],
      ],
    );
  }

  Future<bool> _ensureRouteSequence(
      BuildContext context, OrdersProvider provider, FsmOrder order) async {
    final routeProvider = context.read<RouteProvider>();
    if (routeProvider.stops.isEmpty) {
      await routeProvider.buildRoute(provider.orders);
    }
    if (!routeProvider.isAllowedToCheckIn(order.odooId)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Bạn phải hoàn thành các điểm trước trong lộ trình trước.'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
      return false;
    }
    return true;
  }

  Widget _buildBottomActions(
      BuildContext context, OrdersProvider provider, FsmOrder order) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            if (order.stage == FsmOrderStage.done ||
                order.stage == FsmOrderStage.cancelled ||
                order.isSkipped ||
                order.isRecurringProcessed)
              Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        (order.isSkipped || order.isRecurringProcessed && order.stage == FsmOrderStage.cancelled)
                            ? Icons.next_plan_outlined
                            : (order.stage == FsmOrderStage.done
                                ? Icons.check_circle
                                : Icons.cancel),
                        size: 22,
                        color: order.stage == FsmOrderStage.done
                            ? AppColors.success
                            : Colors.grey,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        (order.isSkipped || order.isRecurringProcessed && order.stage == FsmOrderStage.cancelled)
                            ? 'Đã bỏ qua'
                            : (order.stage == FsmOrderStage.done
                                ? 'Đã hoàn thành'
                                : 'Đã huỷ'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: order.stage == FsmOrderStage.done
                              ? AppColors.success
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (order.dateStart == null)
              // Nút Check-in
              Expanded(
                child: ElevatedButton(
                  key: const Key('btn_check_in'),
                  onPressed: provider.isLoading
                      ? null
                      : () async {
                          if (!await _ensureRouteSequence(
                              context, provider, order)) return;

                          await provider.checkIn(order.odooId);
                          await context
                              .read<RouteProvider>()
                              .buildRoute(provider.orders);

                          if (context.mounted) {
                            if (provider.errorMessage == null) {
                              final statusText = provider.isOffline
                                  ? 'Check-in thành công! (Ngoại tuyến, sẽ đồng bộ sau)'
                                  : 'Check-in thành công!';
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(statusText),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(provider.errorMessage!),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.login, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Check-in',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (order.stage == FsmOrderStage.draft)
              // Nút Bắt đầu thực hiện
              Expanded(
                child: ElevatedButton(
                  onPressed: provider.isLoading
                      ? null
                      : () async {
                          if (!await _ensureRouteSequence(
                              context, provider, order)) return;
                          await provider.updateOrderToInProgress(order.odooId);
                          await context
                              .read<RouteProvider>()
                              .buildRoute(provider.orders);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.info,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.play_circle, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Bắt đầu thực hiện',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              // Nút Hoàn thành
              Expanded(
                child: ElevatedButton(
                  key: const Key('btn_mark_complete'),
                  onPressed: provider.isLoading
                      ? null
                      : () async {
                          if (!await _ensureRouteSequence(
                              context, provider, order)) return;
                          _confirmComplete(context, provider, order);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.check_circle, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Hoàn thành',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmComplete(
    BuildContext context,
    OrdersProvider provider,
    FsmOrder order,
  ) async {
    if (order.requireSignature) {
      final workOrderProvider = context.read<WorkOrderProvider>();

      if (workOrderProvider.report?.orderOdooId != order.odooId) {
        await workOrderProvider.loadReport(order.odooId);
      }

      final bool isSigned =
          workOrderProvider.report?.customerSignaturePath != null &&
              workOrderProvider.report!.customerSignaturePath!.isNotEmpty;

      if (!isSigned && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            key: Key('snackbar_require_signature'),
            content: Text('Vui lòng ký xác nhận trước khi hoàn thành'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận hoàn thành'),
        content: Text('Đánh dấu đơn ${order.name} là hoàn thành?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await provider.updateOrderToDone(order.odooId);
      await context.read<RouteProvider>().buildRoute(provider.orders);
    }
  }

  String _fmt(DateTime dt) =>
      DateFormat('dd/MM/yyyy HH:mm', 'vi').format(dt.toLocal());
}

// ── Sub-widgets ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.accentMuted,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: AppColors.accent),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppColors.onSurfaceMuted,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
    this.isAction = false,
    this.highlight = false,
    this.trailing,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final bool isAction;
  final bool highlight;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.onSurfaceMuted).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: iconColor ?? AppColors.onSurfaceMuted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceMuted,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: highlight ? AppColors.accent : AppColors.onSurface,
                    fontWeight: highlight ? FontWeight.w600 : FontWeight.w400,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    this.subtitle,
    this.onTap,
    this.color,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? color;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fallbackColor = highlight ? theme.colorScheme.primary : theme.colorScheme.secondary;
    final effectiveColor = onTap == null ? theme.colorScheme.outline : (color ?? fallbackColor);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: effectiveColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 22,
                color: effectiveColor,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: highlight ? FontWeight.w700 : FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.onSurfaceMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.onSurfaceMuted,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

// Customer row with quick action buttons (SortScape style)
class _CustomerRow extends StatelessWidget {
  const _CustomerRow({
    required this.name,
    this.phone,
  });

  final String name;
  final String? phone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'KHÁCH HÀNG',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceMuted,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                if (phone != null && phone!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    phone!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurfaceMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Quick action buttons
          if (phone != null && phone!.isNotEmpty) ...[
            _QuickContactButton(
              icon: Icons.phone,
              color: AppColors.accent,
              onTap: () {
                // TODO: Launch phone call
              },
            ),
            const SizedBox(width: 8),
            _QuickContactButton(
              icon: Icons.message_outlined,
              color: AppColors.info,
              onTap: () {
                // TODO: Launch SMS
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickContactButton extends StatelessWidget {
  const _QuickContactButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}
