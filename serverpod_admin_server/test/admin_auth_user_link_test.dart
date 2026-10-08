import 'package:serverpod/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_admin_server/serverpod_admin_server.dart';
import 'package:serverpod_admin_server/src/admin/admin_auth_user_link.dart';
import 'package:test/test.dart';

TableDefinition _table({
  String name = 'profile',
  String column = 'authUserId',
  ColumnType type = ColumnType.uuid,
  bool unique = true,
  String? references,
}) => TableDefinition(
  name: name,
  schema: 'public',
  columns: [
    ColumnDefinition(
      name: 'id',
      columnType: ColumnType.bigint,
      isNullable: false,
    ),
    ColumnDefinition(name: column, columnType: type, isNullable: false),
  ],
  foreignKeys: [
    if (references != null)
      ForeignKeyDefinition(
        constraintName: '${name}_fk_0',
        columns: [column],
        referenceTable: references,
        referenceTableSchema: 'public',
        referenceColumns: ['id'],
      ),
  ],
  indexes: [
    IndexDefinition(
      indexName: '${name}_auth_user_idx',
      elements: [
        IndexElementDefinition(
          type: IndexElementDefinitionType.column,
          definition: column,
        ),
      ],
      type: 'btree',
      isUnique: unique,
      isPrimary: false,
    ),
  ],
  managed: true,
);

void main() {
  group('a row extends an auth user', () {
    test('through a unique authUserId column', () {
      expect(AdminAuthUserLink.detect(_table()), 'authUserId');
    });

    test('through a unique relation to serverpod_auth_core_user', () {
      expect(
        AdminAuthUserLink.detect(
          _table(column: 'ownerId', references: 'serverpod_auth_core_user'),
        ),
        'ownerId',
      );
    });
  });

  group('a row does not extend an auth user', () {
    test('when many rows may share the user', () {
      expect(AdminAuthUserLink.detect(_table(unique: false)), isNull);
    });

    test('when authUserId is not a UUID', () {
      expect(AdminAuthUserLink.detect(_table(type: ColumnType.text)), isNull);
    });

    test('when it is the auth user itself', () {
      expect(
        AdminAuthUserLink.detect(
          _table(name: 'serverpod_auth_core_user', column: 'id'),
        ),
        isNull,
      );
    });
  });

  group('grantable scopes', () {
    final registry = AdminRegistry();
    setUp(registry.reset);
    tearDown(registry.reset);

    test('are the admin scope by default', () {
      expect(registry.authScopeNames, ['serverpod.admin']);
      expect(AdminAuthUserLink('authUserId').columns.first.choices, [
        'serverpod.admin',
      ]);
    });

    test('include the scopes passed to registerAuthUsers', () {
      registry.registerAuthUsers(scopes: [const Scope('dispatcher')]);
      expect(registry.authScopeNames, ['serverpod.admin', 'dispatcher']);
      expect(AdminAuthUserLink('authUserId').columns.first.choices, [
        'serverpod.admin',
        'dispatcher',
      ]);
    });
  });
}
