import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/schedule_top_bar.dart';
import '../widgets/filter_chips_row.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/schedule_card.dart';
import 'package:fieldforce_mobile/features/orders/models/fsm_order.dart';
import 'package:fieldforce_mobile/features/orders/services/orders_service.dart';
import 'package:fieldforce_mobile/features/orders/services/recurring_service.dart';
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
  int _pendingSyncCount = 0;
  bool _isSyncing = false;

  // Dữ liệu thật — nạp từ OrdersService (Isar cache + Odoo), KHÔNG còn mock.
  List<FsmOrder> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _refreshPendingSyncCount() async {
    final count = await OrdersService.instance.pendingSyncCount();
    if (!mounted) return;
    setState(() => _pendingSyncCount = count);
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
    await _refreshPendingSyncCount();
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
    await _refreshPendingSyncCount();
  }

      // Lọc orders theo ngày đã chọn và ẩn các đơn bị skip
  List<FsmOrder>? _cachedFilteredOrders;
  List<FsmOrder>? _cachedOrdersRef;
  DateTime? _cachedSelectedDate;
  String? _cachedViewMode;
  FsmOrderStage? _cachedSelectedStage;
  Set<FsmOrderStage>? _cachedFilterStages;
  Set<String>? _cachedFilterPersons;
  Set<String>? _cachedFilterPriorities;

  List<FsmOrder> get _filteredOrders {
    if (_cachedFilteredOrders != null &&
        _cachedOrdersRef == _orders &&
        _cachedSelectedDate == _selectedDate &&
        _cachedViewMode == _viewMode &&
        _cachedSelectedStage == _selectedStage &&
        _cachedFilterStages == _filterStages &&
        _cachedFilterPersons == _filterPersons &&
        _cachedFilterPriorities == _filterPriorities) {
      return _cachedFilteredOrders!;
    }

    final result = _orders.where((order) {
      if (order.isSkipped || order.isRecurringProcessed) return false;
      if (order.scheduledDateStart == null) return false;
      final orderDate = order.scheduledDateStart!;
      final orderDay = DateTime.utc(orderDate.year, orderDate.month, orderDate.day);
      if (_viewMode == 'Week') {
        final startOfWeek = _selectedDate.subtract(
            Duration(days: _selectedDate.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 7));
        final start = DateTime.utc(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        final end = DateTime.utc(endOfWeek.year, endOfWeek.month, endOfWeek.day);
        if (orderDay.isBefore(start) || !orderDay.isBefore(end)) {
          return false;
        }
      } else {
        final selectedDay = DateTime.utc(_selectedDate.year, _selectedDate.month, _selectedDate.day);
        if (orderDay != selectedDay) return false;
      }
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

    _cachedOrdersRef = _orders;
    _cachedSelectedDate = _selectedDate;
    _cachedViewMode = _viewMode;
    _cachedSelectedStage = _selectedStage;
    _cachedFilterStages = _filterStages;
    _cachedFilterPersons = _filterPersons;
    _cachedFilterPriorities = _filterPriorities;
    _cachedFilteredOrders = result;

    return result;
  }

  // Tính tổng giờ
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
    return '${totalHours.toStringAsFixed(2)} hrs';
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

  Future<void> _onSyncTap() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    try {
      await OrdersService.instance.syncPending();
      if (!mounted) return;
      await _fetchFromOdoo(showSpinner: false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sync completed')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
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
          final hasPhone = order.partnerPhone != null && order.partnerPhone!.isNotEmpty;
          final hasCoords = order.locationLat != null && order.locationLng != null;
          return ScheduleCard(
            order: order,
            onTap: () {
              context.push(RouteNames.workOrderDetailScreen, extra: order);
            },
            onChatTap: () {
              // TODO: Mở màn hình chat/ghi chú
            },
            onCallTap: hasPhone
                ? () {
                    final phone = order.partnerPhone;
                    if (phone == null || phone.isEmpty) return;
                    launchUrl(Uri(scheme: 'tel', path: phone),
                        mode: LaunchMode.externalApplication);
                  }
                : null,
            onDirectionsTap: hasCoords
                ? () {
                    final lat = order.locationLat;
                    final lng = order.locationLng;
                    if (lat == null || lng == null) return;
                    launchUrl(
                        Uri.parse(
                            'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng'),
                        mode: LaunchMode.externalApplication);
                  }
                : null,
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
                context.push(RouteNames.orders);
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
            pendingSyncCount: _pendingSyncCount,
            onSyncTap: _isSyncing ? null : _onSyncTap,
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
