import 'package:flutter/material.dart';

import '../../core/snack.dart';
import '../../data/menu_data.dart';
import '../../data/showcase_data.dart';
import '../../theme/kit_colors.dart';
import '../../theme/tokens.dart';
import '../../widgets/common.dart';
import '../../widgets/kit_buttons.dart';
import '../../widgets/navigation.dart';
import '../doc/doc.dart';

/// `/components/navigation` — barres d'application, tiroir / Sidecar, barre basse,
/// onglets, fil d'Ariane, pagination, étapes, menus.
class NavigationGallery extends StatefulWidget {
  const NavigationGallery({super.key, this.initialSection});
  final String? initialSection;

  @override
  State<NavigationGallery> createState() => _NavigationGalleryState();
}

class _NavigationGalleryState extends State<NavigationGallery> {
  String _menu = 'dashboard';
  int _nav = 0, _rail = 0;
  int _page = 3, _pageSize = 10;
  int _loaded = 6;
  bool _loadingMore = false;
  int _step = 1;
  int _vstep = 0;
  int _wizard = 1;
  bool _searching = false;
  final Set<int> _sel = {1, 3};

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return DocPage(
      title: 'Navigation',
      icon: Icons.explore,
      initialSection: widget.initialSection,
      subtitle: 'Éléments de navigation du shell adaptés au mobile : barres d’application, tiroir et Sidecar, barre de navigation basse, onglets, fil d’Ariane, pagination, étapes et menus.',
      sections: [
        DocSection(
          id: 'header',
          title: 'Header (barre d’application)',
          source: 'AppBar · SliverAppBar.large',
          description: 'La toolbar sticky du shell devient l’AppBar : menu, titre, actions (thème, tâches, notifications, compte). Modes recherche et sélection contextuelle.',
          children: [
            Demo(
              label: 'Barre du shell',
              flush: true,
              child: _Frame(
                child: AppBar(
                  primary: false,
                  leading: IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
                  title: const Text('Tableau de bord'),
                  actions: [
                    IconButton(onPressed: () {}, icon: const Badge(label: Text('7'), child: Icon(Icons.checklist))),
                    IconButton(onPressed: () {}, icon: const Badge(label: Text('3'), child: Icon(Icons.notifications_outlined))),
                    const Padding(padding: EdgeInsets.only(right: Space.s3), child: KitAvatar(name: 'Jean Kouassi', size: 32)),
                  ],
                ),
              ),
            ),
            Demo(
              label: 'Mode recherche',
              hint: 'touchez la loupe',
              flush: true,
              child: _Frame(
                child: AppBar(
                  primary: false,
                  leading: _searching ? IconButton(onPressed: () => setState(() => _searching = false), icon: const Icon(Icons.arrow_back)) : IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
                  title: _searching
                      ? const TextField(autofocus: true, decoration: InputDecoration(hintText: 'Rechercher un client…', filled: false, border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none))
                      : const Text('Clients'),
                  actions: [if (!_searching) IconButton(onPressed: () => setState(() => _searching = true), icon: const Icon(Icons.search)), IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert))],
                ),
              ),
            ),
            Demo(
              label: 'Sélection contextuelle',
              flush: true,
              child: _Frame(
                child: AppBar(
                  primary: false,
                  backgroundColor: c.primaryLight,
                  leading: IconButton(onPressed: () => setState(_sel.clear), icon: const Icon(Icons.close)),
                  title: Text('${_sel.length} sélectionné(s)', style: TextStyle(color: c.primary, fontWeight: FontWeight.w700, fontSize: 18)),
                  actions: [
                    IconButton(onPressed: () {}, icon: const Icon(Icons.archive_outlined)),
                    IconButton(onPressed: () {}, color: c.error, icon: const Icon(Icons.delete_outline)),
                  ],
                ),
              ),
            ),
            Demo(
              label: 'Grand titre (défilement)',
              flush: true,
              child: SizedBox(
                height: 260,
                child: CustomScrollView(slivers: [
                  SliverAppBar.large(
                    primary: false,
                    pinned: true,
                    title: const Text('Registre des clients'),
                    actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list))],
                  ),
                  SliverList.builder(
                    itemCount: 12,
                    itemBuilder: (_, i) => ListTile(leading: KitAvatar(name: kDemoClients[i].raisonSociale, size: 32), title: Text(kDemoClients[i].raisonSociale)),
                  ),
                ]),
              ),
            ),
          ],
        ),
        DocSection(
          id: 'sidebar',
          title: 'Sidebar / drawer',
          source: 'Sidecar · NavigationDrawer · NavigationRail',
          description: 'Sidecar : rail d’icônes + seconde colonne des sous-menus d’un module. En mobile il s’ouvre dans un tiroir ; sur tablette, le NavigationRail reste visible.',
          children: [
            Demo(
              label: 'Sidecar',
              hint: 'touchez un module à chevron',
              flush: true,
              child: SizedBox(
                height: 420,
                child: Row(children: [
                  Sidecar(items: kDemoMenu, selected: _menu, onSelect: (m) => setState(() => _menu = m.id)),
                  Expanded(
                    child: Container(
                      color: c.bg,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(Space.s3),
                      child: Text('Page : ${_label(_menu)}', textAlign: TextAlign.center, style: TextStyle(color: c.textSecondary)),
                    ),
                  ),
                ]),
              ),
            ),
            Demo(
              label: 'Tiroir de navigation',
              child: Align(
                alignment: Alignment.centerLeft,
                child: KitButton(
                  label: 'Ouvrir le tiroir',
                  icon: Icons.menu_open,
                  variant: KitButtonVariant.secondary,
                  onPressed: () => showGeneralDialog(
                    context: context,
                    barrierDismissible: true,
                    barrierLabel: 'Menu',
                    pageBuilder: (ctx, _, _) => Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 300,
                        child: NavigationDrawer(
                          selectedIndex: _nav,
                          onDestinationSelected: (i) {
                            setState(() => _nav = i);
                            Navigator.pop(ctx);
                          },
                          children: [
                            const Padding(padding: EdgeInsets.fromLTRB(28, Space.s5, Space.s4, Space.s3), child: Text('Lookas', style: TextStyle(fontFamily: Fonts.brand, fontSize: 22, fontWeight: FontWeight.w700))),
                            for (final m in kDemoMenu.take(6)) NavigationDrawerDestination(icon: Icon(m.icon), label: Text(m.label)),
                            const Divider(indent: 28, endIndent: 28),
                            const NavigationDrawerDestination(icon: Icon(Icons.settings_outlined), label: Text('Paramètres')),
                          ],
                        ),
                      ),
                    ),
                    transitionBuilder: (ctx, a, _, child) => SlideTransition(position: Tween(begin: const Offset(-1, 0), end: Offset.zero).animate(a), child: child),
                  ),
                ),
              ),
            ),
            Demo(
              label: 'NavigationRail (tablette)',
              flush: true,
              child: SizedBox(
                height: 420,
                child: Row(children: [
                  NavigationRail(
                    selectedIndex: _rail,
                    onDestinationSelected: (i) => setState(() => _rail = i),
                    labelType: NavigationRailLabelType.all,
                    backgroundColor: c.card,
                    leading: FloatingActionButton.small(heroTag: null, onPressed: () {}, child: const Icon(Icons.add)),
                    destinations: [for (final m in kDemoMenu.take(4)) NavigationRailDestination(icon: Icon(m.icon), label: Text(m.label.split(' ').first))],
                  ),
                  Expanded(child: Center(child: Text(kDemoMenu[_rail].label, style: TextStyle(color: c.textSecondary)))),
                ]),
              ),
            ),
          ],
        ),
        DocSection(
          id: 'navbar',
          title: 'Barre de navigation',
          source: 'NavigationBar · PageHeader',
          description: 'La barre basse porte 3 à 5 destinations principales, à portée de pouce ; l’en-tête de page reprend titre, fil d’Ariane et actions.',
          children: [
            Demo(
              label: 'Barre basse',
              flush: true,
              child: NavigationBar(
                selectedIndex: _nav.clamp(0, 3),
                onDestinationSelected: (i) => setState(() => _nav = i),
                destinations: const [
                  NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Accueil'),
                  NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Clients'),
                  NavigationDestination(icon: Badge(label: Text('4'), child: Icon(Icons.build_outlined)), selectedIcon: Icon(Icons.build), label: 'Interventions'),
                  NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Compte'),
                ],
              ),
            ),
            Demo(
              label: 'En-tête de page',
              child: PageHeader(
                breadcrumb: 'Service client',
                title: 'Requêtes clients',
                subtitle: '42 requêtes ouvertes · 6 en retard',
                badge: const StatusBadge('Live', tone: KitTone.success, icon: Icons.circle),
                actions: [
                  RoundIconButton(icon: Icons.refresh, onPressed: () {}),
                  KitButton(label: 'Nouvelle requête', icon: Icons.add, size: KitButtonSize.create, shape: KitButtonShape.rounded, variant: KitButtonVariant.raised, onPressed: () {}),
                ],
              ),
            ),
          ],
        ),
        DocSection(
          id: 'tabs',
          title: 'Tabs',
          source: 'TabBar · TabBarView',
          cols: 2,
          children: [
            Demo(
              label: 'Onglets avec compteurs',
              flush: true,
              child: DefaultTabController(
                length: 3,
                child: Column(children: [
                  const TabBar(isScrollable: true, tabAlignment: TabAlignment.start, tabs: [
                    Tab(text: 'Infos'),
                    Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [Text('Véhicules'), SizedBox(width: 6), CountDot(12, tone: KitTone.primary)])),
                    Tab(text: 'Factures'),
                  ]),
                  SizedBox(
                    height: 120,
                    child: TabBarView(children: [
                      for (final t in ['Coordonnées et contrat', '12 véhicules suivis', '3 factures en attente'])
                        Center(child: Text(t, style: TextStyle(color: c.textSecondary))),
                    ]),
                  ),
                ]),
              ),
            ),
            Demo(
              label: 'Défilants avec icônes',
              flush: true,
              child: DefaultTabController(
                length: 6,
                child: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: [for (final m in kDemoMenu.take(6)) Tab(icon: Icon(m.icon, size: 20), text: m.label.split(' ').first)],
                ),
              ),
            ),
          ],
        ),
        DocSection(
          id: 'breadcrumb',
          title: 'Breadcrumb',
          source: 'Breadcrumb',
          description: 'Défile horizontalement et reste calé sur la page courante quand il est long.',
          children: [
            Demo(
              label: 'Fil d’Ariane',
              child: Gap([
                Breadcrumb(items: const ['Accueil', 'Clients', 'Transports Yao & Fils'], onTap: (i) => showKitSnack(context, 'Retour niveau $i')),
                const Breadcrumb(items: ['Accueil', 'Finance', 'Facturation', 'Groupes de facturation', 'Flotte Abidjan Sud', 'Profil 2026'], separator: Icons.arrow_right),
              ]),
            ),
          ],
        ),
        DocSection(
          id: 'pagination',
          title: 'Pagination',
          source: 'KitPaginator · chargement progressif',
          description: 'Pages numérotées, version compacte, ou « charger plus » (préférable sur mobile pour les longues listes).',
          children: [
            Demo(label: 'Complète', child: KitPaginator(page: _page, pageSize: _pageSize, total: 248, onPage: (p) => setState(() => _page = p), onPageSize: (s) => setState(() => _pageSize = s))),
            Demo(label: 'Compacte', child: KitPaginator(page: _page, pageSize: _pageSize, total: 248, compact: true, onPage: (p) => setState(() => _page = p))),
            Demo(
              label: 'Charger plus',
              flush: true,
              child: Column(children: [
                for (final x in kDemoClients.take(_loaded)) ListTile(dense: true, leading: KitAvatar(name: x.raisonSociale, size: 30), title: Text(x.raisonSociale), subtitle: Text(x.ville)),
                Padding(
                  padding: const EdgeInsets.all(Space.s3),
                  child: _loaded >= kDemoClients.length
                      ? Text('Tous les clients sont affichés', style: TextStyle(color: c.textMuted, fontSize: 12))
                      : KitButton(
                          label: 'Charger plus (${kDemoClients.length - _loaded})',
                          loading: _loadingMore,
                          loadingLabel: 'Chargement…',
                          variant: KitButtonVariant.outline,
                          expand: true,
                          onPressed: () async {
                            setState(() => _loadingMore = true);
                            await Future<void>.delayed(const Duration(milliseconds: 700));
                            if (mounted) {
                              setState(() {
                                _loadingMore = false;
                                _loaded += 6;
                              });
                            }
                          },
                        ),
                ),
              ]),
            ),
          ],
        ),
        DocSection(
          id: 'stepper',
          title: 'Stepper',
          source: 'StepsIndicator · Stepper',
          cols: 2,
          children: [
            Demo(
              label: 'Assistant (indicateur compact)',
              child: Gap([
                StepsIndicator(steps: const ['Client', 'Véhicules', 'Offre', 'Validation'], current: _wizard, onTap: (i) => setState(() => _wizard = i)),
                Row(children: [
                  OutlinedButton(onPressed: _wizard == 0 ? null : () => setState(() => _wizard--), child: const Text('Précédent')),
                  const Spacer(),
                  FilledButton(onPressed: _wizard == 3 ? null : () => setState(() => _wizard++), child: const Text('Suivant')),
                ]),
              ]),
            ),
            Demo(
              label: 'Stepper horizontal (M3)',
              flush: true,
              child: SizedBox(
                height: 230,
                child: Stepper(
                  type: StepperType.horizontal,
                  currentStep: _step,
                  controlsBuilder: _controls,
                  onStepTapped: (i) => setState(() => _step = i),
                  onStepContinue: () => setState(() => _step = (_step + 1).clamp(0, 2)),
                  onStepCancel: () => setState(() => _step = (_step - 1).clamp(0, 2)),
                  steps: [
                    Step(title: const SizedBox.shrink(), label: const Text('Devis'), content: const Text('Devis DEV-2026-118 validé.'), isActive: _step >= 0, state: _step > 0 ? StepState.complete : StepState.indexed),
                    Step(title: const SizedBox.shrink(), label: const Text('Pose'), content: const Text('Installation planifiée le 24/10.'), isActive: _step >= 1, state: _step > 1 ? StepState.complete : StepState.indexed),
                    Step(title: const SizedBox.shrink(), label: const Text('Recette'), content: const Text('Contrôle du signal GPS.'), isActive: _step >= 2),
                  ],
                ),
              ),
            ),
            Demo(
              label: 'Stepper vertical',
              flush: true,
              child: Stepper(
                physics: const NeverScrollableScrollPhysics(),
                currentStep: _vstep,
                controlsBuilder: _controls,
                onStepTapped: (i) => setState(() => _vstep = i),
                onStepContinue: () => setState(() => _vstep = (_vstep + 1).clamp(0, 2)),
                onStepCancel: () => setState(() => _vstep = (_vstep - 1).clamp(0, 2)),
                steps: [
                  Step(title: const Text('Informations client'), subtitle: const Text('Raison sociale, contact'), content: const KitTextField(hint: 'Raison sociale'), isActive: _vstep >= 0),
                  Step(title: const Text('Véhicules'), content: const KitTextField(hint: 'Immatriculations'), isActive: _vstep >= 1),
                  Step(title: const Text('Confirmation'), content: const Text('Vérifiez puis validez.'), isActive: _vstep >= 2, state: StepState.editing),
                ],
              ),
            ),
          ],
        ),
        DocSection(
          id: 'menu',
          title: 'Menu',
          source: 'PopupMenuButton · MenuAnchor · feuille d’actions',
          description: 'Sur mobile, les menus longs ou destructifs s’ouvrent de préférence en feuille basse.',
          cols: 3,
          children: [
            Demo(
              label: 'Menu contextuel',
              child: Align(
                alignment: Alignment.centerLeft,
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (v) => showKitSnack(context, v),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'Voir', child: ListTile(leading: Icon(Icons.visibility_outlined), title: Text('Voir'))),
                    const PopupMenuItem(value: 'Modifier', child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Modifier'))),
                    const PopupMenuItem(value: 'Dupliquer', child: ListTile(leading: Icon(Icons.copy), title: Text('Dupliquer'))),
                    const PopupMenuDivider(),
                    PopupMenuItem(value: 'Supprimer', child: ListTile(leading: Icon(Icons.delete_outline, color: c.error), title: Text('Supprimer', style: TextStyle(color: c.error)))),
                  ],
                ),
              ),
            ),
            Demo(
              label: 'Menu en cascade',
              child: Align(
                alignment: Alignment.centerLeft,
                child: MenuAnchor(
                  builder: (ctx, ctrl, _) => OutlinedButton.icon(onPressed: () => ctrl.isOpen ? ctrl.close() : ctrl.open(), icon: const Icon(Icons.file_download, size: 18), label: const Text('Exporter')),
                  menuChildren: [
                    SubmenuButton(menuChildren: [
                      MenuItemButton(onPressed: () => demoAction(context, 'Export XLSX'), child: const Text('Tableur (.xlsx)')),
                      MenuItemButton(onPressed: () => demoAction(context, 'Export CSV'), child: const Text('CSV')),
                    ], leadingIcon: const Icon(Icons.table_view), child: const Text('Données')),
                    MenuItemButton(leadingIcon: const Icon(Icons.picture_as_pdf), onPressed: () => demoAction(context, 'Export PDF'), child: const Text('PDF')),
                  ],
                ),
              ),
            ),
            Demo(
              label: 'Feuille d’actions',
              child: Align(
                alignment: Alignment.centerLeft,
                child: KitButton(
                  label: 'Actions',
                  icon: Icons.more_horiz,
                  variant: KitButtonVariant.outline,
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    builder: (ctx) => SafeArea(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        ListTile(leading: const Icon(Icons.share_outlined), title: const Text('Partager'), onTap: () => Navigator.pop(ctx)),
                        ListTile(leading: const Icon(Icons.print_outlined), title: const Text('Imprimer'), onTap: () => Navigator.pop(ctx)),
                        ListTile(leading: const Icon(Icons.archive_outlined), title: const Text('Archiver'), onTap: () => Navigator.pop(ctx)),
                        ListTile(leading: Icon(Icons.delete_outline, color: c.error), title: Text('Supprimer', style: TextStyle(color: c.error)), onTap: () => Navigator.pop(ctx)),
                        const SizedBox(height: 8),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _controls(BuildContext context, ControlsDetails d) => Padding(
        padding: const EdgeInsets.only(top: Space.s3),
        child: Wrap(spacing: 8, runSpacing: 8, children: [
          FilledButton(onPressed: d.onStepContinue, child: const Text('Continuer')),
          if (d.stepIndex > 0) TextButton(onPressed: d.onStepCancel, child: const Text('Retour')),
        ]),
      );

  String _label(String id) {
    for (final m in kDemoMenu) {
      if (m.id == id) return m.label;
      for (final ch in m.children) {
        if (ch.id == id) return '${m.label} › ${ch.label}';
      }
    }
    return id;
  }
}

class _Frame extends StatelessWidget {
  const _Frame({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox(height: kToolbarHeight, child: child);
}
