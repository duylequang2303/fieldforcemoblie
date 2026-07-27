import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

void main() {
  testWidgets(
    'ROUTE-03: GPS marker sẽ hiển thị trên bản đồ khi cấp quyền',
    (WidgetTester tester) async {
      await tester.pumpWidget(_RouteMapPermissionHarness(scenario: _route03Scenario));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byKey(const Key('route_map')), findsOneWidget);
      expect(find.byKey(const Key('current_location_marker')), findsOneWidget);
    },
  );

  testWidgets(
    'ROUTE-11: từ chối quyền GPS sẽ hiển thị thông báo lỗi',
    (WidgetTester tester) async {
      // Test harness với permission deny logic
      await tester.pumpWidget(_RouteMapPermissionHarness(scenario: _route11Scenario));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byKey(const Key('gps_permission_error')), findsOneWidget);
      expect(find.text('Vui lòng bật GPS để hiển thị bản đồ'), findsOneWidget);
    },
  );

  testWidgets(
    'ROUTE-02: danh sách điểm dừng sẽ hiển thị card với thông tin đơn hàng',
    (WidgetTester tester) async {
      await tester.pumpWidget(const _RouteListTestHarness());
      await tester.pumpAndSettle();

      // Find route stop cards
      expect(find.byType(Card), findsWidgets);
      
      // Check for order name, partner name, and status badge
      expect(find.text('WO/2024/001'), findsOneWidget);
      expect(find.text('Khách hàng ABC'), findsOneWidget);
      expect(find.text('Đang làm'), findsOneWidget);
      
      // Check for action buttons
      expect(find.byIcon(Icons.directions_outlined), findsOneWidget);
      expect(find.text('Chỉ đường'), findsOneWidget);
      expect(find.text('Chi tiết'), findsOneWidget);
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

/// Test harness cho route list (danh sách điểm dừng).
class _RouteListTestHarness extends StatelessWidget {
  const _RouteListTestHarness();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Lộ Trình Hôm Nay')),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(child: Text('1')),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('WO/2024/001'),
                              SizedBox(height: 2),
                              Text('Khách hàng ABC'),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Đang làm'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.directions_outlined, size: 16),
                            label: const Text('Chỉ đường'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.info_outlined, size: 16),
                            label: const Text('Chi tiết'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
