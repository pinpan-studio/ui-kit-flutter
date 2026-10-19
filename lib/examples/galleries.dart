import 'package:flutter/material.dart';

import '../harnais/harnais_screen.dart';
import '../showcase/layouts/layout_demos.dart';
import '../theme/kit_colors.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import 'app_examples.dart';
import 'auth_examples.dart';
import 'examples_index.dart';
import 'forms_examples.dart';

// ─── Registre des showcases (`showcases.data.ts`) ───────────────────────────

enum ShowcaseDevice { desktop, tablet, phone }

extension ShowcaseDeviceX on ShowcaseDevice {
  String get label => switch (this) { ShowcaseDevice.desktop => 'Ordinateur', ShowcaseDevice.tablet => 'Tablette', ShowcaseDevice.phone => 'Mobile' };
  IconData get icon => switch (this) { ShowcaseDevice.desktop => Icons.desktop_windows_outlined, ShowcaseDevice.tablet => Icons.tablet_mac, ShowcaseDevice.phone => Icons.smartphone };
  Size get size => switch (this) { ShowcaseDevice.desktop => const Size(1440, 900), ShowcaseDevice.tablet => const Size(820, 1180), ShowcaseDevice.phone => const Size(390, 844) };
}

class Showcase {
  const Showcase(this.id, this.group, this.label, this.icon, this.path, this.tags, this.builder, {this.note});
  final String id, group, label, path;
  final IconData icon;
  final List<String> tags;
  final WidgetBuilder builder;

  /// Choix d'adaptation Flutter, quand l'entrée Angular n'a pas de page dédiée.
  final String? note;
}

const kShowcaseGroups = [
  ('modules', 'Modules', Icons.apps, 'Les sous-modules du kit, tels qu’ils s’affichent dans l’application.'),
  ('auth', 'Authentification', Icons.lock_outline, 'Connexion, inscription, récupération et vérification, sous plusieurs dispositions de formulaire.'),
  ('forms', 'Formulaires', Icons.dynamic_form_outlined, 'Formulaires complets : contact, commande, assistant, questionnaire, réservation, candidature.'),
  ('content', 'Contenu éditorial', Icons.auto_stories_outlined, 'Typographie de lecture et discussions : blog, article, documentation, fil d’équipe.'),
  ('layouts', 'Dispositions d’application', Icons.space_dashboard_outlined, 'Gabarits complets : navigation, modules, listes de données, détail, tableaux de bord.'),
];

