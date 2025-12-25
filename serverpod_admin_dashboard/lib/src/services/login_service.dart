import 'package:serverpod_admin_client/serverpod_admin_client.dart'
    as admin_client;
import 'package:serverpod_client/serverpod_client.dart';

/// Service for handling login operations.
/// Calls the adminLoginEndpoint.login method.
class LoginService {
  LoginService({required this.client});

  final ServerpodClientShared client;

  /// Gets the adminLogin endpoint from the client.
  admin_client.EndpointAdminLogin get _adminLoginEndpoint {
    final module = client.moduleLookup['serverpod_admin'];

    if (module is admin_client.Caller) {
      return module.adminLogin;
    }
    throw StateError(
      'Provided client has not registered the serverpod_admin module. '
      'Ensure config/generator.yaml includes it and regenerate code.',
    );
  }

  /// Performs login with email and password.
  /// Returns the authentication response containing token, authUserId, etc.
  Future<Map<String, dynamic>> login(String email, String password) async {
    return await _adminLoginEndpoint.login(email, password);
  }
}
