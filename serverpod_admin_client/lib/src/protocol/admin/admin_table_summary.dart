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
import '../admin/admin_activity_point.dart' as _i2;
import 'package:serverpod_admin_client/src/protocol/protocol.dart' as _i3;

/// A table on the overview: how many rows it has and how many it gained on
/// each recent day.
abstract class AdminTableSummary
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  AdminTableSummary._({
    required this.resourceKey,
    required this.count,
    required this.estimated,
    required this.activity,
  });

  factory AdminTableSummary({
    required String resourceKey,
    required int count,
    required bool estimated,
    required List<_i2.AdminActivityPoint> activity,
  }) = _AdminTableSummaryImpl;

  factory AdminTableSummary.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminTableSummary(
      resourceKey: jsonSerialization['resourceKey'] as String,
      count: jsonSerialization['count'] as int,
      estimated: _i1.BoolJsonExtension.fromJson(jsonSerialization['estimated']),
      activity: _i3.Protocol().deserialize<List<_i2.AdminActivityPoint>>(
        jsonSerialization['activity'],
      ),
    );
  }

  String resourceKey;

  /// The number of rows; -1 when it could not be read.
  int count;

  /// The count is Postgres's estimate, for tables too large to count on
  /// every visit.
  bool estimated;

  /// Rows added per day, oldest first, by the table's chart column; empty
  /// without one.
  List<_i2.AdminActivityPoint> activity;

  /// Returns a shallow copy of this [AdminTableSummary]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AdminTableSummary copyWith({
    String? resourceKey,
    int? count,
    bool? estimated,
    List<_i2.AdminActivityPoint>? activity,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_admin.AdminTableSummary',
      'resourceKey': resourceKey,
      'count': count,
      'estimated': estimated,
      'activity': activity.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_admin.AdminTableSummary',
      'resourceKey': resourceKey,
      'count': count,
      'estimated': estimated,
      'activity': activity.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _AdminTableSummaryImpl extends AdminTableSummary {
  _AdminTableSummaryImpl({
    required String resourceKey,
    required int count,
    required bool estimated,
    required List<_i2.AdminActivityPoint> activity,
  }) : super._(
         resourceKey: resourceKey,
         count: count,
         estimated: estimated,
         activity: activity,
       );

  /// Returns a shallow copy of this [AdminTableSummary]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AdminTableSummary copyWith({
    String? resourceKey,
    int? count,
    bool? estimated,
    List<_i2.AdminActivityPoint>? activity,
  }) {
    return AdminTableSummary(
      resourceKey: resourceKey ?? this.resourceKey,
      count: count ?? this.count,
      estimated: estimated ?? this.estimated,
      activity: activity ?? this.activity.map((e0) => e0.copyWith()).toList(),
    );
  }
}
