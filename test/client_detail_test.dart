import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ui_kit_flutter/data/examples_data.dart';
import 'package:ui_kit_flutter/examples/app_examples.dart';
import 'package:ui_kit_flutter/theme/app_theme.dart';

/// Fiche client : l'onglet actif s'affiche à sa hauteur naturelle, sans défilement imbriqué.
void main() {
  setUpAll(() async => initializeDateFormatting('fr_FR'));

  testWidgets('un seul défilement vertical ; changer d’onglet affiche tout son contenu', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light(), home: ClientDetailExample()));
    await tester.pump();

    final vertical = tester.widgetList<Scrollable>(find.byType(Scrollable)).where((s) => s.axisDirection == AxisDirection.down);
    expect(vertical.length, 1);

    await tester.tap(find.widgetWithText(Tab, 'Factures'));
    await tester.pumpAndSettle();
    for (final i in kExInvoices) {
      expect(find.text(i.ref), findsOneWidget);
    }
  });
}
