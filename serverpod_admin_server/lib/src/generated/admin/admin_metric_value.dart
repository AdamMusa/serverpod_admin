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

/// A key number on the overview, such as "Rides today".
abstract class AdminMetricValue
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  AdminMetricValue._({
    required this.label,
    required this.value,
    this.hint,
  });

  factory AdminMetricValue({
    required String label,
    required String value,
    String? hint,
  }) = _AdminMetricValueImpl;

  factory AdminMetricValue.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminMetricValue(
      label: jsonSerialization['label'] as String,
      value: jsonSerialization['value'] as String,
      hint: jsonSerialization['hint'] as String?,
    );
  }

  String label;

  String value;

  /// A short explanation or comparison.
  String? hint;

  /// Returns a shallow copy of this [AdminMetricValue]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AdminMetricValue copyWith({
    String? label,
    String? value,
    String? hint,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_admin.AdminMetricValue',
      'label': label,
      'value': value,
      if (hint != null) 'hint': hint,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_admin.AdminMetricValue',
      'label': label,
      'value': value,
      if (hint != null) 'hint': hint,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AdminMetricValueImpl extends AdminMetricValue {
  _AdminMetricValueImpl({
    required String label,
    required String value,
    String? hint,
  }) : super._(
         label: label,
         value: value,
         hint: hint,
       );

  /// Returns a shallow copy of this [AdminMetricValue]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AdminMetricValue copyWith({
    String? label,
    String? value,
    Object? hint = _Undefined,
  }) {
    return AdminMetricValue(
      label: label ?? this.label,
      value: value ?? this.value,
      hint: hint is String? ? hint : this.hint,
    );
  }
}
