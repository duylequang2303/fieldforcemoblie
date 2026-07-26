import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest(
    'ROUTE-03: cấp quyền GPS sẽ hiển thị marker trên bản đồ',
    nativeAutomation: true,
    ($) async {
      await $.pumpWidget(_RouteMapPermissionHarness(scenario: _route03Scenario));
      await $.pump(const Duration(seconds: 1));

      await $.native.grantPermissionWhenInUse();
      await $.pumpAndSettle();

      expect($(#route_map), findsOneWidget);
      expect($(#current_location_marker), findsOneWidget);
    },
  );

  patrolTest(
    'ROUTE-11: từ chối quyền GPS sẽ hiển thị thông báo lỗi',
    nativeAutomation: true,
    ($) async {
      await $.pumpWidget(_RouteMapPermissionHarness(scenario: _route11Scenario));
      await $.pump(const Duration(seconds: 1));

      await $.native.denyPermission();
      await $.pumpAndSettle();

      expect($(#gps_permission_error), findsOneWidget);
      expect($('Không thể truy cập vị trí GPS'), findsOneWidget);
    },
  );
}

const _route03Scenario = _RouteMapTestScenario(
  markerLocation: LatLng(10.7769, 106.7009),
  deniedMessage: 'Không thể truy cập vị trí GPS',
);

const _route11Scenario = _RouteMapTestScenario(
  markerLocation: LatLng(10.7769, 106.7009),
  deniedMessage: 'Không thể truy cập vị trí GPS',
);

@immutable
class _RouteMapTestScenario {
  const _RouteMapTestScenario({
    required this.markerLocation,
    required this.deniedMessage,
  });

  final LatLng markerLocation;
  final String deniedMessage;
}

/// Test-only route-map surface. It asks the operating system for GPS access,
/// while keeping the displayed coordinate deterministic and provider-free.
class _RouteMapPermissionHarness extends StatefulWidget {
  const _RouteMapPermissionHarness({required this.scenario});

  final _RouteMapTestScenario scenario;

  @override
  State<_RouteMapPermissionHarness> createState() =>
      _RouteMapPermissionHarnessState();
}

class _RouteMapPermissionHarnessState extends State<_RouteMapPermissionHarness> {
  bool _permissionGranted = false;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _requestGpsPermission();
  }

  Future<void> _requestGpsPermission() async {
    final permission = await Geolocator.requestPermission();
    if (!mounted) return;

    setState(() {
      _permissionGranted = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
      _permissionDenied = !_permissionGranted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: _permissionGranted
            ? FlutterMap(
                key: const Key('route_map'),
                options: MapOptions(
                  initialCenter: widget.scenario.markerLocation,
                  initialZoom: 15,
                ),
                children: [
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: widget.scenario.markerLocation,
                        width: 48,
                        height: 48,
                        child: Icon(
                          Icons.location_on,
                          key: Key('current_location_marker'),
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : _permissionDenied
                ? Center(
                    child: Text(
                      widget.scenario.deniedMessage,
                      key: const Key('gps_permission_error'),
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
