import 'package:flutter/material.dart';
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                provider.isTracking ? Icons.gps_fixed : Icons.gps_not_fixed,
                size: 48,
                color: provider.isTracking
                    ? AppColors.primary
                    : AppColors.onSurfaceMuted,
              ),
            ),
            const SizedBox(height: 24),
            if (pos != null) ...[
              _GpsInfoTile(label: 'Vĩ độ', value: pos.latitude.toStringAsFixed(6)),
              _GpsInfoTile(label: 'Kinh độ', value: pos.longitude.toStringAsFixed(6)),
              _GpsInfoTile(
                label: 'Độ chính xác',
                value: '±${pos.accuracy.toStringAsFixed(0)}m',
              ),
              _GpsInfoTile(
                label: 'Tốc độ',
                value: '${(pos.speed * 3.6).toStringAsFixed(1)} km/h',
              ),
            ] else ...[
              const Text(
                'Chưa có vị trí GPS',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.onSurfaceMuted,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: provider.refreshLocation,
                icon: const Icon(Icons.my_location),
                label: const Text('Lấy vị trí'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
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
    if (stop.latitude == null || stop.longitude == null) return;
    final url = LocationService.instance
        .buildNavigationUrl(stop.latitude!, stop.longitude!);
    try {
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      logger.e('Cannot launch navigation URL', error: e);
    }
  }
}

class _GpsInfoTile extends StatelessWidget {
  const _GpsInfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.onSurfaceMuted)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
