import 'package:flutter/material.dart';

/// User avatar widget with default icon
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.radius = 20,
  });

  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Icon(
        Icons.person,
        color: theme.colorScheme.onPrimaryContainer,
        size: radius * 1.2,
      ),
    );
  }
}

