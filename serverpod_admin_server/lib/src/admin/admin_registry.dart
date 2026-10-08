import 'package:serverpod/serverpod.dart';
import 'package:serverpod/protocol.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    show AuthUser;
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

  /// Registers a new table row type. Table metadata and JSON serialization can
  /// be provided explicitly, but if omitted, they will be resolved from the
  /// host server's [SerializationManager]. This lets host projects register
  /// resources with a simple `register<T>()` call.
  /// [choices] lists, per column name, the values a list or set column may
  /// hold; the dashboard edits such columns with a multi-select.
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
  }) {
    final type = T;
    if (_entries.containsKey(type)) return;

    final entry = AdminEntry<T>(
      table: table,
      fromJson: fromJson,
      // ignore: invalid_use_of_internal_member
      listRows: listRows ?? (session) => session.db.find<T>(),
      // ignore: invalid_use_of_internal_member
      findRowById: findRowById ?? (session, id) => session.db.findById<T>(id),
      // ignore: invalid_use_of_internal_member
      createRow: createRow ?? (session, row) => session.db.insertRow<T>(row),
      // ignore: invalid_use_of_internal_member
      updateRow: updateRow ?? (session, row) => session.db.updateRow<T>(row),
      deleteById:
          deleteById ??
          (session, id) async {
            // ignore: invalid_use_of_internal_member
            final row = await session.db.findById<T>(id);
            if (row != null) {
              // ignore: invalid_use_of_internal_member
              await session.db.deleteRow<T>(row);
            }
          },
      resourceKey: resourceKey,
      choices: choices,
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

  /// The values declared for [enumType] with [registerEnum], if any.
  List<String>? enumValuesFor(Type enumType) => _enumValues[enumType];

  /// Registers Serverpod's persisted future-call jobs table.
  ///
  /// This exposes the `serverpod_future_call` table through the same generic
  /// admin resource metadata and CRUD pipeline as application tables.
  void registerServerpodJobs() {
    register<FutureCallEntry>(
      table: FutureCallEntry.t,
      fromJson: FutureCallEntry.fromJson,
      listRows: (session) =>
          FutureCallEntry.db.find(session, orderBy: (table) => table.time),
      findRowById: (session, id) async {
        final normalizedId = id is int
            ? id
            : (id is String ? int.tryParse(id) : null);
        if (normalizedId == null) return null;
        return FutureCallEntry.db.findById(session, normalizedId);
      },
      createRow: (session, row) => FutureCallEntry.db.insertRow(session, row),
      updateRow: (session, row) => FutureCallEntry.db.updateRow(session, row),
      deleteById: (session, id) async {
        final normalizedId = id is int
            ? id
            : (id is String ? int.tryParse(id) : null);
        if (normalizedId == null) return;
        await FutureCallEntry.db.deleteWhere(
          session,
          where: (table) => table.id.equals(normalizedId),
        );
      },
      resourceKey: 'serverpod_future_call',
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
  /// Identities come from sign-up or [AdminUser.create]; they cannot be created
  /// or deleted here, so logins and app records are never orphaned.
  void registerAuthUsers({Iterable<Scope> scopes = const []}) {
    UuidValue uuid(Object id) =>
        id is UuidValue ? id : UuidValue.fromString(id.toString());
    register<AuthUser>(
      table: AuthUser.t,
      fromJson: AuthUser.fromJson,
      listRows: (session) =>
          AuthUser.db.find(session, orderBy: (table) => table.createdAt),
      findRowById: (session, id) => AuthUser.db.findById(session, uuid(id)),
      createRow: (session, row) => throw StateError(
        'Users are created by signing up, or with AdminUser.create.',
      ),
      updateRow: (session, row) => AuthUser.db.updateRow(session, row),
      deleteById: (session, id) => throw StateError(
        'Block the user instead; deleting would orphan their sign-in.',
      ),
      resourceKey: 'serverpod_auth_core_user',
      choices: {
        'scopeNames': {
          for (final scope in [Scope.admin, ...scopes])
            if (scope.name case final name?) name,
        }.toList(),
      },
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
  }
}
