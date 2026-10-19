import 'package:flutter/material.dart';

import '../../data/showcase_data.dart';
import '../../theme/kit_colors.dart';
import '../../theme/tokens.dart';
import '../../widgets/common.dart';
import '../../widgets/dialogs.dart';
import '../doc/doc.dart';
import '../kit_nav.dart';
import 'layout_demos.dart';

enum _Wire { shell, detail, auth, public, drawer, dialog, kit }

class _LayoutCard {
  const _LayoutCard(this.id, this.title, this.icon, this.wire, this.file, this.description, this.open);
  final String id, title, file, description;
  final IconData icon;
  final _Wire wire;
  final void Function(BuildContext) open;
}

/// `/layouts` — gabarits d'écran complets : maquette schématique + exemple vivant.
class LayoutsGalleryPage extends StatelessWidget {
  const LayoutsGalleryPage({super.key, this.onMenu});
  final VoidCallback? onMenu;

  static void _push(BuildContext context, Widget page) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  static final _layouts = [
    _LayoutCard('shell', 'Shell applicatif', Icons.space_dashboard, _Wire.shell, 'showcase/layouts/layout_demos.dart › AppShellDemo',
        'Barre d’application (recherche, notifications, compte) + tiroir Sidecar + barre de navigation basse + FAB contextuel. Sur tablette, le Sidecar reste visible à gauche.', (c) => _push(c, const AppShellDemo())),
    _LayoutCard('detail', 'Fiche détail', Icons.article, _Wire.detail, 'DetailPageDemo',
        'En-tête repliable (identité, statut, actions), KPI, onglets de sous-listes, actions principales au pouce.', (c) => _push(c, DetailPageDemo(client: kDemoClients[0]))),
    _LayoutCard('auth', 'Authentification', Icons.lock_person, _Wire.auth, 'AuthDemo',
        'Connexion, connexion Google, mot de passe oublié et code OTP — sans authentification réelle.', (c) => _push(c, const AuthDemo())),
    _LayoutCard('public', 'Page publique', Icons.public, _Wire.public, 'PublicPageDemo',
        'Proforma consultable via un lien partagé, paiement mobile money simulé.', (c) => _push(c, const PublicPageDemo())),
    _LayoutCard('drawer', 'Panneau latéral / feuille', Icons.view_sidebar, _Wire.drawer, 'showSidePanel',
        'Le drawer droit 360 px du web : feuille basse quasi plein écran sur téléphone, panneau latéral sur tablette.',
        (c) => showSidePanel(c, title: 'Tâches du jour', icon: Icons.checklist, child: ListView(children: [
              for (var i = 0; i < 8; i++) CheckboxListTile(value: i < 3, onChanged: (_) {}, title: Text('Relancer ${kDemoClients[i].raisonSociale}'), controlAffinity: ListTileControlAffinity.leading),
            ]))),
    _LayoutCard('dialog', 'Dialogs & formulaires', Icons.open_in_new, _Wire.dialog, 'showFormSheet · showKitConfirm',
        'Formulaires en feuille (CrudDialog), confirmations, messages poussés. Voir aussi la galerie Feedback.', (c) => openCategory(c, categoryById('feedback'), 'modal')),
    _LayoutCard('kit', 'Catalogue (UI Kit)', Icons.widgets, _Wire.kit, 'showcase/kit_shell.dart',
        'Layout de ce catalogue : barre basse (Showcase, Composants, Layouts, Harnais), tiroir recherchable, pages documentaires avec sommaire collant.', (c) => Navigator.of(c).popUntil((r) => r.isFirst)),
  ];

