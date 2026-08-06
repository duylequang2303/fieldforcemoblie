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

  void setLocale(String locale) {
    if (locale.isEmpty) return;
    _current = locale;
    Intl.defaultLocale = locale;
    // Persist to SharedPreferences
    _persistLocale(locale);
  }

  Future<void> _persistLocale(String locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLocale, locale);
    } catch (e) {
      logger.w('LocaleService: Failed to persist locale', error: e);
    }
  }

  bool get isVietnamese => _current.startsWith('vi');
}
