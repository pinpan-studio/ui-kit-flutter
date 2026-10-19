import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ui_kit_flutter/showcase/kit_nav.dart';
import 'package:ui_kit_flutter/data/showcase_data.dart';
import 'package:ui_kit_flutter/showcase/kit_shell.dart';
import 'package:ui_kit_flutter/showcase/layouts/layout_demos.dart';
import 'package:ui_kit_flutter/theme/app_theme.dart';

/// Monte chaque écran du catalogue (clair puis sombre, format téléphone)
/// et fait défiler la page entière : toute exception de rendu fait échouer le test.
Widget _host(Widget child, ThemeData theme) => MaterialApp(
      theme: theme,
      locale: const Locale('fr', 'FR'),
      supportedLocales: const [Locale('fr', 'FR')],
      localizationsDelegates: const [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
      home: child,
    );

Future<void> _scrollAll(WidgetTester tester) async {
  final scrollables = find.byType(Scrollable);
  if (scrollables.evaluate().isEmpty) return;
  // Le défilement principal de la page est le plus grand Scrollable vertical.
  for (var i = 0; i < 40; i++) {
    await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -700), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 120));
  }
}

void main() {
  setUpAll(() async => initializeDateFormatting('fr_FR'));

  for (final dark in [false, true]) {
    final theme = dark ? AppTheme.dark() : AppTheme.light();
    final mode = dark ? 'sombre' : 'clair';

    testWidgets('Shell ($mode)', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_host(const KitShell(), theme));
      await tester.pump(const Duration(milliseconds: 300));
      for (final tab in ['Composants', 'Layouts', 'Showcase']) {
        await tester.tap(find.text(tab).last);
        await tester.pump(const Duration(milliseconds: 300));
      }
      await _scrollAll(tester);
    });

    final demos = <String, Widget>{
      'AppShellDemo': const AppShellDemo(),
      'DetailPageDemo': DetailPageDemo(client: kDemoClients[0]),
      'AuthDemo': const AuthDemo(),
      'PublicPageDemo': const PublicPageDemo(),
    };
    for (final d in demos.entries) {
      testWidgets('${d.key} ($mode)', (tester) async {
        tester.view.physicalSize = const Size(390 * 3, 844 * 3);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(_host(d.value, theme));
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 2));
      });
    }

    for (final cat in kCategories) {
      testWidgets('${cat.label} ($mode)', (tester) async {
        tester.view.physicalSize = const Size(390 * 3, 844 * 3);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(_host(cat.builder(null), theme));
        await tester.pump(const Duration(milliseconds: 300));
        await _scrollAll(tester);
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 3));
      });
    }
  }
}
