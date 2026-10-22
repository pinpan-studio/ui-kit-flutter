import 'package:flutter/material.dart';

import 'components/buttons_gallery.dart';
import 'components/data_gallery.dart';
import 'components/feedback_gallery.dart';
import 'components/fields_gallery.dart';
import 'components/forms_gallery.dart';
import 'components/interactions_gallery.dart';
import 'components/layout_gallery.dart';
import 'components/maps_gallery.dart';
import 'components/material_gallery.dart';
import 'components/media_gallery.dart';
import 'components/navigation_gallery.dart';
import 'components/planning_gallery.dart';
import 'components/typography_gallery.dart';
import 'kit_shell.dart';

typedef GalleryBuilder = Widget Function(String? initialSection);

/// Catégorie du catalogue (`COMPONENT_CATEGORIES` de `kit-nav.ts`), avec la liste
/// de ses sections pour la recherche globale et le menu latéral.
class KitCategory {
  const KitCategory({required this.id, required this.label, required this.icon, required this.description, required this.sections, required this.builder});

  final String id, label, description;
  final IconData icon;
  final List<(String, String)> sections;
  final GalleryBuilder builder;
}

final List<KitCategory> kCategories = [
  KitCategory(
    id: 'typography',
    label: 'Typographie',
    icon: Icons.text_fields,
    description: 'Familles, échelle, hiérarchie, graisses, interlignage, interlettrage, mesure, contraste, chiffres, troncature, typographie française, tailles fluides, testeur.',
    sections: const [
      ('families', 'Familles de polices'),
      ('scale', 'Échelle typographique'),
      ('hierarchy', 'Hiérarchie & rythme'),
      ('weights', 'Graisses'),
      ('line-height', 'Interlignage'),
      ('tracking', 'Interlettrage'),
      ('measure', 'Longueur de ligne'),
      ('color', 'Couleur & contraste'),
      ('alignment', 'Alignement & césure'),
      ('numbers', 'Chiffres & formats'),
      ('overflow', 'Troncature'),
      ('inline', 'Styles en ligne'),
      ('prose', 'Contenu éditorial'),
      ('french', 'Typographie française'),
      ('fluid', 'Typographie fluide'),
      ('a11y', 'Accessibilité'),
      ('playground', 'Testeur'),
    ],
    builder: (s) => TypographyGallery(initialSection: s),
  ),
  KitCategory(
    id: 'forms',
    label: 'Formulaires',
    icon: Icons.edit_note,
    description: 'Input, textarea, select, autocomplete, dates, checkbox, radio, toggle, upload, recherche, validation.',
    sections: const [
      ('input', 'Input'),
      ('input-material', 'Input Material'),
      ('textarea', 'Textarea'),
      ('mask', 'Masque de saisie'),
      ('select', 'Select'),
      ('multi-select', 'Multi-select'),
      ('autocomplete', 'Autocomplete'),
      ('date', 'Date picker'),
      ('date-range', 'Date range'),
      ('time', 'Time picker'),
      ('checkbox', 'Checkbox'),
      ('radio', 'Radio'),
      ('toggle', 'Toggle'),
      ('slider', 'Slider'),
      ('upload', 'File upload'),
      ('search', 'Search'),
      ('validation', 'Form validation'),
      ('crud-dialog', 'Formulaire en modale'),
    ],
    builder: (s) => FormsGallery(initialSection: s),
  ),
  KitCategory(
    id: 'fields',
    label: 'Champs avancés',
    icon: Icons.dynamic_form,
    description: 'OTP, nombre +/−, montant FCFA, intervalle, notation, couleur, texte riche, Markdown, signature, tree-select, transfert, tags, adresse, mot de passe, copie.',
    sections: const [
      ('otp', 'Code OTP / PIN'),
      ('stepper', 'Nombre + / −'),
      ('currency', 'Montant / devise'),
      ('range', 'Intervalle'),
      ('rating', 'Notation'),
      ('color', 'Sélecteur de couleur'),
      ('rich-text', 'Texte riche'),
      ('markdown', 'Markdown'),
      ('signature', 'Signature'),
      ('tree-select', 'Sélection arborescente'),
      ('transfer', 'Liste de transfert'),
      ('tags', 'Tags'),
      ('address', 'Adresse avec carte'),
      ('password', 'Mot de passe'),
      ('copy', 'Valeur à copier'),
      ('form', 'Formulaire complet'),
    ],
    builder: (s) => FieldsGallery(initialSection: s),
  ),
  KitCategory(
    id: 'buttons',
    label: 'Boutons',
    icon: Icons.smart_button,
    description: 'Primary, secondary, outline, ghost, danger, success, icône, loading, disabled.',
    sections: const [
      ('variants', 'Variantes'),
      ('states', 'États'),
      ('icon', 'Icon buttons'),
      ('header', 'Actions de page'),
      ('segmented', 'Segmentés & toggles'),
      ('menu', 'Menu & split'),
      ('fab', 'FAB'),
      ('sizes', 'Tailles & formes'),
    ],
    builder: (s) => ButtonsGallery(initialSection: s),
  ),
  KitCategory(
    id: 'navigation',
    label: 'Navigation',
    icon: Icons.explore,
    description: 'Header, sidebar, navbar, onglets, breadcrumb, pagination, stepper, menus.',
    sections: const [
      ('header', 'Header'),
      ('sidebar', 'Sidebar / drawer'),
      ('navbar', 'Barre de navigation'),
      ('tabs', 'Tabs'),
      ('breadcrumb', 'Breadcrumb'),
      ('pagination', 'Pagination'),
      ('stepper', 'Stepper'),
      ('menu', 'Menu'),
    ],
    builder: (s) => NavigationGallery(initialSection: s),
  ),
  KitCategory(
    id: 'data',
    label: 'Data display',
    icon: Icons.table_chart,
    description: 'Tables (dont table avancée), cartes, listes, liste descriptive, timeline, badges, avatars, compteurs, graphiques, diff, audit log, QR code.',
    sections: const [
      ('table', 'Table'),
      ('table-states', 'États de table'),
      ('advanced-table', 'Table avancée'),
      ('cards', 'Cards'),
      ('list', 'List'),
      ('description-list', 'Liste descriptive'),
      ('timeline', 'Timeline'),
      ('badge', 'Badge'),
      ('chip', 'Chip'),
      ('avatar', 'Avatar'),
      ('stats', 'Statistics cards'),
      ('counters', 'Compteurs animés'),
      ('charts', 'Graphiques'),
      ('diff', 'Diff'),
      ('audit', 'Audit log'),
      ('qr', 'QR code & code-barres'),
      ('empty', 'Empty state'),
    ],
    builder: (s) => DataGallery(initialSection: s),
  ),
  KitCategory(
    id: 'feedback',
    label: 'Feedback',
    icon: Icons.notifications_active,
    description: 'Alertes, toasts, modales, drawers, confirmation, loaders, skeletons, erreurs, upload multiple, bannière hors ligne, page de résultat, annulation.',
    sections: const [
      ('alert', 'Alert'),
      ('toast', 'Toast / Snackbar'),
      ('modal', 'Modal'),
      ('dialog', 'Dialog'),
      ('confirm', 'Confirmation'),
      ('drawer', 'Drawer / bottom sheet'),
      ('tooltip', 'Tooltip'),
      ('loading', 'Loading'),
      ('skeleton', 'Skeleton'),
      ('error', 'Error state'),
      ('upload-queue', 'Envoi multiple'),
      ('banner', 'Bannière globale'),
      ('result', 'Page de résultat'),
      ('undo', 'Snackbar « Annuler »'),
    ],
    builder: (s) => FeedbackGallery(initialSection: s),
  ),
  KitCategory(
    id: 'planning',
    label: 'Planning',
    icon: Icons.view_timeline,
    description: 'Kanban, Gantt, notes, vue groupée, calendrier, agenda — modèle générique et filtres optionnels.',
    sections: const [
      ('model', 'Modèle & options'),
      ('kanban', 'Kanban'),
      ('timeline', 'Timeline / Gantt'),
      ('notes', 'Grille de notes'),
      ('grouped', 'Vue groupée'),
      ('calendar', 'Calendrier'),
      ('agenda', 'Agenda'),
    ],
    builder: (s) => PlanningGallery(initialSection: s),
  ),
  KitCategory(
    id: 'maps',
    label: 'Cartes',
    icon: Icons.map,
    description: 'Fonds gratuits, marqueurs, clustering, trajets, zones, dessin, mode sombre.',
    sections: const [
      ('basemaps', 'Fonds de carte'),
      ('markers', 'Marqueurs'),
      ('cluster', 'Clustering'),
      ('routes', 'Trajets'),
      ('zones', 'Zones / géofences'),
      ('draw', 'Dessin'),
      ('compact', 'Carte compacte'),
      ('states', 'États'),
    ],
    builder: (s) => MapsGallery(initialSection: s),
  ),
  KitCategory(
    id: 'media',
    label: 'Médias',
    icon: Icons.perm_media,
    description: 'Lecteur vidéo, YouTube, lecteur audio, PDF, visionneuse de fichiers, carrousel, recadrage d’image.',
    sections: const [
      ('video', 'Lecteur vidéo'),
      ('youtube', 'Lecteur YouTube'),
      ('audio', 'Lecteur audio'),
      ('pdf', 'Lecteur PDF'),
      ('viewer', 'Visionneuse de fichiers'),
      ('carousel', 'Carrousel'),
      ('image-gallery', 'Galerie d’images'),
      ('video-gallery', 'Galerie vidéo'),
      ('masonry', 'Grille masonry'),
      ('cropper', 'Recadrage d’image'),
    ],
    builder: (s) => MediaGallery(initialSection: s),
  ),
  KitCategory(
    id: 'interactions',
    label: 'Interactions',
    icon: Icons.touch_app,
    description: 'Palette de commandes, raccourcis et gestes, popover riche, visite guidée, centre de notifications, menu contextuel.',
    sections: const [
      ('palette', 'Palette de commandes'),
      ('shortcuts', 'Raccourcis & gestes'),
      ('popover', 'Popover riche'),
      ('tour', 'Visite guidée'),
      ('notifications', 'Centre de notifications'),
      ('context-menu', 'Menu contextuel'),
    ],
    builder: (s) => InteractionsGallery(initialSection: s),
  ),
  KitCategory(
    id: 'material',
    label: 'Material',
    icon: Icons.extension,
    description: 'Accordion, tree, drag & drop, chips input, card, grid list, bottom sheet, virtual scroll, ripple.',
    sections: const [
      ('accordion', 'Accordion'),
      ('tree', 'Tree'),
      ('drag-drop', 'Drag & drop'),
      ('chips-input', 'Chips input'),
      ('card', 'Card'),
      ('grid-list', 'Grid list'),
      ('bottom-sheet', 'Bottom sheet'),
      ('virtual-scroll', 'Virtual scroll'),
      ('ripple', 'Ripple'),
    ],
    builder: (s) => MaterialGallery(initialSection: s),
  ),
  KitCategory(
    id: 'layout',
    label: 'Layout',
    icon: Icons.dashboard_customize,
    description: 'Page layout, dashboard, colonnes, sidebar, pleine largeur, sections, conteneurs responsive.',
    sections: const [
      ('page', 'Page layout'),
      ('dashboard', 'Dashboard layout'),
      ('two-cols', 'Deux colonnes'),
      ('three-cols', 'Trois colonnes'),
      ('sidebar', 'Sidebar layout'),
      ('full', 'Pleine largeur'),
      ('sections', 'Card sections'),
      ('responsive', 'Conteneurs responsive'),
      ('breakpoints', 'Breakpoints'),
    ],
    builder: (s) => LayoutGallery(initialSection: s),
  ),
];

/// Ouvre une galerie (éventuellement positionnée sur une section).
void openCategory(BuildContext context, KitCategory cat, [String? section]) {
  // Dans le shell, les galeries s'ouvrent dans l'onglet Composants (barre du bas visible).
  final shell = KitShell.of(context);
  if (shell != null) return shell.openInComponents(cat.builder(section));
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => cat.builder(section)));
}

KitCategory categoryById(String id) => kCategories.firstWhere((c) => c.id == id);
