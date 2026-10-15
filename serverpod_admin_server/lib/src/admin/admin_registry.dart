import 'package:serverpod/serverpod.dart';
import 'package:serverpod/protocol.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    show AuthUser;
import 'package:serverpod_admin_server/src/admin/admin_action.dart';
import 'package:serverpod_admin_server/src/admin/admin_options.dart';
import 'package:serverpod_admin_server/src/admin/admin_auth_user_link.dart';
import 'package:serverpod_admin_server/src/admin/admin_entry.dart';
import 'package:serverpod_admin_server/src/admin/admin_entry_base.dart';

import '../../serverpod_admin_server.dart' show AdminResource;

typedef JsonMap = Map<String, dynamic>;

/// Concrete CRUD entry bound to a specific Serverpod table row type.

class AdminRegistry {
  AdminRegistry._();

  static final AdminRegistry _instance = AdminRegistry._();

  factory AdminRegistry() => _instance;

  final Map<Type, AdminEntryBase> _entries = {};
  final Map<String, AdminEntryBase> _entriesByKey = {};
  final Map<Type, List<String>> _enumValues = {};
  List<String> _authScopeNames = [Scope.admin.name!];

  /// Scopes, besides Scope.admin, that may sign in to the dashboard. What
  /// each may do is set per table with [AdminOptions.permissions]; give the
  /// same scopes to the dashboard's `staffScopes`.
  Set<Scope> staffScopes = {};

  final List<AdminMetric> _metrics = [];

  bool _configured = false;

  /// Runs [configure] the first time it is called after a [reset], so
  /// requests reuse the registered tables instead of registering them
  /// again.
  void ensureConfigured(void Function(AdminRegistry registry) configure) {
    if (_configured) return;
    configure(this);
    _configured = true;
  }

  /// Key numbers shown on the overview.
  List<AdminMetric> get metrics => List.unmodifiable(_metrics);

  /// Adds a key number to the overview, such as "Orders today". A metric
  /// with the same label replaces the earlier one.
  void registerMetric(AdminMetric metric) {
    final index = _metrics.indexWhere((m) => m.label == metric.label);
    if (index == -1) {
      _metrics.add(metric);
    } else {
      _metrics[index] = metric;
    }
  }

  /// How long the change history keeps entries; null keeps them forever.
  /// Set it when rows hold personal data you promise to erase.
  Duration? historyRetention;

  /// Registers a new table row type. Table metadata and JSON serialization can
  /// be provided explicitly, but if omitted, they will be resolved from the
  /// host server's [SerializationManager]. This lets host projects register
  /// resources with a simple `register<T>()` call.
  /// [choices] lists, per column name, the values a list or set column may
  /// hold; the dashboard edits such columns with a multi-select.
  /// Rows that extend a Serverpod auth user (a unique `authUserId` column, or
  /// a relation to `serverpod_auth_core_user`) show that user's
  /// `authUser.scopeNames` and `authUser.blocked`, saved to the auth user.
  /// Name the column with [authUserColumn] when it is detected otherwise.
  /// [options] sets how the table appears and who may change it (see
  /// [AdminOptions]).
  /// [actions] are custom actions administrators run on selected rows.
  /// [present] adjusts each row read for the dashboard (for example to add a
  /// signed preview link) while paging, sorting and filtering still run in
  /// the database; a custom [listRows] makes them run in memory instead.
  /// Enum values are discovered automatically for both name- and
  /// index-serialized enums when the server runs on the Dart VM. A compiled
  /// server (`dart compile exe` / `dart build cli`) cannot discover the values
  /// of name-serialized enums; declare those with [registerEnum].
  void register<T extends TableRow>({
    Table? table,
    T Function(JsonMap json)? fromJson,
    Future<List<T>> Function(Session session)? listRows,
    Future<T?> Function(Session session, Object id)? findRowById,
    Future<T> Function(Session session, T row)? createRow,
    Future<T> Function(Session session, T row)? updateRow,
    Future<void> Function(Session session, Object id)? deleteById,
    String? resourceKey,
    Map<String, List<String>>? choices,
    String? authUserColumn,
    T Function(Session session, T row)? present,
    List<AdminAction<T>> actions = const [],
    AdminOptions options = const AdminOptions(),
  }) {
    final type = T;
    if (_entries.containsKey(type)) return;

    final entry = AdminEntry<T>(
      table: table,
      fromJson: fromJson,
      listRows:
          listRows ??
          (session) async => [
            // ignore: invalid_use_of_internal_member
            for (final row in await session.db.find<T>())
              present?.call(session, row) ?? row,
          ],
      findRowById:
          findRowById ??
          (session, id) async {
            // ignore: invalid_use_of_internal_member
            final row = await session.db.findById<T>(id);
            return row == null ? null : present?.call(session, row) ?? row;
          },
      queryable: listRows == null,
      // Rows are read, saved and deleted many at a time unless the table
      // gives its own way to do it one row at a time.
      batchFind: findRowById == null,
      batchCreate: createRow == null,
      batchUpdate: updateRow == null,
      batchDelete: deleteById == null,
      present: present,
      actions: actions,
      options: options,
      // ignore: invalid_use_of_internal_member
      createRow: createRow ?? (session, row) => session.db.insertRow<T>(row),
      // ignore: invalid_use_of_internal_member
      updateRow: updateRow ?? (session, row) => session.db.updateRow<T>(row),
      deleteById: deleteById,
      resourceKey: resourceKey,
      choices: choices,
      authUserColumn: authUserColumn,
    );
    _entries[type] = entry;
    _entriesByKey[entry.resourceKey] = entry;
  }

