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
import '../admin/admin_log_action.dart' as _i2;

/// One change made through Serverpod Admin: the history of a row and the
/// dashboard's recent actions.
abstract class AdminLogEntry
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  AdminLogEntry._({
    this.id,
    DateTime? createdAt,
    required this.actor,
    this.actorName,
    required this.resourceKey,
    required this.recordId,
    required this.action,
    required this.changes,
    this.summary,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AdminLogEntry({
    int? id,
    DateTime? createdAt,
    required String actor,
    String? actorName,
    required String resourceKey,
    required String recordId,
    required _i2.AdminLogAction action,
    required String changes,
    String? summary,
  }) = _AdminLogEntryImpl;

  factory AdminLogEntry.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminLogEntry(
      id: jsonSerialization['id'] as int?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      actor: jsonSerialization['actor'] as String,
      actorName: jsonSerialization['actorName'] as String?,
      resourceKey: jsonSerialization['resourceKey'] as String,
      recordId: jsonSerialization['recordId'] as String,
      action: _i2.AdminLogAction.fromJson(
        (jsonSerialization['action'] as String),
      ),
      changes: jsonSerialization['changes'] as String,
      summary: jsonSerialization['summary'] as String?,
    );
  }

  static final t = AdminLogEntryTable();

  static const db = AdminLogEntryRepository._();

  @override
  int? id;

  DateTime createdAt;

  /// The administrator's auth user id.
  String actor;

  /// How the administrator is shown, such as their email address.
  String? actorName;

  String resourceKey;

  String recordId;

  _i2.AdminLogAction action;

  /// JSON. Updates: {"field": ["before", "after"]}. Creations and deletions:
  /// the row's values. Fields that look secret are recorded as changed only.
  String changes;

  /// A short description, such as the label of a custom action.
  String? summary;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [AdminLogEntry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AdminLogEntry copyWith({
    int? id,
    DateTime? createdAt,
    String? actor,
    String? actorName,
    String? resourceKey,
    String? recordId,
    _i2.AdminLogAction? action,
    String? changes,
    String? summary,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_admin.AdminLogEntry',
      if (id != null) 'id': id,
      'createdAt': createdAt.toJson(),
      'actor': actor,
      if (actorName != null) 'actorName': actorName,
      'resourceKey': resourceKey,
      'recordId': recordId,
      'action': action.toJson(),
      'changes': changes,
      if (summary != null) 'summary': summary,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_admin.AdminLogEntry',
      if (id != null) 'id': id,
      'createdAt': createdAt.toJson(),
      'actor': actor,
      if (actorName != null) 'actorName': actorName,
      'resourceKey': resourceKey,
      'recordId': recordId,
      'action': action.toJson(),
      'changes': changes,
      if (summary != null) 'summary': summary,
    };
  }

  static AdminLogEntryInclude include() {
    return AdminLogEntryInclude._();
  }

  static AdminLogEntryIncludeList includeList({
    _i1.WhereExpressionBuilder<AdminLogEntryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AdminLogEntryTable>? orderBy,
    _i1.OrderByListBuilder<AdminLogEntryTable>? orderByList,
    AdminLogEntryInclude? include,
  }) {
    return AdminLogEntryIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AdminLogEntry.t),
      orderByList: orderByList?.call(AdminLogEntry.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AdminLogEntryImpl extends AdminLogEntry {
  _AdminLogEntryImpl({
    int? id,
    DateTime? createdAt,
    required String actor,
    String? actorName,
    required String resourceKey,
    required String recordId,
    required _i2.AdminLogAction action,
    required String changes,
    String? summary,
  }) : super._(
         id: id,
         createdAt: createdAt,
         actor: actor,
         actorName: actorName,
         resourceKey: resourceKey,
         recordId: recordId,
         action: action,
         changes: changes,
         summary: summary,
       );

  /// Returns a shallow copy of this [AdminLogEntry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AdminLogEntry copyWith({
    Object? id = _Undefined,
    DateTime? createdAt,
    String? actor,
    Object? actorName = _Undefined,
    String? resourceKey,
    String? recordId,
    _i2.AdminLogAction? action,
    String? changes,
    Object? summary = _Undefined,
  }) {
    return AdminLogEntry(
      id: id is int? ? id : this.id,
      createdAt: createdAt ?? this.createdAt,
      actor: actor ?? this.actor,
      actorName: actorName is String? ? actorName : this.actorName,
      resourceKey: resourceKey ?? this.resourceKey,
      recordId: recordId ?? this.recordId,
      action: action ?? this.action,
      changes: changes ?? this.changes,
      summary: summary is String? ? summary : this.summary,
    );
  }
}

class AdminLogEntryUpdateTable extends _i1.UpdateTable<AdminLogEntryTable> {
  AdminLogEntryUpdateTable(super.table);

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );

  _i1.ColumnValue<String, String> actor(String value) => _i1.ColumnValue(
    table.actor,
    value,
  );

  _i1.ColumnValue<String, String> actorName(String? value) => _i1.ColumnValue(
    table.actorName,
    value,
  );

  _i1.ColumnValue<String, String> resourceKey(String value) => _i1.ColumnValue(
    table.resourceKey,
    value,
  );

  _i1.ColumnValue<String, String> recordId(String value) => _i1.ColumnValue(
    table.recordId,
    value,
  );

  _i1.ColumnValue<_i2.AdminLogAction, _i2.AdminLogAction> action(
    _i2.AdminLogAction value,
  ) => _i1.ColumnValue(
    table.action,
    value,
  );

  _i1.ColumnValue<String, String> changes(String value) => _i1.ColumnValue(
    table.changes,
    value,
  );

  _i1.ColumnValue<String, String> summary(String? value) => _i1.ColumnValue(
    table.summary,
    value,
  );
}

