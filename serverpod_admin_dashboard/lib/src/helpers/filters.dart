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
  return needsValue(filter.comparison)
      ? '${filter.column} $label ${filter.value ?? ''}'
      : '${filter.column} $label';
}
