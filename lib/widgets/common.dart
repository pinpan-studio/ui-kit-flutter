import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/format.dart';
import '../theme/kit_colors.dart';
import '../theme/kit_text.dart';
import '../theme/tokens.dart';
import '../core/haptics.dart';

// ═══════════════════════════════════════════════════════════════════
// Briques partagées du kit (équivalents de shared/components/*).
// ═══════════════════════════════════════════════════════════════════

/// `<app-status-badge>` / `.m3-badge` : capitales 11 px, fond léger, rayon 12.
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.label, {super.key, this.tone = KitTone.neutral, this.icon, this.uppercase = true});

  final String label;
  final KitTone tone;
  final IconData? icon;
  final bool uppercase;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final fg = tone.text(c);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Space.s3, vertical: Space.s1),
      decoration: BoxDecoration(color: tone.light(c), borderRadius: Radii.rm),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: fg), const SizedBox(width: 4)],
          Flexible(
            child: Text(
              uppercase ? label.toUpperCase() : label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.4, color: fg, height: 1.2),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pastille compteur (badge numérique d'icône).
class CountDot extends StatelessWidget {
  const CountDot(this.count, {super.key, this.tone = KitTone.error});
  final int count;
  final KitTone tone;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return Container(
      constraints: const BoxConstraints(minWidth: 18),
      height: 18,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: tone.color(c), borderRadius: Radii.pill),
      child: Text(count > 99 ? '99+' : '$count', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

/// Panneau (`.panel-card` / `.section-card`) : fond carte, bordure fine, rayon 24.
class KitCard extends StatelessWidget {
  const KitCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Space.m),
    this.onTap,
    this.title,
    this.icon,
    this.trailing,
    this.color,
    this.borderColor,
    this.radius = Radii.card,
    this.shadow = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final String? title;
  final IconData? icon;
  final Widget? trailing;
  final Color? color, borderColor;
  final double radius;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final br = BorderRadius.circular(radius);
    Widget body = Padding(padding: padding, child: child);
    if (title != null) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.m, Space.s4, Space.s, 0),
            child: Row(children: [
              if (icon != null) ...[Icon(icon, size: 20, color: c.primary), const SizedBox(width: 10)],
              Expanded(child: Text(title!, style: context.t.cardTitle)),
              ?trailing,
            ]),
          ),
          body,
        ],
      );
    }
    return Material(
      color: color ?? c.card,
      // Sans contour : la carte se détache par son fond ; `borderColor` sert aux états (sélection).
      shape: RoundedRectangleBorder(borderRadius: br, side: borderColor == null ? BorderSide.none : BorderSide(color: borderColor!)),
      clipBehavior: Clip.antiAlias,
      shadowColor: Colors.black26,
      elevation: shadow ? 2 : 0,
      child: onTap == null ? body : InkWell(onTap: onTap, child: body),
    );
  }
}

/// Avatar à initiales coloré.
class KitAvatar extends StatelessWidget {
  const KitAvatar({super.key, required this.name, this.size = 36, this.tone, this.image, this.online});

  final String name;
  final double size;
  final KitTone? tone;
  final ImageProvider? image;
  final bool? online;

  static const _tones = [KitTone.primary, KitTone.info, KitTone.purple, KitTone.warning, KitTone.success, KitTone.cyan, KitTone.tertiary];

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final t = tone ?? _tones[name.codeUnits.fold<int>(0, (a, b) => a + b) % _tones.length];
    final avatar = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: t.light(c),
        image: image == null ? null : DecorationImage(image: image!, fit: BoxFit.cover),
      ),
      child: image != null
          ? null
          : Text(Fmt.initials(name), style: TextStyle(color: t.text(c), fontWeight: FontWeight.w700, fontSize: size * 0.36)),
    );
    if (online == null) return avatar;
    return Stack(clipBehavior: Clip.none, children: [
      avatar,
      Positioned(
        right: 0,
        bottom: 0,
        child: Container(
          width: size * 0.3,
          height: size * 0.3,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: online! ? c.success : c.textMuted,
            border: Border.all(color: c.card, width: 2),
          ),
        ),
      ),
    ]);
  }
}

