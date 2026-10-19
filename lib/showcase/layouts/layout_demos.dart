import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/snack.dart';
import '../../data/menu_data.dart';
import '../../data/showcase_data.dart';
import '../../theme/kit_colors.dart';
import '../../theme/kit_text.dart';
import '../../theme/theme_controller.dart';
import '../../theme/tokens.dart';
import '../../widgets/charts.dart';
import '../../widgets/common.dart';
import '../../widgets/data_display.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/fields/basic_fields.dart';
import '../../widgets/interaction.dart';
import '../../widgets/kit_buttons.dart';
import '../../widgets/navigation.dart';

// ═══════════════════════════════════════════════════════════════════
// Exemples vivants des gabarits d'écran (ouverts depuis /layouts).
// ═══════════════════════════════════════════════════════════════════

/// Shell applicatif mobile : barre d'application, tiroir (Sidecar), barre basse,
/// panneaux de compte / notifications / paramètres en feuilles.
class AppShellDemo extends StatefulWidget {
  const AppShellDemo({super.key});

  @override
  State<AppShellDemo> createState() => _AppShellDemoState();
}

class _AppShellDemoState extends State<AppShellDemo> {
  int _tab = 0;
  String _menu = 'dashboard';
  int _unread = 3;

  String get _title => switch (_tab) { 0 => 'Tableau de bord', 1 => 'Clients', 2 => 'Interventions', _ => 'Compte' };

  void _openProfile() => showSidePanel(context, title: 'Paramètres du compte', icon: Icons.manage_accounts, child: const _AccountPanel());

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final wide = MediaQuery.sizeOf(context).width >= Breakpoints.tablet;
    final body = switch (_tab) {
      0 => const _DashboardBody(),
      1 => const _ClientsBody(),
      2 => const _InterventionsBody(),
      _ => const _AccountPanel(),
    };
    return Scaffold(
      drawer: wide
          ? null
          : Drawer(
              width: 300,
              child: SafeArea(
                child: Sidecar(
                  items: kDemoMenu,
                  selected: _menu,
                  onSelect: (m) {
                    setState(() => _menu = m.id);
                    Navigator.pop(context);
                    showKitSnack(context, 'Module : ${m.label}');
                  },
                ),
              ),
            ),
      appBar: AppBar(
        title: Text(_title),
        actions: [
          IconButton(tooltip: 'Rechercher', onPressed: () => showCommandPalette(context, [for (final m in kDemoMenu) PaletteCommand(m.label, m.icon, 'Modules')]), icon: const Icon(Icons.search)),
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => showSidePanel(
              context,
              title: 'Notifications',
              icon: Icons.notifications,
              child: SingleChildScrollView(padding: const EdgeInsets.all(Space.s4), child: NotificationCenter(onUnreadChanged: (n) => setState(() => _unread = n))),
            ),
            icon: Badge(isLabelVisible: _unread > 0, label: Text('$_unread'), child: const Icon(Icons.notifications_outlined)),
          ),
          Padding(
            padding: const EdgeInsets.only(right: Space.s3, left: Space.s1),
            child: GestureDetector(onTap: _openProfile, child: const KitAvatar(name: 'Jean Kouassi', size: 32, online: true)),
          ),
        ],
      ),
      body: Row(children: [
        if (wide) Sidecar(items: kDemoMenu, selected: _menu, onSelect: (m) => setState(() => _menu = m.id)),
        Expanded(child: body),
      ]),
      floatingActionButton: _tab == 2 ? FloatingActionButton.extended(onPressed: () => demoAction(context, 'Nouvelle intervention'), icon: const Icon(Icons.add), label: const Text('Mission')) : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Accueil'),
          const NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Clients'),
          NavigationDestination(icon: Badge(label: const Text('4'), backgroundColor: c.primary, child: const Icon(Icons.build_outlined)), selectedIcon: const Icon(Icons.build), label: 'Missions'),
          const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Compte'),
        ],
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => Future<void>.delayed(const Duration(milliseconds: 800)),
      child: ListView(padding: const EdgeInsets.all(Space.s4), children: [
        Text('Bonjour Jean 👋', style: context.t.h3),
        Text(Fmt.weekday(DateTime.now()), style: context.t.bodySm),
        const SizedBox(height: 14),
        const ResponsiveGrid(minItemWidth: 160, spacing: 10, children: [
          KpiCard(icon: Icons.local_shipping, value: '42', label: 'Véhicules actifs', tone: KitTone.primary),
          KpiCard(icon: Icons.warning_amber, value: '5', label: 'Alertes', tone: KitTone.warning),
          KpiCard(icon: Icons.build, value: '4', label: 'Missions du jour', tone: KitTone.info),
          KpiCard(icon: Icons.payments, value: '55,8 M', label: 'CA du mois', tone: KitTone.success),
        ]),
        const SizedBox(height: 12),
        KitCard(title: 'Chiffre d’affaires', icon: Icons.show_chart, child: KitChart(kind: ChartKind.area, labels: kMois.sublist(0, 10), series: [ChartSeries('2026', kCa2026.sublist(0, 10)), ChartSeries('2025', kCa2025.sublist(0, 10))], height: 170, compactValues: true)),
        const SizedBox(height: 12),
        KitCard(
          title: 'Activité récente',
          icon: Icons.history,
          child: KitTimeline(dense: true, items: [for (final e in kTimelineEvents) TimelineEntry(title: e.titre, text: e.texte, time: Fmt.time(e.date), icon: e.icon, tone: e.tone)]),
        ),
      ]),
    );
  }
}

