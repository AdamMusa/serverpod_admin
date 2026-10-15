import 'package:flutter/material.dart';
import 'package:serverpod_admin_client/serverpod_admin_client.dart'
    show AdminMetricValue;
import 'package:serverpod_admin_dashboard/src/controller/admin_dashboard.dart';
import 'package:serverpod_admin_dashboard/src/widgets/overview/activity_bars.dart';
import 'package:serverpod_admin_dashboard/src/widgets/history/record_history.dart';
import 'package:serverpod_admin_dashboard/src/helpers/admin_resources.dart';

/// The landing page: the server's key numbers, every table with its number
/// of rows and the rows added each day, and the latest changes made in the
/// dashboard.
class OverviewView extends StatefulWidget {
  const OverviewView({required this.controller, super.key});

  final AdminDashboardController controller;

  @override
  State<OverviewView> createState() => _OverviewViewState();
}

class _OverviewViewState extends State<OverviewView> {
  late Future<Map<String, int>> _counts = widget.controller.resourceCounts();
  late Future<List<AdminMetricValue>> _metrics = widget.controller.metrics();
  int _version = 0;

  void _refresh() => setState(() {
    _counts = widget.controller.resourceCounts();
    _metrics = widget.controller.metrics();
    _version++;
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
        FutureBuilder<List<AdminMetricValue>>(
          future: _metrics,
          builder: (context, snapshot) {
            final metrics = snapshot.data ?? const <AdminMetricValue>[];
            if (metrics.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final metric in metrics) _MetricCard(metric: metric),
                ],
              ),
            );
          },
        ),
        FutureBuilder<Map<String, int>>(
          future: _counts,
          builder: (context, snapshot) {
            final counts = snapshot.data ?? const <String, int>{};
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final resource in controller.resources)
                  _ResourceCard(
                    key: ValueKey('${resource.key}-$_version'),
                    resource: resource,
                    count: counts[resource.key],
                    controller: controller,
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
            key: ValueKey(_version),
            showResource: true,
            load: (offset, limit) =>
                controller.history(offset: offset, limit: limit),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final AdminMetricValue metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hint = metric.hint;
    return SizedBox(
      width: 220,
      child: Card(
        color: theme.colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                metric.label,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                metric.value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (hint != null)
                Text(
                  hint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A table's row count and, when it has a date column, the rows added on
/// each of the last 30 days.
class _ResourceCard extends StatefulWidget {
  const _ResourceCard({
    required this.resource,
    required this.count,
    required this.controller,
    super.key,
  });

  final AdminResource resource;
  final int? count;
  final AdminDashboardController controller;

  @override
  State<_ResourceCard> createState() => _ResourceCardState();
}

class _ResourceCardState extends State<_ResourceCard> {
  late final Future<List<int>> _activity = widget.controller.activity(
    widget.resource,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resource = widget.resource;
    return SizedBox(
      width: 220,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => widget.controller.selectResource(resource),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource.displayName,
                  style: theme.textTheme.titleSmall,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  switch (widget.count) {
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
                FutureBuilder<List<int>>(
                  future: _activity,
                  builder: (context, snapshot) {
                    final counts = snapshot.data ?? const <int>[];
                    if (counts.isEmpty) return const SizedBox.shrink();
                    final added = counts.fold(0, (sum, c) => sum + c);
                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ActivityBars(counts: counts, height: 32),
                          const SizedBox(height: 4),
                          Text(
                            '$added added in the last ${counts.length} days',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
