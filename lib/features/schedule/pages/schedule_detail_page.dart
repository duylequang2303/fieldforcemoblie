import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../schedule/models/schedule_visit.dart';

class ScheduleDetailPage extends StatefulWidget {
  final ScheduleVisit visit;

  const ScheduleDetailPage({super.key, required this.visit});

  @override
  State<ScheduleDetailPage> createState() => _ScheduleDetailPageState();
}

class _ScheduleDetailPageState extends State<ScheduleDetailPage> {
  @override
  Widget build(BuildContext context) {
    final visit = widget.visit;
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.schedulePrimary,
        title: const Text('EDIT',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('SAVE',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppColors.schedulePrimary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(visit.dueDate.replaceAll('due ', ''),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          height: 1.3)),
                  const SizedBox(height: 4),
                  Text(visit.address,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          height: 1.3)),
                  Text('${visit.suburb} NSW',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 16, height: 1.3)),
                  const SizedBox(height: 8),
                  Text(visit.customerName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.schedulePrimary),
            // Action icons
            Container(
              color: AppColors.schedulePrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: const [
                  Spacer(),
                  Icon(Icons.phone, color: Colors.white),
                  SizedBox(width: 24),
                  Icon(Icons.comment_outlined, color: Colors.white),
                  SizedBox(width: 24),
                  Icon(Icons.email_outlined, color: Colors.white),
                  SizedBox(width: 24),
                  Icon(Icons.navigation, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Meta rows
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 18, color: AppColors.scheduleSecondaryText),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(visit.dueDate,
                              style: const TextStyle(
                                  fontSize: 15,
                                  color: AppColors.scheduleText))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 18, color: AppColors.scheduleSecondaryText),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Row(
                          children: [
                            Text('${visit.hours} hr',
                                style: const TextStyle(
                                    fontSize: 15,
                                    color: AppColors.scheduleText)),
                          ],
                        ),
                      ),
                      Text('\$${visit.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 15, color: AppColors.scheduleText)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.schedulePrimary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(44),
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero),
                      ),
                      child: const Text('Mark complete',
                          style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.scheduleText,
                        side:
                            const BorderSide(color: AppColors.scheduleDivider),
                        minimumSize: const Size.fromHeight(44),
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero),
                      ),
                      child: const Text('Skip', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // General instructions
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'GENERAL INSTRUCTIONS',
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.scheduleSecondaryText,
                    letterSpacing: 0.5),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                visit.note ?? '',
                style: const TextStyle(
                    fontSize: 15, color: AppColors.scheduleText, height: 1.4),
              ),
            ),
            const SizedBox(height: 24),
            // Work required
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'WORK REQUIRED',
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.scheduleSecondaryText,
                    letterSpacing: 0.5),
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Remove weeds and general waste as required',
                style: TextStyle(
                    fontSize: 15,
                    color: AppColors.scheduleText,
                    fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 24),
            // Attachments
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'ATTACHMENTS',
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.scheduleSecondaryText,
                    letterSpacing: 0.5),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildImageBox(),
                  const SizedBox(width: 12),
                  _buildImageBox(),
                  const SizedBox(width: 12),
                  _buildAddBox(),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Upcoming Work (Mock - Hidden for Recurring Feature Integration)
            /*
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Upcoming Work',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.scheduleText),
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'REPEATING VISITS',
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.scheduleSecondaryText,
                    letterSpacing: 0.5),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.scheduleText,
                            height: 1.3),
                        children: [
                          const TextSpan(text: '4.0 hrs (\$150.00) '),
                          const WidgetSpan(
                              child: Icon(Icons.sync_alt,
                                  size: 14,
                                  color: AppColors.scheduleSecondaryText)),
                          const TextSpan(text: ' 2 wk on Mon '),
                          const WidgetSpan(
                              child: Icon(Icons.edit,
                                  size: 14,
                                  color: AppColors.scheduleSecondaryText)),
                          const WidgetSpan(
                              child: Icon(Icons.delete_outline,
                                  size: 14,
                                  color: AppColors.scheduleSecondaryText)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(visit.customerName,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.scheduleText)),
            ),
            */
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildImageBox() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider, width: 1),
        image: const DecorationImage(
          image: NetworkImage('https://via.placeholder.com/150'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildAddBox() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider, width: 1),
        color: AppColors.surfaceAlt,
      ),
      child: const Center(
          child: Icon(Icons.add_box_outlined,
              size: 36, color: AppColors.onSurfaceMuted)),
    );
  }
}
