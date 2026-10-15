import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_admin_client/serverpod_admin_client.dart';
import 'package:serverpod_admin_dashboard/src/controller/admin_dashboard.dart';
import 'package:serverpod_admin_dashboard/src/screens/home_operations.dart';
import 'package:serverpod_admin_dashboard/src/widgets/records_view.dart';

AdminColumn _col(String name, {String type = 'String', bool pk = false}) =>
    AdminColumn(name: name, dataType: type, hasDefault: pk, isPrimary: pk);

final _rides = AdminResource(
  key: 'ride',
  tableName: 'ride',
  label: 'Rides',
  listColumns: ['id', 'status'],
  columns: [
    _col('id', type: 'int', pk: true),
    _col('status'),
    _col('fare', type: 'double'),
  ],
);

final _open = AdminFilter(
  column: 'status',
  comparison: AdminFilterOperator.equals,
  value: 'open',
);

/// Keeps saved views in memory and remembers the last query.
class _FakeAdmin implements EndpointAdmin {
  final views = <AdminSavedView>[];
  final saved = <(String, AdminQuery, List<String>?)>[];
  AdminQuery? lastQuery;

  @override
  Future<List<AdminResource>> resources() async => [_rides];

  @override
  Future<AdminPage> query(String resourceKey, AdminQuery query) async {
    lastQuery = query;
    return AdminPage(rows: [], total: 0);
  }

  @override
  Future<List<AdminSavedView>> savedViews(String resourceKey) async => [
    for (final view in views)
      if (view.resourceKey == resourceKey) view,
  ]..sort((a, b) => a.name.compareTo(b.name));

  @override
  Future<AdminSavedView> saveView(
    String resourceKey,
    String name,
    AdminQuery query,
    List<String>? columns,
  ) async {
    saved.add((name, query, columns));
    views.removeWhere((v) => v.name == name);
    final view = AdminSavedView(
      id: views.length + 100,
      owner: 'me',
      resourceKey: resourceKey,
      name: name,
      search: query.search,
      sortColumn: query.sortColumn,
      sortDescending: query.sortDescending,
      filters: query.filters,
      shownColumns: columns,
      updatedAt: DateTime.utc(2026, 10, 15),
    );
    views.add(view);
    return view;
  }

  @override
  Future<bool> deleteView(int id) async {
    views.removeWhere((v) => v.id == id);
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

AdminSavedView _view(
  String name, {
  int id = 1,
  String? search,
  String? sortColumn,
  bool sortDescending = false,
  List<AdminFilter> filters = const [],
  List<String>? shownColumns,
}) => AdminSavedView(
  id: id,
  owner: 'me',
  resourceKey: 'ride',
  name: name,
  search: search,
  sortColumn: sortColumn,
  sortDescending: sortDescending,
  filters: filters,
  shownColumns: shownColumns,
  updatedAt: DateTime.utc(2026, 10, 15),
);

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
  });

  test('a table shows its views once selected', () async {
    admin.views.add(_view('Open rides', filters: [_open]));
    await controller.selectResource(_rides);
    await pumpEventQueue();
    expect([for (final v in controller.savedViews) v.name], ['Open rides']);
  });

  test('a view saves the search, sort, filters and changed columns', () async {
    await controller.selectResource(_rides);
    controller.setFilters([_open]);
    controller.sortBy('fare');
    controller.sortBy('fare');
    controller.setSearchQuery('airport');
    await controller.saveView('Open by fare');
    final (name, query, columns) = admin.saved.single;
    expect(name, 'Open by fare');
    expect(query.search, 'airport');
    expect((query.sortColumn, query.sortDescending), ('fare', true));
    expect(query.filters.single.value, 'open');
    // Columns as the table shows them by default are not saved.
    expect(columns, isNull);
    expect(controller.currentView?.name, 'Open by fare');

    controller.toggleColumn(_rides, 'fare');
    expect(controller.currentView, isNull);
    await controller.saveView('With fare');
    expect(admin.saved.last.$3, ['id', 'status', 'fare']);
    expect(controller.currentView?.name, 'With fare');
  });

  test('applying a view shows it from the first page', () async {
    final view = _view(
      'Expensive',
      search: 'airport',
      sortColumn: 'fare',
      sortDescending: true,
      filters: [_open],
      shownColumns: ['id', 'fare'],
    );
    admin.views.add(view);
    await controller.selectResource(_rides);
    await pumpEventQueue();
    controller.goToPage(3);
    controller.applyView(view);
    await pumpEventQueue();

    expect(controller.pageIndex, 0);
    expect(controller.searchQuery, 'airport');
    expect(controller.hiddenColumns(_rides), {'status'});
    final query = admin.lastQuery!;
    expect(query.offset, 0);
    expect(query.search, 'airport');
    expect((query.sortColumn, query.sortDescending), ('fare', true));
    expect(query.filters.single.column, 'status');
    expect(controller.currentView?.name, 'Expensive');

    // Changing what is shown leaves the view.
    controller.removeFilter(controller.filters.single);
    expect(controller.currentView, isNull);

    await controller.deleteView(view);
    expect(controller.savedViews, isEmpty);
  });

  testWidgets('the views menu applies, saves and deletes views', (
    tester,
  ) async {
    final open = _view('Open rides', filters: [_open]);
    final mine = _view('Mine', id: 2);
    final applied = <String>[];
    final deleted = <String>[];
    var saves = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecordsView(
            resource: _rides,
            records: const [],
            isLoading: false,
            errorMessage: null,
            onAdd: null,
            onEdit: null,
            onDelete: null,
            savedViews: [mine, open],
            currentView: open,
            onApplyView: (view) => applied.add(view.name),
            onSaveView: () => saves++,
            onDeleteView: (view) => deleted.add(view.name),
          ),
        ),
      ),
    );
    // The view shown is named under the title.
    expect(find.text('Open rides'), findsOneWidget);

    await tester.tap(find.byTooltip('Saved views'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mine'));
    await tester.pumpAndSettle();
    expect(applied, ['Mine']);

    await tester.tap(find.byTooltip('Saved views'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save view…'));
    await tester.pumpAndSettle();
    expect(saves, 1);

    await tester.tap(find.byTooltip('Saved views'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete “Open rides”'));
    await tester.pumpAndSettle();
    expect(deleted, ['Open rides']);
  });

  testWidgets('the search box shows the search of a view', (tester) async {
    Widget view(String search) => MaterialApp(
      home: Scaffold(
        body: RecordsView(
          resource: _rides,
          records: const [],
          isLoading: false,
          errorMessage: null,
          onAdd: null,
          onEdit: null,
          onDelete: null,
          searchQuery: search,
          onSearchChanged: (_) {},
        ),
      ),
    );
    await tester.pumpWidget(view(''));
    await tester.pumpWidget(view('airport'));
    expect(find.widgetWithText(TextField, 'airport'), findsOneWidget);
    await tester.pumpWidget(view(''));
    expect(find.widgetWithText(TextField, 'airport'), findsNothing);
  });

  testWidgets('saving asks for a name, the current view at first', (
    tester,
  ) async {
    final view = _view('Open rides', filters: [_open]);
    admin.views.add(view);
    await controller.selectResource(_rides);
    await tester.pumpAndSettle();
    controller.applyView(view);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => HomeOperations(
                controller: controller,
                context: context,
              ).saveView(_rides),
              child: const Text('Save'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Save view of Rides'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Open rides'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Open, renamed');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    expect(admin.saved.single.$1, 'Open, renamed');
    expect(find.text('Saved the view “Open, renamed”.'), findsOneWidget);
  });
}
