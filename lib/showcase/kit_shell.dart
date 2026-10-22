import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../examples/examples_index.dart';
import '../examples/galleries.dart';
import '../harnais/harnais_screen.dart';
import '../theme/kit_colors.dart';
import '../theme/tokens.dart';
import 'components_index.dart';
import 'kit_nav.dart';
import 'layouts/layouts_gallery.dart';
import 'ui_showcase_page.dart';
import '../core/haptics.dart';

/// Layout du catalogue adapté au mobile (`kit-layout`) : la sidebar arborescente
/// devient un tiroir recherchable, les entrées principales une barre de navigation basse.
class KitShell extends StatefulWidget {
  const KitShell({super.key});

  static KitShellState? of(BuildContext context) => context.findAncestorStateOfType<KitShellState>();

  @override
  State<KitShell> createState() => KitShellState();
}

class KitShellState extends State<KitShell> {
  int _index = 0;
  final _scaffold = GlobalKey<ScaffoldState>();

  /// Une pile de pages par onglet (Showcase, Composants, Layouts) : la barre du bas reste visible
  /// sur les pages de détail et chaque onglet retrouve sa page en cours (convention iOS / Material 3).
  final _tabs = List.generate(3, (_) => GlobalKey<NavigatorState>());
  final _reselect = List.generate(3, (_) => ValueNotifier<int>(0));
  final _heroes = List.generate(3, (_) => MaterialApp.createMaterialHeroController());
  late final _observers = List.generate(3, (_) => _TabObserver(() {
        if (mounted) setState(() {});
      }));

  /// Une page de détail est ouverte dans l'onglet courant : le glissé depuis le bord gauche
  /// sert au retour (iOS), pas à ouvrir le tiroir.
  bool get _inDetail => _index < _tabs.length && (_tabs[_index].currentState?.canPop() ?? false);

  int get index => _index;

  /// Toucher l'onglet actif : retour à sa racine, ou en haut de la page s'il y est déjà.
  void select(int i) {
    if (i != _index) {
      kitHaptic();
      setState(() => _index = i);
      return;
    }
    if (i >= _tabs.length) return;
    final nav = _tabs[i].currentState;
    if (nav != null && nav.canPop()) {
      nav.popUntil((r) => r.isFirst);
    } else {
      _reselect[i].value++;
    }
  }

  void openDrawer() => _scaffold.currentState?.openDrawer();

  /// Ouvre une galerie dans l'onglet Composants (comme `/components/<id>` côté React Native).
  void openInComponents(Widget page) {
    setState(() => _index = 1);
    _tabs[1].currentState?.push(MaterialPageRoute<void>(builder: (_) => page));
  }

  /// Retour Android : d'abord la pile de l'onglet, puis l'onglet Showcase, puis sortie.
  void _onBack() {
    final nav = _index < _tabs.length ? _tabs[_index].currentState : null;
    if (nav != null && nav.canPop()) {
      nav.pop();
    } else if (_index != 0) {
      setState(() => _index = 0);
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  void dispose() {
    for (final n in _reselect) {
      n.dispose();
    }
    for (final h in _heroes) {
      h.dispose();
    }
    super.dispose();
  }

  Widget _tab(int i, Widget root) => KitTabReselect(
    ticks: _reselect[i],
    child: HeroControllerScope(
      controller: _heroes[i],
      child: Navigator(
        key: _tabs[i],
        observers: [_observers[i]],
        onGenerateRoute: (_) => MaterialPageRoute<void>(builder: (_) => root),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final pages = [
      _tab(0, UiShowcasePage(onMenu: openDrawer)),
      _tab(1, ComponentsIndexPage(onMenu: openDrawer)),
      _tab(2, LayoutsGalleryPage(onMenu: openDrawer)),
      HarnaisScreen(onExit: () => select(0)),
    ];
    final harnais = _index == 3;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBack();
      },
      child: Scaffold(
        key: _scaffold,
        drawer: const KitDrawer(),
        drawerEnableOpenDragGesture: !_inDetail,
        body: IndexedStack(index: _index, children: pages),
        bottomNavigationBar: harnais
            ? null
            : NavigationBar(
                selectedIndex: _index,
                onDestinationSelected: select,
                destinations: const [
                  NavigationDestination(icon: Icon(Icons.palette_outlined), selectedIcon: Icon(Icons.palette), label: 'Showcase'),
                  NavigationDestination(icon: Icon(Icons.widgets_outlined), selectedIcon: Icon(Icons.widgets), label: 'Composants'),
                  NavigationDestination(icon: Icon(Icons.dashboard_customize_outlined), selectedIcon: Icon(Icons.dashboard_customize), label: 'Layouts'),
                  NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome), label: 'Harnais'),
                ],
              ),
      ),
    );
  }
}

