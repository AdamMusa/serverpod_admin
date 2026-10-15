import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_admin_client/serverpod_admin_client.dart';
import 'package:serverpod_admin_dashboard/src/admin_dashboard.dart';
import 'package:serverpod_admin_dashboard/src/widgets/side_bar.dart';

AdminResource _resource(String key, {String? label, String? group}) =>
    AdminResource(
      key: key,
      tableName: key,
      label: label,
      group: group,
      columns: [
        AdminColumn(
          name: 'id',
          dataType: 'int',
          hasDefault: true,
          isPrimary: true,
        ),
      ],
    );

final _rides = _resource('ride', label: 'Rides', group: 'Trips');
final _jobs = _resource('serverpod_future_call');
final _settings = _resource('app_setting');

void main() {
  Future<List<AdminResource>> pumpSidebar(
    WidgetTester tester, {
    bool collapsed = false,
    VoidCallback? onToggleCollapse,
  }) async {
    final selected = <AdminResource>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Sidebar(
            resources: [_rides, _jobs, _settings],
            isLoading: false,
            errorMessage: null,
            selectedResource: _rides,
            onSelect: selected.add,
            onRetry: () {},
            onOverview: () {},
            isCollapsed: collapsed,
            onToggleCollapse: onToggleCollapse ?? () {},
            itemCustomizations: const {
              'ride': SidebarItemCustomization(icon: Icons.local_taxi),
              'serverpod_future_call': SidebarItemCustomization(
                label: 'Jobs',
                icon: Icons.work_history,
              ),
              'app_setting': SidebarItemCustomization(label: 'Settings'),
            },
          ),
        ),
      ),
    );
    return selected;
  }

  testWidgets('an icon alone keeps the server label', (tester) async {
    await pumpSidebar(tester);
    final ride = find.ancestor(
      of: find.text('Rides'),
      matching: find.byType(Row),
    );
    expect(
      find.descendant(of: ride, matching: find.byIcon(Icons.local_taxi)),
      findsOneWidget,
    );
    // A label replaces the server's, with or without an icon.
    expect(find.text('Jobs'), findsOneWidget);
    expect(find.byIcon(Icons.work_history), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('App Setting'), findsNothing);
  });

  testWidgets('collapsed, the sidebar shows each table as an icon', (
    tester,
  ) async {
    var toggled = 0;
    final selected = await pumpSidebar(
      tester,
      collapsed: true,
      onToggleCollapse: () => toggled++,
    );
    expect(find.text('Rides'), findsNothing);
    expect(find.byTooltip('Overview'), findsOneWidget);
    expect(find.byTooltip('Rides'), findsOneWidget);
    expect(find.byTooltip('Jobs'), findsOneWidget);
    // Without a custom icon, the default one.
    expect(
      find.descendant(
        of: find.byTooltip('Settings'),
        matching: find.byIcon(Icons.label_outline),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.work_history));
    expect(selected, [_jobs]);
    await tester.tap(find.byTooltip('Expand sidebar'));
    expect(toggled, 1);
  });

  test('a customization needs a label or an icon', () {
    expect(() => SidebarItemCustomization(), throwsAssertionError);
  });
}
