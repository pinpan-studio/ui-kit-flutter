import 'package:flutter/material.dart';

import '../../data/showcase_data.dart';
import '../../theme/kit_colors.dart';
import '../../theme/kit_text.dart';
import '../../theme/tokens.dart';
import '../../widgets/charts.dart';
import '../../widgets/common.dart';
import '../../widgets/kit_buttons.dart';
import '../doc/doc.dart';

/// Cadre d'appareil : rend son contenu à une largeur logique donnée puis le met à l'échelle,
/// pour comparer le comportement téléphone / tablette sur un même écran.
class DeviceFrame extends StatelessWidget {
  const DeviceFrame({super.key, required this.width, required this.child, this.height = 420});
  final double width, height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return LayoutBuilder(builder: (context, cons) {
      final scale = (cons.maxWidth / (width + 16)).clamp(0.2, 1.0);
      return Center(
        child: SizedBox(
          width: (width + 16) * scale,
          height: (height + 16) * scale,
          child: FittedBox(
            alignment: Alignment.topCenter,
            child: Container(
              width: width + 16,
              height: height + 16,
              padding: const EdgeInsets.all(Space.s2),
              decoration: BoxDecoration(color: c.textPrimary, borderRadius: BorderRadius.circular(28)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Radii.xl),
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(size: Size(width, height)),
                  child: ColoredBox(color: c.bg, child: SizedBox(width: width, height: height, child: child)),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

enum _Device { phone, tablet }

/// `/components/layout` — structures de page : conteneur, tableau de bord, colonnes,
/// barre latérale, pleine largeur, sections, conteneurs responsive, points de rupture.
class LayoutGallery extends StatefulWidget {
  const LayoutGallery({super.key, this.initialSection});
  final String? initialSection;

  @override
  State<LayoutGallery> createState() => _LayoutGalleryState();
}

class _LayoutGalleryState extends State<LayoutGallery> {
  _Device _device = _Device.phone;
  double _resp = 360;

  double get _w => _device == _Device.phone ? 375 : 820;

  Widget _toggle() => SegmentedToggle<_Device>(
        value: _device,
        onChanged: (d) => setState(() => _device = d),
        options: const [(_Device.phone, 'Téléphone', Icons.smartphone), (_Device.tablet, 'Tablette', Icons.tablet_mac)],
      );

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return DocPage(
      title: 'Layout',
      icon: Icons.dashboard_customize,
      initialSection: widget.initialSection,
      subtitle: 'Structures de page : conteneur, en-tête, grilles de tableau de bord, fiche en colonnes, panneaux de section, conteneurs responsive. Basculez téléphone / tablette pour voir la recomposition.',
      header: Align(alignment: Alignment.centerLeft, child: _toggle()),
      sections: [
        DocSection(
          id: 'page',
          title: 'Page layout',
          source: 'Scaffold + AppBar + PageHeader + contenu défilant',
          children: [
            Demo(
              label: 'Page liste',
              muted: true,
              child: DeviceFrame(
                width: _w,
                child: Scaffold(
                  appBar: AppBar(primary: false, leading: const Icon(Icons.menu), title: const Text('Clients'), actions: const [Icon(Icons.notifications_outlined), SizedBox(width: 16)]),
                  floatingActionButton: _device == _Device.phone ? FloatingActionButton(heroTag: null, onPressed: () {}, child: const Icon(Icons.add)) : null,
                  body: ListView(padding: const EdgeInsets.all(Space.s4), children: [
                    PageHeader(
                      breadcrumb: 'Registre',
                      title: 'Clients',
                      subtitle: '40 clients · 31 actifs',
                      actions: [if (_device == _Device.tablet) KitButton(label: 'Nouveau client', icon: Icons.add, onPressed: () {})],
                    ),
                    const SizedBox(height: 12),
                    for (final x in kDemoClients.take(5))
                      Padding(
                        padding: const EdgeInsets.only(bottom: Space.s2),
                        child: KitCard(
                          padding: const EdgeInsets.all(Space.s3),
                          child: Row(children: [
                            KitAvatar(name: x.raisonSociale, size: 34),
                            const SizedBox(width: 10),
                            Expanded(child: Text(x.raisonSociale, overflow: TextOverflow.ellipsis)),
                            StatusBadge(x.statut.label, tone: x.statut.tone),
                          ]),
                        ),
                      ),
                  ]),
                ),
              ),
            ),
          ],
        ),
        DocSection(
          id: 'dashboard',
          title: 'Dashboard layout',
          source: 'ResponsiveGrid (KPI) + graphiques',
          description: 'KPI en 2 colonnes sur téléphone, 4 sur tablette ; les graphiques passent côte à côte au-delà de 600 px.',
          children: [
            Demo(
              label: 'Tableau de bord',
              muted: true,
              child: DeviceFrame(
                width: _w,
                height: 520,
                child: ListView(padding: const EdgeInsets.all(Space.s4), children: [
                  Text('Tableau de bord', style: context.t.pageTitle),
                  const SizedBox(height: 12),
                  ResponsiveGrid(minItemWidth: 160, spacing: 10, children: const [
                    _MiniKpi(Icons.groups, '1 284', 'Clients', KitTone.primary),
                    _MiniKpi(Icons.local_shipping, '8 432', 'Véhicules', KitTone.info),
                    _MiniKpi(Icons.payments, '55,8 M', 'CA', KitTone.success),
                    _MiniKpi(Icons.warning_amber, '17', 'Alertes', KitTone.warning),
                  ]),
                  const SizedBox(height: 10),
                  ResponsiveGrid(minItemWidth: 300, spacing: 10, maxColumns: 2, children: [
                    KitCard(title: 'Chiffre d’affaires', child: KitChart(kind: ChartKind.area, labels: kMois.sublist(0, 10), series: [ChartSeries('2026', kCa2026.sublist(0, 10))], height: 130, showLegend: false)),
                    const KitCard(title: 'Répartition', child: KitChart(kind: ChartKind.doughnut, labels: ['Abonnement', 'Installation', 'Matériel'], series: [ChartSeries('Part', [60, 25, 15])], height: 130, showLegend: false)),
                  ]),
                ]),
              ),
            ),
          ],
        ),
        DocSection(
          id: 'two-cols',
          title: 'Two columns',
          source: 'fiche détail : colonne principale + colonne latérale',
          description: 'Sur téléphone la colonne latérale passe sous la principale ; sur tablette, ratio 2 : 1.',
          children: [
            Demo(
              label: 'Fiche client',
              muted: true,
              child: DeviceFrame(
                width: _w,
                height: 460,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(Space.s4),
                  child: _TwoCols(
                    main: const KitCard(
                      title: 'Informations',
                      icon: Icons.info_outline,
                      child: Column(children: [_Line('Raison sociale', 'Transports Yao & Fils'), _Line('Contact', 'Jean Kouassi'), _Line('Ville', 'Abidjan'), _Line('Véhicules', '24')]),
                    ),
                    side: KitCard(
                      title: 'Activité',
                      icon: Icons.history,
                      child: Column(children: [
                        for (final e in kTimelineEvents.take(3)) ListTile(dense: true, contentPadding: EdgeInsets.zero, leading: Icon(e.icon, size: 18, color: e.tone.color(c)), title: Text(e.titre)),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        DocSection(
          id: 'three-cols',
          title: 'Three columns',
          source: 'ResponsiveGrid(maxColumns: 3)',
          children: [
            Demo(
              label: 'Offres',
              muted: true,
              child: DeviceFrame(
                width: _w,
                height: 440,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(Space.s4),
                  child: ResponsiveGrid(minItemWidth: 220, maxColumns: 3, spacing: 10, children: [
                    for (final (t, p, ic) in const [('Essentiel', '9 900 F', Icons.gps_fixed), ('Standard', '14 500 F', Icons.verified), ('Premium', '24 000 F', Icons.workspace_premium)])
                      KitCard(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Icon(ic, color: c.primary),
                          const SizedBox(height: 8),
                          Text(t, style: context.t.cardTitle),
                          Text('$p / mois', style: TextStyle(color: c.textSecondary)),
                        ]),
                      ),
                  ]),
                ),
              ),
            ),
          ],
        ),
        DocSection(
          id: 'sidebar',
          title: 'Sidebar layout',
          source: 'NavigationRail (tablette) / tiroir (téléphone)',
          children: [
            Demo(
              label: 'Navigation adaptative',
              muted: true,
              child: DeviceFrame(
                width: _w,
                height: 360,
                child: _device == _Device.tablet
                    ? Row(children: [
                        NavigationRail(
                          selectedIndex: 1,
                          labelType: NavigationRailLabelType.all,
                          backgroundColor: c.card,
                          destinations: const [
                            NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), label: Text('Accueil')),
                            NavigationRailDestination(icon: Icon(Icons.people_outline), label: Text('Clients')),
                            NavigationRailDestination(icon: Icon(Icons.build_outlined), label: Text('Missions')),
                          ],
                        ),
                        const VerticalDivider(width: 1),
                        const Expanded(child: Center(child: Text('Contenu'))),
                      ])
                    : Scaffold(
                        appBar: AppBar(primary: false, leading: const Icon(Icons.menu), title: const Text('Clients')),
                        body: const Center(child: Text('Contenu — menu dans le tiroir')),
                        bottomNavigationBar: NavigationBar(
                          height: 60,
                          selectedIndex: 1,
                          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
                          destinations: const [
                            NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Accueil'),
                            NavigationDestination(icon: Icon(Icons.people_outline), label: 'Clients'),
                            NavigationDestination(icon: Icon(Icons.build_outlined), label: 'Missions'),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
        DocSection(
          id: 'full',
          title: 'Full width',
          source: 'contenu bord à bord (carte, média)',
          children: [
            Demo(
              label: 'Bandeau pleine largeur',
              flush: true,
              child: Container(
                height: 130,
                decoration: BoxDecoration(gradient: LinearGradient(colors: [c.primary, c.info])),
                padding: const EdgeInsets.all(Space.s5),
                alignment: Alignment.bottomLeft,
                child: const Text('Votre flotte, en temps réel', style: TextStyle(color: Colors.white, fontFamily: Fonts.heading, fontSize: 22, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
        DocSection(
          id: 'sections',
          title: 'Card sections',
          source: 'KitCard(title, icon, trailing)',
          cols: 2,
          children: [
            KitCard(title: 'Coordonnées', icon: Icons.contact_mail_outlined, trailing: IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined, size: 18)), child: const Column(children: [_Line('Téléphone', '+225 07 10 20 30 40'), _Line('E-mail', 'contact@yao.ci')])),
            KitCard(title: 'Équipements', icon: Icons.settings_input_antenna, trailing: const StatusBadge('24', tone: KitTone.primary), child: const Column(children: [_Line('Balises actives', '22'), _Line('Hors ligne', '2')])),
          ],
        ),
        DocSection(
          id: 'responsive',
          title: 'Responsive containers',
          source: 'LayoutBuilder · ResponsiveGrid',
          description: 'Faites glisser pour changer la largeur disponible : la grille recalcule son nombre de colonnes.',
          children: [
            Demo(
              label: 'Largeur : ${_resp.round()} px',
              child: Gap([
                Slider(value: _resp, min: 280, max: 1024, onChanged: (v) => setState(() => _resp = v)),
                DeviceFrame(
                  width: _resp,
                  height: 240,
                  child: Padding(
                    padding: const EdgeInsets.all(Space.s3),
                    child: LayoutBuilder(
                      builder: (_, cons) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('${Breakpoints.columns(cons.maxWidth, max: 4)} colonne(s)', style: TextStyle(fontWeight: FontWeight.w700, color: c.textPrimary)),
                        const SizedBox(height: 8),
                        ResponsiveGrid(minItemWidth: 150, spacing: 8, children: [
                          for (var i = 0; i < 6; i++) Container(height: 46, decoration: BoxDecoration(color: c.primary.withValues(alpha: 0.12 + i * 0.05), borderRadius: Radii.rm), alignment: Alignment.center, child: Text('${i + 1}')),
                        ]),
                      ]),
                    ),
                  ),
                ),
              ]),
            ),
          ],
        ),
        DocSection(
          id: 'breakpoints',
          title: 'Breakpoints',
          source: 'Breakpoints (styles/_breakpoints.scss)',
          children: [
            KitCard(
              padding: EdgeInsets.zero,
              child: Column(children: [
                for (final (n, v, u) in const [
                  ('xs', 375, 'Petits mobiles'),
                  ('sm', 480, 'Mobiles standard'),
                  ('md', 600, 'Grands mobiles — 2 colonnes'),
                  ('tablet', 768, 'Tablette portrait — rail visible'),
                  ('lg', 960, 'Tablette paysage — 3 colonnes'),
                  ('xl', 1024, 'Desktop'),
                ])
                  ListTile(
                    leading: Text('Breakpoints.$n', style: TextStyle(fontFamily: Fonts.mono, fontSize: 11.5, color: c.primary)),
                    title: Text('$v px'),
                    subtitle: Text(u),
                    trailing: MediaQuery.sizeOf(context).width >= v ? Icon(Icons.check_circle, color: c.success, size: 18) : null,
                  ),
              ]),
            ),
            Text('Largeur actuelle : ${MediaQuery.sizeOf(context).width.round()} px', style: TextStyle(fontSize: 12, color: c.textMuted)),
          ],
        ),
      ],
    );
  }
}

class _MiniKpi extends StatelessWidget {
  const _MiniKpi(this.icon, this.value, this.label, this.tone);
  final IconData icon;
  final String value, label;
  final KitTone tone;

  @override
  Widget build(BuildContext context) => KpiCard(icon: icon, value: value, label: label, tone: tone);
}

class _Line extends StatelessWidget {
  const _Line(this.k, this.v);
  final String k, v;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.s2),
      child: Row(children: [
        Expanded(child: Text(k, style: TextStyle(fontSize: 12.5, color: c.textSecondary))),
        Flexible(child: Text(v, textAlign: TextAlign.right, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.textPrimary))),
      ]),
    );
  }
}

class _TwoCols extends StatelessWidget {
  const _TwoCols({required this.main, required this.side});
  final Widget main, side;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, cons) {
        if (cons.maxWidth < Breakpoints.md) return Column(children: [main, const SizedBox(height: 12), side]);
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 2, child: main), const SizedBox(width: 12), Expanded(child: side)]);
      });
}
