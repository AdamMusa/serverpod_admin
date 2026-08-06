// Enum constants are intentionally accessed through VM reflection.
// ignore_for_file: unused_field

import 'dart:io';

import 'package:serverpod_admin_server/src/admin/admin_enum_values.dart';
import 'package:test/test.dart';

void main() {
  test('discovers every enum value without application configuration', () {
    expect(discoverAdminEnumValues(_VerificationStatus), [
      'pending',
      'approved',
      'rejected',
    ]);
  });

  test('returns no values for a non-enum type', () {
    expect(discoverAdminEnumValues(String), isEmpty);
  });

  test('discovers generated model YAML values without VM reflection', () {
    expect(
      discoverAdminEnumValues(
        String,
        enumName: 'protocol:FixtureStatus',
        searchRoots: [Directory('test/fixtures')],
      ),
      ['draft', 'published'],
    );
  });
}

enum _VerificationStatus { pending, approved, rejected }
