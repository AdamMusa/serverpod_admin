import 'package:flutter/material.dart';
import 'package:serverpod_admin_dashboard/src/services/login_service.dart';

/// Controller for managing login form state.
/// Uses ChangeNotifier to avoid setState calls.
class LoginController extends ChangeNotifier {
  LoginController({required this.loginService});

  final LoginService loginService;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;
  String? get errorMessage => _errorMessage;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setObscurePassword(bool value) {
    _obscurePassword = value;
    notifyListeners();
  }

  void toggleObscurePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Performs login using the login service.
  /// Returns the authentication response if successful, null otherwise.
  Future<Map<String, dynamic>?> performLogin() async {
    if (usernameController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      setError('Email and password are required');
      return null;
    }

    clearError();
    setLoading(true);

    try {
      final response = await loginService.login(
        usernameController.text.trim(),
        passwordController.text,
      );
      setLoading(false);
      return response;
    } catch (e) {
      setLoading(false);
      setError('Invalid email or password. Please try again.');
      return null;
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
