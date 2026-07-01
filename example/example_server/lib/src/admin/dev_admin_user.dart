import 'dart:io';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

Future<void> findOrCreateAndLinkEmail({
  required String email,
  required String password,
}) async {
  final session = await Serverpod.instance.createSession();

  try {
    final emailAdmin = AuthServices.instance.emailIdp.admin;
    final existingAccount = await emailAdmin.findAccount(
      session,
      email: email,
    );

    final authUserId =
        existingAccount?.authUserId ??
        (await AuthServices.instance.authUsers.create(session)).id;

    if (existingAccount == null) {
      await emailAdmin.createEmailAuthentication(
        session,
        authUserId: authUserId,
        email: email,
        password: password,
      );
    }

    await AuthServices.instance.authUsers.update(
      session,
      authUserId: authUserId,
      scopes: {Scope.admin},
    );

    stdout.writeln('Admin user ready: $email');
  } finally {
    await session.close();
  }
}

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

  await findOrCreateAndLinkEmail(
    email: email.trim(),
    password: password,
  );
}
