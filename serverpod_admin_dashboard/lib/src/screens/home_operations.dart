import 'package:flutter/material.dart';
import 'package:serverpod_admin_dashboard/src/admin_dashboard.dart';
import 'package:serverpod_admin_dashboard/src/controller/admin_dashboard.dart';
import 'package:serverpod_admin_dashboard/src/helpers/admin_resources.dart';
import 'package:serverpod_admin_dashboard/src/helpers/tabular_data.dart';
import 'package:serverpod_admin_dashboard/src/widgets/default_create_dialog.dart';
import 'package:serverpod_admin_dashboard/src/widgets/default_delete_dialog.dart';
import 'package:serverpod_admin_dashboard/src/widgets/default_edit_dialog.dart';

/// Business logic operations for the Home screen.
/// Separated from UI to avoid setState usage.
class HomeOperations {
  HomeOperations({
    required this.controller,
    required this.context,
    this.customEditDialogBuilder,
    this.customDeleteDialogBuilder,
    this.customCreateDialogBuilder,
  });

  final AdminDashboardController controller;
  final BuildContext context;
  final EditDialogBuilder? customEditDialogBuilder;
  final DeleteDialogBuilder? customDeleteDialogBuilder;
  final CreateDialogBuilder? customCreateDialogBuilder;

  /// Shows the create record dialog.
  Future<void> showCreateDialog(AdminResource resource) async {
    if (customCreateDialogBuilder != null) {
      final created = await showDialog<bool>(
        context: context,
        builder: (context) => customCreateDialogBuilder!(
          context,
          controller,
          this,
          resource,
          (payload) => _createRecord(resource, payload),
        ),
      );

      if (created == true) {
        // Records are reloaded in _createRecord
      }
    } else {
      // Default implementation with modern design
      final created = await showDialog<bool>(
        context: context,
        builder: (context) => DefaultCreateDialog(
          resource: resource,
          controller: controller,
          onSubmit: (payload) => _createRecord(resource, payload),
        ),
      );

      if (created == true) {
        // Records are reloaded in _createRecord
      }
    }
  }

  /// Shows the edit record dialog.
  Future<void> showEditDialog(
    AdminResource resource,
    Map<String, String> record,
  ) async {
    if (customEditDialogBuilder != null) {
      final updated = await showDialog<bool>(
        context: context,
        builder: (context) => customEditDialogBuilder!(
          context,
          controller,
          this,
          resource,
          record,
          (payload) => _updateRecord(resource, payload),
        ),
      );

      if (updated == true) {
        // Records are reloaded in _updateRecord
      }
    } else {
      // Default implementation with modern design
      final updated = await showDialog<bool>(
        context: context,
        builder: (context) => DefaultEditDialog(
          resource: resource,
          controller: controller,
          currentValues: record,
          onSubmit: (payload) => _updateRecord(resource, payload),
        ),
      );

      if (updated == true) {
        // Records are reloaded in _updateRecord
      }
    }
  }

  /// Shows the record details page.
  void showDetailsPage(
    AdminResource resource,
    Map<String, String> record,
  ) {
    controller.openDetails(resource, record);
  }

  /// Shows the delete confirmation dialog.
  Future<void> showDeleteConfirmation(
    AdminResource resource,
    Map<String, String> record,
  ) async {
    if (customDeleteDialogBuilder != null) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => customDeleteDialogBuilder!(
          context,
          controller,
          this,
          resource,
          record,
          () => _deleteRecord(resource, record),
        ),
      );

