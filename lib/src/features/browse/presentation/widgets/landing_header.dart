part of '../../../../../main.dart';

class _LandingHeader extends StatelessWidget {
  const _LandingHeader({
    required this.productCount,
    required this.selectedCount,
    required this.accountLabel,
    required this.onAdminLogin,
  });

  final int productCount;
  final int selectedCount;
  final String accountLabel;
  final VoidCallback? onAdminLogin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF17201D),
        borderRadius: BorderRadius.circular(30),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 680;

          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Pill(
                    icon: Icons.local_florist_outlined,
                    label: '$productCount real products',
                    foreground: const Color(0xFFFFE7D7),
                    background: Colors.white.withValues(alpha: .1),
                  ),
                  _Pill(
                    icon: Icons.percent_rounded,
                    label: selectedCount == 0
                        ? 'Match percentage ready'
                        : '$selectedCount filters active',
                    foreground: const Color(0xFFCFF3E8),
                    background: Colors.white.withValues(alpha: .1),
                  ),
                  _Pill(
                    icon: Icons.account_circle_outlined,
                    label: accountLabel,
                    foreground: const Color(0xFFEFE7FF),
                    background: Colors.white.withValues(alpha: .1),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Find your next signature scent.',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 38,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Browse as a normal user, then filter by gender category, fragrance characteristics, and notes.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: .76),
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  if (onAdminLogin != null)
                    FilledButton.tonalIcon(
                      key: const ValueKey('header-admin-login-button'),
                      onPressed: onAdminLogin,
                      icon: const Icon(Icons.fingerprint_rounded),
                      label: const Text('Admin login'),
                    ),
                ],
              ),
            ],
          );

          if (isWide) {
            return Row(
              children: [
                Expanded(flex: 3, child: copy),
                const SizedBox(width: 24),
                const Expanded(flex: 2, child: _BottleShowcase()),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              copy,
              const SizedBox(height: 22),
              const _BottleShowcase(),
            ],
          );
        },
      ),
    );
  }
}
