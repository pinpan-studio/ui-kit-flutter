import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ui_kit_flutter/harnais/harnais_screen.dart';
import 'package:ui_kit_flutter/harnais/harnais_store.dart';
import 'package:ui_kit_flutter/harnais/hz_catalog.dart';
import 'package:ui_kit_flutter/harnais/hz_models.dart';
import 'package:ui_kit_flutter/theme/app_theme.dart';

Widget _host(Widget child, ThemeData theme) => MaterialApp(
      theme: theme,
      locale: const Locale('fr', 'FR'),
      supportedLocales: const [Locale('fr', 'FR')],
      localizationsDelegates: const [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
      home: child,
    );

void main() {
  setUpAll(() async => initializeDateFormatting('fr_FR'));

  test('Détection d’intention', () {
    expect(detectIntent('Montre-moi la flotte sur une carte'), HzIntent.map);
    expect(detectIntent('Fais-moi un tableau de bord'), HzIntent.overview);
    expect(detectIntent('Corrige le bug'), HzIntent.code);
    expect(detectIntent('bonjour'), HzIntent.clarify);
  });

  test('Chaque intention produit une réponse', () {
    for (final i in HzIntent.values) {
      final s = scenarioFor(i);
      expect(s.intro, isNotEmpty);
      expect(s.blocks, isNotEmpty);
    }
  });

  test('Le store génère une réponse complète', () async {
    final store = HarnaisStore();
    await store.send('Liste des clients à relancer');
    final conv = store.active!;
    expect(conv.messages.length, 2);
    expect(conv.messages.last.streaming, isFalse);
    expect(conv.messages.last.blocks.whereType<HzW>().map((w) => w.type), contains('table'));
  });

  for (final dark in [false, true]) {
    final theme = dark ? AppTheme.dark() : AppTheme.light();
    testWidgets('Harnais — conversations de démo (${dark ? 'sombre' : 'clair'})', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_host(const HarnaisScreen(), theme));
      await tester.pump();
      // Accueil puis chaque conversation de démo, défilée jusqu'en bas.
      for (final title in ['Démo · rapport d’activité flotte', 'Démo · boîte à outils de l’agent', 'Sidecar de navigation Flutter']) {
        await tester.tap(find.byTooltip('Ouvrir le menu de navigation'));
        for (var i = 0; i < 6; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        await tester.tap(find.text(title).last);
        await tester.pump(const Duration(milliseconds: 500));
        for (var i = 0; i < 60; i++) {
          await tester.drag(find.byType(ListView).first, const Offset(0, -600), warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 60));
        }
      }
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 2));
    });
  }

  testWidgets('Harnais — envoi de chaque suggestion', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_host(const HarnaisScreen(), AppTheme.light()));
    await tester.pump();
    for (final (_, label, _) in kHzSuggestions) {
      await tester.tap(find.byTooltip('Nouvelle conversation').first);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text(label));
      // Laisse la génération simulée aller au bout.
      for (var i = 0; i < 120; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  });
}
