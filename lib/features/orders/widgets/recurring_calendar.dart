import 'package:flutter/material.dart';
import '../../../../ui/theme/sf_tokens.dart';
import '../models/fsm_order.dart';

class RecurringCalendar extends StatefulWidget {
  final DateTime selectedDate;
  final List<FsmOrder> orders;
  final ValueChanged<DateTime> onDateSelected;

  const RecurringCalendar({
    super.key,
    required this.selectedDate,
    required this.orders,
    required this.onDateSelected,
  });

  @override
  State<RecurringCalendar> createState() => _RecurringCalendarState();
}

class _RecurringCalendarState extends State<RecurringCalendar> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(widget.selectedDate.year, widget.selectedDate.month, 1);
  }

  @override
  void didUpdateWidget(RecurringCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate.year != widget.selectedDate.year ||
        oldWidget.selectedDate.month != widget.selectedDate.month) {
      setState(() {
        _currentMonth = DateTime(widget.selectedDate.year, widget.selectedDate.month, 1);
      });
    }
  }

  List<DateTime> _generateCalendarDays(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final firstWeekday = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday
    final daysBefore = firstWeekday - 1;
    final startGridDate = firstDayOfMonth.subtract(Duration(days: daysBefore));
    return List.generate(42, (index) => startGridDate.add(Duration(days: index)));
  }

  int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  @override
  Widget build(BuildContext context) {
    final days = _generateCalendarDays(_currentMonth);
    final monthName = _getMonthNameVi(_currentMonth.month);
    final year = _currentMonth.year;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Header navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: SfTokens.primary),
                onPressed: () {
                  setState(() {
                    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
                  });
                },
              ),
              Text(
                '$monthName - $year',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: SfTokens.primaryDark,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: SfTokens.primary),
                onPressed: () {
                  setState(() {
                    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Days of week header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _DayHeader(label: 'T2'),
              _DayHeader(label: 'T3'),
              _DayHeader(label: 'T4'),
              _DayHeader(label: 'T5'),
              _DayHeader(label: 'T6'),
              _DayHeader(label: 'T7'),
              _DayHeader(label: 'CN'),
            ],
          ),
          const Divider(height: 12),

          // Calendar Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: 42,
            itemBuilder: (context, index) {
              final dayDate = days[index];
              final isSelected = dayDate.year == widget.selectedDate.year &&
                  dayDate.month == widget.selectedDate.month &&
                  dayDate.day == widget.selectedDate.day;

              final isCurrentMonth = dayDate.month == _currentMonth.month;

              // Find orders for this day
              final dayOrders = widget.orders.where((o) {
                if (o.scheduledDateStart == null) return false;
                return o.scheduledDateStart!.year == dayDate.year &&
                    o.scheduledDateStart!.month == dayDate.month &&
                    o.scheduledDateStart!.day == dayDate.day;
              }).toList();

              // Check features
              final hasRecurring = dayOrders.any((o) => o.isRecurringInstance);
              final hasOverdue = dayOrders.any((o) {
                final isPast = o.scheduledDateStart != null &&
                    o.scheduledDateStart!.isBefore(DateTime.now());
                final incomplete = o.stage != FsmOrderStage.done &&
                    o.stage != FsmOrderStage.cancelled;
                return isPast && incomplete;
              });
              return GestureDetector(
                onTap: () => widget.onDateSelected(dayDate),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? SfTokens.primary
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: hasOverdue
                        ? Border.all(color: Colors.red, width: 1.5)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${dayDate.day}',
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? Colors.white
                              : isCurrentMonth
                                  ? Colors.black87
                                  : Colors.black38,
                        ),
                      ),
                      if (dayOrders.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white
                                    : hasRecurring
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            if (hasOverdue) ...[
                              const SizedBox(width: 2),
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getMonthNameVi(int month) {
    const months = [
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 6',
      'Tháng 7',
      'Tháng 8',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12'
    ];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }
}

class _DayHeader extends StatelessWidget {
  final String label;
  const _DayHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: SfTokens.primaryDark,
        ),
      ),
    );
  }
}
