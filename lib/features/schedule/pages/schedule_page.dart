import 'package:flutter/material.dart';
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
      dueDate: 'due Mon',
      note: 'DO NOT USE BLOWERS BEFORE 9 AM - EVER!',
    ),
    ScheduleVisit(
      address: '1 Edna Street',
      suburb: 'Willoughby',
      customerName: 'Janet Wilson',
      hours: 3,
      price: 112.5,
      dueDate: 'due Mon',
    ),
    ScheduleVisit(
      address: '44 Edinburgh Road',
      suburb: 'Willoughby',
      customerName: 'Amy Watson',
      hours: 4,
      price: 150.0,
      dueDate: 'due Mon',
    ),
    ScheduleVisit(
      address: '51 King Street',
      suburb: 'Wollstonecraft',
      customerName: 'Leroy Wise',
      hours: 4,
      price: 150.0,
      dueDate: 'due Mon',
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
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Properties'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
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
      ScheduleProperty(address: '28 Spring Street', suburb: 'Abbotsford 2046', postcode: '2046', ownerName: 'Mable Adams', imageUrl: 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=600'),
      ScheduleProperty(address: '25 Abbotsford Parade', suburb: 'Abbortsford 2046', postcode: '2046', ownerName: 'Cindi Abbots'),
      ScheduleProperty(address: '29 Tindale Road', suburb: 'Artarmon 2064', postcode: '2064', ownerName: 'Casey Aguilar'),
      ScheduleProperty(address: '47 Stafford Road', suburb: 'Artarmon 2064', postcode: '2064', ownerName: 'Todd Adams'),
      ScheduleProperty(address: '42 Elizabeth Street', suburb: 'Artarmon 2064', postcode: '2064', ownerName: 'Donna Alexander'),
      ScheduleProperty(address: '171 Avalon Parade', suburb: 'Avalon 2107', postcode: '2107', ownerName: 'Stewart Allen'),
      ScheduleProperty(address: '131 Hudson Parade', suburb: 'Avalon 2107', postcode: '2107', ownerName: 'Stewart Allen'),
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
    return ColoredBox(
      color: AppColors.schedulePrimary,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _buildControlButton('Today', selected: true)),
                _navIcon(Icons.arrow_left, Colors.white),
                _navIcon(Icons.arrow_right, Colors.white),
                const SizedBox(width: 18),
                _iconButton(Icons.calendar_today, Colors.white),
                const SizedBox(width: 14),
                _iconButton(Icons.filter_list, AppColors.accentLight),
                const Spacer(),
                _buildWeekToggle(),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'MON, 26 MAY 2025',
                style: TextStyle(color: AppColors.schedulePrimary, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.3),
              ),
            ),
            const SizedBox(height: 16),
            ..._selectedEmployees.map((e) => _buildEmployeeChip(e)),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(String text, {bool selected = false}) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(text, style: TextStyle(color: selected ? AppColors.schedulePrimary : Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
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
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.schedulePrimaryContainer : AppColors.schedulePrimary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const SizedBox(width: 10),
            Icon(Icons.person_outline, color: isSelected ? AppColors.schedulePrimary : Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(name, style: TextStyle(color: isSelected ? AppColors.schedulePrimary : Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
            ),
            if (isSelected)
              Icon(Icons.clear, color: AppColors.schedulePrimary, size: 18),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitList(double totalHrs, double totalCost) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      itemCount: _visits.length + 1,
      itemBuilder: (context, i) {
        if (i == _visits.length) return _buildAddVisitAndTotal(totalHrs, totalCost);
        return _VisitCard(visit: _visits[i]);
      },
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

  const _VisitCard({required this.visit});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(visit.address, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                    const SizedBox(height: 3),
                    Text('${visit.suburb} · ${visit.customerName}', style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceMuted)),
                    const SizedBox(height: 4),
                    Text(visit.dueDate, style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceMuted)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _ActionButton(icon: Icons.sync, label: '${visit.hours}h', color: AppColors.accentDark),
              const SizedBox(width: 14),
              _ActionButton(icon: Icons.comment_outlined, label: '', color: AppColors.onSurfaceMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ActionButton({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        if (label.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        ],
      ],
    );
  }
}
