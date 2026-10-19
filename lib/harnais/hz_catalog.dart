import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/format.dart';
import '../data/map_data.dart';
import '../theme/kit_colors.dart';
import '../widgets/charts.dart';
import '../widgets/planning/planning_models.dart';
import 'hz_models.dart';

// ═══════════════════════════════════════════════════════════════════
// Données et scénarios simulés du Harnais (harnais.data / scenarios / toolkit).
// ═══════════════════════════════════════════════════════════════════

const kHzModels = [
  HzModel('opus', 'Opus 5.5', 'Le plus capable pour les tâches complexes', badge: 'Pro'),
  HzModel('sonnet', 'Sonnet 5.5', 'Équilibre idéal pour le quotidien'),
  HzModel('haiku', 'Haiku 5.5', 'Le plus rapide pour les réponses courtes'),
];

const kHzSuggestions = [
  (Icons.space_dashboard, 'Synthèse', 'Fais-moi un tableau de bord complet de l’activité.'),
  (Icons.map, 'Carte', 'Montre-moi la flotte sur une carte.'),
  (Icons.show_chart, 'Graphique', 'Analyse l’évolution des ventes cette année.'),
  (Icons.table_rows, 'Tableau', 'Liste des clients à relancer.'),
  (Icons.edit_note, 'Formulaire', 'Je veux créer une demande d’intervention.'),
  (Icons.calendar_month, 'Calendrier', 'Affiche le calendrier des interventions.'),
  (Icons.view_kanban, 'Kanban', 'Montre l’avancement des tâches de l’équipe.'),
  (Icons.timeline, 'Gantt', 'Montre la feuille de route du déploiement.'),
  (Icons.account_tree, 'Arborescence', 'Explore les documents du dossier client.'),
  (Icons.difference, 'Corriger un bug', 'Corrige le bug des alertes de zone en double.'),
  (Icons.apps, 'Tous les outils', 'Quels outils peux-tu utiliser ?'),
];

const kHzAttachable = [
  HzAttachment('app-shell.component.ts', 'code', '4 Ko'),
  HzAttachment('maquette-sidecar.png', 'image', '312 Ko'),
  HzAttachment('cahier-des-charges.pdf', 'pdf', '1,2 Mo'),
  HzAttachment('ventes-T3.xlsx', 'sheet', '86 Ko'),
];

const _sidecarCode = '''class Sidecar extends StatefulWidget {
  const Sidecar({super.key, required this.items, required this.selected, required this.onSelect});
  final List<MenuEntry> items;
  final String selected;
  final ValueChanged<MenuEntry> onSelect;

  @override
  State<Sidecar> createState() => _SidecarState();
}

class _SidecarState extends State<Sidecar> {
  /// Module dont la sous-navigation est déployée (null = rail seul).
  String? _open;

  void toggle(String id) => setState(() => _open = _open == id ? null : id);
}''';

const kHzArtifacts = [
  HzArtifact('art-sidecar', 'sidecar.dart', 'code', 'dart', 2, _sidecarCode),
  HzArtifact('art-palette', 'Palette sombre — notes', 'document', 'markdown', 1, '''# Palette sombre accessible

Fond      #0A0D10   (contraste texte 15,8:1)
Surface   #191C1C
Bordure   rgba(255,255,255,.08)
Texte     #E0E3E2
Primaire  #00DDDD   (AA sur surface)

Règle : chaque couleur d'état garde un ratio ≥ 4,5:1 sur la surface.'''),
];

const kHzTasks = [
  HzTask('Lire le shell et la galerie de navigation', 'done'),
  HzTask('Fusionner rail et sous-navigation', 'done'),
  HzTask('Animer l’ouverture de la colonne', 'done'),
  HzTask('Extraire un composant réutilisable', 'running'),
  HzTask('Brancher le Sidecar dans le shell', 'todo'),
];

const kHzContext = [
  HzContextFile('navigation_gallery.dart', 'showcase/components', 4200, 'code'),
  HzContextFile('navigation.dart', 'widgets', 3100, 'code'),
  HzContextFile('menu_data.dart', 'data', 900, 'code'),
  HzContextFile('maquette-sidecar.png', 'pièce jointe', 1600, 'image'),
];
const kHzContextLimit = 200000;

DateTime _day(int offset, [int hour = 9]) {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day + offset, hour);
}

// ─── Briques de widgets (W) ──────────────────────────────────────────
abstract final class W {
  static HzW fleetStats() => HzW('stats', p: {
        'items': const [
          HzStat('Véhicules actifs', '42', delta: '+3', up: true, tone: KitTone.success, icon: Icons.local_shipping, hint: 'sur 48', spark: [36, 37, 39, 38, 40, 39, 42]),
          HzStat('Km parcourus', '12 480', delta: '+8 %', up: true, tone: KitTone.primary, icon: Icons.route, hint: '7 derniers jours', spark: [1500, 1720, 1650, 1880, 1790, 1960, 1980]),
          HzStat('Alertes ouvertes', '5', delta: '−2', up: false, tone: KitTone.warning, icon: Icons.notifications_active, spark: [9, 8, 8, 7, 6, 7, 5]),
          HzStat('Disponibilité', '96,4 %', delta: '+0,6 pt', up: true, tone: KitTone.info, icon: Icons.verified, spark: [95.2, 95.6, 95.4, 95.9, 96.1, 96.0, 96.4]),
        ],
      });

  static HzW fleetMap() => HzW('map', title: 'Flotte en temps réel', subtitle: 'Abidjan · 8 véhicules suivis', icon: Icons.map, p: {
        'markers': kFlotte,
        'legend': const [('En mouvement', KitTone.success), ('À l’arrêt', KitTone.warning), ('Maintenance', KitTone.info), ('Alerte', KitTone.error)],
      });

  static HzW salesChart() => HzW('chart', title: 'Chiffre d’affaires mensuel', subtitle: 'En millions FCFA · 2026 vs 2025', icon: Icons.show_chart, p: {
        'kind': ChartKind.area,
        'unit': ' M',
        'labels': const ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct'],
        'series': const [
          ChartSeries('2026', [182, 196, 210, 205, 231, 248, 240, 262, 275, 291]),
          ChartSeries('2025', [160, 171, 175, 182, 190, 201, 198, 210, 216, 224]),
        ],
      });

  static HzW mixChart() => HzW('chart', title: 'Répartition par offre', subtitle: 'Part du CA · octobre', icon: Icons.donut_large, p: {
        'kind': ChartKind.doughnut,
        'unit': ' %',
        'labels': const ['Abonnement', 'Installation', 'Maintenance', 'Matériel'],
        'series': const [ChartSeries('Part', [54, 21, 15, 10])],
      });

  static HzW regionChart() => HzW('chart', title: 'CA par région', subtitle: 'Millions FCFA · cumul annuel', icon: Icons.bar_chart, p: {
        'kind': ChartKind.hbar,
        'unit': ' M',
        'labels': const ['Abidjan', 'Bouaké', 'San-Pédro', 'Yamoussoukro', 'Korhogo'],
        'series': const [ChartSeries('CA', [1420, 396, 274, 211, 138])],
      });

