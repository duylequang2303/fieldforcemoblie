import 'package:intl/intl.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/logger.dart';

/// Service quản lý locale hiện tại của app, đồng bộ với Odoo `res.users.lang`.
class LocaleService {
  LocaleService._();
  static final LocaleService instance = LocaleService._();

  static const _keyLocale = 'app_locale';
  String _current = const Locale('vi', 'VN').toString();

  String get currentLocale => _current;

  /// Initialize locale from SharedPreferences.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_keyLocale);
    if (saved != null && saved.isNotEmpty) {
      _current = saved;
      Intl.defaultLocale = saved;
      logger.i('LocaleService: Loaded locale from prefs: $saved');
    }
  }

  Future<bool> setLocale(String locale) async {
    if (locale.isEmpty) return false;
    _current = locale;
    Intl.defaultLocale = locale;
    // Persist to SharedPreferences
    return await _persistLocale(locale);
  }

  Future<bool> _persistLocale(String locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setString(_keyLocale, locale);
      if (!success) {
        logger.e('LocaleService: Failed to persist locale - SharedPreferences setString returned false');
      }
      return success;
    } catch (e, stackTrace) {
      logger.e('LocaleService: Exception while persisting locale', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  bool get isVietnamese => _current.startsWith('vi');
}
