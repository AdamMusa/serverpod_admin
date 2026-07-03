import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_admin_dashboard/src/controller/auth_controller.dart';

void main() {
  group('AuthController.loginErrorMessage', () {
    test('hides secure storage platform exceptions behind credential message',
        () {
      final message = AuthController.loginErrorMessage(
        "PlatformException(Unexpected security result code, "
        "Code: -34018, Message: A required entitlement isn't present.)",
      );

      expect(message, 'Incorrect email or password');
    });

    test('hides password failures behind credential message', () {
      final message = AuthController.loginErrorMessage(
        'EmailAuthState.authenticated: invalid password',
      );

      expect(message, 'Incorrect email or password');
    });
  });
}
