import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import '../data/examples_data.dart';
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

String _group(int v) => v.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ' ');

/// Montant en FCFA, séparateur de milliers en espace (`4 250 000 FCFA`).
String exMoney(int v) => '${_group(v)} FCFA';

/// Format compact (`27,9 M`, `1,14 Md`), comme `format: 'compact'` côté Angular.
String exCompact(double v, {int decimals = 1}) {
  String f(double x) => x.toStringAsFixed(decimals).replaceAll('.', ',').replaceAll(RegExp(r',0+$'), '');
  if (v.abs() >= 1e9) return '${f(v / 1e9)} Md';
  if (v.abs() >= 1e6) return '${f(v / 1e6)} M';
  if (v.abs() >= 1e3) return '${f(v / 1e3)} k';
  return f(v);
}

String exDate(String iso) => DateFormat('d MMM y', 'fr_FR').format(DateTime.parse(iso));

/// Rendu du Markdown en ligne de la source (**gras**, *italique*, `code`, [lien](#)).
TextSpan exInline(BuildContext context, String text, {TextStyle? style}) {
  final c = context.kc;
  final spans = <InlineSpan>[];
  final re = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*|`(.+?)`|\[(.+?)\]\((.+?)\)');
  var last = 0;
  for (final m in re.allMatches(text)) {
    if (m.start > last) spans.add(TextSpan(text: text.substring(last, m.start)));
    if (m.group(1) != null) {
      spans.add(TextSpan(text: m.group(1), style: const TextStyle(fontWeight: FontWeight.w700)));
    } else if (m.group(2) != null) {
      spans.add(TextSpan(text: m.group(2), style: const TextStyle(fontStyle: FontStyle.italic)));
    } else if (m.group(3) != null) {
      spans.add(TextSpan(text: m.group(3), style: TextStyle(fontFamily: Fonts.mono, fontSize: 13, backgroundColor: c.hover)));
    } else {
      spans.add(TextSpan(text: m.group(4), style: TextStyle(color: c.primary, decoration: TextDecoration.underline)));
    }
    last = m.end;
  }
  if (last < text.length) spans.add(TextSpan(text: text.substring(last)));
  return TextSpan(style: style, children: spans);
}


// ─── Tableau de bord ────────────────────────────────────────────────────────
class DashboardExample extends StatefulWidget {
  const DashboardExample({super.key, this.openChat = false});

  /// Ouvre la messagerie en panneau latéral au démarrage (`?chat=c-aya`).
  final bool openChat;
  @override
  State<DashboardExample> createState() => _DashboardState();
}

