import 'package:flutter/material.dart';
import 'package:serverpod_admin_dashboard/src/controller/admin_dashboard.dart';
import 'package:serverpod_admin_dashboard/src/widgets/history/record_history.dart';

/// The landing page: every table with its number of rows, and the latest
/// changes made in the dashboard.
class OverviewView extends StatefulWidget {
  const OverviewView({required this.controller, super.key});

  final AdminDashboardController controller;

  @override
  State<OverviewView> createState() => _OverviewViewState();
}

class _OverviewViewState extends State<OverviewView> {
  late Future<Map<String, int>> _counts = widget.controller.resourceCounts();
  int _historyVersion = 0;

  void _refresh() => setState(() {
    _counts = widget.controller.resourceCounts();
    _historyVersion++;
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = widget.controller;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Overview',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton.filledTonal(
              tooltip: 'Refresh',
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FutureBuilder<Map<String, int>>(
          future: _counts,
          builder: (context, snapshot) {
            final counts = snapshot.data ?? const <String, int>{};
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final resource in controller.resources)
                  SizedBox(
                    width: 220,
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => controller.selectResource(resource),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                resource.tableName,
                                style: theme.textTheme.titleSmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                switch (counts[resource.key]) {
                                  null => '…',
                                  -1 => '—',
                                  final count => '$count',
                                },
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('records', style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 32),
        Text(
          'Recent actions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: RecordHistory(
            key: ValueKey(_historyVersion),
            showResource: true,
            load: (offset, limit) =>
                controller.history(offset: offset, limit: limit),
          ),
        ),
      ],
    );
  }
}
