import 'package:flutter/material.dart';
import 'package:serverpod_admin_app/src/admin_app_client.dart';
import 'package:serverpod_admin_dashboard/serverpod_admin_dashboard.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

late final AdminAppClient client;

void main() {
  client = AdminAppClient(resolveServerUrl())
    ..connectivityMonitor = FlutterConnectivityMonitor()
    ..authSessionManager = FlutterAuthSessionManager();
  client.auth.initialize();

  runApp(const ServerpodAdminApp());
}

class ServerpodAdminApp extends StatelessWidget {
  const ServerpodAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Serverpod Admin',
      debugShowCheckedModeBanner: false,
      home: AdminDashboard(
        client: client,
        title: 'Serverpod Admin',
        sidebarItemCustomizations: const {
          serverpodJobsResourceKey: SidebarItemCustomization(
            label: 'Jobs',
            icon: Icons.work_history,
          ),
        },
      ),
    );
  }
}

String resolveServerUrl() {
  const configuredUrl = String.fromEnvironment('SERVER_URL');
  if (configuredUrl.isNotEmpty) {
    return _withTrailingSlash(configuredUrl);
  }

  final base = Uri.base;
  final apiUri = base.hasPort && base.port == 8082
      ? base.replace(port: 8080, path: '/', query: null, fragment: null)
      : base.replace(path: '/', query: null, fragment: null);
  return apiUri.toString();
}

String _withTrailingSlash(String value) {
  return value.endsWith('/') ? value : '$value/';
}
