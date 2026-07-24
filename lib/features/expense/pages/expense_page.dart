import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/locale/locale_service.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_overlay.dart';
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
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            title: const Text(
              'Khoản Chi',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
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
                  : Column(
                      children: [
                        // Summary
                        _SummaryCard(
                          totalExpenses: provider.expenses.length,
                          totalAmount: provider.totalAmount,
                        ),

                        // Form toggle
                        if (_showForm)
                          Container(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
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
                                await provider.addExpense(
                                  orderOdooId: widget.orderId,
                                  name: name,
                                  amount: amount,
                                  date: date,
                                  category: category,
                                  receiptImagePath: receiptImagePath,
                                  note: note,
                                );
                                if (mounted) setState(() => _showForm = false);
                              },
                            ),
                          ),

                        Expanded(
                          child: provider.expenses.isEmpty && !_showForm
                              ? _buildEmptyState()
                              : ListView.builder(
                                  padding: const EdgeInsets.all(12),
                                  itemCount: provider.expenses.length,
                                  itemBuilder: (context, i) =>
                                      _ExpenseTile(expense: provider.expenses[i]),
                                ),
                        ),
                      ],
                    ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'fab_expense',
            onPressed: () => setState(() => _showForm = !_showForm),
            backgroundColor: _showForm ? AppColors.error : AppColors.secondary,
            icon: Icon(_showForm ? Icons.close : Icons.add, color: Colors.white),
            label: Text(
              _showForm ? 'Đóng' : 'Thêm khoản chi',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
          Icon(Icons.receipt_long_outlined,
              size: 72, color: AppColors.onSurfaceMuted.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          const Text('Chưa có khoản chi nào',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceMuted)),
          const SizedBox(height: 8),
          const Text('Nhấn "Thêm khoản chi" để khai báo',
              style: TextStyle(fontSize: 13, color: AppColors.onSurfaceMuted)),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.totalExpenses, required this.totalAmount});

  final int totalExpenses;
  final double totalAmount;

  @override
  Widget build(BuildContext context) {
    final locale = LocaleService.instance.currentLocale;
    final fmt = NumberFormat.currency(locale: locale, symbol: '₫', decimalDigits: 0);
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

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({required this.expense});

  final Expense expense;

  @override
  Widget build(BuildContext context) {
    final locale = LocaleService.instance.currentLocale;
    final fmt = NumberFormat.currency(locale: locale, symbol: '₫', decimalDigits: 0);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: expense.isPendingSync
            ? const BorderSide(color: AppColors.warning, width: 1)
            : BorderSide.none,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: expense.receiptImagePath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(expense.receiptImagePath!),
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                ),
              )
            : Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.receipt_outlined, color: AppColors.secondary, size: 22),
              ),
        title: Text(
          expense.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${expense.categoryLabel} • ${DateFormat('dd/MM/yyyy', 'vi').format(expense.date)}',
          style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              fmt.format(expense.amount),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.secondary,
              ),
            ),
            if (expense.isPendingSync)
              const Icon(Icons.sync_problem, color: AppColors.warning, size: 14)
            else
              const Icon(Icons.cloud_done_outlined, color: AppColors.success, size: 14),
          ],
        ),
      ),
    );
  }
}
