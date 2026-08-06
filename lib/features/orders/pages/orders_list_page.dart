import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../models/fsm_order.dart';
import '../providers/orders_provider.dart';
import '../widgets/order_card.dart';

/// Trang danh sách đơn dịch vụ (Home screen của Worker).
class OrdersListPage extends StatefulWidget {
  const OrdersListPage({super.key});

  @override
  State<OrdersListPage> createState() => _OrdersListPageState();
}

class _OrdersListPageState extends State<OrdersListPage> {
  String _searchQuery = '';
  FsmOrderStage? _filterStage;

  @override
  void initState() {
    super.initState();
    // Fetch ngay khi mở trang
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrdersProvider>(
      builder: (context, provider, _) {
        final filtered = _applyFilter(provider.orders);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  _buildAppBar(context, provider, innerBoxIsScrolled),
                ],
                body: provider.isLoading
                    ? const LoadingOverlay(message: 'Đang tải đơn dịch vụ...')
                    : (provider.errorMessage != null && provider.orders.isEmpty)
                        ? ErrorView(
                            message: provider.errorMessage!,
                            onRetry: () {
                              provider.clearError();
                              provider.fetchOrders();
                            },
                          )
                        : filtered.isEmpty
                            ? _buildEmptyState()
                            : RefreshIndicator(
                                onRefresh: provider.fetchOrders,
                                color: AppColors.primary,
                                child: ListView.builder(
                                  padding:
                                      const EdgeInsets.only(top: 8, bottom: 80),
                                  itemCount: filtered.length,
                                  itemBuilder: (context, i) =>
                                      OrderCard(order: filtered[i]),
                                ),
                              ),
              ),
              // Offline banner nổi trên cùng
              if (provider.isOffline) const OfflineBanner(),
            ],
          ),
          floatingActionButton: provider.isOffline
              ? null
              : FloatingActionButton.extended(
                  heroTag: 'fab_refresh',
                  onPressed: provider.fetchOrders,
                  backgroundColor: AppColors.primary,
                  icon: const Icon(Icons.sync, color: Colors.white),
                  label: const Text(
                    'Làm mới',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
        );
      },
    );
  }

  SliverAppBar _buildAppBar(
    BuildContext context,
    OrdersProvider provider,
    bool innerBoxIsScrolled,
  ) {
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      elevation: innerBoxIsScrolled ? 4 : 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 52),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Đơn Dịch Vụ',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            Text(
              '${provider.orders.length} đơn',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryDark, AppColors.primaryLight],
            ),
          ),
          child: const SafeArea(
            child: Padding(
              padding: EdgeInsets.only(right: 16, top: 8),
              child: Align(
                alignment: Alignment.topRight,
                child: Icon(Icons.engineering, size: 60, color: Colors.white24),
              ),
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(44),
        child: _buildFilterBar(),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Row(
        children: [
          // Search field
          Expanded(
            child: SizedBox(
              height: 36,
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Tìm theo mã, khách hàng...',
                  hintStyle:
                      const TextStyle(fontSize: 13, color: Colors.black45),
                  prefixIcon:
                      const Icon(Icons.search, size: 18, color: Colors.black45),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Filter by stage
          _StageFilterButton(
            selected: _filterStage,
            onChanged: (stage) => setState(() => _filterStage = stage),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.assignment_outlined,
              size: 72, color: AppColors.onSurfaceMuted.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          const Text(
            'Không có đơn nào',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceMuted,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Kéo xuống để tải lại',
            style: TextStyle(fontSize: 13, color: AppColors.onSurfaceMuted),
          ),
        ],
      ),
    );
  }

  List<FsmOrder> _applyFilter(List<FsmOrder> orders) {
    return orders.where((o) {
      // Ẩn các đơn hàng đã bị skip khỏi UI chính
      if (o.isSkipped) return false;

      final matchStage = _filterStage == null || o.stage == _filterStage;
      final q = _searchQuery.toLowerCase();
      final matchSearch = q.isEmpty ||
          o.name.toLowerCase().contains(q) ||
          (o.partnerName?.toLowerCase().contains(q) ?? false) ||
          (o.locationName?.toLowerCase().contains(q) ?? false);
      return matchStage && matchSearch;
    }).toList();
  }
}

class _StageFilterButton extends StatelessWidget {
  const _StageFilterButton({required this.selected, required this.onChanged});

  final FsmOrderStage? selected;
  final ValueChanged<FsmOrderStage?> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<FsmOrderStage?>(
      initialValue: selected,
      onSelected: onChanged,
      itemBuilder: (_) => [
        const PopupMenuItem(value: null, child: Text('Tất cả')),
        const PopupMenuItem(value: FsmOrderStage.draft, child: Text('Mới')),
        const PopupMenuItem(
            value: FsmOrderStage.inProgress, child: Text('Đang thực hiện')),
        const PopupMenuItem(
            value: FsmOrderStage.done, child: Text('Hoàn thành')),
        const PopupMenuItem(
            value: FsmOrderStage.cancelled, child: Text('Đã huỷ')),
      ],
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: selected != null ? Colors.white : Colors.white30,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              Icons.filter_list,
              size: 16,
              color: selected != null ? AppColors.primary : Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              'Lọc',
              style: TextStyle(
                fontSize: 13,
                color: selected != null ? AppColors.primary : Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
