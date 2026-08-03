import 'package:flutter/material.dart';

class ExpandableSection extends StatelessWidget {
  final String title;
  final Widget child;
  final bool initiallyExpanded;

  const ExpandableSection({
    super.key,
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
        title: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
            letterSpacing: 0.5,
          ),
        ),
        collapsedBackgroundColor: theme.colorScheme.surface,
        backgroundColor: theme.colorScheme.surface,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
              ),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