class _DashboardState extends State<DashboardExample> {
  int _period = 2, _tab = 0;
  final _key = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    if (widget.openChat) WidgetsBinding.instance.addPostFrameCallback((_) => _key.currentState?.openEndDrawer());
  }

  String _trend(double t) => '${t >= 0 ? '+' : ''}${t.toStringAsFixed(1).replaceAll('.', ',')} %';

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final p = kDashPeriods[_period];
    final watch = kExClients.where((x) => x.status == ClientStatus.suspendu || x.status == ClientStatus.inactif).take(5).toList();
    final counts = {for (final s in ClientStatus.values) s: kExClients.where((x) => x.status == s).length};
    return ExPage(scaffoldKey: _key, title: 'Tableau de bord', maxWidth: 1280, endDrawer: const Drawer(width: 380, child: SafeArea(child: ChatPanel())), actions: [
      Builder(builder: (ctx) => IconButton(tooltip: 'Messagerie', icon: Badge(label: Text('${kChatConversations.first.unread}'), child: const Icon(Icons.chat_bubble_outline)), onPressed: () => Scaffold.of(ctx).openEndDrawer())),
      const SizedBox(width: Space.s2),
    ], children: [
      Text('Vendredi 17 octobre 2026', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.textMuted)),
      ExHeader('Tableau de bord', subtitle: 'Activité commerciale et encaissements de SC Storage.', actions: [
        SegmentedButton<int>(showSelectedIcon: false, segments: [for (final (i, d) in kDashPeriods.indexed) ButtonSegment(value: i, label: Text(d.label))], selected: {_period}, onSelectionChanged: (s) => setState(() => _period = s.first)),
        KitButton(label: 'Exporter', icon: Icons.download, variant: KitButtonVariant.outline, onPressed: () => exDemo(context, 'Export')),
        KitButton(label: 'Nouvelle facture', icon: Icons.add, onPressed: () => exDemo(context, 'Nouvelle facture')),
      ]),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          for (final (i, t) in kDashTabs.indexed)
            Padding(padding: const EdgeInsets.only(right: Space.s2), child: ChoiceChip(avatar: Icon(t.$2, size: 18), label: Text(t.$1), selected: _tab == i, onSelected: (_) => setState(() => _tab = i))),
        ]),
      ),
      const SizedBox(height: Space.s4),
      Container(
        padding: const EdgeInsets.all(Space.s3),
        decoration: BoxDecoration(color: c.warningLight, borderRadius: BorderRadius.circular(Radii.md)),
        child: Wrap(spacing: Space.s3, runSpacing: Space.s2, crossAxisAlignment: WrapCrossAlignment.center, children: [
          Icon(Icons.warning_amber, color: c.warningText),
          Text('3 factures en retard', style: TextStyle(fontWeight: FontWeight.w700, color: c.warningText)),
          Text('7,3 M FCFA d’encours dépassent l’échéance de plus de 30 jours.', style: TextStyle(color: c.warningText)),
          TextButton(onPressed: () {}, child: const Text('Voir les relances')),
        ]),
      ),
      const SizedBox(height: Space.s4),
      ResponsiveGrid(minItemWidth: 230, children: [
        for (final (i, k) in kDashKpis.indexed)
          KpiCard(
            icon: k.$2,
            value: i == 2 ? p.kpi[i].round().toString() : exCompact(p.kpi[i]),
            unit: k.$3.isEmpty ? null : k.$3,
            label: k.$1,
            delta: '${_trend(p.trend[i])} ${p.compare}',
            up: p.trend[i] >= 0,
            goodWhenUp: k.$4,
            tone: i == 3 ? KitTone.warning : i == 2 ? KitTone.info : KitTone.primary,
          ),
      ]),
      const SizedBox(height: Space.s4),
      LayoutBuilder(builder: (context, box) {
        final chart = KitCard(title: 'Facturé et encaissé', icon: Icons.show_chart, child: KitChart(kind: ChartKind.area, labels: p.labels, series: [ChartSeries('Facturé', p.a), ChartSeries('Encaissé', p.b)], height: 220, compactValues: true));
        final side = ExGap([
          KitCard(title: 'Objectifs', icon: Icons.flag_outlined, child: ExGap(gap: Space.s3, [
            for (final g in kDashGoals)
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Expanded(child: Text(g.$1, style: const TextStyle(fontWeight: FontWeight.w600))), Text('${g.$2} %')]),
                const SizedBox(height: Space.s1),
                KitProgressBar(value: g.$2 / 100),
                const SizedBox(height: Space.s1),
                Text(g.$3, style: TextStyle(fontSize: 12, color: c.textMuted)),
              ]),
          ])),
          KitCard(title: 'Répartition des clients', icon: Icons.pie_chart_outline, child: Wrap(spacing: Space.s2, runSpacing: Space.s2, children: [
            for (final e in counts.entries) StatusBadge('${e.key.label} · ${e.value}', tone: e.key.tone, uppercase: false),
          ])),
        ]);
        if (box.maxWidth < Breakpoints.xl) return ExGap([chart, side]);
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 3, child: chart), const SizedBox(width: Space.s4), Expanded(flex: 2, child: side)]);
      }),
      const SizedBox(height: Space.s4),
      LayoutBuilder(builder: (context, box) {
        final activity = KitCard(title: 'Activité récente', icon: Icons.history, child: Column(children: [
          for (final a in kExActivity) ExTile(leading: Icon(a.icon, color: a.tone.text(c)), title: a.text, subtitle: '${a.at} · ${a.who}'),
        ]));
        final late = KitCard(title: 'Comptes à surveiller', icon: Icons.visibility_outlined, child: Column(children: [
          for (final x in watch)
            ExTile(
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ClientDetailExample(client: x))),
              leading: KitAvatar(name: x.name),
              title: x.name,
              subtitle: '${x.owner} · ${x.city} · ${x.invoices} factures',
              trailing: StatusBadge(x.status.label, tone: x.status.tone),
            ),
        ]));
        if (box.maxWidth < Breakpoints.xl) return ExGap([activity, late]);
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: activity), const SizedBox(width: Space.s4), Expanded(child: late)]);
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
  ClientStatus? _filter;

  void _open(ExClient c) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ClientDetailExample(client: c)));

  @override
  Widget build(BuildContext context) {
    final q = _q.toLowerCase();
    final rows = kExClients.where((c) => (_filter == null || c.status == _filter) && '${c.name} ${c.contact} ${c.city}'.toLowerCase().contains(q)).toList();
    return ExPage(title: 'Clients', maxWidth: 1280, children: [
      ExHeader('Clients', subtitle: '${kExClients.length} comptes', actions: [KitButton(label: 'Nouveau client', icon: Icons.add, onPressed: () => exDemo(context, 'Création'))]),
      TextField(onChanged: (v) => setState(() => _q = v), decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Rechercher un client…')),
      const SizedBox(height: Space.s3),
      Wrap(spacing: Space.s2, runSpacing: Space.s2, children: [
        ChoiceChip(label: Text('Tous · ${kExClients.length}'), selected: _filter == null, onSelected: (_) => setState(() => _filter = null)),
        for (final s in ClientStatus.values) ChoiceChip(label: Text('${s.label} · ${kExClients.where((c) => c.status == s).length}'), selected: _filter == s, onSelected: (_) => setState(() => _filter = s)),
      ]),
      const SizedBox(height: Space.s4),
      if (rows.isEmpty) const EmptyState(icon: Icons.search_off, title: 'Aucun client', subtitle: 'Ajustez vos critères de recherche.'),
      LayoutBuilder(builder: (context, box) {
        if (box.maxWidth >= Breakpoints.xl) {
          return KitCard(padding: EdgeInsets.zero, child: Column(children: [
            for (final c in rows)
              ExTile(
                onTap: () => _open(c),
                leading: KitAvatar(name: c.name),
                title: c.name,
                subtitle: '${c.contact} · ${c.email}',
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  SizedBox(width: 120, child: Text(c.owner, overflow: TextOverflow.ellipsis)),
                  SizedBox(width: 110, child: Text(c.city, overflow: TextOverflow.ellipsis)),
                  SizedBox(width: 120, child: Text(c.sector, overflow: TextOverflow.ellipsis)),
                  SizedBox(width: 60, child: Text('${c.invoices}', textAlign: TextAlign.right)),
                  SizedBox(width: 150, child: Text(exMoney(c.revenue), textAlign: TextAlign.right)),
                  const SizedBox(width: Space.s4),
                  SizedBox(width: 96, child: Align(alignment: Alignment.centerLeft, child: StatusBadge(c.status.label, tone: c.status.tone))),
                ]),
              ),
          ]));
        }
        return Column(children: [
          for (final c in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.s2),
              child: KitCard(
                onTap: () => _open(c),
                child: Row(children: [
                  KitAvatar(name: c.name),
                  const SizedBox(width: Space.s3),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(c.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text('${c.city} · ${exMoney(c.revenue)}', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: context.kc.textMuted)),
                  ])),
                  StatusBadge(c.status.label, tone: c.status.tone),
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
  /// Par défaut `c-104`, comme le showcase Angular `app-detail`.
  ClientDetailExample({super.key, ExClient? client}) : client = client ?? exClientById('c-104');
  final ExClient client;

  @override
  Widget build(BuildContext context) {
    final c = client;
    final kc = context.kc;
    final infos = [(Icons.person_outline, 'Contact', c.contact), (Icons.alternate_email, 'E-mail', c.email), (Icons.phone, 'Téléphone', c.phone), (Icons.location_on_outlined, 'Ville', c.city), (Icons.category_outlined, 'Secteur', c.sector), (Icons.badge_outlined, 'Responsable', c.owner), (Icons.event, 'Client depuis', DateFormat('d MMMM y', 'fr_FR').format(c.since))];
    return DefaultTabController(
      length: 3,
      child: ExPage(title: 'Fiche client', maxWidth: 1100, children: [
        KitCard(child: Wrap(spacing: Space.s4, runSpacing: Space.s3, crossAxisAlignment: WrapCrossAlignment.center, children: [
          KitAvatar(name: c.name, size: 56),
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(c.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            Text('${c.id} · ${c.sector} · ${c.city}', style: TextStyle(color: kc.textMuted)),
          ]),
          StatusBadge(c.status.label, tone: c.status.tone),
          Wrap(spacing: Space.s2, runSpacing: Space.s2, children: [
            KitButton(label: 'Appeler', icon: Icons.call, variant: KitButtonVariant.secondary, onPressed: () => exDemo(context, 'Appel')),
            KitButton(label: 'Modifier', icon: Icons.edit, variant: KitButtonVariant.outline, onPressed: () => exDemo(context, 'Modification')),
          ]),
        ])),
        const SizedBox(height: Space.s4),
        ResponsiveGrid(minItemWidth: 200, children: [
          KpiCard(icon: Icons.payments_outlined, value: exCompact(c.revenue.toDouble()), unit: 'FCFA', label: 'Chiffre d’affaires'),
          KpiCard(icon: Icons.receipt_long, value: '${c.invoices}', label: 'Factures', tone: KitTone.info),
          KpiCard(icon: Icons.schedule, value: exCompact(kExInvoices.where((i) => i.status != 'payée').fold(0, (s, i) => s + i.amount).toDouble()), unit: 'FCFA', label: 'Encours', tone: KitTone.warning),
        ]),
        const SizedBox(height: Space.s4),
        const TabBar(isScrollable: true, tabAlignment: TabAlignment.start, tabs: [Tab(text: 'Coordonnées'), Tab(text: 'Factures'), Tab(text: 'Activité')]),
        const SizedBox(height: Space.s4),
        SizedBox(
          height: 420,
          child: TabBarView(children: [
            SingleChildScrollView(child: ResponsiveGrid(minItemWidth: 240, spacing: Space.s3, children: [
              for (final i in infos) KitCard(child: Row(children: [Icon(i.$1, color: kc.primary), const SizedBox(width: Space.s3), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(i.$2, style: TextStyle(fontSize: 12, color: kc.textMuted)), Text(i.$3, overflow: TextOverflow.ellipsis)]))])),
            ])),
            ListView(children: [
              for (final i in kExInvoices)
                ExTile(leading: const Icon(Icons.receipt_long), title: i.ref, subtitle: '${exDate(i.date)} · ${exMoney(i.amount)}', trailing: StatusBadge(i.status, tone: i.tone, uppercase: false)),
            ]),
            ListView(children: [
              for (final a in kExActivity) ExTile(leading: Icon(a.icon, color: a.tone.text(kc)), title: a.text, subtitle: '${a.at} · ${a.who}'),
            ]),
          ]),
        ),
      ]),
    );
  }
}

// ─── Messagerie (inbox) ─────────────────────────────────────────────────────
class InboxExample extends StatefulWidget {
  const InboxExample({super.key});
  @override
  State<InboxExample> createState() => _InboxState();
}

class _InboxState extends State<InboxExample> {
  int _sel = 0;

  Widget _read(int i) {
    final m = kExMessages[i];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Space.s6),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: Space.s2, runSpacing: Space.s2, crossAxisAlignment: WrapCrossAlignment.center, children: [
          Text(m.subject, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          if (m.label != null) StatusBadge(m.label!.$1, tone: m.label!.$2, uppercase: false),
        ]),
        const SizedBox(height: Space.s4),
        Row(children: [
          KitAvatar(name: m.from),
          const SizedBox(width: Space.s3),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(m.from, style: const TextStyle(fontWeight: FontWeight.w600)), Text(m.email, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: context.kc.textMuted))])),
          Text(m.at),
        ]),
        const SizedBox(height: Space.s6),
        for (final p in m.body) Padding(padding: const EdgeInsets.only(bottom: Space.s3), child: Text(p, style: const TextStyle(height: 1.5))),
        for (final a in m.attachments)
          Padding(padding: const EdgeInsets.only(bottom: Space.s3), child: InputChip(avatar: const Icon(Icons.picture_as_pdf, size: 18), label: Text(a), onPressed: () => exDemo(context, a))),
        const SizedBox(height: Space.s3),
        Wrap(spacing: Space.s2, runSpacing: Space.s2, children: [
          KitButton(label: 'Répondre', icon: Icons.reply, onPressed: () => exDemo(context, 'Réponse')),
          KitButton(label: 'Transférer', icon: Icons.forward, variant: KitButtonVariant.outline, onPressed: () => exDemo(context, 'Transfert')),
        ]),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = ListView(padding: const EdgeInsets.all(Space.s2), children: [
      for (final (i, m) in kExMessages.indexed)
        ExTile(
          selected: exWide(context) && _sel == i,
          onTap: () => exWide(context) ? setState(() => _sel = i) : exPush(context, m.from, _read(i)),
          leading: KitAvatar(name: m.from),
          title: m.subject,
          subtitle: '${m.from} · ${m.preview}',
          trailing: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(m.at, style: TextStyle(fontSize: 12, fontWeight: m.unread ? FontWeight.w700 : FontWeight.w400)),
            if (m.starred) Icon(Icons.star, size: 16, color: context.kc.warning) else if (m.unread) const CountDot(1),
          ]),
        ),
    ]);
    return Scaffold(
      appBar: AppBar(title: Text('Boîte de réception · ${kExMessages.where((m) => m.unread).length} non lus')),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => exDemo(context, 'Nouveau message'), icon: const Icon(Icons.edit), label: const Text('Écrire')),
      body: ExMasterDetail(list: list, detail: _read(_sel), listWidth: 380),
    );
  }
}

