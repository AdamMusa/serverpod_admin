import 'package:serverpod_admin_client/serverpod_admin_client.dart';

void main() {
  final resource = AdminResource(
    key: 'posts',
    tableName: 'post',
    columns: [
      AdminColumn(
        name: 'id',
        dataType: 'int',
        hasDefault: true,
        isPrimary: true,
      ),
      AdminColumn(
        name: 'title',
        dataType: 'String',
        hasDefault: false,
        isPrimary: false,
      ),
    ],
  );

  print(resource.toJson());
}
