import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

/// Utilities for bootstrapping admin users for the admin dashboard.
class AdminUser {
  const AdminUser._();

  /// Finds or creates an email/password auth account and grants admin scope.
  ///
  /// This uses Serverpod's email identity provider admin operations. The email
  /// is treated as verified, and the password is not checked against the email
  /// provider password policy, so only call this from trusted server-side setup
  /// code.
  ///
  /// If [session] is omitted, a temporary internal session is created and
  /// closed automatically.
  static Future<void> create({
    required String email,
    required String password,
    Session? session,
    Set<Scope>? scopes,
  }) async {
    final normalizedEmail = email.trim();
    if (normalizedEmail.isEmpty) {
      throw ArgumentError.value(email, 'email', 'Email must not be empty.');
    }
    if (password.isEmpty) {
      throw ArgumentError.value(
        password,
        'password',
        'Password must not be empty.',
      );
    }

    if (session != null) {
      await _createWithSession(
        session,
        email: normalizedEmail,
        password: password,
        scopes: scopes ?? {Scope.admin},
      );
      return;
    }

    final internalSession = await Serverpod.instance.createSession();
    try {
      await _createWithSession(
        internalSession,
        email: normalizedEmail,
        password: password,
        scopes: scopes ?? {Scope.admin},
      );
    } finally {
      await internalSession.close();
    }
  }

  static Future<void> _createWithSession(
    Session session, {
    required String email,
    required String password,
    required Set<Scope> scopes,
  }) async {
    final emailAdmin = AuthServices.instance.emailIdp.admin;
    final existingAccount = await emailAdmin.findAccount(
      session,
      email: email,
    );

    final authUserId = existingAccount?.authUserId ??
        (await AuthServices.instance.authUsers.create(session)).id;

    if (existingAccount == null) {
      await emailAdmin.createEmailAuthentication(
        session,
        authUserId: authUserId,
        email: email,
        password: password,
      );
    } else {
      await emailAdmin.setPassword(
        session,
        email: email,
        password: password,
      );
    }

    await AuthServices.instance.authUsers.update(
      session,
      authUserId: authUserId,
      scopes: scopes,
    );
  }
}
