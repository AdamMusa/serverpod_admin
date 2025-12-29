import 'package:flutter/material.dart';
import 'package:serverpod_admin_client/serverpod_admin_client.dart';
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
  AdminResponse? _adminResponse;

  // Authentication state
  bool get isAuthenticated => _isAuthenticated;

  // Login form state getters
  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;
  String? get errorMessage => _errorMessage;
  AdminResponse? get adminResponse => _adminResponse;

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
          _errorMessage = error.toString();
          _isLoading = false;
          notifyListeners();
        },
      );
      controller.emailController.text = emailController.text;
      controller.passwordController.text = passwordController.text;
      await controller.login();

      // If authentication was successful, authenticate() will be called
      // which sets _isAuthenticated and notifies listeners
      if (_isAuthenticated) {
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Authenticates the user if they have the required admin scope.
  /// Called after successful email/password authentication.
  void authenticate() {
    final user = client.auth.authInfo;
    if (user != null && user.scopeNames.contains('serverpod.admin')) {
      _isAuthenticated = true;
      _errorMessage = null;
      notifyListeners();
    } else {
      _errorMessage = 'User does not have admin privileges';
      _isAuthenticated = false;
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
