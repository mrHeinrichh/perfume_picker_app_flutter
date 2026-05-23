part of '../../../../../main.dart';

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.group,
    required this.selectedFilters,
    required this.onSelected,
  });

  final FilterGroup group;
  final Set<String> selectedFilters;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withValues(alpha: .07)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(group.icon, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Text(group.title, style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: group.options.map((option) {
                final selected = selectedFilters.contains(option);
                final foregroundColor = selected
                    ? Colors.white
                    : const Color(0xFF17201D);
                final backgroundColor = selected
                    ? theme.colorScheme.primary
                    : Colors.white;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  child: FilterChip(
                    key: ValueKey('filter-$option'),
                    selected: selected,
                    showCheckmark: false,
                    avatar: selected
                        ? Icon(
                            Icons.check_rounded,
                            size: 18,
                            color: foregroundColor,
                          )
                        : null,
                    label: Text(option),
                    labelStyle: TextStyle(
                      color: foregroundColor,
                      fontWeight: FontWeight.w900,
                    ),
                    onSelected: (_) => onSelected(option),
                    selectedColor: backgroundColor,
                    backgroundColor: backgroundColor,
                    side: BorderSide(
                      color: selected
                          ? theme.colorScheme.primary
                          : const Color(0xFFD8D0C4),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
