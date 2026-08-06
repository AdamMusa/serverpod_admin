import 'package:serverpod/serverpod.dart';
import 'package:serverpod/protocol.dart' show TableDefinition;
import 'package:serverpod_admin_server/serverpod_admin_server.dart';
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
  }) : _table = table,
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
  AdminResource get metadata => _metadataCache ??= AdminResource(
    key: resourceKey,
    tableName: tableName,
    columns: _resolvedAdminColumns,
  );

  @override
  TableRow fromJson(JsonMap json) => _resolvedFromJson(json);

  @override
  JsonMap toJson(TableRow row) => (row as T).toJson();

  @override
  Future<List<TableRow>> listRows(Session session) async {
    final rows = await _listRows(session);
    return rows.cast<TableRow>();
  }

  @override
  Future<TableRow?> findRowById(Session session, Object id) async {
    final row = await _findRowById(session, id);
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
    await _deleteById(session, id);
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
          );
        })
        .toList(growable: false);
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