/// Pile d'avatars qui se chevauchent.
class AvatarStack extends StatelessWidget {
  const AvatarStack({super.key, required this.names, this.size = 32, this.max = 4});
  final List<String> names;
  final double size;
  final int max;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final shown = names.take(max).toList();
    final rest = names.length - shown.length;
    final count = shown.length + (rest > 0 ? 1 : 0);
    return SizedBox(
      height: size,
      width: size + (count - 1) * size * 0.65,
      child: Stack(children: [
        for (var i = 0; i < shown.length; i++)
          Positioned(
            left: i * size * 0.65,
            child: Container(
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: c.card, width: 2)),
              child: KitAvatar(name: shown[i], size: size - 4),
            ),
          ),
        if (rest > 0)
          Positioned(
            left: shown.length * size * 0.65,
            child: Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: c.hover, border: Border.all(color: c.card, width: 2)),
              child: Text('+$rest', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c.textSecondary)),
            ),
          ),
      ]),
    );
  }
}

/// `<app-empty-state>` : icône dans un disque, titre, sous-titre, action.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.icon = Icons.inbox_outlined,
    this.title = 'Aucun résultat',
    this.subtitle = 'Il n’y a rien à afficher pour le moment.',
    this.actionLabel,
    this.actionIcon = Icons.add,
    this.onAction,
    this.compact = false,
  });

  final IconData icon;
  final String title, subtitle;
  final String? actionLabel;
  final IconData actionIcon;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final d = compact ? 56.0 : 80.0;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Space.xl, vertical: compact ? Space.l : Space.s12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: d,
            height: d,
            decoration: BoxDecoration(shape: BoxShape.circle, color: c.fieldBg),
            child: Icon(icon, size: d * 0.45, color: c.textSecondary.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 20),
          Text(title, textAlign: TextAlign.center, style: KitText.h4.copyWith(fontSize: 18, fontWeight: FontWeight.w700, color: c.textPrimary)),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Text(subtitle, textAlign: TextAlign.center, style: KitText.body.copyWith(color: c.textSecondary)),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: onAction ?? () {}, icon: Icon(actionIcon, size: 18), label: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

/// État d'erreur (`Error state`) : icône rouge, message, réessayer.
class ErrorState extends StatelessWidget {
  const ErrorState({super.key, this.title = 'Une erreur est survenue', this.subtitle = 'Impossible de charger les données. Vérifiez votre connexion puis réessayez.', this.onRetry, this.code});

  final String title, subtitle;
  final String? code;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.xl, vertical: Space.s10),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(shape: BoxShape.circle, color: c.errorLight),
          child: Icon(Icons.error_outline, size: 34, color: c.error),
        ),
        const SizedBox(height: 16),
        Text(title, textAlign: TextAlign.center, style: context.t.h4.copyWith(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(subtitle, textAlign: TextAlign.center, style: context.t.bodySm),
        if (code != null) ...[
          const SizedBox(height: 8),
          Text(code!, style: context.t.mono.copyWith(color: c.textMuted, fontSize: 11)),
        ],
        if (onRetry != null) ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh, size: 18), label: const Text('Réessayer')),
        ],
      ]),
    );
  }
}

/// `.kpi-card` : disque d'icône teinté, valeur Outfit 22, libellé 12, tendance optionnelle.
class KpiCard extends StatelessWidget {
  const KpiCard({super.key, required this.icon, required this.value, required this.label, this.tone = KitTone.primary, this.unit, this.delta, this.up, this.onTap, this.goodWhenUp = true});

  /// `false` pour un indicateur où la hausse est mauvaise (impayés, latence…).
  final bool goodWhenUp;
  final IconData icon;
  final String value, label;
  final String? unit, delta;
  final bool? up;
  final KitTone tone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return KitCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: Space.s4, vertical: Space.s4),
      child: Row(children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(shape: BoxShape.circle, color: tone.light(c)),
          child: Icon(icon, size: 22, color: tone.color(c)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text.rich(
              TextSpan(children: [
                TextSpan(text: value),
                if (unit != null) TextSpan(text: ' $unit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.textSecondary)),
              ]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontFamily: Fonts.heading, fontSize: 22, fontWeight: FontWeight.w700, color: c.textPrimary, height: 1.2, fontFeatures: KitText.tabular),
            ),
            const SizedBox(height: 2),
            // Libellé et variation passent à la ligne au lieu de déborder (« +12,4 % vs année précédente »).
            Wrap(spacing: 6, runSpacing: 2, crossAxisAlignment: WrapCrossAlignment.center, children: [
              Text(label, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: c.textSecondary)),
              if (delta != null) TrendChip(delta!, up: up ?? true, goodWhenUp: goodWhenUp),
            ]),
          ]),
        ),
      ]),
    );
  }
}

