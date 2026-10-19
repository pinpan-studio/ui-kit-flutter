import 'dart:math' as math;
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'custom_theme.dart';
import 'kit_palette.dart';
import 'theme_palettes.dart';
import 'theme_studio.dart';

/// Thème purement visuel — équivalent de `ThemeService` : mode (clair / sombre / système)
/// et thème de couleur M3 : palette prédéfinie ([kitPalettes]) ou thème personnalisé du studio.
class ThemeController extends ChangeNotifier {
  ThemeController();

  static final instance = ThemeController();

  ThemeMode _mode = ThemeMode.light;
  String _paletteId = kDefaultPaletteId;
  CustomThemeConfig? _custom;
  bool _useCustom = false;

  ThemeMode get mode => _mode;

  /// Dernier thème personnalisé (conservé même quand une palette prédéfinie est active).
  CustomThemeConfig? get custom => _custom;

  bool get isCustom => _useCustom && _custom != null;

  /// Libellé du thème de couleur courant.
  String get label => isCustom ? 'Personnalisé' : palette.label;

  /// Schéma M3 courant pour une luminosité.
  ColorScheme scheme(Brightness b) => isCustom ? _custom!.scheme(b) : palette.scheme(b);

  ThemeData get lightTheme => isCustom ? AppTheme.fromScheme(scheme(Brightness.light)) : AppTheme.light(palette);
  ThemeData get darkTheme => isCustom ? AppTheme.fromScheme(scheme(Brightness.dark)) : AppTheme.dark(palette);

  List<KitPalette> get palettes => kitPalettes;

  KitPalette get palette => kitPalettes.firstWhere((p) => p.id == _paletteId, orElse: () => kitPalettes.first);

  /// Mode sombre effectif (résout [ThemeMode.system] avec le réglage de la plateforme).
  bool get isDark =>
      _mode == ThemeMode.dark ||
      (_mode == ThemeMode.system && PlatformDispatcher.instance.platformBrightness == Brightness.dark);

  void toggle() => setMode(isDark ? ThemeMode.light : ThemeMode.dark);

  void setMode(ThemeMode mode) {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
  }

  /// Active une palette prédéfinie.
  void setPalette(String id) {
    if (!kitPalettes.any((p) => p.id == id) || (id == _paletteId && !isCustom)) return;
    _paletteId = id;
    _useCustom = false;
    notifyListeners();
  }

  /// Enregistre et active un thème personnalisé.
  void applyCustom(CustomThemeConfig config) {
    if (isCustom && config == _custom) return;
    _custom = config;
    _useCustom = true;
    notifyListeners();
  }

  /// Supprime le thème personnalisé et revient à la palette prédéfinie.
  void clearCustom() {
    if (_custom == null) return;
    _custom = null;
    _useCustom = false;
    notifyListeners();
  }

  /// Réactive le dernier thème personnalisé.
  void useCustom() {
    if (_custom == null || _useCustom) return;
    _useCustom = true;
    notifyListeners();
  }
}

/// Bouton de bascule clair / sombre, présent dans toutes les barres d'outils.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      tooltip: dark ? 'Passer en thème clair' : 'Passer en thème sombre',
      icon: Icon(dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
      onPressed: ThemeController.instance.toggle,
    );
  }
}

/// Bouton « Apparence » : ouvre les réglages de thème (mode + couleur) dans une bottom sheet.
class ThemePickerButton extends StatelessWidget {
  const ThemePickerButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Apparence : mode et couleur',
      icon: const Icon(Icons.palette_outlined),
      onPressed: () => showThemeSheet(context),
    );
  }
}

