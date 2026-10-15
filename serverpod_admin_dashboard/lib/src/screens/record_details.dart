import 'package:flutter/material.dart';
import 'package:serverpod_admin_dashboard/src/helpers/admin_resources.dart';
import 'package:serverpod_admin_dashboard/src/helpers/fieldsets.dart';
import 'package:serverpod_admin_dashboard/src/helpers/format_value.dart';
import 'package:serverpod_admin_dashboard/src/helpers/links.dart';
import 'package:serverpod_admin_dashboard/src/widgets/document/link_value.dart';
import 'package:serverpod_admin_dashboard/src/widgets/fieldset_section.dart';
import 'package:serverpod_admin_dashboard/src/controller/admin_dashboard.dart';
import 'package:serverpod_admin_dashboard/src/screens/home_operations.dart';
import 'package:serverpod_admin_dashboard/src/widgets/history/record_history.dart';
import 'package:serverpod_admin_dashboard/src/widgets/relations/foreign_key_value.dart';
import 'package:serverpod_admin_dashboard/src/widgets/relations/related_records.dart';

class RecordDetails extends StatelessWidget {
  const RecordDetails({
    required this.resource,
    required this.record,
    this.onEdit,
    this.onDelete,
    this.onBack,
    this.showAppBar = true,
    this.controller,
    this.operations,
  });

  final AdminResource resource;
  final Map<String, String> record;
  final void Function(Map<String, String> record)? onEdit;
  final void Function(Map<String, String> record)? onDelete;
  final VoidCallback? onBack;
  final bool showAppBar;

  /// When given, foreign keys open their rows and tabs show related rows
  /// and the change history.
  final AdminDashboardController? controller;

  /// When given, related rows are added, edited and deleted in place.
  final HomeOperations? operations;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // A Material, so list tiles inside (related rows, history) show their
    // ink on it.
    final cardContent = Material(
      color: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header matching RecordsPane design
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (!showAppBar && onBack != null)
                          IconButton(
                            tooltip: 'Back',
                            icon: const Icon(Icons.arrow_back),
                            onPressed: onBack,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            style: IconButton.styleFrom(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        if (!showAppBar && onBack != null)
                          const SizedBox(width: 8),
                        Text(
                          resource.displayName,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Chip(
                          label: const Text(
                            'Record Details',
                            style: TextStyle(fontSize: 12),
                          ),
                          avatar: const Icon(Icons.info_outline, size: 18),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!showAppBar && onEdit != null)
                      IconButton(
                        tooltip: 'Edit record',
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => onEdit!(record),
                      ),
                    if (!showAppBar && onDelete != null)
                      IconButton(
                        tooltip: 'Delete record',
                        icon: Icon(
                          Icons.delete_outline,
                          color: theme.colorScheme.error,
                        ),
                        onPressed: () => onDelete!(record),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _buildBody(context, theme),
            ),
          ),
        ],
      ),
    );

