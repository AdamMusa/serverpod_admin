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

abstract class AdminScope implements _i1.SerializableModel {
  AdminScope._({
    this.id,
    required this.userId,
    required this.isStaff,
    required this.isSuperuser,
  });

  factory AdminScope({
    int? id,
    required String userId,
    required bool isStaff,
    required bool isSuperuser,
  }) = _AdminScopeImpl;

  factory AdminScope.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminScope(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as String,
      isStaff: jsonSerialization['isStaff'] as bool,
      isSuperuser: jsonSerialization['isSuperuser'] as bool,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String userId;

  bool isStaff;

  bool isSuperuser;

  /// Returns a shallow copy of this [AdminScope]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AdminScope copyWith({
    int? id,
    String? userId,
    bool? isStaff,
    bool? isSuperuser,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_admin.AdminScope',
      if (id != null) 'id': id,
      'userId': userId,
      'isStaff': isStaff,
      'isSuperuser': isSuperuser,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AdminScopeImpl extends AdminScope {
  _AdminScopeImpl({
    int? id,
    required String userId,
    required bool isStaff,
    required bool isSuperuser,
  }) : super._(
         id: id,
         userId: userId,
         isStaff: isStaff,
         isSuperuser: isSuperuser,
       );

  /// Returns a shallow copy of this [AdminScope]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AdminScope copyWith({
    Object? id = _Undefined,
    String? userId,
    bool? isStaff,
    bool? isSuperuser,
  }) {
    return AdminScope(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      isStaff: isStaff ?? this.isStaff,
      isSuperuser: isSuperuser ?? this.isSuperuser,
    );
  }
}
