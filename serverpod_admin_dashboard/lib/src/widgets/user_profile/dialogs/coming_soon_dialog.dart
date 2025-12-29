import 'package:flutter/material.dart';

/// Dialog to show "coming soon" message for features
class ComingSoonDialog extends StatelessWidget {
  const ComingSoonDialog({
    super.key,
    required this.feature,
  });

  final String feature;

  static const _maxWidth = 400.0;
  static const _headerPadding =
      EdgeInsets.symmetric(horizontal: 24, vertical: 20);
  static const _contentPadding = EdgeInsets.all(24);
  static const _actionsPadding = EdgeInsets.fromLTRB(16, 0, 16, 16);

  static IconData _getFeatureIcon(String feature) {
    switch (feature) {
      case 'Update Profile':
        return Icons.person_outline;
      case 'Change Password':
        return Icons.lock_outline;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: _headerPadding,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getFeatureIcon(feature),
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: _contentPadding,
              child: Text(
                '$feature feature is coming soon!',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            // Actions
            Padding(
              padding: _actionsPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows the coming soon dialog
  static void show(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (dialogContext) => ComingSoonDialog(feature: feature),
    );
  }
}