// ─── Catalogue ──────────────────────────────────────────────────────────────
Color _hue(BuildContext context, int hue, {bool fg = false}) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  return HSLColor.fromAHSL(1, hue.toDouble(), fg ? .6 : .5, fg ? (dark ? .75 : .35) : (dark ? .22 : .9)).toColor();
}

class CatalogExample extends StatefulWidget {
  const CatalogExample({super.key});
  @override
  State<CatalogExample> createState() => _CatalogState();
}

class _CatalogState extends State<CatalogExample> {
  String _cat = 'Tout';
  final _cart = <String>{};

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final items = kExProducts.where((p) => _cat == 'Tout' || p.category == _cat).toList();
    return ExPage(title: 'Catalogue', maxWidth: 1280, actions: [
      Badge(isLabelVisible: _cart.isNotEmpty, label: Text('${_cart.length}'), child: IconButton(tooltip: 'Panier', icon: const Icon(Icons.shopping_cart_outlined), onPressed: () => exDemo(context, 'Panier'))),
      const SizedBox(width: Space.s2),
    ], children: [
      ExHeader('Catalogue', subtitle: '${kExProducts.length} produits'),
      Wrap(spacing: Space.s2, runSpacing: Space.s2, children: [for (final cat in ['Tout', ...kExCategories]) ChoiceChip(label: Text(cat), selected: _cat == cat, onSelected: (_) => setState(() => _cat = cat))]),
      const SizedBox(height: Space.s4),
      ResponsiveGrid(minItemWidth: 220, spacing: Space.s3, children: [
        for (final p in items)
          KitCard(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Stack(children: [
              Container(
                height: 110,
                decoration: BoxDecoration(color: _hue(context, p.hue), borderRadius: BorderRadius.circular(Radii.md)),
                child: Center(child: Icon(p.icon, size: 48, color: _hue(context, p.hue, fg: true))),
              ),
              if (p.badge != null) Positioned(top: Space.s2, left: Space.s2, child: StatusBadge(p.badge!, tone: p.badge == 'Nouveau' ? KitTone.info : KitTone.error, uppercase: false)),
            ]),
            const SizedBox(height: Space.s3),
            Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
            Row(children: [
              Icon(Icons.star, size: 14, color: c.warning),
              const SizedBox(width: 2),
              Text(p.rating.toStringAsFixed(1).replaceAll('.', ','), style: const TextStyle(fontSize: 12)),
              const SizedBox(width: Space.s2),
              Expanded(child: Text(p.stock == 0 ? 'Rupture' : '${p.stock} en stock', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: p.stock == 0 ? c.errorText : c.textMuted))),
            ]),
            const SizedBox(height: Space.s2),
            Row(children: [
              Expanded(child: Text(exMoney(p.price), style: const TextStyle(fontWeight: FontWeight.w700))),
              IconButton.filledTonal(tooltip: _cart.contains(p.id) ? 'Retirer du panier' : 'Ajouter au panier', icon: Icon(_cart.contains(p.id) ? Icons.check : Icons.add_shopping_cart), onPressed: p.stock == 0 ? null : () => setState(() => _cart.contains(p.id) ? _cart.remove(p.id) : _cart.add(p.id))),
            ]),
          ])),
      ]),
    ]);
  }
}

