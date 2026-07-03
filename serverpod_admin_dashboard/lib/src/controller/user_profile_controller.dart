import 'package:flutter/material.dart';
import 'package:serverpod_admin_client/serverpod_admin_client.dart'
    as admin_client;
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

/// Controller for signed-in admin profile actions.
class UserProfileController extends ChangeNotifier {
  UserProfileController({required this.client})
      : _adminEndpoint = _resolveAdminEndpoint(client);

  final ServerpodClientShared client;
  final admin_client.EndpointAdmin _adminEndpoint;

  Map<String, String>? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, String>? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  static admin_client.EndpointAdmin _resolveAdminEndpoint(
    ServerpodClientShared client,
  ) {
    final module = client.moduleLookup['serverpod_admin'];
    if (module is admin_client.Caller) {
      return module.admin;
    }
    throw StateError(
      'Provided client has not registered the serverpod_admin module.',
    );
  }

  Future<void> loadUserProfile() async {
    _setLoading(true);
    _setError(null);
    try {
      _userProfile = await _adminEndpoint.currentUserProfile();
    } catch (e) {
      _setError(_friendlyError(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile({
    required String userName,
    required String fullName,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      _userProfile = await _adminEndpoint.updateCurrentUserProfile(
        userName,
        fullName,
      );
      return true;
    } catch (e) {
      _setError(_friendlyError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      await _adminEndpoint.changeCurrentUserPassword(
        currentPassword,
        newPassword,
      );
      return true;
    } catch (e) {
      _setError(_friendlyError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _errorMessage = value;
    notifyListeners();
  }

  String _friendlyError(Object error) {
    final message = error.toString();
    if (message.contains('invalidCredentials') ||
        message.contains('Current password is incorrect')) {
      return 'Current password is incorrect.';
    }
    if (message.contains('tooManyAttempts')) {
      return 'Too many attempts. Try again later.';
    }
    if (message.contains('passwordPolicyViolation')) {
      return 'The new password does not meet the password policy.';
    }
    return message.replaceFirst('Exception: ', '');
  }
}
