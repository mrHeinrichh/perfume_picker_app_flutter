import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perfume_picker_app/main.dart';
import 'package:perfume_picker_app/store.dart';

void main() {
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

  test('default products include top, middle, and base notes', () {
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
}
