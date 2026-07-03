import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_admin_dashboard/src/controller/auth_controller.dart';

void main() {
  group('AuthController.loginErrorMessage', () {
    test('explains secure storage platform exceptions after auth succeeds', () {
      final message = AuthController.loginErrorMessage(
        "PlatformException(Unexpected security result code, "
        "Code: -34018, Message: A required entitlement isn't present.)",
      );

      expect(
        message,
        'Sign-in succeeded, but the app could not save the session. '
        'Enable Keychain Sharing for the app and try again.',
      );
    });

    test('hides password failures behind credential message', () {
      final message = AuthController.loginErrorMessage(
        'EmailAuthState.authenticated: invalid password',
      );

      expect(message, 'Incorrect email or password');
    });
  });
}
