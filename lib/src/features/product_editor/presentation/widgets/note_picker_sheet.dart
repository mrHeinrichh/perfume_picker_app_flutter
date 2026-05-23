part of '../../../../../main.dart';

class _NotePickerSheet extends StatefulWidget {
  const _NotePickerSheet({
    required this.title,
    required this.icon,
    required this.selectedNotes,
    required this.initialOptions,
  });

  final String title;
  final IconData icon;
  final Set<String> selectedNotes;
  final List<String> initialOptions;

  @override
  State<_NotePickerSheet> createState() => _NotePickerSheetState();
}

class _NotePickerSheetState extends State<_NotePickerSheet> {
  late final TextEditingController _searchController;
  late final Set<String> _selectedNotes;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selectedNotes = {...widget.selectedNotes};
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggle(String note) {
    setState(() {
      if (_selectedNotes.any((item) => _sameNoteLabel(item, note))) {
        _selectedNotes.removeWhere((item) => _sameNoteLabel(item, note));
      } else {
        _selectedNotes.add(note);
      }
    });
  }

  void _addSearchedNote() {
    final note = _cleanNoteLabel(_query);
    if (note.isEmpty) return;
    if (note.length > noteNameMaxLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notes can only be 20 characters long.')),
      );
      return;
    }

    final store = PerfumeScope.read(context);
    final added = store.addNote(note);
    if (!added) return;
    setState(() {
      _selectedNotes.add(note);
      _query = '';
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = PerfumeScope.watch(context);
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final options = _mergeNoteOptions([
      ...widget.initialOptions,
      ...store.noteOptions,
      ..._selectedNotes,
    ]);
    final visibleOptions = options
        .where((note) => note.toLowerCase().contains(_query.toLowerCase()))
        .toList(growable: false);
    final canAdd =
        _cleanNoteLabel(_query).isNotEmpty &&
        _cleanNoteLabel(_query).length <= noteNameMaxLength &&
        !options.any((note) => _sameNoteLabel(note, _query));

    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        initialChildSize: .78,
        minChildSize: .45,
        maxChildSize: .94,
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
                          Icon(widget.icon, color: theme.colorScheme.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Select ${widget.title.toLowerCase()}',
                              style: theme.textTheme.headlineMedium,
                            ),
                          ),
                          IconButton.filledTonal(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        key: ValueKey('note-search-${widget.title}'),
                        controller: _searchController,
                        maxLength: noteNameMaxLength,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
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
                      if (canAdd) ...[
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.tonalIcon(
                            onPressed: _addSearchedNote,
                            icon: const Icon(Icons.add_rounded),
                            label: Text('Add "$_query" to notes list'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  child: visibleOptions.isEmpty
                      ? Center(
                          child: Text(
                            'No notes found',
                            style: theme.textTheme.titleMedium,
                          ),
                        )
                      : ListView.separated(
                          controller: controller,
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                          itemCount: visibleOptions.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final note = visibleOptions[index];
                            final selected = _selectedNotes.any(
                              (item) => _sameNoteLabel(item, note),
                            );

                            return CheckboxListTile(
                              key: ValueKey('note-option-$note'),
                              value: selected,
                              onChanged: (_) => _toggle(note),
                              title: Text(note),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              tileColor: Colors.white,
                              activeColor: theme.colorScheme.primary,
                              checkboxShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            );
                          },
                        ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop(
                          _mergeNoteOptions(_selectedNotes.toList()).toSet(),
                        );
                      },
                      icon: const Icon(Icons.check_rounded),
                      label: Text('Use ${_selectedNotes.length} notes'),
                    ),
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
