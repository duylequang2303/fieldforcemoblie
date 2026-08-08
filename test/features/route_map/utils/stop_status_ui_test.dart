import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce_mobile/features/route_map/models/route_stop.dart';
import 'package:fieldforce_mobile/features/route_map/utils/stop_status_ui.dart';

void main() {
  group('StopStatusUI.label', () {
    test('should return the Vietnamese label of each status', () {
      expect(StopStatusUI.label(StopStatus.pending), 'Sắp tới');
      expect(StopStatusUI.label(StopStatus.current), 'Đang làm');
      expect(StopStatusUI.label(StopStatus.completed), 'Đã hoàn thành');
      expect(StopStatusUI.label(StopStatus.skipped), 'Bỏ qua');
    });

    test('should cover every StopStatus value with a distinct label', () {
      final labels = StopStatus.values.map(StopStatusUI.label).toSet();

      expect(labels.length, StopStatus.values.length);
      expect(labels.any((l) => l.isEmpty), isFalse);
    });
  });

  group('StopStatusUI.color', () {
    // Expected ARGB values of the design tokens (onSurfaceMuted, info, success,
    // warning). Hardcoded rather than imported because the repo pre-commit hook
    // rejects any staged Dart file referencing the palette class directly.
    test('should map each status to its design-system color', () {
      expect(StopStatusUI.color(StopStatus.pending).toARGB32(), 0xFF6B6B6B);
      expect(StopStatusUI.color(StopStatus.current).toARGB32(), 0xFF1565C0);
      expect(StopStatusUI.color(StopStatus.completed).toARGB32(), 0xFF2E7D32);
      expect(StopStatusUI.color(StopStatus.skipped).toARGB32(), 0xFFB28726);
    });

    test('should give every StopStatus a distinct color', () {
      final colors = StopStatus.values.map(StopStatusUI.color).toSet();

      expect(colors.length, StopStatus.values.length);
    });

    test('should return fully opaque colors', () {
      for (final status in StopStatus.values) {
        expect(StopStatusUI.color(status).a, 1.0, reason: '$status');
      }
    });
  });
}
