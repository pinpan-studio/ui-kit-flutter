import 'package:flutter/material.dart';

import '../data/showcase_data.dart';
import '../theme/kit_colors.dart';
import '../theme/tokens.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';
import '../widgets/kit_buttons.dart';
import 'ex_scaffold.dart';

// ─── Briques communes ───────────────────────────────────────────────────────

/// Ligne cliquable sans ListTile (évite l'alerte ListTile-dans-DecoratedBox).
class ExTile extends StatelessWidget {
  const ExTile({super.key, this.leading, required this.title, this.subtitle, this.trailing, this.onTap, this.selected = false});
  final Widget? leading, trailing;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return Material(
      color: selected ? c.primaryLight : Colors.transparent,
      borderRadius: BorderRadius.circular(Radii.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(Radii.md),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.s3, vertical: Space.s2),
            child: Row(children: [
              if (leading != null) ...[leading!, const SizedBox(width: Space.s3)],
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                if (subtitle != null) Text(subtitle!, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: c.textMuted)),
              ])),
              if (trailing != null) ...[const SizedBox(width: Space.s2), trailing!],
            ]),
          ),
        ),
      ),
    );
  }
}

/// En-tête de page : titre, sous-titre, actions qui passent à la ligne.
class ExHeader extends StatelessWidget {
  const ExHeader(this.title, {super.key, this.subtitle, this.actions = const []});
  final String title;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: Space.s4),
        child: Wrap(spacing: Space.s4, runSpacing: Space.s3, alignment: WrapAlignment.spaceBetween, crossAxisAlignment: WrapCrossAlignment.center, children: [
          ConstrainedBox(constraints: const BoxConstraints(maxWidth: 560), child: ExHeading(title, subtitle: subtitle)),
          if (actions.isNotEmpty) Wrap(spacing: Space.s2, runSpacing: Space.s2, children: actions),
        ]),
      );
}

/// Liste + détail côte à côte à partir de 1024 px ; sinon le détail s'ouvre en page.
class ExMasterDetail extends StatelessWidget {
  const ExMasterDetail({super.key, required this.list, required this.detail, this.listWidth = 340});
  final Widget list, detail;
  final double listWidth;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        if (box.maxWidth < Breakpoints.xl) return list;
        return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SizedBox(width: listWidth, child: list),
          VerticalDivider(width: 1, color: context.kc.border),
          Expanded(child: detail),
        ]);
      });
}

bool exWide(BuildContext context) => MediaQuery.sizeOf(context).width >= Breakpoints.xl;

void exPush(BuildContext context, String title, Widget body) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => Scaffold(appBar: AppBar(title: Text(title)), body: body)));

String exMoney(int v) => '${v.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ' ')} F';

// ─── Tableau de bord ────────────────────────────────────────────────────────
class DashboardExample extends StatefulWidget {
  const DashboardExample({super.key});
  @override
  State<DashboardExample> createState() => _DashboardState();
}

class _DashboardState extends State<DashboardExample> {
  String _range = '24 h';
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return ExPage(title: 'Tableau de bord', maxWidth: 1280, children: [
      ExHeader('Bonjour, Jean', subtitle: 'Voici l’activité de SC Storage sur la période.', actions: [
        SegmentedButton<String>(segments: [for (final r in ['1 h', '24 h', '7 j']) ButtonSegment(value: r, label: Text(r))], selected: {_range}, onSelectionChanged: (s) => setState(() => _range = s.first), showSelectedIcon: false),
        KitButton(label: 'Exporter', icon: Icons.download, variant: KitButtonVariant.outline, onPressed: () => exDemo(context, 'Export')),
      ]),
      Container(
        padding: const EdgeInsets.all(Space.s3),
        decoration: BoxDecoration(color: context.kc.warningLight, borderRadius: BorderRadius.circular(Radii.md)),
        child: Wrap(spacing: Space.s3, runSpacing: Space.s2, crossAxisAlignment: WrapCrossAlignment.center, children: [
          Icon(Icons.warning_amber, color: context.kc.warningText),
          Text('3 factures arrivent à échéance cette semaine.', style: TextStyle(color: context.kc.warningText)),
          TextButton(onPressed: () {}, child: const Text('Voir les factures')),
        ]),
      ),
      const SizedBox(height: Space.s4),
      const ResponsiveGrid(minItemWidth: 220, children: [
        KpiCard(icon: Icons.payments_outlined, value: '55,8 M', unit: 'F', label: 'Chiffre d’affaires', delta: '+12 %', up: true),
        KpiCard(icon: Icons.people_outline, value: '1 284', label: 'Clients actifs', delta: '+4 %', up: true, tone: KitTone.info),
        KpiCard(icon: Icons.local_shipping_outlined, value: '326', label: 'Livraisons', delta: '-2 %', up: false, tone: KitTone.warning),
        KpiCard(icon: Icons.sentiment_satisfied_alt, value: '98 %', label: 'Satisfaction', delta: '+1 pt', up: true, tone: KitTone.success),
      ]),
      const SizedBox(height: Space.s4),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          for (final (i, t) in ['Vue d’ensemble', 'Ventes', 'Clients', 'Stocks'].indexed)
            Padding(padding: const EdgeInsets.only(right: Space.s2), child: ChoiceChip(label: Text(t), selected: _tab == i, onSelected: (_) => setState(() => _tab = i))),
        ]),
      ),
      const SizedBox(height: Space.s4),
      LayoutBuilder(builder: (context, box) {
        final chart = KitCard(title: 'Chiffre d’affaires', icon: Icons.show_chart, child: KitChart(kind: ChartKind.area, labels: kMois.sublist(0, 10), series: [ChartSeries('2026', kCa2026.sublist(0, 10)), ChartSeries('2025', kCa2025.sublist(0, 10))], height: 200, compactValues: true));
        final activity = KitCard(title: 'Activité récente', icon: Icons.history, child: Column(children: [
          for (final a in const [('Facture F-2026-118 payée', 'Il y a 5 min', Icons.receipt_long), ('Nouveau client : Sotra Logistique', 'Il y a 1 h', Icons.person_add_alt), ('Stock bas : cartons 60×40', 'Il y a 3 h', Icons.inventory_2_outlined), ('Livraison L-2291 terminée', 'Hier', Icons.local_shipping_outlined)])
            ExTile(leading: Icon(a.$3, color: context.kc.primary), title: a.$1, subtitle: a.$2),
        ]));
        if (box.maxWidth < Breakpoints.xl) return ExGap([chart, activity]);
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 3, child: chart), const SizedBox(width: Space.s4), Expanded(flex: 2, child: activity)]);
      }),
    ]);
  }
}

