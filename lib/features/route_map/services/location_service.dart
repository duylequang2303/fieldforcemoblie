import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import '../../../core/utils/logger.dart';

/// Service định vị GPS và tính toán khoảng cách.
/// Chỉ dùng trong layer service — không import vào Widget/Provider trực tiếp.
class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  Position? _lastPosition;
  Position? get lastPosition => _lastPosition;

  /// Kiểm tra và yêu cầu quyền định vị. Trả về true nếu được cấp quyền.
  Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Lấy vị trí hiện tại (high accuracy).
  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        logger.w('LocationService: permission denied');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _lastPosition = position;
      return position;
    } catch (e) {
      logger.e('LocationService: getCurrentPosition error', error: e);
      return null;
    }
  }

  /// Stream vị trí liên tục (dùng khi worker đang di chuyển).
  Stream<Position> positionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 20,
      ),
    );
  }

  /// Tính khoảng cách (km) giữa 2 tọa độ theo công thức Haversine.
  double distanceBetween(
    double lat1, double lng1,
    double lat2, double lng2,
  ) {
    const r = 6371.0; // Bán kính Trái Đất (km)
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  /// Tạo URL Google Maps navigation đến tọa độ.
  String buildNavigationUrl(double lat, double lng) {
    return 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving';
  }

  double _toRad(double deg) => deg * math.pi / 180;
}