/// Bottom sheet modale M3 contenant [ThemeSettings].
Future<void> showThemeSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Apparence', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            ThemeSettings(
              onOpenStudio: () {
                Navigator.of(context).pop();
                openThemeStudio(context);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

/// Réglages d'apparence : mode (bouton segmenté M3) et thème de couleur (pastilles
/// primary / secondary / tertiary de chaque palette). Utilisable seul (page de réglages).
class ThemeSettings extends StatelessWidget {
  const ThemeSettings({super.key, this.onOpenStudio});

  /// Affiche le bouton « Studio de thème » (masqué si null).
  final VoidCallback? onOpenStudio;

  @override
  Widget build(BuildContext context) {
    final controller = ThemeController.instance;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final brightness = Theme.of(context).brightness;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Mode', style: text.titleSmall),
            const SizedBox(height: 10),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode_outlined), label: Text('Clair')),
                ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode_outlined), label: Text('Sombre')),
                ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto_outlined), label: Text('Système')),
              ],
              selected: {controller.mode},
              showSelectedIcon: false,
              onSelectionChanged: (s) => controller.setMode(s.first),
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('Couleur', style: text.titleSmall),
                const SizedBox(width: 8),
                Text(controller.label, style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                if (controller.custom != null)
                  PaletteSwatch(
                    label: 'Personnalisé',
                    colors: controller.custom!.scheme(brightness),
                    selected: controller.isCustom,
                    icon: Icons.tune,
                    onTap: controller.useCustom,
                  ),
                for (final p in controller.palettes)
                  PaletteSwatch(
                    label: p.label,
                    colors: p.scheme(brightness),
                    selected: !controller.isCustom && p.id == controller.palette.id,
                    onTap: () => controller.setPalette(p.id),
                  ),
              ],
            ),
            if (onOpenStudio != null) ...[
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: onOpenStudio,
                icon: const Icon(Icons.tune),
                label: const Text('Studio de thème : couleurs, styles, nuances'),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Pastille d'un thème : moitié haute primary, quarts bas secondary / tertiary
/// (comme le sélecteur « Fond d'écran et style » d'Android). Cible tactile 48 dp.
class PaletteSwatch extends StatelessWidget {
  const PaletteSwatch({
    super.key,
    required this.label,
    required this.colors,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;

  /// Schéma du thème représenté (primary / secondary / tertiary).
  final ColorScheme colors;
  final bool selected;

  /// Icône affichée au centre quand la pastille n'est pas sélectionnée.
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = colors;
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      label: label,
      child: Tooltip(
        message: label,
        excludeFromSemantics: true,
        child: InkResponse(
          onTap: onTap,
          radius: 24,
          child: SizedBox.square(
            dimension: 48,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: selected ? 34 : 40,
                height: selected ? 34 : 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: selected
                      ? [BoxShadow(color: scheme.surfaceContainerLow, spreadRadius: 3), BoxShadow(color: s.primary, spreadRadius: 5)]
                      : null,
                ),
                child: CustomPaint(
                  painter: _SwatchPainter(s.primary, s.secondary, s.tertiary, scheme.onSurface.withValues(alpha: 0.12)),
                  child: selected || icon != null
                      ? Center(
                          child: Container(
                            decoration: BoxDecoration(color: scheme.surfaceContainerHighest, shape: BoxShape.circle),
                            padding: const EdgeInsets.all(1),
                            child: Icon(selected ? Icons.check : icon, size: 18, color: scheme.onSurface),
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SwatchPainter extends CustomPainter {
  _SwatchPainter(this.primary, this.secondary, this.tertiary, this.outline);

  final Color primary, secondary, tertiary, outline;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    const quarter = math.pi / 2;
    canvas.drawArc(rect, 2 * quarter, 2 * quarter, true, Paint()..color = primary);
    canvas.drawArc(rect, quarter, quarter, true, Paint()..color = secondary);
    canvas.drawArc(rect, 0, quarter, true, Paint()..color = tertiary);
    canvas.drawCircle(
      rect.center,
      size.shortestSide / 2 - 0.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = outline,
    );
  }

  @override
  bool shouldRepaint(_SwatchPainter old) =>
      old.primary != primary || old.secondary != secondary || old.tertiary != tertiary || old.outline != outline;
}
