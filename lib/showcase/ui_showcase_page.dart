import 'package:flutter/material.dart';

import '../core/snack.dart';
import '../data/material_icons.dart';
import '../theme/kit_colors.dart';
import '../theme/kit_text.dart';
import '../theme/theme_controller.dart';
import '../theme/theme_palettes.dart';
import '../theme/theme_studio.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import 'doc/doc.dart';
import 'kit_nav.dart';
import 'kit_shell.dart';

/// `/ui-showcase` — vue d'ensemble : couleurs, typographie, espacements, icônes, catalogue.
class UiShowcasePage extends StatelessWidget {
  const UiShowcasePage({super.key, this.onMenu});
  final VoidCallback? onMenu;

  @override
  Widget build(BuildContext context) {
    return DocPage(
      leading: IconButton(icon: const Icon(Icons.menu), tooltip: 'Catalogue', onPressed: onMenu),
      title: 'UI Showcase',
      icon: Icons.auto_awesome_mosaic,
      eyebrow: 'Catalogue visuel',
      subtitle: 'Vue globale du design system : jetons de couleur, typographie, icônes, composants et layouts, adaptés au mobile. Tout fonctionne sans backend.',
      header: const _Overview(),
      sections: [
        DocSection(
          id: 'themes',
          title: 'Thèmes',
          source: 'theme_palettes.dart (généré par ui-kit/tools/generate-themes.mjs) · ThemeController · ThemePickerButton',
          description: '${kitPalettes.length} thèmes de couleur Material 3, chacun en clair, en sombre ou selon le réglage du système. '
              'Les palettes tonales sont calculées dans l’espace HCT à partir d’une couleur source : les rôles (primary, container, surface…) '
              'garantissent les contrastes Material quelle que soit la couleur. Mêmes tons que le UI Kit Angular.',
          children: const [_Themes()],
        ),
        DocSection(
          id: 'colors',
          title: 'Colors',
          source: 'KitColors (ThemeExtension) · dérivés du thème M3 courant',
          description: 'Jetons définis pour les thèmes clair et sombre. Touchez une pastille pour copier sa valeur hexadécimale. Basculez le thème pour voir les valeurs sombres.',
          children: const [_Colors()],
        ),
        DocSection(
          id: 'typography',
          title: 'Typography',
          source: 'Outfit (titres) · Inter (texte) · Space Mono (codes)',
          description: 'Polices embarquées dans assets/fonts : aucune requête vers Google Fonts.',
          children: const [_TypeScale()],
        ),
        DocSection(
          id: 'spacing',
          title: 'Espacements & rayons',
          source: 'tokens.dart · Space / Radii / Elevations',
          cols: 2,
          children: const [_Spacing(), _RadiiDemo()],
        ),
        DocSection(
          id: 'icons',
          title: 'Icons',
          source: 'Material Icons (police Flutter)',
          description: 'Sélection des icônes utilisées dans le projet. Touchez pour copier le code Dart.',
          children: const [_IconGrid()],
        ),
        DocSection(
          id: 'catalog',
          title: 'Catalogue',
          description: 'Accès direct aux galeries détaillées.',
          children: const [_Catalog()],
        ),
      ],
    );
  }
}

