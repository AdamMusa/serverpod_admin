import 'package:flutter/material.dart';
import 'package:serverpod_admin_dashboard/serverpod_admin_dashboard.dart';

/// Custom body/records pane implementation for the admin dashboard
class CustomBody extends StatefulWidget {
  const CustomBody({
    required this.controller,
    required this.operations,
    super.key,
  });

  final AdminDashboardController controller;
  final HomeOperations operations;

  @override
  State<CustomBody> createState() => _CustomBodyState();
}

class _CustomBodyState extends State<CustomBody> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: widget.controller.searchQuery,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CustomBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller.searchQuery != widget.controller.searchQuery) {
      _searchController.text = widget.controller.searchQuery;
    }
    if (oldWidget.controller.selectedResource?.key !=
        widget.controller.selectedResource?.key) {
      _searchController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.controller.selectedResource == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.table_chart_outlined,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Select a resource to view its records',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withOpacity(0.95),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Custom header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.1),
                    theme.colorScheme.primary.withOpacity(0.05),
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.table_view,
                                color: theme.colorScheme.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.controller.selectedResource!.tableName,
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Chip(
                                        label: Text(
                                          widget.controller.filteredRecords.length !=
                                                  widget.controller.records.length
                                              ? '${widget.controller.filteredRecords.length} of ${widget.controller.records.length} records'
                                              : '${widget.controller.records.length} records',
                                          style: theme.textTheme.labelSmall,
                                        ),
                                        avatar: Icon(
                                          Icons.data_object,
                                          size: 16,
                                          color: theme.colorScheme.primary,
                                        ),
                                        backgroundColor:
                                            theme.colorScheme.primary.withOpacity(0.1),
                                      ),
                                      if (widget.controller.searchQuery.isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        Chip(
                                          label: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.search,
                                                size: 14,
                                                color: theme.colorScheme.secondary,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Filtered',
                                                style: theme.textTheme.labelSmall?.copyWith(
                                                  color: theme.colorScheme.secondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                          backgroundColor:
                                              theme.colorScheme.secondary.withOpacity(0.1),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Search field
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search records...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: widget.controller.searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: () {
                                  _searchController.clear();
                                  widget.controller.clearSearch();
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                style: IconButton.styleFrom(
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        isDense: true,
                      ),
                      onChanged: widget.controller.setSearchQuery,
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: () =>
                        widget.operations.showCreateDialog(widget.controller.selectedResource!),
                    icon: const Icon(Icons.add_circle_outline),
                    label: Text('Add ${widget.controller.selectedResource!.tableName}'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content area
            Expanded(
              child: ListenableBuilder(
                listenable: widget.controller,
                builder: (context, _) {
                  if (widget.controller.isRecordsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (widget.controller.recordsError != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.controller.recordsError!,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  if (widget.controller.filteredRecords.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.controller.searchQuery.isNotEmpty
                                ? Icons.search_off
                                : Icons.inbox_outlined,
                            size: 64,
                            color: theme.colorScheme.onSurface.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.controller.searchQuery.isNotEmpty
                                ? 'No records match your search'
                                : 'No records found',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Custom records display - simplified list view
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.controller.filteredRecords.length,
                    itemBuilder: (context, index) {
                      final record = widget.controller.filteredRecords[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.1),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          title: Text(
                            _getRecordDisplayName(widget.controller.selectedResource!, record),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: record.entries.take(3).map((entry) {
                                return Chip(
                                  label: Text(
                                    '${entry.key}: ${entry.value}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  backgroundColor:
                                      theme.colorScheme.primary.withOpacity(0.1),
                                  padding: EdgeInsets.zero,
                                  labelPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'View details',
                                icon: const Icon(Icons.visibility_outlined),
                                onPressed: () => widget.operations.showDetailsPage(
                                    widget.controller.selectedResource!, record),
                              ),
                              IconButton(
                                tooltip: 'Edit',
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () => widget.operations.showEditDialog(
                                    widget.controller.selectedResource!, record),
                              ),
                              IconButton(
                                tooltip: 'Delete',
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: theme.colorScheme.error,
                                ),
                                onPressed: () => widget.operations.showDeleteConfirmation(
                                    widget.controller.selectedResource!, record),
                              ),
                            ],
                          ),
                          onTap: () => widget.operations.showDetailsPage(
                              widget.controller.selectedResource!, record),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRecordDisplayName(
    AdminResource resource,
    Map<String, String> record,
  ) {
    // Try to find a primary key or first meaningful field
    final primaryColumn = resource.columns.firstWhere(
      (col) => col.isPrimary,
      orElse: () => resource.columns.first,
    );
    final value = record[primaryColumn.name] ?? 'Record';
    return value.isEmpty ? 'Record' : value;
  }
}

