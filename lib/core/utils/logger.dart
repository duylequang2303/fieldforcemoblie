import 'package:flutter/foundation.dart';
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
  // Release builds only keep errors: debug/info logs contain server URLs,
  // customer data and session details that must not reach device logs.
  level: kReleaseMode ? Level.error : Level.debug,
);
