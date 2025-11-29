import 'package:flutter/material.dart';
import 'package:serverpod_admin_dashboard/src/admin_dashboard.dart';
import 'package:serverpod_admin_dashboard/src/helpers/admin_resources.dart';
import 'package:serverpod_admin_dashboard/src/widgets/side_bar_error.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 280,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.dashboard_customize_outlined,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Resources',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${resources.length} available',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: isInDrawer
                        ? 'Close drawer'
                        : (isCollapsed ? 'Expand sidebar' : 'Collapse sidebar'),
                    icon: Icon(
                      isInDrawer
                          ? Icons.close_rounded
                          : (isCollapsed
                              ? Icons.chevron_right_rounded
                              : Icons.chevron_left_rounded),
                    ),
                    onPressed: onToggleCollapse,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: _buildContent(context),
                ),
              ),
            ],
          ),
        ),
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
    return ListView.separated(
      itemCount: resources.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final resource = resources[index];
        final isSelected = selectedResource?.key == resource.key;
        final customization = itemCustomizations?[resource.key];

        // Debug: Print available resource keys (remove in production)
        // Uncomment the line below to see what keys are available:
        // debugPrint('Resource key: ${resource.key}, tableName: ${resource.tableName}');

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.fastOutSlowIn,
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.12)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.dividerColor.withOpacity(0.2),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 6,
            ),
            leading: CircleAvatar(
              radius: 18,
              backgroundColor:
                  theme.colorScheme.primary.withOpacity(isSelected ? 0.2 : 0.1),
              child: Icon(
                customization?.icon ?? Icons.data_object_outlined,
                color: theme.colorScheme.primary,
              ),
            ),
            title: Text(
              customization?.label ?? resource.tableName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.chevron_right_rounded,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.iconTheme.color?.withOpacity(0.4),
            ),
            onTap: () => onSelect(resource),
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.storage_outlined,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Resources',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No resources are registered yet. Register resources in your Serverpod server to get started.',
              style: theme.textTheme.bodyMedium?.copyWith(
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