/// Variation ▲ / ▼ colorée.
class TrendChip extends StatelessWidget {
  const TrendChip(this.text, {super.key, this.up = true, this.goodWhenUp = true});
  final String text;
  final bool up, goodWhenUp;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final good = up == goodWhenUp;
    final col = good ? c.successText : c.errorText;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(up ? Icons.trending_up : Icons.trending_down, size: 14, color: col),
      const SizedBox(width: 2),
      Flexible(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: col))),
    ]);
  }
}

/// En-tête de page (`.page-header`) : fil d'Ariane, titre, sous-titre, actions.
class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, this.breadcrumb, this.subtitle, this.actions = const [], this.badge});
  final String title;
  final String? breadcrumb, subtitle;
  final List<Widget> actions;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (breadcrumb != null)
        Text(breadcrumb!.toUpperCase(), style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, letterSpacing: 0.9, color: c.textMuted)),
      const SizedBox(height: 4),
      Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Flexible(child: Text(title, style: context.t.pageTitle)),
        if (badge != null) ...[const SizedBox(width: 10), badge!],
      ]),
      if (subtitle != null) ...[const SizedBox(height: 4), Text(subtitle!, style: context.t.bodySm)],
      if (actions.isNotEmpty) ...[
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: actions),
      ],
    ]);
  }
}

/// `.refresh-btn` : bouton icône rond bordé de 40 px.
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({super.key, required this.icon, this.onPressed, this.tooltip, this.size = 40, this.active = false});
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final btn = Material(
      color: active ? c.primaryLight : c.card,
      shape: CircleBorder(side: BorderSide(color: active ? c.primary : c.border)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(width: size, height: size, child: Icon(icon, size: size * 0.5, color: active ? c.primary : c.textSecondary)),
      ),
    );
    return tooltip == null ? btn : Tooltip(message: tooltip!, child: btn);
  }
}

/// Bascule segmentée (`.m3-filter-toggle`) : options pilules dans un rail.
class SegmentedToggle<T> extends StatelessWidget {
  const SegmentedToggle({super.key, required this.options, required this.value, required this.onChanged, this.expand = false});

  final List<(T, String, IconData?)> options;
  final T value;
  final ValueChanged<T> onChanged;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final children = [
      for (final (v, label, icon) in options)
        _seg(context, c, v == value, label, icon, () {
          if (v != value) kitHaptic();
          onChanged(v);
        }),
    ];
    return Container(
      padding: const EdgeInsets.all(Space.s1),
      decoration: BoxDecoration(color: c.fieldBg, borderRadius: Radii.pill),
      child: Row(mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min, children: [
        for (final w in children) expand ? Expanded(child: w) : w,
      ]),
    );
  }

  Widget _seg(BuildContext context, KitColors c, bool active, String label, IconData? icon, VoidCallback onTap) {
    return AnimatedContainer(
      duration: Motion.of(context, const Duration(milliseconds: 180)),
      decoration: BoxDecoration(
        color: active ? c.card : Colors.transparent,
        borderRadius: Radii.pill,
        boxShadow: active ? Elevations.e1(Theme.of(context).brightness) : null,
      ),
      child: InkWell(
        borderRadius: Radii.pill,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: expand ? Space.s2 : Space.s3, vertical: Space.s2),
          child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
            if (icon != null) ...[Icon(icon, size: 16, color: active ? c.primary : c.textSecondary), if (label.isNotEmpty) const SizedBox(width: 6)],
            if (label.isNotEmpty)
              Flexible(
                child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: active ? c.primary : c.textSecondary)),
              ),
          ]),
        ),
      ),
    );
  }
}

enum ViewMode { card, list }

/// `<app-view-mode-toggle>` : Cartes / Liste.
class ViewModeToggle extends StatelessWidget {
  const ViewModeToggle({super.key, required this.mode, required this.onChanged, this.showLabels = true});
  final ViewMode mode;
  final ValueChanged<ViewMode> onChanged;
  final bool showLabels;

  @override
  Widget build(BuildContext context) => SegmentedToggle<ViewMode>(
        value: mode,
        onChanged: onChanged,
        options: [
          (ViewMode.card, showLabels ? 'Cartes' : '', Icons.grid_view),
          (ViewMode.list, showLabels ? 'Liste' : '', Icons.view_list),
        ],
      );
}