// ─── Clients ────────────────────────────────────────────────────────────────
class ClientsExample extends StatefulWidget {
  const ClientsExample({super.key});
  @override
  State<ClientsExample> createState() => _ClientsState();
}

class _ClientsState extends State<ClientsExample> {
  String _q = '';
  ClientStatut? _filter;

  @override
  Widget build(BuildContext context) {
    final rows = kDemoClients.where((c) => (_filter == null || c.statut == _filter) && c.raisonSociale.toLowerCase().contains(_q.toLowerCase())).toList();
    return ExPage(title: 'Clients', maxWidth: 1280, children: [
      ExHeader('Clients', subtitle: '${kDemoClients.length} comptes', actions: [KitButton(label: 'Nouveau client', icon: Icons.add, onPressed: () => exDemo(context, 'Création'))]),
      TextField(onChanged: (v) => setState(() => _q = v), decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Rechercher un client…')),
      const SizedBox(height: Space.s3),
      Wrap(spacing: Space.s2, runSpacing: Space.s2, children: [
        ChoiceChip(label: const Text('Tous'), selected: _filter == null, onSelected: (_) => setState(() => _filter = null)),
        for (final s in ClientStatut.values) ChoiceChip(label: Text(s.label), selected: _filter == s, onSelected: (_) => setState(() => _filter = s)),
      ]),
      const SizedBox(height: Space.s4),
      if (rows.isEmpty) const EmptyState(icon: Icons.search_off, title: 'Aucun client', subtitle: 'Ajustez vos critères de recherche.'),
      LayoutBuilder(builder: (context, box) {
        if (box.maxWidth >= Breakpoints.xl) {
          return KitCard(padding: EdgeInsets.zero, child: Column(children: [
            for (final c in rows)
              ExTile(
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ClientDetailExample(client: c))),
                leading: KitAvatar(name: c.raisonSociale),
                title: c.raisonSociale,
                subtitle: '${c.code} · ${c.contact}',
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  SizedBox(width: 140, child: Text(c.ville, overflow: TextOverflow.ellipsis)),
                  SizedBox(width: 140, child: Text(c.secteur, overflow: TextOverflow.ellipsis)),
                  SizedBox(width: 120, child: Text(exMoney(c.caMensuel), textAlign: TextAlign.right)),
                  const SizedBox(width: Space.s4),
                  SizedBox(width: 100, child: Align(alignment: Alignment.centerLeft, child: StatusBadge(c.statut.label, tone: c.statut.tone))),
                ]),
              ),
          ]));
        }
        return Column(children: [
          for (final c in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.s2),
              child: KitCard(
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ClientDetailExample(client: c))),
                child: Row(children: [
                  KitAvatar(name: c.raisonSociale),
                  const SizedBox(width: Space.s3),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(c.raisonSociale, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text('${c.ville} · ${exMoney(c.caMensuel)}/mois', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: context.kc.textMuted)),
                  ])),
                  StatusBadge(c.statut.label, tone: c.statut.tone),
                ]),
              ),
            ),
        ]);
      }),
    ]);
  }
}

// ─── Fiche client ───────────────────────────────────────────────────────────
class ClientDetailExample extends StatelessWidget {
  ClientDetailExample({super.key, DemoClient? client}) : client = client ?? kDemoClients.first;
  final DemoClient client;

  @override
  Widget build(BuildContext context) {
    final c = client;
    final infos = [(Icons.person_outline, 'Contact', c.contact), (Icons.alternate_email, 'E-mail', c.email), (Icons.phone, 'Téléphone', c.telephone), (Icons.location_on_outlined, 'Ville', c.ville), (Icons.category_outlined, 'Secteur', c.secteur), (Icons.local_shipping_outlined, 'Véhicules', '${c.vehicules}')];
    return DefaultTabController(
      length: 3,
      child: ExPage(title: 'Fiche client', maxWidth: 1100, children: [
        KitCard(child: Wrap(spacing: Space.s4, runSpacing: Space.s3, crossAxisAlignment: WrapCrossAlignment.center, children: [
          KitAvatar(name: c.raisonSociale, size: 56),
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(c.raisonSociale, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            Text(c.code, style: TextStyle(color: context.kc.textMuted)),
          ]),
          StatusBadge(c.statut.label, tone: c.statut.tone),
          Wrap(spacing: Space.s2, runSpacing: Space.s2, children: [
            KitButton(label: 'Appeler', icon: Icons.call, variant: KitButtonVariant.secondary, onPressed: () => exDemo(context, 'Appel')),
            KitButton(label: 'Modifier', icon: Icons.edit, variant: KitButtonVariant.outline, onPressed: () => exDemo(context, 'Modification')),
          ]),
        ])),
        const SizedBox(height: Space.s4),
        const ResponsiveGrid(minItemWidth: 200, children: [
          KpiCard(icon: Icons.payments_outlined, value: '4,2 M', unit: 'F', label: 'CA annuel'),
          KpiCard(icon: Icons.receipt_long, value: '38', label: 'Factures', tone: KitTone.info),
          KpiCard(icon: Icons.schedule, value: '12 j', label: 'Délai moyen de paiement', tone: KitTone.warning),
        ]),
        const SizedBox(height: Space.s4),
        const TabBar(isScrollable: true, tabAlignment: TabAlignment.start, tabs: [Tab(text: 'Coordonnées'), Tab(text: 'Factures'), Tab(text: 'Historique')]),
        const SizedBox(height: Space.s4),
        SizedBox(
          height: 360,
          child: TabBarView(children: [
            SingleChildScrollView(child: ResponsiveGrid(minItemWidth: 240, spacing: Space.s3, children: [
              for (final i in infos) KitCard(child: Row(children: [Icon(i.$1, color: context.kc.primary), const SizedBox(width: Space.s3), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(i.$2, style: TextStyle(fontSize: 12, color: context.kc.textMuted)), Text(i.$3, overflow: TextOverflow.ellipsis)]))])),
            ])),
            ListView(children: [
              for (var i = 0; i < 6; i++)
                ExTile(leading: const Icon(Icons.receipt_long), title: 'F-2026-${120 - i}', subtitle: '${12 - i} oct. 2026', trailing: StatusBadge(i == 0 ? 'En attente' : 'Payée', tone: i == 0 ? KitTone.warning : KitTone.success)),
            ]),
            ListView(children: [
              for (final e in const [('Contrat renouvelé', '01/10/2026'), ('Ajout de 4 véhicules', '15/09/2026'), ('Visite commerciale', '02/09/2026'), ('Création du compte', '12/03/2024')])
                ExTile(leading: const Icon(Icons.circle, size: 10), title: e.$1, subtitle: e.$2),
            ]),
          ]),
        ),
      ]),
    );
  }
}

