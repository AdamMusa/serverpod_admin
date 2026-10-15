import 'dart:convert';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod/protocol.dart' show SessionLogEntry;
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:serverpod_admin_server/src/admin/admin_access.dart';
import 'package:serverpod_admin_server/src/admin/admin_auth_user_link.dart';
import 'package:serverpod_admin_server/src/admin/admin_entry_base.dart';
import 'package:serverpod_admin_server/src/admin/admin_overview.dart';
import 'package:serverpod_admin_server/src/admin/admin_history.dart'
    show AdminChange, AdminHistory;
import 'package:serverpod_admin_server/src/admin/admin_query_engine.dart';
import 'package:serverpod_admin_server/src/admin/admin_saved_views.dart';
import 'package:serverpod_admin_server/src/admin/admin_value_parser.dart';

import '../../admin/admin.dart';
import '../admin_registry.dart';
import '../../../serverpod_admin_server.dart'
    show
        AdminAccessInfo,
        AdminActivityPoint,
        AdminMetricValue,
        AdminActionResult,
        AdminLogAction,
        AdminLogPage,
        AdminPage,
        AdminFilter,
        AdminFilterOperator,
        AdminImportResult,
        AdminQuery,
        AdminRelatedRows,
        AdminResource,
        AdminSavedView,
        AdminTableSummary,
        AdminValidationException;

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

  /// Signing in is required; what the user may do is checked in each
  /// method (see [AdminAccess]): administrators everything, staff what
  /// tables grant their scopes.
  @override
  Set<Scope> get requiredScopes => const {};

  /// Resolves [resourceKey] after checking the user may [operation] it.
  AdminEntryBase _entryFor(
    Session session,
    String resourceKey,
    AdminOperation operation,
  ) {
    final access = AdminAccess.of(session)..requireAllowed();
    final entry = _resolve(resourceKey);
    access.require(entry, operation);
    return entry;
  }

  /// What the signed-in user may do; never refused, so the dashboard can
  /// explain a missing role.
  Future<AdminAccessInfo> access(Session session) async {
    final access = AdminAccess.of(session);
    return AdminAccessInfo(allowed: access.allowed, admin: access.admin);
  }

  /// The tables the user may see, each saying whether they may create, edit
  /// and delete rows.
  Future<List<AdminResource>> resources(Session session) async {
    adminRegister();
    final access = AdminAccess.of(session)..requireAllowed();
    final resources = <AdminResource>[];
    for (final entry in _registry.registeredEntries) {
      try {
        if (!access.can(entry, AdminOperation.view)) continue;
        bool? allows(AdminOperation operation) =>
            access.can(entry, operation) ? null : false;
        resources.add(
          entry.metadata.copyWith(
            canCreate: allows(AdminOperation.create),
            canEdit: allows(AdminOperation.edit),
            canDelete: allows(AdminOperation.delete),
          ),
        );
      } catch (error, stackTrace) {
        session.log(
          'serverpod_admin: no metadata for ${entry.type} ($error)',
          level: LogLevel.error,
          stackTrace: stackTrace,
        );
      }
    }
    return resources;
  }

  /// Key numbers for the overview the user may see; a metric that fails
  /// shows "—".
  Future<List<AdminMetricValue>> metrics(Session session) async {
    final access = AdminAccess.of(session)..requireAllowed();
    adminRegister();
    return Future.wait([
      for (final metric in _registry.metrics)
        if (access.sees(metric))
          metric
              .compute(session)
              .timeout(const Duration(seconds: 10))
              .then(
                (value) => AdminMetricValue(
                  label: metric.label,
                  value: value,
                  hint: metric.hint,
                ),
              )
              .catchError(
                (Object _) => AdminMetricValue(
                  label: metric.label,
                  value: '—',
                  hint: metric.hint,
                ),
              ),
    ]);
  }

  /// Every table the user may see with its number of rows and the rows it
  /// gained on each of the last [days] days: the overview in one request
  /// and two queries.
  Future<List<AdminTableSummary>> overview(Session session, int days) async {
    final access = AdminAccess.of(session)..requireAllowed();
    return AdminOverview.summarize(session, [
      for (final entry in adminRegister())
        if (access.can(entry, AdminOperation.view)) entry,
    ], days: days);
  }

  /// Rows added per day over the last [days] days, by the resource's
  /// chart column, for the overview.
  Future<List<AdminActivityPoint>> activity(
    Session session,
    String resourceKey,
    int days,
  ) async {
    final entry = _entryFor(session, resourceKey, AdminOperation.view);
    final activity = await AdminOverview.dailyRows(session, [
      entry,
    ], days: days);
    return activity[entry] ?? const [];
  }

  Future<Map<String, String>> currentUserProfile(Session session) async {
    AdminAccess.of(session).requireAllowed();
    return _profileToMap(await _findOrCreateCurrentProfile(session));
  }

  Future<List<Map<String, String>>> futureCallHistory(Session session) async {
    AdminAccess.of(session).requireAdmin();
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
    AdminAccess.of(session).requireAllowed();
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
    AdminAccess.of(session).requireAllowed();
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
    final entry = _entryFor(session, resourceKey, AdminOperation.view);
    final result = await entry.list(session);
    return _visibleRows(entry, await _withAuthUsers(session, entry, result));
  }

  /// One page of [resourceKey]'s rows: filtered, searched and sorted in the
  /// database when possible, with the total number of matching rows.
  Future<AdminPage> query(
    Session session,
    String resourceKey,
    AdminQuery query,
  ) async {
    final entry = _entryFor(session, resourceKey, AdminOperation.view);
    return _page(
      session,
      entry,
      query.copyWith(
        offset: query.offset < 0 ? 0 : query.offset,
        limit: query.limit.clamp(1, adminMaxPageSize),
      ),
    );
  }

  /// The rows of [entry] matching [bounded], in the database when possible.
  Future<AdminPage> _page(
    Session session,
    AdminEntryBase entry,
    AdminQuery bounded,
  ) async {
    final only = _onlyColumns(entry, bounded.columns);
    final page = await entry.queryPage(session, bounded);
    if (page != null) {
      final rows = only == null || only.any(AdminAuthUserLink.isField)
          ? await _withAuthUsers(session, entry, page.rows)
          : page.rows;
      return AdminPage(
        rows: _visibleRows(entry, rows, only: only),
        total: page.total,
      );
    }
    final all = await _withAuthUsers(session, entry, await entry.list(session));
    final matching = AdminRowQuery.apply(
      // Hidden values never reach the in-memory search.
      _visibleRows(entry, all),
      entry.metadata.columns,
      bounded,
    );
    return only == null
        ? matching
        : matching.copyWith(
            rows: [for (final row in matching.rows) _only(row, only)],
          );
  }

  /// The columns to return for [columns] (with the primary key), or null
  /// for every visible column.
  Set<String>? _onlyColumns(AdminEntryBase entry, List<String>? columns) =>
      columns == null ? null : {entry.table.id.columnName, ...columns};

  static Map<String, String> _only(Map<String, String> row, Set<String> only) =>
      {
        for (final MapEntry(:key, :value) in row.entries)
          if (only.contains(key)) key: value,
      };

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
    final page = await query(
      session,
      resourceKey,
      AdminQuery(
        offset: offset,
        limit: limit,
        sortDescending: false,
        filters: const [],
        countTotal: false,
      ),
    );
    return page.rows;
  }

  Future<Map<String, dynamic>?> find(
    Session session,
    String resourceKey,
    String id,
  ) async {
    final entry = _entryFor(session, resourceKey, AdminOperation.view);
    final result = await entry.find(session, _parseId(entry, id));
    if (result == null) return null;
    return _removeClassName(
      (await _withAuthUsers(session, entry, [result])).single,
    )..removeWhere((key, _) => entry.options.hidden.contains(key));
  }

  Future<Map<String, String>> create(
    Session session,
    String resourceKey,
    Map<String, String> data,
  ) async {
    final entry = _entryFor(session, resourceKey, AdminOperation.create);
    final text = await _create(session, entry, data);
    await AdminHistory.record(
      session,
      resourceKey: entry.resourceKey,
      recordId: _idOf(entry, text),
      action: AdminLogAction.created,
      after: text,
    );
    return text;
  }

  Future<Map<String, String>> update(
    Session session,
    String resourceKey,
    Map<String, String> data,
  ) async {
    final entry = _entryFor(session, resourceKey, AdminOperation.edit);
    final (:before, :after) = await _save(session, entry, data);
    await AdminHistory.record(
      session,
      resourceKey: entry.resourceKey,
      recordId: _idOf(entry, after),
      action: AdminLogAction.updated,
      before: before ?? const {},
      after: after,
    );
    return after;
  }

  /// Creates a row from [data] and returns it as text.
  Future<Map<String, String>> _create(
    Session session,
    AdminEntryBase entry,
    Map<String, String> data,
  ) async {
    final normalized = _normalizeCreate(entry, data);
    final authUser = await entry.authUserLink?.change(
      session,
      normalized,
      data,
    );
    final created = await entry.create(session, normalized);
    if (authUser != null) await AuthUser.db.updateRow(session, authUser);
    return _text(session, entry, created);
  }

  /// [data] for a new row, checked; hidden columns are never set from the
  /// dashboard.
  Map<String, dynamic> _normalizeCreate(
    AdminEntryBase entry,
    Map<String, String> data,
  ) {
    final normalized = _normalizePayload(entry, {
      for (final MapEntry(:key, :value) in data.entries)
        if (!entry.options.hidden.contains(key)) key: value,
    });
    _requireStorable(entry, normalized);
    return normalized;
  }

  /// Saves [data] over its row and returns the row as text before and
  /// after. Hidden and read-only columns keep their [stored] values (read
  /// here unless given); [before] is the stored row as text, when known.
  Future<({Map<String, String>? before, Map<String, String> after})> _save(
    Session session,
    AdminEntryBase entry,
    Map<String, String> data, {
    Map<String, dynamic>? stored,
    Map<String, String>? before,
  }) async {
    final normalized = _normalizeUpdate(entry, data);
    final id = normalized[entry.table.id.columnName];
    stored ??= id == null ? null : await entry.find(session, id);
    _keepLocked(entry, normalized, stored);
    _requireStorable(entry, normalized, stored: stored);
    before ??= stored == null ? null : await _text(session, entry, stored);
    final authUser = await entry.authUserLink?.change(
      session,
      normalized,
      data,
    );
    final updated = await entry.update(session, normalized);
    if (authUser != null) await AuthUser.db.updateRow(session, authUser);
    return (before: before, after: await _text(session, entry, updated));
  }

  /// [data] for an update, without the columns it may not change.
  Map<String, dynamic> _normalizeUpdate(
    AdminEntryBase entry,
    Map<String, String> data,
  ) {
    final locked = {...entry.options.hidden, ...entry.options.readOnly};
    return _normalizePayload(entry, {
      for (final MapEntry(:key, :value) in data.entries)
        if (!locked.contains(key)) key: value,
    });
  }

  /// Gives hidden and read-only columns their [stored] values.
  void _keepLocked(
    AdminEntryBase entry,
    Map<String, dynamic> normalized,
    Map<String, dynamic>? stored,
  ) {
    if (stored == null) return;
    final locked = {...entry.options.hidden, ...entry.options.readOnly};
    for (final name in locked) {
      if (!entry.columns.any((c) => c.columnName == name)) continue;
      if (stored.containsKey(name)) {
        normalized[name] = stored[name];
      } else {
        normalized.remove(name);
      }
    }
  }

  Future<bool> delete(Session session, String resourceKey, String id) async {
    final entry = _entryFor(session, resourceKey, AdminOperation.delete);
    final (:deleted, :failures) = await _deleteRows(session, entry, [id]);
    await _recordDeleted(session, entry, deleted);
    // A row that is already gone counts as deleted.
    if (failures[id] case final message? when message != _gone(id)) {
      throw AdminValidationException(message: message);
    }
    return true;
  }

  /// The change history, newest first: everything, one resource's, or one
  /// row's when [recordId] is given too.
  Future<AdminLogPage> history(
    Session session,
    String? resourceKey,
    String? recordId,
    int offset,
    int limit,
  ) {
    final access = AdminAccess.of(session)..requireAllowed();
    adminRegister();
    if (resourceKey != null) {
      _entryFor(session, resourceKey, AdminOperation.view);
    }
    return AdminHistory.read(
      session,
      resourceKey: resourceKey,
      recordId: recordId,
      // Staff see the history of the tables they may see.
      resourceKeys: access.admin || resourceKey != null
          ? null
          : {
              for (final entry in _registry.registeredEntries)
                if (access.can(entry, AdminOperation.view)) entry.resourceKey,
            },
      offset: offset,
      limit: limit,
    );
  }

  /// The rows of every table the user may see that point at the row [id]
  /// of [resourceKey] through a foreign key: up to [limit] of each, with
  /// how many there are, in one request. [columns] gives, by table, the
  /// columns to return (all the user may see when not given).
  Future<List<AdminRelatedRows>> related(
    Session session,
    String resourceKey,
    String id,
    int limit,
    Map<String, List<String>>? columns,
  ) async {
    final entry = _entryFor(session, resourceKey, AdminOperation.view);
    final access = AdminAccess.of(session);
    final links = [
      for (final other in adminRegister())
        if (access.can(other, AdminOperation.view))
          for (final column in other.metadata.columns)
            if (column.foreignKeyTable == entry.tableName) (other, column.name),
    ];
    return Future.wait([
      for (final (other, column) in links)
        query(
          session,
          other.resourceKey,
          AdminQuery(
            offset: 0,
            limit: limit,
            sortDescending: false,
            filters: [
              AdminFilter(
                column: column,
                comparison: AdminFilterOperator.equals,
                value: id,
              ),
            ],
            columns: columns?[other.resourceKey],
          ),
        ).then(
          (page) => AdminRelatedRows(
            resourceKey: other.resourceKey,
            column: column,
            rows: page.rows,
            total: page.total,
          ),
        ),
    ]);
  }

  /// The signed-in user's saved views of [resourceKey], by name.
  Future<List<AdminSavedView>> savedViews(Session session, String resourceKey) {
    final entry = _entryFor(session, resourceKey, AdminOperation.view);
    return AdminSavedViews.list(
      session,
      owner: _owner(session),
      resourceKey: entry.resourceKey,
    );
  }

  /// Saves [query]'s search, sort and filters and the shown [columns] (null
  /// for the table's defaults) as the signed-in user's view [name] of
  /// [resourceKey], replacing their view of that name. Paging is not saved.
  Future<AdminSavedView> saveView(
    Session session,
    String resourceKey,
    String name,
    AdminQuery query,
    List<String>? columns,
  ) {
    final entry = _entryFor(session, resourceKey, AdminOperation.view);
    return AdminSavedViews.save(
      session,
      owner: _owner(session),
      entry: entry,
      name: name,
      query: query,
      columns: columns,
    );
  }

  /// Deletes the signed-in user's saved view [id]; false when they have no
  /// such view.
  Future<bool> deleteView(Session session, int id) {
    AdminAccess.of(session).requireAllowed();
    return AdminSavedViews.delete(session, owner: _owner(session), id: id);
  }

  String _owner(Session session) => session.authenticated!.userIdentifier;

  /// Deletes the rows with [ids], in one query unless the table deletes
  /// rows its own way, and records each; rows that cannot be deleted are
  /// counted in the message.
  Future<AdminActionResult> deleteMany(
    Session session,
    String resourceKey,
    List<String> ids,
  ) async {
    final entry = _entryFor(session, resourceKey, AdminOperation.delete);
    final (:deleted, :failures) = await _deleteRows(session, entry, ids);
    await _recordDeleted(session, entry, deleted);
    return _result(
      deleted.length,
      failures,
      done: 'Deleted ${deleted.length} ${_rows(deleted.length)}.',
    );
  }

  /// Deletes the rows with [ids]: in one query that returns them where the
  /// table allows (one by one when that fails, to tell which row failed),
  /// else one by one. Returns the deleted rows as text by id, and why the
  /// others were not deleted.
  Future<
    ({Map<String, Map<String, String>> deleted, Map<String, String> failures})
  >
  _deleteRows(Session session, AdminEntryBase entry, List<String> ids) async {
    final deleted = <String, Map<String, String>>{};
    final failures = <String, String>{};
    final parsed = {for (final id in ids) id: _parseId(entry, id)};
    List<Map<String, dynamic>>? batch;
    try {
      batch = await entry.deleteMany(session, parsed.values.toList());
    } catch (_) {
      batch = null;
    }
    if (batch != null) {
      for (final row in await _texts(session, entry, batch)) {
        deleted[_idOf(entry, row)] = row;
      }
      for (final id in ids) {
        if (!deleted.containsKey(id)) failures[id] = _gone(id);
      }
      return (deleted: deleted, failures: failures);
    }
    final stored = {
      for (final row in await _texts(
        session,
        entry,
        await entry.findMany(session, parsed.values.toList()),
      ))
        _idOf(entry, row): row,
    };
    for (final id in ids) {
      final before = stored[id];
      if (before == null) {
        failures[id] = _gone(id);
        continue;
      }
      try {
        await entry.delete(session, parsed[id]!);
        deleted[id] = before;
      } catch (error) {
        failures[id] = _reason(error);
      }
    }
    return (deleted: deleted, failures: failures);
  }

  Future<void> _recordDeleted(
    Session session,
    AdminEntryBase entry,
    Map<String, Map<String, String>> deleted,
  ) => AdminHistory.recordAll(
    session,
    resourceKey: entry.resourceKey,
    changes: [
      for (final MapEntry(key: id, value: before) in deleted.entries)
        AdminChange(
          recordId: id,
          action: AdminLogAction.deleted,
          before: before,
        ),
    ],
  );

  /// Sets [values] (column name to text, as the edit form sends them) on
  /// every row with [ids], through the same validation as a single edit:
  /// the rows are read in one query and saved in one query unless the table
  /// saves rows its own way.
  Future<AdminActionResult> updateMany(
    Session session,
    String resourceKey,
    List<String> ids,
    Map<String, String> values,
  ) async {
    final entry = _entryFor(session, resourceKey, AdminOperation.edit);
    final locked = values.keys.where(
      (key) =>
          entry.options.hidden.contains(key) ||
          entry.options.readOnly.contains(key),
    );
    if (locked.isNotEmpty) {
      throw AdminValidationException(
        field: locked.first,
        message: '${locked.first} cannot be changed here.',
      );
    }
    final primary = entry.table.id.columnName;
    if (values.containsKey(primary)) {
      throw AdminValidationException(
        field: primary,
        message: 'The primary key cannot be changed in bulk.',
      );
    }
    final (:changes, :failures) = await _saveMany(session, entry, {
      for (final id in ids) id: values,
    });
    await AdminHistory.recordAll(
      session,
      resourceKey: entry.resourceKey,
      changes: changes,
    );
    return _result(
      changes.length,
      failures,
      done: 'Updated ${changes.length} ${_rows(changes.length)}.',
    );
  }

  /// Sets the values of [changesById] (column name to text) on each row:
  /// the rows are read in one query, then valid ones saved in one query
  /// unless the table saves rows its own way (or a value changes access,
  /// checked row by row). Returns the changes to record and why other rows
  /// were not saved.
  Future<({List<AdminChange> changes, Map<String, String> failures})> _saveMany(
    Session session,
    AdminEntryBase entry,
    Map<String, Map<String, String>> changesById,
  ) async {
    final primary = entry.table.id.columnName;
    final failures = <String, String>{};
    final changes = <AdminChange>[];
    final stored = {
      for (final row in await entry.findMany(session, [
        for (final id in changesById.keys) _parseId(entry, id),
      ]))
        _stringifyValue(row[primary]): row,
    };
    final current = {
      for (final row in await _texts(session, entry, stored.values.toList()))
        _idOf(entry, row): row,
    };
    // Valid rows saved together.
    final pending = <({String id, Map<String, dynamic> row})>[];
    for (final MapEntry(key: id, value: values) in changesById.entries) {
      final row = stored[id];
      final before = current[id];
      if (row == null || before == null) {
        failures[id] = _gone(id);
        continue;
      }
      final data = {
        // Empty text stands for null; leaving it out keeps null values null.
        for (final MapEntry(:key, :value) in before.entries)
          if (value.isNotEmpty) key: value,
        ...values,
      };
      // Access changes are checked and saved row by row.
      if (values.keys.any(AdminAuthUserLink.isField)) {
        try {
          final saved = await _save(
            session,
            entry,
            data,
            stored: row,
            before: before,
          );
          changes.add(_updated(id, before, saved.after));
        } catch (error) {
          failures[id] = _reason(error);
        }
        continue;
      }
      try {
        final normalized = _normalizeUpdate(entry, data);
        _keepLocked(entry, normalized, row);
        _requireStorable(entry, normalized, stored: row);
        pending.add((id: id, row: normalized));
      } catch (error) {
        failures[id] = _reason(error);
      }
    }
    if (pending.isEmpty) return (changes: changes, failures: failures);
    List<Map<String, dynamic>>? saved;
    try {
      saved = await entry.updateMany(session, [
        for (final item in pending) item.row,
      ]);
    } catch (_) {
      saved = null;
    }
    if (saved != null) {
      final after = {
        for (final row in await _texts(session, entry, saved))
          _idOf(entry, row): row,
      };
      for (final item in pending) {
        if (after[item.id] case final row?) {
          changes.add(_updated(item.id, current[item.id]!, row));
        }
      }
      return (changes: changes, failures: failures);
    }
    // One by one, through the table's own save or to tell which row failed.
    for (final item in pending) {
      try {
        final updated = await entry.update(session, item.row);
        changes.add(
          _updated(
            item.id,
            current[item.id]!,
            await _text(session, entry, updated),
          ),
        );
      } catch (error) {
        failures[item.id] = _reason(error);
      }
    }
    return (changes: changes, failures: failures);
  }

  /// Imports [rows] as a spreadsheet does: rows without a primary key are
  /// created (in one query unless the table creates rows its own way) and
  /// rows with one update theirs (read in one query and saved in one query
  /// unless the table saves rows its own way), all in one request.
  Future<AdminImportResult> importRows(
    Session session,
    String resourceKey,
    List<Map<String, String>> rows,
  ) async {
    final access = AdminAccess.of(session)..requireAllowed();
    final entry = _resolve(resourceKey);
    access.require(entry, AdminOperation.view);
    final primary = entry.table.id.columnName;
    final known = {for (final column in entry.metadata.columns) column.name};
    final failures = <String>[];
    var skipped = 0;
    final creates = <({int line, Map<String, String> data})>[];
    final updates = <String, Map<String, String>>{};
    for (final (index, row) in rows.indexed) {
      final data = {
        for (final MapEntry(:key, :value) in row.entries)
          if (known.contains(key.trim()) && value.trim().isNotEmpty)
            key.trim(): value.trim(),
      };
      if (data.isEmpty) {
        skipped++;
      } else if (data[primary] case final id?) {
        updates[id] = data;
      } else {
        creates.add((line: index + 1, data: data));
      }
    }
    if (creates.isNotEmpty) access.require(entry, AdminOperation.create);
    if (updates.isNotEmpty) access.require(entry, AdminOperation.edit);

    final changes = <AdminChange>[];
    // New rows: checked one by one, inserted together.
    final valid = <({int line, Map<String, dynamic> row})>[];
    final oneByOne = <({int line, Map<String, String> data})>[];
    for (final item in creates) {
      if (item.data.keys.any(AdminAuthUserLink.isField)) {
        oneByOne.add(item);
        continue;
      }
      try {
        valid.add((line: item.line, row: _normalizeCreate(entry, item.data)));
      } catch (error) {
        failures.add('row ${item.line}: ${_reason(error)}');
      }
    }
    List<Map<String, dynamic>>? inserted;
    if (valid.isNotEmpty) {
      try {
        inserted = await entry.createMany(session, [
          for (final item in valid) item.row,
        ]);
      } catch (_) {
        inserted = null;
      }
    }
    if (inserted != null) {
      for (final row in await _texts(session, entry, inserted)) {
        changes.add(
          AdminChange(
            recordId: _idOf(entry, row),
            action: AdminLogAction.created,
            after: row,
          ),
        );
      }
    } else {
      oneByOne.addAll([
        for (final item in valid)
          (
            line: item.line,
            data: creates.firstWhere((c) => c.line == item.line).data,
          ),
      ]);
    }
    for (final item in oneByOne) {
      try {
        final row = await _create(session, entry, item.data);
        changes.add(
          AdminChange(
            recordId: _idOf(entry, row),
            action: AdminLogAction.created,
            after: row,
          ),
        );
      } catch (error) {
        failures.add('row ${item.line}: ${_reason(error)}');
      }
    }
    final created = changes.length;

    final saved = await _saveMany(session, entry, updates);
    changes.addAll(saved.changes);
    failures.addAll([
      for (final MapEntry(key: id, value: reason) in saved.failures.entries)
        '$id: $reason',
    ]);
    await AdminHistory.recordAll(
      session,
      resourceKey: entry.resourceKey,
      changes: changes,
    );
    return AdminImportResult(
      created: created,
      // Rows whose values were already stored count as updated.
      updated: updates.length - saved.failures.length,
      skipped: skipped,
      failures: failures,
    );
  }

  /// Every row matching [query] (its search, filters and order) up to
  /// [maxRows], for exports, in one query.
  Future<List<Map<String, String>>> exportRows(
    Session session,
    String resourceKey,
    AdminQuery query,
    int maxRows,
  ) async {
    final entry = _entryFor(session, resourceKey, AdminOperation.view);
    final page = await _page(
      session,
      entry,
      query.copyWith(
        offset: 0,
        limit: maxRows.clamp(1, adminMaxExportRows),
        countTotal: false,
      ),
    );
    return page.rows;
  }

  /// The primary keys of the rows matching [query] up to [maxRows], to
  /// select them all, in one query reading only the keys.
  Future<List<String>> matchingIds(
    Session session,
    String resourceKey,
    AdminQuery query,
    int maxRows,
  ) async {
    final entry = _entryFor(session, resourceKey, AdminOperation.view);
    final bounded = query.copyWith(
      offset: 0,
      limit: maxRows.clamp(1, adminMaxExportRows),
      countTotal: false,
    );
    final ids = await entry.queryIds(session, bounded);
    if (ids != null) return ids;
    final page = await _page(
      session,
      entry,
      bounded.copyWith(columns: const []),
    );
    return [for (final row in page.rows) _idOf(entry, row)];
  }

  static AdminChange _updated(
    String id,
    Map<String, String> before,
    Map<String, String> after,
  ) => AdminChange(
    recordId: id,
    action: AdminLogAction.updated,
    before: before,
    after: after,
  );

  /// Runs the custom action [name] (registered with `actions:`) on the rows
  /// with [ids], and records it in each row's history.
  Future<AdminActionResult> runAction(
    Session session,
    String resourceKey,
    String name,
    List<String> ids,
  ) async {
    final entry = _entryFor(session, resourceKey, AdminOperation.edit);
    final info = entry.actionInfos.where((a) => a.name == name).firstOrNull;
    if (info == null) {
      throw AdminValidationException(message: 'Unknown action $name.');
    }
    final message = await entry.runAction(session, name, [
      for (final id in ids) _parseId(entry, id),
    ]);
    await AdminHistory.recordAll(
      session,
      resourceKey: entry.resourceKey,
      changes: [
        for (final id in ids)
          AdminChange(
            recordId: id,
            action: AdminLogAction.action,
            summary: info.label,
          ),
      ],
    );
    return AdminActionResult(affected: ids.length, message: message);
  }

  /// What a bulk change did: [done], then how many rows failed and why.
  static AdminActionResult _result(
    int changed,
    Map<String, String> failures, {
    required String done,
  }) {
    final reasons = [
      for (final MapEntry(key: id, value: reason) in failures.entries)
        '$id: $reason',
    ];
    final message = reasons.isEmpty
        ? done
        : '$done ${reasons.length} failed (${reasons.take(3).join('; ')}'
              '${reasons.length > 3 ? '; …' : ''}).';
    return AdminActionResult(affected: changed, message: message);
  }

  static String _gone(String id) => 'Row $id no longer exists.';

  static String _reason(Object error) => switch (error) {
    AdminValidationException(:final message) => message,
    ArgumentError(:final message) => '$message',
    _ => '$error',
  };

  static String _rows(int count) => count == 1 ? 'row' : 'rows';

  /// A row as the dashboard shows it, with its auth user's access.
  Future<Map<String, String>> _text(
    Session session,
    AdminEntryBase entry,
    Map<String, dynamic> row,
  ) async => (await _texts(session, entry, [row])).single;

  /// Rows as the dashboard shows them, their auth users read in one query.
  Future<List<Map<String, String>>> _texts(
    Session session,
    AdminEntryBase entry,
    List<Map<String, dynamic>> rows,
  ) async => _visibleRows(entry, await _withAuthUsers(session, entry, rows));

  /// Rows as text, without the resource's hidden columns, and with only
  /// the columns in [only] when given.
  List<Map<String, String>> _visibleRows(
    AdminEntryBase entry,
    List<Map<String, dynamic>> rows, {
    Set<String>? only,
  }) {
    final hidden = entry.options.hidden;
    bool shown(String key) =>
        key != _classNameKey &&
        !hidden.contains(key) &&
        (only == null || only.contains(key));
    return [
      for (final row in rows)
        {
          for (final MapEntry(:key, :value) in row.entries)
            if (shown(key)) key: _stringifyValue(value),
        },
    ];
  }

  String _idOf(AdminEntryBase entry, Map<String, String> row) =>
      row[entry.table.id.columnName] ?? '';

  /// [id] as the primary key column stores it.
  Object _parseId(AdminEntryBase entry, String id) {
    final column = entry.columns.firstWhere(
      (column) => column.columnName == entry.table.id.columnName,
      orElse: () => entry.columns.first,
    );
    return parseAdminColumnValue(column, id) ?? id;
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
