import 'package:serverpod_admin_server/serverpod_admin_server.dart' as admin;
import 'package:use_serverpod_admin_server/src/generated/protocol.dart';

void registerAdminModule() {
  admin.configureAdminModule((registry) {
    registry.register<Post>();
    registry.register<Person>();
    registry.register<Comment>();
    registry.register<Comment>();
    // Add any model you want to manage!
  });
}