class _ClientsBody extends StatelessWidget {
  const _ClientsBody();

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return ListView.separated(
      padding: const EdgeInsets.all(Space.s3),
      itemCount: kDemoClients.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final x = kDemoClients[i];
        return KitCard(
          padding: const EdgeInsets.all(Space.s3),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DetailPageDemo(client: x))),
          child: Row(children: [
            KitAvatar(name: x.raisonSociale, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(x.raisonSociale, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('${x.code} · ${x.ville}', style: TextStyle(fontSize: 12, color: c.textSecondary)),
              ]),
            ),
            StatusBadge(x.statut.label, tone: x.statut.tone),
          ]),
        );
      },
    );
  }
}

class _InterventionsBody extends StatelessWidget {
  const _InterventionsBody();

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return ListView(padding: const EdgeInsets.all(Space.s3), children: [
      for (final (i, (t, s, tone)) in const [
        ('Pose balise — Transports Yao', 'Planifiée · 08:30', KitTone.info),
        ('Balise hors ligne — SOTRA bus 112', 'En retard · hier', KitTone.error),
        ('Maintenance capteur carburant', 'En route · 10:15', KitTone.purple),
        ('Installation flotte Lôh Logistique', 'Sur site · 11:00', KitTone.warning),
      ].indexed)
        Padding(
          padding: const EdgeInsets.only(bottom: Space.s2),
          child: KitCard(
            padding: const EdgeInsets.all(Space.s3),
            child: Row(children: [
              Container(width: 4, height: 40, decoration: BoxDecoration(color: tone.color(c), borderRadius: Radii.pill)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('INT-${(412 + i).toString().padLeft(4, '0')}', style: TextStyle(fontFamily: Fonts.mono, fontSize: 10.5, color: c.textMuted)),
                  Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(s, style: TextStyle(fontSize: 12, color: tone.text(c))),
                ]),
              ),
              Icon(Icons.chevron_right, color: c.textMuted),
            ]),
          ),
        ),
    ]);
  }
}

