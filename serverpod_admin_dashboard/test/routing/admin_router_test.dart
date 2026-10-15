import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_admin_client/serverpod_admin_client.dart';
import 'package:serverpod_admin_dashboard/src/controller/admin_dashboard.dart';
import 'package:serverpod_admin_dashboard/src/routing/admin_router.dart';
import 'package:serverpod_admin_dashboard/src/screens/home.dart';

AdminColumn _col(String name, {String type = 'String', bool pk = false}) =>
    AdminColumn(name: name, dataType: type, hasDefault: pk, isPrimary: pk);

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
  columns: [
    _col('id', type: 'int', pk: true),
    _col('status'),
  ],
);

/// Serves rides and users, filtered by equality and searched by status.
class _FakeAdmin implements EndpointAdmin {
  final queries = <AdminQuery>[];

  final data = {
    'user_profile': [
      {'id': '1', 'fullName': 'Awa Diallo'},
    ],
    'ride': [
      for (var id = 10; id < 40; id++)
        {'id': '$id', 'status': id.isEven ? 'open' : 'done'},
    ],
  };

  @override
  Future<List<AdminResource>> resources() async => [_users, _rides];

  @override
  Future<AdminPage> query(String resourceKey, AdminQuery query) async {
    queries.add(query);
    var rows = data[resourceKey]!;
    for (final filter in query.filters) {
      rows = rows.where((r) => r[filter.column] == filter.value).toList();
    }
    final search = query.search;
    if (search != null) {
      rows = rows.where((r) => '${r['status']}'.contains(search)).toList();
    }
    return AdminPage(
      rows: rows.skip(query.offset).take(query.limit).toList(),
      total: rows.length,
    );
  }

  @override
  Future<List<AdminSavedView>> savedViews(String resourceKey) async => [];

  @override
  Future<List<AdminMetricValue>> metrics() async => [];

  @override
  Future<List<AdminActivityPoint>> activity(String key, int days) async => [];

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

/// A browser's address bar and history.
class _Browser extends RouteInformationProvider with ChangeNotifier {
  _Browser(String location)
    : _value = RouteInformation(uri: Uri.parse(location)),
      history = [location];

  RouteInformation _value;
  final List<String> history;

  @override
  RouteInformation get value => _value;

  @override
  void routerReportsNewRouteInformation(
    RouteInformation routeInformation, {
    RouteInformationReportingType type = RouteInformationReportingType.none,
  }) {
    final location = routeInformation.uri.toString();
    final replace =
        type == RouteInformationReportingType.neglect ||
        (type == RouteInformationReportingType.none &&
            _same(routeInformation.uri, Uri.parse(history.last)));
    if (replace) {
      history.last = location;
    } else {
      history.add(location);
    }
    _value = routeInformation;
  }

  /// The same place, whatever the order of its parameters, as browsers
  /// are told by Flutter.
  static bool _same(Uri a, Uri b) {
    if (a.path != b.path) return false;
    final x = a.queryParametersAll;
    final y = b.queryParametersAll;
    return x.length == y.length &&
        x.entries.every((e) => y[e.key]?.join('&') == e.value.join('&'));
  }

