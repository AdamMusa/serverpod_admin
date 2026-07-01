import 'package:serverpod_admin_server/serverpod_admin_server.dart';
import 'package:test/test.dart';

void main() {
  group('AdminUser.create', () {
    test('rejects an empty email', () async {
      await expectLater(
        AdminUser.create(email: ' ', password: 'password'),
        throwsArgumentError,
      );
    });

    test('rejects an empty password', () async {
      await expectLater(
        AdminUser.create(email: 'admin@example.com', password: ''),
        throwsArgumentError,
      );
    });
  });
}
