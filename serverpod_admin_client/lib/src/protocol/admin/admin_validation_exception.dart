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

/// Raised when a submitted value cannot be stored, so the dashboard can tell
/// the administrator which field to correct instead of a server error.
abstract class AdminValidationException
    implements
        _i1.SerializableException,
        _i1.SerializableModel,
        _i1.ProtocolSerialization {
  AdminValidationException._({
    this.field,
    required this.message,
  });

  factory AdminValidationException({
    String? field,
    required String message,
  }) = _AdminValidationExceptionImpl;

  factory AdminValidationException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AdminValidationException(
      field: jsonSerialization['field'] as String?,
      message: jsonSerialization['message'] as String,
    );
  }

  /// The column whose value is invalid, when it could be identified.
  String? field;

  String message;

  /// Returns a shallow copy of this [AdminValidationException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AdminValidationException copyWith({
    String? field,
    String? message,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_admin.AdminValidationException',
      if (field != null) 'field': field,
      'message': message,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_admin.AdminValidationException',
      if (field != null) 'field': field,
      'message': message,
    };
  }

  @override
  String toString() {
    return 'AdminValidationException(field: $field, message: $message)';
  }
}

class _Undefined {}

class _AdminValidationExceptionImpl extends AdminValidationException {
  _AdminValidationExceptionImpl({
    String? field,
    required String message,
  }) : super._(
         field: field,
         message: message,
       );

  /// Returns a shallow copy of this [AdminValidationException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AdminValidationException copyWith({
    Object? field = _Undefined,
    String? message,
  }) {
    return AdminValidationException(
      field: field is String? ? field : this.field,
      message: message ?? this.message,
    );
  }
}
