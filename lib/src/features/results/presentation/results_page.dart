part of '../../../../main.dart';

class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key, required this.selectedFilters});

  final Set<String> selectedFilters;

  @override
  Widget build(BuildContext context) {
    final store = PerfumeScope.watch(context);
    final auth = AuthScope.watch(context);
    final matches = rankPerfumes(selectedFilters, store.products);
    final canManageProducts = auth.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
        actions: [
          if (canManageProducts) ...[
            IconButton(
              tooltip: 'Add product',
              onPressed: () => showProductEditor(context),
              icon: const Icon(Icons.add_rounded),
            ),
            IconButton(
              tooltip: 'Reset products',
              onPressed: () => PerfumeScope.read(context).reset(),
              icon: const Icon(Icons.restart_alt_rounded),
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
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              child: matches.isEmpty
                  ? const _EmptyProducts()
                  : ListView.separated(
                      key: ValueKey(store.products.length),
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 88),
                      itemCount: matches.length + 1,
                      separatorBuilder: (_, index) =>
                          SizedBox(height: index == 0 ? 14 : 12),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _ResultsSummary(
                            selectedFilters: selectedFilters,
                            topMatch: matches.first,
                            productCount: store.products.length,
                          );
                        }

                        final match = matches[index - 1];
                        return _AnimatedEntry(
                          delay: Duration(milliseconds: 80 + index * 45),
                          child: _ResultCard(
                            key: ValueKey('result-${match.perfume.id}'),
                            match: match,
                            canManageProducts: canManageProducts,
                            onTap: () => Navigator.of(context).push(
                              _softRoute(
                                ShowPage(
                                  productId: match.perfume.id,
                                  selectedFilters: selectedFilters,
                                ),
                              ),
                            ),
                            onEdit: () => showProductEditor(
                              context,
                              product: match.perfume,
                            ),
                            onDelete: () =>
                                confirmDeleteProduct(context, match.perfume),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
      floatingActionButton: canManageProducts
          ? FloatingActionButton.extended(
              onPressed: () => showProductEditor(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Product'),
            )
          : null,
    );
  }
}