// ─── Tableau kanban ─────────────────────────────────────────────────────────
class BoardExample extends StatelessWidget {
  const BoardExample({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return Scaffold(
      appBar: AppBar(title: const Text('Projet Sotra')),
      body: LayoutBuilder(builder: (context, box) {
        final w = box.maxWidth < Breakpoints.tablet ? box.maxWidth * .85 : 300.0;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(Space.s4),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (final col in kBoardColumns)
              Container(
                width: w,
                margin: const EdgeInsets.only(right: Space.s3),
                padding: const EdgeInsets.all(Space.s3),
                decoration: BoxDecoration(color: c.hover, borderRadius: BorderRadius.circular(Radii.lg)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Row(children: [Expanded(child: Text(col.$2, style: const TextStyle(fontWeight: FontWeight.w700))), StatusBadge('${kBoardTasks.where((t) => t.status == col.$1).length} / 4', tone: col.$3, uppercase: false)]),
                  const SizedBox(height: Space.s3),
                  for (final t in kBoardTasks.where((t) => t.status == col.$1))
                    Padding(
                      padding: const EdgeInsets.only(bottom: Space.s2),
                      child: KitCard(onTap: () => exDemo(context, t.title), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Text(t.ref, style: TextStyle(fontFamily: Fonts.mono, fontSize: 11, color: c.textMuted)),
                          const Spacer(),
                          if (t.badge != null) StatusBadge(t.badge!.$1, tone: t.badge!.$2, uppercase: false),
                        ]),
                        const SizedBox(height: Space.s1),
                        Text(t.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                        if (t.progress != null && t.progress! < 100) ...[const SizedBox(height: Space.s2), KitProgressBar(value: t.progress! / 100)],
                        const SizedBox(height: Space.s2),
                        Row(children: [KitAvatar(name: t.assignee, size: 24), const SizedBox(width: Space.s2), Expanded(child: Text(t.assignee, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13))), for (final g in t.tags) StatusBadge(g, uppercase: false)]),
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

// ─── Lanceur de modules ─────────────────────────────────────────────────────
class ModulesExample extends StatelessWidget {
  const ModulesExample({super.key});

  @override
  Widget build(BuildContext context) => ExPage(title: 'Modules', maxWidth: 1200, children: [
        ExHeader('Bonjour, ${kCurrentUser.prenoms}', subtitle: '${kOrganisation.nom} · ${kExModules.length} modules'),
        ResponsiveGrid(minItemWidth: 240, spacing: Space.s3, children: [
          for (final m in kExModules)
            KitCard(onTap: () => exDemo(context, m.label), child: Row(children: [
              Container(padding: const EdgeInsets.all(Space.s3), decoration: BoxDecoration(color: m.color.withValues(alpha: .15), borderRadius: BorderRadius.circular(Radii.md)), child: Icon(m.icon, color: m.color)),
              const SizedBox(width: Space.s3),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(m.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(m.description, style: TextStyle(fontSize: 12, color: context.kc.textMuted)),
                if (m.count != null) Text(m.count!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.kc.textSecondary)),
              ])),
              if (m.badge != null) CountDot(m.badge!),
            ])),
        ]),
      ]);
}

// ─── Blog & article ─────────────────────────────────────────────────────────
Widget _cover(BuildContext context, Article a, {double ratio = 16 / 9}) => AspectRatio(
      aspectRatio: ratio,
      child: Container(
        decoration: BoxDecoration(color: _hue(context, a.hue), borderRadius: BorderRadius.circular(Radii.md)),
        child: Icon(a.icon, size: 48, color: _hue(context, a.hue, fg: true)),
      ),
    );

class BlogExample extends StatefulWidget {
  const BlogExample({super.key});
  @override
  State<BlogExample> createState() => _BlogState();
}

class _BlogState extends State<BlogExample> {
  String _cat = 'Tous';

  void _open(Article a) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ArticleExample(index: kArticles.indexOf(a))));

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final featured = kArticles.firstWhere((a) => a.featured);
    final list = kArticles.where((a) => !a.featured && (_cat == 'Tous' || a.category == _cat)).toList();
    Widget meta(Article a) => Text('${a.author.name} · ${exDate(a.date)} · ${a.minutes} min de lecture', style: TextStyle(fontSize: 12, color: c.textMuted));
    return ExPage(title: 'Blog', maxWidth: 1200, children: [
      const ExHeader('Le blog', subtitle: 'Design, produit et rédaction : ce que nous apprenons en construisant le kit.'),
      KitCard(
        onTap: () => _open(featured),
        child: LayoutBuilder(builder: (context, box) {
          final text = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            StatusBadge('À la une · ${featured.category}', tone: KitTone.primary, uppercase: false),
            const SizedBox(height: Space.s2),
            Text(featured.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: Space.s2),
            Text(featured.dek, style: TextStyle(color: c.textSecondary)),
            const SizedBox(height: Space.s3),
            meta(featured),
          ]);
          if (box.maxWidth < Breakpoints.tablet) return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [_cover(context, featured), const SizedBox(height: Space.s3), text]);
          return Row(children: [Expanded(child: _cover(context, featured)), const SizedBox(width: Space.s6), Expanded(child: text)]);
        }),
      ),
      const SizedBox(height: Space.s4),
      Wrap(spacing: Space.s2, runSpacing: Space.s2, children: [for (final cat in kBlogCategories) ChoiceChip(label: Text(cat), selected: _cat == cat, onSelected: (_) => setState(() => _cat = cat))]),
      const SizedBox(height: Space.s4),
      ResponsiveGrid(minItemWidth: 280, maxColumns: 3, children: [
        for (final a in list)
          KitCard(
            onTap: () => _open(a),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _cover(context, a),
              const SizedBox(height: Space.s3),
              StatusBadge(a.category, uppercase: false, tone: KitTone.primary),
              const SizedBox(height: Space.s2),
              Text(a.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: Space.s1),
              Text(a.dek, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: c.textSecondary)),
              const SizedBox(height: Space.s2),
              meta(a),
            ]),
          ),
      ]),
    ]);
  }
}

KitTone _blockTone(String? s) => switch (s) { 'info' => KitTone.info, 'success' => KitTone.success, 'warning' => KitTone.warning, 'error' => KitTone.error, _ => KitTone.neutral };

/// Rendu d'un bloc d'article (`ArticleBlock`), partagé par l'article et la documentation.
Widget exBlock(BuildContext context, ArticleBlock b) {
  final c = context.kc;
  final t = Theme.of(context).textTheme;
  final Widget w = switch (b.type) {
    'lead' => Text.rich(exInline(context, b.text!, style: t.titleMedium?.copyWith(color: c.textSecondary, height: 1.5))),
    'p' => Text.rich(exInline(context, b.text!, style: const TextStyle(height: 1.6))),
    'h2' => Text(b.text!, style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
    'h3' => Text(b.text!, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
    'list' => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (final i in b.items!) Padding(padding: const EdgeInsets.only(bottom: Space.s1), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('•  '), Expanded(child: Text.rich(exInline(context, i)))])),
      ]),
    'table' => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
          headingRowHeight: 40, dataRowMinHeight: 36, dataRowMaxHeight: 44,
          columns: [for (final h in b.head!) DataColumn(label: Text(h, style: const TextStyle(fontWeight: FontWeight.w700)))],
          rows: [for (final r in b.rows!) DataRow(cells: [for (final v in r) DataCell(Text.rich(exInline(context, v)))])],
        )),
        if (b.caption != null) Text(b.caption!, style: TextStyle(fontSize: 12, color: c.textMuted)),
      ]),
    'callout' => Container(
        padding: const EdgeInsets.all(Space.s4),
        decoration: BoxDecoration(color: _blockTone(b.tone).light(c), borderRadius: BorderRadius.circular(Radii.md)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (b.title != null) Text(b.title!, style: TextStyle(fontWeight: FontWeight.w700, color: _blockTone(b.tone).text(c))),
          Text.rich(exInline(context, b.text!, style: TextStyle(color: c.textPrimary, height: 1.5))),
        ]),
      ),
    'pullquote' => Padding(padding: const EdgeInsets.symmetric(vertical: Space.s4), child: Text('« ${b.text} »', textAlign: TextAlign.center, style: t.titleLarge?.copyWith(fontStyle: FontStyle.italic, color: c.primary))),
    'quote' => Container(
        padding: const EdgeInsets.all(Space.s4),
        decoration: BoxDecoration(border: Border(left: BorderSide(color: c.primary, width: 4)), color: c.hover),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(b.text!, style: const TextStyle(fontStyle: FontStyle.italic, height: 1.5)),
          if (b.cite != null) Padding(padding: const EdgeInsets.only(top: Space.s2), child: Text('— ${b.cite}', style: TextStyle(fontSize: 13, color: c.textMuted))),
        ]),
      ),
    'code' => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (b.filename != null) Text(b.filename!, style: TextStyle(fontFamily: Fonts.mono, fontSize: 12, color: c.textMuted)),
        const SizedBox(height: Space.s1),
        Container(
          padding: const EdgeInsets.all(Space.s4),
          decoration: BoxDecoration(color: c.tableHeader, border: Border.all(color: c.border), borderRadius: BorderRadius.circular(Radii.md)),
          child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(b.code!, style: TextStyle(fontFamily: Fonts.mono, fontSize: 13, color: c.textPrimary))),
        ),
      ]),
    'figure' => Column(children: [
        Container(height: 160, decoration: BoxDecoration(color: c.primaryLight, borderRadius: BorderRadius.circular(Radii.md)), child: Center(child: Icon(b.icon ?? Icons.image, size: 56, color: c.primary))),
        if (b.caption != null) Padding(padding: const EdgeInsets.only(top: Space.s2), child: Text(b.caption!, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: c.textMuted))),
      ]),
    'divider' => const Divider(),
    _ => const SizedBox.shrink(),
  };
  return Padding(padding: const EdgeInsets.only(bottom: Space.s4), child: w);
}

