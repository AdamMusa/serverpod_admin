import 'package:flutter/material.dart';
import 'package:serverpod_admin_dashboard/src/helpers/admin_resources.dart';
import 'package:serverpod_admin_dashboard/src/helpers/filters.dart';

/// Asks which column to set on the selected rows, and to what. Returns
/// {column: value} as the edit form would send it, or null when cancelled.
Future<Map<String, String>?> showSetFieldDialog(
  BuildContext context, {
  required AdminResource resource,
  required int count,
}) {
  return showDialog<Map<String, String>>(
    context: context,
    builder: (_) => _SetFieldDialog(resource: resource, count: count),
  );
}

class _SetFieldDialog extends StatefulWidget {
  const _SetFieldDialog({required this.resource, required this.count});

  final AdminResource resource;
  final int count;

  @override
  State<_SetFieldDialog> createState() => _SetFieldDialogState();
}

class _SetFieldDialogState extends State<_SetFieldDialog> {
  late final List<AdminColumn> _columns = [
    for (final column in widget.resource.columns)
      if (!column.isPrimary) column,
  ];
  late AdminColumn _column = _columns.firstWhere(
    (c) => filterKindOf(c) == FilterValueKind.enumeration,
    orElse: () => _columns.first,
  );
  final _text = TextEditingController();
  String _value = '';

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kind = filterKindOf(_column);
    final options = switch (kind) {
      FilterValueKind.enumeration => _column.enumValues!,
      FilterValueKind.boolean => const ['true', 'false'],
      _ => null,
    };
    return AlertDialog(
      title: Text(
        'Change ${widget.count} ${widget.count == 1 ? 'row' : 'rows'}',
      ),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<AdminColumn>(
              initialValue: _column,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Column',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final column in _columns)
                  DropdownMenuItem(value: column, child: Text(column.name)),
              ],
              onChanged: (column) => setState(() {
                if (column == null) return;
                _column = column;
                _value = '';
                _text.clear();
              }),
            ),
            const SizedBox(height: 16),
            if (options != null)
              DropdownButtonFormField<String>(
                key: ValueKey(_column.name),
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'New value',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final option in options)
                    DropdownMenuItem(value: option, child: Text(option)),
                ],
                onChanged: (value) => setState(() => _value = value ?? ''),
              )
            else
              TextField(
                controller: _text,
                decoration: InputDecoration(
                  labelText: 'New value',
                  helperText: switch (kind) {
                    FilterValueKind.date => 'For example 2026-10-14T09:30:00Z',
                    FilterValueKind.list => 'JSON, for example ["a", "b"]',
                    _ =>
                      _column.isNullable == true
                          ? 'Leave empty to clear the value'
                          : null,
                  },
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => _value = value),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: options != null && _value.isEmpty
              ? null
              : () => Navigator.of(context).pop({_column.name: _value}),
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
