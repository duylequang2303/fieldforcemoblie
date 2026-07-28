import 'package:flutter/material.dart';
import '../features/orders/models/fsm_order.dart';
import '../ui/theme/sf_tokens.dart';

/// Horizontal scrollable filter chips cho Schedule.
///
/// [selectedStage] = null → "All" đang chọn.
/// [onStageSelected] trả về null khi bấm "All".
class FilterChipsRow extends StatelessWidget {
  final FsmOrderStage? selectedStage;
  final ValueChanged<FsmOrderStage?> onStageSelected;

  const FilterChipsRow({
    super.key,
    required this.selectedStage,
    required this.onStageSelected,
  });

  /// Label hiển thị cho từng stage.
  static const Map<FsmOrderStage, String> _labels = {
    FsmOrderStage.draft: 'Draft',
    FsmOrderStage.inProgress: 'In Progress',
    FsmOrderStage.done: 'Done',
    FsmOrderStage.cancelled: 'Cancelled',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SfTokens.background,
      padding: const EdgeInsets.symmetric(
        horizontal: SfTokens.spacingMd,
        vertical: SfTokens.spacingXs,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            // ── "All" chip ──
            _Chip(
              label: 'All',
              isSelected: selectedStage == null,
              onTap: () => onStageSelected(null),
            ),
            const SizedBox(width: SfTokens.spacingXs),

            // ── 4 stage chips ──
            ...FsmOrderStage.values.map((stage) {
              return Padding(
                padding: const EdgeInsets.only(right: SfTokens.spacingXs),
                child: _Chip(
                  label: _labels[stage]!,
                  isSelected: selectedStage == stage,
                  onTap: () => onStageSelected(
                    selectedStage == stage ? null : stage,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Single filter chip — custom để kiểm soát màu qua SfTokens.
class _Chip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: SfTokens.spacingMd),
        decoration: BoxDecoration(
          color: isSelected ? SfTokens.primary : SfTokens.surface,
          borderRadius: BorderRadius.circular(SfTokens.radiusSm),
          border: isSelected
              ? null
              : Border.all(color: SfTokens.divider),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(
                Icons.check,
                size: SfTokens.iconSm - 4, // 16px
                color: SfTokens.surface,
              ),
              const SizedBox(width: SfTokens.spacingXxs),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? SfTokens.surface : SfTokens.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}