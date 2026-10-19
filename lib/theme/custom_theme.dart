import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

/// Styles de schéma Material 3 (variantes de `DynamicScheme`) — mêmes que le studio Angular.
enum SchemeStyle {
  fidelity('Fidélité', 'Primary fidèle à la couleur choisie (même rendu que les thèmes prédéfinis).'),
  tonalSpot('Tonal spot', 'Style par défaut d’Android : primary adoucie, ambiance calme.'),
  vibrant('Vibrant', 'Couleurs saturées au maximum, pour une interface énergique.'),
  expressive('Expressif', 'Teintes décalées et contrastées, volontairement inattendues.'),
  content('Contenu', 'Suit fidèlement la couleur source, pensé pour s’accorder à une image.'),
  rainbow('Arc-en-ciel', 'Accents colorés sur des surfaces neutres.'),
  fruitSalad('Salade de fruits', 'Primary et tertiary de teintes très différentes, ludique.'),
  neutral('Neutre', 'Couleurs très désaturées, presque grises.'),
  monochrome('Noir & blanc', 'Monochrome : primary noire en clair, blanche en sombre, aucune teinte.');

  const SchemeStyle(this.label, this.description);
  final String label;
  final String description;
}

/// Rôles dont la palette peut être imposée (sinon dérivée de la couleur source selon le style).
enum OverridableRole {
  secondary('Secondary', 'Chips, indicateur de navigation, boutons tonals.'),
  tertiary('Tertiary', 'Accents contrastés : badges, mises en avant.'),
  neutral('Neutral', 'Surfaces et fonds (teinte légère).'),
  neutralVariant('Neutral variant', 'Contours, textes secondaires.'),
  error('Error', 'États d’erreur.');

  const OverridableRole(this.label, this.hint);
  final String label;
  final String hint;
}

/// Niveaux de contraste M3 (-1 réduit, 0 standard, 1 élevé).
const kContrastLevels = <(double, String)>[(0, 'Standard'), (0.5, 'Moyen'), (1, 'Élevé')];

/// Tons affichés dans les nuanciers (0 = noir, 100 = blanc).
const kShowcaseTones = [0, 5, 10, 15, 20, 25, 30, 35, 40, 50, 60, 70, 80, 90, 95, 98, 99, 100];

/// Thème personnalisé : couleur source + style + contraste + couleurs imposées par rôle.
@immutable
class CustomThemeConfig {
  const CustomThemeConfig({
    required this.source,
    this.style = SchemeStyle.fidelity,
    this.contrast = 0,
    this.overrides = const {},
  });

  final Color source;
  final SchemeStyle style;
  final double contrast;
  final Map<OverridableRole, Color> overrides;

  CustomThemeConfig copyWith({Color? source, SchemeStyle? style, double? contrast, Map<OverridableRole, Color>? overrides}) =>
      CustomThemeConfig(
        source: source ?? this.source,
        style: style ?? this.style,
        contrast: contrast ?? this.contrast,
        overrides: overrides ?? this.overrides,
      );

  /// Impose (couleur) ou libère (null) la palette d'un rôle.
  CustomThemeConfig withOverride(OverridableRole role, Color? color) {
    final next = Map<OverridableRole, Color>.of(overrides);
    if (color == null) {
      next.remove(role);
    } else {
      next[role] = color;
    }
    return copyWith(overrides: next);
  }

  /// Schéma dynamique M3 : palettes du style choisi, remplacées par celles des couleurs imposées.
  DynamicScheme dynamicScheme(Brightness brightness) {
    final hct = Hct.fromInt(source.toARGB32());
    final isDark = brightness == Brightness.dark;
    final base = switch (style) {
      SchemeStyle.fidelity => SchemeFidelity(sourceColorHct: hct, isDark: isDark, contrastLevel: contrast),
      SchemeStyle.tonalSpot => SchemeTonalSpot(sourceColorHct: hct, isDark: isDark, contrastLevel: contrast),
      SchemeStyle.vibrant => SchemeVibrant(sourceColorHct: hct, isDark: isDark, contrastLevel: contrast),
      SchemeStyle.expressive => SchemeExpressive(sourceColorHct: hct, isDark: isDark, contrastLevel: contrast),
      SchemeStyle.content => SchemeContent(sourceColorHct: hct, isDark: isDark, contrastLevel: contrast),
      SchemeStyle.rainbow => SchemeRainbow(sourceColorHct: hct, isDark: isDark, contrastLevel: contrast),
      SchemeStyle.fruitSalad => SchemeFruitSalad(sourceColorHct: hct, isDark: isDark, contrastLevel: contrast),
      SchemeStyle.neutral => SchemeNeutral(sourceColorHct: hct, isDark: isDark, contrastLevel: contrast),
      SchemeStyle.monochrome => SchemeMonochrome(sourceColorHct: hct, isDark: isDark, contrastLevel: contrast),
    };
    TonalPalette pal(OverridableRole role, TonalPalette fallback) {
      final c = overrides[role];
      return c == null ? fallback : TonalPalette.fromHct(Hct.fromInt(c.toARGB32()));
    }

    return DynamicScheme(
      sourceColorHct: hct,
      variant: base.variant,
      contrastLevel: contrast,
      isDark: isDark,
      primaryPalette: base.primaryPalette,
      secondaryPalette: pal(OverridableRole.secondary, base.secondaryPalette),
      tertiaryPalette: pal(OverridableRole.tertiary, base.tertiaryPalette),
      neutralPalette: pal(OverridableRole.neutral, base.neutralPalette),
      neutralVariantPalette: pal(OverridableRole.neutralVariant, base.neutralVariantPalette),
      errorPalette: pal(OverridableRole.error, base.errorPalette),
    );
  }

