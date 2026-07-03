import 'package:flutter/material.dart';
import 'package:serverpod_admin_dashboard/src/controller/user_profile_controller.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../widgets/user_profile/dialogs/change_password_dialog.dart';
import '../widgets/user_profile/dialogs/update_profile_dialog.dart';
import '../widgets/user_profile/user_avatar.dart';
import '../widgets/user_profile/user_info_display.dart';
import '../widgets/user_profile/user_menu_button.dart';

/// User info section screen for the sidebar.
class UserInfoSection extends StatefulWidget {
  const UserInfoSection({
    super.key,
    required this.client,
    required this.onLogout,
  });

  final ServerpodClientShared client;
  final VoidCallback onLogout;

  @override
  State<UserInfoSection> createState() => _UserInfoSectionState();
}

class _UserInfoSectionState extends State<UserInfoSection> {
  static const _horizontalPadding = 16.0;
  static const _topPadding = 16.0;
  static const _avatarSpacing = 12.0;

  late final UserProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = UserProfileController(client: widget.client)
      ..addListener(_onControllerChanged);
    _controller.loadUserProfile();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  String _getUserDisplayName() {
    final profile = _controller.userProfile;
    final fullName = profile?['fullName'];
    if (fullName != null && fullName.isNotEmpty) return fullName;

    final userName = profile?['userName'];
    if (userName != null && userName.isNotEmpty) return userName;

    final email = profile?['email'];
    if (email != null && email.isNotEmpty) return email;

    try {
      final authInfo = widget.client.auth.authInfo;
      if (authInfo != null) {
        final authEmail = (authInfo as dynamic).email;
        if (authEmail is String && authEmail.isNotEmpty) return authEmail;
        final user = (authInfo as dynamic).user;
        if (user != null) {
          final userEmail = (user as dynamic).email;
          if (userEmail is String && userEmail.isNotEmpty) return userEmail;
        }
      }
    } catch (_) {
      // Fall back to a neutral label when the auth payload has no email.
    }
    return 'User';
  }

  Future<void> _handleProfileAction(BuildContext context) async {
    final updated = await UpdateProfileDialog.show(
      context,
      client: widget.client,
    );
    if (updated == true) {
      await _controller.loadUserProfile();
    }
  }

  Future<void> _handlePasswordAction(BuildContext context) async {
    await ChangePasswordDialog.show(
      context,
      client: widget.client,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = _getUserDisplayName();

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: _horizontalPadding,
          right: _horizontalPadding,
          top: _topPadding,
        ),
        child: Row(
          children: [
            const UserAvatar(),
            const SizedBox(width: _avatarSpacing),
            Expanded(child: UserInfoDisplay(displayName: displayName)),
            UserMenuButton(
              onProfile: () => _handleProfileAction(context),
              onPassword: () => _handlePasswordAction(context),
              onLogout: widget.onLogout,
            ),
          ],
        ),
      ),
    );
  }
}
