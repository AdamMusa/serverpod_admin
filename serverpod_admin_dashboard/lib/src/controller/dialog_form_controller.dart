import 'package:flutter/material.dart';
import 'package:serverpod_admin_dashboard/src/controller/admin_dashboard.dart';
import 'package:serverpod_admin_dashboard/src/helpers/admin_resources.dart';
import 'package:serverpod_admin_dashboard/src/helpers/dialog_form_helper.dart'
    show DialogFormHelper;
import 'package:serverpod_admin_dashboard/src/helpers/foreign_key_helper.dart';

/// Controller for managing form state in create/edit dialogs.
/// Uses ChangeNotifier to avoid setState calls.
class DialogFormController extends ChangeNotifier {
  DialogFormController({
    required this.resource,
    required this.adminController,
    Map<String, String>? initialValues,
  }) {
    _initializeFields(initialValues);
  }

  final AdminResource resource;
  final AdminDashboardController adminController;

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _isoValues = {};
  final Map<String, String?> _foreignKeyValues = {};
  final Map<String, List<Map<String, String>>> _foreignKeyOptions = {};
  final Map<String, bool> _booleanValues = {};

  bool _isSubmitting = false;
  String? _errorMessage;

  // Getters
  Map<String, TextEditingController> get controllers => _controllers;
  Map<String, String> get isoValues => _isoValues;
  Map<String, String?> get foreignKeyValues => _foreignKeyValues;
  Map<String, List<Map<String, String>>> get foreignKeyOptions =>
      _foreignKeyOptions;
  Map<String, bool> get booleanValues => _booleanValues;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  void _initializeFields(Map<String, String>? initialValues) {
    final isEditMode = initialValues != null;

    for (final column in resource.columns) {
      if (column.isPrimary) continue;

      final initialValue = isEditMode ? (initialValues[column.name] ?? '') : '';

      if (DialogFormHelper.isBooleanType(column)) {
        _booleanValues[column.name] =
            isEditMode ? DialogFormHelper.parseBoolean(initialValue) : false;
      } else if (column.foreignKeyTable != null) {
        _foreignKeyValues[column.name] =
            initialValue.isEmpty ? null : initialValue;
        _loadForeignKeyOptions(column);
      } else if (DialogFormHelper.isDateType(column)) {
        if (isEditMode && initialValue.isNotEmpty) {
          _isoValues[column.name] = initialValue;
          _controllers[column.name] = TextEditingController(
            text: DialogFormHelper.formatDateValue(initialValue, column),
          );
        } else {
          _isoValues[column.name] = '';
          _controllers[column.name] = TextEditingController();
        }
      } else {
        _isoValues[column.name] = initialValue;
        _controllers[column.name] = TextEditingController(text: initialValue);
      }
    }
  }

  Future<void> _loadForeignKeyOptions(AdminColumn column) async {
    if (column.foreignKeyTable == null) return;

    final relatedResource =
        ForeignKeyHelper.findRelatedResource(adminController, column);

    if (relatedResource == null) return;

    try {
      final records = await adminController.adminEndpoint.list(
        relatedResource.key,
      );
      _foreignKeyOptions[column.name] = records;
      notifyListeners();
    } catch (_) {
      _foreignKeyOptions[column.name] = [];
      notifyListeners();
    }
  }

  void setBooleanValue(String columnName, bool value) {
    _booleanValues[columnName] = value;
    notifyListeners();
  }

  void setForeignKeyValue(String columnName, String? value) {
    _foreignKeyValues[columnName] = value;
    notifyListeners();
  }

  void setDateValue(String columnName, String isoValue, String displayValue) {
    _isoValues[columnName] = isoValue;
    _controllers[columnName]?.text = displayValue;
    notifyListeners();
  }

  void setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Map<String, String> buildPayload() {
    final payload = <String, String>{};

    for (final column in resource.columns) {
      if (column.isPrimary) continue;

      if (DialogFormHelper.isBooleanType(column)) {
        payload[column.name] =
            _booleanValues[column.name] == true ? 'true' : 'false';
      } else if (column.foreignKeyTable != null) {
        final selectedValue = _foreignKeyValues[column.name];
        if (selectedValue != null && selectedValue.isNotEmpty) {
          payload[column.name] = selectedValue;
        }
      } else if (_controllers.containsKey(column.name)) {
        final controller = _controllers[column.name]!;
        if (DialogFormHelper.isDateType(column)) {
          payload[column.name] = _isoValues[column.name] ?? '';
        } else {
          payload[column.name] = controller.text.trim();
        }
      }
    }

    return payload;
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
