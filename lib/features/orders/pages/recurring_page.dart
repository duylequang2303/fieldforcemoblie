import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/api/api_exception.dart';
import '../models/fsm_order.dart';
import '../providers/recurring_provider.dart';
import '../services/orders_service.dart';
import '../services/recurring_notification_service.dart';
import '../services/recurring_service.dart';
import '../../../ui/theme/sf_tokens.dart';

/// Tab "ĐỊNH KỲ" — danh sách đơn định kỳ đến hạn trong 7 ngày.
class RecurringPage extends StatefulWidget {
  const RecurringPage({super.key});

  @override
  State<RecurringPage> createState() => _RecurringPageState();
}

class _RecurringPageState extends State<RecurringPage> {
  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  /// Offline-first: hiện cache ngay, rồi fetch nền.
  Future<void> _loadInitial() async {
    try {
      await context.read<RecurringProvider>().loadInitial();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khởi động: $e')),
        );
      }
    }
  }

  Future<void> _fetchFromOdoo({required bool showSpinner}) async {
    try {
      await context.read<RecurringProvider>().fetchFromOdoo(showSpinner: showSpinner);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải Odoo: $e')),
        );
      }
      rethrow;
    }
  }

  Future<void> _onTestNotify() async {
    try {
      final cachedOrders = await OrdersService.instance.loadCachedOrders();
      final content = RecurringService.buildNotificationContent(
        RecurringService.filterDueToday(
          RecurringService.fromFsmOrders(cachedOrders),
          DateTime.now(),
        ),
      );
      await RecurringNotificationService.instance.showTestNotification(
        title: content.title,
        body: content.body,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi gửi thông báo thử: $e')),
        );
      }
    }
  }

  Future<void> _onComplete(RecurringDueOrder order) async {
    final provider = context.read<RecurringProvider>();
    if (provider.busy) return;
    try {
      await provider.completeDueOrder(order);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã hoàn thành kỳ: ${order.name}')),
        );
      }
    } on OdooConnectionException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã lưu offline, sẽ đồng bộ khi có mạng')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
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
      backgroundColor: SfTokens.background,
      appBar: AppBar(
        backgroundColor: SfTokens.primary,
        foregroundColor: SfTokens.surface,
        centerTitle: true,
        title: const Text(
          'ĐỊNH KỲ',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Consumer<RecurringProvider>(
            builder: (context, provider, child) {
              return TextButton.icon(
                onPressed: provider.busy ? null : _onTestNotify,
                style: TextButton.styleFrom(
                  foregroundColor: SfTokens.surface,
                ),
                icon: const Icon(Icons.notifications_active),
                label: const Text('Test Notify'),
              );
            },
          ),
        ],
      ),
      body: Consumer<RecurringProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final dueOrders = provider.dueOrders;
          return RefreshIndicator(
            onRefresh: () => _fetchFromOdoo(showSpinner: false),
            color: theme.colorScheme.primary,
            child: dueOrders.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 100),
                      Icon(Icons.event_repeat, size: 64, color: theme.colorScheme.outline),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          'Không có công việc định kỳ trong 7 ngày tới',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      if (provider.error != null)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            provider.error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: dueOrders.length,
                    itemBuilder: (context, index) {
                      final o = dueOrders[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Icon(
                              Icons.event_repeat,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          title: Text(
                            o.partnerName == null || o.partnerName!.isEmpty
                                ? o.name
                                : o.partnerName!,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (o.serviceName != null) Text(o.serviceName!),
                              Text(
                                _fmtDate(o.dueDate),
                                style: theme.textTheme.labelMedium,
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: IconButton(
                            tooltip: 'Hoàn thành kỳ này',
                            onPressed: provider.busy ? null : () => _onComplete(o),
                            icon: Icon(
                              Icons.check_circle_outline,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}