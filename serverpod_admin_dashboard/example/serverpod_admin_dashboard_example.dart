import 'package:flutter/material.dart';
import 'package:serverpod_admin_dashboard/serverpod_admin_dashboard.dart';

Widget buildAdminDashboard(dynamic client) {
  return AdminDashboard(
    client: client,
    title: 'My Admin',
    sidebarItemCustomizations: const {
      serverpodJobsResourceKey: SidebarItemCustomization(
        label: 'Jobs',
        icon: Icons.work_history,
      ),
    },
  );
}
