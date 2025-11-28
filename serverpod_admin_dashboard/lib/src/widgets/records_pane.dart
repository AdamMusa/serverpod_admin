import 'package:flutter/material.dart';
import 'package:serverpod_admin_dashboard/src/helpers/admin_resources.dart';
import 'package:serverpod_admin_dashboard/src/widgets/records_body.dart';

class RecordsPane extends StatefulWidget {
  const RecordsPane({
    required this.resource,
    required this.records,
    required this.isLoading,
    required this.errorMessage,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    this.onView,
    this.totalRecords,
    this.searchQuery,
    this.onSearchChanged,
    this.onClearSearch,
    super.key,
  });

  final AdminResource? resource;
  final List<Map<String, String>> records;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onAdd;
  final void Function(Map<String, String> record)? onEdit;
  final void Function(Map<String, String> record)? onDelete;
  final void Function(Map<String, String> record)? onView;
  final int? totalRecords;
  final String? searchQuery;
  final void Function(String)? onSearchChanged;
  final VoidCallback? onClearSearch;

  @override
  State<RecordsPane> createState() => _RecordsPaneState();
}

class _RecordsPaneState extends State<RecordsPane> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery ?? '');
  }

  @override
  void didUpdateWidget(RecordsPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only sync controller when resource changes (clear search on resource change)
    if (oldWidget.resource?.key != widget.resource?.key) {
      _searchController.clear();
    }
    // Don't sync controller text on searchQuery changes - let the TextField manage its own state
    // The searchQuery prop is just for external updates (like clearing), not for syncing during typing
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.resource == null) {
      return _buildNoResourceSelected(context);
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          const Divider(height: 1, thickness: 1),
          _buildBody(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
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
          _buildHeaderInfo(context),
          _buildHeaderActions(context),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.resource!.tableName,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        _buildRecordCountChip(context),
      ],
    );
  }

  Widget _buildRecordCountChip(BuildContext context) {
    final theme = Theme.of(context);
    final countText = widget.totalRecords != null &&
            widget.totalRecords != widget.records.length
        ? '${widget.records.length} of ${widget.totalRecords} records'
        : '${widget.records.length} records';

    return Chip(
      label: Text(
        countText,
        style: theme.textTheme.labelLarge,
      ),
      avatar: const Icon(Icons.table_rows, size: 18),
    );
  }

  Widget _buildHeaderActions(BuildContext context) {
    return Row(
      children: [
        if (widget.onSearchChanged != null) ...[
          _buildSearchField(context),
          const SizedBox(width: 12),
        ],
        _buildAddButton(context),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final theme = Theme.of(context);
    final hasSearchQuery = (widget.searchQuery ?? '').isNotEmpty;

    return SizedBox(
      width: 300,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search...',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: hasSearchQuery
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: _handleClearSearch,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.3),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
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
        onChanged: widget.onSearchChanged,
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return FilledButton.icon(
      onPressed: widget.onAdd,
      icon: const Icon(Icons.add),
      label: Text('Add ${widget.resource!.tableName}'),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: RecordsBody(
          resource: widget.resource!,
          records: widget.records,
          isLoading: widget.isLoading,
          errorMessage: widget.errorMessage,
          onEdit: widget.onEdit,
          onDelete: widget.onDelete,
          onView: widget.onView,
          searchQuery: widget.searchQuery,
          totalRecords: widget.totalRecords,
        ),
      ),
    );
  }

  void _handleClearSearch() {
    _searchController.clear();
    widget.onClearSearch?.call();
  }

  Widget _buildNoResourceSelected(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.table_chart_outlined,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Select a Resource',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Choose a resource from the sidebar to view and manage its records.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
