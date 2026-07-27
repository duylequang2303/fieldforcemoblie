import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../ui/theme/sf_tokens.dart';

/// Shell navigation với 3 tab: Schedule, Properties, Settings.
/// Sử dụng StatefulShellRoute.indexedStack để giữ state mỗi tab.
class AppShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  void _goToBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: _goToBranch,
        backgroundColor: SfTokens.surface,
        indicatorColor: SfTokens.primaryMuted,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today, color: SfTokens.primary),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: SfTokens.primary),
            label: 'Properties',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: SfTokens.primary),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