  static HzW clientsTable() => HzW('table', title: 'Clients à relancer', subtitle: '8 comptes · triés par encours', icon: Icons.table_rows, p: {
        'searchable': true,
        'pageSize': 5,
        'columns': const [
          HzColumn('client', 'Client', kind: 'person'),
          HzColumn('ville', 'Ville'),
          HzColumn('encours', 'Encours', kind: 'number', unit: ' FCFA'),
          HzColumn('retard', 'Retard', kind: 'number', unit: ' j'),
          HzColumn('statut', 'Statut', kind: 'badge', tones: {'Critique': KitTone.error, 'À relancer': KitTone.warning, 'En cours': KitTone.info, 'Réglé': KitTone.success}),
          HzColumn('recouvre', 'Recouvré', kind: 'progress'),
        ],
        'rows': const [
          {'client': 'Bolloré Logistics CI', 'ville': 'Abidjan', 'encours': 4850000, 'retard': 47, 'statut': 'Critique', 'recouvre': 20},
          {'client': 'Transports Yao SARL', 'ville': 'Bouaké', 'encours': 2310000, 'retard': 32, 'statut': 'À relancer', 'recouvre': 45},
          {'client': 'SOTRA', 'ville': 'Abidjan', 'encours': 1980000, 'retard': 18, 'statut': 'En cours', 'recouvre': 60},
          {'client': 'Cargill Côte d’Ivoire', 'ville': 'San-Pédro', 'encours': 1420000, 'retard': 12, 'statut': 'En cours', 'recouvre': 72},
          {'client': 'Orange CI', 'ville': 'Abidjan', 'encours': 980000, 'retard': 9, 'statut': 'À relancer', 'recouvre': 35},
          {'client': 'SIFCA', 'ville': 'Abidjan', 'encours': 760000, 'retard': 5, 'statut': 'En cours', 'recouvre': 88},
          {'client': 'Nestlé CI', 'ville': 'Yamoussoukro', 'encours': 420000, 'retard': 2, 'statut': 'Réglé', 'recouvre': 100},
          {'client': 'CIE', 'ville': 'Korhogo', 'encours': 310000, 'retard': 1, 'statut': 'Réglé', 'recouvre': 100},
        ],
      });

  static HzW interventionForm() => HzW('form', title: 'Nouvelle demande d’intervention', icon: Icons.build, p: {
        'formId': 'intervention',
        'description': 'Il me manque quelques informations pour planifier le technicien.',
        'submitLabel': 'Planifier l’intervention',
        'fields': const [
          HzField('client', 'Client', 'select', icon: Icons.business, required: true, options: [HzOption('bollore', 'Bolloré Logistics CI'), HzOption('yao', 'Transports Yao SARL'), HzOption('sotra', 'SOTRA')]),
          HzField('vehicule', 'Immatriculation', 'text', icon: Icons.directions_car, placeholder: 'CI-0000-AB', required: true),
          HzField('type', 'Type d’intervention', 'segmented', wide: true, value: 'install', options: [HzOption('install', 'Installation', icon: Icons.add_circle), HzOption('repair', 'Dépannage', icon: Icons.build), HzOption('remove', 'Retrait', icon: Icons.remove_circle)]),
          HzField('date', 'Date souhaitée', 'date', required: true),
          HzField('creneau', 'Créneau', 'select', value: 'matin', options: [HzOption('matin', 'Matin (8 h – 12 h)'), HzOption('aprem', 'Après-midi (13 h – 17 h)')]),
          HzField('priorite', 'Priorité', 'radio', value: 'normale', options: [HzOption('basse', 'Basse'), HzOption('normale', 'Normale'), HzOption('urgente', 'Urgente')]),
          HzField('equipements', 'Équipements', 'chips', value: ['balise'], options: [HzOption('balise', 'Balise GPS'), HzOption('camera', 'Caméra'), HzOption('sonde', 'Sonde carburant'), HzOption('immob', 'Anti-démarrage')]),
          HzField('duree', 'Durée estimée', 'slider', min: 30, max: 240, step: 15, value: 90.0, unit: ' min'),
          HzField('notes', 'Précisions', 'textarea', wide: true, placeholder: 'Accès au site, contact sur place…'),
          HzField('sms', 'Prévenir le client par SMS', 'toggle', value: true, wide: true),
        ],
      });

  static HzW feedbackForm() => HzW('form', title: 'Votre avis sur l’intervention', icon: Icons.reviews, p: {
        'formId': 'feedback',
        'submitLabel': 'Envoyer',
        'fields': const [
          HzField('note', 'Satisfaction globale', 'rating', value: 4.0, wide: true),
          HzField('ponctuel', 'Le technicien était ponctuel', 'checkbox', value: true, wide: true),
          HzField('commentaire', 'Commentaire', 'textarea', wide: true),
        ],
      });

  static HzW planningCalendar() {
    const list = [
      (0, 9, 'Installation · Bolloré', KitTone.primary), (0, 14, 'Dépannage · SOTRA', KitTone.warning), (1, 10, 'Audit · Cargill', KitTone.info),
      (3, 8, 'Retrait · Orange CI', KitTone.neutral), (5, 11, 'Formation chauffeurs', KitTone.purple), (7, 9, 'Installation · Yao', KitTone.primary),
      (9, 15, 'Recette port', KitTone.success), (-2, 10, 'Dépannage · CIE', KitTone.error), (12, 9, 'Installation · SIFCA', KitTone.primary),
    ];
    return HzW('calendar', title: 'Interventions du mois', subtitle: '9 rendez-vous planifiés', icon: Icons.calendar_month, p: {
      'items': [for (final (i, (d, h, t, tone)) in list.indexed) PlanningItem(id: 'cal$i', title: t, start: _day(d, h), end: _day(d, h + 2), tone: tone)],
    });
  }

  static HzW tasksKanban() => HzW('kanban', title: 'Suivi des tâches', subtitle: 'Équipe technique', icon: Icons.view_kanban, p: {
        'columns': const [PlanningColumn('todo', 'À faire', KitTone.info), PlanningColumn('doing', 'En cours', KitTone.warning), PlanningColumn('done', 'Terminé', KitTone.success)],
        'items': [
          PlanningItem(id: 'k1', ref: 'INT-0412', title: 'Installer balise CI-4521-AB', status: 'todo', tone: KitTone.primary, assignee: 'Awa Koné', due: _day(1)),
          PlanningItem(id: 'k2', ref: 'INT-0415', title: 'Remplacer sonde carburant', status: 'todo', tone: KitTone.warning, assignee: 'Yao Kouamé', due: _day(-1)),
          const PlanningItem(id: 'k3', ref: 'INT-0409', title: 'Dépannage caméra Actros', status: 'doing', tone: KitTone.info, assignee: 'Awa Koné', progress: 60),
          const PlanningItem(id: 'k4', ref: 'INT-0402', title: 'Retrait boîtier Kangoo', status: 'doing', tone: KitTone.neutral, assignee: 'Ibrahim Traoré', progress: 30),
          const PlanningItem(id: 'k5', ref: 'INT-0398', title: 'Audit flotte SOTRA', status: 'done', tone: KitTone.success, assignee: 'Yao Kouamé', done: true),
        ],
      });

  static HzW rolloutGantt() => HzW('gantt', title: 'Déploiement des balises', subtitle: 'Feuille de route · 3 équipes', icon: Icons.timeline, p: {
        'groups': const [PlanningGroup('a', 'Équipe Nord'), PlanningGroup('b', 'Équipe Sud', tone: KitTone.purple), PlanningGroup('c', 'Équipe Port', tone: KitTone.warning)],
        'items': [
          PlanningItem(id: 'g1', title: 'Repérage sites', group: 'a', start: _day(-3), end: _day(1), tone: KitTone.info, progress: 80),
          PlanningItem(id: 'g2', title: 'Installation lot 1', group: 'a', start: _day(2), end: _day(8), tone: KitTone.primary, progress: 0),
          PlanningItem(id: 'g3', title: 'Formation chauffeurs', group: 'b', start: _day(0), end: _day(4), tone: KitTone.purple, progress: 40),
          PlanningItem(id: 'g4', title: 'Installation lot 2', group: 'b', start: _day(5), end: _day(12), tone: KitTone.primary),
          PlanningItem(id: 'g5', title: 'Recette port', group: 'c', start: _day(-1), end: _day(6), tone: KitTone.warning, progress: 25),
        ],
      });

