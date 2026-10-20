import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ui_kit_flutter/examples/app_examples.dart';
import 'package:ui_kit_flutter/examples/app_shell.dart';
import 'package:ui_kit_flutter/examples/examples_index.dart';
import 'package:ui_kit_flutter/examples/galleries.dart';
import 'package:ui_kit_flutter/widgets/common.dart';
import 'package:ui_kit_flutter/theme/theme_controller.dart';

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));
  extraSmoke();
  // Thème sombre : toutes les pages d'exemple à 375 et 1440 px.
  for (final w in [375.0, 1440.0]) {
    for (final g in kExampleGroups) {
      for (final e in g.$2) {
        testWidgets('${e.$1} @ $w (sombre)', (t) async {
          t.view.physicalSize = Size(w, 900); t.view.devicePixelRatio = 1;
          addTearDown(t.view.reset);
          await t.pumpWidget(MaterialApp(theme: ThemeController.instance.darkTheme, home: Builder(builder: e.$5)));
          await t.pump();
          expect(t.takeException(), isNull);
        });
      }
    }
  }
  for (final w in [375.0, 768.0, 1024.0, 1440.0]) {
    for (final g in kExampleGroups) {
      for (final e in g.$2) {
        testWidgets('${e.$1} @ $w', (t) async {
          t.view.physicalSize = Size(w, 900); t.view.devicePixelRatio = 1;
          addTearDown(t.view.reset);
          await t.pumpWidget(MaterialApp(theme: ThemeController.instance.lightTheme, home: Builder(builder: e.$5)));
          await t.pump();
          expect(t.takeException(), isNull);
        });
      }
    }
  }
}

// Galeries, viewer de showcases et vues poussées en mobile.
Future<void> _pump(WidgetTester t, double w, Widget home) async {
  t.view.physicalSize = Size(w, 900);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(theme: ThemeController.instance.lightTheme, home: home));
  await t.pump();
}

void extraSmoke() {
  // Shell applicatif : navigation par la sidenav (desktop) et par le tiroir (mobile), détail poussé.
  testWidgets('shell : sidenav → Clients → fiche @ 1440', (t) async {
    await _pump(t, 1440, const ExAppShell());
    await t.tap(find.text('Clients').first);
    await t.pumpAndSettle();
    expect(find.text('CRM'), findsWidgets);
    await t.tap(find.text('Sotra Logistique').first);
    await t.pumpAndSettle();
    expect(find.byType(BackButton), findsOneWidget);
    expect(t.takeException(), isNull);
  });
  testWidgets('shell : tiroir → Clients @ 375', (t) async {
    await _pump(t, 375, const ExAppShell());
    await t.tap(find.byTooltip('Afficher le menu'));
    await t.pumpAndSettle();
    await t.tap(find.text('Clients').last);
    await t.pumpAndSettle();
    expect(find.text('Nouveau client'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
  testWidgets('dashboard : fermeture de la bannière @ 375', (t) async {
    await _pump(t, 375, const ExAppShell());
    expect(find.text('3 factures en retard'), findsOneWidget);
    await t.tap(find.byTooltip('Fermer'));
    await t.pump();
    expect(find.text('3 factures en retard'), findsNothing);
  });
  for (final w in [375.0, 1440.0]) {
    testWidgets('PagesGallery @ $w', (t) async { await _pump(t, w, const PagesGallery()); expect(t.takeException(), isNull); });
    testWidgets('ShowcasesGallery @ $w', (t) async { await _pump(t, w, const ShowcasesGallery()); expect(t.takeException(), isNull); });
  }
  for (final s in kShowcases) {
    testWidgets('ShowcaseViewer ${s.id} @ 375', (t) async {
      await _pump(t, 375, ShowcaseViewer(id: s.id));
      await t.pump(const Duration(milliseconds: 400));
      expect(t.takeException(), isNull);
    });
  }
  for (final d in ShowcaseDevice.values) {
    testWidgets('ShowcaseViewer app-dashboard ${d.name} @ 1440', (t) async {
      await _pump(t, 1440, ShowcaseViewer(id: 'app-dashboard', device: d));
      expect(t.takeException(), isNull);
    });
  }
  // Vues de détail poussées en mobile : message, fil de chat, fiche client.
  for (final (name, page) in [('inbox → message', const InboxExample() as Widget), ('chat → fil', const ChatExample()), ('clients → fiche', const ClientsExample())]) {
    testWidgets('détail mobile $name @ 375', (t) async {
      await _pump(t, 375, page);
      await t.tap(find.byType(page is ClientsExample ? KitCard : ExTile).first);
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(find.byType(BackButton), findsOneWidget);
    });
  }
  testWidgets('file picker et panneau chat', (t) async {
    await _pump(t, 375, const FilesExample(openPicker: true));
    await t.pumpAndSettle();
    expect(find.text('Sélectionner des fichiers'), findsOneWidget);
    await _pump(t, 1440, const DashboardExample(openChat: true));
    await t.pumpAndSettle();
    expect(find.byType(ChatPanel), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