Widget _comment(BuildContext context, CommentItem k, {bool reply = false}) {
  final c = context.kc;
  return Padding(
    padding: EdgeInsets.only(left: reply ? Space.s10 : 0, bottom: Space.s3),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      KitAvatar(name: k.author.name, size: reply ? 28 : 36),
      const SizedBox(width: Space.s3),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: Space.s2, runSpacing: Space.s1, crossAxisAlignment: WrapCrossAlignment.center, children: [
          Text(k.author.name, style: const TextStyle(fontWeight: FontWeight.w600)),
          if (k.byAuthor) const StatusBadge('Auteur', tone: KitTone.primary, uppercase: false),
          if (k.pinned) const StatusBadge('Épinglé', icon: Icons.push_pin, uppercase: false),
          Text(k.at, style: TextStyle(fontSize: 12, color: c.textMuted)),
        ]),
        const SizedBox(height: Space.s1),
        Text.rich(exInline(context, k.text, style: const TextStyle(height: 1.5))),
        const SizedBox(height: Space.s1),
        Wrap(spacing: Space.s3, crossAxisAlignment: WrapCrossAlignment.center, children: [
          Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.favorite_border, size: 16, color: c.textMuted), const SizedBox(width: 2), Text('${k.likes}', style: TextStyle(fontSize: 12, color: c.textMuted))]),
          for (final r in k.reactions) Text('${r.$1} ${r.$2}', style: const TextStyle(fontSize: 12)),
        ]),
      ])),
    ]),
  );
}

class ArticleExample extends StatelessWidget {
  const ArticleExample({super.key, this.index = 0});
  final int index;
  @override
  Widget build(BuildContext context) {
    final a = kArticles[index];
    final c = context.kc;
    return ExPage(title: 'Article', children: [
      _cover(context, a, ratio: 21 / 9),
      const SizedBox(height: Space.s4),
      Wrap(spacing: Space.s2, runSpacing: Space.s2, children: [StatusBadge(a.category, uppercase: false, tone: KitTone.primary), for (final g in a.tags) StatusBadge(g, uppercase: false)]),
      const SizedBox(height: Space.s3),
      Text(a.title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: Space.s2),
      Text(a.dek, style: TextStyle(color: c.textSecondary, fontSize: 16)),
      const SizedBox(height: Space.s4),
      Row(children: [KitAvatar(name: a.author.name), const SizedBox(width: Space.s3), Expanded(child: Text('${a.author.name} · ${a.author.role}\n${exDate(a.date)} · ${a.minutes} min de lecture', style: TextStyle(color: c.textMuted)))]),
      const SizedBox(height: Space.s6),
      for (final b in a.blocks) exBlock(context, b),
      if (a.author.bio != null) KitCard(child: Row(children: [KitAvatar(name: a.author.name, size: 48), const SizedBox(width: Space.s3), Expanded(child: Text(a.author.bio!))])),
      if (index == 0) ...[
        const SizedBox(height: Space.s6),
        Text('${kComments.fold(0, (n, k) => n + 1 + k.replies.length)} commentaires', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: Space.s4),
        for (final k in kComments) ...[_comment(context, k), for (final r in k.replies) _comment(context, r, reply: true)],
      ],
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
  String _slug = 'commentaires';

  Widget _nav({VoidCallback? after}) => ListView(padding: const EdgeInsets.all(Space.s2), children: [
        for (final g in kDocsNav) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.s3, Space.s4, Space.s3, Space.s1),
            child: Row(children: [Icon(g.icon, size: 16, color: context.kc.textMuted), const SizedBox(width: Space.s2), Text(g.label.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1, color: context.kc.textMuted))]),
          ),
          for (final n in g.children)
            ExTile(title: n.label, selected: _slug == n.slug, trailing: n.badge == null ? null : StatusBadge(n.badge!, tone: KitTone.primary, uppercase: false), onTap: () { setState(() => _slug = n.slug!); after?.call(); }),
        ],
      ]);

  @override
  Widget build(BuildContext context) {
    final group = kDocsNav.firstWhere((g) => g.children.any((n) => n.slug == _slug));
    final node = group.children.firstWhere((n) => n.slug == _slug);
    final content = SingleChildScrollView(
      padding: const EdgeInsets.all(Space.s6),
      child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 760), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${group.label} › ${node.label}', style: TextStyle(color: context.kc.textMuted)),
        const SizedBox(height: Space.s2),
        Text(node.label, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: Space.s4),
        // Comme côté Angular, toutes les pages affichent le même contenu d'exemple (`DOC_PAGE`).
        for (final b in kDocPage) exBlock(context, b),
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

// ─── Fichiers ───────────────────────────────────────────────────────────────
Widget _fmIcon(FmItem f, {double size = 28}) {
  final k = kFmKinds[f.kind]!;
  return Icon(k.$2, size: size, color: f.color ?? k.$3);
}

Widget _fmFlags(BuildContext context, FmItem f) => Row(mainAxisSize: MainAxisSize.min, children: [
      if (f.starred) Icon(Icons.star, size: 14, color: context.kc.warning),
      if (f.shared) Icon(Icons.people_outline, size: 14, color: context.kc.textMuted),
    ]);

class FilesExample extends StatefulWidget {
  const FilesExample({super.key, this.openPicker = false});

  /// Ouvre le sélecteur de fichiers en modale au démarrage (`?picker=1`).
  final bool openPicker;
  @override
  State<FilesExample> createState() => _FilesState();
}

class _FilesState extends State<FilesExample> {
  bool _grid = true;
  String? _folder;

  @override
  void initState() {
    super.initState();
    if (widget.openPicker) WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) showFilePicker(context); });
  }

  List<FmItem> get _crumbs {
    final out = <FmItem>[];
    var id = _folder;
    while (id != null) {
      final f = kFmItems.firstWhere((i) => i.id == id);
      out.insert(0, f);
      id = f.parent;
    }
    return out;
  }

  void _tap(FmItem f) => f.kind == 'folder' ? setState(() => _folder = f.id) : exDemo(context, f.name);

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final items = kFmItems.where((i) => i.parent == _folder).toList()..sort((a, b) => (a.kind == 'folder' ? 0 : 1).compareTo(b.kind == 'folder' ? 0 : 1));
    return ExPage(title: 'Fichiers', maxWidth: 1280, children: [
      ExHeader('Mes fichiers', subtitle: '${kFmItems.where((i) => i.kind != 'folder').length} fichiers', actions: [
        SegmentedButton<bool>(showSelectedIcon: false, segments: const [ButtonSegment(value: true, icon: Icon(Icons.grid_view), label: Text('Grille')), ButtonSegment(value: false, icon: Icon(Icons.list), label: Text('Liste'))], selected: {_grid}, onSelectionChanged: (s) => setState(() => _grid = s.first)),
        KitButton(label: 'Importer', icon: Icons.upload, onPressed: () => showFilePicker(context)),
      ]),
      Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
        TextButton(onPressed: () => setState(() => _folder = null), child: const Text('Mes fichiers')),
        for (final f in _crumbs) ...[Icon(Icons.chevron_right, size: 18, color: c.textMuted), TextButton(onPressed: () => setState(() => _folder = f.id), child: Text(f.name))],
      ]),
      const SizedBox(height: Space.s3),
      if (items.isEmpty) const EmptyState(icon: Icons.folder_open, title: 'Dossier vide', subtitle: 'Déposez des fichiers ici.'),
      if (_grid)
        ResponsiveGrid(minItemWidth: 160, spacing: Space.s3, children: [
          for (final f in items)
            KitCard(onTap: () => _tap(f), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [_fmIcon(f, size: 36), const Spacer(), _fmFlags(context, f)]),
              const SizedBox(height: Space.s3),
              Text(f.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(f.kind == 'folder' ? '${kFmItems.where((i) => i.parent == f.id).length} éléments' : '${fmSize(f.size)} · ${fmModified(f.days)}', style: TextStyle(fontSize: 12, color: c.textMuted)),
            ])),
        ])
      else
        KitCard(padding: EdgeInsets.zero, child: Column(children: [
          for (final f in items)
            ExTile(onTap: () => _tap(f), leading: _fmIcon(f), title: f.name, subtitle: '${kFmKinds[f.kind]!.$1} · ${f.owner} · ${fmModified(f.days)}', trailing: Row(mainAxisSize: MainAxisSize.min, children: [_fmFlags(context, f), const SizedBox(width: Space.s2), Text(f.kind == 'folder' ? '' : fmSize(f.size))])),
        ])),
    ]);
  }
}

