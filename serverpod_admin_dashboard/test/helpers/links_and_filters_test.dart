import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_admin_client/serverpod_admin_client.dart';
import 'package:serverpod_admin_dashboard/src/helpers/filters.dart';
import 'package:serverpod_admin_dashboard/src/helpers/links.dart';

AdminColumn _column(String name, String type, {List<String>? enumValues}) =>
    AdminColumn(
      name: name,
      dataType: type,
      hasDefault: false,
      isPrimary: false,
      enumValues: enumValues,
    );

void main() {
  test('links are recognised by their path or a file named in the query', () {
    expect(linkKind('https://cdn.example.com/a/photo.JPG'), LinkKind.image);
    expect(
      linkKind(
        'https://abraid.app/admin/document-preview?document=private%3A%2F%2Fdriver_documents%2Flicence.png&expires=1&signature=x',
      ),
      LinkKind.image,
    );
    expect(linkKind('https://example.com/files/insurance.pdf'), LinkKind.pdf);
    expect(linkKind('https://example.com/terms'), LinkKind.page);
    for (final value in [
      null,
      '',
      'Awa Diallo',
      'private://driver_documents/licence.jpg',
      'ftp://example.com/a.pdf',
      'https://example.com/a b.pdf',
    ]) {
      expect(linkKind(value), isNull, reason: '$value');
    }
  });

  test('each kind of column offers the comparisons that fit it', () {
    expect(filterKindOf(_column('n', 'int')), FilterValueKind.number);
    expect(filterKindOf(_column('d', 'DateTime')), FilterValueKind.date);
    expect(filterKindOf(_column('b', 'bool')), FilterValueKind.boolean);
    expect(
      filterKindOf(_column('s', 'Status', enumValues: ['a'])),
      FilterValueKind.enumeration,
    );
    expect(filterKindOf(_column('t', 'Set<String>')), FilterValueKind.list);
    expect(filterKindOf(_column('x', 'String')), FilterValueKind.text);
    expect(
      operatorsFor(FilterValueKind.date),
      contains(AdminFilterOperator.lessOrEqual),
    );
    expect(
      operatorsFor(FilterValueKind.text),
      isNot(contains(AdminFilterOperator.greaterOrEqual)),
    );
  });

  test('filters read as sentences', () {
    final resource = AdminResource(
      key: 'ride',
      tableName: 'ride',
      columns: [_column('requestedAt', 'DateTime'), _column('note', 'String')],
    );
    expect(
      describeFilter(
        AdminFilter(
          column: 'requestedAt',
          comparison: AdminFilterOperator.greaterOrEqual,
          value: '2026-10-01',
        ),
        resource,
      ),
      'requestedAt on or after 2026-10-01',
    );
    expect(
      describeFilter(
        AdminFilter(column: 'note', comparison: AdminFilterOperator.isEmpty),
        resource,
      ),
      'note is empty',
    );
  });
}
