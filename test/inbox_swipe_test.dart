import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ui_kit_flutter/examples/app_examples.dart';
import 'package:ui_kit_flutter/theme/app_theme.dart';

/// Messagerie : balayer vers la droite archive le message ; « Annuler » le restaure.
void main() {
  setUpAll(() async => initializeDateFormatting('fr_FR'));

  testWidgets('balayer pour archiver, puis Annuler', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light(), home: const InboxExample()));
    await tester.pump();

    expect(find.text('Aya Koné'), findsOneWidget);
    await tester.drag(find.text('Aya Koné'), const Offset(500, 0));
    await tester.pumpAndSettle();
    expect(find.text('Aya Koné'), findsNothing);
    expect(find.text('Message archivé'), findsOneWidget);

    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();
    expect(find.text('Aya Koné'), findsOneWidget);
  });
}
