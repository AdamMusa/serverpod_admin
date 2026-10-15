import 'package:flutter/material.dart';
import 'package:serverpod_admin_dashboard/src/controller/pagination.dart';
import 'package:serverpod_admin_dashboard/src/helpers/admin_resources.dart';
import 'package:serverpod_admin_dashboard/src/widgets/pagination_controls.dart';
import 'package:serverpod_admin_dashboard/src/widgets/records_body/records_data_table.dart';
import 'package:serverpod_admin_dashboard/src/widgets/records_body/records_empty_state.dart';
import 'package:serverpod_admin_dashboard/src/widgets/records_body/records_error_state.dart';

/// Paging and sorting done by the server: [RecordsBody] then shows the given
/// rows as one page. Without it the body pages the rows itself.
class RecordsPaging {
  const RecordsPaging({
    required this.pageIndex,
    required this.rowsPerPage,
    required this.rowsPerPageOptions,
    required this.totalRecords,
    required this.onPage,
    required this.onRowsPerPage,
    this.sortColumn,
    this.sortDescending = false,
    this.onSort,
  });

  final int pageIndex;
  final int rowsPerPage;
  final List<int> rowsPerPageOptions;
  final int totalRecords;
  final ValueChanged<int> onPage;
  final ValueChanged<int> onRowsPerPage;
  final String? sortColumn;
  final bool sortDescending;
  final void Function(String column)? onSort;

  int get pageCount =>
      totalRecords == 0 ? 1 : (totalRecords / rowsPerPage).ceil();
}

/// Main records body widget that displays records in a table format.
class RecordsBody extends StatefulWidget {
  const RecordsBody({
    required this.resource,
    required this.records,
    required this.isLoading,
    required this.errorMessage,
    required this.onEdit,
    required this.onDelete,
    this.onView,
    this.searchQuery,
    this.totalRecords,
    this.paging,
    this.hiddenColumns = const {},
    this.selectedIds,
    this.onSelect,
    this.onSelectAll,
    this.loadForeignLabels,
    this.onOpenForeign,
    super.key,
  });

  final AdminResource resource;
  final List<Map<String, String>> records;
  final bool isLoading;
  final String? errorMessage;
  final void Function(Map<String, String> record)? onEdit;
  final void Function(Map<String, String> record)? onDelete;
  final void Function(Map<String, String> record)? onView;
  final String? searchQuery;
  final int? totalRecords;
  final RecordsPaging? paging;
  final Set<String> hiddenColumns;
  final Set<String>? selectedIds;
  final void Function(String id, bool selected)? onSelect;
  final ValueChanged<bool>? onSelectAll;

  /// Loads names of the related rows a foreign key column points to.
  final Future<Map<String, String>> Function(
    AdminColumn column,
    Set<String> ids,
  )?
  loadForeignLabels;
  final void Function(AdminColumn column, String id)? onOpenForeign;

  @override
  State<RecordsBody> createState() => _RecordsBodyState();
}

class _RecordsBodyState extends State<RecordsBody> {
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();
  late final PaginationController _paginationController = PaginationController(
    rowsPerPage: 10,
    rowsPerPageOptions: const [5, 10, 25, 50],
  );

  Map<String, Map<String, String>> _foreignLabels = const {};

  @override
  void initState() {
    super.initState();
    _paginationController.setTotalRecords(widget.records.length);
    _loadForeignLabels();
  }

