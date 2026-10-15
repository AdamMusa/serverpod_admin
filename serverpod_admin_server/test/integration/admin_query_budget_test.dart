import 'package:serverpod/serverpod.dart';
import 'package:serverpod/protocol.dart'
    show FutureCallEntry, ReadWriteTestEntry, SessionLogEntry;
import 'package:serverpod_admin_server/serverpod_admin_server.dart';
import 'package:serverpod_admin_server/src/admin/admin_overview.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    show AuthUser, UserProfile;
import 'package:test/test.dart';

import 'query_counter.dart';
import 'test_tools/serverpod_test_tools.dart';

/// Endpoint methods make a fixed number of database queries, however many
/// rows they read or change.
void main() {
  withServerpod('Given the admin endpoint', (sessionBuilder, endpoints) {
    setUpAll(() {
      configureAdminModule((registry) {
        registry.registerAuthUsers();
        registry.registerServerpodJobs();
        registry.register<ReadWriteTestEntry>(
          table: ReadWriteTestEntry.t,
          fromJson: ReadWriteTestEntry.fromJson,
          resourceKey: 'counters',
          actions: [
            AdminAction(
              name: 'count',
              label: 'Count',
              run: (session, rows) async => '${rows.length} rows',
            ),
          ],
        );
        // Saves and deletes through its own hooks, one row at a time.
        registry.register<SessionLogEntry>(
          table: SessionLogEntry.t,
          fromJson: SessionLogEntry.fromJson,
          resourceKey: 'sessions',
          updateRow: (session, row) => SessionLogEntry.db.updateRow(
            session,
            row.copyWith(module: 'hooked'),
          ),
          deleteById: (session, id) => SessionLogEntry.db.deleteWhere(
            session,
            where: (t) => t.id.equals(id as int),
          ),
        );
        registry.register<UserProfile>(
          table: UserProfile.t,
          fromJson: UserProfile.fromJson,
          resourceKey: 'profiles',
        );
      });
    });
    tearDownAll(() => AdminRegistry().reset());

    final admin = sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        '00000000-0000-0000-0000-000000000001',
        {Scope.admin},
      ),
    );

    AdminQuery page({
      int offset = 0,
      int limit = 10,
      List<AdminFilter> filters = const [],
      List<String>? columns,
      bool? countTotal,
    }) => AdminQuery(
      offset: offset,
      limit: limit,
      sortDescending: false,
      filters: filters,
      columns: columns,
      countTotal: countTotal,
    );

    late List<ReadWriteTestEntry> counters;
    late List<UserProfile> profiles;

    setUp(() async {
      final db = sessionBuilder.build();
      counters = await ReadWriteTestEntry.db.insert(db, [
        for (var i = 0; i < 30; i++) ReadWriteTestEntry(number: i),
      ]);
      profiles = [
        for (var i = 0; i < 6; i++)
          await UserProfile.db.insertRow(
            db,
            UserProfile(
              authUserId: (await AuthUser.db.insertRow(
                db,
                AuthUser(scopeNames: {'s$i'}, blocked: i.isEven),
              )).id!,
              fullName: 'User $i',
            ),
          ),
      ];
    });

    Future<(T, int)> measure<T>(Future<T> Function() call) =>
        QueryCounter.measure(call);

    group('a page', () {
      test('is counted only when full', () async {
        final (full, fullQueries) = await measure(
          () => endpoints.admin.query(admin, 'counters', page(limit: 10)),
        );
        expect(full.rows, hasLength(10));
        expect(full.total, 30);
        expect(fullQueries, 2, reason: '${QueryCounter.calls}');

        final (last, lastQueries) = await measure(
          () => endpoints.admin.query(
            admin,
            'counters',
            page(offset: 25, limit: 10),
          ),
        );
        expect(last.rows, hasLength(5));
        expect(last.total, 30);
        expect(lastQueries, 1, reason: '${QueryCounter.calls}');

        // Past the last page, the count says where the rows end.
        final (past, _) = await measure(
          () => endpoints.admin.query(
            admin,
            'counters',
            page(offset: 40, limit: 10),
          ),
        );
        expect(past.rows, isEmpty);
        expect(past.total, 30);
      });

      test('skips the count when asked to', () async {
        final (lookup, queries) = await measure(
          () => endpoints.admin.query(
            admin,
            'counters',
            page(
              limit: 1,
              countTotal: false,
              filters: [
                AdminFilter(
                  column: 'id',
                  comparison: AdminFilterOperator.equals,
                  value: '${counters.first.id}',
                ),
              ],
            ),
          ),
        );
        expect(lookup.rows.single['id'], '${counters.first.id}');
        expect(lookup.total, -1);
        expect(queries, 1, reason: '${QueryCounter.calls}');
      });

      test('returns only the columns asked for, with the key', () async {
        final (result, _) = await measure(
          () => endpoints.admin.query(
            admin,
            'profiles',
            page(columns: ['fullName']),
          ),
        );
        expect(result.rows, hasLength(6));
        for (final row in result.rows) {
          expect(row.keys.toSet(), {'id', 'fullName'});
        }
      });

      test('reads auth users only when their columns are shown', () async {
        final (_, without) = await measure(
          () => endpoints.admin.query(
            admin,
            'profiles',
            page(columns: ['fullName']),
          ),
        );
        expect(without, 1, reason: '${QueryCounter.calls}');

        final (shown, withUsers) = await measure(
          () => endpoints.admin.query(
            admin,
            'profiles',
            page(columns: ['fullName', 'authUser.blocked']),
          ),
        );
        expect(withUsers, 2, reason: '${QueryCounter.calls}');
        final first = shown.rows.firstWhere(
          (r) => r['id'] == '${profiles.first.id}',
        );
        expect(first['authUser.blocked'], 'true');
        expect(first.containsKey('authUser.scopeNames'), isFalse);
      });
    });

    test('rows are filtered by their auth user in the database', () async {
      AdminFilter on(
        String column,
        AdminFilterOperator comparison, [
        String? value,
      ]) => AdminFilter(column: column, comparison: comparison, value: value);
      Future<List<String?>> names(AdminFilter filter) async {
        final (result, queries) = await measure(
          () =>
              endpoints.admin.query(admin, 'profiles', page(filters: [filter])),
        );
        // The page and its rows' auth users, never the whole table.
        expect(queries, lessThanOrEqualTo(2), reason: '${QueryCounter.calls}');
        return [for (final row in result.rows) row['fullName']]..sort();
      }

      expect(
        await names(on('authUser.blocked', AdminFilterOperator.equals, 'true')),
        ['User 0', 'User 2', 'User 4'],
      );
      expect(
        await names(
          on('authUser.blocked', AdminFilterOperator.notEquals, 'true'),
        ),
        ['User 1', 'User 3', 'User 5'],
      );
      expect(
        await names(
          on('authUser.scopeNames', AdminFilterOperator.contains, 's3'),
        ),
        ['User 3'],
      );
      expect(
        await names(on('authUser.scopeNames', AdminFilterOperator.isEmpty)),
        isEmpty,
      );
    });

    test('auth users are paged in the database, newest first', () async {
      final (result, queries) = await measure(
        () => endpoints.admin.query(
          admin,
          'serverpod_auth_core_user',
          page(
            filters: [
              AdminFilter(
                column: 'blocked',
                comparison: AdminFilterOperator.equals,
                value: 'true',
              ),
            ],
          ),
        ),
      );
      expect(queries, 1, reason: '${QueryCounter.calls}');
      expect(result.total, 3);
      expect(result.rows.first['id'], '${profiles[4].authUserId}');
      final users = (await endpoints.admin.resources(
        admin,
      )).firstWhere((r) => r.key == 'serverpod_auth_core_user');
      expect((users.canCreate, users.canDelete), (false, false));
    });

    test('jobs are listed next first, in one query', () async {
      final now = DateTime.now().toUtc();
      await FutureCallEntry.db.insert(sessionBuilder.build(), [
        for (final hours in [3, 1, 2])
          FutureCallEntry(
            name: 'job$hours',
            time: now.add(Duration(hours: hours)),
            serverId: 'test',
          ),
      ]);
      final (rows, queries) = await measure(
        () => endpoints.admin.list(admin, 'serverpod_future_call'),
      );
      expect(queries, 1, reason: '${QueryCounter.calls}');
      expect([for (final r in rows) r['name']], ['job1', 'job2', 'job3']);
    });

    group('changes', () {
      Future<List<AdminLogEntry>> history(String resourceKey) async =>
          (await endpoints.admin.history(
            admin,
            resourceKey,
            null,
            0,
            200,
          )).entries;
      List<String> ids(Iterable<ReadWriteTestEntry> rows) => [
        for (final row in rows) '${row.id}',
      ];

      test('one row is deleted in one query, and recorded', () async {
        final (_, queries) = await measure(
          () => endpoints.admin.delete(admin, 'counters', '${counters[0].id}'),
        );
        expect(queries, 2, reason: '${QueryCounter.calls}');
        final entry = (await history('counters')).first;
        expect(
          (entry.recordId, entry.action),
          ('${counters[0].id}', AdminLogAction.deleted),
        );
        expect(entry.changes, contains('"number":"0"'));
        // A row already gone counts as deleted.
        await endpoints.admin.delete(admin, 'counters', '${counters[0].id}');
      });

      test('deleting many rows takes two queries', () async {
        final chosen = [...ids(counters.take(10)), '999999'];
        final (result, queries) = await measure(
          () => endpoints.admin.deleteMany(admin, 'counters', chosen),
        );
        expect(queries, 2, reason: '${QueryCounter.calls}');
        expect(result.affected, 10);
        expect(result.message, contains('1 failed'));
        expect(await ReadWriteTestEntry.db.count(sessionBuilder.build()), 20);
        final deleted = await history('counters');
        expect(
          deleted.where((e) => e.action == AdminLogAction.deleted),
          hasLength(10),
        );
      });

      test('updating many rows takes three queries', () async {
        final (result, queries) = await measure(
          () => endpoints.admin.updateMany(
            admin,
            'counters',
            ids(counters.take(10)),
            {'number': '7'},
          ),
        );
        expect(queries, 3, reason: '${QueryCounter.calls}');
        expect(result.affected, 10);
        final stored = await ReadWriteTestEntry.db.find(
          sessionBuilder.build(),
          where: (t) => t.number.equals(7),
        );
        expect(stored, hasLength(10));
        final updated = (await history(
          'counters',
        )).where((e) => e.action == AdminLogAction.updated);
        // The counter that already held 7 did not change.
        expect(updated, hasLength(9));
      });

      test('an action reads its rows in one query', () async {
        final (result, queries) = await measure(
          () => endpoints.admin.runAction(
            admin,
            'counters',
            'count',
            ids(counters.take(10)),
          ),
        );
        expect(queries, 2, reason: '${QueryCounter.calls}');
        expect(result.message, '10 rows');
        expect(
          (await history(
            'counters',
          )).where((e) => e.action == AdminLogAction.action),
          hasLength(10),
        );
      });

      test('a table with its own hooks reads its rows in one query', () async {
        final rows = await SessionLogEntry.db.insert(sessionBuilder.build(), [
          for (var i = 0; i < 5; i++)
            SessionLogEntry(
              serverId: 'a',
              time: DateTime.now().toUtc(),
              touched: DateTime.now().toUtc(),
              endpoint: 'e$i',
            ),
        ]);
        final chosen = [for (final row in rows) '${row.id}'];
        final (updated, updates) = await measure(
          () => endpoints.admin.updateMany(admin, 'sessions', chosen, {
            'endpoint': 'bulk',
          }),
        );
        expect(updated.affected, 5);
        // One read, its hook for each row, one history insert.
        expect(updates, 1 + 5 + 1, reason: '${QueryCounter.calls}');
        final saved = await SessionLogEntry.db.find(
          sessionBuilder.build(),
          where: (t) => t.endpoint.equals('bulk'),
        );
        expect({for (final row in saved) row.module}, {'hooked'});

        final (deleted, deletes) = await measure(
          () => endpoints.admin.deleteMany(admin, 'sessions', chosen),
        );
        expect(deleted.affected, 5);
        expect(deletes, 1 + 5 + 1, reason: '${QueryCounter.calls}');
      });
    });

    test('the overview takes two queries for every table', () async {
      final now = DateTime.now().toUtc();
      await SessionLogEntry.db.insert(sessionBuilder.build(), [
        for (final days in [0, 0, 2, 40])
          SessionLogEntry(
            serverId: 'a',
            time: now.subtract(Duration(days: days)),
            touched: now,
          ),
      ]);
      final (summaries, queries) = await measure(
        () => endpoints.admin.overview(admin, 30),
      );
      expect(queries, 2, reason: '${QueryCounter.calls}');
      final byKey = {for (final s in summaries) s.resourceKey: s};
      expect(byKey.keys, containsAll(['counters', 'profiles', 'sessions']));
      expect(
        (byKey['counters']!.count, byKey['counters']!.estimated),
        (30, false),
      );
      expect(byKey['profiles']!.count, 6);
      expect(byKey['counters']!.activity, isEmpty);
      final sessions = byKey['sessions']!;
      expect(sessions.count, 4);
      // Rows of the last 30 days, by day, oldest first.
      expect([for (final p in sessions.activity) p.count], [1, 2]);
      expect(
        sessions.activity.first.day.isBefore(sessions.activity.last.day),
        isTrue,
      );
      // The same numbers as the single-table call.
      final single = await endpoints.admin.activity(admin, 'sessions', 30);
      expect([for (final p in single) p.count], [1, 2]);
    });

    test('large tables are estimated, not counted', () async {
      AdminOverview.exactCountLimit = 10;
      addTearDown(() => AdminOverview.exactCountLimit = 100000);
      final summaries = await endpoints.admin.overview(admin, 30);
      final counters = summaries.firstWhere((s) => s.resourceKey == 'counters');
      expect(counters.estimated, isTrue);
      expect(counters.count, greaterThan(10));
      final profiles = summaries.firstWhere((s) => s.resourceKey == 'profiles');
      expect((profiles.count, profiles.estimated), (6, false));
    });

    test('a list page is read in the database', () async {
      final (rows, queries) = await measure(
        () => endpoints.admin.listPage(admin, 'counters', 5, 5),
      );
      expect(rows, hasLength(5));
      expect(queries, 1, reason: '${QueryCounter.calls}');
    });
  }, databaseInterceptor: QueryCounter.intercept);
}
