import 'package:serverpod/serverpod.dart';
import 'package:serverpod_admin_server/serverpod_admin_server.dart';
import 'package:serverpod_test/serverpod_test.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

/// Simple test model for admin endpoint testing.
/// Uses in-memory storage for testing without requiring database migrations.
abstract class TestModel implements TableRow<int?>, ProtocolSerialization {
  TestModel._({
    this.id,
    required this.name,
    required this.value,
    this.createdAt,
  });

  factory TestModel({
    int? id,
    required String name,
    required int value,
    DateTime? createdAt,
  }) = _TestModelImpl;

  factory TestModel.fromJson(Map<String, dynamic> json) {
    // Handle both camelCase (from normal JSON) and snake_case (from admin endpoint)
    // Handle null values for partial updates
    return TestModel(
      id: json['id'] as int?,
      name: (json['name'] ?? json['name']) as String? ?? '',
      value: (json['value'] ?? json['value']) as int? ?? 0,
      createdAt: () {
        final value = json['createdAt'] ?? json['created_at'];
        if (value == null) return null;
        if (value is String) return DateTime.tryParse(value);
        if (value is DateTime) return value;
        return null;
      }(),
    );
  }

  static final t = _TestModelTable();

  @override
  int? id;

  String name;
  int value;
  DateTime? createdAt;

  @override
  Table<int?> get table => t;

  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'value': value,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() => toJson();
}

class _TestModelImpl extends TestModel {
  _TestModelImpl({
    super.id,
    required super.name,
    required super.value,
    super.createdAt,
  }) : super._();
}

class _TestModelTable extends Table<int?> {
  _TestModelTable() : super(tableName: 'test_models') {
    name = ColumnString('name', this);
    value = ColumnInt('value', this);
    createdAt = ColumnDateTime('created_at', this);
  }

  late final ColumnString name;
  late final ColumnInt value;
  late final ColumnDateTime createdAt;

  @override
  List<Column> get columns => [id, name, value, createdAt];
}

// In-memory storage for test data
final _testStorage = <int, TestModel>{};
int _nextId = 1;

// Test admin user ID - using a test UUID
const _testAdminUserId = '00000000-0000-0000-0000-000000000001';

