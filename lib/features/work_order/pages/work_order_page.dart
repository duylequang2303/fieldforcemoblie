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
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            title: const Text(
              'Nghiệm Thu Công Việc',
              style: TextStyle(fontWeight: FontWeight.w700),
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
                      const SnackBar(content: Text('Đã lưu bản nháp')),
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
    return Stepper(
      currentStep: _currentStep,
      onStepTapped: (i) => setState(() => _currentStep = i),
      onStepContinue: () {
        if (_currentStep < 2) setState(() => _currentStep++);
      },
      onStepCancel: () {
        if (_currentStep > 0) setState(() => _currentStep--);
      },
      controlsBuilder: (context, details) => Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Row(
          children: [
            if (_currentStep < 2)
              FilledButton(
                onPressed: details.onStepContinue,
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text('Tiếp theo'),
              )
            else
              FilledButton.icon(
                onPressed:
                    (provider.isComplete && !provider.isSubmitting)
                        ? () => _submit(context, provider)
                        : null,
                icon: provider.isSubmitting
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send, size: 16),
                label: const Text('Gửi nghiệm thu'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.success,
                ),
              ),
            if (_currentStep > 0) ...[
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: details.onStepCancel,
                child: const Text('Quay lại'),
              ),
            ],
          ],
        ),
      ),
      steps: [
        // Step 1: Mô tả công việc
        Step(
          title: const Text('Công việc đã thực hiện'),
          subtitle: const Text('Mô tả chi tiết'),
          isActive: _currentStep >= 0,
          state: _currentStep > 0 && _workDoneController.text.isNotEmpty
              ? StepState.complete
              : StepState.indexed,
          content: Column(
            children: [
              TextField(
                controller: _workDoneController,
                maxLines: 5,
                onChanged: provider.updateWorkDone,
                decoration: const InputDecoration(
                  labelText: 'Công việc đã thực hiện *',
                  border: OutlineInputBorder(),
                  hintText: 'Mô tả chi tiết công việc...',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _problemsController,
                maxLines: 3,
                onChanged: provider.updateProblems,
                decoration: const InputDecoration(
                  labelText: 'Vấn đề phát sinh (nếu có)',
                  border: OutlineInputBorder(),
                  hintText: 'Mô tả vấn đề...',
                ),
              ),
              const SizedBox(height: 12),
              // Ảnh hiện trường
              if (provider.report != null)
                PhotoCaptureWidget(
                  photoPaths: provider.report!.photoPaths,
                  onAdd: provider.addPhoto,
                  onRemove: provider.removePhoto,
                ),
            ],
          ),
        ),

        // Step 2: Chữ ký khách hàng
        Step(
          title: const Text('Chữ ký khách hàng'),
          subtitle: const Text('Xác nhận nghiệm thu'),
          isActive: _currentStep >= 1,
          state: provider.hasSignature ? StepState.complete : StepState.indexed,
          content: CustomerSignatureWidget(
            existingSignaturePath: provider.report?.customerSignaturePath,
            existingCustomerName: provider.report?.customerName,
            onSigned: ({required String signaturePath, required String customerName}) async {
              provider.setSignature(signaturePath, customerName);
            },
          ),
        ),

        // Step 3: Xác nhận & Submit
        Step(
          title: const Text('Xác nhận & Gửi'),
          subtitle: const Text('Hoàn tất nghiệm thu'),
          isActive: _currentStep >= 2,
          state: StepState.indexed,
          content: _buildSummary(provider),
        ),
      ],
    );
  }

  Widget _buildSummary(WorkOrderProvider provider) {
    final report = provider.report;
    if (report == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SummaryRow(
          icon: Icons.assignment_turned_in_outlined,
          label: 'Mô tả công việc',
          value: report.workDone.isEmpty ? '(chưa nhập)' : report.workDone,
          isOk: report.workDone.isNotEmpty,
        ),
        _SummaryRow(
          icon: Icons.photo_library_outlined,
          label: 'Ảnh hiện trường',
          value: '${report.photoPaths.length} ảnh',
          isOk: report.photoPaths.isNotEmpty,
        ),
        _SummaryRow(
          icon: Icons.draw_outlined,
          label: 'Chữ ký khách hàng',
          value: report.customerSignaturePath != null
              ? 'Đã ký: ${report.customerName}'
              : 'Chưa có chữ ký',
          isOk: report.customerSignaturePath != null,
        ),
        const SizedBox(height: 12),
        if (!provider.isComplete)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.warning),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_outlined, color: AppColors.warning, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Vui lòng hoàn thành mô tả công việc và chữ ký khách hàng trước khi gửi.',
                    style: TextStyle(fontSize: 13, color: AppColors.warning),
                  ),
                ),
              ],
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
