part of '../../../../../main.dart';

class _ResultsSummary extends StatelessWidget {
  const _ResultsSummary({
    required this.selectedFilters,
    required this.topMatch,
    required this.productCount,
  });

  final Set<String> selectedFilters;
  final PerfumeMatch topMatch;
  final int productCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasFilters = selectedFilters.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF17201D),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Pill(
                icon: Icons.sort_rounded,
                label: hasFilters
                    ? 'Highest filter matches first'
                    : 'Perfume catalogue',
                foreground: const Color(0xFFFFE7D7),
                background: Colors.white.withValues(alpha: .1),
              ),
              _Pill(
                icon: Icons.inventory_2_outlined,
                label: '$productCount products',
                foreground: const Color(0xFFCFF3E8),
                background: Colors.white.withValues(alpha: .1),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters
                ? 'Best match: ${topMatch.perfume.name}'
                : 'Browse real hard-coded perfumes',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            hasFilters
                ? '${topMatch.matchPercentage}% match from ${topMatch.score} of ${topMatch.totalFilters} selected filters.'
                : 'Each card includes image, gender category, fragrance characteristics, top notes, middle notes, base notes, and match percentage.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: .76),
            ),
          ),
          if (hasFilters) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedFilters
                  .map(
                    (filter) => _MiniChip(
                      label: filter,
                      background: Colors.white.withValues(alpha: .1),
                      foreground: Colors.white,
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
