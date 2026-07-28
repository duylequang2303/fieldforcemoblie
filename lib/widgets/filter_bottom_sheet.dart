import 'package:flutter/material.dart';
import '../features/orders/models/fsm_order.dart';
import '../ui/theme/sf_tokens.dart';

/// Advanced filter bottom sheet cho Schedule.
/// Multi-select: Status + Employee + Priority.
///
/// Gọi qua [showFilterBottomSheet] — trả về [FilterResult] hoặc null (dismiss).
class FilterResult {
  final Set<FsmOrderStage> stages;
  final Set<String> persons;
  final Set<String> priorities;

  const FilterResult({
    required this.stages,
    required this.persons,
    required this.priorities,
  });

  bool get isEmpty => stages.isEmpty && persons.isEmpty && priorities.isEmpty;
}

/// Hiển thị filter sheet. Trả về [FilterResult] khi bấm Apply, null khi dismiss.
Future<FilterResult?> showFilterBottomSheet({
  required BuildContext context,
  required Set<FsmOrderStage> initialStages,
  required Set<String> initialPersons,
  required Set<String> initialPriorities,
  required List<String> availablePersons,
  required List<FsmOrder> allOrders,
}) {
  return showModalBottomSheet<FilterResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: SfTokens.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(SfTokens.radiusLg),
      ),
    ),
    builder: (_) => _FilterBottomSheetBody(
      initialStages: initialStages,
      initialPersons: initialPersons,
      initialPriorities: initialPriorities,
      availablePersons: availablePersons,
      allOrders: allOrders,
    ),
  );
}

// ─────────────────────────────────────────────
// Body (StatefulWidget — tự quản lý selection)
// ─────────────────────────────────────────────

class _FilterBottomSheetBody extends StatefulWidget {
  final Set<FsmOrderStage> initialStages;
  final Set<String> initialPersons;
  final Set<String> initialPriorities;
  final List<String> availablePersons;
  final List<FsmOrder> allOrders;

  const _FilterBottomSheetBody({
    required this.initialStages,
    required this.initialPersons,
    required this.initialPriorities,
    required this.availablePersons,
    required this.allOrders,
  });

  @override
  State<_FilterBottomSheetBody> createState() =>
      _FilterBottomSheetBodyState();
}

class _FilterBottomSheetBodyState extends State<_FilterBottomSheetBody> {
  late Set<FsmOrderStage> _stages;
  late Set<String> _persons;
  late Set<String> _priorities;

  static const Map<FsmOrderStage, String> _stageLabels = {
    FsmOrderStage.draft: 'Draft',
    FsmOrderStage.inProgress: 'In Progress',
    FsmOrderStage.done: 'Done',
    FsmOrderStage.cancelled: 'Cancelled',
  };

  static const Map<String, String> _priorityLabels = {
    '0': 'Normal',
    '1': 'High',
  };

  @override
  void initState() {
    super.initState();
    _stages = Set.of(widget.initialStages);
    _persons = Set.of(widget.initialPersons);
    _priorities = Set.of(widget.initialPriorities);
  }

  /// Đếm kết quả khớp với selection hiện tại.
  int get _resultCount {
    return widget.allOrders.where((order) {
      if (_stages.isNotEmpty && !_stages.contains(order.stage)) {
        return false;
      }
      if (_persons.isNotEmpty &&
          (order.personName == null ||
              !_persons.contains(order.personName))) {
        return false;
      }
      if (_priorities.isNotEmpty &&
          !_priorities.contains(order.priority)) {
        return false;
      }
      return true;
    }).length;
  }

  void _toggleStage(FsmOrderStage stage) {
    setState(() {
      _stages.contains(stage)
          ? _stages.remove(stage)
          : _stages.add(stage);
    });
  }

  void _togglePerson(String person) {
    setState(() {
      _persons.contains(person)
          ? _persons.remove(person)
          : _persons.add(person);
    });
  }

  void _togglePriority(String priority) {
    setState(() {
      _priorities.contains(priority)
          ? _priorities.remove(priority)
          : _priorities.add(priority);
    });
  }

