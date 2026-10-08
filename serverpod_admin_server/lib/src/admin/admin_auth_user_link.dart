import 'package:serverpod/serverpod.dart';
import 'package:serverpod/protocol.dart' show ColumnType, TableDefinition;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    show AuthUser;

import '../generated/protocol.dart' show AdminColumn, AdminValidationException;
import 'admin_registry.dart';
import 'admin_value_parser.dart';

/// Shows the Serverpod auth user a row extends inside that row, so admins
/// grant dashboard access and block sign-in where they manage the user.
///
/// Rows extend an auth user when they hold its id in a unique column that
/// references `serverpod_auth_core_user` (a `module:auth_core:AuthUser`
/// relation) or is named `authUserId`. The auth user's values are not copied
/// into the row: they are read from and saved to `serverpod_auth_core_user`.
class AdminAuthUserLink {
  AdminAuthUserLink(this.column);

  /// The auth user's permission scopes, edited with a multi-select.
  static const scopeNamesField = 'authUser.scopeNames';

  /// Whether the auth user is blocked from signing in.
  static const blockedField = 'authUser.blocked';

  /// The column holding the auth user's id.
  final String column;

  /// The column linking each row of [definition] to the one auth user it
  /// extends, if any.
  static String? detect(TableDefinition definition) {
    if (definition.name == AuthUser.t.tableName) return null;
    final candidates = {
      for (final key in definition.foreignKeys)
        if (key.referenceTable == AuthUser.t.tableName &&
            key.columns.length == 1)
          key.columns.single,
      for (final column in definition.columns)
        if (column.name == 'authUserId' && column.columnType == ColumnType.uuid)
          column.name,
    };
    // Only a unique link means each row belongs to a single user.
    return candidates
        .where(
          (name) => definition.indexes.any(
            (index) =>
                index.isUnique &&
                index.elements.length == 1 &&
                index.elements.single.definition == name,
          ),
        )
        .firstOrNull;
  }

  /// The columns shown alongside the row's own.
  List<AdminColumn> get columns => [
    AdminColumn(
      name: scopeNamesField,
      dataType: AuthUser.t.scopeNames.type.toString(),
      hasDefault: false,
      isPrimary: false,
      isNullable: false,
      choices: AdminRegistry().authScopeNames,
    ),
    AdminColumn(
      name: blockedField,
      dataType: AuthUser.t.blocked.type.toString(),
      hasDefault: false,
      isPrimary: false,
      isNullable: false,
    ),
  ];

  /// Adds each row's auth user values to [rows].
  Future<List<Map<String, dynamic>>> attach(
    Session session,
    List<Map<String, dynamic>> rows,
  ) async {
    final ids = {
      for (final row in rows)
        if (_authUserId(row) case final id?) id,
    };
    if (ids.isEmpty) return rows;
    final users = {
      for (final user in await AuthUser.db.find(
        session,
        where: (table) => table.id.inSet(ids),
      ))
        user.id: user,
    };
    return [
      for (final row in rows)
        if (users[_authUserId(row)] case final user?)
          {
            ...row,
            scopeNamesField: user.scopeNames.toList()..sort(),
            blockedField: user.blocked,
          }
        else
          row,
    ];
  }

  /// The [row]'s auth user with the values submitted in [data] applied, or
  /// null when nothing changes. Call it before saving the row so an invalid
  /// change saves neither.
  Future<AuthUser?> change(
    Session session,
    Map<String, dynamic> row,
    Map<String, String> data,
  ) async {
    final scopeNames = _scopeNames(data[scopeNamesField]);
    final blocked = parseAdminColumnValue(
      AuthUser.t.blocked,
      data[blockedField],
    );
    if (scopeNames == null && blocked == null) return null;

    final id = _authUserId(row);
    final user = id == null ? null : await AuthUser.db.findById(session, id);
    if (user == null) {
      // A row whose user was deleted keeps saving with nothing granted.
      if ((scopeNames?.isEmpty ?? true) && blocked != true) return null;
      throw AdminValidationException(
        field: scopeNames?.isNotEmpty ?? false ? scopeNamesField : blockedField,
        message: 'No auth user exists for $column, so it has no access to set.',
      );
    }

    final updated = user.copyWith(scopeNames: scopeNames, blocked: blocked);
    requireOwnAccess(
      session,
      updated,
      scopeNamesField: scopeNamesField,
      blockedField: blockedField,
    );
    final unchanged =
        updated.blocked == user.blocked &&
        updated.scopeNames.length == user.scopeNames.length &&
        updated.scopeNames.containsAll(user.scopeNames);
    return unchanged ? null : updated;
  }

  /// Rejects a change to [user] that would lock the signed-in admin out of
  /// the dashboard.
  static void requireOwnAccess(
    Session session,
    AuthUser user, {
    String scopeNamesField = 'scopeNames',
    String blockedField = 'blocked',
  }) {
    if (user.id.toString() != session.authenticated?.userIdentifier) return;
    if (!user.scopeNames.contains(Scope.admin.name)) {
      throw AdminValidationException(
        field: scopeNamesField,
        message: 'You cannot remove your own admin access.',
      );
    }
    if (user.blocked) {
      throw AdminValidationException(
        field: blockedField,
        message: 'You cannot block yourself.',
      );
    }
  }

  Set<String>? _scopeNames(String? raw) {
    if (raw == null) return null;
    return switch (parseAdminColumnValue(AuthUser.t.scopeNames, raw)) {
      null => <String>{},
      final List<dynamic> names => {for (final name in names) '$name'},
      _ => throw AdminValidationException(
        field: scopeNamesField,
        message: '$scopeNamesField must be a list such as ["serverpod.admin"].',
      ),
    };
  }

  UuidValue? _authUserId(Map<String, dynamic> row) {
    final value = row[column];
    if (value is UuidValue) return value;
    if (value is! String) return null;
    try {
      return UuidValue.withValidation(value);
    } on FormatException {
      return null;
    }
  }
}
