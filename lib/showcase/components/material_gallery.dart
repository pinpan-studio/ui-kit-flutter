import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/snack.dart';
import '../../data/showcase_data.dart';
import '../../theme/kit_colors.dart';
import '../../theme/kit_text.dart';
import '../../theme/tokens.dart';
import '../../widgets/common.dart';
import '../../widgets/fields/basic_fields.dart';
import '../../widgets/media/demo_art.dart';
import '../doc/doc.dart';

/// `/components/material` — Accordion, Tree, Drag & drop, Chips input, Card, Grid list,
/// Bottom sheet, Virtual scroll, Ripple : composants Material / Flutter, données locales.
class MaterialGallery extends StatefulWidget {
  const MaterialGallery({super.key, this.initialSection});
  final String? initialSection;

  @override
  State<MaterialGallery> createState() => _MaterialGalleryState();
}

class _MaterialGalleryState extends State<MaterialGallery> {
  int? _openPanel = 0;
  final Set<String> _treeOpen = {'src', 'app'};
  String? _treeSel;
  final List<String> _order = ['Vérifier l’alimentation 12 V', 'Fixer le boîtier', 'Brancher le relais', 'Positionner l’antenne', 'Tester la remontée GPS'];
  final List<String> _todo = ['Balise CI-4521-AB', 'Sonde carburant SOTRA', 'Caméra Actros'];
  final List<String> _done = ['Firmware 12 balises'];
  List<String> _chips = ['Abidjan', 'Poids lourds', 'Premium'];
  int _virtualTap = -1;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return DocPage(
      title: 'Material',
      icon: Icons.extension,
      initialSection: widget.initialSection,
      subtitle: 'Composants Material de Flutter habillés aux couleurs du kit : accordéon, arbre, glisser-déposer, saisie de puces, cartes, grille, feuille basse, liste virtualisée et effet d’ondulation — tous interactifs, données locales.',
      sections: [
        DocSection(
          id: 'accordion',
          title: 'Accordion / Expansion panel',
          source: 'ExpansionPanelList.radio · ExpansionTile',
          cols: 2,
          children: [
            Demo(
              label: 'Panneau unique ouvert',
              flush: true,
              child: ExpansionPanelList(
                elevation: 0,
                expandedHeaderPadding: EdgeInsets.zero,
                materialGapSize: 0,
                dividerColor: c.border,
                expansionCallback: (i, open) => setState(() => _openPanel = open ? i : null),
                children: [
                  for (final (i, (t, ic, body)) in const [
                    ('Informations client', Icons.business, 'Transports Yao & Fils · CLI-1040 · Abidjan, Yopougon'),
                    ('Contrat', Icons.description, 'Premium — Flotte · 24 véhicules · échéance 28/02/2027'),
                    ('Facturation', Icons.receipt_long, 'Virement à 30 jours · 1 250 000 FCFA / mois'),
                  ].indexed)
                    ExpansionPanel(
                      canTapOnHeader: true,
                      backgroundColor: c.card,
                      isExpanded: _openPanel == i,
                      headerBuilder: (_, open) => ListTile(leading: Icon(ic, color: open ? c.primary : c.textSecondary), title: Text(t, style: TextStyle(fontWeight: FontWeight.w600, color: open ? c.primary : c.textPrimary))),
                      body: Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: Text(body, style: TextStyle(color: c.textSecondary))),
                    ),
                ],
              ),
            ),
            Demo(
              label: 'FAQ (multiples)',
              flush: true,
              child: Column(children: [
                for (final (q, a) in const [
                  ('Comment réinitialiser une balise ?', 'Envoyez la commande « cpureset » depuis la fiche équipement, ou coupez l’alimentation 30 s.'),
                  ('Quelle est la précision GPS ?', 'Entre 2 et 5 m en zone dégagée ; jusqu’à 15 m en milieu urbain dense.'),
                  ('Puis-je exporter l’historique ?', 'Oui, au format XLSX ou CSV depuis l’onglet Trajets (90 jours glissants).'),
                ])
                  ExpansionTile(title: Text(q, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)), childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14), expandedAlignment: Alignment.centerLeft, children: [Text(a, style: TextStyle(color: c.textSecondary))]),
              ]),
            ),
          ],
        ),
        DocSection(
          id: 'tree',
          title: 'Tree',
          source: 'arbre déroulant (TreeNodeData)',
          children: [
            Demo(
              label: 'Explorateur de fichiers',
              hint: _treeSel,
              flush: true,
              child: Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Column(children: [for (final n in kFilesTree) ..._treeNode(c, n, 0)])),
            ),
          ],
        ),
        DocSection(
          id: 'drag-drop',
          title: 'Drag & drop',
          source: 'ReorderableListView · LongPressDraggable / DragTarget',
          description: 'Réordonner avec la poignée ; déplacer une carte entre deux listes par appui long.',
          cols: 2,
          children: [
            Demo(
              label: 'Réordonner (checklist de pose)',
              flush: true,
              child: ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                onReorder: (a, b) => setState(() {
                  if (b > a) b--;
                  _order.insert(b, _order.removeAt(a));
                }),
                children: [
                  for (final (i, t) in _order.indexed)
                    ListTile(
                      key: ValueKey(t),
                      leading: CircleAvatar(radius: 13, backgroundColor: c.primaryLight, child: Text('${i + 1}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.primary))),
                      title: Text(t),
                      trailing: ReorderableDragStartListener(index: i, child: Icon(Icons.drag_indicator, color: c.textMuted)),
                    ),
                ],
              ),
            ),
            Demo(
              label: 'Entre deux listes',
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: _dropList(c, 'À faire', _todo, _done, KitTone.warning)),
                const SizedBox(width: 10),
                Expanded(child: _dropList(c, 'Terminé', _done, _todo, KitTone.success)),
              ]),
            ),
          ],
        ),
        DocSection(
          id: 'chips-input',
          title: 'Chips input',
          source: 'TagInput · InputChip',
          children: [
            Demo(
              label: 'Critères de segmentation',
              child: TagInput(tags: _chips, suggestions: const ['Abidjan', 'Bouaké', 'Poids lourds', 'Utilitaires', 'Premium', 'Essentiel', 'Impayés'], onChanged: (v) => setState(() => _chips = v)),
            ),
          ],
        ),
        DocSection(
          id: 'card',
          title: 'Card',
          source: 'Card (elevated · filled · outlined)',
          cols: 3,
          children: [
            Demo(
              label: 'Elevated',
              muted: true,
              child: Card.filled(
                color: c.card,
                elevation: 2,
                child: ListTile(leading: const Icon(Icons.local_shipping), title: const Text('Toyota Hilux'), subtitle: const Text('CI-1024-AB'), trailing: IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert))),
              ),
            ),
            Demo(
              label: 'Média + actions',
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  const SizedBox(height: 110, child: DemoArt(seed: 0, label: 'Dépôt de Koumassi')),
                  const ListTile(title: Text('Dépôt de Koumassi'), subtitle: Text('12 véhicules · 3 techniciens')),
                  OverflowBar(alignment: MainAxisAlignment.end, children: [TextButton(onPressed: () {}, child: const Text('Itinéraire')), TextButton(onPressed: () {}, child: const Text('Détails'))]),
                ]),
              ),
            ),
            Demo(
              label: 'Outlined',
              child: Card.outlined(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('ABONNEMENT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: c.textMuted)),
                    const SizedBox(height: 4),
                    Text('Premium — Flotte', style: context.t.cardTitle),
                    const SizedBox(height: 6),
                    const KitProgressBar(value: 0.62),
                    const SizedBox(height: 4),
                    Text('62 % de la période écoulée', style: TextStyle(fontSize: 12, color: c.textSecondary)),
                  ]),
                ),
              ),
            ),
          ],
        ),
        DocSection(
          id: 'grid-list',
          title: 'Grid list',
          source: 'GridView + GridTile',
          children: [
            Demo(
              label: 'Sites clients',
              child: GridView.count(
                crossAxisCount: MediaQuery.sizeOf(context).width >= Breakpoints.tablet ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: [
                  for (var i = 0; i < 6; i++)
                    ClipRRect(
                      borderRadius: Radii.rm,
                      child: GridTile(
                        footer: GridTileBar(backgroundColor: Colors.black45, title: Text(kVilles[i]), subtitle: Text('${3 + i * 2} sites'), trailing: const Icon(Icons.chevron_right, color: Colors.white)),
                        child: DemoArt(seed: i),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        DocSection(
          id: 'bottom-sheet',
          title: 'Bottom sheet',
          source: 'showModalBottomSheet',
          cols: 2,
          children: [
            Demo(
              label: 'Partage',
              child: Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.tonalIcon(
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    builder: (ctx) => SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Partager le rapport', style: TextStyle(fontFamily: Fonts.heading, fontSize: 18, fontWeight: FontWeight.w600, color: c.textPrimary)),
                          const SizedBox(height: 16),
                          Wrap(spacing: 20, runSpacing: 16, children: [
                            for (final (l, ic, t) in const [('E-mail', Icons.mail, KitTone.info), ('WhatsApp', Icons.chat, KitTone.success), ('SMS', Icons.sms, KitTone.warning), ('Lien', Icons.link, KitTone.purple), ('Imprimer', Icons.print, KitTone.neutral)])
                              InkWell(
                                onTap: () {
                                  Navigator.pop(ctx);
                                  demoAction(context, 'Partage par $l');
                                },
                                child: Column(children: [
                                  CircleAvatar(radius: 26, backgroundColor: t.light(c), child: Icon(ic, color: t.color(c))),
                                  const SizedBox(height: 6),
                                  Text(l, style: const TextStyle(fontSize: 12)),
                                ]),
                              ),
                          ]),
                        ]),
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('Partager'),
                ),
              ),
            ),
            Demo(
              label: 'Feuille persistante (aperçu)',
              flush: true,
              child: SizedBox(
                height: 220,
                child: Stack(children: [
                  const Positioned.fill(child: DemoArt(seed: 5)),
                  DraggableScrollableSheet(
                    initialChildSize: 0.35,
                    minChildSize: 0.2,
                    maxChildSize: 0.95,
                    builder: (ctx, sc) => Material(
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(Radii.l)),
                      elevation: 6,
                      child: ListView(controller: sc, padding: const EdgeInsets.fromLTRB(16, 8, 16, 16), children: [
                        Center(child: Container(width: 32, height: 4, decoration: BoxDecoration(color: c.textMuted, borderRadius: Radii.pill))),
                        const SizedBox(height: 8),
                        Text('8 véhicules à proximité', style: TextStyle(fontWeight: FontWeight.w700, color: c.textPrimary)),
                        for (final x in kDemoClients.take(6)) ListTile(dense: true, contentPadding: EdgeInsets.zero, leading: const Icon(Icons.local_shipping_outlined), title: Text(x.raisonSociale)),
                      ]),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
        DocSection(
          id: 'virtual-scroll',
          title: 'Virtual scroll',
          source: 'ListView.builder (itemExtent fixe)',
          description: '10 000 positions GPS : seules les lignes visibles sont construites.',
          children: [
            Demo(
              label: '10 000 lignes',
              hint: _virtualTap < 0 ? null : 'ligne ${Fmt.number(_virtualTap + 1)}',
              flush: true,
              child: SizedBox(
                height: 280,
                child: Scrollbar(
                  child: ListView.builder(
                    itemCount: 10000,
                    itemExtent: 52,
                    itemBuilder: (_, i) {
                      final t = DateTime(2026, 10, 15).add(Duration(seconds: i * 30));
                      final speed = (i * 37) % 95;
                      return ListTile(
                        dense: true,
                        selected: i == _virtualTap,
                        selectedTileColor: c.primaryLight,
                        onTap: () => setState(() => _virtualTap = i),
                        leading: Text('#${Fmt.number(i + 1)}', style: TextStyle(fontFamily: Fonts.mono, fontSize: 11, color: c.textMuted)),
                        title: Text('${(5.30 + (i % 97) / 1000).toStringAsFixed(4)}, ${(-4.01 - (i % 89) / 1000).toStringAsFixed(4)}', style: const TextStyle(fontFamily: Fonts.mono, fontSize: 12.5)),
                        subtitle: Text(Fmt.dateTime(t)),
                        trailing: StatusBadge('$speed km/h', tone: speed > 80 ? KitTone.error : (speed == 0 ? KitTone.neutral : KitTone.success), uppercase: false),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        DocSection(
          id: 'ripple',
          title: 'Ripple',
          source: 'InkWell · InkSparkle',
          cols: 3,
          children: [
            Demo(
              label: 'Ondulation primaire',
              child: Material(
                color: c.primaryLight,
                borderRadius: Radii.rl,
                child: InkWell(
                  borderRadius: Radii.rl,
                  splashColor: c.primary.withValues(alpha: 0.25),
                  onTap: () {},
                  child: SizedBox(height: 90, child: Center(child: Text('Touchez-moi', style: TextStyle(fontWeight: FontWeight.w700, color: c.primary)))),
                ),
              ),
            ),
            Demo(
              label: 'Ondulation centrée',
              child: Center(
                child: Material(
                  color: c.tertiaryLight,
                  shape: const CircleBorder(),
                  child: InkWell(customBorder: const CircleBorder(), splashColor: c.tertiary.withValues(alpha: 0.3), onTap: () {}, child: SizedBox(width: 90, height: 90, child: Icon(Icons.fingerprint, size: 40, color: c.tertiary))),
                ),
              ),
            ),
            Demo(
              label: 'Sans limite (unbounded)',
              child: SizedBox(
                height: 90,
                child: Center(child: InkResponse(radius: 60, onTap: () {}, child: Icon(Icons.favorite, size: 36, color: c.error))),
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _treeNode(KitColors c, TreeNodeData n, int depth) {
    final open = _treeOpen.contains(n.id);
    return [
      InkWell(
        onTap: () => setState(() {
          if (n.isLeaf) {
            _treeSel = n.label;
          } else {
            open ? _treeOpen.remove(n.id) : _treeOpen.add(n.id);
          }
        }),
        child: Container(
          color: _treeSel == n.label ? c.primaryLight : null,
          padding: EdgeInsets.only(left: 8.0 + depth * 20, right: 12, top: 7, bottom: 7),
          child: Row(children: [
            SizedBox(width: 22, child: n.isLeaf ? null : AnimatedRotation(turns: open ? 0.25 : 0, duration: const Duration(milliseconds: 150), child: Icon(Icons.chevron_right, size: 18, color: c.textSecondary))),
            Icon(n.isLeaf ? (n.icon ?? Icons.insert_drive_file) : (open ? Icons.folder_open : Icons.folder), size: 19, color: n.isLeaf ? c.textSecondary : c.warning),
            const SizedBox(width: 8),
            Expanded(child: Text(n.label, style: TextStyle(fontSize: 13.5, fontWeight: n.isLeaf ? FontWeight.w400 : FontWeight.w600, color: c.textPrimary))),
            if (n.meta != null) Text(n.meta!, style: TextStyle(fontSize: 11.5, color: c.textMuted)),
          ]),
        ),
      ),
      if (open) for (final ch in n.children) ..._treeNode(c, ch, depth + 1),
    ];
  }

  Widget _dropList(KitColors c, String title, List<String> items, List<String> other, KitTone tone) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (d) => !items.contains(d.data),
      onAcceptWithDetails: (d) => setState(() {
        other.remove(d.data);
        items.add(d.data);
      }),
      builder: (context, cand, _) => AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        constraints: const BoxConstraints(minHeight: 160),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: cand.isNotEmpty ? tone.light(c) : c.hover.withValues(alpha: 0.5),
          borderRadius: Radii.rm,
          border: Border.all(color: cand.isNotEmpty ? tone.color(c) : Colors.transparent, width: 1.5),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('$title (${items.length})', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: tone.text(c))),
          const SizedBox(height: 6),
          for (final it in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: LongPressDraggable<String>(
                data: it,
                feedback: Material(elevation: 6, borderRadius: Radii.rm, child: Container(width: 150, padding: const EdgeInsets.all(10), child: Text(it))),
                childWhenDragging: Opacity(opacity: 0.3, child: _chipCard(c, it)),
                child: _chipCard(c, it),
              ),
            ),
        ]),
      ),
    );
  }

  Widget _chipCard(KitColors c, String t) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: c.card, borderRadius: Radii.rm),
        child: Text(t, style: const TextStyle(fontSize: 12.5)),
      );
}
