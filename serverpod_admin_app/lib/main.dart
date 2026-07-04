import 'package:flutter/material.dart';
import 'package:serverpod_admin_app/src/admin_app_client.dart';
import 'package:serverpod_admin_dashboard/serverpod_admin_dashboard.dart';
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as auth_core show AuthStrategy, JwtAuthKeyProvider;
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

late final AdminAppClient client;
late final FlutterAuthSessionManager adminAuthSessionManager;

void main() {
  client = AdminAppClient(resolveServerUrl())
    ..connectivityMonitor = FlutterConnectivityMonitor();

  adminAuthSessionManager = FlutterAuthSessionManager(
    authKeyProviderDelegates: {
      auth_core.AuthStrategy.jwt.name: auth_core.JwtAuthKeyProvider(
        getAuthInfo: () async => adminAuthSessionManager.authInfo,
        onRefreshAuthInfo: (authSuccess) =>
            adminAuthSessionManager.updateSignedInUser(authSuccess),
        refreshEndpoint: client.jwtRefresh,
      ),
    },
  );
  client.authSessionManager = adminAuthSessionManager;
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
  final apiUri = Uri(
    scheme: base.scheme,
    host: base.host,
    port: base.hasPort && base.port == 8082 ? 8080 : base.port,
    path: '/',
  );
  return apiUri.toString();
}

String _withTrailingSlash(String value) {
  return value.endsWith('/') ? value : '$value/';
}
