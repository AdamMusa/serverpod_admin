import 'package:flutter/material.dart';
import 'package:serverpod_admin_dashboard/src/controller/admin_dashboard.dart';
import 'package:serverpod_admin_dashboard/src/controller/dialog_form_controller.dart';
import 'package:serverpod_admin_dashboard/src/helpers/admin_resources.dart';
import 'package:serverpod_admin_dashboard/src/helpers/dialog_form_helper.dart';
import 'package:serverpod_admin_dashboard/src/widgets/foreign_key_dropdown.dart';

/// Reusable form field widget for dialog forms.
/// Handles booleans, enums, foreign keys, dates, passwords, and text fields.
class DialogFormField extends StatelessWidget {
  const DialogFormField({
    required this.column,
    required this.formController,
    required this.adminController,
    super.key,
  });

  final AdminColumn column;
  final DialogFormController formController;
  final AdminDashboardController adminController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDate = DialogFormHelper.isDateType(column);
    final isForeignKey = column.foreignKeyTable != null;
    final isBoolean = DialogFormHelper.isBooleanType(column);
    final isEnum = DialogFormHelper.isEnumType(column);
    final isPassword = DialogFormHelper.isPasswordField(column);
    final isNullable = column.isNullable == true;
    final fieldLabel = isNullable ? '${column.name} (optional)' : column.name;

    // Boolean checkbox
    if (isBoolean) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: AnimatedBuilder(
          animation: formController,
          builder: (context, _) {
            return CheckboxListTile(
              title: Text(fieldLabel),
              value: formController.booleanValues[column.name] ?? false,
              onChanged: (value) {
                formController.setBooleanValue(column.name, value ?? false);
              },
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            );
          },
        ),
      );
    }

    if (isEnum) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: AnimatedBuilder(
          animation: formController,
          builder: (context, _) {
            return DropdownButtonFormField<String>(
              initialValue: formController.enumValues[column.name],
              isExpanded: true,
              decoration: InputDecoration(
                labelText: fieldLabel,
                hintText: isNullable
                    ? 'Optional — select a value'
                    : 'Select ${column.name}',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
              ),
              items: column.enumValues!
                  .map(
                    (value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                formController.setEnumValue(column.name, value);
              },
              validator: (value) =>
                  !isNullable && (value == null || value.isEmpty)
                  ? 'Please select ${column.name}'
                  : null,
            );
          },
        ),
      );
    }

    // Foreign key dropdown
    if (isForeignKey) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: AnimatedBuilder(
          animation: formController,
          builder: (context, _) {
            final options = formController.foreignKeyOptions[column.name] ?? [];

            return ForeignKeyDropdown(
              column: column,
              controller: adminController,
              options: options,
              value: formController.foreignKeyValues[column.name],
              onChanged: (value) {
                formController.setForeignKeyValue(column.name, value);
              },
            );
          },
        ),
      );
    }

    // Regular text field or date field
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AnimatedBuilder(
        animation: formController,
        builder: (context, _) {
          return TextFormField(
            controller: formController.controllers[column.name],
            readOnly: isDate,
            obscureText:
                isPassword &&
                (formController.obscurePasswordValues[column.name] ?? true),
            maxLines: isPassword ? 1 : null,
            minLines: 1,
            onTap: isDate ? () => _handleDateTap(context) : null,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              labelText: fieldLabel,
              hintText: isNullable
                  ? 'Optional — leave empty'
                  : isDate
                  ? 'Tap to select date'
                  : 'Enter ${column.name}',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
              suffixIcon: isDate
                  ? IconButton(
                      icon: const Icon(Icons.calendar_today_outlined),
                      onPressed: () => _handleDateTap(context),
                    )
                  : isPassword
                  ? IconButton(
                      tooltip:
                          formController.obscurePasswordValues[column.name] ??
                              true
                          ? 'Show password'
                          : 'Hide password',
                      icon: Icon(
                        formController.obscurePasswordValues[column.name] ??
                                true
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () =>
                          formController.togglePasswordVisibility(column.name),
                    )
                  : null,
            ),
            validator: (value) =>
                _validateField(value, isDate, isBoolean, isForeignKey),
          );
        },
      ),
    );
  }

  Future<void> _handleDateTap(BuildContext context) async {
    final currentIso = formController.isoValues[column.name];
    final picked = await DialogFormHelper.pickDateTime(
      context,
      currentIso,
      column,
    );
    if (picked != null) {
      final displayValue = DialogFormHelper.formatDateValue(picked, column);
      formController.setDateValue(column.name, picked, displayValue);
    }
  }

  String? _validateField(
    String? value,
    bool isDate,
    bool isBoolean,
    bool isForeignKey,
  ) {
    if (isBoolean || isForeignKey) {
      return null;
    }
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    if (isDate && value.isNotEmpty) {
      final isoValue = formController.isoValues[column.name];
      if (isoValue == null || isoValue.isEmpty) {
        return 'Please select a date';
      }
      if (DateTime.tryParse(isoValue) == null) {
        return 'Invalid date';
      }
    }
    return null;
  }
}
