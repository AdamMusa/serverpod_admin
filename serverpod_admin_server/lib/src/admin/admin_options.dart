import 'package:serverpod/serverpod.dart';

/// How a registered table appears and behaves in the dashboard, like a
/// Django ModelAdmin:
///
/// ```dart
/// registry.register<Order>(
///   options: AdminOptions(
///     label: 'Orders',
///     group: 'Sales',
///     listColumns: ['id', 'customerId', 'status', 'total'],
///     ordering: 'createdAt',
///     descending: true,
///     readOnly: {'createdAt'},
///     hidden: {'paymentToken'},
///     labels: {'customerId': 'Customer'},
///     help: {'status': 'Shipped orders can no longer be edited.'},
///     canDelete: false,
///     permissions: AdminPermissions(
///       view: {Scope('support')},
///       edit: {Scope('support')},
///     ),
///   ),
/// );
/// ```
class AdminOptions {
  const AdminOptions({
    this.label,
    this.group,
    this.listColumns,
    this.ordering,
    this.descending = false,
    this.readOnly = const {},
    this.hidden = const {},
    this.searchColumns,
    this.labels = const {},
    this.help = const {},
    this.canCreate = true,
    this.canEdit = true,
    this.canDelete = true,
    this.chartColumn,
    this.permissions,
  });

  /// Shown in place of the table name, for example "Orders".
  final String? label;

  /// Groups tables in the sidebar, for example "Sales".
  final String? group;

  /// Columns shown in the table at first; the others can be turned on.
  final List<String>? listColumns;

  /// The column rows are sorted by by default (newest first by id when
  /// unset), [descending] or not.
  final String? ordering;
  final bool descending;

  /// Columns shown but not editable. Edits keep their stored values.
  final Set<String> readOnly;

  /// Columns never sent to the dashboard, searched or filtered, such as
  /// secrets. Edits keep their stored values.
  final Set<String> hidden;

  /// Columns searched by the search box (every text-like column when unset).
  final Set<String>? searchColumns;

  /// Names shown in place of column names.
  final Map<String, String> labels;

  /// Explanations shown with columns in forms and details.
  final Map<String, String> help;

  /// Whether rows may be created, edited or deleted from the dashboard at
  /// all. Read-only tables, such as logs, set these to false.
  final bool canCreate;
  final bool canEdit;
  final bool canDelete;

  /// A date column whose daily counts the overview charts (detected from
  /// common names such as createdAt when unset).
  final String? chartColumn;

  /// Which staff scopes may view, create, edit or delete this table.
  /// Administrators (Scope.admin) may always do everything; without
  /// permissions, staff cannot see the table.
  final AdminPermissions? permissions;
}

/// The staff scopes allowed each kind of access to a table. A scope allowed
/// to create, edit or delete may also view.
class AdminPermissions {
  const AdminPermissions({
    this.view = const {},
    this.create = const {},
    this.edit = const {},
    this.delete = const {},
  });

  /// Grants every kind of access to [scopes].
  const AdminPermissions.all(Set<Scope> scopes)
    : view = scopes,
      create = scopes,
      edit = scopes,
      delete = scopes;

  final Set<Scope> view;
  final Set<Scope> create;
  final Set<Scope> edit;
  final Set<Scope> delete;
}

/// A key number on the dashboard's overview, such as "Rides today":
///
/// ```dart
/// registry.registerMetric(AdminMetric(
///   label: 'Orders today',
///   compute: (session) async => '${await Order.db.count(session, …)}',
/// ));
/// ```
class AdminMetric {
  const AdminMetric({
    required this.label,
    required this.compute,
    this.hint,
    this.scopes = const {},
  });

  final String label;

  /// Returns the value as shown, for example "42" or "12 500 MRU".
  final Future<String> Function(Session session) compute;

  /// A short explanation, for example "since midnight UTC".
  final String? hint;

  /// Staff scopes that may see it besides administrators.
  final Set<Scope> scopes;
}