class AdminLogEntryTable extends _i1.Table<int?> {
  AdminLogEntryTable({super.tableRelation})
    : super(tableName: 'serverpod_admin_log') {
    updateTable = AdminLogEntryUpdateTable(this);
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    actor = _i1.ColumnString(
      'actor',
      this,
    );
    actorName = _i1.ColumnString(
      'actorName',
      this,
    );
    resourceKey = _i1.ColumnString(
      'resourceKey',
      this,
    );
    recordId = _i1.ColumnString(
      'recordId',
      this,
    );
    action = _i1.ColumnEnum(
      'action',
      this,
      _i1.EnumSerialization.byName,
    );
    changes = _i1.ColumnString(
      'changes',
      this,
    );
    summary = _i1.ColumnString(
      'summary',
      this,
    );
  }

  late final AdminLogEntryUpdateTable updateTable;

  late final _i1.ColumnDateTime createdAt;

  /// The administrator's auth user id.
  late final _i1.ColumnString actor;

  /// How the administrator is shown, such as their email address.
  late final _i1.ColumnString actorName;

  late final _i1.ColumnString resourceKey;

  late final _i1.ColumnString recordId;

  late final _i1.ColumnEnum<_i2.AdminLogAction> action;

  /// JSON. Updates: {"field": ["before", "after"]}. Creations and deletions:
  /// the row's values. Fields that look secret are recorded as changed only.
  late final _i1.ColumnString changes;

  /// A short description, such as the label of a custom action.
  late final _i1.ColumnString summary;

  @override
  List<_i1.Column> get columns => [
    id,
    createdAt,
    actor,
    actorName,
    resourceKey,
    recordId,
    action,
    changes,
    summary,
  ];
}

class AdminLogEntryInclude extends _i1.IncludeObject {
  AdminLogEntryInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => AdminLogEntry.t;
}

