import 'package:serverpod/serverpod.dart';
import 'package:serverpod/protocol.dart'
    show ReadWriteTestEntry, SessionLogEntry;
import 'package:serverpod_admin_server/serverpod_admin_server.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    show AuthUser, UserProfile;
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

const _support = Scope('support');

Matcher _refused(String message) => throwsA(
  isA<AdminValidationException>().having((e) => e.message, 'message', message),
);

void main() {
  withServerpod('Given tables registered with admin options', (
    sessionBuilder,
    endpoints,
  ) {
    setUpAll(() {
      configureAdminModule((registry) {
        registry.staffScopes = {_support};
        registry.register<SessionLogEntry>(
          table: SessionLogEntry.t,
          fromJson: SessionLogEntry.fromJson,
          resourceKey: 'sessions',
          options: AdminOptions(
            label: 'Sessions',
            group: 'Logs',
            listColumns: ['id', 'endpoint', 'time'],
            ordering: 'time',
            readOnly: {'serverId'},
            hidden: {'stackTrace'},
            labels: const {'endpoint': 'Endpoint name'},
            help: {'slow': 'Took longer than the slow-query limit.'},
            canCreate: false,
            fieldsets: const [
              AdminFieldset(fields: ['endpoint', 'method', 'stackTrace']),
              AdminFieldset(
                name: 'Timing',
                fields: ['time', 'duration', 'unknown', 'endpoint'],
                description: 'When the call ran.',
                collapsed: true,
              ),
              AdminFieldset(name: 'Nothing visible', fields: ['stackTrace']),
            ],
            permissions: AdminPermissions(view: {_support}, edit: {_support}),
          ),
        );
        registry.register<UserProfile>(
          table: UserProfile.t,
          fromJson: UserProfile.fromJson,
          resourceKey: 'profiles',
          options: AdminOptions(
            permissions: AdminPermissions(view: {_support}, edit: {_support}),
          ),
        );
        registry.register<ReadWriteTestEntry>(
          table: ReadWriteTestEntry.t,
          fromJson: ReadWriteTestEntry.fromJson,
          resourceKey: 'counters',
        );
        registry.registerMetric(
          AdminMetric(
            label: 'Counters',
            hint: 'all time',
            compute: (session) async =>
                '${await ReadWriteTestEntry.db.count(session)}',
          ),
        );
        registry.registerMetric(
          AdminMetric(label: 'Broken', compute: (_) async => throw 'down'),
        );
        registry.registerMetric(
          AdminMetric(
            label: 'Open tickets',
            scopes: {_support},
            compute: (_) async => '7',
          ),
        );
      });
      adminRegister();
    });

    tearDownAll(() => AdminRegistry().reset());

    final admin = sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        '00000000-0000-0000-0000-000000000001',
        {Scope.admin},
      ),
    );
    final support = sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        '00000000-0000-0000-0000-000000000002',
        {_support},
      ),
    );
    final nobody = sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        '00000000-0000-0000-0000-000000000003',
        {},
      ),
    );

    Future<SessionLogEntry> session({
      required String endpoint,
      DateTime? time,
      String stackTrace = 'secret-trace',
    }) => SessionLogEntry.db.insertRow(
      sessionBuilder.build(),
      SessionLogEntry(
        serverId: 'server-a',
        time: time ?? DateTime.now().toUtc(),
        touched: DateTime.now().toUtc(),
        endpoint: endpoint,
        stackTrace: stackTrace,
      ),
    );

    AdminQuery query({List<AdminFilter> filters = const [], String? search}) =>
        AdminQuery(
          offset: 0,
          limit: 50,
          sortDescending: true,
          filters: filters,
          search: search,
        );

    AdminFilter endpointIs(String endpoint) => AdminFilter(
      column: 'endpoint',
      comparison: AdminFilterOperator.equals,
      value: endpoint,
    );

    test('the resource describes its options', () async {
      final resources = await endpoints.admin.resources(admin);
      final sessions = resources.firstWhere((r) => r.key == 'sessions');
      expect(sessions.label, 'Sessions');
      expect(sessions.group, 'Logs');
      expect(sessions.listColumns, ['id', 'endpoint', 'time']);
      expect(sessions.sortColumn, 'time');
      expect(sessions.sortDescending, isFalse);
      expect(sessions.canCreate, isFalse);
      expect(sessions.canEdit, isNull);
      expect(sessions.canDelete, isNull);
      expect(sessions.chartColumn, 'time');

      AdminColumn column(String name) =>
          sessions.columns.firstWhere((c) => c.name == name);
      expect(sessions.columns.any((c) => c.name == 'stackTrace'), isFalse);
      expect(column('endpoint').label, 'Endpoint name');
      expect(column('slow').help, 'Took longer than the slow-query limit.');
      expect(column('serverId').readOnly, isTrue);
      expect(column('endpoint').readOnly, isNull);
    });

    test('fieldsets group the visible columns, the rest under Other', () async {
      final resources = await endpoints.admin.resources(admin);
      final sessions = resources.firstWhere((r) => r.key == 'sessions');
      final fieldsets = sessions.fieldsets!;
      expect(
        [for (final f in fieldsets) (f.name, f.description, f.collapsed)],
        [
          (null, null, false),
          ('Timing', 'When the call ran.', true),
          ('Other', null, false),
        ],
      );
      // Hidden, unknown and repeated names are left out.
      expect(fieldsets[0].fields, ['endpoint', 'method']);
      expect(fieldsets[1].fields, ['time', 'duration']);
      expect(fieldsets[2].fields, [
        for (final column in sessions.columns)
          if (!column.isPrimary &&
              !{'endpoint', 'method', 'time', 'duration'}.contains(column.name))
            column.name,
      ]);
      expect(fieldsets[2].fields, isNot(contains('stackTrace')));

      // Without fieldsets, forms list every column.
      final counters = resources.firstWhere((r) => r.key == 'counters');
      expect(counters.fieldsets, isNull);
    });

    test('access says who may open the dashboard', () async {
      final asAdmin = await endpoints.admin.access(admin);
      expect((asAdmin.allowed, asAdmin.admin), (true, true));
      final asSupport = await endpoints.admin.access(support);
      expect((asSupport.allowed, asSupport.admin), (true, false));
      final asNobody = await endpoints.admin.access(nobody);
      expect((asNobody.allowed, asNobody.admin), (false, false));
      expect(
        () => endpoints.admin.resources(nobody),
        _refused('You do not have access to this.'),
      );
    });

    test('staff see only the tables their scopes are granted', () async {
      final resources = await endpoints.admin.resources(support);
      expect([for (final r in resources) r.key], ['sessions', 'profiles']);
      final sessions = resources.first;
      expect(sessions.canCreate, isFalse);
      expect(sessions.canEdit, isNull);
      expect(sessions.canDelete, isFalse);

      expect(
        () => endpoints.admin.query(support, 'counters', query()),
        _refused('You do not have access to this.'),
      );
      expect(
        () => endpoints.admin.futureCallHistory(support),
        _refused('You do not have access to this.'),
      );
    });

    test('staff may edit but not delete what they are not granted', () async {
      final row = await session(endpoint: 'staff-edit');
      final stored = await endpoints.admin.find(
        support,
        'sessions',
        '${row.id}',
      );
      expect(stored, isNotNull);
      await endpoints.admin.update(support, 'sessions', {
        'id': '${row.id}',
        'serverId': 'server-a',
        'time': row.time.toIso8601String(),
        'touched': row.touched.toIso8601String(),
        'endpoint': 'staff-edited',
      });
      expect(
        (await SessionLogEntry.db.findById(
          sessionBuilder.build(),
          row.id!,
        ))?.endpoint,
        'staff-edited',
      );
      expect(
        () => endpoints.admin.delete(support, 'sessions', '${row.id}'),
        _refused('You do not have access to this.'),
      );
      expect(
        () => endpoints.admin.deleteMany(support, 'sessions', ['${row.id}']),
        _refused('You do not have access to this.'),
      );
    });

    test('a table that cannot be created refuses even admins', () async {
      expect(
        () => endpoints.admin.create(admin, 'sessions', {
          'serverId': 'server-a',
          'time': DateTime.now().toUtc().toIso8601String(),
          'touched': DateTime.now().toUtc().toIso8601String(),
        }),
        _refused('Sessions cannot be created here.'),
      );
    });

    test('hidden columns never leave the server', () async {
      final row = await session(endpoint: 'hidden-check');
      final found = await endpoints.admin.find(admin, 'sessions', '${row.id}');
      expect(found, isNot(contains('stackTrace')));

      final page = await endpoints.admin.query(
        admin,
        'sessions',
        query(filters: [endpointIs('hidden-check')]),
      );
      expect(page.total, 1);
      expect(page.rows.single, isNot(contains('stackTrace')));

      final searched = await endpoints.admin.query(
        admin,
        'sessions',
        query(search: 'secret-trace'),
      );
      expect(searched.total, 0);
      expect(
        () => endpoints.admin.query(
          admin,
          'sessions',
          query(
            filters: [
              AdminFilter(
                column: 'stackTrace',
                comparison: AdminFilterOperator.isNotEmpty,
              ),
            ],
          ),
        ),
        throwsA(isA<AdminValidationException>()),
      );
    });

    test('edits keep hidden and read-only values', () async {
      final row = await session(endpoint: 'locked');
      await endpoints.admin.update(admin, 'sessions', {
        'id': '${row.id}',
        'serverId': 'server-b',
        'stackTrace': 'replaced',
        'time': row.time.toIso8601String(),
        'touched': row.touched.toIso8601String(),
        'endpoint': 'unlocked',
      });
      final stored = await SessionLogEntry.db.findById(
        sessionBuilder.build(),
        row.id!,
      );
      expect(stored?.endpoint, 'unlocked');
      expect(stored?.serverId, 'server-a');
      expect(stored?.stackTrace, 'secret-trace');

      expect(
        () => endpoints.admin.updateMany(
          admin,
          'sessions',
          ['${row.id}'],
          {'serverId': 'server-c'},
        ),
        _refused('serverId cannot be changed here.'),
      );
      expect(
        () => endpoints.admin.updateMany(
          admin,
          'sessions',
          ['${row.id}'],
          {'stackTrace': 'x'},
        ),
        _refused('stackTrace cannot be changed here.'),
      );
    });

    test('rows follow the default ordering until another is chosen', () async {
      final now = DateTime.now().toUtc();
      final older = await session(
        endpoint: 'ordered',
        time: now.subtract(const Duration(hours: 2)),
      );
      final newer = await session(endpoint: 'ordered', time: now);
      final page = await endpoints.admin.query(
        admin,
        'sessions',
        query(filters: [endpointIs('ordered')]),
      );
      expect(
        [for (final r in page.rows) r['id']],
        ['${older.id}', '${newer.id}'],
      );

      final chosen = await endpoints.admin.query(
        admin,
        'sessions',
        query(filters: [endpointIs('ordered')]).copyWith(sortColumn: 'id'),
      );
      expect(
        [for (final r in chosen.rows) r['id']],
        ['${newer.id}', '${older.id}'],
      );
    });

    test('metrics show what each user may see', () async {
      final forAdmin = await endpoints.admin.metrics(admin);
      expect(
        [for (final m in forAdmin) (m.label, m.value, m.hint)],
        [
          (
            'Counters',
            '${await ReadWriteTestEntry.db.count(sessionBuilder.build())}',
            'all time',
          ),
          ('Broken', '—', null),
          ('Open tickets', '7', null),
        ],
      );
      final forSupport = await endpoints.admin.metrics(support);
      expect([for (final m in forSupport) m.label], ['Open tickets']);
      expect(
        () => endpoints.admin.metrics(nobody),
        _refused('You do not have access to this.'),
      );
    });

    test('activity counts rows added per day', () async {
      int total(List<AdminActivityPoint> points) =>
          points.fold(0, (sum, p) => sum + p.count);
      final before = await endpoints.admin.activity(admin, 'sessions', 30);
      final now = DateTime.now().toUtc();
      await session(endpoint: 'chart');
      await session(endpoint: 'chart');
      await session(
        endpoint: 'chart',
        time: now.subtract(const Duration(days: 3)),
      );
      await session(
        endpoint: 'chart',
        time: now.subtract(const Duration(days: 90)),
      );

      final after = await endpoints.admin.activity(support, 'sessions', 30);
      expect(total(after) - total(before), 3);
      final today = after.lastWhere(
        (p) =>
            p.day.year == now.year &&
            p.day.month == now.month &&
            p.day.day == now.day,
      );
      final todayBefore = before
          .where((p) => p.day == today.day)
          .fold(0, (sum, p) => sum + p.count);
      expect(today.count - todayBefore, 2);

      // A table without a date column has nothing to chart.
      expect(await endpoints.admin.activity(admin, 'counters', 30), isEmpty);
      expect(
        () => endpoints.admin.activity(support, 'counters', 30),
        _refused('You do not have access to this.'),
      );
    });

    test('only administrators change who may sign in', () async {
      final db = sessionBuilder.build();
      final user = await AuthUser.db.insertRow(
        db,
        AuthUser(scopeNames: {'support'}),
      );
      final profile = await UserProfile.db.insertRow(
        db,
        UserProfile(authUserId: user.id!, fullName: 'Awa'),
      );
      Map<String, String> edit(Map<String, String> values) => {
        'id': '${profile.id}',
        'authUserId': '${user.id}',
        'createdAt': profile.createdAt.toIso8601String(),
        ...values,
      };

      // Staff may edit the profile itself.
      await endpoints.admin.update(
        support,
        'profiles',
        edit({'fullName': 'Awa Diallo', 'authUser.scopeNames': '["support"]'}),
      );
      expect(
        (await UserProfile.db.findById(db, profile.id!))?.fullName,
        'Awa Diallo',
      );
      await expectLater(
        () => endpoints.admin.update(
          support,
          'profiles',
          edit({'authUser.scopeNames': '["serverpod.admin", "support"]'}),
        ),
        _refused('Only administrators can change who may sign in.'),
      );
      await expectLater(
        () => endpoints.admin.update(
          support,
          'profiles',
          edit({'authUser.blocked': 'true'}),
        ),
        _refused('Only administrators can change who may sign in.'),
      );
      expect((await AuthUser.db.findById(db, user.id!))?.scopeNames, {
        'support',
      });

      await endpoints.admin.update(
        admin,
        'profiles',
        edit({'authUser.blocked': 'true'}),
      );
      expect((await AuthUser.db.findById(db, user.id!))?.blocked, isTrue);
    });

    test('staff see the history of the tables they may see', () async {
      final row = await session(endpoint: 'history');
      await endpoints.admin.update(admin, 'sessions', {
        'id': '${row.id}',
        'serverId': 'server-a',
        'time': row.time.toIso8601String(),
        'touched': row.touched.toIso8601String(),
        'endpoint': 'history-edited',
      });
      final counter = await ReadWriteTestEntry.db.insertRow(
        sessionBuilder.build(),
        ReadWriteTestEntry(number: 1),
      );
      await endpoints.admin.update(admin, 'counters', {
        'id': '${counter.id}',
        'number': '2',
      });

      final everything = await endpoints.admin.history(
        admin,
        null,
        null,
        0,
        50,
      );
      expect({
        for (final e in everything.entries) e.resourceKey,
      }, containsAll(['sessions', 'counters']));
      final forSupport = await endpoints.admin.history(
        support,
        null,
        null,
        0,
        50,
      );
      expect({for (final e in forSupport.entries) e.resourceKey}, {'sessions'});
      final change = forSupport.entries.firstWhere(
        (e) => e.recordId == '${row.id}',
      );
      expect(change.changes, isNot(contains('secret-trace')));
      expect(
        () => endpoints.admin.history(support, 'counters', null, 0, 50),
        _refused('You do not have access to this.'),
      );
    });
  });
}