// ─── Messagerie (inbox) ─────────────────────────────────────────────────────
const _mails = [
  ('Aya Koné', 'Devis transport Abidjan – Bouaké', 'Bonjour Jean, pourriez-vous nous envoyer le devis pour 12 palettes ?', '09:42', true),
  ('Service comptable', 'Relance facture F-2026-114', 'La facture arrive à échéance vendredi. Merci de confirmer le règlement.', '08:15', true),
  ('Moussa Traoré', 'Planning de la semaine', 'Voici le planning des tournées. Deux chauffeurs sont en congé jeudi.', 'Hier', false),
  ('Orange Business', 'Votre facture d’octobre', 'Votre facture mensuelle est disponible dans votre espace client.', 'Hier', false),
  ('Fatou Bamba', 'Réunion trimestrielle', 'La réunion est confirmée pour le 28 octobre à 10 h au Plateau.', 'Lun.', false),
];

class InboxExample extends StatefulWidget {
  const InboxExample({super.key});
  @override
  State<InboxExample> createState() => _InboxState();
}

class _InboxState extends State<InboxExample> {
  int _sel = 0;

  Widget _read(int i) => SingleChildScrollView(
        padding: const EdgeInsets.all(Space.s6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_mails[i].$2, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: Space.s4),
          Row(children: [KitAvatar(name: _mails[i].$1), const SizedBox(width: Space.s3), Expanded(child: Text(_mails[i].$1, style: const TextStyle(fontWeight: FontWeight.w600))), Text(_mails[i].$4)]),
          const SizedBox(height: Space.s6),
          Text('${_mails[i].$3}\n\nCordialement,\n${_mails[i].$1}'),
          const SizedBox(height: Space.s6),
          Wrap(spacing: Space.s2, runSpacing: Space.s2, children: [
            KitButton(label: 'Répondre', icon: Icons.reply, onPressed: () => exDemo(context, 'Réponse')),
            KitButton(label: 'Transférer', icon: Icons.forward, variant: KitButtonVariant.outline, onPressed: () => exDemo(context, 'Transfert')),
          ]),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final list = ListView(padding: const EdgeInsets.all(Space.s2), children: [
      for (var i = 0; i < _mails.length; i++)
        ExTile(
          selected: exWide(context) && _sel == i,
          onTap: () => exWide(context) ? setState(() => _sel = i) : exPush(context, _mails[i].$1, _read(i)),
          leading: KitAvatar(name: _mails[i].$1),
          title: _mails[i].$2,
          subtitle: '${_mails[i].$1} · ${_mails[i].$3}',
          trailing: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [Text(_mails[i].$4, style: const TextStyle(fontSize: 12)), if (_mails[i].$5) const CountDot(1)]),
        ),
    ]);
    return Scaffold(
      appBar: AppBar(title: const Text('Messagerie')),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => exDemo(context, 'Nouveau message'), icon: const Icon(Icons.edit), label: const Text('Écrire')),
      body: ExMasterDetail(list: list, detail: _read(_sel), listWidth: 380),
    );
  }
}

// ─── Catalogue ──────────────────────────────────────────────────────────────
class CatalogExample extends StatefulWidget {
  const CatalogExample({super.key});
  @override
  State<CatalogExample> createState() => _CatalogState();
}

class _CatalogState extends State<CatalogExample> {
  String _cat = 'Tout';
  final _cart = <int>{};
  static const _products = [
    ('Carton double cannelure', 'Emballage', 850, Icons.inventory_2_outlined), ('Palette Europe', 'Manutention', 12500, Icons.view_module_outlined),
    ('Film étirable 500 mm', 'Emballage', 6500, Icons.layers_outlined), ('Transpalette manuel', 'Manutention', 285000, Icons.precision_manufacturing_outlined),
    ('Étiquettes thermiques', 'Bureau', 12000, Icons.label_outline), ('Scanner code-barres', 'Bureau', 95000, Icons.qr_code_scanner),
    ('Gants de manutention', 'Sécurité', 2500, Icons.back_hand_outlined), ('Gilet haute visibilité', 'Sécurité', 3500, Icons.safety_divider),
  ];

