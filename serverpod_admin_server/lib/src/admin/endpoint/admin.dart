import 'dart:convert';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod/protocol.dart' show SessionLogEntry;
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:serverpod_admin_server/src/admin/admin_entry_base.dart';
import 'package:serverpod_admin_server/src/admin/admin_value_parser.dart';

import '../../admin/admin.dart';
import '../admin_registry.dart';
import '../../../serverpod_admin_server.dart'
    show AdminResource, AdminValidationException;

class AdminEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  static const String _classNameKey = '__className__';

  final AdminRegistry _registry = AdminRegistry();

  AdminEntryBase _resolve(String resourceKey) {
    adminRegister();
    final entry = _registry.entryByKey(resourceKey);
    if (entry == null) {
      throw ArgumentError('Unknown admin resource "$resourceKey".');
    }
    return entry;
  }

  /// Checks if the authenticated user has admin permissions (isSuperuser or isStaff).
  /// Throws an exception if the user doesn't have permissions.
  @override
  Set<Scope> get requiredScopes => {Scope.admin};

  Future<List<AdminResource>> resources(Session session) async {
    adminRegister();
    return _registry.registeredResourceMetadata;
  }

  Future<Map<String, String>> currentUserProfile(Session session) async {
    return _profileToMap(await _findOrCreateCurrentProfile(session));
  }

  Future<List<Map<String, String>>> futureCallHistory(Session session) async {
    final entries = await SessionLogEntry.db.find(
      session,
      where: (table) => table.endpoint.equals('FutureCall'),
      orderBy: (table) => table.time.desc(),
      limit: 100,
    );

    return entries.map(_futureCallLogToMap).toList(growable: false);
  }

  Future<Map<String, String>> updateCurrentUserProfile(
    Session session,
    String userName,
    String fullName,
  ) async {
    final authUserId = session.authenticated!.authUserId;
    final profiles = AuthServices.instance.userProfiles;

    final normalizedUserName = _blankToNull(userName);
    final normalizedFullName = _blankToNull(fullName);

    await _findOrCreateCurrentProfile(session);
    await profiles.changeUserName(session, authUserId, normalizedUserName);
    final updatedProfile = await profiles.changeFullName(
      session,
      authUserId,
      normalizedFullName,
    );

    return _profileToMap(updatedProfile);
  }

  Future<bool> changeCurrentUserPassword(
    Session session,
    String currentPassword,
    String newPassword,
  ) async {
    if (currentPassword.isEmpty || newPassword.isEmpty) {
      throw ArgumentError('Current password and new password are required.');
    }

    final emailIdp = AuthServices.instance.emailIdp;
    final account = await emailIdp.utils.getAccount(session);
    if (account == null) {
      throw StateError('No email account is linked to this admin user.');
    }

    late final UuidValue authenticatedUserId;
    try {
      authenticatedUserId = await emailIdp.utils.authentication.authenticate(
        session,
        email: account.email,
        password: currentPassword,
        transaction: null,
      );
    } on EmailLoginServerException {
      throw StateError('Current password is incorrect.');
    }
    if (authenticatedUserId != session.authenticated!.authUserId) {
      throw StateError('Current password is incorrect.');
    }

    await emailIdp.admin.setPassword(
      session,
      email: account.email,
      password: newPassword,
    );
    return true;
  }

  Future<List<Map<String, String>>> list(
    Session session,
    String resourceKey,
  ) async {
    final entry = _resolve(resourceKey);
    final result = await entry.list(session);
    return _stringifyRecords(await _withAuthUsers(session, entry, result));
  }

  Future<List<Map<String, String>>> listPage(
    Session session,
    String resourceKey,
    int offset,
    int limit,
  ) async {
    if (offset < 0 || limit <= 0) {
      throw ArgumentError(
        'Invalid pagination arguments. Offset must be >= 0 and limit > 0.',
      );
    }
    final entry = _resolve(resourceKey);
    final all = await entry.list(session);
    final window = all.skip(offset).take(limit).toList(growable: false);
    return _stringifyRecords(await _withAuthUsers(session, entry, window));
  }

  Future<Map<String, dynamic>?> find(
    Session session,
    String resourceKey,
    String id,
  ) async {
    final entry = _resolve(resourceKey);
    final primaryColumnMetadata = entry.metadata.columns.firstWhere(
      (column) => column.isPrimary,
      orElse: () => entry.metadata.columns.first,
    );
    final tableColumn = entry.columns.firstWhere(
      (column) => column.columnName == primaryColumnMetadata.name,
      orElse: () => entry.columns.first,
    );
    final normalizedId = parseAdminColumnValue(tableColumn, id) ?? id;
    final result = await entry.find(session, normalizedId);
    if (result == null) return null;
    return _removeClassName(
      (await _withAuthUsers(session, entry, [result])).single,
    );
  }

  Future<Map<String, String>> create(
    Session session,
    String resourceKey,
    Map<String, String> data,
  ) async {
    final entry = _resolve(resourceKey);
    final normalized = _normalizePayload(entry, data);
    _requireStorable(entry, normalized);
    final authUser = await entry.authUserLink?.change(
      session,
      normalized,
      data,
    );
    final created = await entry.create(session, normalized);
    if (authUser != null) await AuthUser.db.updateRow(session, authUser);
    return _stringifyRecord(
      (await _withAuthUsers(session, entry, [created])).single,
    );
  }

  Future<Map<String, String>> update(
    Session session,
    String resourceKey,
    Map<String, String> data,
  ) async {
    final entry = _resolve(resourceKey);
    final normalized = _normalizePayload(entry, data);
    final id = normalized[entry.table.id.columnName];
    _requireStorable(
      entry,
      normalized,
      stored: id == null ? null : await entry.find(session, id),
    );
    final authUser = await entry.authUserLink?.change(
      session,
      normalized,
      data,
    );
    final updated = await entry.update(session, normalized);
    if (authUser != null) await AuthUser.db.updateRow(session, authUser);
    return _stringifyRecord(
      (await _withAuthUsers(session, entry, [updated])).single,
    );
  }

  Future<bool> delete(Session session, String resourceKey, String id) async {
    final entry = _resolve(resourceKey);
    final primaryColumnMetadata = entry.metadata.columns.firstWhere(
      (column) => column.isPrimary,
      orElse: () => entry.metadata.columns.first,
    );
    final tableColumn = entry.columns.firstWhere(
      (column) => column.columnName == primaryColumnMetadata.name,
      orElse: () => entry.columns.first,
    );
    final normalizedId = parseAdminColumnValue(tableColumn, id) ?? id;
    await entry.delete(session, normalizedId);
    return true;
  }

  /// Adds the auth user values of rows that extend an auth user.
  Future<List<Map<String, dynamic>>> _withAuthUsers(
    Session session,
    AdminEntryBase entry,
    List<Map<String, dynamic>> rows,
  ) async => await entry.authUserLink?.attach(session, rows) ?? rows;

  Map<String, dynamic> _normalizePayload(
    AdminEntryBase entry,
    Map<String, String> data,
  ) {
    final normalized = <String, dynamic>{};
    for (final column in entry.columns) {
      final name = column.columnName;
      if (!data.containsKey(name)) continue;
      final value = data[name];
      normalized[name] = parseAdminColumnValue(column, value);
    }
    return normalized;
  }

  /// Rejects values the model cannot hold (for example a malformed
  /// geography point) with a message naming the field, instead of letting
  /// the conversion fail as an internal server error. A field is identified
  /// by swapping each submitted value for its [stored] one in turn.
  void _requireStorable(
    AdminEntryBase entry,
    Map<String, dynamic> json, {
    Map<String, dynamic>? stored,
  }) {
    bool converts(Map<String, dynamic> candidate) {
      try {
        entry.fromJson(candidate);
        return true;
      } catch (_) {
        return false;
      }
    }

    if (converts(json)) return;
    if (stored != null) {
      for (final column in entry.columns) {
        final name = column.columnName;
        // Serialized rows omit null fields, so a missing stored value is null.
        if (!json.containsKey(name)) continue;
        if (converts({...json, name: stored[name]})) {
          throw AdminValidationException(
            field: name,
            message: column is ColumnGeographyPoint
                ? '$name must be a point such as '
                      'SRID=4326;POINT(-15.97 18.08) (longitude latitude).'
                : '$name has a value that cannot be saved.',
          );
        }
      }
    }
    throw AdminValidationException(
      message: 'Some values cannot be saved. Check the formats and try again.',
    );
  }

  String? _blankToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<UserProfileModel> _findOrCreateCurrentProfile(Session session) async {
    final authUserId = session.authenticated!.authUserId;
    final profiles = AuthServices.instance.userProfiles;
    final profile = await profiles.maybeFindUserProfileByUserId(
      session,
      authUserId,
    );
    if (profile != null) return profile;

    final account = await AuthServices.instance.emailIdp.utils.getAccount(
      session,
    );
    return profiles.createUserProfile(
      session,
      authUserId,
      UserProfileData(email: account?.email),
    );
  }

  Map<String, String> _profileToMap(UserProfileModel profile) {
    return {
      'authUserId': profile.authUserId.toString(),
      'userName': profile.userName ?? '',
      'fullName': profile.fullName ?? '',
      'email': profile.email ?? '',
      'imageUrl': profile.imageUrl?.toString() ?? '',
    };
  }

  Map<String, String> _futureCallLogToMap(SessionLogEntry entry) {
    final error = entry.error ?? '';
    return {
      'id': entry.id?.toString() ?? '',
      'name': entry.method ?? '',
      'serverId': entry.serverId,
      'time': entry.time.toUtc().toIso8601String(),
      'finishedAt': entry.touched.toUtc().toIso8601String(),
      'duration': entry.duration?.toString() ?? '',
      'queries': entry.numQueries?.toString() ?? '',
      'error': error,
      'stackTrace': entry.stackTrace ?? '',
      'status': error.isEmpty ? 'finished' : 'failed',
      'source': 'history',
    };
  }

  List<Map<String, String>> _stringifyRecords(
    List<Map<String, dynamic>> rows,
  ) => rows.map(_stringifyRecord).toList();
  Map<String, String> _stringifyRecord(Map<String, dynamic> row) {
    return Map.fromEntries(
      row.entries
          .where((entry) => entry.key != _classNameKey)
          .map((entry) => MapEntry(entry.key, _stringifyValue(entry.value))),
    );
  }

  /// Removes __className__ from a dynamic map to prevent client-side
  /// deserialization issues.
  Map<String, dynamic> _removeClassName(Map<String, dynamic> map) {
    final cleaned = Map<String, dynamic>.from(map);
    cleaned.remove(_classNameKey);
    return cleaned;
  }

  String _stringifyValue(dynamic value) {
    if (value == null) return '';
    if (value is DateTime) {
      return value.toUtc().toIso8601String();
    }
    if (value is Enum) return value.name;
    // JSON round-trips through the edit form; toString() would not parse.
    if (value is List || value is Map) return jsonEncode(value);
    if (value is Set) return jsonEncode(value.toList());
    return value.toString();
  }
}
