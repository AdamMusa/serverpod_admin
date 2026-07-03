// ignore_for_file: deprecated_member_use

import 'package:serverpod_admin_client/serverpod_admin_client.dart'
    as serverpod_admin;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as auth_core;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as auth_idp;
import 'package:serverpod_client/serverpod_client.dart';

class EndpointEmailIdp extends auth_idp.EndpointEmailIdpBase {
  EndpointEmailIdp(super.caller);

  @override
  String get name => 'emailIdp';

  @override
  Future<auth_core.AuthSuccess> login({
    required String email,
    required String password,
  }) {
    return caller.callServerEndpoint<auth_core.AuthSuccess>(
      'emailIdp',
      'login',
      {
        'email': email,
        'password': password,
      },
    );
  }

  @override
  Future<UuidValue> startRegistration({required String email}) {
    return caller.callServerEndpoint<UuidValue>(
      'emailIdp',
      'startRegistration',
      {'email': email},
    );
  }

  @override
  Future<String> verifyRegistrationCode({
    required UuidValue accountRequestId,
    required String verificationCode,
  }) {
    return caller.callServerEndpoint<String>(
      'emailIdp',
      'verifyRegistrationCode',
      {
        'accountRequestId': accountRequestId,
        'verificationCode': verificationCode,
      },
    );
  }

  @override
  Future<auth_core.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) {
    return caller.callServerEndpoint<auth_core.AuthSuccess>(
      'emailIdp',
      'finishRegistration',
      {
        'registrationToken': registrationToken,
        'password': password,
      },
    );
  }

  @override
  Future<UuidValue> startPasswordReset({required String email}) {
    return caller.callServerEndpoint<UuidValue>(
      'emailIdp',
      'startPasswordReset',
      {'email': email},
    );
  }

  @override
  Future<String> verifyPasswordResetCode({
    required UuidValue passwordResetRequestId,
    required String verificationCode,
  }) {
    return caller.callServerEndpoint<String>(
      'emailIdp',
      'verifyPasswordResetCode',
      {
        'passwordResetRequestId': passwordResetRequestId,
        'verificationCode': verificationCode,
      },
    );
  }

  @override
  Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) {
    return caller.callServerEndpoint<void>(
      'emailIdp',
      'finishPasswordReset',
      {
        'finishPasswordResetToken': finishPasswordResetToken,
        'newPassword': newPassword,
      },
    );
  }

  @override
  Future<bool> hasAccount() {
    return caller.callServerEndpoint<bool>('emailIdp', 'hasAccount', {});
  }
}

class AdminAppModules {
  AdminAppModules(AdminAppClient client) {
    serverpodAuthCore = auth_core.Caller(client);
    serverpodAuthIdp = auth_idp.Caller(client);
    serverpodAdmin = serverpod_admin.Caller(client);
  }

  late final auth_core.Caller serverpodAuthCore;
  late final auth_idp.Caller serverpodAuthIdp;
  late final serverpod_admin.Caller serverpodAdmin;
}

class AdminAppClient extends ServerpodClientShared {
  AdminAppClient(
    String host, {
    dynamic securityContext,
    super.authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    super.onFailedCall,
    super.onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
          host,
          serverpod_admin.Protocol(),
          securityContext: securityContext,
          streamingConnectionTimeout: streamingConnectionTimeout,
          connectionTimeout: connectionTimeout,
          disconnectStreamsOnLostInternetConnection:
              disconnectStreamsOnLostInternetConnection,
        ) {
    emailIdp = EndpointEmailIdp(this);
    modules = AdminAppModules(this);
  }

  late final EndpointEmailIdp emailIdp;
  late final AdminAppModules modules;

  @override
  Map<String, EndpointRef> get endpointRefLookup => {
        'emailIdp': emailIdp,
      };

  @override
  Map<String, ModuleEndpointCaller> get moduleLookup => {
        'serverpod_auth_core': modules.serverpodAuthCore,
        'serverpod_auth_idp': modules.serverpodAuthIdp,
        'serverpod_admin': modules.serverpodAdmin,
      };
}