      if (confirmed == true) {
        // Deletion handled in the custom dialog's onConfirm callback
      }
    } else {
      // Default implementation with modern design
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => DefaultDeleteDialog(
          resource: resource,
          record: record,
          onConfirm: () => _deleteRecord(resource, record),
        ),
      );

      if (confirmed == true) {
        // Deletion handled in the dialog's onConfirm callback
      }
    }
  }

  Future<void> importRecords(AdminResource resource) async {
    try {
      final file = await TabularDataHelper.pickImportFile();
      if (file == null) return;

      final result = await controller.importRecords(resource, file.rows);
      if (!context.mounted) return;

      _showSnackBar(
        'Imported ${result.imported} ${resource.tableName} rows '
        '(${result.created} created, ${result.updated} updated, '
        '${result.skipped} skipped).',
        isError: false,
      );
    } catch (error) {
      debugPrint('Failed to import ${resource.key}: $error');
      if (!context.mounted) return;
      _showSnackBar(
        'Failed to import ${resource.tableName}: $error',
        isError: true,
      );
    }
  }

  Future<void> exportRecords(
    AdminResource resource,
    List<Map<String, String>> records,
    TabularFileFormat format,
  ) async {
    try {
      final saved = await TabularDataHelper.saveExportFile(
        resource: resource,
        records: records,
        format: format,
      );
      if (!saved || !context.mounted) return;

      _showSnackBar(
        '${resource.tableName} exported as ${format.extension.toUpperCase()}.',
        isError: false,
      );
    } catch (error) {
      debugPrint('Failed to export ${resource.key}: $error');
      if (!context.mounted) return;
      _showSnackBar(
        'Failed to export ${resource.tableName}: $error',
        isError: true,
      );
    }
  }

  Future<void> runJobNow(
    AdminResource resource,
    Map<String, String> record,
  ) async {
    await _updateJobTime(
      resource,
      record,
      DateTime.now().toUtc(),
      successMessage: '${record['name'] ?? 'Job'} queued to run now.',
      errorMessage: 'Failed to queue job.',
    );
  }

  Future<void> pauseJob(
    AdminResource resource,
    Map<String, String> record,
  ) async {
    await _updateJobTime(
      resource,
      record,
      DateTime.utc(9999, 12, 31, 23, 59, 59),
      successMessage: '${record['name'] ?? 'Job'} paused.',
      errorMessage: 'Failed to pause job.',
    );
  }

  Future<void> resumeJob(
    AdminResource resource,
    Map<String, String> record,
  ) async {
    await _updateJobTime(
      resource,
      record,
      DateTime.now().toUtc(),
      successMessage: '${record['name'] ?? 'Job'} resumed.',
      errorMessage: 'Failed to resume job.',
    );
  }

  Future<bool> _createRecord(
    AdminResource resource,
    Map<String, String> payload,
  ) async {
    try {
      await controller.createRecord(resource, payload);
      if (!context.mounted) return true;
      _showSnackBar(
        '${resource.tableName} created successfully.',
        isError: false,
      );
      return true;
    } catch (error) {
      debugPrint('Failed to create ${resource.key}: $error');
      if (!context.mounted) return false;
      _showSnackBar(
        'Failed to create ${resource.tableName}: $error',
        isError: true,
      );
      return false;
    }
  }

  Future<bool> _updateRecord(
    AdminResource resource,
    Map<String, String> payload,
  ) async {
    try {
      await controller.updateRecord(resource, payload);
      if (!context.mounted) return true;
      _showSnackBar(
        '${resource.tableName} updated successfully.',
        isError: false,
      );
      return true;
    } catch (error) {
      debugPrint('Failed to update ${resource.key}: $error');
      if (!context.mounted) return false;
      _showSnackBar(
        'Failed to update ${resource.tableName}: $error',
        isError: true,
      );
      return false;
    }
  }

  Future<void> _updateJobTime(
    AdminResource resource,
    Map<String, String> record,
    DateTime time, {
    required String successMessage,
    required String errorMessage,
  }) async {
    final primaryValue = controller.resolvePrimaryKeyValue(resource, record);
    if (primaryValue == null) {
      debugPrint('Unable to resolve primary key for ${resource.key}.');
      return;
    }

    final payload = Map<String, String>.from(record)
      ..['id'] = primaryValue
      ..['time'] = time.toIso8601String();

    try {
      await controller.updateRecord(resource, payload);
      if (!context.mounted) return;
      _showSnackBar(successMessage, isError: false);
    } catch (error) {
      debugPrint('$errorMessage ${resource.key}: $error');
      if (!context.mounted) return;
      _showSnackBar('$errorMessage $error', isError: true);
    }
  }

  Future<void> _deleteRecord(
    AdminResource resource,
    Map<String, String> record,
  ) async {
    final primaryValue = controller.resolvePrimaryKeyValue(resource, record);
    if (primaryValue == null) {
      debugPrint(
        'Unable to resolve primary key for ${resource.key}, aborting delete.',
      );
      return;
    }

    // Close details if the deleted record is currently being viewed
    if (controller.isShowingDetails &&
        controller.detailsResource?.key == resource.key &&
        controller.detailsRecord != null) {
      final detailsPrimaryKey = controller.resolvePrimaryKeyValue(
          resource, controller.detailsRecord!);
      if (detailsPrimaryKey == primaryValue) {
        controller.closeDetails();
      }
    }

    try {
      await controller.deleteRecord(resource, primaryValue);
      if (!context.mounted) return;
      _showSnackBar(
        '${resource.tableName} deleted successfully.',
        isError: false,
      );
    } catch (error) {
      debugPrint('Failed to delete ${resource.key}: $error');
      if (!context.mounted) return;
      _showSnackBar(
        'Failed to delete ${resource.tableName}: $error',
        isError: true,
      );
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }
}
