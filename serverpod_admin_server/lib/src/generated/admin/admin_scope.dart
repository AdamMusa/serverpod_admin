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

abstract class AdminScope
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  AdminScope._({
    this.id,
    required this.userId,
    required this.isStaff,
    required this.isSuperuser,
  });

  factory AdminScope({
    int? id,
    required String userId,
    required bool isStaff,
    required bool isSuperuser,
  }) = _AdminScopeImpl;

  factory AdminScope.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminScope(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as String,
      isStaff: jsonSerialization['isStaff'] as bool,
      isSuperuser: jsonSerialization['isSuperuser'] as bool,
    );
  }

  static final t = AdminScopeTable();

  static const db = AdminScopeRepository._();

  @override
  int? id;

  String userId;

  bool isStaff;

  bool isSuperuser;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [AdminScope]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AdminScope copyWith({
    int? id,
    String? userId,
    bool? isStaff,
    bool? isSuperuser,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_admin.AdminScope',
      if (id != null) 'id': id,
      'userId': userId,
      'isStaff': isStaff,
      'isSuperuser': isSuperuser,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_admin.AdminScope',
      if (id != null) 'id': id,
      'userId': userId,
      'isStaff': isStaff,
      'isSuperuser': isSuperuser,
    };
  }

  static AdminScopeInclude include() {
    return AdminScopeInclude._();
  }

  static AdminScopeIncludeList includeList({
    _i1.WhereExpressionBuilder<AdminScopeTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AdminScopeTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AdminScopeTable>? orderByList,
    AdminScopeInclude? include,
  }) {
    return AdminScopeIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AdminScope.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(AdminScope.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AdminScopeImpl extends AdminScope {
  _AdminScopeImpl({
    int? id,
    required String userId,
    required bool isStaff,
    required bool isSuperuser,
  }) : super._(
         id: id,
         userId: userId,
         isStaff: isStaff,
         isSuperuser: isSuperuser,
       );

  /// Returns a shallow copy of this [AdminScope]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AdminScope copyWith({
    Object? id = _Undefined,
    String? userId,
    bool? isStaff,
    bool? isSuperuser,
  }) {
    return AdminScope(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      isStaff: isStaff ?? this.isStaff,
      isSuperuser: isSuperuser ?? this.isSuperuser,
    );
  }
}

class AdminScopeUpdateTable extends _i1.UpdateTable<AdminScopeTable> {
  AdminScopeUpdateTable(super.table);

  _i1.ColumnValue<String, String> userId(String value) => _i1.ColumnValue(
    table.userId,
    value,
  );

  _i1.ColumnValue<bool, bool> isStaff(bool value) => _i1.ColumnValue(
    table.isStaff,
    value,
  );

  _i1.ColumnValue<bool, bool> isSuperuser(bool value) => _i1.ColumnValue(
    table.isSuperuser,
    value,
  );
}

class AdminScopeTable extends _i1.Table<int?> {
  AdminScopeTable({super.tableRelation}) : super(tableName: 'admin_scope') {
    updateTable = AdminScopeUpdateTable(this);
    userId = _i1.ColumnString(
      'userId',
      this,
    );
    isStaff = _i1.ColumnBool(
      'isStaff',
      this,
    );
    isSuperuser = _i1.ColumnBool(
      'isSuperuser',
      this,
    );
  }

  late final AdminScopeUpdateTable updateTable;

  late final _i1.ColumnString userId;

  late final _i1.ColumnBool isStaff;

  late final _i1.ColumnBool isSuperuser;

  @override
  List<_i1.Column> get columns => [
    id,
    userId,
    isStaff,
    isSuperuser,
  ];
}

class AdminScopeInclude extends _i1.IncludeObject {
  AdminScopeInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => AdminScope.t;
}

class AdminScopeIncludeList extends _i1.IncludeList {
  AdminScopeIncludeList._({
    _i1.WhereExpressionBuilder<AdminScopeTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AdminScope.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => AdminScope.t;
}

class AdminScopeRepository {
  const AdminScopeRepository._();

  /// Returns a list of [AdminScope]s matching the given query parameters.
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
  Future<List<AdminScope>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<AdminScopeTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AdminScopeTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AdminScopeTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<AdminScope>(
      where: where?.call(AdminScope.t),
      orderBy: orderBy?.call(AdminScope.t),
      orderByList: orderByList?.call(AdminScope.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [AdminScope] matching the given query parameters.
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
  Future<AdminScope?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<AdminScopeTable>? where,
    int? offset,
    _i1.OrderByBuilder<AdminScopeTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AdminScopeTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<AdminScope>(
      where: where?.call(AdminScope.t),
      orderBy: orderBy?.call(AdminScope.t),
      orderByList: orderByList?.call(AdminScope.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [AdminScope] by its [id] or null if no such row exists.
  Future<AdminScope?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<AdminScope>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [AdminScope]s in the list and returns the inserted rows.
  ///
  /// The returned [AdminScope]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<AdminScope>> insert(
    _i1.Session session,
    List<AdminScope> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<AdminScope>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [AdminScope] and returns the inserted row.
  ///
  /// The returned [AdminScope] will have its `id` field set.
  Future<AdminScope> insertRow(
    _i1.Session session,
    AdminScope row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<AdminScope>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [AdminScope]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<AdminScope>> update(
    _i1.Session session,
    List<AdminScope> rows, {
    _i1.ColumnSelections<AdminScopeTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<AdminScope>(
      rows,
      columns: columns?.call(AdminScope.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AdminScope]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AdminScope> updateRow(
    _i1.Session session,
    AdminScope row, {
    _i1.ColumnSelections<AdminScopeTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<AdminScope>(
      row,
      columns: columns?.call(AdminScope.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AdminScope] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AdminScope?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<AdminScopeUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<AdminScope>(
      id,
      columnValues: columnValues(AdminScope.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AdminScope]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<AdminScope>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<AdminScopeUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<AdminScopeTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AdminScopeTable>? orderBy,
    _i1.OrderByListBuilder<AdminScopeTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<AdminScope>(
      columnValues: columnValues(AdminScope.t.updateTable),
      where: where(AdminScope.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AdminScope.t),
      orderByList: orderByList?.call(AdminScope.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [AdminScope]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<AdminScope>> delete(
    _i1.Session session,
    List<AdminScope> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<AdminScope>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [AdminScope].
  Future<AdminScope> deleteRow(
    _i1.Session session,
    AdminScope row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AdminScope>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<AdminScope>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<AdminScopeTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<AdminScope>(
      where: where(AdminScope.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<AdminScopeTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<AdminScope>(
      where: where?.call(AdminScope.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
