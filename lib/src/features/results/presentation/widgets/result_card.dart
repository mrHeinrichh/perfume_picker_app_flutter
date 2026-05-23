part of '../../../../../main.dart';

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    super.key,
    required this.match,
    required this.canManageProducts,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final PerfumeMatch match;
  final bool canManageProducts;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = match.perfume;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Ink(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Colors.black.withValues(alpha: .07)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 620;
              final image = ProductImage(
                product: product,
                size: compact ? 88 : 116,
              );

              final details = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              product.gender,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.black.withValues(alpha: .58),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _MatchBadge(match: match),
                      if (canManageProducts)
                        PopupMenuButton<_ProductAction>(
                          tooltip: 'Product actions',
                          onSelected: (action) {
                            switch (action) {
                              case _ProductAction.edit:
                                onEdit();
                              case _ProductAction.delete:
                                onDelete();
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: _ProductAction.edit,
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined),
                                  SizedBox(width: 10),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: _ProductAction.delete,
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline),
                                  SizedBox(width: 10),
                                  Text('Delete'),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    product.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black.withValues(alpha: .7),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MiniChip(
                        icon: Icons.wc_outlined,
                        label: product.gender,
                        background: const Color(0xFFFFF1C7),
                        foreground: const Color(0xFF6E4C00),
                      ),
                      ...product.fragranceCharacteristics
                          .take(4)
                          .map(
                            (characteristic) => _MiniChip(
                              label: characteristic,
                              background: product.accent.withValues(alpha: .1),
                              foreground: product.accent,
                            ),
                          ),
                      ...product.notes
                          .take(3)
                          .map(
                            (note) => _MiniChip(
                              label: note,
                              background: const Color(0xFFEAF3EE),
                              foreground: theme.colorScheme.primary,
                            ),
                          ),
                    ],
                  ),
                ],
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        image,
                        const SizedBox(width: 14),
                        Expanded(child: details),
                      ],
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  image,
                  const SizedBox(width: 16),
                  Expanded(child: details),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right_rounded),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
