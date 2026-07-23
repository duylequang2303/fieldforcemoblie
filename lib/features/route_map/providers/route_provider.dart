import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/utils/logger.dart';
import '../../orders/models/fsm_order.dart';
import '../models/route_stop.dart';
import '../services/location_service.dart';

/// State management cho bản đồ lộ trình.
class RouteProvider extends ChangeNotifier {
  final _locationService = LocationService.instance;

  List<RouteStop> _stops = [];
  Position? _currentPosition;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isTracking = false;

  List<RouteStop> get stops => List.unmodifiable(_stops);
  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isTracking => _isTracking;

  /// Xây lộ trình từ danh sách đơn dịch vụ.
  /// Sắp xếp theo scheduledDateStart.
  Future<void> buildRoute(List<FsmOrder> orders) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final sorted = [...orders]
        ..sort((a, b) {
          if (a.scheduledDateStart == null) return 1;
          if (b.scheduledDateStart == null) return -1;
          return a.scheduledDateStart!.compareTo(b.scheduledDateStart!);
        });

      _stops = sorted.asMap().entries.map((entry) {
        final i = entry.key;
        final order = entry.value;
        return RouteStop.fromOrder(
          orderOdooId: order.odooId,
          orderName: order.name,
          sequence: i,
          partnerName: order.partnerName,
          locationName: order.locationName,
          lat: order.locationLat,
          lng: order.locationLng,
        );
      }).toList();

      // Tính khoảng cách giữa các điểm
      _calculateDistances();
    } on OdooApiException catch (e) {
      _errorMessage = e.message;
      logger.e('RouteProvider.buildRoute', error: e);
    } catch (e) {
      _errorMessage = 'Lỗi xây lộ trình: $e';
      logger.e('RouteProvider.buildRoute', error: e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Bắt đầu theo dõi vị trí GPS realtime.
  void startTracking() {
    _isTracking = true;
    notifyListeners();

    _locationService.positionStream().listen(
      (position) {
        _currentPosition = position;
        notifyListeners();
      },
      onError: (Object e) {
        logger.w('RouteProvider: GPS stream error', error: e);
      },
    );
  }

  /// Lấy vị trí hiện tại một lần.
  Future<void> refreshLocation() async {
    try {
      _currentPosition = await _locationService.getCurrentPosition();
      notifyListeners();
    } catch (e) {
      logger.w('RouteProvider.refreshLocation', error: e);
    }
  }

  /// Đánh dấu một điểm dừng là đã hoàn thành.
  void markStopCompleted(int orderOdooId) {
    final idx = _stops.indexWhere((s) => s.orderOdooId == orderOdooId);
    if (idx != -1) {
      _stops[idx]
        ..status = StopStatus.completed
        ..completedAt = DateTime.now();

      // Tự động set điểm tiếp theo là current
      if (idx + 1 < _stops.length) {
        _stops[idx + 1].status = StopStatus.current;
      }
      notifyListeners();
    }
  }

  /// Tính khoảng cách giữa các điểm dừng liên tiếp.
  void _calculateDistances() {
    for (int i = 1; i < _stops.length; i++) {
      final prev = _stops[i - 1];
      final curr = _stops[i];
      if (prev.latitude != null &&
          prev.longitude != null &&
          curr.latitude != null &&
          curr.longitude != null) {
        curr.distanceFromPrev = _locationService.distanceBetween(
          prev.latitude!, prev.longitude!,
          curr.latitude!, curr.longitude!,
        );
      }
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
