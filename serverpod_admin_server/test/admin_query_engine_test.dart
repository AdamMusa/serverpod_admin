import 'package:serverpod/serverpod.dart';
import 'package:serverpod_admin_server/serverpod_admin_server.dart';
import 'package:serverpod_admin_server/src/admin/admin_query_engine.dart';
import 'package:test/test.dart';

// The table only needs the enum type; its values come from metadata.
// ignore: unused_field
enum _Status { pending, approved }

class _Things extends Table<int?> {
  _Things() : super(tableName: 'thing') {
    name = ColumnString('name', this);
    count = ColumnInt('count', this);
    active = ColumnBool('active', this);
    status = ColumnEnum<_Status>('status', this, EnumSerialization.byName);
    level = ColumnEnum<_Status>('level', this, EnumSerialization.byIndex);
    createdAt = ColumnDateTime('createdAt', this);
  }

  late final ColumnString name;
  late final ColumnInt count;
  late final ColumnBool active;
  late final ColumnEnum<_Status> status;
  late final ColumnEnum<_Status> level;
  late final ColumnDateTime createdAt;

  @override
  List<Column> get columns => [
    id,
    name,
    count,
    active,
    status,
    level,
    createdAt,
  ];
}

AdminColumn _column(
  String name,
  String type, {
  List<String>? enumValues,
  bool? byName,
  bool primary = false,
}) => AdminColumn(
  name: name,
  dataType: type,
  hasDefault: false,
  isPrimary: primary,
  enumValues: enumValues,
  enumSerializedByName: byName,
);

final _columns = [
  _column('id', 'int', primary: true),
  _column('name', 'String'),
  _column('count', 'int'),
  _column('active', 'bool'),
  _column(
    'status',
    '_Status',
    enumValues: ['pending', 'approved'],
    byName: true,
  ),
  _column(
    'level',
    '_Status',
    enumValues: ['pending', 'approved'],
    byName: false,
  ),
  _column('createdAt', 'DateTime'),
  _column('authUser.blocked', 'bool'),
];

AdminQuery _query({
  List<AdminFilter> filters = const [],
  String? search,
  String? sort,
  bool descending = false,
}) => AdminQuery(
  offset: 0,
  limit: 25,
  search: search,
  sortColumn: sort,
  sortDescending: descending,
  filters: filters,
);

AdminFilter _filter(String column, AdminFilterOperator op, [String? value]) =>
    AdminFilter(column: column, comparison: op, value: value);

String _where(AdminQuery query) =>
    AdminSqlQuery.build(_Things(), _columns, query)!.where.toString();

