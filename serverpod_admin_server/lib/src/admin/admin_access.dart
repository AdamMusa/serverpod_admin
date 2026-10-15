import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart' show AdminValidationException;
import 'admin_entry_base.dart';
import 'admin_options.dart';
import 'admin_registry.dart';

/// Something done to a table's rows.
enum AdminOperation { view, create, edit, delete }

/// What the signed-in user may do in the dashboard. Administrators
/// (Scope.admin) may do everything a table allows; staff
/// ([AdminRegistry.staffScopes]) what each table's
/// [AdminOptions.permissions] grant their scopes.
class AdminAccess {
  AdminAccess._(this.admin, this._scopes);

  factory AdminAccess.of(Session session) {
    final names = {
      for (final scope in session.authenticated?.scopes ?? const <Scope>{})
        if (scope.name case final name?) name,
    };
    return AdminAccess._(names.contains(Scope.admin.name), names);
  }

  /// Has the admin scope.
  final bool admin;
  final Set<String> _scopes;

  /// Has one of the staff scopes.
  bool get staff => AdminRegistry().staffScopes.any(_holds);

  /// May open the dashboard at all.
  bool get allowed => admin || staff;

  bool _holds(Scope scope) => _scopes.contains(scope.name);

  void requireAllowed() {
    if (!allowed) throw _denied;
  }

  void requireAdmin() {
    if (!admin) throw _denied;
  }

  /// Whether [operation] is allowed on [entry]'s rows.
  bool can(AdminEntryBase entry, AdminOperation operation) {
    final options = entry.options;
    final enabled = switch (operation) {
      AdminOperation.view => true,
      AdminOperation.create => options.canCreate,
      AdminOperation.edit => options.canEdit,
      AdminOperation.delete => options.canDelete,
    };
    if (!enabled) return false;
    if (admin) return true;
    if (!staff) return false;
    final permissions = options.permissions;
    if (permissions == null) return false;
    final granted = switch (operation) {
      AdminOperation.view => {
        ...permissions.view,
        ...permissions.create,
        ...permissions.edit,
        ...permissions.delete,
      },
      AdminOperation.create => permissions.create,
      AdminOperation.edit => permissions.edit,
      AdminOperation.delete => permissions.delete,
    };
    return granted.any(_holds);
  }

  void require(AdminEntryBase entry, AdminOperation operation) {
    if (can(entry, operation)) return;
    final options = entry.options;
    final disabled = switch (operation) {
      AdminOperation.view => false,
      AdminOperation.create => !options.canCreate,
      AdminOperation.edit => !options.canEdit,
      AdminOperation.delete => !options.canDelete,
    };
    final name = options.label ?? entry.tableName;
    throw disabled
        ? AdminValidationException(
            message: switch (operation) {
              AdminOperation.create => '$name cannot be created here.',
              AdminOperation.edit => '$name cannot be edited here.',
              _ => '$name cannot be deleted here.',
            },
          )
        : _denied;
  }

  /// Whether [metric] is shown to this user.
  bool sees(AdminMetric metric) => admin || metric.scopes.any(_holds);

  static AdminValidationException get _denied =>
      AdminValidationException(message: 'You do not have access to this.');
}
