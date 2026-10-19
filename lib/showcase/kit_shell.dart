import 'package:flutter/material.dart';

import '../examples/examples_index.dart';
import '../harnais/harnais_screen.dart';
import '../theme/kit_colors.dart';
import '../theme/tokens.dart';
import 'components_index.dart';
import 'kit_nav.dart';
import 'layouts/layouts_gallery.dart';
import 'ui_showcase_page.dart';

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

  void select(int i) => setState(() => _index = i);
  void openDrawer() => _scaffold.currentState?.openDrawer();

  @override
  Widget build(BuildContext context) {
    final pages = [
      UiShowcasePage(onMenu: openDrawer),
      ComponentsIndexPage(onMenu: openDrawer),
      LayoutsGalleryPage(onMenu: openDrawer),
      HarnaisScreen(onExit: () => select(0)),
    ];
    final harnais = _index == 3;
    return Scaffold(
      key: _scaffold,
      drawer: const KitDrawer(),
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
    );
  }
}

/// Logo + nom du kit.
class KitBrand extends StatelessWidget {
  const KitBrand({super.key, this.size = 32});
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(size * 0.3)),
        child: Icon(Icons.widgets, color: c.onPrimary, size: size * 0.58),
      ),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text('UI Kit', style: TextStyle(fontFamily: Fonts.brand, fontSize: 17, fontWeight: FontWeight.w700, color: c.textPrimary, height: 1.1)),
        Text('Flutter · mobile', style: TextStyle(fontSize: 11, color: c.textMuted)),
      ]),
    ]);
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
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
                focusedBorder: OutlineInputBorder(borderRadius: Radii.pill, borderSide: BorderSide(color: c.primary, width: 1.5)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(padding: const EdgeInsets.symmetric(horizontal: Space.s2, vertical: Space.s1), children: [
              if (q.isNotEmpty) ...[
                if (matches.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(Space.s6),
                    child: Text('Aucun résultat pour « $_q »', textAlign: TextAlign.center, style: TextStyle(color: c.textMuted)),
                  ),
                ...matches,
              ] else ...[
                _tile(context, Icons.palette_outlined, 'UI Showcase', () => go(0)),
                _tile(context, Icons.widgets_outlined, 'Composants', () => go(1)),
                _tile(context, Icons.dashboard_customize_outlined, 'Layouts', () => go(2)),
                _tile(context, Icons.auto_awesome_outlined, 'Harnais (assistant IA)', () => go(3)),
                _tile(context, Icons.web_outlined, 'Pages d’exemple', () {
                  final nav = Navigator.of(context)..pop();
                  nav.push(MaterialPageRoute<void>(builder: (_) => const ExamplesIndex()));
                }),
                Padding(
                  padding: const EdgeInsets.fromLTRB(Space.s3, Space.s4, Space.s3, Space.s2),
                  child: Text('COMPOSANTS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1, color: c.textMuted)),
                ),
                for (final cat in kCategories)
                  Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      dense: true,
                      tilePadding: const EdgeInsets.symmetric(horizontal: Space.s3),
                      leading: Icon(cat.icon, size: 20, color: c.textSecondary),
                      title: Text(cat.label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: c.textPrimary)),
                      childrenPadding: const EdgeInsets.only(left: 28),
                      children: [
                        for (final s in cat.sections) _tile(context, null, s.$2, () => open(cat, s.$1), dense: true),
                      ],
                    ),
                  ),
              ],
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _tile(BuildContext context, IconData? icon, String label, VoidCallback onTap,
      {String? subtitle, bool bold = false, bool indent = false, bool dense = false}) {
    final c = context.kc;
    return ListTile(
      dense: dense || indent,
      visualDensity: dense ? VisualDensity.compact : null,
      contentPadding: EdgeInsets.only(left: indent ? Space.s6 : Space.s3, right: Space.s3),
      leading: icon == null ? null : Icon(icon, size: 20),
      minLeadingWidth: 20,
      title: Text(label, style: TextStyle(fontSize: dense ? 13 : 14, fontWeight: bold ? FontWeight.w700 : FontWeight.w500, color: c.textPrimary)),
      subtitle: subtitle == null ? null : Text(subtitle),
      onTap: onTap,
    );
  }
}
