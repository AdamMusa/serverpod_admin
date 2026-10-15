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

/// What importing rows from a spreadsheet did.
abstract class AdminImportResult
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  AdminImportResult._({
    required this.created,
    required this.updated,
    required this.skipped,
    required this.failures,
  });

  factory AdminImportResult({
    required int created,
    required int updated,
    required int skipped,
    required List<String> failures,
  }) = _AdminImportResultImpl;

  factory AdminImportResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminImportResult(
      created: jsonSerialization['created'] as int,
      updated: jsonSerialization['updated'] as int,
      skipped: jsonSerialization['skipped'] as int,
      failures: _i2.Protocol().deserialize<List<String>>(
        jsonSerialization['failures'],
      ),
    );
  }

  int created;

  int updated;

  /// Rows without any value.
  int skipped;

  /// Rows that could not be saved and why, such as "row 3: …".
  List<String> failures;

  /// Returns a shallow copy of this [AdminImportResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AdminImportResult copyWith({
    int? created,
    int? updated,
    int? skipped,
    List<String>? failures,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_admin.AdminImportResult',
      'created': created,
      'updated': updated,
      'skipped': skipped,
      'failures': failures.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_admin.AdminImportResult',
      'created': created,
      'updated': updated,
      'skipped': skipped,
      'failures': failures.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _AdminImportResultImpl extends AdminImportResult {
  _AdminImportResultImpl({
    required int created,
    required int updated,
    required int skipped,
    required List<String> failures,
  }) : super._(
         created: created,
         updated: updated,
         skipped: skipped,
         failures: failures,
       );

  /// Returns a shallow copy of this [AdminImportResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AdminImportResult copyWith({
    int? created,
    int? updated,
    int? skipped,
    List<String>? failures,
  }) {
    return AdminImportResult(
      created: created ?? this.created,
      updated: updated ?? this.updated,
      skipped: skipped ?? this.skipped,
      failures: failures ?? this.failures.map((e0) => e0).toList(),
    );
  }
}
