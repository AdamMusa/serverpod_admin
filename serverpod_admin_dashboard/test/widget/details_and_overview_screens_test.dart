import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_admin_client/serverpod_admin_client.dart'
    hide AdminColumn, AdminResource;
import 'package:serverpod_admin_dashboard/serverpod_admin_dashboard.dart';
import 'package:serverpod_admin_dashboard/src/screens/record_details.dart';
import 'package:serverpod_admin_dashboard/src/widgets/overview/overview_view.dart';

AdminColumn _col(
  String name, {
  String type = 'String',
  bool pk = false,
  String? fk,
}) => AdminColumn(
  name: name,
  dataType: type,
  hasDefault: false,
  isPrimary: pk,
  foreignKeyTable: fk,
);

final _users = AdminResource(
  key: 'user_profile',
  tableName: 'user_profile',
  columns: [
    _col('id', type: 'int', pk: true),
    _col('fullName'),
  ],
);
final _rides = AdminResource(
  key: 'ride',
  tableName: 'ride',
  columns: [
    _col('id', type: 'int', pk: true),
    _col('passengerId', type: 'int', fk: 'user_profile'),
  ],
);

class _FakeAdmin implements EndpointAdmin {
  @override
  Future<List<AdminResource>> resources() async => [_users, _rides];

  @override
  Future<List<AdminTableSummary>> overview(int days) async => [
    for (final key in ['user_profile', 'ride'])
      AdminTableSummary(
        resourceKey: key,
        count: 1,
        estimated: false,
        activity: [],
      ),
  ];

  @override
  Future<AdminPage> query(String key, AdminQuery query) async => key == 'ride'
      ? AdminPage(
          rows: [
            {'id': '10', 'passengerId': '1'},
          ],
          total: 1,
        )
      : AdminPage(
          rows: [
            {'id': '1', 'fullName': 'Awa Diallo'},
          ],
          total: 1,
        );

  @override
  Future<AdminLogPage> history(
    String? resourceKey,
    String? recordId,
    int offset,
    int limit,
  ) async => AdminLogPage(
    total: 1,
    entries: [
      AdminLogEntry(
        actor: 'a',
        actorName: 'admin@abraid.app',
        resourceKey: 'ride',
        recordId: '10',
        action: AdminLogAction.created,
        changes: '{"passengerId":"1"}',
        createdAt: DateTime.utc(2026, 10, 14),
      ),
    ],
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<AdminDashboardController> _controller() async {
  final controller = AdminDashboardController(
    adminEndpoint: _FakeAdmin(),
    initialThemeMode: ThemeMode.light,
  );
  await controller.loadResources();
  return controller;
}

void _size(WidgetTester tester) {
  tester.view.physicalSize = const Size(1280, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('a record shows its fields, related rows and history', (
    tester,
  ) async {
    _size(tester);
    final controller = await _controller();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecordDetails(
            resource: _rides,
            record: const {'id': '10', 'passengerId': '1'},
            showAppBar: false,
            controller: controller,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    // The foreign key is named after the row it points at.
    expect(find.text('Awa Diallo (#1)'), findsOneWidget);
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.text('admin@abraid.app created #10'), findsOneWidget);
    await tester.tap(find.text('Related'));
    await tester.pumpAndSettle();
    expect(find.text('No other records point to this one.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a user lists the rides pointing at them', (tester) async {
    _size(tester);
    final controller = await _controller();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecordDetails(
            resource: _users,
            record: const {'id': '1', 'fullName': 'Awa Diallo'},
            showAppBar: false,
            controller: controller,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Related'));
    await tester.pumpAndSettle();
    expect(find.text('ride (1)'), findsOneWidget);
    expect(find.text('by passengerId'), findsOneWidget);
    expect(find.text('View all 1'), findsOneWidget);
  });

  testWidgets('the overview counts tables and shows recent actions', (
    tester,
  ) async {
    _size(tester);
    final controller = await _controller();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: OverviewView(controller: controller)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('user_profile'), findsOneWidget);
    expect(find.text('1'), findsNWidgets(2));
    expect(find.text('admin@abraid.app created ride #10'), findsOneWidget);
    await tester.tap(find.text('ride'));
    await tester.pumpAndSettle();
    expect(controller.selectedResource?.key, 'ride');
    expect(controller.isShowingOverview, isFalse);
    expect(tester.takeException(), isNull);
  });
}