  static HzW incidentTimeline() => HzW('timeline', title: 'Historique de l’alerte', subtitle: 'CI-9902-NP · Isuzu D-Max', icon: Icons.history, p: {
        'items': const [
          HzTimelineItem('08:12', 'Départ du dépôt', text: 'Koumassi, atelier', tone: KitTone.neutral, icon: Icons.play_arrow),
          HzTimelineItem('09:40', 'Entrée zone aéroport', tone: KitTone.info, icon: Icons.login),
          HzTimelineItem('10:05', 'Sortie de zone autorisée', text: 'Geofence « Port-Bouët » franchie', tone: KitTone.error, icon: Icons.warning),
          HzTimelineItem('10:07', 'Alerte envoyée au superviseur', tone: KitTone.warning, icon: Icons.notifications_active),
        ],
      });

  static HzW technicians() => HzW('records', title: 'Techniciens disponibles', subtitle: 'Demain matin · Abidjan', icon: Icons.engineering, p: {
        'items': const [
          HzRecord('Awa Koné', subtitle: 'Installation & dépannage', meta: 'à 4 km', tone: KitTone.success, badge: 'Disponible', badgeTone: KitTone.success, tags: ['Balise', 'Caméra']),
          HzRecord('Yao Kouamé', subtitle: 'Sondes carburant', meta: 'à 9 km', tone: KitTone.primary, badge: '1 créneau', badgeTone: KitTone.warning, tags: ['Sonde']),
          HzRecord('Ibrahim Traoré', subtitle: 'Poids lourds', meta: 'à 15 km', tone: KitTone.purple, badge: 'Indisponible', tags: ['Actros', 'Anti-démarrage']),
        ],
      });

  static HzW whatNext() => HzW('choices', p: {
        'question': 'Que voulez-vous voir ensuite ?',
        'options': const [
          HzOption('carte', 'La flotte sur une carte', icon: Icons.map),
          HzOption('graphique', 'L’évolution du CA', icon: Icons.show_chart),
          HzOption('tableau', 'Les clients à relancer', icon: Icons.table_rows),
          HzOption('formulaire', 'Créer une intervention', icon: Icons.edit_note),
          HzOption('calendrier', 'Le planning du mois', icon: Icons.calendar_month),
          HzOption('outils', 'Autres outils…', icon: Icons.apps),
        ],
      });

  static HzW callout(KitTone tone, IconData icon, String title, String text) => HzW('callout', p: {'tone': tone, 'icon': icon, 'title': title, 'text': text});
}

// ─── Boîte à outils avancée (X) ──────────────────────────────────────
abstract final class X {
  static HzW documentsTree() => HzW('tree', title: 'Documents du dossier client', subtitle: 'Bolloré Logistics CI · cochez ce qu’il faut inclure', icon: Icons.account_tree, p: {
        'submitLabel': 'Générer le rapport avec ces pièces',
        'nodes': const [
          HzTreeNode('contrats', 'Contrats', icon: Icons.folder, children: [
            HzTreeNode('c1', 'CTR-2026-0042.pdf', icon: Icons.picture_as_pdf, meta: '1,2 Mo', badge: 'Signé', badgeTone: KitTone.success),
            HzTreeNode('c2', 'Avenant n°1.pdf', icon: Icons.picture_as_pdf, meta: '340 Ko', badge: 'En attente', badgeTone: KitTone.warning),
          ]),
          HzTreeNode('factures', 'Factures', icon: Icons.folder, children: [
            HzTreeNode('f1', 'FAC-2026-0911.pdf', icon: Icons.receipt_long, meta: '4 850 000 F', badge: 'Impayée', badgeTone: KitTone.error),
            HzTreeNode('f2', 'FAC-2026-0874.pdf', icon: Icons.receipt_long, meta: '2 100 000 F'),
            HzTreeNode('f3', 'FAC-2026-0812.pdf', icon: Icons.receipt_long, meta: '1 980 000 F'),
          ]),
          HzTreeNode('interventions', 'Interventions', icon: Icons.folder, children: [
            HzTreeNode('i1', 'Rapport INT-0409.pdf', icon: Icons.build, meta: '12/10'),
            HzTreeNode('i2', 'Photos installation', icon: Icons.folder, children: [
              HzTreeNode('p1', 'cabine.jpg', icon: Icons.image, meta: '2,4 Mo'),
              HzTreeNode('p2', 'boitier.jpg', icon: Icons.image, meta: '1,9 Mo'),
            ]),
          ]),
        ],
      });

  static HzW apiJson() => HzW('json', title: 'Réponse de l’API véhicule', subtitle: 'GET /vehicules/CI-9902-NP · 200 OK · 84 ms', icon: Icons.data_object, p: {
        'data': const {
          'immatriculation': 'CI-9902-NP',
          'modele': 'Isuzu D-Max',
          'enLigne': true,
          'vitesse': 0,
          'position': {'lat': 5.255, 'lng': -3.93, 'precision': 6},
          'alertes': [
            {'code': 'GEOFENCE_EXIT', 'niveau': 'critique', 'heure': '10:05'},
          ],
          'capteurs': {'carburant': 62, 'batterie': 12.6, 'temperatureMoteur': 88},
        },
      });

  static HzW offersCarousel() => HzW('carousel', title: 'Nos offres de suivi', subtitle: '4 formules · faites défiler', icon: Icons.view_carousel, p: {
        'slides': const [
          HzSlide('Suivi essentiel', tag: 'Le plus vendu', icon: Icons.gps_fixed, tone: KitTone.primary, text: 'Position en temps réel, historique 90 jours et alertes de zone pour les flottes légères.', stats: [('Prix', '9 900 F/mois'), ('Clients', '312')]),
          HzSlide('Poids lourds', tag: 'Transport', image: 'assets/images/camion.png', tone: KitTone.info, text: 'Sondes carburant, temps de conduite et rapports chronotachygraphe.', stats: [('Prix', '18 500 F/mois'), ('Économie', '−14 % carburant')]),
          HzSlide('Vidéo embarquée', icon: Icons.videocam, tone: KitTone.purple, text: 'Caméra double face, détection de fatigue et extraits vidéo sur incident.', stats: [('Prix', '24 000 F/mois')]),
          HzSlide('Anti-démarrage', icon: Icons.lock, tone: KitTone.error, text: 'Coupure moteur à distance et déverrouillage par badge chauffeur.', stats: [('Option', '+4 500 F/mois')]),
        ],
      });

  static HzW clientIdentity() => HzW('keyvalue', title: 'Identité', icon: Icons.badge, p: {
        'items': const [
          HzPair('Raison sociale', 'Bolloré Logistics CI', icon: Icons.business),
          HzPair('Compte', 'CLI-002', mono: true, copy: true),
          HzPair('RCCM', 'CI-ABJ-2003-B-1234', mono: true, copy: true),
          HzPair('Contact', 'Mme Aya Diallo', icon: Icons.person),
          HzPair('Téléphone', '+225 07 07 45 12 98', icon: Icons.call, copy: true),
          HzPair('Statut', 'Retard de paiement', icon: Icons.warning, tone: KitTone.error),
        ],
      });

