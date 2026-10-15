import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// The rows a page may hold.
const adminMaxPageSize = 500;

/// An [AdminQuery] as SQL for one table: filters and search as a WHERE
/// expression (values escaped by Serverpod) and the sort order. Newest rows
/// come first unless another column is chosen; the primary key keeps pages
/// stable.
class AdminSqlQuery {
  const AdminSqlQuery._(this.where, this.orderBy);

  final Expression? where;
  final List<Column> orderBy;

  /// Null when the query names a column the table does not store (such as an
  /// auth user's scopes shown on a profile row); then it runs in memory.
  static AdminSqlQuery? build(
    Table table,
    List<AdminColumn> columns,
    AdminQuery query, {
    Set<String>? searchColumns,
    String? defaultSort,
    bool defaultDescending = true,
  }) {
    Column? stored(String name) =>
        table.columns.where((c) => c.columnName == name).firstOrNull;
    AdminColumn? described(String name) =>
        columns.where((c) => c.name == name).firstOrNull;

    final conditions = <String>[];
    for (final filter in query.filters) {
      final column = stored(filter.column);
      final metadata = described(filter.column);
      if (metadata == null) throw _unknownColumn(filter.column);
      if (column == null) return null;
      conditions.add(_condition(column, metadata, filter));
    }

    final search = query.search?.trim() ?? '';
    if (search.isNotEmpty) {
      final pattern = _literal('%${_escapeLike(search)}%');
      // Only columns the dashboard may see are searched.
      final allowed = searchColumns ?? {for (final c in columns) c.name};
      final searchable = table.columns
          .where((c) => _searchable(c) && allowed.contains(c.columnName))
          .map((c) => "$c::text ILIKE $pattern ESCAPE '\\'");
      conditions.add(
        searchable.isEmpty ? 'FALSE' : '(${searchable.join(' OR ')})',
      );
    }

    final chosen = query.sortColumn;
    final sortName =
        chosen ??
        (defaultSort != null && stored(defaultSort) != null
            ? defaultSort
            : null);
    final Column sort;
    if (sortName == null) {
      sort = table.id;
    } else {
      if (described(sortName) == null) throw _unknownColumn(sortName);
      final column = stored(sortName);
      if (column == null) return null;
      sort = column;
    }
    final descending = chosen != null
        ? query.sortDescending
        : sortName == null || defaultDescending;
    return AdminSqlQuery._(
      conditions.isEmpty ? null : Expression('(${conditions.join(' AND ')})'),
      [
        descending ? sort.desc() : sort.asc(),
        if (sort != table.id) table.id.desc(),
      ],
    );
  }

  static String _condition(
    Column column,
    AdminColumn metadata,
    AdminFilter filter,
  ) {
    final name = '$column';
    switch (filter.comparison) {
      case AdminFilterOperator.isEmpty:
        return "($name IS NULL OR $name::text = '')";
      case AdminFilterOperator.isNotEmpty:
        return "($name IS NOT NULL AND $name::text <> '')";
      case AdminFilterOperator.contains:
        final pattern = _literal('%${_escapeLike(filter.value ?? '')}%');
        return "$name::text ILIKE $pattern ESCAPE '\\'";
      case AdminFilterOperator.equals:
        return '$name = ${_value(column, metadata, filter)}';
      case AdminFilterOperator.oneOf:
        final values = _oneOf(filter.value);
        if (values.isEmpty) return 'FALSE';
        final literals = [
          for (final value in values)
            _value(
              column,
              metadata,
              AdminFilter(
                column: filter.column,
                comparison: AdminFilterOperator.equals,
                value: value,
              ),
            ),
        ];
        return '$name IN (${literals.join(', ')})';
      case AdminFilterOperator.notEquals:
        return '($name IS NULL OR $name <> ${_value(column, metadata, filter)})';
      case AdminFilterOperator.greaterOrEqual:
        _requireOrdered(column, filter);
        return '$name >= ${_value(column, metadata, filter)}';
      case AdminFilterOperator.lessOrEqual:
        _requireOrdered(column, filter);
        final value = filter.value?.trim() ?? '';
        // A date alone means the whole day.
        if (column is ColumnDateTime && _dateOnly.hasMatch(value)) {
          final next = DateTime.parse(value).add(const Duration(days: 1));
          return '$name < ${_literal(next.toIso8601String().substring(0, 10))}';
        }
        return '$name <= ${_value(column, metadata, filter)}';
    }
  }

