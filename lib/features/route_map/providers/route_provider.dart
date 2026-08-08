import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fieldforce_mobile/core/api/api_exception.dart';
import 'package:fieldforce_mobile/core/utils/logger.dart';
import 'package:fieldforce_mobile/features/orders/models/fsm_order.dart';
import 'package:fieldforce_mobile/features/orders/providers/orders_provider.dart';
import 'package:fieldforce_mobile/features/route_map/models/route_stop.dart';
import 'package:fieldforce_mobile/features/route_map/services/location_service.dart';

/// Kết quả validate check-in: cho phép hay từ chối + lý do
class CheckInValidationResult {
  final bool allowed;
  final String? reason;

  const CheckInValidationResult.allowed() : allowed = true, reason = null;
  const CheckInValidationResult.denied(this.reason) : allowed = false;

  static CheckInValidationResult allow() => const CheckInValidationResult.allowed();
  static CheckInValidationResult deny(String reason) => CheckInValidationResult.denied(reason);
}

/// State management cho bản đồ lộ trình.
class RouteProvider extends ChangeNotifier {
  RouteProvider({LocationService? locationService, required OrdersProvider ordersProvider})
      : _locationService = locationService ?? LocationService.instance,
        _ordersProvider = ordersProvider;

  final LocationService _locationService;
  final OrdersProvider _ordersProvider;

  List<RouteStop> _stops = [];
  Position? _currentPosition;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isTracking = false;
  StreamSubscription<Position>? _positionSubscription;

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
      // Deduplicate orders by odooId (in case same order fetched from multiple domains)
      final uniqueOrders = <int, FsmOrder>{};
      for (final order in orders) {
        if (!uniqueOrders.containsKey(order.odooId)) {
          uniqueOrders[order.odooId] = order;
        }
      }

      final sorted = uniqueOrders.values.toList()..sort((a, b) {
          final seqA = a.routeSequence ?? 9999;
          final seqB = b.routeSequence ?? 9999;
          return seqA.compareTo(seqB);
        });

