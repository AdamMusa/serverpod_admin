import 'package:use_serverpod_admin_client/use_serverpod_admin_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:serverpod_admin_dashboard/serverpod_admin_dashboard.dart';
import 'custom_sidebar.dart';
import 'custom_body.dart';
import 'custom_details.dart';
import 'custom_edit_dialog.dart';
import 'custom_delete_dialog.dart';
import 'custom_create_dialog.dart';

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
  final serverUrl =
      serverUrlFromEnv.isEmpty ? 'http://$localhost:8080/' : serverUrlFromEnv;

  client = Client(serverUrl)
    ..connectivityMonitor = FlutterConnectivityMonitor();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: AdminDashboard(
      //   client: client,
      //   customSidebarBuilder: (context, controller) {
      //     return CustomSidebar(controller: controller);
      //   },
      //   customBodyBuilder: (context, controller, operations) {
      //     return CustomBody(
      //       controller: controller,
      //       operations: operations,
      //     );
      //   },
      //   customDetailsBuilder:
      //       (context, controller, operations, resource, record) {
      //     return CustomDetails(
      //       controller: controller,
      //       operations: operations,
      //       resource: resource,
      //       record: record,
      //     );
      //   },
      //   customEditDialogBuilder: (context, controller, operations, resource,
      //       currentValues, onSubmit) {
      //     return CustomEditDialog(
      //       resource: resource,
      //       currentValues: currentValues,
      //       onSubmit: onSubmit,
      //     );
      //   },
      //   customDeleteDialogBuilder:
      //       (context, controller, operations, resource, record, onConfirm) {
      //     return CustomDeleteDialog(
      //       resource: resource,
      //       record: record,
      //       onConfirm: onConfirm,
      //     );
      //   },
      //   customCreateDialogBuilder:
      //       (context, controller, operations, resource, onSubmit) {
      //     return CustomCreateDialog(
      //       resource: resource,
      //       onSubmit: onSubmit,
      //     );
      //   },
      // ),

      home: AdminDashboard(
        client: client,
        sidebarItemCustomizations: {
          'posts': SidebarItemCustomization(
            label: 'Posts',
            icon: Icons.post_add,
          ),
        },
      ),
    ),
  );
}
