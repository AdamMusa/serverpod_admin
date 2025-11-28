import 'package:flutter/material.dart';
import 'package:serverpod_admin_dashboard/serverpod_admin_dashboard.dart';

/// Custom sidebar implementation for the admin dashboard
class CustomSidebar extends StatelessWidget {
  const CustomSidebar({
    required this.controller,
    super.key,
  });

  final AdminDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 280,
      child: Card(
        margin: EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withOpacity(0.1),
                theme.colorScheme.primary.withOpacity(0.05),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Custom header
                Row(
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.admin_panel_settings,
                        color: theme.colorScheme.onPrimary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin Panel',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Text(
                            'Custom Sidebar',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // Resources list
                Expanded(
                  child: ListenableBuilder(
                    listenable: controller,
                    builder: (context, _) {
                      if (controller.isResourcesLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (controller.resourcesError != null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: theme.colorScheme.error,
                                size: 48,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                controller.resourcesError!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.error,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              FilledButton.icon(
                                onPressed: controller.loadResources,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (controller.resources.isEmpty) {
                        return Center(
                          child: Text(
                            'No resources available',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: controller.resources.length,
                        itemBuilder: (context, index) {
                          final resource = controller.resources[index];
                          final isSelected =
                              controller.selectedResource?.key == resource.key;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: isSelected
                                  ? theme.colorScheme.primary.withOpacity(0.15)
                                  : Colors.transparent,
                            ),
                            child: ListTile(
                              selected: isSelected,
                              leading: Icon(
                                Icons.table_chart,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface
                                        .withOpacity(0.7),
                              ),
                              title: Text(
                                resource.tableName,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : null,
                                ),
                              ),
                              subtitle: Text(
                                resource.key,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.5),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () => controller.selectResource(resource),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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
        ),
      ),
    );
  }
}
