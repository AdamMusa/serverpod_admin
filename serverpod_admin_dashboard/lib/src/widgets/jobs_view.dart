import 'package:flutter/material.dart';
import 'package:serverpod_admin_dashboard/src/helpers/admin_resources.dart';

const serverpodJobsResourceKey = 'serverpod_future_call';

class JobsView extends StatefulWidget {
  const JobsView({
    required this.resource,
    required this.records,
    required this.isLoading,
    required this.errorMessage,
    required this.onView,
    required this.onEdit,
    required this.onDiscard,
    super.key,
  });

  final AdminResource resource;
  final List<Map<String, String>> records;
  final bool isLoading;
  final String? errorMessage;
  final void Function(Map<String, String> record)? onView;
  final void Function(Map<String, String> record)? onEdit;
  final void Function(Map<String, String> record)? onDiscard;

  @override
  State<JobsView> createState() => _JobsViewState();
}

class _JobsViewState extends State<JobsView> with TickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 3,
    vsync: this,
  );
  final TextEditingController _jobFilterController = TextEditingController();
  final TextEditingController _serverFilterController = TextEditingController();

  @override
  void dispose() {
    _tabController.dispose();
    _jobFilterController.dispose();
    _serverFilterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          const Divider(height: 1),
          Expanded(child: _buildContent(context)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final scheduled = _scheduledRecords.length;
    final due = _dueRecords.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 22, 28, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Serverpod jobs',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            onTap: (_) => setState(() {}),
            tabs: [
              Tab(text: 'Scheduled jobs ($scheduled)'),
              Tab(text: 'Due jobs ($due)'),
              Tab(text: 'All jobs (${widget.records.length})'),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildFilterField(
                controller: _jobFilterController,
                hintText: 'Filter by job name...',
                icon: Icons.work_outline,
              ),
              _buildFilterField(
                controller: _serverFilterController,
                hintText: 'Filter by server id...',
                icon: Icons.dns_outlined,
              ),
              OutlinedButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear),
                label: const Text('Clear'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return SizedBox(
      width: 280,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, size: 20),
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final errorMessage = widget.errorMessage;
    if (errorMessage != null) {
      return Center(child: Text(errorMessage));
    }

    final records = _visibleRecords;
    if (records.isEmpty) {
      return const Center(child: Text('No jobs found.'));
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: DataTable(
              columnSpacing: 48,
              horizontalMargin: 12,
              columns: const [
                DataColumn(label: Text('Job')),
                DataColumn(label: Text('Server')),
                DataColumn(label: Text('Scheduled')),
                DataColumn(label: Text('Identifier')),
                DataColumn(label: Text('Actions')),
              ],
              rows: records.map(_buildRow).toList(),
            ),
          ),
        ),
      ),
    );
  }

  DataRow _buildRow(Map<String, String> record) {
    final theme = Theme.of(context);
    final name = record['name'] ?? '';
    final serverId = record['serverId'] ?? '';
    final identifier = record['identifier'] ?? '';

    return DataRow(
      cells: [
        DataCell(
          InkWell(
            onTap: widget.onView == null ? null : () => widget.onView!(record),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _statusLabel(record),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
        DataCell(Text(serverId)),
        DataCell(Text(_scheduledLabel(record))),
        DataCell(Text(identifier.isEmpty ? '-' : identifier)),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.onEdit != null)
                IconButton(
                  tooltip: 'Update job',
                  icon: const Icon(Icons.edit_calendar_outlined),
                  onPressed: () => widget.onEdit!(record),
                ),
              if (widget.onDiscard != null)
                FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    backgroundColor:
                        theme.colorScheme.errorContainer.withValues(alpha: 0.4),
                  ),
                  onPressed: () => widget.onDiscard!(record),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Discard'),
                ),
            ],
          ),
        ),
      ],
    );
  }

  List<Map<String, String>> get _scheduledRecords {
    final now = DateTime.now().toUtc();
    return widget.records.where((record) {
      final time = DateTime.tryParse(record['time'] ?? '')?.toUtc();
      return time == null || time.isAfter(now);
    }).toList();
  }

  List<Map<String, String>> get _dueRecords {
    final now = DateTime.now().toUtc();
    return widget.records.where((record) {
      final time = DateTime.tryParse(record['time'] ?? '')?.toUtc();
      return time != null && !time.isAfter(now);
    }).toList();
  }

  List<Map<String, String>> get _visibleRecords {
    final base = switch (_tabController.index) {
      0 => _scheduledRecords,
      1 => _dueRecords,
      _ => widget.records,
    };

    final jobFilter = _jobFilterController.text.trim().toLowerCase();
    final serverFilter = _serverFilterController.text.trim().toLowerCase();

    return base.where((record) {
      final name = (record['name'] ?? '').toLowerCase();
      final serverId = (record['serverId'] ?? '').toLowerCase();
      return (jobFilter.isEmpty || name.contains(jobFilter)) &&
          (serverFilter.isEmpty || serverId.contains(serverFilter));
    }).toList();
  }

  String _scheduledLabel(Map<String, String> record) {
    final time = DateTime.tryParse(record['time'] ?? '')?.toLocal();
    if (time == null) return '-';

    final now = DateTime.now();
    final difference = time.difference(now);
    if (difference.inSeconds.abs() < 60) return 'now';
    if (difference.isNegative) return '${difference.inMinutes.abs()}m overdue';
    if (difference.inDays > 0) return 'in ${difference.inDays}d';
    if (difference.inHours > 0) return 'in ${difference.inHours}h';
    return 'in ${difference.inMinutes}m';
  }

  String _statusLabel(Map<String, String> record) {
    final time = DateTime.tryParse(record['time'] ?? '')?.toLocal();
    if (time == null) return 'No schedule time';

    final difference = time.difference(DateTime.now());
    if (difference.isNegative) return 'Due ${_scheduledLabel(record)}';
    return 'Scheduled for ${time.toString()}';
  }

  void _clearFilters() {
    _jobFilterController.clear();
    _serverFilterController.clear();
    setState(() {});
  }
}