  static HzW clientModal() => HzW('modal', title: 'Fiche client complète', icon: Icons.business, p: {
        'summary': 'Bolloré Logistics CI · 48 véhicules suivis · encours de 4 850 000 FCFA, dont une facture en retard de 47 jours.',
        'button': 'Ouvrir la fiche',
        'dialogTitle': 'Bolloré Logistics CI',
        'dialogSubtitle': 'Client depuis mars 2021 · Abidjan, Plateau',
        'blocks': [
          clientIdentity(),
          HzW('stats', p: {
            'items': const [
              HzStat('Véhicules', '48', icon: Icons.local_shipping, tone: KitTone.primary, spark: [38, 40, 41, 44, 45, 48]),
              HzStat('Encours', '4,85 M', icon: Icons.account_balance_wallet, tone: KitTone.error, delta: '+1,2 M', up: true),
              HzStat('Satisfaction', '4,6 / 5', icon: Icons.sentiment_satisfied, tone: KitTone.success),
            ],
          }),
          HzW('timeline', title: 'Derniers échanges', p: {
            'items': const [
              HzTimelineItem('12/10', 'Relance facture FAC-0911', text: 'Par e-mail, sans réponse', tone: KitTone.warning, icon: Icons.mail),
              HzTimelineItem('08/10', 'Intervention INT-0409 clôturée', tone: KitTone.success, icon: Icons.build),
              HzTimelineItem('02/10', 'Appel du responsable flotte', text: 'Demande de 6 balises supplémentaires', tone: KitTone.info, icon: Icons.call),
            ],
          }),
        ],
      });

  static HzW clientTabs() => HzW('tabs', title: 'Dossier Bolloré Logistics CI', subtitle: 'Toutes les informations, par onglet', icon: Icons.folder_shared, p: {
        'tabs': [
          ('Aperçu', Icons.dashboard, null, [
            HzW('stats', p: {
              'items': const [
                HzStat('CA annuel', '58,2 M', tone: KitTone.primary, icon: Icons.payments, spark: [3.9, 4.4, 4.1, 4.8, 5.2, 5.6, 5.1, 5.9]),
                HzStat('Véhicules', '48', tone: KitTone.success, icon: Icons.local_shipping, spark: [38, 40, 41, 44, 45, 48]),
                HzStat('Tickets ouverts', '3', tone: KitTone.warning, icon: Icons.support_agent, spark: [6, 5, 7, 4, 3, 3]),
              ],
            }),
            HzW('paragraph', p: {'text': 'Client stratégique : il représente 12 % du CA de la région d’Abidjan. Le retard de paiement est récent et lié à un changement d’interlocuteur comptable.'}),
          ]),
          ('Factures', Icons.receipt_long, '3', [
            HzW('table', p: {
              'columns': const [
                HzColumn('num', 'N°', kind: 'mono'),
                HzColumn('date', 'Date'),
                HzColumn('montant', 'Montant', kind: 'number', unit: ' F'),
                HzColumn('statut', 'Statut', kind: 'badge', tones: {'Payée': KitTone.success, 'Impayée': KitTone.error, 'Partielle': KitTone.warning}),
              ],
              'rows': const [
                {'num': 'FAC-0911', 'date': '28/08', 'montant': 4850000, 'statut': 'Impayée'},
                {'num': 'FAC-0874', 'date': '28/07', 'montant': 2100000, 'statut': 'Partielle'},
                {'num': 'FAC-0812', 'date': '28/06', 'montant': 1980000, 'statut': 'Payée'},
              ],
            }),
          ]),
          ('Contacts', Icons.contacts, null, [
            HzW('records', p: {
              'items': const [
                HzRecord('Aya Diallo', subtitle: 'Responsable flotte', meta: 'principal', tags: ['Décisionnaire']),
                HzRecord('Marc Kouadio', subtitle: 'Comptabilité fournisseurs', meta: 'nouveau', tone: KitTone.warning, badge: 'À contacter', badgeTone: KitTone.warning),
              ],
            }),
          ]),
          ('Historique', Icons.history, null, [
            HzW('timeline', p: {
              'items': const [
                HzTimelineItem('2021', 'Signature du premier contrat', tone: KitTone.success, icon: Icons.handshake),
                HzTimelineItem('2024', 'Extension à 40 véhicules', tone: KitTone.info, icon: Icons.trending_up),
                HzTimelineItem('2026', 'Passage à l’offre Poids lourds', tone: KitTone.primary, icon: Icons.local_shipping),
              ],
            }),
          ]),
        ],
      });

  static HzW faqAccordion() => HzW('accordion', title: 'Questions fréquentes', subtitle: 'Balises GPS et abonnements', icon: Icons.quiz, p: {
        'items': [
          ('Combien de temps dure une installation ?', Icons.schedule, true, [
            HzW('paragraph', p: {'text': 'Comptez 45 à 90 minutes par véhicule selon les options. Le véhicule reste immobilisé pendant toute la durée.'}),
            HzW('progress', p: {
              'items': const [HzMeter('Balise seule', 45, 90, unit: ' min', tone: KitTone.success), HzMeter('Balise + caméra', 90, 90, unit: ' min', tone: KitTone.warning)],
            }),
          ]),
          ('Que se passe-t-il en cas de perte de réseau ?', Icons.signal_cellular_off, false, [
            HzW('paragraph', p: {'text': 'La balise stocke jusqu’à 30 jours de positions et les renvoie dès que le réseau revient.'}),
          ]),
          ('Quels documents fournir ?', Icons.description, false, [
            HzW('checklist', p: {
              'items': const [('Carte grise du véhicule', true, null), ('Pièce d’identité du gérant', true, null), ('Bon de commande signé', false, null)],
            }),
          ]),
        ],
      });

  static HzW onboardingSteps() => HzW('steps', title: 'Mise en service d’un nouveau client', icon: Icons.linear_scale, p: {
        'steps': const [HzStep('Contrat signé', 'done', text: '02/10'), HzStep('Pièces reçues', 'done', text: '05/10'), HzStep('Installation', 'current', text: 'en cours'), HzStep('Formation', 'todo'), HzStep('Recette', 'todo')],
      });

  static HzW installChecklist() => HzW('checklist', title: 'Contrôles avant installation', subtitle: 'Cochez au fur et à mesure', icon: Icons.checklist, p: {
        'items': const [
          ('Véhicule disponible sur site', true, 'confirmé'),
          ('Batterie > 12,2 V', true, null),
          ('Emplacement boîtier validé avec le client', false, null),
          ('Carte SIM activée', false, 'ICCID requis'),
          ('Photos avant / après', false, null),
        ],
      });

  static HzW objectives() => HzW('progress', title: 'Objectifs du trimestre', subtitle: 'T4 2026 · au 14 octobre', icon: Icons.track_changes, p: {
        'items': const [
          HzMeter('Nouvelles installations', 142, 200),
          HzMeter('Chiffre d’affaires', 291, 320, unit: ' M', tone: KitTone.success),
          HzMeter('Taux de résolution J+1', 87, 95, unit: ' %', tone: KitTone.warning),
          HzMeter('Recouvrement', 61, 90, unit: ' %', tone: KitTone.error),
        ],
      });

  static HzW activityHeatmap() {
    final cols = [for (var i = 0; i < 12; i++) '${7 + i}h'];
    const rows = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    var seed = 11;
    double rnd() => (seed = (seed * 16807) % 2147483647) / 2147483647;
    final values = [
      for (var r = 0; r < rows.length; r++) [for (var c = 0; c < cols.length; c++) ((r > 4 ? 0.25 : 1) * (c > 1 && c < 10 ? 1 : 0.4) * (20 + rnd() * 80)).roundToDouble()],
    ];
    return HzW('heatmap', title: 'Activité des véhicules', subtitle: 'Trajets démarrés par heure · 4 dernières semaines', icon: Icons.grid_on, p: {'rows': rows, 'cols': cols, 'values': values, 'unit': ' trajets'});
  }

  static HzW usageStats() => HzW('stats', p: {
        'items': const [
          HzStat('Trajets / jour', '386', delta: '+6 %', up: true, tone: KitTone.primary, icon: Icons.route, spark: [320, 335, 341, 352, 360, 371, 386]),
          HzStat('Heure de pointe', '8 h – 9 h', tone: KitTone.info, icon: Icons.schedule, hint: 'lun. – ven.'),
          HzStat('Moteur à l’arrêt', '11 %', delta: '−3 pt', up: false, tone: KitTone.success, icon: Icons.local_gas_station, spark: [16, 15, 14, 14, 13, 12, 11]),
        ],
      });

