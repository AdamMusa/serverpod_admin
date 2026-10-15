import 'package:serverpod/serverpod.dart';
import 'package:serverpod/protocol.dart' show TableDefinition;
import 'package:serverpod_admin_server/serverpod_admin_server.dart';
import 'package:serverpod_admin_server/src/admin/admin_auth_user_link.dart';
import 'package:serverpod_admin_server/src/admin/admin_query_engine.dart';
import 'package:serverpod_admin_server/src/admin/admin_enum_values.dart';
import 'package:serverpod_admin_server/src/admin/admin_entry_base.dart';

class AdminEntry<T extends TableRow> extends AdminEntryBase {
  AdminEntry({
    Table? table,
    T Function(JsonMap json)? fromJson,
    required Future<List<T>> Function(Session session) listRows,
    required Future<T?> Function(Session session, Object id) findRowById,
    required Future<T> Function(Session session, T row) createRow,
    required Future<T> Function(Session session, T row) updateRow,
    required Future<void> Function(Session session, Object id) deleteById,
    String? resourceKey,
    Map<String, List<String>>? choices,
    String? authUserColumn,
    bool queryable = false,
    List<AdminAction<T>> actions = const [],
    AdminOptions options = const AdminOptions(),
    T Function(Session session, T row)? present,
  }) : _options = options,
       _actions = actions,
       _queryable = queryable,
       _present = present,
       _choices = choices,
       _authUserColumn = authUserColumn,
       _table = table,
       _fromJson = fromJson,
       _listRows = listRows,
       _findRowById = findRowById,
       _createRow = createRow,
       _updateRow = updateRow,
       _deleteById = deleteById,
       _resourceKeyOverride = resourceKey;

  Table? _table;
  T Function(JsonMap json)? _fromJson;
  final Future<List<T>> Function(Session session) _listRows;
  final Future<T?> Function(Session session, Object id) _findRowById;
  final Future<T> Function(Session session, T row) _createRow;
  final Future<T> Function(Session session, T row) _updateRow;
  final Future<void> Function(Session session, Object id) _deleteById;
  final String? _resourceKeyOverride;
  final Map<String, List<String>>? _choices;
  final String? _authUserColumn;
  final bool _queryable;
  final List<AdminAction<T>> _actions;
  final AdminOptions _options;

  @override
  AdminOptions get options => _options;
  final T Function(Session session, T row)? _present;
  List<AdminColumn>? _adminColumns;
  AdminResource? _metadataCache;

  @override
  Type get type => T;

  @override
  String get resourceKey => _resourceKeyOverride ?? _resolvedTable.tableName;

  @override
  String get tableName => _resolvedTable.tableName;

  @override
  Table get table => _resolvedTable;

  @override
  List<Column> get columns => _resolvedTable.columns;

  @override
  AdminResource get metadata => _metadataCache ??= _buildMetadata();

  AdminResource _buildMetadata() {
    final columns = [
      for (final column in [
        ..._resolvedAdminColumns,
        ...?authUserLink?.columns,
      ])
        if (!_options.hidden.contains(column.name))
          column.copyWith(
            label: _options.labels[column.name],
            help: _options.help[column.name],
            readOnly: _options.readOnly.contains(column.name) ? true : null,
          ),
    ];
    return AdminResource(
      key: resourceKey,
      tableName: tableName,
      columns: columns,
      actions: _actions.isEmpty ? null : actionInfos,
      label: _options.label,
      group: _options.group,
      listColumns: _options.listColumns,
      sortColumn: _options.ordering,
      sortDescending: _options.ordering == null ? null : _options.descending,
      canCreate: _options.canCreate ? null : false,
      canEdit: _options.canEdit ? null : false,
      canDelete: _options.canDelete ? null : false,
      chartColumn: _options.chartColumn ?? _detectChartColumn(columns),
      fieldsets: _resolveFieldsets(columns),
    );
  }

