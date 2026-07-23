import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../models/stock_move.dart';
import '../providers/stock_provider.dart';

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
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            title: const Text(
              'Vật Tư Đã Xuất',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            actions: [
              // Total items badge
              if (provider.moves.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${provider.moves.length} dòng',
                        style: const TextStyle(fontSize: 12),
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
                          padding: const EdgeInsets.all(12),
                          itemCount: provider.moves.length,
                          itemBuilder: (context, i) =>
                              _MoveTile(move: provider.moves[i]),
                        ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'fab_scanner',
            onPressed: () {
              Navigator.of(context).pushNamed('/scanner');
            },
            backgroundColor: AppColors.secondary,
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            label: const Text(
              'Quét vật tư',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 72,
            color: AppColors.onSurfaceMuted.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          const Text(
            'Chưa có vật tư nào',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceMuted,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nhấn "Quét vật tư" để thêm',
            style: TextStyle(fontSize: 13, color: AppColors.onSurfaceMuted),
          ),
        ],
      ),
    );
  }
}

class _MoveTile extends StatelessWidget {
  const _MoveTile({required this.move});

  final StockMove move;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: move.isPendingSync
            ? const BorderSide(color: AppColors.warning, width: 1)
            : BorderSide.none,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.inventory_outlined, color: AppColors.primary, size: 20),
        ),
        title: Text(
          move.productName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (move.productCode != null)
              Text(
                'Mã: ${move.productCode}',
                style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted),
              ),
            Row(
              children: [
                if (move.isPendingSync) ...[
                  const Icon(Icons.sync_problem, size: 12, color: AppColors.warning),
                  const SizedBox(width: 4),
                  const Text(
                    'Chờ sync ',
                    style: TextStyle(fontSize: 11, color: AppColors.warning),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${move.doneQty.toStringAsFixed(move.doneQty == move.doneQty.truncate() ? 0 : 1)} ${move.uomName ?? ''}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.primary,
              ),
            ),
            Text(
              move.moveType == MoveType.out ? 'Xuất' : 'Nhập',
              style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceMuted),
            ),
          ],
        ),
      ),
    );
  }
}