/// Squelette animé (`ngx-skeleton-loader`).
class Skeleton extends StatefulWidget {
  const Skeleton({super.key, this.width, this.height = 14, this.radius = 8, this.circle = false});
  final double? width;
  final double height, radius;
  final bool circle;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> with SingleTickerProviderStateMixin {
  late final _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final base = c.fieldBg;
    final hi = Color.alphaBlend(c.card.withValues(alpha: 0.7), base);
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final x = _ctrl.value * 3 - 1;
        return Container(
          width: widget.circle ? widget.height : widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            shape: widget.circle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: widget.circle ? null : BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(x - 1, 0),
              end: Alignment(x + 1, 0),
              colors: [base, hi, base],
              stops: const [0.2, 0.5, 0.8],
            ),
          ),
        );
      },
    );
  }
}

/// Squelette d'une ligne de liste (avatar + 2 lignes).
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: Space.s3),
        child: Row(children: [
          Skeleton(height: 40, circle: true),
          SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Skeleton(width: 160, height: 12),
              SizedBox(height: 8),
              Skeleton(height: 10),
            ]),
          ),
        ]),
      );
}

/// `<app-paginator>` adapté au mobile : taille de page, plage, pages visibles.
class KitPaginator extends StatelessWidget {
  const KitPaginator({
    super.key,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.onPage,
    this.onPageSize,
    this.pageSizes = const [5, 10, 25, 50],
    this.compact = false,
  });

  final int page, pageSize, total;
  final ValueChanged<int> onPage;
  final ValueChanged<int>? onPageSize;
  final List<int> pageSizes;
  final bool compact;

  int get pages => math.max(1, (total / pageSize).ceil());

  List<int?> _visible() {
    if (pages <= 5) return [for (var i = 1; i <= pages; i++) i];
    if (page <= 3) return [1, 2, 3, 4, null, pages];
    if (page >= pages - 2) return [1, null, pages - 3, pages - 2, pages - 1, pages];
    return [1, null, page - 1, page, page + 1, null, pages];
  }

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final start = total == 0 ? 0 : (page - 1) * pageSize + 1;
    final end = math.min(page * pageSize, total);
    final nav = Row(mainAxisSize: MainAxisSize.min, children: [
      IconButton(visualDensity: VisualDensity.compact, onPressed: page > 1 ? () => onPage(page - 1) : null, icon: const Icon(Icons.chevron_left), tooltip: 'Précédent'),
      if (!compact)
        for (final p in _visible())
          p == null
              ? Padding(padding: const EdgeInsets.symmetric(horizontal: Space.s0_5), child: Text('…', style: TextStyle(color: c.textMuted)))
              : _PageNum(p, active: p == page, onTap: () => onPage(p))
      else
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.s2),
          child: Text('$page / $pages', style: TextStyle(fontWeight: FontWeight.w600, color: c.textSecondary)),
        ),
      IconButton(visualDensity: VisualDensity.compact, onPressed: page < pages ? () => onPage(page + 1) : null, icon: const Icon(Icons.chevron_right), tooltip: 'Suivant'),
    ]);
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 4,
      children: [
        Wrap(crossAxisAlignment: WrapCrossAlignment.center, runSpacing: 4, children: [
          if (onPageSize != null) ...[
            Text('Par page', style: TextStyle(fontSize: 12.5, color: c.textSecondary)),
            const SizedBox(width: 6),
            PopupMenuButton<int>(
              initialValue: pageSize,
              onSelected: onPageSize,
              itemBuilder: (_) => [for (final s in pageSizes) PopupMenuItem(value: s, child: Text('$s'))],
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: Space.s2, vertical: Space.s1),
                decoration: BoxDecoration(color: c.fieldBg, borderRadius: BorderRadius.circular(Radii.sm)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('$pageSize', style: const TextStyle(fontWeight: FontWeight.w600)),
                  Icon(Icons.arrow_drop_down, size: 18, color: c.textSecondary),
                ]),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Text('$start–$end sur $total', style: TextStyle(fontSize: 12.5, color: c.textSecondary, fontFeatures: KitText.tabular)),
        ]),
        nav,
      ],
    );
  }
}

