import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Empty state dùng chung: icon trong khối bo góc + tiêu đề + gợi ý hành động.
///
/// Dùng cho các danh sách rỗng (vật tư, khoản chi, ...) thay vì mỗi page tự
/// dựng lại cùng một layout.
class IconEmptyState extends StatelessWidget {
  const IconEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.iconBackgroundColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color iconBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, size: 40, color: iconColor),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
                fontSize: 14, color: AppColors.onSurfaceMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
