import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_admin_client/serverpod_admin_client.dart';
import 'package:serverpod_admin_dashboard/src/helpers/tabular_data.dart';

void main() {
  final resource = AdminResource(
    key: 'people',
    tableName: 'people',
    columns: [
      AdminColumn(
        name: 'id',
        dataType: 'int',
        hasDefault: true,
        isPrimary: true,
      ),
      AdminColumn(
        name: 'name',
        dataType: 'String',
        hasDefault: false,
        isPrimary: false,
      ),
      AdminColumn(
        name: 'email',
        dataType: 'String',
        hasDefault: false,
        isPrimary: false,
      ),
    ],
  );

  const records = [
    {'id': '1', 'name': 'Ada', 'email': 'ada@example.com'},
    {'id': '2', 'name': 'Grace, Hopper', 'email': 'grace@example.com'},
  ];

  group('TabularDataHelper', () {
    test('round trips CSV records', () {
      final encoded = TabularDataHelper.encodeCsv(resource, records);
      final decoded = TabularDataHelper.decodeCsv(encoded);

      expect(decoded, records);
    });

    test('round trips XLSX records', () {
      final encoded = TabularDataHelper.encodeXlsx(resource, records);
      final decoded = TabularDataHelper.decodeXlsx(encoded);

      expect(decoded, records);
    });
  });
}
