import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/snack.dart';
import '../../data/showcase_data.dart';
import '../../theme/kit_colors.dart';
import '../../theme/tokens.dart';
import '../../widgets/common.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/feedback.dart';
import '../../widgets/kit_buttons.dart';
import '../doc/doc.dart';

/// `/components/feedback` — alertes, snackbars, modales, dialogs, confirmations, drawers,
/// tooltips, chargements, squelettes, erreurs, envoi multiple, bannières, résultat, annulation.
class FeedbackGallery extends StatefulWidget {
  const FeedbackGallery({super.key, this.initialSection});
  final String? initialSection;

  @override
  State<FeedbackGallery> createState() => _FeedbackGalleryState();
}

class _FeedbackGalleryState extends State<FeedbackGallery> {
  final Set<String> _closed = {};
  bool _overlay = false;
  bool _saving = false;
  double _determinate = 0.35;
  Timer? _timer;
  bool _offline = false;
  final Set<String> _bannersClosed = {};
  String _result = 'success';
  final List<String> _tasks = ['Relancer Bolloré Logistics', 'Valider le devis DEV-118', 'Planifier INT-0418', 'Envoyer le rapport T3'];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _runOverlay() {
    setState(() => _overlay = true);
    Timer(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _overlay = false);
    });
  }

  void _runDeterminate() {
    _timer?.cancel();
    setState(() => _determinate = 0);
    _timer = Timer.periodic(const Duration(milliseconds: 60), (t) {
      if (!mounted) return t.cancel();
      setState(() => _determinate = (_determinate + 0.02).clamp(0, 1));
      if (_determinate >= 1) t.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return Stack(children: [
      DocPage(
        title: 'Feedback',
        icon: Icons.notifications_active,
        initialSection: widget.initialSection,
        subtitle: 'Retours visuels : alertes, snackbars, dialogs génériques, formulaires en feuille, confirmations, drawers, indicateurs de chargement, squelettes et états d’erreur.',
        sections: [
          _alerts(c),
          _toasts(c),
          _modals(c),
          _dialogsSection(c),
          _confirm(c),
          _drawer(c),
          _tooltip(c),
          _loading(c),
          _skeleton(c),
          _errors(c),
          const DocSection(
            id: 'upload-queue',
            title: 'Envoi multiple avec progression',
            source: 'UploadQueue (simulé, sans réseau)',
            description: 'Deux envois simultanés, pause / reprise, échec et nouvelle tentative (le fichier « photo » échoue volontairement).',
            children: [Demo(label: 'File d’envoi', child: UploadQueue())],
          ),
          _banners(c),
          _resultSection(c),
          _undo(c),
        ],
      ),
      if (_overlay) const Positioned.fill(child: OverlaySpinner(message: 'Synchronisation des positions…')),
    ]);
  }

  DocSection _alerts(KitColors c) {
    Widget closable(String id, Widget Function(VoidCallback) b) => AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: _closed.contains(id) ? const SizedBox(width: double.infinity) : b(() => setState(() => _closed.add(id))),
        );
    return DocSection(
      id: 'alert',
      title: 'Alert',
      source: 'KitAlert',
      children: [
        Demo(
          label: 'Variantes',
          hint: _closed.isEmpty ? null : 'réinitialiser ↻',
          code: "KitAlert(tone: KitTone.warning, title: 'Abonnement bientôt expiré', text: '…', action: 'Renouveler', onClose: close)",
          child: Gap([
            closable('s', (x) => KitAlert(tone: KitTone.success, title: 'Paiement reçu', text: 'Bolloré Logistics CI a réglé la facture FAC-2026-0874.', onClose: x)),
            closable('i', (x) => KitAlert(tone: KitTone.info, title: 'Mise à jour disponible', text: 'Le firmware v03.28.07 peut être déployé sur 12 balises.', action: 'Planifier', onAction: () => demoAction(context, 'Planification'), onClose: x)),
            closable('w', (x) => KitAlert(tone: KitTone.warning, title: 'Abonnement bientôt expiré', text: 'Le contrat CTR-2026-0042 arrive à échéance dans 12 jours.', action: 'Renouveler', onClose: x)),
            closable('e', (x) => KitAlert(tone: KitTone.error, title: 'Balise hors ligne', text: 'CI-0418-GH n’émet plus depuis 2 jours.', onClose: x)),
            if (_closed.isNotEmpty) Align(alignment: Alignment.centerLeft, child: TextButton.icon(onPressed: () => setState(_closed.clear), icon: const Icon(Icons.refresh, size: 18), label: const Text('Réafficher'))),
          ]),
        ),
        const Demo(
          label: 'Compactes',
          child: Gap(gap: 8, [
            KitAlert(compact: true, tone: KitTone.success, text: 'Modifications enregistrées.'),
            KitAlert(compact: true, tone: KitTone.warning, text: '3 champs requièrent votre attention.'),
            KitAlert(compact: true, tone: KitTone.error, text: 'Connexion perdue — nouvelle tentative…'),
          ]),
        ),
        const Demo(
          label: 'Alerte bloquante (.alert-client)',
          child: KitAlert(filled: true, tone: KitTone.error, icon: Icons.block, title: 'Compte suspendu', text: 'Ce client a 3 factures impayées. Les nouvelles interventions sont bloquées jusqu’à régularisation.'),
        ),
      ],
    );
  }

  DocSection _toasts(KitColors c) => DocSection(
        id: 'toast',
        title: 'Toast / Snackbar',
        source: 'showKitSnack (snackbar-success / error / info)',
        description: 'Snackbars flottantes au-dessus de la barre de navigation, teintées selon le type.',
        cols: 2,
        children: [
          Demo(
            label: 'Types',
            code: "showKitSnack(context, 'Client enregistré', kind: SnackKind.success);",
            child: DemoWrap(children: [
              KitButton(label: 'Succès', variant: KitButtonVariant.success, onPressed: () => showKitSnack(context, 'Client enregistré avec succès', kind: SnackKind.success)),
              KitButton(label: 'Erreur', variant: KitButtonVariant.danger, onPressed: () => showKitSnack(context, 'Échec de la synchronisation', kind: SnackKind.error)),
              KitButton(label: 'Info', variant: KitButtonVariant.secondary, onPressed: () => showKitSnack(context, '3 nouvelles alertes', kind: SnackKind.info)),
              KitButton(label: 'Neutre', variant: KitButtonVariant.outline, onPressed: () => showKitSnack(context, 'Brouillon enregistré', action: 'Voir')),
            ]),
          ),
          Demo(
            label: 'Positions',
            child: DemoWrap(children: [
              OutlinedButton(onPressed: () => showKitSnack(context, 'En bas (par défaut)'), child: const Text('Bas')),
              OutlinedButton(
                onPressed: () {
                  final m = ScaffoldMessenger.of(context);
                  m.clearMaterialBanners();
                  m.showMaterialBanner(MaterialBanner(
                    leading: Icon(Icons.info, color: c.info),
                    content: const Text('Message en haut d’écran (MaterialBanner)'),
                    actions: [TextButton(onPressed: m.hideCurrentMaterialBanner, child: const Text('OK'))],
                  ));
                  Timer(const Duration(seconds: 3), () => m.hideCurrentMaterialBanner());
                },
                child: const Text('Haut'),
              ),
            ]),
          ),
        ],
      );

  DocSection _modals(KitColors c) => DocSection(
        id: 'modal',
        title: 'Modal',
        source: 'showKitAlert · showKitConfirm · showKitPrompt · showPushMessage · showFormSheet',
        cols: 2,
        children: [
          Demo(
            label: 'ModalService (génériques)',
            child: DemoWrap(children: [
              OutlinedButton(onPressed: () => showKitAlert(context, title: 'Synchronisation terminée', message: '248 positions ont été importées.', icon: Icons.cloud_done, tone: KitTone.success), child: const Text('alert')),
              OutlinedButton(
                onPressed: () async {
                  final ok = await showKitConfirm(context, title: 'Clôturer l’intervention ?', message: 'INT-0412 passera au statut « Clôturée ».');
                  if (mounted) showKitSnack(context, ok ? 'Confirmé' : 'Annulé');
                },
                child: const Text('confirm'),
              ),
              OutlinedButton(
                onPressed: () async {
                  final v = await showKitPrompt(context, title: 'Renommer le groupe', initial: 'Livraisons Nord', hint: 'Nom du groupe');
                  if (v != null && mounted) showKitSnack(context, 'Renommé en « $v »', kind: SnackKind.success);
                },
                child: const Text('prompt'),
              ),
            ]),
          ),
          Demo(
            label: 'Messages poussés',
            child: DemoWrap(children: [
              OutlinedButton.icon(
                onPressed: () => showPushMessage(context, title: 'Nouveau : rapports carburant', message: 'Suivez la consommation de chaque véhicule et recevez une alerte en cas de siphonnage.'),
                icon: const Icon(Icons.campaign, size: 18),
                label: const Text('Annonce'),
              ),
              OutlinedButton.icon(
                onPressed: () => showPriorityMessage(context, title: 'Maintenance planifiée', message: 'La plateforme sera indisponible dimanche de 02:00 à 04:00. Les positions seront mises en mémoire tampon par les balises.'),
                icon: const Icon(Icons.priority_high, size: 18),
                label: const Text('Prioritaire'),
              ),
            ]),
          ),
          Demo(
            label: 'Formulaire (feuille)',
            child: Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: () => showFormSheet<void>(
                  context,
                  title: 'Nouvelle intervention',
                  icon: Icons.build,
                  builder: (ctx, _) => const Gap(gap: 14, [
                    KitTextField(label: 'Véhicule', hint: 'CI-4521-AB', icon: Icons.directions_car),
                    KitTextField(label: 'Motif', maxLines: 3, hint: 'Décrivez le problème…'),
                  ]),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Ouvrir'),
              ),
            ),
          ),
          Demo(
            label: 'Overlay plein écran',
            child: Align(alignment: Alignment.centerLeft, child: KitButton(label: 'Synchroniser', icon: Icons.sync, variant: KitButtonVariant.secondary, onPressed: _runOverlay)),
          ),
        ],
      );

  DocSection _dialogsSection(KitColors c) => DocSection(
        id: 'dialog',
        title: 'Dialog',
        source: 'AlertDialog · Dialog.fullscreen',
        cols: 2,
        children: [
          Demo(
            label: 'Types',
            child: DemoWrap(children: [
              OutlinedButton(onPressed: () => showKitAlert(context, title: 'Information', message: 'La balise redémarrera à la prochaine connexion.'), child: const Text('Info')),
              OutlinedButton(onPressed: () => showKitAlert(context, title: 'Attention', message: 'La carte SIM expire dans 5 jours.', icon: Icons.warning_amber, tone: KitTone.warning), child: const Text('Avertissement')),
              OutlinedButton(onPressed: () => showKitAlert(context, title: 'Erreur', message: 'Impossible de joindre la balise.', icon: Icons.error_outline, tone: KitTone.error, ok: 'Fermer'), child: const Text('Erreur')),
              OutlinedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (ctx) => Dialog.fullscreen(
                    child: Scaffold(
                      appBar: AppBar(leading: IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)), title: const Text('Conditions générales'), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Accepter'))]),
                      body: ListView(padding: const EdgeInsets.all(20), children: [
                        for (var i = 1; i <= 8; i++) ...[
                          Text('Article $i', style: const TextStyle(fontFamily: Fonts.heading, fontWeight: FontWeight.w700, fontSize: 16)),
                          const SizedBox(height: 6),
                          Text('Les prestations de géolocalisation sont fournies dans le cadre du contrat d’abonnement. Le client s’engage à informer ses chauffeurs de la présence du dispositif.', style: TextStyle(color: c.textSecondary, height: 1.55)),
                          const SizedBox(height: 16),
                        ],
                      ]),
                    ),
                  ),
                ),
                child: const Text('Plein écran'),
              ),
            ]),
          ),
          Demo(
            label: 'Aperçu statique (contenu de dialog)',
            muted: true,
            child: Center(
              child: Material(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: Radii.rl,
                elevation: 2,
                child: SizedBox(
                  width: 300,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Container(width: 52, height: 52, decoration: BoxDecoration(shape: BoxShape.circle, color: c.primaryLight), child: Icon(Icons.mark_email_read, color: c.primary)),
                      const SizedBox(height: 12),
                      Text('Rapport envoyé', style: TextStyle(fontFamily: Fonts.heading, fontSize: 18, fontWeight: FontWeight.w600, color: c.textPrimary)),
                      const SizedBox(height: 6),
                      Text('Le rapport mensuel a été envoyé à 3 destinataires.', textAlign: TextAlign.center, style: TextStyle(color: c.textSecondary)),
                      const SizedBox(height: 16),
                      SizedBox(width: double.infinity, child: FilledButton(onPressed: () {}, child: const Text('Fermer'))),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ],
      );

  DocSection _confirm(KitColors c) => DocSection(
        id: 'confirm',
        title: 'Confirmation dialog',
        source: 'showKitConfirm(danger, typeToConfirm) · showBottomConfirm',
        description: 'Actions destructives : bouton rouge, et saisie de confirmation pour les plus graves.',
        cols: 2,
        children: [
          Demo(
            label: 'Suppression',
            child: DemoWrap(children: [
              KitButton(
                label: 'Supprimer',
                icon: Icons.delete_outline,
                variant: KitButtonVariant.dangerOutline,
                onPressed: () async {
                  final ok = await showKitConfirm(context, title: 'Supprimer ce client ?', message: 'Transports Yao & Fils et ses 12 véhicules seront supprimés.', confirm: 'Supprimer', danger: true);
                  if (ok && mounted) showKitSnack(context, 'Client supprimé (démo)', kind: SnackKind.error);
                },
              ),
              KitButton(
                label: 'Saisie de confirmation',
                variant: KitButtonVariant.danger,
                onPressed: () => showKitConfirm(context, title: 'Résilier le contrat ?', message: 'Toutes les balises seront désactivées.', confirm: 'Résilier', danger: true, typeToConfirm: 'CTR-0042'),
              ),
            ]),
          ),
          Demo(
            label: 'Bottom sheet',
            child: Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final ok = await showBottomConfirm(context, title: 'Couper le moteur ?', message: 'Le véhicule CI-4521-AB sera immobilisé à son prochain arrêt.', confirm: 'Couper le moteur', danger: true, icon: Icons.power_settings_new);
                  if (ok && mounted) showKitSnack(context, 'Commande envoyée (démo)', kind: SnackKind.info);
                },
                icon: const Icon(Icons.power_settings_new, size: 18),
                label: const Text('Confirmer en feuille'),
              ),
            ),
          ),
        ],
      );

  DocSection _drawer(KitColors c) => DocSection(
        id: 'drawer',
        title: 'Drawer / bottom sheet',
        source: 'showSidePanel · showModalBottomSheet · DraggableScrollableSheet',
        description: 'Le drawer droit 360 px du shell devient une feuille basse sur téléphone (panneau latéral sur tablette).',
        cols: 2,
        children: [
          Demo(
            label: 'Panneau de notifications',
            child: Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonalIcon(
                onPressed: () => showSidePanel(
                  context,
                  title: 'Notifications',
                  icon: Icons.notifications,
                  child: ListView(children: [
                    for (final n in kNotifications)
                      ListTile(
                        leading: Container(width: 38, height: 38, decoration: BoxDecoration(shape: BoxShape.circle, color: n.tone.light(c)), child: Icon(n.icon, size: 19, color: n.tone.color(c))),
                        title: Text(n.title, style: TextStyle(fontWeight: n.read ? FontWeight.w500 : FontWeight.w700)),
                        subtitle: Text(n.text),
                        isThreeLine: true,
                      ),
                  ]),
                ),
                icon: const Icon(Icons.notifications, size: 18),
                label: const Text('Ouvrir le panneau'),
              ),
            ),
          ),
          Demo(
            label: 'Feuille extensible',
            child: Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (ctx) => DraggableScrollableSheet(
                    expand: false,
                    initialChildSize: 0.45,
                    maxChildSize: 0.92,
                    minChildSize: 0.3,
                    builder: (ctx, ctrl) => ListView(controller: ctrl, padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), children: [
                      Text('Tâches du jour', style: TextStyle(fontFamily: Fonts.heading, fontSize: 18, fontWeight: FontWeight.w600, color: c.textPrimary)),
                      const SizedBox(height: 4),
                      Text('Glissez vers le haut pour agrandir.', style: TextStyle(fontSize: 12, color: c.textMuted)),
                      for (var i = 0; i < 14; i++) CheckboxListTile(value: i < 3, onChanged: (_) {}, title: Text('Tâche ${i + 1} — ${kDemoClients[i].raisonSociale}'), controlAffinity: ListTileControlAffinity.leading),
                    ]),
                  ),
                ),
                icon: const Icon(Icons.expand_less, size: 18),
                label: const Text('Tâches du jour'),
              ),
            ),
          ),
        ],
      );

  DocSection _tooltip(KitColors c) => DocSection(
        id: 'tooltip',
        title: 'Tooltip',
        source: 'Tooltip (appui long sur mobile)',
        description: 'Sur écran tactile, l’info-bulle apparaît à l’appui long ; elle double toujours un libellé accessible.',
        children: [
          Demo(
            label: 'Appui long',
            child: DemoWrap(spacing: 16, children: [
              const Tooltip(message: 'Modifier le client', child: Icon(Icons.edit_outlined)),
              const Tooltip(message: 'Balise en ligne · dernier signal il y a 12 s', child: Icon(Icons.sensors, color: Colors.green)),
              Tooltip(
                richMessage: TextSpan(children: [
                  const TextSpan(text: 'CA mensuel\n', style: TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(text: '1 250 000 FCFA · +9 %', style: TextStyle(color: c.success)),
                ]),
                triggerMode: TooltipTriggerMode.tap,
                child: const Chip(avatar: Icon(Icons.touch_app, size: 16), label: Text('Toucher (riche)')),
              ),
            ]),
          ),
        ],
      );

  DocSection _loading(KitColors c) => DocSection(
        id: 'loading',
        title: 'Loading',
        source: 'CircularProgressIndicator · LinearProgressIndicator · RefreshIndicator',
        cols: 2,
        children: [
          Demo(
            label: 'Spinners',
            child: DemoWrap(spacing: 24, children: [
              const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5)),
              const SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 3)),
              SizedBox(width: 44, height: 44, child: CircularProgressIndicator(strokeWidth: 4, color: c.tertiary, backgroundColor: c.tertiaryLight)),
              const CircularProgressIndicator.adaptive(),
            ]),
          ),
          const Demo(label: 'Barre indéterminée', child: LinearProgressIndicator()),
          Demo(
            label: 'Barre déterminée',
            hint: 'toucher pour rejouer',
            child: InkWell(
              onTap: _runDeterminate,
              child: Gap([
                ClipRRect(borderRadius: Radii.pill, child: LinearProgressIndicator(value: _determinate, minHeight: 8)),
                Text('Import des positions : ${(_determinate * 100).round()} %', style: TextStyle(fontSize: 12, color: c.textSecondary)),
              ]),
            ),
          ),
          Demo(
            label: 'Tirer pour rafraîchir',
            flush: true,
            child: SizedBox(
              height: 200,
              child: RefreshIndicator(
                onRefresh: () async {
                  await Future<void>.delayed(const Duration(milliseconds: 900));
                  if (mounted) showKitSnack(context, 'Liste actualisée', kind: SnackKind.success);
                },
                child: ListView(physics: const AlwaysScrollableScrollPhysics(), children: [
                  Padding(padding: const EdgeInsets.all(12), child: Text('↓ Tirez la liste vers le bas', textAlign: TextAlign.center, style: TextStyle(color: c.textMuted, fontSize: 12))),
                  for (final x in kDemoClients.take(5)) ListTile(dense: true, title: Text(x.raisonSociale), subtitle: Text(x.ville)),
                ]),
              ),
            ),
          ),
          const Demo(label: 'Chargement avec libellé', flush: true, child: SizedBox(height: 140, child: OverlaySpinner(message: 'Chargement des clients…'))),
          Demo(
            label: 'Bouton en cours',
            child: Align(
              alignment: Alignment.centerLeft,
              child: KitButton(
                label: 'Enregistrer',
                loadingLabel: 'Enregistrement…',
                icon: Icons.save,
                loading: _saving,
                onPressed: () {
                  setState(() => _saving = true);
                  Timer(const Duration(milliseconds: 1500), () => mounted ? setState(() => _saving = false) : null);
                },
              ),
            ),
          ),
        ],
      );

  DocSection _skeleton(KitColors c) => DocSection(
        id: 'skeleton',
        title: 'Skeleton',
        source: 'Skeleton · SkeletonListTile',
        cols: 2,
        children: const [
          Demo(label: 'Lignes', child: Gap(gap: 8, [Skeleton(width: 180, height: 16), Skeleton(height: 12), Skeleton(height: 12), Skeleton(width: 220, height: 12)])),
          Demo(label: 'Liste avec avatar', child: Column(children: [SkeletonListTile(), SkeletonListTile(), SkeletonListTile()])),
          Demo(
            label: 'Carte',
            child: Gap(gap: 10, [
              Skeleton(height: 120, radius: 16),
              Skeleton(width: 160, height: 16),
              Skeleton(height: 12),
              Row(children: [Skeleton(width: 80, height: 28, radius: 14), SizedBox(width: 8), Skeleton(width: 80, height: 28, radius: 14)]),
            ]),
          ),
          Demo(
            label: 'Tuiles KPI',
            child: Row(children: [
              Expanded(child: Skeleton(height: 72, radius: 20)),
              SizedBox(width: 10),
              Expanded(child: Skeleton(height: 72, radius: 20)),
            ]),
          ),
        ],
      );

  DocSection _errors(KitColors c) => DocSection(
        id: 'error',
        title: 'Error state',
        source: 'ErrorState · EmptyState',
        cols: 3,
        children: [
          Demo(label: 'Erreur de chargement', child: ErrorState(code: 'HTTP 503 · réf. 7f2c-91', onRetry: () => showKitSnack(context, 'Nouvelle tentative…'))),
          Demo(
            label: 'Ressource introuvable',
            child: EmptyState(icon: Icons.person_off_outlined, title: 'Client introuvable', subtitle: 'Ce client a peut-être été supprimé ou fusionné.', actionLabel: 'Retour à la liste', actionIcon: Icons.arrow_back, onAction: () {}),
          ),
          const Demo(label: 'Accès refusé', child: ResultView(tone: KitTone.warning, icon: Icons.lock_outline, title: 'Accès refusé', subtitle: 'Vous n’avez pas la permission « Finance › Paiements ». Contactez votre administrateur.')),
        ],
      );

  DocSection _banners(KitColors c) {
    Widget b(String id, Widget Function(VoidCallback) w) => _bannersClosed.contains(id) ? const SizedBox.shrink() : w(() => setState(() => _bannersClosed.add(id)));
    return DocSection(
      id: 'banner',
      title: 'Bannière globale & hors ligne',
      source: 'GlobalBanner',
      children: [
        Demo(
          label: 'Bannières',
          flush: true,
          child: Column(children: [
            b('m', (x) => GlobalBanner(tone: KitTone.info, icon: Icons.build_circle_outlined, title: 'Maintenance planifiée', text: 'dimanche 02:00 – 04:00', onClose: x)),
            b('i', (x) => GlobalBanner(tone: KitTone.error, icon: Icons.report_outlined, title: 'Incident en cours', text: 'retards de remontée GPS', action: 'Statut', onAction: () {}, onClose: x)),
            b('a', (x) => GlobalBanner(tone: KitTone.warning, icon: Icons.schedule, title: 'Abonnement bientôt expiré', text: 'dans 12 jours', action: 'Renouveler', onAction: () {}, onClose: x)),
            b('n', (x) => GlobalBanner(tone: KitTone.purple, icon: Icons.auto_awesome, title: 'Nouveau : rapports carburant', action: 'Découvrir', onAction: () {}, onClose: x)),
            if (_bannersClosed.isNotEmpty) TextButton(onPressed: () => setState(_bannersClosed.clear), child: const Text('Réafficher les bannières')),
          ]),
        ),
        Demo(
          label: 'Hors ligne',
          hint: 'basculer la connexion',
          flush: true,
          child: Column(children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              child: _offline
                  ? Container(
                      width: double.infinity,
                      color: c.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                      child: Row(children: [
                        Icon(Icons.cloud_off, size: 18, color: c.bg),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Hors ligne — les modifications seront synchronisées au retour du réseau.', style: TextStyle(fontSize: 12.5, color: c.bg))),
                      ]),
                    )
                  : const SizedBox(width: double.infinity),
            ),
            SwitchListTile(value: !_offline, onChanged: (v) {
              setState(() => _offline = !v);
              if (v) showKitSnack(context, 'Connexion rétablie', kind: SnackKind.success);
            }, title: const Text('Connexion réseau'), secondary: Icon(_offline ? Icons.wifi_off : Icons.wifi)),
          ]),
        ),
      ],
    );
  }

  DocSection _resultSection(KitColors c) => DocSection(
        id: 'result',
        title: 'Page de résultat',
        source: 'ResultView',
        children: [
          Demo(
            label: 'Résultats',
            child: Gap([
              SegmentedToggle<String>(
                value: _result,
                expand: true,
                onChanged: (v) => setState(() => _result = v),
                options: const [('success', 'Succès', null), ('error', 'Échec', null), ('pending', 'Attente', null), ('404', '404', null)],
              ),
              switch (_result) {
                'success' => ResultView(
                    key: const ValueKey('s'),
                    tone: KitTone.success,
                    title: 'Paiement confirmé',
                    subtitle: 'Un reçu a été envoyé à jean.kouassi@transports-yao.ci.',
                    extra: const KitCard(child: Text('Réf. PAY-2026-4412 · 1 250 000 FCFA · Orange Money', textAlign: TextAlign.center)),
                    actions: [FilledButton(onPressed: () {}, child: const Text('Voir le reçu')), OutlinedButton(onPressed: () {}, child: const Text('Retour'))],
                  ),
                'error' => ResultView(key: const ValueKey('e'), tone: KitTone.error, title: 'Paiement refusé', subtitle: 'Solde insuffisant sur le compte mobile money.', actions: [FilledButton(onPressed: () {}, child: const Text('Réessayer'))]),
                'pending' => const ResultView(key: ValueKey('p'), tone: KitTone.info, icon: Icons.hourglass_top, title: 'Validation en cours', subtitle: 'Votre demande sera traitée sous 24 h ouvrées.'),
                _ => ResultView(key: const ValueKey('n'), tone: KitTone.neutral, icon: Icons.travel_explore, title: 'Page introuvable', subtitle: 'Le lien est peut-être expiré.', actions: [OutlinedButton(onPressed: () {}, child: const Text('Accueil'))]),
              },
            ]),
          ),
        ],
      );

  DocSection _undo(KitColors c) => DocSection(
        id: 'undo',
        title: 'Snackbar « Annuler »',
        source: 'showKitSnack(action: \'Annuler\')',
        description: 'Suppression optimiste : l’élément disparaît tout de suite et peut être restauré pendant quelques secondes.',
        children: [
          Demo(
            label: 'Tâches',
            flush: true,
            child: Column(children: [
              if (_tasks.isEmpty) const EmptyState(compact: true, icon: Icons.task_alt, title: 'Plus aucune tâche', subtitle: 'Bravo !'),
              for (final t in List.of(_tasks))
                ListTile(
                  leading: Icon(Icons.radio_button_unchecked, color: c.textMuted),
                  title: Text(t),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      final i = _tasks.indexOf(t);
                      setState(() => _tasks.remove(t));
                      showKitSnack(context, '« $t » supprimée', action: 'Annuler', duration: const Duration(seconds: 5), onAction: () => setState(() => _tasks.insert(i, t)));
                    },
                  ),
                ),
            ]),
          ),
        ],
      );
}