    final content = showAppBar
        ? Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: cardContent,
            ),
          )
        : cardContent;

    if (showAppBar) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${resource.displayName} Details'),
          actions: [
            if (onEdit != null)
              IconButton(
                tooltip: 'Edit record',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  Navigator.of(context).pop();
                  onEdit!(record);
                },
              ),
            if (onDelete != null)
              IconButton(
                tooltip: 'Delete record',
                icon: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.error,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  onDelete!(record);
                },
              ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: content,
          ),
        ),
      );
    }

    return content;
  }

  Widget _buildBody(BuildContext context, ThemeData theme) {
    final details = _buildDetailsTable(context, theme);
    final controller = this.controller;
    final operations = this.operations;
    if (controller == null) return details;
    final id = controller.resolvePrimaryKeyValue(resource, record);
    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(icon: Icon(Icons.list_alt), text: 'Details'),
              Tab(icon: Icon(Icons.account_tree_outlined), text: 'Related'),
              Tab(icon: Icon(Icons.history), text: 'History'),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              children: [
                details,
                SingleChildScrollView(
                  child: RelatedRecords(
                    controller: controller,
                    resource: resource,
                    record: record,
                    onAdd: operations == null
                        ? null
                        : (related, presets) => operations.showCreateDialog(
                            related,
                            presets: presets,
                          ),
                    onEdit: operations?.showEditDialog,
                    onDelete: operations?.showDeleteConfirmation,
                  ),
                ),
                SingleChildScrollView(
                  child: RecordHistory(
                    key: ValueKey('${resource.key}/$id'),
                    load: (offset, limit) => controller.history(
                      resourceKey: resource.key,
                      recordId: id,
                      offset: offset,
                      limit: limit,
                    ),
                    emptyText:
                        'This record has not been changed in the '
                        'dashboard yet.',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _foreignKey(AdminColumn column, String id) {
    final controller = this.controller!;
    final related = controller.relatedResource(column);
    if (related == null) return SelectableText(id);
    return Align(
      alignment: Alignment.centerLeft,
      child: FutureBuilder<Map<String, String>>(
        future: controller.labelsFor(related, [id]),
        builder: (context, snapshot) => ForeignKeyValue(
          id: id,
          label: snapshot.data?[id],
          onOpen: () => controller.openRecord(related, id),
        ),
      ),
    );
  }

  /// Every column with its value, grouped by the resource's fieldsets.
  Widget _buildDetailsTable(BuildContext context, ThemeData theme) {
    final divider = Divider(
      height: 1,
      thickness: 0.5,
      color: theme.dividerColor.withValues(alpha: 0.3),
    );
    return ListView(
      children: [
        for (final group in columnGroups(resource, withPrimary: true))
          FieldsetSection(
            key: ValueKey(group.name),
            group: group,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (index, column) in group.columns.indexed) ...[
                  if (index > 0) divider,
                  _buildDetailRow(context, theme, column),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    ThemeData theme,
    AdminColumn column,
  ) {
    final value = record[column.name];
    final formattedValue = formatRecordValue(column, value);
    final isEmpty = formattedValue.isEmpty;
    final isPrimary = column.isPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Field column
          SizedBox(
            width: 200,
            child: Row(
              children: [
                Icon(
                  isPrimary ? Icons.vpn_key : Icons.label_outline,
                  size: 18,
                  color: isPrimary
                      ? theme.colorScheme.primary
                      : theme.textTheme.bodyMedium?.color?.withValues(
                          alpha: 0.6,
                        ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    column.displayName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isPrimary ? theme.colorScheme.primary : null,
                    ),
                  ),
                ),
                if (isPrimary) ...[
                  const SizedBox(width: 8),
                  Chip(
                    label: const Text('PK', style: TextStyle(fontSize: 10)),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    backgroundColor: theme.colorScheme.primary.withValues(
                      alpha: 0.1,
                    ),
                    labelStyle: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 10,
                    ),
                  ),
                ],
                if (column.hasDefault) ...[
                  const SizedBox(width: 8),
                  Chip(
                    label: const Text(
                      'Default',
                      style: TextStyle(fontSize: 10),
                    ),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    backgroundColor: theme.colorScheme.secondary.withValues(
                      alpha: 0.1,
                    ),
                    labelStyle: TextStyle(
                      color: theme.colorScheme.secondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Value column - wraps to multiple lines
          Expanded(
            child: switch (linkKind(value)) {
              _
                  when controller != null &&
                      column.foreignKeyTable != null &&
                      !isEmpty =>
                _foreignKey(column, value!.trim()),
              final kind? => Align(
                alignment: Alignment.centerLeft,
                child: LinkValue(
                  url: value!.trim(),
                  kind: kind,
                  title: column.displayName,
                  large: true,
                ),
              ),
              null => SelectableText(
                isEmpty ? '(empty)' : formattedValue,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isEmpty
                      ? theme.textTheme.bodyMedium?.color?.withValues(
                          alpha: 0.5,
                        )
                      : null,
                ),
              ),
            },
          ),
        ],
      ),
    );
  }
}
