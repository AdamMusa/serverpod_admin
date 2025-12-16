import 'package:flutter/material.dart';
import 'package:serverpod_admin_dashboard/src/controller/pagination.dart';
import 'package:serverpod_admin_dashboard/src/helpers/admin_resources.dart';
import 'package:serverpod_admin_dashboard/src/widgets/pagination_controls.dart';
import 'package:serverpod_admin_dashboard/src/widgets/records_body/records_data_table.dart';
import 'package:serverpod_admin_dashboard/src/widgets/records_body/records_empty_state.dart';
import 'package:serverpod_admin_dashboard/src/widgets/records_body/records_error_state.dart';

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
      return RecordsErrorState(errorMessage: widget.errorMessage!);
    }

    if (widget.records.isEmpty) {
      return RecordsEmptyState(
        searchQuery: widget.searchQuery,
        totalRecords: widget.totalRecords,
      );
    }

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
                    child: RecordsDataTable(
                      resource: widget.resource,
                      records: pagedRecords,
                      onView: widget.onView,
                      onEdit: widget.onEdit,
                      onDelete: widget.onDelete,
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
}
