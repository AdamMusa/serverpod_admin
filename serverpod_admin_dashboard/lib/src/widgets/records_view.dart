import 'package:flutter/material.dart';
import 'package:serverpod_admin_client/serverpod_admin_client.dart'
    show AdminActionInfo, AdminFilter, AdminSavedView;
import 'package:serverpod_admin_dashboard/src/helpers/admin_resources.dart';
import 'package:serverpod_admin_dashboard/src/helpers/tabular_data.dart';
import 'package:serverpod_admin_dashboard/src/helpers/filters.dart';
import 'package:serverpod_admin_dashboard/src/widgets/filters/filter_dialog.dart';
import 'package:serverpod_admin_dashboard/src/widgets/records_body/records_body.dart';

/// Widget that displays a resource's records with search, add, edit, and delete functionality.
class RecordsView extends StatefulWidget {
  const RecordsView({
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
    this.onImport,
    this.onExport,
    this.filters = const [],
    this.onFiltersChanged,
    this.hiddenColumns = const {},
    this.onToggleColumn,
    this.onRefresh,
    this.paging,
    this.selectedIds = const {},
    this.onSelect,
    this.onSelectPage,
    this.onSelectAllMatching,
    this.onClearSelection,
    this.onDeleteSelected,
    this.onSetField,
    this.onRunAction,
    this.loadForeignLabels,
    this.onOpenForeign,
    this.savedViews = const [],
    this.currentView,
    this.onApplyView,
    this.onSaveView,
    this.onDeleteView,
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
  final VoidCallback? onImport;
  final void Function(TabularFileFormat format)? onExport;

  /// Active filters, shown as chips; [onFiltersChanged] edits them.
  final List<AdminFilter> filters;
  final ValueChanged<List<AdminFilter>>? onFiltersChanged;

  /// Columns hidden from the table; [onToggleColumn] shows or hides one.
  final Set<String> hiddenColumns;
  final ValueChanged<String>? onToggleColumn;

  final VoidCallback? onRefresh;

  /// Server-side paging and sorting; without it the rows are paged here.
  final RecordsPaging? paging;

  /// Selected rows by primary key, and what can be done with them.
  final Set<String> selectedIds;
  final void Function(String id, bool selected)? onSelect;
  final ValueChanged<bool>? onSelectPage;
  final VoidCallback? onSelectAllMatching;
  final VoidCallback? onClearSelection;
  final VoidCallback? onDeleteSelected;
  final VoidCallback? onSetField;
  final void Function(AdminActionInfo action)? onRunAction;

  final Future<Map<String, String>> Function(
    AdminColumn column,
    Set<String> ids,
  )?
  loadForeignLabels;
  final void Function(AdminColumn column, String id)? onOpenForeign;

  /// The user's saved views of this table, the one showing now, and what
  /// can be done with them; [onSaveView] saves what is shown.
  final List<AdminSavedView> savedViews;
  final AdminSavedView? currentView;
  final ValueChanged<AdminSavedView>? onApplyView;
  final VoidCallback? onSaveView;
  final ValueChanged<AdminSavedView>? onDeleteView;

  @override
  State<RecordsView> createState() => _RecordsViewState();
}

class _RecordsViewState extends State<RecordsView> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery ?? '');
  }

  @override
  void didUpdateWidget(RecordsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Shows a search set elsewhere, such as by a saved view or a link, and
    // clears it for another table.
    final query = widget.searchQuery ?? '';
    if (query != _searchController.text) _searchController.text = query;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.resource == null) {
      return _buildEmptyState(context);
    }

    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          const Divider(height: 1, thickness: 1),
          if (widget.filters.isNotEmpty) _buildFilterChips(context),
          if (widget.selectedIds.isNotEmpty) _buildBulkBar(context),
          _buildRecordsContent(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 720;
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildResourceInfo(context),
                const SizedBox(height: 16),
                _buildActionButtons(context, compact: true),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildResourceInfo(context)),
              const SizedBox(width: 16),
              Flexible(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _buildActionButtons(context),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildResourceInfo(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.resource!.displayName,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildRecordsCountChip(context),
            if (widget.currentView case final view?)
              Chip(
                avatar: const Icon(Icons.bookmark, size: 18),
                label: Text(view.name, style: theme.textTheme.labelLarge),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSavedViewsMenu(BuildContext context) {
    final current = widget.currentView;
    return MenuAnchor(
      builder: (context, controller, child) => IconButton.filledTonal(
        tooltip: 'Saved views',
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
        icon: Icon(current == null ? Icons.bookmark_border : Icons.bookmark),
      ),
      menuChildren: [
        for (final view in widget.savedViews)
          MenuItemButton(
            leadingIcon: Icon(
              view.id == current?.id ? Icons.check : Icons.bookmark_border,
            ),
            onPressed: () => widget.onApplyView?.call(view),
            child: Text(view.name),
          ),
        if (widget.savedViews.isNotEmpty) const Divider(height: 1),
        if (widget.onSaveView != null)
          MenuItemButton(
            leadingIcon: const Icon(Icons.bookmark_add_outlined),
            onPressed: widget.onSaveView,
            child: const Text('Save view…'),
          ),
        if (current != null && widget.onDeleteView != null)
          MenuItemButton(
            leadingIcon: const Icon(Icons.bookmark_remove_outlined),
            onPressed: () => widget.onDeleteView!(current),
            child: Text('Delete “${current.name}”'),
          ),
      ],
    );
  }

  Widget _buildRecordsCountChip(BuildContext context) {
    final theme = Theme.of(context);
    final matching = widget.paging?.totalRecords;
    final countText = matching != null
        ? '$matching ${matching == 1 ? 'record' : 'records'}'
        : widget.totalRecords != null &&
              widget.totalRecords != widget.records.length
        ? '${widget.records.length} of ${widget.totalRecords} records'
        : '${widget.records.length} records';

    return Chip(
      label: Text(countText, style: theme.textTheme.labelLarge),
      avatar: const Icon(Icons.table_rows, size: 18),
    );
  }

  Widget _buildActionButtons(BuildContext context, {bool compact = false}) {
    return Wrap(
      alignment: compact ? WrapAlignment.start : WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        if (widget.onSearchChanged != null) _buildSearchInput(context, compact),
        if (widget.onFiltersChanged != null)
          Badge(
            isLabelVisible: widget.filters.isNotEmpty,
            label: Text('${widget.filters.length}'),
            child: IconButton.filledTonal(
              tooltip: 'Filter records',
              onPressed: () => _editFilters(context),
              icon: const Icon(Icons.filter_list),
            ),
          ),
        if (widget.onSaveView != null || widget.savedViews.isNotEmpty)
          _buildSavedViewsMenu(context),
        if (widget.onToggleColumn != null)
          MenuAnchor(
            builder: (context, controller, child) => IconButton.filledTonal(
              tooltip: 'Show or hide columns',
              onPressed: () =>
                  controller.isOpen ? controller.close() : controller.open(),
              icon: const Icon(Icons.view_column_outlined),
            ),
            menuChildren: [
              for (final column in widget.resource!.columns)
                CheckboxMenuButton(
                  value: !widget.hiddenColumns.contains(column.name),
                  closeOnActivate: false,
                  onChanged: (_) => widget.onToggleColumn!(column.name),
                  child: Text(column.name),
                ),
            ],
          ),
        if (widget.onRefresh != null)
          IconButton.filledTonal(
            tooltip: 'Refresh',
            onPressed: widget.onRefresh,
            icon: const Icon(Icons.refresh),
          ),
        IconButton.filledTonal(
          tooltip: 'Import CSV or XLSX',
          onPressed: widget.onImport,
          icon: const Icon(Icons.upload_file_outlined),
        ),
        MenuAnchor(
          builder: (context, controller, child) {
            return IconButton.filledTonal(
              tooltip: 'Export records',
              onPressed: widget.records.isEmpty
                  ? null
                  : () {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    },
              icon: const Icon(Icons.download_outlined),
            );
          },
          menuChildren: [
            MenuItemButton(
              leadingIcon: const Icon(Icons.table_chart_outlined),
              onPressed: () => widget.onExport?.call(TabularFileFormat.csv),
              child: const Text('CSV'),
            ),
            MenuItemButton(
              leadingIcon: const Icon(Icons.grid_on_outlined),
              onPressed: () => widget.onExport?.call(TabularFileFormat.xlsx),
              child: const Text('XLSX'),
            ),
          ],
        ),
        if (widget.onAdd != null)
          _buildAddRecordButton(context, compact: compact),
      ],
    );
  }

  Widget _buildSearchInput(BuildContext context, bool compact) {
    final theme = Theme.of(context);
    final hasSearchQuery = (widget.searchQuery ?? '').isNotEmpty;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: compact ? 220 : 240,
        maxWidth: compact ? 360 : 300,
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search...',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: hasSearchQuery
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: _clearSearch,
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
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
          ),
          filled: true,
          fillColor: theme.scaffoldBackgroundColor,
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

  Widget _buildAddRecordButton(BuildContext context, {bool compact = false}) {
    final tableName = widget.resource!.displayName;
    return FilledButton.icon(
      onPressed: widget.onAdd,
      icon: const Icon(Icons.add),
      label: Text(compact ? 'Add' : 'Add $tableName'),
    );
  }

  Widget _buildRecordsContent(BuildContext context) {
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
          paging: widget.paging,
          hiddenColumns: widget.hiddenColumns,
          selectedIds: widget.onSelect == null ? null : widget.selectedIds,
          onSelect: widget.onSelect,
          onSelectAll: widget.onSelectPage,
          loadForeignLabels: widget.loadForeignLabels,
          onOpenForeign: widget.onOpenForeign,
        ),
      ),
    );
  }

  Widget _buildBulkBar(BuildContext context) {
    final theme = Theme.of(context);
    final count = widget.selectedIds.length;
    final total = widget.paging?.totalRecords ?? widget.records.length;
    final actions = widget.resource!.actions ?? const <AdminActionInfo>[];
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            '$count selected',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (widget.onSelectAllMatching != null && count < total)
            TextButton(
              onPressed: widget.onSelectAllMatching,
              child: Text('Select all $total'),
            ),
          if (widget.onSetField != null)
            FilledButton.tonalIcon(
              onPressed: widget.onSetField,
              icon: const Icon(Icons.edit_note),
              label: const Text('Set field'),
            ),
          if (widget.onRunAction != null)
            for (final action in actions)
              FilledButton.tonalIcon(
                onPressed: () => widget.onRunAction!(action),
                icon: Icon(
                  action.destructive ? Icons.warning_amber : Icons.bolt,
                ),
                label: Text(action.label),
              ),
          if (widget.onDeleteSelected != null)
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
              onPressed: widget.onDeleteSelected,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete selected'),
            ),
          TextButton(
            onPressed: widget.onClearSelection,
            child: const Text('Clear selection'),
          ),
        ],
      ),
    );
  }

  Future<void> _editFilters(BuildContext context) async {
    final filters = await showFilterDialog(
      context,
      resource: widget.resource!,
      current: widget.filters,
    );
    if (filters != null) widget.onFiltersChanged?.call(filters);
  }

  Widget _buildFilterChips(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final filter in widget.filters)
            InputChip(
              avatar: const Icon(Icons.filter_alt_outlined, size: 18),
              label: Text(describeFilter(filter, widget.resource!)),
              onPressed: () => _editFilters(context),
              onDeleted: () => widget.onFiltersChanged?.call(
                [...widget.filters]..remove(filter),
              ),
            ),
          TextButton(
            onPressed: () => widget.onFiltersChanged?.call(const []),
            child: const Text('Clear filters'),
          ),
        ],
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    widget.onClearSearch?.call();
  }

  Widget _buildEmptyState(BuildContext context) {
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
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
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
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
