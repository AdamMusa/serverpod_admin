import 'package:flutter/material.dart';
import 'package:serverpod_admin_dashboard/src/controller/admin_dashboard.dart';
import 'package:serverpod_admin_dashboard/src/helpers/admin_resources.dart';
import 'package:serverpod_admin_dashboard/src/helpers/foreign_key_helper.dart';

/// Picks the related row of a foreign key by searching it, so large tables
/// are never loaded whole. Shows the current row by name.
class ForeignKeyDropdown extends StatefulWidget {
  const ForeignKeyDropdown({
    required this.column,
    required this.controller,
    required this.value,
    required this.onChanged,
    this.options = const [],
    super.key,
  });

  final AdminColumn column;
  final AdminDashboardController controller;

  /// Unused: rows are searched as the administrator types.
  final List<Map<String, String>> options;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  State<ForeignKeyDropdown> createState() => _ForeignKeyDropdownState();
}

class _ForeignKeyDropdownState extends State<ForeignKeyDropdown> {
  late final AdminResource? _related = ForeignKeyHelper.findRelatedResource(
    widget.controller,
    widget.column,
  );
  TextEditingController? _text;
  bool _edited = false;

  @override
  void initState() {
    super.initState();
    _showCurrent();
  }

  Future<void> _showCurrent() async {
    final related = _related;
    final value = widget.value;
    if (related == null || value == null || value.isEmpty) return;
    final labels = await widget.controller.labelsFor(related, [value]);
    final text = _text;
    if (!mounted || _edited || text == null) return;
    text.text = labels[value] ?? '#$value';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final related = _related;
    final decoration = InputDecoration(
      labelText: widget.column.isNullable == true
          ? '${widget.column.displayName} (optional)'
          : widget.column.displayName,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: theme.colorScheme.surfaceContainerHighest,
    );
    if (related == null) {
      return TextFormField(
        initialValue: widget.value,
        decoration: decoration.copyWith(
          helperText:
              'Related table ${widget.column.foreignKeyTable} is '
              'not registered; enter its id.',
        ),
        onChanged: (text) =>
            widget.onChanged(text.trim().isEmpty ? null : text.trim()),
      );
    }
    return Autocomplete<Map<String, String>>(
      displayStringForOption: (row) =>
          AdminDashboardController.recordLabel(related, row),
      optionsBuilder: (text) =>
          widget.controller.searchRecords(related, _query(text.text)),
      onSelected: (row) {
        _edited = true;
        widget.onChanged(
          widget.controller.resolvePrimaryKeyValue(related, row),
        );
      },
      fieldViewBuilder: (context, text, focusNode, onSubmitted) {
        if (_text == null) {
          _text = text;
          final value = widget.value;
          if (value != null && value.isNotEmpty) text.text = '#$value';
        }
        return TextFormField(
          controller: text,
          focusNode: focusNode,
          decoration: decoration.copyWith(
            hintText: 'Search ${related.displayName}',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              tooltip: 'Clear',
              icon: const Icon(Icons.clear),
              onPressed: () {
                _edited = true;
                text.clear();
                widget.onChanged(null);
              },
            ),
          ),
          onFieldSubmitted: (_) => onSubmitted(),
        );
      },
    );
  }

  /// "Awa Diallo (#12)" searches for "Awa Diallo".
  static String _query(String text) =>
      text.replaceAll(RegExp(r'\s*\(#[^)]*\)\s*$'), '').replaceFirst('#', '');
}
