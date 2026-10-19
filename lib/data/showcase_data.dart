import 'package:flutter/material.dart';

import '../theme/kit_colors.dart';

/// Jeux de données génériques de la galerie de composants (`data/static/showcase.data.ts`).
/// Déterministes (aucun aléatoire) : rendu identique à chaque lancement.

enum ClientStatut { actif, inactif, suspendu, resilie }

extension ClientStatutX on ClientStatut {
  String get label => switch (this) {
        ClientStatut.actif => 'Actif',
        ClientStatut.inactif => 'Inactif',
        ClientStatut.suspendu => 'Suspendu',
        ClientStatut.resilie => 'Résilié',
      };

  /// `STATUT_COLOR`
  KitTone get tone => switch (this) {
        ClientStatut.actif => KitTone.success,
        ClientStatut.inactif => KitTone.neutral,
        ClientStatut.suspendu => KitTone.warning,
        ClientStatut.resilie => KitTone.error,
      };
}

class DemoClient {
  const DemoClient({
    required this.id,
    required this.code,
    required this.raisonSociale,
    required this.contact,
    required this.email,
    required this.telephone,
    required this.ville,
    required this.secteur,
    required this.vehicules,
    required this.caMensuel,
    required this.statut,
    required this.createdAt,
  });

  final String id, code, raisonSociale, contact, email, telephone, ville, secteur;
  final int vehicules, caMensuel;
  final ClientStatut statut;
  final DateTime createdAt;
}

const kRaisons = [
  'Transports Yao & Fils', 'Bolloré Logistics CI', 'SOTRA Abidjan', 'Kouamé BTP', 'Ivoire Express Livraison',
  'CFAO Motors CI', 'Groupe Diallo Négoce', 'SIFCA Logistique', 'Coulibaly Frères Transit', 'Aka Mobilité',
  'Sahel Cargo', 'Bamba Distribution', 'Ouattara Services', 'San-Pédro Shipping', 'Yamoussoukro Taxi Pool',
  'Bouaké Agro Transport', 'Gbaka Line', 'Atlantique Fret', 'Konan Location Auto', 'Treichville Moto Pro',
  'Cocody Premium Cars', 'Plateau VTC', 'Daloa Céréales', 'Korhogo Coton Logistique', 'Man Minerais',
  'Assinie Tourisme', 'Grand-Bassam Bus', 'Yopougon Livraison', 'Abobo Transports', 'Marcory Auto-École',
  'Port-Bouët Conteneurs', 'Bingerville Agrumes', 'Anyama Kola Export', 'Divo Cacao Trans', 'Gagnoa Bois',
  'Soubré Palmeraie', 'Odienné Bétail', 'Bondoukou Négoce', 'Abengourou Hévéa', 'Agboville Maraîchers',
];
const kContacts = [
  'Jean Kouassi', 'Marie Yao', 'Aminata Diallo', 'Koffi N’Guessan', 'Fatou Bamba', 'Serge Kouamé', 'Awa Coulibaly',
  'Patrick Aka', 'Mariam Ouattara', 'Eric Konan', 'Christelle Tanoh', 'Ibrahim Traoré', 'Nadège Gnagne', 'Yves Brou',
  'Alimata Koné', 'Didier Assi', 'Sandrine Ehui', 'Moussa Sanogo', 'Brigitte Adjoua', 'Hervé Kacou',
];
const kVilles = ['Abidjan', 'Yamoussoukro', 'Bouaké', 'San-Pédro', 'Daloa', 'Korhogo', 'Man', 'Gagnoa'];
const kSecteurs = ['Transport', 'Logistique', 'BTP', 'Distribution', 'Agro-industrie', 'Location', 'Tourisme'];
const _statuts = [
  ClientStatut.actif, ClientStatut.actif, ClientStatut.actif, ClientStatut.suspendu,
  ClientStatut.actif, ClientStatut.inactif, ClientStatut.actif, ClientStatut.resilie,
];

