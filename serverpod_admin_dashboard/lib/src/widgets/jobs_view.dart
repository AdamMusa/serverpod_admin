import 'package:flutter/material.dart';
import 'package:serverpod_admin_dashboard/src/controller/pagination.dart';
import 'package:serverpod_admin_dashboard/src/helpers/admin_resources.dart';
import 'package:serverpod_admin_dashboard/src/widgets/pagination_controls.dart';

const serverpodJobsResourceKey = 'serverpod_future_call';

class JobsView extends StatefulWidget {
  const JobsView({
    required this.resource,
    required this.records,
    this.historyRecords = const [],
    required this.isLoading,
    required this.errorMessage,
    required this.onView,
    required this.onEdit,
    required this.onDiscard,
    this.onRunNow,
    this.onPause,
    this.onResume,
    super.key,
  });

  final AdminResource resource;
  final List<Map<String, String>> records;
  final List<Map<String, String>> historyRecords;
  final bool isLoading;
  final String? errorMessage;
  final void Function(Map<String, String> record)? onView;
  final void Function(Map<String, String> record)? onEdit;
  final void Function(Map<String, String> record)? onDiscard;
  final void Function(Map<String, String> record)? onRunNow;
  final void Function(Map<String, String> record)? onPause;
  final void Function(Map<String, String> record)? onResume;

  @override
  State<JobsView> createState() => _JobsViewState();
}