final List<Showcase> kShowcases = [
  Showcase('main', 'modules', 'Main', Icons.space_dashboard_outlined, '/main', const ['shell', 'rail', 'drawer'], (_) => const AppShellDemo()),
  Showcase('harnais', 'modules', 'Harnais · accueil', Icons.auto_awesome_outlined, '/harnais', const ['IA', 'chat'], (_) => const HarnaisScreen()),
  Showcase('harnais-conversation', 'modules', 'Harnais · conversation', Icons.forum_outlined, '/harnais/c-sidecar', const ['IA', 'artefact'], (_) => const HarnaisScreen(initialConversation: 'c-sidecar'),
      note: 'Harnais existant, ouvert directement sur la conversation c-sidecar.'),
  for (final id in kAuthVariants.keys)
    Showcase('auth-$id', 'auth', kAuthLabels[id]!, Icons.login, '/examples/auth/$id', const ['authentification'], (_) => AuthExample(variant: id)),
  Showcase('form-contact', 'forms', 'Contact', Icons.contact_mail_outlined, '/examples/forms/contact', const ['validation'], (_) => const ContactFormExample()),
  Showcase('form-checkout', 'forms', 'Commande & paiement', Icons.shopping_cart_checkout, '/examples/forms/checkout', const ['Mobile Money', 'carte', 'récapitulatif'], (_) => const CheckoutFormExample()),
  Showcase('form-onboarding', 'forms', 'Assistant d’accueil', Icons.rocket_launch_outlined, '/examples/forms/onboarding', const ['wizard', 'invitations'], (_) => const OnboardingFormExample()),
  Showcase('form-survey', 'forms', 'Questionnaire', Icons.quiz_outlined, '/examples/forms/survey', const ['NPS', 'notation'], (_) => const SurveyFormExample()),
  Showcase('form-booking', 'forms', 'Réservation', Icons.event_available, '/examples/forms/booking', const ['créneaux'], (_) => const BookingFormExample()),
  Showcase('form-application', 'forms', 'Candidature', Icons.assignment_ind_outlined, '/examples/forms/application', const ['formulaire long', 'signature'], (_) => const ApplicationFormExample()),
  Showcase('content-article', 'content', 'Article', Icons.article_outlined, '/examples/app/blog/:slug', const ['typographie'], (_) => const ArticleExample()),
  Showcase('content-blog', 'content', 'Blog', Icons.auto_stories_outlined, '/examples/app/blog', const ['articles'], (_) => const BlogExample()),
  Showcase('content-docs', 'content', 'Documentation', Icons.menu_book_outlined, '/examples/app/docs', const ['sommaire'], (_) => const DocsExample()),
  Showcase('content-feed', 'content', 'Fil d’équipe', Icons.dynamic_feed_outlined, '/examples/app/feed', const ['publications'], (_) => const FeedExample()),
  Showcase('app-dashboard', 'layouts', 'Tableau de bord', Icons.dashboard_outlined, '/examples/app/dashboard', const ['KPI', 'graphiques'], (_) => const DashboardExample()),
  Showcase('app-list', 'layouts', 'Liste de données', Icons.table_rows_outlined, '/examples/app/clients', const ['table', 'filtres'], (_) => const ClientsExample(),
      note: 'Même page que Clients, comme côté Angular (même route).'),
  Showcase('app-detail', 'layouts', 'Fiche détail', Icons.article_outlined, '/examples/app/clients/c-104', const ['onglets', 'KPI'], (_) => ClientDetailExample()),
  Showcase('app-inbox', 'layouts', 'Maître / détail', Icons.mark_email_unread_outlined, '/examples/app/inbox', const ['split', 'messagerie'], (_) => const InboxExample()),
  Showcase('app-catalog', 'layouts', 'Catalogue en grille', Icons.grid_view, '/examples/app/catalog', const ['cartes'], (_) => const CatalogExample()),
  Showcase('app-kanban', 'layouts', 'Tableau kanban', Icons.view_kanban_outlined, '/examples/app/board', const ['kanban'], (_) => const BoardExample()),
  Showcase('app-modules', 'layouts', 'Lanceur de modules', Icons.apps, '/examples/app/modules', const ['tuiles'], (_) => const ModulesExample()),
  Showcase('app-files', 'layouts', 'Gestionnaire de fichiers', Icons.folder_open_outlined, '/examples/app/files', const ['grille / liste'], (_) => const FilesExample()),
  Showcase('app-files-columns', 'layouts', 'Fichiers en colonnes', Icons.view_week_outlined, '/examples/app/files/columns', const ['Finder'], (_) => const FilesColumnsExample()),
  Showcase('app-monitoring', 'layouts', 'Supervision', Icons.monitor_heart_outlined, '/examples/app/monitoring', const ['incidents'], (_) => const MonitoringExample()),
  Showcase('app-chat', 'layouts', 'Messagerie instantanée', Icons.chat_outlined, '/examples/app/chat', const ['plein écran'], (_) => const ChatExample()),
  Showcase('app-chat-panel', 'layouts', 'Messagerie en panneau latéral', Icons.view_sidebar_outlined, '/examples/app/dashboard?chat=c-aya', const ['panneau droit'], (_) => const DashboardExample(openChat: true),
      note: 'Tableau de bord avec la messagerie (ChatPanel) ouverte en tiroir latéral droit.'),
  Showcase('app-file-picker', 'layouts', 'Sélecteur de fichiers (modale)', Icons.file_open_outlined, '/examples/app/files?picker=1', const ['modale', 'sélection multiple'], (_) => const FilesExample(openPicker: true),
      note: 'Gestionnaire de fichiers qui ouvre la modale showFilePicker au démarrage.'),
  Showcase('app-settings', 'layouts', 'Paramètres', Icons.settings_outlined, '/examples/app/settings', const ['sous-navigation'], (_) => const SettingsExample()),
];

Widget _groupTitle(BuildContext context, String t) => Padding(
      padding: const EdgeInsets.fromLTRB(Space.s1, Space.s6, 0, Space.s3),
      child: Text(t.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1, color: context.kc.textMuted)),
    );

