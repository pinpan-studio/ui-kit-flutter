import 'package:flutter/material.dart';

import 'kit_colors.dart';
import 'tokens.dart';

/// Échelle typographique du kit (`styles/_typography.scss`) :
/// ratio ≈ 1,2 arrondi sur la grille de 2 px. Outfit pour les titres, Inter pour le texte.
abstract final class KitText {
  static const display = TextStyle(fontFamily: Fonts.heading, fontSize: 40, height: 1.15, fontWeight: FontWeight.w700, letterSpacing: -1.2);
  static const h1 = TextStyle(fontFamily: Fonts.heading, fontSize: 32, height: 1.2, fontWeight: FontWeight.w700, letterSpacing: -0.64);
  static const h2 = TextStyle(fontFamily: Fonts.heading, fontSize: 24, height: 1.25, fontWeight: FontWeight.w600, letterSpacing: -0.24);
  static const h3 = TextStyle(fontFamily: Fonts.heading, fontSize: 20, height: 1.3, fontWeight: FontWeight.w600);
  static const h4 = TextStyle(fontFamily: Fonts.heading, fontSize: 16, height: 1.4, fontWeight: FontWeight.w600);
  static const pageTitle = TextStyle(fontFamily: Fonts.heading, fontSize: 22, height: 1.3, fontWeight: FontWeight.w700);
  static const cardTitle = TextStyle(fontFamily: Fonts.heading, fontSize: 16, height: 1.35, fontWeight: FontWeight.w700);
  static const bodyLg = TextStyle(fontFamily: Fonts.body, fontSize: 16, height: 1.7, fontWeight: FontWeight.w400);
  static const body = TextStyle(fontFamily: Fonts.body, fontSize: 14, height: 1.55, fontWeight: FontWeight.w400);
  static const bodySm = TextStyle(fontFamily: Fonts.body, fontSize: 13, height: 1.55, fontWeight: FontWeight.w400);
  static const label = TextStyle(fontFamily: Fonts.body, fontSize: 12, height: 1.4, fontWeight: FontWeight.w600);
  static const caption = TextStyle(fontFamily: Fonts.body, fontSize: 12, height: 1.4, fontWeight: FontWeight.w400);
  /// Petite étiquette (puces, filtres, métadonnées compactes).
  static const labelSm = TextStyle(fontFamily: Fonts.body, fontSize: 11.5, height: 1.4, fontWeight: FontWeight.w600);

  /// Plus petit texte lisible : badges, compteurs, légendes de graphique. Jamais pour un texte cliquable.
  static const micro = TextStyle(fontFamily: Fonts.body, fontSize: 11, height: 1.35, fontWeight: FontWeight.w500);
  static const overline = TextStyle(fontFamily: Fonts.body, fontSize: 11, height: 1.4, fontWeight: FontWeight.w700, letterSpacing: 0.66);
  static const mono = TextStyle(fontFamily: Fonts.mono, fontSize: 12.5, height: 1.5);
  static const brand = TextStyle(fontFamily: Fonts.brand, fontSize: 18, fontWeight: FontWeight.w600);

  /// Chiffres tabulaires (`.text-tabular`).
  static const tabular = [FontFeature.tabularFigures()];
}

/// Raccourcis colorés : `context.t.body.secondary`…
extension KitTextContext on BuildContext {
  KitTextColors get t => KitTextColors(kc);
}

class KitTextColors {
  KitTextColors(this.c);
  final KitColors c;

  TextStyle get display => KitText.display.copyWith(color: c.textPrimary);
  TextStyle get h1 => KitText.h1.copyWith(color: c.textPrimary);
  TextStyle get h2 => KitText.h2.copyWith(color: c.textPrimary);
  TextStyle get h3 => KitText.h3.copyWith(color: c.textPrimary);
  TextStyle get h4 => KitText.h4.copyWith(color: c.textPrimary);
  TextStyle get pageTitle => KitText.pageTitle.copyWith(color: c.textPrimary);
  TextStyle get cardTitle => KitText.cardTitle.copyWith(color: c.textPrimary);
  TextStyle get bodyLg => KitText.bodyLg.copyWith(color: c.textPrimary);
  TextStyle get body => KitText.body.copyWith(color: c.textPrimary);
  TextStyle get bodySm => KitText.bodySm.copyWith(color: c.textSecondary);
  TextStyle get label => KitText.label.copyWith(color: c.textSecondary);
  TextStyle get caption => KitText.caption.copyWith(color: c.textMuted);
  TextStyle get labelSm => KitText.labelSm.copyWith(color: c.textSecondary);
  TextStyle get micro => KitText.micro.copyWith(color: c.textMuted);
  TextStyle get overline => KitText.overline.copyWith(color: c.textMuted);
  TextStyle get mono => KitText.mono.copyWith(color: c.textPrimary);
}
