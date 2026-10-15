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
import 'package:serverpod_admin_server/src/generated/protocol.dart' as _i2;

/// One page of rows, as text, and how many rows match in total (-1 when
/// the query asked not to count them).
abstract class AdminPage
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  AdminPage._({
    required this.rows,
    required this.total,
  });

  factory AdminPage({
    required List<Map<String, String>> rows,
    required int total,
  }) = _AdminPageImpl;

  factory AdminPage.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminPage(
      rows: _i2.Protocol().deserialize<List<Map<String, String>>>(
        jsonSerialization['rows'],
      ),
      total: jsonSerialization['total'] as int,
    );
  }

  List<Map<String, String>> rows;

  int total;

  /// Returns a shallow copy of this [AdminPage]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AdminPage copyWith({
    List<Map<String, String>>? rows,
    int? total,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_admin.AdminPage',
      'rows': rows.toJson(valueToJson: (v) => v.toJson()),
      'total': total,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_admin.AdminPage',
      'rows': rows.toJson(valueToJson: (v) => v.toJson()),
      'total': total,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _AdminPageImpl extends AdminPage {
  _AdminPageImpl({
    required List<Map<String, String>> rows,
    required int total,
  }) : super._(
         rows: rows,
         total: total,
       );

  /// Returns a shallow copy of this [AdminPage]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AdminPage copyWith({
    List<Map<String, String>>? rows,
    int? total,
  }) {
    return AdminPage(
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
