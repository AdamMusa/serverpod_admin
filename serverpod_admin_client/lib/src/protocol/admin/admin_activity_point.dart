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

/// How many rows a table gained on one day, for overview charts.
abstract class AdminActivityPoint
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  AdminActivityPoint._({
    required this.day,
    required this.count,
  });

  factory AdminActivityPoint({
    required DateTime day,
    required int count,
  }) = _AdminActivityPointImpl;

  factory AdminActivityPoint.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminActivityPoint(
      day: _i1.DateTimeJsonExtension.fromJson(jsonSerialization['day']),
      count: jsonSerialization['count'] as int,
    );
  }

  DateTime day;

  int count;

  /// Returns a shallow copy of this [AdminActivityPoint]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AdminActivityPoint copyWith({
    DateTime? day,
    int? count,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_admin.AdminActivityPoint',
      'day': day.toJson(),
      'count': count,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_admin.AdminActivityPoint',
      'day': day.toJson(),
      'count': count,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _AdminActivityPointImpl extends AdminActivityPoint {
  _AdminActivityPointImpl({
    required DateTime day,
    required int count,
  }) : super._(
         day: day,
         count: count,
       );

  /// Returns a shallow copy of this [AdminActivityPoint]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AdminActivityPoint copyWith({
    DateTime? day,
    int? count,
  }) {
    return AdminActivityPoint(
      day: day ?? this.day,
      count: count ?? this.count,
    );
  }
}
