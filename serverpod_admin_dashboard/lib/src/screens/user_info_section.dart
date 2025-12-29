import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../widgets/user_profile/dialogs/coming_soon_dialog.dart';
import '../widgets/user_profile/user_avatar.dart';
import '../widgets/user_profile/user_info_display.dart';
import '../widgets/user_profile/user_menu_button.dart';

/// User info section screen for the sidebar
///
/// Displays user avatar, name, role, and provides a menu for profile actions
class UserInfoSection extends StatelessWidget {
  const UserInfoSection({
    super.key,
    required this.client,
    required this.onLogout,
  });

  final ServerpodClientShared client;
  final VoidCallback onLogout;

  static const _horizontalPadding = 16.0;
  static const _topPadding = 16.0;
  static const _avatarSpacing = 12.0;

  String _getUserDisplayName() {
    try {
      final authInfo = client.auth.authInfo;
      if (authInfo != null) {
        // Try to get email or other identifier from authInfo
        final email = (authInfo as dynamic).email;
        if (email != null && email is String) {
          return email;
        }
        // Try user property
        final user = (authInfo as dynamic).user;
        if (user != null) {
          final userEmail = (user as dynamic).email;
          if (userEmail != null && userEmail is String) {
            return userEmail;
          }
        }
      }
    } catch (_) {
      // Ignore errors
    }
    return 'User';
  }

  void _handleProfileAction(BuildContext context) {
    ComingSoonDialog.show(context, 'Update Profile');
  }

  void _handlePasswordAction(BuildContext context) {
    ComingSoonDialog.show(context, 'Change Password');
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
          bottom: 0,
        ),
        child: Row(
          children: [
            const UserAvatar(),
            const SizedBox(width: _avatarSpacing),
            Expanded(
              child: UserInfoDisplay(displayName: displayName),
            ),
            UserMenuButton(
              onProfile: () => _handleProfileAction(context),
              onPassword: () => _handlePasswordAction(context),
              onLogout: onLogout,
            ),
          ],
        ),
      ),
    );
  }
}