  static const _before = '''  check(position: Position, zone: Zone): void {
    const inside = zone.contains(position);
    if (!inside) {
      this.alertes.emit({ code: 'GEOFENCE_EXIT', vehicule: position.vehicule });
    }
  }''';
  static const _after = '''  check(position: Position, zone: Zone): void {
    const inside = zone.contains(position);
    const wasInside = this.state.get(position.vehicule) ?? true;
    // On n'alerte qu'au franchissement, pas à chaque position hors zone.
    if (wasInside && !inside) {
      this.alertes.emit({ code: 'GEOFENCE_EXIT', vehicule: position.vehicule });
    }
    this.state.set(position.vehicule, inside);
  }''';

  static HzW codeDiff() => HzW('diff', title: 'Correctif proposé', subtitle: 'Alerte de zone déclenchée deux fois', icon: Icons.difference, p: {'file': 'src/app/alertes/geofence.service.ts', 'before': _before, 'after': _after});

  static HzW approvalTests() => HzW('approval', p: {
        'risk': KitTone.warning,
        'title': 'Autoriser l’exécution de cette commande ?',
        'text': 'Je dois lancer les tests du service d’alertes pour vérifier le correctif. Aucun fichier ne sera modifié.',
        'command': 'npm run test -- --include=src/app/alertes/**',
      });

  static HzW webSources() => HzW('sources', title: 'Sources consultées', subtitle: '4 résultats pertinents', icon: Icons.travel_explore, p: {
        'items': const [
          HzSource('Cadre réglementaire des données de géolocalisation', 'artci.ci', date: 'sept. 2026', snippet: 'Les données de position des véhicules professionnels sont des données personnelles dès lors qu’elles permettent d’identifier un conducteur…'),
          HzSource('Obligation de chronotachygraphe pour les poids lourds', 'transports.gouv.ci', date: 'août 2026', snippet: 'À compter de janvier 2027, tout véhicule de plus de 3,5 t affecté au transport de marchandises…'),
          HzSource('La télématique s’impose dans la logistique ouest-africaine', 'jeuneafrique.com', date: 'juil. 2026'),
          HzSource('ISO 15638 — Cadre des applications télématiques coopératives', 'iso.org'),
        ],
      });

  static HzW topicTags() => HzW('tags', title: 'Thèmes détectés', icon: Icons.sell, p: {
        'items': const [
          ('Données personnelles', 12, KitTone.error), ('Chronotachygraphe', 8, KitTone.warning), ('Poids lourds', 7, KitTone.info),
          ('Consentement', 5, KitTone.purple), ('Conservation 12 mois', 3, KitTone.primary), ('ARTCI', 3, KitTone.neutral),
        ],
      });

  static HzW reportFiles() => HzW('files', title: 'Fichiers générés', subtitle: 'Prêts à être envoyés', icon: Icons.folder, p: {
        'items': const [
          HzFile('Rapport-Bollore-T4.pdf', 'pdf', '2,8 Mo', date: 'à l’instant', by: 'Harnais'),
          HzFile('Encours-clients.xls', 'xls', '84 Ko', date: 'à l’instant', by: 'Harnais'),
          HzFile('Trajets-octobre.csv', 'csv', '1,1 Mo', date: 'à l’instant', by: 'Harnais'),
        ],
      });

  static HzW offerCards() => HzW('cards', title: 'Équipements recommandés', subtitle: 'Pour une flotte mixte de 48 véhicules', icon: Icons.grid_view, p: {
        'items': const [
          HzCard('Balise GT-06', icon: Icons.gps_fixed, text: 'GPS + GSM, batterie de secours 8 h.', price: '45 000 F', meta: 'en stock', tags: ['4G', 'IP67'], cta: 'Ajouter'),
          HzCard('Sonde carburant', icon: Icons.local_gas_station, tone: KitTone.warning, text: 'Mesure capacitive ±1 %.', price: '120 000 F', meta: '5 j', tags: ['Poids lourds'], cta: 'Ajouter'),
          HzCard('Caméra DC-2', icon: Icons.videocam, tone: KitTone.purple, text: 'Double face, détection de fatigue.', price: '185 000 F', meta: 'en stock', cta: 'Ajouter'),
          HzCard('Lecteur de badge', icon: Icons.badge, tone: KitTone.info, text: 'Identification du chauffeur.', price: '32 000 F', meta: '10 j', cta: 'Ajouter'),
        ],
      });

  static HzW plansCompare() => HzW('compare', title: 'Comparatif des formules', subtitle: 'Prix par véhicule et par mois', icon: Icons.compare, p: {
        'plans': const [('Essentiel', '9 900 F', null, false), ('Pro', '14 500 F', 'le meilleur rapport', true), ('Poids lourds', '18 500 F', null, false)],
        'features': const [
          ('Position temps réel', [true, true, true]),
          ('Historique', ['90 j', '12 mois', '24 mois']),
          ('Alertes de zone', [true, true, true]),
          ('Rapports automatiques', [false, true, true]),
          ('Sonde carburant', [false, 'option', true]),
          ('Chronotachygraphe', [false, false, true]),
          ('Support', ['e-mail', '7j/7', 'dédié']),
        ],
      });

  static HzW uploadRequest() => HzW('upload', title: 'Fichier à analyser', subtitle: 'Export de trajets, factures ou liste de véhicules', icon: Icons.upload_file, p: {
        'hint': 'CSV, Excel, PDF ou JSON · lu localement, rien n’est envoyé sur un serveur.',
      });

  static HzW weekAgenda() {
    const list = [
      (0, 8, 10, 'Installation · Bolloré', KitTone.primary), (0, 14, 16, 'Dépannage · SOTRA', KitTone.warning),
      (1, 9, 11, 'Audit · Cargill', KitTone.info), (2, 10, 12, 'Retrait · Orange CI', KitTone.neutral), (3, 13, 15, 'Formation chauffeurs', KitTone.purple),
    ];
    return HzW('agenda', title: 'Agenda de la semaine', subtitle: 'Awa Koné · technicienne', icon: Icons.today, p: {
      'items': [for (final (i, (d, h1, h2, t, tone)) in list.indexed) PlanningItem(id: 'ag$i', title: t, start: _day(d, h1), end: _day(d, h2), tone: tone)],
    });
  }

  static HzW moreTools() => HzW('choices', p: {
        'question': 'Je peux aussi :',
        'options': const [
          HzOption('arborescence', 'Explorer les documents', icon: Icons.account_tree),
          HzOption('fiche client', 'Ouvrir une fiche client', icon: Icons.badge),
          HzOption('offres', 'Présenter les offres', icon: Icons.view_carousel),
          HzOption('comparer', 'Comparer les formules', icon: Icons.compare),
          HzOption('corrige le bug', 'Corriger un bug', icon: Icons.difference),
          HzOption('importer un fichier', 'Analyser un fichier', icon: Icons.upload_file),
          HzOption('veille réglementaire', 'Faire une veille', icon: Icons.travel_explore),
          HzOption('objectifs', 'Suivre les objectifs', icon: Icons.track_changes),
        ],
      });
}

// ─── Intentions et scénarios ─────────────────────────────────────────
enum HzIntent { map, chart, table, form, calendar, agenda, kanban, gantt, overview, code, upload, detail, tree, json, carousel, compare, process, sources, activity, objectives, faq, tools, clarify }

