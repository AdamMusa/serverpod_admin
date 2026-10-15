import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_admin_client/serverpod_admin_client.dart';
import 'package:serverpod_admin_dashboard/src/controller/admin_dashboard.dart';
import 'package:serverpod_admin_dashboard/src/controller/dialog_form_controller.dart';
import 'package:serverpod_admin_dashboard/src/helpers/filters.dart';
import 'package:serverpod_admin_dashboard/src/widgets/dialog_form_field.dart';
import 'package:serverpod_admin_dashboard/src/widgets/filters/filter_dialog.dart';
import 'package:serverpod_admin_dashboard/src/widgets/overview/overview_view.dart';
import 'package:serverpod_admin_dashboard/src/widgets/side_bar.dart';

/// Answers the overview's calls and counts them.
class _FakeAdmin implements EndpointAdmin {
  _FakeAdmin({this.points = const [], this.failMetrics = false});

  final List<AdminActivityPoint> points;
  final bool failMetrics;
  final activityCalls = <String>[];

  @override
  Future<List<AdminResource>> resources() async => [_rides, _drivers];

  @override
  Future<List<AdminMetricValue>> metrics() async {
    if (failMetrics) throw Exception('down');
    return [
      AdminMetricValue(
        label: 'Rides today',
        value: '42',
        hint: 'since midnight',
      ),
    ];
  }

  @override
  Future<List<AdminActivityPoint>> activity(
    String resourceKey,
    int days,
  ) async {
    activityCalls.add(resourceKey);
    return points;
  }

  @override
  Future<AdminPage> query(String resourceKey, AdminQuery query) async =>
      AdminPage(rows: [], total: 12);

