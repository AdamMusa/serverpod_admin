import 'dart:io';

import 'package:serverpod/serverpod.dart';

/// Default path where `serverpod_admin install` places the bundled Flutter web
/// dashboard inside a Serverpod server package.
const defaultAdminDashboardDirectory = 'web/admin';

/// Default web route where the bundled admin dashboard is served.
const defaultAdminDashboardPath = '/admin';

/// Serves the installed Serverpod Admin Flutter web dashboard from [path].
///
/// Run `serverpod_admin install` in your server package first. It installs the
/// prebuilt dashboard files into [directory], which defaults to `web/admin`.
/// The default route is `/admin`. Pass [path] to serve it somewhere else, for
/// example `path: '/customadminpath'`.
///
/// The route uses Serverpod's [FlutterRoute], so Flutter web fallback routing,
/// cache headers, and WASM headers are handled by Serverpod.
void serveAdminDashboard(
  Serverpod pod, {
  String path = defaultAdminDashboardPath,
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

  pod.webServer.addRoute(FlutterRoute(adminDirectory), _normalizeRoute(path));
}

String _normalizeRoute(String path) {
  if (path.isEmpty || path == '/') return defaultAdminDashboardPath;
  return path.startsWith('/') ? path : '/$path';
}
