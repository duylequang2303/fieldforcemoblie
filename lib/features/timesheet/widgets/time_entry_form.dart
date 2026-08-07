import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Form nhập giờ công — dùng trong TimesheetPage.
class TimeEntryForm extends StatefulWidget {
  const TimeEntryForm({
    super.key,
    required this.onSubmit,
  });

  final Future<void> Function({
    required DateTime date,
    required double hours,
    required String description,
  }) onSubmit;

  @override
  State<TimeEntryForm> createState() => _TimeEntryFormState();
}

class _TimeEntryFormState extends State<TimeEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  final _hoursController = TextEditingController(text: '1.0');

  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ngày
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today_outlined,
                color: AppColors.primary),
            title: const Text('Ngày làm việc'),
            subtitle: Text(
              '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            onTap: _pickDate,
          ),

          const Divider(),

          // Số giờ
          TextFormField(
            controller: _hoursController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Số giờ công',
              prefixIcon:
                  Icon(Icons.access_time_outlined, color: AppColors.primary),
              border: OutlineInputBorder(),
              suffixText: 'giờ',
            ),
            validator: (v) {
              final h = double.tryParse(v ?? '');
              if (h == null || !h.isFinite || h <= 0) return 'Nhập số giờ hợp lệ (> 0)';
              if (h > 24) return 'Không thể quá 24 giờ/ngày';
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Mô tả công việc
          TextFormField(
            controller: _descController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Mô tả công việc',
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Icon(Icons.notes_outlined, color: AppColors.primary),
              ),
              border: OutlineInputBorder(),
              hintText: 'VD: Kiểm tra, sửa chữa, lắp đặt...',
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Vui lòng nhập mô tả';
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Nút submit
          FilledButton.icon(
            onPressed: _isSubmitting ? null : _submit,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.save_outlined, size: 18),
            label: Text(_isSubmitting ? 'Đang lưu...' : 'Lưu giờ công'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      await widget.onSubmit(
        date: _selectedDate,
        hours: double.parse(_hoursController.text),
        description: _descController.text.trim(),
      );
      _descController.clear();
      _hoursController.text = '1.0';
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
