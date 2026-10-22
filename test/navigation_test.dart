import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ui_kit_flutter/showcase/kit_shell.dart';
import 'package:ui_kit_flutter/theme/app_theme.dart';

/// Navigation du shell : une pile par onglet, retour Android, onglet actif touché à nouveau.
/// Mêmes parcours que `__tests__/navigation.test.tsx` du kit React Native.
Future<void> _pumpShell(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light(),
    locale: const Locale('fr', 'FR'),
    supportedLocales: const [Locale('fr', 'FR')],
    localizationsDelegates: const [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
    home: const KitShell(),
  ));
  await tester.pumpAndSettle();
}

/// Laisse finir les transitions ; certaines galeries ont des animations en boucle (pumpAndSettle ne finirait jamais).
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

Finder _tab(String label) => find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

/// Retour système (bouton retour Android / geste) : passe par le `PopScope` du shell.
Future<void> _systemBack(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await _settle(tester);
}

void main() {
  setUpAll(() async => initializeDateFormatting('fr_FR'));

  testWidgets('une galerie s’ouvre dans l’onglet Composants, barre du bas visible', (tester) async {
    await _pumpShell(tester);
    await tester.tap(_tab('Composants'));
    await _settle(tester);
    await tester.tap(find.text('Formulaires').first);
    await _settle(tester);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Input').hitTestable(), findsWidgets);
  });

  testWidgets('chaque onglet retrouve sa page en cours', (tester) async {
    await _pumpShell(tester);
    await tester.tap(_tab('Composants'));
    await _settle(tester);
    await tester.tap(find.text('Formulaires').first);
    await _settle(tester);
    await tester.tap(_tab('Layouts'));
    await _settle(tester);
    await tester.tap(_tab('Composants'));
    await _settle(tester);
    // Toujours sur la galerie Formulaires, pas sur l’index.
    expect(find.text('Input').hitTestable(), findsWidgets);
  });

  testWidgets('onglet actif touché à nouveau : retour à la racine de l’onglet', (tester) async {
    await _pumpShell(tester);
    await tester.tap(_tab('Composants'));
    await _settle(tester);
    await tester.tap(find.text('Formulaires').first);
    await _settle(tester);
    await tester.tap(_tab('Composants'));
    await _settle(tester);
    expect(find.textContaining('galeries ·').hitTestable(), findsOneWidget);
  });

  testWidgets('retour Android : pile de l’onglet, puis onglet Showcase', (tester) async {
    await _pumpShell(tester);
    await tester.tap(_tab('Composants'));
    await _settle(tester);
    await tester.tap(find.text('Formulaires').first);
    await _settle(tester);

    await _systemBack(tester); // Formulaires → index Composants
    expect(find.textContaining('galeries ·').hitTestable(), findsOneWidget);

    await _systemBack(tester); // Composants → Showcase
    expect(find.text('CATALOGUE VISUEL').hitTestable(), findsOneWidget);
  });

  testWidgets('page de détail : le bord gauche sert au retour, pas au tiroir', (tester) async {
    await _pumpShell(tester);
    Scaffold shellScaffold() => tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(shellScaffold().drawerEnableOpenDragGesture, isTrue);
    await tester.tap(_tab('Composants'));
    await _settle(tester);
    await tester.tap(find.text('Formulaires').first);
    await _settle(tester);
    expect(shellScaffold().drawerEnableOpenDragGesture, isFalse);
    await _systemBack(tester);
    expect(shellScaffold().drawerEnableOpenDragGesture, isTrue);
  });
}