class FilesColumnsExample extends StatefulWidget {
  const FilesColumnsExample({super.key});
  @override
  State<FilesColumnsExample> createState() => _FilesColumnsState();
}

class _FilesColumnsState extends State<FilesColumnsExample> {
  final _path = <String>[];
  FmItem? _file;

  Widget _column(String? parent, int depth) {
    final items = kFmItems.where((i) => i.parent == parent).toList();
    return Container(
      width: 240,
      decoration: BoxDecoration(border: Border(right: BorderSide(color: context.kc.border))),
      child: ListView(padding: const EdgeInsets.all(Space.s1), children: [
        for (final f in items)
          ExTile(
            selected: (depth < _path.length && _path[depth] == f.id) || _file?.id == f.id,
            leading: _fmIcon(f, size: 20),
            title: f.name,
            trailing: f.kind == 'folder' ? const Icon(Icons.chevron_right, size: 18) : null,
            onTap: () => setState(() {
              _path.removeRange(depth, _path.length);
              if (f.kind == 'folder') { _path.add(f.id); _file = null; } else { _file = f; }
            }),
          ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final f = _file;
    return Scaffold(
      appBar: AppBar(title: const Text('Fichiers · colonnes')),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height,
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _column(null, 0),
            for (final (i, id) in _path.indexed) _column(id, i + 1),
            if (f != null)
              SizedBox(width: 260, child: Padding(padding: const EdgeInsets.all(Space.s4), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _fmIcon(f, size: 56),
                const SizedBox(height: Space.s3),
                Text(f.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: Space.s2),
                Text('${kFmKinds[f.kind]!.$1} · ${fmSize(f.size)}\n${f.owner}\n${fmModified(f.days)}', style: TextStyle(color: context.kc.textMuted, height: 1.5)),
              ]))),
          ]),
        ),
      ),
    );
  }
}

// ─── Monitoring ─────────────────────────────────────────────────────────────
class MonitoringExample extends StatelessWidget {
  const MonitoringExample({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    KitTone sev(String s) => switch (s) { 'critique' => KitTone.error, 'majeur' => KitTone.warning, _ => KitTone.info };
    (String, KitTone) job(String s) => switch (s) { 'ok' => ('Réussi', KitTone.success), 'running' => ('En cours', KitTone.info), _ => ('Échec', KitTone.error) };
    final degraded = kMonServices.where((s) => s.$5 != 'up').length;
    return ExPage(title: 'Monitoring', maxWidth: 1280, children: [
      ExHeader('État des services', subtitle: degraded == 0 ? 'Tous les systèmes sont opérationnels' : '$degraded services à surveiller'),
      ResponsiveGrid(minItemWidth: 220, children: [
        for (final k in kMonKpis) KpiCard(icon: k.$4, value: k.$2, unit: k.$3.isEmpty ? null : k.$3, label: '${k.$1} · ${k.$5}'),
      ]),
      const SizedBox(height: Space.s4),
      KitCard(padding: EdgeInsets.zero, child: Column(children: [
        for (final s in kMonServices)
          ExTile(
            leading: Icon(s.$4, color: monHealth(s.$5).$2.text(c)),
            title: s.$2,
            subtitle: '${s.$3} · ${s.$6.toStringAsFixed(2).replaceAll('.', ',')} % · ${s.$7 == 0 ? '—' : '${s.$7} ms'}',
            trailing: StatusBadge(monHealth(s.$5).$1, tone: monHealth(s.$5).$2, uppercase: false),
          ),
      ])),
      const SizedBox(height: Space.s4),
      ExHeading('Incidents'),
      for (final i in kMonIncidents)
        Padding(padding: const EdgeInsets.only(bottom: Space.s2), child: KitCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(spacing: Space.s2, runSpacing: Space.s1, crossAxisAlignment: WrapCrossAlignment.center, children: [
            Text(i.$1, style: TextStyle(fontFamily: Fonts.mono, fontSize: 12, color: c.textMuted)),
            StatusBadge(i.$3, tone: sev(i.$3), uppercase: false),
            StatusBadge(i.$4, tone: i.$4 == 'résolu' ? KitTone.success : KitTone.neutral, uppercase: false),
          ]),
          const SizedBox(height: Space.s1),
          Text(i.$2, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text('${i.$6} · ${i.$7} · ${i.$5}', style: TextStyle(fontSize: 12, color: c.textMuted)),
        ]))),
      const SizedBox(height: Space.s4),
      ExHeading('Tâches planifiées'),
      KitCard(padding: EdgeInsets.zero, child: Column(children: [
        for (final j in kMonJobs) ExTile(leading: const Icon(Icons.schedule), title: j.$1, subtitle: '${j.$2} · ${j.$3} · ${j.$4}', trailing: StatusBadge(job(j.$5).$1, tone: job(j.$5).$2, uppercase: false)),
      ])),
    ]);
  }
}

// ─── Messagerie instantanée ─────────────────────────────────────────────────
class ChatExample extends StatefulWidget {
  const ChatExample({super.key});
  @override
  State<ChatExample> createState() => _ChatState();
}

class _ChatState extends State<ChatExample> {
  int _conv = 0;
  final _ctrl = TextEditingController();
  final _extra = <String, List<(String, String)>>{};

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _send(ChatConv conv, StateSetter set) {
    if (_ctrl.text.trim().isEmpty) return;
    set(() { (_extra[conv.id] ??= []).add(('me', _ctrl.text.trim())); _ctrl.clear(); });
  }

