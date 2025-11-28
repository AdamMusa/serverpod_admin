import 'package:flutter/material.dart';
import 'package:serverpod_admin_dashboard/src/helpers/admin_resources.dart';
import 'package:serverpod_admin_dashboard/src/helpers/format_value.dart';

class RecordDetails extends StatelessWidget {
  const RecordDetails({
    required this.resource,
    required this.record,
    this.onEdit,
    this.onDelete,
    this.onBack,
    this.showAppBar = true,
  });

  final AdminResource resource;
  final Map<String, String> record;
  final void Function(Map<String, String> record)? onEdit;
  final void Function(Map<String, String> record)? onDelete;
  final VoidCallback? onBack;
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final columns = resource.columns;

    final cardContent = Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header matching RecordsPane design
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              color: theme.colorScheme.primary.withOpacity(0.06),
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
                          resource.tableName,
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
              child: SingleChildScrollView(
                child: DataTableTheme(
                  data: DataTableThemeData(
                    headingTextStyle: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    headingRowColor: WidgetStateProperty.resolveWith(
                      (states) =>
                          theme.colorScheme.secondary.withOpacity(0.08),
                    ),
                    dataTextStyle: theme.textTheme.bodyMedium,
                    dividerThickness: 0.6,
                  ),
                  child: DataTable(
                      columnSpacing: 36,
                      horizontalMargin: 20,
                      columns: const [
                        DataColumn(
                          label: Row(
                            children: [
                              Icon(Icons.view_column_outlined, size: 16),
                              SizedBox(width: 8),
                              Text('Field'),
                            ],
                          ),
                        ),
                        DataColumn(
                          label: Row(
                            children: [
                              Icon(Icons.view_column_outlined, size: 16),
                              SizedBox(width: 8),
                              Text('Value'),
                            ],
                          ),
                        ),
                      ],
                      rows: columns.map((column) {
                        final value = record[column.name];
                        final formattedValue = formatRecordValue(column, value);
                        final isEmpty = formattedValue.isEmpty;
                        final isPrimary = column.isPrimary;

                        return DataRow(
                          cells: [
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isPrimary
                                        ? Icons.vpn_key
                                        : Icons.label_outline,
                                    size: 18,
                                    color: isPrimary
                                        ? theme.colorScheme.primary
                                        : theme.textTheme.bodyMedium?.color
                                            ?.withOpacity(0.6),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    column.name,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isPrimary
                                          ? theme.colorScheme.primary
                                          : null,
                                    ),
                                  ),
                                  if (isPrimary) ...[
                                    const SizedBox(width: 8),
                                    Chip(
                                      label: const Text(
                                        'PK',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                      padding: EdgeInsets.zero,
                                      visualDensity: VisualDensity.compact,
                                      backgroundColor: theme.colorScheme.primary
                                          .withOpacity(0.1),
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
                                      backgroundColor: theme
                                          .colorScheme.secondary
                                          .withOpacity(0.1),
                                      labelStyle: TextStyle(
                                        color: theme.colorScheme.secondary,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            DataCell(
                              ConstrainedBox(
                                constraints: const BoxConstraints(minWidth: 200),
                                child: SelectableText(
                                  isEmpty ? '(empty)' : formattedValue,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isEmpty
                                        ? theme.textTheme.bodyMedium?.color
                                            ?.withOpacity(0.5)
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                  ),
                ),
              ),
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
          title: Text('${resource.tableName} Details'),
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
}
