import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/section_header.dart';
import '../widgets/attachment_grid.dart';

import '../features/orders/models/fsm_order.dart';
import '../widgets/material_entry_form.dart';

class WorkOrderDetailScreen extends StatefulWidget {
  final FsmOrder order;

  const WorkOrderDetailScreen({
    super.key,
    required this.order,
  });

  @override
  State<WorkOrderDetailScreen> createState() => _WorkOrderDetailScreenState();
}

class _WorkOrderDetailScreenState extends State<WorkOrderDetailScreen> {
  late SignatureController _signatureController;
  final List<Map<String, dynamic>> _materialsUsed = [
    {'name': 'AC Filter (Standard)', 'qty': 1}
  ];

  @override
  void initState() {
    super.initState();
    _signatureController = SignatureController(
      penStrokeWidth: 2,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  Widget _buildStickyHeader() {
    final theme = Theme.of(context);
    
    // Helpers format data
    String formatDate(DateTime? date) {
      if (date == null) return 'Chưa xác định ngày';
      return '${date.day} Thg ${date.month}, ${date.year}';
    }

    String calculateDuration(DateTime? start, DateTime? end) {
      if (start == null || end == null) return 'N/A hrs';
      return '${end.difference(start).inHours} hrs';
    }

    double calculatePrice(DateTime? start, DateTime? end) {
      if (start == null || end == null) return 0.0;
      final hours = end.difference(start).inMinutes / 60.0;
      return hours * 50; // Mock $50/hour
    }

    return Card(
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                          const SizedBox(width: 6),
                          Text(
                            formatDate(widget.order.scheduledDateStart),
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Address
                      Text(
                        widget.order.locationAddress ?? widget.order.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Customer name
                      Text(
                        widget.order.partnerName ?? 'Khách hàng ẩn',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Quick Actions
                Column(
                  children: [
                    QuickActionButton(icon: Icons.phone_outlined, onTap: () {}),
                    const SizedBox(height: 8),
                    QuickActionButton(icon: Icons.chat_bubble_outline, onTap: () {}),
                    const SizedBox(height: 8),
                    QuickActionButton(icon: Icons.email_outlined, onTap: () {}),
                    const SizedBox(height: 8),
                    QuickActionButton(icon: Icons.directions_outlined, onTap: () {}),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            // Info Grid
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DUE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${formatDate(widget.order.scheduledDateStart)}\n(Does not repeat)',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DURATION / PRICE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${calculateDuration(widget.order.scheduledDateStart, widget.order.scheduledDateEnd)}\n\$ ${calculatePrice(widget.order.scheduledDateStart, widget.order.scheduledDateEnd).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    key: const Key('btn_mark_complete'),
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Mark complete', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    key: const Key('btn_skip'),
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: theme.dividerColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.order.locationAddress ?? widget.order.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStickyHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  ExpandableSection(
                    title: 'GENERAL INSTRUCTIONS',
                    initiallyExpanded: true,
                    child: Text(
                      'Please call 30 mins before arrival. Beware of the dog in the backyard.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  ExpandableSection(
                    title: 'WORK REQUIRED',
                    child: Text(
                      '1. Inspect AC unit\n2. Replace filter\n3. Check gas levels',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  ExpandableSection(
                    title: 'ATTACHMENTS',
                    child: AttachmentGrid(
                      imageUrls: const ['dummy1', 'dummy2'],
                      onAdd: () {},
                    ),
                  ),
                  ExpandableSection(
                    title: 'MATERIALS USED',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ..._materialsUsed.map((mat) => Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(mat['name']),
                              trailing: Text('x${mat['qty']}'),
                              visualDensity: VisualDensity.compact,
                            ),
                            const Divider(height: 1),
                          ],
                        )),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          key: const Key('btn_add_material'),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (ctx) => MaterialEntryForm(
                                onSaved: (product, qty) {
                                  Navigator.pop(ctx);
                                  if (product != null) {
                                    setState(() {
                                      _materialsUsed.add({
                                        'name': product.name,
                                        'qty': qty,
                                      });
                                    });
                                  }
                                },
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add material'),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        ),
                      ],
                    ),
                  ),
                  ExpandableSection(
                    title: 'TIMESHEET',
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                key: const Key('btn_check_in'),
                                onPressed: () {},
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Check-in'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                key: const Key('btn_check_out'),
                                onPressed: () {},
                                icon: const Icon(Icons.stop),
                                label: const Text('Check-out'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('Today'),
                          trailing: Text('09:00 - 11:00 (2 hrs)'),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                  ExpandableSection(
                    title: 'SIGNATURE',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).dividerColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Signature(
                              key: const Key('signature_pad'),
                              controller: _signatureController,
                              height: 150,
                              backgroundColor: Colors.grey[100]!,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => _signatureController.clear(),
                            child: const Text('Clear'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24), // spacing bottom
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
