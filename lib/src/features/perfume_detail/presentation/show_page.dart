part of '../../../../main.dart';

class ShowPage extends StatelessWidget {
  const ShowPage({
    super.key,
    required this.productId,
    required this.selectedFilters,
  });

  final String productId;
  final Set<String> selectedFilters;

  @override
  Widget build(BuildContext context) {
    final store = PerfumeScope.watch(context);
    final auth = AuthScope.watch(context);
    final product = store.byId(productId);

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product removed')),
        body: const Center(child: Text('This product was deleted.')),
      );
    }

    final match = rankPerfumes(selectedFilters, [product]).first;
    final theme = Theme.of(context);
    final canManageProducts = auth.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          if (canManageProducts) ...[
            IconButton(
              tooltip: 'Edit product',
              onPressed: () => showProductEditor(context, product: product),
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'Delete product',
              onPressed: () async {
                final deleted = await confirmDeleteProduct(context, product);
                if (deleted && context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              icon: const Icon(Icons.delete_outline),
            ),
          ] else ...[
            IconButton(
              tooltip: 'Admin login',
              onPressed: () {
                showAdminLogin(context);
              },
              icon: const Icon(Icons.admin_panel_settings_outlined),
            ),
          ],
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
              children: [
                _AnimatedEntry(
                  delay: const Duration(milliseconds: 70),
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: const Color(0xFF17201D),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 660;
                        final image = ProductImage(
                          product: product,
                          size: isWide ? 220 : 190,
                          hero: true,
                        );

                        final details = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _Pill(
                                  icon: Icons.percent_rounded,
                                  label: '${match.matchPercentage}% match',
                                  foreground: const Color(0xFFFFE7D7),
                                  background: Colors.white.withValues(
                                    alpha: .1,
                                  ),
                                ),
                                _Pill(
                                  icon: Icons.wc_outlined,
                                  label: product.gender,
                                  foreground: const Color(0xFFCFF3E8),
                                  background: Colors.white.withValues(
                                    alpha: .1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Text(
                              product.name,
                              style: theme.textTheme.headlineLarge?.copyWith(
                                color: Colors.white,
                                letterSpacing: 0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product.fragranceCharacteristics.join(' / '),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: product.glow,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              product.description,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withValues(alpha: .78),
                              ),
                            ),
                          ],
                        );

                        if (isWide) {
                          return Row(
                            children: [
                              image,
                              const SizedBox(width: 24),
                              Expanded(child: details),
                            ],
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(child: image),
                            const SizedBox(height: 24),
                            details,
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _DetailGrid(product: product, match: match),
                const SizedBox(height: 18),
                _NotePyramidSection(product: product),
                const SizedBox(height: 14),
                _DetailSection(
                  title: 'Matched filters',
                  icon: Icons.check_circle_outline_rounded,
                  children: match.matchedTags.isEmpty
                      ? [
                          const _MiniChip(
                            label: 'No filters selected',
                            background: Color(0xFFEFEAE1),
                            foreground: Color(0xFF5A5146),
                          ),
                        ]
                      : match.matchedTags
                            .map(
                              (tag) => _MiniChip(
                                label: tag,
                                background: product.accent.withValues(
                                  alpha: .12,
                                ),
                                foreground: product.accent,
                              ),
                            )
                            .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
