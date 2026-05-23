import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'auth_store.dart';
import 'catalog.dart';
import 'models.dart';
import 'store.dart';

export 'catalog.dart'
    show
        defaultEditableFragranceCharacteristicOptions,
        defaultNoteOptions,
        defaultProducts,
        filterGroups,
        filterGroupsForCatalog,
        fragranceCharacteristicNameMaxLength,
        fragranceCharacteristicOptions,
        genderOptions,
        noteNameMaxLength;
export 'models.dart' show PerfumeMatch, PerfumeProduct, rankPerfumes;
export 'auth_store.dart' show AuthStore, UserRole;

void main() {
  runApp(const PerfumePickerApp());
}

class PerfumePickerApp extends StatefulWidget {
  const PerfumePickerApp({super.key});

  @override
  State<PerfumePickerApp> createState() => _PerfumePickerAppState();
}

class _PerfumePickerAppState extends State<PerfumePickerApp> {
  late final PerfumeStore _store;
  late final AuthStore _authStore;

  @override
  void initState() {
    super.initState();
    _store = PerfumeStore();
    _authStore = AuthStore()..load();
  }

  @override
  void dispose() {
    _authStore.dispose();
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScope(
      notifier: _authStore,
      child: PerfumeScope(
        notifier: _store,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Perfume Picker',
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF7F4ED),
            colorScheme:
                ColorScheme.fromSeed(
                  seedColor: const Color(0xFF2F6F64),
                  brightness: Brightness.light,
                ).copyWith(
                  primary: const Color(0xFF2F6F64),
                  secondary: const Color(0xFFE46D55),
                  tertiary: const Color(0xFF6C5A8A),
                  surface: const Color(0xFFFFFCF6),
                ),
            textTheme: const TextTheme(
              headlineLarge: TextStyle(
                fontWeight: FontWeight.w900,
                height: 1.02,
              ),
              headlineMedium: TextStyle(
                fontWeight: FontWeight.w900,
                height: 1.08,
              ),
              titleLarge: TextStyle(fontWeight: FontWeight.w900),
              titleMedium: TextStyle(fontWeight: FontWeight.w800),
              bodyLarge: TextStyle(height: 1.45),
              bodyMedium: TextStyle(height: 1.45),
            ),
            chipTheme: ChipThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              side: BorderSide(color: Colors.black.withValues(alpha: .08)),
              labelStyle: const TextStyle(fontWeight: FontWeight.w800),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            ),
            appBarTheme: const AppBarTheme(
              centerTitle: false,
              elevation: 0,
              backgroundColor: Color(0xFFF7F4ED),
              foregroundColor: Color(0xFF17201D),
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFFF6F0E8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 15,
              ),
            ),
          ),
          home: const AuthGate(),
        ),
      ),
    );
  }
}

class AuthScope extends InheritedNotifier<AuthStore> {
  const AuthScope({
    super.key,
    required AuthStore super.notifier,
    required super.child,
  });

  static AuthStore watch(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'No AuthScope found in context');
    return scope!.notifier!;
  }

  static AuthStore read(BuildContext context) {
    final element = context
        .getElementForInheritedWidgetOfExactType<AuthScope>();
    assert(element != null, 'No AuthScope found in context');
    final scope = element!.widget as AuthScope;
    return scope.notifier!;
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.watch(context);

    if (!auth.isReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return const LandingPage();
  }
}

class AdminLoginSheet extends StatefulWidget {
  const AdminLoginSheet({super.key});

  @override
  State<AdminLoginSheet> createState() => _AdminLoginSheetState();
}

