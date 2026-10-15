import 'package:serverpod/serverpod.dart';
import 'package:serverpod/protocol.dart'
    show ReadWriteTestEntry, SessionLogEntry;
import 'package:serverpod_admin_server/serverpod_admin_server.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

const _support = Scope('support');

Matcher _refused(String message) => throwsA(
  isA<AdminValidationException>().having((e) => e.message, 'message', message),
);

void main() {
  withServerpod('Given saved views', (sessionBuilder, endpoints) {
    setUpAll(() {
      configureAdminModule((registry) {
        registry.staffScopes = {_support};
        registry.register<SessionLogEntry>(
          table: SessionLogEntry.t,
          fromJson: SessionLogEntry.fromJson,
          resourceKey: 'sessions',
          options: AdminOptions(
            hidden: {'stackTrace'},
            permissions: AdminPermissions(view: {_support}),
          ),
        );
        registry.register<ReadWriteTestEntry>(
          table: ReadWriteTestEntry.t,
          fromJson: ReadWriteTestEntry.fromJson,
          resourceKey: 'counters',
        );
      });
      adminRegister();
    });

    tearDownAll(() => AdminRegistry().reset());

    TestSessionBuilder user(String id, Set<Scope> scopes) =>
        sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            '00000000-0000-0000-0000-00000000000$id',
            scopes,
          ),
        );
    final admin = user('1', {Scope.admin});
    final otherAdmin = user('2', {Scope.admin});
    final support = user('3', {_support});

    final slowCalls = AdminQuery(
      offset: 40,
      limit: 20,
      search: '  login  ',
      sortColumn: 'duration',
      sortDescending: true,
      filters: [
        AdminFilter(
          column: 'slow',
          comparison: AdminFilterOperator.equals,
          value: 'true',
        ),
      ],
    );

    test('a view keeps the search, sort, filters and columns', () async {
      final saved = await endpoints.admin.saveView(
        admin,
        'sessions',
        ' Slow logins ',
        slowCalls,
        ['id', 'endpoint', 'duration'],
      );
      expect(saved.id, isNotNull);
      expect(saved.owner, '00000000-0000-0000-0000-000000000001');
      expect(saved.name, 'Slow logins');
      expect(saved.search, 'login');
      expect((saved.sortColumn, saved.sortDescending), ('duration', true));
      expect(saved.filters.single.column, 'slow');
      expect(saved.filters.single.value, 'true');
      expect(saved.shownColumns, ['id', 'endpoint', 'duration']);

      final views = await endpoints.admin.savedViews(admin, 'sessions');
      expect([for (final v in views) v.name], ['Slow logins']);
      expect(
        views.single.filters.single.comparison,
        AdminFilterOperator.equals,
      );
    });

    test('views are listed by name, per table and per user', () async {
      for (final name in ['Today', 'All errors']) {
        await endpoints.admin.saveView(
          admin,
          'sessions',
          name,
          slowCalls,
          null,
        );
      }
      await endpoints.admin.saveView(
        admin,
        'counters',
        'Big',
        slowCalls.copyWith(sortColumn: 'number', filters: []),
        null,
      );
      await endpoints.admin.saveView(
        otherAdmin,
        'sessions',
        'Mine',
        slowCalls,
        null,
      );

      expect(
        [
          for (final v in await endpoints.admin.savedViews(admin, 'sessions'))
            v.name,
        ],
        ['All errors', 'Today'],
      );
      expect(
        [
          for (final v in await endpoints.admin.savedViews(admin, 'counters'))
            v.name,
        ],
        ['Big'],
      );
      expect(
        [
          for (final v in await endpoints.admin.savedViews(
            otherAdmin,
            'sessions',
          ))
            v.name,
        ],
        ['Mine'],
      );
    });

    test('saving under the same name replaces the view', () async {
      final first = await endpoints.admin.saveView(
        admin,
        'sessions',
        'Errors',
        slowCalls,
        null,
      );
      final second = await endpoints.admin.saveView(
        admin,
        'sessions',
        'Errors',
        AdminQuery(offset: 0, limit: 25, sortDescending: true, filters: []),
        ['id'],
      );
      expect(second.id, first.id);
      final views = await endpoints.admin.savedViews(admin, 'sessions');
      expect(views, hasLength(1));
      expect(views.single.filters, isEmpty);
      expect(views.single.search, isNull);
      // Without a chosen sort, the direction is not kept.
      expect(
        (views.single.sortColumn, views.single.sortDescending),
        (null, false),
      );
      expect(views.single.shownColumns, ['id']);
    });

    test('only the owner deletes a view', () async {
      final view = await endpoints.admin.saveView(
        admin,
        'sessions',
        'Temporary',
        slowCalls,
        null,
      );
      expect(await endpoints.admin.deleteView(otherAdmin, view.id!), isFalse);
      expect(await endpoints.admin.savedViews(admin, 'sessions'), hasLength(1));
      expect(await endpoints.admin.deleteView(admin, view.id!), isTrue);
      expect(await endpoints.admin.savedViews(admin, 'sessions'), isEmpty);
    });

    test('a view names only columns the user may see', () async {
      await expectLater(
        () =>
            endpoints.admin.saveView(admin, 'sessions', '  ', slowCalls, null),
        _refused('Name the view.'),
      );
      await expectLater(
        () => endpoints.admin.saveView(
          admin,
          'sessions',
          'x' * 101,
          slowCalls,
          null,
        ),
        _refused('Use at most 100 characters for the name.'),
      );
      await expectLater(
        () => endpoints.admin.saveView(admin, 'sessions', 'Traces', slowCalls, [
          'id',
          'stackTrace',
        ]),
        _refused('Unknown column stackTrace.'),
      );
      await expectLater(
        () => endpoints.admin.saveView(
          admin,
          'sessions',
          'Traces',
          slowCalls.copyWith(sortColumn: 'stackTrace'),
          null,
        ),
        _refused('Unknown column stackTrace.'),
      );
      await expectLater(
        () => endpoints.admin.saveView(
          admin,
          'sessions',
          'Traces',
          slowCalls.copyWith(
            filters: [
              AdminFilter(
                column: 'stackTrace',
                comparison: AdminFilterOperator.isNotEmpty,
              ),
            ],
          ),
          null,
        ),
        _refused('Unknown column stackTrace.'),
      );
      expect(await endpoints.admin.savedViews(admin, 'sessions'), isEmpty);
    });

    test('staff save views of the tables they may see', () async {
      await endpoints.admin.saveView(
        support,
        'sessions',
        'Mine',
        slowCalls,
        null,
      );
      expect(
        await endpoints.admin.savedViews(support, 'sessions'),
        hasLength(1),
      );
      await expectLater(
        () => endpoints.admin.savedViews(support, 'counters'),
        _refused('You do not have access to this.'),
      );
      await expectLater(
        () => endpoints.admin.saveView(
          support,
          'counters',
          'No',
          slowCalls,
          null,
        ),
        _refused('You do not have access to this.'),
      );
    });
  });
}
