// Miroir Dart des jeux de données Angular des écrans d'exemple (lecture seule) :
// - `src/app/data/static/session.data.ts`
// - `src/app/data/static/examples.data.ts`
// - `src/app/data/static/content.data.ts`
// - données déclarées dans les composants `examples/app/*` (tableau de bord, kanban,
//   supervision, messagerie, fichiers, fil, paramètres).
// Mêmes noms, montants, textes et statuts que la référence Angular ; montants en FCFA.

import 'package:flutter/material.dart';

import '../theme/kit_colors.dart';

// ─── session.data.ts ────────────────────────────────────────────────────────

class StaticUser {
  const StaticUser({required this.id, required this.fullname, required this.nom, required this.prenoms, required this.mail, required this.phone, required this.role, this.actif = true});
  final String id, fullname, nom, prenoms, mail, phone, role;
  final bool actif;
}

const kCurrentUser = StaticUser(id: 'u-001', fullname: 'Jean Kouassi', nom: 'Kouassi', prenoms: 'Jean', mail: 'jean.kouassi@example.com', phone: '+225 07 07 12 34 56', role: 'Administrateur');

const kOrganisation = (id: 'org-001', nom: 'SC Storage', sigle: 'SCS', ville: 'Abidjan', pays: 'Côte d\'Ivoire');

class StaticNotification {
  const StaticNotification(this.id, this.type, this.objet, this.contenu, this.lu, this.envoyeLe);
  final String id, type, objet, contenu, envoyeLe;
  final bool lu;
}

const kNotificationsSession = [
  StaticNotification('n-1', 'Requête', 'Nouvelle requête client', 'Transports Yao SARL a ouvert une requête « Balise hors ligne » (REQ-2024-0412).', false, '2026-10-13T08:42:00'),
  StaticNotification('n-2', 'Mission', 'Mission terminée', 'La mission MIS-0098 (installation 4 véhicules) a été clôturée par Koffi N’Guessan.', false, '2026-10-13T07:15:00'),
  StaticNotification('n-3', 'Facturation', 'Rôle de facturation généré', 'Le rôle d’octobre 2026 a été généré : 312 factures pour 48 750 000 FCFA.', false, '2026-10-12T18:05:00'),
  StaticNotification('n-4', 'Tâche', 'Tâche en retard', '« Relancer Bolloré Logistics pour le renouvellement » est en retard de 2 jours.', true, '2026-10-11T09:30:00'),
  StaticNotification('n-5', 'Synchronisation', 'Synchronisation terminée', 'La synchronisation Wialon a importé 1 284 équipements (3 anomalies).', true, '2026-10-10T22:10:00'),
];

const kTodayTasksCount = 7;

// ─── examples.data.ts ───────────────────────────────────────────────────────

enum ClientStatus { actif, prospect, suspendu, inactif }

extension ClientStatusX on ClientStatus {
  /// `CLIENT_STATUS`
  String get label => switch (this) { ClientStatus.actif => 'Actif', ClientStatus.prospect => 'Prospect', ClientStatus.suspendu => 'Suspendu', ClientStatus.inactif => 'Inactif' };
  KitTone get tone => switch (this) { ClientStatus.actif => KitTone.success, ClientStatus.prospect => KitTone.info, ClientStatus.suspendu => KitTone.warning, ClientStatus.inactif => KitTone.neutral };
}

class ExClient {
  const ExClient({required this.id, required this.name, required this.contact, required this.email, required this.phone, required this.city, required this.sector, required this.status, required this.revenue, required this.invoices, required this.since, required this.owner});
  final String id, name, contact, email, phone, city, sector, owner;
  final ClientStatus status;
  final int revenue, invoices;
  final DateTime since;
}

const _names = [
  ['Sotra Logistique', 'Aya Koné', 'Transport'], ['Ivoire Agro SA', 'Moussa Traoré', 'Agro-industrie'], ['Banque Lagune', 'Fatou Diabaté', 'Finance'],
  ['Cacao Plus', 'Yao N’Guessan', 'Agro-industrie'], ['Clinique Riviera', 'Dr Awa Bamba', 'Santé'], ['Batim CI', 'Koffi Assi', 'BTP'],
  ['Orca Télécom', 'Mariam Ouattara', 'Télécoms'], ['Hôtel Assinie', 'Serge Kacou', 'Hôtellerie'], ['Pharma Sud', 'Inès Coulibaly', 'Santé'],
  ['Energie Nord', 'Ibrahim Sanogo', 'Énergie'], ['Café Akwaba', 'Rose Adjoua', 'Restauration'], ['Mines de Tongon', 'Alain Gnamien', 'Mines'],
  ['École Les Palmiers', 'Nadia Touré', 'Éducation'], ['AutoPro Yopougon', 'Didier Zadi', 'Automobile'], ['Textile Bouaké', 'Salif Konaté', 'Industrie'],
  ['Port Sec San Pedro', 'Linda Ehui', 'Transport'], ['Studio Lagune', 'Eric Brou', 'Médias'], ['Agence Kôrô', 'Mireille Yapi', 'Services'],
  ['FreshMarket', 'Hervé Tanoh', 'Distribution'], ['Assur’Ivoire', 'Kadi Fofana', 'Assurance'], ['Cimenterie Est', 'Paul Amani', 'Industrie'],
  ['Digital Baobab', 'Grace Kouamé', 'Numérique'], ['Radio Plateau', 'Jules Ahoua', 'Médias'], ['Ferme Bio Dabou', 'Clarisse Djè', 'Agro-industrie'],
];
const _cities = ['Abidjan', 'Bouaké', 'San Pedro', 'Yamoussoukro', 'Korhogo', 'Daloa', 'Man', 'Grand-Bassam'];
const _statuses = [ClientStatus.actif, ClientStatus.actif, ClientStatus.prospect, ClientStatus.actif, ClientStatus.suspendu, ClientStatus.actif, ClientStatus.inactif, ClientStatus.prospect];
const kOwners = ['Jean Kouassi', 'Aïcha Diallo', 'Marc Yao', 'Sarah Bamba'];

/// Équivalent de `normalize('NFD').replace(/[^a-z…]/g, '')` : retire les accents.
String _fold(String s) {
  const from = 'àâäáãåçéèêëíìîïñóòôöõúùûüýÿœ';
  const to = 'aaaaaaceeeeiiiinooooouuuuyyo';
  final b = StringBuffer();
  for (final ch in s.split('')) {
    final i = from.indexOf(ch);
    b.write(i >= 0 ? to[i] : ch);
  }
  return b.toString();
}

String _pad2(int n) => n.toString().padLeft(2, '0');