  @override
  Widget build(BuildContext context) {
    return DocPage(
      leading: IconButton(icon: const Icon(Icons.menu), tooltip: 'Catalogue', onPressed: onMenu),
      title: 'Layouts',
      eyebrow: 'Gabarits',
      icon: Icons.dashboard_customize,
      subtitle: 'Les gabarits d’écran complets, adaptés au mobile. Chaque carte montre la structure schématique et ouvre un exemple vivant. Les briques (grilles, panneaux, conteneurs) sont dans Composants › Layout.',
      sections: [
        DocSection(
          id: 'layouts',
          title: '${_layouts.length} gabarits',
          cols: 2,
          children: [for (final l in _layouts) _Card(l)],
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card(this.l);
  final _LayoutCard l;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return KitCard(
      padding: EdgeInsets.zero,
      onTap: () => l.open(context),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(height: 150, color: c.hover.withValues(alpha: 0.6), padding: const EdgeInsets.all(14), child: Center(child: _Wireframe(l.wire))),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(l.icon, color: c.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(l.title, style: TextStyle(fontFamily: Fonts.heading, fontSize: 16, fontWeight: FontWeight.w700, color: c.textPrimary))),
              Icon(Icons.open_in_new, size: 18, color: c.textMuted),
            ]),
            const SizedBox(height: 6),
            Text(l.description, style: TextStyle(fontSize: 12.5, height: 1.45, color: c.textSecondary)),
            const SizedBox(height: 8),
            Text(l.file, style: TextStyle(fontFamily: Fonts.mono, fontSize: 10.5, color: c.textMuted)),
          ]),
        ),
      ]),
    );
  }
}

/// Maquette schématique d'un gabarit (blocs gris).
class _Wireframe extends StatelessWidget {
  const _Wireframe(this.wire);
  final _Wire wire;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    Widget b({double? w, double h = 8, Color? color, double r = 3}) => Container(width: w, height: h, decoration: BoxDecoration(color: color ?? c.textMuted.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(r)));
    final accent = c.primary.withValues(alpha: 0.7);
    final phone = Container(
      width: 74,
      decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: c.textMuted.withValues(alpha: 0.5), width: 2)),
      padding: const EdgeInsets.all(5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: switch (wire) {
        _Wire.shell => [b(h: 10, color: accent), const SizedBox(height: 5), Row(children: [Expanded(child: b(h: 18)), const SizedBox(width: 3), Expanded(child: b(h: 18))]), const SizedBox(height: 4), b(h: 30), const Spacer(), b(h: 10)],
        _Wire.detail => [b(h: 28, color: accent), const SizedBox(height: 4), Row(children: [for (var i = 0; i < 3; i++) Expanded(child: Padding(padding: const EdgeInsets.all(1), child: b(h: 5)))]), const SizedBox(height: 4), b(h: 14), const SizedBox(height: 3), b(h: 14), const SizedBox(height: 3), b(h: 14)],
        _Wire.auth => [const Spacer(), Center(child: b(w: 18, h: 18, color: accent, r: 6)), const SizedBox(height: 6), b(h: 7), const SizedBox(height: 3), b(h: 7), const SizedBox(height: 5), b(h: 9, color: accent, r: 9), const Spacer()],
        _Wire.public => [b(h: 8), const SizedBox(height: 5), b(w: 36, h: 9), const SizedBox(height: 5), b(h: 34), const Spacer(), b(h: 10, color: accent, r: 10)],
        _Wire.drawer => [b(h: 8), const SizedBox(height: 4), b(h: 20), const Spacer(), Container(height: 60, decoration: BoxDecoration(color: accent.withValues(alpha: 0.35), borderRadius: const BorderRadius.vertical(top: Radius.circular(8))))],
        _Wire.dialog => [b(h: 8), const Spacer(), Container(height: 70, decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(8), boxShadow: Elevations.e3(Theme.of(context).brightness)), padding: const EdgeInsets.all(4), child: Column(children: [b(h: 6), const SizedBox(height: 3), b(h: 6), const Spacer(), b(h: 8, color: accent)]))],
        _Wire.kit => [b(h: 8), const SizedBox(height: 4), Row(children: [for (var i = 0; i < 3; i++) Expanded(child: Padding(padding: const EdgeInsets.all(1), child: b(h: 6, r: 6)))]), const SizedBox(height: 4), b(h: 22), const SizedBox(height: 3), b(h: 22), const Spacer(), b(h: 10, color: accent)],
      }),
    );
    return AspectRatio(aspectRatio: 74 / 130, child: phone);
  }
}
