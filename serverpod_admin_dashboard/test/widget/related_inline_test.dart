import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_admin_client/serverpod_admin_client.dart';
import 'package:serverpod_admin_dashboard/src/controller/admin_dashboard.dart';
import 'package:serverpod_admin_dashboard/src/screens/home_operations.dart';
import 'package:serverpod_admin_dashboard/src/screens/record_details.dart';

AdminColumn _col(
  String name, {
  String type = 'String',
  bool pk = false,
  String? fk,
}) => AdminColumn(
  name: name,
  dataType: type,
  hasDefault: pk,
  isPrimary: pk,
  foreignKeyTable: fk,
  isNullable: false,
);

final _users = AdminResource(
  key: 'user_profile',
  tableName: 'user_profile',
  label: 'Users',
  columns: [
    _col('id', type: 'int', pk: true),
    _col('fullName'),
  ],
);
final _rides = AdminResource(
  key: 'ride',
  tableName: 'ride',
  label: 'Rides',
  listColumns: ['id', 'status', 'passengerId'],
  columns: [
    _col('id', type: 'int', pk: true),
    _col(
      'passengerId',
      type: 'int',
      fk: 'user_profile',
    ).copyWith(label: 'Passenger'),
    _col('status'),
    _col('note'),
  ],
);
final _payments = AdminResource(
  key: 'payment',
  tableName: 'payment',
  label: 'Payments',
  canCreate: false,
  canEdit: false,
  canDelete: false,
  columns: [
    _col('id', type: 'int', pk: true),
    _col('payerId', type: 'int', fk: 'user_profile'),
  ],
);

/// Serves and changes users and rides in memory.
class _FakeAdmin implements EndpointAdmin {
  final data = {
    'user_profile': [
      {'id': '1', 'fullName': 'Awa Diallo'},
    ],
    'ride': [
      {'id': '10', 'passengerId': '1', 'status': 'done', 'note': 'a'},
      {'id': '11', 'passengerId': '1', 'status': 'open', 'note': 'b'},
      {'id': '12', 'passengerId': '2', 'status': 'open', 'note': 'c'},
    ],
    'payment': <Map<String, String>>[],
  };
  final calls = <String>[];

  @override
  Future<List<AdminResource>> resources() async => [_users, _rides, _payments];

  @override
  Future<AdminPage> query(String resourceKey, AdminQuery query) async {
    var rows = data[resourceKey]!;
    for (final filter in query.filters) {
      final wanted = filter.comparison == AdminFilterOperator.oneOf
          ? filter.value!.split(',')
          : [filter.value];
      rows = rows.where((r) => wanted.contains(r[filter.column])).toList();
    }
    return AdminPage(
      rows: rows.skip(query.offset).take(query.limit).toList(),
      total: rows.length,
    );
  }

  @override
  Future<Map<String, String>> create(
    String resourceKey,
    Map<String, String> values,
  ) async {
    calls.add('create $resourceKey $values');
    final row = {'id': '13', ...values};
    data[resourceKey]!.add(row);
    return row;
  }

  @override
  Future<Map<String, String>> update(
    String resourceKey,
    Map<String, String> values,
  ) async {
    calls.add('update $resourceKey $values');
    final rows = data[resourceKey]!;
    final index = rows.indexWhere((r) => r['id'] == values['id']);
    rows[index] = {...rows[index], ...values};
    return rows[index];
  }

  @override
  Future<bool> delete(String resourceKey, String id) async {
    calls.add('delete $resourceKey $id');
    data[resourceKey]!.removeWhere((r) => r['id'] == id);
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeAdmin admin;
  late AdminDashboardController controller;

  setUp(() async {
    admin = _FakeAdmin();
    controller = AdminDashboardController(
      adminEndpoint: admin,
      initialThemeMode: ThemeMode.light,
    );
    await controller.loadResources();
    await controller.selectResource(_users);
  });

  Future<void> pumpUser(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ListenableBuilder(
              listenable: controller,
              builder: (context, _) => RecordDetails(
                resource: _users,
                record: const {'id': '1', 'fullName': 'Awa Diallo'},
                showAppBar: false,
                controller: controller,
                operations: HomeOperations(
                  controller: controller,
                  context: context,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Related'));
    await tester.pumpAndSettle();
  }

  testWidgets('related rows show in a table, without their link', (
    tester,
  ) async {
    await pumpUser(tester);
    expect(find.text('Rides (2)'), findsOneWidget);
    expect(find.text('by Passenger'), findsOneWidget);
    expect(find.text('done'), findsOneWidget);
    expect(find.text('open'), findsOneWidget);
    // The rides' link to the user is the same in every row, so not shown.
    expect(
      find.descendant(
        of: find.byType(DataTable),
        matching: find.text('passengerId'),
      ),
      findsNothing,
    );
    // Tables without rows are listed too, so a first row can be added; this
    // one cannot be changed here.
    expect(find.text('Payments (0)'), findsOneWidget);
    // The rows start at the left, under the table's name.
    expect(
      tester.getTopLeft(find.byType(DataTable)).dx,
      tester.getTopLeft(find.text('Rides (2)')).dx - 16,
    );
    expect(find.text('Add Payments'), findsNothing);
    expect(find.text('Add Rides'), findsOneWidget);
  });

  testWidgets('a related row is added linked to the record', (tester) async {
    await pumpUser(tester);
    await tester.tap(find.text('Add Rides'));
    await tester.pumpAndSettle();

    // The link to the user is set and cannot be changed.
    expect(find.text('Read-only.'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Passenger'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextFormField, 'status'), 'new');
    await tester.enterText(find.widgetWithText(TextFormField, 'note'), 'z');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(
      admin.calls.single,
      'create ride {passengerId: 1, status: new, note: z}',
    );
    expect(find.text('Rides (3)'), findsOneWidget);
    expect(find.text('new'), findsOneWidget);
    // The table shown keeps its rows.
    expect(controller.selectedResource?.key, 'user_profile');
    expect(controller.records.map((r) => r['id']), ['1']);
  });

  testWidgets('a related row is edited and deleted in place', (tester) async {
    await pumpUser(tester);
    await tester.tap(find.byTooltip('Edit').first);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'done'),
      'refunded',
    );
    await tester.tap(find.text('Update'));
    await tester.pumpAndSettle();
    expect(admin.calls.last, startsWith('update ride '));
    expect(admin.data['ride']!.first['status'], 'refunded');
    expect(find.text('refunded'), findsOneWidget);

    await tester.tap(find.byTooltip('Delete').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    expect(admin.calls.last, 'delete ride 10');
    expect(find.text('Rides (1)'), findsOneWidget);
    expect(controller.records.map((r) => r['id']), ['1']);
  });

  testWidgets('a related row opens its record', (tester) async {
    await pumpUser(tester);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(controller.selectedResource?.key, 'ride');
    expect(controller.detailsRecord?['id'], '11');
  });
}
