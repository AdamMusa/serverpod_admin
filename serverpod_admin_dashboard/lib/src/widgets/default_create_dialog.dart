import 'package:flutter/material.dart';
import 'package:serverpod_admin_dashboard/src/helpers/admin_resources.dart';

/// Default create dialog with modern design
class DefaultCreateDialog extends StatefulWidget {
  const DefaultCreateDialog({
    required this.resource,
    required this.onSubmit,
    super.key,
  });

  final AdminResource resource;
  final Future<bool> Function(Map<String, String> payload) onSubmit;

  @override
  State<DefaultCreateDialog> createState() => _DefaultCreateDialogState();
}

class _DefaultCreateDialogState extends State<DefaultCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _isoValues = {}; // Store ISO8601 values separately
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Only include non-primary columns for create
    for (final column in widget.resource.columns) {
      if (column.isPrimary) continue;
      _controllers[column.name] = TextEditingController();
      _isoValues[column.name] = '';
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final payload = <String, String>{};
    for (final entry in _controllers.entries) {
      final column = widget.resource.columns.firstWhere(
        (col) => col.name == entry.key,
      );

      if (_isDateType(column)) {
        // Use ISO8601 value for date fields
        final isoValue = _isoValues[entry.key];
        payload[entry.key] = isoValue ?? '';
      } else {
        // Use text value for other fields
        payload[entry.key] = entry.value.text.trim();
      }
    }

    final success = await widget.onSubmit(payload);
    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Failed to create record. Please try again.';
      });
    }
  }

  bool _isDateType(AdminColumn column) {
    final dataType = column.dataType.toLowerCase();
    return dataType.contains('date') || dataType.contains('time');
  }

  Future<String?> _pickDateTime(
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
      // Date only
      final dateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
      );
      return dateTime.toUtc().toIso8601String();
    }
  }

  String _formatDateValue(String? value, AdminColumn column) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.1),
                    theme.colorScheme.primary.withOpacity(0.05),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.add_circle_outline,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create ${widget.resource.tableName}',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Fill in the fields below to create a new record',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      ...widget.resource.columns
                          .where((col) => !col.isPrimary)
                          .map((column) {
                        final isDate = _isDateType(column);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: TextFormField(
                            controller: _controllers[column.name],
                            readOnly: isDate,
                            maxLines: null,
                            minLines: 1,
                            onTap: isDate
                                ? () async {
                                    final currentIso = _isoValues[column.name];
                                    final picked = await _pickDateTime(
                                      context,
                                      currentIso,
                                      column,
                                    );
                                    if (picked != null && mounted) {
                                      _isoValues[column.name] = picked;
                                      _controllers[column.name]!.text =
                                          _formatDateValue(picked, column);
                                      setState(() {});
                                    }
                                  }
                                : null,
                            textInputAction: TextInputAction.newline,
                            decoration: InputDecoration(
                              labelText: column.name,
                              hintText: isDate
                                  ? 'Tap to select date'
                                  : 'Enter ${column.name}',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor:
                                  theme.colorScheme.surfaceContainerHighest,
                              prefixIcon: column.hasDefault
                                  ? Icon(
                                      Icons.settings,
                                      size: 18,
                                      color: theme.colorScheme.secondary,
                                    )
                                  : null,
                              suffixIcon: isDate
                                  ? IconButton(
                                      icon: const Icon(
                                          Icons.calendar_today_outlined),
                                      onPressed: () async {
                                        final currentIso =
                                            _isoValues[column.name];
                                        final picked = await _pickDateTime(
                                          context,
                                          currentIso,
                                          column,
                                        );
                                        if (picked != null && mounted) {
                                          _isoValues[column.name] = picked;
                                          _controllers[column.name]!.text =
                                              _formatDateValue(picked, column);
                                          setState(() {});
                                        }
                                      },
                                    )
                                  : column.hasDefault
                                      ? Container(
                                          margin:
                                              const EdgeInsets.only(right: 12),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.secondary
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'DEFAULT',
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                              color:
                                                  theme.colorScheme.secondary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                      : null,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                if (!column.hasDefault) {
                                  return 'This field is required';
                                }
                              }
                              if (isDate && value != null && value.isNotEmpty) {
                                // Check if we have a valid ISO value stored
                                final isoValue = _isoValues[column.name];
                                if (isoValue == null || isoValue.isEmpty) {
                                  return 'Please select a date';
                                }
                                if (DateTime.tryParse(isoValue) == null) {
                                  return 'Invalid date';
                                }
                              }
                              return null;
                            },
                          ),
                        );
                      }),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: theme.colorScheme.error,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            // Actions
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add_circle),
                    label: Text(_isSubmitting ? 'Creating...' : 'Create'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