  @override
  Widget build(BuildContext context) {
    final cats = ['Tout', ...{for (final p in _products) p.$2}];
    final items = [for (var i = 0; i < _products.length; i++) if (_cat == 'Tout' || _products[i].$2 == _cat) i];
    return ExPage(title: 'Catalogue', maxWidth: 1280, actions: [
      Badge(isLabelVisible: _cart.isNotEmpty, label: Text('${_cart.length}'), child: IconButton(tooltip: 'Panier', icon: const Icon(Icons.shopping_cart_outlined), onPressed: () => exDemo(context, 'Panier'))),
      const SizedBox(width: Space.s2),
    ], children: [
      const ExHeader('Catalogue', subtitle: 'Fournitures et équipements d’entrepôt'),
      Wrap(spacing: Space.s2, runSpacing: Space.s2, children: [for (final c in cats) ChoiceChip(label: Text(c), selected: _cat == c, onSelected: (_) => setState(() => _cat = c))]),
      const SizedBox(height: Space.s4),
      ResponsiveGrid(minItemWidth: 220, spacing: Space.s3, children: [
        for (final i in items)
          KitCard(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(height: 110, decoration: BoxDecoration(color: context.kc.hover, borderRadius: BorderRadius.circular(Radii.md)), child: Icon(_products[i].$4, size: 48, color: context.kc.primary)),
            const SizedBox(height: Space.s3),
            Text(_products[i].$1, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(_products[i].$2, style: TextStyle(fontSize: 12, color: context.kc.textMuted)),
            const SizedBox(height: Space.s2),
            Row(children: [
              Expanded(child: Text(exMoney(_products[i].$3), style: const TextStyle(fontWeight: FontWeight.w700))),
              IconButton.filledTonal(tooltip: _cart.contains(i) ? 'Retirer du panier' : 'Ajouter au panier', icon: Icon(_cart.contains(i) ? Icons.check : Icons.add_shopping_cart), onPressed: () => setState(() => _cart.contains(i) ? _cart.remove(i) : _cart.add(i))),
            ]),
          ])),
      ]),
    ]);
  }
}

// ─── Tableau kanban ─────────────────────────────────────────────────────────
class BoardExample extends StatelessWidget {
  const BoardExample({super.key});
  static const _cols = [
    ('À faire', KitTone.neutral, [('Inventaire zone B', 'Moussa', 'Haute'), ('Relancer Sotra', 'Aya', 'Moyenne'), ('Commander des palettes', 'Jean', 'Basse')]),
    ('En cours', KitTone.info, [('Livraison Bouaké', 'Koffi', 'Haute'), ('Audit sécurité', 'Fatou', 'Moyenne')]),
    ('En revue', KitTone.warning, [('Devis Agro-CI', 'Aya', 'Haute')]),
    ('Terminé', KitTone.success, [('Formation caristes', 'Jean', 'Basse'), ('Clôture septembre', 'Fatou', 'Moyenne')]),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tableau des tâches')),
      body: LayoutBuilder(builder: (context, box) {
        final w = box.maxWidth < Breakpoints.tablet ? box.maxWidth * .85 : 300.0;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(Space.s4),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (final col in _cols)
              Container(
                width: w,
                margin: const EdgeInsets.only(right: Space.s3),
                padding: const EdgeInsets.all(Space.s3),
                decoration: BoxDecoration(color: context.kc.hover, borderRadius: BorderRadius.circular(Radii.lg)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Row(children: [Expanded(child: Text(col.$1, style: const TextStyle(fontWeight: FontWeight.w700))), StatusBadge('${col.$3.length}', tone: col.$2)]),
                  const SizedBox(height: Space.s3),
                  for (final t in col.$3)
                    Padding(
                      padding: const EdgeInsets.only(bottom: Space.s2),
                      child: KitCard(onTap: () => exDemo(context, t.$1), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(t.$1, style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: Space.s2),
                        Row(children: [KitAvatar(name: t.$2, size: 24), const SizedBox(width: Space.s2), Expanded(child: Text(t.$2, overflow: TextOverflow.ellipsis)), StatusBadge(t.$3, uppercase: false, tone: t.$3 == 'Haute' ? KitTone.error : t.$3 == 'Moyenne' ? KitTone.warning : KitTone.neutral)]),
                      ])),
                    ),
                  TextButton.icon(onPressed: () => exDemo(context, 'Ajout de carte'), icon: const Icon(Icons.add), label: const Text('Ajouter une carte')),
                ]),
              ),
          ]),
        );
      }),
    );
  }
}

// ─── Modules ────────────────────────────────────────────────────────────────
class ModulesExample extends StatefulWidget {
  const ModulesExample({super.key});
  @override
  State<ModulesExample> createState() => _ModulesState();
}

class _ModulesState extends State<ModulesExample> {
  final _on = <String>{'Stocks', 'Ventes', 'Flotte'};
  static const _mods = [
    ('Stocks', 'Entrepôts, inventaires, mouvements', Icons.inventory_2_outlined), ('Ventes', 'Devis, commandes, factures', Icons.point_of_sale),
    ('Achats', 'Fournisseurs et réceptions', Icons.shopping_cart_outlined), ('Comptabilité', 'Écritures, rapprochements', Icons.account_balance_outlined),
    ('RH', 'Salariés, congés, paie', Icons.badge_outlined), ('Flotte', 'Véhicules, carburant, entretiens', Icons.local_shipping_outlined),
    ('CRM', 'Prospects et opportunités', Icons.handshake_outlined), ('Rapports', 'Tableaux de bord personnalisés', Icons.insights),
  ];

  @override
  Widget build(BuildContext context) => ExPage(title: 'Modules', maxWidth: 1200, children: [
        ExHeader('Modules', subtitle: '${_on.length} modules activés sur ${_mods.length}'),
        ResponsiveGrid(minItemWidth: 260, spacing: Space.s3, children: [
          for (final m in _mods)
            KitCard(child: Row(children: [
              Container(padding: const EdgeInsets.all(Space.s3), decoration: BoxDecoration(color: context.kc.primaryLight, borderRadius: BorderRadius.circular(Radii.md)), child: Icon(m.$3, color: context.kc.primary)),
              const SizedBox(width: Space.s3),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(m.$1, style: const TextStyle(fontWeight: FontWeight.w600)), Text(m.$2, style: TextStyle(fontSize: 12, color: context.kc.textMuted))])),
              Switch(value: _on.contains(m.$1), onChanged: (v) => setState(() => v ? _on.add(m.$1) : _on.remove(m.$1))),
            ])),
        ]),
      ]);
}

