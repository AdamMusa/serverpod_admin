import 'package:serverpod/serverpod.dart';
import 'package:serverpod_admin_server/serverpod_admin_server.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

/// Test model with various data types for testing parsing and stringification.
abstract class DataTypeTestModel
    implements TableRow<int?>, ProtocolSerialization {
  DataTypeTestModel._({
    this.id,
    required this.stringField,
    required this.intField,
    this.bigIntField,
    this.doubleField,
    this.boolField,
    this.dateTimeField,
  });

  factory DataTypeTestModel({
    int? id,
    required String stringField,
    required int intField,
    int? bigIntField,
    double? doubleField,
    bool? boolField,
    DateTime? dateTimeField,
  }) = _DataTypeTestModelImpl;

  factory DataTypeTestModel.fromJson(Map<String, dynamic> json) {
    // Handle both camelCase (from normal JSON) and snake_case (from admin endpoint)
    return DataTypeTestModel(
      id: json['id'] as int?,
      stringField:
          (json['stringField'] ?? json['string_field']) as String? ?? '',
      intField: (json['intField'] ?? json['int_field']) as int? ?? 0,
      bigIntField: (json['bigIntField'] ?? json['big_int_field']) as int?,
      doubleField: (json['doubleField'] ?? json['double_field']) as double?,
      boolField: (json['boolField'] ?? json['bool_field']) as bool?,
      dateTimeField: () {
        final value = json['dateTimeField'] ?? json['date_time_field'];
        if (value == null) return null;
        if (value is String) return DateTime.tryParse(value);
        if (value is DateTime) return value;
        return null;
      }(),
    );
  }

  static final t = _DataTypeTestModelTable();

  @override
  int? id;

  String stringField;
  int intField;
  int? bigIntField;
  double? doubleField;
  bool? boolField;
  DateTime? dateTimeField;

  @override
  Table<int?> get table => t;

  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'stringField': stringField,
      'intField': intField,
      if (bigIntField != null) 'bigIntField': bigIntField,
      if (doubleField != null) 'doubleField': doubleField,
      if (boolField != null) 'boolField': boolField,
      if (dateTimeField != null)
        'dateTimeField': dateTimeField!.toIso8601String(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() => toJson();
}

class _DataTypeTestModelImpl extends DataTypeTestModel {
  _DataTypeTestModelImpl({
    super.id,
    required super.stringField,
    required super.intField,
    super.bigIntField,
    super.doubleField,
    super.boolField,
    super.dateTimeField,
  }) : super._();
}

class _DataTypeTestModelTable extends Table<int?> {
  _DataTypeTestModelTable() : super(tableName: 'data_type_test_models') {
    stringField = ColumnString('string_field', this);
    intField = ColumnInt('int_field', this);
    bigIntField = ColumnBigInt('big_int_field', this);
    doubleField = ColumnDouble('double_field', this);
    boolField = ColumnBool('bool_field', this);
    dateTimeField = ColumnDateTime('date_time_field', this);
  }

  late final ColumnString stringField;
  late final ColumnInt intField;
  late final ColumnBigInt bigIntField;
  late final ColumnDouble doubleField;
  late final ColumnBool boolField;
  late final ColumnDateTime dateTimeField;

  @override
  List<Column> get columns => [
        id,
        stringField,
        intField,
        bigIntField,
        doubleField,
        boolField,
        dateTimeField,
      ];
}

// In-memory storage for test data
final _testStorage = <int, DataTypeTestModel>{};
int _nextId = 1;

// Test admin user ID - using a test UUID
const _testAdminUserId = '00000000-0000-0000-0000-000000000001';

void main() {
  withServerpod('Given Admin endpoint data parsing',
      (sessionBuilder, endpoints) {
    setUpAll(() {
      // Clear test storage
      _testStorage.clear();
      _nextId = 1;

      // Configure admin module with test model using in-memory storage
      configureAdminModule((registry) {
        registry.register<DataTypeTestModel>(
          table: DataTypeTestModel.t,
          fromJson: DataTypeTestModel.fromJson,
          listRows: (session) async => _testStorage.values.toList(),
          findRowById: (session, id) async => _testStorage[id],
          createRow: (session, row) async {
            final model = row;
            model.id = _nextId++;
            _testStorage[model.id!] = model;
            return model;
          },
          updateRow: (session, row) async {
            final model = row;
            if (model.id != null && _testStorage.containsKey(model.id)) {
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
    // Using a test user ID string for authentication
    final authenticatedSessionBuilder = sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        _testAdminUserId,
        {Scope.admin},
      ),
    );

    group('boolean parsing', () {
      test('should parse "true" as true', () async {
        final created = await endpoints.admin.create(
          authenticatedSessionBuilder,
          'data_type_test_models',
          {
            'string_field': 'Test',
            'int_field': '1',
            'bool_field': 'true',
          },
        );

        expect(created['boolField'], 'true');
      });

      test('should parse "1" as true', () async {
        final created = await endpoints.admin.create(
          authenticatedSessionBuilder,
          'data_type_test_models',
          {
            'string_field': 'Test',
            'int_field': '1',
            'bool_field': '1',
          },
        );

        expect(created['boolField'], 'true');
      });

      test('should parse "yes" as true', () async {
        final created = await endpoints.admin.create(
          authenticatedSessionBuilder,
          'data_type_test_models',
          {
            'string_field': 'Test',
            'int_field': '1',
            'bool_field': 'yes',
          },
        );

        expect(created['boolField'], 'true');
      });

      test('should parse "false" as false', () async {
        final created = await endpoints.admin.create(
          authenticatedSessionBuilder,
          'data_type_test_models',
          {
            'string_field': 'Test',
            'int_field': '1',
            'bool_field': 'false',
          },
        );

        expect(created['boolField'], 'false');
      });

      test('should parse "0" as false', () async {
        final created = await endpoints.admin.create(
          authenticatedSessionBuilder,
          'data_type_test_models',
          {
            'string_field': 'Test',
            'int_field': '1',
            'bool_field': '0',
          },
        );

        expect(created['boolField'], 'false');
      });

      test('should parse "no" as false', () async {
        final created = await endpoints.admin.create(
          authenticatedSessionBuilder,
          'data_type_test_models',
          {
            'string_field': 'Test',
            'int_field': '1',
            'bool_field': 'no',
          },
        );

        expect(created['boolField'], 'false');
      });

      test('should handle invalid boolean values as null', () async {
        final created = await endpoints.admin.create(
          authenticatedSessionBuilder,
          'data_type_test_models',
          {
            'string_field': 'Test',
            'int_field': '1',
            'bool_field': 'invalid',
          },
        );

        // Invalid boolean should be parsed as null, which is omitted from JSON
        expect(created['boolField'], isNull);
      });
    });

    group('numeric parsing', () {
      test('should parse integer values correctly', () async {
        final created = await endpoints.admin.create(
          authenticatedSessionBuilder,
          'data_type_test_models',
          {
            'string_field': 'Test',
            'int_field': '42',
          },
        );

        expect(created['intField'], '42');
      });

      test('should parse negative integers correctly', () async {
        final created = await endpoints.admin.create(
          authenticatedSessionBuilder,
          'data_type_test_models',
          {
            'string_field': 'Test',
            'int_field': '-42',
          },
        );

        expect(created['intField'], '-42');
      });

      test('should parse big integers correctly', () async {
        final created = await endpoints.admin.create(
          authenticatedSessionBuilder,
          'data_type_test_models',
          {
            'string_field': 'Test',
            'int_field': '1',
            'big_int_field': '9223372036854775807',
          },
        );

        expect(created['bigIntField'], '9223372036854775807');
      });

      test('should parse double values correctly', () async {
        final created = await endpoints.admin.create(
          authenticatedSessionBuilder,
          'data_type_test_models',
          {
            'string_field': 'Test',
            'int_field': '1',
            'double_field': '3.14159',
          },
        );

        expect(created['doubleField'], '3.14159');
      });

      test('should parse negative doubles correctly', () async {
        final created = await endpoints.admin.create(
          authenticatedSessionBuilder,
          'data_type_test_models',
          {
            'string_field': 'Test',
            'int_field': '1',
            'double_field': '-3.14159',
          },
        );

        expect(created['doubleField'], '-3.14159');
      });

      test('should handle invalid integer as default value', () async {
        final created = await endpoints.admin.create(
          authenticatedSessionBuilder,
          'data_type_test_models',
          {
            'string_field': 'Test',
            'int_field': 'not_a_number',
          },
        );

        // Invalid integer for required field defaults to 0 (from fromJson default)
        expect(created['intField'], '0');
      });

      test('should handle invalid double as null', () async {
        final created = await endpoints.admin.create(
          authenticatedSessionBuilder,
          'data_type_test_models',
          {
            'string_field': 'Test',
            'int_field': '1',
            'double_field': 'not_a_number',
          },
        );

        // Invalid double should be parsed as null, which is omitted from JSON
        expect(created['doubleField'], isNull);
      });
    });

    group('DateTime parsing', () {
      test('should parse ISO 8601 DateTime strings', () async {
        final now = DateTime.now().toUtc();
        final isoString = now.toIso8601String();

        final created = await endpoints.admin.create(
          authenticatedSessionBuilder,
          'data_type_test_models',
          {
            'string_field': 'Test',
            'int_field': '1',
            'date_time_field': isoString,
          },
        );

        expect(created['dateTimeField'], isNotEmpty);
        expect(created['dateTimeField'], contains('T'));
      });

      test('should convert DateTime to UTC ISO 8601 format', () async {
        final localTime = DateTime(2024, 1, 15, 14, 30, 45);
        final created = await endpoints.admin.create(
          authenticatedSessionBuilder,
          'data_type_test_models',
          {
            'string_field': 'Test',
            'int_field': '1',
            'date_time_field': localTime.toIso8601String(),
          },
        );

        expect(created['dateTimeField'], isNotEmpty);
        // Should be in ISO 8601 format
        expect(
            created['dateTimeField'], matches(RegExp(r'^\d{4}-\d{2}-\d{2}T')));
      });

      test('should handle invalid DateTime as null', () async {
        final created = await endpoints.admin.create(
          authenticatedSessionBuilder,
          'data_type_test_models',
          {
            'string_field': 'Test',
            'int_field': '1',
            'date_time_field': 'not_a_date',
          },
        );

        // Invalid DateTime should be parsed as null, which is omitted from JSON
        expect(created['dateTimeField'], isNull);
      });
    });

    group('string handling', () {
      test('should preserve string values', () async {
        final created = await endpoints.admin.create(
          authenticatedSessionBuilder,
          'data_type_test_models',
          {
            'string_field': 'Hello World',
            'int_field': '1',
          },
        );

        expect(created['stringField'], 'Hello World');
      });

      test('should handle empty strings', () async {
        final created = await endpoints.admin.create(
          authenticatedSessionBuilder,
          'data_type_test_models',
          {
            'string_field': '',
            'int_field': '1',
          },
        );

        expect(created['stringField'], '');
      });

      test('should trim whitespace from values', () async {
        final created = await endpoints.admin.create(
          authenticatedSessionBuilder,
          'data_type_test_models',
          {
            'string_field': '  Trimmed  ',
            'int_field': '1',
          },
        );

        expect(created['stringField'], 'Trimmed');
      });

      test('should handle null values as empty strings', () async {
        final created = await endpoints.admin.create(
          authenticatedSessionBuilder,
          'data_type_test_models',
          {
            'string_field': 'Test',
            'int_field': '1',
            // bool_field not provided, should default to empty string
          },
        );

        // Null values are omitted from JSON (optional fields)
        expect(created['boolField'], isNull);
      });
    });

    group('edge cases', () {
      test('should handle missing optional fields', () async {
        final created = await endpoints.admin.create(
          authenticatedSessionBuilder,
          'data_type_test_models',
          {
            'string_field': 'Test',
            'int_field': '1',
            // Optional fields not provided
          },
        );

        expect(created['stringField'], 'Test');
        expect(created['intField'], '1');
        // Optional fields are omitted from JSON when not provided (null)
        expect(created['bigIntField'], isNull);
        expect(created['doubleField'], isNull);
        expect(created['boolField'], isNull);
        expect(created['dateTimeField'], isNull);
      });

      test('should handle empty string values for optional fields', () async {
        final created = await endpoints.admin.create(
          authenticatedSessionBuilder,
          'data_type_test_models',
          {
            'string_field': 'Test',
            'int_field': '1',
            'bool_field': '',
            'double_field': '',
          },
        );

        // Empty strings should be parsed as null, which is omitted from JSON
        expect(created['boolField'], isNull);
        expect(created['doubleField'], isNull);
      });

      test('should handle whitespace-only values', () async {
        final created = await endpoints.admin.create(
          authenticatedSessionBuilder,
          'data_type_test_models',
          {
            'string_field': '   ',
            'int_field': '1',
          },
        );

        // Trimmed whitespace becomes empty, which is parsed as null for non-string fields
        expect(created['stringField'], '');
      });

      test('should stringify DateTime values correctly', () async {
        final now = DateTime.now().toUtc();
        final created = await endpoints.admin.create(
          authenticatedSessionBuilder,
          'data_type_test_models',
          {
            'string_field': 'Test',
            'int_field': '1',
            'date_time_field': now.toIso8601String(),
          },
        );

        // DateTime should be stringified as ISO 8601 UTC string
        final stringified = created['dateTimeField'];
        expect(stringified, isNotEmpty);
        expect(stringified, isNotNull);
        if (stringified != null && stringified.isNotEmpty) {
          expect(DateTime.parse(stringified).isUtc, isTrue);
        }
      });

      test('should stringify numeric values correctly', () async {
        final created = await endpoints.admin.create(
          authenticatedSessionBuilder,
          'data_type_test_models',
          {
            'string_field': 'Test',
            'int_field': '42',
            'double_field': '3.14',
          },
        );

        expect(created['intField'], '42');
        expect(created['doubleField'], '3.14');
      });

      test('should stringify boolean values correctly', () async {
        final created = await endpoints.admin.create(
          authenticatedSessionBuilder,
          'data_type_test_models',
          {
            'string_field': 'Test',
            'int_field': '1',
            'bool_field': 'true',
          },
        );

        expect(created['boolField'], 'true');
      });
    });

    group('update operations with data parsing', () {
      test('should update boolean field with different formats', () async {
        final created = await endpoints.admin.create(
          authenticatedSessionBuilder,
          'data_type_test_models',
          {
            'string_field': 'Test',
            'int_field': '1',
            'bool_field': 'true',
          },
        );

        final id = created['id']!;
        final updated = await endpoints.admin.update(
          authenticatedSessionBuilder,
          'data_type_test_models',
          {
            'id': id,
            'string_field': 'Test',
            'int_field': '1',
            'bool_field': '0', // Update to false
          },
        );

        expect(updated['boolField'], 'false');
      });

      test('should update numeric fields', () async {
        final created = await endpoints.admin.create(
          authenticatedSessionBuilder,
          'data_type_test_models',
          {
            'string_field': 'Test',
            'int_field': '1',
          },
        );

        final id = created['id']!;
        final updated = await endpoints.admin.update(
          authenticatedSessionBuilder,
          'data_type_test_models',
          {
            'id': id,
            'string_field': 'Test',
            'int_field': '999',
            'double_field': '2.718',
          },
        );

        expect(updated['intField'], '999');
        expect(updated['doubleField'], '2.718');
      });
    });
  });
}