      _stops = sorted.asMap().entries.map((entry) {
        final i = entry.key;
        final order = entry.value;
        return RouteStop.fromOrder(order, i);
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

    _positionSubscription?.cancel();
    _positionSubscription = _locationService.positionStream().listen(
      (position) {
        _currentPosition = position;
        notifyListeners();
      },
      onError: (Object e) {
        logger.w('RouteProvider: GPS stream error', error: e);
      },
    );
  }

  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _isTracking = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
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
  /// Returns true if local state was updated successfully.
  Future<bool> markStopCompleted(int orderOdooId) async {
    final idx = _stops.indexWhere((s) => s.orderOdooId == orderOdooId);
    if (idx == -1) return false;

    try {
      await _ordersProvider.updateOrderToDone(orderOdooId);
    } catch (e) {
      logger.w('RouteProvider.markStopCompleted: error updating order', error: e);
      _errorMessage = 'Không thể đồng bộ hoàn thành: $e';
      notifyListeners();
      return false;
    }

    _stops[idx]
      ..status = StopStatus.completed
      ..completedAt = DateTime.now();

    // Tự động set điểm tiếp theo là current
    if (idx + 1 < _stops.length) {
      _stops[idx + 1].status = StopStatus.current;
    }

    _errorMessage = null;
    notifyListeners();
    return true;
  }

  /// Tính khoảng cách giữa các điểm dừng liên tiếp.
  void _calculateDistances() {
    const double avgSpeedKmh = 30.0;

    for (int i = 1; i < _stops.length; i++) {
      final prev = _stops[i - 1];
      final curr = _stops[i];
      if (prev.latitude != null &&
          prev.longitude != null &&
          curr.latitude != null &&
          curr.longitude != null) {
        final distanceKm = _locationService.distanceBetween(
          prev.latitude!,
          prev.longitude!,
          curr.latitude!,
          curr.longitude!,
        );
        curr.distanceFromPrev = distanceKm;
        curr.estimatedMinutes = ((distanceKm / avgSpeedKmh) * 60).round();
      }
    }

    if (_stops.isNotEmpty) {
      int? cumulative = 0;
      _stops[0].estimatedMinutes = 0;

      for (int i = 1; i < _stops.length; i++) {
        final segmentMinutes = _stops[i].estimatedMinutes;
        cumulative = (cumulative != null && segmentMinutes != null)
            ? cumulative + segmentMinutes
            : null;
        _stops[i].estimatedMinutes = cumulative;
      }
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Kiểm tra xem nhân viên có được phép check-in tại order này không
  /// dựa trên thứ tự ưu tiên Optimal Route, GPS location và deadline.
  ///
  /// Logic:
  /// 1. Không có trong lộ trình -> Cho phép (true)
  /// 2. Route state = 'draft' -> Bỏ qua enforcement (true)
  /// 3. GPS validation: Nếu worker cách location > 500m -> Không cho phép
  /// 4. Date validation: Chỉ cho phép check-in đơn hôm nay hoặc quá khứ (không cho phép làm đơn tương lai)
  /// 5. Sequential check: Phải hoàn thành các điểm trước trong route 'planned'/'done'
  CheckInValidationResult checkInValidation(
    int orderOdooId, {
    Position? currentLocation,
    double maxDistanceMeters = 500.0, // Default 500m
    bool enforceDateConstraint = true, // Mặc định bật ràng buộc ngày
  }) {
    final stopIdx = _stops.indexWhere((s) => s.orderOdooId == orderOdooId);
    if (stopIdx == -1) return CheckInValidationResult.allow(); // Không có trong lộ trình thì cho phép

    final currentStop = _stops[stopIdx];
    final routeState = currentStop.routeState;

    // Route state = 'draft' -> Bỏ qua enforcement (thường là route chưa được lên lịch)
    if (routeState == 'draft') {
      return CheckInValidationResult.allow();
    }

    // GPS validation: Kiểm tra khoảng cách đến location
    if (currentLocation != null &&
        currentStop.latitude != null &&
        currentStop.longitude != null) {
      final distance = _locationService.distanceBetween(
        currentLocation.latitude,
        currentLocation.longitude,
        currentStop.latitude!,
        currentStop.longitude!,
      );

      // Nếu cách xa hơn 500m -> Không cho phép check-in (strict enforcement)
      if (distance * 1000 > maxDistanceMeters) {
        logger.w(
            'RouteProvider.checkInValidation: Worker quá xa location (${distance}km > ${maxDistanceMeters / 1000}km)');
        return CheckInValidationResult.deny('Bạn đang cách địa điểm quá xa (>${(maxDistanceMeters / 1000).toInt()}km). Hãy đến gần hơn để check-in.');
      }
    }

    // Date validation: Kiểm tra scheduled_date_start
    // Chỉ cho phép check-in đơn hôm nay hoặc quá khứ, KHÔNG cho phép đơn tương lai
    if (enforceDateConstraint && currentStop.scheduledDateStart != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final orderDate = DateTime(
          currentStop.scheduledDateStart!.year,
          currentStop.scheduledDateStart!.month,
          currentStop.scheduledDateStart!.day);
      
      if (orderDate.isAfter(today)) {
        logger.w(
            'RouteProvider.checkInValidation: Không cho phép check-in đơn tương lai (scheduled: ${orderDate.toIso8601String()})');
        return CheckInValidationResult.deny('Đơn này được lên lịch cho ngày ${DateFormat('dd/MM/yyyy', 'vi').format(orderDate)}. Chỉ được làm đơn hôm nay hoặc các đơn quá khứ.');
      }
    }

    // Sequential check: Phải hoàn thành các điểm trước trong route 'planned'/'done'
    // Route đã hoàn thành ('done') -> Không cho phép check-in bất kỳ điểm nào
    if (routeState == 'done') {
      logger.w('RouteProvider.checkInValidation: Route đã hoàn thành');
      return CheckInValidationResult.deny('Lộ trình này đã hoàn thành.');
    }

    // Kiểm tra tất cả các điểm trước đó (có sequence < current)
    for (int i = 0; i < stopIdx; i++) {
      final prev = _stops[i];
      // Nếu có điểm trước nào chưa hoàn thành hoặc chưa bị bỏ qua -> Không cho phép check-in
      if (prev.status != StopStatus.completed &&
          prev.status != StopStatus.skipped) {
        logger.w(
            'RouteProvider.checkInValidation: Điểm trước (${prev.orderName}) chưa hoàn thành');
        return CheckInValidationResult.deny('Bạn phải hoàn thành "${prev.orderName}" trước.');
      }
    }

    return CheckInValidationResult.allow();
  }

  /// @deprecated Use checkInValidation instead
  @Deprecated('Use checkInValidation for detailed error messages')
  bool isAllowedToCheckIn(
    int orderOdooId, {
    Position? currentLocation,
    double maxDistanceMeters = 500.0,
    bool enforceDateConstraint = true,
  }) {
    return checkInValidation(
      orderOdooId,
      currentLocation: currentLocation,
      maxDistanceMeters: maxDistanceMeters,
      enforceDateConstraint: enforceDateConstraint,
    ).allowed;
  }
}
