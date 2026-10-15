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
import 'package:serverpod_admin_server/src/generated/protocol.dart' as _i2;

/// A titled group of fields in the dashboard's forms and details, like a
/// Django fieldset.
abstract class AdminFieldsetInfo
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  AdminFieldsetInfo._({
    this.name,
    required this.fields,
    this.description,
    required this.collapsed,
  });

  factory AdminFieldsetInfo({
    String? name,
    required List<String> fields,
    String? description,
    required bool collapsed,
  }) = _AdminFieldsetInfoImpl;

  factory AdminFieldsetInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminFieldsetInfo(
      name: jsonSerialization['name'] as String?,
      fields: _i2.Protocol().deserialize<List<String>>(
        jsonSerialization['fields'],
      ),
      description: jsonSerialization['description'] as String?,
      collapsed: _i1.BoolJsonExtension.fromJson(jsonSerialization['collapsed']),
    );
  }

  /// Shown above the fields; an untitled group has none.
  String? name;

  /// The column names in the group, in order.
  List<String> fields;

  /// Explains the group, shown under its name.
  String? description;

  /// Starts folded, for fields rarely changed.
  bool collapsed;

  /// Returns a shallow copy of this [AdminFieldsetInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AdminFieldsetInfo copyWith({
    String? name,
    List<String>? fields,
    String? description,
    bool? collapsed,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_admin.AdminFieldsetInfo',
      if (name != null) 'name': name,
      'fields': fields.toJson(),
      if (description != null) 'description': description,
      'collapsed': collapsed,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_admin.AdminFieldsetInfo',
      if (name != null) 'name': name,
      'fields': fields.toJson(),
      if (description != null) 'description': description,
      'collapsed': collapsed,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AdminFieldsetInfoImpl extends AdminFieldsetInfo {
  _AdminFieldsetInfoImpl({
    String? name,
    required List<String> fields,
    String? description,
    required bool collapsed,
  }) : super._(
         name: name,
         fields: fields,
         description: description,
         collapsed: collapsed,
       );

  /// Returns a shallow copy of this [AdminFieldsetInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AdminFieldsetInfo copyWith({
    Object? name = _Undefined,
    List<String>? fields,
    Object? description = _Undefined,
    bool? collapsed,
  }) {
    return AdminFieldsetInfo(
      name: name is String? ? name : this.name,
      fields: fields ?? this.fields.map((e0) => e0).toList(),
      description: description is String? ? description : this.description,
      collapsed: collapsed ?? this.collapsed,
    );
  }
}