// ─── Blog & article ─────────────────────────────────────────────────────────
const _posts = [
  ('optimiser-entrepot', 'Optimiser l’espace de son entrepôt en 5 étapes', 'Logistique', 'Aya Koné', '12 oct. 2026', 6),
  ('mobile-money', 'Encaisser par Mobile Money : ce qui change en 2026', 'Finance', 'Moussa Traoré', '5 oct. 2026', 4),
  ('flotte-carburant', 'Réduire la consommation de carburant de sa flotte', 'Flotte', 'Koffi Yao', '28 sept. 2026', 8),
  ('inventaire-tournant', 'L’inventaire tournant, mode d’emploi', 'Stocks', 'Fatou Bamba', '20 sept. 2026', 5),
];

class BlogExample extends StatelessWidget {
  const BlogExample({super.key});
  @override
  Widget build(BuildContext context) => ExPage(title: 'Blog', maxWidth: 1200, children: [
        const ExHeader('Le blog SC Storage', subtitle: 'Conseils logistiques, nouveautés produit et retours d’expérience.'),
        ResponsiveGrid(minItemWidth: 280, maxColumns: 3, children: [
          for (final (i, p) in _posts.indexed)
            KitCard(
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ArticleExample(index: i))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                AspectRatio(aspectRatio: 16 / 9, child: Container(decoration: BoxDecoration(color: context.kc.primaryLight, borderRadius: BorderRadius.circular(Radii.md)), child: Icon(Icons.article_outlined, size: 48, color: context.kc.primary))),
                const SizedBox(height: Space.s3),
                StatusBadge(p.$3, uppercase: false, tone: KitTone.primary),
                const SizedBox(height: Space.s2),
                Text(p.$2, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: Space.s2),
                Text('${p.$4} · ${p.$5} · ${p.$6} min de lecture', style: TextStyle(fontSize: 12, color: context.kc.textMuted)),
              ]),
            ),
        ]),
      ]);
}

class ArticleExample extends StatelessWidget {
  const ArticleExample({super.key, this.index = 0});
  final int index;
  @override
  Widget build(BuildContext context) {
    final p = _posts[index];
    const para = 'Un entrepôt bien organisé réduit les temps de préparation et les erreurs. Commencez par cartographier les flux : réception, stockage, préparation et expédition. Placez les références à forte rotation au plus près des quais, et revoyez ce classement chaque trimestre.';
    return ExPage(title: 'Article', children: [
      StatusBadge(p.$3, uppercase: false, tone: KitTone.primary),
      const SizedBox(height: Space.s3),
      Text(p.$2, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: Space.s4),
      Row(children: [KitAvatar(name: p.$4), const SizedBox(width: Space.s3), Expanded(child: Text('${p.$4}\n${p.$5} · ${p.$6} min de lecture', style: TextStyle(color: context.kc.textMuted)))]),
      const SizedBox(height: Space.s6),
      for (final h in ['1. Cartographier les flux', '2. Classer par rotation', '3. Exploiter la hauteur']) ...[
        Text(h, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: Space.s2),
        const Text(para, style: TextStyle(height: 1.6)),
        const SizedBox(height: Space.s6),
      ],
      Container(
        padding: const EdgeInsets.all(Space.s4),
        decoration: BoxDecoration(border: Border(left: BorderSide(color: context.kc.primary, width: 4)), color: context.kc.hover),
        child: const Text('« Nous avons gagné 18 % de surface utile sans pousser un seul mur. »', style: TextStyle(fontStyle: FontStyle.italic)),
      ),
    ]);
  }
}

// ─── Documentation ──────────────────────────────────────────────────────────
class DocsExample extends StatefulWidget {
  const DocsExample({super.key});
  @override
  State<DocsExample> createState() => _DocsState();
}

class _DocsState extends State<DocsExample> {
  int _sel = 0;
  static const _pages = [('Démarrage', 'Prise en main'), ('Installation', 'Prise en main'), ('Entrepôts', 'Stocks'), ('Mouvements', 'Stocks'), ('Factures', 'Ventes'), ('API', 'Développeurs')];

  Widget _nav({VoidCallback? after}) => ListView(padding: const EdgeInsets.all(Space.s2), children: [
        for (final (i, p) in _pages.indexed) ...[
          if (i == 0 || _pages[i - 1].$2 != p.$2) Padding(padding: const EdgeInsets.fromLTRB(Space.s3, Space.s4, Space.s3, Space.s1), child: Text(p.$2.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1, color: context.kc.textMuted))),
          ExTile(title: p.$1, selected: _sel == i, onTap: () { setState(() => _sel = i); after?.call(); }),
        ],
      ]);

  @override
  Widget build(BuildContext context) {
    final content = SingleChildScrollView(
      padding: const EdgeInsets.all(Space.s6),
      child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 760), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${_pages[_sel].$2} › ${_pages[_sel].$1}', style: TextStyle(color: context.kc.textMuted)),
        const SizedBox(height: Space.s2),
        Text(_pages[_sel].$1, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: Space.s4),
        const Text('Cette page décrit la configuration de base. Suivez les étapes dans l’ordre ; chaque section se termine par une vérification.', style: TextStyle(height: 1.6)),
        const SizedBox(height: Space.s4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Space.s4),
          decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(Radii.md)),
          child: const SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text('curl -H "Authorization: Bearer <jeton>" https://api.sc-storage.ci/v1/entrepots', style: TextStyle(fontFamily: Fonts.mono, color: Colors.white, fontSize: 13))),
        ),
        const SizedBox(height: Space.s4),
        Container(
          padding: const EdgeInsets.all(Space.s3),
          decoration: BoxDecoration(color: context.kc.infoLight, borderRadius: BorderRadius.circular(Radii.md)),
          child: Row(children: [Icon(Icons.info_outline, color: context.kc.info), const SizedBox(width: Space.s2), const Expanded(child: Text('Les jetons expirent après 90 jours.'))]),
        ),
      ]))),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Documentation'), actions: [
        if (!exWide(context)) Builder(builder: (ctx) => IconButton(tooltip: 'Sommaire', icon: const Icon(Icons.menu_book), onPressed: () => Scaffold.of(ctx).openEndDrawer())),
      ]),
      endDrawer: exWide(context) ? null : Drawer(child: SafeArea(child: Builder(builder: (ctx) => _nav(after: () => Navigator.of(ctx).pop())))),
      body: exWide(context) ? Row(children: [SizedBox(width: 260, child: _nav()), VerticalDivider(width: 1, color: context.kc.border), Expanded(child: content)]) : content,
    );
  }
}

