import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fieldforce_mobile/core/theme/app_colors.dart';
import 'package:fieldforce_mobile/core/utils/logger.dart';
import 'package:fieldforce_mobile/shared/widgets/error_view.dart';
import 'package:fieldforce_mobile/shared/widgets/loading_overlay.dart';
import 'package:fieldforce_mobile/features/orders/providers/orders_provider.dart';
import 'package:fieldforce_mobile/features/route_map/models/route_stop.dart';
import 'package:fieldforce_mobile/features/route_map/providers/route_provider.dart';
import 'package:fieldforce_mobile/features/route_map/services/location_service.dart';
import 'package:fieldforce_mobile/features/route_map/utils/stop_status_ui.dart';

/// Trang bản đồ lộ trình — hiển thị danh sách điểm đến trong ngày.
/// Dùng RouteInfoPanel (list view) thay vì bản đồ thực tế
/// để tránh phụ thuộc vào Google Maps API key.
class RouteMapPage extends StatefulWidget {
  const RouteMapPage({super.key});

  @override
  State<RouteMapPage> createState() => _RouteMapPageState();
}

class _RouteMapPageState extends State<RouteMapPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  RouteProvider? _routeProvider;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  @override
  void dispose() {
    _routeProvider?.stopTracking();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    if (!mounted) return;

    final ordersProvider = context.read<OrdersProvider>();
    _routeProvider = context.read<RouteProvider>();

    if (ordersProvider.orders.isEmpty) {
      await ordersProvider.fetchOrders();
      if (!mounted) return;
    }

    await _routeProvider!.buildRoute(ordersProvider.orders);
    if (!mounted) return;

    await _routeProvider!.refreshLocation();
    if (!mounted) return;

    _routeProvider!.startTracking();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RouteProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.accentDark,
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Lộ Trình Hôm Nay',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            actions: [
              // Refresh location
              IconButton(
                icon: const Icon(Icons.my_location_outlined),
                onPressed: provider.refreshLocation,
                tooltip: 'Cập nhật vị trí',
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                        color: Colors.white.withOpacity(0.1), width: 1),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withOpacity(0.6),
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                  tabs: [
                    Tab(
                      text: 'Lộ trình (${provider.stops.length})',
                      icon: const Icon(Icons.list_alt_outlined, size: 20),
                    ),
                    const Tab(
                      text: 'Vị trí',
                      icon: Icon(Icons.location_on_outlined, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: provider.isLoading
              ? const LoadingOverlay(message: 'Đang xây dựng lộ trình...')
              : provider.errorMessage != null
                  ? ErrorView(
                      message: provider.errorMessage!,
                      onRetry: () {
                        provider.clearError();
                        _initialize();
                      },
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        // Tab 1: Danh sách điểm dừng
                        _buildRouteListTab(context, provider),

                        // Tab 2: Thông tin GPS hiện tại
                        _buildLocationTab(provider),
                      ],
                    ),
        );
      },
    );
  }

  Widget _buildRouteListTab(BuildContext context, RouteProvider provider) {
    if (provider.stops.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.accentMuted,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.route_outlined,
                size: 40,
                color: AppColors.accent.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Chưa có lộ trình',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Lộ trình sẽ được tạo dựa trên các đơn của bạn',
              style: TextStyle(fontSize: 14, color: AppColors.onSurfaceMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: provider.stops.length,
      itemBuilder: (context, i) => _RouteStopCard(
        stop: provider.stops[i],
        index: i + 1,
        onTap: () => _showStopBottomSheet(context, provider, provider.stops[i]),
        onNavigate: () => _openNavigation(provider.stops[i]),
      ),
    );
  }

  Widget _buildLocationTab(RouteProvider provider) {
    final pos = provider.currentPosition;
    final colorScheme = Theme.of(context).colorScheme;

    if (pos == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.accentMuted,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.location_off_outlined,
                size: 40,
                color: AppColors.accent.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Đang lấy vị trí...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vui lòng bật GPS để hiển thị bản đồ',
              style: TextStyle(fontSize: 14, color: AppColors.onSurfaceMuted),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: provider.refreshLocation,
              icon: const Icon(Icons.refresh_outlined),
              label: const Text('Làm mới vị trí'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => LocationService.instance.openLocationSettings(),
              icon: const Icon(Icons.settings_outlined),
              label: const Text('Cài đặt GPS'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.onSurfaceVariant,
                side: BorderSide(color: colorScheme.outline, width: 1),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Show map with worker's location and route stops
    final routePoints = provider.stops
        .where((s) => s.latitude != null && s.longitude != null)
        .map((s) => LatLng(s.latitude!, s.longitude!))
        .toList();

    // Fit map to show all stops + current location
    final allPoints = [
      ...routePoints,
      LatLng(pos.latitude, pos.longitude),
    ];

    CameraFit? initialCameraFit;
    if (routePoints.isNotEmpty) {
      final bounds = LatLngBounds.fromPoints(allPoints);
      initialCameraFit = CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(50),
      );
    }

    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(pos.latitude, pos.longitude),
        initialZoom: 16.0,
        initialCameraFit: initialCameraFit,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.fieldforce_mobile',
        ),
        if (routePoints.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: routePoints,
                color: colorScheme.primary,
                strokeWidth: 4.0,
                strokeCap: StrokeCap.round,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            // Current position marker
            Marker(
              point: LatLng(pos.latitude, pos.longitude),
              width: 80,
              height: 80,
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            // Route stop markers
            ...provider.stops
                .where((s) => s.latitude != null && s.longitude != null)
                .map((stop) {
              return Marker(
                point: LatLng(stop.latitude!, stop.longitude!),
                width: 40,
                height: 40,
                child: Container(
                  decoration: BoxDecoration(
                    color: StopStatusUI.color(stop.status),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: stop.status == StopStatus.completed
                      ? const Icon(Icons.check, size: 20, color: Colors.white)
                      : Center(
                          child: Text(
                            '${stop.sequence + 1}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  void _showStopBottomSheet(
    BuildContext context,
    RouteProvider provider,
    RouteStop stop,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order name with badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stop.orderName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: AppColors.onSurface,
                              ),
                            ),
                            if (stop.partnerName != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                stop.partnerName!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.onSurfaceMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: StopStatusUI.color(stop.status)
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color:
                                  StopStatusUI.color(stop.status).withOpacity(0.3)),
                        ),
                        child: Text(
                          StopStatusUI.label(stop.status),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: StopStatusUI.color(stop.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (stop.locationName != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 16, color: AppColors.accent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            stop.locationName!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.onSurfaceMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (stop.estimatedMinutes != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.schedule_outlined,
                            size: 16, color: AppColors.info),
                        const SizedBox(width: 8),
                        Text(
                          'ETA: ${stop.estimatedMinutes} phút',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.onSurfaceMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _openNavigation(stop);
                          },
                          icon: const Icon(Icons.directions_outlined),
                          label: const Text('Chỉ đường'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.info,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                          Expanded(
                        child: ElevatedButton.icon(
                          onPressed: stop.status != StopStatus.completed
                              ? () async {
                                  final ok = await provider.markStopCompleted(stop.orderOdooId);
                                  if (mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(ok
                                            ? 'Đã hoàn thành'
                                            : 'Hoàn thành thất bại'),
                                      ),
                                    );
                                  }
                                }
                              : null,
                          icon: const Icon(Icons.check_circle_outlined),
                          label: const Text('Hoàn thành'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            disabledBackgroundColor:
                                AppColors.onSurfaceWeak.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openNavigation(RouteStop stop) async {
    if (stop.latitude == null || stop.longitude == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Điểm đến chưa có tọa độ GPS')),
        );
      }
      return;
    }
    final url = LocationService.instance
        .buildNavigationUrl(stop.latitude!, stop.longitude!);
    final uri = Uri.parse(url);
    try {
      final canLaunch = await canLaunchUrl(uri);
      if (canLaunch) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: mở bằng Chrome
        await launchUrl(uri, mode: LaunchMode.inAppWebView);
      }
    } catch (e) {
      logger.e('Cannot launch navigation URL', error: e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể mở bản đồ: $e')),
        );
      }
    }
  }
}

/// Card widget hiển thị một điểm dừng trong lộ trình.
class _RouteStopCard extends StatelessWidget {
  final RouteStop stop;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onNavigate;

  const _RouteStopCard({
    required this.stop,
    required this.index,
    required this.onTap,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.onSurface.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: sequence badge + order name + status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sequence badge
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.accent.withOpacity(0.3),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$index',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Order info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stop.orderName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppColors.onSurface,
                          ),
                        ),
                        if (stop.partnerName != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            stop.partnerName!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.onSurfaceMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status badge
                    Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: StopStatusUI.color(stop.status).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: StopStatusUI.color(stop.status).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      StopStatusUI.label(stop.status),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: StopStatusUI.color(stop.status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Location & distance info
              if (stop.locationName != null || stop.distanceFromPrev != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (stop.locationName != null) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              stop.locationName!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.onSurfaceMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (stop.distanceFromPrev != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.route_outlined,
                            size: 14,
                            color: AppColors.info,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${stop.distanceFromPrev!.toStringAsFixed(1)} km từ điểm trước',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.onSurfaceMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (stop.estimatedMinutes != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_outlined,
                            size: 14,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'ETA: ${stop.estimatedMinutes} phút',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.onSurfaceMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                  ],
                ),
              // Quick action button
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onNavigate,
                      icon: const Icon(Icons.directions_outlined, size: 16),
                      label: const Text('Chỉ đường'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.info,
                        side: const BorderSide(color: AppColors.info, width: 1),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.info_outlined, size: 16),
                      label: const Text('Chi tiết'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