class _AdminLoginSheetState extends State<AdminLoginSheet> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  var _submitting = false;
  var _biometricSubmitting = false;
  var _passwordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    final auth = AuthScope.read(context);
    final result = await auth.login(
      username: _usernameController.text,
      password: _passwordController.text,
      role: UserRole.admin,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));

    if (result.success) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _loginWithBiometrics() async {
    setState(() => _biometricSubmitting = true);
    final result = await AuthScope.read(context).loginWithBiometrics();

    if (!mounted) return;
    setState(() => _biometricSubmitting = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));

    if (result.success) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final busy = _submitting || _biometricSubmitting;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFFCF6),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: .16),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: .12,
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          Icons.admin_panel_settings_outlined,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Admin login',
                              style: theme.textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Browsing is open to everyone. Product management is admin only.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.black.withValues(alpha: .62),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton.filledTonal(
                        tooltip: 'Close',
                        onPressed: busy
                            ? null
                            : () => Navigator.of(context).pop(false),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCFF3E8),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: .2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.fingerprint_rounded,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Use the admin password, or skip typing with Face ID or biometrics.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    key: const ValueKey('admin-username'),
                    controller: _usernameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.account_circle_outlined),
                      labelText: 'Admin username',
                    ),
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Enter the admin username.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const ValueKey('admin-password'),
                    controller: _passwordController,
                    obscureText: !_passwordVisible,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) {
                      if (!busy) _submit();
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      labelText: 'Admin password',
                      suffixIcon: IconButton(
                        tooltip: _passwordVisible
                            ? 'Hide password'
                            : 'Show password',
                        onPressed: () {
                          setState(() => _passwordVisible = !_passwordVisible);
                        },
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if ((value ?? '').isEmpty) {
                        return 'Enter the admin password.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    key: const ValueKey('admin-submit-button'),
                    onPressed: busy ? null : _submit,
                    icon: _submitting
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.login_rounded),
                    label: const Text('Login as admin'),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.tonalIcon(
                    key: const ValueKey('admin-biometric-button'),
                    onPressed: busy ? null : _loginWithBiometrics,
                    icon: _biometricSubmitting
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.fingerprint_rounded),
                    label: const Text('Use biometrics shortcut'),
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

class PerfumeScope extends InheritedNotifier<PerfumeStore> {
  const PerfumeScope({
    super.key,
    required PerfumeStore super.notifier,
    required super.child,
  });

  static PerfumeStore watch(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PerfumeScope>();
    assert(scope != null, 'No PerfumeScope found in context');
    return scope!.notifier!;
  }

  static PerfumeStore read(BuildContext context) {
    final element = context
        .getElementForInheritedWidgetOfExactType<PerfumeScope>();
    assert(element != null, 'No PerfumeScope found in context');
    final scope = element!.widget as PerfumeScope;
    return scope.notifier!;
  }
}

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

class _AdminToolsPanel extends StatelessWidget {
  const _AdminToolsPanel({
    required this.productCount,
    required this.noteCount,
    required this.characteristicCount,
    required this.dummyDataEnabled,
    required this.onDummyDataChanged,
    required this.onAddProduct,
    required this.onManageNotes,
    required this.onManageCharacteristics,
  });

  final int productCount;
  final int noteCount;
  final int characteristicCount;
  final bool dummyDataEnabled;
  final ValueChanged<bool> onDummyDataChanged;
  final VoidCallback onAddProduct;
  final VoidCallback onManageNotes;
  final VoidCallback onManageCharacteristics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF17201D).withValues(alpha: .08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .035),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFF17201D),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.admin_panel_settings_outlined,
                  color: Color(0xFFCFF3E8),
                  size: 19,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Admin tools',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _MiniChip(
                icon: Icons.inventory_2_outlined,
                label: '$productCount products',
                foreground: theme.colorScheme.primary,
                background: theme.colorScheme.primary.withValues(alpha: .1),
              ),
              _MiniChip(
                icon: Icons.edit_note_rounded,
                label: '$noteCount notes',
                foreground: theme.colorScheme.secondary,
                background: theme.colorScheme.secondary.withValues(alpha: .12),
              ),
              _MiniChip(
                icon: Icons.auto_awesome_outlined,
                label: '$characteristicCount characteristics',
                foreground: const Color(0xFF6C5A8A),
                background: const Color(0xFFEFE7FF),
              ),
              _MiniSwitchChip(
                label: 'Dummy data',
                enabled: dummyDataEnabled,
                onChanged: onDummyDataChanged,
                foreground: const Color(0xFF2F6B5F),
                background: const Color(0xFFEAF3EE),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _AdminCommandChip(
                key: const ValueKey('admin-add-product-button'),
                onPressed: onAddProduct,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add product'),
              ),
              _AdminCommandChip(
                key: const ValueKey('admin-manage-notes-button'),
                onPressed: onManageNotes,
                icon: const Icon(Icons.edit_note_rounded),
                label: Text('Notes ($noteCount)'),
              ),
              _AdminCommandChip(
                key: const ValueKey('admin-manage-characteristics-button'),
                onPressed: onManageCharacteristics,
                icon: const Icon(Icons.auto_awesome_outlined),
                label: Text('Characteristics ($characteristicCount)'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminCommandChip extends StatelessWidget {
  const _AdminCommandChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final Widget icon;
  final Widget label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = theme.colorScheme.primary;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black.withValues(alpha: .08)),
          ),
          child: IconTheme(
            data: IconThemeData(color: foreground, size: 18),
            child: DefaultTextStyle(
              style: theme.textTheme.labelMedium!.copyWith(
                color: const Color(0xFF17201D),
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [icon, const SizedBox(width: 6), label],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottleShowcase extends StatelessWidget {
  const _BottleShowcase();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF3F7D72),
                    Color(0xFFE46D55),
                    Color(0xFF6C5A8A),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 850),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 18 * (1 - value)),
                  child: Transform.scale(scale: value, child: child),
                );
              },
              child: Container(
                width: 118,
                height: 136,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .88),
                  borderRadius: BorderRadius.circular(36),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .2),
                      blurRadius: 24,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF17201D).withValues(alpha: .92),
                    ),
                    child: const Icon(
                      Icons.spa_rounded,
                      color: Color(0xFFFFE7D7),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 18,
            child: Container(
              width: 52,
              height: 26,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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

class _DetailGrid extends StatelessWidget {
  const _DetailGrid({required this.product, required this.match});

  final PerfumeProduct product;
  final PerfumeMatch match;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 680 ? 4 : 2;

        return GridView.count(
          crossAxisCount: columns,
          childAspectRatio: columns == 4 ? 1.35 : 1.45,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _MetricTile(
              icon: Icons.percent_rounded,
              label: 'Match',
              value: '${match.matchPercentage}%',
            ),
            _MetricTile(
              icon: Icons.wc_outlined,
              label: 'Category',
              value: product.gender,
            ),
            _MetricTile(
              icon: Icons.auto_awesome_outlined,
              label: 'Characteristics',
              value: product.fragranceCharacteristics.join(', '),
            ),
            _MetricTile(
              icon: Icons.blur_on_rounded,
              label: 'Notes',
              value: '${product.notes.length} total',
            ),
          ],
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: .07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: theme.colorScheme.secondary),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.black.withValues(alpha: .52),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

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
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Text(title, style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, children: children),
        ],
      ),
    );
  }
}

