import 'package:flutter/material.dart';
import 'package:serverpod_admin_dashboard/src/controller/user_profile_controller.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({
    super.key,
    required this.client,
  });

  final ServerpodClientShared client;

  static Future<bool?> show(
    BuildContext context, {
    required ServerpodClientShared client,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => ChangePasswordDialog(client: client),
    );
  }

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late final UserProfileController _controller;

  bool _hideCurrentPassword = true;
  bool _hideNewPassword = true;
  bool _hideConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _controller = UserProfileController(client: widget.client)
      ..addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await _controller.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );
    if (!mounted) return;
    if (success) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Header(isBusy: _controller.isLoading),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _PasswordField(
                        controller: _currentPasswordController,
                        label: 'Current password',
                        isBusy: _controller.isLoading,
                        obscureText: _hideCurrentPassword,
                        onToggleVisibility: () => setState(
                          () => _hideCurrentPassword = !_hideCurrentPassword,
                        ),
                        validator: _requiredPassword,
                      ),
                      const SizedBox(height: 16),
                      _PasswordField(
                        controller: _newPasswordController,
                        label: 'New password',
                        isBusy: _controller.isLoading,
                        obscureText: _hideNewPassword,
                        onToggleVisibility: () => setState(
                          () => _hideNewPassword = !_hideNewPassword,
                        ),
                        validator: _newPasswordValidator,
                      ),
                      const SizedBox(height: 16),
                      _PasswordField(
                        controller: _confirmPasswordController,
                        label: 'Confirm new password',
                        isBusy: _controller.isLoading,
                        obscureText: _hideConfirmPassword,
                        onToggleVisibility: () => setState(
                          () => _hideConfirmPassword = !_hideConfirmPassword,
                        ),
                        validator: _confirmPasswordValidator,
                      ),
                      if (_controller.errorMessage != null) ...[
                        const SizedBox(height: 16),
                        _ErrorMessage(message: _controller.errorMessage!),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            _Actions(
              isBusy: _controller.isLoading,
              onSubmit: _submit,
            ),
          ],
        ),
      ),
    );
  }

  String? _requiredPassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required.';
    return null;
  }

  String? _newPasswordValidator(String? value) {
    if (value == null || value.isEmpty) return 'New password is required.';
    if (value.length < 8) return 'Use at least 8 characters.';
    if (value == _currentPasswordController.text) {
      return 'Choose a different password.';
    }
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    if (value != _newPasswordController.text) return 'Passwords do not match.';
    return null;
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.isBusy,
    required this.obscureText,
    required this.onToggleVisibility,
    required this.validator,
  });

  final TextEditingController controller;
  final String label;
  final bool isBusy;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: !isBusy,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          onPressed: isBusy ? null : onToggleVisibility,
          icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.isBusy});

  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline, color: theme.colorScheme.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Change Password',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: isBusy ? null : () => Navigator.of(context).pop(false),
            icon: const Icon(Icons.close, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.isBusy,
    required this.onSubmit,
  });

  final bool isBusy;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: isBusy ? null : () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: isBusy ? null : onSubmit,
            icon: isBusy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_circle_outline),
            label: Text(isBusy ? 'Changing...' : 'Change'),
          ),
        ],
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
