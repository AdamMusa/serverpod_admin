import 'package:example_server/src/generated/protocol.dart';
import 'package:serverpod_admin_server/serverpod_admin_server.dart' as admin;

void registerAdminModule() {
  admin.configureAdminModule((registry) {
    registry.register<Post>();
    registry.register<Person>();
    registry.register<Comment>();
    registry.register<Setting>();

    print("Admin module registered");
    print(registry.registeredResourceMetadata);
    // Add any model you want to manage!
  });
}
