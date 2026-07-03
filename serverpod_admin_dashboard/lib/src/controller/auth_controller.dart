import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

/// Controller for managing authentication state and login form.
/// Uses ChangeNotifier to avoid setState calls.
class AuthController extends ChangeNotifier {
  AuthController({required this.client});
  final ServerpodClientShared client;

  bool _isAuthenticated = false;

  // Login form state
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  // Authentication state
  bool get isAuthenticated => _isAuthenticated;

  // Login form state getters
  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;
  String? get errorMessage => _errorMessage;

  /// Handles the login process using EmailAuthController.
  /// Validates the form and authenticates the user.
  /// Returns true if login was successful, false otherwise.
  Future<bool> login() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      _errorMessage = 'Email and password are required';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final controller = EmailAuthController(
        client: client,
        startScreen: EmailFlowScreen.login,
        onAuthenticated: () {
          authenticate();
        },
        onError: (error) {
          _errorMessage = loginErrorMessage(error);
          _isLoading = false;
          notifyListeners();
        },
      );
      controller.emailController.text = emailController.text;
      controller.passwordController.text = passwordController.text;
      await controller.login();

      // authenticate() is called from onAuthenticated callback if successful
      // and it already handles setting _isLoading and notifying listeners
      // So we only need to handle the case where login completed but
      // authentication failed (no admin scope)
      if (!_isAuthenticated && _errorMessage == null) {
        // Login completed but authenticate() wasn't called (shouldn't happen)
        _errorMessage = 'Incorrect email or password';
        _isLoading = false;
        notifyListeners();
      }

      return _isAuthenticated;
    } catch (e) {
      _errorMessage = loginErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  @visibleForTesting
  static String loginErrorMessage(Object error) {
    final message = error.toString().toLowerCase();
    final isSessionStorageError =
        message.contains('platformexception') && message.contains('-34018');

    if (isSessionStorageError) {
      return 'Sign-in succeeded, but the app could not save the session. '
          'Enable Keychain Sharing for the app and try again.';
    }

    final isCredentialError = message.contains('password') ||
        message.contains('credential') ||
        message.contains('invalid') ||
        message.contains('unauthorized') ||
        message.contains('authentication') ||
        message.contains('authstate');

    if (isCredentialError) {
      return 'Incorrect email or password';
    }

    return 'Unable to sign in. Please try again.';
  }

  /// Authenticates the user if they have the required admin scope.
  /// Called after successful email/password authentication.
  void authenticate() {
    final user = client.auth.authInfo;
    if (user != null && user.scopeNames.contains('serverpod.admin')) {
      _isAuthenticated = true;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
    } else {
      _errorMessage = 'User does not have admin privileges';
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _isAuthenticated = false;
    _errorMessage = null;
    emailController.clear();
    passwordController.clear();
    notifyListeners();
  }

  void toggleObscurePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
