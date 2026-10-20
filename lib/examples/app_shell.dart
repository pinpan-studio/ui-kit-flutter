import 'package:flutter/material.dart';

import '../data/examples_data.dart';
import '../theme/kit_colors.dart';
import '../theme/theme_controller.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import 'app_examples.dart';
import 'ex_scaffold.dart';
import 'forms_examples.dart';

/// Entrée de navigation du shell (`ExNavItem`).
class ExNavItem {
  const ExNavItem(this.id, this.label, this.icon, this.builder, {this.badge, this.title, this.crumb});
  final String id, label;
  final IconData icon;
  final WidgetBuilder builder;
  final int? badge;

  /// Titre et fil d'Ariane de la barre supérieure (`title` / `crumb` de `ex-app-shell`).
  final String? title, crumb;
}

/// `EX_NAV_TOP`
final kExNavTop = [
  ExNavItem('dashboard', 'Tableau de bord', Icons.space_dashboard, (_) => const DashboardExample(), crumb: 'Accueil'),
  ExNavItem('monitoring', 'Supervision', Icons.monitor_heart, (_) => const MonitoringExample()),
  ExNavItem('modules', 'Modules', Icons.apps, (_) => const ModulesExample()),
];

/// `EX_NAV_GROUPS` : (libellé, icône, repliable, entrées)
final kExNavGroups = <(String, IconData, bool, List<ExNavItem>)>[
  ('Pilotage', Icons.insights, false, [
    ExNavItem('clients', 'Clients', Icons.group, (_) => const ClientsExample(), crumb: 'CRM'),
    ExNavItem('catalog', 'Catalogue', Icons.inventory_2, (_) => const CatalogExample()),
    ExNavItem('board', 'Planning', Icons.view_kanban, (_) => const BoardExample(), title: 'Déploiement Sotra', crumb: 'Projets'),
  ]),
  ('Communication', Icons.forum, false, [
    ExNavItem('inbox', 'Messagerie', Icons.inbox, (_) => const InboxExample(), badge: 2),
    ExNavItem('chat', 'Messagerie instantanée', Icons.chat, (_) => const ChatExample(), crumb: 'Communication'),
    ExNavItem('feed', 'Fil d’équipe', Icons.dynamic_feed, (_) => const FeedExample()),
  ]),
  ('Ressources', Icons.local_library, false, [
    ExNavItem('blog', 'Blog', Icons.newspaper, (_) => const BlogExample()),
    ExNavItem('docs', 'Documentation', Icons.menu_book, (_) => const DocsExample(), crumb: 'Ressources'),
    ExNavItem('files', 'Fichiers', Icons.folder, (_) => const FilesExample(), crumb: 'Ressources'),
  ]),
  ('Formulaires', Icons.dynamic_form, true, [
    ExNavItem('forms/contact', 'Contact', Icons.contact_mail, (_) => const ContactFormExample()),
    ExNavItem('forms/checkout', 'Commande', Icons.shopping_cart_checkout, (_) => const CheckoutFormExample()),
    ExNavItem('forms/booking', 'Réservation', Icons.event_available, (_) => const BookingFormExample()),
    ExNavItem('forms/application', 'Candidature', Icons.assignment_ind, (_) => const ApplicationFormExample()),
    ExNavItem('forms/onboarding', 'Assistant d’accueil', Icons.rocket_launch, (_) => const OnboardingFormExample()),
    ExNavItem('forms/survey', 'Questionnaire', Icons.quiz, (_) => const SurveyFormExample()),
  ]),
  ('Compte', Icons.manage_accounts, false, [
    ExNavItem('settings', 'Paramètres', Icons.settings, (_) => const SettingsExample(), crumb: 'Compte'),
  ]),
];

List<ExNavItem> get kExNav => [...kExNavTop, for (final g in kExNavGroups) ...g.$4];

/// Pages hors menu mais rendues dans le shell (fiche client, article, colonnes…).
final kExNavExtra = [
  ExNavItem('clients/:id', 'Fiche client', Icons.person, (_) => ClientDetailExample(), title: 'Cacao Plus', crumb: 'Clients'),
  ExNavItem('blog/:slug', 'Article', Icons.article, (_) => const ArticleExample(), crumb: 'Blog'),
  ExNavItem('files/columns', 'Fichiers · Colonnes', Icons.view_column, (_) => const FilesColumnsExample(), crumb: 'Ressources'),
];

/// Shell des écrans d'exemple (`ex-app-shell`) : sidenav fixe (carte flottante) à partir de 960 px,
/// tiroir superposé en dessous ; barre supérieure 68 px avec fil d'Ariane, recherche, thème,
/// messagerie, notifications et avatar. Les entrées du menu changent la page sans empiler de route.
class ExAppShell extends StatefulWidget {
  const ExAppShell({super.key, this.initial = 'dashboard'});
  final String initial;
  @override
  State<ExAppShell> createState() => _ExAppShellState();
}

class _ExAppShellState extends State<ExAppShell> {
  late String _id = widget.initial;
  String _search = '';
  bool _formsOpen = false;
  bool _sideOpen = true;
  final _key = GlobalKey<ScaffoldState>();

