import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit_flutter/core/haptics.dart';
import 'package:ui_kit_flutter/theme/app_theme.dart';
import 'package:ui_kit_flutter/widgets/common.dart';
import 'package:ui_kit_flutter/widgets/kit_buttons.dart';

/// Retour haptique aux mêmes endroits que `hapticToggle` du kit React Native.
void main() {
  late List<String> calls;

  setUp(() {
    calls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') calls.add(call.arguments as String);
      return null;
    });
  });

  tearDown(() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));

  Widget host(Widget child) => MaterialApp(theme: AppTheme.light(), home: Scaffold(body: Center(child: child)));

  test('withHaptic : déclenche le retour puis l’action ; null reste null', () async {
    var got = false;
    withHaptic<bool>((v) => got = v)!(true);
    await Future<void>.delayed(Duration.zero);
    expect(got, isTrue);
    expect(calls, ['HapticFeedbackType.selectionClick']);
    expect(withHaptic<bool>(null), isNull);
  });

  testWidgets('SegmentedToggle : retour seulement en changeant de valeur', (tester) async {
    var value = 'a';
    await tester.pumpWidget(host(StatefulBuilder(
      builder: (context, setState) => SegmentedToggle<String>(
        options: const [('a', 'Liste', null), ('b', 'Grille', null)],
        value: value,
        onChanged: (v) => setState(() => value = v),
      ),
    )));
    await tester.tap(find.text('Liste'));
    expect(calls, isEmpty);
    await tester.tap(find.text('Grille'));
    expect(calls, ['HapticFeedbackType.selectionClick']);
  });

  testWidgets('FilterChipButton : retour au toucher', (tester) async {
    await tester.pumpWidget(host(FilterChipButton(label: 'En retard', count: 3, onTap: () {})));
    await tester.tap(find.text('En retard'));
    expect(calls, ['HapticFeedbackType.selectionClick']);
  });
}
