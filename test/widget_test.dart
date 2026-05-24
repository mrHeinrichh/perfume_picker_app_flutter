import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perfume_picker_app/main.dart';
import 'package:perfume_picker_app/src/core/data/catalog_persistence.dart';
import 'package:perfume_picker_app/store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeCatalogPersistence implements CatalogPersistence {
  CatalogSnapshot? snapshot;

  @override
  Future<CatalogSnapshot?> load() async => snapshot;

  @override
  Future<void> save(CatalogSnapshot snapshot) async {
    this.snapshot = snapshot;
  }
}

void main() {
  Future<void> loginAsAdmin(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('admin-login-button')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('admin-username')),
      AuthStore.adminUsername,
    );
    await tester.enterText(
      find.byKey(const ValueKey('admin-password')),
      AuthStore.adminPassword,
    );
    await tester.tap(find.byKey(const ValueKey('admin-submit-button')));
    await tester.pumpAndSettle();
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('rankPerfumes sorts from highest filter matches', () {
    final ranked = rankPerfumes({'Male', 'Woody', 'Cedar'}, defaultProducts);
    final scores = ranked.map((match) => match.score).toList();
    final sortedScores = [...scores]..sort((a, b) => b.compareTo(a));

    expect(scores, sortedScores);
    expect(ranked.first.score, 3);
    expect(ranked.first.matchPercentage, 100);
  });

  test('PerfumeStore can create, update, and delete products', () {
    final store = PerfumeStore();
    final product = defaultProducts.first.copyWith(
      id: 'test-product',
      name: 'Test Product',
    );

    store.add(product);
    expect(store.byId('test-product')?.name, 'Test Product');

    store.update(product.copyWith(gender: 'Unisex'));
    expect(store.byId('test-product')?.gender, 'Unisex');

    store.delete('test-product');
    expect(store.byId('test-product'), isNull);
  });

  test('PerfumeStore can add, rename, and delete editable notes', () {
    final store = PerfumeStore();
    final product = defaultProducts.first.copyWith(
      id: 'note-test-product',
      topNotes: ['Custom citrus'],
      middleNotes: ['Jasmine'],
      baseNotes: ['Musk'],
    );

    expect(store.addNote('Custom citrus'), isTrue);
    expect(store.addNote(' custom   citrus '), isFalse);
    expect(store.addNote('This note is way too long'), isFalse);

    store.add(product);
    expect(store.noteUsageCount('custom citrus'), 1);

    expect(store.renameNote('Custom citrus', 'Sparkling citrus'), isTrue);
    expect(store.noteOptions, contains('Sparkling citrus'));
    expect(store.byId(product.id)?.topNotes, contains('Sparkling citrus'));

    expect(store.deleteNote('Sparkling citrus'), isTrue);
    expect(store.noteOptions, isNot(contains('Sparkling citrus')));
    expect(
      store.byId(product.id)?.topNotes,
      isNot(contains('Sparkling citrus')),
    );
  });

  test('PerfumeStore can add, rename, and delete characteristics', () {
    final store = PerfumeStore();
    final product = defaultProducts.first.copyWith(
      id: 'characteristic-test-product',
      fragranceCharacteristics: ['Smoky'],
    );

    expect(store.addCharacteristic('Smoky'), isTrue);
    expect(store.addCharacteristic(' smoky '), isFalse);
    expect(
      store.addCharacteristic('This characteristic name is too long'),
      isFalse,
    );

    store.add(product);
    expect(store.characteristicUsageCount('smoky'), 1);

    expect(store.renameCharacteristic('Smoky', 'Dry woods'), isTrue);
    expect(store.fragranceCharacteristicOptions, contains('Dry woods'));
    expect(
      store.byId(product.id)?.fragranceCharacteristics,
      contains('Dry woods'),
    );

    expect(store.deleteCharacteristic('Dry woods'), isTrue);
    expect(store.fragranceCharacteristicOptions, isNot(contains('Dry woods')));
    expect(
      store.byId(product.id)?.fragranceCharacteristics,
      isNot(contains('Dry woods')),
    );
  });

  test('PerfumeStore can toggle dummy data on and off', () {
    final store = PerfumeStore();

    expect(store.dummyDataEnabled, isTrue);
    expect(store.products, isNotEmpty);
    expect(store.noteOptions, isNotEmpty);
    expect(store.fragranceCharacteristicOptions, contains('Woody'));
    expect(genderOptions, ['Male', 'Female', 'Unisex']);
    expect(fragranceCharacteristicOptions, contains('Woody'));

    store.setDummyDataEnabled(false);
    expect(store.dummyDataEnabled, isFalse);
    expect(store.products, isEmpty);
    expect(store.noteOptions, isEmpty);
    expect(store.fragranceCharacteristicOptions, isEmpty);
    expect(genderOptions, ['Male', 'Female', 'Unisex']);
    expect(fragranceCharacteristicOptions, contains('Woody'));

    expect(store.addNote('Neroli'), isTrue);
    expect(store.noteOptions, ['Neroli']);
    expect(store.addCharacteristic('Solar'), isTrue);
    expect(store.fragranceCharacteristicOptions, contains('Solar'));

    store.setDummyDataEnabled(true);
    expect(store.dummyDataEnabled, isTrue);
    expect(store.products.length, defaultProducts.length);
    expect(store.noteOptions, contains('Bergamot'));
    expect(store.noteOptions, isNot(contains('Neroli')));
    expect(store.fragranceCharacteristicOptions, contains('Woody'));
    expect(store.fragranceCharacteristicOptions, isNot(contains('Solar')));
  });

  test('PerfumeStore persists catalog changes through persistence', () async {
    final persistence = FakeCatalogPersistence();
    final store = PerfumeStore(persistence: persistence);
    final product = defaultProducts.first.copyWith(
      id: 'persisted-product',
      name: 'Persisted Product',
      imageUrl: '',
      imageBytes: Uint8List.fromList([1, 2, 3]),
      fragranceCharacteristics: ['Solar'],
      topNotes: ['Neroli'],
      middleNotes: ['Jasmine'],
      baseNotes: ['Musk'],
    );

    store.setDummyDataEnabled(false);
    store.addNote('Neroli');
    store.addCharacteristic('Solar');
    store.add(product);

    expect(persistence.snapshot?.products.single.name, 'Persisted Product');

    final restored = PerfumeStore(persistence: persistence);
    await restored.load();

    expect(restored.products.single.name, 'Persisted Product');
    expect(restored.products.single.imageBytes, orderedEquals([1, 2, 3]));
    expect(restored.noteOptions, ['Neroli']);
    expect(restored.fragranceCharacteristicOptions, ['Solar']);
    expect(restored.dummyDataEnabled, isFalse);
  });

  test(
    'SharedPreferencesCatalogPersistence saves and loads catalog snapshots',
    () async {
      SharedPreferences.setMockInitialValues({});
      const persistence = SharedPreferencesCatalogPersistence();
      final product = defaultProducts.first.copyWith(
        id: 'shared-preferences-product',
        name: 'Shared Preferences Product',
        imageUrl: '',
        imageBytes: Uint8List.fromList([9, 8, 7]),
      );

      await persistence.save(
        CatalogSnapshot(
          products: [product],
          noteOptions: const ['Bergamot'],
          fragranceCharacteristicOptions: const ['Fresh'],
          dummyDataEnabled: false,
        ),
      );

      final restored = await persistence.load();

      expect(restored, isNotNull);
      expect(restored!.products.single.name, 'Shared Preferences Product');
      expect(restored.products.single.imageBytes, orderedEquals([9, 8, 7]));
      expect(restored.noteOptions, ['Bergamot']);
      expect(restored.fragranceCharacteristicOptions, ['Fresh']);
      expect(restored.dummyDataEnabled, isFalse);
    },
  );

  test('default products include top, middle, and base notes', () {
    expect(PerfumeStore().noteOptions, contains('Bergamot'));

    for (final product in defaultProducts) {
      expect(product.topNotes, isNotEmpty, reason: product.name);
      expect(product.middleNotes, isNotEmpty, reason: product.name);
      expect(product.baseNotes, isNotEmpty, reason: product.name);
      expect(genderOptions, contains(product.gender), reason: product.name);
      expect(
        product.fragranceCharacteristics,
        isNotEmpty,
        reason: product.name,
      );
      expect(product.notes, [
        ...product.topNotes,
        ...product.middleNotes,
        ...product.baseNotes,
      ]);
    }
  });

  test('AuthStore starts in user mode and only accepts admin login', () async {
    final auth = AuthStore();
    await auth.load();

    expect(auth.isReady, isTrue);
    expect(auth.isAdmin, isFalse);
    expect(auth.currentAccount, isNull);

    final userLogin = await auth.login(
      username: 'demo_user',
      password: 'demo1234',
      role: UserRole.user,
    );
    expect(userLogin.success, isFalse);

    final wrongAdminLogin = await auth.login(
      username: AuthStore.adminUsername,
      password: 'wrong-password',
      role: UserRole.admin,
    );
    expect(wrongAdminLogin.success, isFalse);

    final adminLogin = await auth.login(
      username: AuthStore.adminUsername,
      password: AuthStore.adminPassword,
      role: UserRole.admin,
    );
    expect(adminLogin.success, isTrue);
    expect(auth.isAdmin, isTrue);
  });

  testWidgets('admin sees dummy data toggle on homepage', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PerfumePickerApp());
    await tester.pumpAndSettle();

    await loginAsAdmin(tester);

    expect(find.text('Admin tools'), findsOneWidget);
    expect(find.text('Dummy data'), findsWidgets);
    expect(
      find.byKey(const ValueKey('admin-dummy-data-toggle')),
      findsOneWidget,
    );
    expect(find.text('${defaultProducts.length} products'), findsOneWidget);
    expect(
      find.text(
        '${defaultEditableFragranceCharacteristicOptions().length} characteristics',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Characteristics (${defaultEditableFragranceCharacteristicOptions().length})',
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('admin-manage-characteristics-button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Manage characteristics'), findsOneWidget);
  });

  testWidgets('admin cancel edit dialogs do not crash', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PerfumePickerApp());
    await tester.pumpAndSettle();
    await loginAsAdmin(tester);

    await tester.tap(find.byKey(const ValueKey('admin-add-product-button')));
    await tester.pumpAndSettle();
    expect(find.text('Add product'), findsWidgets);

    await tester.tap(find.byIcon(Icons.close_rounded).last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('admin-manage-notes-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Rename note').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.byIcon(Icons.close_rounded).last);
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('admin-manage-characteristics-button')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Rename characteristic').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('picker flow opens results and show page', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PerfumePickerApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('admin-login-button')), findsOneWidget);
    expect(find.text('Find your next signature scent.'), findsOneWidget);
    expect(find.text('User mode'), findsOneWidget);
    expect(find.text('Male / Female / Unisex'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('filter-Fresh')));
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('find-matches-button')));
    await tester.pumpAndSettle();

    final topMatch = rankPerfumes({'Fresh'}, defaultProducts).first;

    expect(find.text('Results'), findsOneWidget);
    expect(find.text('Highest filter matches first'), findsOneWidget);
    expect(find.text('Best match: ${topMatch.perfume.name}'), findsOneWidget);

    await tester.tap(find.byKey(ValueKey('result-${topMatch.perfume.id}')));
    await tester.pumpAndSettle();

    expect(find.text(topMatch.perfume.name), findsWidgets);
    expect(find.text('${topMatch.matchPercentage}% match'), findsOneWidget);
    expect(find.text('Top notes'), findsOneWidget);
    expect(find.text('Mid notes'), findsOneWidget);
    expect(find.text('Base notes'), findsOneWidget);
    expect(find.text(topMatch.perfume.gender), findsWidgets);
    expect(
      find.text(topMatch.perfume.fragranceCharacteristics.join(' / ')),
      findsOneWidget,
    );
  });

  testWidgets('admin results page does not show add product floating button', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PerfumePickerApp());
    await tester.pumpAndSettle();
    await loginAsAdmin(tester);

    await tester.tap(find.byKey(const ValueKey('find-matches-button')));
    await tester.pumpAndSettle();

    expect(find.text('Results'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
  });
}
