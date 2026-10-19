import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/format.dart';
import '../../core/snack.dart';
import '../../data/showcase_data.dart';
import '../../theme/kit_colors.dart';
import '../../theme/tokens.dart';
import '../../widgets/common.dart';
import '../../widgets/interaction.dart';
import '../../widgets/kit_buttons.dart';
import '../doc/doc.dart';
import '../kit_nav.dart';

/// `/components/interactions` — palette ⌘K, raccourcis & gestes, popover, visite guidée,
/// centre de notifications, menu contextuel.
class InteractionsGallery extends StatefulWidget {
  const InteractionsGallery({super.key, this.initialSection});
  final String? initialSection;

  @override
  State<InteractionsGallery> createState() => _InteractionsGalleryState();
}

class _InteractionsGalleryState extends State<InteractionsGallery> {
  final _tSearch = GlobalKey(), _tKpis = GlobalKey(), _tAlerts = GlobalKey(), _tCreate = GlobalKey();
  String _gesture = 'Essayez un geste dans la zone ci-dessous';
  double _scale = 1;
  String? _lastShortcut;
  int _unread = 3;
  final _files = ['Contrat-cadre-2026.pdf', 'Photos installation', 'Relevé T3.xlsx', 'Rapport INT-0412.pdf'];
  final Set<String> _starred = {};

  List<PaletteCommand> get _commands => [
        for (final cat in kCategories) PaletteCommand(cat.label, cat.icon, 'Navigation', hint: 'Galerie de composants', keywords: cat.description),
        const PaletteCommand('Nouveau client', Icons.person_add, 'Actions', shortcut: '⌘N'),
        const PaletteCommand('Nouvelle intervention', Icons.build, 'Actions', shortcut: '⌘I'),
        const PaletteCommand('Basculer le thème', Icons.dark_mode, 'Actions', shortcut: '⌘⇧L'),
        const PaletteCommand('Exporter la liste', Icons.download, 'Actions', shortcut: '⌘E'),
        for (final x in kDemoClients.take(6)) PaletteCommand(x.raisonSociale, Icons.business, 'Clients', hint: '${x.code} · ${x.ville}'),
      ];

  Future<void> _palette() async {
    final cmd = await showCommandPalette(context, _commands);
    if (cmd == null || !mounted) return;
    final cat = kCategories.where((k) => k.label == cmd.label).firstOrNull;
    if (cat != null) {
      openCategory(context, cat);
    } else {
      showKitSnack(context, '« ${cmd.label} » exécuté (démo)', kind: SnackKind.info);
    }
  }

