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

/// A custom action administrators can run on selected rows.
abstract class AdminActionInfo
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  AdminActionInfo._({
    required this.name,
    required this.label,
    required this.confirm,
    required this.destructive,
  });

  factory AdminActionInfo({
    required String name,
    required String label,
    required bool confirm,
    required bool destructive,
  }) = _AdminActionInfoImpl;

  factory AdminActionInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminActionInfo(
      name: jsonSerialization['name'] as String,
      label: jsonSerialization['label'] as String,
      confirm: _i1.BoolJsonExtension.fromJson(jsonSerialization['confirm']),
      destructive: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['destructive'],
      ),
    );
  }

  String name;

  String label;

  /// Ask before running.
  bool confirm;

  /// Shown as dangerous, like a deletion.
  bool destructive;

  /// Returns a shallow copy of this [AdminActionInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AdminActionInfo copyWith({
    String? name,
    String? label,
    bool? confirm,
    bool? destructive,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_admin.AdminActionInfo',
      'name': name,
      'label': label,
      'confirm': confirm,
      'destructive': destructive,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_admin.AdminActionInfo',
      'name': name,
      'label': label,
      'confirm': confirm,
      'destructive': destructive,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _AdminActionInfoImpl extends AdminActionInfo {
  _AdminActionInfoImpl({
    required String name,
    required String label,
    required bool confirm,
    required bool destructive,
  }) : super._(
         name: name,
         label: label,
         confirm: confirm,
         destructive: destructive,
       );

  /// Returns a shallow copy of this [AdminActionInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AdminActionInfo copyWith({
    String? name,
    String? label,
    bool? confirm,
    bool? destructive,
  }) {
    return AdminActionInfo(
      name: name ?? this.name,
      label: label ?? this.label,
      confirm: confirm ?? this.confirm,
      destructive: destructive ?? this.destructive,
    );
  }
}