final _rules = <(HzIntent, RegExp)>[
  (HzIntent.overview, RegExp(r'tableau de bord|dashboard|synthèse|vue d.ensemble|démo|rapport', caseSensitive: false)),
  (HzIntent.tools, RegExp(r'outils|que sais-tu faire|que peux-tu|capacités|autre chose', caseSensitive: false)),
  (HzIntent.code, RegExp(r'code|diff|correctif|patch|bug|corrige|commit|test', caseSensitive: false)),
  (HzIntent.upload, RegExp(r'importer|import |upload|téléverser|fichier à analyser|analyser un fichier|joindre', caseSensitive: false)),
  (HzIntent.detail, RegExp(r'fiche|détail|profil|modal|dossier client|onglets', caseSensitive: false)),
  (HzIntent.json, RegExp(r'json|\bapi\b|payload|données brutes|réponse brute', caseSensitive: false)),
  (HzIntent.tree, RegExp(r'arborescence|dossier|répertoire|structure|organigramme|permissions|explorer|documents', caseSensitive: false)),
  (HzIntent.compare, RegExp(r'compar|versus| vs |choisir entre|meilleure formule', caseSensitive: false)),
  (HzIntent.carousel, RegExp(r'carrousel|carousel|galerie|offres|catalogue|produits|équipements|nouveautés', caseSensitive: false)),
  (HzIntent.process, RegExp(r'étapes|processus|procédure|onboarding|checklist|contrôles|mise en service|marche à suivre', caseSensitive: false)),
  (HzIntent.sources, RegExp(r'source|web|actualité|veille|article|presse|réglementa', caseSensitive: false)),
  (HzIntent.activity, RegExp(r'activité|heatmap|chaleur|connexions|usage|fréquentation|heures', caseSensitive: false)),
  (HzIntent.objectives, RegExp(r'objectif|kpi|progression|performance|cible', caseSensitive: false)),
  (HzIntent.faq, RegExp(r'faq|questions fréquentes|aide|explique', caseSensitive: false)),
  (HzIntent.agenda, RegExp(r'agenda|semaine|journée|aujourd.hui', caseSensitive: false)),
  (HzIntent.form, RegExp(r'formulaire|demande|réserv|inscri|créer|ajout|nouveau|nouvelle|signal|ticket|devis', caseSensitive: false)),
  (HzIntent.map, RegExp(r'carte|map|localis|position|flotte|véhicule|trajet|zone|gps', caseSensitive: false)),
  (HzIntent.chart, RegExp(r'graph|chart|courbe|évolution|tendance|ventes|chiffre|ca |revenu|statist|analyse', caseSensitive: false)),
  (HzIntent.table, RegExp(r'tableau|liste|clients|export|lignes|registre|inventaire', caseSensitive: false)),
  (HzIntent.calendar, RegExp(r'calendrier|rendez|rdv|planning du mois|disponib', caseSensitive: false)),
  (HzIntent.kanban, RegExp(r'kanban|tâches|taches|backlog|colonnes|avancement', caseSensitive: false)),
  (HzIntent.gantt, RegExp(r'gantt|projet|déploiement|jalon|feuille de route|roadmap', caseSensitive: false)),
];

HzIntent detectIntent(String prompt) => _rules.where((r) => r.$2.hasMatch(prompt)).map((r) => r.$1).firstOrNull ?? HzIntent.clarify;

/// Réponse simulée : intro, blocs, conclusion et outils « utilisés ».
class HzScenario {
  const HzScenario({required this.tool, required this.intro, required this.blocks, this.outro, this.tools});
  final String tool, intro;
  final List<HzBlock> blocks;
  final String? outro;
  final List<HzTool>? tools;
}

HzScenario scenarioFor(HzIntent intent) {
  switch (intent) {
    case HzIntent.map:
      return HzScenario(
        tool: 'positions GPS · 8 véhicules',
        intro: 'Voici la position actuelle de la flotte. Un véhicule est en alerte (sortie de zone à Port-Bouët) :',
        blocks: [W.fleetMap(), W.incidentTimeline(), W.callout(KitTone.warning, Icons.warning, '1 véhicule hors zone', 'CI-9902-NP a quitté la geofence autorisée à 10:05. Le superviseur a été prévenu.')],
        outro: 'Je peux planifier une intervention sur ce véhicule si besoin.',
      );
    case HzIntent.chart:
      return HzScenario(
        tool: 'ventes 2025 – 2026',
        intro: 'Le chiffre d’affaires progresse de `+30 %` sur un an. Les trois vues ci-dessous résument la tendance :',
        blocks: [
          W.salesChart(),
          HzList(['Croissance régulière depuis mai, portée par les abonnements.', 'Abidjan concentre près des deux tiers du CA.', 'La maintenance gagne 3 points de part sur le trimestre.']),
          W.mixChart(),
          W.regionChart(),
        ],
      );
    case HzIntent.table:
      return HzScenario(tool: 'encours clients', intro: 'J’ai trouvé 8 clients avec un encours. Les deux premiers dépassent 30 jours de retard :', blocks: [W.clientsTable()], outro: 'Vous pouvez trier les colonnes et filtrer la liste directement dans le tableau.');
    case HzIntent.form:
      return HzScenario(tool: 'référentiel clients & véhicules', intro: 'Avec plaisir. Complétez ce formulaire et je planifie l’intervention avec le technicien le plus proche :', blocks: [W.interventionForm()]);
    case HzIntent.calendar:
      return HzScenario(tool: 'agenda des techniciens', intro: 'Voici le planning du mois. Les journées les plus chargées sont en début de semaine :', blocks: [W.planningCalendar()]);
    case HzIntent.kanban:
      return HzScenario(tool: 'tâches de l’équipe', intro: 'Voici l’avancement des tâches. Une tâche est en retard (sonde carburant) :', blocks: [W.tasksKanban()]);
    case HzIntent.gantt:
      return HzScenario(tool: 'feuille de route', intro: 'Voici la feuille de route du déploiement sur les deux prochaines semaines :', blocks: [W.rolloutGantt()]);
    case HzIntent.overview:
      return HzScenario(tool: 'flotte, ventes et encours', intro: 'Voici une synthèse complète de l’activité :', blocks: [W.fleetStats(), W.salesChart(), W.fleetMap(), W.clientsTable(), W.whatNext()]);
    case HzIntent.tools:
      return HzScenario(tool: 'capacités disponibles', intro: 'Je peux afficher l’information sous la forme la plus utile. Voici ce que je sais faire :', blocks: [X.moreTools()]);
    case HzIntent.code:
      return HzScenario(
        tool: 'geofence.service.ts',
        tools: [
          HzTool(HzToolKind.search, 'Recherche', 'GEOFENCE_EXIT', output: '3 occurrences'),
          HzTool(HzToolKind.read, 'Lecture', 'geofence.service.ts', output: '84 lignes'),
          HzTool(HzToolKind.edit, 'Modification', 'geofence.service.ts', output: '+5 −3'),
        ],
        intro: 'J’ai trouvé la cause : l’alerte est émise à chaque position hors zone, au lieu d’une seule fois au franchissement. Voici le correctif :',
        blocks: [X.codeDiff(), X.approvalTests()],
      );
    case HzIntent.upload:
      return HzScenario(tool: 'formats pris en charge', intro: 'Envoyez-moi le fichier : je l’analyse et je vous en fais une synthèse.', blocks: [X.uploadRequest()]);
    case HzIntent.detail:
      return HzScenario(tool: 'dossier CLI-002', intro: 'Voici le dossier du client. L’essentiel est dans les onglets, et la fiche complète s’ouvre en modale :', blocks: [X.clientTabs(), X.clientModal()]);
    case HzIntent.json:
      return HzScenario(
        tool: 'API véhicules',
        tools: [HzTool(HzToolKind.web, 'Requête', 'GET /vehicules/CI-9902-NP', output: '200 OK · 84 ms')],
        intro: 'Voici la réponse brute de l’API, dépliable champ par champ :',
        blocks: [X.apiJson()],
      );
    case HzIntent.tree:
      return HzScenario(tool: 'GED · dossier client', intro: 'Voici l’arborescence du dossier. Sélectionnez les pièces à inclure dans le rapport :', blocks: [X.documentsTree()]);
    case HzIntent.compare:
      return HzScenario(tool: 'grille tarifaire 2026', intro: 'Pour une flotte comme la vôtre, la formule Pro offre le meilleur équilibre :', blocks: [X.plansCompare(), X.offerCards()]);
    case HzIntent.carousel:
      return HzScenario(tool: 'catalogue des offres', intro: 'Voici nos offres, à faire défiler :', blocks: [X.offersCarousel(), X.offerCards()]);
    case HzIntent.process:
      return HzScenario(tool: 'procédure de mise en service', intro: 'Voici où en est la mise en service, et les contrôles restants :', blocks: [X.onboardingSteps(), X.installChecklist()]);
    case HzIntent.sources:
      return HzScenario(
        tool: 'veille réglementaire',
        tools: [HzTool(HzToolKind.web, 'Recherche web', 'réglementation géolocalisation Côte d’Ivoire', output: '18 résultats')],
        intro: 'Deux évolutions vous concernent directement : la protection des données de position et le chronotachygraphe obligatoire en 2027.',
        blocks: [X.webSources(), X.topicTags(), W.callout(KitTone.info, Icons.gavel, 'À anticiper', 'Les poids lourds de plus de 3,5 t devront être équipés d’un chronotachygraphe avant janvier 2027.')],
      );
    case HzIntent.activity:
      return HzScenario(tool: 'trajets des 4 dernières semaines', intro: 'L’activité se concentre en semaine entre 8 h et 17 h, avec un pic le matin :', blocks: [X.usageStats(), X.activityHeatmap()]);
    case HzIntent.objectives:
      return HzScenario(tool: 'objectifs T4', intro: 'Le CA est en bonne voie ; le recouvrement est l’objectif le plus à risque :', blocks: [X.objectives()]);
    case HzIntent.faq:
      return HzScenario(tool: 'base de connaissances', intro: 'Voici les réponses aux questions les plus fréquentes :', blocks: [X.faqAccordion()]);
    case HzIntent.agenda:
      return HzScenario(tool: 'agenda technicien', intro: 'Voici l’agenda de la semaine. Mercredi après-midi est encore libre :', blocks: [X.weekAgenda()]);
    case HzIntent.clarify:
      return HzScenario(tool: 'contexte', intro: 'Je peux vous répondre sous plusieurs formes. Choisissez ce qui vous serait le plus utile :', blocks: [W.whatNext()]);
  }
}