class _PageNum extends StatelessWidget {
  const _PageNum(this.n, {required this.active, required this.onTap});
  final int n;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: Material(
        color: active ? c.primary : Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 34,
            height: 34,
            child: Center(
              child: Text('$n', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: active ? c.onPrimary : c.textSecondary)),
            ),
          ),
        ),
      ),
    );
  }
}

/// Motif « field-box » : libellé 12/600 au-dessus d'un champ.
class FormFieldLabel extends StatelessWidget {
  const FormFieldLabel({super.key, required this.label, required this.child, this.required = false, this.hint, this.error});
  final String label;
  final Widget child;
  final bool required;
  final String? hint, error;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
      Text.rich(
        TextSpan(text: label, children: [if (required) TextSpan(text: ' *', style: TextStyle(color: c.error))]),
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.textSecondary),
      ),
      const SizedBox(height: 6),
      child,
      if (error != null || hint != null) ...[
        const SizedBox(height: 4),
        Text(error ?? hint!, style: TextStyle(fontSize: 12, color: error != null ? c.errorText : c.textMuted)),
      ],
    ]);
  }
}

/// Champ texte au style field-box (fond surface-high, bordure fine, focus primaire).
class KitTextField extends StatelessWidget {
  const KitTextField({
    super.key,
    this.label,
    this.hint,
    this.icon,
    this.suffix,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.minLines,
    this.obscure = false,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.required = false,
    this.helper,
    this.errorText,
    this.textInputAction,
    this.inputFormatters,
    this.autofocus = false,
    this.focusNode,
    this.onSubmitted,
  });

  final String? label, hint, initialValue, helper, errorText;
  final IconData? icon;
  final Widget? suffix;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged, onSubmitted;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final int? maxLines, minLines;
  final bool obscure, enabled, readOnly, required, autofocus;
  final VoidCallback? onTap;
  final TextInputAction? textInputAction;
  final List<dynamic>? inputFormatters;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final field = TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: obscure ? 1 : maxLines,
      minLines: minLines,
      obscureText: obscure,
      enabled: enabled,
      readOnly: readOnly,
      onTap: onTap,
      autofocus: autofocus,
      focusNode: focusNode,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters?.cast(),
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: icon == null ? null : Icon(icon, size: 20),
        suffixIcon: suffix,
        errorText: errorText,
      ),
    );
    if (label == null) return field;
    return FormFieldLabel(label: label!, required: required, hint: helper, child: field);
  }
}

/// Bloc de chargement plein cadre (`<app-overlay-spiner>`).
class OverlaySpinner extends StatelessWidget {
  const OverlaySpinner({super.key, this.message = 'Chargement…'});
  final String message;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return Container(
      color: c.bg.withValues(alpha: 0.72),
      alignment: Alignment.center,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(width: 36, height: 36, child: CircularProgressIndicator(strokeWidth: 3, color: c.primary)),
        const SizedBox(height: 12),
        Text(message, style: TextStyle(color: c.textSecondary, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

/// Grille responsive simple (1 colonne en mobile, n au-delà).
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({super.key, required this.children, this.minItemWidth = 280, this.spacing = Space.m, this.maxColumns = 4});
  final List<Widget> children;
  final double minItemWidth, spacing;
  final int maxColumns;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, cons) {
      final cols = math.max(1, math.min(maxColumns, ((cons.maxWidth + spacing) / (minItemWidth + spacing)).floor()));
      final w = (cons.maxWidth - spacing * (cols - 1)) / cols;
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [for (final ch in children) SizedBox(width: w, child: ch)],
      );
    });
  }
}

/// Séparateur avec libellé centré (« ou »).
class LabeledDivider extends StatelessWidget {
  const LabeledDivider(this.label, {super.key});
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return Row(children: [
      const Expanded(child: Divider()),
      Padding(padding: const EdgeInsets.symmetric(horizontal: Space.s3), child: Text(label, style: TextStyle(fontSize: 12, color: c.textMuted))),
      const Expanded(child: Divider()),
    ]);
  }
}

/// Barre de progression arrondie.
class KitProgressBar extends StatelessWidget {
  const KitProgressBar({super.key, required this.value, this.tone = KitTone.primary, this.height = 6});
  final double value;
  final KitTone tone;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return ClipRRect(
      borderRadius: Radii.pill,
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: height,
        backgroundColor: c.fieldBg,
        color: tone.color(c),
      ),
    );
  }
}
