import 'package:serverpod_admin_server/src/admin/admin_entry_base.dart';

import 'admin_registry.dart';

typedef AdminConfigurator = void Function(AdminRegistry registry);

AdminConfigurator? _adminConfigurator;

/// When true, Serverpod's persisted future-call jobs table is included in the
/// admin resources.
bool jobs = false;

/// Sets the callback used to register resources with the admin module. This
/// should be invoked by the host server during startup.
void configureAdminModule(AdminConfigurator configurator) {
  _adminConfigurator = configurator;
  // Clear any previously registered resources so the configurator can rebuild
  // state, e.g. during hot-reload scenarios.
  AdminRegistry().reset();
}

List<AdminEntryBase> adminRegister() {
  final configurator = _adminConfigurator;
  if (configurator == null) {
    throw StateError(
      'The serverpod_admin module has not been configured. '
      'Call configureAdminModule() during server startup.',
    );
  }

  final registry = AdminRegistry();
  configurator(registry);
  if (jobs) {
    registry.registerServerpodJobs();
  }
  return registry.registeredEntries;
}
