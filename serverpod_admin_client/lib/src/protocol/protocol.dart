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
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'admin/admin_column.dart' as _i2;
import 'admin/admin_resource.dart' as _i3;
import 'admin/admin_response.dart' as _i4;
import 'module_class.dart' as _i5;
import 'package:serverpod_admin_client/src/protocol/admin/admin_resource.dart'
    as _i6;
export 'admin/admin_column.dart';
export 'admin/admin_resource.dart';
export 'admin/admin_response.dart';
export 'module_class.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

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

    if (t == _i2.AdminColumn) {
      return _i2.AdminColumn.fromJson(data) as T;
    }
    if (t == _i3.AdminResource) {
      return _i3.AdminResource.fromJson(data) as T;
    }
    if (t == _i4.AdminResponse) {
      return _i4.AdminResponse.fromJson(data) as T;
    }
    if (t == _i5.ModuleClass) {
      return _i5.ModuleClass.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.AdminColumn?>()) {
      return (data != null ? _i2.AdminColumn.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.AdminResource?>()) {
      return (data != null ? _i3.AdminResource.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.AdminResponse?>()) {
      return (data != null ? _i4.AdminResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.ModuleClass?>()) {
      return (data != null ? _i5.ModuleClass.fromJson(data) : null) as T;
    }
    if (t == List<_i2.AdminColumn>) {
      return (data as List).map((e) => deserialize<_i2.AdminColumn>(e)).toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i6.AdminResource>) {
      return (data as List)
              .map((e) => deserialize<_i6.AdminResource>(e))
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
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.AdminColumn => 'AdminColumn',
      _i3.AdminResource => 'AdminResource',
      _i4.AdminResponse => 'AdminResponse',
      _i5.ModuleClass => 'ModuleClass',
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
      case _i2.AdminColumn():
        return 'AdminColumn';
      case _i3.AdminResource():
        return 'AdminResource';
      case _i4.AdminResponse():
        return 'AdminResponse';
      case _i5.ModuleClass():
        return 'ModuleClass';
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
      return deserialize<_i2.AdminColumn>(data['data']);
    }
    if (dataClassName == 'AdminResource') {
      return deserialize<_i3.AdminResource>(data['data']);
    }
    if (dataClassName == 'AdminResponse') {
      return deserialize<_i4.AdminResponse>(data['data']);
    }
    if (dataClassName == 'ModuleClass') {
      return deserialize<_i5.ModuleClass>(data['data']);
    }
    return super.deserializeByClassName(data);
  }
}
