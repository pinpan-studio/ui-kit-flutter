import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit_flutter/theme/tokens.dart';

/// « Réduire les animations » : les durées du kit tombent à zéro.
void main() {
  Future<Duration> durationWith(WidgetTester tester, {required bool reduce}) async {
    late Duration d;
    await tester.pumpWidget(MediaQuery(
      data: MediaQueryData(disableAnimations: reduce),
      child: Builder(builder: (context) {
        d = Motion.of(context, Motion.medium);
        return const SizedBox();
      }),
    ));
    return d;
  }

  testWidgets('durée normale par défaut', (tester) async {
    expect(await durationWith(tester, reduce: false), Motion.medium);
  });

  testWidgets('durée nulle quand le système réduit les animations', (tester) async {
    expect(await durationWith(tester, reduce: true), Duration.zero);
  });
}
