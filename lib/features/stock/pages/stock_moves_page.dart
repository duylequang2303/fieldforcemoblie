import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../models/stock_move.dart';
import '../providers/stock_provider.dart';
import '../../../shared/widgets/icon_empty_state.dart';

/// Trang danh sách vật tư đã xuất kho cho một đơn dịch vụ.
class StockMovesPage extends StatefulWidget {
  const StockMovesPage({super.key, required this.orderId});

  final int orderId;

  @override
  State<StockMovesPage> createState() => _StockMovesPageState();
}

class _StockMovesPageState extends State<StockMovesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StockProvider>().loadMoves(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StockProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.accentDark,
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Vật Tư / Thiết Bị',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            actions: [
              // Total items badge
              if (provider.moves.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.inventory_2_outlined,
                              size: 16, color: Colors.white.withOpacity(0.8)),
                          const SizedBox(width: 6),
                          Text(
                            '${provider.moves.length} dòng',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: provider.isLoading
              ? const LoadingOverlay(message: 'Đang tải...')
              : provider.errorMessage != null
                  ? ErrorView(
                      message: provider.errorMessage!,
                      onRetry: () {
                        provider.clearError();
                        provider.loadMoves(widget.orderId);
                      },
                    )
                  : provider.moves.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          itemCount: provider.moves.length,
                          itemBuilder: (context, i) =>
                              _MoveCard(move: provider.moves[i]),
                        ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'fab_scanner',
            onPressed: () async {
              await context.push('${RouteNames.scanner}/${widget.orderId}');
              if (context.mounted) {
                context.read<StockProvider>().loadMoves(widget.orderId);
              }
            },
            backgroundColor: AppColors.accent,
            elevation: 4,
            icon: const Icon(Icons.qr_code_scanner_rounded,
                color: Colors.white, size: 22),
            label: const Text(
              'Quét vật tư',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return IconEmptyState(
      icon: Icons.inventory_2_outlined,
      title: 'Chưa có vật tư nào',
      subtitle: 'Nhấn nút "Quét vật tư" bên dưới để bắt đầu',
      iconColor: AppColors.accent.withOpacity(0.6),
      iconBackgroundColor: AppColors.accentMuted,
    );
  }
}

class _MoveCard extends StatelessWidget {
  const _MoveCard({required this.move});

  final StockMove move;

  // Color based on move type
  Color get moveTypeColor =>
      move.moveType == MoveType.out ? AppColors.error : AppColors.success;
  String get moveTypeLabel => move.moveType == MoveType.out ? 'Xuất' : 'Nhập';

  // Calculate progress ratio
  double get progressRatio {
    if (move.demandQty <= 0) return 0;
    return (move.doneQty / move.demandQty).clamp(0, 1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: move.isPendingSync
              ? AppColors.warning.withOpacity(0.3)
              : AppColors.divider,
          width: move.isPendingSync ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
            // Top row: Product info and move type badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: moveTypeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    move.moveType == MoveType.out
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    color: moveTypeColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product name
                      Text(
                        move.productName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Product code/barcode
                      if (move.productCode != null &&
                          move.productCode!.isNotEmpty)
                        Row(
                          children: [
                            Icon(Icons.qr_code_2,
                                size: 14, color: AppColors.onSurfaceMuted),
                            const SizedBox(width: 6),
                            Text(
                              move.productCode!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.onSurfaceMuted,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Move type badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: moveTypeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: moveTypeColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    moveTypeLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: moveTypeColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Progress bar
            Container(
              width: double.infinity,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(4),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progressRatio,
                  minHeight: 8,
                  backgroundColor: AppColors.divider,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progressRatio == 1.0 ? AppColors.success : AppColors.info,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Bottom row: Quantities and UOM
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thực hiện',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceMuted,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      AppNumberFormat.quantity(move.doneQty),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      '/',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.onSurfaceMuted,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Yêu cầu',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceMuted,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      AppNumberFormat.quantity(move.demandQty),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Đơn vị',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceMuted,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      move.uomName ?? '-',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Sync status indicator
            if (move.isPendingSync) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.warningContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.sync_problem,
                        size: 16, color: AppColors.warning),
                    const SizedBox(width: 8),
                    const Text(
                      'Chờ đồng bộ lên Odoo',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