class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.product,
    required this.size,
    this.hero = true,
  });

  final PerfumeProduct product;
  final double size;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    final imagePath = product.imageUrl.trim();
    final isNetworkImage =
        imagePath.startsWith('http://') || imagePath.startsWith('https://');
    final imageBytes = product.imageBytes;

    final image = SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * .92,
            height: size * .92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: product.glow.withValues(alpha: .28),
            ),
          ),
          if (imageBytes != null || imagePath.isNotEmpty)
            Container(
              width: size * .76,
              height: size * .76,
              padding: EdgeInsets.all(size * .06),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .92),
                borderRadius: BorderRadius.circular(size * .16),
                boxShadow: [
                  BoxShadow(
                    color: product.accent.withValues(alpha: .16),
                    blurRadius: size * .14,
                    offset: Offset(0, size * .05),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(size * .11),
                child: imageBytes != null
                    ? Image.memory(
                        imageBytes,
                        width: size * .64,
                        height: size * .64,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) =>
                            _BottleFallback(product: product, size: size),
                      )
                    : isNetworkImage
                    ? Image.network(
                        imagePath,
                        width: size * .64,
                        height: size * .64,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) =>
                            _BottleFallback(product: product, size: size),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return _BottleFallback(product: product, size: size);
                        },
                      )
                    : Image.asset(
                        imagePath,
                        width: size * .64,
                        height: size * .64,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) =>
                            _BottleFallback(product: product, size: size),
                      ),
              ),
            )
          else
            _BottleFallback(product: product, size: size),
        ],
      ),
    );

    if (!hero) return image;

    return Hero(tag: 'product-image-${product.id}', child: image);
  }
}

class _BottleFallback extends StatelessWidget {
  const _BottleFallback({required this.product, required this.size});

