import 'package:serverpod_admin_client/serverpod_admin_client.dart';

/// How a column's filter value is entered and compared.
enum FilterValueKind { text, number, date, boolean, enumeration, list }

FilterValueKind filterKindOf(AdminColumn column) {
  if (column.enumValues?.isNotEmpty ?? false) {
    return FilterValueKind.enumeration;
  }
  if (column.choices?.isNotEmpty ?? false) return FilterValueKind.list;
  final type = column.dataType.toLowerCase();
  if (type.contains('bool')) return FilterValueKind.boolean;
  if (type == 'int' || type == 'double' || type == 'bigint') {
    return FilterValueKind.number;
  }
  if (type.contains('date')) return FilterValueKind.date;
  if (type.startsWith('list') ||
      type.startsWith('set') ||
      type.startsWith('map')) {
    return FilterValueKind.list;
  }
  return FilterValueKind.text;
}

/// The comparisons that make sense for a kind of column.
List<AdminFilterOperator> operatorsFor(FilterValueKind kind) => switch (kind) {
  FilterValueKind.text => const [
    AdminFilterOperator.contains,
    AdminFilterOperator.equals,
    AdminFilterOperator.notEquals,
    AdminFilterOperator.isEmpty,
    AdminFilterOperator.isNotEmpty,
  ],
  FilterValueKind.number || FilterValueKind.date => const [
    AdminFilterOperator.equals,
    AdminFilterOperator.notEquals,
    AdminFilterOperator.greaterOrEqual,
    AdminFilterOperator.lessOrEqual,
    AdminFilterOperator.isEmpty,
    AdminFilterOperator.isNotEmpty,
  ],
  FilterValueKind.boolean => const [AdminFilterOperator.equals],
  FilterValueKind.enumeration => const [
    AdminFilterOperator.equals,
    AdminFilterOperator.notEquals,
    AdminFilterOperator.isEmpty,
    AdminFilterOperator.isNotEmpty,
  ],
  FilterValueKind.list => const [
    AdminFilterOperator.contains,
    AdminFilterOperator.isEmpty,
    AdminFilterOperator.isNotEmpty,
  ],
};

String operatorLabel(AdminFilterOperator operator, FilterValueKind kind) =>
    switch (operator) {
      AdminFilterOperator.equals => 'is',
      AdminFilterOperator.notEquals => 'is not',
      AdminFilterOperator.contains => 'contains',
      AdminFilterOperator.oneOf => 'is one of',
      AdminFilterOperator.greaterOrEqual =>
        kind == FilterValueKind.date ? 'on or after' : 'at least',
      AdminFilterOperator.lessOrEqual =>
        kind == FilterValueKind.date ? 'on or before' : 'at most',
      AdminFilterOperator.isEmpty => 'is empty',
      AdminFilterOperator.isNotEmpty => 'is not empty',
    };

bool needsValue(AdminFilterOperator operator) =>
    operator != AdminFilterOperator.isEmpty &&
    operator != AdminFilterOperator.isNotEmpty;

/// "status is approved", "createdAt on or after 2026-10-01".
String describeFilter(AdminFilter filter, AdminResource resource) {
  final column = resource.columns
      .where((c) => c.name == filter.column)
      .firstOrNull;
  final kind = column == null ? FilterValueKind.text : filterKindOf(column);
  final label = operatorLabel(filter.comparison, kind);
  final name = column?.label ?? filter.column;
  return needsValue(filter.comparison)
      ? '$name $label ${filter.value ?? ''}'
      : '$name $label';
}

/// A quick date range offered by the filter dialog.
enum DateShortcut {
  today('Today'),
  last7Days('Last 7 days'),
  last30Days('Last 30 days'),
  thisMonth('This month');

  const DateShortcut(this.label);

  final String label;

  /// The first day of the range ending [now], as a date filter value.
  String start(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final first = switch (this) {
      DateShortcut.today => today,
      DateShortcut.last7Days => DateTime(now.year, now.month, now.day - 6),
      DateShortcut.last30Days => DateTime(now.year, now.month, now.day - 29),
      DateShortcut.thisMonth => DateTime(now.year, now.month),
    };
    return first.toIso8601String().substring(0, 10);
  }

  /// The filter keeping [column]'s rows in the range ending [now].
  AdminFilter filter(String column, DateTime now) => AdminFilter(
    column: column,
    comparison: AdminFilterOperator.greaterOrEqual,
    value: start(now),
  );
}
