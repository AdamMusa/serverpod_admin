import 'package:flutter/material.dart';
import 'package:serverpod_admin_dashboard/src/controller/admin_dashboard.dart';
import 'package:serverpod_admin_dashboard/src/controller/dialog_form_controller.dart';
import 'package:serverpod_admin_dashboard/src/helpers/admin_resources.dart';
import 'package:serverpod_admin_dashboard/src/widgets/dialog_form_field.dart';

/// Default edit dialog with modern design
class DefaultEditDialog extends StatefulWidget {
  const DefaultEditDialog({
    required this.resource,
    required this.currentValues,
    required this.onSubmit,
    required this.controller,
    super.key,
  });

  final AdminResource resource;
  final Map<String, String> currentValues;
  final Future<bool> Function(Map<String, String> payload) onSubmit;
  final AdminDashboardController controller;

  @override
  State<DefaultEditDialog> createState() => _DefaultEditDialogState();
}

class _DefaultEditDialogState extends State<DefaultEditDialog> {
  late final DialogFormController _formController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _formController = DialogFormController(
      resource: widget.resource,
      adminController: widget.controller,
      initialValues: widget.currentValues,
    );
  }

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  Map<String, String> _buildPayload() {
    final payload = _formController.buildPayload();

    // Include primary key for updates
    final primaryColumn = widget.resource.columns.firstWhere(
      (col) => col.isPrimary,
      orElse: () => widget.resource.columns.first,
    );
    final primaryKeyValue = widget.currentValues[primaryColumn.name];
    if (primaryKeyValue != null && primaryKeyValue.isNotEmpty) {
      payload[primaryColumn.name] = primaryKeyValue;
    }

    return payload;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    _formController.setSubmitting(true);
    _formController.setError(null);

    final payload = _buildPayload();
    final success = await widget.onSubmit(payload);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      _formController.setSubmitting(false);
      _formController.setError('Failed to update record. Please try again.');
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
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
              child: AnimatedBuilder(
                animation: _formController,
                builder: (context, _) {
                  return Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Edit ${widget.resource.tableName}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _formController.isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(false),
                        icon: const Icon(Icons.close, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  );
                },
              ),
            ),
            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: AnimatedBuilder(
                    animation: _formController,
                    builder: (context, _) {
                      return Column(
                        children: [
                          ...widget.resource.columns
                              .where((col) => !col.isPrimary)
                              .map(
                                (column) => DialogFormField(
                                  column: column,
                                  formController: _formController,
                                  adminController: widget.controller,
                                ),
                              ),
                          if (_formController.errorMessage != null) ...[
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
                                      _formController.errorMessage!,
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.error,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      );
                    },
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
                    color: theme.dividerColor.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
              child: AnimatedBuilder(
                animation: _formController,
                builder: (context, _) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _formController.isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed:
                            _formController.isSubmitting ? null : _handleSubmit,
                        icon: _formController.isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.check_circle_outline),
                        label: Text(_formController.isSubmitting
                            ? 'Updating...'
                            : 'Update'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
