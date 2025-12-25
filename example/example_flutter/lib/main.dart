import 'package:example_client/example_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_admin_dashboard/serverpod_admin_dashboard.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

/// Sets up a global client object that can be used to talk to the server from
/// anywhere in our app. The client is generated from your server code
/// and is set up to connect to a Serverpod running on a local server on
/// the default port. You will need to modify this to connect to staging or
/// production servers.
/// In a larger app, you may want to use the dependency injection of your choice
/// instead of using a global client object. This is just a simple example.
late final Client client;

late String serverUrl;

void main() {
  // When you are running the app on a physical device, you need to set the
  // server URL to the IP address of your computer. You can find the IP
  // address by running `ipconfig` on Windows or `ifconfig` on Mac/Linux.
  // You can set the variable when running or building your app like this:
  // E.g. `flutter run --dart-define=SERVER_URL=https://api.example.com/`
  const serverUrlFromEnv = String.fromEnvironment('SERVER_URL');
  final serverUrl = serverUrlFromEnv.isEmpty
      ? 'http://$localhost:8080'
      : serverUrlFromEnv;

  client = Client(serverUrl)
    ..connectivityMonitor = FlutterConnectivityMonitor()
    ..authSessionManager = FlutterAuthSessionManager();
  print("Host url is : ${client.host}");
  client.auth.initialize();

  runApp(
    MaterialApp(
      home: AdminDashboard(
        client: client,
        title: 'Super Admin Dashboard',
        sidebarItemCustomizations: const {
          'comments': SidebarItemCustomization(
            label: 'Comment',
            icon: Icons.comment,
          ),
          'persons': SidebarItemCustomization(
            label: 'People',
            icon: Icons.people,
          ),
          'posts': SidebarItemCustomization(
            label: 'Posts',
            icon: Icons.post_add,
          ),
          'settings': SidebarItemCustomization(
            label: 'Settings',
            icon: Icons.settings,
          ),
        },
      ),
    ),
  );
}
