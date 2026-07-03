import 'dart:io';

import 'package:serverpod/serverpod.dart';

/// Default path where `serverpod_admin install` places the bundled Flutter web
/// dashboard inside a Serverpod server package.
const defaultAdminDashboardDirectory = 'web/admin';

/// Serves the installed Serverpod Admin Flutter web dashboard from [path].
///
/// Run `serverpod_admin install` in your server package first. It installs the
/// prebuilt dashboard files into [directory], which defaults to `web/admin`.
/// The route uses Serverpod's [FlutterRoute], so Flutter web fallback routing,
/// cache headers, and WASM headers are handled by Serverpod.
void serveAdminDashboard(
  Serverpod pod, {
  String path = '/admin',
  Directory? directory,
  bool warnIfMissing = true,
}) {
  final adminDirectory = directory ?? Directory(defaultAdminDashboardDirectory);

  if (!adminDirectory.existsSync()) {
    if (warnIfMissing) {
      // ignore: avoid_print
      print(
        'serverpod_admin: Dashboard build not found at '
        '${adminDirectory.path}. Run `serverpod_admin install` from your '
        'server package directory.',
      );
    }
    return;
  }

  pod.webServer.addRoute(FlutterRoute(adminDirectory), path);
}
