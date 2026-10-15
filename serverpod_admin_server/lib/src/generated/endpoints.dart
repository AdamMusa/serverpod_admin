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
import 'package:serverpod/serverpod.dart' as _i1;
import '../admin/endpoint/admin.dart' as _i2;
import 'package:serverpod_admin_server/src/generated/admin/admin_query.dart'
    as _i3;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i4;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i5;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'admin': _i2.AdminEndpoint()
        ..initialize(
          server,
          'admin',
          'serverpod_admin',
        ),
    };
    connectors['admin'] = _i1.EndpointConnector(
      name: 'admin',
      endpoint: endpoints['admin']!,
      methodConnectors: {
        'access': _i1.MethodConnector(
          name: 'access',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['admin'] as _i2.AdminEndpoint).access(session),
        ),
        'resources': _i1.MethodConnector(
          name: 'resources',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['admin'] as _i2.AdminEndpoint).resources(session),
        ),
        'metrics': _i1.MethodConnector(
          name: 'metrics',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['admin'] as _i2.AdminEndpoint).metrics(session),
        ),
        'overview': _i1.MethodConnector(
          name: 'overview',
          params: {
            'days': _i1.ParameterDescription(
              name: 'days',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i2.AdminEndpoint).overview(
                session,
                params['days'],
              ),
        ),
        'activity': _i1.MethodConnector(
          name: 'activity',
          params: {
            'resourceKey': _i1.ParameterDescription(
              name: 'resourceKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'days': _i1.ParameterDescription(
              name: 'days',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i2.AdminEndpoint).activity(
                session,
                params['resourceKey'],
                params['days'],
              ),
        ),
        'currentUserProfile': _i1.MethodConnector(
          name: 'currentUserProfile',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i2.AdminEndpoint)
                  .currentUserProfile(session),
        ),
        'futureCallHistory': _i1.MethodConnector(
          name: 'futureCallHistory',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i2.AdminEndpoint)
                  .futureCallHistory(session),
        ),
        'updateCurrentUserProfile': _i1.MethodConnector(
          name: 'updateCurrentUserProfile',
          params: {
            'userName': _i1.ParameterDescription(
              name: 'userName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'fullName': _i1.ParameterDescription(
              name: 'fullName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i2.AdminEndpoint)
                  .updateCurrentUserProfile(
                    session,
                    params['userName'],
                    params['fullName'],
                  ),
        ),
        'changeCurrentUserPassword': _i1.MethodConnector(
          name: 'changeCurrentUserPassword',
          params: {
            'currentPassword': _i1.ParameterDescription(
              name: 'currentPassword',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'newPassword': _i1.ParameterDescription(
              name: 'newPassword',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i2.AdminEndpoint)
                  .changeCurrentUserPassword(
                    session,
                    params['currentPassword'],
                    params['newPassword'],
                  ),
        ),
        'list': _i1.MethodConnector(
          name: 'list',
          params: {
            'resourceKey': _i1.ParameterDescription(
              name: 'resourceKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i2.AdminEndpoint).list(
                session,
                params['resourceKey'],
              ),
        ),
        'query': _i1.MethodConnector(
          name: 'query',
          params: {
            'resourceKey': _i1.ParameterDescription(
              name: 'resourceKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'query': _i1.ParameterDescription(
              name: 'query',
              type: _i1.getType<_i3.AdminQuery>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i2.AdminEndpoint).query(
                session,
                params['resourceKey'],
                params['query'],
              ),
        ),
        'listPage': _i1.MethodConnector(
          name: 'listPage',
          params: {
            'resourceKey': _i1.ParameterDescription(
              name: 'resourceKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'offset': _i1.ParameterDescription(
              name: 'offset',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'limit': _i1.ParameterDescription(
              name: 'limit',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i2.AdminEndpoint).listPage(
                session,
                params['resourceKey'],
                params['offset'],
                params['limit'],
              ),
        ),
        'find': _i1.MethodConnector(
          name: 'find',
          params: {
            'resourceKey': _i1.ParameterDescription(
              name: 'resourceKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i2.AdminEndpoint).find(
                session,
                params['resourceKey'],
                params['id'],
              ),
        ),
        'create': _i1.MethodConnector(
          name: 'create',
          params: {
            'resourceKey': _i1.ParameterDescription(
              name: 'resourceKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'data': _i1.ParameterDescription(
              name: 'data',
              type: _i1.getType<Map<String, String>>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i2.AdminEndpoint).create(
                session,
                params['resourceKey'],
                params['data'],
              ),
        ),
        'update': _i1.MethodConnector(
          name: 'update',
          params: {
            'resourceKey': _i1.ParameterDescription(
              name: 'resourceKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'data': _i1.ParameterDescription(
              name: 'data',
              type: _i1.getType<Map<String, String>>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i2.AdminEndpoint).update(
                session,
                params['resourceKey'],
                params['data'],
              ),
        ),
        'delete': _i1.MethodConnector(
          name: 'delete',
          params: {
            'resourceKey': _i1.ParameterDescription(
              name: 'resourceKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i2.AdminEndpoint).delete(
                session,
                params['resourceKey'],
                params['id'],
              ),
        ),
        'history': _i1.MethodConnector(
          name: 'history',
          params: {
            'resourceKey': _i1.ParameterDescription(
              name: 'resourceKey',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'recordId': _i1.ParameterDescription(
              name: 'recordId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'offset': _i1.ParameterDescription(
              name: 'offset',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'limit': _i1.ParameterDescription(
              name: 'limit',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i2.AdminEndpoint).history(
                session,
                params['resourceKey'],
                params['recordId'],
                params['offset'],
                params['limit'],
              ),
        ),
        'related': _i1.MethodConnector(
          name: 'related',
          params: {
            'resourceKey': _i1.ParameterDescription(
              name: 'resourceKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'limit': _i1.ParameterDescription(
              name: 'limit',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'columns': _i1.ParameterDescription(
              name: 'columns',
              type: _i1.getType<Map<String, List<String>>?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i2.AdminEndpoint).related(
                session,
                params['resourceKey'],
                params['id'],
                params['limit'],
                params['columns'],
              ),
        ),
        'savedViews': _i1.MethodConnector(
          name: 'savedViews',
          params: {
            'resourceKey': _i1.ParameterDescription(
              name: 'resourceKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i2.AdminEndpoint).savedViews(
                session,
                params['resourceKey'],
              ),
        ),
        'saveView': _i1.MethodConnector(
          name: 'saveView',
          params: {
            'resourceKey': _i1.ParameterDescription(
              name: 'resourceKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'query': _i1.ParameterDescription(
              name: 'query',
              type: _i1.getType<_i3.AdminQuery>(),
              nullable: false,
            ),
            'columns': _i1.ParameterDescription(
              name: 'columns',
              type: _i1.getType<List<String>?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i2.AdminEndpoint).saveView(
                session,
                params['resourceKey'],
                params['name'],
                params['query'],
                params['columns'],
              ),
        ),
        'deleteView': _i1.MethodConnector(
          name: 'deleteView',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i2.AdminEndpoint).deleteView(
                session,
                params['id'],
              ),
        ),
        'deleteMany': _i1.MethodConnector(
          name: 'deleteMany',
          params: {
            'resourceKey': _i1.ParameterDescription(
              name: 'resourceKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'ids': _i1.ParameterDescription(
              name: 'ids',
              type: _i1.getType<List<String>>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i2.AdminEndpoint).deleteMany(
                session,
                params['resourceKey'],
                params['ids'],
              ),
        ),
        'updateMany': _i1.MethodConnector(
          name: 'updateMany',
          params: {
            'resourceKey': _i1.ParameterDescription(
              name: 'resourceKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'ids': _i1.ParameterDescription(
              name: 'ids',
              type: _i1.getType<List<String>>(),
              nullable: false,
            ),
            'values': _i1.ParameterDescription(
              name: 'values',
              type: _i1.getType<Map<String, String>>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i2.AdminEndpoint).updateMany(
                session,
                params['resourceKey'],
                params['ids'],
                params['values'],
              ),
        ),
        'runAction': _i1.MethodConnector(
          name: 'runAction',
          params: {
            'resourceKey': _i1.ParameterDescription(
              name: 'resourceKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'ids': _i1.ParameterDescription(
              name: 'ids',
              type: _i1.getType<List<String>>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i2.AdminEndpoint).runAction(
                session,
                params['resourceKey'],
                params['name'],
                params['ids'],
              ),
        ),
      },
    );
    modules['serverpod_auth_core'] = _i4.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_idp'] = _i5.Endpoints()
      ..initializeEndpoints(server);
  }
}
