import 'dart:io';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_admin_server/serverpod_admin_server.dart';

Future<void> createDevAdminUserFromEnvironment() async {
  if (Serverpod.instance.runMode != 'development') return;

  final email = Platform.environment['SERVERPOD_ADMIN_EMAIL'];
  final password = Platform.environment['SERVERPOD_ADMIN_PASSWORD'];
  if (email == null ||
      email.trim().isEmpty ||
      password == null ||
      password.isEmpty) {
    stdout.writeln(
      'Skipping dev admin user bootstrap. Set SERVERPOD_ADMIN_EMAIL and '
      'SERVERPOD_ADMIN_PASSWORD to create one.',
    );
    return;
  }

  await AdminUser.create(
    email: email.trim(),
    password: password,
  );
  stdout.writeln('Admin user ready: ${email.trim()}');
}
