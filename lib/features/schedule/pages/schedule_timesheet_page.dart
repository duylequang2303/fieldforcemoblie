import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ScheduleTimesheetPage extends StatefulWidget {
  const ScheduleTimesheetPage({super.key});

  @override
  State<ScheduleTimesheetPage> createState() => _ScheduleTimesheetPageState();
}

class _ScheduleTimesheetPageState extends State<ScheduleTimesheetPage> {
  final List<String> _selectedEmployees = ['Janice', 'Martin'];
  final TimeOfDay _start = const TimeOfDay(hour: 8, minute: 15);
  final TimeOfDay _end = const TimeOfDay(hour: 21, minute: 45);
  final TextEditingController _noteController = TextEditingController();

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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('EMPLOYEE(S)', style: TextStyle(fontSize: 13, color: AppColors.onSurfaceMuted, letterSpacing: 0.4)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _selectedEmployees
                  .map(
                    (e) => InputChip(
                      label: Text(e),
                      onDeleted: () {},
                      deleteIconColor: AppColors.onSurfaceMuted,
                      backgroundColor: AppColors.surface,
                      side: const BorderSide(color: AppColors.divider),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _TimeField(label: 'START TIME', value: _start.format(context), onTap: () {}),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _TimeField(label: 'END TIME', value: _end.format(context), onTap: () {}),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _DropdownField(label: 'BREAK', value: 'No Break'),
            const SizedBox(height: 24),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'NOTE',
                hintText: 'Note (optional)',
                hintStyle: TextStyle(color: AppColors.scheduleSecondaryText),
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

class _TimeField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _TimeField({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceMuted, letterSpacing: 0.4)),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.scheduleDivider),
              borderRadius: BorderRadius.circular(4),
            ),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Text(value, style: const TextStyle(fontSize: 16, color: AppColors.onSurface)),
                 const Icon(Icons.arrow_drop_down, color: AppColors.onSurfaceMuted),
               ],
             ),
           ),
         ),
       ],
     );
   }
 }

 class _DropdownField extends StatelessWidget {
   final String label;
   final String value;

   const _DropdownField({required this.label, required this.value});

   @override
   Widget build(BuildContext context) {
     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Text(label, style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceMuted, letterSpacing: 0.4)),
         const SizedBox(height: 6),
         Container(
           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
           decoration: BoxDecoration(
             border: Border.all(color: AppColors.divider),
             borderRadius: BorderRadius.circular(8),
           ),
           child: Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Text(value, style: const TextStyle(fontSize: 16, color: AppColors.onSurface)),
               const Icon(Icons.arrow_drop_down, color: AppColors.onSurfaceMuted),
             ],
           ),
         ),
       ],
     );
   }
 }
