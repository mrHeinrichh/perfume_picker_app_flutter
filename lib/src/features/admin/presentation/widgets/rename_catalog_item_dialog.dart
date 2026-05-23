part of '../../../../../main.dart';

class _RenameCatalogItemDialog extends StatefulWidget {
  const _RenameCatalogItemDialog({
    required this.title,
    required this.labelText,
    required this.initialValue,
    required this.maxLength,
  });

  final String title;
  final String labelText;
  final String initialValue;
  final int maxLength;

  @override
  State<_RenameCatalogItemDialog> createState() =>
      _RenameCatalogItemDialogState();
}

class _RenameCatalogItemDialogState extends State<_RenameCatalogItemDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.of(context).pop(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: widget.maxLength,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        decoration: InputDecoration(labelText: widget.labelText),
        textInputAction: TextInputAction.done,
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