  void _reset() {
    setState(() {
      _stages.clear();
      _persons.clear();
      _priorities.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters =
        _stages.isNotEmpty || _persons.isNotEmpty || _priorities.isNotEmpty;

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // ── Drag handle ──
            Padding(
              padding: const EdgeInsets.only(top: SfTokens.spacingXs),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: SfTokens.divider,
                  borderRadius:
                      BorderRadius.circular(SfTokens.radiusFull),
                ),
              ),
            ),

            // ── Header ──
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SfTokens.spacingMd,
                vertical: SfTokens.spacingSm,
              ),
              child: Row(
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: SfTokens.onSurface,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius:
                        BorderRadius.circular(SfTokens.radiusFull),
                    child: const Padding(
                      padding: EdgeInsets.all(SfTokens.spacingXxs),
                      child: Icon(
                        Icons.close,
                        size: SfTokens.iconSm,
                        color: SfTokens.onSurfaceWeak,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: SfTokens.divider),

            // ── Scrollable content ──
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(SfTokens.spacingMd),
                children: [
                  // STATUS
                  _SectionTitle(label: 'Status'),
                  const SizedBox(height: SfTokens.spacingXs),
                  Wrap(
                    spacing: SfTokens.spacingXs,
                    runSpacing: SfTokens.spacingXs,
                    children: FsmOrderStage.values.map((stage) {
                      return _SheetChip(
                        label: _stageLabels[stage]!,
                        isSelected: _stages.contains(stage),
                        onTap: () => _toggleStage(stage),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: SfTokens.spacingLg),

                  // EMPLOYEE
                  _SectionTitle(label: 'Employee'),
                  const SizedBox(height: SfTokens.spacingXs),
                  if (widget.availablePersons.isEmpty)
                    const Text(
                      'No employees assigned yet',
                      style: TextStyle(
                        fontSize: 13,
                        color: SfTokens.onSurfaceWeak,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else
                    Wrap(
                      spacing: SfTokens.spacingXs,
                      runSpacing: SfTokens.spacingXs,
                      children: widget.availablePersons.map((person) {
                        return _SheetChip(
                          label: person,
                          isSelected: _persons.contains(person),
                          leadingIcon: Icons.person_outline,
                          onTap: () => _togglePerson(person),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: SfTokens.spacingLg),

                  // PRIORITY
                  _SectionTitle(label: 'Priority'),
                  const SizedBox(height: SfTokens.spacingXs),
                  Wrap(
                    spacing: SfTokens.spacingXs,
                    runSpacing: SfTokens.spacingXs,
                    children: _priorityLabels.entries.map((entry) {
                      return _SheetChip(
                        label: entry.value,
                        isSelected: _priorities.contains(entry.key),
                        onTap: () => _togglePriority(entry.key),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // ── Footer ──
            Container(
              padding: const EdgeInsets.all(SfTokens.spacingMd),
              decoration: const BoxDecoration(
                color: SfTokens.surface,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    // Reset
                    TextButton(
                      onPressed: hasActiveFilters ? _reset : null,
                      style: TextButton.styleFrom(
                        foregroundColor: SfTokens.error,
                        disabledForegroundColor:
                            SfTokens.onSurfaceWeak.withOpacity(0.4),
                      ),
                      child: const Text(
                        'Reset',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const Spacer(),
                    // Apply
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          FilterResult(
                            stages: Set.of(_stages),
                            persons: Set.of(_persons),
                            priorities: Set.of(_priorities),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SfTokens.primary,
                        foregroundColor: SfTokens.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              SfTokens.radiusSm),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: SfTokens.spacingLg,
                          vertical: SfTokens.spacingSm,
                        ),
                      ),
                      child: Text(
                        'Show $_resultCount result${_resultCount == 1 ? '' : 's'}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// Private sub-widgets
// ─────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String label;
  const _SectionTitle({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: SfTokens.onSurfaceWeak,
        letterSpacing: 0.8,
      ),
    );
  }
}

/// Multi-select chip dùng trong bottom sheet.
class _SheetChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final IconData? leadingIcon;
  final VoidCallback onTap;

  const _SheetChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: SfTokens.spacingSm,
          vertical: SfTokens.spacingXs,
        ),
        decoration: BoxDecoration(
          color: isSelected ? SfTokens.primary : SfTokens.background,
          borderRadius: BorderRadius.circular(SfTokens.radiusSm),
          border: isSelected
              ? null
              : Border.all(color: SfTokens.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(
                Icons.check,
                size: 16,
                color: SfTokens.surface,
              ),
              const SizedBox(width: SfTokens.spacingXxs),
            ] else if (leadingIcon != null) ...[
              Icon(
                leadingIcon,
                size: 16,
                color: SfTokens.onSurfaceWeak,
              ),
              const SizedBox(width: SfTokens.spacingXxs),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? SfTokens.surface
                    : SfTokens.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}