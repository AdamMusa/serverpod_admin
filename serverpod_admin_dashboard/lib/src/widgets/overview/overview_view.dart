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
  late Future<Map<String, TableOverview>> _tables = widget.controller
      .overview();
  late Future<List<AdminMetricValue>> _metrics = widget.controller.metrics();
  int _version = 0;

  void _refresh() => setState(() {
    _tables = widget.controller.overview();
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
        FutureBuilder<Map<String, TableOverview>>(
          future: _tables,
          builder: (context, snapshot) {
            final tables = snapshot.data;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final resource in controller.resources)
                  _ResourceCard(
                    resource: resource,
                    // Unknown until loaded, and when it could not be read.
                    table:
                        tables?[resource.key] ??
                        (tables == null
                            ? null
                            : const TableOverview(
                                count: -1,
                                estimated: false,
                                activity: [],
                              )),
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
class _ResourceCard extends StatelessWidget {
  const _ResourceCard({
    required this.resource,
    required this.table,
    required this.controller,
  });

  final AdminResource resource;

  /// Null while loading.
  final TableOverview? table;
  final AdminDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final counts = table?.activity ?? const <int>[];
    final added = counts.fold(0, (sum, c) => sum + c);
    return SizedBox(
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
                  resource.displayName,
                  style: theme.textTheme.titleSmall,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  switch (table) {
                    null => '…',
                    TableOverview(count: -1) => '—',
                    TableOverview(:final count, estimated: true) =>
                      '≈ ${compactCount(count)}',
                    TableOverview(:final count) => '$count',
                  },
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('records', style: theme.textTheme.bodySmall),
                if (counts.isNotEmpty)
                  Padding(
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
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A large number in a few characters, such as 1.2M or 350k.
String compactCount(int count) {
  String scaled(double value, String unit) =>
      '${value >= 10 ? value.round() : (value * 10).round() / 10}$unit';
  if (count >= 1000000) return scaled(count / 1000000, 'M');
  if (count >= 1000) return scaled(count / 1000, 'k');
  return '$count';
}
