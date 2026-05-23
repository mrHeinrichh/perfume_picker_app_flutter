part of '../../../../main.dart';

class NoteManagerSheet extends StatefulWidget {
  const NoteManagerSheet({super.key});

  @override
  State<NoteManagerSheet> createState() => _NoteManagerSheetState();
}

class _NoteManagerSheetState extends State<NoteManagerSheet> {
  late final TextEditingController _addController;
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _addController = TextEditingController();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _addController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _addNote() {
    final note = _cleanNoteLabel(_addController.text);
    if (note.isEmpty) return;
    if (note.length > noteNameMaxLength) {
      _showMessage('Notes can only be 20 characters long.');
      return;
    }

    final added = PerfumeScope.read(context).addNote(note);
    if (!added) {
      _showMessage('$note is already in the notes list.');
      return;
    }

    _addController.clear();
    _showMessage('$note added.');
  }

  Future<void> _renameNote(String note) async {
    final controller = TextEditingController(text: note);
    final nextNote = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename note'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: noteNameMaxLength,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            decoration: const InputDecoration(labelText: 'Note name'),
            textInputAction: TextInputAction.done,
            onSubmitted: (value) => Navigator.of(context).pop(value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (!mounted) return;
    if (nextNote == null) return;
    final cleaned = _cleanNoteLabel(nextNote);
    if (cleaned.isEmpty) return;
    if (cleaned.length > noteNameMaxLength) {
      _showMessage('Notes can only be 20 characters long.');
      return;
    }

    final renamed = PerfumeScope.read(context).renameNote(note, cleaned);
    if (!renamed) {
      _showMessage('Could not rename note. It may already exist.');
      return;
    }

    _showMessage('$note renamed to $cleaned.');
  }

  Future<void> _deleteNote(String note) async {
    final store = PerfumeScope.read(context);
    final usageCount = store.noteUsageCount(note);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete note?'),
          content: Text(
            usageCount == 0
                ? '$note will be removed from the selectable notes list.'
                : '$note is used by $usageCount product(s). Deleting it also removes it from those products.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    if (confirmed != true) return;
    store.deleteNote(note);
    _showMessage('$note deleted.');
  }

  @override
  Widget build(BuildContext context) {
    final store = PerfumeScope.watch(context);
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final visibleNotes = store.noteOptions
        .where((note) => note.toLowerCase().contains(_query.toLowerCase()))
        .toList(growable: false);

    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        initialChildSize: .86,
        minChildSize: .56,
        maxChildSize: .96,
        expand: false,
        builder: (context, controller) {
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFFFCF6),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: .16),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.edit_note_rounded,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Manage notes',
                              style: theme.textTheme.headlineMedium,
                            ),
                          ),
                          IconButton.filledTonal(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              key: const ValueKey('note-add-field'),
                              controller: _addController,
                              maxLength: noteNameMaxLength,
                              maxLengthEnforcement:
                                  MaxLengthEnforcement.enforced,
                              decoration: const InputDecoration(
                                labelText: 'Add a new note',
                                prefixIcon: Icon(Icons.add_rounded),
                              ),
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _addNote(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton.filled(
                            key: const ValueKey('note-add-button'),
                            tooltip: 'Add note',
                            onPressed: _addNote,
                            icon: const Icon(Icons.check_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        key: const ValueKey('note-manager-search'),
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Search notes',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _query.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Clear search',
                                  onPressed: () {
                                    setState(() {
                                      _query = '';
                                      _searchController.clear();
                                    });
                                  },
                                  icon: const Icon(Icons.close_rounded),
                                ),
                        ),
                        onChanged: (value) => setState(() => _query = value),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: visibleNotes.isEmpty
                      ? Center(
                          child: Text(
                            'No notes found',
                            style: theme.textTheme.titleMedium,
                          ),
                        )
                      : ListView.separated(
                          controller: controller,
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          itemCount: visibleNotes.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final note = visibleNotes[index];
                            final usageCount = store.noteUsageCount(note);

                            return ListTile(
                              key: ValueKey('managed-note-$note'),
                              tileColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: Text(note),
                              subtitle: Text(
                                usageCount == 0
                                    ? 'Not used yet'
                                    : 'Used by $usageCount product(s)',
                              ),
                              trailing: Wrap(
                                spacing: 4,
                                children: [
                                  IconButton(
                                    tooltip: 'Rename note',
                                    onPressed: () => _renameNote(note),
                                    icon: const Icon(Icons.edit_outlined),
                                  ),
                                  IconButton(
                                    tooltip: 'Delete note',
                                    onPressed: () => _deleteNote(note),
                                    icon: const Icon(Icons.delete_outline),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
