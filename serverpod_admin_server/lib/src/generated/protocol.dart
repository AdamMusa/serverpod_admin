/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;
import 'package:serverpod/protocol.dart' as _i2;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i3;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i4;
import 'admin/admin_column.dart' as _i5;
import 'admin/admin_filter.dart' as _i6;
import 'admin/admin_filter_operator.dart' as _i7;
import 'admin/admin_page.dart' as _i8;
import 'admin/admin_query.dart' as _i9;
import 'admin/admin_resource.dart' as _i10;
import 'admin/admin_validation_exception.dart' as _i11;
import 'module_class.dart' as _i12;
import 'package:serverpod_admin_server/src/generated/admin/admin_resource.dart'
    as _i13;
export 'admin/admin_column.dart';
export 'admin/admin_filter.dart';
export 'admin/admin_filter_operator.dart';
export 'admin/admin_page.dart';
export 'admin/admin_query.dart';
export 'admin/admin_resource.dart';
export 'admin/admin_validation_exception.dart';
export 'module_class.dart';

class Protocol extends _i1.DatabaseSerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static final List<_i2.TableDefinition> targetTableDefinitions = [
    ..._i3.Protocol.targetTableDefinitions,
    ..._i4.Protocol.targetTableDefinitions,
  ];

  final Set<_i1.SerializationManager> _hostProtocols = {};

  void registerHostProtocol(
    String projectName,
    _i1.SerializationManager protocol,
  ) {
    _hostProtocols.add(protocol);
  }

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

    if (t == _i5.AdminColumn) {
      return _i5.AdminColumn.fromJson(data) as T;
    }
    if (t == _i6.AdminFilter) {
      return _i6.AdminFilter.fromJson(data) as T;
    }
    if (t == _i7.AdminFilterOperator) {
      return _i7.AdminFilterOperator.fromJson(data) as T;
    }
    if (t == _i8.AdminPage) {
      return _i8.AdminPage.fromJson(data) as T;
    }
    if (t == _i9.AdminQuery) {
      return _i9.AdminQuery.fromJson(data) as T;
    }
    if (t == _i10.AdminResource) {
      return _i10.AdminResource.fromJson(data) as T;
    }
    if (t == _i11.AdminValidationException) {
      return _i11.AdminValidationException.fromJson(data) as T;
    }
    if (t == _i12.ModuleClass) {
      return _i12.ModuleClass.fromJson(data) as T;
    }
    if (t == _i1.getType<_i5.AdminColumn?>()) {
      return (data != null ? _i5.AdminColumn.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.AdminFilter?>()) {
      return (data != null ? _i6.AdminFilter.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.AdminFilterOperator?>()) {
      return (data != null ? _i7.AdminFilterOperator.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i8.AdminPage?>()) {
      return (data != null ? _i8.AdminPage.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.AdminQuery?>()) {
      return (data != null ? _i9.AdminQuery.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.AdminResource?>()) {
      return (data != null ? _i10.AdminResource.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.AdminValidationException?>()) {
      return (data != null
              ? _i11.AdminValidationException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i12.ModuleClass?>()) {
      return (data != null ? _i12.ModuleClass.fromJson(data) : null) as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == _i1.getType<List<String>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<String>(e)).toList()
              : null)
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
    if (t == List<_i6.AdminFilter>) {
      return (data as List).map((e) => deserialize<_i6.AdminFilter>(e)).toList()
          as T;
    }
    if (t == List<_i5.AdminColumn>) {
      return (data as List).map((e) => deserialize<_i5.AdminColumn>(e)).toList()
          as T;
    }
    if (t == List<_i13.AdminResource>) {
      return (data as List)
              .map((e) => deserialize<_i13.AdminResource>(e))
              .toList()
          as T;
    }
    if (t == Map<String, String>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<String>(v)),
          )
          as T;
    }
    if (t == List<Map<String, String>>) {
      return (data as List)
              .map((e) => deserialize<Map<String, String>>(e))
              .toList()
          as T;
    }
    if (t == Map<String, dynamic>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<dynamic>(v)),
          )
          as T;
    }
    if (t == dynamic) {
      return deserializeDynamicFieldValue(data) as T;
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
      return _i3.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i4.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i2.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i5.AdminColumn => 'AdminColumn',
      _i6.AdminFilter => 'AdminFilter',
      _i7.AdminFilterOperator => 'AdminFilterOperator',
      _i8.AdminPage => 'AdminPage',
      _i9.AdminQuery => 'AdminQuery',
      _i10.AdminResource => 'AdminResource',
      _i11.AdminValidationException => 'AdminValidationException',
      _i12.ModuleClass => 'ModuleClass',
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
      case _i5.AdminColumn():
        return 'AdminColumn';
      case _i6.AdminFilter():
        return 'AdminFilter';
      case _i7.AdminFilterOperator():
        return 'AdminFilterOperator';
      case _i8.AdminPage():
        return 'AdminPage';
      case _i9.AdminQuery():
        return 'AdminQuery';
      case _i10.AdminResource():
        return 'AdminResource';
      case _i11.AdminValidationException():
        return 'AdminValidationException';
      case _i12.ModuleClass():
        return 'ModuleClass';
    }
    className = _i2.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.') ? className : 'serverpod.$className';
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
      return deserialize<_i5.AdminColumn>(data['data']);
    }
    if (dataClassName == 'AdminFilter') {
      return deserialize<_i6.AdminFilter>(data['data']);
    }
    if (dataClassName == 'AdminFilterOperator') {
      return deserialize<_i7.AdminFilterOperator>(data['data']);
    }
    if (dataClassName == 'AdminPage') {
      return deserialize<_i8.AdminPage>(data['data']);
    }
    if (dataClassName == 'AdminQuery') {
      return deserialize<_i9.AdminQuery>(data['data']);
    }
    if (dataClassName == 'AdminResource') {
      return deserialize<_i10.AdminResource>(data['data']);
    }
    if (dataClassName == 'AdminValidationException') {
      return deserialize<_i11.AdminValidationException>(data['data']);
    }
    if (dataClassName == 'ModuleClass') {
      return deserialize<_i12.ModuleClass>(data['data']);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _i2.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  @override
  Object? dynamicFieldToJson(
    Object? object, {
    bool forProtocol = false,
  }) {
    if ((object is List || object is Set || object is Map) ||
        getClassNameForObject(object) != null) {
      return super.dynamicFieldToJson(object, forProtocol: forProtocol);
    }
    for (final protocol in _hostProtocols) {
      final className = protocol.getClassNameForObject(object);
      if (className == null) continue;
      final host = protocol.getModuleName();
      final wrapped = {
        'className': className.contains('.') ? className : '$host.$className',
        'data': object,
      };
      return forProtocol
          ? _i1.SerializationManager.toEncodableForProtocol(wrapped)
          : _i1.SerializationManager.toEncodable(wrapped);
    }
    return super.dynamicFieldToJson(object, forProtocol: forProtocol);
  }

  @override
  dynamic deserializeDynamicFieldValue(Object? value) {
    if (value == null) return null;
    if (value is! Map<String, dynamic> || value['className'] is! String) {
      throw FormatException(
        'Dynamic fields are encoded as a Map with className and data, but got '
        '${value.runtimeType} instead.',
      );
    }
    final className = value['className'] as String;
    for (final protocol in _hostProtocols) {
      final host = protocol.getModuleName();
      final hostPrefix = '$host.';
      if (className.startsWith(hostPrefix)) {
        final strippedClassName = className.substring(hostPrefix.length);
        if (strippedClassName.contains('.')) {
          throw FormatException(
            'Dynamic field className must not use multiple prefixes: $className',
          );
        }
        final hostData = Map<String, dynamic>.from(value);
        hostData['className'] = strippedClassName;
        return protocol.deserializeByClassName(hostData);
      }
    }
    if (className.contains('.')) {
      for (final protocol in _hostProtocols) {
        try {
          return protocol.deserializeByClassName(value);
        } on FormatException catch (_) {}
      }
    }
    return deserializeByClassName(value);
  }

  @override
  _i1.Table? getTableForType(Type t) {
    {
      var table = _i3.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _i4.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _i2.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    return null;
  }

  @override
  List<_i2.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'serverpod_admin';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _i3.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i4.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
