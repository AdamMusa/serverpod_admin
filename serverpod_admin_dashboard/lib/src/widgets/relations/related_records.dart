import 'package:flutter/material.dart';
import 'package:serverpod_admin_client/serverpod_admin_client.dart'
    show AdminFilter, AdminFilterOperator;
import 'package:serverpod_admin_dashboard/src/controller/admin_dashboard.dart';
import 'package:serverpod_admin_dashboard/src/helpers/admin_resources.dart';

/// Rows of other tables that point at a record (a driver's vehicles, a
/// user's rides…), each opening its row, with a link to all of them.
class RelatedRecords extends StatelessWidget {
  const RelatedRecords({
    required this.controller,
    required this.resource,
    required this.record,
    super.key,
  });

  final AdminDashboardController controller;
  final AdminResource resource;
  final Map<String, String> record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<List<RelatedRows>>(
      future: controller.relatedRecords(resource, record),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final related = snapshot.data ?? const [];
        if (related.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'No other records point to this one.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }
        return Column(
          children: [
            for (final group in related)
              ExpansionTile(
                initiallyExpanded: related.length <= 3,
                title: Text(
                  '${group.resource.tableName} '
                  '(${group.total}) · by ${group.column.name}',
                ),
                children: [
                  for (final row in group.rows)
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.subdirectory_arrow_right),
                      title: Text(
                        AdminDashboardController.recordLabel(
                          group.resource,
                          row,
                        ),
                      ),
                      onTap: () {
                        final id = controller.resolvePrimaryKeyValue(
                          group.resource,
                          row,
                        );
                        if (id != null) {
                          controller.openRecord(group.resource, id);
                        }
                      },
                    ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      icon: const Icon(Icons.open_in_full, size: 18),
                      label: Text('View all ${group.total}'),
                      onPressed: () => controller.showFiltered(group.resource, [
                        AdminFilter(
                          column: group.column.name,
                          comparison: AdminFilterOperator.equals,
                          value: group.value,
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }
}