class _Overview extends StatelessWidget {
  const _Overview();

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final sections = kCategories.fold<int>(0, (n, k) => n + k.sections.length);
    final shell = KitShell.of(context);
    Widget stat(IconData icon, String value, String label, VoidCallback onTap) => KitCard(
          onTap: onTap,
          padding: const EdgeInsets.all(Space.s4),
          child: Row(children: [
            Icon(icon, color: c.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(value, style: TextStyle(fontFamily: Fonts.heading, fontSize: 22, fontWeight: FontWeight.w700, color: c.textPrimary)),
                Text(label, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, height: 1.25, color: c.textSecondary)),
              ]),
            ),
          ]),
        );
    const quick = [
      ('Buttons', 'buttons', null, Icons.smart_button),
      ('Inputs', 'forms', 'input', Icons.input),
      ('Selects', 'forms', 'select', Icons.arrow_drop_down_circle),
      ('Forms', 'forms', 'validation', Icons.fact_check),
      ('Tables', 'data', 'table', Icons.table_rows),
      ('Cards', 'data', 'cards', Icons.view_agenda),
      ('Modals', 'feedback', 'modal', Icons.open_in_new),
      ('Drawers', 'feedback', 'drawer', Icons.view_sidebar),
      ('Alerts', 'feedback', 'alert', Icons.report),
      ('Toasts', 'feedback', 'toast', Icons.chat_bubble),
      ('Navigation', 'navigation', null, Icons.explore),
      ('Pagination', 'navigation', 'pagination', Icons.last_page),
      ('Accordion', 'material', 'accordion', Icons.expand_circle_down),
      ('Tree', 'material', 'tree', Icons.account_tree),
      ('Drag & drop', 'material', 'drag-drop', Icons.drag_indicator),
      ('Loading', 'feedback', 'loading', Icons.hourglass_top),
      ('Empty states', 'data', 'empty', Icons.inbox),
      ('Error states', 'feedback', 'error', Icons.error),
      ('Kanban', 'planning', 'kanban', Icons.view_kanban),
      ('Timeline', 'planning', 'timeline', Icons.view_timeline),
      ('Agenda', 'planning', 'agenda', Icons.calendar_month),
      ('Maps', 'maps', null, Icons.map),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ResponsiveGrid(minItemWidth: 150, spacing: 10, children: [
        stat(Icons.widgets, '${kCategories.length}', 'galeries de composants', () => shell?.select(1)),
        stat(Icons.segment, '$sections', 'sections documentées', () => shell?.select(1)),
        stat(Icons.dashboard_customize, '7', 'gabarits d’écran', () => shell?.select(2)),
        stat(Icons.auto_awesome, '33', 'widgets du harnais', () => shell?.select(3)),
      ]),
      const SizedBox(height: Space.m),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final (label, cat, section, icon) in quick)
          ActionChip(
            avatar: Icon(icon, size: 16, color: c.primary),
            label: Text(label),
            backgroundColor: c.card,
            onPressed: () => openCategory(context, categoryById(cat), section),
          ),
      ]),
    ]);
  }
}

String _hex(Color col) {
  final a = (col.a * 255).round();
  final rgb = col.toARGB32() & 0xFFFFFF;
  final h = rgb.toRadixString(16).padLeft(6, '0').toUpperCase();
  return a == 255 ? '#$h' : '#$h · ${(a / 255 * 100).round()} %';
}

/// Réglages de thème + rôles de couleur M3 (paires « rôle / on-rôle ») + aperçu des composants.
class _Themes extends StatelessWidget {
  const _Themes();

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final roles = [
      ('Primary', 'primary', s.primary, s.onPrimary),
      ('Primary container', 'primaryContainer', s.primaryContainer, s.onPrimaryContainer),
      ('Secondary', 'secondary', s.secondary, s.onSecondary),
      ('Secondary container', 'secondaryContainer', s.secondaryContainer, s.onSecondaryContainer),
      ('Tertiary', 'tertiary', s.tertiary, s.onTertiary),
      ('Tertiary container', 'tertiaryContainer', s.tertiaryContainer, s.onTertiaryContainer),
      ('Error', 'error', s.error, s.onError),
      ('Error container', 'errorContainer', s.errorContainer, s.onErrorContainer),
      ('Surface', 'surface', s.surface, s.onSurface),
      ('Surface container', 'surfaceContainer', s.surfaceContainer, s.onSurface),
      ('Surface container highest', 'surfaceContainerHighest', s.surfaceContainerHighest, s.onSurfaceVariant),
      ('Inverse surface', 'inverseSurface', s.inverseSurface, s.onInverseSurface),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(
        padding: const EdgeInsets.all(Space.l),
        decoration: BoxDecoration(color: s.surfaceContainer, borderRadius: BorderRadius.circular(Radii.lg)),
        child: ThemeSettings(onOpenStudio: () => openThemeStudio(context)),
      ),
      const SizedBox(height: Space.m),
      ResponsiveGrid(minItemWidth: 150, spacing: 8, children: [
        for (final (label, token, bg, fg) in roles)
          Material(
            color: bg,
            shape: RoundedRectangleBorder(borderRadius: Radii.rm, side: BorderSide(color: s.outlineVariant)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => copyToClipboard(context, 'colorScheme.$token', label: '« colorScheme.$token » copié'),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(Space.s3, Space.s3, Space.s3, Space.s3),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: fg)),
                  const SizedBox(height: 14),
                  Text('$token · ${_hex(bg)}', style: TextStyle(fontFamily: Fonts.mono, fontSize: 10.5, color: fg.withValues(alpha: 0.8))),
                ]),
              ),
            ),
          ),
      ]),
      const SizedBox(height: Space.m),
      DemoWrap(spacing: 8, children: [
        FilledButton(onPressed: () {}, child: const Text('Filled')),
        FilledButton.tonal(onPressed: () {}, child: const Text('Tonal')),
        OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
        ElevatedButton(onPressed: () {}, child: const Text('Elevated')),
        TextButton(onPressed: () {}, child: const Text('Text')),
        FloatingActionButton.extended(heroTag: null, onPressed: () {}, icon: const Icon(Icons.edit), label: const Text('FAB')),
      ]),
      const SizedBox(height: Space.s),
      DemoWrap(spacing: 8, children: [
        Switch(value: true, onChanged: (_) {}),
        Checkbox(value: true, onChanged: (_) {}),
        FilterChip(label: const Text('Filtre'), selected: true, onSelected: (_) {}),
        const SizedBox(width: 160, child: LinearProgressIndicator(value: 0.62)),
      ]),
    ]);
  }
}