// ─── /showcases ─────────────────────────────────────────────────────────────
class ShowcasesGallery extends StatelessWidget {
  const ShowcasesGallery({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return Scaffold(
      appBar: AppBar(title: const Text('Showcases')),
      body: ListView(padding: const EdgeInsets.all(Space.s4), children: [
        Text('${kShowcases.length} écrans complets, à prévisualiser en ordinateur, tablette ou mobile.', style: TextStyle(color: c.textMuted)),
        for (final g in kShowcaseGroups) ...[
          _groupTitle(context, g.$2),
          Text(g.$4, style: TextStyle(fontSize: 13, color: c.textSecondary)),
          const SizedBox(height: Space.s3),
          ResponsiveGrid(minItemWidth: 260, spacing: Space.s3, children: [
            for (final s in kShowcases.where((s) => s.group == g.$1))
              KitCard(
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ShowcaseViewer(id: s.id))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(s.icon, color: c.primary),
                    const SizedBox(width: Space.s3),
                    Expanded(child: Text(s.label, style: const TextStyle(fontWeight: FontWeight.w600))),
                    Icon(Icons.chevron_right, color: c.textMuted),
                  ]),
                  const SizedBox(height: Space.s2),
                  Text(s.path, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: Fonts.mono, fontSize: 11, color: c.textMuted)),
                  const SizedBox(height: Space.s2),
                  Wrap(spacing: Space.s1, runSpacing: Space.s1, children: [for (final t in s.tags) StatusBadge(t, uppercase: false)]),
                ]),
              ),
          ]),
        ],
      ]),
    );
  }
}

// ─── /showcases/:id ─────────────────────────────────────────────────────────
class ShowcaseViewer extends StatefulWidget {
  const ShowcaseViewer({super.key, required this.id, this.device});
  final String id;
  final ShowcaseDevice? device;
  @override
  State<ShowcaseViewer> createState() => _ShowcaseViewerState();
}

class _ShowcaseViewerState extends State<ShowcaseViewer> {
  late int _index = kShowcases.indexWhere((s) => s.id == widget.id).clamp(0, kShowcases.length - 1);
  ShowcaseDevice? _device;
  bool _landscape = false;
  int _reload = 0;

  Showcase get _s => kShowcases[_index];

  void _go(int delta) => setState(() { _index = (_index + delta + kShowcases.length) % kShowcases.length; _reload++; });

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final screen = MediaQuery.sizeOf(context);
    // Par défaut : l'appareil qui correspond à l'écran réel.
    final device = _device ?? widget.device ?? (screen.width < Breakpoints.tablet ? ShowcaseDevice.phone : screen.width < Breakpoints.xl ? ShowcaseDevice.tablet : ShowcaseDevice.desktop);
    var size = device.size;
    if (_landscape && device != ShowcaseDevice.desktop) size = size.flipped;

