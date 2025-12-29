import 'package:flutter/material.dart';

/// Menu item data for user menu
class UserMenuItem {
  const UserMenuItem({
    required this.value,
    required this.label,
    required this.icon,
    this.isDestructive = false,
  });

  final String value;
  final String label;
  final IconData icon;
  final bool isDestructive;
}

/// Extension to convert UserMenuItem to PopupMenuItem
extension UserMenuItemExtension on UserMenuItem {
  PopupMenuItem<String> toPopupMenuItem(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        isDestructive ? theme.colorScheme.error : theme.colorScheme.onSurface;

    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
