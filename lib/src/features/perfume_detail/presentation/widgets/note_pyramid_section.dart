part of '../../../../../main.dart';

class _NotePyramidSection extends StatelessWidget {
  const _NotePyramidSection({required this.product});

  final PerfumeProduct product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withValues(alpha: .07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.blur_on_rounded, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Text('Notes', style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 14),
          _NoteTier(
            title: 'Top notes',
            icon: Icons.keyboard_double_arrow_up_rounded,
            notes: product.topNotes,
            background: const Color(0xFFFFE7D7),
            foreground: product.accent,
          ),
          const Divider(height: 24),
          _NoteTier(
            title: 'Mid notes',
            icon: Icons.local_florist_outlined,
            notes: product.middleNotes,
            background: product.glow.withValues(alpha: .28),
            foreground: product.accent,
          ),
          const Divider(height: 24),
          _NoteTier(
            title: 'Base notes',
            icon: Icons.layers_outlined,
            notes: product.baseNotes,
            background: const Color(0xFFEAF3EE),
            foreground: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

class _NoteTier extends StatelessWidget {
  const _NoteTier({
    required this.title,
    required this.icon,
    required this.notes,
    required this.background,
    required this.foreground,
  });

  final String title;
  final IconData icon;
  final List<String> notes;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: foreground),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: notes
              .map(
                (note) => _MiniChip(
                  label: note,
                  background: background,
                  foreground: foreground,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
