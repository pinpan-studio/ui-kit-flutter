import 'package:flutter/material.dart';

import 'kit_colors.dart';
import 'kit_palette.dart';
import 'theme_palettes.dart';
import 'tokens.dart';

/// Thèmes M3 clair / sombre pour chaque palette de couleur ([kitPalettes], mêmes tons que
/// `mat.theme()` côté Angular ; Outfit / Inter) avec les surcharges de `styles.scss` :
/// boutons pilule 40 px, champs arrondis 12 px, cartes 24 px sans contour (détachées par leur
/// fond), séparateurs de tableau allégés.
abstract final class AppTheme {
  static ThemeData light([KitPalette? palette]) => build(palette ?? defaultPalette, Brightness.light);
  static ThemeData dark([KitPalette? palette]) => build(palette ?? defaultPalette, Brightness.dark);

  static KitPalette get defaultPalette => kitPalettes.firstWhere((p) => p.id == kDefaultPaletteId);

  static ThemeData build(KitPalette palette, Brightness b) => fromScheme(palette.scheme(b));

  /// Thème complet du kit pour un `ColorScheme` quelconque (palette prédéfinie ou thème personnalisé).
  static ThemeData fromScheme(ColorScheme scheme) {
    final kc = KitColors.fromScheme(scheme);

    final base = ThemeData(useMaterial3: true, colorScheme: scheme, fontFamily: Fonts.body);
    final text = base.textTheme
        .copyWith(
          displayLarge: base.textTheme.displayLarge?.copyWith(fontFamily: Fonts.heading),
          displayMedium: base.textTheme.displayMedium?.copyWith(fontFamily: Fonts.heading),
          displaySmall: base.textTheme.displaySmall?.copyWith(fontFamily: Fonts.heading),
          headlineLarge: base.textTheme.headlineLarge?.copyWith(fontFamily: Fonts.heading, fontWeight: FontWeight.w700),
          headlineMedium: base.textTheme.headlineMedium?.copyWith(fontFamily: Fonts.heading, fontWeight: FontWeight.w700),
          headlineSmall: base.textTheme.headlineSmall?.copyWith(fontFamily: Fonts.heading, fontWeight: FontWeight.w600),
          titleLarge: base.textTheme.titleLarge?.copyWith(fontFamily: Fonts.heading, fontWeight: FontWeight.w600),
          titleMedium: base.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        )
        .apply(bodyColor: kc.textPrimary, displayColor: kc.textPrimary);

    const buttonText = TextStyle(fontFamily: Fonts.body, fontSize: 14, fontWeight: FontWeight.w600);
    const buttonSize = Size(64, 40);
    const buttonPadding = EdgeInsets.symmetric(horizontal: Space.s5);
    const pill = StadiumBorder();

    OutlineInputBorder border(Color c, [double w = 1]) =>
        OutlineInputBorder(borderRadius: Radii.rm, borderSide: BorderSide(color: c, width: w));

    return base.copyWith(
      extensions: [kc],
      scaffoldBackgroundColor: kc.bg,
      canvasColor: kc.bg,
      textTheme: text,
      dividerColor: kc.border,
      dividerTheme: DividerThemeData(color: kc.border, space: 1, thickness: 1),
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: kc.bg,
        foregroundColor: kc.textPrimary,
        elevation: 0,
        // M3 : au défilement, la barre passe en surface teintée (niveau 3 ≈ surface-container).
        scrolledUnderElevation: 3,
        centerTitle: false,
        titleTextStyle: TextStyle(fontFamily: Fonts.heading, fontSize: 20, fontWeight: FontWeight.w700, color: kc.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: kc.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: Radii.rl),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStatePropertyAll(kc.tableHeader),
        dividerThickness: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: buttonSize, padding: buttonPadding, shape: pill, textStyle: buttonText),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(minimumSize: buttonSize, padding: buttonPadding, shape: pill, textStyle: buttonText),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: buttonSize,
          padding: buttonPadding,
          shape: pill,
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(minimumSize: buttonSize, padding: buttonPadding, shape: pill, textStyle: buttonText),
      ),
      iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom(foregroundColor: kc.textSecondary)),
      // FAB M3 : primary-container / on-primary-container, élévation niveau 3, coins 16.
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.lg)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kc.fieldBg,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: Space.s3, vertical: Space.s3),
        hintStyle: TextStyle(color: kc.textMuted, fontSize: 14),
        labelStyle: TextStyle(color: kc.textSecondary, fontSize: 14),
        prefixIconColor: kc.textSecondary,
        suffixIconColor: kc.textSecondary,
        border: border(kc.border),
        enabledBorder: border(kc.border),
        focusedBorder: border(kc.primary, 1.5),
        errorBorder: border(kc.error),
        focusedErrorBorder: border(kc.error, 1.5),
        disabledBorder: border(kc.border.withValues(alpha: 0.5)),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.sm)),
        // Puces remplies, sans contour (style « sans bordure »).
        side: BorderSide.none,
        backgroundColor: kc.fieldBg,
        // Chip de filtre sélectionnée : secondary-container (M3).
        selectedColor: scheme.secondaryContainer,
        checkmarkColor: scheme.onSecondaryContainer,
        labelStyle: TextStyle(fontFamily: Fonts.body, fontSize: 13, fontWeight: FontWeight.w500, color: kc.textPrimary),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: Radii.rl),
        titleTextStyle: TextStyle(fontFamily: Fonts.heading, fontSize: 20, fontWeight: FontWeight.w600, color: kc.textPrimary),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.l))),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: Radii.rm),
      ),
      // Barre de navigation M3 : surface-container, indicateur secondary-container,
      // icône active on-secondary-container, libellés on-surface / on-surface-variant.
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => TextStyle(
            fontFamily: Fonts.body,
            fontSize: 12,
            fontWeight: s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
            color: s.contains(WidgetState.selected) ? scheme.onSurface : scheme.onSurfaceVariant,
          ),
        ),
      ),
      drawerTheme: DrawerThemeData(backgroundColor: kc.card, surfaceTintColor: Colors.transparent),
      tabBarTheme: TabBarThemeData(
        labelColor: kc.primary,
        unselectedLabelColor: kc.textSecondary,
        indicatorColor: kc.primary,
        dividerColor: kc.border,
        labelStyle: const TextStyle(fontFamily: Fonts.body, fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontFamily: Fonts.body, fontSize: 14, fontWeight: FontWeight.w500),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: kc.textSecondary,
        shape: RoundedRectangleBorder(borderRadius: Radii.rm),
        titleTextStyle: TextStyle(fontFamily: Fonts.body, fontSize: 14, fontWeight: FontWeight.w500, color: kc.textPrimary),
        subtitleTextStyle: TextStyle(fontFamily: Fonts.body, fontSize: 12.5, color: kc.textSecondary),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(color: scheme.inverseSurface, borderRadius: BorderRadius.circular(Radii.sm)),
        textStyle: TextStyle(color: scheme.onInverseSurface, fontSize: 12),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: Radii.rm),
      ),
      expansionTileTheme: ExpansionTileThemeData(
        shape: const Border(),
        collapsedShape: const Border(),
        iconColor: kc.textSecondary,
        collapsedIconColor: kc.textSecondary,
      ),
    );
  }
}
