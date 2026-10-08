import 'package:serverpod_admin_server/serverpod_admin_server.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    show AuthUser;
import 'package:test/test.dart';

void main() {
  final registry = AdminRegistry();
  setUp(registry.reset);
  tearDown(registry.reset);

  test('auth users are offered for managing admin access', () {
    expect(registry[AuthUser], isNull);
    registry.registerAuthUsers();
    expect(registry[AuthUser], isNotNull);
    expect(
      registry.entryByKey('serverpod_auth_core_user'),
      same(registry[AuthUser]),
    );
  });
}
