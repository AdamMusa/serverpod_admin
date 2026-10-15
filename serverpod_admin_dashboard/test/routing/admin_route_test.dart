import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_admin_client/serverpod_admin_client.dart';
import 'package:serverpod_admin_dashboard/src/routing/admin_route.dart';

AdminRoute _parse(String location) => AdminRoute.fromUri(Uri.parse(location));

void main() {
  test('the overview is the root', () {
    expect(AdminRoute.overview.toUri().toString(), '/');
    expect(_parse('/'), AdminRoute.overview);
    expect(_parse(''), AdminRoute.overview);
  });

  test('a record is its table and id', () {
    const route = AdminRoute(resourceKey: 'ride', recordId: '12');
    expect(route.toUri().toString(), '/ride/12');
    expect(_parse('/ride/12'), route);
    // Ids are escaped.
    const odd = AdminRoute(resourceKey: 'tag', recordId: 'a b/c');
    expect(_parse(odd.toUri().toString()), odd);
  });

  test('a page keeps its search, sort, filters and size', () {
    final route = AdminRoute(
      resourceKey: 'ride',
      page: 1,
      rowsPerPage: 50,
      sortColumn: 'fare',
      sortDescending: true,
      search: 'air port',
      filters: [
        AdminFilter(
          column: 'status',
          comparison: AdminFilterOperator.equals,
          value: 'open',
        ),
        AdminFilter(
          column: 'requestedAt',
          comparison: AdminFilterOperator.greaterOrEqual,
          value: '2026-10-01',
        ),
        AdminFilter(
          column: 'driverId',
          comparison: AdminFilterOperator.isEmpty,
        ),
        AdminFilter(
          column: 'id',
          comparison: AdminFilterOperator.oneOf,
          value: '1,2',
        ),
      ],
    );
    final location = route.toUri().toString();
    expect(
      location,
      '/ride?q=air+port&sort=-fare&page=2&per=50&status__exact=open'
      '&requestedAt__gte=2026-10-01&driverId__isempty=1&id__in=1%2C2',
    );
    expect(_parse(location), route);
    expect(_parse(location).hashCode, route.hashCode);
  });

  test('every comparison has a name', () {
    for (final comparison in AdminFilterOperator.values) {
      final route = AdminRoute(
        resourceKey: 'ride',
        filters: [
          AdminFilter(column: 'status', comparison: comparison, value: 'x'),
        ],
      );
      final parsed = _parse(route.toUri().toString());
      expect(parsed.filters.single.comparison, comparison);
      expect(parsed, route);
    }
  });

  test('what an address does not say is left at the defaults', () {
    expect(
      _parse('/ride?page=abc&per=&sort=-&other=1&status__nope=x&__exact=y'),
      const AdminRoute(resourceKey: 'ride'),
    );
    expect(_parse('/ride?page=0'), const AdminRoute(resourceKey: 'ride'));
    expect(_parse('/ride?sort=status').sortColumn, 'status');
    // Column names may hold underscores.
    expect(
      _parse('/ride?created__at__gte=1').filters.single.column,
      'created__at',
    );
  });

  test('a search alone can change', () {
    const a = AdminRoute(resourceKey: 'ride', search: 'ai', page: 0);
    expect(
      a.withSearch('air'),
      const AdminRoute(resourceKey: 'ride', search: 'air'),
    );
    expect(a.withSearch(''), isNot(a));
  });
}
