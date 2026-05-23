part of '../../../../main.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final Set<String> _selectedFilters = {};

  void _toggleFilter(String option) {
    setState(() {
      if (_selectedFilters.contains(option)) {
        _selectedFilters.remove(option);
      } else {
        _selectedFilters.add(option);
      }
    });
  }

  void _openResults() {
    Navigator.of(
      context,
    ).push(_softRoute(ResultsPage(selectedFilters: Set.of(_selectedFilters))));
  }

  void _setDummyDataEnabled(bool enabled) {
    final store = PerfumeScope.read(context);
    store.setDummyDataEnabled(enabled);
    _syncSelectedFiltersWithStore(store);
  }

  Future<void> _openNoteManager() async {
    await showNoteManager(context);
    if (!mounted) return;
    _syncSelectedFiltersWithStore();
  }

  Future<void> _openCharacteristicManager() async {
    await showCharacteristicManager(context);
    if (!mounted) return;
    _syncSelectedFiltersWithStore();
  }

  void _syncSelectedFiltersWithStore([PerfumeStore? perfumeStore]) {
    final store = perfumeStore ?? PerfumeScope.read(context);
    final validFilters = filterGroupsForCatalog(
      noteOptions: store.noteOptions,
      fragranceCharacteristics: store.fragranceCharacteristicOptions,
    ).expand((group) => group.options).toSet();
    final removedFilters = _selectedFilters
        .where((filter) => !validFilters.contains(filter))
        .toList(growable: false);

    if (removedFilters.isEmpty) return;
    setState(() => _selectedFilters.removeAll(removedFilters));
  }

  @override
  Widget build(BuildContext context) {
    final store = PerfumeScope.watch(context);
    final auth = AuthScope.watch(context);
    final theme = Theme.of(context);
    final groups = filterGroupsForCatalog(
      noteOptions: store.noteOptions,
      fragranceCharacteristics: store.fragranceCharacteristicOptions,
    );
    final canManageProducts = auth.isAdmin;
    final account = auth.currentAccount;
    final accountLabel = canManageProducts
        ? '${account?.username ?? AuthStore.adminUsername} (Admin)'
        : 'User mode';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                    child: _LandingHeader(
                      productCount: store.products.length,
                      selectedCount: _selectedFilters.length,
                      accountLabel: accountLabel,
                      onAdminLogin: canManageProducts
                          ? null
                          : () {
                              showAdminLogin(context);
                            },
                    ),
                  ),
                ),
                if (canManageProducts)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                      child: _AdminToolsPanel(
                        productCount: store.products.length,
                        noteCount: store.noteOptions.length,
                        characteristicCount:
                            store.fragranceCharacteristicOptions.length,
                        dummyDataEnabled: store.dummyDataEnabled,
                        onDummyDataChanged: _setDummyDataEnabled,
                        onAddProduct: () => showProductEditor(context),
                        onManageNotes: _openNoteManager,
                        onManageCharacteristics: _openCharacteristicManager,
                      ),
                    ),
                  ),
                SliverList.separated(
                  itemCount: groups.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    return Padding(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        index == 0 ? 8 : 0,
                        20,
                        index == groups.length - 1 ? 118 : 0,
                      ),
                      child: _AnimatedEntry(
                        delay: Duration(milliseconds: 90 + index * 55),
                        child: _FilterSection(
                          group: group,
                          selectedFilters: _selectedFilters,
                          onSelected: _toggleFilter,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: .94),
            border: Border(
              top: BorderSide(color: Colors.black.withValues(alpha: .07)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .08),
                blurRadius: 24,
                offset: const Offset(0, -12),
              ),
            ],
          ),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: Row(
                children: [
                  if (canManageProducts) ...[
                    IconButton.filledTonal(
                      key: const ValueKey('admin-logout-button'),
                      tooltip: 'Exit admin mode',
                      onPressed: auth.logout,
                      icon: const Icon(Icons.logout_rounded),
                    ),
                    const SizedBox(width: 10),
                  ] else ...[
                    IconButton.filledTonal(
                      key: const ValueKey('admin-login-button'),
                      tooltip: 'Admin login',
                      onPressed: () {
                        showAdminLogin(context);
                      },
                      icon: const Icon(Icons.admin_panel_settings_outlined),
                    ),
                    const SizedBox(width: 10),
                  ],
                  IconButton.filledTonal(
                    tooltip: 'Reset filters',
                    onPressed: _selectedFilters.isEmpty
                        ? null
                        : () => setState(_selectedFilters.clear),
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      key: const ValueKey('find-matches-button'),
                      onPressed: _openResults,
                      icon: const Icon(Icons.search_rounded),
                      label: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 240),
                        child: Text(
                          _selectedFilters.isEmpty
                              ? 'Browse ${store.products.length} perfumes'
                              : 'Find ${_selectedFilters.length} filter matches',
                          key: ValueKey(_selectedFilters.length),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
