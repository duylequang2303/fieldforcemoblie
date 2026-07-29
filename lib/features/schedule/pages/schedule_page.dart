import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../schedule/models/schedule_visit.dart';
import '../../schedule/models/schedule_property.dart';
import '../../schedule/pages/schedule_property_detail_page.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final List<String> _employees = ['Janice', 'Martin'];
  final Set<String> _selectedEmployees = {'Janice', 'Martin'};

  final List<ScheduleVisit> _visits = const [
    ScheduleVisit(
      address: '51 Warrane Road',
      suburb: 'Willoughby',
      customerName: 'Barbara Williams',
      hours: 4,
      price: 150.0,
      dueDate: 'Mon, 23 Aug 21',
      note: 'DO NOT USE BLOWERS BEFORE 9 AM - EVER!',
    ),
    ScheduleVisit(
      address: '1 Edna Street',
      suburb: 'Willoughby',
      customerName: 'Janet Wilson',
      hours: 3,
      price: 112.5,
      dueDate: 'Mon, 23 Aug 21',
    ),
    ScheduleVisit(
      address: '44 Edinburgh Road',
      suburb: 'Willoughby',
      customerName: 'Amy Watson',
      hours: 4,
      price: 150.0,
      dueDate: 'Mon, 23 Aug 21',
    ),
    ScheduleVisit(
      address: '51 King Street',
      suburb: 'Wollstonecraft',
      customerName: 'Leroy Wise',
      hours: 4,
      price: 150.0,
      dueDate: 'Mon, 23 Aug 21',
    ),
  ];

  int _selectedBottomIndex = 0; // 0 = Schedule, 1 = Properties, 2 = Settings

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeaderAndControls(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedBottomIndex,
        onTap: (i) => setState(() => _selectedBottomIndex = i),
        selectedItemColor: AppColors.schedulePrimary,
        unselectedItemColor: AppColors.scheduleSecondaryText,
        backgroundColor: AppColors.surface,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.home_work_outlined), label: 'Properties'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedBottomIndex) {
      case 0:
        return _buildScheduleBody();
      case 1:
        return _buildPropertiesBody();
      default:
        return const Center(child: Text('Settings'));
    }
  }

  Widget _buildScheduleBody() {
    final totalHrs = _visits.fold<double>(0, (s, v) => s + v.hours);
    final totalCost = _visits.fold<double>(0, (s, v) => s + v.price);
    return _buildVisitList(totalHrs, totalCost);
  }

  Widget _buildPropertiesBody() {
    final properties = const [
      ScheduleProperty(id: 0, address: '28 Spring Street', suburb: 'Abbotsford 2046', postcode: '2046', ownerName: 'Mable Adams', imageUrl: 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=600'),
      ScheduleProperty(id: 0, address: '25 Abbotsford Parade', suburb: 'Abbortsford 2046', postcode: '2046', ownerName: 'Cindi Abbots'),
      ScheduleProperty(id: 0, address: '29 Tindale Road', suburb: 'Artarmon 2064', postcode: '2064', ownerName: 'Casey Aguilar'),
      ScheduleProperty(id: 0, address: '47 Stafford Road', suburb: 'Artarmon 2064', postcode: '2064', ownerName: 'Todd Adams'),
      ScheduleProperty(id: 0, address: '42 Elizabeth Street', suburb: 'Artarmon 2064', postcode: '2064', ownerName: 'Donna Alexander'),
      ScheduleProperty(id: 0, address: '171 Avalon Parade', suburb: 'Avalon 2107', postcode: '2107', ownerName: 'Stewart Allen'),
      ScheduleProperty(id: 0, address: '131 Hudson Parade', suburb: 'Avalon 2107', postcode: '2107', ownerName: 'Stewart Allen'),
    ];

    return SearchAnchor(
      builder: (context, controller) => SearchBar(
        controller: controller,
        padding: const MaterialStatePropertyAll<EdgeInsets>(EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
        leading: Icon(Icons.search, color: AppColors.scheduleSecondaryText, size: 20),
        trailing: [
          IconButton(onPressed: () {}, icon: Icon(Icons.close, size: 18, color: AppColors.scheduleSecondaryText)),
          TextButton(onPressed: () {}, child: const Text('Search', style: TextStyle(fontSize: 14))),
        ],
        hintText: 'Search properties',
        hintStyle: MaterialStatePropertyAll(TextStyle(color: AppColors.scheduleSecondaryText, fontSize: 14)),
      ),
      suggestionsBuilder: (context, controller) {
        final filtered = properties.where((p) {
          final q = controller.text.toLowerCase();
          return p.address.toLowerCase().contains(q) || p.ownerName.toLowerCase().contains(q);
        }).toList();
        return filtered
            .map((p) => ListTile(
                  title: Text(p.address, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.scheduleText)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.suburb, style: const TextStyle(fontSize: 14, color: AppColors.scheduleSecondaryText)),
                      Text(p.ownerName, style: const TextStyle(fontSize: 14, color: AppColors.scheduleSecondaryText)),
                    ],
                  ),
                  onTap: () {
                    controller.closeView(p.address);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => SchedulePropertyDetailPage(property: p)));
                  },
                ))
            .toList();
      },
    );
  }

  Widget _buildHeaderAndControls() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.schedulePrimary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top controls row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildControlButton('Today', selected: true),
                    const SizedBox(width: 8),
                    _navIcon(Icons.chevron_left, Colors.white),
                    _navIcon(Icons.chevron_right, Colors.white),
                  ],
                ),
                Row(
                  children: [
                    _iconButton(Icons.view_list, Colors.white),
                    const SizedBox(width: 12),
                    _iconButton(Icons.filter_list, AppColors.accentLight),
                    const SizedBox(width: 12),
                    _buildWeekToggle(),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Date badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'MON, 23 AUG',
                style: TextStyle(
                  color: AppColors.schedulePrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 14),
            // Employee chips
            ..._selectedEmployees.map((e) => _buildEmployeeChip(e)),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(String text, {bool selected = false}) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: selected ? AppColors.schedulePrimary : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _navIcon(IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Icon(icon, color: color, size: 18),
    );
  }

  Widget _iconButton(IconData icon, Color color) {
    return InkWell(onTap: () {}, child: Icon(icon, color: color, size: 20));
  }

  Widget _buildWeekToggle() {
    final isWeek = true;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.onSurfaceWeak),
      ),
      child: Row(
        children: [
          Text('Week', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: isWeek ? FontWeight.w600 : FontWeight.normal)),
          const SizedBox(width: 6),
          Icon(Icons.expand_more, color: Colors.white, size: 18),
        ],
      ),
    );
  }

  Widget _buildEmployeeChip(String name) {
    final isSelected = _selectedEmployees.contains(name);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedEmployees.remove(name);
            } else {
              _selectedEmployees.add(name);
            }
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accentLight : Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: isSelected ? null : Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Row(
            children: [
              // Avatar circle with initial
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.schedulePrimary : Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    name[0].toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.schedulePrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    color: isSelected ? AppColors.schedulePrimary : Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isSelected)
                Icon(Icons.close, color: AppColors.schedulePrimary, size: 20)
              else
                Icon(Icons.person_add_outlined, color: Colors.white.withOpacity(0.8), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisitList(double totalHrs, double totalCost) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _visits.length + 1,
      itemBuilder: (context, i) {
        if (i == _visits.length) return _buildAddVisitAndTotal(totalHrs, totalCost);
        return _VisitCard(
          visit: _visits[i],
          onTap: () => _showVisitDetailModal(context, _visits[i]),
        );
      },
    );
  }

  void _showVisitDetailModal(BuildContext context, ScheduleVisit visit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _VisitDetailModal(visit: visit),
    );
  }

  Widget _buildAddVisitAndTotal(double totalHrs, double totalCost) {
    return Column(
      children: [
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {},
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.divider, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(child: Text('Add Visit', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(color: AppColors.accentDark),
          child: Row(
            children: [
              Expanded(
                child: Text('${totalHrs.toStringAsFixed(2)} hrs (\$ ${totalCost.toStringAsFixed(0)})', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
              ),
              Icon(Icons.settings, color: Colors.white70, size: 18),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _VisitCard extends StatelessWidget {
  final ScheduleVisit visit;
  final VoidCallback? onTap;

  const _VisitCard({required this.visit, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            // Orange accent bar (like SortScape)
            Container(
              width: 5,
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0xFFFF9800), // Orange accent
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date badge
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: AppColors.onSurfaceMuted),
                        const SizedBox(width: 6),
                        Text(
                          visit.dueDate,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.onSurfaceMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        // Hours badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.infoContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time, size: 13, color: AppColors.info),
                              const SizedBox(width: 4),
                              Text(
                                '${visit.hours} hr',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.info,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Address (bold)
                    Text(
                      visit.address,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Suburb
                    Text(
                      '${visit.suburb} NSW 2068',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurfaceMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Customer name (with person icon)
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 16, color: AppColors.accent),
                        const SizedBox(width: 6),
                        Text(
                          visit.customerName,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Quick action icons column
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _QuickActionIcon(
                    icon: Icons.phone,
                    color: AppColors.accent,
                    onTap: () {},
                  ),
                  const SizedBox(height: 8),
                  _QuickActionIcon(
                    icon: Icons.directions,
                    color: AppColors.accent,
                    onTap: () {},
                  ),
                  if (visit.note != null && visit.note!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _QuickActionIcon(
                      icon: Icons.comment_outlined,
                      color: AppColors.warning,
                      onTap: () {},
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionIcon({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}

// Detail modal like SortScape style
class _VisitDetailModal extends StatelessWidget {
  final ScheduleVisit visit;

  const _VisitDetailModal({required this.visit});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Close button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Job Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  color: AppColors.onSurfaceMuted,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and time
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: AppColors.accent),
                      const SizedBox(width: 8),
                      Text(
                        visit.dueDate,
                        style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceMuted),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time, size: 16, color: AppColors.accent),
                      const SizedBox(width: 8),
                      Text(
                        '${visit.hours} hr',
                        style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceMuted),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.infoContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '\$${visit.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Address
                  const Text(
                    'ADDRESS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurfaceMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    visit.address,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    '${visit.suburb} NSW 2068',
                    style: const TextStyle(fontSize: 15, color: AppColors.onSurfaceMuted),
                  ),
                  const SizedBox(height: 20),
                  // Customer
                  const Text(
                    'CUSTOMER',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurfaceMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            visit.customerName[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        visit.customerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                  if (visit.note != null && visit.note!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'GENERAL INSTRUCTIONS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurfaceMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.warningContainer,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                      ),
                      child: Text(
                        visit.note!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.onSurface,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  // Quick action buttons (like SortScape)
                  Row(
                    children: [
                      Expanded(
                        child: _DetailActionButton(
                          icon: Icons.phone,
                          label: 'Call',
                          color: AppColors.accent,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DetailActionButton(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          color: AppColors.info,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DetailActionButton(
                          icon: Icons.directions,
                          label: 'Directions',
                          color: AppColors.accent,
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Mark complete button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Mark complete',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Skip button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.onSurfaceMuted,
                        side: const BorderSide(color: AppColors.divider),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DetailActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
