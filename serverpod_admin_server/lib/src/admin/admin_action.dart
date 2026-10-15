import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// A custom action administrators run on selected rows of a registered
/// table, offered next to "Delete selected" (like a Django admin action):
///
/// ```dart
/// registry.register<Order>(actions: [
///   AdminAction(
///     name: 'ship',
///     label: 'Mark as shipped',
///     run: (session, orders) async {
///       for (final order in orders) { /* … */ }
///       return '${orders.length} orders shipped.';
///     },
///   ),
/// ]);
/// ```
class AdminAction<T extends TableRow> {
  const AdminAction({
    required this.name,
    required this.label,
    required this.run,
    this.confirm = true,
    this.destructive = false,
  });

  /// Identifies the action in requests; unique per table.
  final String name;

  /// Shown in the dashboard's actions menu.
  final String label;

  /// Runs on the selected rows (as stored) and returns an optional message
  /// for the administrator. Throw an AdminValidationException to refuse.
  final Future<String?> Function(Session session, List<T> rows) run;

  /// Asks the administrator to confirm before running.
  final bool confirm;

  /// Shown as dangerous, like a deletion.
  final bool destructive;

  AdminActionInfo get info => AdminActionInfo(
    name: name,
    label: label,
    confirm: confirm,
    destructive: destructive,
  );
}
