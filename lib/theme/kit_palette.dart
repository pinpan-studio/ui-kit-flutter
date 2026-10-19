import 'package:flutter/material.dart';

/// Palette tonale M3 : une teinte déclinée en tons de luminance 0 (noir) → 100 (blanc).
@immutable
class TonalTones {
  const TonalTones(this.tones);

  final Map<int, Color> tones;

  Color operator [](int tone) => tones[tone]!;
}

/// Thème de couleur du kit : palettes tonales M3 calculées depuis une couleur source
/// (voir `theme_palettes.dart`, généré par `ui-kit/tools/generate-themes.mjs`).
///
/// [scheme] associe chaque rôle M3 à un ton, avec la même table que le thème
/// `mat.theme()` d'Angular Material : les deux kits affichent les mêmes couleurs.
@immutable
class KitPalette {
  const KitPalette({
    required this.id,
    required this.label,
    required this.seed,
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.neutral,
    required this.neutralVariant,
    required this.error,
  });

  final String id;
  final String label;

  /// Couleur source des palettes.
  final Color seed;

  final TonalTones primary, secondary, tertiary, neutral, neutralVariant, error;

  ColorScheme scheme(Brightness brightness) {
    final p = primary, s = secondary, t = tertiary, n = neutral, nv = neutralVariant, e = error;
    return brightness == Brightness.light
        ? ColorScheme(
            brightness: Brightness.light,
            primary: p[40],
            onPrimary: p[100],
            primaryContainer: p[90],
            onPrimaryContainer: p[30],
            primaryFixed: p[90],
            primaryFixedDim: p[80],
            onPrimaryFixed: p[10],
            onPrimaryFixedVariant: p[30],
            secondary: s[40],
            onSecondary: s[100],
            secondaryContainer: s[90],
            onSecondaryContainer: s[30],
            secondaryFixed: s[90],
            secondaryFixedDim: s[80],
            onSecondaryFixed: s[10],
            onSecondaryFixedVariant: s[30],
            tertiary: t[40],
            onTertiary: t[100],
            tertiaryContainer: t[90],
            onTertiaryContainer: t[30],
            tertiaryFixed: t[90],
            tertiaryFixedDim: t[80],
            onTertiaryFixed: t[10],
            onTertiaryFixedVariant: t[30],
            error: e[40],
            onError: e[100],
            errorContainer: e[90],
            onErrorContainer: e[30],
            surface: n[98],
            onSurface: n[10],
            onSurfaceVariant: nv[30],
            surfaceDim: n[87],
            surfaceBright: n[98],
            surfaceContainerLowest: n[100],
            surfaceContainerLow: n[96],
            surfaceContainer: n[94],
            surfaceContainerHigh: n[92],
            surfaceContainerHighest: n[90],
            outline: nv[50],
            outlineVariant: nv[80],
            inverseSurface: n[20],
            onInverseSurface: n[95],
            inversePrimary: p[80],
            surfaceTint: p[40],
            shadow: n[0],
            scrim: n[0],
          )
        : ColorScheme(
            brightness: Brightness.dark,
            primary: p[80],
            onPrimary: p[20],
            primaryContainer: p[30],
            onPrimaryContainer: p[90],
            primaryFixed: p[90],
            primaryFixedDim: p[80],
            onPrimaryFixed: p[10],
            onPrimaryFixedVariant: p[30],
            secondary: s[80],
            onSecondary: s[20],
            secondaryContainer: s[30],
            onSecondaryContainer: s[90],
            secondaryFixed: s[90],
            secondaryFixedDim: s[80],
            onSecondaryFixed: s[10],
            onSecondaryFixedVariant: s[30],
            tertiary: t[80],
            onTertiary: t[20],
            tertiaryContainer: t[30],
            onTertiaryContainer: t[90],
            tertiaryFixed: t[90],
            tertiaryFixedDim: t[80],
            onTertiaryFixed: t[10],
            onTertiaryFixedVariant: t[30],
            error: e[80],
            onError: e[20],
            errorContainer: e[30],
            onErrorContainer: e[90],
            surface: n[6],
            onSurface: n[90],
            onSurfaceVariant: nv[80],
            surfaceDim: n[6],
            surfaceBright: n[24],
            surfaceContainerLowest: n[4],
            surfaceContainerLow: n[10],
            surfaceContainer: n[12],
            surfaceContainerHigh: n[17],
            surfaceContainerHighest: n[22],
            outline: nv[60],
            outlineVariant: nv[30],
            inverseSurface: n[90],
            onInverseSurface: n[20],
            inversePrimary: p[40],
            surfaceTint: p[80],
            shadow: n[0],
            scrim: n[0],
          );
  }
}
