import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

/// Controller for managing user profile state.
/// Uses ChangeNotifier to avoid setState calls.
class UserProfileController extends ChangeNotifier {
  UserProfileController({required this.client});

  final ServerpodClientShared client;

  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Loads the user profile from the server
  Future<void> loadUserProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get authInfo - use extension override to specify FlutterAuthSessionManagerExtension
      final authInfo = FlutterAuthSessionManagerExtension(client).auth.authInfo;
      if (authInfo == null) {
        _errorMessage = 'User not authenticated';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Get userId from AuthSuccess - access the user property directly
      final userId = (authInfo as dynamic).user?.id;

      if (userId == null) {
        _errorMessage = 'User ID not found in AuthSuccess';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Access modules through the client
      dynamic modules;
      try {
        modules = (client as dynamic).modules;
        if (modules == null) {
          // Try alternative access
          modules = (client as dynamic).moduleLookup;
        }
      } catch (e) {
        _errorMessage = 'Cannot access modules: $e';
        _isLoading = false;
        notifyListeners();
        return;
      }

      if (modules == null) {
        _errorMessage = 'Modules not available on client';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Try to get serverpod_auth_core module
      dynamic authCoreModule;
      try {
        authCoreModule = modules.serverpod_auth_core;
      } catch (_) {
        // Try alternative access
        try {
          authCoreModule = modules['serverpod_auth_core'];
        } catch (_) {
          _errorMessage = 'serverpod_auth_core module not found';
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      if (authCoreModule == null) {
        _errorMessage = 'serverpod_auth_core module is null';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Call getUserProfile - it might return null if profile doesn't exist
      UserProfile? profile;
      try {
        profile = await authCoreModule.getUserProfile(userId);
      } catch (e) {
        // If getUserProfile fails, try to create a profile or handle the error
        // Some implementations might require creating the profile first
        try {
          // Try to create profile if it doesn't exist
          profile = await authCoreModule.createUserProfile(
            authUserId: userId,
          );
        } catch (createError) {
          // If both fail, show the original error
          throw e;
        }
      }

      if (profile == null) {
        _errorMessage = 'Profile not found and could not be created';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _userProfile = profile;
      _errorMessage = null;
    } catch (e, stackTrace) {
      _errorMessage =
          'Error loading profile: $e\n${stackTrace.toString().split('\n').take(3).join('\n')}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates the user profile
  Future<bool> updateProfile({
    String? userName,
    String? fullName,
    String? email,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final modules = (client as dynamic).modules;
      if (modules != null) {
        final updated = await modules.serverpod_auth_core.updateUserProfile(
          userName: userName?.trim().isEmpty == true ? null : userName?.trim(),
          fullName: fullName?.trim().isEmpty == true ? null : fullName?.trim(),
          email: email?.trim().isEmpty == true ? null : email?.trim(),
        );
        _userProfile = updated;
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Modules not available';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
