import 'dart:async';

import 'package:flutter/material.dart';
import 'package:serverpod_admin_dashboard/src/admin_dashboard.dart';
import 'package:serverpod_admin_dashboard/src/controller/admin_dashboard.dart';
import 'package:serverpod_admin_dashboard/src/screens/home_operations.dart';
import 'package:serverpod_admin_dashboard/src/screens/record_details.dart';
import 'package:serverpod_admin_dashboard/src/widgets/footer.dart';
import 'package:serverpod_admin_dashboard/src/widgets/jobs_view.dart';
import 'package:serverpod_admin_dashboard/src/widgets/records_view.dart';
import 'package:serverpod_admin_dashboard/src/widgets/side_bar.dart';
import 'package:serverpod_admin_client/serverpod_admin_client.dart';
import 'package:serverpod_admin_dashboard/src/widgets/records_body/records_body.dart';
import 'package:serverpod_admin_dashboard/src/widgets/overview/overview_view.dart';
import 'package:serverpod_admin_dashboard/src/helpers/admin_resources.dart'
    show AdminResourceDisplay;

class Home extends StatefulWidget {
  const Home({
    super.key,
    required this.controller,
    this.title,
    this.customSidebarBuilder,
    this.sidebarItemCustomizations,
    this.customBodyBuilder,
    this.customJobsBuilder,
    this.customDetailsBuilder,
    this.customEditDialogBuilder,
    this.customDeleteDialogBuilder,
    this.customCreateDialogBuilder,
    this.customFooterBuilder,
    this.client,
    this.onLogout,
  });

  final AdminDashboardController controller;
  final SidebarBuilder? customSidebarBuilder;
  final Map<String, SidebarItemCustomization>? sidebarItemCustomizations;
  final BodyBuilder? customBodyBuilder;
  final JobsBuilder? customJobsBuilder;
  final DetailsBuilder? customDetailsBuilder;
  final EditDialogBuilder? customEditDialogBuilder;
  final DeleteDialogBuilder? customDeleteDialogBuilder;
  final CreateDialogBuilder? customCreateDialogBuilder;
  final FooterBuilder? customFooterBuilder;
  final String? title;
  final ServerpodClientShared? client;
  final VoidCallback? onLogout;
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static const _jobsRefreshInterval = Duration(seconds: 2);