/// `EX_CLIENTS` — même formule de génération que la version Angular.
final List<ExClient> kExClients = [
  for (var i = 0; i < _names.length; i++)
    ExClient(
      id: 'c-${101 + i}',
      name: _names[i][0],
      contact: _names[i][1],
      sector: _names[i][2],
      email: '${_fold(_names[i][1].toLowerCase()).replaceAll(RegExp(r'[^a-z ]'), '').trim().replaceAll(RegExp(r'\s+'), '.')}@'
          '${(() { final n = _fold(_names[i][0].toLowerCase()).replaceAll(RegExp(r'[^a-z]'), ''); return n.length > 12 ? n.substring(0, 12) : n; })()}.ci',
      phone: '+225 07 ${_pad2(10 + ((i * 37) % 89))} ${_pad2(10 + ((i * 53) % 89))} ${_pad2(10 + ((i * 71) % 89))}',
      city: _cities[i % _cities.length],
      status: _statuses[i % _statuses.length],
      revenue: (((i * 7919) % 97) + 8) * 1250000,
      invoices: ((i * 13) % 40) + 2,
      since: DateTime(2019 + (i % 7), ((i * 5) % 12) + 1, 1 + ((i * 11) % 27)),
      owner: kOwners[i % kOwners.length],
    ),
];

ExClient exClientById(String id) => kExClients.firstWhere((c) => c.id == id, orElse: () => kExClients.first);

class ExActivity {
  const ExActivity(this.icon, this.tone, this.text, this.at, this.who);
  final IconData icon;
  final KitTone tone;
  final String text, at, who;
}

const kExActivity = [
  ExActivity(Icons.receipt_long, KitTone.primary, 'Facture FAC-2026-0412 émise · 4 250 000 FCFA', 'Il y a 12 min', 'Jean Kouassi'),
  ExActivity(Icons.payments, KitTone.success, 'Paiement reçu de Banque Lagune', 'Il y a 1 h', 'Système'),
  ExActivity(Icons.person_add, KitTone.info, 'Nouveau prospect : Digital Baobab', 'Il y a 3 h', 'Aïcha Diallo'),
  ExActivity(Icons.warning, KitTone.warning, 'Relance : Clinique Riviera, 2 factures en retard', 'Hier', 'Système'),
  ExActivity(Icons.description, KitTone.purple, 'Contrat signé avec Orca Télécom', 'Hier', 'Marc Yao'),
  ExActivity(Icons.block, KitTone.error, 'Compte suspendu : Pharma Sud', 'Il y a 2 j', 'Sarah Bamba'),
];

class ExInvoice {
  const ExInvoice(this.ref, this.date, this.amount, this.status);
  final String ref, date, status;
  final int amount;
  KitTone get tone => switch (status) { 'payée' => KitTone.success, 'en retard' => KitTone.error, _ => KitTone.warning };
}

const kExInvoices = [
  ExInvoice('FAC-2026-0412', '2026-10-14', 4250000, 'en attente'),
  ExInvoice('FAC-2026-0388', '2026-09-30', 1870000, 'payée'),
  ExInvoice('FAC-2026-0351', '2026-09-02', 2400000, 'en retard'),
  ExInvoice('FAC-2026-0310', '2026-08-05', 960000, 'payée'),
  ExInvoice('FAC-2026-0277', '2026-07-11', 3150000, 'payée'),
];

class ExMessage {
  const ExMessage({required this.id, required this.from, required this.email, required this.subject, required this.preview, required this.body, required this.at, required this.unread, required this.starred, this.label, this.attachments = const []});
  final String id, from, email, subject, preview, at;
  final List<String> body;
  final bool unread, starred;
  final (String, KitTone)? label;
  final List<String> attachments;
}

const kExMessages = [
  ExMessage(id: 'm1', from: 'Aya Koné', email: 'aya.kone@sotra.ci', subject: 'Livraison du lot 14 — créneau confirmé', at: '09:24', unread: true, starred: true,
      label: ('Logistique', KitTone.info), attachments: ['bon-livraison-14.pdf'],
      preview: 'Bonjour, nous confirmons le créneau de jeudi 8h pour la livraison du lot 14…',
      body: ['Bonjour Jean,', 'Nous confirmons le créneau de jeudi 8 h pour la livraison du lot 14 au dépôt de Vridi. Le camion arrivera avec 32 palettes.', 'Vous trouverez le bon de livraison en pièce jointe. Merci de prévoir deux agents pour le déchargement.', 'Bien cordialement,\nAya Koné — Sotra Logistique']),
  ExMessage(id: 'm2', from: 'Fatou Diabaté', email: 'f.diabate@banquelagune.ci', subject: 'Relevé de compte septembre', at: '08:02', unread: true, starred: false,
      label: ('Finance', KitTone.success),
      preview: 'Veuillez trouver ci-joint le relevé de compte du mois de septembre…',
      body: ['Bonjour,', 'Veuillez trouver ci-joint le relevé de compte du mois de septembre. Le solde créditeur s’élève à 48 320 000 FCFA.', 'Cordialement,\nFatou Diabaté']),
  ExMessage(id: 'm3', from: 'Marc Yao', email: 'marc.yao@exemple.ci', subject: 'Re: Proposition Orca Télécom', at: 'Hier', unread: false, starred: true,
      preview: 'Le client a validé la proposition, je prépare le contrat pour signature…',
      body: ['Salut Jean,', 'Le client a validé la proposition à 12,4 M FCFA. Je prépare le contrat pour une signature lundi.', 'Marc']),
  ExMessage(id: 'm4', from: 'Support UI Kit', email: 'support@uikit.dev', subject: 'Votre ticket #4821 a été résolu', at: 'Hier', unread: false, starred: false,
      label: ('Support', KitTone.purple),
      preview: 'Bonne nouvelle : le problème d’export PDF est corrigé dans la version 2.4…',
      body: ['Bonjour,', 'Bonne nouvelle : le problème d’export PDF est corrigé dans la version 2.4. Aucune action n’est requise de votre part.', 'L’équipe Support']),
  ExMessage(id: 'm5', from: 'Dr Awa Bamba', email: 'a.bamba@clinique-riviera.ci', subject: 'Échéancier de paiement', at: 'Lun.', unread: false, starred: false,
      label: ('Relance', KitTone.warning),
      preview: 'Suite à votre relance, nous proposons un règlement en trois échéances…',
      body: ['Monsieur Kouassi,', 'Suite à votre relance, nous proposons un règlement en trois échéances mensuelles à compter du 1er novembre.', 'Dr Awa Bamba']),
  ExMessage(id: 'm6', from: 'Serge Kacou', email: 'serge@hotel-assinie.ci', subject: 'Réservation séminaire décembre', at: 'Dim.', unread: false, starred: false,
      preview: 'Nous avons bien noté votre demande pour 40 personnes du 12 au 14 décembre…',
      body: ['Bonjour,', 'Nous avons bien noté votre demande pour 40 personnes du 12 au 14 décembre. Un devis vous sera adressé sous 48 h.', 'Serge Kacou — Hôtel Assinie']),
  ExMessage(id: 'm7', from: 'Grace Kouamé', email: 'grace@digitalbaobab.ci', subject: 'Atelier design system', at: '12 oct.', unread: false, starred: false,
      preview: 'Merci pour l’atelier de mardi ! Voici le compte rendu et les prochaines étapes…',
      body: ['Merci pour l’atelier de mardi !', 'Voici le compte rendu et les prochaines étapes : audit des composants, jetons de couleur, documentation.', 'Grace']),
];

class ExProduct {
  const ExProduct({required this.id, required this.name, required this.category, required this.icon, required this.hue, required this.price, required this.rating, required this.stock, this.badge});
  final String id, name, category;
  final IconData icon;
  final int hue, price, stock;
  final double rating;
  final String? badge;
}

