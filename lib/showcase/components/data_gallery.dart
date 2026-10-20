import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/snack.dart';
import '../../data/showcase_data.dart';
import '../../theme/kit_colors.dart';
import '../../theme/kit_text.dart';
import '../../theme/tokens.dart';
import '../../widgets/charts.dart';
import '../../widgets/common.dart';
import '../../widgets/data_display.dart';
import '../../widgets/data_table.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/selects.dart';
import '../doc/doc.dart';

const _v1 = '''Article 4 — Conditions financières
Les prestations sont facturées mensuellement, terme à échoir.
Le règlement intervient à trente (30) jours date de facture.
Tout retard entraîne une pénalité de 1 % par mois.
Les prix sont révisables chaque année au 1er janvier.

Article 5 — Résiliation
Chaque partie peut résilier avec un préavis de trois (3) mois.
La résiliation est notifiée par lettre recommandée.''';
const _v2 = '''Article 4 — Conditions financières
Les prestations sont facturées mensuellement, terme à échoir.
Le règlement intervient à quarante-cinq (45) jours date de facture, par virement ou mobile money.
Tout retard entraîne une pénalité de 1,5 % par mois.
Les prix sont révisables chaque année au 1er janvier.

Article 5 — Résiliation
Chaque partie peut résilier avec un préavis de deux (2) mois.
La résiliation est notifiée par lettre recommandée ou par email avec accusé de réception.
Aucune indemnité n'est due en cas de résiliation à l'échéance.''';
const _cfg1 = '''{
  "intervalle_gps": 30,
  "vitesse_max": 90,
  "coupe_moteur": false,
  "alertes": ["sortie_zone", "batterie_faible"]
}''';
const _cfg2 = '''{
  "intervalle_gps": 15,
  "vitesse_max": 90,
  "coupe_moteur": true,
  "alertes": ["sortie_zone", "batterie_faible", "exces_vitesse"]
}''';

const _audit = [
  AuditEntry(
    user: 'Aminata Diallo',
    action: AuditAction.update,
    hoursAgo: 0.3,
    target: 'Client CLI-1040',
    meta: 'Android · 41.202.x.x',
    changes: [AuditChange('Téléphone', '+225 07 10 20 30 40', '+225 05 44 21 18 90'), AuditChange('Véhicules', '12', '14')],
  ),
  AuditEntry(
    user: 'Koffi N’Guessan',
    action: AuditAction.comment,
    hoursAgo: 1.2,
    target: 'Ticket #4521',
    comment: 'Balise remplacée, la remontée GPS est de nouveau normale. Client prévenu par téléphone.',
  ),
  AuditEntry(
    user: 'Aminata Diallo',
    action: AuditAction.status,
    hoursAgo: 3,
    target: 'Contrat CTR-2026-0412',
    changes: [AuditChange('Statut', 'Brouillon', 'Signé'), AuditChange('Signé le', null, '15/10/2026')],
  ),
  AuditEntry(
    user: 'Serge Kouamé',
    action: AuditAction.create,
    hoursAgo: 26,
    target: 'Véhicule CI-8843-UV',
    changes: [AuditChange('Marque', null, 'Nissan Navara'), AuditChange('Groupe', null, 'Livraisons Nord')],
  ),
  AuditEntry(user: 'Serge Kouamé', action: AuditAction.export, hoursAgo: 28, target: 'Rapport de trajets (septembre)', meta: 'XLSX · 2 480 lignes'),
  AuditEntry(user: 'Jean Kouassi', action: AuditAction.delete, hoursAgo: 52, target: 'Zone « Dépôt provisoire »'),
  AuditEntry(user: 'Jean Kouassi', action: AuditAction.login, hoursAgo: 55, meta: 'Application mobile · Android'),
];

/// `/components/data` — tables, cartes, listes, timeline, badges, KPI, graphiques, diff, audit, QR.
class DataGallery extends StatefulWidget {
  const DataGallery({super.key, this.initialSection});
  final String? initialSection;

  @override
  State<DataGallery> createState() => _DataGalleryState();
}

class _DataGalleryState extends State<DataGallery> {
  late final List<DemoClient> _clients = List.of(kDemoClients);
  final Map<String, ClientStatut> _statutOverride = {};
  final Map<String, String> _villeOverride = {};
  String _tableState = 'loading';
  ChartKind _chart = ChartKind.area;
  int _kpiSeed = 0;
  final _chips = <String>{'Transport', 'Abidjan'};