  /// The table's fieldsets with only the columns the dashboard sees, each
  /// column once, and the columns no group names in a last "Other" group.
  List<AdminFieldsetInfo>? _resolveFieldsets(List<AdminColumn> columns) {
    final fieldsets = _options.fieldsets;
    if (fieldsets == null) return null;
    final known = {for (final column in columns) column.name};
    final placed = <String>{};
    final resolved = [
      for (final fieldset in fieldsets)
        fieldset.info.copyWith(
          fields: [
            for (final name in fieldset.fields)
              if (known.contains(name) && placed.add(name)) name,
          ],
        ),
    ]..removeWhere((fieldset) => fieldset.fields.isEmpty);
    final rest = [
      for (final column in columns)
        if (!column.isPrimary && !placed.contains(column.name)) column.name,
    ];
    return [
      ...resolved,
      if (rest.isNotEmpty)
        AdminFieldsetInfo(name: 'Other', fields: rest, collapsed: false),
    ];
  }

  static const _chartNames = [
    'createdAt',
    'requestedAt',
    'insertedAt',
    'addedAt',
    'addedTime',
    'created',
    'time',
  ];

  static String? _detectChartColumn(List<AdminColumn> columns) {
    for (final name in _chartNames) {
      final column = columns.where((c) => c.name == name).firstOrNull;
      if (column != null && column.dataType.toLowerCase().contains('date')) {
        return name;
      }
    }
    return null;
  }

  @override
  List<AdminActionInfo> get actionInfos => [
    for (final action in _actions) action.info,
  ];

  @override
  Future<String?> runAction(
    Session session,
    String name,
    List<Object> ids,
  ) async {
    final action = _actions.where((a) => a.name == name).firstOrNull;
    if (action == null) {
      throw AdminValidationException(message: 'Unknown action $name.');
    }
    final rows = <T>[];
    for (final id in ids) {
      // Actions see rows as stored, not as presented to the dashboard.
      final row = _queryable
          // ignore: invalid_use_of_internal_member
          ? await session.db.findById<T>(_rowId(id))
          : await _findRowById(session, _rowId(id));
      if (row != null) rows.add(row);
    }
    return action.run(session, rows);
  }

  @override
  late final AdminAuthUserLink? authUserLink = _resolveAuthUserLink();

  @override
  Future<({List<JsonMap> rows, int total})?> queryPage(
    Session session,
    AdminQuery query,
  ) async {
    if (!_queryable) return null;
    final sql = AdminSqlQuery.build(
      _resolvedTable,
      metadata.columns,
      query,
      searchColumns: _options.searchColumns,
      defaultSort: _options.ordering,
      defaultDescending: _options.ordering == null || _options.descending,
      authUserColumn: authUserLink?.column,
    );
    if (sql == null) return null;
    // ignore: invalid_use_of_internal_member
    final rows = await session.db.find<T>(
      where: sql.where,
      orderByList: sql.orderBy,
      limit: query.limit,
      offset: query.offset,
    );
    // A page that is not full holds the last matching rows, so they need no
    // count.
    final last =
        rows.length < query.limit && (rows.isNotEmpty || query.offset == 0);
    final total = last
        ? query.offset + rows.length
        : query.countTotal == false
        ? -1
        // ignore: invalid_use_of_internal_member
        : await session.db.count<T>(where: sql.where);
    return (
      rows: [
        for (final row in rows) toJson(_present?.call(session, row) ?? row),
      ],
      total: total,
    );
  }

  @override
  TableRow fromJson(JsonMap json) => _resolvedFromJson(json);

  @override
  JsonMap toJson(TableRow row) => (row as T).toJson();

  @override
  Future<List<TableRow>> listRows(Session session) async {
    if (_queryable) {
      // ignore: invalid_use_of_internal_member
      final rows = await session.db.find<T>(orderByList: _defaultOrder);
      return [for (final row in rows) _present?.call(session, row) ?? row];
    }
    final rows = await _listRows(session);
    return rows.cast<TableRow>();
  }