  HomeOperations? _operations;
  late final TextEditingController _searchController;
  Timer? _jobsRefreshTimer;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: widget.controller.searchQuery,
    );
    widget.controller.addListener(_onControllerChanged);
    _jobsRefreshTimer = Timer.periodic(
      _jobsRefreshInterval,
      (_) => _refreshJobsIfVisible(),
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _jobsRefreshTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (_searchController.text != widget.controller.searchQuery) {
      _searchController.text = widget.controller.searchQuery;
    }
  }

  Future<void> _refreshJobsIfVisible() async {
    if (!mounted) return;
    final selectedResource = widget.controller.selectedResource;
    if (selectedResource?.key != serverpodJobsResourceKey) return;
    if (widget.controller.isResourcesLoading) return;

    await widget.controller.loadRecords(selectedResource!, showLoading: false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize operations after context is available
    _operations ??= HomeOperations(
      controller: widget.controller,
      context: context,
      customEditDialogBuilder: widget.customEditDialogBuilder,
      customDeleteDialogBuilder: widget.customDeleteDialogBuilder,
      customCreateDialogBuilder: widget.customCreateDialogBuilder,
    );
  }

  HomeOperations get operations {
    // This should only be called after didChangeDependencies
    return _operations ??= HomeOperations(
      controller: widget.controller,
      context: context,
      customEditDialogBuilder: widget.customEditDialogBuilder,
      customDeleteDialogBuilder: widget.customDeleteDialogBuilder,
      customCreateDialogBuilder: widget.customCreateDialogBuilder,
    );
  }

  /// Builds the RecordDetails widget with common callbacks
  Widget _buildRecordDetails() {
    final detailsResource = widget.controller.detailsResource;
    final detailsRecord = widget.controller.detailsRecord;

    if (detailsResource == null || detailsRecord == null) {
      return const SizedBox.shrink();
    }

    // Use custom builder if provided
    if (widget.customDetailsBuilder != null) {
      return widget.customDetailsBuilder!(
        context,
        widget.controller,
        operations,
        detailsResource,
        detailsRecord,
      );
    }

    final canMutateDetails = _canMutateDetails(detailsResource, detailsRecord);
    final canEdit = canMutateDetails && detailsResource.editable;
    final canDelete = canMutateDetails && detailsResource.deletable;

    // Default implementation
    return RecordDetails(
      resource: detailsResource,
      record: detailsRecord,
      controller: widget.controller,
      showAppBar: false,
      operations: operations,
      onBack: () => widget.controller.closeDetails(),
      onEdit: canEdit
          ? (record) {
              operations.showEditDialog(detailsResource, record);
            }
          : null,
      onDelete: canDelete
          ? (record) {
              operations.showDeleteConfirmation(detailsResource, record);
            }
          : null,
    );
  }

  bool _canMutateDetails(AdminResource resource, Map<String, String> record) {
    if (resource.key != serverpodJobsResourceKey) return true;
    if (record['source'] == 'history') return false;
    if (record['status'] == 'finished') return false;
    return true;
  }

  /// Builds the records view widget with common callbacks
  Widget _buildRecordsView() {
    final selectedResource = widget.controller.selectedResource;
    if (selectedResource == null) {
      return const SizedBox.shrink();
    }

    // Use custom builder if provided
    if (widget.customBodyBuilder != null) {
      return widget.customBodyBuilder!(context, widget.controller, operations);
    }

    if (selectedResource.key == serverpodJobsResourceKey) {
      final onView = (Map<String, String> record) =>
          operations.showDetailsPage(selectedResource, record);
      final onEdit = (Map<String, String> record) =>
          operations.showEditDialog(selectedResource, record);
      final onDiscard = (Map<String, String> record) =>
          operations.showDeleteConfirmation(selectedResource, record);
      final onRunNow = (Map<String, String> record) =>
          operations.runJobNow(selectedResource, record);
      final onPause = (Map<String, String> record) =>
          operations.pauseJob(selectedResource, record);
      final onResume = (Map<String, String> record) =>
          operations.resumeJob(selectedResource, record);

      if (widget.customJobsBuilder != null) {
        return widget.customJobsBuilder!(
          context,
          widget.controller,
          operations,
          selectedResource,
          widget.controller.records,
          widget.controller.isRecordsLoading,
          widget.controller.recordsError,
          onView,
          onEdit,
          onDiscard,
        );
      }

      return JobsView(
        resource: selectedResource,
        records: widget.controller.records,
        historyRecords: widget.controller.jobHistory,
        isLoading: widget.controller.isRecordsLoading,
        errorMessage: widget.controller.recordsError,
        onView: onView,
        onEdit: onEdit,
        onDiscard: onDiscard,
        onRunNow: onRunNow,
        onPause: onPause,
        onResume: onResume,
      );
    }

    // Default implementation
    final controller = widget.controller;
    // Rows can be selected when something can be done with a selection.
    final bulk = selectedResource.editable || selectedResource.deletable;
    return RecordsView(
      resource: selectedResource,
      records: controller.records,
      totalRecords: controller.totalRecords,
      isLoading: controller.isRecordsLoading,
      errorMessage: controller.recordsError,
      searchQuery: controller.searchQuery,
      onSearchChanged: controller.setSearchQuery,
      onClearSearch: controller.clearSearch,
      filters: controller.filters,
      onFiltersChanged: controller.setFilters,
      hiddenColumns: controller.hiddenColumns(selectedResource),
      onToggleColumn: (column) =>
          controller.toggleColumn(selectedResource, column),
      onRefresh: () => controller.loadRecords(selectedResource),
      paging: RecordsPaging(
        pageIndex: controller.pageIndex,
        rowsPerPage: controller.rowsPerPage,
        rowsPerPageOptions: AdminDashboardController.rowsPerPageOptions,
        totalRecords: controller.totalRecords,
        onPage: controller.goToPage,
        onRowsPerPage: controller.setRowsPerPage,
        sortColumn: controller.sortColumn ?? selectedResource.sortColumn,
        sortDescending: controller.sortColumn != null
            ? controller.sortDescending
            : selectedResource.sortDescending ?? false,
        onSort: controller.sortBy,
      ),
      selectedIds: controller.selectedIds,
      onSelect: bulk ? controller.toggleSelected : null,
      onSelectPage: bulk ? controller.selectPage : null,
      onSelectAllMatching: controller.selectAllMatching,
      onClearSelection: controller.clearSelection,
      onDeleteSelected: selectedResource.deletable
          ? () => operations.deleteSelected(selectedResource)
          : null,
      onSetField: selectedResource.editable
          ? () => operations.setFieldOnSelected(selectedResource)
          : null,
      onRunAction: selectedResource.editable
          ? (action) => operations.runActionOnSelected(selectedResource, action)
          : null,
      loadForeignLabels: (column, ids) async {
        final related = controller.relatedResource(column);
        if (related == null) return const {};
        return controller.labelsFor(related, ids);
      },
      onOpenForeign: (column, id) {
        final related = controller.relatedResource(column);
        if (related != null) controller.openRecord(related, id);
      },
      onAdd: selectedResource.creatable
          ? () => operations.showCreateDialog(selectedResource)
          : null,
      onImport: selectedResource.creatable && selectedResource.editable
          ? () => operations.importRecords(selectedResource)
          : null,
      // Exports every row matching the search and filters, not one page.
      onExport: (format) async {
        final rows = await controller.fetchAllMatching(selectedResource);
        await operations.exportRecords(selectedResource, rows, format);
      },
      onEdit: selectedResource.editable
          ? (record) => operations.showEditDialog(selectedResource, record)
          : null,
      onDelete: selectedResource.deletable
          ? (record) =>
                operations.showDeleteConfirmation(selectedResource, record)
          : null,
      onView: (record) => operations.showDetailsPage(selectedResource, record),
    );
  }

  /// Builds the main content area (RecordDetails or RecordsView)
  Widget _buildMainContent() {
    if (widget.controller.isShowingDetails) {
      return _buildRecordDetails();
    }
    if (widget.controller.isShowingOverview &&
        widget.controller.resources.isNotEmpty) {
      return OverviewView(controller: widget.controller);
    }
    return _buildRecordsView();
  }

  /// Builds the footer widget
  Widget _buildFooter() {
    // Always show default footer, and custom footer on top if provided
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.customFooterBuilder != null) ...[
          widget.customFooterBuilder!(context, widget.controller),
          const SizedBox(height: 12),
        ],
        // Default footer (always shown, unchanged)
        const Footer(),
      ],
    );
  }

  /// Builds the sidebar widget
  Widget _buildSidebar() {
    // Use custom builder if provided
    if (widget.customSidebarBuilder != null) {
      return widget.customSidebarBuilder!(context, widget.controller);
    }

    // Default implementation; collapsed, it shows only icons.
    return Sidebar(
      resources: widget.controller.resources,
      isLoading: widget.controller.isResourcesLoading,
      errorMessage: widget.controller.resourcesError,
      selectedResource: widget.controller.isShowingOverview
          ? null
          : widget.controller.selectedResource,
      onOverview: widget.controller.showOverview,
      isOverviewSelected:
          widget.controller.isShowingOverview &&
          !widget.controller.isShowingDetails,
      onRetry: widget.controller.loadResources,
      onSelect: widget.controller.selectResource,
      isCollapsed: widget.controller.isSidebarCollapsed,
      onToggleCollapse: () => widget.controller.toggleSidebarCollapsed(),
      itemCustomizations: widget.sidebarItemCustomizations,
      client: widget.client,
      onLogout: widget.onLogout,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final width = MediaQuery.of(context).size.width;
        final isSmallScreen = width < 800;

        return Scaffold(
          appBar: AppBar(
            leading: isSmallScreen
                ? Builder(
                    builder: (context) => IconButton(
                      tooltip: 'Open navigation',
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  )
                : null,
            title: Text(widget.title!),
            actions: [
              IconButton(
                tooltip: widget.controller.themeMode == ThemeMode.dark
                    ? 'Switch to light mode'
                    : 'Switch to dark mode',
                onPressed: widget.controller.toggleThemeMode,
                icon: Icon(
                  widget.controller.themeMode == ThemeMode.dark
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          drawer: isSmallScreen
              ? Drawer(
                  child: SafeArea(
                    child: Sidebar(
                      resources: widget.controller.resources,
                      isLoading: widget.controller.isResourcesLoading,
                      errorMessage: widget.controller.resourcesError,
                      selectedResource: widget.controller.selectedResource,
                      onRetry: widget.controller.loadResources,
                      onSelect: (resource) {
                        Navigator.of(context).pop(); // close drawer
                        widget.controller.selectResource(resource);
                      },
                      isCollapsed: false,
                      onToggleCollapse: () {
                        Navigator.of(context).pop(); // close drawer
                      },
                      isInDrawer: true,
                      itemCustomizations: widget.sidebarItemCustomizations,
                      client: widget.client,
                      onLogout: widget.onLogout,
                    ),
                  ),
                )
              : null,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1440),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: isSmallScreen
                            ? _buildMainContent()
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSidebar(),
                                  const SizedBox(width: 20),
                                  Expanded(child: _buildMainContent()),
                                ],
                              ),
                      ),
                      const SizedBox(height: 16),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
