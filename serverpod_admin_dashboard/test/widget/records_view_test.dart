import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_admin_client/serverpod_admin_client.dart'
    hide AdminColumn, AdminResource;
import 'package:serverpod_admin_dashboard/src/helpers/admin_resources.dart';
import 'package:serverpod_admin_dashboard/src/widgets/records_body/records_body.dart';
import 'package:serverpod_admin_dashboard/src/widgets/records_view.dart';

final _resource = AdminResource(
  key: 'driver_profile',
  tableName: 'driver_profile',
  actions: [
    AdminActionInfo(
      name: 'approve',
      label: 'Approve drivers',
      confirm: true,
      destructive: false,
    ),
  ],
  columns: [
    AdminColumn(name: 'id', dataType: 'int', hasDefault: true, isPrimary: true),
    AdminColumn(
      name: 'verificationStatus',
      dataType: 'DriverVerificationStatus',
      hasDefault: true,
      isPrimary: false,
      enumValues: ['pending', 'approved', 'rejected'],
    ),
    AdminColumn(
      name: 'insuranceDocUrl',
      dataType: 'String',
      hasDefault: false,
      isPrimary: false,
      isNullable: true,
    ),
  ],
);

Future<void> _pump(
  WidgetTester tester, {
  List<AdminFilter> filters = const [],
  void Function(List<AdminFilter>)? onFilters,
  void Function(String)? onSort,
  Set<String> hidden = const {},
  Set<String> selected = const {},
  void Function(String)? onBulk,
  bool addable = true,
}) async {
  tester.view.physicalSize = const Size(1400, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: RecordsView(
                resource: _resource,
                records: const [
                  {
                    'id': '12',
                    'verificationStatus': 'pending',
                    'insuranceDocUrl': 'https://abraid.app/files/insurance.pdf',
                  },
                ],
                isLoading: false,
                errorMessage: null,
                onAdd: addable ? () {} : null,
                onEdit: (_) {},
                onDelete: (_) {},
                filters: filters,
                onFiltersChanged: onFilters ?? (_) {},
                hiddenColumns: hidden,
                onToggleColumn: (_) {},
                onRefresh: () {},
                selectedIds: selected,
                onSelect: (_, _) {},
                onSelectPage: (_) {},
                onSelectAllMatching: () => onBulk?.call('all'),
                onClearSelection: () => onBulk?.call('clear'),
                onDeleteSelected: () => onBulk?.call('delete'),
                onSetField: () => onBulk?.call('set'),
                onRunAction: (action) => onBulk?.call(action.name),
                paging: RecordsPaging(
                  pageIndex: 0,
                  rowsPerPage: 25,
                  rowsPerPageOptions: const [10, 25],
                  totalRecords: 1,
                  onPage: (_) {},
                  onRowsPerPage: (_) {},
                  onSort: onSort,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('document links show as something to open', (tester) async {
    await _pump(tester);
    expect(find.text('View PDF'), findsOneWidget);
    expect(find.text('1 record'), findsOneWidget);
    expect(find.text('Add driver_profile'), findsOneWidget);
  });

  testWidgets('a table that cannot be created has no Add button', (
    tester,
  ) async {
    await _pump(tester, addable: false);
    expect(find.text('Add driver_profile'), findsNothing);
  });

  testWidgets('column headers sort and hidden columns stay out', (
    tester,
  ) async {
    String? sorted;
    await _pump(
      tester,
      onSort: (column) => sorted = column,
      hidden: {'insuranceDocUrl'},
    );
    expect(find.text('View PDF'), findsNothing);
    await tester.tap(find.text('verificationStatus'));
    expect(sorted, 'verificationStatus');
  });

  testWidgets('filters show as chips that can be removed', (tester) async {
    final filter = AdminFilter(
      column: 'verificationStatus',
      comparison: AdminFilterOperator.equals,
      value: 'pending',
    );
    List<AdminFilter>? changed;
    await _pump(tester, filters: [filter], onFilters: (f) => changed = f);
    expect(find.text('verificationStatus is pending'), findsOneWidget);
    await tester.tap(find.byTooltip('Delete'));
    expect(changed, isEmpty);
  });

  testWidgets('the filter dialog builds a filter from dropdowns', (
    tester,
  ) async {
    List<AdminFilter>? applied;
    await _pump(tester, onFilters: (f) => applied = f);
    await tester.tap(find.byTooltip('Filter records'));
    await tester.pumpAndSettle();
    // The first column offered is the first non-key one: an enum.
    await tester.tap(find.text('Value').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('approved').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(applied, hasLength(1));
    expect(applied!.single.column, 'verificationStatus');
    expect(applied!.single.comparison, AdminFilterOperator.equals);
    expect(applied!.single.value, 'approved');
  });

  testWidgets('selected rows get bulk actions', (tester) async {
    final used = <String>[];
    await _pump(tester, selected: {'12'}, onBulk: used.add);
    expect(find.text('1 selected'), findsOneWidget);
    for (final label in ['Set field', 'Approve drivers', 'Delete selected']) {
      await tester.tap(find.text(label));
    }
    expect(used, ['set', 'approve', 'delete']);
    expect(find.byType(Checkbox), findsWidgets);
  });
}
