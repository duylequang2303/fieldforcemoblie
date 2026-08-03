import 'package:intl/intl.dart';
import 'dart:ui';

/// Service quản lý locale hiện tại của app, đồng bộ với Odoo `res.users.lang`.
class LocaleService {
  LocaleService._();
  static final LocaleService instance = LocaleService._();

  String _current = const Locale('vi', 'VN').toString();

  String get currentLocale => _current;

  void setLocale(String locale) {
    if (locale.isEmpty) return;
    _current = locale;
    Intl.defaultLocale = locale;
  }

  bool get isVietnamese => _current.startsWith('vi');
}