class _Colors extends StatelessWidget {
  const _Colors();

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final brand = [
      ('Primary', 'primary', c.primary, 'M3 primary (thème courant)'),
      ('Primary light', 'primaryLight', c.primaryLight, null),
      ('Tertiary', 'tertiary', c.tertiary, 'M3 tertiary (thème courant)'),
      ('Tertiary light', 'tertiaryLight', c.tertiaryLight, null),
    ];
    final semantic = [
      ('Success', 'success', c.success), ('Success light', 'successLight', c.successLight), ('Success text', 'successText', c.successText),
      ('Warning', 'warning', c.warning), ('Warning light', 'warningLight', c.warningLight), ('Warning text', 'warningText', c.warningText),
      ('Error', 'error', c.error), ('Error light', 'errorLight', c.errorLight), ('Error text', 'errorText', c.errorText),
      ('Info', 'info', c.info), ('Purple', 'purple', c.purple), ('Cyan', 'cyan', c.cyan),
    ];
    final surfaces = [
      ('Background', 'bg', c.bg), ('Card', 'card', c.card), ('Hover', 'hover', c.hover), ('Table header', 'tableHeader', c.tableHeader),
      ('Border', 'border', c.border), ('Text primary', 'textPrimary', c.textPrimary), ('Text secondary', 'textSecondary', c.textSecondary),
      ('Text muted', 'textMuted', c.textMuted),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      KitCard(
        padding: const EdgeInsets.symmetric(horizontal: Space.s4, vertical: Space.s3),
        child: Row(children: [
          Expanded(
            child: Text.rich(TextSpan(text: 'Thème actuel : ', children: [
              TextSpan(text: context.isDark ? 'sombre' : 'clair', style: const TextStyle(fontWeight: FontWeight.w700)),
            ])),
          ),
          OutlinedButton.icon(
            onPressed: ThemeController.instance.toggle,
            icon: Icon(context.isDark ? Icons.light_mode : Icons.dark_mode, size: 18),
            label: const Text('Basculer'),
          ),
        ]),
      ),
      _sub(context, 'Marque'),
      ResponsiveGrid(minItemWidth: 150, spacing: 10, children: [for (final s in brand) _Swatch(s.$1, s.$2, s.$3, note: s.$4)]),
      _sub(context, 'Sémantique'),
      ResponsiveGrid(minItemWidth: 150, spacing: 10, children: [for (final s in semantic) _Swatch(s.$1, s.$2, s.$3)]),
      _sub(context, 'Surfaces & texte'),
      ResponsiveGrid(minItemWidth: 150, spacing: 10, children: [for (final s in surfaces) _Swatch(s.$1, s.$2, s.$3, bordered: true)]),
      _sub(context, 'Badges de statut'),
      const DemoWrap(spacing: 8, children: [
        StatusBadge('success', tone: KitTone.success), StatusBadge('warning', tone: KitTone.warning), StatusBadge('error', tone: KitTone.error),
        StatusBadge('info', tone: KitTone.info), StatusBadge('purple', tone: KitTone.purple), StatusBadge('cyan', tone: KitTone.cyan),
        StatusBadge('neutral'),
      ]),
    ]);
  }

  Widget _sub(BuildContext context, String t) => Padding(
        padding: const EdgeInsets.only(top: Space.s5, bottom: Space.s3),
        child: Text(t, style: context.t.h4),
      );
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.name, this.token, this.color, {this.note, this.bordered = false});
  final String name, token;
  final Color color;
  final String? note;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final hex = _hex(color);
    return KitCard(
      onTap: () => copyToClipboard(context, hex, label: '« $hex » copié ($token)'),
      padding: const EdgeInsets.all(Space.s3),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          height: 44,
          decoration: BoxDecoration(color: color, borderRadius: Radii.rm, border: bordered ? Border.all(color: c.textMuted.withValues(alpha: 0.3)) : null),
        ),
        const SizedBox(height: 8),
        Text(name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.textPrimary)),
        Text('kc.$token', style: TextStyle(fontFamily: Fonts.mono, fontSize: 10.5, color: c.textSecondary)),
        Text(hex, style: TextStyle(fontFamily: Fonts.mono, fontSize: 10.5, color: c.textMuted)),
        if (note != null) Text(note!, style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: c.textMuted)),
      ]),
    );
  }
}