/// Panneau « Paramètres du compte » (user-settings + profil).
class _AccountPanel extends StatelessWidget {
  const _AccountPanel();

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    Widget item(IconData i, String t, String s, VoidCallback onTap, {KitTone tone = KitTone.primary}) => ListTile(
          leading: Container(width: 38, height: 38, decoration: BoxDecoration(color: tone.light(c), borderRadius: Radii.rm), child: Icon(i, size: 20, color: tone.color(c))),
          title: Text(t, style: TextStyle(fontWeight: FontWeight.w600, color: tone == KitTone.error ? c.error : null)),
          subtitle: Text(s),
          trailing: Icon(Icons.chevron_right, color: c.textMuted),
          onTap: onTap,
        );
    return ListView(padding: const EdgeInsets.all(Space.s4), children: [
      Center(
        child: Column(children: [
          const KitAvatar(name: 'Jean Kouassi', size: 72, online: true),
          const SizedBox(height: 8),
          Text('Jean Kouassi', style: context.t.h4),
          Text('Responsable exploitation · Lookas CI', style: context.t.bodySm),
        ]),
      ),
      const SizedBox(height: 16),
      Text('GESTION DE PROFIL', style: context.t.overline),
      item(Icons.person_outline, 'Paramètres personnels', 'Modifiez vos données personnelles', () => _editProfile(context)),
      item(Icons.lock_outline, 'Mot de passe', 'Changez votre mot de passe', () => showFormSheet<void>(context, title: 'Mot de passe', icon: Icons.lock_outline, builder: (_, _) => const PasswordField(label: 'Nouveau mot de passe'))),
      const SizedBox(height: 8),
      Text('PRÉFÉRENCES', style: context.t.overline),
      SwitchListTile(
        secondary: const Icon(Icons.dark_mode_outlined),
        title: const Text('Thème sombre'),
        value: context.isDark,
        onChanged: (_) => ThemeController.instance.toggle(),
      ),
      ListTile(
        leading: const Icon(Icons.palette_outlined),
        title: const Text('Apparence'),
        subtitle: Text('Couleur : ${ThemeController.instance.label}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => showThemeSheet(context),
      ),
      SwitchListTile(secondary: const Icon(Icons.notifications_outlined), title: const Text('Notifications push'), value: true, onChanged: (_) {}),
      const SizedBox(height: 8),
      Text('CONNEXION', style: context.t.overline),
      item(Icons.logout, 'Déconnexion', 'Fermer la session en cours', () async {
        final ok = await showBottomConfirm(context, title: 'Se déconnecter ?', message: 'Vous devrez saisir à nouveau vos identifiants.', confirm: 'Déconnexion', danger: true, icon: Icons.logout);
        if (ok && context.mounted) Navigator.of(context).popUntil((r) => r.isFirst);
      }, tone: KitTone.error),
    ]);
  }

  void _editProfile(BuildContext context) => showFormSheet<void>(
        context,
        title: 'Paramètres personnels',
        icon: Icons.person_outline,
        submitLabel: 'Valider',
        builder: (_, _) => const Gap14([
          KitTextField(label: 'Nom complet', initialValue: 'Jean Kouassi', icon: Icons.person_outline),
          KitTextField(label: 'Email', initialValue: 'jean.kouassi@lookas.ci', icon: Icons.alternate_email),
          KitTextField(label: 'Téléphone', initialValue: '+225 07 10 20 30 40', icon: Icons.phone),
        ]),
      );
}

/// Colonne espacée de 14 px (formulaires).
class Gap14 extends StatelessWidget {
  const Gap14(this.children, {super.key});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
        for (var i = 0; i < children.length; i++) ...[if (i > 0) const SizedBox(height: 14), children[i]],
      ]);
}