String _slug(String s) {
  const from = 'àâäéèêëîïôöùûüçœ’';
  const to = 'aaaeeeeiioouuucoe';
  final buf = StringBuffer();
  for (final ch in s.toLowerCase().split('')) {
    final i = from.indexOf(ch);
    buf.write(i >= 0 ? to[i] : ch);
  }
  return buf.toString().replaceAll(RegExp(r'[^a-z0-9]+'), '.').replaceAll(RegExp(r'^\.|\.$'), '');
}

String _p2(int n) => n.toString().padLeft(2, '0');

final List<DemoClient> kDemoClients = List.generate(kRaisons.length, (i) {
  final raison = kRaisons[i];
  final contact = kContacts[i % kContacts.length];
  return DemoClient(
    id: 'cli-${(i + 1).toString().padLeft(3, '0')}',
    code: 'CLI-${1040 + i * 3}',
    raisonSociale: raison,
    contact: contact,
    email: '${_slug(contact)}@${_slug(raison).split('.').first}.ci',
    telephone: '+225 07 ${_p2(10 + (i * 13) % 89)} ${_p2(20 + (i * 17) % 79)} ${_p2(30 + (i * 7) % 69)}',
    ville: kVilles[i % kVilles.length],
    secteur: kSecteurs[i % kSecteurs.length],
    vehicules: 2 + (i * 11) % 47,
    caMensuel: 150000 + (i * 137500) % 4850000,
    statut: _statuts[i % _statuts.length],
    createdAt: DateTime(2024 + i % 3, (i * 5) % 12 + 1, (i * 7) % 28 + 1),
  );
});

const kMois = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
const kCa2026 = [38.2, 41.5, 39.8, 44.1, 47.6, 46.2, 49.9, 52.4, 51.1, 55.8, 0.0, 0.0];
const kCa2025 = [31.4, 33.0, 34.8, 35.2, 37.9, 38.4, 40.1, 41.7, 42.2, 44.0, 45.3, 47.9];

class TimelineEvent {
  const TimelineEvent(this.date, this.icon, this.tone, this.titre, this.texte);
  final DateTime date;
  final IconData icon;
  final KitTone tone;
  final String titre, texte;
}

final kTimelineEvents = [
  TimelineEvent(DateTime(2026, 10, 13, 9, 12), Icons.add_circle, KitTone.primary, 'Requête créée', 'REQ-2026-0412 « Balise hors ligne » ouverte par Marie Yao.'),
  TimelineEvent(DateTime(2026, 10, 13, 10, 5), Icons.assignment_ind, KitTone.info, 'Affectée', 'Assignée à Koffi N’Guessan (équipe technique Abidjan Sud).'),
  TimelineEvent(DateTime(2026, 10, 13, 14, 40), Icons.engineering, KitTone.warning, 'Intervention planifiée', 'Passage sur site prévu le 14/10 à 08:30 — Zone 4, Marcory.'),
  TimelineEvent(DateTime(2026, 10, 14, 9, 55), Icons.check_circle, KitTone.success, 'Résolue', 'Antenne GPS remplacée, balise de nouveau en ligne.'),
  TimelineEvent(DateTime(2026, 10, 14, 11, 20), Icons.lock, KitTone.neutral, 'Clôturée', 'Clôture validée par le client (satisfaction 5/5).'),
];

/// Arborescence générique (tree, tree-select, material tree).
class TreeNodeData {
  const TreeNodeData(this.id, this.label, {this.icon, this.meta, this.children = const []});
  final String id, label;
  final IconData? icon;
  final String? meta;
  final List<TreeNodeData> children;
  bool get isLeaf => children.isEmpty;

  Iterable<TreeNodeData> get leaves sync* {
    if (isLeaf) {
      yield this;
    } else {
      for (final c in children) {
        yield* c.leaves;
      }
    }
  }
}

