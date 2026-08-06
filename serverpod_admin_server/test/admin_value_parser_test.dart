import 'package:serverpod/serverpod.dart';
import 'package:serverpod_admin_server/src/admin/admin_value_parser.dart';
import 'package:test/test.dart';

void main() {
  final table = _ParserTable();

  test('N/A is preserved for model validation', () {
    expect(parseAdminColumnValue(table.label, 'N/A'), 'N/A');
    expect(parseAdminColumnValue(table.location, 'N/A'), 'N/A');
    expect(parseAdminColumnValue(table.label, ' N/A '), ' N/A ');
  });

  test('valid EWKT geography values are preserved', () {
    const value = 'SRID=4326;POINT(-73.9857 40.7484)';
    expect(parseAdminColumnValue(table.location, value), value);
  });
}

class _ParserTable extends Table<int?> {
  _ParserTable() : super(tableName: 'parser_test') {
    label = ColumnString('label', this);
    location = ColumnGeographyPoint('location', this);
  }

  late final ColumnString label;
  late final ColumnGeographyPoint location;

  @override
  List<Column> get columns => [id, label, location];
}
