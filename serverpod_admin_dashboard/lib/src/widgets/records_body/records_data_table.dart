import 'package:flutter/material.dart';
import 'package:serverpod_admin_dashboard/src/helpers/admin_resources.dart';
import 'package:serverpod_admin_dashboard/src/widgets/records_body/records_action_buttons.dart';
import 'package:serverpod_admin_dashboard/src/widgets/records_body/records_data_cell.dart';
import 'package:serverpod_admin_dashboard/src/widgets/records_body/records_data_column.dart';

/// Data table widget for displaying records.
class RecordsDataTable extends StatelessWidget {
  const RecordsDataTable({
    required this.resource,
    required this.records,
    this.onView,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  final AdminResource resource;
  final List<Map<String, String>> records;
  final void Function(Map<String, String> record)? onView;
  final void Function(Map<String, String> record)? onEdit;
  final void Function(Map<String, String> record)? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final columns = resource.columns;

    return DataTableTheme(
      data: DataTableThemeData(
        headingTextStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        headingRowColor: WidgetStateProperty.resolveWith(
          (states) => theme.dividerColor.withValues(alpha: 0.05),
        ),
        dataTextStyle: theme.textTheme.bodyMedium,
        dividerThickness: 0.6,
      ),
      child: DataTable(
        columnSpacing: 36,
        horizontalMargin: 20,
        columns: _buildDataColumns(columns),
        rows: _buildDataRows(records, columns),
      ),
    );
  }

  List<DataColumn> _buildDataColumns(List<AdminColumn> columns) {
    return [
      ...columns.map((column) => RecordsDataColumn.build(column)),
      const DataColumn(label: Text('Actions')),
    ];
  }

  List<DataRow> _buildDataRows(
    List<Map<String, String>> records,
    List<AdminColumn> columns,
  ) {
    return records.map((record) {
      final cells = columns
          .map(
            (column) => RecordsDataCell.build(
              column: column,
              value: record[column.name],
              onTap: onView != null ? () => onView!(record) : null,
            ),
          )
          .toList()
        ..add(
          DataCell(
            RecordsActionButtons(
              record: record,
              onView: onView,
              onEdit: onEdit,
              onDelete: onDelete,
            ),
          ),
        );

      return DataRow(cells: cells);
    }).toList();
  }
}
