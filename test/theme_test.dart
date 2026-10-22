import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit_flutter/theme/app_theme.dart';
import 'package:ui_kit_flutter/theme/custom_theme.dart';
import 'package:ui_kit_flutter/theme/kit_colors.dart';
import 'package:ui_kit_flutter/theme/theme_controller.dart';
import 'package:ui_kit_flutter/theme/theme_palettes.dart';
import 'package:ui_kit_flutter/theme/theme_studio.dart';
import 'package:ui_kit_flutter/theme/tokens.dart';
import 'package:ui_kit_flutter/theme/kit_text.dart';
import 'package:ui_kit_flutter/widgets/common.dart';
import 'package:ui_kit_flutter/widgets/fields/picker_fields.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  return (la > lb ? la + 0.05 : lb + 0.05) / (la > lb ? lb + 0.05 : la + 0.05);
}

void main() {
  // Mêmes valeurs que `__tests__/theme.test.ts` du kit React Native : les deux kits partagent leurs jetons.
  group('jetons partagés avec le kit React Native', () {
    test('cible tactile et dimensions', () {
      expect(kMinTouch, 48);
      expect([Sizes.buttonCompact, Sizes.buttonStandard, Sizes.buttonCreate, Sizes.buttonLarge], [32, 40, 42, 48]);
      expect([Sizes.iconSm, Sizes.iconMd, Sizes.iconLg, Sizes.avatar, Sizes.appBar, Sizes.toc], [16, 20, 24, 36, 64, 48]);
    });
    test('couches d\'état', () {
      expect([StateLayers.hover, StateLayers.focus, StateLayers.pressed, StateLayers.dragged], [0.08, 0.12, 0.12, 0.16]);
      expect([StateLayers.disabledContainer, StateLayers.disabledContent], [0.12, 0.38]);
    });
    test('durées d\'animation croissantes', () {
      final ms = [Motion.instant, Motion.fast, Motion.base, Motion.medium, Motion.slow, Motion.emphasized].map((d) => d.inMilliseconds);
      expect(ms, [100, 150, 200, 250, 300, 400]);
    });
    test('petits styles typographiques', () {
      expect(KitText.micro.fontSize, 11);
      expect(KitText.labelSm.fontSize, 11.5);
    });
  });

  test('identifiants de thème uniques et thème par défaut présent', () {
    final ids = kitPalettes.map((p) => p.id).toList();
    expect(ids.toSet().length, ids.length);
    expect(ids, contains(kDefaultPaletteId));
  });

  // Rôles M3 : chaque paire « rôle / on-rôle » doit atteindre 4,5:1 (WCAG AA texte normal).
  for (final palette in kitPalettes) {
    for (final b in Brightness.values) {
      test('contrastes M3 — ${palette.label} (${b.name})', () {
        final theme = AppTheme.build(palette, b);
        final s = theme.colorScheme;
        final pairs = {
          'primary': (s.primary, s.onPrimary),
          'primaryContainer': (s.primaryContainer, s.onPrimaryContainer),
          'secondary': (s.secondary, s.onSecondary),
          'secondaryContainer': (s.secondaryContainer, s.onSecondaryContainer),
          'tertiary': (s.tertiary, s.onTertiary),
          'tertiaryContainer': (s.tertiaryContainer, s.onTertiaryContainer),
          'error': (s.error, s.onError),
          'errorContainer': (s.errorContainer, s.onErrorContainer),
          'surface': (s.surface, s.onSurface),
          'surfaceVariant': (s.surfaceContainerHighest, s.onSurfaceVariant),
          'inverseSurface': (s.inverseSurface, s.onInverseSurface),
        };
        pairs.forEach((name, pair) {
          expect(_contrast(pair.$1, pair.$2), greaterThanOrEqualTo(4.5), reason: name);
        });
        expect(theme.brightness, b);
        expect(theme.extension<KitColors>()!.primary, s.primary);
      });
    }
  }

  testWidgets('le sélecteur change la palette et le mode', (tester) async {
    final c = ThemeController.instance;
    await tester.pumpWidget(ListenableBuilder(
      listenable: c,
      builder: (_, _) => MaterialApp(
        theme: AppTheme.light(c.palette),
        darkTheme: AppTheme.dark(c.palette),
        themeMode: c.mode,
        home: const Scaffold(body: SingleChildScrollView(child: ThemeSettings())),
      ),
    ));

    await tester.tap(find.bySemanticsLabel('Rouge'));
    await tester.pumpAndSettle();
    expect(c.palette.id, 'red');

    await tester.tap(find.text('Sombre'));
    await tester.pumpAndSettle();
    expect(c.mode, ThemeMode.dark);
    expect(Theme.of(tester.element(find.byType(ThemeSettings))).colorScheme.primary,
        kitPalettes.firstWhere((p) => p.id == 'red').scheme(Brightness.dark).primary);

    c
      ..setMode(ThemeMode.light)
      ..setPalette(kDefaultPaletteId);
  });

  // Thèmes personnalisés : chaque style M3, en clair et en sombre, avec et sans couleurs imposées.
  for (final style in SchemeStyle.values) {
    for (final b in Brightness.values) {
      test('thème personnalisé — ${style.label} (${b.name})', () {
        final configs = [
          CustomThemeConfig(source: const Color(0xFFE53935), style: style),
          CustomThemeConfig(source: const Color(0xFF1E88E5), style: style, overrides: const {
            OverridableRole.secondary: Color(0xFFFFB300),
            OverridableRole.tertiary: Color(0xFF8E24AA),
            OverridableRole.error: Color(0xFFD81B60),
          }),
        ];
        for (final cfg in configs) {
          final s = cfg.scheme(b);
          final pairs = {
            'primary': (s.primary, s.onPrimary),
            'primaryContainer': (s.primaryContainer, s.onPrimaryContainer),
            'secondaryContainer': (s.secondaryContainer, s.onSecondaryContainer),
            'tertiaryContainer': (s.tertiaryContainer, s.onTertiaryContainer),
            'error': (s.error, s.onError),
            'surface': (s.surface, s.onSurface),
            'surfaceVariant': (s.surfaceContainerHighest, s.onSurfaceVariant),
          };
          pairs.forEach((name, pair) {
            expect(contrastRatio(pair.$1, pair.$2), greaterThanOrEqualTo(4.5), reason: '$name ${cfg.overrides.length}');
          });
          expect(AppTheme.fromScheme(s).brightness, b);
        }
      });
    }
  }

  test('noir & blanc : primary noire en clair, blanche en sombre', () {
    const cfg = CustomThemeConfig(source: Color(0xFF1E88E5), style: SchemeStyle.monochrome);
    expect(cfg.scheme(Brightness.light).primary, const Color(0xFF000000));
    expect(cfg.scheme(Brightness.dark).primary, const Color(0xFFFFFFFF));
  });

  test('le contraste élevé augmente l’écart primary / surface', () {
    const base = CustomThemeConfig(source: Color(0xFF43A047));
    final std = base.scheme(Brightness.light), high = base.copyWith(contrast: 1).scheme(Brightness.light);
    expect(contrastRatio(high.primary, high.surface), greaterThan(contrastRatio(std.primary, std.surface)));
  });

  for (final size in const [Size(1400, 1000), Size(400, 900)]) {
    testWidgets('studio de thème — ${size.width.toInt()} px', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final c = ThemeController.instance;
      await tester.pumpWidget(MaterialApp(theme: AppTheme.light(), home: const ThemeStudioPage()));
      await tester.pumpAndSettle();
      expect(find.text('Studio de thème'), findsOneWidget);
      // Color picker du kit pour la source, widgets du kit dans l'aperçu.
      expect(find.byType(ColorPickerField), findsOneWidget);

      // Imposer la couleur secondary affiche un second color picker.
      final secondarySwitch = find.byKey(const ValueKey('override-secondary'));
      await tester.ensureVisible(secondarySwitch);
      await tester.pumpAndSettle();
      await tester.tap(secondarySwitch);
      await tester.pumpAndSettle();
      expect(find.byType(ColorPickerField), findsNWidgets(2));

      // L'aperçu est monté avec les widgets du kit (sous les réglages sur mobile).
      for (var i = 0; i < 12 && find.byType(KpiCard).evaluate().isEmpty; i++) {
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -600));
        await tester.pumpAndSettle();
      }
      expect(find.byType(KpiCard), findsWidgets);
      expect(find.byType(KitCard), findsWidgets);

      await tester.ensureVisible(find.widgetWithText(ChoiceChip, 'Noir & blanc'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, 'Noir & blanc'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Appliquer'));
      await tester.pumpAndSettle();
      expect(c.isCustom, isTrue);
      expect(c.custom!.style, SchemeStyle.monochrome);
      expect(c.lightTheme.colorScheme.primary, const Color(0xFF000000));

      c.setPalette(kDefaultPaletteId);
      expect(c.isCustom, isFalse);
      c.clearCustom();
      expect(c.custom, isNull);
    });
  }
}
