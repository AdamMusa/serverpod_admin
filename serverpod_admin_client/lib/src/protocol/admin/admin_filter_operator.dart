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

/// How an [AdminFilter] compares a column with its value.
enum AdminFilterOperator implements _i1.SerializableModel {
  equals,
  notEquals,
  contains,
  greaterOrEqual,
  lessOrEqual,
  isEmpty,
  isNotEmpty,

  /// Any of the comma-separated values.
  oneOf
  ;

  static AdminFilterOperator fromJson(String name) {
    switch (name) {
      case 'equals':
        return AdminFilterOperator.equals;
      case 'notEquals':
        return AdminFilterOperator.notEquals;
      case 'contains':
        return AdminFilterOperator.contains;
      case 'greaterOrEqual':
        return AdminFilterOperator.greaterOrEqual;
      case 'lessOrEqual':
        return AdminFilterOperator.lessOrEqual;
      case 'isEmpty':
        return AdminFilterOperator.isEmpty;
      case 'isNotEmpty':
        return AdminFilterOperator.isNotEmpty;
      case 'oneOf':
        return AdminFilterOperator.oneOf;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "AdminFilterOperator"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