  /// The table's ordering option, newest first without one.
  List<Column> get _defaultOrder {
    final table = _resolvedTable;
    final name = _options.ordering;
    final column = table.columns.where((c) => c.columnName == name).firstOrNull;
    if (column == null) return [table.id.desc()];
    return [
      _options.descending ? column.desc() : column.asc(),
      if (column != table.id) table.id.desc(),
    ];
  }

  @override
  Future<TableRow?> findRowById(Session session, Object id) async {
    final row = await _findRowById(session, _rowId(id));
    return row;
  }

  @override
  Future<TableRow> createRow(Session session, TableRow row) async {
    final created = await _createRow(session, row as T);
    return created;
  }

  @override
  Future<TableRow> updateRow(Session session, TableRow row) async {
    final updated = await _updateRow(session, row as T);
    return updated;
  }

  @override
  Future<void> deleteById(Session session, Object id) async {
    await _deleteById(session, _rowId(id));
  }

  /// [id] as the table's key type: ids arrive as text from the dashboard,
  /// and UUID keys are looked up as UuidValue.
  Object _rowId(Object id) {
    if (_resolvedTable.id is ColumnUuid && id is String) {
      try {
        return UuidValue.withValidation(id);
      } on FormatException {
        throw AdminValidationException(message: '$id is not a valid id.');
      }
    }
    return id;
  }

  Table get _resolvedTable {
    return _table ??= _inferTableForType<T>();
  }

  T Function(JsonMap json) get _resolvedFromJson {
    return _fromJson ??= _inferFromJsonForType<T>();
  }

  List<AdminColumn> get _resolvedAdminColumns {
    if (_adminColumns != null) return _adminColumns!;

    final foreignKeyMap = _buildForeignKeyMap();

    final tableDefinition = _findTableDefinition();

    return _adminColumns = _resolvedTable.columns
        .map((column) {
          final columnDefinition = tableDefinition?.columns
              .where((definition) => definition.name == column.columnName)
              .firstOrNull;
          final enumMetadata = _resolveEnumMetadata(
            column,
            dartType: columnDefinition?.dartType,
            moduleName: tableDefinition?.module,
          );

          return AdminColumn(
            name: column.columnName,
            dataType: column.type.toString(),
            hasDefault: column.hasDefault,
            isPrimary: identical(column, _resolvedTable.id),
            foreignKeyTable: foreignKeyMap[column.columnName],
            enumValues: enumMetadata?.values,
            enumSerializedByName: enumMetadata?.serializedByName,
            isNullable: columnDefinition?.isNullable,
            choices: _choices?[column.columnName],
          );
        })
        .toList(growable: false);
  }

  AdminAuthUserLink? _resolveAuthUserLink() {
    final definition = _findTableDefinition();
    final column =
        _authUserColumn ??
        (definition == null ? null : AdminAuthUserLink.detect(definition));
    return column == null ? null : AdminAuthUserLink(column);
  }

  TableDefinition? _findTableDefinition() {
    final tableName = _resolvedTable.tableName;
    return Serverpod.instance.serializationManager
        .getTargetTableDefinitions()
        .where((definition) => definition.name == tableName)
        .firstOrNull;
  }

  _AdminEnumMetadata? _resolveEnumMetadata(
    Column column, {
    String? dartType,
    String? moduleName,
  }) {
    if (column is! ColumnEnum) return null;

    final serializedByName =
        column is ColumnEnumExtended &&
        column.serialized == EnumSerialization.byName;
    final registeredValues = AdminRegistry().enumValuesFor(column.type);
    if (registeredValues != null) {
      return _AdminEnumMetadata(
        values: registeredValues,
        serializedByName: serializedByName,
      );
    }
    final reflectedValues = discoverAdminEnumValues(
      column.type,
      enumName: dartType,
    );
    final values = reflectedValues.isNotEmpty
        ? reflectedValues
        : serializedByName
        ? const <String>[]
        : _discoverIndexSerializedEnumValues(
            column,
            dartType: dartType,
            moduleName: moduleName,
          );
    return _AdminEnumMetadata(
      values: values.isEmpty ? null : values,
      serializedByName: serializedByName,
    );
  }