/// Prévient le shell quand la pile d'un onglet change (ouverture / fermeture d'une page de détail).
class _TabObserver extends NavigatorObserver {
  _TabObserver(this.onChange);
  final VoidCallback onChange;

  void _notify() => WidgetsBinding.instance.addPostFrameCallback((_) => onChange());

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => _notify();

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => _notify();

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) => _notify();
}

/// Signale aux pages racines d'un onglet que l'onglet actif a été touché à nouveau.
class KitTabReselect extends InheritedWidget {
  const KitTabReselect({super.key, required this.ticks, required super.child});
  final ValueListenable<int> ticks;

  static ValueListenable<int>? maybeOf(BuildContext context) => context.dependOnInheritedWidgetOfExactType<KitTabReselect>()?.ticks;

  @override
  bool updateShouldNotify(KitTabReselect oldWidget) => ticks != oldWidget.ticks;
}

/// Remonte en haut de [controller] quand l'onglet de la page est touché à nouveau
/// (seulement si la page est la racine de son onglet).
class ScrollToTopOnReselect extends StatefulWidget {
  const ScrollToTopOnReselect({super.key, required this.controller, required this.child});
  final ScrollController controller;
  final Widget child;

  @override
  State<ScrollToTopOnReselect> createState() => _ScrollToTopOnReselectState();
}

class _ScrollToTopOnReselectState extends State<ScrollToTopOnReselect> {
  ValueListenable<int>? _ticks;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ticks = KitTabReselect.maybeOf(context);
    if (ticks == _ticks) return;
    _ticks?.removeListener(_toTop);
    _ticks = ticks?..addListener(_toTop);
  }

  void _toTop() {
    if (!(ModalRoute.of(context)?.isFirst ?? false) || !widget.controller.hasClients) return;
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (reduce) {
      widget.controller.jumpTo(0);
    } else {
      widget.controller.animateTo(0, duration: Motion.slow, curve: Motion.standard);
    }
  }

  @override
  void dispose() {
    _ticks?.removeListener(_toTop);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Logo + nom du kit.
class KitBrand extends StatelessWidget {
  const KitBrand({super.key, this.size = 32});
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(size * 0.3)),
          child: Icon(Icons.widgets, color: c.onPrimary, size: size * 0.58),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'UI Kit',
              style: TextStyle(fontFamily: Fonts.brand, fontSize: 17, fontWeight: FontWeight.w700, color: c.textPrimary, height: 1.1),
            ),
            Text('Flutter · mobile', style: TextStyle(fontSize: 11, color: c.textMuted)),
          ],
        ),
      ],
    );
  }
}

/// Tiroir du catalogue : recherche + arborescence catégories › sections.
class KitDrawer extends StatefulWidget {
  const KitDrawer({super.key});

  @override
  State<KitDrawer> createState() => _KitDrawerState();
}