const _products = [
  ('Casque sans fil Pro', 'Audio', Icons.headphones, 210), ('Enceinte nomade', 'Audio', Icons.speaker, 190), ('Montre connectée S2', 'Objets connectés', Icons.watch, 260),
  ('Ordinateur portable 14"', 'Informatique', Icons.laptop_mac, 220), ('Écran 27" QHD', 'Informatique', Icons.monitor, 200), ('Clavier mécanique', 'Informatique', Icons.keyboard, 280),
  ('Smartphone X12', 'Téléphonie', Icons.smartphone, 170), ('Tablette 11"', 'Téléphonie', Icons.tablet, 160), ('Appareil photo hybride', 'Photo', Icons.photo_camera, 20),
  ('Drone compact', 'Photo', Icons.flight, 30), ('Console portable', 'Jeux', Icons.sports_esports, 300), ('Routeur Wi-Fi 6', 'Réseau', Icons.router, 140),
];

/// `EX_PRODUCTS`
final List<ExProduct> kExProducts = [
  for (var i = 0; i < _products.length; i++)
    ExProduct(
      id: 'p-${i + 1}', name: _products[i].$1, category: _products[i].$2, icon: _products[i].$3, hue: _products[i].$4,
      price: (((i * 37) % 23) + 4) * 15000,
      rating: 3.5 + ((i * 7) % 15) / 10,
      stock: (i * 17) % 9 == 0 ? 0 : (i * 17) % 40,
      badge: i % 5 == 0 ? 'Nouveau' : i % 4 == 1 ? '-20 %' : null,
    ),
];

/// `EX_CATEGORIES`
final List<String> kExCategories = [...{for (final p in kExProducts) p.category}];

class ExModule {
  const ExModule(this.id, this.label, this.icon, this.description, this.color, {this.count, this.badge});
  final String id, label, description;
  final IconData icon;
  final Color color;
  final String? count;
  final int? badge;
}

const kExModules = [
  ExModule('crm', 'Clients', Icons.groups, 'Comptes, contacts et opportunités', Color(0xFF0EA5E9), count: '1 248 comptes', badge: 3),
  ExModule('billing', 'Facturation', Icons.receipt_long, 'Devis, factures, encaissements', Color(0xFF10B981), count: '86 factures ce mois'),
  ExModule('stock', 'Stocks', Icons.inventory_2, 'Articles, entrepôts, mouvements', Color(0xFFF59E0B), count: '4 entrepôts'),
  ExModule('planning', 'Planning', Icons.calendar_month, 'Interventions et rendez-vous', Color(0xFF8B5CF6), count: '14 aujourd’hui', badge: 2),
  ExModule('fleet', 'Flotte', Icons.local_shipping, 'Véhicules, trajets, balises', Color(0xFFEF4444), count: '62 véhicules'),
  ExModule('hr', 'Ressources humaines', Icons.badge, 'Employés, congés, paie', Color(0xFFEC4899), count: '138 employés'),
  ExModule('docs', 'Documents', Icons.folder_open, 'GED, modèles, signatures', Color(0xFF64748B), count: '2,4 Go'),
  ExModule('reports', 'Rapports', Icons.insights, 'Tableaux de bord et exports', Color(0xFF06B6D4), count: '18 rapports'),
  ExModule('support', 'Support', Icons.support_agent, 'Tickets et base de connaissances', Color(0xFFF97316), count: '7 tickets ouverts', badge: 7),
  ExModule('settings', 'Administration', Icons.admin_panel_settings, 'Utilisateurs, rôles, intégrations', Color(0xFF475569)),
];

// ─── content.data.ts ────────────────────────────────────────────────────────

class CommentAuthor {
  const CommentAuthor(this.name, this.color, this.role, {this.bio});
  final String name, role;
  final Color color;
  final String? bio;
}

const kPeople = [
  CommentAuthor('Jean Kouassi', Color(0xFF0EA5E9), 'Administrateur'),
  CommentAuthor('Aya Koné', Color(0xFF8B5CF6), 'Opérations'),
  CommentAuthor('Marc Yao', Color(0xFF10B981), 'Développeur'),
  CommentAuthor('Grace Kouamé', Color(0xFFF59E0B), 'Designer'),
  CommentAuthor('Ibrahim Sanogo', Color(0xFFEF4444), 'Produit'),
  CommentAuthor('Nadia Touré', Color(0xFFEC4899), 'Rédaction'),
];
const kMe = CommentAuthor('Jean Kouassi', Color(0xFF0EA5E9), 'Administrateur');
const _aya = CommentAuthor('Aya Koné', Color(0xFF8B5CF6), 'Opérations');
const _marc = CommentAuthor('Marc Yao', Color(0xFF10B981), 'Développeur');
const _grace = CommentAuthor('Grace Kouamé', Color(0xFFF59E0B), 'Designer');
const _ibrahim = CommentAuthor('Ibrahim Sanogo', Color(0xFFEF4444), 'Produit');
const _nadia = CommentAuthor('Nadia Touré', Color(0xFFEC4899), 'Rédaction');

/// Bloc d'article (`ArticleBlock`). Le texte garde le Markdown en ligne de la source.
class ArticleBlock {
  const ArticleBlock(this.type, {this.text, this.title, this.tone, this.items, this.head, this.rows, this.caption, this.code, this.lang, this.filename, this.cite, this.icon, this.dropcap = false});
  final String type;
  final String? text, title, tone, caption, code, lang, filename, cite;
  final List<String>? items, head;
  final List<List<String>>? rows;
  final IconData? icon;
  final bool dropcap;
}

