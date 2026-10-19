import 'package:flutter/material.dart';

import '../theme/kit_colors.dart';
import '../widgets/planning/planning_models.dart';

/// Données des composants de planification (`data/static/planning.data.ts`).
/// Dates relatives à aujourd'hui : retards, ligne « aujourd'hui » et agenda restent parlants.
DateTime _d(int offsetDays, [int h = 0, int m = 0]) {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day + offsetDays, h, m);
}

/// Jour `dow` (0 = lundi) de la semaine courante.
DateTime _w(int dow, int h, [int m = 0]) {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day - (n.weekday - 1) + dow, h, m);
}

// ─── Interventions terrain (kanban, notes, vue groupée, calendrier) ─────────
const kInterventionColumns = [
  PlanningColumn('planifiee', 'Planifiée', KitTone.info),
  PlanningColumn('en_route', 'En route', KitTone.purple),
  PlanningColumn('sur_site', 'Sur site', KitTone.warning),
  PlanningColumn('cloturee', 'Clôturée', KitTone.success),
];

const kTechniciens = [
  PlanningGroup('kouame', 'Kouamé Aya', subtitle: 'Abidjan Sud', tone: KitTone.primary),
  PlanningGroup('traore', 'Traoré Ibrahim', subtitle: 'Abidjan Nord', tone: KitTone.info),
  PlanningGroup('yao', 'Yao Serge', subtitle: 'Bouaké', tone: KitTone.purple),
];

const _typeTone = {
  'installation': KitTone.primary,
  'maintenance': KitTone.info,
  'diagnostic': KitTone.warning,
  'desinstallation': KitTone.neutral,
};
const kTypeLabel = {
  'installation': 'Installation',
  'maintenance': 'Maintenance',
  'diagnostic': 'Diagnostic',
  'desinstallation': 'Désinstallation',
};

PlanningItem _inter(int n, String title, String type, String status, String tech, int due, {String? description, List<String> tags = const []}) {
  final g = kTechniciens.firstWhere((t) => t.key == tech);
  return PlanningItem(
    id: 'int-$n',
    ref: 'INT-${(400 + n).toString().padLeft(4, '0')}',
    title: title,
    description: description,
    status: status,
    group: tech,
    assignee: g.label,
    due: _d(due, 17),
    start: _d(due, 8 + n % 8),
    done: status == 'cloturee',
    progress: switch (status) { 'cloturee' => 100, 'sur_site' => 60, 'en_route' => 20, _ => 0 },
    tone: _typeTone[type],
    badge: kTypeLabel[type],
    badgeTone: _typeTone[type],
    tags: tags,
    fields: {'type': type, 'zone': g.subtitle!},
  );
}

List<PlanningItem> buildInterventions() => [
      _inter(1, 'Pose balise — Transports Yao (CI-4521-AB)', 'installation', 'planifiee', 'kouame', 1, description: 'Pose d’une balise FMB920 avec coupure moteur. Prévoir relais 12 V.'),
      _inter(2, 'Balise hors ligne — SOTRA bus 112', 'diagnostic', 'planifiee', 'traore', -2, description: 'Aucune position depuis 48 h. Vérifier alimentation et carte SIM.', tags: ['Urgent']),
      _inter(3, 'Maintenance capteur carburant', 'maintenance', 'en_route', 'yao', 0, description: 'Recalibrage de la sonde après remplacement du réservoir.'),
      _inter(4, 'Installation flotte — 6 véhicules Lôh Logistique', 'installation', 'sur_site', 'kouame', 0, description: 'Lot de 6 balises + boutons SOS.'),
      _inter(5, 'Retrait balise — fin de contrat CFAO', 'desinstallation', 'planifiee', 'traore', 3),
      _inter(6, 'Remplacement antenne GPS', 'maintenance', 'cloturee', 'yao', -3),
      _inter(7, 'Diagnostic coupure intermittente', 'diagnostic', 'sur_site', 'traore', -1, description: 'Coupures aléatoires signalées par le client depuis lundi.'),
      _inter(8, 'Pose caméra embarquée — Bolloré', 'installation', 'planifiee', 'yao', 5),
      _inter(9, 'Contrôle annuel — flotte Ivoire Express', 'maintenance', 'cloturee', 'kouame', -5),
      _inter(10, 'Mise à jour firmware (12 balises)', 'maintenance', 'en_route', 'kouame', 2),
      _inter(11, 'Installation boîtier température — Agro CI', 'installation', 'planifiee', 'traore', 8),
      _inter(12, 'Retrait équipement accidenté', 'desinstallation', 'cloturee', 'yao', -7),
    ];