class _KitDrawerState extends State<KitDrawer> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final q = _q.trim().toLowerCase();
    final shell = KitShell.of(context);

    void go(int tab) {
      Navigator.pop(context);
      shell?.select(tab);
    }

    void open(KitCategory cat, [String? section]) {
      Navigator.pop(context);
      openCategory(context, cat, section);
    }

    final current = shell?.index;

    final matches = <Widget>[];
    if (q.isNotEmpty) {
      for (final cat in kCategories) {
        final catHit = cat.label.toLowerCase().contains(q);
        final hits = cat.sections.where((s) => s.$2.toLowerCase().contains(q)).toList();
        if (catHit) matches.add(_tile(context, cat.icon, cat.label, () => open(cat), bold: true));
        for (final s in hits) {
          matches.add(_tile(context, Icons.subdirectory_arrow_right, s.$2, () => open(cat, s.$1), subtitle: cat.label, indent: true));
        }
      }
    }

    return Drawer(
      width: 300,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(padding: EdgeInsets.fromLTRB(Space.s5, Space.s4, Space.s4, Space.s3), child: KitBrand()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.s3),
              child: TextField(
                onChanged: (v) => setState(() => _q = v),
                // Recherche pilule sans contour ; liseré primaire seulement au focus.
                decoration: InputDecoration(
                  hintText: 'Rechercher un composant…',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  enabledBorder: OutlineInputBorder(borderRadius: Radii.pill, borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: Radii.pill,
                    borderSide: BorderSide(color: c.primary, width: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: Space.s2, vertical: Space.s1),
                children: [
                  if (q.isNotEmpty) ...[
                    if (matches.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(Space.s6),
                        child: Text(
                          'Aucun résultat pour « $_q »',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: c.textMuted),
                        ),
                      ),
                    ...matches,
                  ] else ...[
                    _tile(context, Icons.palette_outlined, 'UI Showcase', () => go(0), selected: current == 0),
                    _tile(context, Icons.widgets_outlined, 'Composants', () => go(1), selected: current == 1),
                    _tile(context, Icons.dashboard_customize_outlined, 'Layouts', () => go(2), selected: current == 2),
                    _tile(context, Icons.auto_awesome_outlined, 'Harnais (assistant IA)', () => go(3), selected: current == 3),
                    _tile(context, Icons.web_outlined, 'Pages d’exemple', () {
                      final nav = Navigator.of(context)..pop();
                      nav.push(MaterialPageRoute<void>(builder: (_) => const ExamplesIndex()));
                    }),
                    _tile(context, Icons.collections_bookmark_outlined, 'Galerie des pages', () {
                      final nav = Navigator.of(context)..pop();
                      nav.push(MaterialPageRoute<void>(builder: (_) => const PagesGallery()));
                    }),
                    _tile(context, Icons.devices_outlined, 'Showcases', () {
                      final nav = Navigator.of(context)..pop();
                      nav.push(MaterialPageRoute<void>(builder: (_) => const ShowcasesGallery()));
                    }),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(Space.s3, Space.s4, Space.s3, Space.s2),
                      child: Text(
                        'COMPOSANTS',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1, color: c.textMuted),
                      ),
                    ),
                    for (final cat in kCategories)
                      Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          dense: true,
                          tilePadding: const EdgeInsets.symmetric(horizontal: Space.s3),
                          leading: Icon(cat.icon, size: 20, color: c.textSecondary),
                          title: Text(
                            cat.label,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: c.textPrimary),
                          ),
                          childrenPadding: const EdgeInsets.only(left: 28),
                          children: [for (final s in cat.sections) _tile(context, null, s.$2, () => open(cat, s.$1), dense: true)],
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, IconData? icon, String label, VoidCallback onTap, {String? subtitle, bool bold = false, bool indent = false, bool dense = false, bool selected = false}) {
    final c = context.kc;
    // Destination courante : icône et libellé primaires, comme le panneau React Native.
    final color = selected ? c.primary : c.textPrimary;
    return ListTile(
      selected: selected,
      iconColor: selected ? c.primary : null,
      dense: dense || indent,
      contentPadding: EdgeInsets.only(left: indent ? Space.s6 : Space.s3, right: Space.s3),
      leading: icon == null ? null : Icon(icon, size: 20),
      minLeadingWidth: 20,
      title: Text(
        label,
        style: TextStyle(fontSize: 14, fontWeight: bold ? FontWeight.w700 : FontWeight.w500, color: color),
      ),
      subtitle: subtitle == null ? null : Text(subtitle),
      onTap: onTap,
    );
  }
}
