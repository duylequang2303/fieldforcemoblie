import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../providers/work_order_provider.dart';
import '../widgets/customer_signature_widget.dart';
import '../widgets/photo_capture_widget.dart';

/// Trang nghiệm thu công việc — bao gồm:
/// - Mô tả công việc đã thực hiện
/// - Ảnh hiện trường
/// - Chữ ký khách hàng
/// - Nút submit lên Odoo
class WorkOrderPage extends StatefulWidget {
  const WorkOrderPage({super.key, required this.orderId});

  final int orderId;

  @override
  State<WorkOrderPage> createState() => _WorkOrderPageState();
}

class _WorkOrderPageState extends State<WorkOrderPage> {
  final _workDoneController = TextEditingController();
  final _problemsController = TextEditingController();
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<WorkOrderProvider>();
      await provider.loadReport(widget.orderId);

      if (provider.report != null && mounted) {
        _workDoneController.text = provider.report!.workDone;
        _problemsController.text = provider.report!.problemsFound ?? '';
      }
    });
  }

  @override
  void dispose() {
    _workDoneController.dispose();
    _problemsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkOrderProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.accentDark,
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Nghiệm Thu Công Việc',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            actions: [
              // Save locally
              IconButton(
                icon: const Icon(Icons.save_outlined),
                onPressed: provider.isLoading ? null : () async {
                  provider.updateWorkDone(_workDoneController.text);
                  provider.updateProblems(_problemsController.text);
                  await provider.saveLocally();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã lưu bản nháp'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
                tooltip: 'Lưu nháp',
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
                        provider.loadReport(widget.orderId);
                      },
                    )
                  : _buildStepper(context, provider),
        );
      },
    );
  }

  Widget _buildStepper(BuildContext context, WorkOrderProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          _buildProgressBar(provider),
          const SizedBox(height: 24),

          // Step content
          if (_currentStep == 0)
            _buildStep1(provider)
          else if (_currentStep == 1)
            _buildStep2(provider)
          else
            _buildStep3(provider),

          const SizedBox(height: 24),

          // Navigation buttons
          _buildButtons(context, provider),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProgressBar(WorkOrderProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _StepIndicator(
              number: 1,
              label: 'Công việc',
              isActive: _currentStep >= 0,
              isComplete: _workDoneController.text.isNotEmpty,
            ),
            Container(
              width: 40,
              height: 2,
              margin: const EdgeInsets.only(top: 20),
              color: _currentStep >= 1 ? AppColors.accent : AppColors.divider,
            ),
            _StepIndicator(
              number: 2,
              label: 'Chữ ký',
              isActive: _currentStep >= 1,
              isComplete: provider.hasSignature,
            ),
            Container(
              width: 40,
              height: 2,
              margin: const EdgeInsets.only(top: 20),
              color: _currentStep >= 2 ? AppColors.accent : AppColors.divider,
            ),
            _StepIndicator(
              number: 3,
              label: 'Xác nhận',
              isActive: _currentStep >= 2,
              isComplete: false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep1(WorkOrderProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Công Việc Đã Thực Hiện', Icons.assignment_turned_in_outlined),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _workDoneController,
            maxLines: 5,
            onChanged: provider.updateWorkDone,
            decoration: InputDecoration(
              labelText: 'Mô tả chi tiết công việc *',
              hintText: 'Nhập mô tả chi tiết về công việc đã thực hiện...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.accent, width: 2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildSectionHeader('Vấn Đề Phát Sinh (Nếu Có)', Icons.warning_outlined),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _problemsController,
            maxLines: 3,
            onChanged: provider.updateProblems,
            decoration: InputDecoration(
              labelText: 'Mô tả vấn đề phát sinh',
              hintText: 'Nhập các vấn đề, nếu có...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.accent, width: 2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildSectionHeader('Ảnh Hiện Trường', Icons.photo_library_outlined),
        const SizedBox(height: 12),
        if (provider.report != null)
          PhotoCaptureWidget(
            photoPaths: provider.report!.photoPaths,
            onAdd: provider.addPhoto,
            onRemove: provider.removePhoto,
          ),
      ],
    );
  }

  Widget _buildStep2(WorkOrderProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Chữ Ký Khách Hàng', Icons.draw_outlined),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CustomerSignatureWidget(
            existingSignaturePath: provider.report?.customerSignaturePath,
            existingCustomerName: provider.report?.customerName,
            onSigned: ({required String signaturePath, required String customerName}) async {
              provider.setSignature(signaturePath, customerName);
            },
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.infoContainer,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.info.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outlined, color: AppColors.info, size: 18),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Khách hàng cần ký xác nhận công việc trước khi hoàn thành',
                  style: TextStyle(fontSize: 13, color: AppColors.info),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep3(WorkOrderProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Tóm Tắt Nghiệm Thu', Icons.summarize),
        const SizedBox(height: 12),
        _buildSummaryReview(provider),
        if (!provider.isComplete) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.warningContainer,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_rounded, color: AppColors.warning, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Vui lòng hoàn thành mô tả công việc và chữ ký khách hàng trước khi gửi.',
                    style: TextStyle(fontSize: 13, color: AppColors.warning, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.accent),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryReview(WorkOrderProvider provider) {
    final report = provider.report;
    if (report == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _ReviewRow(
            icon: Icons.assignment_turned_in_outlined,
            label: 'Công việc đã thực hiện',
            value: report.workDone.isEmpty ? '(chưa nhập)' : report.workDone,
            isOk: report.workDone.isNotEmpty,
          ),
          const Divider(height: 1),
          _ReviewRow(
            icon: Icons.photo_library_outlined,
            label: 'Ảnh hiện trường',
            value: '${report.photoPaths.length} ảnh',
            isOk: report.photoPaths.isNotEmpty,
          ),
          const Divider(height: 1),
          _ReviewRow(
            icon: Icons.draw_outlined,
            label: 'Chữ ký khách hàng',
            value: report.customerSignaturePath != null
                ? 'Đã ký: ${report.customerName ?? 'Khách hàng'}'
                : 'Chưa có chữ ký',
            isOk: report.customerSignaturePath != null,
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context, WorkOrderProvider provider) {
    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _currentStep--),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Quay lại'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: 12),
        Expanded(
          child: _currentStep < 2
              ? ElevatedButton.icon(
                  onPressed: () => setState(() => _currentStep++),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Tiếp theo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                )
              : ElevatedButton.icon(
                  onPressed: (provider.isComplete && !provider.isSubmitting)
                      ? () => _submit(context, provider)
                      : null,
                  icon: provider.isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.check_circle),
                  label: provider.isSubmitting ? const Text('Đang gửi...') : const Text('Gửi Nghiệm Thu'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: AppColors.onSurfaceWeak.withOpacity(0.3),
                  ),
                ),
        ),
      ],
    );
  }


  Future<void> _submit(BuildContext context, WorkOrderProvider provider) async {
    provider.updateWorkDone(_workDoneController.text);
    provider.updateProblems(_problemsController.text);

    final success = await provider.submitReport();
    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nghiệm thu đã được gửi thành công!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Lỗi khi gửi'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isOk,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isOk;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isOk ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isOk ? AppColors.success : AppColors.onSurfaceMuted,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.onSurfaceMuted)),
                Text(value,
                    style: TextStyle(
                      fontSize: 14,
                      color: isOk ? AppColors.onSurface : AppColors.onSurfaceMuted,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.number,
    required this.label,
    required this.isActive,
    required this.isComplete,
  });

  final int number;
  final String label;
  final bool isActive;
  final bool isComplete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isComplete
                ? AppColors.success
                : isActive
                    ? AppColors.accent
                    : AppColors.divider,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isComplete
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    '$number',
                    style: TextStyle(
                      color: isActive ? Colors.white : AppColors.onSurfaceMuted,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? AppColors.onSurface : AppColors.onSurfaceMuted,
          ),
        ),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isOk,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isOk;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceMuted,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: isOk ? AppColors.onSurface : AppColors.onSurfaceMuted,
                    fontWeight: isOk ? FontWeight.w600 : FontWeight.w400,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isOk ? AppColors.successContainer : AppColors.divider,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOk ? Icons.check : Icons.close,
              size: 14,
              color: isOk ? AppColors.success : AppColors.onSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }
}
