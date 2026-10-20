import 'package:flutter/widgets.dart';

/// Jetons du design system, alignés sur `ui-kit/src/styles.scss` (:root),
/// échelle unique introduite par `feat/design-tokens` (base 4 px).
///
/// Espacements : `--space-0` → `--space-16`, plus les alias historiques.
abstract final class Space {
  static const double s0 = 0;
  static const double s0_5 = 2;
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s8 = 32;
  static const double s10 = 40;
  static const double s12 = 48;
  static const double s16 = 64;

  // Alias historiques (`--space-xs` → `--space-xxl`).
  static const double xs = s1;
  static const double s = s2;
  static const double m = s4;
  static const double l = s6;
  static const double xl = s8;
  static const double xxl = s12;
}

/// Rayons : `--radius-none` → `--radius-full`, plus les alias historiques.
abstract final class Radii {
  static const double none = 0;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double x2l = 24;
  static const double full = 9999;

  // Alias historiques (`--r-s`, `--r-m`, `--r-l`, `--r-full`).
  static const double s = xs;
  static const double m = md;
  static const double l = x2l;

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

/// Élévations `--elevation-0` → `--elevation-5` (versions claire et sombre).
abstract final class Elevations {
  static List<BoxShadow> e0(Brightness b) => const [];

  static List<BoxShadow> e1(Brightness b) => b == Brightness.light
      ? const [
          BoxShadow(color: Color(0x0F000000), blurRadius: 3, offset: Offset(0, 1)),
          BoxShadow(color: Color(0x08000000), blurRadius: 2, offset: Offset(0, 1)),
        ]
      : const [
          BoxShadow(color: Color(0x66000000), blurRadius: 3, offset: Offset(0, 1)),
          BoxShadow(color: Color(0x4D000000), blurRadius: 2, offset: Offset(0, 1)),
        ];

  static List<BoxShadow> e2(Brightness b) => b == Brightness.light
      ? const [
          BoxShadow(color: Color(0x12000000), blurRadius: 8, spreadRadius: -2, offset: Offset(0, 4)),
          BoxShadow(color: Color(0x0A000000), blurRadius: 4, spreadRadius: -1, offset: Offset(0, 2)),
        ]
      : const [
          BoxShadow(color: Color(0x73000000), blurRadius: 8, spreadRadius: -2, offset: Offset(0, 4)),
          BoxShadow(color: Color(0x59000000), blurRadius: 4, spreadRadius: -1, offset: Offset(0, 2)),
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

  static List<BoxShadow> e4(Brightness b) => b == Brightness.light
      ? const [
          BoxShadow(color: Color(0x1F000000), blurRadius: 32, spreadRadius: -6, offset: Offset(0, 16)),
          BoxShadow(color: Color(0x0F000000), blurRadius: 12, spreadRadius: -4, offset: Offset(0, 6)),
        ]
      : const [
          BoxShadow(color: Color(0x8C000000), blurRadius: 32, spreadRadius: -6, offset: Offset(0, 16)),
          BoxShadow(color: Color(0x73000000), blurRadius: 12, spreadRadius: -4, offset: Offset(0, 6)),
        ];

  static List<BoxShadow> e5(Brightness b) => b == Brightness.light
      ? const [
          BoxShadow(color: Color(0x2E000000), blurRadius: 48, spreadRadius: -12, offset: Offset(0, 24)),
          BoxShadow(color: Color(0x14000000), blurRadius: 20, spreadRadius: -6, offset: Offset(0, 10)),
        ]
      : const [
          BoxShadow(color: Color(0x99000000), blurRadius: 48, spreadRadius: -12, offset: Offset(0, 24)),
          BoxShadow(color: Color(0x80000000), blurRadius: 20, spreadRadius: -6, offset: Offset(0, 10)),
        ];
}
