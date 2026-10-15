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
import 'package:serverpod_admin_client/src/protocol/protocol.dart' as _i2;

/// Rows of a table that point at a record through one of its foreign keys.
abstract class AdminRelatedRows
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  AdminRelatedRows._({
    required this.resourceKey,
    required this.column,
    required this.rows,
    required this.total,
  });

  factory AdminRelatedRows({
    required String resourceKey,
    required String column,
    required List<Map<String, String>> rows,
    required int total,
  }) = _AdminRelatedRowsImpl;

  factory AdminRelatedRows.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminRelatedRows(
      resourceKey: jsonSerialization['resourceKey'] as String,
      column: jsonSerialization['column'] as String,
      rows: _i2.Protocol().deserialize<List<Map<String, String>>>(
        jsonSerialization['rows'],
      ),
      total: jsonSerialization['total'] as int,
    );
  }

  String resourceKey;

  /// The foreign key column holding the record's id.
  String column;

  /// The first rows, with the columns asked for.
  List<Map<String, String>> rows;

  /// How many rows point at the record.
  int total;

  /// Returns a shallow copy of this [AdminRelatedRows]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AdminRelatedRows copyWith({
    String? resourceKey,
    String? column,
    List<Map<String, String>>? rows,
    int? total,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_admin.AdminRelatedRows',
      'resourceKey': resourceKey,
      'column': column,
      'rows': rows.toJson(valueToJson: (v) => v.toJson()),
      'total': total,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_admin.AdminRelatedRows',
      'resourceKey': resourceKey,
      'column': column,
      'rows': rows.toJson(valueToJson: (v) => v.toJson()),
      'total': total,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _AdminRelatedRowsImpl extends AdminRelatedRows {
  _AdminRelatedRowsImpl({
    required String resourceKey,
    required String column,
    required List<Map<String, String>> rows,
    required int total,
  }) : super._(
         resourceKey: resourceKey,
         column: column,
         rows: rows,
         total: total,
       );

  /// Returns a shallow copy of this [AdminRelatedRows]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AdminRelatedRows copyWith({
    String? resourceKey,
    String? column,
    List<Map<String, String>>? rows,
    int? total,
  }) {
    return AdminRelatedRows(
      resourceKey: resourceKey ?? this.resourceKey,
      column: column ?? this.column,
      rows:
          rows ??
          this.rows
              .map(
                (e0) => e0.map(
                  (
                    key1,
                    value1,
                  ) => MapEntry(
                    key1,
                    value1,
                  ),
                ),
              )
              .toList(),
      total: total ?? this.total,
    );
  }
}
