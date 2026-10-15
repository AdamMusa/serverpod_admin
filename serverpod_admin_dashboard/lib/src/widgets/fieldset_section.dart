import 'package:flutter/material.dart';
import 'package:serverpod_admin_dashboard/src/helpers/fieldsets.dart';

/// One [ColumnGroup] of a form or of details: its fields under the group's
/// name and description, folded at first when the group says so.
class FieldsetSection extends StatefulWidget {
  const FieldsetSection({
    required this.group,
    required this.child,
    this.expand = false,
    super.key,
  });

  final ColumnGroup group;

  /// The group's fields.
  final Widget child;

  /// Unfolds the section, for example to show a field's error.
  final bool expand;

  @override
  State<FieldsetSection> createState() => _FieldsetSectionState();
}

class _FieldsetSectionState extends State<FieldsetSection> {
  final _controller = ExpansibleController();

  @override
  void didUpdateWidget(FieldsetSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expand && !_controller.isExpanded) _controller.expand();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    final theme = Theme.of(context);
    final description = group.description;
    final name = group.name;
    if (name == null) {
      if (description == null) return widget.child;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          widget.child,
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        controller: _controller,
        initiallyExpanded: !group.collapsed || widget.expand,
        // Folded fields stay in the form, so they are validated and saved.
        maintainState: true,
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: 8),
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        title: Text(
          name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: description == null ? null : Text(description),
        children: [widget.child],
      ),
    );
  }
}