/// Suite donnée à un formulaire soumis.
HzScenario formFollowUp(String formId, Map<String, dynamic> values) {
  if (formId == 'intervention') {
    final d = values['date'];
    final date = d is DateTime ? Fmt.weekday(d) : 'à la date choisie';
    return HzScenario(
      tool: 'disponibilités techniciens',
      intro: 'C’est noté : intervention planifiée $date. Voici les techniciens disponibles, Awa Koné est la plus proche :',
      blocks: [
        W.technicians(),
        W.callout(KitTone.success, Icons.event_available, 'Intervention INT-0418 créée', values['sms'] == true ? 'Le client recevra un SMS de confirmation la veille.' : 'Aucun SMS ne sera envoyé au client.'),
        W.feedbackForm(),
      ],
      outro: 'Vous pourrez recueillir l’avis du client après l’intervention avec le formulaire ci-dessus.',
    );
  }
  return HzScenario(
    tool: 'enregistrement',
    intro: 'Merci, votre retour a bien été enregistré.',
    blocks: [W.callout(KitTone.success, Icons.check_circle, 'Avis enregistré', 'Note : ${(values['note'] as num?)?.round() ?? '—'} / 5.')],
  );
}

/// Suite donnée à une réponse interactive (choix, autorisation, fichier, sélection dans un arbre).
HzScenario answerFollowUp(String type, HzOption option) {
  if (type == 'approval') {
    return option.value == 'approve'
        ? HzScenario(
            tool: 'tests',
            tools: [HzTool(HzToolKind.bash, 'Terminal', 'npm run test -- --include=src/app/alertes/**', output: '14 tests réussis · 2,1 s')],
            intro: 'Les tests passent. Le correctif est prêt :',
            blocks: [
              HzW('steps', p: {'steps': const [HzStep('Cause identifiée', 'done'), HzStep('Correctif écrit', 'done'), HzStep('Tests', 'done', text: '14 / 14'), HzStep('Revue', 'current')]}),
              W.callout(KitTone.success, Icons.check_circle, 'Prêt à être relu', 'Les alertes de zone ne sont plus envoyées qu’une seule fois par franchissement.'),
            ],
          )
        : HzScenario(
            tool: 'alternatives',
            intro: 'D’accord, je ne lance rien. Le correctif reste en attente : vous pouvez exécuter les tests vous-même.',
            blocks: [HzCode('npm run test -- --include=src/app/alertes/**', lang: 'bash')],
          );
  }
  if (type == 'upload') {
    return HzScenario(
      tool: 'lecture du fichier',
      tools: [HzTool(HzToolKind.read, 'Lecture', option.label, output: '1 240 lignes · 9 colonnes')],
      intro: 'J’ai analysé le fichier. Voici ce qu’il contient :',
      blocks: [
        HzW('keyvalue', title: 'Fichier', p: {
          'items': [
            HzPair('Nom', option.label, icon: Icons.description),
            const HzPair('Lignes', '1 240'),
            const HzPair('Colonnes', '9'),
            const HzPair('Période', '01/09 → 30/09'),
            const HzPair('Doublons', '3', tone: KitTone.warning),
            const HzPair('Valeurs manquantes', '0,4 %'),
          ],
        }),
        HzW('tags', title: 'Colonnes détectées', p: {
          'items': const [
            ('immatriculation', null, null), ('date', null, null), ('départ', null, null), ('arrivée', null, null), ('distance_km', null, KitTone.primary),
            ('durée', null, null), ('conducteur', null, null), ('carburant_l', null, KitTone.primary), ('alerte', null, KitTone.warning),
          ],
        }),
        HzW('chart', title: 'Distance par semaine', p: {'kind': ChartKind.bar, 'unit': ' km', 'labels': const ['S36', 'S37', 'S38', 'S39'], 'series': const [ChartSeries('Distance', [11200, 12480, 11950, 13100])]}),
      ],
      outro: 'Souhaitez-vous que je corrige les 3 doublons ?',
    );
  }
  if (type == 'tree') {
    return HzScenario(tool: 'génération du rapport', intro: 'Le rapport est prêt avec les pièces sélectionnées :', blocks: [X.reportFiles(), W.callout(KitTone.success, Icons.task_alt, 'Rapport généré', option.label)]);
  }
  return scenarioFor(detectIntent(option.value));
}

// ─── Conversations initiales ─────────────────────────────────────────
HzMessage _ask(String id, String time, String text) => HzMessage(id: id, role: HzRole.user, time: time, blocks: [HzText(text)]);
HzMessage _reply(String id, String time, List<HzBlock> blocks) => HzMessage(id: id, role: HzRole.assistant, time: time, blocks: blocks);

