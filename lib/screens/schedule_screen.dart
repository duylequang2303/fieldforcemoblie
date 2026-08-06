import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/schedule_top_bar.dart';
import '../widgets/filter_chips_row.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/schedule_card.dart';
import 'package:fieldforce_mobile/features/orders/models/fsm_order.dart';
import 'package:fieldforce_mobile/features/orders/services/orders_service.dart';
import 'package:fieldforce_mobile/features/orders/widgets/recurring_calendar.dart';
import 'package:go_router/go_router.dart';
import '../core/routing/route_names.dart';

/// Màn hình ScheduleScreen — đọc dữ liệu fsm.order thật từ OrdersService
/// (Odoo + cache Isar, offline-first). Thiết kế Sortscape (Card-based List).
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();
  String _viewMode = 'Today';
  FsmOrderStage? _selectedStage; // null = All
  Set<FsmOrderStage> _filterStages = {};
  Set<String> _filterPersons = {};
  Set<String> _filterPriorities = {};

  // Dữ liệu thật — nạp từ OrdersService (Isar cache + Odoo), KHÔNG còn mock.
  List<FsmOrder> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  /// Offline-first: hiện cache Isar ngay, rồi pull Odoo nền.
  Future<void> _loadInitial() async {
    List<FsmOrder> cached = [];
    try {
      cached = await OrdersService.instance.loadCachedOrders();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ScheduleScreen loadCachedOrders failed: $e');
      }
    }
    if (!mounted) return;
    setState(() => _orders = cached);

    // Lần đầu chưa có cache → hiện spinner; đã có cache → fetch nền lặng lẽ.
    await _fetchFromOdoo(showSpinner: cached.isEmpty);
  }

  /// Pull dữ liệu thật từ Odoo (fetchMyOrders tự lưu Isar).
  /// Offline/lỗi → giữ nguyên cache đã có, không crash.
  Future<void> _fetchFromOdoo({required bool showSpinner}) async {
    if (showSpinner && mounted) setState(() => _isLoading = true);
    try {
      final fresh = await OrdersService.instance.fetchMyOrders();
      if (!mounted) return;
      setState(() => _orders = fresh);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ScheduleScreen fetchMyOrders failed (offline?): $e');
      }
    } finally {
      if (showSpinner && mounted) setState(() => _isLoading = false);
    }
  }

      // Lọc orders theo ngày đã chọn và ẩn các đơn bị skip
      List<FsmOrder> get _filteredOrders {
        return _orders.where((order) {
          if (order.isSkipped) return false;
          if (order.scheduledDateStart == null) return false;
      final matchDate = order.scheduledDateStart!.year == _selectedDate.year &&
          order.scheduledDateStart!.month == _selectedDate.month &&
          order.scheduledDateStart!.day == _selectedDate.day;
      if (!matchDate) return false;
      if (_selectedStage != null && order.stage != _selectedStage) {
        return false;
      }
      if (_selectedStage == null &&
          _filterStages.isNotEmpty &&
          !_filterStages.contains(order.stage)) {
        return false;
      }
      if (_filterPersons.isNotEmpty &&
          (order.personName == null ||
              !_filterPersons.contains(order.personName))) {
        return false;
      }
      if (_filterPriorities.isNotEmpty &&
          !_filterPriorities.contains(order.priority)) {
        return false;
      }
      return true;
    }).toList();
  }

  // Tính tổng giờ và giả lập tính tiền
  String _getSummaryText() {
    double totalHours = 0;
    for (var order in _filteredOrders) {
      if (order.scheduledDateStart != null && order.scheduledDateEnd != null) {
        totalHours += order.scheduledDateEnd!
                .difference(order.scheduledDateStart!)
                .inMinutes /
            60.0;
      }
    }
    // Giả lập tính tiền: $50 / giờ (do FsmOrder hiện tại chưa có field giá trị)
    final double totalValue = totalHours * 50;
    return '${totalHours.toStringAsFixed(2)} hrs (\$ ${totalValue.toStringAsFixed(0)})';
  }

  List<String> get _availablePersons {
    return _orders.map((o) => o.personName).whereType<String>().toSet().toList()
      ..sort();
  }

  Future<void> _openFilterSheet() async {
    final result = await showFilterBottomSheet(
      context: context,
      initialStages: _selectedStage != null ? {_selectedStage!} : _filterStages,
      initialPersons: _filterPersons,
      initialPriorities: _filterPriorities,
      availablePersons: _availablePersons,
      allOrders: _orders,
    );

    if (result == null) return;

    setState(() {
      if (result.stages.length == 1) {
        _selectedStage = result.stages.first;
        _filterStages = {};
      } else {
        _selectedStage = null;
        _filterStages = result.stages;
      }
      _filterPersons = result.persons;
      _filterPriorities = result.priorities;
    });
  }

  Future<void> _onRefresh() async {
    await _fetchFromOdoo(showSpinner: true);
  }

  Widget _buildJobList() {
    if (_isLoading) {
      // TODO: Có thể thay thế bằng Shimmer Loading thật
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final displayOrders = _filteredOrders;

    if (displayOrders.isEmpty) {
      return const EmptyStateWidget(
        message: 'No jobs scheduled for this day',
        icon: Icons.event_available,
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: Theme.of(context).colorScheme.primary,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: displayOrders.length,
        itemBuilder: (context, index) {
          final order = displayOrders[index];
          return ScheduleCard(
            order: order,
            onTap: () {
              context.push(RouteNames.workOrderDetailScreen, extra: order);
            },
            onChatTap: () {
              // TODO: Mở màn hình chat/ghi chú
            },
          );
        },
      ),
    );
  }

  Widget _buildBottomSummaryBar() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getSummaryText(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            OutlinedButton.icon(
              onPressed: () {
                // TODO: Tạo công việc mới
              },
              icon: Icon(Icons.add, color: theme.colorScheme.primary),
              label: Text(
                'Add Visit',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: theme.colorScheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          ScheduleTopBar(
            viewMode: _viewMode,
            selectedDate: _selectedDate,
            onPrevious: () {
              setState(() {
                _selectedDate = _viewMode == 'Week'
                    ? _selectedDate.subtract(const Duration(days: 7))
                    : _selectedDate.subtract(const Duration(days: 1));
              });
            },
            onNext: () {
              setState(() {
                _selectedDate = _viewMode == 'Week'
                    ? _selectedDate.add(const Duration(days: 7))
                    : _selectedDate.add(const Duration(days: 1));
              });
            },
            onCalendarTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                setState(() => _selectedDate = date);
              }
            },
            onFilterTap: () {
              _openFilterSheet();
            },
            onViewModeChanged: (mode) {
              setState(() => _viewMode = mode);
            },
          ),
          FilterChipsRow(
            selectedStage: _selectedStage,
            onStageSelected: (stage) {
              setState(() {
                _selectedStage = stage;
                _filterStages = {};
                _filterPersons = {};
                _filterPriorities = {};
              });
            },
          ),
          Expanded(
            child: _viewMode == 'Month'
                ? Column(
                    children: [
                      RecurringCalendar(
                        selectedDate: _selectedDate,
                        orders: _orders,
                        onDateSelected: (date) async {
                          setState(() {
                            _selectedDate = date;
                          });
                          // Khi chuyển qua ngày khác, tự động chạy check sinh local recurring instances
                          await RecurringService.instance.generateOfflineInstances();
                          final updated = await OrdersService.instance.loadCachedOrders();
                          if (mounted) {
                            setState(() {
                              _orders = updated;
                            });
                          }
                        },
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: _buildJobList(),
                      ),
                    ],
                  )
                : _buildJobList(),
          ),
          _buildBottomSummaryBar(),
        ],
      ),
    );
  }
}
