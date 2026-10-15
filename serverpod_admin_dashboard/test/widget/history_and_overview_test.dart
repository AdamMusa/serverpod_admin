import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_admin_client/serverpod_admin_client.dart';
import 'package:serverpod_admin_dashboard/src/widgets/history/record_history.dart';
import 'package:serverpod_admin_dashboard/src/widgets/relations/foreign_key_value.dart';

void main() {
  testWidgets('history reads as who changed what', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RecordHistory(
              showResource: true,
              load: (offset, limit) async => AdminLogPage(
                total: 2,
                entries: [
                  AdminLogEntry(
                    createdAt: DateTime.utc(2026, 10, 14, 9),
                    actor: 'a',
                    actorName: 'admin@abraid.app',
                    resourceKey: 'driver_profile',
                    recordId: '12',
                    action: AdminLogAction.updated,
                    changes:
                        '{"verificationStatus":["pending","approved"],'
                        '"password":["•••","•••"]}',
                  ),
                  AdminLogEntry(
                    createdAt: DateTime.utc(2026, 10, 14, 10),
                    actor: 'a',
                    resourceKey: 'ride',
                    recordId: '7',
                    action: AdminLogAction.action,
                    changes: '{}',
                    summary: 'Refund',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(
      find.text('admin@abraid.app changed driver_profile #12'),
      findsOneWidget,
    );
    expect(find.text('verificationStatus: pending → approved'), findsOneWidget);
    expect(find.text('password: ••• → •••'), findsOneWidget);
    expect(find.text('a ran Refund on ride #7'), findsOneWidget);
    expect(find.text('Show older changes'), findsNothing);
  });

  testWidgets('a foreign key shows its row by name and opens it', (
    tester,
  ) async {
    var opened = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ForeignKeyValue(
            id: '12',
            label: 'Awa Diallo (#12)',
            onOpen: () => opened = true,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Awa Diallo (#12)'));
    expect(opened, isTrue);
  });
}
