import 'package:flutter/material.dart';

/// A foreign key value shown by name; tapping opens the related row.
class ForeignKeyValue extends StatelessWidget {
  const ForeignKeyValue({required this.id, this.label, this.onOpen, super.key});

  final String id;

  /// The related row's name, once loaded.
  final String? label;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = Text(
      label ?? '#$id',
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: onOpen == null ? null : theme.colorScheme.primary,
        decoration: onOpen == null ? null : TextDecoration.underline,
      ),
    );
    if (onOpen == null) return text;
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onOpen,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.link, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 4),
            Flexible(child: text),
          ],
        ),
      ),
    );
  }
}
