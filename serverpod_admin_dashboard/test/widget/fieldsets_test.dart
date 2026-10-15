import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_admin_client/serverpod_admin_client.dart';
import 'package:serverpod_admin_dashboard/src/controller/admin_dashboard.dart';
import 'package:serverpod_admin_dashboard/src/helpers/fieldsets.dart';
import 'package:serverpod_admin_dashboard/src/screens/record_details.dart';
import 'package:serverpod_admin_dashboard/src/widgets/default_create_dialog.dart';

AdminColumn _col(String name, {String type = 'String', bool pk = false}) =>
    AdminColumn(
      name: name,
      dataType: type,
      hasDefault: pk,
      isPrimary: pk,
      isNullable: false,
    );

AdminResource _orders({List<AdminFieldsetInfo>? fieldsets}) => AdminResource(
  key: 'order',
  tableName: 'order',
  columns: [
    _col('id', type: 'int', pk: true),
    _col('customer'),
    _col('status'),
    _col('address'),
    _col('note'),
  ],
  fieldsets: fieldsets,
);

final _grouped = _orders(
  fieldsets: [
    AdminFieldsetInfo(fields: ['customer', 'status'], collapsed: false),
    AdminFieldsetInfo(
      name: 'Delivery',
      fields: ['address'],
      description: 'Filled in by the warehouse.',
      collapsed: true,
    ),
    AdminFieldsetInfo(name: 'Other', fields: ['note'], collapsed: false),
  ],
);

class _FakeAdmin implements EndpointAdmin {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Each group as "name: column, column".
List<String> _names(List<ColumnGroup> groups) => [
  for (final group in groups)
    '${group.name}: ${[for (final column in group.columns) column.name].join(', ')}',
];

void main() {
  group('column groups', () {
    test('without fieldsets, one group of every column', () {
      expect(_names(columnGroups(_orders())), [
        'null: customer, status, address, note',
      ]);
      expect(_names(columnGroups(_orders(), withPrimary: true)), [
        'null: id, customer, status, address, note',
      ]);
    });

    test('with fieldsets, their groups; details start with the key', () {
      expect(_names(columnGroups(_grouped)), [
        'null: customer, status',
        'Delivery: address',
        'Other: note',
      ]);
      expect(_names(columnGroups(_grouped, withPrimary: true)), [
        'null: id, customer, status',
        'Delivery: address',
        'Other: note',
      ]);
      // A titled first group follows the key.
      final titled = _orders(
        fieldsets: [
          AdminFieldsetInfo(
            name: 'Customer',
            fields: ['customer'],
            collapsed: false,
          ),
        ],
      );
      expect(_names(columnGroups(titled, withPrimary: true)), [
        'null: id',
        'Customer: customer',
      ]);
      final delivery = columnGroups(_grouped)[1];
      expect(delivery.description, 'Filled in by the warehouse.');
      expect(delivery.collapsed, isTrue);
    });
  });

  testWidgets('a form groups its fields and unfolds a group with errors', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = AdminDashboardController(
      adminEndpoint: _FakeAdmin(),
      initialThemeMode: ThemeMode.light,
    );
    final submitted = <Map<String, String>>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DefaultCreateDialog(
            resource: _grouped,
            controller: controller,
            onSubmit: (payload) async {
              submitted.add(payload);
              return true;
            },
          ),
        ),
      ),
    );
    expect(find.text('Delivery'), findsOneWidget);
    expect(find.text('Filled in by the warehouse.'), findsOneWidget);
    expect(find.text('Other'), findsOneWidget);
    // The folded group's field is in the form but not shown.
    expect(find.widgetWithText(TextFormField, 'address'), findsNothing);
    expect(
      find.widgetWithText(TextFormField, 'address', skipOffstage: false),
      findsOneWidget,
    );

    for (final name in ['customer', 'status', 'note']) {
      await tester.enterText(find.widgetWithText(TextFormField, name), 'x');
    }
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();
    // The empty required address is shown with its error.
    expect(submitted, isEmpty);
    expect(find.widgetWithText(TextFormField, 'address'), findsOneWidget);
    expect(find.text('This field is required'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'address'),
      '12 Rue',
    );
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();
    expect(submitted.single, {
      'customer': 'x',
      'status': 'x',
      'address': '12 Rue',
      'note': 'x',
    });
  });

  testWidgets('details group values under their fieldsets', (tester) async {
    tester.view.physicalSize = const Size(1280, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecordDetails(
            resource: _grouped,
            record: const {
              'id': '7',
              'customer': 'Awa',
              'status': 'paid',
              'address': '12 Rue',
              'note': 'fragile',
            },
            showAppBar: false,
          ),
        ),
      ),
    );
    double top(String text) => tester.getTopLeft(find.text(text)).dy;
    expect(top('7'), lessThan(top('Awa')));
    expect(top('paid'), lessThan(top('Delivery')));
    expect(top('Delivery'), lessThan(top('Other')));
    expect(top('Other'), lessThan(top('fragile')));
    // Folded until opened.
    expect(find.text('12 Rue'), findsNothing);
    await tester.tap(find.text('Delivery'));
    await tester.pumpAndSettle();
    expect(find.text('12 Rue'), findsOneWidget);
  });
}