  ExNavItem get _item => [...kExNav, ...kExNavExtra].firstWhere((n) => n.id == _id, orElse: () => kExNavTop.first);

  void _go(String id) {
    setState(() => _id = id);
    if (_key.currentState?.isDrawerOpen ?? false) Navigator.of(context).pop();
  }

  bool _matches(String s) => _search.isEmpty || s.toLowerCase().contains(_search.toLowerCase());

  Widget _entry(ExNavItem n, {bool top = false}) {
    final c = context.kc;
    final on = n.id == _id || (_id.startsWith('${n.id}/') && !kExNav.any((x) => x.id == _id));
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: on ? c.primaryLight : Colors.transparent,
        borderRadius: BorderRadius.circular(Radii.sm),
        child: InkWell(
          borderRadius: BorderRadius.circular(Radii.sm),
          onTap: () => _go(n.id),
          child: Container(
            constraints: const BoxConstraints(minHeight: 44),
            padding: EdgeInsets.symmetric(horizontal: top ? Space.s4 : Space.s3),
            child: Row(children: [
              Icon(n.icon, size: top ? 18 : 16, color: on ? c.primary : c.textSecondary),
              const SizedBox(width: Space.s3),
              Expanded(child: Text(n.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: top ? 13 : 12.5, fontWeight: top || on ? FontWeight.w600 : FontWeight.w500, color: on ? c.textPrimary : c.textSecondary))),
              if (n.badge != null)
                Container(
                  margin: const EdgeInsets.only(left: Space.s2),
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                  decoration: BoxDecoration(color: c.hover, borderRadius: BorderRadius.circular(99)),
                  child: Text('${n.badge}', style: TextStyle(fontSize: 11, color: c.textSecondary)),
                ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _sidebar({required bool drawer}) {
    final c = context.kc;
    return Padding(
      padding: const EdgeInsets.all(Space.s2),
      child: Container(
        decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(Radii.xl), border: Border.all(color: c.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.s6, Space.s4, Space.s2, Space.s2),
            child: Row(children: [
              Image.asset('assets/images/logo.png', height: 30, errorBuilder: (_, _, _) => Icon(Icons.warehouse, color: c.primary)),
              const SizedBox(width: Space.s3),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('SC Storage', style: TextStyle(fontFamily: Fonts.heading, fontSize: 15, fontWeight: FontWeight.w700, color: c.textPrimary)),
                Text('Espace de travail', style: TextStyle(fontSize: 11, color: c.textMuted)),
              ])),
              if (drawer) IconButton(tooltip: 'Fermer le menu', icon: const Icon(Icons.chevron_left), onPressed: () => Navigator.of(context).pop()),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.s4, vertical: Space.s2),
            child: SizedBox(height: 44, child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(isDense: true, prefixIcon: Icon(Icons.search, size: 18), hintText: 'Rechercher une page…'),
            )),
          ),
          Expanded(child: ListView(padding: const EdgeInsets.all(Space.s4), children: [
            for (final n in kExNavTop) if (_matches(n.label)) _entry(n, top: true),
            for (final g in kExNavGroups)
              if (_matches(g.$1) || g.$4.any((n) => _matches(n.label))) ...[
                const SizedBox(height: Space.s3),
                InkWell(
                  borderRadius: BorderRadius.circular(Radii.md),
                  onTap: g.$3 ? () => setState(() => _formsOpen = !_formsOpen) : null,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 44),
                    padding: const EdgeInsets.symmetric(horizontal: Space.s4),
                    child: Row(children: [
                      Icon(g.$2, size: 18, color: c.textPrimary),
                      const SizedBox(width: Space.s3),
                      Expanded(child: Text(g.$1, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.textPrimary))),
                      if (g.$3) AnimatedRotation(turns: _formsOpen ? .5 : 0, duration: const Duration(milliseconds: 200), child: const Icon(Icons.expand_more, size: 18)),
                    ]),
                  ),
                ),
                if (!g.$3 || _formsOpen || _search.isNotEmpty)
                  Padding(padding: const EdgeInsets.only(left: Space.s4, top: Space.s1), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    for (final n in g.$4) if (_matches(n.label) || _matches(g.$1)) _entry(n),
                  ])),
              ],
          ])),
          Divider(height: 1, color: c.border),
          Padding(
            padding: const EdgeInsets.all(Space.s3),
            child: Row(children: [
              KitAvatar(name: kCurrentUser.fullname, size: 36),
              const SizedBox(width: Space.s3),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(kCurrentUser.fullname, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                Text(kCurrentUser.role, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: c.textMuted)),
              ])),
              IconButton(tooltip: 'Paramètres', icon: const Icon(Icons.settings_outlined, size: 20), onPressed: () => _go('settings')),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _badge(Widget icon, int n) => Badge(label: Text('$n'), backgroundColor: context.kc.error, child: icon);

  PreferredSizeWidget _topBar({required bool mobile}) {
    final c = context.kc;
    final it = _item;
    final title = it.title ?? it.label;
    final theme = ThemeController.instance;
    return PreferredSize(
      preferredSize: const Size.fromHeight(68),
      child: Container(
        height: 68,
        padding: EdgeInsets.symmetric(horizontal: mobile ? Space.s2 : Space.s4),
        color: c.bg,
        child: Row(children: [
          Builder(builder: (ctx) => IconButton(
            tooltip: mobile ? 'Afficher le menu' : (_sideOpen ? 'Masquer le menu' : 'Afficher le menu'),
            icon: Icon(mobile || !_sideOpen ? Icons.menu : Icons.menu_open),
            onPressed: () => mobile ? Scaffold.of(ctx).openDrawer() : setState(() => _sideOpen = !_sideOpen),
          )),
          const SizedBox(width: Space.s1),
          Expanded(child: Row(children: [
            if (!mobile && it.crumb != null) ...[
              Flexible(child: Text(it.crumb!, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: Fonts.heading, fontSize: 18, fontWeight: FontWeight.w700, color: c.textMuted))),
              Icon(Icons.chevron_right, size: 20, color: c.textMuted),
            ],
            Flexible(child: Text(title, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: Fonts.heading, fontSize: mobile ? 16 : 18, fontWeight: FontWeight.w700, color: c.textPrimary))),
          ])),
          if (mobile)
            IconButton(tooltip: 'Rechercher', icon: const Icon(Icons.search), onPressed: () => exDemo(context, 'Palette de commandes'))
          else
            Padding(
              padding: const EdgeInsets.only(right: Space.s2),
              child: Material(
                color: c.hover,
                borderRadius: BorderRadius.circular(22),
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () => exDemo(context, 'Palette de commandes'),
                  child: Container(
                    height: 44,
                    constraints: const BoxConstraints(minWidth: 220),
                    padding: const EdgeInsets.symmetric(horizontal: Space.s3),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.search, size: 19, color: c.textMuted),
                      const SizedBox(width: Space.s2),
                      Text('Rechercher…', style: TextStyle(fontSize: 13, color: c.textMuted)),
                      const SizedBox(width: Space.s6),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(border: Border.all(color: c.border), borderRadius: BorderRadius.circular(Radii.sm)), child: Text('Ctrl K', style: TextStyle(fontSize: 11, color: c.textMuted))),
                    ]),
                  ),
                ),
              ),
            ),
          if (!mobile) ...[
            IconButton(tooltip: 'Changer de thème', icon: Icon(theme.isDark ? Icons.light_mode : Icons.dark_mode), onPressed: theme.toggle),
            IconButton(tooltip: 'Personnaliser le thème', icon: const Icon(Icons.palette_outlined), onPressed: () => exDemo(context, 'Sélecteur de thème')),
          ],
          Builder(builder: (ctx) => IconButton(tooltip: 'Messages', icon: _badge(const Icon(Icons.chat_bubble_outline), kChatConversations.fold(0, (s, x) => s + x.unread)), onPressed: () => Scaffold.of(ctx).openEndDrawer())),
          IconButton(tooltip: 'Notifications', icon: _badge(const Icon(Icons.notifications_none), 3), onPressed: () => exDemo(context, 'Centre de notifications')),
          PopupMenuButton<String>(
            tooltip: 'Mon compte',
            onSelected: (v) => v == 'settings' ? _go('settings') : exDemo(context, v),
            itemBuilder: (_) => [
              PopupMenuItem(enabled: false, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(kCurrentUser.fullname, style: TextStyle(fontWeight: FontWeight.w600, color: c.textPrimary)), Text(kCurrentUser.mail, style: TextStyle(fontSize: 12, color: c.textMuted))])),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'settings', child: ListTile(leading: Icon(Icons.person), title: Text('Mon profil'))),
              const PopupMenuItem(value: 'settings', child: ListTile(leading: Icon(Icons.settings), title: Text('Paramètres'))),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'Verrouiller', child: ListTile(leading: Icon(Icons.lock), title: Text('Verrouiller'))),
              const PopupMenuItem(value: 'Se déconnecter', child: ListTile(leading: Icon(Icons.logout), title: Text('Se déconnecter'))),
            ],
            child: Padding(padding: const EdgeInsets.all(2), child: SizedBox.square(dimension: 44, child: Center(child: KitAvatar(name: kCurrentUser.fullname, size: 40)))),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        final mobile = box.maxWidth < Breakpoints.lg;
        final c = context.kc;
        final page = ExShellScope(child: KeyedSubtree(key: ValueKey(_id), child: Builder(builder: _item.builder)));
        return Scaffold(
          key: _key,
          backgroundColor: c.bg,
          drawer: mobile ? Drawer(width: box.maxWidth * .85 < 320 ? box.maxWidth * .85 : 320, backgroundColor: c.bg, child: SafeArea(child: _sidebar(drawer: true))) : null,
          endDrawer: const Drawer(width: 380, child: SafeArea(child: ChatPanel())),
          body: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (!mobile && _sideOpen) SizedBox(width: 272 + Space.s2 * 2, child: SafeArea(right: false, child: _sidebar(drawer: false))),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              SafeArea(bottom: false, left: mobile || !_sideOpen, child: _topBar(mobile: mobile)),
              Expanded(child: page),
            ])),
          ]),
        );
      });
}
