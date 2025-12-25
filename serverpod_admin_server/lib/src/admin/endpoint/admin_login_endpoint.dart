import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';

/// Login endpoint for admin dashboard authentication.
/// This endpoint does not require authentication (it's the login itself).
class AdminLoginEndpoint extends Endpoint {
  /// Login endpoint that authenticates users via email/password.
  /// Makes a POST request to the emailIdp/login endpoint.
  Future<Map<String, dynamic>> login(
    Session session,
    String email,
    String password,
  ) async {
    try {
      final httpClient = HttpClient();
      final uri = Uri.parse('${session.request!.url.origin}/emailIdp/login');
      print("Here is the session request url: $uri");

      final request = await httpClient.postUrl(uri);
      request.headers.set('Content-Type', 'application/json');

      final requestBody = jsonEncode({
        'email': email,
        'password': password,
      });

      request.write(requestBody);
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      httpClient.close();

      if (response.statusCode != 200) {
        throw ArgumentError(
          'Login failed: ${response.statusCode} - $responseBody',
        );
      }

      final responseData = jsonDecode(responseBody) as Map<String, dynamic>;

      session.log('AdminLoginEndpoint.login successful for email: $email');

      return responseData;
    } catch (e) {
      session.log('AdminLoginEndpoint.login error: $e');
      if (e is ArgumentError) {
        rethrow;
      }
      throw ArgumentError('Login failed: ${e.toString()}');
    }
  }
}
