import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce_mobile/features/orders/models/fsm_frequency_set.dart';
import 'package:fieldforce_mobile/features/orders/services/recurring_service.dart';

void main() {
  group('RecurringService - calculateNextOccurrence Tests', () {
    final service = RecurringService.instance;

    test('Daily interval validation', () {
      final from = DateTime(2026, 8, 5, 8, 0, 0); // 2026-08-05
      
      // Daily, interval = 1
      final freqSet1 = FsmFrequencySet()
        ..interval = 1
        ..intervalType = FrequencyIntervalType.daily;
      
      final next1 = service.calculateNextOccurrence(from, freqSet1);
      expect(next1, DateTime(2026, 8, 6, 8, 0, 0));

      // Daily, interval = 3
      final freqSet2 = FsmFrequencySet()
        ..interval = 3
        ..intervalType = FrequencyIntervalType.daily;

      final next2 = service.calculateNextOccurrence(from, freqSet2);
      expect(next2, DateTime(2026, 8, 8, 8, 0, 0));
    });

    test('Weekly interval validation', () {
      final from = DateTime(2026, 8, 5, 8, 0, 0); // Wed, 2026-08-05

      // Weekly, interval = 1 (every week)
      final freqSet1 = FsmFrequencySet()
        ..interval = 1
        ..intervalType = FrequencyIntervalType.weekly;

      final next1 = service.calculateNextOccurrence(from, freqSet1);
      expect(next1, DateTime(2026, 8, 12, 8, 0, 0));

      // Weekly, interval = 2 (every 2 weeks)
      final freqSet2 = FsmFrequencySet()
        ..interval = 2
        ..intervalType = FrequencyIntervalType.weekly;

      final next2 = service.calculateNextOccurrence(from, freqSet2);
      expect(next2, DateTime(2026, 8, 19, 8, 0, 0));
    });

    test('Monthly interval validation (simple and leap/days overlap)', () {
      final from1 = DateTime(2026, 8, 5, 8, 0, 0);

      // Monthly, interval = 1
      final freqSet1 = FsmFrequencySet()
        ..interval = 1
        ..intervalType = FrequencyIntervalType.monthly;

      final next1 = service.calculateNextOccurrence(from1, freqSet1);
      expect(next1, DateTime(2026, 9, 5, 8, 0, 0));

      // Monthly, interval = 2
      final next2 = service.calculateNextOccurrence(from1, freqSet1..interval = 2);
      expect(next2, DateTime(2026, 10, 5, 8, 0, 0));

      // Leap transition / end of month: 31st Jan -> increment 1 month
      final from2 = DateTime(2026, 1, 31, 8, 0, 0);
      final next3 = service.calculateNextOccurrence(from2, freqSet1..interval = 1);
      // Feb has 28 days in 2026, it should rollback to 28th Feb
      expect(next3, DateTime(2026, 2, 28, 8, 0, 0));

      // Month overflow cross year: 15/11 -> increment 3 months -> 15/02 next year
      final from3 = DateTime(2025, 11, 15, 8, 0, 0);
      final next4 = service.calculateNextOccurrence(from3, freqSet1..interval = 3);
      expect(next4, DateTime(2026, 2, 15, 8, 0, 0));

      // Target day test: 31st Jan -> Feb 28 -> March 31 (using targetDay: 31)
      final freqSetMonthly = FsmFrequencySet()
        ..interval = 1
        ..intervalType = FrequencyIntervalType.monthly;
      final nextFeb = service.calculateNextOccurrence(DateTime(2026, 1, 31), freqSetMonthly, targetDay: 31);
      expect(nextFeb, DateTime(2026, 2, 28));

      final nextMarch = service.calculateNextOccurrence(nextFeb, freqSetMonthly, targetDay: 31);
      expect(nextMarch, DateTime(2026, 3, 31));
    });

    test('Yearly interval validation', () {
      final from = DateTime(2026, 8, 5, 8, 0, 0);

      // Yearly, interval = 1
      final freqSet1 = FsmFrequencySet()
        ..interval = 1
        ..intervalType = FrequencyIntervalType.yearly;

      final next1 = service.calculateNextOccurrence(from, freqSet1);
      expect(next1, DateTime(2027, 8, 5, 8, 0, 0));

      // Yearly, interval = 3
      final freqSet2 = FsmFrequencySet()
        ..interval = 3
        ..intervalType = FrequencyIntervalType.yearly;

      final next2 = service.calculateNextOccurrence(from, freqSet2);
      expect(next2, DateTime(2029, 8, 5, 8, 0, 0));
    });
  });
}
