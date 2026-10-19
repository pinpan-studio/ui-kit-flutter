import 'package:flutter/material.dart';

/// Couleurs sémantiques du kit (`--primary-color`, `--success-color-light`, `--text-muted`…),
/// exposées via `Theme.of(context).extension<KitColors>()` ou `context.kc`.
///
/// Valeurs identiques aux classes `.light` / `.dark` de `styles.scss`, qui dérivent
/// fond, surfaces et textes du thème M3 courant (voir [KitColors.fromScheme]).
@immutable
class KitColors extends ThemeExtension<KitColors> {
  const KitColors({
    required this.primary,
    required this.primaryLight,
    required this.onPrimary,
    required this.tertiary,
    required this.tertiaryLight,
    required this.success,
    required this.successLight,
    required this.successText,
    required this.warning,
    required this.warningLight,
    required this.warningText,
    required this.error,
    required this.errorLight,
    required this.errorText,
    required this.info,
    required this.infoLight,
    required this.purple,
    required this.purpleLight,
    required this.cyan,
    required this.cyanLight,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.bg,
    required this.card,
    required this.hover,
    required this.tableHeader,
    required this.border,
    required this.divider,
    required this.fieldBg,
  });

  final Color primary, primaryLight, onPrimary;
  final Color tertiary, tertiaryLight;
  final Color success, successLight, successText;
  final Color warning, warningLight, warningText;
  final Color error, errorLight, errorText;
  final Color info, infoLight;
  final Color purple, purpleLight;
  final Color cyan, cyanLight;
  final Color textPrimary, textSecondary, textMuted;
  final Color bg, card, hover, tableHeader, border;

  /// Séparateur de lignes de tableau, allégé (`--mat-table-row-item-outline-color` :
  /// outline-variant à 45 %).
  final Color divider;

  /// Fond d'un `field-box` au repos (`--mat-sys-surface-container-high`).
  final Color fieldBg;

  static const _success = Color(0xFF22C55E);
  static const _warning = Color(0xFFEAB308);
  static const _info = Color(0xFF3B82F6);
  static const _purple = Color(0xFFA855F7);
  static const _cyan = Color(0xFF06B6D4);

  /// Couleurs du kit dérivées des rôles M3 du thème courant (palette + mode),
  /// comme les classes `.light` / `.dark` de `styles.scss` les dérivent des `--mat-sys-*`.
  /// Les couleurs sémantiques (succès, alerte, info…) restent fixes d'un thème à l'autre.
  factory KitColors.fromScheme(ColorScheme s) {
    final light = s.brightness == Brightness.light;
    return KitColors(
      primary: s.primary,
      primaryLight: s.primary.withValues(alpha: light ? 0.08 : 0.14),
      onPrimary: s.onPrimary,
      tertiary: s.tertiary,
      tertiaryLight: s.tertiary.withValues(alpha: light ? 0.10 : 0.14),
      success: _success,
      successLight: _success.withValues(alpha: 0.15),
      successText: light ? const Color(0xFF15803D) : const Color(0xFF4ADE80),
      warning: _warning,
      warningLight: _warning.withValues(alpha: 0.15),
      warningText: light ? const Color(0xFFA16207) : const Color(0xFFFBBF24),
      error: s.error,
      errorLight: s.error.withValues(alpha: light ? 0.10 : 0.16),
      errorText: light ? const Color(0xFFB91C1C) : const Color(0xFFF87171),
      info: _info,
      infoLight: _info.withValues(alpha: 0.15),
      purple: _purple,
      purpleLight: _purple.withValues(alpha: 0.15),
      cyan: _cyan,
      cyanLight: _cyan.withValues(alpha: 0.15),
      textPrimary: s.onSurface,
      textSecondary: s.onSurfaceVariant,
      textMuted: s.onSurfaceVariant.withValues(alpha: light ? 0.70 : 0.65),
      bg: s.surface,
      card: s.surfaceContainerLow,
      hover: s.surfaceContainerHigh,
      tableHeader: s.surfaceContainer,
      border: light ? const Color(0x14000000) : const Color(0x14FFFFFF),
      divider: s.outlineVariant.withValues(alpha: 0.45),
      fieldBg: s.surfaceContainerHigh,
    );
  }

  @override
  KitColors copyWith() => this;

  @override
  KitColors lerp(ThemeExtension<KitColors>? other, double t) {
    if (other is! KitColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return KitColors(
      primary: l(primary, other.primary),
      primaryLight: l(primaryLight, other.primaryLight),
      onPrimary: l(onPrimary, other.onPrimary),
      tertiary: l(tertiary, other.tertiary),
      tertiaryLight: l(tertiaryLight, other.tertiaryLight),
      success: l(success, other.success),
      successLight: l(successLight, other.successLight),
      successText: l(successText, other.successText),
      warning: l(warning, other.warning),
      warningLight: l(warningLight, other.warningLight),
      warningText: l(warningText, other.warningText),
      error: l(error, other.error),
      errorLight: l(errorLight, other.errorLight),
      errorText: l(errorText, other.errorText),
      info: l(info, other.info),
      infoLight: l(infoLight, other.infoLight),
      purple: l(purple, other.purple),
      purpleLight: l(purpleLight, other.purpleLight),
      cyan: l(cyan, other.cyan),
      cyanLight: l(cyanLight, other.cyanLight),
      textPrimary: l(textPrimary, other.textPrimary),
      textSecondary: l(textSecondary, other.textSecondary),
      textMuted: l(textMuted, other.textMuted),
      bg: l(bg, other.bg),
      card: l(card, other.card),
      hover: l(hover, other.hover),
      tableHeader: l(tableHeader, other.tableHeader),
      border: l(border, other.border),
      divider: l(divider, other.divider),
      fieldBg: l(fieldBg, other.fieldBg),
    );
  }
}

/// Teintes sémantiques communes (badges, planning, harnais, cartes…).
/// Équivalent de `PlanningTone` / `HzTone` du projet web.
enum KitTone { neutral, primary, info, success, warning, error, purple, cyan, tertiary }

extension KitToneColors on KitTone {
  /// Couleur pleine (`toneVar`).
  Color color(KitColors c) => switch (this) {
        KitTone.primary => c.primary,
        KitTone.info => c.info,
        KitTone.success => c.success,
        KitTone.warning => c.warning,
        KitTone.error => c.error,
        KitTone.purple => c.purple,
        KitTone.cyan => c.cyan,
        KitTone.tertiary => c.tertiary,
        KitTone.neutral => c.textMuted,
      };

  /// Fond léger (`--*-color-light`).
  Color light(KitColors c) => switch (this) {
        KitTone.primary => c.primaryLight,
        KitTone.info => c.infoLight,
        KitTone.success => c.successLight,
        KitTone.warning => c.warningLight,
        KitTone.error => c.errorLight,
        KitTone.purple => c.purpleLight,
        KitTone.cyan => c.cyanLight,
        KitTone.tertiary => c.tertiaryLight,
        KitTone.neutral => c.textPrimary.withValues(alpha: 0.06),
      };

  /// Couleur de texte lisible sur le fond léger (`--*-color-text`).
  Color text(KitColors c) => switch (this) {
        KitTone.success => c.successText,
        KitTone.warning => c.warningText,
        KitTone.error => c.errorText,
        KitTone.neutral => c.textSecondary,
        _ => color(c),
      };
}

extension KitColorsContext on BuildContext {
  KitColors get kc => Theme.of(this).extension<KitColors>()!;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