// ─── Fichiers (grille / liste) et vue Colonnes ──────────────────────────────
const _files = [
  ('Contrats', null, Icons.folder, '12 éléments'), ('Factures 2026', null, Icons.folder, '118 éléments'), ('Photos entrepôt', null, Icons.folder, '46 éléments'),
  ('Rapport-septembre.pdf', 'PDF', Icons.picture_as_pdf, '2,4 Mo'), ('Inventaire-zone-B.xlsx', 'XLSX', Icons.table_chart, '640 Ko'),
  ('Plan-quai-3.png', 'PNG', Icons.image_outlined, '1,1 Mo'), ('Présentation-client.pptx', 'PPTX', Icons.slideshow, '8,2 Mo'), ('Notes-réunion.docx', 'DOCX', Icons.description_outlined, '96 Ko'),
];

class FilesExample extends StatefulWidget {
  const FilesExample({super.key});
  @override
  State<FilesExample> createState() => _FilesState();
}

class _FilesState extends State<FilesExample> {
  bool _grid = true;

  @override
  Widget build(BuildContext context) => ExPage(title: 'Fichiers', maxWidth: 1280, children: [
        ExHeader('Mes fichiers', subtitle: '4,6 Go utilisés sur 10 Go', actions: [
          SegmentedButton<bool>(showSelectedIcon: false, segments: const [ButtonSegment(value: true, icon: Icon(Icons.grid_view), label: Text('Grille')), ButtonSegment(value: false, icon: Icon(Icons.list), label: Text('Liste'))], selected: {_grid}, onSelectionChanged: (s) => setState(() => _grid = s.first)),
          KitButton(label: 'Importer', icon: Icons.upload, onPressed: () => exDemo(context, 'Import')),
        ]),
        const KitProgressBar(value: .46),
        const SizedBox(height: Space.s4),
        if (_grid)
          ResponsiveGrid(minItemWidth: 160, maxColumns: 6, spacing: Space.s3, children: [
            for (final f in _files)
              KitCard(onTap: () => exDemo(context, f.$1), child: Column(children: [
                Icon(f.$3, size: 40, color: f.$2 == null ? Colors.amber.shade700 : context.kc.primary),
                const SizedBox(height: Space.s2),
                Text(f.$1, maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(f.$4, style: TextStyle(fontSize: 12, color: context.kc.textMuted)),
              ])),
          ])
        else
          KitCard(padding: EdgeInsets.zero, child: Column(children: [
            for (final f in _files) ExTile(onTap: () => exDemo(context, f.$1), leading: Icon(f.$3, color: f.$2 == null ? Colors.amber.shade700 : context.kc.primary), title: f.$1, subtitle: f.$4, trailing: IconButton(tooltip: 'Plus d’actions', icon: const Icon(Icons.more_vert), onPressed: () {})),
          ])),
      ]);
}

class FilesColumnsExample extends StatefulWidget {
  const FilesColumnsExample({super.key});
  @override
  State<FilesColumnsExample> createState() => _FilesColumnsState();
}

class _FilesColumnsState extends State<FilesColumnsExample> {
  final _path = <String>['Documents'];
  static const _tree = <String, List<String>>{
    'Documents': ['Contrats', 'Factures 2026', 'Rapport-septembre.pdf'],
    'Contrats': ['Sotra Logistique', 'Agro-CI', 'Contrat-cadre.pdf'],
    'Factures 2026': ['Octobre', 'Septembre', 'F-2026-118.pdf'],
    'Sotra Logistique': ['Avenant-2026.pdf', 'Contrat-2024.pdf'],
    'Agro-CI': ['Contrat-2025.pdf'],
    'Octobre': ['F-2026-118.pdf', 'F-2026-117.pdf'],
    'Septembre': ['F-2026-110.pdf'],
  };

  Widget _column(int level, {double? width}) {
    final items = _tree[_path[level]] ?? const [];
    return SizedBox(
      width: width,
      child: ListView(padding: const EdgeInsets.all(Space.s2), children: [
        for (final it in items)
          ExTile(
            selected: _path.length > level + 1 && _path[level + 1] == it,
            leading: Icon(_tree.containsKey(it) ? Icons.folder : Icons.picture_as_pdf, color: _tree.containsKey(it) ? Colors.amber.shade700 : context.kc.primary),
            title: it,
            trailing: _tree.containsKey(it) ? const Icon(Icons.chevron_right) : null,
            onTap: () => setState(() { _path.removeRange(level + 1, _path.length); if (_tree.containsKey(it)) _path.add(it); }),
          ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Fichiers · Colonnes')),
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Space.s3),
            child: Row(children: [
              for (final (i, p) in _path.indexed) ...[
                if (i > 0) const Icon(Icons.chevron_right, size: 18),
                TextButton(onPressed: () => setState(() => _path.removeRange(i + 1, _path.length)), child: Text(p)),
              ],
            ]),
          ),
          const Divider(height: 1),
          Expanded(child: LayoutBuilder(builder: (context, box) {
            // Mobile : une seule colonne (la plus profonde) ; au-delà, colonnes défilantes.
            if (box.maxWidth < Breakpoints.tablet) return _column(_path.length - 1);
            return SingleChildScrollView(scrollDirection: Axis.horizontal, child: SizedBox(height: box.maxHeight, child: Row(children: [
              for (var l = 0; l < _path.length; l++) ...[_column(l, width: 260), VerticalDivider(width: 1, color: context.kc.border)],
            ])));
          })),
        ]),
      );
}

// ─── Supervision ────────────────────────────────────────────────────────────
class MonitoringExample extends StatelessWidget {
  const MonitoringExample({super.key});
  static const _services = [('API publique', 'Opérationnel', KitTone.success, '99,98 %'), ('Synchronisation mobile', 'Opérationnel', KitTone.success, '99,91 %'), ('Paiements Mobile Money', 'Dégradé', KitTone.warning, '98,40 %'), ('Notifications SMS', 'Opérationnel', KitTone.success, '99,95 %'), ('Rapports', 'Incident', KitTone.error, '96,10 %')];