  @override
  Future<AdminLogPage> history(
    String? resourceKey,
    String? recordId,
    int offset,
    int limit,
  ) async => AdminLogPage(entries: [], total: 0);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

AdminColumn _column(String name, String type, {bool primary = false}) =>
    AdminColumn(
      name: name,
      dataType: type,
      hasDefault: primary,
      isPrimary: primary,
    );

final _rides = AdminResource(
  key: 'ride',
  tableName: 'ride',
  label: 'Rides',
  group: 'Operations',
  chartColumn: 'requestedAt',
  listColumns: ['id', 'status'],
  columns: [
    _column('id', 'int', primary: true),
    _column('status', 'String'),
    _column('fare', 'double'),
    _column('requestedAt', 'DateTime'),
    _column('completedAt', 'DateTime'),
  ],
);

final _drivers = AdminResource(
  key: 'driver_profile',
  tableName: 'driver_profile',
  group: 'People',
  columns: [_column('id', 'int', primary: true)],
);

final _settings = AdminResource(
  key: 'app_setting',
  tableName: 'app_setting',
  columns: [_column('id', 'int', primary: true)],
);

DateTime _today() {
  final now = DateTime.now().toUtc();
  return DateTime.utc(now.year, now.month, now.day);
}

void main() {
  AdminDashboardController controllerFor(_FakeAdmin admin) =>
      AdminDashboardController(
        adminEndpoint: admin,
        initialThemeMode: ThemeMode.light,
      );

  group('date shortcuts', () {
    test('start on the first day of their range', () {
      final now = DateTime(2026, 10, 15, 18, 30);
      expect(DateShortcut.today.start(now), '2026-10-15');
      expect(DateShortcut.last7Days.start(now), '2026-10-09');
      expect(DateShortcut.last30Days.start(now), '2026-09-16');
      expect(DateShortcut.thisMonth.start(now), '2026-10-01');
      expect(DateShortcut.last7Days.start(DateTime(2026, 3, 3)), '2026-02-25');
    });

    test('filter from the first day on', () {
      final filter = DateShortcut.thisMonth.filter(
        'requestedAt',
        DateTime(2026, 10, 15),
      );
      expect(filter.column, 'requestedAt');
      expect(filter.comparison, AdminFilterOperator.greaterOrEqual);
      expect(filter.value, '2026-10-01');
    });
  });

  group('controller', () {
    test('activity has a count for every day, today last', () async {
      final today = _today();
      final admin = _FakeAdmin(
        points: [
          AdminActivityPoint(
            day: today.subtract(const Duration(days: 3)),
            count: 1,
          ),
          AdminActivityPoint(day: today, count: 2),
          // Outside the range.
          AdminActivityPoint(
            day: today.subtract(const Duration(days: 40)),
            count: 9,
          ),
        ],
      );
      final counts = await controllerFor(admin).activity(_rides);
      expect(counts, hasLength(30));
      expect(counts.last, 2);
      expect(counts[26], 1);
      expect(counts.fold(0, (sum, c) => sum + c), 3);
    });

    test('a table without a date column is not charted', () async {
      final admin = _FakeAdmin();
      expect(await controllerFor(admin).activity(_drivers), isEmpty);
      expect(admin.activityCalls, isEmpty);
    });

    test('failing metrics leave the overview without them', () async {
      final controller = controllerFor(_FakeAdmin(failMetrics: true));
      expect(await controller.metrics(), isEmpty);
    });

    test('only the list columns show at first', () {
      final controller = controllerFor(_FakeAdmin());
      expect(controller.hiddenColumns(_rides), {
        'fare',
        'requestedAt',
        'completedAt',
      });
      controller.toggleColumn(_rides, 'fare');
      expect(controller.hiddenColumns(_rides), {'requestedAt', 'completedAt'});
      expect(controller.hiddenColumns(_drivers), isEmpty);
    });
  });

  testWidgets('the sidebar groups tables under their group', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Sidebar(
            resources: [_rides, _settings, _drivers],
            isLoading: false,
            errorMessage: null,
            selectedResource: null,
            onSelect: (_) {},
            onRetry: () {},
            isCollapsed: false,
            onToggleCollapse: () {},
          ),
        ),
      ),
    );
    double top(String text) => tester.getTopLeft(find.text(text)).dy;
    expect(find.text('Rides'), findsOneWidget);
    // Ungrouped tables come first, then each group in order.
    expect(top('App Setting'), lessThan(top('OPERATIONS')));
    expect(top('OPERATIONS'), lessThan(top('Rides')));
    expect(top('Rides'), lessThan(top('PEOPLE')));
    expect(top('PEOPLE'), lessThan(top('Driver Profile')));
  });

  testWidgets('the overview shows metrics and daily activity', (tester) async {
    final admin = _FakeAdmin(
      points: [AdminActivityPoint(day: _today(), count: 3)],
    );
    final controller = controllerFor(admin);
    await controller.loadResources();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: OverviewView(controller: controller)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Rides today'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(find.text('since midnight'), findsOneWidget);
    expect(find.text('Rides'), findsOneWidget);
    expect(find.text('3 added in the last 30 days'), findsOneWidget);
    // Only tables with a date column are charted.
    expect(admin.activityCalls, ['ride']);
  });

  testWidgets('a date shortcut filters the charted column', (tester) async {
    List<AdminFilter>? applied;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => applied = await showFilterDialog(
              context,
              resource: _rides,
              current: const [],
            ),
            child: const Text('Filter'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Filter'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Last 7 days'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(applied, hasLength(1));
    expect(applied!.single.column, 'requestedAt');
    expect(applied!.single.comparison, AdminFilterOperator.greaterOrEqual);
    expect(applied!.single.value, DateShortcut.last7Days.start(DateTime.now()));
  });

  testWidgets('read-only columns are locked when editing, with help', (
    tester,
  ) async {
    final column = AdminColumn(
      name: 'fare',
      dataType: 'double',
      hasDefault: false,
      isPrimary: false,
      label: 'Fare (MRU)',
      help: 'Set when the ride ends.',
      readOnly: true,
    );
    final resource = AdminResource(
      key: 'ride',
      tableName: 'ride',
      columns: [column],
    );
    final admin = controllerFor(_FakeAdmin());
    Future<void> pump(DialogFormController form) => tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DialogFormField(
            key: UniqueKey(),
            column: column,
            formController: form,
            adminController: admin,
          ),
        ),
      ),
    );

    final editing = DialogFormController(
      resource: resource,
      adminController: admin,
      initialValues: {'fare': '120'},
    );
    addTearDown(editing.dispose);
    await pump(editing);
    expect(find.text('Read-only. Set when the ride ends.'), findsOneWidget);
    expect(find.textContaining('Fare (MRU)'), findsWidgets);
    final ignore = tester.widget<IgnorePointer>(
      find
          .ancestor(
            of: find.byType(TextFormField),
            matching: find.byType(IgnorePointer),
          )
          .first,
    );
    expect(ignore.ignoring, isTrue);

    final creating = DialogFormController(
      resource: resource,
      adminController: admin,
    );
    addTearDown(creating.dispose);
    await pump(creating);
    expect(find.text('Set when the ride ends.'), findsOneWidget);
    expect(find.textContaining('Read-only.'), findsNothing);
  });
}
