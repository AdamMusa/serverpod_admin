import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_admin_dashboard/src/widgets/user_profile/widgets/user_menu_item.dart';

void main() {
  group('UserMenuItem', () {
    test('should create menu item with correct properties', () {
      const item = UserMenuItem(
        value: 'test',
        label: 'Test Label',
        icon: Icons.settings,
        isDestructive: false,
      );

      expect(item.value, 'test');
      expect(item.label, 'Test Label');
      expect(item.icon, Icons.settings);
      expect(item.isDestructive, false);
    });

    test('should create destructive menu item', () {
      const item = UserMenuItem(
        value: 'delete',
        label: 'Delete',
        icon: Icons.delete,
        isDestructive: true,
      );

      expect(item.isDestructive, true);
    });

    testWidgets('toPopupMenuItem should create PopupMenuItem with correct content', (tester) async {
      const item = UserMenuItem(
        value: 'test',
        label: 'Test Label',
        icon: Icons.settings,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final popupItem = item.toPopupMenuItem(context);
                return popupItem.child as Widget;
              },
            ),
          ),
        ),
      );

      expect(find.text('Test Label'), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('toPopupMenuItem should use error color for destructive items', (tester) async {
      const item = UserMenuItem(
        value: 'delete',
        label: 'Delete',
        icon: Icons.delete,
        isDestructive: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          ),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final popupItem = item.toPopupMenuItem(context);
                return popupItem.child as Widget;
              },
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.delete));
      final theme = Theme.of(tester.element(find.byType(Scaffold)));
      expect(icon.color, theme.colorScheme.error);
    });
  });
}

