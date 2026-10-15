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
import '../admin/admin_log_entry.dart' as _i2;
import 'package:serverpod_admin_client/src/protocol/protocol.dart' as _i3;

/// Entries of the change history, newest first, and how many match.
abstract class AdminLogPage
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  AdminLogPage._({
    required this.entries,
    required this.total,
  });

  factory AdminLogPage({
    required List<_i2.AdminLogEntry> entries,
    required int total,
  }) = _AdminLogPageImpl;

  factory AdminLogPage.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminLogPage(
      entries: _i3.Protocol().deserialize<List<_i2.AdminLogEntry>>(
        jsonSerialization['entries'],
      ),
      total: jsonSerialization['total'] as int,
    );
  }

  List<_i2.AdminLogEntry> entries;

  int total;

  /// Returns a shallow copy of this [AdminLogPage]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AdminLogPage copyWith({
    List<_i2.AdminLogEntry>? entries,
    int? total,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_admin.AdminLogPage',
      'entries': entries.toJson(valueToJson: (v) => v.toJson()),
      'total': total,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_admin.AdminLogPage',
      'entries': entries.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'total': total,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _AdminLogPageImpl extends AdminLogPage {
  _AdminLogPageImpl({
    required List<_i2.AdminLogEntry> entries,
    required int total,
  }) : super._(
         entries: entries,
         total: total,
       );

  /// Returns a shallow copy of this [AdminLogPage]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AdminLogPage copyWith({
    List<_i2.AdminLogEntry>? entries,
    int? total,
  }) {
    return AdminLogPage(
      entries: entries ?? this.entries.map((e0) => e0.copyWith()).toList(),
      total: total ?? this.total,
    );
  }
}
