import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_admin_client/serverpod_admin_client.dart';
import 'package:serverpod_admin_dashboard/src/widgets/jobs_view.dart';

void main() {
  final resource = AdminResource(
    key: serverpodJobsResourceKey,
    tableName: serverpodJobsResourceKey,
    columns: [
      AdminColumn(
        name: 'id',
        dataType: 'int',
        hasDefault: true,
        isPrimary: true,
      ),
      AdminColumn(
        name: 'name',
        dataType: 'String',
        hasDefault: false,
        isPrimary: false,
      ),
      AdminColumn(
        name: 'time',
        dataType: 'DateTime',
        hasDefault: false,
        isPrimary: false,
      ),
      AdminColumn(
        name: 'serverId',
        dataType: 'String',
        hasDefault: false,
        isPrimary: false,
      ),
      AdminColumn(
        name: 'identifier',
        dataType: 'String',
        hasDefault: false,
        isPrimary: false,
      ),
    ],
  );

  testWidgets('shows Serverpod jobs with discard action', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var discarded = false;
    final futureTime = DateTime.now().toUtc().add(const Duration(hours: 1));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1000,
            height: 700,
            child: JobsView(
              resource: resource,
              records: [
                {
                  'id': '1',
                  'name': 'SendEmailJob',
                  'time': futureTime.toIso8601String(),
                  'serverId': 'server-1',
                  'identifier': 'email-1',
                },
              ],
              isLoading: false,
              errorMessage: null,
              onView: (_) {},
              onEdit: (_) {},
              onDiscard: (_) {
                discarded = true;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Serverpod jobs'), findsOneWidget);
    expect(find.text('Scheduled jobs (1)'), findsOneWidget);
    expect(find.text('SendEmailJob'), findsOneWidget);

    final discardButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Discard'),
    );
    discardButton.onPressed?.call();
    expect(discarded, isTrue);
  });
}
