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
import 'package:serverpod_admin_client/src/protocol/admin/admin_access_info.dart'
    as _i3;
import 'package:serverpod_admin_client/src/protocol/admin/admin_resource.dart'
    as _i4;
import 'package:serverpod_admin_client/src/protocol/admin/admin_metric_value.dart'
    as _i5;
import 'package:serverpod_admin_client/src/protocol/admin/admin_table_summary.dart'
    as _i6;
import 'package:serverpod_admin_client/src/protocol/admin/admin_activity_point.dart'
    as _i7;
import 'package:serverpod_admin_client/src/protocol/admin/admin_page.dart'
    as _i8;
import 'package:serverpod_admin_client/src/protocol/admin/admin_query.dart'
    as _i9;
import 'package:serverpod_admin_client/src/protocol/admin/admin_log_page.dart'
    as _i10;
import 'package:serverpod_admin_client/src/protocol/admin/admin_related_rows.dart'
    as _i11;
import 'package:serverpod_admin_client/src/protocol/admin/admin_saved_view.dart'
    as _i12;
import 'package:serverpod_admin_client/src/protocol/admin/admin_action_result.dart'
    as _i13;
import 'package:serverpod_admin_client/src/protocol/admin/admin_import_result.dart'
    as _i14;

/// {@category Endpoint}
class EndpointAdmin extends _i1.EndpointRef {
  EndpointAdmin(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'serverpod_admin.admin';

  /// What the signed-in user may do; never refused, so the dashboard can
  /// explain a missing role.
  _i2.Future<_i3.AdminAccessInfo> access() =>
      caller.callServerEndpoint<_i3.AdminAccessInfo>(
        'serverpod_admin.admin',
        'access',
        {},
      );

  /// The tables the user may see, each saying whether they may create, edit
  /// and delete rows.
  _i2.Future<List<_i4.AdminResource>> resources() =>
      caller.callServerEndpoint<List<_i4.AdminResource>>(
        'serverpod_admin.admin',
        'resources',
        {},
      );

  /// Key numbers for the overview the user may see; a metric that fails
  /// shows "—".
  _i2.Future<List<_i5.AdminMetricValue>> metrics() =>
      caller.callServerEndpoint<List<_i5.AdminMetricValue>>(
        'serverpod_admin.admin',
        'metrics',
        {},
      );

  /// Every table the user may see with its number of rows and the rows it
  /// gained on each of the last [days] days: the overview in one request
  /// and two queries.
  _i2.Future<List<_i6.AdminTableSummary>> overview(int days) =>
      caller.callServerEndpoint<List<_i6.AdminTableSummary>>(
        'serverpod_admin.admin',
        'overview',
        {'days': days},
      );

  /// Rows added per day over the last [days] days, by the resource's
  /// chart column, for the overview.
  _i2.Future<List<_i7.AdminActivityPoint>> activity(
    String resourceKey,
    int days,
  ) => caller.callServerEndpoint<List<_i7.AdminActivityPoint>>(
    'serverpod_admin.admin',
    'activity',
    {
      'resourceKey': resourceKey,
      'days': days,
    },
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
  _i2.Future<_i8.AdminPage> query(
    String resourceKey,
    _i9.AdminQuery query,
  ) => caller.callServerEndpoint<_i8.AdminPage>(
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
  _i2.Future<_i10.AdminLogPage> history(
    String? resourceKey,
    String? recordId,
    int offset,
    int limit,
  ) => caller.callServerEndpoint<_i10.AdminLogPage>(
    'serverpod_admin.admin',
    'history',
    {
      'resourceKey': resourceKey,
      'recordId': recordId,
      'offset': offset,
      'limit': limit,
    },
  );

  /// The rows of every table the user may see that point at the row [id]
  /// of [resourceKey] through a foreign key: up to [limit] of each, with
  /// how many there are, in one request. [columns] gives, by table, the
  /// columns to return (all the user may see when not given).
  _i2.Future<List<_i11.AdminRelatedRows>> related(
    String resourceKey,
    String id,
    int limit,
    Map<String, List<String>>? columns,
  ) => caller.callServerEndpoint<List<_i11.AdminRelatedRows>>(
    'serverpod_admin.admin',
    'related',
    {
      'resourceKey': resourceKey,
      'id': id,
      'limit': limit,
      'columns': columns,
    },
  );

  /// The signed-in user's saved views of [resourceKey], by name.
  _i2.Future<List<_i12.AdminSavedView>> savedViews(String resourceKey) =>
      caller.callServerEndpoint<List<_i12.AdminSavedView>>(
        'serverpod_admin.admin',
        'savedViews',
        {'resourceKey': resourceKey},
      );

  /// Saves [query]'s search, sort and filters and the shown [columns] (null
  /// for the table's defaults) as the signed-in user's view [name] of
  /// [resourceKey], replacing their view of that name. Paging is not saved.
  _i2.Future<_i12.AdminSavedView> saveView(
    String resourceKey,
    String name,
    _i9.AdminQuery query,
    List<String>? columns,
  ) => caller.callServerEndpoint<_i12.AdminSavedView>(
    'serverpod_admin.admin',
    'saveView',
    {
      'resourceKey': resourceKey,
      'name': name,
      'query': query,
      'columns': columns,
    },
  );

  /// Deletes the signed-in user's saved view [id]; false when they have no
  /// such view.
  _i2.Future<bool> deleteView(int id) => caller.callServerEndpoint<bool>(
    'serverpod_admin.admin',
    'deleteView',
    {'id': id},
  );

  /// Deletes the rows with [ids], in one query unless the table deletes
  /// rows its own way, and records each; rows that cannot be deleted are
  /// counted in the message.
  _i2.Future<_i13.AdminActionResult> deleteMany(
    String resourceKey,
    List<String> ids,
  ) => caller.callServerEndpoint<_i13.AdminActionResult>(
    'serverpod_admin.admin',
    'deleteMany',
    {
      'resourceKey': resourceKey,
      'ids': ids,
    },
  );

  /// Sets [values] (column name to text, as the edit form sends them) on
  /// every row with [ids], through the same validation as a single edit:
  /// the rows are read in one query and saved in one query unless the table
  /// saves rows its own way.
  _i2.Future<_i13.AdminActionResult> updateMany(
    String resourceKey,
    List<String> ids,
    Map<String, String> values,
  ) => caller.callServerEndpoint<_i13.AdminActionResult>(
    'serverpod_admin.admin',
    'updateMany',
    {
      'resourceKey': resourceKey,
      'ids': ids,
      'values': values,
    },
  );

  /// Imports [rows] as a spreadsheet does: rows without a primary key are
  /// created (in one query unless the table creates rows its own way) and
  /// rows with one update theirs (read in one query and saved in one query
  /// unless the table saves rows its own way), all in one request.
  _i2.Future<_i14.AdminImportResult> importRows(
    String resourceKey,
    List<Map<String, String>> rows,
  ) => caller.callServerEndpoint<_i14.AdminImportResult>(
    'serverpod_admin.admin',
    'importRows',
    {
      'resourceKey': resourceKey,
      'rows': rows,
    },
  );

  /// Every row matching [query] (its search, filters and order) up to
  /// [maxRows], for exports, in one query.
  _i2.Future<List<Map<String, String>>> exportRows(
    String resourceKey,
    _i9.AdminQuery query,
    int maxRows,
  ) => caller.callServerEndpoint<List<Map<String, String>>>(
    'serverpod_admin.admin',
    'exportRows',
    {
      'resourceKey': resourceKey,
      'query': query,
      'maxRows': maxRows,
    },
  );

  /// The primary keys of the rows matching [query] up to [maxRows], to
  /// select them all, in one query reading only the keys.
  _i2.Future<List<String>> matchingIds(
    String resourceKey,
    _i9.AdminQuery query,
    int maxRows,
  ) => caller.callServerEndpoint<List<String>>(
    'serverpod_admin.admin',
    'matchingIds',
    {
      'resourceKey': resourceKey,
      'query': query,
      'maxRows': maxRows,
    },
  );

  /// Runs the custom action [name] (registered with `actions:`) on the rows
  /// with [ids], and records it in each row's history.
  _i2.Future<_i13.AdminActionResult> runAction(
    String resourceKey,
    String name,
    List<String> ids,
  ) => caller.callServerEndpoint<_i13.AdminActionResult>(
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
