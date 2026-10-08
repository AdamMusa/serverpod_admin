import 'package:serverpod_admin_server/serverpod_admin_server.dart';
import 'package:test/test.dart';

enum _Status { pending, approved, rejected }

void main() {
  final registry = AdminRegistry();
  setUp(registry.reset);
  tearDown(registry.reset);

  test('declared enum values are available to column metadata', () {
    expect(registry.enumValuesFor(_Status), isNull);
    registry.registerEnum(_Status.values);
    expect(registry.enumValuesFor(_Status), [
      'pending',
      'approved',
      'rejected',
    ]);
  });

  test('values keep declaration order for index-serialized enums', () {
    registry.registerEnum([
      _Status.rejected,
      _Status.pending,
      _Status.approved,
    ]);
    expect(registry.enumValuesFor(_Status), [
      'pending',
      'approved',
      'rejected',
    ]);
  });

  test('an empty list declares nothing and reset clears declarations', () {
    registry.registerEnum(<_Status>[]);
    expect(registry.enumValuesFor(_Status), isNull);
    registry.registerEnum(_Status.values);
    registry.reset();
    expect(registry.enumValuesFor(_Status), isNull);
  });
}
