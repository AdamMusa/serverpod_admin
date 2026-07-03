import 'package:serverpod_admin_server/src/install/serverpod_admin_cli.dart';

Future<void> main(List<String> arguments) async {
  await ServerpodAdminCli().run(arguments);
}
