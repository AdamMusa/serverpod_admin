import 'package:flutter/material.dart';
import 'package:serverpod_admin_dashboard/src/controller/pagination.dart';
import 'package:serverpod_admin_dashboard/src/helpers/format_value.dart';
import 'package:serverpod_admin_dashboard/src/helpers/admin_resources.dart';
import 'package:serverpod_admin_dashboard/src/widgets/pagination_controls.dart';

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

  @override
  void initState() {
    super.initState();
    _paginationController.setTotalRecords(widget.records.length);
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
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.errorMessage != null) {
      return _buildErrorState(context);
    }

    if (widget.records.isEmpty) {
      return _buildEmptyState(context);
    }

    final columns = widget.resource.columns;
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: _paginationController,
      builder: (context, _) {
        final pagedRecords = _paginationController.getPageItems(widget.records);

        return Column(
          children: [
            Expanded(
              child: Scrollbar(
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
                        columns: _buildDataColumns(columns),
                        rows: _buildDataRows(pagedRecords, columns, theme),
                      ),
                    ),
                  ),
                ),
              ),
            ),
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

  /// Builds DataColumn widgets for the table
  List<DataColumn> _buildDataColumns(List<AdminColumn> columns) {
    return [
      ...columns.map(
        (column) => DataColumn(
          label: Row(
            children: [
              const Icon(Icons.view_column_outlined, size: 16),
              const SizedBox(width: 8),
              Text(column.name),
            ],
          ),
        ),
      ),
      const DataColumn(label: Text('Actions')),
    ];
  }

  /// Builds DataRow widgets for the table
  List<DataRow> _buildDataRows(
    List<Map<String, String>> records,
    List<AdminColumn> columns,
    ThemeData theme,
  ) {
    return records.map((record) {
      final cells = columns
          .map(
            (column) => DataCell(
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 160, maxWidth: 300),
                child: Tooltip(
                  message: _truncateTooltipText(
                    formatRecordValue(column, record[column.name]),
                  ),
                  child: Text(
                    formatRecordValue(column, record[column.name]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
              onTap:
                  widget.onView != null ? () => widget.onView!(record) : null,
            ),
          )
          .toList()
        ..add(
          DataCell(_buildActionButtons(record, theme)),
        );

      return DataRow(cells: cells);
    }).toList();
  }

  /// Truncates text for tooltip display to prevent overly long tooltips
  String _truncateTooltipText(String text, {int maxLength = 100}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Builds action buttons for a record row
  Widget _buildActionButtons(Map<String, String> record, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.onView != null)
          IconButton(
            tooltip: 'Show record',
            icon: const Icon(Icons.visibility_outlined),
            onPressed: () => widget.onView!(record),
          ),
        if (widget.onEdit != null)
          IconButton(
            tooltip: 'Edit record',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => widget.onEdit!(record),
          ),
        if (widget.onDelete != null)
          IconButton(
            tooltip: 'Delete record',
            icon: Icon(
              Icons.delete_outline,
              color: theme.colorScheme.error,
            ),
            onPressed: () => widget.onDelete!(record),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final isSearchResult = widget.searchQuery != null &&
        widget.searchQuery!.isNotEmpty &&
        widget.totalRecords != null &&
        widget.totalRecords! > 0;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isSearchResult
                    ? theme.colorScheme.secondaryContainer.withOpacity(0.3)
                    : theme.colorScheme.primaryContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSearchResult
                    ? Icons.search_off_rounded
                    : Icons.inbox_outlined,
                size: 64,
                color: isSearchResult
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isSearchResult ? 'No matching records found' : 'No records yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isSearchResult
                  ? 'Try adjusting your search query to find what you\'re looking for.'
                  : 'This table is empty. Create your first record to get started.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (isSearchResult) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Searching for: "${widget.searchQuery}"',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.errorContainer.withOpacity(0.4),
                    theme.colorScheme.errorContainer.withOpacity(0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.error.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 56,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.error.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 20,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Failed to Load Records',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.error,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.errorMessage!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
