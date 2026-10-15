import 'dart:async';

import 'package:serverpod/serverpod.dart';

/// Counts the database calls sessions make, so tests can hold endpoint
/// methods to a fixed number of queries however many rows they touch:
///
/// ```dart
/// withServerpod('…', (sessionBuilder, endpoints) {
///   test('…', () async {
///     final (page, queries) = await QueryCounter.measure(
///       () => endpoints.admin.query(admin, 'counters', query),
///     );
///     expect(queries, 1);
///   });
/// }, databaseInterceptor: QueryCounter.intercept);
/// ```
class QueryCounter {
  const QueryCounter._();

  static int _calls = 0;

  /// What was called, in order, for failure messages.
  static final calls = <String>[];

  static Database intercept(Session session, Database inner) =>
      _CountingDatabase(inner);

  static final _measuring = Object();

  /// Runs [call] and returns its result with the database calls it made.
  /// Calls made by other work meanwhile, such as Serverpod's own background
  /// tasks, are not counted.
  static Future<(T, int)> measure<T>(Future<T> Function() call) async {
    _calls = 0;
    calls.clear();
    final result = await runZoned(call, zoneValues: {_measuring: true});
    return (result, _calls);
  }

  static void _count(String name) {
    if (Zone.current[_measuring] != true) return;
    _calls++;
    calls.add(name);
  }
}

class _CountingDatabase implements Database {
  _CountingDatabase(this._inner);

  final Database _inner;

  @override
  DatabaseDialect get dialect => _inner.dialect;

  @override
  DatabaseSerializationManager get serializationManager =>
      _inner.serializationManager;

  @override
  get analyzer => _inner.analyzer;

