import 'package:flutter/material.dart';
import 'package:serverpod_admin_client/serverpod_admin_client.dart'
    as admin_client;
import 'package:serverpod_admin_dashboard/src/helpers/admin_resources.dart';
import 'package:serverpod_admin_dashboard/src/helpers/tabular_data.dart';

/// Controller holding all shared admin dashboard state and behavior.
class AdminDashboardController extends ChangeNotifier {
  AdminDashboardController({
    required this.adminEndpoint,
    required ThemeMode initialThemeMode,
  }) : _themeMode = initialThemeMode;

  final admin_client.EndpointAdmin adminEndpoint;

  // Theme & layout
  ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;

  bool _isSidebarCollapsed = false;
  bool get isSidebarCollapsed => _isSidebarCollapsed;

  // Resources state
  List<AdminResource> resources = const [];
  AdminResource? selectedResource;
  String? resourcesError;
  bool isResourcesLoading = false;

  // Records state
  List<Map<String, String>> records = const [];
  List<Map<String, String>> jobHistory = const [];
  String? recordsError;
  bool isRecordsLoading = false;
  bool _isRecordsRefreshInFlight = false;

  // Search state
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  List<Map<String, String>> get filteredRecords {
    if (_searchQuery.isEmpty) return records;

    final query = _searchQuery.toLowerCase();
    return records.where((record) {
      return record.values.any((value) {
        return value.toLowerCase().contains(query);
      });
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // Details state
  AdminResource? detailsResource;
  Map<String, String>? detailsRecord;

  bool get isShowingDetails => detailsResource != null && detailsRecord != null;

  void openDetails(AdminResource resource, Map<String, String> record) {
    detailsResource = resource;
    detailsRecord = record;
    notifyListeners();
  }

  void closeDetails() {
    detailsResource = null;
    detailsRecord = null;
    notifyListeners();
  }

  void toggleThemeMode() {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void toggleSidebarCollapsed() {
    _isSidebarCollapsed = !_isSidebarCollapsed;
    notifyListeners();
  }

  Future<void> loadResources() async {
    // Prevent concurrent loads
    if (isResourcesLoading) return;

    isResourcesLoading = true;
    resourcesError = null;
    notifyListeners();

    try {
      final loaded = await adminEndpoint.resources();
      resources = loaded;

      // Preserve selection if possible.
      if (selectedResource != null) {
        try {
          selectedResource = loaded.firstWhere(
            (r) => r.key == selectedResource!.key,
          );
        } catch (_) {
          selectedResource = loaded.isNotEmpty ? loaded.first : null;
        }
      } else {
        selectedResource = loaded.isNotEmpty ? loaded.first : null;
      }
      resourcesError = null;
    } catch (error) {
      resourcesError = 'Unable to load resources. Please try again.';
      print("Error loading resources: $error");
      resources = const [];
      selectedResource = null;
      records = const [];
    } finally {
      isResourcesLoading = false;
      notifyListeners();
    }

    final current = selectedResource;
    if (current != null) {
      await loadRecords(current);
    } else {
      records = const [];
      notifyListeners();
    }
  }

  Future<void> selectResource(AdminResource resource) async {
    selectedResource = resource;
    closeDetails(); // Close details when changing resource
    clearSearch(); // Clear search when changing resource
    notifyListeners();
    await loadRecords(resource);
  }

  Future<void> loadRecords(
    AdminResource resource, {
    bool showLoading = true,
  }) async {
    if (_isRecordsRefreshInFlight) return;
    _isRecordsRefreshInFlight = true;

    if (showLoading) {
      isRecordsLoading = true;
      recordsError = null;
      notifyListeners();
    }

    try {
      final loaded = await adminEndpoint.list(resource.key);
      records = loaded;
      if (resource.key == 'serverpod_future_call') {
        jobHistory = await adminEndpoint.futureCallHistory();
      } else {
        jobHistory = const [];
      }

      recordsError = null;
      // Update details record if it's the same resource and record still exists
      if (isShowingDetails &&
          detailsResource?.key == resource.key &&
          detailsRecord != null) {
        final updatedRecord = _findUpdatedDetailsRecord(resource);
        if (updatedRecord != null) {
          detailsRecord = updatedRecord;
        } else if (resource.key != 'serverpod_future_call') {
          // Record was deleted, close details. Job rows can move from the
          // future-call table into history between refreshes, so keep their
          // details open even when the active row disappears.
          closeDetails();
        }
      }
    } catch (error) {
      if (showLoading || records.isEmpty) {
        recordsError =
            'Unable to load ${resource.tableName} records. Please try again.';
        records = const [];
        if (resource.key == 'serverpod_future_call') {
          jobHistory = const [];
        }
      }
    } finally {
      _isRecordsRefreshInFlight = false;
      if (showLoading) {
        isRecordsLoading = false;
      }
      notifyListeners();
    }
  }

  Map<String, String>? _findUpdatedDetailsRecord(AdminResource resource) {
    final currentDetailsRecord = detailsRecord;
    if (currentDetailsRecord == null) return null;

    final candidates = resource.key == 'serverpod_future_call'
        ? [...records, ...jobHistory]
        : records;

    final primaryKey = resolvePrimaryKeyValue(resource, currentDetailsRecord);
    if (primaryKey != null) {
      for (final record in candidates) {
        if (resolvePrimaryKeyValue(resource, record) == primaryKey) {
          return record;
        }
      }
    }

    if (resource.key == 'serverpod_future_call') {
      final name = currentDetailsRecord['name'];
      final serverId = currentDetailsRecord['serverId'];
      if (name != null && name.isNotEmpty && serverId != null) {
        for (final record in candidates) {
          if (record['name'] == name && record['serverId'] == serverId) {
            return record;
          }
        }
      }
    }

    return null;
  }

  Future<void> createRecord(
    AdminResource resource,
    Map<String, String> payload,
  ) async {
    await adminEndpoint.create(resource.key, payload);
    await loadRecords(resource);
  }

  Future<void> updateRecord(
    AdminResource resource,
    Map<String, String> payload,
  ) async {
    await adminEndpoint.update(resource.key, payload);
    await loadRecords(resource);

    // Update details record if it's the same record being edited
    if (isShowingDetails &&
        detailsResource?.key == resource.key &&
        detailsRecord != null) {
      final primaryKey = resolvePrimaryKeyValue(resource, detailsRecord!);
      final updatedPrimaryKey = resolvePrimaryKeyValue(resource, payload);
      if (primaryKey != null &&
          updatedPrimaryKey != null &&
          primaryKey == updatedPrimaryKey) {
        // Update the displayed record with the new values
        detailsRecord = payload;
        notifyListeners();
      }
    }
  }

  Future<void> deleteRecord(
    AdminResource resource,
    String id,
  ) async {
    await adminEndpoint.delete(resource.key, id);
    await loadRecords(resource);
  }

  Future<TabularImportResult> importRecords(
    AdminResource resource,
    List<Map<String, String>> rows,
  ) async {
    var created = 0;
    var updated = 0;
    var skipped = 0;

    for (final row in rows) {
      final payload = _cleanImportRow(resource, row);
      if (payload.isEmpty) {
        skipped++;
        continue;
      }

      final primaryValue = resolvePrimaryKeyValue(resource, payload);
      if (primaryValue == null) {
        await adminEndpoint.create(resource.key, payload);
        created++;
      } else {
        await adminEndpoint.update(resource.key, payload);
        updated++;
      }
    }

    await loadRecords(resource);
    return TabularImportResult(
      created: created,
      updated: updated,
      skipped: skipped,
    );
  }

  /// Resolves the primary key value from a record.
  String? resolvePrimaryKeyValue(
    AdminResource resource,
    Map<String, String> record,
  ) {
    final primaryColumn =
        resource.columns.firstWhere((column) => column.isPrimary, orElse: () {
      return AdminColumn(
        name: 'id',
        dataType: 'String',
        hasDefault: true,
        isPrimary: true,
      );
    });
    final raw = record[primaryColumn.name];
    if (raw == null || raw.isEmpty) return null;
    return raw;
  }

  Map<String, String> _cleanImportRow(
    AdminResource resource,
    Map<String, String> row,
  ) {
    final columnNames = resource.columns.map((column) => column.name).toSet();
    final payload = <String, String>{};

    for (final entry in row.entries) {
      final key = entry.key.trim();
      final value = entry.value.trim();
      if (!columnNames.contains(key) || value.isEmpty) continue;
      payload[key] = value;
    }

    return payload;
  }
}
