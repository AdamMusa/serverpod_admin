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

/// What the signed-in user may do in the dashboard.
abstract class AdminAccessInfo
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  AdminAccessInfo._({
    required this.allowed,
    required this.admin,
  });

  factory AdminAccessInfo({
    required bool allowed,
    required bool admin,
  }) = _AdminAccessInfoImpl;

  factory AdminAccessInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminAccessInfo(
      allowed: _i1.BoolJsonExtension.fromJson(jsonSerialization['allowed']),
      admin: _i1.BoolJsonExtension.fromJson(jsonSerialization['admin']),
    );
  }

  /// May open the dashboard at all.
  bool allowed;

  /// Has the admin scope: may do everything.
  bool admin;

  /// Returns a shallow copy of this [AdminAccessInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AdminAccessInfo copyWith({
    bool? allowed,
    bool? admin,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_admin.AdminAccessInfo',
      'allowed': allowed,
      'admin': admin,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_admin.AdminAccessInfo',
      'allowed': allowed,
      'admin': admin,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _AdminAccessInfoImpl extends AdminAccessInfo {
  _AdminAccessInfoImpl({
    required bool allowed,
    required bool admin,
  }) : super._(
         allowed: allowed,
         admin: admin,
       );

  /// Returns a shallow copy of this [AdminAccessInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AdminAccessInfo copyWith({
    bool? allowed,
    bool? admin,
  }) {
    return AdminAccessInfo(
      allowed: allowed ?? this.allowed,
      admin: admin ?? this.admin,
    );
  }
}
