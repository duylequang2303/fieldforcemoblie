import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/locale/locale_service.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/safe_image_file.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_form.dart';

/// Trang quản lý chi phí cho một đơn dịch vụ.
class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key, required this.orderId});

  final int orderId;

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().loadExpenses(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: const Color(0xFFE65100),
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Khoản Chi',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            actions: [
              if (provider.pendingSyncCount > 0)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${provider.pendingSyncCount} chưa sync',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
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
                        provider.loadExpenses(widget.orderId);
                      },
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        final result = await provider.syncExpenses();
                        if (result != null && result.hasFailures) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '${result.failedCount} khoản chi không đồng bộ. '
                                  'Vui lòng thử lại.'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                        await provider.loadExpenses(widget.orderId);
                      },
                      child: Column(
                        children: [
                          // Summary
                          _SummaryCard(
                            totalExpenses: provider.expenses.length,
                            totalAmount: provider.totalAmount,
                            pendingCount: provider.pendingSyncCount,
                          ),

                          // Form toggle (animated) — uses AnimatedCrossFade to
                          // properly unmount the form subtree when collapsed,
                          // avoiding layout jank from height=0 keeping child in tree.
                          AnimatedCrossFade(
                            duration: const Duration(milliseconds: 300),
                            crossFadeState: _showForm
                                ? CrossFadeState.showFirst
                                : CrossFadeState.showSecond,
                            firstChild: Container(
                              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.secondary.withOpacity(0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ExpenseForm(
                                onSubmit: ({
                                  required String name,
                                  required double amount,
                                  required DateTime date,
                                  required ExpenseCategory category,
                                  String? receiptImagePath,
                                  String? note,
                                }) async {
                                  try {
                                    await provider.addExpense(
                                      orderOdooId: widget.orderId,
                                      name: name,
                                      amount: amount,
                                      date: date,
                                      category: category,
                                      receiptImagePath: receiptImagePath,
                                      note: note,
                                    );
                                    if (mounted) {
                                      setState(() => _showForm = false);
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Thêm khoản chi thất bại: $e'),
                                          backgroundColor: AppColors.error,
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                            secondChild: const SizedBox.shrink(),
                          ),

                          Expanded(
                            child: provider.expenses.isEmpty && !_showForm
                                ? _buildEmptyState()
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    itemCount: provider.expenses.length,
                                    itemBuilder: (context, i) => _ExpenseCard(
                                        expense: provider.expenses[i]),
                                  ),
                          ),
                        ],
                      ),
                    ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'fab_expense',
            onPressed: () => setState(() => _showForm = !_showForm),
            backgroundColor: _showForm ? AppColors.error : AppColors.secondary,
            icon:
                Icon(_showForm ? Icons.close : Icons.add, color: Colors.white),
            label: Text(
              _showForm ? 'Đóng' : 'Thêm khoản chi',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600),
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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.secondaryLight.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 40,
              color: AppColors.secondary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Chưa có khoản chi nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nhấn nút "Thêm khoản chi" bên dưới để khai báo',
            style: TextStyle(fontSize: 14, color: AppColors.onSurfaceMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.totalExpenses,
    required this.totalAmount,
    required this.pendingCount,
  });

  final int totalExpenses;
  final double totalAmount;
  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    final locale = LocaleService.instance.currentLocale;
    final fmt =
        NumberFormat.currency(locale: locale, symbol: '₫', decimalDigits: 0);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE65100), AppColors.secondaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Stat(
              label: 'Khoản chi',
              value: '$totalExpenses',
              icon: Icons.receipt_outlined,
            ),
          ),
          Container(width: 1, height: 40, color: Colors.white30),
          Expanded(
            child: _Stat(
              label: 'Tổng tiền',
              value: fmt.format(totalAmount),
              icon: Icons.account_balance_wallet_outlined,
            ),
          ),
          if (pendingCount > 0) ...[
            Container(width: 1, height: 40, color: Colors.white30),
            Expanded(
              child: _Stat(
                label: 'Chờ sync',
                value: '$pendingCount',
                icon: Icons.sync_problem,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  const _ExpenseCard({required this.expense});

  final Expense expense;

  Color get categoryColor {
    switch (expense.category) {
      case ExpenseCategory.fuel:
        return const Color(0xFFFF6F00); // Orange
      case ExpenseCategory.meal:
        return const Color(0xFF4CAF50); // Green
      case ExpenseCategory.transport:
        return const Color(0xFF2196F3); // Blue
      case ExpenseCategory.material:
        return const Color(0xFF9C27B0); // Purple
      case ExpenseCategory.other:
        return const Color(0xFF757575); // Gray
    }
  }

  IconData get categoryIcon {
    switch (expense.category) {
      case ExpenseCategory.fuel:
        return Icons.local_gas_station;
      case ExpenseCategory.meal:
        return Icons.restaurant;
      case ExpenseCategory.transport:
        return Icons.directions_car;
      case ExpenseCategory.material:
        return Icons.inventory_2;
      case ExpenseCategory.other:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = LocaleService.instance.currentLocale;
    final fmt =
        NumberFormat.currency(locale: locale, symbol: '₫', decimalDigits: 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: expense.isPendingSync
              ? AppColors.warning.withOpacity(0.3)
              : AppColors.divider,
          width: expense.isPendingSync ? 2 : 1,
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
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Receipt image or category icon
            if (expense.receiptImagePath != null)
              SafeImageFile(
                path: expense.receiptImagePath!,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(12),
                cacheWidth: 128,
                cacheHeight: 128,
                errorWidget: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    categoryIcon,
                    color: categoryColor,
                    size: 28,
                  ),
                ),
              )
            else
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  categoryIcon,
                  color: categoryColor,
                  size: 28,
                ),
              ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Expense name
                  Text(
                    expense.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Category and date
                  Row(
                    children: [
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          expense.categoryLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: categoryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Date
                      Icon(Icons.calendar_today,
                          size: 13, color: AppColors.onSurfaceMuted),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd/MM/yyyy', 'vi').format(expense.date),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (expense.note != null && expense.note!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      expense.note!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Amount and sync status column
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  fmt.format(expense.amount),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: categoryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: expense.isPendingSync
                        ? AppColors.warningContainer
                        : AppColors.successContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    expense.isPendingSync
                        ? Icons.sync_problem
                        : Icons.cloud_done,
                    size: 14,
                    color: expense.isPendingSync
                        ? AppColors.warning
                        : AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
