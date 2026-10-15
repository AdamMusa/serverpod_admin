import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_admin_client/serverpod_admin_client.dart'
    hide AdminColumn, AdminResource;
import 'package:serverpod_admin_dashboard/serverpod_admin_dashboard.dart';

AdminColumn _col(
  String name, {
  String type = 'String',
  bool primary = false,
  String? fk,
}) => AdminColumn(
  name: name,
  dataType: type,
  hasDefault: false,
  isPrimary: primary,
  foreignKeyTable: fk,
);

final _users = AdminResource(
  key: 'user_profile',
  tableName: 'user_profile',
  columns: [
    _col('id', type: 'int', primary: true),
    _col('fullName'),
  ],
);
final _rides = AdminResource(
  key: 'ride',
  tableName: 'ride',
  columns: [
    _col('id', type: 'int', primary: true),
    _col('passengerId', type: 'int', fk: 'user_profile'),
  ],
  actions: [
    AdminActionInfo(
      name: 'refund',
      label: 'Refund',
      confirm: true,
      destructive: false,
    ),
  ],
);

/// Serves users and rides, honouring equals and oneOf filters.
class _FakeAdmin implements EndpointAdmin {
  final data = {
    'user_profile': [
      {'id': '1', 'fullName': 'Awa Diallo'},
      {'id': '2', 'fullName': 'Moussa Ba'},
    ],
    'ride': [
      {'id': '10', 'passengerId': '1'},
      {'id': '11', 'passengerId': '1'},
      {'id': '12', 'passengerId': '2'},
    ],
  };
  final calls = <String>[];

  @override
  Future<List<AdminResource>> resources() async => [_users, _rides];

  @override
  Future<AdminPage> query(String resourceKey, AdminQuery query) async {
    var rows = data[resourceKey]!;
    for (final filter in query.filters) {
      final wanted = filter.comparison == AdminFilterOperator.oneOf
          ? filter.value!.split(',')
          : [filter.value];
      rows = rows.where((r) => wanted.contains(r[filter.column])).toList();
    }
    return AdminPage(
      rows: rows.skip(query.offset).take(query.limit).toList(),
      total: rows.length,
    );
  }

  @override
  Future<AdminActionResult> deleteMany(String key, List<String> ids) async {
    calls.add('delete $key ${ids.join(',')}');
    return AdminActionResult(affected: ids.length, message: 'Deleted');
  }

  @override
  Future<AdminActionResult> updateMany(
    String key,
    List<String> ids,
    Map<String, String> values,
  ) async {
    calls.add('update $key ${ids.join(',')} $values');
    return AdminActionResult(affected: ids.length);
  }

  @override
  Future<AdminActionResult> runAction(
    String key,
    String name,
    List<String> ids,
  ) async {
    calls.add('action $key $name ${ids.join(',')}');
    return AdminActionResult(affected: ids.length, message: 'Refunded');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

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

  test('the overview counts every table', () async {
    expect(await controller.resourceCounts(), {'user_profile': 2, 'ride': 3});
  });

  test('foreign keys are named from their rows, in one request', () async {
    final column = _rides.columns.last;
    expect(controller.relatedResource(column)?.key, 'user_profile');
    expect(await controller.labelsFor(_users, ['1', '2']), {
      '1': 'Awa Diallo (#1)',
      '2': 'Moussa Ba (#2)',
    });
  });

  test('a record lists the rows pointing at it, with a link to all', () async {
    final related = await controller.relatedRecords(_users, {
      'id': '1',
      'fullName': 'Awa Diallo',
    });
    expect(related.single.resource.key, 'ride');
    expect(related.single.total, 2);

    await controller.showFiltered(related.single.resource, [
      AdminFilter(
        column: 'passengerId',
        comparison: AdminFilterOperator.equals,
        value: '1',
      ),
    ]);
    expect(controller.selectedResource?.key, 'ride');
    expect(controller.records.map((r) => r['id']), ['10', '11']);
  });

  test('opening a related record shows its details', () async {
    await controller.openRecord(_users, '2');
    expect(controller.isShowingDetails, isTrue);
    expect(controller.detailsRecord?['fullName'], 'Moussa Ba');
  });

  test('selected rows are deleted, changed or acted on together', () async {
    await controller.selectResource(_rides);
    controller.selectPage(true);
    expect(controller.selectedIds, {'10', '11', '12'});
    controller.toggleSelected('12', false);

    final refunded = await controller.runActionOnSelected('refund');
    expect(refunded.message, 'Refunded');
    expect(admin.calls.last, 'action ride refund 10,11');
    expect(controller.selectedIds, isEmpty);

    controller.toggleSelected('12', true);
    await controller.updateSelected({'passengerId': '2'});
    expect(admin.calls.last, 'update ride 12 {passengerId: 2}');

    await controller.selectAllMatching();
    expect(controller.selectedIds, {'10', '11', '12'});
    await controller.deleteSelected();
    expect(admin.calls.last, 'delete ride 10,11,12');
  });
}
