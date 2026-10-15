import 'package:serverpod/protocol.dart' show ReadWriteTestEntry;
import 'package:serverpod_admin_server/serverpod_admin_server.dart';
import 'package:test/test.dart';

void main() {
  tearDown(() => AdminRegistry().reset());

  test('tables are registered once, not on every request', () {
    var runs = 0;
    configureAdminModule((registry) {
      runs++;
      registry.register<ReadWriteTestEntry>(
        table: ReadWriteTestEntry.t,
        fromJson: ReadWriteTestEntry.fromJson,
        resourceKey: 'counters',
      );
    });
    expect(adminRegister().single.resourceKey, 'counters');
    adminRegister();
    adminRegister();
    expect(runs, 1);

    // Configuring again registers again.
    configureAdminModule((registry) => runs++);
    expect(adminRegister(), isEmpty);
    expect(runs, 2);
  });
}
