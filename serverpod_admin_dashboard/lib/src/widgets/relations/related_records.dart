import 'package:flutter/material.dart';
import 'package:serverpod_admin_client/serverpod_admin_client.dart'
    show AdminFilter, AdminFilterOperator;
import 'package:serverpod_admin_dashboard/src/controller/admin_dashboard.dart';
import 'package:serverpod_admin_dashboard/src/helpers/admin_resources.dart';
import 'package:serverpod_admin_dashboard/src/helpers/format_value.dart';

/// Called with a related table and one of its rows.
typedef RelatedRowCallback =
    void Function(AdminResource resource, Map<String, String> row);

/// Rows of other tables that point at a record (a driver's vehicles, a
/// user's rides…), like Django's inlines: each table's rows in a small
/// table, opened, edited or deleted in place, new ones added already
/// linked to the record, with a link to all of them.
class RelatedRecords extends StatefulWidget {
  const RelatedRecords({
    required this.controller,
    required this.resource,
    required this.record,
    this.onAdd,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  final AdminDashboardController controller;
  final AdminResource resource;
  final Map<String, String> record;

  /// Adds a row to a related table, starting with [presets]: its link to
  /// this record. Offered where the table allows creating.
  final void Function(AdminResource resource, Map<String, String> presets)?
  onAdd;

  /// Edits or deletes a related row, where its table allows it.
  final RelatedRowCallback? onEdit;
  final RelatedRowCallback? onDelete;

  @override
  State<RelatedRecords> createState() => _RelatedRecordsState();
}

class _RelatedRecordsState extends State<RelatedRecords> {
  late Future<List<RelatedRows>> _related;
  late String? _id;
  late int _revision;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(RelatedRecords oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Read again for another record, or after rows changed.
    if (widget.resource.key != oldWidget.resource.key ||
        widget.controller.resolvePrimaryKeyValue(
              widget.resource,
              widget.record,
            ) !=
            _id ||
        widget.controller.revision != _revision) {
      _load();
    }
  }

  void _load() {
    _id = widget.controller.resolvePrimaryKeyValue(
      widget.resource,
      widget.record,
    );
    _revision = widget.controller.revision;
    _related = widget.controller.relatedRecords(widget.resource, widget.record);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<List<RelatedRows>>(
      future: _related,
      builder: (context, snapshot) {
        // Rows read again after a change replace the shown ones when ready.
        if (snapshot.connectionState != ConnectionState.done &&
            !snapshot.hasData) {
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
        final filled = related.where((group) => group.total > 0).length;
        return Column(
          children: [
            for (final group in related)
              _RelatedGroup(
                key: ValueKey('${group.resource.key}/${group.column.name}'),
                group: group,
                controller: widget.controller,
                initiallyExpanded: group.total > 0 && filled <= 3,
                onAdd: widget.onAdd != null && group.resource.creatable
                    ? () => widget.onAdd!(group.resource, {
                        group.column.name: group.value,
                      })
                    : null,
                onEdit: group.resource.editable ? widget.onEdit : null,
                onDelete: group.resource.deletable ? widget.onDelete : null,
              ),
          ],
        );
      },
    );
  }
}

/// One related table's rows pointing at the record.
class _RelatedGroup extends StatelessWidget {
  const _RelatedGroup({
    required this.group,
    required this.controller,
    required this.initiallyExpanded,
    this.onAdd,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  final RelatedRows group;
  final AdminDashboardController controller;
  final bool initiallyExpanded;
  final VoidCallback? onAdd;
  final RelatedRowCallback? onEdit;
  final RelatedRowCallback? onDelete;

  /// At most this many of the related table's columns are shown.
  static const _maxColumns = 5;

  /// The columns shown inline, without the link to the record.
  List<AdminColumn> _columns() => [
    for (final column in AdminDashboardController.inlineColumns(group.resource))
      if (column.name != group.column.name) column,
  ].take(_maxColumns).toList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resource = group.resource;
    final columns = _columns();
    final actions = onEdit != null || onDelete != null;
    return ExpansionTile(
      initiallyExpanded: initiallyExpanded,
      title: Text('${resource.displayName} (${group.total})'),
      subtitle: Text('by ${group.column.displayName}'),
      expandedAlignment: Alignment.centerLeft,
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      childrenPadding: const EdgeInsets.only(bottom: 8),
      children: [
        if (group.rows.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'None yet.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              showCheckboxColumn: false,
              headingRowHeight: 40,
              dataRowMinHeight: 40,
              dataRowMaxHeight: 48,
              columns: [
                for (final column in columns)
                  DataColumn(label: Text(column.displayName)),
                if (actions) const DataColumn(label: Text('')),
              ],
              rows: [
                for (final row in group.rows)
                  DataRow(
                    onSelectChanged: (_) => _open(row),
                    cells: [
                      for (final column in columns)
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 220),
                            child: Text(
                              formatRecordValue(column, row[column.name]),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      if (actions)
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (onEdit case final edit?)
                                IconButton(
                                  tooltip: 'Edit',
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 20,
                                  ),
                                  onPressed: () => edit(resource, row),
                                ),
                              if (onDelete case final delete?)
                                IconButton(
                                  tooltip: 'Delete',
                                  icon: Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                    color: theme.colorScheme.error,
                                  ),
                                  onPressed: () => delete(resource, row),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Wrap(
            spacing: 8,
            children: [
              if (onAdd != null)
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: Text('Add ${resource.displayName}'),
                  onPressed: onAdd,
                ),
              if (group.total > 0)
                TextButton.icon(
                  icon: const Icon(Icons.open_in_full, size: 18),
                  label: Text('View all ${group.total}'),
                  onPressed: () => controller.showFiltered(resource, [
                    AdminFilter(
                      column: group.column.name,
                      comparison: AdminFilterOperator.equals,
                      value: group.value,
                    ),
                  ]),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _open(Map<String, String> row) {
    final id = controller.resolvePrimaryKeyValue(group.resource, row);
    if (id != null) controller.openRecord(group.resource, id);
  }
}
