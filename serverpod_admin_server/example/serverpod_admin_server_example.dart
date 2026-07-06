import 'package:serverpod/serverpod.dart';
import 'package:serverpod_admin_server/serverpod_admin_server.dart' as admin;

void configureServerpodAdmin() {
  admin.jobs = true;
  admin.configureAdminModule((registry) {
    // Register your Serverpod table rows here:
    // registry.register<Post>();
  });
}

void serveInstalledDashboard(Serverpod pod) {
  admin.serveAdminDashboard(pod);
}