  @override
  Widget build(BuildContext context) => ExPage(title: 'Supervision', maxWidth: 1280, children: [
        ExHeader('Supervision', subtitle: 'État des services en temps réel', actions: [KitButton(label: 'Actualiser', icon: Icons.refresh, variant: KitButtonVariant.outline, onPressed: () => exDemo(context, 'Actualisation'))]),
        Container(
          padding: const EdgeInsets.all(Space.s3),
          decoration: BoxDecoration(color: context.kc.errorLight, borderRadius: BorderRadius.circular(Radii.md)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.error_outline, color: context.kc.errorText), const SizedBox(width: Space.s2), Expanded(child: Text('Incident en cours sur la génération des rapports depuis 10:42. Nos équipes sont mobilisées.', style: TextStyle(color: context.kc.errorText)))]),
        ),
        const SizedBox(height: Space.s4),
        const ResponsiveGrid(minItemWidth: 200, children: [
          KpiCard(icon: Icons.speed, value: '182', unit: 'ms', label: 'Latence moyenne', delta: '-8 %', up: true),
          KpiCard(icon: Icons.sync_alt, value: '12,4 k', label: 'Requêtes / min', tone: KitTone.info),
          KpiCard(icon: Icons.error_outline, value: '0,4 %', label: 'Taux d’erreur', tone: KitTone.error, delta: '+0,1 pt', up: false),
          KpiCard(icon: Icons.memory, value: '61 %', label: 'CPU', tone: KitTone.warning),
        ]),
        const SizedBox(height: Space.s4),
        LayoutBuilder(builder: (context, box) {
          final chart = KitCard(title: 'Latence (ms)', icon: Icons.show_chart, child: KitChart(kind: ChartKind.line, labels: const ['10:00', '10:10', '10:20', '10:30', '10:40', '10:50', '11:00'], series: [ChartSeries('API', const [170, 175, 168, 190, 240, 210, 182])], height: 200));
          final services = KitCard(title: 'Services', icon: Icons.dns_outlined, child: Column(children: [
            for (final s in _services) ExTile(leading: Icon(Icons.circle, size: 12, color: s.$3.text(context.kc)), title: s.$1, subtitle: 'Disponibilité 30 j : ${s.$4}', trailing: StatusBadge(s.$2, tone: s.$3, uppercase: false)),
          ]));
          if (box.maxWidth < Breakpoints.xl) return ExGap([chart, services]);
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: chart), const SizedBox(width: Space.s4), Expanded(child: services)]);
        }),
      ]);
}

// ─── Chat ───────────────────────────────────────────────────────────────────
class ChatExample extends StatefulWidget {
  const ChatExample({super.key});
  @override
  State<ChatExample> createState() => _ChatState();
}

class _ChatState extends State<ChatExample> {
  int _conv = 0;
  final _ctrl = TextEditingController();
  final _convs = [('Équipe logistique', 'Koffi : La tournée est bouclée'), ('Aya Koné', 'Merci pour le devis !'), ('Support SC Storage', 'Votre ticket est résolu'), ('Moussa Traoré', 'On se voit demain ?')];
  final _msgs = <(bool, String, String)>[
    (false, 'Bonjour à tous, la tournée de Bouaké part à 6 h demain.', '08:02'),
    (true, 'Parfait, les palettes sont prêtes au quai 3.', '08:05'),
    (false, 'Il manque deux cartons pour Agro-CI, je m’en occupe.', '08:11'),
    (true, 'Merci Koffi 👍', '08:12'),
    (false, 'La tournée est bouclée.', '17:40'),
  ];

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _send() {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() { _msgs.add((true, _ctrl.text.trim(), 'À l’instant')); _ctrl.clear(); });
  }

  Widget _thread() => Column(children: [
        Expanded(child: ListView(padding: const EdgeInsets.all(Space.s4), children: [
          for (final m in _msgs)
            Align(
              alignment: m.$1 ? Alignment.centerRight : Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  margin: const EdgeInsets.only(bottom: Space.s2),
                  padding: const EdgeInsets.symmetric(horizontal: Space.s3, vertical: Space.s2),
                  decoration: BoxDecoration(color: m.$1 ? context.kc.primary : context.kc.hover, borderRadius: BorderRadius.circular(Radii.lg)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(m.$2, style: TextStyle(color: m.$1 ? context.kc.onPrimary : context.kc.textPrimary)),
                    Text(m.$3, style: TextStyle(fontSize: 11, color: m.$1 ? context.kc.onPrimary.withValues(alpha: .7) : context.kc.textMuted)),
                  ]),
                ),
              ),
            ),
        ])),
        SafeArea(top: false, child: Padding(
          padding: const EdgeInsets.all(Space.s2),
          child: Row(children: [
            IconButton(tooltip: 'Joindre un fichier', icon: const Icon(Icons.attach_file), onPressed: () {}),
            Expanded(child: TextField(controller: _ctrl, onSubmitted: (_) => _send(), decoration: const InputDecoration(hintText: 'Écrire un message…'))),
            const SizedBox(width: Space.s2),
            IconButton.filled(tooltip: 'Envoyer', icon: const Icon(Icons.send), onPressed: _send),
          ]),
        )),
      ]);

  @override
  Widget build(BuildContext context) {
    final list = ListView(padding: const EdgeInsets.all(Space.s2), children: [
      for (final (i, c) in _convs.indexed)
        ExTile(selected: exWide(context) && _conv == i, leading: KitAvatar(name: c.$1, online: i.isEven), title: c.$1, subtitle: c.$2, onTap: () => exWide(context) ? setState(() => _conv = i) : exPush(context, c.$1, StatefulBuilder(builder: (_, _) => _thread()))),
    ]);
    return Scaffold(appBar: AppBar(title: Text(exWide(context) ? 'Messages · ${_convs[_conv].$1}' : 'Messages')), body: ExMasterDetail(list: list, detail: _thread()));
  }
}

// ─── Fil d'actualité ────────────────────────────────────────────────────────
class FeedExample extends StatefulWidget {
  const FeedExample({super.key});
  @override
  State<FeedExample> createState() => _FeedState();
}