void main() {
  withServerpod('Given Admin endpoint', (sessionBuilder, endpoints) {
    setUpAll(() {
      // Clear test storage
      _testStorage.clear();
      _nextId = 1;

      // Configure admin module with test model using in-memory storage
      configureAdminModule((registry) {
        registry.register<TestModel>(
          table: TestModel.t,
          fromJson: TestModel.fromJson,
          listRows: (session) async => _testStorage.values.toList(),
          findRowById: (session, id) async {
            // Handle both int and String ids
            final intId =
                id is int ? id : (id is String ? int.tryParse(id) : null);
            return intId != null ? _testStorage[intId] : null;
          },
          createRow: (session, row) async {
            final model = row;
            model.id = _nextId++;
            _testStorage[model.id!] = model;
            return model;
          },
          updateRow: (session, row) async {
            final model = row;
            if (model.id != null && _testStorage.containsKey(model.id)) {
              // Merge with existing data for partial updates
              final existing = _testStorage[model.id!];
              if (existing != null) {
                // Preserve existing values if new values are defaults (empty string or 0)
                if (model.name.isEmpty && existing.name.isNotEmpty) {
                  model.name = existing.name;
                }
                if (model.value == 0 && existing.value != 0) {
                  model.value = existing.value;
                }
                if (model.createdAt == null && existing.createdAt != null) {
                  model.createdAt = existing.createdAt;
                }
              }
              _testStorage[model.id!] = model;
            }
            return model;
          },
          deleteById: (session, id) async {
            _testStorage.remove(id as int);
          },
        );
      });
      adminRegister();
    });

    tearDown(() {
      // Clear test storage after each test
      _testStorage.clear();
      _nextId = 1;
    });

    tearDownAll(() {
      // Clean up after all tests
      AdminRegistry().reset();
      _testStorage.clear();
    });

    // Create authenticated session builder with admin user
    final authenticatedSessionBuilder = sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        _testAdminUserId,
        {Scope.admin},
      ),
    );

    group('resources', () {
      test('should return list of registered resources', () async {
        final resources =
            await endpoints.admin.resources(authenticatedSessionBuilder);

        expect(resources, isNotEmpty);
        final testModelResource = resources.firstWhere(
          (r) => r.key == 'test_models',
          orElse: () => throw Exception('test_models resource not found'),
        );

        expect(testModelResource.tableName, 'test_models');
        expect(testModelResource.columns.length, greaterThan(0));
        expect(
          testModelResource.columns.any((c) => c.name == 'name'),
          isTrue,
        );
        expect(
          testModelResource.columns.any((c) => c.name == 'value'),
          isTrue,
        );
      });
    });

    group('create', () {
      test('should create a new record', () async {
        final data = {
          'name': 'Test Item',
          'value': '42',
        };

        final created = await endpoints.admin.create(
          authenticatedSessionBuilder,
          'test_models',
          data,
        );

        expect(created, isNotEmpty);
        expect(created['name'], 'Test Item');
        expect(created['value'], '42');
        expect(created.containsKey('id'), isTrue);
      });

      test('should handle DateTime fields', () async {
        final now = DateTime.now().toUtc();
        final data = {
          'name': 'Dated Item',
          'value': '100',
          'created_at': now.toIso8601String(),
        };

        final created = await endpoints.admin.create(
          authenticatedSessionBuilder,
          'test_models',
          data,
        );

        expect(created['name'], 'Dated Item');
        expect(created.containsKey('createdAt'), isTrue);
      });

      test('should throw error for invalid resource key', () async {
        final data = {'name': 'Test', 'value': '1'};

        expect(
          () => endpoints.admin.create(
            authenticatedSessionBuilder,
            'invalid_resource',
            data,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('list', () {
      test('should return empty list when no records exist', () async {
        final records = await endpoints.admin.list(
          authenticatedSessionBuilder,
          'test_models',
        );

        expect(records, isEmpty);
      });

      test('should return all records', () async {
        // Create test records
        await endpoints.admin.create(
          authenticatedSessionBuilder,
          'test_models',
          {'name': 'Item 1', 'value': '10'},
        );
        await endpoints.admin.create(
          authenticatedSessionBuilder,
          'test_models',
          {'name': 'Item 2', 'value': '20'},
        );

        final records = await endpoints.admin.list(
          authenticatedSessionBuilder,
          'test_models',
        );

        expect(records.length, greaterThanOrEqualTo(2));
        expect(
          records.any((r) => r['name'] == 'Item 1'),
          isTrue,
        );
        expect(
          records.any((r) => r['name'] == 'Item 2'),
          isTrue,
        );
      });

      test('should throw error for invalid resource key', () async {
        expect(
          () => endpoints.admin
              .list(authenticatedSessionBuilder, 'invalid_resource'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('listPage', () {
      test('should return paginated results', () async {
        // Create multiple records
        for (var i = 1; i <= 5; i++) {
          await endpoints.admin.create(
            authenticatedSessionBuilder,
            'test_models',
            {'name': 'Item $i', 'value': '$i'},
          );
        }

        // Get first page
        final page1 = await endpoints.admin.listPage(
          authenticatedSessionBuilder,
          'test_models',
          0,
          2,
        );

        expect(page1.length, 2);

        // Get second page
        final page2 = await endpoints.admin.listPage(
          authenticatedSessionBuilder,
          'test_models',
          2,
          2,
        );

        expect(page2.length, 2);
        expect(page1[0]['name'], isNot(page2[0]['name']));
      });

      test('should handle offset beyond available records', () async {
        final page = await endpoints.admin.listPage(
          authenticatedSessionBuilder,
          'test_models',
          1000,
          10,
        );

        expect(page, isEmpty);
      });

      test('should throw error for invalid pagination parameters', () async {
        expect(
          () => endpoints.admin.listPage(
            authenticatedSessionBuilder,
            'test_models',
            -1,
            10,
          ),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => endpoints.admin.listPage(
            authenticatedSessionBuilder,
            'test_models',
            0,
            0,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('find', () {
      test('should return record by id', () async {
        final created = await endpoints.admin.create(
          authenticatedSessionBuilder,
          'test_models',
          {'name': 'Findable Item', 'value': '99'},
        );

        final idStr = created['id']!;
        final id = int.parse(idStr);
        final found = await endpoints.admin.find(
          authenticatedSessionBuilder,
          'test_models',
          id, // Pass as int - endpoint accepts Object
        );

        expect(found, isNotNull);
        expect(found!['name'], 'Findable Item');
        // When calling endpoint directly, values are not stringified
        expect(found['value'], 99);
      });

      test('should return null for non-existent id', () async {
        final found = await endpoints.admin.find(
          authenticatedSessionBuilder,
          'test_models',
          99999,
        );

        expect(found, isNull);
      });

      test('should throw error for invalid resource key', () async {
        expect(
          () => endpoints.admin
              .find(authenticatedSessionBuilder, 'invalid_resource', 1),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('update', () {
      test('should update existing record', () async {
        final created = await endpoints.admin.create(
          authenticatedSessionBuilder,
          'test_models',
          {'name': 'Original Name', 'value': '1'},
        );

        final id = created['id']!;
        final updated = await endpoints.admin.update(
          authenticatedSessionBuilder,
          'test_models',
          {
            'id': id.toString(),
            'name': 'Updated Name',
            'value': '2',
          },
        );

        expect(updated['name'], 'Updated Name');
        expect(updated['value'], '2');
      });

      test('should handle partial updates', () async {
        final created = await endpoints.admin.create(
          authenticatedSessionBuilder,
          'test_models',
          {'name': 'Partial Update', 'value': '10'},
        );

        final id = created['id']!;
        final updated = await endpoints.admin.update(
          authenticatedSessionBuilder,
          'test_models',
          {
            'id': id.toString(),
            'value': '20',
          },
        );

        expect(updated['name'], 'Partial Update');
        expect(updated['value'], '20');
      });

      test('should throw error for invalid resource key', () async {
        expect(
          () => endpoints.admin.update(
            authenticatedSessionBuilder,
            'invalid_resource',
            {'id': '1', 'name': 'Test'},
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('delete', () {
      test('should delete record by id', () async {
        final created = await endpoints.admin.create(
          authenticatedSessionBuilder,
          'test_models',
          {'name': 'To Delete', 'value': '1'},
        );

        final id = created['id']!;
        final deleted = await endpoints.admin.delete(
          authenticatedSessionBuilder,
          'test_models',
          id.toString(),
        );

        expect(deleted, isTrue);

        // Verify it's deleted
        final found = await endpoints.admin.find(
          authenticatedSessionBuilder,
          'test_models',
          int.parse(id), // Convert String to int
        );
        expect(found, isNull);
      });

      test('should return true even if record does not exist', () async {
        final deleted = await endpoints.admin.delete(
          authenticatedSessionBuilder,
          'test_models',
          '99999',
        );

        expect(deleted, isTrue);
      });

      test('should throw error for invalid resource key', () async {
        expect(
          () => endpoints.admin.delete(
            authenticatedSessionBuilder,
            'invalid_resource',
            '1',
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('data type handling', () {
      test('should handle integer values', () async {
        final created = await endpoints.admin.create(
          authenticatedSessionBuilder,
          'test_models',
          {'name': 'Int Test', 'value': '123'},
        );

        expect(created['value'], '123');
      });

      test('should handle boolean-like strings', () async {
        // Note: This test depends on the column type
        // For string columns, it should preserve the value
        final created = await endpoints.admin.create(
          authenticatedSessionBuilder,
          'test_models',
          {'name': 'Bool Test', 'value': '1'},
        );

        expect(created['value'], '1');
      });
    });

    group('error handling', () {
      test('should handle missing required fields gracefully', () async {
        // For creates, missing required fields will use defaults from fromJson
        // (empty string for name, 0 for value)
        final created = await endpoints.admin.create(
          authenticatedSessionBuilder,
          'test_models',
          {'value': '1'}, // Missing 'name'
        );
        // Should create with defaults
        expect(created['name'], '');
        expect(created['value'], '1');
      });
    });
  });
}
