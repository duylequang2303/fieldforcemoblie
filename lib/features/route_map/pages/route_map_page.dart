import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/logger.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../orders/providers/orders_provider.dart';
import '../models/route_stop.dart';
import '../providers/route_provider.dart';
import '../services/location_service.dart';
import '../widgets/route_info_panel.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    final ordersProvider = context.read<OrdersProvider>();
    final routeProvider = context.read<RouteProvider>();

    if (ordersProvider.orders.isEmpty) {
      await ordersProvider.fetchOrders();
    }
    await routeProvider.buildRoute(ordersProvider.orders);
    await routeProvider.refreshLocation();
    routeProvider.startTracking();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RouteProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            title: const Text(
              'Lộ Trình Hôm Nay',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            actions: [
              // Refresh location
              IconButton(
                icon: const Icon(Icons.my_location),
                onPressed: provider.refreshLocation,
                tooltip: 'Cập nhật vị trí',
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              tabs: [
                Tab(
                  text: 'Lộ trình (${provider.stops.length})',
                  icon: const Icon(Icons.list_alt, size: 18),
                ),
                const Tab(
                  text: 'Vị trí tôi',
                  icon: Icon(Icons.location_on, size: 18),
                ),
              ],
            ),
          ),
          body: provider.isLoading
              ? const LoadingOverlay(message: 'Đang xây lộ trình...')
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
                        RouteInfoPanel(
                          stops: provider.stops,
                          onStopTapped: (stop) {
                            _showStopBottomSheet(context, provider, stop);
                          },
                          onNavigateTapped: (stop) {
                            _openNavigation(stop);
                          },
                        ),

                        // Tab 2: Thông tin GPS hiện tại
                        _buildLocationTab(provider),
                      ],
                    ),
        );
      },
    );
  }

  Widget _buildLocationTab(RouteProvider provider) {
    final pos = provider.currentPosition;
    
    if (pos == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_off_outlined,
                size: 64,
                color: AppColors.onSurfaceMuted,
              ),
              const SizedBox(height: 16),
              const Text(
                'Đang lấy vị trí...',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.onSurfaceMuted,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: provider.refreshLocation,
                icon: const Icon(Icons.my_location),
                label: const Text('Lấy vị trí'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    // Show map with worker's location
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(pos.latitude, pos.longitude),
        initialZoom: 16,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.fieldforce_mobile',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: LatLng(pos.latitude, pos.longitude),
              width: 80,
              height: 80,
              child: const Icon(
                Icons.location_on,
                color: AppColors.primary,
                size: 40,
              ),
            ),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stop.orderName,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            if (stop.partnerName != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  stop.partnerName!,
                  style: const TextStyle(color: AppColors.onSurfaceMuted),
                ),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _openNavigation(stop);
                    },
                    icon: const Icon(Icons.navigation_outlined),
                    label: const Text('Dẫn đường'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: stop.status != StopStatus.completed
                        ? () {
                            provider.markStopCompleted(stop.orderOdooId);
                            Navigator.pop(context);
                          }
                        : null,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Hoàn thành'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                  ),
                ),
              ],
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
