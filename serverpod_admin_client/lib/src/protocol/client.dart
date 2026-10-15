/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'dart:async' as _i2;
import 'package:serverpod_admin_client/src/protocol/admin/admin_resource.dart'
    as _i3;
import 'package:serverpod_admin_client/src/protocol/admin/admin_page.dart'
    as _i4;
import 'package:serverpod_admin_client/src/protocol/admin/admin_query.dart'
    as _i5;
import 'package:serverpod_admin_client/src/protocol/admin/admin_log_page.dart'
    as _i6;
import 'package:serverpod_admin_client/src/protocol/admin/admin_action_result.dart'
    as _i7;

/// {@category Endpoint}
class EndpointAdmin extends _i1.EndpointRef {
  EndpointAdmin(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'serverpod_admin.admin';

  _i2.Future<List<_i3.AdminResource>> resources() =>
      caller.callServerEndpoint<List<_i3.AdminResource>>(
        'serverpod_admin.admin',
        'resources',
        {},
      );

  _i2.Future<Map<String, String>> currentUserProfile() =>
      caller.callServerEndpoint<Map<String, String>>(
        'serverpod_admin.admin',
        'currentUserProfile',
        {},
      );

  _i2.Future<List<Map<String, String>>> futureCallHistory() =>
      caller.callServerEndpoint<List<Map<String, String>>>(
        'serverpod_admin.admin',
        'futureCallHistory',
        {},
      );

  _i2.Future<Map<String, String>> updateCurrentUserProfile(
    String userName,
    String fullName,
  ) => caller.callServerEndpoint<Map<String, String>>(
    'serverpod_admin.admin',
    'updateCurrentUserProfile',
    {
      'userName': userName,
      'fullName': fullName,
    },
  );

  _i2.Future<bool> changeCurrentUserPassword(
    String currentPassword,
    String newPassword,
  ) => caller.callServerEndpoint<bool>(
    'serverpod_admin.admin',
    'changeCurrentUserPassword',
    {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    },
  );

  _i2.Future<List<Map<String, String>>> list(String resourceKey) =>
      caller.callServerEndpoint<List<Map<String, String>>>(
        'serverpod_admin.admin',
        'list',
        {'resourceKey': resourceKey},
      );

  /// One page of [resourceKey]'s rows: filtered, searched and sorted in the
  /// database when possible, with the total number of matching rows.
  _i2.Future<_i4.AdminPage> query(
    String resourceKey,
    _i5.AdminQuery query,
  ) => caller.callServerEndpoint<_i4.AdminPage>(
    'serverpod_admin.admin',
    'query',
    {
      'resourceKey': resourceKey,
      'query': query,
    },
  );

  _i2.Future<List<Map<String, String>>> listPage(
    String resourceKey,
    int offset,
    int limit,
  ) => caller.callServerEndpoint<List<Map<String, String>>>(
    'serverpod_admin.admin',
    'listPage',
    {
      'resourceKey': resourceKey,
      'offset': offset,
      'limit': limit,
    },
  );

  _i2.Future<Map<String, dynamic>?> find(
    String resourceKey,
    String id,
  ) => caller.callServerEndpoint<Map<String, dynamic>?>(
    'serverpod_admin.admin',
    'find',
    {
      'resourceKey': resourceKey,
      'id': id,
    },
  );

  _i2.Future<Map<String, String>> create(
    String resourceKey,
    Map<String, String> data,
  ) => caller.callServerEndpoint<Map<String, String>>(
    'serverpod_admin.admin',
    'create',
    {
      'resourceKey': resourceKey,
      'data': data,
    },
  );

  _i2.Future<Map<String, String>> update(
    String resourceKey,
    Map<String, String> data,
  ) => caller.callServerEndpoint<Map<String, String>>(
    'serverpod_admin.admin',
    'update',
    {
      'resourceKey': resourceKey,
      'data': data,
    },
  );

  _i2.Future<bool> delete(
    String resourceKey,
    String id,
  ) => caller.callServerEndpoint<bool>(
    'serverpod_admin.admin',
    'delete',
    {
      'resourceKey': resourceKey,
      'id': id,
    },
  );

  /// The change history, newest first: everything, one resource's, or one
  /// row's when [recordId] is given too.
  _i2.Future<_i6.AdminLogPage> history(
    String? resourceKey,
    String? recordId,
    int offset,
    int limit,
  ) => caller.callServerEndpoint<_i6.AdminLogPage>(
    'serverpod_admin.admin',
    'history',
    {
      'resourceKey': resourceKey,
      'recordId': recordId,
      'offset': offset,
      'limit': limit,
    },
  );

  /// Deletes the rows with [ids], one by one, recording each; rows that
  /// cannot be deleted are counted in the message.
  _i2.Future<_i7.AdminActionResult> deleteMany(
    String resourceKey,
    List<String> ids,
  ) => caller.callServerEndpoint<_i7.AdminActionResult>(
    'serverpod_admin.admin',
    'deleteMany',
    {
      'resourceKey': resourceKey,
      'ids': ids,
    },
  );

  /// Sets [values] (column name to text, as the edit form sends them) on
  /// every row with [ids], through the same validation and hooks as a
  /// single edit.
  _i2.Future<_i7.AdminActionResult> updateMany(
    String resourceKey,
    List<String> ids,
    Map<String, String> values,
  ) => caller.callServerEndpoint<_i7.AdminActionResult>(
    'serverpod_admin.admin',
    'updateMany',
    {
      'resourceKey': resourceKey,
      'ids': ids,
      'values': values,
    },
  );

  /// Runs the custom action [name] (registered with `actions:`) on the rows
  /// with [ids], and records it in each row's history.
  _i2.Future<_i7.AdminActionResult> runAction(
    String resourceKey,
    String name,
    List<String> ids,
  ) => caller.callServerEndpoint<_i7.AdminActionResult>(
    'serverpod_admin.admin',
    'runAction',
    {
      'resourceKey': resourceKey,
      'name': name,
      'ids': ids,
    },
  );
}

class Caller extends _i1.ModuleEndpointCaller {
  Caller(_i1.ServerpodClientShared client) : super(client) {
    admin = EndpointAdmin(this);
  }

  late final EndpointAdmin admin;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
    'serverpod_admin.admin': admin,
  };
}
