import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'auth_store.dart';
import 'catalog.dart';
import 'models.dart';
import 'src/core/data/catalog_persistence.dart';
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

part 'src/core/presentation/bloc_scopes.dart';
part 'src/features/auth/presentation/auth_gate.dart';
part 'src/features/auth/presentation/admin_login_sheet.dart';
part 'src/features/auth/presentation/auth_routes.dart';
part 'src/features/browse/presentation/landing_page.dart';
part 'src/features/browse/presentation/widgets/landing_header.dart';
part 'src/features/browse/presentation/widgets/admin_tools_panel.dart';
part 'src/features/browse/presentation/widgets/bottle_showcase.dart';
part 'src/features/browse/presentation/widgets/filter_section.dart';
part 'src/features/browse/presentation/widgets/empty_products.dart';
part 'src/features/results/presentation/results_page.dart';
part 'src/features/results/presentation/widgets/results_summary.dart';
part 'src/features/results/presentation/widgets/result_card.dart';
part 'src/features/results/presentation/widgets/match_badge.dart';
part 'src/features/results/presentation/result_actions.dart';
part 'src/features/perfume_detail/presentation/show_page.dart';
part 'src/features/perfume_detail/presentation/widgets/detail_grid.dart';
part 'src/features/perfume_detail/presentation/widgets/metric_tile.dart';
part 'src/features/perfume_detail/presentation/widgets/note_pyramid_section.dart';
part 'src/features/perfume_detail/presentation/widgets/detail_section.dart';
part 'src/features/perfume_detail/presentation/widgets/product_image.dart';
part 'src/features/product_editor/presentation/product_editor_sheet.dart';
part 'src/features/product_editor/presentation/widgets/image_picker_panel.dart';
part 'src/features/product_editor/presentation/widgets/editor_text_field.dart';
part 'src/features/product_editor/presentation/widgets/note_select_field.dart';
part 'src/features/product_editor/presentation/widgets/note_picker_sheet.dart';
part 'src/features/product_editor/presentation/product_editor_helpers.dart';
part 'src/features/admin/presentation/note_manager_sheet.dart';
part 'src/features/admin/presentation/characteristic_manager_sheet.dart';
part 'src/features/admin/presentation/widgets/rename_catalog_item_dialog.dart';
part 'src/features/admin/presentation/catalog_manager_routes.dart';
part 'src/shared/presentation/widgets/pill.dart';
part 'src/shared/presentation/widgets/mini_chip.dart';
part 'src/shared/presentation/widgets/mini_switch_chip.dart';
part 'src/shared/presentation/widgets/animated_entry.dart';
part 'src/shared/navigation/soft_route.dart';

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
    _store = PerfumeStore(
      persistence: const SharedPreferencesCatalogPersistence(),
    );
    unawaited(_store.load());
    _authStore = AuthStore()..load();
  }

  @override
  void dispose() {
    _authStore.close();
    _store.close();
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