/// Fiche détail : en-tête repliable (identité, statut, actions), KPI, onglets de sous-listes.
class DetailPageDemo extends StatelessWidget {
  const DetailPageDemo({super.key, required this.client});
  final DemoClient client;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final x = client;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              pinned: true,
              expandedHeight: 210,
              title: Text(x.raisonSociale, overflow: TextOverflow.ellipsis),
              actions: [
                IconButton(onPressed: () => demoAction(context, 'Modification'), icon: const Icon(Icons.edit_outlined)),
                PopupMenuButton<String>(
                  onSelected: (v) => demoAction(context, v),
                  itemBuilder: (_) => const [PopupMenuItem(value: 'Export PDF', child: Text('Exporter en PDF')), PopupMenuItem(value: 'Suspension', child: Text('Suspendre'))],
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(Space.s4, Space.s16, Space.s4, 52),
                    child: Row(children: [
                      KitAvatar(name: x.raisonSociale, size: 60),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(x.raisonSociale, maxLines: 2, style: context.t.h3),
                          const SizedBox(height: 4),
                          Wrap(spacing: 8, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
                            StatusBadge(x.statut.label, tone: x.statut.tone),
                            Text(x.code, style: TextStyle(fontFamily: Fonts.mono, fontSize: 11.5, color: c.textMuted)),
                          ]),
                        ]),
                      ),
                    ]),
                  ),
                ),
              ),
              bottom: const TabBar(tabs: [Tab(text: 'Aperçu'), Tab(text: 'Véhicules'), Tab(text: 'Factures')]),
            ),
          ],
          body: TabBarView(children: [
            ListView(padding: const EdgeInsets.all(Space.s4), children: [
              ResponsiveGrid(minItemWidth: 160, spacing: 10, children: [
                KpiCard(icon: Icons.local_shipping, value: '${x.vehicules}', label: 'Véhicules', tone: KitTone.primary),
                KpiCard(icon: Icons.payments, value: Fmt.compact(x.caMensuel), unit: 'FCFA', label: 'CA mensuel', tone: KitTone.success),
              ]),
              const SizedBox(height: 12),
              KitCard(
                title: 'Coordonnées',
                icon: Icons.contact_mail_outlined,
                child: DescriptionList(horizontal: true, items: [
                  DescItem('Contact', x.contact),
                  DescItem('Téléphone', x.telephone, type: DescType.phone),
                  DescItem('Email', x.email, type: DescType.email, copy: true),
                  DescItem('Ville', x.ville),
                  DescItem('Secteur', x.secteur),
                  DescItem('Client depuis', Fmt.dateLong(x.createdAt)),
                ]),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: KitButton(label: 'Appeler', icon: Icons.call, variant: KitButtonVariant.secondary, expand: true, onPressed: () => demoAction(context, 'Appel'))),
                const SizedBox(width: 10),
                Expanded(child: KitButton(label: 'Intervention', icon: Icons.build, expand: true, onPressed: () => demoAction(context, 'Nouvelle intervention'))),
              ]),
            ]),
            ListView(padding: const EdgeInsets.all(Space.s3), children: [
              for (var i = 0; i < x.vehicules.clamp(1, 12); i++)
                ListTile(
                  leading: Icon(i.isEven ? Icons.local_shipping : Icons.directions_car, color: c.primary),
                  title: Text('CI-${(1000 + i * 137) % 9999}-${String.fromCharCode(65 + i % 26)}${String.fromCharCode(66 + i % 24)}'),
                  subtitle: Text(i % 5 == 3 ? 'Hors ligne depuis 2 j' : 'En ligne · il y a ${i + 1} min'),
                  trailing: StatusBadge(i % 5 == 3 ? 'Hors ligne' : 'En ligne', tone: i % 5 == 3 ? KitTone.error : KitTone.success),
                ),
            ]),
            ListView(padding: const EdgeInsets.all(Space.s3), children: [
              for (var i = 0; i < 6; i++)
                ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: Text('FAC-2026-${(912 - i * 38).toString().padLeft(4, '0')}'),
                  subtitle: Text(Fmt.date(DateTime(2026, 10 - i, 15))),
                  trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(Fmt.fcfa(x.caMensuel), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                    StatusBadge(i == 0 ? 'Émise' : 'Payée', tone: i == 0 ? KitTone.warning : KitTone.success),
                  ]),
                ),
            ]),
          ]),
        ),
      ),
    );
  }
}