const _long = [
  ArticleBlock('lead', text: 'Un design system n’est pas une bibliothèque de boutons. C’est un **langage commun** entre designers, développeurs et métiers — et comme tout langage, il vit, s’use et se réforme.'),
  ArticleBlock('p', dropcap: true, text: 'Il y a deux ans, notre application comptait quatorze nuances de bleu, neuf tailles de titres et autant de façons d’afficher une date. Chaque écran était cohérent avec lui-même, aucun ne l’était avec ses voisins. Les équipes livraient vite, mais chaque nouvelle page ajoutait un peu plus de dette visuelle.'),
  ArticleBlock('p', text: 'Nous avons alors pris une décision simple : avant d’ajouter un composant, nous le cherchons dans le kit. S’il n’existe pas, nous le construisons **dans** le kit, documenté et testé, puis nous l’utilisons.'),
  ArticleBlock('h2', text: 'Commencer par la typographie'),
  ArticleBlock('p', text: 'La typographie porte 90 % de l’interface. Avant les couleurs, avant les composants, nous avons fixé une échelle : un ratio de 1,2 (tierce mineure), arrondi sur une grille de 2 px. Deux familles seulement : *Outfit* pour les titres, *Inter* pour le texte.'),
  ArticleBlock('table', caption: 'Échelle typographique retenue (px).', head: ['Rôle', 'Taille', 'Interlignage', 'Graisse'], rows: [
    ['Display', '40', '1,15', '700'], ['Titre 1', '32', '1,2', '700'], ['Titre 2', '24', '1,25', '600'], ['Corps', '14 – 16', '1,55', '400'], ['Légende', '12', '1,4', '400'],
  ]),
  ArticleBlock('callout', tone: 'info', title: 'La mesure compte', text: 'Une ligne de texte confortable fait entre **60 et 75 caractères**. Au-delà, l’œil peine à retrouver le début de la ligne suivante : nous plafonnons le corps de texte à `68ch`.'),
  ArticleBlock('h3', text: 'Les règles de la typographie française'),
  ArticleBlock('p', text: 'Le français a ses propres conventions : espace insécable avant les signes doubles, guillemets « chevrons », apostrophe typographique, séparateur de milliers en espace fine. Nous les appliquons automatiquement à la saisie.'),
  ArticleBlock('list', items: ['Espace fine insécable avant `; ! ?` et espace insécable avant `:`', 'Guillemets « … » avec espaces insécables intérieures', 'Montants : 1 250 000 FCFA, heures : 14 h 05', 'Points de suspension en un seul caractère (…)']),
  ArticleBlock('pullquote', text: 'Un composant qui n’est pas documenté n’existe pas. Un composant documenté mais pas utilisé non plus.'),
  ArticleBlock('h2', text: 'Des jetons plutôt que des valeurs'),
  ArticleBlock('p', text: 'Chaque couleur est un **rôle**, jamais une valeur : `--primary-color`, `--text-secondary`, `--border-color`. Le mode sombre et les 41 thèmes de couleur deviennent alors un simple changement de jeu de jetons.'),
  ArticleBlock('code', lang: 'scss', filename: 'styles/_tokens.scss', code: ':root {\n  --primary-color: var(--mat-sys-primary);\n  --text-primary: #1f2937;\n  --text-secondary: #4b5563;\n  --border-color: #e5e7eb;\n  --radius-card: 24px;\n}\n\n.card {\n  border: 1px solid var(--border-color);\n  border-radius: var(--radius-card);\n}'),
  ArticleBlock('figure', icon: Icons.palette, caption: 'Les rôles de couleur Material 3, déclinés en clair et en sombre pour chaque thème.'),
  ArticleBlock('h2', text: 'Mesurer l’adoption'),
  ArticleBlock('p', text: 'Un kit se juge à son usage. Chaque mois, nous comptons les composants maison encore présents dans le code et les écarts de style relevés en revue.'),
  ArticleBlock('quote', text: 'Le jour où un nouvel arrivant a livré un écran complet sans écrire une ligne de CSS, nous avons su que le kit avait gagné.', cite: 'Grace Kouamé, lead design'),
  ArticleBlock('callout', tone: 'success', title: 'Résultat après 18 mois', text: '84 % des écrans n’utilisent que des composants du kit, et le temps moyen de conception d’une page est passé de 5 à 2 jours.'),
  ArticleBlock('divider'),
  ArticleBlock('p', text: 'Il reste du chemin : l’accessibilité des graphiques, la densité des tableaux sur mobile, les formulaires très longs. Ce sera l’objet des prochains articles.'),
];

List<ArticleBlock> _short(String lead, String h) => [
      ArticleBlock('lead', text: lead),
      const ArticleBlock('p', text: 'Cet article d’exemple illustre la mise en page éditoriale du kit : chapô, intertitres, listes, encadrés et citations, avec une mesure de ligne confortable.'),
      ArticleBlock('h2', text: h),
      const ArticleBlock('p', text: 'Les données sont statiques. Ouvrez l’article principal pour voir l’ensemble des blocs disponibles et le fil de commentaires complet.'),
      const ArticleBlock('callout', tone: 'neutral', text: 'Astuce : tous les blocs acceptent le Markdown en ligne, **gras**, *italique*, `code` et [liens](#).'),
    ];

class Article {
  const Article({required this.slug, required this.title, required this.dek, required this.category, required this.tags, required this.author, required this.date, required this.minutes, required this.hue, required this.icon, required this.blocks, this.featured = false});
  final String slug, title, dek, category, date;
  final List<String> tags;
  final CommentAuthor author;
  final int minutes, hue;
  final IconData icon;
  final List<ArticleBlock> blocks;
  final bool featured;
}

final List<Article> kArticles = [
  const Article(slug: 'design-system-langage-commun', title: 'Un design system, c’est d’abord un langage commun', dek: 'Ce que deux ans de composants partagés nous ont appris sur la typographie, les jetons et l’adoption.',
      category: 'Design', tags: ['design system', 'typographie', 'jetons'], author: CommentAuthor('Grace Kouamé', Color(0xFFF59E0B), 'Lead design', bio: 'Designer produit à Abidjan, Grace anime l’équipe design system et la communauté UI Kit.'),
      date: '2026-10-14', minutes: 8, hue: 185, icon: Icons.auto_stories, featured: true, blocks: _long),
  Article(slug: 'formulaires-longs-sans-douleur', title: 'Des formulaires longs, sans douleur', dek: 'Découper, enregistrer en continu, valider au bon moment : nos règles pour les formulaires de plus de 20 champs.',
      category: 'UX', tags: const ['formulaires', 'validation'], author: const CommentAuthor('Nadia Touré', Color(0xFFEC4899), 'Rédaction'), date: '2026-10-09', minutes: 6, hue: 280, icon: Icons.dynamic_form,
      blocks: _short('Un formulaire long n’est pas un mauvais formulaire : c’est un formulaire mal découpé.', 'Une étape, une intention')),
  Article(slug: 'mobile-money-paiement', title: 'Intégrer le Mobile Money dans un tunnel de paiement', dek: 'Orange Money, MTN MoMo, Wave : concevoir un parcours clair quand la confirmation arrive par SMS.',
      category: 'Produit', tags: const ['paiement', 'mobile'], author: const CommentAuthor('Ibrahim Sanogo', Color(0xFFEF4444), 'Produit'), date: '2026-10-02', minutes: 5, hue: 30, icon: Icons.phone_iphone,
      blocks: _short('Le paiement mobile est la norme : le tunnel doit l’être aussi.', 'Attendre la confirmation')),
  Article(slug: 'mode-sombre-sans-regret', title: 'Le mode sombre, sans regret', dek: 'Contrastes, élévation, images : les pièges du thème sombre et comment les éviter.',
      category: 'Design', tags: const ['thème', 'accessibilité'], author: const CommentAuthor('Marc Yao', Color(0xFF10B981), 'Développeur'), date: '2026-09-25', minutes: 4, hue: 230, icon: Icons.dark_mode,
      blocks: _short('Inverser les couleurs ne suffit pas.', 'L’élévation par la lumière')),
  Article(slug: 'tableaux-sur-mobile', title: 'Que faire des tableaux sur mobile ?', dek: 'Cartes, colonnes prioritaires, défilement horizontal : comparaison de quatre stratégies.',
      category: 'UX', tags: const ['responsive', 'tableaux'], author: const CommentAuthor('Aya Koné', Color(0xFF8B5CF6), 'Opérations'), date: '2026-09-18', minutes: 7, hue: 150, icon: Icons.table_rows,
      blocks: _short('Un tableau de 8 colonnes ne tiendra jamais dans 393 px.', 'Choisir ce qui compte')),
  Article(slug: 'ecrire-pour-interface', title: 'Écrire pour l’interface', dek: 'Boutons, erreurs, états vides : le microtexte est une partie du design.',
      category: 'Rédaction', tags: const ['UX writing'], author: const CommentAuthor('Nadia Touré', Color(0xFFEC4899), 'Rédaction'), date: '2026-09-11', minutes: 5, hue: 340, icon: Icons.edit_note,
      blocks: _short('Un bon libellé de bouton dit ce qui va se passer.', 'Verbes d’action')),
];

