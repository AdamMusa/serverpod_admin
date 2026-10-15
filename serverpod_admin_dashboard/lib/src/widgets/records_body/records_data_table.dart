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
    this.sortColumn,
    this.sortDescending = false,
    this.onSort,
    this.hiddenColumns = const {},
    this.selectedIds,
    this.onSelect,
    this.onSelectAll,
    this.foreignLabels = const {},
    this.onOpenForeign,
    super.key,
  });

  final AdminResource resource;
  final List<Map<String, String>> records;
  final void Function(Map<String, String> record)? onView;
  final void Function(Map<String, String> record)? onEdit;
  final void Function(Map<String, String> record)? onDelete;

  /// The column the rows are sorted by, if any.
  final String? sortColumn;
  final bool sortDescending;

  /// Sorts by the tapped column header; null leaves headers inert.
  final void Function(String column)? onSort;

  /// Columns left out of the table.
  final Set<String> hiddenColumns;

  /// Selected rows by primary key; with [onSelect], rows get checkboxes.
  final Set<String>? selectedIds;
  final void Function(String id, bool selected)? onSelect;
  final ValueChanged<bool>? onSelectAll;

  /// Names of related rows: column name to {id: name}.
  final Map<String, Map<String, String>> foreignLabels;
  final void Function(AdminColumn column, String id)? onOpenForeign;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final columns = resource.columns
        .where((column) => !hiddenColumns.contains(column.name))
        .toList();
    final sortIndex = columns.indexWhere((c) => c.name == sortColumn);

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
        showCheckboxColumn: onSelect != null,
        onSelectAll: onSelectAll == null
            ? null
            : (selected) => onSelectAll!(selected ?? false),
        sortColumnIndex: sortIndex < 0 ? null : sortIndex,
        sortAscending: !sortDescending,
        columns: _buildDataColumns(columns),
        rows: _buildDataRows(records, columns),
      ),
    );
  }

  List<DataColumn> _buildDataColumns(List<AdminColumn> columns) {
    return [
      ...columns.map(
        (column) => RecordsDataColumn.build(
          column,
          onSort: onSort == null ? null : () => onSort!(column.name),
        ),
      ),
      const DataColumn(label: Text('Actions')),
    ];
  }

  List<DataRow> _buildDataRows(
    List<Map<String, String>> records,
    List<AdminColumn> columns,
  ) {
    return records.map((record) {
      final cells =
          columns
              .map(
                (column) => RecordsDataCell.build(
                  column: column,
                  value: record[column.name],
                  onTap: onView != null ? () => onView!(record) : null,
                  foreignLabel:
                      foreignLabels[column.name]?[record[column.name] ?? ''],
                  onOpenForeign: onOpenForeign == null
                      ? null
                      : () => onOpenForeign!(column, record[column.name]!),
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

      final id = _primaryValue(record);
      final select = onSelect;
      return DataRow(
        selected: id != null && (selectedIds?.contains(id) ?? false),
        onSelectChanged: select == null || id == null
            ? null
            : (selected) => select(id, selected ?? false),
        cells: cells,
      );
    }).toList();
  }

  String? _primaryValue(Map<String, String> record) {
    final primary = resource.columns.where((c) => c.isPrimary).firstOrNull;
    final value = primary == null ? null : record[primary.name];
    return value == null || value.isEmpty ? null : value;
  }
}
