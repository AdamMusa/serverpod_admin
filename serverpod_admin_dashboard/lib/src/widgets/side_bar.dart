import 'package:flutter/material.dart';
import 'package:serverpod_admin_dashboard/src/admin_dashboard.dart';
import 'package:serverpod_admin_dashboard/src/helpers/admin_resources.dart';
import 'package:serverpod_admin_dashboard/src/widgets/side_bar_error.dart';
import 'package:serverpod_admin_dashboard/src/screens/user_info_section.dart';
import 'package:serverpod_admin_client/serverpod_admin_client.dart'
    show ServerpodClientShared;

class Sidebar extends StatelessWidget {
  const Sidebar({
    required this.resources,
    required this.isLoading,
    required this.errorMessage,
    required this.selectedResource,
    required this.onSelect,
    required this.onRetry,
    required this.isCollapsed,
    required this.onToggleCollapse,
    this.isInDrawer = false,
    this.itemCustomizations,
    this.client,
    this.onLogout,
  });

  final List<AdminResource> resources;
  final bool isLoading;
  final String? errorMessage;
  final AdminResource? selectedResource;
  final void Function(AdminResource resource) onSelect;
  final VoidCallback onRetry;
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;
  final bool isInDrawer;
  final Map<String, SidebarItemCustomization>? itemCustomizations;
  final ServerpodClientShared? client;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 280,
      color: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          // Simple header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Resources',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (!isInDrawer)
                  IconButton(
                    icon: Icon(
                      isCollapsed
                          ? Icons.chevron_right_rounded
                          : Icons.chevron_left_rounded,
                      size: 20,
                    ),
                    onPressed: onToggleCollapse,
                    tooltip:
                        isCollapsed ? 'Expand sidebar' : 'Collapse sidebar',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                if (isInDrawer)
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: onToggleCollapse,
                    tooltip: 'Close drawer',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: _buildContent(context),
          ),
          // User info section at the bottom
          if (client != null && onLogout != null)
            UserInfoSection(
              client: client!,
              onLogout: onLogout!,
            ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return SidebarError(
        message: errorMessage!,
        onRetry: onRetry,
      );
    }

    if (resources.isEmpty) {
      return _buildNoResourcesState(context);
    }

    final theme = Theme.of(context);
    return ListView.builder(
      itemCount: resources.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final resource = resources[index];
        final isSelected = selectedResource?.key == resource.key;
        final customization = itemCustomizations?[resource.key];

        return InkWell(
          onTap: () => onSelect(resource),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.08)
                  : Colors.transparent,
              border: Border(
                left: BorderSide(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    customization?.icon ?? Icons.table_chart_outlined,
                    size: 20,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.iconTheme.color?.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      customization?.label ?? resource.tableName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoResourcesState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: theme.iconTheme.color?.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No Resources',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Register resources in your Serverpod server',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