  /// Declares the values of an enum used by registered tables, so its columns
  /// are edited with a dropdown:
  ///
  /// ```dart
  /// registry.registerEnum(OrderStatus.values);
  /// ```
  ///
  /// Required for name-serialized enums on a compiled server, where
  /// `dart:mirrors` is unavailable and model files are not deployed. Harmless
  /// elsewhere; registered values take precedence over discovery.
  ///
  /// Pass every value (`MyEnum.values`): they are kept in declaration order,
  /// which index-serialized enums rely on to store the selected value.
  void registerEnum<E extends Enum>(List<E> values) {
    if (values.isEmpty) return;
    final ordered = [...values]..sort((a, b) => a.index.compareTo(b.index));
    _enumValues[values.first.runtimeType] = List.unmodifiable(
      ordered.map((value) => value.name),
    );
  }

  /// The permission scopes admins may grant: [Scope.admin] plus those passed
  /// to [registerAuthUsers].
  List<String> get authScopeNames => List.unmodifiable(_authScopeNames);

  /// The values declared for [enumType] with [registerEnum], if any.
  List<String>? enumValuesFor(Type enumType) => _enumValues[enumType];

  /// Registers Serverpod's persisted future-call jobs table.
  ///
  /// This exposes the `serverpod_future_call` table through the same generic
  /// admin resource metadata and CRUD pipeline as application tables, next
  /// job first.
  void registerServerpodJobs() {
    register<FutureCallEntry>(
      table: FutureCallEntry.t,
      fromJson: FutureCallEntry.fromJson,
      resourceKey: 'serverpod_future_call',
      options: const AdminOptions(ordering: 'time'),
    );
  }

  /// Registers Serverpod's auth users (`serverpod_auth_core_user`) so admins
  /// manage access from the dashboard:
  ///
  /// - `scopeNames`: a multi-select of [Scope.admin] (dashboard access) and
  ///   any app-specific [scopes]. Takes effect when the user's access token
  ///   next refreshes.
  /// - `blocked`: stops the user from signing in.
  ///
  /// The same scopes are offered on rows that extend an auth user. An admin
  /// cannot remove their own admin access or block themselves.
  ///
  /// Identities come from sign-up or [AdminUser.create]; they cannot be created
  /// or deleted here, so logins and app records are never orphaned.
  ///
  /// [options] set how the table appears: by default newest users first,
  /// without Add or Delete buttons.
  void registerAuthUsers({
    Iterable<Scope> scopes = const [],
    AdminOptions options = const AdminOptions(
      ordering: 'createdAt',
      descending: true,
      canCreate: false,
      canDelete: false,
    ),
  }) {
    _authScopeNames = {
      for (final scope in [Scope.admin, ...scopes])
        if (scope.name case final name?) name,
    }.toList();
    register<AuthUser>(
      table: AuthUser.t,
      fromJson: AuthUser.fromJson,
      options: options,
      createRow: (session, row) => throw StateError(
        'Users are created by signing up, or with AdminUser.create.',
      ),
      updateRow: (session, row) {
        AdminAuthUserLink.requireOwnAccess(session, row);
        return AuthUser.db.updateRow(session, row);
      },
      deleteById: (session, id) => throw StateError(
        'Block the user instead; deleting would orphan their sign-in.',
      ),
      resourceKey: 'serverpod_auth_core_user',
      choices: {'scopeNames': authScopeNames},
    );
  }

  /// Returns the registered CRUD resources.
  List<AdminEntryBase> get registeredEntries =>
      List.unmodifiable(_entries.values);

  /// Lookup helper to retrieve a registered entry by type.
  AdminEntryBase? operator [](Type type) => _entries[type];

  /// Lookup helper by resource key.
  AdminEntryBase? entryByKey(String key) => _entriesByKey[key];

  /// Returns registered resource keys.
  List<String> get registeredResourceKeys =>
      List.unmodifiable(_entriesByKey.keys);

  /// Returns metadata for all registered entries.
  List<AdminResource> get registeredResourceMetadata {
    final result = <AdminResource>[];
    for (final entry in registeredEntries) {
      try {
        result.add(entry.metadata);
      } catch (e, stackTrace) {
        // If metadata generation fails for one entry, skip it but continue with others
        // This prevents one failing entry from hiding all other resources
        print('Error generating metadata for ${entry.type}: $e');
        print(stackTrace);
      }
    }
    return List.unmodifiable(result);
  }

  /// Removes all registered entries. Primarily useful during hot-reload or when
  /// reconfiguring the module at runtime.
  void reset() {
    _entries.clear();
    _entriesByKey.clear();
    _enumValues.clear();
    _authScopeNames = [Scope.admin.name!];
    historyRetention = null;
    staffScopes = {};
    _metrics.clear();
    _configured = false;
  }
}
