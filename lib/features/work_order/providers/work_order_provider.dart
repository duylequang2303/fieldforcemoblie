import 'package:flutter/foundation.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/api/odoo_session_manager.dart';
import '../../../core/api/session_guard.dart';
import '../../../core/utils/logger.dart';
import '../models/work_report.dart';
import '../services/work_order_service.dart';
import '../../orders/models/fsm_order.dart';

class WorkOrderProvider extends ChangeNotifier with SessionGuard {
  WorkOrderProvider._internal() : _service = WorkOrderService.instance;
  static final WorkOrderProvider instance = WorkOrderProvider._internal();

  final WorkOrderService _service;

  WorkReport? _report;
  FsmOrder? _order;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSubmitting = false;

  WorkReport? get report => _report;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSubmitting => _isSubmitting;
  bool get hasSignature => _report?.customerSignaturePath != null;
  FsmOrder? get order => _order;

  bool get isComplete {
    if (_report == null || _report!.workDone.trim().isEmpty) return false;

    // Check photo requirements
    if (_order?.requirePhoto == true) {
      if (_report!.photoPaths.isEmpty && _report!.syncedPhotoPaths.isEmpty) {
        return false;
      }
    }

    // Check signature requirements
    if (_order?.requireSignature == true) {
      return _report!.customerSignaturePath != null;
    }

    return true;
  }

  Future<void> loadReport(int orderOdooId) async {
    final sessionToken = currentSessionToken;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final report = await _service.getOrCreateReport(orderOdooId);
      final order = await _service.getOrder(orderOdooId);
      if (!isSameSession(sessionToken)) return;
      _report = report;
      _order = order;
    } catch (e) {
      if (!isSameSession(sessionToken)) return;
      _errorMessage = 'Lỗi tải báo cáo: $e';
      logger.e('WorkOrderProvider.loadReport', error: e);
    } finally {
      if (isSameSession(sessionToken)) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void updateWorkDone(String text) {
    if (_report == null) return;
    _report!.workDone = text;
    notifyListeners();
  }

  void updateProblems(String? text) {
    if (_report == null) return;
    _report!.problemsFound = text?.isEmpty == true ? null : text;
    notifyListeners();
  }

  void addPhoto(String path) {
    if (_report == null) return;
    _report!.photoPaths = [..._report!.photoPaths, path];
    _report!.isPendingSync = true;
    notifyListeners();
  }

  void removePhoto(int index) {
    if (_report == null) return;
    final list = [..._report!.photoPaths]..removeAt(index);
    _report!.photoPaths = list;
    _report!.isPendingSync = true;
    notifyListeners();
  }

  void setSignature(String signaturePath, String customerName) {
    if (_report == null) return;
    _report!
      ..customerSignaturePath = signaturePath
      ..customerName = customerName
      ..signedAt = DateTime.now();
    notifyListeners();
  }

  Future<void> saveLocally() async {
    if (_report == null) return;
    final sessionToken = currentSessionToken;
    if (sessionToken == null) return;
    final currentUserId = OdooSessionManager.instance.currentUserId;
    if (currentUserId == null) return;
    try {
      await _service.saveReport(_report!, currentUserId);
    } catch (e) {
      if (!isSameSession(sessionToken)) return;
      _errorMessage = 'Lỗi lưu báo cáo: $e';
      notifyListeners();
    }
  }

  Future<bool> submitReport() async {
    if (_report == null || !isComplete) return false;
    final sessionToken = currentSessionToken;
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _service.submitReport(_report!);
      if (!isSameSession(sessionToken)) return false;
      return true;
    } on OdooApiException catch (e) {
      if (!isSameSession(sessionToken)) return false;
      _errorMessage = e.message;
      logger.e('WorkOrderProvider.submitReport', error: e);
      return false;
    } finally {
      if (isSameSession(sessionToken)) {
        _isSubmitting = false;
        notifyListeners();
      }
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear all provider state (call on logout)
  void clear() {
    _report = null;
    _order = null;
    _isLoading = false;
    _errorMessage = null;
    _isSubmitting = false;
    notifyListeners();
  }
}
