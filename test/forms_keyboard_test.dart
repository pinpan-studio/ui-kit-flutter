import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ui_kit_flutter/examples/ex_scaffold.dart';
import 'package:ui_kit_flutter/examples/forms_examples.dart';
import 'package:ui_kit_flutter/theme/app_theme.dart';

/// Formulaires longs : barre d'action collée en bas et enchaînement des champs au clavier.
void main() {
  setUpAll(() async => initializeDateFormatting('fr_FR'));

  Future<void> pump(WidgetTester tester, Widget page) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light(), home: page));
    await tester.pump();
  }

  List<TextInputAction?> actions(WidgetTester tester) =>
      tester.widgetList<EditableText>(find.byType(EditableText)).map((e) => e.textInputAction).toList();

  testWidgets('Commande : barre d’action en bas, « Suivant » puis « OK »', (tester) async {
    await pump(tester, const CheckoutFormExample());
    expect(find.byType(ExActionBar), findsOneWidget);
    expect(find.text('Continuer').hitTestable(), findsOneWidget);
    final a = actions(tester);
    expect(a.take(3), everyElement(TextInputAction.next));
    expect(a[3], TextInputAction.done);
  });

  testWidgets('Onboarding et Réservation : barre d’action en bas', (tester) async {
    await pump(tester, const OnboardingFormExample());
    expect(find.byType(ExActionBar), findsOneWidget);
    await pump(tester, const BookingFormExample());
    expect(find.byType(ExActionBar), findsOneWidget);
  });
}
