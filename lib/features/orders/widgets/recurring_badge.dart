import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';
import '../../../../core/database/isar_service.dart';
import '../models/fsm_recurring.dart';
import '../models/fsm_frequency_set.dart';

/// Badge hiển thị biểu tượng lặp định kỳ và mô tả tần suất lặp.
class RecurringBadge extends StatelessWidget {
  const RecurringBadge({
    super.key,
    required this.recurringId,
    this.showText = false,
  });

  final int recurringId;
  final bool showText;

  @override
  Widget build(BuildContext context) {
    if (recurringId <= 0) return const SizedBox.shrink();

    // TỐI ƯU HÓA CUỘN DANH SÁCH: Nếu chỉ hiện icon (trong ListTile/Card), 
    // không query database Isar để tránh giật lag khi cuộn (jank frames).
    if (!showText) {
      return Tooltip(
        message: 'Lặp định kỳ',
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            Icons.repeat_one_rounded,
            size: 14,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      );
    }

    final isar = IsarService.instance.db;

    // Chỉ truy cập database đồng bộ cho màn hình chi tiết (chỉ render 1 lần)
    final recurring = isar.fsmRecurrings
        .filter()
        .odooIdEqualTo(recurringId)
        .findFirstSync();

    if (recurring == null) return const SizedBox.shrink();

    final freqSet = isar.fsmFrequencySets
        .filter()
        .odooIdEqualTo(recurring.frequencySetId)
        .findFirstSync();

    final patternText = _buildPatternText(recurring, freqSet);

    return Tooltip(
      message: patternText,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.repeat_one_rounded,
              size: 14,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            if (showText) ...[
              const SizedBox(width: 4),
              Text(
                patternText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _buildPatternText(FsmRecurring rule, FsmFrequencySet? freqSet) {
    if (freqSet == null) {
      return 'Định kỳ'; // Fallback nếu không có frequency
    }

    final interval = freqSet.interval;
    final unit = _getIntervalUnitVi(freqSet.intervalType, interval);

    if (interval == 1) {
      return 'Mỗi $unit';
    } else {
      return '$interval $unit một lần';
    }
  }

  String _getIntervalUnitVi(FrequencyIntervalType type, int count) {
    switch (type) {
      case FrequencyIntervalType.daily:
        return 'ngày';
      case FrequencyIntervalType.weekly:
        return 'tuần';
      case FrequencyIntervalType.monthly:
        return 'tháng';
      case FrequencyIntervalType.yearly:
        return 'năm';
    }
  }
}