  final PerfumeProduct product;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: size * .13,
          child: Container(
            width: size * .28,
            height: size * .17,
            decoration: BoxDecoration(
              color: product.glow.withValues(alpha: .92),
              borderRadius: BorderRadius.circular(size * .06),
            ),
          ),
        ),
        Positioned(
          bottom: size * .1,
          child: Container(
            width: size * .58,
            height: size * .66,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size * .18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [product.glow.withValues(alpha: .96), product.accent],
              ),
              boxShadow: [
                BoxShadow(
                  color: product.accent.withValues(alpha: .26),
                  blurRadius: size * .17,
                  offset: Offset(0, size * .08),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: size * .3,
                height: size * .3,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .86),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.spa_rounded,
                  color: product.accent,
                  size: size * .17,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ProductEditorSheet extends StatefulWidget {
  const ProductEditorSheet({super.key, this.product});

  final PerfumeProduct? product;

  @override
  State<ProductEditorSheet> createState() => _ProductEditorSheetState();
}

class _ProductEditorSheetState extends State<ProductEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final Set<String> _fragranceCharacteristics;
  late final Set<String> _topNotes;
  late final Set<String> _middleNotes;
  late final Set<String> _baseNotes;
  late String _selectedGender;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameController = TextEditingController(text: product?.name ?? '');
    _descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    _imageBytes = product?.imageBytes;
    _selectedGender = product?.gender ?? genderOptions.first;
    _fragranceCharacteristics = {...?product?.fragranceCharacteristics};
    _topNotes = {...?product?.topNotes};
    _middleNotes = {...?product?.middleNotes};
    _baseNotes = {...?product?.baseNotes};
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_fragranceCharacteristics.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choose at least one fragrance characteristic.'),
        ),
      );
      return;
    }
    if (_topNotes.isEmpty || _middleNotes.isEmpty || _baseNotes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choose at least one note for top, mid, and base.'),
        ),
      );
      return;
    }

    final existing = widget.product;
    final name = _nameController.text.trim();
    final id = existing?.id ?? _createId(name);
    final accent = existing?.accent ?? stableAccentFor(name);
    final glow = existing?.glow ?? stableGlowFor(accent);

    Navigator.of(context).pop(
      PerfumeProduct(
        id: id,
        name: name,
        description: _descriptionController.text.trim(),
        imageUrl: existing?.imageUrl ?? '',
        imageBytes: _imageBytes,
        gender: _selectedGender,
        fragranceCharacteristics: _fragranceCharacteristics.toList()..sort(),
        topNotes: _topNotes.toList(growable: false),
        middleNotes: _middleNotes.toList(growable: false),
        baseNotes: _baseNotes.toList(growable: false),
        accent: accent,
        glow: glow,
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1400,
        maxHeight: 1400,
        imageQuality: 88,
      );

      if (pickedImage == null) return;

      final bytes = await pickedImage.readAsBytes();
      if (!mounted) return;

      setState(() => _imageBytes = bytes);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open gallery. Please try again.'),
        ),
      );
    }
  }

  void _removePickedImage() {
    setState(() => _imageBytes = null);
  }

  String _createId(String name) {
    final slug = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    return '$slug-${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = PerfumeScope.watch(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final editing = widget.product != null;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        initialChildSize: .92,
        minChildSize: .65,
        maxChildSize: .96,
        expand: false,
        builder: (context, controller) {
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFFFCF6),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Form(
              key: _formKey,
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: .16),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          editing ? 'Edit product' : 'Add product',
                          style: theme.textTheme.headlineMedium,
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _EditorTextField(
                    controller: _nameController,
                    label: 'Name',
                    icon: Icons.local_florist_outlined,
                    requiredField: true,
                  ),
                  const SizedBox(height: 12),
                  _EditorTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    icon: Icons.notes_outlined,
                    requiredField: true,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  _ImagePickerPanel(
                    product: widget.product,
                    imageBytes: _imageBytes,
                    onPickImage: _pickImage,
                    onRemoveImage: _imageBytes == null
                        ? null
                        : _removePickedImage,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Male / Female / Unisex',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  SegmentedButton<String>(
                    segments: genderOptions
                        .map(
                          (gender) => ButtonSegment<String>(
                            value: gender,
                            label: Text(gender),
                          ),
                        )
                        .toList(growable: false),
                    selected: {_selectedGender},
                    onSelectionChanged: (selection) {
                      setState(() => _selectedGender = selection.first);
                    },
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Fragrance characteristics',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: store.fragranceCharacteristicOptions.map((tag) {
                      final selected = _fragranceCharacteristics.contains(tag);
                      final foregroundColor = selected
                          ? Colors.white
                          : const Color(0xFF17201D);
                      final backgroundColor = selected
                          ? theme.colorScheme.primary
                          : Colors.white;

                      return FilterChip(
                        selected: selected,
                        showCheckmark: false,
                        avatar: selected
                            ? Icon(
                                Icons.check_rounded,
                                size: 18,
                                color: foregroundColor,
                              )
                            : null,
                        label: Text(tag),
                        labelStyle: TextStyle(
                          color: foregroundColor,
                          fontWeight: FontWeight.w900,
                        ),
                        selectedColor: backgroundColor,
                        backgroundColor: backgroundColor,
                        side: BorderSide(
                          color: selected
                              ? theme.colorScheme.primary
                              : const Color(0xFFD8D0C4),
                        ),
                        onSelected: (_) {
                          setState(() {
                            if (selected) {
                              _fragranceCharacteristics.remove(tag);
                            } else {
                              _fragranceCharacteristics.add(tag);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  _NoteSelectField(
                    title: 'Top notes',
                    icon: Icons.blur_on_rounded,
                    selectedNotes: _topNotes,
                    options: store.noteOptions,
                    onChanged: (notes) {
                      setState(() {
                        _topNotes
                          ..clear()
                          ..addAll(notes);
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _NoteSelectField(
                    title: 'Mid notes',
                    icon: Icons.local_florist_outlined,
                    selectedNotes: _middleNotes,
                    options: store.noteOptions,
                    onChanged: (notes) {
                      setState(() {
                        _middleNotes
                          ..clear()
                          ..addAll(notes);
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _NoteSelectField(
                    title: 'Base notes',
                    icon: Icons.layers_outlined,
                    selectedNotes: _baseNotes,
                    options: store.noteOptions,
                    onChanged: (notes) {
                      setState(() {
                        _baseNotes
                          ..clear()
                          ..addAll(notes);
                      });
                    },
                  ),
                  const SizedBox(height: 22),
                  FilledButton.icon(
                    onPressed: _save,
                    icon: Icon(
                      editing ? Icons.save_outlined : Icons.add_rounded,
                    ),
                    label: Text(editing ? 'Save changes' : 'Create product'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ImagePickerPanel extends StatelessWidget {
  const _ImagePickerPanel({
    required this.product,
    required this.imageBytes,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  final PerfumeProduct? product;
  final Uint8List? imageBytes;
  final VoidCallback onPickImage;
  final VoidCallback? onRemoveImage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPickedImage = imageBytes != null;
    final hasExistingImage = product?.imageUrl.trim().isNotEmpty ?? false;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD8D0C4)),
      ),
      child: Row(
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F4ED),
              borderRadius: BorderRadius.circular(18),
            ),
            clipBehavior: Clip.antiAlias,
            child: hasPickedImage
                ? Image.memory(
                    imageBytes!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        const Icon(Icons.image_not_supported_outlined),
                  )
                : hasExistingImage
                ? Center(
                    child: ProductImage(
                      product: product!,
                      size: 82,
                      hero: false,
                    ),
                  )
                : const Icon(Icons.add_photo_alternate_outlined, size: 34),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Product image', style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  hasPickedImage
                      ? 'Gallery photo selected'
                      : hasExistingImage
                      ? 'Current product photo'
                      : 'No photo selected',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black.withValues(alpha: .58),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: onPickImage,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text(hasPickedImage ? 'Change' : 'Gallery'),
                    ),
                    if (onRemoveImage != null)
                      IconButton.filledTonal(
                        tooltip: 'Remove selected image',
                        onPressed: onRemoveImage,
                        icon: const Icon(Icons.close_rounded),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditorTextField extends StatelessWidget {
  const _EditorTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.requiredField = false,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool requiredField;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: requiredField
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label is required';
              }
              return null;
            }
          : null,
    );
  }
}

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

class _NotePickerSheet extends StatefulWidget {
  const _NotePickerSheet({
    required this.title,
    required this.icon,
    required this.selectedNotes,
    required this.initialOptions,
  });

  final String title;
  final IconData icon;
  final Set<String> selectedNotes;
  final List<String> initialOptions;

  @override
  State<_NotePickerSheet> createState() => _NotePickerSheetState();
}

class _NotePickerSheetState extends State<_NotePickerSheet> {
  late final TextEditingController _searchController;
  late final Set<String> _selectedNotes;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selectedNotes = {...widget.selectedNotes};
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggle(String note) {
    setState(() {
      if (_selectedNotes.any((item) => _sameNoteLabel(item, note))) {
        _selectedNotes.removeWhere((item) => _sameNoteLabel(item, note));
      } else {
        _selectedNotes.add(note);
      }
    });
  }

  void _addSearchedNote() {
    final note = _cleanNoteLabel(_query);
    if (note.isEmpty) return;
    if (note.length > noteNameMaxLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notes can only be 20 characters long.')),
      );
      return;
    }

    final store = PerfumeScope.read(context);
    final added = store.addNote(note);
    if (!added) return;
    setState(() {
      _selectedNotes.add(note);
      _query = '';
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = PerfumeScope.watch(context);
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final options = _mergeNoteOptions([
      ...widget.initialOptions,
      ...store.noteOptions,
      ..._selectedNotes,
    ]);
    final visibleOptions = options
        .where((note) => note.toLowerCase().contains(_query.toLowerCase()))
        .toList(growable: false);
    final canAdd =
        _cleanNoteLabel(_query).isNotEmpty &&
        _cleanNoteLabel(_query).length <= noteNameMaxLength &&
        !options.any((note) => _sameNoteLabel(note, _query));

    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        initialChildSize: .78,
        minChildSize: .45,
        maxChildSize: .94,
        expand: false,
        builder: (context, controller) {
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFFFCF6),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: .16),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(widget.icon, color: theme.colorScheme.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Select ${widget.title.toLowerCase()}',
                              style: theme.textTheme.headlineMedium,
                            ),
                          ),
                          IconButton.filledTonal(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        key: ValueKey('note-search-${widget.title}'),
                        controller: _searchController,
                        maxLength: noteNameMaxLength,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        decoration: InputDecoration(
                          labelText: 'Search notes',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _query.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Clear search',
                                  onPressed: () {
                                    setState(() {
                                      _query = '';
                                      _searchController.clear();
                                    });
                                  },
                                  icon: const Icon(Icons.close_rounded),
                                ),
                        ),
                        onChanged: (value) => setState(() => _query = value),
                      ),
                      if (canAdd) ...[
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.tonalIcon(
                            onPressed: _addSearchedNote,
                            icon: const Icon(Icons.add_rounded),
                            label: Text('Add "$_query" to notes list'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  child: visibleOptions.isEmpty
                      ? Center(
                          child: Text(
                            'No notes found',
                            style: theme.textTheme.titleMedium,
                          ),
                        )
                      : ListView.separated(
                          controller: controller,
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                          itemCount: visibleOptions.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final note = visibleOptions[index];
                            final selected = _selectedNotes.any(
                              (item) => _sameNoteLabel(item, note),
                            );

                            return CheckboxListTile(
                              key: ValueKey('note-option-$note'),
                              value: selected,
                              onChanged: (_) => _toggle(note),
                              title: Text(note),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              tileColor: Colors.white,
                              activeColor: theme.colorScheme.primary,
                              checkboxShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            );
                          },
                        ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop(
                          _mergeNoteOptions(_selectedNotes.toList()).toSet(),
                        );
                      },
                      icon: const Icon(Icons.check_rounded),
                      label: Text('Use ${_selectedNotes.length} notes'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class NoteManagerSheet extends StatefulWidget {
  const NoteManagerSheet({super.key});

  @override
  State<NoteManagerSheet> createState() => _NoteManagerSheetState();
}

class _NoteManagerSheetState extends State<NoteManagerSheet> {
  late final TextEditingController _addController;
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _addController = TextEditingController();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _addController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _addNote() {
    final note = _cleanNoteLabel(_addController.text);
    if (note.isEmpty) return;
    if (note.length > noteNameMaxLength) {
      _showMessage('Notes can only be 20 characters long.');
      return;
    }

    final added = PerfumeScope.read(context).addNote(note);
    if (!added) {
      _showMessage('$note is already in the notes list.');
      return;
    }

    _addController.clear();
    _showMessage('$note added.');
  }

  Future<void> _renameNote(String note) async {
    final controller = TextEditingController(text: note);
    final nextNote = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename note'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: noteNameMaxLength,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            decoration: const InputDecoration(labelText: 'Note name'),
            textInputAction: TextInputAction.done,
            onSubmitted: (value) => Navigator.of(context).pop(value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (!mounted) return;
    if (nextNote == null) return;
    final cleaned = _cleanNoteLabel(nextNote);
    if (cleaned.isEmpty) return;
    if (cleaned.length > noteNameMaxLength) {
      _showMessage('Notes can only be 20 characters long.');
      return;
    }

    final renamed = PerfumeScope.read(context).renameNote(note, cleaned);
    if (!renamed) {
      _showMessage('Could not rename note. It may already exist.');
      return;
    }

    _showMessage('$note renamed to $cleaned.');
  }

  Future<void> _deleteNote(String note) async {
    final store = PerfumeScope.read(context);
    final usageCount = store.noteUsageCount(note);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete note?'),
          content: Text(
            usageCount == 0
                ? '$note will be removed from the selectable notes list.'
                : '$note is used by $usageCount product(s). Deleting it also removes it from those products.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    if (confirmed != true) return;
    store.deleteNote(note);
    _showMessage('$note deleted.');
  }

  @override
  Widget build(BuildContext context) {
    final store = PerfumeScope.watch(context);
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final visibleNotes = store.noteOptions
        .where((note) => note.toLowerCase().contains(_query.toLowerCase()))
        .toList(growable: false);

    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        initialChildSize: .86,
        minChildSize: .56,
        maxChildSize: .96,
        expand: false,
        builder: (context, controller) {
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFFFCF6),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: .16),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.edit_note_rounded,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Manage notes',
                              style: theme.textTheme.headlineMedium,
                            ),
                          ),
                          IconButton.filledTonal(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              key: const ValueKey('note-add-field'),
                              controller: _addController,
                              maxLength: noteNameMaxLength,
                              maxLengthEnforcement:
                                  MaxLengthEnforcement.enforced,
                              decoration: const InputDecoration(
                                labelText: 'Add a new note',
                                prefixIcon: Icon(Icons.add_rounded),
                              ),
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _addNote(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton.filled(
                            key: const ValueKey('note-add-button'),
                            tooltip: 'Add note',
                            onPressed: _addNote,
                            icon: const Icon(Icons.check_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        key: const ValueKey('note-manager-search'),
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Search notes',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _query.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Clear search',
                                  onPressed: () {
                                    setState(() {
                                      _query = '';
                                      _searchController.clear();
                                    });
                                  },
                                  icon: const Icon(Icons.close_rounded),
                                ),
                        ),
                        onChanged: (value) => setState(() => _query = value),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: visibleNotes.isEmpty
                      ? Center(
                          child: Text(
                            'No notes found',
                            style: theme.textTheme.titleMedium,
                          ),
                        )
                      : ListView.separated(
                          controller: controller,
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          itemCount: visibleNotes.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final note = visibleNotes[index];
                            final usageCount = store.noteUsageCount(note);

                            return ListTile(
                              key: ValueKey('managed-note-$note'),
                              tileColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: Text(note),
                              subtitle: Text(
                                usageCount == 0
                                    ? 'Not used yet'
                                    : 'Used by $usageCount product(s)',
                              ),
                              trailing: Wrap(
                                spacing: 4,
                                children: [
                                  IconButton(
                                    tooltip: 'Rename note',
                                    onPressed: () => _renameNote(note),
                                    icon: const Icon(Icons.edit_outlined),
                                  ),
                                  IconButton(
                                    tooltip: 'Delete note',
                                    onPressed: () => _deleteNote(note),
                                    icon: const Icon(Icons.delete_outline),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CharacteristicManagerSheet extends StatefulWidget {
  const CharacteristicManagerSheet({super.key});

  @override
  State<CharacteristicManagerSheet> createState() =>
      _CharacteristicManagerSheetState();
}

class _CharacteristicManagerSheetState
    extends State<CharacteristicManagerSheet> {
  late final TextEditingController _addController;
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _addController = TextEditingController();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _addController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _addCharacteristic() {
    final characteristic = _cleanCharacteristicLabel(_addController.text);
    if (characteristic.isEmpty) return;
    if (characteristic.length > fragranceCharacteristicNameMaxLength) {
      _showMessage('Characteristics can only be 24 characters long.');
      return;
    }

    final added = PerfumeScope.read(context).addCharacteristic(characteristic);
    if (!added) {
      _showMessage('$characteristic is already in the characteristics list.');
      return;
    }

    _addController.clear();
    _showMessage('$characteristic added.');
  }

  Future<void> _renameCharacteristic(String characteristic) async {
    final controller = TextEditingController(text: characteristic);
    final nextCharacteristic = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename characteristic'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: fragranceCharacteristicNameMaxLength,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            decoration: const InputDecoration(labelText: 'Characteristic name'),
            textInputAction: TextInputAction.done,
            onSubmitted: (value) => Navigator.of(context).pop(value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (!mounted) return;
    if (nextCharacteristic == null) return;
    final cleaned = _cleanCharacteristicLabel(nextCharacteristic);
    if (cleaned.isEmpty) return;
    if (cleaned.length > fragranceCharacteristicNameMaxLength) {
      _showMessage('Characteristics can only be 24 characters long.');
      return;
    }

    final renamed = PerfumeScope.read(
      context,
    ).renameCharacteristic(characteristic, cleaned);
    if (!renamed) {
      _showMessage('Could not rename characteristic. It may already exist.');
      return;
    }

    _showMessage('$characteristic renamed to $cleaned.');
  }

  Future<void> _deleteCharacteristic(String characteristic) async {
    final store = PerfumeScope.read(context);
    final usageCount = store.characteristicUsageCount(characteristic);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete characteristic?'),
          content: Text(
            usageCount == 0
                ? '$characteristic will be removed from the selectable characteristics list.'
                : '$characteristic is used by $usageCount product(s). Deleting it also removes it from those products.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    if (confirmed != true) return;
    store.deleteCharacteristic(characteristic);
    _showMessage('$characteristic deleted.');
  }

  @override
  Widget build(BuildContext context) {
    final store = PerfumeScope.watch(context);
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final visibleCharacteristics = store.fragranceCharacteristicOptions
        .where(
          (characteristic) =>
              characteristic.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList(growable: false);

    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        initialChildSize: .86,
        minChildSize: .56,
        maxChildSize: .96,
        expand: false,
        builder: (context, controller) {
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFFFCF6),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: .16),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.auto_awesome_outlined,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Manage characteristics',
                              style: theme.textTheme.headlineMedium,
                            ),
                          ),
                          IconButton.filledTonal(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              key: const ValueKey('characteristic-add-field'),
                              controller: _addController,
                              maxLength: fragranceCharacteristicNameMaxLength,
                              maxLengthEnforcement:
                                  MaxLengthEnforcement.enforced,
                              decoration: const InputDecoration(
                                labelText: 'Add a characteristic',
                                prefixIcon: Icon(Icons.add_rounded),
                              ),
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _addCharacteristic(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton.filled(
                            key: const ValueKey('characteristic-add-button'),
                            tooltip: 'Add characteristic',
                            onPressed: _addCharacteristic,
                            icon: const Icon(Icons.check_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        key: const ValueKey('characteristic-manager-search'),
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Search characteristics',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _query.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Clear search',
                                  onPressed: () {
                                    setState(() {
                                      _query = '';
                                      _searchController.clear();
                                    });
                                  },
                                  icon: const Icon(Icons.close_rounded),
                                ),
                        ),
                        onChanged: (value) => setState(() => _query = value),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: visibleCharacteristics.isEmpty
                      ? Center(
                          child: Text(
                            'No characteristics found',
                            style: theme.textTheme.titleMedium,
                          ),
                        )
                      : ListView.separated(
                          controller: controller,
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          itemCount: visibleCharacteristics.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final characteristic =
                                visibleCharacteristics[index];
                            final usageCount = store.characteristicUsageCount(
                              characteristic,
                            );

                            return ListTile(
                              key: ValueKey(
                                'managed-characteristic-$characteristic',
                              ),
                              tileColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: Text(characteristic),
                              subtitle: Text(
                                usageCount == 0
                                    ? 'Not used yet'
                                    : 'Used by $usageCount product(s)',
                              ),
                              trailing: Wrap(
                                spacing: 4,
                                children: [
                                  IconButton(
                                    tooltip: 'Rename characteristic',
                                    onPressed: () =>
                                        _renameCharacteristic(characteristic),
                                    icon: const Icon(Icons.edit_outlined),
                                  ),
                                  IconButton(
                                    tooltip: 'Delete characteristic',
                                    onPressed: () =>
                                        _deleteCharacteristic(characteristic),
                                    icon: const Icon(Icons.delete_outline),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

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

class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.label,
    required this.foreground,
    required this.background,
  });

  final IconData icon;
  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: foreground),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniSwitchChip extends StatelessWidget {
  const _MiniSwitchChip({
    required this.label,
    required this.enabled,
    required this.onChanged,
    required this.background,
    required this.foreground,
  });

  final String label;
  final bool enabled;
  final ValueChanged<bool> onChanged;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 4, 5, 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            enabled ? Icons.toggle_on_outlined : Icons.toggle_off_outlined,
            size: 15,
            color: foreground,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 40,
            height: 28,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Switch.adaptive(
                key: const ValueKey('admin-dummy-data-toggle'),
                value: enabled,
                onChanged: onChanged,
                activeThumbColor: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedEntry extends StatelessWidget {
  const _AnimatedEntry({required this.child, required this.delay});

  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 430 + delay.inMilliseconds),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _EmptyProducts extends StatelessWidget {
  const _EmptyProducts();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 54,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text('No products yet', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Add a perfume product to rebuild the list.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

enum _ProductAction { edit, delete }

String _cleanNoteLabel(String note) {
  return note.trim().replaceAll(RegExp(r'\s+'), ' ');
}

bool _sameNoteLabel(String a, String b) {
  return _cleanNoteLabel(a).toLowerCase() == _cleanNoteLabel(b).toLowerCase();
}

String _cleanCharacteristicLabel(String characteristic) {
  return characteristic.trim().replaceAll(RegExp(r'\s+'), ' ');
}

List<String> _mergeNoteOptions(List<String> notes) {
  final unique = <String>[];
  for (final note in notes.map(_cleanNoteLabel)) {
    if (note.isEmpty || unique.any((item) => _sameNoteLabel(item, note))) {
      continue;
    }
    unique.add(note);
  }
  return unique..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
}

Future<bool> showAdminLogin(BuildContext context) async {
  if (AuthScope.read(context).isAdmin) return true;

  final unlocked = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const AdminLoginSheet(),
  );

  return unlocked == true;
}

Future<void> showNoteManager(BuildContext context) async {
  if (!AuthScope.read(context).isAdmin) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Admin access is required.')));
    return;
  }

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const NoteManagerSheet(),
  );
}

Future<void> showCharacteristicManager(BuildContext context) async {
  if (!AuthScope.read(context).isAdmin) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Admin access is required.')));
    return;
  }

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const CharacteristicManagerSheet(),
  );
}

Future<void> showProductEditor(
  BuildContext context, {
  PerfumeProduct? product,
}) async {
  if (!AuthScope.read(context).isAdmin) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Admin access is required.')));
    return;
  }

  final store = PerfumeScope.read(context);
  final saved = await showModalBottomSheet<PerfumeProduct>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ProductEditorSheet(product: product),
  );

  if (saved == null) return;

  if (product == null) {
    store.add(saved);
  } else {
    store.update(saved);
  }
}

Future<bool> confirmDeleteProduct(
  BuildContext context,
  PerfumeProduct product,
) async {
  if (!AuthScope.read(context).isAdmin) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Admin access is required.')));
    return false;
  }

  final store = PerfumeScope.read(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Delete product?'),
        content: Text('${product.name} will be removed from this demo list.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );

  if (confirmed != true) return false;
  store.delete(product.id);
  return true;
}

Route<T> _softRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 340),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (_, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      final slide = Tween<Offset>(
        begin: const Offset(.04, .03),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}
