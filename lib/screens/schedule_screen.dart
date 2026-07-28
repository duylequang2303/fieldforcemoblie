import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/schedule_top_bar.dart';
import '../widgets/filter_chips_row.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/schedule_card.dart';
import '../features/orders/models/fsm_order.dart';
import '../ui/theme/sf_tokens.dart';
import 'package:go_router/go_router.dart';
import '../core/routing/route_names.dart';

/// Màn hình mẫu ScheduleScreen tuân thủ cấu trúc Scaffold mới
/// và thiết kế Sortscape (Card-based List).
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _currentIndex = 0;
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();
  String _viewMode = 'Today';
  FsmOrderStage? _selectedStage; // null = All
  Set<FsmOrderStage> _filterStages = {};
  Set<String> _filterPersons = {};
  Set<String> _filterPriorities = {};

  // Mock dữ liệu dựa theo FsmOrder cho UI mẫu
  final List<FsmOrder> _orders = [
    FsmOrder()
      ..odooId = 1
      ..name = "WO/2026/001"
      ..locationAddress = "42 Garden Street, Sydney NSW"
      ..partnerName = "John Doe"
      ..personName = "John Doe"
      ..priority = "0"
      ..scheduledDateStart = DateTime.now().copyWith(hour: 9, minute: 0)
      ..scheduledDateEnd = DateTime.now().copyWith(hour: 11, minute: 0)
      ..stageId = 1
      ..stageName = 'Draft'
      ..stage = FsmOrderStage.draft
      ..isPendingSync = false,
    FsmOrder()
      ..odooId = 2
      ..name = "WO/2026/002"
      ..locationAddress = "150 George Street, Brisbane"
      ..partnerName = "Acme Corp"
      ..personName = "Jane Smith"
      ..priority = "1"
      ..scheduledDateStart = DateTime.now().copyWith(hour: 13, minute: 0)
      ..scheduledDateEnd = DateTime.now().copyWith(hour: 14, minute: 30)
      ..stageId = 2
      ..stageName = 'In Progress'
      ..stage = FsmOrderStage.inProgress
      ..isPendingSync = true,
  ];

  // Lọc orders theo ngày đã chọn
  List<FsmOrder> get _filteredOrders {
    return _orders.where((order) {
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
            .inMinutes / 60.0;
      }
    }
    // Giả lập tính tiền: $50 / giờ (do FsmOrder hiện tại chưa có field giá trị)
    double totalValue = totalHours * 50;
    return '${totalHours.toStringAsFixed(2)} hrs (\$ ${totalValue.toStringAsFixed(0)})';
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  List<String> get _availablePersons {
    return _orders
        .map((o) => o.personName)
        .whereType<String>()
        .toSet()
        .toList()
      ..sort();
  }

  Future<void> _openFilterSheet() async {
    final result = await showFilterBottomSheet(
      context: context,
      initialStages: _selectedStage != null
          ? {_selectedStage!}
          : _filterStages,
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
    setState(() {
      _isLoading = true;
    });
    // Giả lập gọi API sync
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
    });
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
      color: SfTokens.primary,
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
    return Scaffold(
      backgroundColor: SfTokens.background,
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
            child: _buildJobList(),
          ),
          _buildBottomSummaryBar(),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}