    return Scaffold(
      appBar: AppBar(
        title: Text(_s.label, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(tooltip: 'Précédent', icon: const Icon(Icons.chevron_left), onPressed: () => _go(-1)),
          IconButton(tooltip: 'Suivant', icon: const Icon(Icons.chevron_right), onPressed: () => _go(1)),
          IconButton(tooltip: 'Ouvrir en plein écran', icon: const Icon(Icons.open_in_full), onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: _s.builder))),
        ],
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Space.s4, Space.s2, Space.s4, Space.s2),
          child: Wrap(spacing: Space.s2, runSpacing: Space.s2, crossAxisAlignment: WrapCrossAlignment.center, children: [
            SegmentedButton<ShowcaseDevice>(
              showSelectedIcon: false,
              segments: [for (final d in ShowcaseDevice.values) ButtonSegment(value: d, icon: Icon(d.icon), tooltip: d.label, label: screen.width < Breakpoints.sm ? null : Text(d.label))],
              selected: {device},
              onSelectionChanged: (s) => setState(() => _device = s.first),
            ),
            IconButton.outlined(tooltip: 'Pivoter', icon: const Icon(Icons.screen_rotation), onPressed: device == ShowcaseDevice.desktop ? null : () => setState(() => _landscape = !_landscape)),
            IconButton.outlined(tooltip: 'Recharger', icon: const Icon(Icons.refresh), onPressed: () => setState(() => _reload++)),
            Text('${size.width.round()} × ${size.height.round()}', style: TextStyle(fontFamily: Fonts.mono, fontSize: 12, color: c.textMuted)),
          ]),
        ),
        if (_s.note != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.s4),
            child: Text(_s.note!, style: TextStyle(fontSize: 12, color: c.textSecondary)),
          ),
        Expanded(
          child: Container(
            color: c.hover,
            padding: const EdgeInsets.all(Space.s4),
            child: FittedBox(
              // Cadre d'appareil : la page est rendue à la taille réelle de l'appareil, puis réduite.
              child: Container(
                width: size.width + 2 * Space.s3,
                height: size.height + 2 * Space.s3,
                padding: const EdgeInsets.all(Space.s3),
                decoration: BoxDecoration(color: const Color(0xFF1F2937), borderRadius: BorderRadius.circular(device == ShowcaseDevice.desktop ? Radii.md : Radii.x2l), boxShadow: Elevations.e3(Theme.of(context).brightness)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(device == ShowcaseDevice.desktop ? Radii.sm : Radii.lg),
                  child: MediaQuery(
                    data: MediaQuery.of(context).copyWith(size: size, padding: EdgeInsets.zero, viewPadding: EdgeInsets.zero, viewInsets: EdgeInsets.zero),
                    child: SizedBox.fromSize(
                      size: size,
                      // Navigator imbriqué : les pages poussées restent dans le cadre.
                      child: Navigator(key: ValueKey('${_s.id}-$_reload'), onGenerateRoute: (_) => MaterialPageRoute<void>(builder: _s.builder)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// ─── /pages ─────────────────────────────────────────────────────────────────

/// Type de page (`PageEntry.kind`), déduit de la route.
String _kindOf(String id) {
  if (id.startsWith('auth/')) return 'Authentification';
  if (id.startsWith('forms/onboarding') || id.startsWith('forms/checkout') || id.startsWith('forms/survey')) return 'Assistant';
  if (id.startsWith('forms/')) return 'Formulaire';
  if (id.contains('dashboard') || id.contains('monitoring')) return 'Tableau de bord';
  if (id.contains('settings')) return 'Paramètres';
  if (id.contains('board')) return 'Kanban';
  if (id.contains(':')) return 'Détail';
  if (id.contains('clients') || id.contains('inbox') || id.contains('files') || id.contains('catalog')) return 'Liste';
  if (id.contains('blog') || id.contains('docs') || id.contains('feed')) return 'Publique';
  return 'Autre';
}

class PagesGallery extends StatefulWidget {
  const PagesGallery({super.key});
  @override
  State<PagesGallery> createState() => _PagesGalleryState();
}

class _PagesGalleryState extends State<PagesGallery> {
  String _q = '', _kind = '';

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final kinds = {for (final g in kExampleGroups) for (final e in g.$2) _kindOf(e.$1)}.toList()..sort();
    final q = _q.toLowerCase().trim();
    final groups = [
      for (final g in kExampleGroups)
        (g.$1, [for (final e in g.$2) if ((_kind.isEmpty || _kindOf(e.$1) == _kind) && (q.isEmpty || '${e.$1} ${e.$2} ${e.$3} ${g.$1}'.toLowerCase().contains(q))) e]),
    ].where((g) => g.$2.isNotEmpty).toList();
    final count = groups.fold(0, (n, g) => n + g.$2.length);

    return Scaffold(
      appBar: AppBar(title: const Text('Galerie des pages')),
      body: ListView(padding: const EdgeInsets.all(Space.s4), children: [
        TextField(onChanged: (v) => setState(() => _q = v), decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Rechercher une page, une route…')),
        const SizedBox(height: Space.s3),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            Padding(padding: const EdgeInsets.only(right: Space.s2), child: ChoiceChip(label: const Text('Tous les types'), selected: _kind.isEmpty, onSelected: (_) => setState(() => _kind = ''))),
            for (final k in kinds) Padding(padding: const EdgeInsets.only(right: Space.s2), child: ChoiceChip(label: Text(k), selected: _kind == k, onSelected: (_) => setState(() => _kind = k))),
          ]),
        ),
        const SizedBox(height: Space.s2),
        Text('$count page${count > 1 ? 's' : ''}', style: TextStyle(color: c.textMuted)),
        if (groups.isEmpty) const EmptyState(icon: Icons.search_off, title: 'Aucune page', subtitle: 'Ajustez votre recherche ou le filtre de type.'),
        for (final g in groups) ...[
          _groupTitle(context, '${g.$1} (${g.$2.length})'),
          ResponsiveGrid(minItemWidth: 260, spacing: Space.s3, children: [
            for (final e in g.$2)
              KitCard(
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: e.$5)),
                child: Row(children: [
                  Icon(e.$4, color: c.primary),
                  const SizedBox(width: Space.s3),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(e.$2, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text('/examples/${e.$1}', overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: Fonts.mono, fontSize: 11, color: c.textMuted)),
                    const SizedBox(height: Space.s1),
                    StatusBadge(_kindOf(e.$1), uppercase: false),
                  ])),
                ]),
              ),
          ]),
        ],
      ]),
    );
  }
}