/// `BLOG_CATEGORIES`
final List<String> kBlogCategories = ['Tous', ...{for (final a in kArticles) a.category}];

class CommentItem {
  const CommentItem(this.id, this.author, this.at, this.likes, this.text, {this.byAuthor = false, this.pinned = false, this.reactions = const [], this.replies = const []});
  final String id, at, text;
  final CommentAuthor author;
  final int likes;
  final bool byAuthor, pinned;
  final List<(String, int)> reactions;
  final List<CommentItem> replies;
}

const kComments = [
  CommentItem('k1', _grace, 'il y a 2 j', 24, 'Merci pour vos retours ! Le prochain article portera sur **la densité des tableaux sur mobile**. Dites-moi en réponse ce que vous aimeriez y voir.',
      byAuthor: true, pinned: true, reactions: [('🎉', 6), ('❤️', 3)], replies: [
        CommentItem('k1a', _marc, 'il y a 2 j', 5, 'Les colonnes figées et le défilement horizontal, surtout avec la sélection multiple.'),
        CommentItem('k1b', _aya, 'il y a 1 j', 2, '@Marc-Yao +1, et les actions groupées : sur mobile on ne sait jamais où les mettre.'),
        CommentItem('k1c', _ibrahim, 'il y a 20 h', 1, 'Et les filtres ! Une feuille du bas (*bottom sheet*) marche bien chez nous.'),
        CommentItem('k1d', _grace, 'il y a 18 h', 3, 'Noté, merci à tous 🙏', byAuthor: true),
      ]),
  CommentItem('k2', _marc, 'il y a 1 j', 12, 'Le passage sur les jetons est exactement ce qu’il nous manquait. Petite question : vous générez les palettes à la compilation ou à l’exécution ?\n\n```\nnode tools/generate-themes.mjs\n```', replies: [
    CommentItem('k2a', _grace, 'il y a 1 j', 4, 'À la compilation pour les 41 thèmes prédéfinis, à l’exécution pour le **studio de thème** (couleur personnalisée).', byAuthor: true),
  ]),
  CommentItem('k3', _nadia, 'il y a 9 h', 7, 'Bravo pour la partie typographie française. Les espaces fines avant `?` et `!` sont trop souvent oubliées.', reactions: [('👍', 4)]),
  CommentItem('k4', _aya, 'il y a 3 h', 1, 'Est-ce que le kit est utilisable dans une application Flutter aussi ?'),
];

const kFeedComments = [
  [
    CommentItem('f1', _marc, 'il y a 1 h', 3, 'Super, on teste ça dès lundi sur l’entrepôt de Vridi.'),
    CommentItem('f2', _aya, 'il y a 40 min', 1, '@Marc-Yao je te prépare les accès.'),
  ],
  [CommentItem('f3', _nadia, 'il y a 3 h', 2, 'Les nouvelles illustrations sont magnifiques 😍')],
  <CommentItem>[],
];

class DocNode {
  const DocNode(this.label, {this.slug, this.icon, this.children = const [], this.badge});
  final String label;
  final String? slug, badge;
  final IconData? icon;
  final List<DocNode> children;
}

const kDocsNav = [
  DocNode('Prise en main', icon: Icons.rocket_launch, children: [DocNode('Introduction', slug: 'introduction'), DocNode('Installation', slug: 'installation', badge: 'v2'), DocNode('Thèmes', slug: 'themes')]),
  DocNode('Fondations', icon: Icons.foundation, children: [DocNode('Typographie', slug: 'typographie'), DocNode('Couleurs', slug: 'couleurs'), DocNode('Espacements', slug: 'espacements')]),
  DocNode('Composants', icon: Icons.widgets, children: [DocNode('Boutons', slug: 'boutons'), DocNode('Formulaires', slug: 'formulaires'), DocNode('Commentaires', slug: 'commentaires', badge: 'Nouveau'), DocNode('Article', slug: 'article', badge: 'Nouveau')]),
  DocNode('Guides', icon: Icons.menu_book, children: [DocNode('Accessibilité', slug: 'accessibilite'), DocNode('Contribuer', slug: 'contribuer')]),
];

const kDocPage = [
  ArticleBlock('lead', text: '`<app-comment-thread>` affiche un fil de discussion complet : saisie, tri, réponses imbriquées, réactions, modification et suppression.'),
  ArticleBlock('h2', text: 'Utilisation'),
  ArticleBlock('code', lang: 'html', filename: 'article.component.html', code: '<app-comment-thread\n  [comments]="comments"\n  [me]="currentUser"\n  [mentionables]="team"\n  moderator\n  (changed)="save(\$event)" />'),
  ArticleBlock('p', text: 'Le composant garde une copie locale de la liste : les interactions sont immédiates, et chaque modification est émise via `changed` pour que l’hôte la persiste.'),
  ArticleBlock('h2', text: 'Propriétés'),
  ArticleBlock('table', head: ['Entrée', 'Type', 'Défaut', 'Description'], rows: [
    ['`comments`', '`CommentItem[]`', '`[]`', 'Commentaires et réponses.'],
    ['`me`', '`CommentAuthor`', '`null`', 'Utilisateur courant (droits de modification).'],
    ['`mentionables`', '`CommentAuthor[]`', '`[]`', 'Personnes proposées après « @ ».'],
    ['`compact`', '`boolean`', '`false`', 'Variante resserrée, saisie en bas.'],
    ['`moderator`', '`boolean`', '`false`', 'Autorise l’épinglage.'],
    ['`visibleReplies`', '`number`', '`2`', 'Réponses visibles avant « Afficher plus ».'],
  ]),
  ArticleBlock('h3', text: 'Saisie seule'),
  ArticleBlock('p', text: '`<app-comment-composer>` peut être utilisé seul : barre de mise en forme Markdown, mentions, aperçu, compteur et envoi par ⌘/Ctrl + Entrée.'),
  ArticleBlock('callout', tone: 'warning', title: 'Contenu utilisateur', text: 'Le texte est échappé avant le rendu Markdown : aucun HTML saisi n’est interprété.'),
  ArticleBlock('h2', text: 'Accessibilité'),
  ArticleBlock('list', items: ['Les boutons J’aime et réactions exposent `aria-pressed`.', 'Les mentions se naviguent au clavier (↑ ↓ Entrée Échap).', 'Chaque commentaire a une ancre `#comment-<id>` partageable.']),
];

// ─── dashboard-example.component.ts ─────────────────────────────────────────

class DashPeriod {
  const DashPeriod(this.id, this.label, this.compare, this.kpi, this.trend, this.labels, this.a, this.b);
  final String id, label, compare;
  final List<double> kpi, trend, a, b;
  final List<String> labels;
}

