import 'package:flutter/material.dart';

/// Asks for the name of a saved view, starting with [initial]; null when
/// cancelled.
Future<String?> showSaveViewDialog(
  BuildContext context, {
  required String title,
  String initial = '',
}) => showDialog<String>(
  context: context,
  builder: (context) => _SaveViewDialog(title: title, initial: initial),
);

class _SaveViewDialog extends StatefulWidget {
  const _SaveViewDialog({required this.title, required this.initial});

  final String title;
  final String initial;

  @override
  State<_SaveViewDialog> createState() => _SaveViewDialogState();
}

class _SaveViewDialogState extends State<_SaveViewDialog> {
  late final _name = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isNotEmpty) Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _name,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Name',
          helperText: 'Saving under an existing name replaces it.',
        ),
        onSubmitted: (_) => _save(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
