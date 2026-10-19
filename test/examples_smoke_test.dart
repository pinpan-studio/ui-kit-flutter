import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ui_kit_flutter/examples/examples_index.dart';
import 'package:ui_kit_flutter/theme/theme_controller.dart';

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));
  for (final w in [375.0, 768.0, 1280.0]) {
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