  /// The Back button.
  void back() {
    history.removeLast();
    _value = RouteInformation(uri: Uri.parse(history.last));
    notifyListeners();
  }
}

void main() {
  late _FakeAdmin admin;
  late AdminDashboardController controller;

  setUp(() {
    admin = _FakeAdmin();
    controller = AdminDashboardController(
      adminEndpoint: admin,
      initialThemeMode: ThemeMode.light,
    );
  });

  /// Opens the dashboard at [location]; signs in unless [signIn] is false.
  Future<(_Browser, AdminRouterDelegate)> open(
    WidgetTester tester,
    String location, {
    bool signIn = true,
    WidgetBuilder? builder,
  }) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final browser = _Browser(location);
    final delegate = AdminRouterDelegate(
      controller: controller,
      builder:
          builder ?? (context) => Home(controller: controller, title: 'Admin'),
    );
    addTearDown(delegate.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        routerDelegate: delegate,
        routeInformationParser: const AdminRouteParser(),
        routeInformationProvider: browser,
      ),
    );
    if (signIn) {
      await controller.loadResources();
      await tester.pumpAndSettle();
    }
    return (browser, delegate);
  }

  testWidgets('each place opened adds to the history, Back returns', (
    tester,
  ) async {
    final (browser, _) = await open(tester, '/');
    expect(controller.isShowingOverview, isTrue);

    await tester.tap(find.text('Rides').first);
    await tester.pumpAndSettle();
    controller.goToPage(1);
    await tester.pumpAndSettle();
    controller.sortBy('status');
    await tester.pumpAndSettle();
    controller.setFilters([
      AdminFilter(
        column: 'status',
        comparison: AdminFilterOperator.equals,
        value: 'open',
      ),
    ]);
    await tester.pumpAndSettle();
    await controller.openRecord(_rides, '12');
    await tester.pumpAndSettle();
    expect(browser.history, [
      '/',
      '/ride',
      '/ride?page=2',
      '/ride?sort=status',
      '/ride?sort=status&status__exact=open',
      '/ride/12',
    ]);

    browser.back();
    await tester.pumpAndSettle();
    expect(controller.isShowingDetails, isFalse);
    expect(controller.filters.single.value, 'open');

    browser.back();
    await tester.pumpAndSettle();
    expect(controller.filters, isEmpty);
    expect(controller.sortColumn, 'status');

    browser.back();
    await tester.pumpAndSettle();
    expect((controller.sortColumn, controller.pageIndex), (null, 1));
    expect(admin.queries.last.offset, 25);

    browser.back();
    browser.back();
    await tester.pumpAndSettle();
    expect(controller.isShowingOverview, isTrue);
    expect(browser.history, ['/']);
  });

  testWidgets('a search replaces its entry as it is typed', (tester) async {
    final (browser, _) = await open(tester, '/ride');
    for (final text in ['o', 'op', 'ope']) {
      controller.setSearchQuery(text);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
    }
    expect(browser.history, ['/ride', '/ride?q=ope']);
    controller.clearSearch();
    await tester.pumpAndSettle();
    expect(browser.history, ['/ride', '/ride?q=ope', '/ride']);
  });

  testWidgets('a link opened before signing in is shown after', (tester) async {
    final (browser, _) = await open(
      tester,
      '/ride?sort=-status&status__exact=done&page=2&per=10',
      signIn: false,
    );
    expect(browser.history, hasLength(1));
    await controller.loadResources();
    await tester.pumpAndSettle();
    expect(controller.selectedResource?.key, 'ride');
    expect(controller.isShowingOverview, isFalse);
    expect(
      (controller.sortColumn, controller.sortDescending),
      ('status', true),
    );
    expect(controller.pageIndex, 1);
    expect(controller.rowsPerPage, 10);
    final query = admin.queries.last;
    expect((query.offset, query.limit), (10, 10));
    expect(query.filters.single.value, 'done');
    expect(controller.records, hasLength(5));
    expect(browser.history, hasLength(1));
  });

  testWidgets('a record is opened from its link', (tester) async {
    final (browser, _) = await open(tester, '/ride/15');
    expect(controller.isShowingDetails, isTrue);
    expect(controller.detailsRecord?['status'], 'done');
    expect(controller.selectedResource?.key, 'ride');
    expect(browser.history, ['/ride/15']);
    // Its table is listed behind it.
    expect(controller.records, isNotEmpty);
  });

  testWidgets('an address naming something gone is corrected in place', (
    tester,
  ) async {
    final (browser, _) = await open(tester, '/ride/999');
    expect(controller.isShowingDetails, isFalse);
    expect(controller.selectedResource?.key, 'ride');
    expect(browser.history, ['/ride']);
  });

  testWidgets('a page past the last shows the last, in place', (tester) async {
    final (browser, _) = await open(tester, '/ride?page=9');
    expect(controller.pageIndex, 1);
    expect(browser.history, ['/ride?page=2']);
  });

  testWidgets('an unknown table shows the overview', (tester) async {
    final (browser, _) = await open(tester, '/nothing');
    expect(controller.isShowingOverview, isTrue);
    expect(browser.history, ['/']);
  });

  testWidgets('Back on a phone closes a record first', (tester) async {
    final (browser, delegate) = await open(tester, '/ride/15');
    expect(await delegate.popRoute(), isTrue);
    await tester.pumpAndSettle();
    expect(controller.isShowingDetails, isFalse);
    expect(browser.history.last, '/ride');
    expect(await delegate.popRoute(), isFalse);
  });

  testWidgets('what is built follows the app, such as signing in', (
    tester,
  ) async {
    var signedIn = false;
    final delegate = AdminRouterDelegate(
      controller: controller,
      builder: (context) => Text(signedIn ? 'Dashboard' : 'Sign in'),
    );
    addTearDown(delegate.dispose);
    late StateSetter update;
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          update = setState;
          return MaterialApp.router(
            routerDelegate: delegate,
            routeInformationParser: const AdminRouteParser(),
            routeInformationProvider: _Browser('/'),
          );
        },
      ),
    );
    expect(find.text('Sign in'), findsOneWidget);
    update(() => signedIn = true);
    await tester.pumpAndSettle();
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
