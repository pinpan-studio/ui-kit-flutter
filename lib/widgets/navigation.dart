import 'package:flutter/material.dart';

import '../data/menu_data.dart';
import '../theme/kit_colors.dart';
import '../theme/tokens.dart';
import 'common.dart';

// ═══════════════════════════════════════════════════════════════════
// Navigation : Sidecar (rail + sous-navigation), fil d'Ariane, étapes.
// ═══════════════════════════════════════════════════════════════════

/// Sidecar : rail d'icônes ; toucher un module ouvre une seconde colonne avec ses sous-menus.
/// En mobile, il vit dans un tiroir (Drawer) ; sur tablette, à gauche du contenu.
class Sidecar extends StatefulWidget {
  const Sidecar({super.key, required this.items, required this.selected, required this.onSelect, this.height});
  final List<MenuEntry> items;
  final String selected;
  final ValueChanged<MenuEntry> onSelect;
  final double? height;

  @override
  State<Sidecar> createState() => _SidecarState();
}

class _SidecarState extends State<Sidecar> {
  String? _open;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final open = widget.items.where((m) => m.id == _open).firstOrNull;
    bool activeIn(MenuEntry m) => m.id == widget.selected || m.children.any((ch) => ch.id == widget.selected);
    return SizedBox(
      height: widget.height,
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          width: 68,
          decoration: BoxDecoration(color: c.card, border: Border(right: BorderSide(color: c.border))),
          child: Column(children: [
            const SizedBox(height: 12),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(11)),
              child: Icon(Icons.widgets, color: c.onPrimary, size: 22),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(padding: const EdgeInsets.symmetric(vertical: Space.s1), children: [
                for (final m in widget.items)
                  Tooltip(
                    message: m.label,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Space.s3, vertical: Space.s1),
                      child: Material(
                        color: activeIn(m) || _open == m.id ? c.primaryLight : Colors.transparent,
                        borderRadius: Radii.rm,
                        child: InkWell(
                          borderRadius: Radii.rm,
                          onTap: () {
                            if (m.isGroup) {
                              setState(() => _open = _open == m.id ? null : m.id);
                            } else {
                              setState(() => _open = null);
                              widget.onSelect(m);
                            }
                          },
                          child: SizedBox(
                            height: 44,
                            child: Stack(alignment: Alignment.center, children: [
                              Icon(m.icon, size: 22, color: activeIn(m) || _open == m.id ? c.primary : c.textSecondary),
                              if (m.isGroup) Positioned(right: 3, bottom: 3, child: Icon(Icons.chevron_right, size: 11, color: c.textMuted)),
                            ]),
                          ),
                        ),
                      ),
                    ),
                  ),
              ]),
            ),
            const Padding(padding: EdgeInsets.only(bottom: Space.s3), child: KitAvatar(name: 'Jean Kouassi', size: 34, online: true)),
          ]),
        ),
        AnimatedContainer(
          duration: Motion.of(context, const Duration(milliseconds: 240)),
          curve: Curves.easeOutCubic,
          width: open == null ? 0 : 220,
          decoration: BoxDecoration(color: c.card, border: Border(right: BorderSide(color: c.border))),
          child: open == null
              ? null
              : ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.topLeft,
                    minWidth: 220,
                    maxWidth: 220,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(Space.s4, Space.s4, Space.s1, Space.s2),
                        child: Row(children: [
                          Expanded(child: Text(open.label, style: TextStyle(fontFamily: Fonts.heading, fontWeight: FontWeight.w700, fontSize: 16, color: c.textPrimary))),
                          IconButton(visualDensity: VisualDensity.compact, onPressed: () => setState(() => _open = null), icon: const Icon(Icons.chevron_left)),
                        ]),
                      ),
                      Expanded(
                        child: ListView(padding: const EdgeInsets.symmetric(horizontal: Space.s2), children: [
                          for (final ch in open.children)
                            ListTile(
                              dense: true,
                              selected: ch.id == widget.selected,
                              selectedTileColor: c.primaryLight,
                              selectedColor: c.primary,
                              leading: Icon(ch.icon, size: 20),
                              minLeadingWidth: 20,
                              title: Text(ch.label),
                              onTap: () => widget.onSelect(ch),
                            ),
                        ]),
                      ),
                    ]),
                  ),
                ),
        ),
      ]),
    );
  }
}

/// Fil d'Ariane défilant horizontalement (le dernier élément est la page courante).
class Breadcrumb extends StatelessWidget {
  const Breadcrumb({super.key, required this.items, this.onTap, this.icon = Icons.home_outlined, this.separator = Icons.chevron_right});
  final List<String> items;
  final ValueChanged<int>? onTap;
  final IconData? icon;
  final IconData separator;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Row(children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) Padding(padding: const EdgeInsets.symmetric(horizontal: Space.s0_5), child: Icon(separator, size: 16, color: c.textMuted)),
          InkWell(
            borderRadius: Radii.rs,
            onTap: i == items.length - 1 || onTap == null ? null : () => onTap!(i),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.s1, vertical: Space.s1),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                if (i == 0 && icon != null) ...[Icon(icon, size: 16, color: c.textSecondary), const SizedBox(width: 4)],
                Text(
                  items[i],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: i == items.length - 1 ? FontWeight.w700 : FontWeight.w500,
                    color: i == items.length - 1 ? c.textPrimary : c.primary,
                  ),
                ),
              ]),
            ),
          ),
        ],
      ]),
    );
  }
}

enum StepStatus { done, current, todo, error }

/// Indicateur d'étapes horizontal compact (wizard mobile).
class StepsIndicator extends StatelessWidget {
  const StepsIndicator({super.key, required this.steps, required this.current, this.onTap, this.errorAt});
  final List<String> steps;
  final int current;
  final int? errorAt;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
      Row(children: [
        for (var i = 0; i < steps.length; i++) ...[
          if (i > 0)
            Expanded(
              child: AnimatedContainer(
                duration: Motion.of(context, const Duration(milliseconds: 250)),
                height: 2,
                color: i <= current ? c.primary : c.border,
              ),
            ),
          GestureDetector(
            onTap: onTap == null || i > current ? null : () => onTap!(i),
            child: AnimatedContainer(
              duration: Motion.of(context, const Duration(milliseconds: 250)),
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: errorAt == i ? c.error : (i < current ? c.primary : (i == current ? c.primaryLight : c.fieldBg)),
                border: Border.all(color: errorAt == i ? c.error : (i <= current ? c.primary : c.border), width: 2),
              ),
              child: errorAt == i
                  ? const Icon(Icons.priority_high, size: 16, color: Colors.white)
                  : i < current
                      ? Icon(Icons.check, size: 16, color: c.onPrimary)
                      : Text('${i + 1}', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: i == current ? c.primary : c.textMuted)),
            ),
          ),
        ],
      ]),
      const SizedBox(height: 8),
      Text('Étape ${current + 1} sur ${steps.length} · ${steps[current]}', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.textSecondary)),
    ]);
  }
}
