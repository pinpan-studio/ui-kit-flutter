import 'package:flutter/material.dart';

import '../theme/kit_colors.dart';
import '../theme/tokens.dart';
import '../core/haptics.dart';

/// Variantes de bouton du kit (correspondance avec Angular Material) :
/// primary = mat-flat-button · raised = mat-raised-button · secondary = stroked primaire ·
/// outline = stroked neutre · ghost = mat-button · danger = warn · success = jetons success.
enum KitButtonVariant { primary, raised, secondary, outline, ghost, danger, dangerOutline, success, tertiary }

enum KitButtonSize { compact, standard, create, large }

enum KitButtonShape { pill, rounded }

class KitButton extends StatelessWidget {
  const KitButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = KitButtonVariant.primary,
    this.icon,
    this.iconEnd,
    this.loading = false,
    this.loadingLabel,
    this.size = KitButtonSize.standard,
    this.shape = KitButtonShape.pill,
    this.expand = false,
  });

  final String label;
  final String? loadingLabel;
  final VoidCallback? onPressed;
  final KitButtonVariant variant;
  final IconData? icon, iconEnd;
  final bool loading, expand;
  final KitButtonSize size;
  final KitButtonShape shape;

  double get _height => switch (size) {
        KitButtonSize.compact => Sizes.buttonCompact,
        KitButtonSize.standard => Sizes.buttonStandard,
        KitButtonSize.create => Sizes.buttonCreate,
        KitButtonSize.large => Sizes.buttonLarge,
      };

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final scheme = Theme.of(context).colorScheme;
    final OutlinedBorder border = shape == KitButtonShape.pill
        ? const StadiumBorder()
        : RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));

    final (Color? bg, Color fg, BorderSide? side, double elevation) = switch (variant) {
      KitButtonVariant.primary => (c.primary, c.onPrimary, null, 0.0),
      KitButtonVariant.raised => (scheme.surfaceContainerLow, c.primary, null, 1.5),
      KitButtonVariant.secondary => (null, c.primary, BorderSide(color: scheme.outlineVariant), 0.0),
      KitButtonVariant.outline => (null, c.textPrimary, BorderSide(color: scheme.outlineVariant), 0.0),
      KitButtonVariant.ghost => (null, c.primary, null, 0.0),
      KitButtonVariant.danger => (c.error, scheme.onError, null, 0.0),
      KitButtonVariant.dangerOutline => (null, c.error, BorderSide(color: c.error.withValues(alpha: 0.5)), 0.0),
      KitButtonVariant.success => (c.success, Colors.white, null, 0.0),
      KitButtonVariant.tertiary => (c.tertiary, scheme.onTertiary, null, 0.0),
    };

    final busy = loading;
    final iconSize = size == KitButtonSize.compact ? Sizes.buttonIconCompact : Sizes.buttonIcon;
    final leading = busy
        ? SizedBox(width: iconSize, height: iconSize, child: CircularProgressIndicator(strokeWidth: 2, color: fg))
        : icon == null
            ? null
            : Icon(icon, size: iconSize);

    final child = Row(mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
      if (leading != null) ...[leading, const SizedBox(width: 8)],
      Flexible(child: Text(busy ? (loadingLabel ?? label) : label, overflow: TextOverflow.ellipsis)),
      if (iconEnd != null) ...[const SizedBox(width: 8), Icon(iconEnd, size: iconSize)],
    ]);

    final style = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size(expand ? double.infinity : Sizes.buttonMinWidth, _height)),
      fixedSize: expand ? null : WidgetStatePropertyAll(Size.fromHeight(_height)),
      padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: size == KitButtonSize.compact ? Space.s4 : Space.s5)),
      shape: WidgetStatePropertyAll(border),
      elevation: WidgetStatePropertyAll(elevation),
      textStyle: WidgetStatePropertyAll(TextStyle(fontFamily: Fonts.body, fontSize: size == KitButtonSize.compact ? 13 : 14, fontWeight: FontWeight.w600)),
      backgroundColor: WidgetStateProperty.resolveWith((s) {
        if (s.contains(WidgetState.disabled)) return bg == null ? null : c.textPrimary.withValues(alpha: 0.12);
        return bg;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.disabled) && !busy ? c.textPrimary.withValues(alpha: 0.38) : fg),
      overlayColor: WidgetStatePropertyAll(fg.withValues(alpha: 0.1)),
      side: side == null
          ? null
          : WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.disabled) ? BorderSide(color: c.textPrimary.withValues(alpha: 0.12)) : side),
    );

    return TextButton(onPressed: busy ? null : onPressed, style: style, child: child);
  }
}

/// Chip de filtre avec compteur (`.filter-chip` + `.chip-count`).
class FilterChipButton extends StatelessWidget {
  const FilterChipButton({super.key, required this.label, this.count, this.active = false, this.tone = KitTone.primary, this.onTap});
  final String label;
  final int? count;
  final bool active;
  final KitTone tone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final col = tone.text(c);
    return Material(
      color: active ? tone.light(c) : c.card,
      shape: StadiumBorder(side: BorderSide(color: active ? tone.color(c).withValues(alpha: 0.6) : c.border)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap == null
            ? null
            : () {
                kitHaptic();
                onTap!();
              },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Space.s4, Space.s2, Space.s2, Space.s2),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: active ? col : c.textSecondary)),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: Space.s2, vertical: 1),
                decoration: BoxDecoration(color: active ? tone.color(c).withValues(alpha: 0.18) : c.hover, borderRadius: Radii.pill),
                child: Text('$count', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: active ? col : c.textMuted)),
              ),
            ] else
              const SizedBox(width: 6),
          ]),
        ),
      ),
    );
  }
}

/// Bouton partagé : action principale + menu d'actions secondaires.
class SplitButton extends StatelessWidget {
  const SplitButton({super.key, required this.label, required this.icon, required this.onPressed, required this.items, required this.onSelected});
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final List<(String, IconData)> items;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return Material(
      color: c.primary,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          InkWell(
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, Space.s3, Space.s4, Space.s3),
              child: Row(children: [
                Icon(icon, size: 18, color: c.onPrimary),
                const SizedBox(width: 8),
                Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: c.onPrimary)),
              ]),
            ),
          ),
          VerticalDivider(width: 1, thickness: 1, color: c.onPrimary.withValues(alpha: 0.3)),
          PopupMenuButton<String>(
            tooltip: 'Plus d’options',
            onSelected: onSelected,
            itemBuilder: (_) => [
              for (final (l, i) in items) PopupMenuItem(value: l, child: Row(children: [Icon(i, size: 20), const SizedBox(width: 12), Text(l)])),
            ],
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: Space.s2), child: Icon(Icons.arrow_drop_down, color: c.onPrimary)),
          ),
        ]),
      ),
    );
  }
}

/// Lien d'action souligné au survol (`.line-action`).
class LineAction extends StatelessWidget {
  const LineAction(this.label, {super.key, this.onTap, this.icon = Icons.arrow_forward});
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return InkWell(
      borderRadius: Radii.rs,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Space.s1, horizontal: Space.s0_5),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.primary, decoration: TextDecoration.underline, decorationColor: c.primary.withValues(alpha: 0.4))),
          if (icon != null) ...[const SizedBox(width: 4), Icon(icon, size: 14, color: c.primary)],
        ]),
      ),
    );
  }
}
