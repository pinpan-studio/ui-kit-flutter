import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit_flutter/theme/app_theme.dart';
import 'package:ui_kit_flutter/widgets/common.dart';
import 'package:ui_kit_flutter/widgets/data_table.dart';

/// Cartes sur téléphone : « Afficher plus » au lieu des pages (mêmes cas que `__tests__/data.test.tsx`).
void main() {
  final rows = [for (var i = 1; i <= 20; i++) 'Client $i'];

  Future<void> pump(WidgetTester tester, {required double width, ViewMode mode = ViewMode.card}) async {
    tester.view.physicalSize = Size(width * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: SingleChildScrollView(
          child: KitDataTable<String>(
            rows: rows,
            initialMode: mode,
            columns: [KitColumn(label: 'Nom', cell: (_, r) => Text(r))],
            cardBuilder: (_, r, _) => SizedBox(height: 40, child: Text(r)),
          ),
        ),
      ),
    ));
  }

  testWidgets('téléphone, cartes : « Afficher plus » ajoute une tranche, sans pages', (tester) async {
    await pump(tester, width: 390);
    expect(find.text('8 sur 20'), findsOneWidget);
    expect(find.text('Client 9'), findsNothing);
    await tester.ensureVisible(find.text('Afficher 8 de plus'));
    await tester.tap(find.text('Afficher 8 de plus'));
    await tester.pump();
    expect(find.text('16 sur 20'), findsOneWidget);
    expect(find.text('Client 9'), findsOneWidget);
    await tester.ensureVisible(find.text('Afficher 4 de plus'));
    await tester.tap(find.text('Afficher 4 de plus'));
    await tester.pump();
    expect(find.text('20 sur 20'), findsOneWidget);
    expect(find.textContaining('de plus'), findsNothing);
  });

  testWidgets('tablette, cartes : la pagination reste', (tester) async {
    await pump(tester, width: 800);
    expect(find.textContaining('de plus'), findsNothing);
    expect(find.byType(KitPaginator), findsOneWidget);
  });
}
