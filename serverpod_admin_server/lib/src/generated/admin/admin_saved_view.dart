/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;
import '../admin/admin_filter.dart' as _i2;
import 'package:serverpod_admin_server/src/generated/protocol.dart' as _i3;

/// Filters, sort, search and visible columns an administrator saved under a
/// name for one table, to apply again later. Views are personal.
abstract class AdminSavedView
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  AdminSavedView._({
    this.id,
    required this.owner,
    required this.resourceKey,
    required this.name,
    this.search,
    this.sortColumn,
    required this.sortDescending,
    required this.filters,
    this.shownColumns,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory AdminSavedView({
    int? id,
    required String owner,
    required String resourceKey,
    required String name,
    String? search,
    String? sortColumn,
    required bool sortDescending,
    required List<_i2.AdminFilter> filters,
    List<String>? shownColumns,
    DateTime? updatedAt,
  }) = _AdminSavedViewImpl;

  factory AdminSavedView.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminSavedView(
      id: jsonSerialization['id'] as int?,
      owner: jsonSerialization['owner'] as String,
      resourceKey: jsonSerialization['resourceKey'] as String,
      name: jsonSerialization['name'] as String,
      search: jsonSerialization['search'] as String?,
      sortColumn: jsonSerialization['sortColumn'] as String?,
      sortDescending: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['sortDescending'],
      ),
      filters: _i3.Protocol().deserialize<List<_i2.AdminFilter>>(
        jsonSerialization['filters'],
      ),
      shownColumns: jsonSerialization['shownColumns'] == null
          ? null
          : _i3.Protocol().deserialize<List<String>>(
              jsonSerialization['shownColumns'],
            ),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = AdminSavedViewTable();

  static const db = AdminSavedViewRepository._();

  @override
  int? id;

  /// The auth user id of the administrator who saved it.
  String owner;

  String resourceKey;

  String name;

  /// Text matched against the table's searched columns.
  String? search;

  /// The chosen sort; none keeps the table's default order.
  String? sortColumn;

  bool sortDescending;

  List<_i2.AdminFilter> filters;

  /// The columns shown in the table; none keeps the table's defaults.
  List<String>? shownColumns;

  DateTime updatedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [AdminSavedView]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AdminSavedView copyWith({
    int? id,
    String? owner,
    String? resourceKey,
    String? name,
    String? search,
    String? sortColumn,
    bool? sortDescending,
    List<_i2.AdminFilter>? filters,
    List<String>? shownColumns,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_admin.AdminSavedView',
      if (id != null) 'id': id,
      'owner': owner,
      'resourceKey': resourceKey,
      'name': name,
      if (search != null) 'search': search,
      if (sortColumn != null) 'sortColumn': sortColumn,
      'sortDescending': sortDescending,
      'filters': filters.toJson(valueToJson: (v) => v.toJson()),
      if (shownColumns != null) 'shownColumns': shownColumns?.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_admin.AdminSavedView',
      if (id != null) 'id': id,
      'owner': owner,
      'resourceKey': resourceKey,
      'name': name,
      if (search != null) 'search': search,
      if (sortColumn != null) 'sortColumn': sortColumn,
      'sortDescending': sortDescending,
      'filters': filters.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      if (shownColumns != null) 'shownColumns': shownColumns?.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static AdminSavedViewInclude include() {
    return AdminSavedViewInclude._();
  }

  static AdminSavedViewIncludeList includeList({
    _i1.WhereExpressionBuilder<AdminSavedViewTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AdminSavedViewTable>? orderBy,
    _i1.OrderByListBuilder<AdminSavedViewTable>? orderByList,
    AdminSavedViewInclude? include,
  }) {
    return AdminSavedViewIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AdminSavedView.t),
      orderByList: orderByList?.call(AdminSavedView.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AdminSavedViewImpl extends AdminSavedView {
  _AdminSavedViewImpl({
    int? id,
    required String owner,
    required String resourceKey,
    required String name,
    String? search,
    String? sortColumn,
    required bool sortDescending,
    required List<_i2.AdminFilter> filters,
    List<String>? shownColumns,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         owner: owner,
         resourceKey: resourceKey,
         name: name,
         search: search,
         sortColumn: sortColumn,
         sortDescending: sortDescending,
         filters: filters,
         shownColumns: shownColumns,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [AdminSavedView]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AdminSavedView copyWith({
    Object? id = _Undefined,
    String? owner,
    String? resourceKey,
    String? name,
    Object? search = _Undefined,
    Object? sortColumn = _Undefined,
    bool? sortDescending,
    List<_i2.AdminFilter>? filters,
    Object? shownColumns = _Undefined,
    DateTime? updatedAt,
  }) {
    return AdminSavedView(
      id: id is int? ? id : this.id,
      owner: owner ?? this.owner,
      resourceKey: resourceKey ?? this.resourceKey,
      name: name ?? this.name,
      search: search is String? ? search : this.search,
      sortColumn: sortColumn is String? ? sortColumn : this.sortColumn,
      sortDescending: sortDescending ?? this.sortDescending,
      filters: filters ?? this.filters.map((e0) => e0.copyWith()).toList(),
      shownColumns: shownColumns is List<String>?
          ? shownColumns
          : this.shownColumns?.map((e0) => e0).toList(),
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class AdminSavedViewUpdateTable extends _i1.UpdateTable<AdminSavedViewTable> {
  AdminSavedViewUpdateTable(super.table);

  _i1.ColumnValue<String, String> owner(String value) => _i1.ColumnValue(
    table.owner,
    value,
  );

  _i1.ColumnValue<String, String> resourceKey(String value) => _i1.ColumnValue(
    table.resourceKey,
    value,
  );

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<String, String> search(String? value) => _i1.ColumnValue(
    table.search,
    value,
  );

  _i1.ColumnValue<String, String> sortColumn(String? value) => _i1.ColumnValue(
    table.sortColumn,
    value,
  );

  _i1.ColumnValue<bool, bool> sortDescending(bool value) => _i1.ColumnValue(
    table.sortDescending,
    value,
  );

  _i1.ColumnValue<List<_i2.AdminFilter>, List<_i2.AdminFilter>> filters(
    List<_i2.AdminFilter> value,
  ) => _i1.ColumnValue(
    table.filters,
    value,
  );

  _i1.ColumnValue<List<String>, List<String>> shownColumns(
    List<String>? value,
  ) => _i1.ColumnValue(
    table.shownColumns,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _i1.ColumnValue(
        table.updatedAt,
        value,
      );
}

class AdminSavedViewTable extends _i1.Table<int?> {
  AdminSavedViewTable({super.tableRelation})
    : super(tableName: 'serverpod_admin_saved_view') {
    updateTable = AdminSavedViewUpdateTable(this);
    owner = _i1.ColumnString(
      'owner',
      this,
    );
    resourceKey = _i1.ColumnString(
      'resourceKey',
      this,
    );
    name = _i1.ColumnString(
      'name',
      this,
    );
    search = _i1.ColumnString(
      'search',
      this,
    );
    sortColumn = _i1.ColumnString(
      'sortColumn',
      this,
    );
    sortDescending = _i1.ColumnBool(
      'sortDescending',
      this,
    );
    filters = _i1.ColumnSerializable<List<_i2.AdminFilter>>(
      'filters',
      this,
    );
    shownColumns = _i1.ColumnSerializable<List<String>>(
      'shownColumns',
      this,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
      hasDefault: true,
    );
  }

  late final AdminSavedViewUpdateTable updateTable;

  /// The auth user id of the administrator who saved it.
  late final _i1.ColumnString owner;

  late final _i1.ColumnString resourceKey;

  late final _i1.ColumnString name;

  /// Text matched against the table's searched columns.
  late final _i1.ColumnString search;

  /// The chosen sort; none keeps the table's default order.
  late final _i1.ColumnString sortColumn;

  late final _i1.ColumnBool sortDescending;

  late final _i1.ColumnSerializable<List<_i2.AdminFilter>> filters;

  /// The columns shown in the table; none keeps the table's defaults.
  late final _i1.ColumnSerializable<List<String>> shownColumns;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    owner,
    resourceKey,
    name,
    search,
    sortColumn,
    sortDescending,
    filters,
    shownColumns,
    updatedAt,
  ];
}

class AdminSavedViewInclude extends _i1.IncludeObject {
  AdminSavedViewInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => AdminSavedView.t;
}

class AdminSavedViewIncludeList extends _i1.IncludeList {
  AdminSavedViewIncludeList._({
    _i1.WhereExpressionBuilder<AdminSavedViewTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AdminSavedView.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => AdminSavedView.t;
}

class AdminSavedViewRepository {
  const AdminSavedViewRepository._();

  /// Returns a list of [AdminSavedView]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<AdminSavedView>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AdminSavedViewTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AdminSavedViewTable>? orderBy,
    _i1.OrderByListBuilder<AdminSavedViewTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AdminSavedView>(
      where: where?.call(AdminSavedView.t),
      orderBy: orderBy?.call(AdminSavedView.t),
      orderByList: orderByList?.call(AdminSavedView.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [AdminSavedView] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<AdminSavedView?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AdminSavedViewTable>? where,
    int? offset,
    _i1.OrderByBuilder<AdminSavedViewTable>? orderBy,
    _i1.OrderByListBuilder<AdminSavedViewTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AdminSavedView>(
      where: where?.call(AdminSavedView.t),
      orderBy: orderBy?.call(AdminSavedView.t),
      orderByList: orderByList?.call(AdminSavedView.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AdminSavedView] by its [id] or null if no such row exists.
  Future<AdminSavedView?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AdminSavedView>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AdminSavedView]s in the list and returns the inserted rows.
  ///
  /// The returned [AdminSavedView]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AdminSavedView>> insert(
    _i1.DatabaseSession session,
    List<AdminSavedView> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<AdminSavedView>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [AdminSavedView] and returns the inserted row.
  ///
  /// The returned [AdminSavedView] will have its `id` field set.
  Future<AdminSavedView> insertRow(
    _i1.DatabaseSession session,
    AdminSavedView row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<AdminSavedView>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [AdminSavedView]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [AdminSavedView]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AdminSavedView>> upsert(
    _i1.DatabaseSession session,
    List<AdminSavedView> rows, {
    required _i1.ColumnSelections<AdminSavedViewTable> conflictColumns,
    _i1.ColumnSelections<AdminSavedViewTable>? updateColumns,
    _i1.WhereExpressionBuilder<AdminSavedViewTable>? updateWhere,
    _i1.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<AdminSavedView>(
      rows,
      conflictColumns: conflictColumns(AdminSavedView.t),
      updateColumns: updateColumns?.call(AdminSavedView.t),
      updateWhere: updateWhere?.call(AdminSavedView.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [AdminSavedView] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [AdminSavedView] will have its `id` field set.
  Future<AdminSavedView?> upsertRow(
    _i1.DatabaseSession session,
    AdminSavedView row, {
    required _i1.ColumnSelections<AdminSavedViewTable> conflictColumns,
    _i1.ColumnSelections<AdminSavedViewTable>? updateColumns,
    _i1.WhereExpressionBuilder<AdminSavedViewTable>? updateWhere,
    _i1.Transaction? transaction,
  }) async {
    return session.db.upsertRow<AdminSavedView>(
      row,
      conflictColumns: conflictColumns(AdminSavedView.t),
      updateColumns: updateColumns?.call(AdminSavedView.t),
      updateWhere: updateWhere?.call(AdminSavedView.t),
      transaction: transaction,
    );
  }

  /// Updates all [AdminSavedView]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AdminSavedView>> update(
    _i1.DatabaseSession session,
    List<AdminSavedView> rows, {
    _i1.ColumnSelections<AdminSavedViewTable>? columns,
    _i1.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<AdminSavedView>(
      rows,
      columns: columns?.call(AdminSavedView.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [AdminSavedView]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AdminSavedView> updateRow(
    _i1.DatabaseSession session,
    AdminSavedView row, {
    _i1.ColumnSelections<AdminSavedViewTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<AdminSavedView>(
      row,
      columns: columns?.call(AdminSavedView.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AdminSavedView] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AdminSavedView?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<AdminSavedViewUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<AdminSavedView>(
      id,
      columnValues: columnValues(AdminSavedView.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AdminSavedView]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AdminSavedView>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<AdminSavedViewUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<AdminSavedViewTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AdminSavedViewTable>? orderBy,
    _i1.OrderByListBuilder<AdminSavedViewTable>? orderByList,
    _i1.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<AdminSavedView>(
      columnValues: columnValues(AdminSavedView.t.updateTable),
      where: where(AdminSavedView.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AdminSavedView.t),
      orderByList: orderByList?.call(AdminSavedView.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [AdminSavedView]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AdminSavedView>> delete(
    _i1.DatabaseSession session,
    List<AdminSavedView> rows, {
    _i1.OrderByBuilder<AdminSavedViewTable>? orderBy,
    _i1.OrderByListBuilder<AdminSavedViewTable>? orderByList,
    _i1.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<AdminSavedView>(
      rows,
      orderBy: orderBy?.call(AdminSavedView.t),
      orderByList: orderByList?.call(AdminSavedView.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [AdminSavedView].
  Future<AdminSavedView> deleteRow(
    _i1.DatabaseSession session,
    AdminSavedView row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AdminSavedView>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AdminSavedView>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<AdminSavedViewTable> where,
    _i1.OrderByBuilder<AdminSavedViewTable>? orderBy,
    _i1.OrderByListBuilder<AdminSavedViewTable>? orderByList,
    _i1.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<AdminSavedView>(
      where: where(AdminSavedView.t),
      orderBy: orderBy?.call(AdminSavedView.t),
      orderByList: orderByList?.call(AdminSavedView.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AdminSavedViewTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<AdminSavedView>(
      where: where?.call(AdminSavedView.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AdminSavedView] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<AdminSavedViewTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AdminSavedView>(
      where: where(AdminSavedView.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