final kInterventionFilters = [
  PlanningFilter(key: 'type', label: 'Type', allLabel: 'Tous les types', options: [for (final e in kTypeLabel.entries) FilterOption(e.key, e.value)]),
  const PlanningFilter(key: 'zone', label: 'Zone', allLabel: 'Toutes les zones', options: [
    FilterOption('Abidjan Sud', 'Abidjan Sud'), FilterOption('Abidjan Nord', 'Abidjan Nord'), FilterOption('Bouaké', 'Bouaké'),
  ]),
  PlanningFilter(key: 'group', label: 'Technicien', allLabel: 'Tous', options: [for (final t in kTechniciens) FilterOption(t.key, t.label)]),
];

// ─── Réservations de véhicules de service (gantt) ───────────────────────────
const kVehicules = [
  PlanningGroup('v1', 'Toyota Hilux', subtitle: 'CI-1024-AB', icon: Icons.local_shipping, tone: KitTone.primary),
  PlanningGroup('v2', 'Renault Kangoo', subtitle: 'CI-2210-CD', icon: Icons.airport_shuttle, tone: KitTone.info),
  PlanningGroup('v3', 'Suzuki Swift', subtitle: 'CI-3307-EF', icon: Icons.directions_car, tone: KitTone.purple),
  PlanningGroup('v4', 'Yamaha Crux', subtitle: 'CI-0418-GH', icon: Icons.two_wheeler, tone: KitTone.cyan),
];

List<PlanningItem> buildReservations() => [
      PlanningItem(id: 'r1', ref: 'RSV-101', title: 'Tournée Abidjan Sud', group: 'v1', start: _d(-6), end: _d(-2), done: true, assignee: 'Kouamé Aya', tone: KitTone.success, fields: const {'motif': 'tournee'}),
      PlanningItem(id: 'r2', ref: 'RSV-102', title: 'Déploiement Lôh Logistique', group: 'v1', start: _d(-1), end: _d(3), due: _d(2), progress: 55, assignee: 'Kouamé Aya', tone: KitTone.primary, fields: const {'motif': 'installation'}),
      PlanningItem(id: 'r3', ref: 'RSV-103', title: 'Mission Bouaké', group: 'v2', start: _d(-4), end: _d(-1), due: _d(-2), progress: 80, assignee: 'Yao Serge', tone: KitTone.warning, fields: const {'motif': 'mission'}),
      PlanningItem(id: 'r4', ref: 'RSV-104', title: 'Livraison matériel Yamoussoukro', group: 'v2', start: _d(2), end: _d(4), assignee: 'Traoré Ibrahim', tone: KitTone.info, fields: const {'motif': 'livraison'}),
      PlanningItem(id: 'r5', ref: 'RSV-105', title: 'Visite client CFAO', group: 'v3', start: _d(0), end: _d(0), assignee: 'Traoré Ibrahim', tone: KitTone.purple, fields: const {'motif': 'visite'}),
      PlanningItem(id: 'r6', ref: 'RSV-106', title: 'Révision garage', group: 'v3', start: _d(5), end: _d(7), tone: KitTone.neutral, fields: const {'motif': 'entretien'}),
      PlanningItem(id: 'r7', ref: 'RSV-107', title: 'Courses urgentes', group: 'v4', start: _d(-3), end: _d(1), assignee: 'Coulibaly Awa', tone: KitTone.error, fields: const {'motif': 'mission'}),
      PlanningItem(id: 'r8', ref: 'RSV-108', title: 'Relevés compteurs', group: 'v4', start: _d(1), end: _d(2), assignee: 'Coulibaly Awa', tone: KitTone.info, fields: const {'motif': 'tournee'}),
      PlanningItem(id: 'r9', ref: 'RSV-109', title: 'Formation conduite', group: 'v1', start: _d(6), end: _d(9), tone: KitTone.purple, fields: const {'motif': 'formation'}),
    ];

