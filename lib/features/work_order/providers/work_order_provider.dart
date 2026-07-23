import 'package:flutter/foundation.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/utils/logger.dart';
import '../models/work_report.dart';
import '../services/work_order_service.dart';

class WorkOrderProvider extends ChangeNotifier {
  final _service = WorkOrderService.instance;

  WorkReport? _report;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSubmitting = false;

  WorkReport? get report => _report;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSubmitting => _isSubmitting;
  bool get hasSignature => _report?.customerSignaturePath != null;
  bool get isComplete =>
      _report != null &&
      _report!.workDone.isNotEmpty &&
      _report!.customerSignaturePath != null;

  Future<void> loadReport(int orderOdooId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _report = await _service.getOrCreateReport(orderOdooId);
    } catch (e) {
      _errorMessage = 'Lỗi tải báo cáo: $e';
      logger.e('WorkOrderProvider.loadReport', error: e);
    } finally {
      _isLoading = false;
      notifyListeners();
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
    notifyListeners();
  }

  void removePhoto(int index) {
    if (_report == null) return;
    final list = [..._report!.photoPaths]..removeAt(index);
    _report!.photoPaths = list;
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
    try {
      await _service.saveReport(_report!);
    } catch (e) {
      _errorMessage = 'Lỗi lưu báo cáo: $e';
      notifyListeners();
    }
  }

  Future<bool> submitReport() async {
    if (_report == null || !isComplete) return false;
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _service.submitReport(_report!);
      return true;
    } on OdooApiException catch (e) {
      _errorMessage = e.message;
      logger.e('WorkOrderProvider.submitReport', error: e);
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