class _JobsViewState extends State<JobsView> with TickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 6,
    vsync: this,
  );
  late final PaginationController _paginationController = PaginationController(
    rowsPerPage: 10,
    rowsPerPageOptions: const [5, 10, 25, 50],
  );
  final TextEditingController _jobFilterController = TextEditingController();
  final TextEditingController _serverFilterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _paginationController.setTotalRecords(_visibleRecords.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _paginationController.dispose();
    _jobFilterController.dispose();
    _serverFilterController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant JobsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateVisibleRecordCount();
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
    final paused = _pausedRecords.length;
    final failed = _failedRecords.length;
    final finished = _finishedRecords.length;

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
            onTap: (_) {
              _resetPagination();
              setState(() {});
            },
            tabs: [
              Tab(text: 'Scheduled jobs ($scheduled)'),
              Tab(text: 'Ready jobs ($due)'),
              Tab(text: 'Paused jobs ($paused)'),
              Tab(text: 'Failed jobs ($failed)'),
              Tab(text: 'Finished jobs ($finished)'),
              Tab(text: 'All jobs (${_allRecords.length})'),
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
        onChanged: (_) {
          _resetPagination();
          setState(() {});
        },
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

    return ListenableBuilder(
      listenable: _paginationController,
      builder: (context, _) {
        final pagedRecords = _paginationController.getPageItems(records);

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
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
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Server')),
                          DataColumn(label: Text('Scheduled')),
                          DataColumn(label: Text('Identifier')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: pagedRecords.map(_buildRow).toList(),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              PaginationControls(
                currentPage: _paginationController.currentPage,
                totalPages: _paginationController.totalPages,
                startRecord: _paginationController.startRecord,
                endRecord: _paginationController.endRecord,
                totalRecords: _paginationController.totalRecords,
                rowsPerPage: _paginationController.rowsPerPage,
                rowsPerPageOptions: _paginationController.rowsPerPageOptions,
                onRowsPerPageChanged: (value) {
                  _paginationController.setRowsPerPage(value ?? 10);
                },
                onPrevious: _paginationController.goToPreviousPage,
                onNext: _paginationController.goToNextPage,
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateVisibleRecordCount() {
    _paginationController.setTotalRecords(_visibleRecords.length);
  }

  void _resetPagination() {
    _paginationController.reset();
    _updateVisibleRecordCount();
  }

  DataRow _buildRow(Map<String, String> record) {
    final theme = Theme.of(context);
    final name = record['name'] ?? '';
    final serverId = record['serverId'] ?? '';
    final identifier = record['identifier'] ?? '';
    final state = _jobState(record);
    final isHistory = _isHistory(record);

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
                  isHistory ? _historySubtitle(record) : _statusLabel(record),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
        DataCell(_StatusChip(state: state)),
        DataCell(Text(serverId)),
        DataCell(
            Text(isHistory ? _finishedLabel(record) : _scheduledLabel(record))),
        DataCell(Text(identifier.isEmpty ? '-' : identifier)),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isHistory)
                TextButton.icon(
                  onPressed: widget.onView == null
                      ? null
                      : () => widget.onView!(record),
                  icon: const Icon(Icons.receipt_long_outlined),
                  label: const Text('Details'),
                )
              else if (state == _JobState.ready)
                const _PendingWorkerLabel()
              else if (state == _JobState.paused && widget.onResume != null)
                IconButton(
                  tooltip: 'Resume now',
                  icon: const Icon(Icons.play_circle_outline),
                  onPressed: () => widget.onResume!(record),
                )
              else if (widget.onRunNow != null)
                IconButton(
                  tooltip: 'Run now',
                  icon: const Icon(Icons.play_arrow_outlined),
                  onPressed: () => widget.onRunNow!(record),
                ),
              if (state == _JobState.scheduled && widget.onPause != null)
                IconButton(
                  tooltip: 'Pause job',
                  icon: const Icon(Icons.pause_circle_outline),
                  onPressed: () => widget.onPause!(record),
                ),
              if (state != _JobState.ready && widget.onEdit != null)
                IconButton(
                  tooltip: 'Reschedule job',
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
      return time == null || (time.isAfter(now) && !_isPaused(record));
    }).toList();
  }

  List<Map<String, String>> get _dueRecords {
    final now = DateTime.now().toUtc();
    return widget.records.where((record) {
      final time = DateTime.tryParse(record['time'] ?? '')?.toUtc();
      return time != null && !time.isAfter(now);
    }).toList();
  }

  List<Map<String, String>> get _pausedRecords {
    return widget.records.where(_isPaused).toList();
  }

  List<Map<String, String>> get _failedRecords {
    return widget.historyRecords
        .where((record) => record['status'] == 'failed')
        .toList();
  }

  List<Map<String, String>> get _finishedRecords {
    return widget.historyRecords
        .where((record) => record['status'] == 'finished')
        .toList();
  }

  List<Map<String, String>> get _allRecords {
    return [...widget.records, ...widget.historyRecords];
  }

  List<Map<String, String>> get _visibleRecords {
    final base = switch (_tabController.index) {
      0 => _scheduledRecords,
      1 => _dueRecords,
      2 => _pausedRecords,
      3 => _failedRecords,
      4 => _finishedRecords,
      _ => _allRecords,
    };

    final jobFilter = _jobFilterController.text.trim().toLowerCase();
    final serverFilter = _serverFilterController.text.trim().toLowerCase();

    return base.where((record) {
      final name = (record['name'] ?? '').toLowerCase();
      final serverId = (record['serverId'] ?? '').toLowerCase();
      final error = (record['error'] ?? '').toLowerCase();
      return (jobFilter.isEmpty || name.contains(jobFilter)) &&
          (serverFilter.isEmpty ||
              serverId.contains(serverFilter) ||
              error.contains(serverFilter));
    }).toList();
  }

  String _scheduledLabel(Map<String, String> record) {
    final time = DateTime.tryParse(record['time'] ?? '')?.toLocal();
    if (time == null) return '-';
    if (_isPaused(record)) return 'paused';

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
    if (_isPaused(record)) return 'Paused';

    final difference = time.difference(DateTime.now());
    if (difference.isNegative) return 'Waiting for worker';
    return 'Scheduled for ${time.toString()}';
  }

  bool _isPaused(Map<String, String> record) {
    final time = DateTime.tryParse(record['time'] ?? '')?.toUtc();
    return time != null && time.year >= _pausedYear;
  }

  _JobState _jobState(Map<String, String> record) {
    if (record['status'] == 'failed') return _JobState.failed;
    if (record['status'] == 'finished') return _JobState.finished;
    if (_isPaused(record)) return _JobState.paused;
    final time = DateTime.tryParse(record['time'] ?? '')?.toUtc();
    if (time == null) return _JobState.unknown;
    if (time.isAfter(DateTime.now().toUtc())) return _JobState.scheduled;
    return _JobState.ready;
  }

  bool _isHistory(Map<String, String> record) {
    return record['source'] == 'history';
  }

  String _historySubtitle(Map<String, String> record) {
    final error = record['error'];
    if (error != null && error.isNotEmpty) return error;
    final duration = double.tryParse(record['duration'] ?? '');
    if (duration == null) return 'Finished';
    return 'Finished in ${duration.toStringAsFixed(2)}s';
  }

  String _finishedLabel(Map<String, String> record) {
    final finishedAt = DateTime.tryParse(record['finishedAt'] ?? '')?.toLocal();
    if (finishedAt == null) return '-';
    final difference = DateTime.now().difference(finishedAt);
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'just now';
  }

  void _clearFilters() {
    _jobFilterController.clear();
    _serverFilterController.clear();
    _resetPagination();
    setState(() {});
  }
}

const _pausedYear = 9999;

enum _JobState { scheduled, ready, paused, finished, failed, unknown }

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.state});

  final _JobState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, icon, color) = switch (state) {
      _JobState.ready => (
          'Ready',
          Icons.bolt_outlined,
          theme.colorScheme.tertiary,
        ),
      _JobState.paused => (
          'Paused',
          Icons.pause_circle_outline,
          theme.colorScheme.secondary,
        ),
      _JobState.finished => (
          'Finished',
          Icons.check_circle_outline,
          Colors.green,
        ),
      _JobState.failed => (
          'Failed',
          Icons.error_outline,
          theme.colorScheme.error,
        ),
      _JobState.unknown => (
          'Unknown',
          Icons.help_outline,
          theme.colorScheme.outline,
        ),
      _JobState.scheduled => (
          'Scheduled',
          Icons.schedule_outlined,
          theme.colorScheme.primary,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingWorkerLabel extends StatelessWidget {
  const _PendingWorkerLabel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        'Waiting for worker',
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
