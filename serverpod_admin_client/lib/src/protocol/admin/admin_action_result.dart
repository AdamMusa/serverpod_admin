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

/// What a bulk change or custom action did.
abstract class AdminActionResult
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  AdminActionResult._({
    required this.affected,
    this.message,
  });

  factory AdminActionResult({
    required int affected,
    String? message,
  }) = _AdminActionResultImpl;

  factory AdminActionResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminActionResult(
      affected: jsonSerialization['affected'] as int,
      message: jsonSerialization['message'] as String?,
    );
  }

  int affected;

  String? message;

  /// Returns a shallow copy of this [AdminActionResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AdminActionResult copyWith({
    int? affected,
    String? message,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_admin.AdminActionResult',
      'affected': affected,
      if (message != null) 'message': message,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_admin.AdminActionResult',
      'affected': affected,
      if (message != null) 'message': message,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AdminActionResultImpl extends AdminActionResult {
  _AdminActionResultImpl({
    required int affected,
    String? message,
  }) : super._(
         affected: affected,
         message: message,
       );

  /// Returns a shallow copy of this [AdminActionResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AdminActionResult copyWith({
    int? affected,
    Object? message = _Undefined,
  }) {
    return AdminActionResult(
      affected: affected ?? this.affected,
      message: message is String? ? message : this.message,
    );
  }
}