/// Écrans d'authentification : connexion, mot de passe oublié (code OTP), sans authentification réelle.
class AuthDemo extends StatefulWidget {
  const AuthDemo({super.key});

  @override
  State<AuthDemo> createState() => _AuthDemoState();
}

class _AuthDemoState extends State<AuthDemo> {
  int _step = 0; // 0 connexion · 1 e-mail de récupération · 2 code · 3 succès
  bool _loading = false;
  bool _showPwd = false;

  Future<void> _go(int step) async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (mounted) {
      setState(() {
        _loading = false;
        _step = step;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, leading: _step > 0 && _step < 3 ? BackButton(onPressed: () => setState(() => _step = 0)) : const CloseButton(), actions: const [ThemeToggleButton(), ThemePickerButton()]),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [c.primaryLight, c.bg, c.bg])),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(Space.s6),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: KeyedSubtree(key: ValueKey(_step), child: _content(c)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(KitColors c) {
    Widget logo() => Column(children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(Radii.xl), boxShadow: Elevations.e3(Theme.of(context).brightness)),
            child: Icon(Icons.gps_fixed, color: c.onPrimary, size: 34),
          ),
          const SizedBox(height: 12),
          Text('Lookas', style: KitText.brand.copyWith(fontSize: 26, color: c.textPrimary)),
        ]);
    switch (_step) {
      case 0:
        return Gap14([
          logo(),
          Text('Connexion', textAlign: TextAlign.center, style: context.t.h2),
          Text('Suivez votre flotte en temps réel.', textAlign: TextAlign.center, style: context.t.bodySm),
          const SizedBox(height: 6),
          const TextField(keyboardType: TextInputType.emailAddress, decoration: InputDecoration(labelText: 'E-mail', prefixIcon: Icon(Icons.alternate_email), filled: false)),
          TextField(
            obscureText: !_showPwd,
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              prefixIcon: const Icon(Icons.lock_outline),
              filled: false,
              suffixIcon: IconButton(onPressed: () => setState(() => _showPwd = !_showPwd), icon: Icon(_showPwd ? Icons.visibility_off : Icons.visibility)),
            ),
          ),
          Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => setState(() => _step = 1), child: const Text('Mot de passe oublié ?'))),
          KitButton(label: 'Se connecter', loading: _loading, loadingLabel: 'Connexion…', expand: true, size: KitButtonSize.large, onPressed: () => _go(3)),
          const LabeledDivider('ou'),
          KitButton(label: 'Continuer avec Google', icon: Icons.g_mobiledata, variant: KitButtonVariant.outline, expand: true, size: KitButtonSize.large, onPressed: () => _go(3)),
          Text('Démo statique : aucune authentification réelle.', textAlign: TextAlign.center, style: context.t.caption),
        ]);
      case 1:
        return Gap14([
          logo(),
          Text('Mot de passe oublié', textAlign: TextAlign.center, style: context.t.h2),
          Text('Saisissez votre e-mail : nous vous enverrons un code à 6 chiffres.', textAlign: TextAlign.center, style: context.t.bodySm),
          const TextField(keyboardType: TextInputType.emailAddress, decoration: InputDecoration(labelText: 'E-mail', prefixIcon: Icon(Icons.alternate_email), filled: false)),
          KitButton(label: 'Envoyer le code', loading: _loading, expand: true, size: KitButtonSize.large, onPressed: () => _go(2)),
        ]);
      case 2:
        return Gap14([
          logo(),
          Text('Vérification', textAlign: TextAlign.center, style: context.t.h2),
          Text('Code envoyé à j•••@lookas.ci', textAlign: TextAlign.center, style: context.t.bodySm),
          Center(child: OtpInput(onCompleted: (_) => _go(3))),
          TextButton(onPressed: () => showKitSnack(context, 'Nouveau code envoyé (démo)'), child: const Text('Renvoyer le code')),
        ]);
      default:
        return Gap14([
          Icon(Icons.check_circle, size: 72, color: c.success),
          Text('Bienvenue Jean !', textAlign: TextAlign.center, style: context.t.h2),
          Text('Vous êtes connecté (démo).', textAlign: TextAlign.center, style: context.t.bodySm),
          KitButton(label: 'Ouvrir l’application', expand: true, onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AppShellDemo()))),
          TextButton(onPressed: () => setState(() => _step = 0), child: const Text('Revenir à la connexion')),
        ]);
    }
  }
}

