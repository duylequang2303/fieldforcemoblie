import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/connectivity/connectivity_service.dart';
import '../ui/theme/sf_tokens.dart';

/// Sortscape-style top bar cho tab Schedule.
/// Thay thế AppBar cũ + DateNavigationBar.
///
/// [viewMode]: 'Today' | 'Week' — hiển thị trên pill chính.
/// [selectedDate]: ngày đang chọn (để render badge).
/// Callbacks: [onPrevious], [onNext], [onCalendarTap], [onFilterTap],
///            [onViewModeChanged].
class ScheduleTopBar extends StatefulWidget {
  final String viewMode;
  final DateTime selectedDate;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onCalendarTap;
  final VoidCallback onFilterTap;
  final ValueChanged<String> onViewModeChanged;

  const ScheduleTopBar({
    super.key,
    required this.viewMode,
    required this.selectedDate,
    required this.onPrevious,
    required this.onNext,
    required this.onCalendarTap,
    required this.onFilterTap,
    required this.onViewModeChanged,
  });

  @override
  State<ScheduleTopBar> createState() => _ScheduleTopBarState();
}

class _ScheduleTopBarState extends State<ScheduleTopBar> {
  final _connectivity = ConnectivityService.instance;
  bool _isOffline = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _checkInitial();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
  }

  Future<void> _checkInitial() async {
    final online = await _connectivity.checkConnectivity();
    if (mounted) setState(() => _isOffline = !online);
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) async {
    final online = await _connectivity.checkConnectivity();
    if (mounted) setState(() => _isOffline = !online);
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  /// Format "MON, 27 JUL" từ selectedDate.
  String get _dateBadgeText {
    final f = DateFormat('EEE, dd MMM', 'en_US');
    if (widget.viewMode == 'Week') {
      final startOfWeek = widget.selectedDate.subtract(
          Duration(days: widget.selectedDate.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      return '${f.format(startOfWeek)} - ${f.format(endOfWeek)}';
    }
    return f.format(widget.selectedDate).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: SfTokens.primary,
        boxShadow: [
          BoxShadow(
            color: Color(
                0x14000000), // 8% black — shadow duy nhất, không phải màu brand
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            SfTokens.spacingMd,
            SfTokens.spacingSm,
            SfTokens.spacingMd,
            SfTokens.spacingMd,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Row 1: controls ──
              Row(
                children: [
                  // "Today" / "Week" pill
                  _ViewModePill(
                    label: widget.viewMode,
                    onTap: () => _showViewModeMenu(context),
                  ),
                  const SizedBox(width: SfTokens.spacingXs),

                  // ◀ arrow
                  _ArrowButton(icon: Icons.chevron_left, onTap: widget.onPrevious),

                  // ▶ arrow
                  _ArrowButton(icon: Icons.chevron_right, onTap: widget.onNext),

                  const Spacer(),

                  // Offline indicator
                  if (_isOffline)
                    Padding(
                      padding: const EdgeInsets.only(right: SfTokens.spacingSm),
                      child: Icon(
                        Icons.wifi_off_rounded,
                        color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
                        size: SfTokens.iconMd,
                      ),
                    ),

                  // 📅 calendar
                  _TopBarIconButton(
                    icon: Icons.calendar_today,
                    color: SfTokens.surface,
                    onTap: widget.onCalendarTap,
                  ),
                  const SizedBox(width: SfTokens.spacingSm),

                  // 🔍 filter
                  _TopBarIconButton(
                    icon: Icons.filter_list,
                    color: SfTokens.primaryLight,
                    onTap: widget.onFilterTap,
                  ),
                  const SizedBox(width: SfTokens.spacingSm),

                  // "Week ▾" toggle
                  _WeekToggle(
                    currentMode: widget.viewMode,
                    onTap: () => _showViewModeMenu(context),
                  ),
                ],
              ),

              const SizedBox(height: SfTokens.spacingSm),

              // ── Row 2: date badge ──
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: SfTokens.spacingSm,
                  vertical: SfTokens.spacingXs + 2, // ~10px
                ),
                decoration: BoxDecoration(
                  color: SfTokens.primaryLight,
                  borderRadius: BorderRadius.circular(SfTokens.radiusXs),
                ),
                child: Text(
                  _dateBadgeText,
                  style: const TextStyle(
                    color: SfTokens.primaryDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Popup menu chọn Today / Week / Month.
  void _showViewModeMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: SfTokens.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(SfTokens.radiusLg)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['Today', 'Week', 'Month'].map((mode) {
              final isActive = mode == widget.viewMode;
              return ListTile(
                leading: Icon(
                  isActive
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: isActive ? SfTokens.primary : SfTokens.onSurfaceWeak,
                ),
                title: Text(
                  mode,
                  style: TextStyle(
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                    color: isActive ? SfTokens.primary : SfTokens.onSurface,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  widget.onViewModeChanged(mode);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// Private sub-widgets
// ─────────────────────────────────────────────

/// Pill "Today" / "Week" — nền trắng khi active.
class _ViewModePill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ViewModePill({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: SfTokens.spacingMd),
        decoration: BoxDecoration(
          color: SfTokens.surface,
          borderRadius: BorderRadius.circular(SfTokens.radiusSm),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: SfTokens.primary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

/// Nút mũi tên ◀ ▶ trên nền primary.
class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SfTokens.radiusFull),
      child: Padding(
        padding: const EdgeInsets.all(SfTokens.spacingXxs),
        child: Icon(icon, color: SfTokens.surface, size: SfTokens.iconSm),
      ),
    );
  }
}

/// Icon button tròn trên top bar.
class _TopBarIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _TopBarIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SfTokens.radiusFull),
      child: Icon(icon, color: color, size: SfTokens.iconMd),
    );
  }
}

/// Toggle "Week ▾" nhỏ bên phải.
class _WeekToggle extends StatelessWidget {
  final String currentMode;
  final VoidCallback onTap;

  const _WeekToggle({required this.currentMode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SfTokens.spacingXs + 2,
          vertical: SfTokens.spacingXxs + 2,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SfTokens.radiusSm),
          border: Border.all(color: SfTokens.surface.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentMode,
              style: const TextStyle(
                color: SfTokens.surface,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: SfTokens.spacingXxs),
            const Icon(
              Icons.expand_more,
              color: SfTokens.surface,
              size: SfTokens.iconSm,
            ),
          ],
        ),
      ),
    );
  }
}
