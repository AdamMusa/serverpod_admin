import 'dart:convert';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../generated/protocol.dart';
import 'admin_registry.dart';

/// The change history of rows edited through Serverpod Admin: who created,
/// updated, deleted or ran an action on which row, and what changed.
class AdminHistory {
  const AdminHistory._();

  static final _secret = RegExp(
    r'(password|secret|token|hash|privatekey|apikey|pepper)',
  );
  static const _hidden = '•••';
  static DateTime? _lastPrune;

  /// Records one change; never fails the edit it describes.
  static Future<void> record(
    Session session, {
    required String resourceKey,
    required String recordId,
    required AdminLogAction action,
    Map<String, String> before = const {},
    Map<String, String> after = const {},
    String? summary,
  }) async {
    try {
      final changes = switch (action) {
        AdminLogAction.updated => _diff(before, after),
        AdminLogAction.created => _values(after),
        AdminLogAction.deleted => _values(before),
        AdminLogAction.action => <String, Object?>{},
      };
      if (action == AdminLogAction.updated && changes.isEmpty) return;
      final actor = session.authenticated?.userIdentifier ?? 'unknown';
      await AdminLogEntry.db.insertRow(
        session,
        AdminLogEntry(
          actor: actor,
          actorName: await _actorName(session, actor),
          resourceKey: resourceKey,
          recordId: recordId,
          action: action,
          changes: jsonEncode(changes),
          summary: summary,
        ),
      );
      await _prune(session);
    } catch (error) {
      session.log(
        'serverpod_admin: history not recorded ($error)',
        level: LogLevel.warning,
      );
    }
  }

  /// Entries newest first, optionally for one resource or one row.
  static Future<AdminLogPage> read(
    Session session, {
    String? resourceKey,
    String? recordId,
    Set<String>? resourceKeys,
    int offset = 0,
    int limit = 50,
  }) async {
    Expression? where;
    if (resourceKeys != null) {
      if (resourceKeys.isEmpty) return AdminLogPage(entries: [], total: 0);
      where = AdminLogEntry.t.resourceKey.inSet(resourceKeys);
    }
    if (resourceKey != null) {
      where = AdminLogEntry.t.resourceKey.equals(resourceKey);
      if (recordId != null) {
        where = where & AdminLogEntry.t.recordId.equals(recordId);
      }
    }
    final entries = await AdminLogEntry.db.find(
      session,
      where: (_) => where ?? Constant.bool(true),
      orderByList: (t) => [t.createdAt.desc(), t.id.desc()],
      offset: offset < 0 ? 0 : offset,
      limit: limit.clamp(1, 200),
    );
    final total = await AdminLogEntry.db.count(
      session,
      where: (_) => where ?? Constant.bool(true),
    );
    return AdminLogPage(entries: entries, total: total);
  }

  static Map<String, Object?> _diff(
    Map<String, String> before,
    Map<String, String> after,
  ) => {
    for (final field in {...before.keys, ...after.keys})
      if ((before[field] ?? '') != (after[field] ?? ''))
        field: _secretField(field)
            ? [_hidden, _hidden]
            : [before[field] ?? '', after[field] ?? ''],
  };

  static Map<String, Object?> _values(Map<String, String> row) => {
    for (final MapEntry(:key, :value) in row.entries)
      if (value.isNotEmpty) key: _secretField(key) ? _hidden : value,
  };

  static bool _secretField(String name) =>
      _secret.hasMatch(name.toLowerCase().replaceAll(RegExp('[^a-z]'), ''));

  static Future<String?> _actorName(Session session, String actor) async {
    try {
      final profile = await AuthServices.instance.userProfiles
          .maybeFindUserProfileByUserId(
            session,
            UuidValue.withValidation(actor),
          );
      return profile?.email ?? profile?.fullName ?? profile?.userName;
    } catch (_) {
      return null;
    }
  }

  /// Removes entries older than [AdminRegistry.historyRetention], at most
  /// once an hour per server.
  static Future<void> _prune(Session session) async {
    final retention = AdminRegistry().historyRetention;
    if (retention == null) return;
    final now = DateTime.now().toUtc();
    final last = _lastPrune;
    if (last != null && now.difference(last) < const Duration(hours: 1)) {
      return;
    }
    _lastPrune = now;
    await AdminLogEntry.db.deleteWhere(
      session,
      where: (t) => t.createdAt < now.subtract(retention),
    );
  }
}