const kDashPeriods = [
  DashPeriod('7j', '7 jours', 'vs semaine précédente', [27.9e6, 22.1e6, 9, 7.3e6], [6.2, 4.8, 12.5, -3.1],
      ['Sam', 'Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven'], [2.1, 0.8, 4.6, 5.2, 3.9, 6.1, 5.4], [1.8, 0.6, 3.1, 4.4, 3.2, 4.9, 4.1]),
  DashPeriod('30j', '30 jours', 'vs mois précédent', [119e6, 96.1e6, 38, 7.3e6], [9.4, 8.1, 4.6, -2.3],
      ['S1', 'S2', 'S3', 'S4'], [24, 31, 28, 36], [19, 26, 24, 27]),
  DashPeriod('12m', '12 mois', 'vs année précédente', [1.14e9, 0.99e9, 412, 7.3e6], [12.4, 10.2, 18.0, -8.5],
      ['Nov', 'Déc', 'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct'], [82, 95, 71, 78, 90, 99, 104, 97, 88, 93, 115, 128], [70, 81, 66, 70, 79, 84, 92, 85, 80, 82, 98, 96]),
];

/// (libellé, icône, unité, hausse = bonne nouvelle)
const kDashKpis = [
  ('Chiffre d’affaires', Icons.payments, 'FCFA', true),
  ('Encaissé', Icons.account_balance_wallet, 'FCFA', true),
  ('Nouveaux clients', Icons.person_add, '', true),
  ('Impayés', Icons.schedule, 'FCFA', false),
];

const kDashTabs = [('Vue d’ensemble', Icons.space_dashboard), ('Ventes', Icons.bar_chart), ('Clients', Icons.pie_chart), ('Opérations', Icons.insights)];

const kDashGoals = [('Chiffre d’affaires', 72, '128,4 M sur 178 M FCFA'), ('Taux d’encaissement', 88, 'Cible 90 %'), ('Nouveaux comptes', 45, '38 sur 85')];

// ─── board-example.component.ts ─────────────────────────────────────────────

class BoardTask {
  const BoardTask(this.id, this.ref, this.title, this.status, this.assignee, {this.progress, this.badge, this.tags = const []});
  final String id, ref, title, status, assignee;
  final int? progress;
  final (String, KitTone)? badge;
  final List<String> tags;
}

const kBoardColumns = [('todo', 'À faire', KitTone.neutral), ('doing', 'En cours', KitTone.info), ('review', 'En revue', KitTone.warning), ('done', 'Terminé', KitTone.success)];

const kBoardTasks = [
  BoardTask('t1', 'SOT-101', 'Audit des entrepôts de Vridi', 'todo', 'Marc Yao', badge: ('Terrain', KitTone.info)),
  BoardTask('t2', 'SOT-102', 'Import des 1 200 références articles', 'todo', 'Aïcha Diallo', tags: ['data']),
  BoardTask('t3', 'SOT-103', 'Paramétrage des tarifs transport', 'todo', 'Jean Kouassi', badge: ('Urgent', KitTone.error)),
  BoardTask('t4', 'SOT-097', 'Formation des chefs de quai', 'doing', 'Sarah Bamba', progress: 60),
  BoardTask('t5', 'SOT-098', 'Connexion API balises GPS', 'doing', 'Marc Yao', progress: 35, badge: ('Technique', KitTone.purple)),
  BoardTask('t6', 'SOT-099', 'Modèles de bons de livraison', 'doing', 'Aïcha Diallo', progress: 80),
  BoardTask('t7', 'SOT-094', 'Recette du module facturation', 'review', 'Jean Kouassi', progress: 90),
  BoardTask('t8', 'SOT-095', 'Droits d’accès par site', 'review', 'Sarah Bamba'),
  BoardTask('t9', 'SOT-090', 'Atelier de cadrage', 'done', 'Jean Kouassi', progress: 100),
  BoardTask('t10', 'SOT-091', 'Création des comptes utilisateurs', 'done', 'Aïcha Diallo', progress: 100),
];

// ─── monitoring-example.component.ts ────────────────────────────────────────

/// (id, nom, groupe, icône, statut, disponibilité 90 j, latence ms)
const kMonServices = [
  ('api', 'API publique', 'Plateforme', Icons.api, 'up', 99.98, 84),
  ('pay', 'Paiements Mobile Money', 'Plateforme', Icons.payments, 'degraded', 99.71, 412),
  ('web', 'Application web', 'Plateforme', Icons.language, 'up', 99.99, 120),
  ('mobile', 'API mobile', 'Plateforme', Icons.smartphone, 'up', 99.95, 96),
  ('gps', 'Passerelle GPS (balises)', 'Terrain', Icons.satellite_alt, 'up', 99.9, 38),
  ('sms', 'Envoi SMS', 'Tiers', Icons.sms, 'up', 99.6, 640),
  ('mail', 'E-mails transactionnels', 'Tiers', Icons.mail, 'maintenance', 99.92, 230),
  ('backup', 'Sauvegardes', 'Infrastructure', Icons.backup, 'up', 100.0, 0),
];

(String, KitTone) monHealth(String s) => switch (s) {
      'up' => ('Opérationnel', KitTone.success),
      'degraded' => ('Dégradé', KitTone.warning),
      'down' => ('Panne', KitTone.error),
      _ => ('Maintenance', KitTone.info),
    };

/// (id, titre, gravité, statut, début, service, responsable)
const kMonIncidents = [
  ('INC-214', 'Latence élevée sur les callbacks Mobile Money', 'majeur', 'en cours', 'il y a 38 min', 'Paiements', 'Marc Yao'),
  ('INC-213', 'Échec de l’export Sage nocturne', 'mineur', 'surveillance', 'il y a 7 h', 'Tâches planifiées', 'Fatou Diabaté'),
  ('INC-211', 'Perte de signal de 2 balises sur l’axe nord', 'mineur', 'résolu', 'hier', 'Passerelle GPS', 'Aya Koné'),
  ('INC-207', 'Indisponibilité partielle des SMS (opérateur)', 'critique', 'résolu', 'il y a 3 j', 'Envoi SMS', 'Ibrahim Sanogo'),
];

/// (nom, planification, dernière exécution, durée, statut)
const kMonJobs = [
  ('Relances automatiques', 'Chaque jour · 09:00', 'aujourd’hui 09:00', '42 s', 'ok'),
  ('Synchronisation comptable', 'Toutes les heures', 'il y a 12 min', '3 min 08', 'running'),
  ('Export Sage', 'Chaque nuit · 02:00', 'aujourd’hui 02:00', '—', 'failed'),
  ('Sauvegarde complète', 'Chaque nuit · 03:30', 'aujourd’hui 03:30', '18 min', 'ok'),
  ('Purge des journaux', 'Dimanche · 04:00', 'il y a 5 j', '1 min 12', 'ok'),
];

/// (libellé, valeur, unité, icône, indication)
const kMonKpis = [
  ('Disponibilité (30 j)', '99,94', '%', Icons.verified, 'SLO 99,9 %'),
  ('Latence p95', '184', 'ms', Icons.speed, 'objectif < 250 ms'),
  ('Taux d’erreur', '0,42', '%', Icons.error_outline, '5xx / total'),
  ('Alertes actives', '3', '', Icons.notifications_active, '1 critique'),
];

// ─── chat/ex-chat.service.ts ────────────────────────────────────────────────

