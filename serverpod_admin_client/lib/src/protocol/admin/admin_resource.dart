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
import '../admin/admin_column.dart' as _i2;
import '../admin/admin_action_info.dart' as _i3;
import 'package:serverpod_admin_client/src/protocol/protocol.dart' as _i4;

abstract class AdminResource
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  AdminResource._({
    required this.key,
    required this.tableName,
    required this.columns,
    this.actions,
  });

  factory AdminResource({
    required String key,
    required String tableName,
    required List<_i2.AdminColumn> columns,
    List<_i3.AdminActionInfo>? actions,
  }) = _AdminResourceImpl;

  factory AdminResource.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminResource(
      key: jsonSerialization['key'] as String,
      tableName: jsonSerialization['tableName'] as String,
      columns: _i4.Protocol().deserialize<List<_i2.AdminColumn>>(
        jsonSerialization['columns'],
      ),
      actions: jsonSerialization['actions'] == null
          ? null
          : _i4.Protocol().deserialize<List<_i3.AdminActionInfo>>(
              jsonSerialization['actions'],
            ),
    );
  }

  String key;

  String tableName;

  List<_i2.AdminColumn> columns;

  /// Custom actions for selected rows.
  List<_i3.AdminActionInfo>? actions;

  /// Returns a shallow copy of this [AdminResource]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AdminResource copyWith({
    String? key,
    String? tableName,
    List<_i2.AdminColumn>? columns,
    List<_i3.AdminActionInfo>? actions,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_admin.AdminResource',
      'key': key,
      'tableName': tableName,
      'columns': columns.toJson(valueToJson: (v) => v.toJson()),
      if (actions != null)
        'actions': actions?.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_admin.AdminResource',
      'key': key,
      'tableName': tableName,
      'columns': columns.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      if (actions != null)
        'actions': actions?.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AdminResourceImpl extends AdminResource {
  _AdminResourceImpl({
    required String key,
    required String tableName,
    required List<_i2.AdminColumn> columns,
    List<_i3.AdminActionInfo>? actions,
  }) : super._(
         key: key,
         tableName: tableName,
         columns: columns,
         actions: actions,
       );

  /// Returns a shallow copy of this [AdminResource]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AdminResource copyWith({
    String? key,
    String? tableName,
    List<_i2.AdminColumn>? columns,
    Object? actions = _Undefined,
  }) {
    return AdminResource(
      key: key ?? this.key,
      tableName: tableName ?? this.tableName,
      columns: columns ?? this.columns.map((e0) => e0.copyWith()).toList(),
      actions: actions is List<_i3.AdminActionInfo>?
          ? actions
          : this.actions?.map((e0) => e0.copyWith()).toList(),
    );
  }
}