  ClientStatut _statut(DemoClient x) => _statutOverride[x.id] ?? x.statut;
  String _ville(DemoClient x) => _villeOverride[x.id] ?? x.ville;
  int _sante(DemoClient x) => 62 + (x.vehicules * 7) % 38;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return DocPage(
      title: 'Data display',
      icon: Icons.table_chart,
      initialSection: widget.initialSection,
      subtitle: 'Affichage de données du design system « registre » : tables (cartes en mobile), cartes d’entité, listes compactes, timelines, badges de statut, KPI et graphiques.',
      sections: [
        _table(c),
        _tableStates(c),
        _advanced(c),
        _cards(c),
        _list(c),
        _description(),
        _timeline(),
        _badges(c),
        _chipsSection(c),
        _avatars(c),
        _stats(c),
        _counters(c),
        _charts(c),
        DocSection(
          id: 'diff',
          title: 'Comparaison de versions (diff)',
          source: 'TextDiff · diffLines (LCS)',
          description: 'Vue unifiée adaptée à l’écran étroit ; les lignes identiques peuvent être repliées.',
          children: const [
            Demo(
              label: 'Contrat (texte)',
              child: TextDiff(before: _v1, after: _v2, fileName: 'contrat-cadre.txt'),
            ),
            Demo(
              label: 'Configuration (code)',
              child: TextDiff(before: _cfg1, after: _cfg2, fileName: 'gt06-config.json', mono: true),
            ),
          ],
        ),
        const DocSection(
          id: 'audit',
          title: 'Historique des modifications (audit log)',
          source: 'AuditLog',
          children: [
            Demo(
              label: 'Activité du compte',
              child: AuditLog(entries: _audit),
            ),
          ],
        ),
        DocSection(
          id: 'qr',
          title: 'QR code & code-barres',
          source: 'qr_flutter · barcode_widget',
          cols: 3,
          children: [
            const Demo(
              label: 'Lien de suivi',
              child: Center(
                child: QrBlock(data: 'https://suivi.lookas.ci/v/CI-4521-AB', label: 'Suivi CI-4521-AB'),
              ),
            ),
            const Demo(
              label: 'Wi-Fi atelier + logo',
              child: Center(
                child: QrBlock(data: 'WIFI:T:WPA;S:Atelier-Lookas;P:balise2026;;', label: 'Atelier-Lookas', withLogo: true),
              ),
            ),
            const Demo(
              label: 'Code-barres Code 128',
              child: Center(child: BarcodeBlock(data: 'FAC-2026-0912')),
            ),
          ],
        ),
        DocSection(
          id: 'empty',
          title: 'Empty state',
          source: 'EmptyState',
          cols: 2,
          children: [
            Demo(
              label: 'Avec action',
              child: EmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'Aucun produit trouvé',
                subtitle: 'Ajustez vos critères de recherche ou ajoutez un nouveau produit.',
                actionLabel: 'Nouveau produit',
                onAction: () => demoAction(context, 'Création'),
              ),
            ),
            const Demo(
              label: 'Compact',
              child: EmptyState(compact: true, icon: Icons.notifications_off_outlined, title: 'Aucune notification', subtitle: 'Vous êtes à jour.'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _clientCard(BuildContext context, DemoClient x, bool selected) {
    final c = context.kc;
    final st = _statut(x);
    return KitCard(
      color: selected ? c.primaryLight : null,
      borderColor: selected ? c.primary : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              KitAvatar(name: x.raisonSociale, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(x.raisonSociale, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.t.cardTitle.copyWith(fontSize: 15)),
                    Text(
                      x.code,
                      style: TextStyle(fontFamily: Fonts.mono, fontSize: 11, color: c.textMuted),
                    ),
                  ],
                ),
              ),
              if (selected) Icon(Icons.check_circle, color: c.primary) else StatusBadge(st.label, tone: st.tone),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on_outlined, size: 15, color: c.textMuted),
                  const SizedBox(width: 4),
                  Text(_ville(x), style: TextStyle(fontSize: 12.5, color: c.textSecondary)),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_shipping_outlined, size: 15, color: c.textMuted),
                  const SizedBox(width: 4),
                  Text('${x.vehicules} véh.', style: TextStyle(fontSize: 12.5, color: c.textSecondary)),
                ],
              ),
              Text(
                Fmt.fcfa(x.caMensuel),
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: c.textPrimary, fontFeatures: KitText.tabular),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<KitColumn<DemoClient>> _basicCols(KitColors c) => [
    KitColumn(
      label: 'Raison sociale',
      width: 170,
      sortValue: (x) => x.raisonSociale,
      cell: (_, x) => Text(
        x.raisonSociale,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    KitColumn(
      label: 'Code',
      width: 100,
      sortValue: (x) => x.code,
      cell: (_, x) => Text(x.code, style: const TextStyle(fontFamily: Fonts.mono, fontSize: 11.5)),
    ),
    KitColumn(label: 'Ville', width: 120, sortValue: (x) => _ville(x), cell: (_, x) => Text(_ville(x))),
    KitColumn(label: 'Véhicules', width: 100, numeric: true, sortValue: (x) => x.vehicules, cell: (_, x) => Text('${x.vehicules}')),
    KitColumn(label: 'CA mensuel', width: 140, numeric: true, sortValue: (x) => x.caMensuel, cell: (_, x) => Text(Fmt.fcfa(x.caMensuel))),
    KitColumn(
      label: 'Statut',
      width: 120,
      sortValue: (x) => _statut(x).index,
      cell: (_, x) => StatusBadge(_statut(x).label, tone: _statut(x).tone),
    ),
  ];

  DocSection _table(KitColors c) => DocSection(
    id: 'table',
    title: 'Table',
    source: 'KitDataTable (styles/entity-list)',
    description: 'Liste principale : vue cartes (par défaut en mobile) ou tableau défilant à 1re colonne fixe. Recherche, tri par en-tête, pagination.',
    children: [
      Demo(
        label: 'Clients (40)',
        flush: true,
        code: '''KitDataTable<DemoClient>(
  rows: clients,
  columns: [...],
  searchText: (c) => '\${c.raisonSociale} \${c.code}',
  cardBuilder: (ctx, c, selected) => ClientCard(c),
)''',
        child: Padding(
          padding: const EdgeInsets.all(Space.s3),
          child: KitDataTable<DemoClient>(
            rows: _clients,
            initialMode: ViewMode.card,
            columns: _basicCols(c),
            searchText: (x) => '${x.raisonSociale} ${x.code} ${x.ville}',
            cardBuilder: _clientCard,
            pageSize: 5,
            onRowTap: (x) => showKitSnack(context, 'Ouverture de ${x.raisonSociale}'),
          ),
        ),
      ),
    ],
  );

  DocSection _tableStates(KitColors c) => DocSection(
    id: 'table-states',
    title: 'États de table',
    description: 'Chargement (squelettes), vide, aucun résultat de recherche, erreur.',
    children: [
      Demo(
        label: 'États',
        child: Gap([
          SegmentedToggle<String>(
            value: _tableState,
            expand: true,
            onChanged: (v) => setState(() => _tableState = v),
            options: const [('loading', 'Chargement', null), ('empty', 'Vide', null), ('noresult', 'Recherche', null), ('error', 'Erreur', null)],
          ),
          switch (_tableState) {
            'loading' => const Column(children: [SkeletonListTile(), SkeletonListTile(), SkeletonListTile()]),
            'empty' => EmptyState(
              icon: Icons.groups_outlined,
              title: 'Aucun client trouvé',
              subtitle: 'Ajustez vos critères de recherche ou ajoutez un nouveau client.',
              actionLabel: 'Nouveau client',
              onAction: () => demoAction(context, 'Création'),
            ),
            'noresult' => const EmptyState(icon: Icons.search_off, title: 'Aucun résultat', subtitle: 'Aucun client ne correspond à « Korhogo Transit ».'),
            _ => ErrorState(code: 'HTTP 503 · réf. 7f2c-91', onRetry: () => setState(() => _tableState = 'loading')),
          },
        ]),
      ),
    ],
  );

  DocSection _advanced(KitColors c) {
    Future<void> editStatut(BuildContext ctx, DemoClient x) async {
      final v = await showSelectSheet<ClientStatut>(
        ctx,
        title: 'Statut — ${x.raisonSociale}',
        selected: _statut(x),
        searchable: false,
        options: [for (final s in ClientStatut.values) SelectOption(s, s.label, tone: s.tone)],
      );
      if (v != null) setState(() => _statutOverride[x.id] = v);
    }

    Future<void> editVille(BuildContext ctx, DemoClient x) async {
      final v = await showSelectSheet<String>(ctx, title: 'Ville', selected: _ville(x), options: [for (final v in kVilles) SelectOption(v, v)]);
      if (v != null) setState(() => _villeOverride[x.id] = v);
    }

    return DocSection(
      id: 'advanced-table',
      title: 'Table avancée',
      source: 'KitDataTable(selectable, bulkActions, columnToggle, total, onEdit)',
      description: 'Sélection multiple et actions groupées, colonnes masquables, ligne de total, édition en ligne (touchez une cellule marquée ✎).',
      children: [
        Demo(
          label: 'Clients',
          flush: true,
          child: Padding(
            padding: const EdgeInsets.all(Space.s3),
            child: KitDataTable<DemoClient>(
              rows: _clients,
              selectable: true,
              columnToggle: true,
              dense: true,
              searchText: (x) => '${x.raisonSociale} ${x.code} ${x.contact}',
              cardBuilder: _clientCard,
              bulkActions: const [
                BulkAction('export', 'Exporter', Icons.download),
                BulkAction('mail', 'Envoyer un email', Icons.mail_outline),
                BulkAction('suspend', 'Suspendre', Icons.pause_circle_outline),
                BulkAction('delete', 'Supprimer', Icons.delete_outline, danger: true),
              ],
              onBulk: (a, rows) async {
                if (a == 'delete') {
                  final ok = await showKitConfirm(context, title: 'Supprimer ${rows.length} client(s) ?', message: 'Cette action est irréversible.', confirm: 'Supprimer', danger: true);
                  if (ok) setState(() => _clients.removeWhere(rows.contains));
                } else if (a == 'suspend') {
                  setState(() {
                    for (final r in rows) {
                      _statutOverride[r.id] = ClientStatut.suspendu;
                    }
                  });
                } else if (mounted) {
                  demoAction(context, '${a == 'export' ? 'Export' : 'Email'} de ${rows.length} client(s)');
                }
              },
              columns: [
                KitColumn(
                  label: 'Raison sociale',
                  width: 160,
                  sortValue: (x) => x.raisonSociale,
                  cell: (_, x) => Text(
                    x.raisonSociale,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                KitColumn(
                  label: 'Code',
                  width: 100,
                  sortValue: (x) => x.code,
                  cell: (_, x) => Text(x.code, style: const TextStyle(fontFamily: Fonts.mono, fontSize: 11.5)),
                ),
                KitColumn(label: 'Contact', width: 150, cell: (_, x) => Text(x.contact)),
                KitColumn(label: 'Ville', width: 130, sortValue: (x) => _ville(x), cell: (_, x) => Text(_ville(x)), onEdit: editVille),
                KitColumn(label: 'Secteur', width: 120, cell: (_, x) => Text(x.secteur)),
                KitColumn(
                  label: 'Véhicules',
                  width: 100,
                  numeric: true,
                  sortValue: (x) => x.vehicules,
                  cell: (_, x) => Text('${x.vehicules}'),
                  total: (r) => Fmt.number(r.fold<int>(0, (a, x) => a + x.vehicules)),
                ),
                KitColumn(
                  label: 'CA mensuel',
                  width: 140,
                  numeric: true,
                  sortValue: (x) => x.caMensuel,
                  cell: (_, x) => Text(Fmt.fcfa(x.caMensuel)),
                  total: (r) => Fmt.compact(r.fold<int>(0, (a, x) => a + x.caMensuel)),
                ),
                KitColumn(
                  label: 'Remontée',
                  width: 150,
                  sortValue: (x) => _sante(x),
                  cell: (_, x) => Row(
                    children: [
                      Expanded(
                        child: KitProgressBar(
                          value: _sante(x) / 100,
                          tone: _sante(x) > 85
                              ? KitTone.success
                              : _sante(x) > 70
                              ? KitTone.warning
                              : KitTone.error,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${_sante(x)} %', style: const TextStyle(fontSize: 11.5)),
                    ],
                  ),
                ),
                KitColumn(label: 'Email', width: 230, hidden: true, cell: (_, x) => Text(x.email)),
                KitColumn(label: 'Téléphone', width: 160, hidden: true, cell: (_, x) => Text(x.telephone)),
                KitColumn(label: 'Client depuis', width: 120, sortValue: (x) => x.createdAt, cell: (_, x) => Text(Fmt.date(x.createdAt))),
                KitColumn(
                  label: 'Statut',
                  width: 120,
                  sortValue: (x) => _statut(x).index,
                  cell: (_, x) => StatusBadge(_statut(x).label, tone: _statut(x).tone),
                  onEdit: editStatut,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  DocSection _cards(KitColors c) => DocSection(
    id: 'cards',
    title: 'Cards',
    source: '.entity-card · .panel-card',
    cols: 3,
    children: [
      Demo(label: 'Carte d’entité', child: _clientCard(context, _clients[1], false)),
      Demo(
        label: 'Carte produit',
        child: KitCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 110,
                color: c.primaryLight,
                child: Stack(
                  children: [
                    Center(child: Image.asset('assets/images/camion.png', height: 84)),
                    const Positioned(top: 10, left: 10, child: StatusBadge('Populaire', tone: KitTone.tertiary)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(Space.s4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Suivi Poids lourds', style: context.t.cardTitle),
                    const SizedBox(height: 4),
                    Text('Sondes carburant, temps de conduite, chronotachygraphe.', style: context.t.bodySm),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: '18 500',
                                style: TextStyle(fontFamily: Fonts.heading, fontSize: 20, fontWeight: FontWeight.w700),
                              ),
                              TextSpan(
                                text: ' FCFA/mois',
                                style: TextStyle(fontSize: 12, color: c.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        IconButton.filledTonal(onPressed: () => demoAction(context, 'Ajout au devis'), icon: const Icon(Icons.add_shopping_cart, size: 20)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      Demo(
        label: 'Panneau de section',
        child: KitCard(
          title: 'Informations générales',
          icon: Icons.info_outline,
          trailing: IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined, size: 18)),
          child: const DescriptionList(
            columns: 1,
            horizontal: true,
            items: [
              DescItem('Offre', 'Premium — Flotte'),
              DescItem('Véhicules', '24'),
              DescItem('Statut', 'Actif', type: DescType.badge, tone: KitTone.success),
            ],
          ),
        ),
      ),
    ],
  );

  DocSection _list(KitColors c) => DocSection(
    id: 'list',
    title: 'List',
    source: 'ListTile · Dismissible',
    description: 'Listes compactes ; balayez une ligne pour l’archiver (geste mobile).',
    cols: 2,
    children: [
      Demo(
        label: 'Liste avec avatars',
        flush: true,
        child: Column(
          children: [
            for (final x in _clients.take(4))
              ListTile(
                leading: KitAvatar(name: x.contact, online: x.vehicules.isEven),
                title: Text(x.contact),
                subtitle: Text('${x.raisonSociale} · ${_ville(x)}'),
                trailing: Icon(Icons.chevron_right, color: c.textMuted),
                onTap: () {},
              ),
          ],
        ),
      ),
      Demo(label: 'Balayer pour archiver', flush: true, child: _SwipeList()),
    ],
  );

  DocSection _description() => const DocSection(
    id: 'description-list',
    title: 'Liste descriptive (clé / valeur)',
    source: 'DescriptionList',
    children: [
      Demo(
        label: 'Grille (copie, liens, badge, multiligne)',
        child: DescriptionList(
          columns: 3,
          items: [
            DescItem('Raison sociale', 'Transports Yao & Fils', icon: Icons.business),
            DescItem('Code client', 'CLI-1040', type: DescType.mono, copy: true),
            DescItem('Statut', 'Actif', type: DescType.badge, tone: KitTone.success),
            DescItem('Contact', 'Jean Kouassi', icon: Icons.person_outline),
            DescItem('Email', 'jean.kouassi@transports-yao.ci', type: DescType.email, copy: true),
            DescItem('Téléphone', '+225 07 10 20 30 40', type: DescType.phone),
            DescItem('RCCM', 'CI-ABJ-2019-B-12345', type: DescType.mono, copy: true, hint: 'Registre du commerce'),
            DescItem('Site web', 'transports-yao.ci', type: DescType.link),
            DescItem('Gestionnaire', null),
            DescItem('Adresse', 'Zone industrielle de Yopougon\nLot 412, BP 1234 Abidjan 01', type: DescType.multiline, full: true),
          ],
        ),
      ),
      Demo(
        label: 'Horizontale (contrat en cours)',
        child: DescriptionList(
          horizontal: true,
          title: 'Contrat en cours',
          items: [
            DescItem('Offre', 'Premium — Flotte'),
            DescItem('Début', '01/03/2026'),
            DescItem('Échéance', '28/02/2027'),
            DescItem('Montant mensuel', '1 250 000 FCFA'),
            DescItem('Paiement', 'Virement, à 30 jours'),
            DescItem('Renouvellement', 'Tacite', type: DescType.badge, tone: KitTone.info),
          ],
        ),
      ),
    ],
  );

  DocSection _timeline() => DocSection(
    id: 'timeline',
    title: 'Timeline',
    source: 'KitTimeline',
    cols: 2,
    children: [
      Demo(
        label: 'Cycle d’une requête',
        child: KitTimeline(
          items: [for (final e in kTimelineEvents) TimelineEntry(title: e.titre, text: e.texte, time: '${Fmt.dayMonth(e.date)} · ${Fmt.time(e.date)}', icon: e.icon, tone: e.tone)],
        ),
      ),
      const Demo(
        label: 'Dense',
        child: KitTimeline(
          dense: true,
          items: [
            TimelineEntry(title: 'Départ du dépôt', time: '08:12', icon: Icons.play_arrow, tone: KitTone.neutral),
            TimelineEntry(title: 'Entrée zone aéroport', time: '09:40', icon: Icons.login, tone: KitTone.info),
            TimelineEntry(title: 'Sortie de zone autorisée', text: 'Geofence « Port-Bouët » franchie', time: '10:05', icon: Icons.warning, tone: KitTone.error),
            TimelineEntry(title: 'Alerte envoyée', time: '10:07', icon: Icons.notifications_active, tone: KitTone.warning),
          ],
        ),
      ),
    ],
  );

  DocSection _badges(KitColors c) => DocSection(
    id: 'badge',
    title: 'Badge',
    source: 'StatusBadge (.m3-badge) · Badge',
    cols: 2,
    children: [
      const Demo(
        label: 'Statuts',
        child: DemoWrap(
          spacing: 8,
          children: [
            StatusBadge('Actif', tone: KitTone.success, icon: Icons.check_circle),
            StatusBadge('Suspendu', tone: KitTone.warning),
            StatusBadge('Résilié', tone: KitTone.error),
            StatusBadge('Installé', tone: KitTone.info),
            StatusBadge('Premium', tone: KitTone.purple, icon: Icons.workspace_premium),
            StatusBadge('Brouillon'),
            StatusBadge('Nouveau', tone: KitTone.primary, uppercase: false),
          ],
        ),
      ),
      Demo(
        label: 'Pastilles d’icône',
        child: DemoWrap(
          spacing: 20,
          children: [
            const Badge(label: Text('3'), child: Icon(Icons.notifications_outlined)),
            Badge(label: const Text('12'), backgroundColor: c.primary, child: const Icon(Icons.mail_outline)),
            const Badge(smallSize: 9, child: Icon(Icons.chat_bubble_outline)),
            const Badge(label: Text('99+'), child: Icon(Icons.shopping_cart_outlined)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Alertes', style: TextStyle(color: c.textPrimary)),
                const SizedBox(width: 6),
                const CountDot(5),
              ],
            ),
          ],
        ),
      ),
    ],
  );

  DocSection _chipsSection(KitColors c) => DocSection(
    id: 'chip',
    title: 'Chip',
    source: 'FilterChip · InputChip · ActionChip',
    cols: 2,
    children: [
      Demo(
        label: 'Filtres',
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final t in const ['Transport', 'Logistique', 'Abidjan', 'Bouaké', 'Premium'])
              FilterChip(label: Text(t), selected: _chips.contains(t), onSelected: (v) => setState(() => v ? _chips.add(t) : _chips.remove(t))),
          ],
        ),
      ),
      Demo(
        label: 'Saisie & actions',
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            InputChip(
              avatar: const KitAvatar(name: 'Awa Koné', size: 24),
              label: const Text('Awa Koné'),
              onDeleted: () {},
            ),
            InputChip(avatar: const Icon(Icons.location_on, size: 18), label: const Text('Marcory'), onDeleted: () {}),
            ActionChip(avatar: const Icon(Icons.add, size: 18), label: const Text('Ajouter un filtre'), onPressed: () {}),
            const Chip(label: Text('Lecture seule')),
          ],
        ),
      ),
    ],
  );

  DocSection _avatars(KitColors c) => DocSection(
    id: 'avatar',
    title: 'Avatar',
    source: 'KitAvatar · AvatarStack',
    cols: 3,
    children: [
      const Demo(
        label: 'Tailles',
        child: DemoWrap(
          children: [
            KitAvatar(name: 'Jean Kouassi', size: 24),
            KitAvatar(name: 'Marie Yao', size: 32),
            KitAvatar(name: 'Aminata Diallo', size: 40),
            KitAvatar(name: 'Koffi N’Guessan', size: 56),
          ],
        ),
      ),
      const Demo(
        label: 'Image & présence',
        child: DemoWrap(
          children: [
            KitAvatar(name: 'Logo', size: 48, image: AssetImage('assets/images/logo.png')),
            KitAvatar(name: 'Fatou Bamba', size: 48, online: true),
            KitAvatar(name: 'Serge Kouamé', size: 48, online: false),
          ],
        ),
      ),
      const Demo(
        label: 'Groupe',
        child: AvatarStack(names: ['Jean Kouassi', 'Marie Yao', 'Aminata Diallo', 'Koffi N’Guessan', 'Fatou Bamba', 'Serge Kouamé']),
      ),
    ],
  );

  DocSection _stats(KitColors c) => DocSection(
    id: 'stats',
    title: 'Statistics cards',
    source: '.kpi-card · Sparkline',
    children: [
      ResponsiveGrid(
        minItemWidth: 240,
        children: const [
          KpiCard(icon: Icons.groups, value: '1 284', label: 'Clients actifs', tone: KitTone.primary, delta: '+4,2 %', up: true),
          KpiCard(icon: Icons.local_shipping, value: '8 432', label: 'Véhicules suivis', tone: KitTone.info, delta: '+3,1 %', up: true),
          KpiCard(icon: Icons.payments, value: '55,8', unit: 'M FCFA', label: 'CA du mois', tone: KitTone.success, delta: '+9,2 %', up: true),
          KpiCard(icon: Icons.warning_amber, value: '17', label: 'Alertes ouvertes', tone: KitTone.warning, delta: '−5', up: false),
        ],
      ),
      Demo(
        label: 'Tuiles avec mini-courbe',
        child: ResponsiveGrid(
          minItemWidth: 200,
          spacing: 10,
          children: [
            _SparkTile(label: 'Km parcourus', value: '12 480', delta: '+8 %', up: true, tone: KitTone.primary, data: const [1500, 1720, 1650, 1880, 1790, 1960, 1980]),
            _SparkTile(label: 'Disponibilité', value: '96,4 %', delta: '+0,6 pt', up: true, tone: KitTone.success, data: const [95.2, 95.6, 95.4, 95.9, 96.1, 96.0, 96.4]),
            _SparkTile(label: 'Impayés', value: '4,9 M', delta: '+12 %', up: true, good: false, tone: KitTone.error, data: const [3.1, 3.4, 3.2, 3.9, 4.2, 4.4, 4.9]),
          ],
        ),
      ),
    ],
  );

  DocSection _counters(KitColors c) {
    final ca = 55800000.0 + _kpiSeed * 1350000;
    final veh = 8432.0 + _kpiSeed * 37;
    return DocSection(
      id: 'counters',
      title: 'Compteurs animés & tendances',
      source: 'StatCounter · TrendChip · RingGauge',
      children: [
        Demo(
          label: 'Animation au changement',
          hint: 'touchez « Actualiser »',
          child: Gap([
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CA du mois', style: context.t.label),
                      StatCounter(value: ca, compact: true, suffix: ' FCFA'),
                      const TrendChip('+9,2 % vs sept.'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Véhicules', style: context.t.label),
                      StatCounter(value: veh),
                      const TrendChip('+3,1 % vs sept.'),
                    ],
                  ),
                ),
                RingGauge(value: 0.72 + _kpiSeed % 3 * 0.08, tone: KitTone.success),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(onPressed: () => setState(() => _kpiSeed++), icon: const Icon(Icons.refresh, size: 18), label: const Text('Actualiser')),
            ),
          ]),
        ),
      ],
    );
  }

  DocSection _charts(KitColors c) {
    final labels = kMois.sublist(0, 10);
    final s26 = ChartSeries('2026', [for (final v in kCa2026.sublist(0, 10)) v]);
    final s25 = ChartSeries('2025', [for (final v in kCa2025.sublist(0, 10)) v]);
    final (kindLabels, kindSeries) = switch (_chart) {
      ChartKind.doughnut || ChartKind.pie => (
        ['Abonnement', 'Installation', 'Maintenance', 'Matériel'],
        [
          const ChartSeries('Part', [54, 21, 15, 10]),
        ],
      ),
      ChartKind.hbar => (
        ['Abidjan', 'Bouaké', 'San-Pédro', 'Yamoussoukro', 'Korhogo'],
        [
          const ChartSeries('CA', [312, 96, 74, 58, 31]),
        ],
      ),
      ChartKind.radar => (
        ['Réactivité', 'Qualité', 'Délais', 'Prix', 'Support', 'Couverture'],
        [
          const ChartSeries('Lookas', [8, 9, 7, 6, 9, 8]),
          const ChartSeries('Marché', [6, 7, 6, 7, 5, 6]),
        ],
      ),
      ChartKind.stacked => (
        ['T1', 'T2', 'T3', 'T4'],
        [
          const ChartSeries('Abonnements', [92, 101, 112, 120]),
          const ChartSeries('Installations', [31, 36, 29, 40]),
          const ChartSeries('Matériel', [12, 18, 15, 22]),
        ],
      ),
      _ => (labels, [s26, s25]),
    };
    return DocSection(
      id: 'charts',
      title: 'Graphiques',
      source: 'KitChart (fl_chart)',
      description: 'Couleurs du thème, grille discrète, info-bulles au toucher. Touchez un point ou une barre.',
      children: [
        Demo(
          label: 'Types',
          code: '''KitChart(
  kind: ChartKind.area,
  labels: mois,
  series: [ChartSeries('2026', ca2026), ChartSeries('2025', ca2025)],
  compactValues: true,
)''',
          child: Gap([
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final k in ChartKind.values)
                    Padding(
                      padding: const EdgeInsets.only(right: Space.s2),
                      child: ChoiceChip(
                        label: Text(switch (k) {
                          ChartKind.line => 'Ligne',
                          ChartKind.area => 'Aire',
                          ChartKind.bar => 'Barres',
                          ChartKind.hbar => 'Horizontal',
                          ChartKind.stacked => 'Empilé',
                          ChartKind.doughnut => 'Anneau',
                          ChartKind.pie => 'Secteurs',
                          ChartKind.radar => 'Radar',
                        }),
                        selected: _chart == k,
                        onSelected: (_) => setState(() => _chart = k),
                      ),
                    ),
                ],
              ),
            ),
            KitChart(
              key: ValueKey(_chart),
              kind: _chart,
              labels: kindLabels,
              series: kindSeries,
              compactValues: _chart == ChartKind.line || _chart == ChartKind.area || _chart == ChartKind.bar,
              unit: switch (_chart) {
                ChartKind.doughnut || ChartKind.pie => ' %',
                ChartKind.hbar || ChartKind.stacked => ' M',
                _ => '',
              },
            ),
          ]),
        ),
      ],
    );
  }
}

class _SparkTile extends StatelessWidget {
  const _SparkTile({required this.label, required this.value, required this.delta, required this.up, required this.tone, required this.data, this.good = true});
  final String label, value, delta;
  final bool up, good;
  final KitTone tone;
  final List<double> data;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return KitCard(
      padding: const EdgeInsets.all(Space.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: c.textSecondary)),
          const SizedBox(height: 2),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(fontFamily: Fonts.heading, fontSize: 20, fontWeight: FontWeight.w700, color: c.textPrimary),
              ),
              const Spacer(),
              TrendChip(delta, up: up, goodWhenUp: good),
            ],
          ),
          const SizedBox(height: 6),
          Sparkline(data, color: tone.color(c)),
        ],
      ),
    );
  }
}