  Widget _bubble(BuildContext context, ChatConv conv, (String, String) m) {
    final c = context.kc;
    if (m.$1 == 'system') return Padding(padding: const EdgeInsets.symmetric(vertical: Space.s2), child: Center(child: Text(m.$2, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: c.textMuted))));
    final mine = m.$1 == 'me';
    final p = chatPerson(m.$1);
    final fg = mine ? c.onPrimary : c.textPrimary;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Container(
          margin: const EdgeInsets.only(bottom: Space.s2),
          padding: const EdgeInsets.symmetric(horizontal: Space.s3, vertical: Space.s2),
          decoration: BoxDecoration(color: mine ? c.primary : c.hover, borderRadius: BorderRadius.circular(Radii.lg)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            if (!mine && conv.kind != 'direct') Text(p.name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.textSecondary)),
            if (m.$2.isEmpty)
              Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.play_arrow, color: fg), Icon(Icons.graphic_eq, color: fg), const SizedBox(width: Space.s1), Text('Note vocale', style: TextStyle(color: fg))])
            else
              Text(m.$2, style: TextStyle(color: fg)),
          ]),
        ),
      ),
    );
  }

  Widget _thread(ChatConv conv) => StatefulBuilder(builder: (context, set) {
        final msgs = [...conv.messages, ...?_extra[conv.id]];
        return Column(children: [
          if (conv.description != null) Padding(padding: const EdgeInsets.all(Space.s3), child: Text(conv.description!, style: TextStyle(fontSize: 12, color: context.kc.textMuted))),
          Expanded(child: ListView(padding: const EdgeInsets.all(Space.s4), children: [for (final m in msgs) _bubble(context, conv, m)])),
          SafeArea(top: false, child: Padding(
            padding: const EdgeInsets.all(Space.s2),
            child: Row(children: [
              IconButton(tooltip: 'Joindre un fichier', icon: const Icon(Icons.attach_file), onPressed: () => showFilePicker(context)),
              Expanded(child: TextField(controller: _ctrl, onSubmitted: (_) => _send(conv, set), decoration: const InputDecoration(hintText: 'Écrire un message…'))),
              const SizedBox(width: Space.s2),
              IconButton.filled(tooltip: 'Envoyer', icon: const Icon(Icons.send), onPressed: () => _send(conv, set)),
            ]),
          )),
        ]);
      });

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final convs = [...kChatConversations.where((x) => x.pinned), ...kChatConversations.where((x) => !x.pinned)];
    final list = ListView(padding: const EdgeInsets.all(Space.s2), children: [
      for (final (i, conv) in convs.indexed)
        ExTile(
          selected: exWide(context) && _conv == i,
          leading: conv.kind == 'direct' ? KitAvatar(name: conv.title, online: chatPerson(conv.members[1]).online) : CircleAvatar(backgroundColor: c.primaryLight, child: Icon(conv.kind == 'channel' ? Icons.tag : Icons.groups, color: c.primary)),
          title: conv.title,
          subtitle: () { final m = conv.messages.last; return m.$2.isEmpty ? 'Note vocale' : m.$2; }(),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            if (conv.pinned) Icon(Icons.push_pin, size: 14, color: c.textMuted),
            if (conv.muted) Icon(Icons.notifications_off, size: 14, color: c.textMuted),
            if (conv.unread > 0) CountDot(conv.unread),
          ]),
          onTap: () => exWide(context) ? setState(() => _conv = i) : exPush(context, conv.title, _thread(conv)),
        ),
    ]);
    return Scaffold(appBar: AppBar(title: Text(exWide(context) ? 'Messages · ${convs[_conv].title}' : 'Messages')), body: ExMasterDetail(list: list, detail: _thread(convs[_conv])));
  }
}

// ─── Fil d'actualité ────────────────────────────────────────────────────────
class FeedExample extends StatefulWidget {
  const FeedExample({super.key});
  @override
  State<FeedExample> createState() => _FeedState();
}

class _FeedState extends State<FeedExample> {
  final _liked = <String>{};

  Widget _media(BuildContext context, FeedPost p) {
    final c = context.kc;
    if (p.poll != null) {
      final total = p.poll!.$2.fold(0, (s, o) => s + o.$2);
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(p.poll!.$1, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: Space.s2),
        for (final o in p.poll!.$2) Padding(padding: const EdgeInsets.only(bottom: Space.s2), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [Expanded(child: Text(o.$1)), Text('${(o.$2 * 100 / total).round()} %')]),
          const SizedBox(height: 2),
          KitProgressBar(value: o.$2 / total),
        ])),
        Text('$total votes', style: TextStyle(fontSize: 12, color: c.textMuted)),
      ]);
    }
    final kind = p.media.split(' · ').first;
    final icon = switch (kind) { 'photos' => Icons.photo_library, 'video' => Icons.movie, 'voice' => Icons.mic, 'link' => Icons.link, 'youtube' => Icons.smart_display, 'file' => Icons.picture_as_pdf, _ => Icons.attachment };
    final label = p.media.contains(' · ') ? p.media.substring(p.media.indexOf(' · ') + 3) : 'Photos';
    return Container(
      padding: const EdgeInsets.all(Space.s3),
      decoration: BoxDecoration(color: c.hover, borderRadius: BorderRadius.circular(Radii.md)),
      child: Row(children: [Icon(icon, color: c.primary), const SizedBox(width: Space.s3), Expanded(child: Text(label, overflow: TextOverflow.ellipsis))]),
    );
  }

  @override
  Widget build(BuildContext context) => ExPage(title: 'Fil d’actualité', maxWidth: 640, children: [
        KitCard(child: Row(children: [
          KitAvatar(name: kCurrentUser.fullname),
          const SizedBox(width: Space.s3),
          Expanded(child: TextField(decoration: InputDecoration(hintText: 'Quoi de neuf, ${kCurrentUser.prenoms} ?'))),
          const SizedBox(width: Space.s2),
          IconButton.filled(tooltip: 'Publier', icon: const Icon(Icons.send), onPressed: () => exDemo(context, 'Publication')),
        ])),
        const SizedBox(height: Space.s4),
        for (final p in kFeedPosts)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.s3),
            child: KitCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [KitAvatar(name: p.author.name), const SizedBox(width: Space.s3), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.author.name, style: const TextStyle(fontWeight: FontWeight.w600)), Text('${p.author.role} · ${p.at}', style: TextStyle(fontSize: 12, color: context.kc.textMuted))]))]),
              const SizedBox(height: Space.s3),
              Text.rich(exInline(context, p.text, style: const TextStyle(height: 1.5))),
              const SizedBox(height: Space.s3),
              _media(context, p),
              const SizedBox(height: Space.s2),
              Wrap(spacing: Space.s2, children: [
                TextButton.icon(onPressed: () => setState(() => _liked.contains(p.id) ? _liked.remove(p.id) : _liked.add(p.id)), icon: Icon(_liked.contains(p.id) ? Icons.favorite : Icons.favorite_border), label: Text('${p.likes + (_liked.contains(p.id) ? 1 : 0)}')),
                TextButton.icon(onPressed: () {}, icon: const Icon(Icons.chat_bubble_outline), label: Text('${p.comments.length}')),
                TextButton.icon(onPressed: () => exDemo(context, 'Partage'), icon: const Icon(Icons.share_outlined), label: const Text('Partager')),
              ]),
              for (final k in p.comments) _comment(context, k),
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
  bool _reveal = false;
  final _security = [for (final s in kSettingsSecurity) s.$3];
  final _notifs = [for (final n in kSettingsNotifs) [n.$3, n.$4, n.$5]];
  final _skills = {...kSettingsProfileSkills};
  ThemeMode _mode = ThemeMode.system;

  Widget _switch(String t, String s, bool v, ValueChanged<bool> on) => Padding(
        padding: const EdgeInsets.symmetric(vertical: Space.s2),
        child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: const TextStyle(fontWeight: FontWeight.w600)), Text(s, style: TextStyle(fontSize: 13, color: context.kc.textMuted))])), Switch(value: v, onChanged: on)]),
      );

  Widget _body() {
    final c = context.kc;
    final u = kCurrentUser;
    return switch (kSettingsSections[_sec].$1) {
      'profile' => ExGap([
          Row(children: [KitAvatar(name: u.fullname, size: 64), const SizedBox(width: Space.s4), Expanded(child: Text('${u.fullname}\n${u.role}', style: const TextStyle(fontWeight: FontWeight.w600, height: 1.4)))]),
          ExRow([KitTextField(label: 'Prénoms', initialValue: u.prenoms), KitTextField(label: 'Nom', initialValue: u.nom)]),
          ExRow([KitTextField(label: 'E-mail', initialValue: u.mail), KitTextField(label: 'Téléphone', initialValue: u.phone)]),
          const KitTextField(label: 'Bio', initialValue: kSettingsProfileBio, maxLines: 3),
          Wrap(spacing: Space.s2, runSpacing: Space.s2, children: [for (final s in kSettingsSkillSuggestions) FilterChip(label: Text(s), selected: _skills.contains(s), onSelected: (v) => setState(() => v ? _skills.add(s) : _skills.remove(s)))]),
        ]),
      'security' => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (final (i, s) in kSettingsSecurity.indexed) _switch(s.$1, s.$2, _security[i], (v) => setState(() => _security[i] = v)),
          const Divider(),
          const ExHeading('Sessions actives'),
          for (final s in kSettingsSessions) ExTile(leading: Icon(s.$3), title: s.$1, subtitle: s.$2, trailing: s.$4 ? const StatusBadge('Cet appareil', tone: KitTone.success, uppercase: false) : TextButton(onPressed: () => exDemo(context, 'Session révoquée'), child: const Text('Révoquer'))),
          const SizedBox(height: Space.s2),
          Align(alignment: Alignment.centerLeft, child: KitButton(label: 'Changer le mot de passe', variant: KitButtonVariant.outline, onPressed: () => exDemo(context, 'Mot de passe'))),
        ]),
      'api' => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('Clé secrète'),
          const SizedBox(height: Space.s2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: Space.s3, vertical: Space.s2),
            decoration: BoxDecoration(color: c.tableHeader, border: Border.all(color: c.border), borderRadius: BorderRadius.circular(Radii.md)),
            child: Row(children: [
              Expanded(child: Text(_reveal ? kSettingsSecret : '${kSettingsSecret.substring(0, 8)}${'•' * 16}', overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: Fonts.mono, color: c.textPrimary))),
              IconButton(tooltip: _reveal ? 'Masquer' : 'Afficher', icon: Icon(_reveal ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _reveal = !_reveal)),
              IconButton(tooltip: 'Copier', icon: const Icon(Icons.copy), onPressed: () => exDemo(context, 'Clé copiée')),
            ]),
          ),
          const SizedBox(height: Space.s3),
          Align(alignment: Alignment.centerLeft, child: KitButton(label: 'Régénérer la clé', icon: Icons.refresh, variant: KitButtonVariant.outline, onPressed: () => exDemo(context, 'Clé régénérée'))),
        ]),
      'notifications' => Column(children: [
          for (final (i, n) in kSettingsNotifs.indexed)
            Padding(padding: const EdgeInsets.symmetric(vertical: Space.s2), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(n.$1, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(n.$2, style: TextStyle(fontSize: 13, color: c.textMuted)),
              const SizedBox(height: Space.s1),
              Wrap(spacing: Space.s2, children: [for (final (j, ch) in ['E-mail', 'Push', 'SMS'].indexed) FilterChip(label: Text(ch), selected: _notifs[i][j], onSelected: (v) => setState(() => _notifs[i][j] = v))]),
            ])),
        ]),
      'appearance' => Align(alignment: Alignment.centerLeft, child: SegmentedButton<ThemeMode>(
          segments: const [ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode), label: Text('Clair')), ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode), label: Text('Sombre')), ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto), label: Text('Système'))],
          selected: {_mode}, onSelectionChanged: (s) => setState(() => _mode = s.first))),
      _ => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('La suppression du compte ${kOrganisation.nom} est définitive.', style: TextStyle(color: c.textSecondary)),
          const SizedBox(height: Space.s3),
          KitButton(label: 'Supprimer le compte', icon: Icons.delete_forever, variant: KitButtonVariant.danger, onPressed: () => exDemo(context, 'Suppression')),
        ]),
    };
  }

  @override
  Widget build(BuildContext context) => ExPage(title: 'Paramètres', maxWidth: 1100, children: [
        LayoutBuilder(builder: (context, box) {
          final s = kSettingsSections[_sec];
          final card = KitCard(title: s.$2, icon: s.$3, child: _body());
          if (box.maxWidth < Breakpoints.tablet) {
            return ExGap([
              SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [for (final (i, x) in kSettingsSections.indexed) Padding(padding: const EdgeInsets.only(right: Space.s2), child: ChoiceChip(avatar: Icon(x.$3, size: 18), label: Text(x.$2), selected: _sec == i, onSelected: (_) => setState(() => _sec = i)))])),
              card,
            ]);
          }
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 240, child: Column(children: [for (final (i, x) in kSettingsSections.indexed) ExTile(leading: Icon(x.$3), title: x.$2, selected: _sec == i, onTap: () => setState(() => _sec = i))])),
            const SizedBox(width: Space.s4),
            Expanded(child: card),
          ]);
        }),
        const SizedBox(height: Space.s4),
        Align(alignment: Alignment.centerRight, child: KitButton(label: 'Enregistrer', icon: Icons.save_outlined, onPressed: () => exDemo(context, 'Paramètres enregistrés'))),
      ]);
}

