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
    await tester.binding.setSurfaceSize(const Size(1800, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var discarded = false;
    final futureTime = DateTime.now().toUtc().add(const Duration(hours: 1));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1600,
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

    await tester.tap(find.text('Discard'));
    await tester.pump();

    expect(discarded, isTrue);
  });

  testWidgets('shows failed and finished future call history', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final now = DateTime.now().toUtc();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1100,
            height: 700,
            child: JobsView(
              resource: resource,
              records: const [],
              historyRecords: [
                {
                  'id': '10',
                  'name': 'FailedReportJob',
                  'serverId': 'server-1',
                  'time': now
                      .subtract(const Duration(minutes: 4))
                      .toIso8601String(),
                  'finishedAt': now
                      .subtract(const Duration(minutes: 3))
                      .toIso8601String(),
                  'duration': '1.23',
                  'error': 'NoMethodError: bad state',
                  'status': 'failed',
                  'source': 'history',
                },
                {
                  'id': '11',
                  'name': 'FinishedDigestJob',
                  'serverId': 'server-1',
                  'time': now
                      .subtract(const Duration(minutes: 2))
                      .toIso8601String(),
                  'finishedAt': now
                      .subtract(const Duration(minutes: 1))
                      .toIso8601String(),
                  'duration': '0.42',
                  'error': '',
                  'status': 'finished',
                  'source': 'history',
                },
              ],
              isLoading: false,
              errorMessage: null,
              onView: (_) {},
              onEdit: (_) {},
              onDiscard: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Failed jobs (1)'), findsOneWidget);
    expect(find.text('Finished jobs (1)'), findsOneWidget);

    await tester.tap(find.text('Failed jobs (1)'));
    await tester.pumpAndSettle();
    expect(find.text('FailedReportJob'), findsOneWidget);
    expect(find.text('NoMethodError: bad state'), findsOneWidget);
    expect(find.text('Failed'), findsOneWidget);

    await tester.tap(find.text('Finished jobs (1)'));
    await tester.pumpAndSettle();
    expect(find.text('FinishedDigestJob'), findsOneWidget);
    expect(find.text('Finished in 0.42s'), findsOneWidget);
    expect(find.text('Finished'), findsOneWidget);
  });

  testWidgets('does not show run now action for ready jobs', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final dueTime = DateTime.now().toUtc().subtract(const Duration(minutes: 2));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1100,
            height: 700,
            child: JobsView(
              resource: resource,
              records: [
                {
                  'id': '1',
                  'name': 'ReadyJob',
                  'time': dueTime.toIso8601String(),
                  'serverId': 'server-1',
                  'identifier': 'ready-1',
                },
              ],
              isLoading: false,
              errorMessage: null,
              onView: (_) {},
              onEdit: (_) {},
              onDiscard: (_) {},
              onRunNow: (_) {},
              onPause: (_) {},
              onResume: (_) {},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Ready jobs (1)'));
    await tester.pumpAndSettle();

    expect(find.text('ReadyJob'), findsOneWidget);
    expect(find.text('Waiting for worker'), findsWidgets);
    expect(find.byTooltip('Run now'), findsNothing);
    expect(find.byTooltip('Pause job'), findsNothing);
    expect(find.byTooltip('Reschedule job'), findsNothing);
  });

  testWidgets('paginates job rows with shared admin controls', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final futureTime = DateTime.now().toUtc().add(const Duration(hours: 1));
    final records = List.generate(12, (index) {
      final jobNumber = index + 1;
      return {
        'id': '$jobNumber',
        'name': 'ScheduledJob$jobNumber',
        'time': futureTime.add(Duration(minutes: index)).toIso8601String(),
        'serverId': 'server-1',
        'identifier': 'scheduled-$jobNumber',
      };
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            height: 700,
            child: JobsView(
              resource: resource,
              records: records,
              isLoading: false,
              errorMessage: null,
              onView: (_) {},
              onEdit: (_) {},
              onDiscard: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Showing 1-10 of 12'), findsOneWidget);
    expect(find.text('Page 1 of 2'), findsOneWidget);
    expect(find.text('ScheduledJob1'), findsOneWidget);
    expect(find.text('ScheduledJob11'), findsNothing);

    await tester.tap(find.byTooltip('Next page'));
    await tester.pumpAndSettle();

    expect(find.text('Showing 11-12 of 12'), findsOneWidget);
    expect(find.text('Page 2 of 2'), findsOneWidget);
    expect(find.text('ScheduledJob1'), findsNothing);
    expect(find.text('ScheduledJob11'), findsOneWidget);
  });
}