  /// `ColorScheme` Flutter complet résolu par material-color-utilities.
  ColorScheme scheme(Brightness brightness) {
    final s = dynamicScheme(brightness);
    Color c(DynamicColor d) => Color(d.getArgb(s));
    return ColorScheme(
      brightness: brightness,
      primary: c(MaterialDynamicColors.primary),
      onPrimary: c(MaterialDynamicColors.onPrimary),
      primaryContainer: c(MaterialDynamicColors.primaryContainer),
      onPrimaryContainer: c(MaterialDynamicColors.onPrimaryContainer),
      primaryFixed: c(MaterialDynamicColors.primaryFixed),
      primaryFixedDim: c(MaterialDynamicColors.primaryFixedDim),
      onPrimaryFixed: c(MaterialDynamicColors.onPrimaryFixed),
      onPrimaryFixedVariant: c(MaterialDynamicColors.onPrimaryFixedVariant),
      secondary: c(MaterialDynamicColors.secondary),
      onSecondary: c(MaterialDynamicColors.onSecondary),
      secondaryContainer: c(MaterialDynamicColors.secondaryContainer),
      onSecondaryContainer: c(MaterialDynamicColors.onSecondaryContainer),
      secondaryFixed: c(MaterialDynamicColors.secondaryFixed),
      secondaryFixedDim: c(MaterialDynamicColors.secondaryFixedDim),
      onSecondaryFixed: c(MaterialDynamicColors.onSecondaryFixed),
      onSecondaryFixedVariant: c(MaterialDynamicColors.onSecondaryFixedVariant),
      tertiary: c(MaterialDynamicColors.tertiary),
      onTertiary: c(MaterialDynamicColors.onTertiary),
      tertiaryContainer: c(MaterialDynamicColors.tertiaryContainer),
      onTertiaryContainer: c(MaterialDynamicColors.onTertiaryContainer),
      tertiaryFixed: c(MaterialDynamicColors.tertiaryFixed),
      tertiaryFixedDim: c(MaterialDynamicColors.tertiaryFixedDim),
      onTertiaryFixed: c(MaterialDynamicColors.onTertiaryFixed),
      onTertiaryFixedVariant: c(MaterialDynamicColors.onTertiaryFixedVariant),
      error: c(MaterialDynamicColors.error),
      onError: c(MaterialDynamicColors.onError),
      errorContainer: c(MaterialDynamicColors.errorContainer),
      onErrorContainer: c(MaterialDynamicColors.onErrorContainer),
      surface: c(MaterialDynamicColors.surface),
      onSurface: c(MaterialDynamicColors.onSurface),
      onSurfaceVariant: c(MaterialDynamicColors.onSurfaceVariant),
      surfaceDim: c(MaterialDynamicColors.surfaceDim),
      surfaceBright: c(MaterialDynamicColors.surfaceBright),
      surfaceContainerLowest: c(MaterialDynamicColors.surfaceContainerLowest),
      surfaceContainerLow: c(MaterialDynamicColors.surfaceContainerLow),
      surfaceContainer: c(MaterialDynamicColors.surfaceContainer),
      surfaceContainerHigh: c(MaterialDynamicColors.surfaceContainerHigh),
      surfaceContainerHighest: c(MaterialDynamicColors.surfaceContainerHighest),
      outline: c(MaterialDynamicColors.outline),
      outlineVariant: c(MaterialDynamicColors.outlineVariant),
      inverseSurface: c(MaterialDynamicColors.inverseSurface),
      onInverseSurface: c(MaterialDynamicColors.inverseOnSurface),
      inversePrimary: c(MaterialDynamicColors.inversePrimary),
      surfaceTint: c(MaterialDynamicColors.surfaceTint),
      shadow: c(MaterialDynamicColors.shadow),
      scrim: c(MaterialDynamicColors.scrim),
    );
  }

