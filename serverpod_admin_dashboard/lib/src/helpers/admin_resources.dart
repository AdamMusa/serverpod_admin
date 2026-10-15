import 'package:serverpod_admin_client/serverpod_admin_client.dart'
    as admin_client;

typedef AdminResource = admin_client.AdminResource;
typedef AdminColumn = admin_client.AdminColumn;

/// How a column is named in the dashboard.
extension AdminColumnDisplay on admin_client.AdminColumn {
  String get displayName => label ?? name;
}

/// How a resource is named, and what the signed-in user may do with it.
extension AdminResourceDisplay on admin_client.AdminResource {
  String get displayName => label ?? tableName;
  bool get creatable => canCreate != false;
  bool get editable => canEdit != false;
  bool get deletable => canDelete != false;
}