class ChatPerson {
  const ChatPerson(this.id, this.name, this.color, this.role, this.online);
  final String id, name, role;
  final Color color;
  final bool online;
}

const kChatPeople = [
  ChatPerson('me', 'Jean Kouassi', Color(0xFF0EA5E9), 'Administrateur', true),
  ChatPerson('aya', 'Aya Koné', Color(0xFF8B5CF6), 'Opérations', true),
  ChatPerson('marc', 'Marc Yao', Color(0xFF10B981), 'Développeur', true),
  ChatPerson('grace', 'Grace Kouamé', Color(0xFFF59E0B), 'Designer', false),
  ChatPerson('ibrahim', 'Ibrahim Sanogo', Color(0xFFEF4444), 'Produit', true),
  ChatPerson('fatou', 'Fatou Diabaté', Color(0xFF7C3AED), 'Juridique', false),
  ChatPerson('koffi', 'Koffi N’Guessan', Color(0xFF0891B2), 'Technicien', true),
  ChatPerson('sarah', 'Sarah Bamba', Color(0xFFDB2777), 'Formation', false),
];

ChatPerson chatPerson(String id) => kChatPeople.firstWhere((p) => p.id == id);

class ChatConv {
  const ChatConv(this.id, this.kind, this.name, this.members, this.unread, this.messages, {this.pinned = false, this.muted = false, this.description});
  final String id, kind, name;
  final List<String> members;
  final int unread;
  final bool pinned, muted;
  final String? description;

  /// (auteur, texte) ; texte vide = note vocale ; auteur `system` = message système.
  final List<(String, String)> messages;

  String get title => kind == 'direct' ? chatPerson(members[1]).name : (kind == 'channel' ? '# $name' : name);
}

const kChatConversations = [
  ChatConv('c-aya', 'direct', '', ['me', 'aya'], 2, pinned: true, [
    ('aya', 'Bonjour Jean, tu as pu valider le planning de jeudi ?'),
    ('me', 'Oui, c’est validé. Le camion arrive à 8 h.'),
    ('aya', 'Top. Je préviens l’équipe du quai.'),
    ('aya', 'Les quais 2 et 3 sont prêts 📦'),
    ('aya', 'On a aussi reçu le bon de livraison signé.'),
    ('me', 'Excellent travail, merci à toute l’équipe !'),
    ('aya', 'Merci ! Petite question : on garde le créneau de 8 h pour le lot 15 ?'),
    ('aya', 'Ou on décale à 9 h à cause de la marée ?'),
  ]),
  ChatConv('c-ops', 'group', 'Équipe opérations', ['me', 'aya', 'koffi', 'sarah', 'marc'], 5, description: 'Coordination terrain, livraisons et interventions.', [
    ('system', 'Jean a créé le groupe « Équipe opérations »'),
    ('koffi', 'Installation terminée chez Transports Yao, 12 balises posées.'),
    ('sarah', 'Formation des chefs de quai : 8 personnes inscrites pour lundi.'),
    ('koffi', ''),
    ('aya', 'Koffi, tu peux passer à Vridi après ?'),
    ('koffi', 'Oui, j’y serai vers 14 h.'),
    ('marc', 'La connexion API des balises est en recette, retours bienvenus 🙌'),
  ]),
  ChatConv('c-marc', 'direct', '', ['me', 'marc'], 0, [
    ('marc', 'Le client a validé la proposition à 12,4 M FCFA.'),
    ('me', 'Génial 🎉 On prépare le contrat pour lundi ?'),
    ('marc', 'Oui, je m’en occupe.'),
  ]),
  ChatConv('c-general', 'channel', 'général', ['me', 'aya', 'marc', 'grace', 'ibrahim', 'fatou', 'koffi', 'sarah'], 0, muted: true, description: 'Annonces et informations pour toute l’entreprise.', [
    ('ibrahim', 'La version 2.4 est en production : export PDF corrigé, nouveaux rapports.'),
    ('grace', 'Les nouvelles illustrations du site sont en ligne ✨'),
  ]),
  ChatConv('c-fatou', 'direct', '', ['me', 'fatou'], 0, [
    ('fatou', 'Voici la version signée du contrat cadre.'),
    ('me', 'Merci Fatou, je classe ça dans le dossier Contrats.'),
  ]),
  ChatConv('c-grace', 'direct', '', ['me', 'grace'], 0, [
    ('grace', 'Tu as un moment pour revoir les maquettes du tableau de bord ?'),
    ('me', 'Demain matin si ça te va.'),
  ]),
];

// ─── files/ex-files.service.ts ──────────────────────────────────────────────

class FmItem {
  const FmItem(this.id, this.name, this.kind, this.parent, this.days, this.owner, {this.size, this.color, this.shared = false, this.starred = false});
  final String id, name, kind, owner;
  final String? parent;
  final int days;

  /// Taille en octets quand la source la fixe (fichiers « fantômes ») ; sinon calculée à l'exécution côté Angular.
  final int? size;
  final Color? color;
  final bool shared, starred;
}

/// `FM_KINDS` : (libellé, icône, couleur)
const Map<String, (String, IconData, Color)> kFmKinds = {
  'folder': ('Dossier', Icons.folder, Color(0xFF64748B)),
  'image': ('Image', Icons.image, Color(0xFF8B5CF6)),
  'video': ('Vidéo', Icons.movie, Color(0xFFEC4899)),
  'audio': ('Audio', Icons.audiotrack, Color(0xFFF59E0B)),
  'pdf': ('PDF', Icons.picture_as_pdf, Color(0xFFEF4444)),
  'sheet': ('Tableur', Icons.table_chart, Color(0xFF10B981)),
  'slides': ('Présentation', Icons.slideshow, Color(0xFFF97316)),
  'doc': ('Document', Icons.description, Color(0xFF3B82F6)),
  'text': ('Texte', Icons.article, Color(0xFF0EA5E9)),
  'archive': ('Archive', Icons.folder_zip, Color(0xFF78716C)),
};

const _photoCaptions = ['Flotte stationnée - Plateau', 'Dépôt de Yopougon au coucher du soleil', 'Axe Abidjan - Yamoussoukro', 'Port de San-Pédro', 'Atelier d’installation des balises'];

