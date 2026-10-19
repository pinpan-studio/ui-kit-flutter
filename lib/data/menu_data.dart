import 'package:flutter/material.dart';

/// Entrée de menu du shell (`MenuItem` de `menu.data.ts`).
class MenuEntry {
  const MenuEntry(this.id, this.label, this.icon, [this.children = const []]);
  final String id, label;
  final IconData icon;
  final List<MenuEntry> children;
  bool get isGroup => children.isNotEmpty;
}

/// Menu d'exemple (ancien rail du projet d'origine) — jeu de données du Sidecar de démo.
const kDemoMenu = [
  MenuEntry('dashboard', 'Tableau de bord', Icons.dashboard),
  MenuEntry('client', 'Clients', Icons.people),
  MenuEntry('produit', 'Produits', Icons.inventory_2),
  MenuEntry('equipement', 'Équipement', Icons.settings_input_antenna),
  MenuEntry('service-client', 'Service Client', Icons.support_agent, [
    MenuEntry('sc-dashboard', 'Tableau de bord', Icons.analytics),
    MenuEntry('sc-requetes', 'Requêtes clients', Icons.contact_support),
    MenuEntry('sc-programmations', 'Programmations', Icons.event_available),
    MenuEntry('sc-gestionnaires', 'Gestionnaires clients', Icons.assignment_ind),
    MenuEntry('sc-equipe', 'Équipe', Icons.groups),
  ]),
  MenuEntry('intervention', 'Intervention', Icons.build, [
    MenuEntry('int-dashboard', 'Tableau de bord', Icons.analytics),
    MenuEntry('int-missions', 'Missions', Icons.assignment),
    MenuEntry('int-programmees', 'Interventions programmées', Icons.event_note),
    MenuEntry('int-equipe', 'Équipe Technique', Icons.engineering),
  ]),
  MenuEntry('synchronizations', 'Synchronisations', Icons.cloud_sync),
  MenuEntry('repertoire', 'Répertoire', Icons.menu_book),
  MenuEntry('assac', 'ASSAC', Icons.hub, [
    MenuEntry('assac-agenda', 'Agenda', Icons.calendar_month),
    MenuEntry('assac-appels', 'Appels', Icons.call),
    MenuEntry('assac-rdv', 'RDV', Icons.event),
    MenuEntry('assac-promesses', 'Promesses', Icons.task_alt),
    MenuEntry('assac-prospects', 'Prospects', Icons.contact_page),
    MenuEntry('assac-dossiers', 'Dossiers', Icons.folder_shared),
  ]),
  MenuEntry('cesar', 'CESAR', Icons.savings, [
    MenuEntry('cesar-dashboard', 'Tableau de bord', Icons.analytics),
    MenuEntry('cesar-customers', 'Gestion Clients', Icons.contact_page),
    MenuEntry('cesar-encaissements', 'Encaissements', Icons.payments),
    MenuEntry('cesar-ecritures', 'Factures', Icons.receipt_long),
    MenuEntry('cesar-notes', 'Notes', Icons.sticky_note_2),
  ]),
  MenuEntry('taches', 'Tâches', Icons.task_alt),
  MenuEntry('finance', 'Finance', Icons.account_balance, [
    MenuEntry('facture', 'Factures', Icons.receipt),
    MenuEntry('fin-exercices', 'Exercices comptables', Icons.event_note),
    MenuEntry('fin-paiements', 'Paiements', Icons.payments),
    MenuEntry('fin-abonnements', 'Abonnements', Icons.subscriptions),
    MenuEntry('fin-groupes', 'Groupes de facturation', Icons.workspaces),
  ]),
  MenuEntry('file-manager', 'Gestionnaire de Fichiers', Icons.folder),
  MenuEntry('admin', 'Administration', Icons.admin_panel_settings, [
    MenuEntry('user-list', 'Utilisateurs', Icons.people),
    MenuEntry('group-list', 'Groupes', Icons.group),
  ]),
];
