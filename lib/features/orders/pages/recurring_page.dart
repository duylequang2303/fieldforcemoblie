import 'package:flutter/material.dart';
import '../models/fsm_order.dart';
import '../services/orders_service.dart';
import '../services/recurring_service.dart';
import '../services/recurring_notification_service.dart';

/// Tab "ĐỊNH KỲ" — danh sách đơn định kỳ đến hạn trong 7 ngày.
///
/// Widget KHÔNG chứa logic: chỉ gọi [RecurringService] để lọc,
/// [RecurringNotificationService] để test notify,
/// [OrdersService.completeOrder] để đánh dấu hoàn thành kỳ (offline-first).
class RecurringPage extends StatefulWidget {
  const RecurringPage({super.key});

  @override
  State<RecurringPage> createState() => _RecurringPageState();
}

class _RecurringPageState extends State<RecurringPage> {
  bool _isLoading = false;
  List<RecurringDueOrder> _dueOrders = [];
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  /// Offline-first: hiện cache ngay, rồi fetch nền.
  Future<void> _loadInitial() async {
    List<FsmOrder> cached = [];
    try {
      cached = await OrdersService.instance.loadCachedOrders();
    } catch (_) {}
    if (!mounted) return;
    _applyOrders(cached);
    await _fetchFromOdoo(showSpinner: cached.isEmpty);
  }

  /// Chuyển đổi qua service thuần + filter 7 ngày.
  void _applyOrders(List<FsmOrder> orders) {
    final recurring = RecurringService.fromFsmOrders(orders);
    final due = RecurringService.filterDueOrders(recurring, DateTime.now());
    setState(() => _dueOrders = due);
  }

  Future<void> _fetchFromOdoo({required bool showSpinner}) async {
    if (showSpinner && mounted) setState(() => _isLoading = true);
    try {
      final fresh = await OrdersService.instance.fetchMyOrders();
      if (!mounted) return;
      _applyOrders(fresh);
      _error = null;
    } catch (e) {
      if (mounted) setState(() => _error = 'Không thể tải dữ liệu. Hiển thị cache.');
    } finally {
      if (showSpinner && mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onTestNotify() async {
    final content =
        RecurringService.buildNotificationContent(
          RecurringService.filterDueToday(RecurringService.fromFsmOrders(
            await OrdersService.instance.loadCachedOrders(),
          ), DateTime.now()),
        );
    await RecurringNotificationService.instance.showTestNotification(
      title: content.title,
      body: content.body,
    );
  }

  Future<void> _onComplete(RecurringDueOrder order) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      // Offline-first: completeOrder tự lưu local + push lên Odoo.
      await OrdersService.instance.completeOrder(order.odooId);
      await _fetchFromOdoo(showSpinner: false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã hoàn thành kỳ: ${order.name}')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã lưu offline, sẽ đồng bộ khi có mạng')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return 'Chưa có ngày';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(d.year, d.month, d.day);
    final diff = day.difference(today).inDays;
    if (diff == 0) return 'Hôm nay';
    if (diff == 1) return 'Ngày mai';
    if (diff > 1) return 'Trong $diff ngày';
    return '${d.day}/${d.month}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('ĐỊNH KỲ'),
        backgroundColor: theme.colorScheme.surface,
        actions: [
          TextButton.icon(
            onPressed: _busy ? null : _onTestNotify,
            icon: Icon(Icons.notifications_active,
                color: theme.colorScheme.primary),
            label: Text('Test Notify',
                style: TextStyle(color: theme.colorScheme.primary)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _fetchFromOdoo(showSpinner: false),
              color: theme.colorScheme.primary,
              child: _dueOrders.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 100),
                        Icon(Icons.event_repeat,
                            size: 64, color: theme.colorScheme.outline),
                        const SizedBox(height: 16),
                        Center(
                          child: Text('Không có công việc định kỳ trong 7 ngày tới',
                              style: theme.textTheme.bodyMedium),
                        ),
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(_error!,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: theme.colorScheme.error)),
                          ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _dueOrders.length,
                      itemBuilder: (context, index) {
                        final o = _dueOrders[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.primaryContainer,
                              child: Icon(Icons.event_repeat,
                                  color: theme.colorScheme.onPrimaryContainer),
                            ),
                            title: Text(
                                o.partnerName == null || o.partnerName!.isEmpty
                                    ? o.name
                                    : o.partnerName!),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (o.serviceName != null)
                                  Text(o.serviceName!),
                                Text(_fmtDate(o.dueDate),
                                    style: theme.textTheme.labelMedium),
                              ],
                            ),
                            isThreeLine: true,
                            trailing: IconButton(
                              tooltip: 'Hoàn thành kỳ này',
                              onPressed:
                                  _busy ? null : () => _onComplete(o),
                              icon: Icon(Icons.check_circle_outline,
                                  color: theme.colorScheme.primary),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}