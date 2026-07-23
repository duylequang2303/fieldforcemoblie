import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../schedule/models/schedule_property.dart';

class SchedulePropertyDetailPage extends StatefulWidget {
  final ScheduleProperty property;

  const SchedulePropertyDetailPage({super.key, required this.property});

  @override
  State<SchedulePropertyDetailPage> createState() => _SchedulePropertyDetailPageState();
}

class _SchedulePropertyDetailPageState extends State<SchedulePropertyDetailPage> {
  @override
  Widget build(BuildContext context) {
    final p = widget.property;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          // Image gallery header
          Container(
            height: 240,
            width: double.infinity,
            color: Colors.black,
            child: Stack(
              children: [
                PageView(
                  children: [
                    Image.network(
                      p.imageUrl ?? 'https://via.placeholder.com/600',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    const Center(child: Text('Street view', style: TextStyle(color: Colors.white, fontSize: 14))),
                  ],
                ),
                Positioned(
                  left: 12,
                  top: MediaQuery.of(context).padding.top + 12,
                  child: Container(
                    decoration: const BoxDecoration(color: AppColors.schedulePrimary, shape: BoxShape.circle),
                    child: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white)),
                  ),
                ),
                const Positioned(
                  right: 16,
                  top: 80,
                  child: Icon(Icons.edit, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Address and contact
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.address, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                const SizedBox(height: 4),
                Text('${p.suburb} NSW ${p.postcode}', style: const TextStyle(fontSize: 15, color: AppColors.onSurfaceMuted)),
                const SizedBox(height: 4),
                Text(p.ownerName, style: const TextStyle(fontSize: 15, color: AppColors.onSurfaceMuted)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Action icons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
           child: Row(
             children: const [
               Spacer(),
               Icon(Icons.phone, color: AppColors.accent),
               SizedBox(width: 24),
               Icon(Icons.comment_outlined, color: AppColors.accent),
               SizedBox(width: 24),
               Icon(Icons.email_outlined, color: AppColors.accent),
               SizedBox(width: 24),
               Icon(Icons.navigation, color: AppColors.accent),
             ],
           ),
          ),
          const SizedBox(height: 24),
          // Upcoming work header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Upcoming Work', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.scheduleText)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.add_box_outlined, color: AppColors.scheduleSecondaryText)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('REPEATING VISITS', style: TextStyle(fontSize: 12, color: AppColors.scheduleSecondaryText, letterSpacing: 0.5)),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 14, color: AppColors.scheduleText, height: 1.3),
                children: [
                  TextSpan(text: '4.0 hrs (\$150.00) '),
                  WidgetSpan(child: Icon(Icons.sync_alt, size: 14, color: AppColors.scheduleSecondaryText)),
                  TextSpan(text: ' 2 wk on Mon '),
                  WidgetSpan(child: Icon(Icons.edit, size: 14, color: AppColors.scheduleSecondaryText)),
                  WidgetSpan(child: Icon(Icons.delete_outline, size: 14, color: AppColors.scheduleSecondaryText)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Remove weeds and general waste as required', style: const TextStyle(fontSize: 14, color: AppColors.scheduleText)),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}