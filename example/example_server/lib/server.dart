import 'dart:io';

import 'package:example_server/src/admin/admin.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_admin_server/serverpod_admin_server.dart'
    show AdminScope;
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

import 'src/generated/endpoints.dart';
import 'src/generated/protocol.dart';
import 'src/web/routes/root.dart';

/// The starting point of the Serverpod server.
void run(List<String> args) async {
  // Initialize Serverpod and connect it with your generated code.
  final pod = Serverpod(args, Protocol(), Endpoints());

  // Initialize authentication services for the server.
  // Token managers will be used to validate and issue authentication keys,
  // and the identity providers will be the authentication options available for users.

  pod.initializeAuthServices(
    tokenManagerBuilders: [
      // Use JWT for authentication keys towards the server.
      JwtConfigFromPasswords(),
    ],
    identityProviderBuilders: [
      // Configure the email identity provider for email/password authentication.
      EmailIdpConfigFromPasswords(
        sendRegistrationVerificationCode: _sendRegistrationCode,
        sendPasswordResetVerificationCode: _sendPasswordResetCode,
      ),
    ],
  );

  // Setup a default page at the web root.
  pod.webServer.addRoute(RootRoute(), '/');
  pod.webServer.addRoute(RootRoute(), '/index.html');

  // Serve all files in the web/static relative directory under /.
  final root = Directory(Uri(path: 'web/static').toFilePath());
  pod.webServer.addRoute(StaticRoute.directory(root), '/**');

  // Start the server.
  await pod.start();
  registerAdminModule();
  // await findOrCreateAndLinkEmail();

  // await createAdminUser();
}

void _sendRegistrationCode(
  Session session, {
  required String email,
  required UuidValue accountRequestId,
  required String verificationCode,
  required Transaction? transaction,
}) {
  // NOTE: Here you call your mail service to send the verification code to
  // the user. For testing, we will just log the verification code.
  session.log('[EmailIdp] Registration code ($email): $verificationCode');
}

void _sendPasswordResetCode(
  Session session, {
  required String email,
  required UuidValue passwordResetRequestId,
  required String verificationCode,
  required Transaction? transaction,
}) {
  // NOTE: Here you call your mail service to send the verification code to
  // the user. For testing, we will just log the verification code.
  session.log('[EmailIdp] Password reset code ($email): $verificationCode');
}

Future<void> findOrCreateAndLinkEmail() async {
  // Create a manual session for internal work
  var session = await Serverpod.instance.createSession();

  // Use a nullable ID or UuidValue to track the target user
  UuidValue? authUserId;

  try {
    final emailAdmin = AuthServices.instance.emailIdp.admin;
    const email = 'adammusaaly@gmail.com';
    const password = 'Adaforlan';

    // 1. Check if the email account already exists
    final emailAccount = await emailAdmin.findAccount(
      session,
      email: email,
    );

    if (emailAccount == null) {
      // 2. Create a new AuthUser if no account exists
      final authUser = await AuthServices.instance.authUsers.create(session);
      authUserId = authUser.id;

      // 3. Create the email authentication for the new user
      await emailAdmin.createEmailAuthentication(
        session,
        authUserId: authUserId,
        email: email,
        password: password,
      );
    } else {
      // If account exists, get the ID from the existing record
      authUserId = emailAccount.authUserId;
    }

    // 4. Update the user to have admin scopes using the identified ID
    await AuthServices.instance.authUsers.update(
      session,
      authUserId: authUserId,
      scopes: {Scope.admin},
    );
    print("User $email updated to admin successfully.");
  } catch (e) {
    print("Error creating internal admin: $e");
  } finally {
    // IMPORTANT: Always close manual sessions to prevent memory leaks
    await session.close();
  }
}
