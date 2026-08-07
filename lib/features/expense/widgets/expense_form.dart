import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../models/expense.dart';
import 'receipt_image_picker.dart';

/// Parse Vietnamese-formatted amount string.
/// Handles thousand separators (space, dot, comma) for integer VND amounts.
double? parseAmount(String? text) {
  if (text == null || text.trim().isEmpty) return null;
  final value = text.trim();

  // Ensure it does not mix different types of thousand separators
  final hasDot = value.contains('.') ? 1 : 0;
  final hasComma = value.contains(',') ? 1 : 0;
  final hasSpace = value.contains(' ') ? 1 : 0;
  if (hasDot + hasComma + hasSpace > 1) {
    return null;
  }

  if (!RegExp(
    r'^-?(?:\d+|\d{1,3}(?:[.,\s]\d{3})+)$',
  ).hasMatch(value)) {
    return null;
  }
  return double.tryParse(value.replaceAll(RegExp(r'[.,\s]'), ''));
}

/// Form nhập thông tin một khoản chi phí.
class ExpenseForm extends StatefulWidget {
  const ExpenseForm({
    super.key,
    required this.onSubmit,
  });

  final Future<void> Function({
    required String name,
    required double amount,
    required DateTime date,
    required ExpenseCategory category,
    String? receiptImagePath,
    String? note,
  }) onSubmit;

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _date = DateTime.now();
  ExpenseCategory _category = ExpenseCategory.other;
  String? _receiptPath;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Category selector
          _CategoryPicker(
            selected: _category,
            onChanged: (c) => setState(() => _category = c),
          ),

          const SizedBox(height: 12),

          // Mô tả
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Mô tả chi phí *',
              border: OutlineInputBorder(),
              prefixIcon:
                  Icon(Icons.description_outlined, color: AppColors.primary),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Vui lòng nhập mô tả' : null,
          ),

          const SizedBox(height: 12),

          // Số tiền
          TextFormField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Số tiền (VND) *',
              border: OutlineInputBorder(),
              prefixIcon:
                  Icon(Icons.payments_outlined, color: AppColors.primary),
              suffixText: 'VND',
            ),
            validator: (v) {
              final n = parseAmount(v);
              if (n == null || n <= 0) return 'Nhập số tiền hợp lệ';
              return null;
            },
          ),

          const SizedBox(height: 12),

          // Ngày
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today_outlined,
                color: AppColors.primary),
            title: const Text('Ngày chi'),
            subtitle: Text(
              DateFormat('dd/MM/yyyy', 'vi').format(_date),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: _pickDate,
          ),

          const SizedBox(height: 12),

          // Ảnh hoá đơn
          const Text(
            'Ảnh hoá đơn (tuỳ chọn)',
            style: TextStyle(color: AppColors.onSurfaceMuted, fontSize: 12),
          ),
          const SizedBox(height: 6),
          ReceiptImagePicker(
            imagePath: _receiptPath,
            onImageSelected: (path) => setState(() => _receiptPath = path),
            onRemove: () => setState(() => _receiptPath = null),
          ),

          const SizedBox(height: 12),

          // Ghi chú
          TextFormField(
            controller: _noteController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Ghi chú (tuỳ chọn)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.notes_outlined, color: AppColors.primary),
            ),
          ),

          const SizedBox(height: 20),

          FilledButton.icon(
            onPressed: _isSubmitting ? null : _submit,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.save_outlined, size: 18),
            label: Text(_isSubmitting ? 'Đang lưu...' : 'Lưu chi phí'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.secondary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final amount = parseAmount(_amountController.text);
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Số tiền không hợp lệ')),
        );
        return;
      }
      await widget.onSubmit(
        name: _nameController.text.trim(),
        amount: amount,
        date: _date,
        category: _category,
        receiptImagePath: _receiptPath,
        note: _noteController.text.isEmpty ? null : _noteController.text.trim(),
      );
      _nameController.clear();
      _amountController.clear();
      _noteController.clear();
      setState(() {
        _date = DateTime.now();
        _receiptPath = null;
        _category = ExpenseCategory.other;
      });
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}

class _CategoryPicker extends StatelessWidget {
  const _CategoryPicker({required this.selected, required this.onChanged});

  final ExpenseCategory selected;
  final ValueChanged<ExpenseCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: ExpenseCategory.values.map((c) {
          final isSelected = c == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_label(c)),
              avatar: Icon(_icon(c), size: 14),
              selected: isSelected,
              onSelected: (_) => onChanged(c),
              selectedColor: AppColors.secondary.withValues(alpha: 0.15),
              checkmarkColor: AppColors.secondary,
            ),
          );
        }).toList(),
      ),
    );
  }

  String _label(ExpenseCategory c) {
    switch (c) {
      case ExpenseCategory.fuel:
        return 'Nhiên liệu';
      case ExpenseCategory.meal:
        return 'Ăn uống';
      case ExpenseCategory.transport:
        return 'Vận chuyển';
      case ExpenseCategory.material:
        return 'Vật liệu';
      case ExpenseCategory.other:
        return 'Khác';
    }
  }

  IconData _icon(ExpenseCategory c) {
    switch (c) {
      case ExpenseCategory.fuel:
        return Icons.local_gas_station_outlined;
      case ExpenseCategory.meal:
        return Icons.restaurant_outlined;
      case ExpenseCategory.transport:
        return Icons.directions_car_outlined;
      case ExpenseCategory.material:
        return Icons.build_outlined;
      case ExpenseCategory.other:
        return Icons.more_horiz;
    }
  }
}
