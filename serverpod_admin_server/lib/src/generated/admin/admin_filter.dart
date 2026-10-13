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
import '../admin/admin_filter_operator.dart' as _i2;

/// One condition on a column, for example `status equals approved`.
abstract class AdminFilter
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  AdminFilter._({
    required this.column,
    required this.comparison,
    this.value,
  });

  factory AdminFilter({
    required String column,
    required _i2.AdminFilterOperator comparison,
    String? value,
  }) = _AdminFilterImpl;

  factory AdminFilter.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminFilter(
      column: jsonSerialization['column'] as String,
      comparison: _i2.AdminFilterOperator.fromJson(
        (jsonSerialization['comparison'] as String),
      ),
      value: jsonSerialization['value'] as String?,
    );
  }

  String column;

  _i2.AdminFilterOperator comparison;

  /// The value as the dashboard shows it; unused by isEmpty and isNotEmpty.
  String? value;

  /// Returns a shallow copy of this [AdminFilter]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AdminFilter copyWith({
    String? column,
    _i2.AdminFilterOperator? comparison,
    String? value,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_admin.AdminFilter',
      'column': column,
      'comparison': comparison.toJson(),
      if (value != null) 'value': value,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_admin.AdminFilter',
      'column': column,
      'comparison': comparison.toJson(),
      if (value != null) 'value': value,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AdminFilterImpl extends AdminFilter {
  _AdminFilterImpl({
    required String column,
    required _i2.AdminFilterOperator comparison,
    String? value,
  }) : super._(
         column: column,
         comparison: comparison,
         value: value,
       );

  /// Returns a shallow copy of this [AdminFilter]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AdminFilter copyWith({
    String? column,
    _i2.AdminFilterOperator? comparison,
    Object? value = _Undefined,
  }) {
    return AdminFilter(
      column: column ?? this.column,
      comparison: comparison ?? this.comparison,
      value: value is String? ? value : this.value,
    );
  }
}
