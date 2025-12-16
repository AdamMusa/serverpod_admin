import 'package:flutter/material.dart';
import 'package:serverpod_admin_dashboard/src/helpers/admin_resources.dart';
import 'package:serverpod_admin_dashboard/src/helpers/format_value.dart';

/// Helper class for building data cells for records table.
/// Handles boolean values with checkmarks/crosses and regular text values.
class RecordsDataCell {
  const RecordsDataCell._();

  /// Creates a DataCell for a record column value.
  static DataCell build({
    required AdminColumn column,
    required String? value,
    VoidCallback? onTap,
  }) {
    return DataCell(
      ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 160, maxWidth: 300),
        child: Builder(
          builder: (context) {
            final theme = Theme.of(context);
            final isBoolean = isBooleanType(column);

            return isBoolean
                ? _buildBooleanCell(parseBooleanValue(value), theme)
                : _buildTextCell(column, value, theme);
          },
        ),
      ),
      onTap: onTap,
    );
  }

  static Widget _buildBooleanCell(bool value, ThemeData theme) {
    return Center(
      child: value
          ? Icon(
              Icons.check_circle,
              color: theme.colorScheme.primary,
              size: 20,
            )
          : Icon(
              Icons.cancel,
              color: theme.colorScheme.error,
              size: 20,
            ),
    );
  }

  static Widget _buildTextCell(
      AdminColumn column, String? value, ThemeData theme) {
    final formattedValue = formatRecordValue(column, value);
    final tooltipText = _truncateTooltipText(formattedValue);

    return Tooltip(
      message: tooltipText,
      child: Text(
        formattedValue,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium,
      ),
    );
  }

  static String _truncateTooltipText(String text, {int maxLength = 100}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
