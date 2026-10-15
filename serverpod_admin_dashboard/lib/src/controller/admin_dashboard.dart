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
      _hiddenColumns[resource.key] ?? _defaultHidden(resource);

  /// Columns left out at first: those not in the resource's listColumns.
  static Set<String> _defaultHidden(AdminResource resource) {
    final shown = resource.listColumns;
    if (shown == null) return {};
    return {
      for (final column in resource.columns)
        if (!shown.contains(column.name)) column.name,
    };
  }

  void toggleColumn(AdminResource resource, String column) {
    final hidden = _hiddenColumns.putIfAbsent(
      resource.key,
      () => {..._defaultHidden(resource)},
    );
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
    final resource = selectedResource;
    if (_sortColumn == column) {
      _sortDescending = !_sortDescending;
    } else if (_sortColumn == null && column == resource?.sortColumn) {
      // The first click flips the resource's default order.
      _sortColumn = column;
      _sortDescending = !(resource?.sortDescending ?? false);
    } else {
      _sortColumn = column;
      _sortDescending = false;
    }
    _pageIndex = 0;
    _reloadSelected();
  }

  void setFilters(List<admin_client.AdminFilter> filters) {
    _selected.clear();
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
    _selected.clear();
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

  // Saved views: the signed-in user's named searches, sorts, filters and
  // columns of the selected resource.
  List<admin_client.AdminSavedView> savedViews = const [];
  String? _savedViewsKey;

  /// Reads [resource]'s saved views when it is about to be shown.
  void _showSavedViewsOf(AdminResource resource) {
    if (resource.key == _savedViewsKey) return;
    _savedViewsKey = resource.key;
    savedViews = const [];
    if (resource.key != serverpodJobsKey) {
      unawaited(loadSavedViews(resource));
    }
  }

  Future<void> loadSavedViews(AdminResource resource) async {
    List<admin_client.AdminSavedView> views;
    try {
      views = await adminEndpoint.savedViews(resource.key);
    } catch (_) {
      views = const [];
    }
    if (_savedViewsKey != resource.key) return;
    savedViews = views;
    notifyListeners();
  }

  /// The saved view showing what is shown now: the same search, sort,
  /// filters and columns.
  admin_client.AdminSavedView? get currentView {
    final resource = selectedResource;
    if (resource == null) return null;
    final shown = _shownColumns(resource, hiddenColumns(resource));
    for (final view in savedViews) {
      final viewShown =
          view.shownColumns?.toSet() ??
          _shownColumns(resource, _defaultHidden(resource));
      if ((view.search ?? '') == _searchQuery.trim() &&
          view.sortColumn == _sortColumn &&
          (view.sortColumn == null || view.sortDescending == _sortDescending) &&
          _sameFilters(view.filters, _filters) &&
          viewShown.length == shown.length &&
          viewShown.containsAll(shown)) {
        return view;
      }
    }
    return null;
  }

  static Set<String> _shownColumns(
    AdminResource resource,
    Set<String> hidden,
  ) => {
    for (final column in resource.columns)
      if (!hidden.contains(column.name)) column.name,
  };

  static bool _sameFilters(
    List<admin_client.AdminFilter> a,
    List<admin_client.AdminFilter> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].column != b[i].column ||
          a[i].comparison != b[i].comparison ||
          (a[i].value ?? '') != (b[i].value ?? '')) {
        return false;
      }
    }
    return true;
  }

  /// Shows [view]'s search, sort, filters and columns, from the first page.
  void applyView(admin_client.AdminSavedView view) {
    final resource = selectedResource;
    if (resource == null || view.resourceKey != resource.key) return;
    _searchDebounce?.cancel();
    _selected.clear();
    _searchQuery = view.search ?? '';
    _sortColumn = view.sortColumn;
    _sortDescending = view.sortColumn != null && view.sortDescending;
    _filters = List.unmodifiable(view.filters);
    final shown = view.shownColumns;
    if (shown == null) {
      _hiddenColumns.remove(resource.key);
    } else {
      _hiddenColumns[resource.key] = {
        for (final column in resource.columns)
          if (!shown.contains(column.name)) column.name,
      };
    }
    _pageIndex = 0;
    _reloadSelected();
  }

  /// Saves what is shown (search, sort, filters and, once changed, the
  /// columns) as the view [name], replacing the user's view of that name.
  Future<admin_client.AdminSavedView> saveView(String name) async {
    final resource = selectedResource!;
    final hidden = _hiddenColumns[resource.key];
    final view = await adminEndpoint.saveView(
      resource.key,
      name,
      _query(),
      hidden == null ? null : _shownColumns(resource, hidden).toList(),
    );
    await loadSavedViews(resource);
    return view;
  }

  Future<void> deleteView(admin_client.AdminSavedView view) async {
    await adminEndpoint.deleteView(view.id!);
    final resource = selectedResource;
    if (resource != null) await loadSavedViews(resource);
  }

  // Overview: the landing page with record counts and recent changes.
  bool _showingOverview = true;
  bool get isShowingOverview => _showingOverview || selectedResource == null;

  void showOverview() {
    _showingOverview = true;
    closeDetails();
    notifyListeners();
  }

  /// How many rows each resource has, for the overview.
  Future<Map<String, int>> resourceCounts() async {
    final counts = <String, int>{};
    await Future.wait([
      for (final resource in resources)
        adminEndpoint
            .query(
              resource.key,
              admin_client.AdminQuery(
                offset: 0,
                limit: 1,
                sortDescending: false,
                filters: const [],
              ),
            )
            .then((page) => counts[resource.key] = page.total)
            .catchError((Object _) => -1),
    ]);
    return counts;
  }

  /// The key numbers the server registered, for the overview.
  Future<List<admin_client.AdminMetricValue>> metrics() async {
    try {
      return await adminEndpoint.metrics();
    } catch (_) {
      return const [];
    }
  }

  /// Rows added on each of the last [days] days (oldest first, today last),
  /// or empty when [resource] has no date column to chart.
  Future<List<int>> activity(
    admin_client.AdminResource resource, {
    int days = 30,
  }) async {
    if (resource.chartColumn == null) return const [];
    final List<admin_client.AdminActivityPoint> points;
    try {
      points = await adminEndpoint.activity(resource.key, days);
    } catch (_) {
      return const [];
    }
    final now = DateTime.now().toUtc();
    final today = DateTime.utc(now.year, now.month, now.day);
    final counts = List.filled(days, 0);
    for (final point in points) {
      final day = point.day.toUtc();
      final index =
          days -
          1 -
          today.difference(DateTime.utc(day.year, day.month, day.day)).inDays;
      if (index >= 0 && index < days) counts[index] += point.count;
    }
    return counts;
  }

  /// The change history: everything, one resource's or one row's.
  Future<admin_client.AdminLogPage> history({
    String? resourceKey,
    String? recordId,
    int offset = 0,
    int limit = 25,
  }) => adminEndpoint.history(resourceKey, recordId, offset, limit);

  // Selection of rows on the current page, for bulk changes and actions.
  final Set<String> _selected = {};
  Set<String> get selectedIds => Set.unmodifiable(_selected);

  void toggleSelected(String id, bool selected) {
    selected ? _selected.add(id) : _selected.remove(id);
    notifyListeners();
  }

  void selectPage(bool selected) {
    final resource = selectedResource;
    if (resource == null) return;
    for (final record in records) {
      final id = resolvePrimaryKeyValue(resource, record);
      if (id == null) continue;
      selected ? _selected.add(id) : _selected.remove(id);
    }
    notifyListeners();
  }

  /// Selects every row matching the search and filters, not only this page.
  Future<void> selectAllMatching() async {
    final resource = selectedResource;
    if (resource == null) return;
    final rows = await fetchAllMatching(resource, maxRows: 10000);
    _selected
      ..clear()
      ..addAll([
        for (final row in rows) ?resolvePrimaryKeyValue(resource, row),
      ]);
    notifyListeners();
  }

  void clearSelection() {
    if (_selected.isEmpty) return;
    _selected.clear();
    notifyListeners();
  }

  Future<admin_client.AdminActionResult> deleteSelected() =>
      _bulk((resource, ids) => adminEndpoint.deleteMany(resource.key, ids));

  /// Sets [values] (column name to text) on every selected row.
  Future<admin_client.AdminActionResult> updateSelected(
    Map<String, String> values,
  ) => _bulk(
    (resource, ids) => adminEndpoint.updateMany(resource.key, ids, values),
  );

  /// Runs the custom action [name] on the selected rows.
  Future<admin_client.AdminActionResult> runActionOnSelected(String name) =>
      _bulk(
        (resource, ids) => adminEndpoint.runAction(resource.key, name, ids),
      );

  Future<admin_client.AdminActionResult> _bulk(
    Future<admin_client.AdminActionResult> Function(
      AdminResource resource,
      List<String> ids,
    )
    request,
  ) async {
    final resource = selectedResource;
    if (resource == null || _selected.isEmpty) {
      return admin_client.AdminActionResult(affected: 0);
    }
    try {
      return await request(resource, _selected.toList());
    } finally {
      _selected.clear();
      _revision++;
      await loadRecords(resource, showLoading: false);
    }
  }

  /// Counts the changes made through the dashboard, so views of other
  /// tables' rows (such as a record's related rows) read them again.
  int get revision => _revision;
  int _revision = 0;

  /// Reloads [resource]'s rows after a change when it is the table shown;
  /// otherwise views of its rows read them again through [revision].
  Future<void> _changed(AdminResource resource) async {
    _revision++;
    if (resource.key == selectedResource?.key) {
      await loadRecords(resource);
    } else {
      notifyListeners();
    }
  }

  // Relationships between resources.
  final Map<String, Map<String, String>> _labels = {};

  /// The resource a foreign key [column] points to, if registered.
  AdminResource? relatedResource(AdminColumn column) {
    final table = column.foreignKeyTable;
    if (table == null) return null;
    return resources
        .where((r) => r.tableName == table || r.key == table)
        .firstOrNull;
  }

  /// How a row of [resource] is named: its first name-like column.
  static AdminColumn? labelColumn(AdminResource resource) {
    const preferred = [
      'fullName',
      'name',
      'title',
      'label',
      'displayName',
      'userName',
      'email',
      'plate',
      'make',
    ];
    for (final name in preferred) {
      final column = resource.columns.where((c) => c.name == name).firstOrNull;
      if (column != null) return column;
    }
    return resource.columns
        .where(
          (c) =>
              !c.isPrimary &&
              c.foreignKeyTable == null &&
              c.dataType.toLowerCase() == 'string',
        )
        .firstOrNull;
  }

  /// A readable name for [record], such as "Awa Diallo (#12)".
  static String recordLabel(
    AdminResource resource,
    Map<String, String> record,
  ) {
    final primary = resource.columns.where((c) => c.isPrimary).firstOrNull;
    final id = primary == null ? '' : record[primary.name] ?? '';
    final name = labelColumn(resource);
    final text = name == null ? '' : record[name.name] ?? '';
    return text.isEmpty ? '#$id' : '$text (#$id)';
  }

  /// Names for the rows of [resource] with [ids], cached.
  Future<Map<String, String>> labelsFor(
    AdminResource resource,
    Iterable<String> ids,
  ) async {
    final cache = _labels.putIfAbsent(resource.key, () => {});
    final missing = {
      for (final id in ids)
        if (id.isNotEmpty && !cache.containsKey(id)) id,
    };
    final primary = resource.columns.where((c) => c.isPrimary).firstOrNull;
    if (missing.isNotEmpty && primary != null) {
      try {
        final page = await adminEndpoint.query(
          resource.key,
          admin_client.AdminQuery(
            offset: 0,
            limit: missing.length,
            sortDescending: false,
            filters: [
              admin_client.AdminFilter(
                column: primary.name,
                comparison: admin_client.AdminFilterOperator.oneOf,
                value: missing.join(','),
              ),
            ],
          ),
        );
        for (final row in page.rows) {
          final id = row[primary.name];
          if (id != null) cache[id] = recordLabel(resource, row);
        }
      } catch (_) {
        // Unnamed rows show their id.
      }
    }
    return {
      for (final id in ids)
        if (cache[id] case final label?) id: label,
    };
  }

  /// Rows of [resource] matching [text], for pickers.
  Future<List<Map<String, String>>> searchRecords(
    AdminResource resource,
    String text, {
    int limit = 20,
  }) async {
    final page = await adminEndpoint.query(
      resource.key,
      admin_client.AdminQuery(
        offset: 0,
        limit: limit,
        search: text.trim().isEmpty ? null : text.trim(),
        sortDescending: false,
        filters: const [],
      ),
    );
    return page.rows;
  }

  /// Opens the row of [resource] with primary key [id].
  Future<void> openRecord(AdminResource resource, String id) async {
    final primary = resource.columns.where((c) => c.isPrimary).firstOrNull;
    if (primary == null) return;
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
    final row = page.rows.firstOrNull;
    if (row == null) return;
    if (selectedResource?.key != resource.key) await selectResource(resource);
    openDetails(resource, row);
  }

  /// Lists [resource] narrowed by [filters], for "view all" links.
  Future<void> showFiltered(
    AdminResource resource,
    List<admin_client.AdminFilter> filters,
  ) async {
    _showSavedViewsOf(resource);
    selectedResource = resource;
    _showingOverview = false;
    closeDetails();
    _resetQuery();
    _filters = List.unmodifiable(filters);
    records = const [];
    notifyListeners();
    await loadRecords(resource);
  }

  /// Rows of other resources pointing at [record] through a foreign key:
  /// up to [limit] of each, with how many there are; tables with rows
  /// first.
  Future<List<RelatedRows>> relatedRecords(
    AdminResource resource,
    Map<String, String> record, {
    int limit = 10,
  }) async {
    final id = resolvePrimaryKeyValue(resource, record);
    if (id == null) return const [];
    final links = [
      for (final other in resources)
        for (final column in other.columns)
          if (column.foreignKeyTable == resource.tableName) (other, column),
    ];
    final results = await Future.wait([
      for (final (other, column) in links)
        adminEndpoint
            .query(
              other.key,
              admin_client.AdminQuery(
                offset: 0,
                limit: limit,
                sortDescending: false,
                filters: [
                  admin_client.AdminFilter(
                    column: column.name,
                    comparison: admin_client.AdminFilterOperator.equals,
                    value: id,
                  ),
                ],
              ),
            )
            .then<RelatedRows?>(
              (page) => RelatedRows(
                resource: other,
                column: column,
                value: id,
                rows: page.rows,
                total: page.total,
              ),
            )
            .catchError((Object _) => null),
    ]);
    return [
      for (final result in results)
        if (result != null && result.total > 0) result,
      for (final result in results)
        if (result != null && result.total == 0) result,
    ];
  }

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
    _themeMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
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
    if (current != null && !_showingOverview) {
      await loadRecords(current);
    } else {
      records = const [];
      notifyListeners();
    }
  }

  Future<void> selectResource(AdminResource resource) async {
    _showSavedViewsOf(resource);
    selectedResource = resource;
    _showingOverview = false;
    _selected.clear();
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
        final updatedRecord =
            _findUpdatedDetailsRecord(resource) ??
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
    await _changed(resource);
  }

  Future<void> updateRecord(
    AdminResource resource,
    Map<String, String> payload,
  ) async {
    await _write(() => adminEndpoint.update(resource.key, payload));
    await _changed(resource);

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

  Future<void> deleteRecord(AdminResource resource, String id) async {
    await adminEndpoint.delete(resource.key, id);
    await _changed(resource);
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

    await _changed(resource);
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
    final primaryColumn = resource.columns.firstWhere(
      (column) => column.isPrimary,
      orElse: () {
        return AdminColumn(
          name: 'id',
          dataType: 'String',
          hasDefault: true,
          isPrimary: true,
        );
      },
    );
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

/// Rows of [resource] whose [column] points at a record, as listed on that
/// record's details.
class RelatedRows {
  const RelatedRows({
    required this.resource,
    required this.column,
    required this.value,
    required this.rows,
    required this.total,
  });

  final AdminResource resource;
  final AdminColumn column;
  final String value;
  final List<Map<String, String>> rows;
  final int total;
}