/// Sélecteur de fichiers en modale, sélection multiple (`app-file-picker`).
Future<void> showFilePicker(BuildContext context) => showDialog<void>(
      context: context,
      builder: (ctx) {
        final sel = <int>{};
        return StatefulBuilder(builder: (ctx, set) => AlertDialog(
              title: const Text('Sélectionner des fichiers'),
              content: SizedBox(
                width: 440,
                child: ListView(shrinkWrap: true, children: [
                  for (final (i, f) in kFmItems.indexed)
                    if (f.kind != 'folder')
                      ExTile(
                        selected: sel.contains(i),
                        leading: Icon(kFmKinds[f.kind]!.$2, color: kFmKinds[f.kind]!.$3),
                        title: f.name,
                        subtitle: '${kFmKinds[f.kind]!.$1} · ${fmModified(f.days)} · ${f.owner}',
                        trailing: Checkbox(value: sel.contains(i), onChanged: (_) => set(() => sel.contains(i) ? sel.remove(i) : sel.add(i))),
                        onTap: () => set(() => sel.contains(i) ? sel.remove(i) : sel.add(i)),
                      ),
                ]),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Annuler')),
                FilledButton(onPressed: sel.isEmpty ? null : () { Navigator.of(ctx).pop(); exDemo(context, '${sel.length} fichier(s) sélectionné(s)'); }, child: Text('Joindre (${sel.length})')),
              ],
            ));
      },
    );

/// Messagerie compacte pour panneau latéral (`app-chat-panel`).
class ChatPanel extends StatefulWidget {
  const ChatPanel({super.key});
  @override
  State<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<ChatPanel> {
  final _ctrl = TextEditingController();
  // Conversation `c-aya` (`?chat=c-aya`).
  final _msgs = <(bool, String)>[for (final m in kChatConversations.first.messages) (m.$1 == 'me', m.$2)];

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Column(children: [
        Padding(
          padding: const EdgeInsets.all(Space.s3),
          child: Row(children: [
            const KitAvatar(name: 'Aya Koné', online: true),
            const SizedBox(width: Space.s3),
            const Expanded(child: Text('Aya Koné', style: TextStyle(fontWeight: FontWeight.w600))),
            IconButton(tooltip: 'Fermer', icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).maybePop()),
          ]),
        ),
        const Divider(height: 1),
        Expanded(child: ListView(padding: const EdgeInsets.all(Space.s3), children: [
          for (final m in _msgs)
            Align(
              alignment: m.$1 ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(bottom: Space.s2),
                padding: const EdgeInsets.symmetric(horizontal: Space.s3, vertical: Space.s2),
                constraints: const BoxConstraints(maxWidth: 280),
                decoration: BoxDecoration(color: m.$1 ? context.kc.primary : context.kc.hover, borderRadius: BorderRadius.circular(Radii.lg)),
                child: Text(m.$2, style: TextStyle(color: m.$1 ? context.kc.onPrimary : context.kc.textPrimary)),
              ),
            ),
        ])),
        Padding(
          padding: const EdgeInsets.all(Space.s2),
          child: Row(children: [
            Expanded(child: TextField(controller: _ctrl, decoration: const InputDecoration(hintText: 'Répondre…'))),
            const SizedBox(width: Space.s2),
            IconButton.filled(tooltip: 'Envoyer', icon: const Icon(Icons.send), onPressed: () { if (_ctrl.text.trim().isEmpty) return; setState(() { _msgs.add((true, _ctrl.text.trim())); _ctrl.clear(); }); }),
          ]),
        ),
      ]);
}
