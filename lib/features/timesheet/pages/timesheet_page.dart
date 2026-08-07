import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../models/timesheet_entry.dart';
import '../providers/timesheet_provider.dart';
import '../widgets/time_entry_form.dart';

/// Trang ghi nhận giờ công cho một đơn dịch vụ.
class TimesheetPage extends StatefulWidget {
  const TimesheetPage({super.key, required this.orderId});

  final int orderId;

  @override
  State<TimesheetPage> createState() => _TimesheetPageState();
}

class _TimesheetPageState extends State<TimesheetPage> {
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TimesheetProvider>().loadEntries(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimesheetProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.accentDark,
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Ghi Nhận Giờ Công',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            actions: [
              if (provider.entries.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {
                    // TODO: Show help/info
                  },
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
                        provider.loadEntries(widget.orderId);
                      },
                    )
                  : Column(
                      children: [
                        // Summary card
                        _SummaryCard(
                          totalEntries: provider.entries.length,
                          totalHours: provider.totalHours,
                        ),

                        // Form thêm mới (toggle)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          height: _showForm ? null : 0,
                          child: _showForm
                              ? Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color:
                                            AppColors.accent.withOpacity(0.3),
                                        width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: TimeEntryForm(
                                    onSubmit: ({
                                      required DateTime date,
                                      required double hours,
                                      required String description,
                                    }) async {
                                      await provider.addEntry(
                                        orderOdooId: widget.orderId,
                                        date: date,
                                        hours: hours,
                                        description: description,
                                      );
                                      if (mounted) {
                                        setState(() => _showForm = false);
                                      }
                                    },
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),

                        // Danh sách entries
                        Expanded(
                          child: provider.entries.isEmpty && !_showForm
                              ? _buildEmptyState()
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  itemCount: provider.entries.length,
                                  itemBuilder: (context, i) =>
                                      _EntryCard(entry: provider.entries[i]),
                                ),
                        ),
                      ],
                    ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'fab_timesheet',
            onPressed: () => setState(() => _showForm = !_showForm),
            backgroundColor: _showForm ? AppColors.error : AppColors.accent,
            elevation: _showForm ? 2 : 4,
            icon: Icon(
              _showForm ? Icons.close : Icons.add_circle_outline,
              color: Colors.white,
              size: 22,
            ),
            label: Text(
              _showForm ? 'Đóng' : 'Thêm giờ công',
              style: const TextStyle(
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time_outlined,
              size: 72, color: AppColors.onSurfaceMuted.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          const Text(
            'Chưa có giờ công nào',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceMuted),
          ),
          const SizedBox(height: 8),
          const Text('Nhấn "Thêm giờ công" để ghi nhận',
              style: TextStyle(fontSize: 13, color: AppColors.onSurfaceMuted)),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.totalEntries, required this.totalHours});

  final int totalEntries;
  final double totalHours;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accentDark, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _Stat(
              label: 'Lần ghi nhận',
              value: '$totalEntries',
              icon: Icons.receipt_long_outlined,
            ),
          ),
          Container(
            width: 1,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.0),
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Expanded(
            child: _Stat(
              label: 'Tổng giờ',
              value: '${totalHours.toStringAsFixed(1)}h',
              icon: Icons.timer_outlined,
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
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 28,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry});

  final TimesheetEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: entry.isPendingSync
              ? AppColors.warning.withOpacity(0.3)
              : AppColors.divider,
          width: entry.isPendingSync ? 2 : 1,
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
        child: Row(
          children: [
            // Hours badge with icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: entry.isPendingSync
                      ? [AppColors.warning, AppColors.warning.withOpacity(0.7)]
                      : [AppColors.accent, AppColors.accentLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: (entry.isPendingSync
                            ? AppColors.warning
                            : AppColors.accent)
                        .withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timer,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${entry.hours.toStringAsFixed(entry.hours == entry.hours.truncate() ? 0 : 1)}h',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text(
                    entry.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.onSurface,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Date with icon
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: AppColors.onSurfaceMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('dd/MM/yyyy', 'vi').format(entry.date),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.onSurfaceMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (entry.employeeName != null &&
                      entry.employeeName!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 14,
                          color: AppColors.onSurfaceMuted,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          entry.employeeName!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.onSurfaceMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Status indicator
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: entry.isPendingSync
                    ? AppColors.warningContainer
                    : AppColors.successContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                entry.isPendingSync ? Icons.sync_problem : Icons.cloud_done,
                color:
                    entry.isPendingSync ? AppColors.warning : AppColors.success,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