/// Page publique (lien partagé) : proforma consultable et payable sans compte.
class PublicPageDemo extends StatelessWidget {
  const PublicPageDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    const lines = [('Abonnement Suivi Premium', 24, 14500), ('Installation balise FMB920', 6, 35000), ('Option anti-démarrage', 6, 4500)];
    final total = lines.fold<int>(0, (a, l) => a + l.$2 * l.$3);
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [Icon(Icons.gps_fixed, color: c.primary), const SizedBox(width: 8), Text('Lookas', style: KitText.brand.copyWith(color: c.textPrimary))]),
        actions: [IconButton(onPressed: () => demoAction(context, 'Téléchargement PDF'), icon: const Icon(Icons.download_outlined))],
      ),
      body: ListView(padding: const EdgeInsets.all(Space.s4), children: [
        const KitCard(child: Row(children: [Icon(Icons.verified_user_outlined), SizedBox(width: 10), Expanded(child: Text('Lien sécurisé · valable jusqu’au 30/10/2026'))])),
        const SizedBox(height: 12),
        Text('PROFORMA', style: context.t.overline),
        Text('PRO-2026-0318', style: context.t.h2),
        Text('Émise le 15/10/2026 pour Transports Yao & Fils', style: context.t.bodySm),
        const SizedBox(height: 12),
        KitCard(
          padding: EdgeInsets.zero,
          child: Column(children: [
            for (final (l, q, p) in lines)
              ListTile(title: Text(l), subtitle: Text('$q × ${Fmt.fcfa(p)}'), trailing: Text(Fmt.fcfa(q * p), style: const TextStyle(fontWeight: FontWeight.w700))),
            const Divider(),
            ListTile(title: const Text('Total TTC', style: TextStyle(fontWeight: FontWeight.w800)), trailing: Text(Fmt.fcfa(total), style: TextStyle(fontFamily: Fonts.heading, fontSize: 18, fontWeight: FontWeight.w800, color: c.primary))),
          ]),
        ),
        const SizedBox(height: 16),
        KitButton(
          label: 'Payer ${Fmt.fcfa(total)}',
          icon: Icons.phone_android,
          size: KitButtonSize.large,
          expand: true,
          onPressed: () => showModalBottomSheet(
            context: context,
            builder: (ctx) => SafeArea(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                for (final (n, col) in const [('Orange Money', Color(0xFFFF7900)), ('MTN MoMo', Color(0xFFFFCC00)), ('Wave', Color(0xFF1DC4FF)), ('Carte bancaire', Color(0xFF64748B))])
                  ListTile(
                    leading: CircleAvatar(backgroundColor: col, radius: 16, child: const Icon(Icons.payments, size: 16, color: Colors.white)),
                    title: Text(n),
                    onTap: () {
                      Navigator.pop(ctx);
                      showKitSnack(context, 'Paiement $n simulé', kind: SnackKind.success);
                    },
                  ),
                const SizedBox(height: 8),
              ]),
            ),
          ),
        ),
        const SizedBox(height: 8),
        KitButton(label: 'Accepter sans payer', variant: KitButtonVariant.outline, expand: true, onPressed: () => showKitSnack(context, 'Proforma acceptée (démo)', kind: SnackKind.success)),
      ]),
    );
  }
}