const kZonesTree = [
  TreeNodeData('abj', 'Abidjan', icon: Icons.location_city, children: [
    TreeNodeData('abj-n', 'Abidjan Nord', children: [
      TreeNodeData('abobo', 'Abobo'), TreeNodeData('yop', 'Yopougon'), TreeNodeData('adj', 'Adjamé'),
    ]),
    TreeNodeData('abj-s', 'Abidjan Sud', children: [
      TreeNodeData('marc', 'Marcory'), TreeNodeData('treich', 'Treichville'), TreeNodeData('kouma', 'Koumassi'), TreeNodeData('pb', 'Port-Bouët'),
    ]),
    TreeNodeData('coco', 'Cocody', children: [TreeNodeData('riv', 'Riviera'), TreeNodeData('ang', 'Angré')]),
  ]),
  TreeNodeData('centre', 'Centre', icon: Icons.landscape, children: [
    TreeNodeData('yakro', 'Yamoussoukro'), TreeNodeData('bke', 'Bouaké'),
  ]),
  TreeNodeData('ouest', 'Ouest', icon: Icons.forest, children: [
    TreeNodeData('sp', 'San-Pédro'), TreeNodeData('man', 'Man'), TreeNodeData('daloa', 'Daloa'),
  ]),
];

const kFilesTree = [
  TreeNodeData('src', 'src', icon: Icons.folder, children: [
    TreeNodeData('app', 'app', icon: Icons.folder, children: [
      TreeNodeData('core', 'core', icon: Icons.folder, children: [
        TreeNodeData('theme', 'theme_controller.dart', icon: Icons.code, meta: '2 Ko'),
      ]),
      TreeNodeData('shared', 'shared', icon: Icons.folder, children: [
        TreeNodeData('badge', 'status_badge.dart', icon: Icons.code, meta: '1 Ko'),
        TreeNodeData('empty', 'empty_state.dart', icon: Icons.code, meta: '2 Ko'),
      ]),
      TreeNodeData('main', 'main.dart', icon: Icons.code, meta: '1 Ko'),
    ]),
    TreeNodeData('assets', 'assets', icon: Icons.folder, children: [
      TreeNodeData('logo', 'logo.png', icon: Icons.image, meta: '24 Ko'),
      TreeNodeData('bg', 'bg.jpg', icon: Icons.image, meta: '310 Ko'),
    ]),
  ]),
  TreeNodeData('readme', 'README.md', icon: Icons.description, meta: '3 Ko'),
  TreeNodeData('pubspec', 'pubspec.yaml', icon: Icons.settings, meta: '2 Ko'),
];

/// Notifications (centre de notifications, panneau du shell).
class DemoNotification {
  const DemoNotification(this.icon, this.tone, this.title, this.text, this.minutesAgo, {this.read = false, this.category = 'Système'});
  final IconData icon;
  final KitTone tone;
  final String title, text, category;
  final int minutesAgo;
  final bool read;
}

const kNotifications = [
  DemoNotification(Icons.warning_amber, KitTone.error, 'Sortie de zone', 'CI-9902-NP a quitté la geofence « Port-Bouët ».', 4, category: 'Alertes'),
  DemoNotification(Icons.payments, KitTone.success, 'Paiement reçu', 'Bolloré Logistics CI a réglé FAC-2026-0874 (2 100 000 FCFA).', 22, category: 'Finance'),
  DemoNotification(Icons.engineering, KitTone.info, 'Intervention planifiée', 'INT-0412 confiée à Kouamé Aya pour demain 08:30.', 75, category: 'Terrain'),
  DemoNotification(Icons.sim_card, KitTone.warning, 'Forfait SIM bientôt épuisé', '12 cartes SIM sous 10 % de data restante.', 180, read: true, category: 'Système'),
  DemoNotification(Icons.person_add, KitTone.primary, 'Nouveau client', 'Lôh Logistique a signé un contrat de 6 véhicules.', 1440, read: true, category: 'Commercial'),
];
