import 'package:flutter/material.dart';

class DateNavigationBar extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onCalendarTap;
  final ValueChanged<String?> onDropdownChanged;

  const DateNavigationBar({
    super.key,
    required this.selectedDate,
    required this.onPrevious,
    required this.onNext,
    required this.onCalendarTap,
    required this.onDropdownChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock date string
    final dateStr = "${selectedDate.day} Thg ${selectedDate.month}, ${selectedDate.year}";

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: onPrevious,
              ),
              GestureDetector(
                onTap: onCalendarTap,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Hôm nay', // "Today"
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dateStr,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: onNext,
              ),
            ],
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: 'Ngày', // 'Day'
              icon: const Icon(Icons.arrow_drop_down),
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
              items: <String>['Ngày', 'Tuần', 'Tháng']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: onDropdownChanged,
            ),
          ),
        ],
      ),
    );
  }
}
