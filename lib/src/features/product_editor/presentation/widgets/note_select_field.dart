part of '../../../../../main.dart';

class _NoteSelectField extends StatelessWidget {
  const _NoteSelectField({
    required this.title,
    required this.icon,
    required this.selectedNotes,
    required this.options,
    required this.onChanged,
  });

  final String title;
  final IconData icon;
  final Set<String> selectedNotes;
  final List<String> options;
  final ValueChanged<Set<String>> onChanged;

  Future<void> _openPicker(BuildContext context) async {
    final notes = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NotePickerSheet(
        title: title,
        icon: icon,
        selectedNotes: selectedNotes,
        initialOptions: options,
      ),
    );

    if (notes != null) onChanged(notes);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSelection = selectedNotes.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: ValueKey('note-select-$title'),
        borderRadius: BorderRadius.circular(20),
        onTap: () => _openPicker(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD8D0C4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: theme.colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(title, style: theme.textTheme.titleMedium),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.black.withValues(alpha: .56),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (hasSelection)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: selectedNotes
                      .map(
                        (note) => _MiniChip(
                          label: note,
                          background: const Color(0xFFEAF3EE),
                          foreground: theme.colorScheme.primary,
                        ),
                      )
                      .toList(growable: false),
                )
              else
                Text(
                  'Search and select notes',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black.withValues(alpha: .56),
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