  /// Names the related rows of every foreign key shown on this page: one
  /// request per related table, however many columns point at it.
  Future<void> _loadForeignLabels() async {
    final load = widget.loadForeignLabels;
    if (load == null) return;
    final records = widget.records;
    final byTable = <String, List<AdminColumn>>{};
    for (final column in widget.resource.columns) {
      final table = column.foreignKeyTable;
      if (table == null || widget.hiddenColumns.contains(column.name)) continue;
      (byTable[table] ??= []).add(column);
    }
    final labels = <String, Map<String, String>>{};
    await Future.wait([
      for (final columns in byTable.values)
        load(columns.first, {
          for (final column in columns)
            for (final record in records)
              if ((record[column.name] ?? '').isNotEmpty) record[column.name]!,
        }).then((names) {
          for (final column in columns) {
            labels[column.name] = names;
          }
        }),
    ]);
    if (mounted && identical(records, widget.records)) {
      setState(() => _foreignLabels = labels);
    }
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    _paginationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant RecordsBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.records.length != oldWidget.records.length) {
      _paginationController.setTotalRecords(widget.records.length);
    }
    if (!identical(widget.records, oldWidget.records)) _loadForeignLabels();
  }

  @override
  Widget build(BuildContext context) {
    final paging = widget.paging;
    // A page change keeps the current rows visible while the next loads.
    if (widget.isLoading && (paging == null || widget.records.isEmpty)) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.errorMessage != null) {
      return RecordsErrorState(errorMessage: widget.errorMessage!);
    }

    if (widget.records.isEmpty) {
      return RecordsEmptyState(
        searchQuery: widget.searchQuery,
        totalRecords: widget.totalRecords,
      );
    }

    if (paging != null) {
      final start = paging.pageIndex * paging.rowsPerPage;
      return Column(
        children: [
          SizedBox(
            height: 3,
            child: widget.isLoading ? const LinearProgressIndicator() : null,
          ),
          Expanded(child: _table(widget.records, paging)),
          const SizedBox(height: 16),
          PaginationControls(
            currentPage: paging.pageIndex,
            totalPages: paging.pageCount,
            startRecord: start + 1,
            endRecord: start + widget.records.length,
            totalRecords: paging.totalRecords,
            rowsPerPage: paging.rowsPerPage,
            rowsPerPageOptions: paging.rowsPerPageOptions,
            onRowsPerPageChanged: (value) {
              if (value != null) paging.onRowsPerPage(value);
            },
            onPrevious: () => paging.onPage(paging.pageIndex - 1),
            onNext: () => paging.onPage(paging.pageIndex + 1),
          ),
        ],
      );
    }

    return ListenableBuilder(
      listenable: _paginationController,
      builder: (context, _) {
        final pagedRecords = _paginationController.getPageItems(widget.records);

        return Column(
          children: [
            Expanded(child: _table(pagedRecords, null)),
            const SizedBox(height: 16),
            PaginationControls(
              currentPage: _paginationController.currentPage,
              totalPages: _paginationController.totalPages,
              startRecord: _paginationController.startRecord,
              endRecord: _paginationController.endRecord,
              totalRecords: _paginationController.totalRecords,
              rowsPerPage: _paginationController.rowsPerPage,
              rowsPerPageOptions: _paginationController.rowsPerPageOptions,
              onRowsPerPageChanged: (value) {
                _paginationController.setRowsPerPage(value ?? 10);
              },
              onPrevious: _paginationController.goToPreviousPage,
              onNext: _paginationController.goToNextPage,
            ),
          ],
        );
      },
    );
  }

  Widget _table(List<Map<String, String>> rows, RecordsPaging? paging) {
    return Scrollbar(
      controller: _verticalController,
      thumbVisibility: true,
      radius: const Radius.circular(12),
      child: SingleChildScrollView(
        controller: _horizontalController,
        scrollDirection: Axis.horizontal,
        primary: false,
        child: SingleChildScrollView(
          controller: _verticalController,
          primary: false,
          child: RecordsDataTable(
            resource: widget.resource,
            records: rows,
            onView: widget.onView,
            onEdit: widget.onEdit,
            onDelete: widget.onDelete,
            sortColumn: paging?.sortColumn,
            sortDescending: paging?.sortDescending ?? false,
            onSort: paging?.onSort,
            hiddenColumns: widget.hiddenColumns,
            selectedIds: widget.selectedIds,
            onSelect: widget.onSelect,
            onSelectAll: widget.onSelectAll,
            foreignLabels: _foreignLabels,
            onOpenForeign: widget.onOpenForeign,
          ),
        ),
      ),
    );
  }
}
