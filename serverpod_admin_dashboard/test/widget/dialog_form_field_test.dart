import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:serverpod_admin_client/serverpod_admin_client.dart';
import 'package:serverpod_admin_dashboard/src/controller/admin_dashboard.dart';
import 'package:serverpod_admin_dashboard/src/controller/dialog_form_controller.dart';
import 'package:serverpod_admin_dashboard/src/widgets/dialog_form_field.dart';

class _MockEndpointAdmin extends Mock implements EndpointAdmin {}

void main() {
  late AdminDashboardController adminController;

  setUp(() {
    adminController = AdminDashboardController(
      adminEndpoint: _MockEndpointAdmin(),
      initialThemeMode: ThemeMode.light,
    );
  });

  testWidgets('renders enum metadata as a select and serializes its index', (
    tester,
  ) async {
    final column = AdminColumn(
      name: 'verificationStatus',
      dataType: 'VerificationStatus',
      hasDefault: false,
      isPrimary: false,
      enumValues: ['pending', 'approved', 'rejected'],
      enumSerializedByName: false,
    );
    final resource = AdminResource(
      key: 'users',
      tableName: 'users',
      columns: [column],
    );
    final formController = DialogFormController(
      resource: resource,
      adminController: adminController,
      initialValues: {'verificationStatus': 'approved'},
    );
    addTearDown(formController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DialogFormField(
            column: column,
            formController: formController,
            adminController: adminController,
          ),
        ),
      ),
    );

    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    expect(find.text('approved'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('rejected').last);
    await tester.pumpAndSettle();

    expect(formController.buildPayload()['verificationStatus'], '2');
  });

  testWidgets('obscures password fields and toggles visibility', (
    tester,
  ) async {
    final column = AdminColumn(
      name: 'password',
      dataType: 'String',
      hasDefault: false,
      isPrimary: false,
    );
    final resource = AdminResource(
      key: 'users',
      tableName: 'users',
      columns: [column],
    );
    final formController = DialogFormController(
      resource: resource,
      adminController: adminController,
    );
    addTearDown(formController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DialogFormField(
            column: column,
            formController: formController,
            adminController: adminController,
          ),
        ),
      ),
    );

    expect(
      tester.widget<EditableText>(find.byType(EditableText)).obscureText,
      isTrue,
    );
    expect(find.byTooltip('Show password'), findsOneWidget);

    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();

    expect(
      tester.widget<EditableText>(find.byType(EditableText)).obscureText,
      isFalse,
    );
    expect(find.byTooltip('Hide password'), findsOneWidget);
  });
}