class AdminLogEntryIncludeList extends _i1.IncludeList {
  AdminLogEntryIncludeList._({
    _i1.WhereExpressionBuilder<AdminLogEntryTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AdminLogEntry.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => AdminLogEntry.t;
}

class AdminLogEntryRepository {
  const AdminLogEntryRepository._();

  /// Returns a list of [AdminLogEntry]s matching the given query parameters.
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
  Future<List<AdminLogEntry>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AdminLogEntryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AdminLogEntryTable>? orderBy,
    _i1.OrderByListBuilder<AdminLogEntryTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AdminLogEntry>(
      where: where?.call(AdminLogEntry.t),
      orderBy: orderBy?.call(AdminLogEntry.t),
      orderByList: orderByList?.call(AdminLogEntry.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [AdminLogEntry] matching the given query parameters.
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
  Future<AdminLogEntry?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AdminLogEntryTable>? where,
    int? offset,
    _i1.OrderByBuilder<AdminLogEntryTable>? orderBy,
    _i1.OrderByListBuilder<AdminLogEntryTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AdminLogEntry>(
      where: where?.call(AdminLogEntry.t),
      orderBy: orderBy?.call(AdminLogEntry.t),
      orderByList: orderByList?.call(AdminLogEntry.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AdminLogEntry] by its [id] or null if no such row exists.
  Future<AdminLogEntry?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AdminLogEntry>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AdminLogEntry]s in the list and returns the inserted rows.
  ///
  /// The returned [AdminLogEntry]s will have their `id` fields set.
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
  Future<List<AdminLogEntry>> insert(
    _i1.DatabaseSession session,
    List<AdminLogEntry> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<AdminLogEntry>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [AdminLogEntry] and returns the inserted row.
  ///
  /// The returned [AdminLogEntry] will have its `id` field set.
  Future<AdminLogEntry> insertRow(
    _i1.DatabaseSession session,
    AdminLogEntry row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<AdminLogEntry>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [AdminLogEntry]s in the list and returns the resulting rows.
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
  /// The returned [AdminLogEntry]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AdminLogEntry>> upsert(
    _i1.DatabaseSession session,
    List<AdminLogEntry> rows, {
    required _i1.ColumnSelections<AdminLogEntryTable> conflictColumns,
    _i1.ColumnSelections<AdminLogEntryTable>? updateColumns,
    _i1.WhereExpressionBuilder<AdminLogEntryTable>? updateWhere,
    _i1.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<AdminLogEntry>(
      rows,
      conflictColumns: conflictColumns(AdminLogEntry.t),
      updateColumns: updateColumns?.call(AdminLogEntry.t),
      updateWhere: updateWhere?.call(AdminLogEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [AdminLogEntry] and returns the resulting row.
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
  /// The returned [AdminLogEntry] will have its `id` field set.
  Future<AdminLogEntry?> upsertRow(
    _i1.DatabaseSession session,
    AdminLogEntry row, {
    required _i1.ColumnSelections<AdminLogEntryTable> conflictColumns,
    _i1.ColumnSelections<AdminLogEntryTable>? updateColumns,
    _i1.WhereExpressionBuilder<AdminLogEntryTable>? updateWhere,
    _i1.Transaction? transaction,
  }) async {
    return session.db.upsertRow<AdminLogEntry>(
      row,
      conflictColumns: conflictColumns(AdminLogEntry.t),
      updateColumns: updateColumns?.call(AdminLogEntry.t),
      updateWhere: updateWhere?.call(AdminLogEntry.t),
      transaction: transaction,
    );
  }

  /// Updates all [AdminLogEntry]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AdminLogEntry>> update(
    _i1.DatabaseSession session,
    List<AdminLogEntry> rows, {
    _i1.ColumnSelections<AdminLogEntryTable>? columns,
    _i1.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<AdminLogEntry>(
      rows,
      columns: columns?.call(AdminLogEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [AdminLogEntry]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AdminLogEntry> updateRow(
    _i1.DatabaseSession session,
    AdminLogEntry row, {
    _i1.ColumnSelections<AdminLogEntryTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<AdminLogEntry>(
      row,
      columns: columns?.call(AdminLogEntry.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AdminLogEntry] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AdminLogEntry?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<AdminLogEntryUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<AdminLogEntry>(
      id,
      columnValues: columnValues(AdminLogEntry.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AdminLogEntry]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AdminLogEntry>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<AdminLogEntryUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<AdminLogEntryTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AdminLogEntryTable>? orderBy,
    _i1.OrderByListBuilder<AdminLogEntryTable>? orderByList,
    _i1.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<AdminLogEntry>(
      columnValues: columnValues(AdminLogEntry.t.updateTable),
      where: where(AdminLogEntry.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AdminLogEntry.t),
      orderByList: orderByList?.call(AdminLogEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [AdminLogEntry]s in the list and returns the deleted rows.
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
  Future<List<AdminLogEntry>> delete(
    _i1.DatabaseSession session,
    List<AdminLogEntry> rows, {
    _i1.OrderByBuilder<AdminLogEntryTable>? orderBy,
    _i1.OrderByListBuilder<AdminLogEntryTable>? orderByList,
    _i1.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<AdminLogEntry>(
      rows,
      orderBy: orderBy?.call(AdminLogEntry.t),
      orderByList: orderByList?.call(AdminLogEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [AdminLogEntry].
  Future<AdminLogEntry> deleteRow(
    _i1.DatabaseSession session,
    AdminLogEntry row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AdminLogEntry>(
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
  Future<List<AdminLogEntry>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<AdminLogEntryTable> where,
    _i1.OrderByBuilder<AdminLogEntryTable>? orderBy,
    _i1.OrderByListBuilder<AdminLogEntryTable>? orderByList,
    _i1.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<AdminLogEntry>(
      where: where(AdminLogEntry.t),
      orderBy: orderBy?.call(AdminLogEntry.t),
      orderByList: orderByList?.call(AdminLogEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AdminLogEntryTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<AdminLogEntry>(
      where: where?.call(AdminLogEntry.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AdminLogEntry] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<AdminLogEntryTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AdminLogEntry>(
      where: where(AdminLogEntry.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