  /// The filter value as a SQL literal of the column's type.
  static String _value(
    Column column,
    AdminColumn metadata,
    AdminFilter filter,
  ) {
    final value = filter.value?.trim() ?? '';
    AdminValidationException invalid(String expected) =>
        AdminValidationException(
          field: filter.column,
          message: '${filter.column} must be $expected.',
        );
    if (column is ColumnEnum) {
      final values = metadata.enumValues ?? const <String>[];
      if (!values.contains(value)) throw invalid('one of ${values.join(', ')}');
      return metadata.enumSerializedByName == false
          ? '${values.indexOf(value)}'
          : _literal(value);
    }
    if (column is ColumnBool) {
      final lowered = value.toLowerCase();
      if (lowered != 'true' && lowered != 'false') {
        throw invalid('true or false');
      }
      return lowered.toUpperCase();
    }
    if (column is ColumnInt || column is ColumnBigInt) {
      final parsed = int.tryParse(value);
      if (parsed == null) throw invalid('a whole number');
      return '$parsed';
    }
    if (column is ColumnDouble) {
      final parsed = double.tryParse(value);
      if (parsed == null) throw invalid('a number');
      return '$parsed';
    }
    if (column is ColumnDateTime) {
      final parsed = DateTime.tryParse(value);
      if (parsed == null) throw invalid('a date such as 2026-10-01');
      return _literal(
        _dateOnly.hasMatch(value) ? value : parsed.toUtc().toIso8601String(),
      );
    }
    if (column is ColumnUuid) {
      try {
        UuidValue.withValidation(value);
      } on FormatException {
        throw invalid('a UUID');
      }
    }
    return _literal(value);
  }

  static void _requireOrdered(Column column, AdminFilter filter) {
    if (column is ColumnInt ||
        column is ColumnBigInt ||
        column is ColumnDouble ||
        column is ColumnDateTime) {
      return;
    }
    throw AdminValidationException(
      field: filter.column,
      message: '${filter.column} cannot be compared as greater or less.',
    );
  }

  /// The values of a [AdminFilterOperator.oneOf] filter.
  static List<String> _oneOf(String? value) => [
    for (final part in (value ?? '').split(','))
      if (part.trim().isNotEmpty) part.trim(),
  ];

  static bool _searchable(Column column) =>
      column is ColumnString ||
      column is ColumnUuid ||
      column is ColumnEnum ||
      column is ColumnInt ||
      column is ColumnBigInt;

