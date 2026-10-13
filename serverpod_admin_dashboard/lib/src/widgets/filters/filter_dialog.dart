import 'package:flutter/material.dart';
import 'package:serverpod_admin_client/serverpod_admin_client.dart';
import 'package:serverpod_admin_dashboard/src/helpers/filters.dart';

/// Edits [current] filters of [resource]; returns the new filters, or null
/// when cancelled.
Future<List<AdminFilter>?> showFilterDialog(
  BuildContext context, {
  required AdminResource resource,
  required List<AdminFilter> current,
}) {
  return showDialog<List<AdminFilter>>(
    context: context,
    builder: (_) => FilterDialog(resource: resource, current: current),
  );
}

class FilterDialog extends StatefulWidget {
  const FilterDialog({
    required this.resource,
    required this.current,
    super.key,
  });

  final AdminResource resource;
  final List<AdminFilter> current;

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _Draft {
  _Draft(this.column, this.operator, [this.value = '']);

  AdminColumn column;
  AdminFilterOperator operator;
  String value;
  late final text = TextEditingController(text: value);

  FilterValueKind get kind => filterKindOf(column);

  bool get complete => !needsValue(operator) || value.trim().isNotEmpty;

  AdminFilter toFilter() => AdminFilter(
    column: column.name,
    comparison: operator,
    value: needsValue(operator) ? value.trim() : null,
  );
}

class _FilterDialogState extends State<FilterDialog> {
  late final List<_Draft> _drafts = [
    for (final filter in widget.current)
      if (_column(filter.column) case final column?)
        _Draft(column, filter.comparison, filter.value ?? ''),
  ];

  List<AdminColumn> get _columns => widget.resource.columns;

  AdminColumn? _column(String name) =>
      _columns.where((c) => c.name == name).firstOrNull;

  @override
  void initState() {
    super.initState();
    if (_drafts.isEmpty) _add();
  }

  @override
  void dispose() {
    for (final draft in _drafts) {
      draft.text.dispose();
    }
    super.dispose();
  }

  void _add() {
    final column = _columns.firstWhere(
      (c) => !c.isPrimary,
      orElse: () => _columns.first,
    );
    _drafts.add(_Draft(column, operatorsFor(filterKindOf(column)).first));
  }

  void _setColumn(_Draft draft, AdminColumn column) {
    setState(() {
      draft
        ..column = column
        ..operator = operatorsFor(filterKindOf(column)).first
        ..value = '';
      draft.text.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final complete = _drafts.where((d) => d.complete).toList();
    return AlertDialog(
      title: Text('Filter ${widget.resource.tableName}'),
      content: SizedBox(
        width: 720,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final draft in _drafts) _row(context, draft),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => setState(_add),
                icon: const Icon(Icons.add),
                label: const Text('Add filter'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(<AdminFilter>[]),
          child: const Text('Clear all'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(
            context,
          ).pop([for (final draft in complete) draft.toFilter()]),
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Widget _row(BuildContext context, _Draft draft) {
    final operators = operatorsFor(draft.kind);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<AdminColumn>(
              initialValue: draft.column,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Column',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              items: [
                for (final column in _columns)
                  DropdownMenuItem(value: column, child: Text(column.name)),
              ],
              onChanged: (column) {
                if (column != null) _setColumn(draft, column);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<AdminFilterOperator>(
              key: ValueKey('${draft.column.name}-operator'),
              initialValue: draft.operator,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Condition',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              items: [
                for (final operator in operators)
                  DropdownMenuItem(
                    value: operator,
                    child: Text(operatorLabel(operator, draft.kind)),
                  ),
              ],
              onChanged: (operator) {
                if (operator != null) {
                  setState(() => draft.operator = operator);
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: needsValue(draft.operator)
                ? _value(context, draft)
                : const SizedBox.shrink(),
          ),
          IconButton(
            tooltip: 'Remove filter',
            icon: const Icon(Icons.close),
            onPressed: () => setState(() {
              _drafts.remove(draft);
              draft.text.dispose();
            }),
          ),
        ],
      ),
    );
  }

  Widget _value(BuildContext context, _Draft draft) {
    const decoration = InputDecoration(
      labelText: 'Value',
      isDense: true,
      border: OutlineInputBorder(),
    );
    final options = switch (draft.kind) {
      FilterValueKind.enumeration => draft.column.enumValues!,
      FilterValueKind.boolean => const ['true', 'false'],
      _ => null,
    };
    if (options != null) {
      return DropdownButtonFormField<String>(
        key: ValueKey('${draft.column.name}-value'),
        initialValue: options.contains(draft.value) ? draft.value : null,
        isExpanded: true,
        decoration: decoration,
        items: [
          for (final option in options)
            DropdownMenuItem(value: option, child: Text(option)),
        ],
        onChanged: (value) => setState(() => draft.value = value ?? ''),
      );
    }
    if (draft.kind == FilterValueKind.date) {
      return OutlinedButton.icon(
        icon: const Icon(Icons.calendar_today_outlined, size: 18),
        label: Text(draft.value.isEmpty ? 'Pick a date' : draft.value),
        onPressed: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.tryParse(draft.value) ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (picked == null) return;
          setState(
            () => draft.value = picked.toIso8601String().substring(0, 10),
          );
        },
      );
    }
    return TextField(
      controller: draft.text,
      decoration: decoration,
      keyboardType: draft.kind == FilterValueKind.number
          ? const TextInputType.numberWithOptions(decimal: true, signed: true)
          : TextInputType.text,
      onChanged: (value) => setState(() => draft.value = value),
    );
  }
}