class _SwipeList extends StatefulWidget {
  @override
  State<_SwipeList> createState() => _SwipeListState();
}

class _SwipeListState extends State<_SwipeList> {
  final _items = kNotifications.toList();

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    if (_items.isEmpty) {
      return EmptyState(
        compact: true,
        icon: Icons.inbox,
        title: 'Boîte vide',
        subtitle: 'Tout est archivé.',
        actionLabel: 'Restaurer',
        actionIcon: Icons.restore,
        onAction: () => setState(() => _items.addAll(kNotifications)),
      );
    }
    return Column(
      children: [
        for (final n in List.of(_items))
          Dismissible(
            key: ValueKey(n.title),
            background: Container(
              color: c.successLight,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: Space.s5),
              child: Icon(Icons.archive_outlined, color: c.successText),
            ),
            secondaryBackground: Container(
              color: c.errorLight,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: Space.s5),
              child: Icon(Icons.delete_outline, color: c.errorText),
            ),
            onDismissed: (d) {
              final i = _items.indexOf(n);
              setState(() => _items.remove(n));
              showKitSnack(context, d == DismissDirection.startToEnd ? 'Archivé' : 'Supprimé', action: 'Annuler', onAction: () => setState(() => _items.insert(i, n)));
            },
            child: ListTile(
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(shape: BoxShape.circle, color: n.tone.light(c)),
                child: Icon(n.icon, size: 19, color: n.tone.color(c)),
              ),
              title: Text(n.title, style: TextStyle(fontWeight: n.read ? FontWeight.w500 : FontWeight.w700)),
              subtitle: Text(n.text, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
      ],
    );
  }
}