void main() {
  group('in the database', () {
    test('filters become escaped SQL of each column type', () {
      expect(
        _where(
          _query(
            filters: [
              _filter('status', AdminFilterOperator.equals, 'approved'),
              _filter('level', AdminFilterOperator.equals, 'approved'),
              _filter('active', AdminFilterOperator.equals, 'TRUE'),
              _filter('count', AdminFilterOperator.greaterOrEqual, '3'),
              _filter('name', AdminFilterOperator.contains, "50%_o'k"),
            ],
          ),
        ),
        r'''("thing"."status" = E'approved' AND "thing"."level" = 1 AND '''
        r'''"thing"."active" = TRUE AND "thing"."count" >= 3 AND '''
        r'''"thing"."name"::text ILIKE E'%50\\%\\_o\'k%' ESCAPE '\')''',
      );
    });

    test('a date as the upper bound includes the whole day', () {
      expect(
        _where(
          _query(
            filters: [
              _filter(
                'createdAt',
                AdminFilterOperator.lessOrEqual,
                '2026-10-12',
              ),
            ],
          ),
        ),
        r'''("thing"."createdAt" < E'2026-10-13')''',
      );
    });

    test('search looks in text-like columns', () {
      final where = _where(_query(search: 'awa'));
      expect(where, contains('"thing"."name"::text ILIKE'));
      expect(where, contains('"thing"."status"::text ILIKE'));
      expect(where, isNot(contains('"thing"."createdAt"')));
    });

    test('newest rows come first unless a column is chosen', () {
      final byDefault = AdminSqlQuery.build(_Things(), _columns, _query())!;
      expect(byDefault.where, isNull);
      expect(byDefault.orderBy.map((c) => '$c'), ['"thing"."id" DESC']);
      final byName = AdminSqlQuery.build(
        _Things(),
        _columns,
        _query(sort: 'name'),
      )!;
      expect(byName.orderBy.map((c) => '$c'), [
        '"thing"."name"',
        '"thing"."id" DESC',
      ]);
    });

    test('an auth user value is filtered with a subquery', () {
      final sql = AdminSqlQuery.build(
        _Things(),
        [
          ..._columns,
          AdminColumn(
            name: 'authUser.blocked',
            dataType: 'bool',
            hasDefault: false,
            isPrimary: false,
          ),
        ],
        _query(
          filters: [
            _filter('authUser.blocked', AdminFilterOperator.equals, 'true'),
          ],
        ),
        authUserColumn: 'name',
      )!;
      expect(
        '${sql.where}',
        '("thing"."name" IN (SELECT "serverpod_auth_core_user"."id" FROM '
            '"serverpod_auth_core_user" WHERE '
            '"serverpod_auth_core_user"."blocked" = TRUE))',
      );
    });

    test('columns the table does not store run in memory', () {
      expect(
        AdminSqlQuery.build(
          _Things(),
          _columns,
          _query(
            filters: [
              _filter('authUser.blocked', AdminFilterOperator.equals, 'true'),
            ],
          ),
        ),
        isNull,
      );
    });

    test('invalid values name their column', () {
      for (final filter in [
        _filter('status', AdminFilterOperator.equals, 'deleted'),
        _filter('count', AdminFilterOperator.equals, 'many'),
        _filter('createdAt', AdminFilterOperator.greaterOrEqual, 'soon'),
        _filter('name', AdminFilterOperator.greaterOrEqual, 'b'),
        _filter('missing', AdminFilterOperator.equals, 'x'),
      ]) {
        expect(
          () => AdminSqlQuery.build(
            _Things(),
            _columns,
            _query(filters: [filter]),
          ),
          throwsA(
            isA<AdminValidationException>().having(
              (e) => e.field,
              'field',
              filter.column,
            ),
          ),
        );
      }
    });
  });

  group('in memory', () {
    final rows = [
      {
        'id': '1',
        'name': 'Awa',
        'count': '9',
        'createdAt': '2026-10-01T10:00:00.000Z',
      },
      {
        'id': '2',
        'name': 'Moussa',
        'count': '10',
        'createdAt': '2026-10-12T22:00:00.000Z',
      },
      {'id': '3', 'name': 'awa ba', 'count': '', 'createdAt': ''},
    ];

    test('filters, searches, sorts by type and pages', () {
      final page = AdminRowQuery.apply(
        rows,
        _columns,
        _query(
          filters: [_filter('count', AdminFilterOperator.greaterOrEqual, '9')],
          sort: 'count',
          descending: true,
        ),
      );
      expect(page.total, 2);
      expect(page.rows.map((r) => r['id']), ['2', '1']);
      expect(
        AdminRowQuery.apply(rows, _columns, _query(search: 'AWA')).total,
        2,
      );
      expect(
        AdminRowQuery.apply(
          rows,
          _columns,
          _query(
            filters: [
              _filter(
                'createdAt',
                AdminFilterOperator.lessOrEqual,
                '2026-10-12',
              ),
            ],
          ),
        ).rows.map((r) => r['id']),
        ['2', '1'],
      );
      expect(
        AdminRowQuery.apply(
          rows,
          _columns,
          _query(filters: [_filter('count', AdminFilterOperator.isEmpty)]),
        ).rows.single['id'],
        '3',
      );
    });

    test('newest rows come first by default', () {
      expect(
        AdminRowQuery.apply(rows, _columns, _query()).rows.map((r) => r['id']),
        ['3', '2', '1'],
      );
    });
  });
}
