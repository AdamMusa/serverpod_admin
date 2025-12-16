import 'package:flutter/material.dart';
import 'package:serverpod_admin_dashboard/src/controller/admin_dashboard.dart';
import 'package:serverpod_admin_dashboard/src/helpers/admin_resources.dart';
import 'package:serverpod_admin_dashboard/src/helpers/foreign_key_helper.dart';

/// A dropdown widget for selecting foreign key values.
class ForeignKeyDropdown extends StatelessWidget {
  const ForeignKeyDropdown({
    required this.column,
    required this.controller,
    required this.options,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final AdminColumn column;
  final AdminDashboardController controller;
  final List<Map<String, String>> options;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final relatedResource = ForeignKeyHelper.findRelatedResource(
      controller,
      column,
    );

    if (relatedResource == null) {
      // Resource not found, show disabled dropdown
      return DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: column.name,
          hintText: 'Related resource not found',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest,
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.error.withOpacity(0.5),
            ),
          ),
        ),
        items: [
          if (value != null)
            DropdownMenuItem<String>(
              value: value,
              child: Text(value!),
            ),
        ],
        onChanged: null,
      );
    }

    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: column.name,
        hintText: 'Select ${column.name}',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest,
      ),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('None'),
        ),
        ...options.map((record) {
          final primaryValue =
              ForeignKeyHelper.getPrimaryKeyValue(record, relatedResource);
          if (primaryValue == null) return null;

          return DropdownMenuItem<String>(
            value: primaryValue,
            child: Text(
              ForeignKeyHelper.formatForeignKeyOption(
                record,
                relatedResource,
              ),
            ),
          );
        }).whereType<DropdownMenuItem<String>>(),
      ],
      onChanged: onChanged,
      validator: (_) => null, // Validation is handled by parent form
    );
  }
}