  @override
  Future<List<T>> find<T extends TableRow>({
    Expression? where,
    int? limit,
    int? offset,
    Column? orderBy,
    List<Column>? orderByList,
    Transaction? transaction,
    Include? include,
    LockMode? lockMode,
    LockBehavior? lockBehavior,
  }) {
    QueryCounter._count('find<$T>');
    return _inner.find<T>(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy,
      orderByList: orderByList,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  @override
  Future<T?> findFirstRow<T extends TableRow>({
    Expression? where,
    int? offset,
    Column? orderBy,
    List<Column>? orderByList,
    Transaction? transaction,
    Include? include,
    LockMode? lockMode,
    LockBehavior? lockBehavior,
  }) {
    QueryCounter._count('findFirstRow<$T>');
    return _inner.findFirstRow<T>(
      where: where,
      offset: offset,
      orderBy: orderBy,
      orderByList: orderByList,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  @override
  Future<T?> findById<T extends TableRow>(
    Object id, {
    Transaction? transaction,
    Include? include,
    LockMode? lockMode,
    LockBehavior? lockBehavior,
  }) {
    QueryCounter._count('findById<$T>');
    return _inner.findById<T>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  @override
  Future<void> lockRows<T extends TableRow>({
    required Expression where,
    required LockMode lockMode,
    required Transaction transaction,
    LockBehavior lockBehavior = LockBehavior.wait,
  }) {
    QueryCounter._count('lockRows<$T>');
    return _inner.lockRows<T>(
      where: where,
      lockMode: lockMode,
      transaction: transaction,
      lockBehavior: lockBehavior,
    );
  }

  @override
  Future<List<T>> update<T extends TableRow>(
    List<T> rows, {
    List<Column>? columns,
    Transaction? transaction,
    bool noReturn = false,
  }) {
    QueryCounter._count('update<$T>');
    return _inner.update<T>(
      rows,
      columns: columns,
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  @override
  Future<T> updateRow<T extends TableRow>(
    T row, {
    List<Column>? columns,
    Transaction? transaction,
  }) {
    QueryCounter._count('updateRow<$T>');
    return _inner.updateRow<T>(row, columns: columns, transaction: transaction);
  }

  @override
  Future<T?> updateById<T extends TableRow>(
    Object id, {
    required List<ColumnValue> columnValues,
    Transaction? transaction,
  }) {
    QueryCounter._count('updateById<$T>');
    return _inner.updateById<T>(
      id,
      columnValues: columnValues,
      transaction: transaction,
    );
  }

  @override
  Future<List<T>> updateWhere<T extends TableRow>({
    required List<ColumnValue> columnValues,
    required Expression where,
    int? limit,
    int? offset,
    Column? orderBy,
    List<Column>? orderByList,
    Transaction? transaction,
    bool noReturn = false,
  }) {
    QueryCounter._count('updateWhere<$T>');
    return _inner.updateWhere<T>(
      columnValues: columnValues,
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy,
      orderByList: orderByList,
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  @override
  Future<List<T>> insert<T extends TableRow>(
    List<T> rows, {
    Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) {
    QueryCounter._count('insert<$T>');
    return _inner.insert<T>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  @override
  Future<T> insertRow<T extends TableRow>(T row, {Transaction? transaction}) {
    QueryCounter._count('insertRow<$T>');
    return _inner.insertRow<T>(row, transaction: transaction);
  }

  @override
  Future<List<T>> upsert<T extends TableRow>(
    List<T> rows, {
    required List<Column> conflictColumns,
    List<Column>? updateColumns,
    Expression? updateWhere,
    Transaction? transaction,
    bool noReturn = false,
  }) {
    QueryCounter._count('upsert<$T>');
    return _inner.upsert<T>(
      rows,
      conflictColumns: conflictColumns,
      updateColumns: updateColumns,
      updateWhere: updateWhere,
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  @override
  Future<T?> upsertRow<T extends TableRow>(
    T row, {
    required List<Column> conflictColumns,
    List<Column>? updateColumns,
    Expression? updateWhere,
    Transaction? transaction,
  }) {
    QueryCounter._count('upsertRow<$T>');
    return _inner.upsertRow<T>(
      row,
      conflictColumns: conflictColumns,
      updateColumns: updateColumns,
      updateWhere: updateWhere,
      transaction: transaction,
    );
  }

  @override
  Future<List<T>> delete<T extends TableRow>(
    List<T> rows, {
    Column? orderBy,
    List<Column>? orderByList,
    Transaction? transaction,
    bool noReturn = false,
  }) {
    QueryCounter._count('delete<$T>');
    return _inner.delete<T>(
      rows,
      orderBy: orderBy,
      orderByList: orderByList,
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  @override
  Future<T> deleteRow<T extends TableRow>(T row, {Transaction? transaction}) {
    QueryCounter._count('deleteRow<$T>');
    return _inner.deleteRow<T>(row, transaction: transaction);
  }

  @override
  Future<List<T>> deleteWhere<T extends TableRow>({
    required Expression where,
    Column? orderBy,
    List<Column>? orderByList,
    Transaction? transaction,
    bool noReturn = false,
  }) {
    QueryCounter._count('deleteWhere<$T>');
    return _inner.deleteWhere<T>(
      where: where,
      orderBy: orderBy,
      orderByList: orderByList,
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  @override
  Future<int> count<T extends TableRow>({
    Expression? where,
    int? limit,
    bool useCache = true,
    Transaction? transaction,
  }) {
    QueryCounter._count('count<$T>');
    return _inner.count<T>(
      where: where,
      limit: limit,
      useCache: useCache,
      transaction: transaction,
    );
  }

  @override
  Future<DatabaseResult> unsafeQuery(
    String query, {
    int? timeoutInSeconds,
    Transaction? transaction,
    QueryParameters? parameters,
  }) {
    QueryCounter._count('unsafeQuery');
    return _inner.unsafeQuery(
      query,
      timeoutInSeconds: timeoutInSeconds,
      transaction: transaction,
      parameters: parameters,
    );
  }

  @override
  Future<int> unsafeExecute(
    String query, {
    int? timeoutInSeconds,
    Transaction? transaction,
    QueryParameters? parameters,
  }) {
    QueryCounter._count('unsafeExecute');
    return _inner.unsafeExecute(
      query,
      timeoutInSeconds: timeoutInSeconds,
      transaction: transaction,
      parameters: parameters,
    );
  }

  @override
  Future<DatabaseResult> unsafeSimpleQuery(
    String query, {
    int? timeoutInSeconds,
    Transaction? transaction,
  }) {
    QueryCounter._count('unsafeSimpleQuery');
    return _inner.unsafeSimpleQuery(
      query,
      timeoutInSeconds: timeoutInSeconds,
      transaction: transaction,
    );
  }

  @override
  Future<int> unsafeSimpleExecute(
    String query, {
    int? timeoutInSeconds,
    Transaction? transaction,
  }) {
    QueryCounter._count('unsafeSimpleExecute');
    return _inner.unsafeSimpleExecute(
      query,
      timeoutInSeconds: timeoutInSeconds,
      transaction: transaction,
    );
  }

  @override
  Future<R> transaction<R>(
    TransactionFunction<R> transactionFunction, {
    TransactionSettings? settings,
  }) => _inner.transaction<R>(transactionFunction, settings: settings);

  @override
  Future<bool> testConnection() => _inner.testConnection();
}
