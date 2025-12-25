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
import 'package:serverpod/protocol.dart' as _i2;
import 'admin/admin_column.dart' as _i3;
import 'admin/admin_resource.dart' as _i4;
import 'admin/admin_scope.dart' as _i5;
import 'module_class.dart' as _i6;
import 'package:serverpod_admin_server/src/generated/admin/admin_resource.dart'
    as _i7;
export 'admin/admin_column.dart';
export 'admin/admin_resource.dart';
export 'admin/admin_scope.dart';
export 'module_class.dart';

class Protocol extends _i1.SerializationManagerServer {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static final List<_i2.TableDefinition> targetTableDefinitions = [
    _i2.TableDefinition(
      name: 'admin_scope',
      dartName: 'AdminScope',
      schema: 'public',
      module: 'serverpod_admin',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'admin_scope_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'userId',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'isStaff',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _i2.ColumnDefinition(
          name: 'isSuperuser',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'admin_scope_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'uniq_user',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
  ];

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    if (className == null) return null;
    if (!className.startsWith('serverpod_admin.')) return className;
    return className.substring(16);
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i3.AdminColumn) {
      return _i3.AdminColumn.fromJson(data) as T;
    }
    if (t == _i4.AdminResource) {
      return _i4.AdminResource.fromJson(data) as T;
    }
    if (t == _i5.AdminScope) {
      return _i5.AdminScope.fromJson(data) as T;
    }
    if (t == _i6.ModuleClass) {
      return _i6.ModuleClass.fromJson(data) as T;
    }
    if (t == _i1.getType<_i3.AdminColumn?>()) {
      return (data != null ? _i3.AdminColumn.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.AdminResource?>()) {
      return (data != null ? _i4.AdminResource.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.AdminScope?>()) {
      return (data != null ? _i5.AdminScope.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.ModuleClass?>()) {
      return (data != null ? _i6.ModuleClass.fromJson(data) : null) as T;
    }
    if (t == List<_i3.AdminColumn>) {
      return (data as List).map((e) => deserialize<_i3.AdminColumn>(e)).toList()
          as T;
    }
    if (t == List<_i7.AdminResource>) {
      return (data as List)
              .map((e) => deserialize<_i7.AdminResource>(e))
              .toList()
          as T;
    }
    if (t == List<Map<String, String>>) {
      return (data as List)
              .map((e) => deserialize<Map<String, String>>(e))
              .toList()
          as T;
    }
    if (t == Map<String, String>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<String>(v)),
          )
          as T;
    }
    if (t == Map<String, dynamic>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<dynamic>(v)),
          )
          as T;
    }
    if (t == _i1.getType<Map<String, dynamic>?>()) {
      return (data != null
              ? (data as Map).map(
                  (k, v) =>
                      MapEntry(deserialize<String>(k), deserialize<dynamic>(v)),
                )
              : null)
          as T;
    }
    try {
      return _i2.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i3.AdminColumn => 'AdminColumn',
      _i4.AdminResource => 'AdminResource',
      _i5.AdminScope => 'AdminScope',
      _i6.ModuleClass => 'ModuleClass',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst(
        'serverpod_admin.',
        '',
      );
    }

    switch (data) {
      case _i3.AdminColumn():
        return 'AdminColumn';
      case _i4.AdminResource():
        return 'AdminResource';
      case _i5.AdminScope():
        return 'AdminScope';
      case _i6.ModuleClass():
        return 'ModuleClass';
    }
    className = _i2.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'AdminColumn') {
      return deserialize<_i3.AdminColumn>(data['data']);
    }
    if (dataClassName == 'AdminResource') {
      return deserialize<_i4.AdminResource>(data['data']);
    }
    if (dataClassName == 'AdminScope') {
      return deserialize<_i5.AdminScope>(data['data']);
    }
    if (dataClassName == 'ModuleClass') {
      return deserialize<_i6.ModuleClass>(data['data']);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _i2.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  @override
  _i1.Table? getTableForType(Type t) {
    {
      var table = _i2.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _i5.AdminScope:
        return _i5.AdminScope.t;
    }
    return null;
  }

  @override
  List<_i2.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'serverpod_admin';
}