class _FeedState extends State<FeedExample> {
  final _liked = <int>{1};
  static const _items = [
    ('Aya Koné', 'il y a 20 min', 'Nouveau record : 412 commandes préparées hier à l’entrepôt de Vridi ! Bravo à toute l’équipe 🎉', 24, 6),
    ('Koffi Yao', 'il y a 2 h', 'Rappel : formation caristes vendredi à 9 h, salle B. Pensez à vos EPI.', 8, 2),
    ('SC Storage', 'Hier', 'La version 4.2 est disponible : paiements Mobile Money intégrés et mode hors ligne amélioré.', 56, 14),
  ];

  @override
  Widget build(BuildContext context) => ExPage(title: 'Fil d’actualité', maxWidth: 640, children: [
        KitCard(child: Row(children: [
          const KitAvatar(name: 'Jean Kouassi'),
          const SizedBox(width: Space.s3),
          const Expanded(child: TextField(decoration: InputDecoration(hintText: 'Quoi de neuf, Jean ?'))),
          const SizedBox(width: Space.s2),
          IconButton.filled(tooltip: 'Publier', icon: const Icon(Icons.send), onPressed: () => exDemo(context, 'Publication')),
        ])),
        const SizedBox(height: Space.s4),
        for (final (i, p) in _items.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.s3),
            child: KitCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [KitAvatar(name: p.$1), const SizedBox(width: Space.s3), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.$1, style: const TextStyle(fontWeight: FontWeight.w600)), Text(p.$2, style: TextStyle(fontSize: 12, color: context.kc.textMuted))]))]),
              const SizedBox(height: Space.s3),
              Text(p.$3),
              const SizedBox(height: Space.s2),
              Wrap(spacing: Space.s2, children: [
                TextButton.icon(onPressed: () => setState(() => _liked.contains(i) ? _liked.remove(i) : _liked.add(i)), icon: Icon(_liked.contains(i) ? Icons.favorite : Icons.favorite_border), label: Text('${p.$4 + (_liked.contains(i) ? 1 : 0)}')),
                TextButton.icon(onPressed: () {}, icon: const Icon(Icons.chat_bubble_outline), label: Text('${p.$5}')),
                TextButton.icon(onPressed: () => exDemo(context, 'Partage'), icon: const Icon(Icons.share_outlined), label: const Text('Partager')),
              ]),
            ])),
          ),
      ]);
}

// ─── Paramètres ─────────────────────────────────────────────────────────────
class SettingsExample extends StatefulWidget {
  const SettingsExample({super.key});
  @override
  State<SettingsExample> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsExample> {
  int _sec = 0;
  bool _mail = true, _sms = false, _push = true, _twoFa = true;
  static const _sections = [(Icons.person_outline, 'Profil'), (Icons.notifications_none, 'Notifications'), (Icons.lock_outline, 'Sécurité'), (Icons.receipt_long, 'Facturation')];

  Widget _switch(String t, String s, bool v, ValueChanged<bool> on) => Padding(
        padding: const EdgeInsets.symmetric(vertical: Space.s2),
        child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: const TextStyle(fontWeight: FontWeight.w600)), Text(s, style: TextStyle(fontSize: 13, color: context.kc.textMuted))])), Switch(value: v, onChanged: on)]),
      );

  Widget _body() => switch (_sec) {
        0 => const ExGap([ExRow([KitTextField(label: 'Prénom', initialValue: 'Jean'), KitTextField(label: 'Nom', initialValue: 'Kouassi')]), KitTextField(label: 'E-mail', initialValue: 'jean.kouassi@scstorage.ci'), KitTextField(label: 'Téléphone', initialValue: '+225 07 10 20 30 40')]),
        1 => Column(children: [
            _switch('E-mail', 'Résumé quotidien et alertes', _mail, (v) => setState(() => _mail = v)),
            _switch('SMS', 'Alertes critiques uniquement', _sms, (v) => setState(() => _sms = v)),
            _switch('Notifications push', 'Sur l’application mobile', _push, (v) => setState(() => _push = v)),
          ]),
        2 => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _switch('Double authentification', 'Code SMS à chaque connexion', _twoFa, (v) => setState(() => _twoFa = v)),
            const SizedBox(height: Space.s2),
            Align(alignment: Alignment.centerLeft, child: KitButton(label: 'Changer le mot de passe', variant: KitButtonVariant.outline, onPressed: () => exDemo(context, 'Mot de passe'))),
          ]),
        _ => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const StatusBadge('Pro', tone: KitTone.purple, uppercase: false),
            const SizedBox(height: Space.s2),
            const Text('45 000 F / mois · renouvellement le 1er novembre 2026'),
            const SizedBox(height: Space.s3),
            KitButton(label: 'Gérer l’abonnement', onPressed: () => exDemo(context, 'Abonnement')),
          ]),
      };

  @override
  Widget build(BuildContext context) => ExPage(title: 'Paramètres', maxWidth: 1100, children: [
        LayoutBuilder(builder: (context, box) {
          final card = KitCard(title: _sections[_sec].$2, icon: _sections[_sec].$1, child: _body());
          if (box.maxWidth < Breakpoints.tablet) {
            return ExGap([
              SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [for (final (i, s) in _sections.indexed) Padding(padding: const EdgeInsets.only(right: Space.s2), child: ChoiceChip(avatar: Icon(s.$1, size: 18), label: Text(s.$2), selected: _sec == i, onSelected: (_) => setState(() => _sec = i)))])),
              card,
            ]);
          }
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 220, child: Column(children: [for (final (i, s) in _sections.indexed) ExTile(leading: Icon(s.$1), title: s.$2, selected: _sec == i, onTap: () => setState(() => _sec = i))])),
            const SizedBox(width: Space.s4),
            Expanded(child: card),
          ]);
        }),
        const SizedBox(height: Space.s4),
        Align(alignment: Alignment.centerRight, child: KitButton(label: 'Enregistrer', icon: Icons.save_outlined, onPressed: () => exDemo(context, 'Paramètres enregistrés'))),
      ]);
}
