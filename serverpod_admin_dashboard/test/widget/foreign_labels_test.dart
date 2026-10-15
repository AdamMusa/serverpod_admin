import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_admin_client/serverpod_admin_client.dart';
import 'package:serverpod_admin_dashboard/src/widgets/records_body/records_body.dart';

AdminColumn _col(String name, {bool pk = false, String? fk}) => AdminColumn(
  name: name,
  dataType: pk || fk != null ? 'int' : 'String',
  hasDefault: pk,
  isPrimary: pk,
  foreignKeyTable: fk,
);

void main() {
  testWidgets('names of rows in one table are read in one request', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final requests = <(String, Set<String>)>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecordsBody(
            resource: AdminResource(
              key: 'ride',
              tableName: 'ride',
              columns: [
                _col('id', pk: true),
                _col('passengerId', fk: 'user_profile'),
                _col('driverId', fk: 'user_profile'),
                _col('vehicleId', fk: 'vehicle'),
              ],
            ),
            records: const [
              {
                'id': '1',
                'passengerId': '7',
                'driverId': '8',
                'vehicleId': '3',
              },
              {'id': '2', 'passengerId': '9', 'driverId': '8'},
            ],
            isLoading: false,
            errorMessage: null,
            onEdit: null,
            onDelete: null,
            onOpenForeign: (column, id) {},
            loadForeignLabels: (column, ids) async {
              requests.add((column.foreignKeyTable!, ids));
              return {for (final id in ids) id: 'Name $id'};
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(requests, hasLength(2));
    final users = requests.firstWhere((r) => r.$1 == 'user_profile').$2;
    expect(users, {'7', '8', '9'});
    // Both columns show the names.
    expect(find.text('Name 7'), findsOneWidget);
    expect(find.text('Name 8'), findsNWidgets(2));
  });
}
