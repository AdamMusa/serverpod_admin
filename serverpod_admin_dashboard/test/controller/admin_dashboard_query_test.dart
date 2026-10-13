import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_admin_client/serverpod_admin_client.dart'
    hide AdminColumn, AdminResource;
import 'package:serverpod_admin_dashboard/serverpod_admin_dashboard.dart';

/// Answers queries from a list of rows and records what was asked.
class _FakeAdmin implements EndpointAdmin {
  _FakeAdmin(this.rows);

  final List<Map<String, String>> rows;
  final queries = <AdminQuery>[];
  Completer<void>? hold;

  @override
  Future<List<AdminResource>> resources() async => [_resource];

  @override
  Future<AdminPage> query(String resourceKey, AdminQuery query) async {
    queries.add(query);
    final gate = hold;
    if (gate != null) await gate.future;
    final end = (query.offset + query.limit).clamp(0, rows.length);
    return AdminPage(
      rows: rows.sublist(query.offset.clamp(0, rows.length), end),
      total: rows.length,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _resource = AdminResource(
  key: 'ride',
  tableName: 'ride',
  columns: [
    AdminColumn(name: 'id', dataType: 'int', hasDefault: true, isPrimary: true),
    AdminColumn(
      name: 'status',
      dataType: 'RideStatus',
      hasDefault: false,
      isPrimary: false,
      enumValues: ['requested', 'completed'],
    ),
  ],
);

List<Map<String, String>> _rows(int count) => [
  for (var i = count; i > 0; i--) {'id': '$i', 'status': 'requested'},
];

void main() {
  late _FakeAdmin admin;
  late AdminDashboardController controller;

  setUp(() async {
    admin = _FakeAdmin(_rows(60));
    controller = AdminDashboardController(
      adminEndpoint: admin,
      initialThemeMode: ThemeMode.light,
    );
    await controller.loadResources();
  });

  test('the first page loads with the total', () {
    expect(controller.records, hasLength(25));
    expect(controller.totalRecords, 60);
    expect(controller.pageCount, 3);
    expect(admin.queries.last.offset, 0);
  });

  test('paging, sorting and filters are asked of the server', () async {
    controller.goToPage(2);
    await pumpEventQueue();
    expect(admin.queries.last.offset, 50);
    expect(controller.records, hasLength(10));

    controller.sortBy('status');
    await pumpEventQueue();
    expect(admin.queries.last.sortColumn, 'status');
    expect(admin.queries.last.sortDescending, isFalse);
    expect(admin.queries.last.offset, 0);
    controller.sortBy('status');
    await pumpEventQueue();
    expect(admin.queries.last.sortDescending, isTrue);

    final filter = AdminFilter(
      column: 'status',
      comparison: AdminFilterOperator.equals,
      value: 'completed',
    );
    controller.setFilters([filter]);
    await pumpEventQueue();
    expect(admin.queries.last.filters, [filter]);
    controller.removeFilter(filter);
    await pumpEventQueue();
    expect(admin.queries.last.filters, isEmpty);
  });

  test('search waits for typing to pause', () async {
    final before = admin.queries.length;
    controller.setSearchQuery('a');
    controller.setSearchQuery('aw');
    controller.setSearchQuery('awa');
    await Future<void>.delayed(const Duration(milliseconds: 450));
    expect(admin.queries.length, before + 1);
    expect(admin.queries.last.search, 'awa');
  });

  test('a slower earlier reply never replaces a newer page', () async {
    final slow = Completer<void>();
    admin.hold = slow;
    controller.goToPage(1);
    admin.hold = null;
    controller.goToPage(2);
    await pumpEventQueue();
    expect(controller.records.first['id'], '10');
    slow.complete(); // Page 1 answers last.
    await pumpEventQueue();
    expect(controller.pageIndex, 2);
    expect(controller.records.first['id'], '10');
  });

  test('export reads every matching row, page by page', () async {
    admin.rows
      ..clear()
      ..addAll(_rows(1200));
    final all = await controller.fetchAllMatching(_resource);
    expect(all, hasLength(1200));
    expect(
      admin.queries.reversed.take(3).map((q) => q.limit),
      everyElement(500),
    );
  });
}
