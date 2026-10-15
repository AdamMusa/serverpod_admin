import 'package:serverpod/serverpod.dart';
import 'package:serverpod/protocol.dart' show ReadWriteTestEntry;
import 'package:serverpod_admin_server/serverpod_admin_server.dart';
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
        registry.register<ReadWriteTestEntry>(
          table: ReadWriteTestEntry.t,
          fromJson: ReadWriteTestEntry.fromJson,
          resourceKey: 'counters',
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

    test('a list page is read in the database', () async {
      final (rows, queries) = await measure(
        () => endpoints.admin.listPage(admin, 'counters', 5, 5),
      );
      expect(rows, hasLength(5));
      expect(queries, 1, reason: '${QueryCounter.calls}');
    });
  }, databaseInterceptor: QueryCounter.intercept);
}
