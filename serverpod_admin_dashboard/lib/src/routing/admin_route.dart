import 'package:serverpod_admin_client/serverpod_admin_client.dart'
    show AdminFilter, AdminFilterOperator;

/// What the dashboard shows, as an address that can be shared and is kept
/// in the browser's history: the overview (`/`), a page of a table with its
/// search, sort and filters (`/ride?q=airport&sort=-fare&page=2&status__exact=open`)
/// or a record (`/ride/12`).
///
/// Filters are written like Django admin's: `column__exact`, `__not`,
/// `__contains`, `__gte`, `__lte`, `__in` (comma-separated), `__isempty`
/// and `__notempty`.
class AdminRoute {
  const AdminRoute({
    this.resourceKey,
    this.recordId,
    this.page = 0,
    this.rowsPerPage,
    this.sortColumn,
    this.sortDescending = false,
    this.search = '',
    this.filters = const [],
  });

  static const overview = AdminRoute();

  /// The table shown; none for the overview.
  final String? resourceKey;

  /// The record shown, by primary key.
  final String? recordId;

  /// The page, from 0 (shown from 1 in the address).
  final int page;

  /// Rows per page, when not the default.
  final int? rowsPerPage;

  /// The chosen sort; none keeps the table's default order.
  final String? sortColumn;
  final bool sortDescending;
  final String search;
  final List<AdminFilter> filters;

  static const _operators = {
    AdminFilterOperator.equals: 'exact',
    AdminFilterOperator.notEquals: 'not',
    AdminFilterOperator.contains: 'contains',
    AdminFilterOperator.greaterOrEqual: 'gte',
    AdminFilterOperator.lessOrEqual: 'lte',
    AdminFilterOperator.oneOf: 'in',
    AdminFilterOperator.isEmpty: 'isempty',
    AdminFilterOperator.isNotEmpty: 'notempty',
  };

  static final _byToken = {
    for (final MapEntry(:key, :value) in _operators.entries) value: key,
  };

  /// The route an address names; parts it does not understand are ignored.
  factory AdminRoute.fromUri(Uri uri) {
    final segments = [
      for (final segment in uri.pathSegments)
        if (segment.isNotEmpty) segment,
    ];
    if (segments.isEmpty) return overview;
    if (segments.length > 1) {
      return AdminRoute(resourceKey: segments[0], recordId: segments[1]);
    }
    final parameters = uri.queryParametersAll;
    String? single(String name) => parameters[name]?.firstOrNull;
    final sort = single('sort') ?? '';
    final page = int.tryParse(single('page') ?? '') ?? 1;
    return AdminRoute(
      resourceKey: segments[0],
      page: page > 1 ? page - 1 : 0,
      rowsPerPage: int.tryParse(single('per') ?? ''),
      sortColumn: sort.isEmpty || sort == '-'
          ? null
          : sort.startsWith('-')
          ? sort.substring(1)
          : sort,
      sortDescending: sort.startsWith('-') && sort.length > 1,
      search: (single('q') ?? '').trim(),
      filters: [
        for (final MapEntry(:key, :value) in parameters.entries)
          if (_filterKey(key) case (final column, final comparison))
            for (final text in value)
              AdminFilter(
                column: column,
                comparison: comparison,
                value: _needsValue(comparison) ? text : null,
              ),
      ],
    );
  }

  /// "status__exact" as the status column and its comparison.
  static (String, AdminFilterOperator)? _filterKey(String key) {
    final split = key.lastIndexOf('__');
    if (split <= 0) return null;
    final comparison = _byToken[key.substring(split + 2)];
    if (comparison == null) return null;
    return (key.substring(0, split), comparison);
  }

  static bool _needsValue(AdminFilterOperator comparison) =>
      comparison != AdminFilterOperator.isEmpty &&
      comparison != AdminFilterOperator.isNotEmpty;

  Uri toUri() {
    final key = resourceKey;
    if (key == null) return Uri(path: '/');
    final id = recordId;
    if (id != null) return Uri(pathSegments: ['', key, id]);
    final parameters = <String, List<String>>{
      if (search.isNotEmpty) 'q': [search],
      if (sortColumn case final sort?)
        'sort': [sortDescending ? '-$sort' : sort],
      if (page > 0) 'page': ['${page + 1}'],
      if (rowsPerPage case final rows?) 'per': ['$rows'],
    };
    for (final filter in filters) {
      final name = '${filter.column}__${_operators[filter.comparison]}';
      (parameters[name] ??= []).add(
        _needsValue(filter.comparison) ? filter.value ?? '' : '1',
      );
    }
    return Uri(
      pathSegments: ['', key],
      queryParameters: parameters.isEmpty ? null : parameters,
    );
  }

  /// This route with another search.
  AdminRoute withSearch(String search) => AdminRoute(
    resourceKey: resourceKey,
    recordId: recordId,
    page: page,
    rowsPerPage: rowsPerPage,
    sortColumn: sortColumn,
    sortDescending: sortDescending,
    search: search,
    filters: filters,
  );

  @override
  bool operator ==(Object other) =>
      other is AdminRoute &&
      other.resourceKey == resourceKey &&
      other.recordId == recordId &&
      other.page == page &&
      other.rowsPerPage == rowsPerPage &&
      other.sortColumn == sortColumn &&
      other.sortDescending == sortDescending &&
      other.search == search &&
      sameFilters(other.filters, filters);

  @override
  int get hashCode => Object.hash(
    resourceKey,
    recordId,
    page,
    rowsPerPage,
    sortColumn,
    sortDescending,
    search,
    Object.hashAll([
      for (final filter in filters)
        (
          filter.column,
          filter.comparison,
          _needsValue(filter.comparison) ? filter.value ?? '' : '',
        ),
    ]),
  );

  @override
  String toString() => toUri().toString();
}

/// Whether [a] and [b] are the same filters in the same order.
bool sameFilters(List<AdminFilter> a, List<AdminFilter> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i].column != b[i].column ||
        a[i].comparison != b[i].comparison ||
        (AdminRoute._needsValue(a[i].comparison) &&
            (a[i].value ?? '') != (b[i].value ?? ''))) {
      return false;
    }
  }
  return true;
}
