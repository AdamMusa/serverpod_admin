import 'dart:async';

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

  // Query state: the current page of the selected resource, read from the
  // server with its sort, search and filters.
  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  Timer? _searchDebounce;

  /// Rows on the current page; the server has already searched, filtered,
  /// sorted and paged them.
  List<Map<String, String>> get filteredRecords => records;

  /// How many rows match the search and filters.
  int totalRecords = 0;

  int _pageIndex = 0;
  int get pageIndex => _pageIndex;
  int _rowsPerPage = 25;
  int get rowsPerPage => _rowsPerPage;
  static const rowsPerPageOptions = [10, 25, 50, 100];
  int get pageCount =>
      totalRecords == 0 ? 1 : (totalRecords / _rowsPerPage).ceil();

  String? _sortColumn;
  String? get sortColumn => _sortColumn;
  bool _sortDescending = false;
  bool get sortDescending => _sortDescending;

  List<admin_client.AdminFilter> _filters = const [];
  List<admin_client.AdminFilter> get filters => _filters;

  final Map<String, Set<String>> _hiddenColumns = {};

  /// Columns of [resource] hidden from the table (all stay in details).
  Set<String> hiddenColumns(AdminResource resource) =>
      _hiddenColumns[resource.key] ?? const {};

  void toggleColumn(AdminResource resource, String column) {
    final hidden = _hiddenColumns.putIfAbsent(resource.key, () => {});
    if (!hidden.remove(column)) hidden.add(column);
    notifyListeners();
  }

  void setSearchQuery(String query) {
    if (query == _searchQuery) return;
    _searchQuery = query;
    notifyListeners();
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      _pageIndex = 0;
      _reloadSelected();
    });
  }

  void clearSearch() {
    _searchDebounce?.cancel();
    if (_searchQuery.isEmpty) return;
    _searchQuery = '';
    _pageIndex = 0;
    notifyListeners();
    _reloadSelected();
  }

  /// Sorts by [column]: ascending first, then descending on a second click.
  void sortBy(String column) {
    if (_sortColumn == column) {
      _sortDescending = !_sortDescending;
    } else {
      _sortColumn = column;
      _sortDescending = false;
    }
    _pageIndex = 0;
    _reloadSelected();
  }

  void setFilters(List<admin_client.AdminFilter> filters) {
    _filters = List.unmodifiable(filters);
    _pageIndex = 0;
    _reloadSelected();
  }

  void removeFilter(admin_client.AdminFilter filter) =>
      setFilters([..._filters]..remove(filter));

  void goToPage(int page) {
    final target = page.clamp(0, pageCount - 1);
    if (target == _pageIndex) return;
    _pageIndex = target;
    _reloadSelected();
  }

  void setRowsPerPage(int value) {
    if (value == _rowsPerPage || !rowsPerPageOptions.contains(value)) return;
    _rowsPerPage = value;
    _pageIndex = 0;
    _reloadSelected();
  }

  void _resetQuery() {
    _searchDebounce?.cancel();
    _searchQuery = '';
    _pageIndex = 0;
    _sortColumn = null;
    _sortDescending = false;
    _filters = const [];
    totalRecords = 0;
  }

  void _reloadSelected() {
    final resource = selectedResource;
    if (resource != null) unawaited(loadRecords(resource));
  }

  admin_client.AdminQuery _query({int? offset, int? limit}) =>
      admin_client.AdminQuery(
        offset: offset ?? _pageIndex * _rowsPerPage,
        limit: limit ?? _rowsPerPage,
        search: _searchQuery.trim().isEmpty ? null : _searchQuery.trim(),
        sortColumn: _sortColumn,
        sortDescending: _sortDescending,
        filters: _filters,
      );

  /// Every row matching the current search and filters, in the current
  /// order, for export.
  Future<List<Map<String, String>>> fetchAllMatching(
    AdminResource resource, {
    int maxRows = 50000,
  }) async {
    if (resource.key == serverpodJobsKey) return records;
    final rows = <Map<String, String>>[];
    while (rows.length < maxRows) {
      final page = await adminEndpoint.query(
        resource.key,
        _query(offset: rows.length, limit: 500),
      );
      rows.addAll(page.rows);
      if (page.rows.isEmpty || rows.length >= page.total) break;
    }
    return rows;
  }

  static const serverpodJobsKey = 'serverpod_future_call';

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
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
    _resetQuery(); // A new table starts unfiltered on its first page
    records = const [];
    notifyListeners();
    await loadRecords(resource);
  }

  Future<void> loadRecords(
    AdminResource resource, {
    bool showLoading = true,
  }) async {
    final isJobs = resource.key == serverpodJobsKey;
    // Jobs refresh in the background every few seconds; skip overlapping
    // refreshes. Other tables load the latest query and ignore stale replies.
    if (isJobs && _isRecordsRefreshInFlight) return;
    _isRecordsRefreshInFlight = true;
    final request = ++_recordsRequest;

    if (showLoading) {
      isRecordsLoading = true;
      recordsError = null;
      notifyListeners();
    }

    try {
      if (isJobs) {
        records = await adminEndpoint.list(resource.key);
        totalRecords = records.length;
        jobHistory = await adminEndpoint.futureCallHistory();
      } else {
        final page = await adminEndpoint.query(resource.key, _query());
        if (request != _recordsRequest) return;
        records = page.rows;
        totalRecords = page.total;
        jobHistory = const [];
        // A filter or deletion can leave the page past the last one.
        if (records.isEmpty && totalRecords > 0 && _pageIndex > 0) {
          _pageIndex = pageCount - 1;
          _isRecordsRefreshInFlight = false;
          return loadRecords(resource, showLoading: showLoading);
        }
      }

      recordsError = null;
      // Update details record if it's the same resource and record still exists
      if (isShowingDetails &&
          detailsResource?.key == resource.key &&
          detailsRecord != null) {
        final updatedRecord = _findUpdatedDetailsRecord(resource) ??
            (isJobs ? null : await _fetchDetailsRecord(resource));
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
      if (request != _recordsRequest) return;
      if (showLoading || records.isEmpty) {
        recordsError = error is admin_client.AdminValidationException
            ? error.message
            : 'Unable to load ${resource.tableName} records. Please try again.';
        records = const [];
        if (resource.key == 'serverpod_future_call') {
          jobHistory = const [];
        }
      }
    } finally {
      if (request == _recordsRequest) {
        _isRecordsRefreshInFlight = false;
        if (showLoading) {
          isRecordsLoading = false;
        }
        notifyListeners();
      }
    }
  }

  int _recordsRequest = 0;

  /// The open details row read by its primary key, when it is not on the
  /// current page (for example after an edit moved it).
  Future<Map<String, String>?> _fetchDetailsRecord(
    AdminResource resource,
  ) async {
    final record = detailsRecord;
    final primary = resource.columns.where((c) => c.isPrimary).firstOrNull;
    final id = record == null ? null : resolvePrimaryKeyValue(resource, record);
    if (primary == null || id == null) return null;
    final page = await adminEndpoint.query(
      resource.key,
      admin_client.AdminQuery(
        offset: 0,
        limit: 1,
        sortDescending: false,
        filters: [
          admin_client.AdminFilter(
            column: primary.name,
            comparison: admin_client.AdminFilterOperator.equals,
            value: id,
          ),
        ],
      ),
    );
    return page.rows.firstOrNull;
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

  /// Why the last create or update failed, worded for administrators (for
  /// example which field has an invalid value); null after a success.
  String? lastWriteError;

  Future<T> _write<T>(Future<T> Function() request) async {
    lastWriteError = null;
    try {
      return await request();
    } on admin_client.AdminValidationException catch (error) {
      lastWriteError = error.message;
      rethrow;
    } catch (error) {
      lastWriteError = '$error';
      rethrow;
    }
  }

  Future<void> createRecord(
    AdminResource resource,
    Map<String, String> payload,
  ) async {
    await _write(() => adminEndpoint.create(resource.key, payload));
    await loadRecords(resource);
  }

  Future<void> updateRecord(
    AdminResource resource,
    Map<String, String> payload,
  ) async {
    await _write(() => adminEndpoint.update(resource.key, payload));
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
