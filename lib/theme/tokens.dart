import 'package:flutter/widgets.dart';

/// Jetons du design system, repris de `ui-kit/src/styles.scss` (:root).
///
/// Espacements : `--space-xs` → `--space-xxl`.
abstract final class Space {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 16;
  static const double l = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

/// Rayons : `--r-s`, `--r-m`, `--r-l`, `--r-full`.
abstract final class Radii {
  static const double s = 4;
  static const double m = 12;
  static const double l = 24;
  static const double full = 9999;

  /// `--radius-card`
  static const double card = l;

  /// `--radius-input`
  static const double input = m;

  static BorderRadius get rs => BorderRadius.circular(s);
  static BorderRadius get rm => BorderRadius.circular(m);
  static BorderRadius get rl => BorderRadius.circular(l);
  static BorderRadius get pill => BorderRadius.circular(full);
}

/// Familles de polices (`--font-heading`, `--font-body`, `--font-mono`, `--font-brand`).
/// Toutes embarquées dans `assets/fonts` : aucune requête réseau.
abstract final class Fonts {
  static const String heading = 'Outfit';
  static const String body = 'Inter';
  static const String mono = 'SpaceMono';
  static const String brand = 'TTWellingtons';
}

/// Points de rupture de `styles/_breakpoints.scss`.
abstract final class Breakpoints {
  static const double xs = 375;
  static const double sm = 480;
  static const double md = 600;
  static const double tablet = 768;
  static const double lg = 960;
  static const double xl = 1024;

  static bool isCompact(BuildContext context) => MediaQuery.sizeOf(context).width < md;
  static bool isTablet(BuildContext context) => MediaQuery.sizeOf(context).width >= tablet;

  /// Nombre de colonnes pour une grille de démos (`cols-2` / `cols-3` du catalogue).
  static int columns(double width, {int max = 3}) {
    if (width >= lg) return max;
    if (width >= md) return max >= 2 ? 2 : 1;
    return 1;
  }
}

/// Ombres `--elevation-1` et `--elevation-3`.
abstract final class Elevations {
  static List<BoxShadow> e1(Brightness b) => b == Brightness.light
      ? const [
          BoxShadow(color: Color(0x0F000000), blurRadius: 3, offset: Offset(0, 1)),
          BoxShadow(color: Color(0x08000000), blurRadius: 2, offset: Offset(0, 1)),
        ]
      : const [
          BoxShadow(color: Color(0x66000000), blurRadius: 3, offset: Offset(0, 1)),
          BoxShadow(color: Color(0x4D000000), blurRadius: 2, offset: Offset(0, 1)),
        ];

  static List<BoxShadow> e3(Brightness b) => b == Brightness.light
      ? const [
          BoxShadow(color: Color(0x14000000), blurRadius: 20, spreadRadius: -3, offset: Offset(0, 10)),
          BoxShadow(color: Color(0x0A000000), blurRadius: 8, spreadRadius: -2, offset: Offset(0, 4)),
        ]
      : const [
          BoxShadow(color: Color(0x80000000), blurRadius: 20, spreadRadius: -3, offset: Offset(0, 10)),
          BoxShadow(color: Color(0x66000000), blurRadius: 8, spreadRadius: -2, offset: Offset(0, 4)),
        ];
}