  List<String> _discoverIndexSerializedEnumValues(
    Column column, {
    String? dartType,
    String? moduleName,
  }) {
    final serializationManager = Serverpod.instance.serializationManager;
    final classNames = _enumClassNames(dartType, column.type, moduleName);

    for (final className in classNames) {
      final values = <String>[];
      for (var index = 0; index < 1024; index++) {
        try {
          final value = serializationManager.deserializeByClassName({
            'className': className,
            'data': index,
          });
          if (value is! Enum || value.runtimeType != column.type) break;
          values.add(value.name);
        } catch (_) {
          break;
        }
      }
      if (values.isNotEmpty) return List.unmodifiable(values);
    }

    return const [];
  }

  List<String> _enumClassNames(
    String? dartType,
    Type fallbackType,
    String? moduleName,
  ) {
    final normalized = dartType?.replaceAll('?', '');
    if (normalized == null || normalized.isEmpty) {
      final className = fallbackType.toString();
      final tableName = _resolvedTable.tableName;
      final inferredModule = tableName.startsWith('serverpod_auth_core_')
          ? 'serverpod_auth_core'
          : tableName.startsWith('serverpod_auth_idp_')
          ? 'serverpod_auth_idp'
          : tableName.startsWith('serverpod_')
          ? 'serverpod'
          : null;
      return [
        className,
        if (inferredModule != null) '$inferredModule.$className',
      ];
    }
    if (normalized.startsWith('protocol:')) {
      final className = normalized.substring('protocol:'.length);
      return [moduleName == null ? className : '$moduleName.$className'];
    }
    return [normalized.replaceFirst(':', '.')];
  }

  /// Builds a map from column names to their referenced foreign key tables.
  /// Only single-column foreign keys are supported.
  Map<String, String> _buildForeignKeyMap() {
    final pod = Serverpod.instance;
    final tableDefs = pod.serializationManager.getTargetTableDefinitions();
    final tableName = _resolvedTable.tableName;

    // In test mode, allow tables that aren't in the protocol
    // This allows testing with in-memory storage without requiring protocol registration
    if (pod.runMode == 'test') {
      try {
        final tableDef = tableDefs.firstWhere((def) => def.name == tableName);
        final foreignKeyMap = <String, String>{};
        for (final fk in tableDef.foreignKeys) {
          // Only support single-column foreign keys for now
          if (fk.columns.length == 1) {
            final columnName = fk.columns.first;
            foreignKeyMap[columnName] = fk.referenceTable;
          }
        }
        return foreignKeyMap;
      } catch (e) {
        // Table not in protocol - return empty map for tests
        return <String, String>{};
      }
    }

    final tableDef = tableDefs.firstWhere(
      (def) => def.name == tableName,
      orElse: () => throw StateError(
        'serverpod_admin: Table definition not found for "$tableName". '
        'Ensure the table is properly registered in your Serverpod server.',
      ),
    );

    final foreignKeyMap = <String, String>{};
    for (final fk in tableDef.foreignKeys) {
      // Only support single-column foreign keys for now
      if (fk.columns.length == 1) {
        final columnName = fk.columns.first;
        foreignKeyMap[columnName] = fk.referenceTable;
      }
    }

    return foreignKeyMap;
  }
}

class _AdminEnumMetadata {
  const _AdminEnumMetadata({
    required this.values,
    required this.serializedByName,
  });

  final List<String>? values;
  final bool serializedByName;
}

Table _inferTableForType<T extends TableRow>() {
  final pod = Serverpod.instance;
  final table = pod.serializationManager.getTableForType(T);
  if (table == null) {
    throw StateError(
      'serverpod_admin: Unable to resolve table metadata for $T. '
      'Pass the table parameter to registry.register to configure this type.',
    );
  }
  return table;
}

T Function(JsonMap json) _inferFromJsonForType<T extends TableRow>() {
  final pod = Serverpod.instance;
  return (json) => pod.serializationManager.deserialize<T>(json);
}