class _TypeScale extends StatelessWidget {
  const _TypeScale();

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final t = context.t;
    final rows = <(String, Widget)>[
      ('h1 · 32/700', Text('Référentiel unique', style: t.h1)),
      ('Titre de page · Outfit 22', Text('Registre des Produits', style: t.pageTitle)),
      ('h2 · 24/600', Text('Tableau de bord Finance', style: t.h2)),
      ('h3 · 20/600', Text('Informations générales', style: t.h3)),
      ('Titre de carte · Outfit 16', Text('Abonnement Standard', style: t.cardTitle)),
      ('Corps · Inter 14', Text('Le client signale une perte de signal récurrente entre 18h et 20h sur l’axe Yopougon–Abobo.', style: t.body)),
      ('Secondaire · 13', Text('Catalogue des offres : tarifs d’installation, d’abonnement et de désinstallation.', style: t.bodySm)),
      ('Libellé · 12/600', Text('Raison sociale', style: t.label)),
      ('En-tête de table · 11/700', Text('CODE CLIENT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: c.textSecondary))),
      ('Code · Space Mono 11', Text('FAC-2026-0912', style: t.mono.copyWith(fontSize: 11.5, color: c.primary))),
      ('Montant · tabulaire', Text('1 245 000 F CFA', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, fontFeatures: KitText.tabular, color: c.textPrimary))),
      ('Marque · TT Wellingtons', Text('Lookas', style: KitText.brand.copyWith(fontSize: 22, color: c.primary))),
    ];
    return KitCard(
      padding: EdgeInsets.zero,
      child: Column(children: [
        for (var i = 0; i < rows.length; i++)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: Space.s4, vertical: Space.s3),
            decoration: BoxDecoration(border: i == 0 ? null : Border(top: BorderSide(color: c.divider))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(rows[i].$1, style: TextStyle(fontFamily: Fonts.mono, fontSize: 10.5, color: c.textMuted)),
              const SizedBox(height: 4),
              rows[i].$2,
            ]),
          ),
      ]),
    );
  }
}

class _Spacing extends StatelessWidget {
  const _Spacing();

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    const spaces = [('xs', Space.xs), ('s', Space.s), ('m', Space.m), ('l', Space.l), ('xl', Space.xl), ('xxl', Space.xxl)];
    return Demo(
      label: 'Échelle d’espacement',
      code: 'const SizedBox(height: Space.m); // 16\nPadding(padding: EdgeInsets.all(Space.l)) // 24',
      child: Column(children: [
        for (final (n, v) in spaces)
          InkWell(
            onTap: () => copyToClipboard(context, 'Space.$n'),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: Space.s2),
              child: Row(children: [
                SizedBox(width: 82, child: Text('Space.$n', style: TextStyle(fontFamily: Fonts.mono, fontSize: 11, color: c.textSecondary))),
                Container(width: v * 3, height: 14, decoration: BoxDecoration(color: c.primary.withValues(alpha: 0.75), borderRadius: Radii.rs)),
                const SizedBox(width: 10),
                Text('${v.toInt()} px', style: TextStyle(fontSize: 12, color: c.textMuted)),
              ]),
            ),
          ),
      ]),
    );
  }
}

