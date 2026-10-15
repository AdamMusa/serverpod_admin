import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

/// Controller for managing authentication state and login form.
/// Uses ChangeNotifier to avoid setState calls.
class AuthController extends ChangeNotifier {
  AuthController({
    required this.client,
    this.staffScopes = const {},
    this.serverAccess,
  }) : _isAuthenticated = _hasAdminScope(client.auth.authInfo, staffScopes);

  /// Scope names, besides serverpod.admin, that may sign in.
  final Set<String> staffScopes;

  /// Asks the server whether the signed-in user may open the dashboard, for
  /// users holding neither serverpod.admin nor one of [staffScopes] (staff
  /// roles the server grants with AdminRegistry.staffScopes).
  final Future<bool> Function()? serverAccess;

  Future<void>? _authenticating;

  final ServerpodClientShared client;

  bool _isAuthenticated;

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

  Future<void> restoreAuthentication() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await client.auth.initialize();
      if (client.auth.authInfo == null) {
        _isAuthenticated = false;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      } else {
        await authenticate();
      }
    } catch (_) {
      _isAuthenticated = _hasAdminScope(client.auth.authInfo, staffScopes);
      _isLoading = false;
      notifyListeners();
    }
  }

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
          _authenticating = authenticate();
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
      await _authenticating;
      _authenticating = null;

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

  /// Authenticates the user if they may open the dashboard: they hold the
  /// admin scope or a staff scope, or the server says so.
  /// Called after successful email/password authentication.
  Future<void> authenticate() async {
    final user = client.auth.authInfo;
    if (_hasAdminScope(user, staffScopes) ||
        (user != null && await _serverAllows())) {
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

  Future<bool> _serverAllows() async {
    final ask = serverAccess;
    if (ask == null) return false;
    try {
      return await ask();
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _errorMessage = null;
    emailController.clear();
    passwordController.clear();
    notifyListeners();

    try {
      await client.auth.signOutDevice();
    } catch (_) {
      await client.auth.updateSignedInUser(null);
    }
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

/// Whether the signed-in user may open the dashboard: administrators, or
/// staff holding one of [staffScopes].
bool _hasAdminScope(dynamic authInfo, Set<String> staffScopes) {
  if (authInfo == null) return false;
  final Set<String> scopes = {...authInfo.scopeNames};
  return scopes.contains('serverpod.admin') ||
      scopes.intersection(staffScopes).isNotEmpty;
}
