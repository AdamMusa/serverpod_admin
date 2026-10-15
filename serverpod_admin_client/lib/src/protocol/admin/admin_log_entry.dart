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
import '../admin/admin_log_action.dart' as _i2;

/// One change made through Serverpod Admin: the history of a row and the
/// dashboard's recent actions.
abstract class AdminLogEntry
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  AdminLogEntry._({
    this.id,
    DateTime? createdAt,
    required this.actor,
    this.actorName,
    required this.resourceKey,
    required this.recordId,
    required this.action,
    required this.changes,
    this.summary,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AdminLogEntry({
    int? id,
    DateTime? createdAt,
    required String actor,
    String? actorName,
    required String resourceKey,
    required String recordId,
    required _i2.AdminLogAction action,
    required String changes,
    String? summary,
  }) = _AdminLogEntryImpl;

  factory AdminLogEntry.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminLogEntry(
      id: jsonSerialization['id'] as int?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      actor: jsonSerialization['actor'] as String,
      actorName: jsonSerialization['actorName'] as String?,
      resourceKey: jsonSerialization['resourceKey'] as String,
      recordId: jsonSerialization['recordId'] as String,
      action: _i2.AdminLogAction.fromJson(
        (jsonSerialization['action'] as String),
      ),
      changes: jsonSerialization['changes'] as String,
      summary: jsonSerialization['summary'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  DateTime createdAt;

  /// The administrator's auth user id.
  String actor;

  /// How the administrator is shown, such as their email address.
  String? actorName;

  String resourceKey;

  String recordId;

  _i2.AdminLogAction action;

  /// JSON. Updates: {"field": ["before", "after"]}. Creations and deletions:
  /// the row's values. Fields that look secret are recorded as changed only.
  String changes;

  /// A short description, such as the label of a custom action.
  String? summary;

  /// Returns a shallow copy of this [AdminLogEntry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AdminLogEntry copyWith({
    int? id,
    DateTime? createdAt,
    String? actor,
    String? actorName,
    String? resourceKey,
    String? recordId,
    _i2.AdminLogAction? action,
    String? changes,
    String? summary,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_admin.AdminLogEntry',
      if (id != null) 'id': id,
      'createdAt': createdAt.toJson(),
      'actor': actor,
      if (actorName != null) 'actorName': actorName,
      'resourceKey': resourceKey,
      'recordId': recordId,
      'action': action.toJson(),
      'changes': changes,
      if (summary != null) 'summary': summary,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_admin.AdminLogEntry',
      if (id != null) 'id': id,
      'createdAt': createdAt.toJson(),
      'actor': actor,
      if (actorName != null) 'actorName': actorName,
      'resourceKey': resourceKey,
      'recordId': recordId,
      'action': action.toJson(),
      'changes': changes,
      if (summary != null) 'summary': summary,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AdminLogEntryImpl extends AdminLogEntry {
  _AdminLogEntryImpl({
    int? id,
    DateTime? createdAt,
    required String actor,
    String? actorName,
    required String resourceKey,
    required String recordId,
    required _i2.AdminLogAction action,
    required String changes,
    String? summary,
  }) : super._(
         id: id,
         createdAt: createdAt,
         actor: actor,
         actorName: actorName,
         resourceKey: resourceKey,
         recordId: recordId,
         action: action,
         changes: changes,
         summary: summary,
       );

  /// Returns a shallow copy of this [AdminLogEntry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AdminLogEntry copyWith({
    Object? id = _Undefined,
    DateTime? createdAt,
    String? actor,
    Object? actorName = _Undefined,
    String? resourceKey,
    String? recordId,
    _i2.AdminLogAction? action,
    String? changes,
    Object? summary = _Undefined,
  }) {
    return AdminLogEntry(
      id: id is int? ? id : this.id,
      createdAt: createdAt ?? this.createdAt,
      actor: actor ?? this.actor,
      actorName: actorName is String? ? actorName : this.actorName,
      resourceKey: resourceKey ?? this.resourceKey,
      recordId: recordId ?? this.recordId,
      action: action ?? this.action,
      changes: changes ?? this.changes,
      summary: summary is String? ? summary : this.summary,
    );
  }
}
