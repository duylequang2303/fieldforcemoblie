import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../schedule/models/schedule_property.dart';

class SchedulePropertiesListPage extends StatefulWidget {
  const SchedulePropertiesListPage({super.key});

  @override
  State<SchedulePropertiesListPage> createState() => _SchedulePropertiesListPageState();
}

class _SchedulePropertiesListPageState extends State<SchedulePropertiesListPage> {
  @override
  Widget build(BuildContext context) {
    final properties = const [
      ScheduleProperty(address: '28 Spring Street', suburb: 'Abbotsford 2046', postcode: '2046', ownerName: 'Mable Adams'),
      ScheduleProperty(address: '25 Abbotsford Parade', suburb: 'Abbortsford 2046', postcode: '2046', ownerName: 'Cindi Abbots'),
      ScheduleProperty(address: '29 Tindale Road', suburb: 'Artarmon 2064', postcode: '2064', ownerName: 'Casey Aguilar'),
      ScheduleProperty(address: '47 Stafford Road', suburb: 'Artarmon 2064', postcode: '2064', ownerName: 'Todd Adams'),
      ScheduleProperty(address: '42 Elizabeth Street', suburb: 'Artarmon 2064', postcode: '2064', ownerName: 'Donna Alexander'),
      ScheduleProperty(address: '171 Avalon Parade', suburb: 'Avalon 2107', postcode: '2107', ownerName: 'Stewart Allen'),
      ScheduleProperty(address: '131 Hudson Parade', suburb: 'Avalon 2107', postcode: '2107', ownerName: 'Stewart Allen'),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        forceMaterialTransparency: true,
        elevation: 0,
        backgroundColor: AppColors.schedulePrimary,
        title: const Text('Properties', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            color: AppColors.schedulePrimary,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search properties',
                hintStyle: const TextStyle(color: AppColors.onSurfaceWeak),
                prefixIcon: Icon(Icons.search, color: AppColors.onSurfaceWeak),
                suffixIcon: IconButton(onPressed: () {}, icon: Icon(Icons.close, color: AppColors.onSurfaceWeak)),
                filled: true,
                fillColor: AppColors.surfaceAlt,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: properties.length,
        separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.divider, indent: 16, endIndent: 16),
        itemBuilder: (context, index) {
          final p = properties[index];
          return ListTile(
            title: Text(p.address, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.suburb, style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceMuted)),
                  Text(p.ownerName, style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceMuted)),
                ],
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceWeak),
            onTap: () => context.push('/schedule-properties/${index}', extra: p),
          );
        },
      ),
    );
  }
}