final List<FmItem> kFmItems = [
  const FmItem('docs', 'Documents', 'folder', null, 1, 'Jean Kouassi', color: Color(0xFF3B82F6)),
  const FmItem('contracts', 'Contrats', 'folder', 'docs', 3, 'Jean Kouassi', color: Color(0xFF3B82F6), shared: true),
  const FmItem('invoices', 'Factures 2026', 'folder', 'docs', 0, 'Jean Kouassi', color: Color(0xFF10B981)),
  const FmItem('photos', 'Photos terrain', 'folder', null, 2, 'Jean Kouassi', color: Color(0xFF8B5CF6), starred: true),
  const FmItem('media', 'Médias', 'folder', null, 4, 'Jean Kouassi', color: Color(0xFFEC4899)),
  const FmItem('sotra', 'Projet Sotra', 'folder', null, 1, 'Jean Kouassi', color: Color(0xFFF59E0B), shared: true, starred: true),
  const FmItem('f1', 'Contrat cadre 2026.pdf', 'pdf', 'contracts', 3, 'Fatou Diabaté', starred: true, shared: true),
  const FmItem('f2', 'Avenant n°2 — Cacao Plus.pdf', 'pdf', 'contracts', 12, 'Fatou Diabaté'),
  const FmItem('f3', 'FAC-2026-0981.pdf', 'pdf', 'invoices', 0, 'Jean Kouassi'),
  const FmItem('f4', 'FAC-2026-0974.pdf', 'pdf', 'invoices', 5, 'Jean Kouassi'),
  const FmItem('f5', 'Relevé septembre.xlsx', 'sheet', 'invoices', 9, 'Fatou Diabaté', size: 184320),
  const FmItem('f6', 'Clients actifs.csv', 'text', 'docs', 1, 'Aïcha Diallo'),
  const FmItem('f7', 'Compte rendu atelier.txt', 'text', 'docs', 2, 'Grace Kouamé', shared: true),
  const FmItem('f8', 'Présentation T4.pptx', 'slides', 'docs', 6, 'Ibrahim Sanogo', size: 4812000),
  const FmItem('f9', 'Procédure d’installation.docx', 'doc', 'docs', 20, 'Marc Yao', size: 642000),
  for (var i = 0; i < 7; i++) FmItem('ph$i', '${_photoCaptions[i % 5]}.jpg', 'image', 'photos', i, i.isOdd ? 'Aya Koné' : 'Marc Yao'),
  for (var i = 0; i < 3; i++) FmItem('q$i', 'Quai ${i + 2} - Vridi.jpg', 'image', 'sotra', i + 1, 'Aya Koné'),
  const FmItem('f10', 'Message vocal - technicien.wav', 'audio', 'media', 1, 'Koffi N’Guessan'),
  const FmItem('f11', 'Appel client - Transports Yao.wav', 'audio', 'media', 6, 'Support'),
  const FmItem('f12', 'Archives 2025.zip', 'archive', 'media', 40, 'Jean Kouassi', size: 412000000),
  const FmItem('f13', 'Planning de déploiement.pdf', 'pdf', 'sotra', 1, 'Jean Kouassi', shared: true),
  const FmItem('f14', 'Budget Sotra.xlsx', 'sheet', 'sotra', 2, 'Ibrahim Sanogo', size: 96256, starred: true),
  const FmItem('f15', 'Rapport mensuel.pdf', 'pdf', null, 4, 'Jean Kouassi'),
  const FmItem('f16', 'Trajet CI-4521-AB.webm', 'video', 'media', 0, 'Marc Yao', starred: true),
];

/// `formatBytes` (Ko / Mo / Go, virgule décimale).
String fmSize(int? n) {
  if (n == null || n == 0) return '—';
  const units = ['o', 'Ko', 'Mo', 'Go', 'To'];
  var v = n.toDouble();
  var u = 0;
  while (v >= 1024 && u < units.length - 1) { v /= 1024; u++; }
  final s = (u == 0 || v >= 100) ? v.round().toString() : v.toStringAsFixed(1).replaceAll('.', ',');
  return '$s ${units[u]}';
}

String fmModified(int days) => days == 0 ? 'Aujourd’hui' : days == 1 ? 'Hier' : 'Il y a $days j';

// ─── feed-example.component.ts ──────────────────────────────────────────────

class FeedPost {
  const FeedPost(this.id, this.author, this.at, this.likes, this.text, this.media, {this.comments = const [], this.poll});
  final String id, at, text, media;
  final CommentAuthor author;
  final int likes;
  final List<CommentItem> comments;
  final (String, List<(String, int)>)? poll;
}

final List<FeedPost> kFeedPosts = [
  FeedPost('p1', _aya, 'il y a 2 h', 18, 'Le nouvel entrepôt de **Vridi** est opérationnel ! Merci à toute l’équipe logistique pour ces trois semaines intenses. Les premières livraisons partent lundi.', 'photos', comments: kFeedComments[0]),
  const FeedPost('p2', _marc, 'il y a 3 h', 24, 'Démo du **suivi en temps réel** sur l’axe Abidjan – Yamoussoukro : la trace se met à jour toutes les 5 secondes.', 'video · Trajet CI-4521-AB'),
  FeedPost('p3', _ibrahim, 'il y a 5 h', 9, 'Petit sondage pour l’atelier produit de vendredi :', 'poll', comments: kFeedComments[1],
      poll: ('Quel module voulez-vous améliorer en priorité ?', const [('Facturation', 14), ('Planning terrain', 22), ('Application mobile', 9), ('Rapports', 5)])),
  const FeedPost('p4', CommentAuthor('Koffi N’Guessan', Color(0xFF0891B2), 'Technicien'), 'il y a 6 h', 4, 'Note vocale depuis le chantier de San-Pédro 👇', 'voice · Note vocale'),
  const FeedPost('p5', CommentAuthor('Fatou Diabaté', Color(0xFF7C3AED), 'Juridique'), 'hier', 11, 'Le **contrat cadre 2026** est signé. Version finale ci-dessous, merci de vous y référer pour les nouvelles commandes.', 'document · Contrat cadre 2026.pdf · 4 pages'),
  FeedPost('p6', _grace, 'hier', 31, 'Nouvel article sur le blog. Vos commentaires sont les bienvenus 🙌', 'link · ${kArticles.first.title}', comments: kFeedComments[2]),
  const FeedPost('p7', _nadia, 'hier', 15, 'Pour la pause café : un court-métrage libre qui sert de référence pour nos tests vidéo.', 'youtube · Big Buck Bunny · 10:34'),
];

// ─── settings-example.component.ts ──────────────────────────────────────────

const kSettingsSections = [
  ('profile', 'Profil', Icons.person),
  ('security', 'Sécurité', Icons.shield),
  ('api', 'API & intégrations', Icons.key),
  ('notifications', 'Notifications', Icons.notifications),
  ('appearance', 'Apparence', Icons.palette),
  ('danger', 'Zone sensible', Icons.warning),
];

const kSettingsSecret = 'sk_demo_51Nf3a9QeLx2Tb8Rk0pYv';
const kSettingsSkillSuggestions = ['Logistique', 'Facturation', 'Formation', 'Support', 'Achats', 'Comptabilité'];
const kSettingsProfileBio = 'Administrateur de l’espace SC Storage.';
const kSettingsProfileSkills = ['Logistique', 'Formation'];
const kSettingsSecurity = [
  ('Vérification en deux étapes', 'Code SMS à chaque nouvelle connexion', true),
  ('Connexion avec Google', 'jean.kouassi@gmail.com', true),
  ('Alertes de connexion', 'E-mail lors d’une connexion inhabituelle', false),
];
const kSettingsSessions = [
  ('MacBook Pro · Chrome', 'Abidjan · maintenant', Icons.laptop_mac, true),
  ('iPhone 15 Pro · Safari', 'Abidjan · il y a 2 h', Icons.phone_iphone, false),
];

/// (libellé, détail, e-mail, push, SMS)
const kSettingsNotifs = [
  ('Nouvelles factures', 'Émises par votre équipe', true, true, false),
  ('Paiements reçus', 'Tous moyens de paiement', true, false, false),
  ('Relances', 'Factures échues', false, true, true),
  ('Mentions', 'Commentaires et fil d’équipe', true, true, false),
];