class _RadiiDemo extends StatelessWidget {
  const _RadiiDemo();

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final b = Theme.of(context).brightness;
    const radii = [('Radii.s', Radii.s, '4'), ('Radii.m', Radii.m, '12'), ('Radii.l', Radii.l, '24'), ('Radii.full', 999.0, '9999')];
    Widget box(Widget child, {double radius = 12, List<BoxShadow>? shadow}) => Container(
          height: 72,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(radius),
            border: shadow == null ? Border.all(color: c.primary.withValues(alpha: 0.5), width: 1.5) : null,
            boxShadow: shadow,
          ),
          child: child,
        );
    return Demo(
      label: 'Rayons & ombres',
      child: Column(children: [
        Row(children: [
          for (final (n, r, px) in radii)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(Space.s1),
                child: InkWell(
                  onTap: () => copyToClipboard(context, n),
                  child: box(
                    Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(n.split('.').last, style: TextStyle(fontFamily: Fonts.mono, fontSize: 11, color: c.textSecondary)),
                      Text('$px px', style: TextStyle(fontSize: 10.5, color: c.textMuted)),
                    ]),
                    radius: r,
                  ),
                ),
              ),
            ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: Padding(padding: const EdgeInsets.all(Space.s2), child: box(Text('elevation-1', style: TextStyle(fontFamily: Fonts.mono, fontSize: 11, color: c.textSecondary)), shadow: Elevations.e1(b)))),
          Expanded(child: Padding(padding: const EdgeInsets.all(Space.s2), child: box(Text('elevation-3', style: TextStyle(fontFamily: Fonts.mono, fontSize: 11, color: c.textSecondary)), shadow: Elevations.e3(b)))),
        ]),
      ]),
    );
  }
}

class _IconGrid extends StatefulWidget {
  const _IconGrid();

  @override
  State<_IconGrid> createState() => _IconGridState();
}

class _IconGridState extends State<_IconGrid> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final q = _q.trim().toLowerCase();
    final icons = kMaterialIcons.entries.where((e) => q.isEmpty || e.key.contains(q)).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Expanded(
          child: TextField(
            onChanged: (v) => setState(() => _q = v),
            decoration: const InputDecoration(hintText: 'Filtrer les icônes…', prefixIcon: Icon(Icons.search, size: 20)),
          ),
        ),
        const SizedBox(width: 12),
        Text('${icons.length} icône(s)', style: TextStyle(fontSize: 12, color: c.textMuted)),
      ]),
      const SizedBox(height: 12),
      if (icons.isEmpty)
        const EmptyState(compact: true, icon: Icons.search_off, title: 'Aucune icône', subtitle: 'Essayez un autre mot-clé.')
      else
        LayoutBuilder(builder: (context, cons) {
          final cols = (cons.maxWidth / 92).floor().clamp(3, 10);
          return GridView.count(
            crossAxisCount: cols,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1,
            children: [
              for (final e in icons)
                Material(
                  color: c.card,
                  shape: RoundedRectangleBorder(borderRadius: Radii.rm),
                  child: InkWell(
                    borderRadius: Radii.rm,
                    onTap: () => copyToClipboard(context, 'Icon(Icons.${e.key})', label: '« ${e.key} » copié'),
                    child: Padding(
                      padding: const EdgeInsets.all(Space.s2),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(e.value, color: c.textPrimary),
                        const SizedBox(height: 6),
                        Text(e.key, maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9.5, color: c.textMuted)),
                      ]),
                    ),
                  ),
                ),
            ],
          );
        }),
    ]);
  }
}

class _Catalog extends StatelessWidget {
  const _Catalog();

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final shell = KitShell.of(context);
    Widget card(IconData icon, String title, String desc, VoidCallback onTap) => KitCard(
          onTap: onTap,
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(shape: BoxShape.circle, color: c.primaryLight),
              child: Icon(icon, size: 20, color: c.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: c.textPrimary)),
                const SizedBox(height: 2),
                Text(desc, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: c.textSecondary)),
              ]),
            ),
          ]),
        );
    return ResponsiveGrid(minItemWidth: 280, spacing: 10, children: [
      for (final cat in kCategories) card(cat.icon, cat.label, cat.description, () => openCategory(context, cat)),
      card(Icons.view_compact, 'Layouts', 'Shell mobile, fiche détail, authentification, bottom sheets, dialogs, catalogue.', () => shell?.select(2)),
      card(Icons.auto_awesome, 'Harnais', 'Assistant IA simulé qui répond avec des widgets : cartes, graphiques, formulaires, planning…', () => shell?.select(3)),
    ]);
  }
}
