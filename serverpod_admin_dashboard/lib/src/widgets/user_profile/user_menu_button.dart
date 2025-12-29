import 'package:flutter/material.dart';
import 'widgets/user_menu_item.dart';

/// Menu button widget that safely handles popup menu
class UserMenuButton extends StatelessWidget {
  const UserMenuButton({
    super.key,
    required this.onProfile,
    required this.onPassword,
    required this.onLogout,
  });

  final VoidCallback onProfile;
  final VoidCallback onPassword;
  final VoidCallback onLogout;

  static const _menuWidth = 200.0;
  static const _menuHeight = 200.0;
  static const _menuPadding = 8.0;

  List<UserMenuItem> _buildMenuItems() {
    return [
      const UserMenuItem(
        value: 'profile',
        label: 'Update Profile',
        icon: Icons.person_outline,
      ),
      const UserMenuItem(
        value: 'password',
        label: 'Change Password',
        icon: Icons.lock_outline,
      ),
      const UserMenuItem(
        value: 'logout',
        label: 'Logout',
        icon: Icons.logout,
        isDestructive: true,
      ),
    ];
  }

  void _handleMenuSelection(String? value) {
    switch (value) {
      case 'profile':
        onProfile();
        break;
      case 'password':
        onPassword();
        break;
      case 'logout':
        onLogout();
        break;
    }
  }

  RelativeRect _calculateMenuPosition(
    BuildContext context,
    RenderBox buttonBox,
  ) {
    final Offset buttonPosition = buttonBox.localToGlobal(Offset.zero);
    final Size buttonSize = buttonBox.size;
    final Size screenSize = MediaQuery.of(context).size;

    final double left = buttonPosition.dx + buttonSize.width - _menuWidth;
    final double top = buttonPosition.dy + buttonSize.height;
    final double right = screenSize.width - left - _menuWidth;
    final double bottom = screenSize.height - top - _menuHeight;

    return RelativeRect.fromLTRB(
      left.clamp(_menuPadding, screenSize.width - _menuWidth - _menuPadding),
      top,
      right.clamp(_menuPadding, screenSize.width - _menuWidth - _menuPadding),
      bottom,
    );
  }

  void _showMenu(BuildContext context) {
    final RenderBox? buttonBox = context.findRenderObject() as RenderBox?;
    if (buttonBox == null) return;

    final theme = Theme.of(context);
    final menuItems = _buildMenuItems();
    final popupItems = <PopupMenuEntry<String>>[];

    for (var i = 0; i < menuItems.length; i++) {
      if (i > 0 && menuItems[i].isDestructive) {
        popupItems.add(
          PopupMenuDivider(
            color: theme.dividerColor.withOpacity(0.1),
          ),
        );
      }
      popupItems.add(menuItems[i].toPopupMenuItem(context));
    }

    showMenu<String>(
      context: context,
      position: _calculateMenuPosition(context, buttonBox),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 8,
      color: theme.scaffoldBackgroundColor,
      items: popupItems,
    ).then(_handleMenuSelection);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.more_vert, size: 18),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      onPressed: () => _showMenu(context),
    );
  }
}