  static final _dateOnly = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  /// A quoted SQL string. Quoted here rather than with EscapedExpression,
  /// whose encoder in some Serverpod releases passes strings shaped like
  /// `decode('…', 'base64')` through unescaped.
  static String _literal(String value) {
    if (value.contains('\u0000')) {
      throw AdminValidationException(message: 'Values cannot contain NUL.');
    }
    final escaped = value.replaceAll(r'\', r'\\').replaceAll("'", r"\'");
    return "E'$escaped'";
  }

  static String _escapeLike(String value) => value
      .replaceAll(r'\', r'\\')
      .replaceAll('%', r'\%')
      .replaceAll('_', r'\_');

  static AdminValidationException _unknownColumn(String name) =>
      AdminValidationException(field: name, message: 'Unknown column $name.');
}

/// An [AdminQuery] applied in memory to rows as the dashboard shows them, for
/// resources read with a custom `listRows` or columns not stored in the
/// table. Comparisons follow each column's type.
class AdminRowQuery {
  const AdminRowQuery._();

  static AdminPage apply(
    List<Map<String, String>> rows,
    List<AdminColumn> columns,
    AdminQuery query,
  ) {
    AdminColumn describe(String name) =>
        columns.where((c) => c.name == name).firstOrNull ??
        (throw AdminSqlQuery._unknownColumn(name));
    final filters = [
      for (final filter in query.filters) (describe(filter.column), filter),
    ];
    final search = query.search?.trim().toLowerCase() ?? '';
    final matching = rows.where((row) {
      if (search.isNotEmpty &&
          !row.values.any((v) => v.toLowerCase().contains(search))) {
        return false;
      }
      return filters.every((f) => _matches(row[f.$1.name] ?? '', f.$1, f.$2));
    }).toList();

    final sortName = query.sortColumn;
    if (sortName != null) {
      final column = describe(sortName);
      matching.sort((a, b) {
        final order = _compare(a[sortName] ?? '', b[sortName] ?? '', column);
        return query.sortDescending ? -order : order;
      });
    } else {
      // Newest first, as in the database.
      final primary = columns.where((c) => c.isPrimary).firstOrNull;
      if (primary != null) {
        matching.sort(
          (a, b) =>
              -_compare(a[primary.name] ?? '', b[primary.name] ?? '', primary),
        );
      }
    }
    final start = query.offset.clamp(0, matching.length);
    final end = (start + query.limit).clamp(start, matching.length);
    return AdminPage(
      rows: matching.sublist(start, end),
      total: matching.length,
    );
  }

  static bool _matches(String value, AdminColumn column, AdminFilter filter) {
    final wanted = filter.value?.trim() ?? '';
    return switch (filter.comparison) {
      AdminFilterOperator.isEmpty => value.isEmpty,
      AdminFilterOperator.isNotEmpty => value.isNotEmpty,
      AdminFilterOperator.contains => value.toLowerCase().contains(
        wanted.toLowerCase(),
      ),
      AdminFilterOperator.equals => _compare(value, wanted, column) == 0,
      AdminFilterOperator.oneOf => AdminSqlQuery._oneOf(
        wanted,
      ).any((option) => _compare(value, option, column) == 0),
      AdminFilterOperator.notEquals => _compare(value, wanted, column) != 0,
      AdminFilterOperator.greaterOrEqual =>
        value.isNotEmpty && _compare(value, wanted, column) >= 0,
      AdminFilterOperator.lessOrEqual =>
        value.isNotEmpty && _upTo(value, wanted, column),
    };
  }

  static bool _upTo(String value, String wanted, AdminColumn column) {
    final dateOnly = AdminSqlQuery._dateOnly.hasMatch(wanted);
    if (dateOnly && _isDate(column)) {
      final end = DateTime.parse(wanted).add(const Duration(days: 1));
      final parsed = DateTime.tryParse(value);
      return parsed != null && parsed.isBefore(end);
    }
    return _compare(value, wanted, column) <= 0;
  }

  static int _compare(String a, String b, AdminColumn column) {
    if (_isNumber(column)) {
      final x = num.tryParse(a);
      final y = num.tryParse(b);
      if (x != null && y != null) return x.compareTo(y);
    }
    if (_isDate(column)) {
      final x = DateTime.tryParse(a);
      final y = DateTime.tryParse(b);
      if (x != null && y != null) return x.compareTo(y);
    }
    return a.toLowerCase().compareTo(b.toLowerCase());
  }

  static bool _isNumber(AdminColumn column) {
    final type = column.dataType.toLowerCase();
    return type == 'int' || type == 'double' || type == 'bigint';
  }

  static bool _isDate(AdminColumn column) =>
      column.dataType.toLowerCase().contains('date');
}