List<HzConversation> buildConversations() => [
      HzConversation(id: 'c-demo', title: 'Démo · rapport d’activité flotte', group: 'Aujourd’hui', pinned: true, project: 'Démo', model: 'opus', messages: [
        _ask('d1', '10:02', 'Fais-moi un rapport d’activité de la flotte et des ventes, avec tout ce qui est utile.'),
        _reply('d2', '10:03', [
          HzThinking('Le rapport doit couvrir l’état de la flotte (carte, alertes), la dynamique commerciale (CA, mix, régions) et les encours. Je termine par un formulaire pour planifier l’action corrective.', duration: '4 s'),
          HzTool(HzToolKind.search, 'Recherche', 'positions GPS', output: '8 véhicules'),
          HzTool(HzToolKind.read, 'Lecture', 'ventes-T3.xlsx', output: '1 240 lignes'),
          HzText('Voici le rapport. Les indicateurs sont bons, avec un point d’attention sur un véhicule hors zone.'),
          W.fleetStats(), W.fleetMap(), W.incidentTimeline(),
          W.callout(KitTone.warning, Icons.warning, 'Point d’attention', 'CI-9902-NP est sorti de sa zone autorisée. Une intervention est recommandée.'),
          W.salesChart(), W.mixChart(), W.regionChart(), W.clientsTable(), W.tasksKanban(), W.rolloutGantt(), W.planningCalendar(),
          HzText('Pour traiter l’alerte, j’ai besoin de quelques informations :'),
          W.interventionForm(),
        ]),
      ]),
      HzConversation(id: 'c-outils', title: 'Démo · boîte à outils de l’agent', group: 'Aujourd’hui', pinned: true, project: 'Démo', model: 'opus', messages: [
        _ask('o1', '11:20', 'Montre-moi tout ce que tu peux afficher pour m’aider à décider.'),
        _reply('o2', '11:21', [
          HzThinking('Je présente chaque outil sur un cas concret : explorer, détailler, comparer, mesurer, sourcer, puis demander une validation.', duration: '3 s'),
          HzText('Voici l’ensemble des outils que je peux utiliser dans une réponse, sur des données d’exemple.'),
          HzText('**Explorer et naviguer**'),
          X.clientTabs(), X.clientModal(), X.documentsTree(), X.offersCarousel(), X.faqAccordion(),
          HzText('**Mesurer et préciser**'),
          X.usageStats(), X.objectives(), X.activityHeatmap(), X.onboardingSteps(), X.installChecklist(), X.clientIdentity(), X.plansCompare(), X.offerCards(),
          HzText('**Sourcer et inspecter**'),
          X.webSources(), X.topicTags(), X.apiJson(), X.reportFiles(), X.weekAgenda(),
          HzText('**Agir avec votre accord**'),
          X.codeDiff(), X.approvalTests(), X.uploadRequest(), X.moreTools(),
        ]),
      ]),
      HzConversation(id: 'c-sidecar', title: 'Sidecar de navigation Flutter', group: 'Aujourd’hui', project: 'UI Kit', model: 'opus', messages: [
        HzMessage(
          id: 'm1',
          role: HzRole.user,
          time: '09:12',
          attachments: const [HzAttachment('maquette-sidecar.png', 'image', '312 Ko')],
          blocks: [HzText('Combine le rail d’icônes et la sous-navigation de module en un seul Sidecar. Par défaut on ne voit que le rail ; au toucher d’une icône, une seconde colonne s’ouvre avec les sous-menus.')],
        ),
        HzMessage(id: 'm2', role: HzRole.assistant, time: '09:13', feedback: 'up', blocks: [
          HzThinking('Le rail et la sous-navigation partagent déjà les mêmes jetons (surface, rayon, couleurs actives). Le plus simple est un conteneur unique dont la largeur s’anime entre « rail seul » et « rail + panneau ».', duration: '6 s'),
          HzTool(HzToolKind.search, 'Recherche', 'components/navigation', output: '3 fichiers trouvés'),
          HzTool(HzToolKind.read, 'Lecture', 'navigation_gallery.dart', output: '308 lignes'),
          HzTool(HzToolKind.edit, 'Modification', 'navigation.dart', output: '+62 −48'),
          HzTool(HzToolKind.bash, 'Terminal', 'flutter analyze', output: 'No issues found! (ran in 2.4s)'),
          HzText('C’est fait : le Sidecar remplace les deux démos. Voici le comportement :'),
          HzList(['Par défaut, seul le rail est visible (logo, icônes, avatar).', 'Un toucher sur une icône l’active et déploie une colonne de `220 px` avec les sous-menus.', 'Re-toucher l’icône ou le chevron replie la colonne.']),
          HzText('J’ai aussi extrait la logique dans un widget autonome, prêt à être branché dans le shell :'),
          HzArtifactRef('art-sidecar'),
        ]),
        _ask('m3', '09:20', 'Parfait. Comment je l’utilise dans le shell ?'),
        _reply('m4', '09:20', [
          HzText('Placez-le dans le tiroir sur téléphone, et à gauche du contenu sur tablette :'),
          HzCode('drawer: wide ? null : Drawer(child: Sidecar(items: kDemoMenu, selected: id, onSelect: go)),\nbody: Row(children: [\n  if (wide) Sidecar(items: kDemoMenu, selected: id, onSelect: go),\n  Expanded(child: page),\n]),', lang: 'dart', file: 'app_shell.dart'),
        ]),
      ]),
      HzConversation(id: 'c-palette', title: 'Palette sombre accessible', group: 'Aujourd’hui', project: 'UI Kit', model: 'sonnet', messages: [
        _ask('p1', '08:02', 'Propose une palette sombre qui respecte le contraste AA avec notre couleur primaire teal.'),
        _reply('p2', '08:03', [HzText('Voici une base testée : chaque couleur garde un ratio d’au moins 4,5:1 sur la surface.'), HzArtifactRef('art-palette')]),
      ]),
      HzConversation(id: 'c-csv', title: 'Export CSV des factures', group: 'Hier', model: 'sonnet', messages: [
        _ask('x1', '17:40', 'Comment exporter une liste en CSV sans dépendance ?'),
        _reply('x2', '17:41', [
          HzText('Construisez les lignes à partir des données puis partagez le fichier :'),
          HzCode("final csv = [cols.join(';'), ...rows.map((r) => cols.map((c) => r[c]).join(';'))].join('\\n');", lang: 'dart'),
        ]),
      ]),
      HzConversation(id: 'c-reunion', title: 'Résumé réunion produit', group: 'Hier', model: 'haiku', messages: [
        _ask('r1', '11:05', 'Résume les décisions de la réunion produit en cinq points.'),
        _reply('r2', '11:05', [
          HzList(['Le Sidecar devient la navigation par défaut.', 'Les pages métiers sont retirées du kit.', 'Le mode sombre est prioritaire pour la v2.', 'Les démos restent 100 % statiques.', 'Revue d’accessibilité avant la fin du mois.']),
        ]),
      ]),
      HzConversation(id: 'c-migration', title: 'Migration Flutter 3.41', group: '7 derniers jours', project: 'UI Kit', model: 'opus', messages: [
        _ask('g1', 'Lun.', 'Quelles sont les étapes pour migrer le kit vers la dernière version de Flutter ?'),
        _reply('g2', 'Lun.', [HzText('Lancez `flutter upgrade`, puis `dart fix --apply` et vérifiez les API dépréciées signalées par `flutter analyze`.')]),
      ]),
      HzConversation(id: 'c-sql', title: 'Requêtes SQL lentes', group: '7 derniers jours', model: 'sonnet', messages: [
        _ask('s1', 'Mar.', 'Pourquoi ma requête avec un LIKE \'%abc%\' est-elle lente ?'),
        _reply('s2', 'Mar.', [HzText('Un joker en tête empêche l’usage d’un index B-tree. Utilisez un index trigramme ou une recherche plein texte.')]),
      ]),
      HzConversation(id: 'c-e2e', title: 'Plan de tests e2e', group: '30 derniers jours', model: 'haiku', messages: [
        _ask('e1', '2 oct.', 'Liste les parcours critiques à couvrir en e2e.'),
        _reply('e2', '2 oct.', [HzText('Connexion, navigation dans le shell, ouverture du panneau de compte et bascule du thème.')]),
      ]),
    ];

/// Petit aléa déterministe pour varier les durées de « réflexion ».
int hzDelay(int seed, int base) => base + math.Random(seed).nextInt(base);
