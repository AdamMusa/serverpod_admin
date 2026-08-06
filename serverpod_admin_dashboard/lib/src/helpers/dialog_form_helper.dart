import 'package:flutter/material.dart'
    show BuildContext, showDatePicker, showTimePicker, TimeOfDay;
import 'package:serverpod_admin_client/serverpod_admin_client.dart';

/// Shared helper utilities for dialog forms.
class DialogFormHelper {
  static bool isDateType(AdminColumn column) {
    final dataType = column.dataType.toLowerCase();
    return dataType.contains('date') || dataType.contains('time');
  }

  static bool isBooleanType(AdminColumn column) {
    final dataType = column.dataType.toLowerCase();
    return dataType.contains('bool');
  }

  static bool isEnumType(AdminColumn column) {
    return column.enumValues?.isNotEmpty ?? false;
  }

  static bool isPasswordField(AdminColumn column) {
    return column.name.toLowerCase().contains('password');
  }

  static bool parseBoolean(String value) {
    if (value.isEmpty) return false;
    final lower = value.toLowerCase().trim();
    return lower == 'true' || lower == '1' || lower == 'yes';
  }

  static String formatDateValue(String? value, AdminColumn column) {
    if (value == null || value.isEmpty) return '';
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;

    final local = parsed.toLocal();
    final isDateTime = column.dataType.toLowerCase().contains('datetime');

    if (isDateTime) {
      final year = local.year.toString().padLeft(4, '0');
      final month = local.month.toString().padLeft(2, '0');
      final day = local.day.toString().padLeft(2, '0');
      final hour = local.hour.toString().padLeft(2, '0');
      final minute = local.minute.toString().padLeft(2, '0');
      return '$year-$month-$day $hour:$minute';
    } else {
      final year = local.year.toString().padLeft(4, '0');
      final month = local.month.toString().padLeft(2, '0');
      final day = local.day.toString().padLeft(2, '0');
      return '$year-$month-$day';
    }
  }

  static Future<String?> pickDateTime(
    BuildContext context,
    String? currentValue,
    AdminColumn column,
  ) async {
    final now = DateTime.now();
    final initial = currentValue != null && currentValue.isNotEmpty
        ? DateTime.tryParse(currentValue)?.toLocal() ?? now
        : now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return null;

    final isDateTime = column.dataType.toLowerCase().contains('datetime');

    if (isDateTime) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initial),
      );
      if (pickedTime == null) return null;

      final dateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      return dateTime.toUtc().toIso8601String();
    } else {
      final dateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
      );
      return dateTime.toUtc().toIso8601String();
    }
  }
}
