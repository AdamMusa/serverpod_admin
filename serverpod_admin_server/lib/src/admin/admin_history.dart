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
  }) => recordAll(
    session,
    resourceKey: resourceKey,
    changes: [
      AdminChange(
        recordId: recordId,
        action: action,
        before: before,
        after: after,
        summary: summary,
      ),
    ],
  );

  /// Records [changes] to rows of [resourceKey] in one insert; never fails
  /// the edits they describe.
  static Future<void> recordAll(
    Session session, {
    required String resourceKey,
    required List<AdminChange> changes,
  }) async {
    try {
      final actor = session.authenticated?.userIdentifier ?? 'unknown';
      String? actorName;
      final entries = <AdminLogEntry>[];
      for (final change in changes) {
        final values = switch (change.action) {
          AdminLogAction.updated => _diff(change.before, change.after),
          AdminLogAction.created => _values(change.after),
          AdminLogAction.deleted => _values(change.before),
          AdminLogAction.action => <String, Object?>{},
        };
        if (change.action == AdminLogAction.updated && values.isEmpty) {
          continue;
        }
        actorName ??= await _actorName(session, actor) ?? '';
        entries.add(
          AdminLogEntry(
            actor: actor,
            actorName: actorName.isEmpty ? null : actorName,
            resourceKey: resourceKey,
            recordId: change.recordId,
            action: change.action,
            changes: jsonEncode(values),
            summary: change.summary,
          ),
        );
      }
      if (entries.isEmpty) return;
      await AdminLogEntry.db.insert(session, entries);
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

  static final _actorNames = <String, ({String? name, DateTime read})>{};

  /// How [actor] is shown, read at most every few minutes rather than for
  /// every change.
  static Future<String?> _actorName(Session session, String actor) async {
    final now = DateTime.now();
    final cached = _actorNames[actor];
    if (cached != null && now.difference(cached.read) < _actorNameAge) {
      return cached.name;
    }
    String? name;
    try {
      final profile = await AuthServices.instance.userProfiles
          .maybeFindUserProfileByUserId(
            session,
            UuidValue.withValidation(actor),
          );
      name = profile?.email ?? profile?.fullName ?? profile?.userName;
    } catch (_) {
      name = null;
    }
    if (_actorNames.length >= 1000) _actorNames.clear();
    _actorNames[actor] = (name: name, read: now);
    return name;
  }

  static const _actorNameAge = Duration(minutes: 10);

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

/// One change to a row, for [AdminHistory.recordAll].
class AdminChange {
  const AdminChange({
    required this.recordId,
    required this.action,
    this.before = const {},
    this.after = const {},
    this.summary,
  });

  final String recordId;
  final AdminLogAction action;
  final Map<String, String> before;
  final Map<String, String> after;
  final String? summary;
}
