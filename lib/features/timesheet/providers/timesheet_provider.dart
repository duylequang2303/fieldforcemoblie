import 'package:flutter/foundation.dart';
import '../../../core/utils/logger.dart';
import '../models/timesheet_entry.dart';
import '../services/timesheet_service.dart';

class TimesheetProvider extends ChangeNotifier {
  TimesheetProvider._internal() : _service = TimesheetService.instance;
  static final TimesheetProvider instance = TimesheetProvider._internal();

  final TimesheetService _service;

  List<TimesheetEntry> _entries = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TimesheetEntry> get entries => List.unmodifiable(_entries);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalHours => _entries.fold(0.0, (sum, e) => sum + e.hours);

  Future<void> loadEntries(int orderOdooId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _entries = await _service.getEntriesForOrder(orderOdooId);
    } catch (e) {
      _errorMessage = 'Lỗi tải dữ liệu: $e';
      logger.e('TimesheetProvider.loadEntries', error: e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addEntry({
    required int orderOdooId,
    required DateTime date,
    required double hours,
    required String description,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.addEntry(
        orderOdooId: orderOdooId,
        date: date,
        hours: hours,
        description: description,
      );
      await loadEntries(orderOdooId);
    } catch (e) {
      _errorMessage = 'Lỗi thêm giờ công: $e';
      logger.e('TimesheetProvider.addEntry', error: e);
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear all provider state (call on logout)
  void clear() {
    _entries = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
