import 'package:flutter/material.dart';
import 'package:serverpod_admin_dashboard/src/admin_dashboard.dart';
import 'package:serverpod_admin_dashboard/src/controller/admin_dashboard.dart';
import 'package:serverpod_admin_dashboard/src/helpers/admin_resources.dart';
import 'package:serverpod_admin_dashboard/src/screens/home_operations.dart';
import 'package:serverpod_admin_dashboard/src/screens/record_details.dart';
import 'package:serverpod_admin_dashboard/src/widgets/footer.dart';
import 'package:serverpod_admin_dashboard/src/widgets/records_pane.dart';
import 'package:serverpod_admin_dashboard/src/widgets/side_bar.dart';

/// Builder function for custom records pane/body widget
typedef BodyBuilder = Widget Function(
  BuildContext context,
  AdminDashboardController controller,
  HomeOperations operations,
);

/// Builder function for custom record details widget
typedef DetailsBuilder = Widget Function(
  BuildContext context,
  AdminDashboardController controller,
  HomeOperations operations,
  AdminResource resource,
  Map<String, String> record,
);

/// Builder function for custom edit/update dialog widget
typedef EditDialogBuilder = Widget Function(
  BuildContext context,
  AdminDashboardController controller,
  HomeOperations operations,
  AdminResource resource,
  Map<String, String> currentValues,
  Future<bool> Function(Map<String, String> payload) onSubmit,
);

/// Builder function for custom delete confirmation dialog widget
typedef DeleteDialogBuilder = Widget Function(
  BuildContext context,
  AdminDashboardController controller,
  HomeOperations operations,
  AdminResource resource,
  Map<String, String> record,
  Future<void> Function() onConfirm,
);

/// Builder function for custom create/new record dialog widget
typedef CreateDialogBuilder = Widget Function(
  BuildContext context,
  AdminDashboardController controller,
  HomeOperations operations,
  AdminResource resource,
  Future<bool> Function(Map<String, String> payload) onSubmit,
);

class Home extends StatefulWidget {
  const Home({
    super.key,
    required this.controller,
    this.customSidebarBuilder,
    this.sidebarItemCustomizations,
    this.customBodyBuilder,
    this.customDetailsBuilder,
    this.customEditDialogBuilder,
    this.customDeleteDialogBuilder,
    this.customCreateDialogBuilder,
  });

  final AdminDashboardController controller;
  final SidebarBuilder? customSidebarBuilder;
  final Map<String, SidebarItemCustomization>? sidebarItemCustomizations;
  final BodyBuilder? customBodyBuilder;
  final DetailsBuilder? customDetailsBuilder;
  final EditDialogBuilder? customEditDialogBuilder;
  final DeleteDialogBuilder? customDeleteDialogBuilder;
  final CreateDialogBuilder? customCreateDialogBuilder;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  HomeOperations? _operations;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: widget.controller.searchQuery,
    );
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (_searchController.text != widget.controller.searchQuery) {
      _searchController.text = widget.controller.searchQuery;
    }
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

    // Default implementation
    return RecordDetails(
      resource: detailsResource,
      record: detailsRecord,
      showAppBar: false,
      onBack: () => widget.controller.closeDetails(),
      onEdit: (record) {
        operations.showEditDialog(detailsResource, record);
      },
      onDelete: (record) {
        operations.showDeleteConfirmation(detailsResource, record);
      },
    );
  }

  /// Builds the RecordsPane widget with common callbacks
  Widget _buildRecordsPane() {
    final selectedResource = widget.controller.selectedResource;
    if (selectedResource == null) {
      return const SizedBox.shrink();
    }

    // Use custom builder if provided
    if (widget.customBodyBuilder != null) {
      return widget.customBodyBuilder!(
        context,
        widget.controller,
        operations,
      );
    }

    // Default implementation
    return RecordsPane(
      resource: selectedResource,
      records: widget.controller.filteredRecords,
      totalRecords: widget.controller.records.length,
      isLoading: widget.controller.isRecordsLoading,
      errorMessage: widget.controller.recordsError,
      searchQuery: widget.controller.searchQuery,
      onSearchChanged: widget.controller.setSearchQuery,
      onClearSearch: widget.controller.clearSearch,
      onAdd: () => operations.showCreateDialog(selectedResource),
      onEdit: (record) => operations.showEditDialog(selectedResource, record),
      onDelete: (record) =>
          operations.showDeleteConfirmation(selectedResource, record),
      onView: (record) => operations.showDetailsPage(selectedResource, record),
    );
  }

  /// Builds the main content area (RecordDetails or RecordsPane)
  Widget _buildMainContent() {
    if (widget.controller.isShowingDetails) {
      return _buildRecordDetails();
    }
    return _buildRecordsPane();
  }

  /// Builds the sidebar widget
  Widget _buildSidebar() {
    // Use custom builder if provided
    if (widget.customSidebarBuilder != null) {
      return widget.customSidebarBuilder!(context, widget.controller);
    }

    // Default implementation
    if (widget.controller.isSidebarCollapsed) {
      return Container(
        width: 40,
        alignment: Alignment.topCenter,
        child: IconButton(
          tooltip: 'Expand sidebar',
          icon: const Icon(Icons.chevron_right_rounded),
          onPressed: () => widget.controller.toggleSidebarCollapsed(),
        ),
      );
    }

    return Sidebar(
      resources: widget.controller.resources,
      isLoading: widget.controller.isResourcesLoading,
      errorMessage: widget.controller.resourcesError,
      selectedResource: widget.controller.selectedResource,
      onRetry: widget.controller.loadResources,
      onSelect: widget.controller.selectResource,
      isCollapsed: widget.controller.isSidebarCollapsed,
      onToggleCollapse: () => widget.controller.toggleSidebarCollapsed(),
      itemCustomizations: widget.sidebarItemCustomizations,
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
            title: const Text('Admin Dashboard'),
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
                    ),
                  ),
                )
              : null,
          body: SafeArea(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0x1A6A5AE0),
                    Color(0x106A5AE0),
                    Color(0x006A5AE0),
                  ],
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1440),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 20),
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
                        const Footer(),
                      ],
                    ),
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
