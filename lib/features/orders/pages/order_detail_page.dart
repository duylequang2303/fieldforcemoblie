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

        final order = provider.orders.where((o) => o.odooId == widget.orderId).firstOrNull;

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
                        if (provider.errorMessage != null && !provider.isOffline)
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
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            OrderStatusChip(stage: order.stage),
          ],
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryDark, AppColors.primaryLight],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(FsmOrder order) {
    return _SectionCard(
      title: 'Thông tin đơn',
      icon: Icons.assignment_outlined,
      children: [
        if (order.partnerName != null && order.partnerName!.isNotEmpty)
          _DetailRow(
            label: 'Khách hàng',
            value: order.partnerName!,
            icon: Icons.person_outline,
          ),
        if (order.partnerPhone != null && order.partnerPhone!.isNotEmpty)
          _DetailRow(
            label: 'Điện thoại',
            value: order.partnerPhone!,
            icon: Icons.phone_outlined,
            isAction: true,
          ),
        if (order.locationName != null && order.locationName!.isNotEmpty)
          _DetailRow(
            label: 'Địa điểm',
            value: order.locationAddress ?? order.locationName!,
            icon: Icons.location_on_outlined,
          ),
        if (order.description != null && order.description!.isNotEmpty)
          _DetailRow(
            label: 'Mô tả',
            value: _stripHtml(order.description!),
            icon: Icons.notes_outlined,
          ),
        if (order.personName != null && order.personName!.isNotEmpty)
          _DetailRow(
            label: 'Kỹ thuật viên',
            value: order.personName!,
            icon: Icons.engineering_outlined,
          ),
      ],
    );
  }

  Widget _buildScheduleCard(FsmOrder order) {
    return _SectionCard(
      title: 'Lịch hẹn',
      icon: Icons.schedule_outlined,
      children: [
        if (order.scheduledDateStart != null)
          _DetailRow(
            label: 'Bắt đầu dự kiến',
            value: _fmt(order.scheduledDateStart!),
            icon: Icons.calendar_today_outlined,
          ),
        if (order.scheduledDateEnd != null)
          _DetailRow(
            label: 'Kết thúc dự kiến',
            value: _fmt(order.scheduledDateEnd!),
            icon: Icons.event_outlined,
          ),
        if (order.dateStart != null)
          _DetailRow(
            label: 'Check-in thực tế',
            value: _fmt(order.dateStart!),
            icon: Icons.login_outlined,
            highlight: true,
            trailing: order.isPendingSync
                ? const Tooltip(
                    message: 'Đang chờ đồng bộ lên Odoo',
                    child: Icon(Icons.sync_problem, color: AppColors.warning, size: 18),
                  )
                : null,
          ),
      ],
    );
  }

  Widget _buildActionsCard(
      BuildContext context, OrdersProvider provider, FsmOrder order) {
    return _SectionCard(
      title: 'Công việc liên quan',
      icon: Icons.work_outline,
      children: [
        _ActionTile(
          icon: Icons.map_outlined,
          label: 'Xem bản đồ tuyến đường',
          onTap: () => context.push(RouteNames.routeMap),
        ),
        _ActionTile(
          icon: Icons.qr_code_scanner_outlined,
          label: 'Quét vật tư / Stock',
          onTap: () => context.push(
            RouteNames.stockMoves.replaceFirst(':orderId', '${order.odooId}'),
          ),
        ),
        _ActionTile(
          icon: Icons.access_time_outlined,
          label: 'Ghi nhận giờ công',
          onTap: () => context.push(
            RouteNames.timesheet.replaceFirst(':orderId', '${order.odooId}'),
          ),
        ),
        _ActionTile(
          icon: Icons.receipt_long_outlined,
          label: 'Thêm khoản chi',
          onTap: () => context.push(
            RouteNames.expense.replaceFirst(':orderId', '${order.odooId}'),
          ),
        ),
        _ActionTile(
          icon: Icons.fact_check_outlined,
          label: 'Nghiệm thu & Chữ ký',
          onTap: () => context.push(
            RouteNames.workOrder.replaceFirst(':orderId', '${order.odooId}'),
          ),
          highlight: true,
        ),
      ],
    );
  }

  Future<bool> _ensureRouteSequence(BuildContext context, OrdersProvider provider, FsmOrder order) async {
    final routeProvider = context.read<RouteProvider>();
    if (routeProvider.stops.isEmpty) {
      await routeProvider.buildRoute(provider.orders);
    }
    if (!routeProvider.isAllowedToCheckIn(order.odooId)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bạn phải hoàn thành các điểm trước trong lộ trình trước.'),
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
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            if (order.stage == FsmOrderStage.done || order.stage == FsmOrderStage.cancelled)
              Expanded(
                child: FilledButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.lock_outline, size: 18),
                  label: Text(order.stage == FsmOrderStage.done
                      ? 'Đã hoàn thành'
                      : 'Đã huỷ'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.surfaceVariant,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              )
            else if (order.dateStart == null)
              // Nút Check-in
              Expanded(
                child: FilledButton.icon(
                  key: const Key('btn_check_in'),
                  onPressed: provider.isLoading
                      ? null
                      : () async {
                          if (!await _ensureRouteSequence(context, provider, order)) return;
                          
                          await provider.checkIn(order.odooId);
                          await context.read<RouteProvider>().buildRoute(provider.orders);
                          
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
                  icon: const Icon(Icons.login, size: 18),
                  label: const Text('Check-in'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              )
            else if (order.stage == FsmOrderStage.draft)
              // Nút Bắt đầu thực hiện (chuyển sang stageId = 2)
              Expanded(
                child: FilledButton.icon(
                  onPressed: provider.isLoading
                      ? null
                      : () async {
                          if (!await _ensureRouteSequence(context, provider, order)) return;
                          // Gọi hàm tự động lấy ID trạng thái In Progress
                          await provider.updateOrderToInProgress(order.odooId);
                          await context.read<RouteProvider>().buildRoute(provider.orders);
                        },
                  icon: const Icon(Icons.play_circle_outline, size: 18),
                  label: const Text('Bắt đầu thực hiện'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              )
            else
              // Nút Hoàn thành (chuyển sang stageId = 3)
              Expanded(
                child: FilledButton.icon(
                  key: const Key('btn_mark_complete'),
                  onPressed: provider.isLoading
                      ? null
                      : () async {
                          if (!await _ensureRouteSequence(context, provider, order)) return;
                          _confirmComplete(context, provider, order);
                        },
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Hoàn thành'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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

      final bool isSigned = workOrderProvider.report?.customerSignaturePath != null &&
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.surfaceVariant),
          ...children,
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
    this.isAction = false,
    this.highlight = false,
    this.trailing,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool isAction;
  final bool highlight;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: highlight ? AppColors.secondary : AppColors.onSurfaceMuted,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.onSurfaceMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: highlight ? AppColors.secondary : AppColors.onSurface,
                    fontWeight: highlight ? FontWeight.w600 : FontWeight.w400,
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
    required this.onTap,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: (highlight ? AppColors.secondary : AppColors.primary)
              .withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: highlight ? AppColors.secondary : AppColors.primary,
        ),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: highlight ? FontWeight.w600 : FontWeight.w400,
          color: highlight ? AppColors.secondary : AppColors.onSurface,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceMuted),
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}
