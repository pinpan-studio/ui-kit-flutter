# UI Kit Flutter — version mobile

Portage mobile (iOS / Android) du catalogue Angular `../ui-kit`, avec le même design system (palette M3 cyan / orange, Outfit / Inter, rayons 4 / 12 / 24, espacements 4 → 48) et les mêmes fonctionnalités, adaptées au tactile.
Comme l'original, il est **100 % statique** : aucune logique métier, aucun appel backend. Les seules requêtes réseau sont les tuiles des fonds de carte.

## Démarrer

```bash
flutter pub get
flutter run                     # simulateur iOS ou émulateur Android
flutter analyze                 # 0 problème attendu
flutter test                    # 148 tests : chaque écran monté en clair et en sombre + harnais
```

Prérequis : Flutter 3.41+ (Dart 3.11). Les polices (Inter, Outfit, Space Mono, TT Wellingtons) sont embarquées dans `assets/fonts`.

## Navigation

| Onglet | Contenu |
|---|---|
| **Showcase** | Couleurs (touchez une pastille pour copier sa valeur hex), typographie, espacements et rayons, icônes, accès au catalogue |
| **Composants** | 13 galeries, 147 sections : Typographie, Formulaires, Champs avancés, Boutons, Navigation, Data display, Feedback, Planning, Cartes, Médias, Interactions, Material, Layout |
| **Layouts** | 7 gabarits d'écran avec maquette et exemple vivant : shell applicatif, fiche détail, authentification, page publique, panneau latéral, dialogs, catalogue |
| **Harnais** | Assistant IA simulé : historique, réponses générées en flux, 33 types de widgets (carte, graphiques, tableau, formulaire, kanban, Gantt, arbre, diff, JSON…) |

Le menu ☰ ouvre un tiroir qui permet de chercher dans tout le catalogue et d'ouvrir directement une section. Chaque galerie a un sommaire en puces collant qui suit le défilement. Le bouton `</>` d'une démo affiche un extrait Dart prêt à copier.

## Architecture

```
lib/
├── main.dart                 MaterialApp (fr-FR, thème courant : couleur × clair / sombre / système)
├── theme/                    tokens.dart (Space, Radii, Fonts, Breakpoints), kit_text.dart,
│                             kit_palette.dart (palette tonale → ColorScheme M3), theme_palettes.dart (généré),
│                             kit_colors.dart (KitColors dérivés du ColorScheme + KitTone), app_theme.dart,
│                             theme_controller.dart (mode + couleur, ThemePickerButton, ThemeSettings),
│                             custom_theme.dart + theme_studio.dart (thème personnalisé, studio)
├── core/                     formats fr-FR (FCFA, dates), snackbars, typographie française
├── data/                     jeux de données statiques déterministes (clients, planning, carte, menu)
├── widgets/                  composants réutilisables du kit
│   ├── common.dart           StatusBadge, KitCard, KpiCard, EmptyState, Skeleton, KitPaginator, KitTextField…
│   ├── kit_buttons.dart      KitButton (9 variantes, 4 tailles, chargement), FilterChipButton, SplitButton
│   ├── selects.dart          SearchableSelect (feuille basse), MultiSelectField, FilterDropdown, EntityAutocomplete
│   ├── inputs.dart           MaskFormatter, champs date / période / heure, upload simulé, DropZone
│   ├── dialogs.dart          alerte, confirmation, prompt, feuille de formulaire, panneau latéral
│   ├── fields/               OTP, nombre ±, montant, notation, couleur, texte riche, Markdown, signature,
│   │                         tree-select, transfert, tags, mot de passe, copie, adresse avec carte
│   ├── data_table.dart       tableau mobile (cartes / tableau, tri, sélection, actions groupées, total)
│   ├── data_display.dart     timeline, liste descriptive, compteur animé, diff, audit log, QR / code-barres
│   ├── charts.dart           KitChart (8 types, fl_chart), Sparkline, RingGauge
│   ├── planning/             modèle PlanningItem + kanban, Gantt, notes, vue groupée, calendrier, agenda
│   ├── map/                  KitMap (flutter_map) : fonds gratuits, marqueurs, clustering, trajets, zones, dessin
│   ├── media/                lecteurs vidéo / audio / YouTube, PDF, visionneuse, carrousel, galeries, recadrage
│   ├── feedback.dart         KitAlert, GlobalBanner, ResultView, UploadQueue
│   ├── interaction.dart      palette de commandes, Popover, visite guidée, centre de notifications, menu contextuel
│   └── navigation.dart       Sidecar, Breadcrumb, StepsIndicator
├── showcase/                 le catalogue : doc/ (DocPage, DocSection, Demo), galeries, layouts, shell
└── harnais/                  modèle, catalogue de scénarios, store (génération simulée), widgets, écran
```

