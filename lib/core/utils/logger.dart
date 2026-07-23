import 'package:logger/logger.dart';

/// Logger singleton dùng chung toàn app.
/// Dùng thay cho print() theo quy tắc AGENTS.md.
///
/// Cách dùng:
/// ```dart
/// import '../../../core/utils/logger.dart';
/// logger.i('Info message');
/// logger.w('Warning', error: e);
/// logger.e('Error', error: e, stackTrace: st);
/// ```
final Logger logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
  level: Level.debug,
);
