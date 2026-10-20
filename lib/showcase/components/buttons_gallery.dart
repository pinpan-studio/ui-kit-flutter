import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/snack.dart';
import '../../theme/kit_colors.dart';
import '../../widgets/common.dart';
import '../../widgets/kit_buttons.dart';
import '../doc/doc.dart';
import 'package:ui_kit_flutter/theme/tokens.dart';

/// `/components/buttons` — variantes, états, icônes, actions de page, segmentés, menus, FAB, tailles.
class ButtonsGallery extends StatefulWidget {
  const ButtonsGallery({super.key, this.initialSection});
  final String? initialSection;

  @override
  State<ButtonsGallery> createState() => _ButtonsGalleryState();
}

class _ButtonsGalleryState extends State<ButtonsGallery> {
  String? _loading;
  ViewMode _view = ViewMode.card;
  String _period = 'month';
  String _tab = 'mois';
  String _range = 'day';
  String _chip = 'all';

  void _simulate(String key) {
    setState(() => _loading = key);
    Timer(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _loading = null);
    });
  }

  void _tap(String what) => showKitSnack(context, what);

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return DocPage(
      title: 'Boutons',
      icon: Icons.smart_button,
      initialSection: widget.initialSection,
      subtitle: 'Boutons Material 3 du projet (FilledButton primaire majoritaire, bouton « create » des en-têtes de liste, contour, warn) et variantes maison (refresh, toggles segmentés, chips de filtre). Cibles tactiles ≥ 40 px.',
      sections: [
        DocSection(
          id: 'variants',
          title: 'Variantes',
          source: 'KitButton(variant: …)',
          description: 'Primary = flat primaire ; Secondary = contour primaire ; Outline = contour neutre ; Ghost = texte ; Danger = warn. « Success » dérive des jetons success.',
          children: [
            Demo(
              label: 'Toutes les variantes',
              code: '''KitButton(label: 'Primary', onPressed: save)
KitButton(label: 'Secondary', variant: KitButtonVariant.secondary, onPressed: …)
KitButton(label: 'Danger', variant: KitButtonVariant.danger, onPressed: …)''',
              child: DemoWrap(children: [
                for (final (l, v) in const [
                  ('Primary', KitButtonVariant.primary), ('Raised', KitButtonVariant.raised), ('Secondary', KitButtonVariant.secondary),
                  ('Outline', KitButtonVariant.outline), ('Ghost', KitButtonVariant.ghost), ('Danger', KitButtonVariant.danger),
                  ('Danger outline', KitButtonVariant.dangerOutline), ('Success', KitButtonVariant.success), ('Tertiary', KitButtonVariant.tertiary),
                ])
                  KitButton(label: l, variant: v, onPressed: () => _tap(l)),
              ]),
            ),
            Demo(
              label: 'Avec icône (Icon + Text)',
              child: DemoWrap(children: [
                KitButton(label: 'Enregistrer', icon: Icons.save, onPressed: () => _tap('Enregistré')),
                KitButton(label: 'Modifier', icon: Icons.edit, variant: KitButtonVariant.secondary, onPressed: () {}),
                KitButton(label: 'Exporter', icon: Icons.file_download, variant: KitButtonVariant.outline, onPressed: () {}),
                KitButton(label: 'Voir', icon: Icons.visibility, variant: KitButtonVariant.ghost, onPressed: () {}),
                KitButton(label: 'Supprimer', icon: Icons.delete, variant: KitButtonVariant.dangerOutline, onPressed: () {}),
                KitButton(label: 'Valider', icon: Icons.check_circle, variant: KitButtonVariant.success, onPressed: () {}),
                KitButton(label: 'Fiche produit', iconEnd: Icons.arrow_forward, variant: KitButtonVariant.ghost, onPressed: () {}),
              ]),
            ),
          ],
        ),
        DocSection(
          id: 'states',
          title: 'États',
          description: 'Désactivé, chargement (spinner intégré — touchez pour simuler), pleine largeur.',
          cols: 2,
          children: [
            const Demo(
              label: 'Disabled',
              child: DemoWrap(children: [
                KitButton(label: 'Primary'),
                KitButton(label: 'Outline', variant: KitButtonVariant.outline),
                KitButton(label: 'Ghost', variant: KitButtonVariant.ghost),
                IconButton(onPressed: null, icon: Icon(Icons.delete)),
              ]),
            ),
            Demo(
              label: 'Loading',
              hint: 'touchez',
              code: '''KitButton(
  label: 'Enregistrer',
  loadingLabel: 'Enregistrement…',
  icon: Icons.save,
  loading: saving,
  onPressed: save,
)''',
              child: DemoWrap(children: [
                KitButton(label: 'Enregistrer', loadingLabel: 'Enregistrement…', icon: Icons.save, loading: _loading == 'save', onPressed: () => _simulate('save')),
                KitButton(label: 'Synchroniser', icon: Icons.sync, variant: KitButtonVariant.secondary, loading: _loading == 'sync', onPressed: () => _simulate('sync')),
                _SpinningRefresh(spinning: _loading == 'refresh', onTap: () => _simulate('refresh')),
              ]),
            ),
            Demo(
              label: 'Pleine largeur (dialogs, auth)',
              child: Gap([
                KitButton(label: 'Accepter et continuer', expand: true, onPressed: () {}),
                KitButton(label: 'Connectez-vous par e-mail', variant: KitButtonVariant.secondary, expand: true, onPressed: () {}),
              ]),
            ),
            Demo(
              label: 'Connexion Google',
              child: Align(
                alignment: Alignment.centerLeft,
                child: KitButton(label: 'Se connecter avec Google', icon: Icons.login, variant: KitButtonVariant.raised, onPressed: () {}),
              ),
            ),
          ],
        ),
        DocSection(
          id: 'icon',
          title: 'Icon buttons',
          source: 'IconButton · RoundIconButton',
          cols: 3,
          children: [
            Demo(
              label: 'Icon button',
              code: "IconButton(tooltip: 'Modifier', icon: const Icon(Icons.edit), onPressed: edit)",
              child: DemoWrap(children: [
                IconButton(tooltip: 'Modifier', onPressed: () {}, icon: const Icon(Icons.edit)),
                IconButton(tooltip: 'Ajouter', color: c.primary, onPressed: () {}, icon: const Icon(Icons.add_circle)),
                IconButton(tooltip: 'Supprimer', color: c.error, onPressed: () {}, icon: const Icon(Icons.delete)),
                IconButton.filledTonal(tooltip: 'Options', onPressed: () {}, icon: const Icon(Icons.more_vert)),
              ]),
            ),
            Demo(
              label: 'refresh-btn',
              child: DemoWrap(children: [
                RoundIconButton(icon: Icons.refresh, tooltip: 'Rafraîchir', onPressed: () {}),
                RoundIconButton(icon: Icons.tune, tooltip: 'Filtres', onPressed: () {}),
                RoundIconButton(icon: Icons.file_download, tooltip: 'Exporter', onPressed: () {}),
                RoundIconButton(icon: Icons.filter_alt, tooltip: 'Filtre actif', active: true, onPressed: () {}),
              ]),
            ),
            Demo(
              label: 'Toolbar (shell)',
              child: Row(children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
                const Spacer(),
                IconButton(onPressed: () {}, icon: const Icon(Icons.dark_mode_outlined)),
                IconButton(onPressed: () {}, icon: const Badge(label: Text('7'), backgroundColor: null, child: Icon(Icons.checklist))),
                IconButton(onPressed: () {}, icon: const Badge(label: Text('3'), child: Icon(Icons.notifications_outlined))),
                const KitAvatar(name: 'Jean Kouassi', size: 32),
              ]),
            ),
          ],
        ),
        DocSection(
          id: 'header',
          title: 'Actions de page',
          source: 'PageHeader(actions: …)',
          description: 'Groupe d’actions des pages liste : bascule cartes/liste, rafraîchir, créer, suppression groupée. Sur mobile, il passe sous le titre et revient à la ligne.',
          children: [
            Demo(
              label: 'En-tête de liste',
              code: '''PageHeader(
  breadcrumb: 'Catalogue',
  title: 'Produits',
  actions: [
    ViewModeToggle(mode: mode, onChanged: setMode),
    RoundIconButton(icon: Icons.refresh, onPressed: reload),
    KitButton(label: 'Nouveau produit', icon: Icons.add,
      variant: KitButtonVariant.raised, size: KitButtonSize.create,
      shape: KitButtonShape.rounded, onPressed: create),
  ],
)''',
              child: PageHeader(
                breadcrumb: 'Catalogue',
                title: 'Produits',
                subtitle: '128 produits référencés',
                actions: [
                  ViewModeToggle(mode: _view, onChanged: (m) => setState(() => _view = m)),
                  RoundIconButton(icon: Icons.refresh, tooltip: 'Rafraîchir', onPressed: () {}),
                  KitButton(label: 'Nouveau produit', icon: Icons.add, variant: KitButtonVariant.raised, size: KitButtonSize.create, shape: KitButtonShape.rounded, onPressed: () => demoAction(context, 'Création')),
                  KitButton(label: '(3)', icon: Icons.delete, variant: KitButtonVariant.dangerOutline, onPressed: () {}),
                ],
              ),
            ),
            Demo(
              label: 'En-tête de fiche (détail)',
              child: Row(children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_back)),
                const Spacer(),
                IconButton.outlined(tooltip: 'Modifier', onPressed: () {}, icon: const Icon(Icons.edit)),
                const SizedBox(width: 6),
                IconButton.outlined(tooltip: 'Supprimer', color: c.error, onPressed: () {}, icon: const Icon(Icons.delete)),
                const SizedBox(width: 6),
                KitButton(label: 'Envoyer', icon: Icons.send, onPressed: () {}),
              ]),
            ),
          ],
        ),
        DocSection(
          id: 'segmented',
          title: 'Segmentés & toggles',
          source: 'SegmentedToggle · SegmentedButton · FilterChipButton',
          cols: 3,
          children: [
            Demo(
              label: 'm3-filter-toggle',
              code: '''SegmentedToggle<String>(
  value: period,
  onChanged: setPeriod,
  options: const [('month', 'Mois', null), ('quarter', 'Trimestre', null), ('year', 'Année', null)],
)''',
              child: Align(
                alignment: Alignment.centerLeft,
                child: SegmentedToggle<String>(
                  value: _period,
                  onChanged: (v) => setState(() => _period = v),
                  options: const [('month', 'Mois', null), ('quarter', 'Trimestre', null), ('year', 'Année', null)],
                ),
              ),
            ),
            Demo(
              label: 'chart-tab-toggles',
              child: Wrap(children: [
                for (final (k, l) in const [('mois', 'Mois'), ('trim', 'Trimestre'), ('annee', 'Année')])
                  Padding(
                    padding: const EdgeInsets.only(right: Space.s2),
                    child: ChoiceChip(label: Text(l), selected: _tab == k, onSelected: (_) => setState(() => _tab = k), showCheckmark: false),
                  ),
              ]),
            ),
            Demo(
              label: 'ViewModeToggle',
              child: Wrap(spacing: 12, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
                ViewModeToggle(mode: _view, onChanged: (m) => setState(() => _view = m)),
                Text('mode = ${_view.name}', style: TextStyle(fontSize: 12, color: c.textMuted)),
              ]),
            ),
            Demo(
              label: 'Chips de filtre',
              hint: '.filter-chip',
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  for (final (k, l, n, t) in const [
                    ('all', 'Tous', 48, KitTone.primary), ('ok', 'Actifs', 31, KitTone.success),
                    ('plan', 'Planifiés', 6, KitTone.warning), ('out', 'Désinstallés', 4, KitTone.error),
                  ])
                    Padding(
                      padding: const EdgeInsets.only(right: Space.s2),
                      child: FilterChipButton(label: l, count: n, tone: t, active: _chip == k, onTap: () => setState(() => _chip = k)),
                    ),
                ]),
              ),
            ),
            Demo(
              label: 'SegmentedButton (M3)',
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'day', label: Text('Jour')),
                  ButtonSegment(value: 'week', label: Text('Semaine')),
                  ButtonSegment(value: 'month', label: Text('Mois')),
                ],
                selected: {_range},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setState(() => _range = s.first),
              ),
            ),
            Demo(
              label: 'Lien d’action (.line-action)',
              child: Align(alignment: Alignment.centerLeft, child: LineAction('Voir l’historique', onTap: () {})),
            ),
          ],
        ),
        DocSection(
          id: 'menu',
          title: 'Menu & split',
          source: 'PopupMenuButton · SplitButton',
          cols: 2,
          children: [
            Demo(
              label: 'Bouton menu',
              code: '''PopupMenuButton<String>(
  onSelected: export,
  itemBuilder: (_) => const [
    PopupMenuItem(value: 'xlsx', child: Text('Excel')),
    PopupMenuItem(value: 'pdf', child: Text('PDF')),
  ],
  child: …,
)''',
              child: Align(
                alignment: Alignment.centerLeft,
                child: PopupMenuButton<String>(
                  onSelected: (v) => v == 'del' ? showKitSnack(context, 'Supprimé (démo)', kind: SnackKind.error) : demoAction(context, 'Export $v'),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'Excel', child: ListTile(leading: Icon(Icons.table_view), title: Text('Excel'))),
                    const PopupMenuItem(value: 'PDF', child: ListTile(leading: Icon(Icons.picture_as_pdf), title: Text('PDF'))),
                    const PopupMenuDivider(),
                    PopupMenuItem(value: 'del', child: ListTile(leading: Icon(Icons.delete, color: c.error), title: Text('Supprimer', style: TextStyle(color: c.error)))),
                  ],
                  child: const IgnorePointer(
                    child: KitButton(label: 'Exporter', icon: Icons.file_download, iconEnd: Icons.expand_more, variant: KitButtonVariant.outline, onPressed: _noop),
                  ),
                ),
              ),
            ),
            Demo(
              label: 'Split button',
              child: Align(
                alignment: Alignment.centerLeft,
                child: SplitButton(
                  label: 'Envoyer',
                  icon: Icons.send,
                  onPressed: () => showKitSnack(context, 'Envoyé (démo)', kind: SnackKind.success),
                  items: const [('Programmer l’envoi', Icons.schedule_send), ('Enregistrer en brouillon', Icons.drafts)],
                  onSelected: (v) => showKitSnack(context, v),
                ),
              ),
            ),
          ],
        ),
        DocSection(
          id: 'fab',
          title: 'FAB',
          source: 'FloatingActionButton',
          description: 'Sur mobile, le FAB porte l’action principale de l’écran (création), en bas à droite au-dessus de la barre de navigation.',
          cols: 2,
          children: [
            Demo(
              label: 'FAB',
              child: DemoWrap(spacing: 16, children: [
                FloatingActionButton(heroTag: null, onPressed: () {}, tooltip: 'Ajouter', child: const Icon(Icons.add)),
                FloatingActionButton.small(heroTag: null, onPressed: () {}, child: const Icon(Icons.edit)),
                FloatingActionButton.extended(heroTag: null, onPressed: () {}, icon: const Icon(Icons.add), label: const Text('Nouvelle mission')),
              ]),
            ),
            Demo(
              label: 'Bouton d’action principale (shell)',
              hint: '.action-main-btn',
              child: Align(
                alignment: Alignment.centerLeft,
                child: KitButton(label: 'Action rapide', icon: Icons.bolt, variant: KitButtonVariant.secondary, onPressed: () {}),
              ),
            ),
          ],
        ),
        DocSection(
          id: 'sizes',
          title: 'Tailles & formes',
          description: 'Hauteurs : compact 32, standard 40, create 42, large 48. Rayons : pilule (radius-button), 10 px (create-btn).',
          cols: 2,
          children: [
            Demo(
              label: 'Hauteurs',
              child: DemoWrap(children: [
                KitButton(label: 'Compact', size: KitButtonSize.compact, onPressed: () {}),
                KitButton(label: 'Standard', onPressed: () {}),
                KitButton(label: 'create-btn', size: KitButtonSize.create, shape: KitButtonShape.rounded, variant: KitButtonVariant.raised, onPressed: () {}),
                KitButton(label: 'Large', size: KitButtonSize.large, onPressed: () {}),
              ]),
            ),
            Demo(
              label: 'Formes',
              child: DemoWrap(children: [
                KitButton(label: 'Pilule (M3)', onPressed: () {}),
                KitButton(label: 'Rayon 10 px', shape: KitButtonShape.rounded, variant: KitButtonVariant.raised, onPressed: () {}),
                KitButton(label: 'Contour arrondi', variant: KitButtonVariant.secondary, onPressed: () {}),
              ]),
            ),
          ],
        ),
      ],
    );
  }
}

void _noop() {}

class _SpinningRefresh extends StatefulWidget {
  const _SpinningRefresh({required this.spinning, required this.onTap});
  final bool spinning;
  final VoidCallback onTap;

  @override
  State<_SpinningRefresh> createState() => _SpinningRefreshState();
}

class _SpinningRefreshState extends State<_SpinningRefresh> with SingleTickerProviderStateMixin {
  late final _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  @override
  void didUpdateWidget(covariant _SpinningRefresh old) {
    super.didUpdateWidget(old);
    widget.spinning ? _ctrl.repeat() : _ctrl.reset();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return Tooltip(
      message: 'Rafraîchir',
      child: Material(
        color: c.card,
        shape: CircleBorder(side: BorderSide(color: c.border)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: widget.onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: RotationTransition(turns: _ctrl, child: Icon(Icons.refresh, size: 20, color: c.textSecondary)),
          ),
        ),
      ),
    );
  }
}