const kMotifFilter = PlanningFilter(key: 'motif', label: 'Motif', allLabel: 'Tous les motifs', options: [
  FilterOption('tournee', 'Tournée'), FilterOption('installation', 'Installation'), FilterOption('mission', 'Mission'),
  FilterOption('livraison', 'Livraison'), FilterOption('visite', 'Visite'), FilterOption('entretien', 'Entretien'),
  FilterOption('formation', 'Formation'),
]);

// ─── Projet de déploiement sans groupes ─────────────────────────────────────
List<PlanningItem> buildPhases() => [
      PlanningItem(id: 'p1', ref: 'P1', title: 'Cadrage & devis', start: _d(-12), end: _d(-8), done: true, tone: KitTone.success),
      PlanningItem(id: 'p2', ref: 'P2', title: 'Commande des balises', start: _d(-8), end: _d(-3), due: _d(-4), progress: 90, tone: KitTone.info),
      PlanningItem(id: 'p3', ref: 'P3', title: 'Installation sur la flotte', start: _d(-3), end: _d(6), progress: 40, tone: KitTone.primary),
      PlanningItem(id: 'p4', ref: 'P4', title: 'Formation des exploitants', start: _d(5), end: _d(8), tone: KitTone.purple),
      PlanningItem(id: 'p5', ref: 'P5', title: 'Recette & mise en service', start: _d(8), end: _d(11), tone: KitTone.warning),
    ];

// ─── Rendez-vous (agenda) ───────────────────────────────────────────────────
List<PlanningItem> buildRendezVous() => [
      PlanningItem(id: 'a1', title: 'Point hebdo exploitation', start: _w(0, 9), end: _w(0, 10), tone: KitTone.primary, assignee: 'Équipe ops', fields: const {'kind': 'reunion'}),
      PlanningItem(id: 'a2', title: 'Démo plateforme — Agro CI', start: _w(0, 11), end: _w(0, 12, 30), tone: KitTone.purple, fields: const {'kind': 'client'}),
      PlanningItem(id: 'a3', title: 'Installation CI-4521-AB', start: _w(1, 8, 30), end: _w(1, 11), tone: KitTone.info, assignee: 'Kouamé Aya', fields: const {'kind': 'terrain'}),
      PlanningItem(id: 'a4', title: 'Appel fournisseur Teltonika', start: _w(1, 10), end: _w(1, 10, 45), tone: KitTone.warning, fields: const {'kind': 'reunion'}),
      PlanningItem(id: 'a5', title: 'Diagnostic SOTRA bus 112', start: _w(2, 14), end: _w(2, 16), tone: KitTone.error, assignee: 'Traoré Ibrahim', fields: const {'kind': 'terrain'}),
      PlanningItem(id: 'a6', title: 'Revue des impayés', start: _w(2, 15), end: _w(2, 16, 30), tone: KitTone.neutral, fields: const {'kind': 'reunion'}),
      PlanningItem(id: 'a7', title: 'Formation nouveaux techniciens', start: _w(3, 9), end: _w(3, 12), tone: KitTone.success, fields: const {'kind': 'formation'}),
      PlanningItem(id: 'a8', title: 'Visite Bolloré — caméras', start: _w(3, 14, 30), end: _w(3, 15, 30), tone: KitTone.purple, fields: const {'kind': 'client'}),
      PlanningItem(id: 'a9', title: 'Inventaire du stock', start: _w(4, 0), tone: KitTone.info, fields: const {'kind': 'interne'}),
      PlanningItem(id: 'a10', title: 'Clôture mensuelle', start: _w(4, 16), end: _w(4, 18), tone: KitTone.primary, fields: const {'kind': 'reunion'}),
      PlanningItem(id: 'a11', title: 'Astreinte week-end', start: _w(5, 0), tone: KitTone.warning, fields: const {'kind': 'interne'}),
      PlanningItem(id: 'a12', title: 'Point flotte Lôh Logistique', start: _w(1, 15), end: _w(1, 16), tone: KitTone.info, fields: const {'kind': 'client'}),
    ];

const kRdvKindFilter = PlanningFilter(key: 'kind', label: 'Catégorie', allLabel: 'Toutes', options: [
  FilterOption('reunion', 'Réunion'), FilterOption('client', 'Client'), FilterOption('terrain', 'Terrain'),
  FilterOption('formation', 'Formation'), FilterOption('interne', 'Interne'),
]);
