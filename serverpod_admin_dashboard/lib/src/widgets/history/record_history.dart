import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:serverpod_admin_client/serverpod_admin_client.dart';

/// Loads one page of change history.
typedef HistoryLoader = Future<AdminLogPage> Function(int offset, int limit);

/// The change history of a row, a resource or everything: who did what,
/// when, and which values changed.
class RecordHistory extends StatefulWidget {
  const RecordHistory({
    required this.load,
    this.showResource = false,
    this.pageSize = 20,
    this.emptyText = 'No changes have been made in the dashboard yet.',
    super.key,
  });

  final HistoryLoader load;

  /// Names the table of each entry (for the overview's recent actions).
  final bool showResource;
  final int pageSize;
  final String emptyText;

  @override
  State<RecordHistory> createState() => _RecordHistoryState();
}

class _RecordHistoryState extends State<RecordHistory> {
  final _entries = <AdminLogEntry>[];
  int _total = 0;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _more();
  }

  Future<void> _more() async {
    setState(() => _loading = true);
    try {
      final page = await widget.load(_entries.length, widget.pageSize);
      if (!mounted) return;
      setState(() {
        _entries.addAll(page.entries);
        _total = page.total;
        _error = null;
      });
    } catch (error) {
      if (mounted) setState(() => _error = 'Could not load the history.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_entries.isEmpty) {
      if (_loading) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          _error ?? widget.emptyText,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in _entries) _HistoryTile(entry, widget.showResource),
        if (_entries.length < _total)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: _loading ? null : _more,
              child: Text(_loading ? 'Loading…' : 'Show older changes'),
            ),
          ),
      ],
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile(this.entry, this.showResource);

  final AdminLogEntry entry;
  final bool showResource;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, verb, color) = switch (entry.action) {
      AdminLogAction.created => (
        Icons.add_circle_outline,
        'created',
        Colors.green,
      ),
      AdminLogAction.updated => (Icons.edit_outlined, 'changed', Colors.blue),
      AdminLogAction.deleted => (
        Icons.delete_outline,
        'deleted',
        theme.colorScheme.error,
      ),
      AdminLogAction.action => (
        Icons.bolt_outlined,
        'ran ${entry.summary ?? 'an action'} on',
        Colors.orange,
      ),
    };
    final who = entry.actorName ?? entry.actor;
    final what = showResource
        ? '${entry.resourceKey} #${entry.recordId}'
        : '#${entry.recordId}';
    final changes = _changes();
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Icon(icon, color: color),
      title: Text('$who $verb $what'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.createdAt.toLocal().toString().substring(0, 19),
            style: theme.textTheme.bodySmall,
          ),
          for (final line in changes)
            Text(
              line,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
        ],
      ),
    );
  }

  /// "status: pending → approved" for updates; "name = Awa" for rows.
  List<String> _changes() {
    try {
      final decoded = jsonDecode(entry.changes);
      if (decoded is! Map) return const [];
      String short(Object? value) {
        final text = '$value';
        return text.length > 80 ? '${text.substring(0, 80)}…' : text;
      }

      return [
        for (final MapEntry(:key, :value) in decoded.entries)
          if (value is List && value.length == 2)
            '$key: ${short(value[0]).isEmpty ? '∅' : short(value[0])} → '
                '${short(value[1]).isEmpty ? '∅' : short(value[1])}'
          else
            '$key = ${short(value)}',
      ];
    } catch (_) {
      return const [];
    }
  }
}
