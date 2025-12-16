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
import 'package:example_server/src/generated/protocol.dart' as _i2;

/// AI Generation or App Configuration
abstract class Setting
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  Setting._({
    this.id,
    required this.theme,
    required this.detailLevel,
    required this.mood,
    required this.language,
    required this.features,
    required this.createdAt,
  });

  factory Setting({
    int? id,
    required String theme,
    required String detailLevel,
    required String mood,
    required String language,
    required List<String> features,
    required DateTime createdAt,
  }) = _SettingImpl;

  factory Setting.fromJson(Map<String, dynamic> jsonSerialization) {
    return Setting(
      id: jsonSerialization['id'] as int?,
      theme: jsonSerialization['theme'] as String,
      detailLevel: jsonSerialization['detailLevel'] as String,
      mood: jsonSerialization['mood'] as String,
      language: jsonSerialization['language'] as String,
      features: _i2.Protocol().deserialize<List<String>>(
        jsonSerialization['features'],
      ),
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = SettingTable();

  static const db = SettingRepository._();

  @override
  int? id;

  /// The theme or style of the AI-generated content
  String theme;

  /// The theme or style of the AI-generated content
  /// Level of detail or complexity
  String detailLevel;

  /// The theme or style of the AI-generated content
  /// Level of detail or complexity
  /// Mood or tone for content generation
  String mood;

  /// The theme or style of the AI-generated content
  /// Level of detail or complexity
  /// Mood or tone for content generation
  /// Language or locale
  String language;

  /// The theme or style of the AI-generated content
  /// Level of detail or complexity
  /// Mood or tone for content generation
  /// Language or locale
  /// List of features or options enabled
  List<String> features;

  /// The theme or style of the AI-generated content
  /// Level of detail or complexity
  /// Mood or tone for content generation
  /// Language or locale
  /// List of features or options enabled
  /// Timestamp of creation or last update
  DateTime createdAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [Setting]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Setting copyWith({
    int? id,
    String? theme,
    String? detailLevel,
    String? mood,
    String? language,
    List<String>? features,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Setting',
      if (id != null) 'id': id,
      'theme': theme,
      'detailLevel': detailLevel,
      'mood': mood,
      'language': language,
      'features': features.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Setting',
      if (id != null) 'id': id,
      'theme': theme,
      'detailLevel': detailLevel,
      'mood': mood,
      'language': language,
      'features': features.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  static SettingInclude include() {
    return SettingInclude._();
  }

  static SettingIncludeList includeList({
    _i1.WhereExpressionBuilder<SettingTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SettingTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SettingTable>? orderByList,
    SettingInclude? include,
  }) {
    return SettingIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Setting.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Setting.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SettingImpl extends Setting {
  _SettingImpl({
    int? id,
    required String theme,
    required String detailLevel,
    required String mood,
    required String language,
    required List<String> features,
    required DateTime createdAt,
  }) : super._(
         id: id,
         theme: theme,
         detailLevel: detailLevel,
         mood: mood,
         language: language,
         features: features,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Setting]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Setting copyWith({
    Object? id = _Undefined,
    String? theme,
    String? detailLevel,
    String? mood,
    String? language,
    List<String>? features,
    DateTime? createdAt,
  }) {
    return Setting(
      id: id is int? ? id : this.id,
      theme: theme ?? this.theme,
      detailLevel: detailLevel ?? this.detailLevel,
      mood: mood ?? this.mood,
      language: language ?? this.language,
      features: features ?? this.features.map((e0) => e0).toList(),
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class SettingUpdateTable extends _i1.UpdateTable<SettingTable> {
  SettingUpdateTable(super.table);

  _i1.ColumnValue<String, String> theme(String value) => _i1.ColumnValue(
    table.theme,
    value,
  );

  _i1.ColumnValue<String, String> detailLevel(String value) => _i1.ColumnValue(
    table.detailLevel,
    value,
  );

  _i1.ColumnValue<String, String> mood(String value) => _i1.ColumnValue(
    table.mood,
    value,
  );

  _i1.ColumnValue<String, String> language(String value) => _i1.ColumnValue(
    table.language,
    value,
  );

  _i1.ColumnValue<List<String>, List<String>> features(List<String> value) =>
      _i1.ColumnValue(
        table.features,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class SettingTable extends _i1.Table<int?> {
  SettingTable({super.tableRelation}) : super(tableName: 'settings') {
    updateTable = SettingUpdateTable(this);
    theme = _i1.ColumnString(
      'theme',
      this,
    );
    detailLevel = _i1.ColumnString(
      'detailLevel',
      this,
    );
    mood = _i1.ColumnString(
      'mood',
      this,
    );
    language = _i1.ColumnString(
      'language',
      this,
    );
    features = _i1.ColumnSerializable<List<String>>(
      'features',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final SettingUpdateTable updateTable;

  /// The theme or style of the AI-generated content
  late final _i1.ColumnString theme;

  /// The theme or style of the AI-generated content
  /// Level of detail or complexity
  late final _i1.ColumnString detailLevel;

  /// The theme or style of the AI-generated content
  /// Level of detail or complexity
  /// Mood or tone for content generation
  late final _i1.ColumnString mood;

  /// The theme or style of the AI-generated content
  /// Level of detail or complexity
  /// Mood or tone for content generation
  /// Language or locale
  late final _i1.ColumnString language;

  /// The theme or style of the AI-generated content
  /// Level of detail or complexity
  /// Mood or tone for content generation
  /// Language or locale
  /// List of features or options enabled
  late final _i1.ColumnSerializable<List<String>> features;

  /// The theme or style of the AI-generated content
  /// Level of detail or complexity
  /// Mood or tone for content generation
  /// Language or locale
  /// List of features or options enabled
  /// Timestamp of creation or last update
  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    theme,
    detailLevel,
    mood,
    language,
    features,
    createdAt,
  ];
}

class SettingInclude extends _i1.IncludeObject {
  SettingInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => Setting.t;
}

class SettingIncludeList extends _i1.IncludeList {
  SettingIncludeList._({
    _i1.WhereExpressionBuilder<SettingTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Setting.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => Setting.t;
}

class SettingRepository {
  const SettingRepository._();

  /// Returns a list of [Setting]s matching the given query parameters.
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
  Future<List<Setting>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<SettingTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SettingTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SettingTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<Setting>(
      where: where?.call(Setting.t),
      orderBy: orderBy?.call(Setting.t),
      orderByList: orderByList?.call(Setting.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [Setting] matching the given query parameters.
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
  Future<Setting?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<SettingTable>? where,
    int? offset,
    _i1.OrderByBuilder<SettingTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SettingTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<Setting>(
      where: where?.call(Setting.t),
      orderBy: orderBy?.call(Setting.t),
      orderByList: orderByList?.call(Setting.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [Setting] by its [id] or null if no such row exists.
  Future<Setting?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<Setting>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [Setting]s in the list and returns the inserted rows.
  ///
  /// The returned [Setting]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<Setting>> insert(
    _i1.Session session,
    List<Setting> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<Setting>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [Setting] and returns the inserted row.
  ///
  /// The returned [Setting] will have its `id` field set.
  Future<Setting> insertRow(
    _i1.Session session,
    Setting row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Setting>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Setting]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Setting>> update(
    _i1.Session session,
    List<Setting> rows, {
    _i1.ColumnSelections<SettingTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Setting>(
      rows,
      columns: columns?.call(Setting.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Setting]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Setting> updateRow(
    _i1.Session session,
    Setting row, {
    _i1.ColumnSelections<SettingTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Setting>(
      row,
      columns: columns?.call(Setting.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Setting] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Setting?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<SettingUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Setting>(
      id,
      columnValues: columnValues(Setting.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Setting]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Setting>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<SettingUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<SettingTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SettingTable>? orderBy,
    _i1.OrderByListBuilder<SettingTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Setting>(
      columnValues: columnValues(Setting.t.updateTable),
      where: where(Setting.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Setting.t),
      orderByList: orderByList?.call(Setting.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Setting]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Setting>> delete(
    _i1.Session session,
    List<Setting> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Setting>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Setting].
  Future<Setting> deleteRow(
    _i1.Session session,
    Setting row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Setting>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Setting>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<SettingTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Setting>(
      where: where(Setting.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<SettingTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Setting>(
      where: where?.call(Setting.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
