import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ScheduleMaterialsPage extends StatefulWidget {
  const ScheduleMaterialsPage({super.key});

  @override
  State<ScheduleMaterialsPage> createState() => _ScheduleMaterialsPageState();
}

class _ScheduleMaterialsPageState extends State<ScheduleMaterialsPage> {
  final TextEditingController _materialController = TextEditingController(text: 'Waste (bag)');
  final TextEditingController _qtyController = TextEditingController(text: '1');
  final TextEditingController _priceController = TextEditingController(text: '\$8.0');
  final TextEditingController _noteController = TextEditingController(text: 'Note');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.schedulePrimary,
        title: const Text('SAVE', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('MATERIAL OR ADD NEW', style: TextStyle(fontSize: 13, color: AppColors.onSurfaceMuted, letterSpacing: 0.4)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.divider),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _materialController,
                      decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 14)),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: AppColors.onSurfaceMuted),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _OutlineField(label: 'QUANTITY', controller: _qtyController)),
                const SizedBox(width: 16),
                Expanded(child: _OutlineField(label: 'PRICE', controller: _priceController)),
                const SizedBox(width: 16),
                Expanded(child: _OutlineField(label: 'SUBTOTAL', readOnly: true, controller: TextEditingController(text: '\$8.00'))),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'NOTE',
                hintText: 'Note',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _OutlineField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool readOnly;

  const _OutlineField({required this.label, required this.controller, this.readOnly = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceMuted, letterSpacing: 0.4)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: readOnly,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            isDense: true,
          ),
        ),
      ],
    );
  }
}