## Thèmes

41 thèmes de couleur Material 3, identiques à ceux du UI Kit Angular (mêmes palettes tonales,
générées par `ui-kit/tools/generate-themes.mjs` dans `lib/theme/theme_palettes.dart`), chacun en mode
clair, sombre ou système.

- Sélecteur : `ThemePickerButton` (barres d'outils) → bottom sheet avec `ThemeSettings`
  (bouton segmenté du mode + pastilles de couleur). Section « Thèmes » de l'écran UI Showcase.
- Code : `ThemeController.instance.setMode(ThemeMode.system)`, `ThemeController.instance.setPalette('red')`.
  `MaterialApp` reçoit `AppTheme.light(palette)` / `AppTheme.dark(palette)`.
- Les widgets lisent `Theme.of(context).colorScheme` (rôles M3) ou `context.kc` (jetons du kit dérivés
  du `ColorScheme`) : aucune couleur de marque n'est figée.
- `test/theme_test.dart` vérifie pour chaque thème × mode un contraste ≥ 4,5:1 entre chaque rôle et son
  rôle « on- ».
- **Studio de thème** (`ThemeStudioPage`, bouton du sélecteur ou section « Thèmes ») : couleur source,
  style M3 (dont **Noir & blanc**), contraste, couleurs imposées par rôle, aperçu clair / sombre,
  nuanciers 0 → 100, rôles avec contrastes, export du code Dart. Moteur : `lib/theme/custom_theme.dart`
  (`material_color_utilities`, la bibliothèque utilisée par `ColorScheme.fromSeed`).
- Le choix n'est pas persisté entre deux lancements (aucune dépendance de stockage ajoutée).

## Réutiliser un élément dans une app

1. Trouver le composant dans le catalogue, copier l'extrait du bouton `</>`.
2. Copier `lib/theme/` (obligatoire : couleurs et typographie passent par `context.kc` et `context.t`), puis le fichier du composant depuis `lib/widgets/`.
3. Remplacer les données de `lib/data/` par vos sources.

## Adaptations mobiles (écarts assumés vis-à-vis du web)

- **Sidebar du catalogue** → barre de navigation basse + tiroir recherchable ; **sidebar du shell** → `Sidecar` dans un tiroir (visible en permanence sur tablette ≥ 768 px).
- **Survol / clic droit** → appui long (tooltips, menus contextuels, glisser-déposer kanban) ; **raccourcis clavier** conservés avec clavier physique (⌘K / Ctrl+K), complétés par des gestes.
- **Overlays de sélection** → feuilles basses avec recherche ; **drawer droit 360 px** et **CrudDialog** → feuilles quasi plein écran (panneau latéral sur tablette).
- **Tables** → vue cartes par défaut, ou tableau défilant horizontalement à 1re colonne fixe.
- **Grilles multi-colonnes** → 1 colonne sous 600 px, 2 jusqu'à 960 px, 3 au-delà (mêmes points de rupture que `_breakpoints.scss`).
- **Leaflet** → `flutter_map` avec les mêmes fonds gratuits (Esri, OSM) ; le dessin (Leaflet Draw / Geoman) devient un outil point / ligne / zone au doigt ; le clustering est fait maison.
- **Chart.js** → `fl_chart` ; **CKEditor / Quill** → éditeur de texte riche maison ; **PDF / vidéo / audio** → lecteurs aux contrôles tactiles sur des médias générés localement (branchez `video_player`, `just_audio`, `pdfx` pour de vrais fichiers).
- **Upload** → sélecteur de fichiers de démonstration : aucun accès au stockage ni envoi réseau, pour rester statique.
- La galerie **Pages** du web n'a pas d'équivalent : son registre est vide dans le projet d'origine.