  void _shortcut(String label) {
    setState(() => _lastShortcut = label);
    showKitSnack(context, 'Raccourci : $label');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): _palette,
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): _palette,
        const SingleActivator(LogicalKeyboardKey.keyN, meta: true): () => _shortcut('⌘N · Nouveau client'),
        const SingleActivator(LogicalKeyboardKey.keyE, meta: true): () => _shortcut('⌘E · Exporter'),
        const SingleActivator(LogicalKeyboardKey.slash, shift: true): () => _shortcut('? · Aide'),
      },
      child: Focus(
        autofocus: true,
        child: DocPage(
          title: 'Interactions',
          icon: Icons.touch_app,
          initialSection: widget.initialSection,
          actions: [IconButton(tooltip: 'Palette de commandes', onPressed: _palette, icon: const Icon(Icons.search))],
          subtitle: 'Ce qui rend une application « finie » : palette de commandes, raccourcis (clavier physique) et gestes tactiles, popovers riches, visite guidée, centre de notifications et menus contextuels à l’appui long.',
          sections: [
            DocSection(
              id: 'palette',
              title: 'Palette de commandes (⌘K)',
              source: 'showCommandPalette',
              description: 'Recherche floue sur les pages, actions et clients. Sur téléphone : feuille plein écran ouverte par la loupe ; avec un clavier : ⌘K / Ctrl+K.',
              children: [
                Demo(
                  label: 'Ouvrir la palette',
                  code: "final cmd = await showCommandPalette(context, commands);",
                  child: InkWell(
                    borderRadius: Radii.pill,
                    onTap: _palette,
                    child: Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: Space.s4),
                      decoration: BoxDecoration(color: c.fieldBg, borderRadius: Radii.pill),
                      child: Row(children: [
                        Icon(Icons.search, size: 20, color: c.textSecondary),
                        const SizedBox(width: 10),
                        Expanded(child: Text('Rechercher ou lancer une commande…', overflow: TextOverflow.ellipsis, style: TextStyle(color: c.textMuted))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: Space.s2, vertical: Space.s0_5),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(color: c.border)),
                          child: Text('⌘K', style: TextStyle(fontFamily: Fonts.mono, fontSize: 11, color: c.textMuted)),
                        ),
                      ]),
                    ),
                  ),
                ),
              ],
            ),
            DocSection(
              id: 'shortcuts',
              title: 'Raccourcis & gestes',
              source: 'CallbackShortcuts · GestureDetector',
              description: 'Les raccourcis clavier restent actifs sur tablette avec clavier ; sur téléphone, les gestes prennent le relais.',
              cols: 2,
              children: [
                Demo(
                  label: 'Clavier physique',
                  hint: _lastShortcut,
                  child: Column(children: [
                    for (final (k, l) in const [('⌘ K', 'Palette de commandes'), ('⌘ N', 'Nouveau client'), ('⌘ E', 'Exporter'), ('?', 'Aide des raccourcis')])
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(children: [
                          Expanded(child: Text(l, style: TextStyle(color: c.textPrimary))),
                          for (final key in k.split(' '))
                            Container(
                              margin: const EdgeInsets.only(left: Space.s1),
                              padding: const EdgeInsets.symmetric(horizontal: Space.s2, vertical: Space.s1),
                              decoration: BoxDecoration(
                                color: c.card,
                                borderRadius: BorderRadius.circular(Radii.sm),
                                border: Border.all(color: c.border),
                                boxShadow: [BoxShadow(color: c.border, offset: const Offset(0, 2))],
                              ),
                              child: Text(key, style: TextStyle(fontFamily: Fonts.mono, fontSize: 12, fontWeight: FontWeight.w700, color: c.textSecondary)),
                            ),
                        ]),
                      ),
                  ]),
                ),
                Demo(
                  label: 'Gestes tactiles',
                  child: Gap([
                    GestureDetector(
                      onTap: () => setState(() => _gesture = 'Toucher'),
                      onDoubleTap: () => setState(() => _gesture = 'Double-toucher'),
                      onLongPress: () {
                        HapticFeedback.mediumImpact();
                        setState(() => _gesture = 'Appui long');
                      },
                      onScaleUpdate: (d) => setState(() {
                        if (d.pointerCount > 1) {
                          _scale = d.scale.clamp(0.5, 2.5);
                          _gesture = 'Pincement ×${_scale.toStringAsFixed(1).replaceAll('.', ',')}';
                        } else if (d.focalPointDelta.dx.abs() > 4) {
                          _gesture = d.focalPointDelta.dx > 0 ? 'Balayage → droite' : 'Balayage ← gauche';
                        } else if (d.focalPointDelta.dy.abs() > 4) {
                          _gesture = d.focalPointDelta.dy > 0 ? 'Balayage ↓ bas' : 'Balayage ↑ haut';
                        }
                      }),
                      onScaleEnd: (_) => setState(() => _scale = 1),
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(color: c.primaryLight, borderRadius: Radii.rl),
                        child: Center(
                          child: AnimatedScale(
                            scale: _scale,
                            duration: const Duration(milliseconds: 80),
                            child: Column(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.touch_app, size: 36, color: c.primary),
                              const SizedBox(height: 6),
                              Text(_gesture, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700, color: c.primary)),
                            ]),
                          ),
                        ),
                      ),
                    ),
                    Wrap(spacing: 6, runSpacing: 6, children: [
                      for (final g in const ['Toucher', 'Double-toucher', 'Appui long', 'Balayage', 'Pincement', 'Tirer pour rafraîchir'])
                        Chip(label: Text(g), visualDensity: VisualDensity.compact),
                    ]),
                  ]),
                ),
              ],
            ),
            DocSection(
              id: 'popover',
              title: 'Popover riche',
              source: 'Popover (OverlayPortal)',
              description: 'Carte flottante ancrée (au-dessus ou au-dessous selon la place) ; toucher en dehors la ferme.',
              cols: 2,
              children: [
                Demo(
                  label: 'Carte de profil',
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Popover(
                      content: (ctx, close) => Padding(
                        padding: const EdgeInsets.all(Space.s4),
                        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Row(children: [
                            KitAvatar(name: 'Koffi N’Guessan', size: 44, online: true),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('Koffi N’Guessan', style: TextStyle(fontWeight: FontWeight.w700)),
                                Text('Technicien · Abidjan Sud', style: TextStyle(fontSize: 12)),
                              ]),
                            ),
                          ]),
                          const SizedBox(height: 10),
                          const Row(children: [
                            Icon(Icons.phone, size: 16),
                            SizedBox(width: 6),
                            Text('+225 07 22 31 44 58', style: TextStyle(fontSize: 12.5)),
                          ]),
                          const SizedBox(height: 4),
                          const Row(children: [
                            Icon(Icons.task_alt, size: 16),
                            SizedBox(width: 6),
                            Text('4 interventions aujourd’hui', style: TextStyle(fontSize: 12.5)),
                          ]),
                          const SizedBox(height: 10),
                          Row(children: [
                            Expanded(child: OutlinedButton(onPressed: close, child: const Text('Appeler'))),
                            const SizedBox(width: 8),
                            Expanded(child: FilledButton(onPressed: close, child: const Text('Assigner'))),
                          ]),
                        ]),
                      ),
                      child: Chip(avatar: const KitAvatar(name: 'Koffi N’Guessan', size: 24), label: const Text('Koffi N’Guessan')),
                    ),
                  ),
                ),
                Demo(
                  label: 'Aperçu d’indicateur',
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Popover(
                      width: 240,
                      content: (ctx, close) => Padding(
                        padding: const EdgeInsets.all(Space.s4),
                        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('CA d’octobre', style: TextStyle(fontSize: 12, color: c.textSecondary)),
                          Text('55,8 M FCFA', style: TextStyle(fontFamily: Fonts.heading, fontSize: 22, fontWeight: FontWeight.w700, color: c.textPrimary)),
                          const TrendChip('+9,2 % vs septembre'),
                          const Divider(height: 18),
                          for (final (l, v) in const [('Abonnements', '38,1 M'), ('Installations', '11,4 M'), ('Matériel', '6,3 M')])
                            Padding(padding: const EdgeInsets.symmetric(vertical: Space.s0_5), child: Row(children: [Expanded(child: Text(l, style: const TextStyle(fontSize: 12.5))), Text(v, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5))])),
                        ]),
                      ),
                      child: const KpiCard(icon: Icons.payments, value: '55,8', unit: 'M', label: 'CA du mois', tone: KitTone.success),
                    ),
                  ),
                ),
              ],
            ),
            DocSection(
              id: 'tour',
              title: 'Visite guidée / onboarding',
              source: 'startTour(TourStep…)',
              description: 'Projecteur percé dans un voile, bulle positionnée selon la place disponible, navigation et progression.',
              children: [
                Demo(
                  label: 'Mini-tableau de bord',
                  child: Gap([
                    Container(key: _tSearch, child: const KitTextField(hint: 'Rechercher un véhicule…', icon: Icons.search)),
                    Container(
                      key: _tKpis,
                      child: const Row(children: [
                        Expanded(child: KpiCard(icon: Icons.local_shipping, value: '42', label: 'Actifs', tone: KitTone.primary)),
                        SizedBox(width: 10),
                        Expanded(child: KpiCard(icon: Icons.speed, value: '96 %', label: 'Dispo.', tone: KitTone.success)),
                      ]),
                    ),
                    Row(children: [
                      Container(key: _tAlerts, child: Badge(label: Text('$_unread'), child: const RoundIconButton(icon: Icons.notifications_outlined))),
                      const Spacer(),
                      Flexible(child: Container(key: _tCreate, child: KitButton(label: 'Mission', icon: Icons.add, onPressed: () {}))),
                    ]),
                    FilledButton.tonalIcon(
                      onPressed: () => startTour(context, [
                        TourStep(_tSearch, 'Recherche instantanée', 'Retrouvez un véhicule par immatriculation, chauffeur ou client.', icon: Icons.search),
                        TourStep(_tKpis, 'Indicateurs clés', 'Suivez l’état de la flotte d’un coup d’œil. Touchez une tuile pour le détail.', icon: Icons.insights),
                        TourStep(_tAlerts, 'Alertes', 'Les sorties de zone et excès de vitesse arrivent ici en temps réel.', icon: Icons.notifications_active),
                        TourStep(_tCreate, 'Créer une mission', 'Planifiez une intervention et assignez un technicien en deux étapes.', icon: Icons.add_task),
                      ]),
                      icon: const Icon(Icons.play_circle_outline, size: 18),
                      label: const Text('Lancer la visite'),
                    ),
                  ]),
                ),
              ],
            ),
            DocSection(
              id: 'notifications',
              title: 'Centre de notifications',
              source: 'NotificationCenter',
              description: 'Filtres par catégorie, non lues, « tout marquer lu », balayage pour supprimer, toucher pour lire.',
              children: [Demo(label: 'Boîte de réception', hint: '$_unread non lue(s)', child: NotificationCenter(onUnreadChanged: (n) => setState(() => _unread = n)))],
            ),
            DocSection(
              id: 'context-menu',
              title: 'Menu contextuel',
              source: 'LongPressMenu (appui long = clic droit)',
              description: 'Appui long sur un élément : menu positionné sous le doigt, avec retour haptique.',
              children: [
                Demo(
                  label: 'Documents',
                  flush: true,
                  child: Column(children: [
                    for (final f in _files)
                      LongPressMenu<String>(
                        onSelected: (v) {
                          if (v == 'star') {
                            setState(() => _starred.contains(f) ? _starred.remove(f) : _starred.add(f));
                          } else if (v == 'delete') {
                            final i = _files.indexOf(f);
                            setState(() => _files.remove(f));
                            showKitSnack(context, '« $f » supprimé', action: 'Annuler', onAction: () => setState(() => _files.insert(i, f)));
                          } else {
                            demoAction(context, '$v « $f »');
                          }
                        },
                        items: [
                          const PopupMenuItem(value: 'Ouverture de', child: ListTile(leading: Icon(Icons.open_in_new), title: Text('Ouvrir'))),
                          PopupMenuItem(value: 'star', child: ListTile(leading: Icon(_starred.contains(f) ? Icons.star : Icons.star_border), title: Text(_starred.contains(f) ? 'Retirer des favoris' : 'Ajouter aux favoris'))),
                          const PopupMenuItem(value: 'Partage de', child: ListTile(leading: Icon(Icons.share_outlined), title: Text('Partager'))),
                          const PopupMenuDivider(),
                          PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete_outline, color: c.error), title: Text('Supprimer', style: TextStyle(color: c.error)))),
                        ],
                        child: ListTile(
                          leading: Icon(f.endsWith('.pdf') ? Icons.picture_as_pdf : (f.endsWith('.xlsx') ? Icons.table_view : Icons.folder), color: c.primary),
                          title: Text(f),
                          subtitle: Text('Modifié ${Fmt.ago(DateTime.now().subtract(Duration(hours: f.length)))} · appui long pour le menu'),
                          trailing: _starred.contains(f) ? Icon(Icons.star, color: c.warning) : null,
                        ),
                      ),
                  ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