  /// Couleur clé de chaque palette dérivée (affichée quand un rôle est en « auto »).
  Map<OverridableRole, Color> derivedKeyColors() {
    final s = copyWith(overrides: const {}).dynamicScheme(Brightness.light);
    return {
      OverridableRole.secondary: Color(s.secondaryPalette.keyColor.toInt()),
      OverridableRole.tertiary: Color(s.tertiaryPalette.keyColor.toInt()),
      OverridableRole.neutral: Color(s.neutralPalette.keyColor.toInt()),
      OverridableRole.neutralVariant: Color(s.neutralVariantPalette.keyColor.toInt()),
      OverridableRole.error: Color(s.errorPalette.keyColor.toInt()),
    };
  }

  /// Nuanciers : chaque palette tonale du thème (libellé, couleur clé, tons 0 → 100).
  List<(String, Color, List<(int, Color)>)> paletteStrips() {
    final s = dynamicScheme(Brightness.light);
    final rows = [
      ('Primary', s.primaryPalette),
      ('Secondary', s.secondaryPalette),
      ('Tertiary', s.tertiaryPalette),
      ('Neutral', s.neutralPalette),
      ('Neutral variant', s.neutralVariantPalette),
      ('Error', s.errorPalette),
    ];
    return [
      for (final (label, p) in rows)
        (label, Color(p.keyColor.toInt()), [for (final t in kShowcaseTones) (t, Color(p.get(t)))]),
    ];
  }

  /// Code Dart prêt à coller (ColorScheme clair et sombre).
  String toDart() {
    String hex(Color c) => '0x${c.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
    String block(Brightness b) {
      final s = scheme(b);
      final roles = {
        'primary': s.primary, 'onPrimary': s.onPrimary, 'primaryContainer': s.primaryContainer,
        'onPrimaryContainer': s.onPrimaryContainer, 'secondary': s.secondary, 'onSecondary': s.onSecondary,
        'secondaryContainer': s.secondaryContainer, 'onSecondaryContainer': s.onSecondaryContainer,
        'tertiary': s.tertiary, 'onTertiary': s.onTertiary, 'tertiaryContainer': s.tertiaryContainer,
        'onTertiaryContainer': s.onTertiaryContainer, 'error': s.error, 'onError': s.onError,
        'errorContainer': s.errorContainer, 'onErrorContainer': s.onErrorContainer, 'surface': s.surface,
        'onSurface': s.onSurface, 'onSurfaceVariant': s.onSurfaceVariant,
        'surfaceContainerLowest': s.surfaceContainerLowest, 'surfaceContainerLow': s.surfaceContainerLow,
        'surfaceContainer': s.surfaceContainer, 'surfaceContainerHigh': s.surfaceContainerHigh,
        'surfaceContainerHighest': s.surfaceContainerHighest, 'outline': s.outline, 'outlineVariant': s.outlineVariant,
        'inverseSurface': s.inverseSurface, 'onInverseSurface': s.onInverseSurface, 'inversePrimary': s.inversePrimary,
      };
      final lines = roles.entries.map((e) => '  ${e.key}: Color(${hex(e.value)}),').join('\n');
      return 'const ${b == Brightness.light ? 'light' : 'dark'}Scheme = ColorScheme(\n  brightness: Brightness.${b.name},\n$lines\n);';
    }

    return '// Thème personnalisé — source ${hex(source)}, style ${style.label}, contraste $contrast\n'
        '${block(Brightness.light)}\n\n${block(Brightness.dark)}\n';
  }

  @override
  bool operator ==(Object other) =>
      other is CustomThemeConfig &&
      other.source == source &&
      other.style == style &&
      other.contrast == contrast &&
      _mapEquals(other.overrides, overrides);

  @override
  int get hashCode => Object.hash(source, style, contrast, Object.hashAllUnordered(overrides.entries.map((e) => Object.hash(e.key, e.value))));

  static bool _mapEquals(Map<OverridableRole, Color> a, Map<OverridableRole, Color> b) =>
      a.length == b.length && a.entries.every((e) => b[e.key] == e.value);
}

/// Ratio de contraste WCAG entre deux couleurs.
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}
