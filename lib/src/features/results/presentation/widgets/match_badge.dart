part of '../../../../../main.dart';

class _MatchBadge extends StatelessWidget {
  const _MatchBadge({required this.match});

  final PerfumeMatch match;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = match.perfume;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: match.matchPercentage / 100),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Container(
          width: 72,
          height: 46,
          decoration: BoxDecoration(
            color: product.accent.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              '${(value * 100).round()}%',
              style: theme.textTheme.titleMedium?.copyWith(
                color: product.accent,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        );
      },
    );
  }
}
