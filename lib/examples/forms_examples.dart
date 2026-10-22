import 'package:flutter/material.dart';

import '../theme/kit_colors.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import '../widgets/kit_buttons.dart';
import '../widgets/selects.dart';
import 'ex_scaffold.dart';

// ─── Contact ────────────────────────────────────────────────────────────────
class ContactFormExample extends StatefulWidget {
  const ContactFormExample({super.key});
  @override
  State<ContactFormExample> createState() => _ContactState();
}

class _ContactState extends State<ContactFormExample> {
  bool _sent = false;
  String _subject = 'Demande de démo';

  @override
  Widget build(BuildContext context) {
    final infos = [
      (Icons.phone_outlined, 'Téléphone', '+225 27 22 40 50 60'),
      (Icons.alternate_email, 'E-mail', 'contact@sc-storage.ci'),
      (Icons.location_on_outlined, 'Bureaux', 'Plateau, Abidjan'),
    ];
    return ExPage(title: 'Contact', maxWidth: 960, children: [
      const ExHeading('Parlons de votre projet', subtitle: 'Notre équipe vous répond sous 24 h ouvrées.'),
      ResponsiveGrid(minItemWidth: 220, maxColumns: 3, children: [
        for (final i in infos)
          KitCard(child: Row(children: [
            Icon(i.$1, color: context.kc.primary),
            const SizedBox(width: Space.s3),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(i.$2, style: TextStyle(fontSize: 12, color: context.kc.textMuted)),
              Text(i.$3, style: const TextStyle(fontWeight: FontWeight.w600)),
            ])),
          ])),
      ]),
      const SizedBox(height: Space.s6),
      KitCard(
        padding: const EdgeInsets.all(Space.s6),
        child: _sent
            ? ExSuccess(title: 'Message envoyé', message: 'Merci ! Nous revenons vers vous très vite.', onReset: () => setState(() => _sent = false))
            : ExGap([
                const ExRow([
                  KitTextField(label: 'Nom complet', hint: 'Jean Kouassi', icon: Icons.person_outline, required: true, textInputAction: TextInputAction.next),
                  KitTextField(label: 'E-mail', hint: 'nom@entreprise.ci', icon: Icons.alternate_email, required: true, keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next),
                ]),
                const KitTextField(label: 'Téléphone', hint: '07 07 12 34 56', icon: Icons.phone, keyboardType: TextInputType.phone, textInputAction: TextInputAction.done),
                // Sélecteur en feuille du kit (comme `SearchableSelect` React Native), pas un menu déroulant.
                SearchableSelect<String>(
                  label: 'Objet',
                  value: _subject,
                  options: [for (final s in ['Demande de démo', 'Devis', 'Support', 'Partenariat']) SelectOption(s, s)],
                  onChanged: (v) => setState(() => _subject = v ?? _subject),
                ),
                const KitTextField(label: 'Message', hint: 'Décrivez votre besoin : contexte, volumes, délais…', maxLines: 5, minLines: 4),
                Align(alignment: Alignment.centerRight, child: KitButton(label: 'Envoyer', icon: Icons.send, onPressed: () => setState(() => _sent = true))),
              ]),
      ),
    ]);
  }
}

// ─── Réservation ────────────────────────────────────────────────────────────
class BookingFormExample extends StatefulWidget {
  const BookingFormExample({super.key});
  @override
  State<BookingFormExample> createState() => _BookingState();
}

class _BookingState extends State<BookingFormExample> {
  int _type = 0, _day = 2, _slot = -1;
  bool _done = false;
  static const _types = [('Formation utilisateurs', '2 h', Icons.school_outlined), ('Démonstration produit', '45 min', Icons.slideshow_outlined), ('Atelier paramétrage', '3 h', Icons.tune)];
  static const _days = ['Lun 19', 'Mar 20', 'Mer 21', 'Jeu 22', 'Ven 23'];
  static const _morning = ['08:30', '09:30', '10:30', '11:30'];
  static const _afternoon = ['14:00', '15:00', '16:00', '17:00'];

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    Widget slots(String label, List<String> list, int offset) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: c.textSecondary)),
          const SizedBox(height: Space.s2),
          Wrap(spacing: Space.s2, runSpacing: Space.s2, children: [
            for (var i = 0; i < list.length; i++)
              ChoiceChip(label: Text(list[i]), selected: _slot == offset + i, onSelected: (_) => setState(() => _slot = offset + i)),
          ]),
        ]);
    return ExPage(title: 'Réservation', bottom: _done ? null : ExActionBar(children: [
      Expanded(child: KitButton(label: 'Confirmer la réservation', expand: true, icon: Icons.event_available, onPressed: _slot < 0 ? null : () => setState(() => _done = true))),
    ]), children: [
      if (_done)
        KitCard(child: ExSuccess(title: 'Réservation confirmée', message: '${_types[_type].$1} · ${_days[_day]} octobre à ${[..._morning, ..._afternoon][_slot]}', onReset: () => setState(() { _done = false; _slot = -1; })))
      else ...[
        const ExHeading('Réservez un créneau', subtitle: 'Choisissez une prestation, un jour et une heure.'),
        for (var i = 0; i < _types.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.s2),
            child: KitCard(
              onTap: () => setState(() => _type = i),
              borderColor: _type == i ? c.primary : null,
              child: Row(children: [
                Icon(_types[i].$3, color: _type == i ? c.primary : c.textSecondary),
                const SizedBox(width: Space.s3),
                Expanded(child: Text(_types[i].$1, style: const TextStyle(fontWeight: FontWeight.w600))),
                StatusBadge(_types[i].$2, uppercase: false),
              ]),
            ),
          ),
        const SizedBox(height: Space.s4),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            for (var i = 0; i < _days.length; i++)
              Padding(padding: const EdgeInsets.only(right: Space.s2), child: ChoiceChip(label: Text(_days[i]), selected: _day == i, onSelected: (_) => setState(() { _day = i; _slot = -1; }))),
          ]),
        ),
        const SizedBox(height: Space.s4),
        ExRow([slots('Matin', _morning, 0), slots('Après-midi', _afternoon, 4)]),
        const SizedBox(height: Space.s4),
        const KitTextField(label: 'Remarque (facultatif)', maxLines: 3),
      ],
    ]);
  }
}

// ─── Questionnaire ──────────────────────────────────────────────────────────
class SurveyFormExample extends StatefulWidget {
  const SurveyFormExample({super.key});
  @override
  State<SurveyFormExample> createState() => _SurveyState();
}

class _SurveyState extends State<SurveyFormExample> {
  int _q = 0, _nps = -1, _freq = -1;
  final _ratings = <String, int>{'Facilité d’utilisation': 4, 'Rapidité': 3, 'Support client': 5};
  final _features = <String>{};
  static const _freqs = ['Plusieurs fois par jour', 'Tous les jours', 'Chaque semaine', 'Rarement'];
  static const _feat = ['Mode hors ligne', 'Signature électronique', 'Paiement Mobile Money intégré', 'Rapports personnalisés', 'API publique'];
  static const _titles = ['Recommanderiez-vous SC Storage à un collègue ?', 'À quelle fréquence utilisez-vous l’application ?', 'Comment évaluez-vous ces aspects ?', 'Quelles fonctionnalités aimeriez-vous voir arriver ?', 'Un dernier mot pour l’équipe ?'];

  Widget _body(BuildContext context) {
    final c = context.kc;
    switch (_q) {
      case 0:
        return LayoutBuilder(builder: (context, box) {
          final w = ((box.maxWidth - 10 * Space.s1) / 11).clamp(24.0, 48.0);
          return Column(children: [
            Wrap(spacing: Space.s1, runSpacing: Space.s1, alignment: WrapAlignment.center, children: [
              for (var i = 0; i <= 10; i++)
                SizedBox(
                  width: w, height: 44,
                  child: Material(
                    color: _nps == i ? c.primary : c.hover,
                    borderRadius: BorderRadius.circular(Radii.sm),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(Radii.sm),
                      onTap: () => setState(() => _nps = i),
                      child: Center(child: Text('$i', style: TextStyle(fontWeight: FontWeight.w700, color: _nps == i ? c.onPrimary : c.textPrimary))),
                    ),
                  ),
                ),
            ]),
            const SizedBox(height: Space.s2),
            Row(children: [Text('Pas du tout', style: TextStyle(fontSize: 12, color: c.textMuted)), const Spacer(), Text('Absolument', style: TextStyle(fontSize: 12, color: c.textMuted))]),
          ]);
        });
      case 1:
        return RadioGroup<int>(
          groupValue: _freq,
          onChanged: (v) => setState(() => _freq = v!),
          child: Column(children: [for (var i = 0; i < _freqs.length; i++) RadioListTile<int>(value: i, title: Text(_freqs[i]))]),
        );
      case 2:
        return Column(children: [
          for (final e in _ratings.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.s3),
              child: Wrap(alignment: WrapAlignment.spaceBetween, crossAxisAlignment: WrapCrossAlignment.center, spacing: Space.s2, children: [
                Text(e.key, style: const TextStyle(fontWeight: FontWeight.w500)),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  for (var s = 1; s <= 5; s++)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: '$s étoile${s > 1 ? 's' : ''}',
                      icon: Icon(s <= e.value ? Icons.star : Icons.star_border, color: context.kc.warning),
                      onPressed: () => setState(() => _ratings[e.key] = s),
                    ),
                ]),
              ]),
            ),
        ]);
      case 3:
        return Column(children: [
          for (final f in _feat)
            CheckboxListTile(value: _features.contains(f), title: Text(f), onChanged: (v) => setState(() => v! ? _features.add(f) : _features.remove(f))),
        ]);
      default:
        return const KitTextField(label: 'Votre message', hint: 'Ce qui vous plaît, ce qui vous agace, vos idées…', maxLines: 5, minLines: 4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final last = _q == _titles.length - 1;
    return ExPage(title: 'Questionnaire', children: [
      Text('Question ${_q + 1} sur ${_titles.length}', style: TextStyle(color: context.kc.textMuted)),
      const SizedBox(height: Space.s2),
      KitProgressBar(value: (_q + 1) / _titles.length),
      const SizedBox(height: Space.s6),
      ExHeading(_titles[_q]),
      _body(context),
      const SizedBox(height: Space.s6),
      Wrap(alignment: WrapAlignment.spaceBetween, spacing: Space.s2, runSpacing: Space.s2, children: [
        KitButton(label: 'Question précédente', icon: Icons.arrow_back, variant: KitButtonVariant.ghost, onPressed: _q == 0 ? null : () => setState(() => _q--)),
        KitButton(label: last ? 'Envoyer' : 'Question suivante', iconEnd: last ? Icons.send : Icons.arrow_forward,
            onPressed: () => last ? exDemo(context, 'Réponses envoyées') : setState(() => _q++)),
      ]),
    ]);
  }
}

// ─── Commande (checkout) ────────────────────────────────────────────────────
class CheckoutFormExample extends StatefulWidget {
  const CheckoutFormExample({super.key});
  @override
  State<CheckoutFormExample> createState() => _CheckoutState();
}

class _CheckoutState extends State<CheckoutFormExample> {
  int _step = 0, _ship = 0, _pay = 0;
  bool _done = false;
  final _items = [('Carton double cannelure ×50', 42500, 1), ('Ruban adhésif 48 mm', 3500, 4), ('Étiquettes thermiques', 12000, 2)];
  static const _ships = [('Standard', '3 à 5 jours', 2000), ('Express', '24 h', 5000), ('Retrait en point relais', '2 jours', 0)];
  static const _pays = [('Orange Money', Icons.phone_android), ('MTN MoMo', Icons.phone_android), ('Wave', Icons.waves), ('Carte bancaire', Icons.credit_card)];

  int get _subtotal => _items.fold(0, (s, i) => s + i.$2 * i.$3);
  String _f(int v) => '${v.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ' ')} F CFA';

  Widget _summary(BuildContext context) => KitCard(
        title: 'Récapitulatif',
        icon: Icons.receipt_long,
        child: ExGap(gap: Space.s2, [
          for (final i in _items) Row(children: [Expanded(child: Text('${i.$1} · ${i.$3}')), Text(_f(i.$2 * i.$3))]),
          const Divider(),
          Row(children: [const Expanded(child: Text('Livraison')), Text(_f(_ships[_ship].$3))]),
          Row(children: [const Expanded(child: Text('Total', style: TextStyle(fontWeight: FontWeight.w700))), Text(_f(_subtotal + _ships[_ship].$3), style: const TextStyle(fontWeight: FontWeight.w700))]),
          const KitTextField(hint: 'Code promo (AKWABA10)', icon: Icons.local_offer_outlined),
        ]),
      );

  Widget _stepBody() {
    switch (_step) {
      case 0:
        return ExGap([
          const ExRow([KitTextField(label: 'Nom complet', initialValue: 'Aya Koné', textInputAction: TextInputAction.next), KitTextField(label: 'Téléphone', initialValue: '+225 07 07 12 34 56', keyboardType: TextInputType.phone, textInputAction: TextInputAction.next)]),
          const KitTextField(label: 'Adresse', initialValue: 'Cocody Angré, 8e tranche', keyboardType: TextInputType.streetAddress, textInputAction: TextInputAction.next),
          const KitTextField(label: 'Indications', hint: 'Portail bleu, à côté de la pharmacie…', textInputAction: TextInputAction.done),
          RadioGroup<int>(
            groupValue: _ship,
            onChanged: (v) => setState(() => _ship = v!),
            child: Column(children: [
              for (var i = 0; i < _ships.length; i++) RadioListTile<int>(value: i, title: Text(_ships[i].$1), subtitle: Text('${_ships[i].$2} · ${_ships[i].$3 == 0 ? 'Gratuit' : _f(_ships[i].$3)}')),
            ]),
          ),
        ]);
      case 1:
        return ExGap([
          Wrap(spacing: Space.s2, runSpacing: Space.s2, children: [
            for (var i = 0; i < _pays.length; i++) ChoiceChip(avatar: Icon(_pays[i].$2, size: 18), label: Text(_pays[i].$1), selected: _pay == i, onSelected: (_) => setState(() => _pay = i)),
          ]),
          if (_pay == 3) ...[
            const KitTextField(label: 'Numéro de carte', hint: '4242 4242 4242 4242', icon: Icons.credit_card, keyboardType: TextInputType.number, textInputAction: TextInputAction.next),
            const ExRow([KitTextField(label: 'Expiration', hint: 'MM / AA', keyboardType: TextInputType.number, textInputAction: TextInputAction.next), KitTextField(label: 'CVC', hint: '123', keyboardType: TextInputType.number, textInputAction: TextInputAction.done)]),
          ] else
            const KitTextField(label: 'Numéro Mobile Money', initialValue: '07 07 12 34 56', icon: Icons.phone_android, keyboardType: TextInputType.phone, textInputAction: TextInputAction.done),
        ]);
      default:
        return Text('Vérifiez votre commande puis confirmez. Paiement : ${_pays[_pay].$1}, livraison : ${_ships[_ship].$1}.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_done) {
      return ExPage(title: 'Commande', children: [KitCard(child: ExSuccess(title: 'Commande confirmée', message: 'Commande n° CMD-2026-0412 · ${_f(_subtotal + _ships[_ship].$3)}', onReset: () => setState(() { _done = false; _step = 0; })))]);
    }
    const labels = ['Livraison', 'Paiement', 'Validation'];
    final form = KitCard(
      child: ExGap([
        Wrap(spacing: Space.s2, runSpacing: Space.s2, children: [
          for (var i = 0; i < 3; i++) StatusBadge('${i + 1}. ${labels[i]}', uppercase: false, tone: i == _step ? KitTone.primary : (i < _step ? KitTone.success : KitTone.neutral)),
        ]),
        _stepBody(),
      ]),
    );
    final bar = ExActionBar(children: [
      KitButton(label: 'Retour', variant: KitButtonVariant.ghost, onPressed: _step == 0 ? null : () => setState(() => _step--)),
      KitButton(label: _step == 2 ? 'Payer' : 'Continuer', onPressed: () => setState(() => _step == 2 ? _done = true : _step++)),
    ]);
    return ExPage(title: 'Commande', maxWidth: 1080, bottom: bar, children: [
      LayoutBuilder(builder: (context, box) {
        if (box.maxWidth < Breakpoints.lg) return ExGap([form, _summary(context)]);
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 3, child: form), const SizedBox(width: Space.s6), Expanded(flex: 2, child: _summary(context))]);
      }),
    ]);
  }
}

// ─── Onboarding ─────────────────────────────────────────────────────────────
class OnboardingFormExample extends StatefulWidget {
  const OnboardingFormExample({super.key});
  @override
  State<OnboardingFormExample> createState() => _OnboardingState();
}

class _OnboardingState extends State<OnboardingFormExample> {
  int _step = 0;
  String _sector = 'Transport & logistique';
  final _modules = <String>{'Stocks'};
  final _invites = <String>['awa.diallo@sotra.ci'];
  static const _steps = ['Votre profil', 'Votre organisation', 'Vos modules', 'Votre équipe'];
  static const _sectors = ['Transport & logistique', 'Agro-industrie', 'Commerce & distribution', 'Services', 'Santé', 'Autre'];
  static const _mods = [('Stocks', Icons.inventory_2_outlined), ('Ventes', Icons.point_of_sale), ('Achats', Icons.shopping_cart_outlined), ('Comptabilité', Icons.account_balance_outlined), ('RH', Icons.badge_outlined), ('Flotte', Icons.local_shipping_outlined)];

  Widget _body() {
    switch (_step) {
      case 0:
        return const ExGap([ExHeading('Faisons connaissance'), ExRow([KitTextField(label: 'Prénom', initialValue: 'Koffi', textInputAction: TextInputAction.next), KitTextField(label: 'Nom', initialValue: 'Yao', textInputAction: TextInputAction.next)]), KitTextField(label: 'Fonction', initialValue: 'Directeur des opérations')]);
      case 1:
        return ExGap([
          const ExHeading('Votre organisation'),
          const KitTextField(label: 'Raison sociale', initialValue: 'Sotra Logistique'),
          Wrap(spacing: Space.s2, runSpacing: Space.s2, children: [for (final s in _sectors) ChoiceChip(label: Text(s), selected: _sector == s, onSelected: (_) => setState(() => _sector = s))]),
        ]);
      case 2:
        return ExGap([
          const ExHeading('Que voulez-vous gérer ?'),
          ResponsiveGrid(minItemWidth: 150, maxColumns: 3, spacing: Space.s3, children: [
            for (final m in _mods)
              KitCard(
                onTap: () => setState(() => _modules.contains(m.$1) ? _modules.remove(m.$1) : _modules.add(m.$1)),
                borderColor: _modules.contains(m.$1) ? context.kc.primary : null,
                child: Row(children: [Icon(m.$2), const SizedBox(width: Space.s2), Expanded(child: Text(m.$1)), if (_modules.contains(m.$1)) Icon(Icons.check_circle, color: context.kc.primary, size: 20)]),
              ),
          ]),
        ]);
      default:
        return ExGap([
          const ExHeading('Invitez votre équipe'),
          Row(children: [
            const Expanded(child: KitTextField(hint: 'collegue@entreprise.ci', icon: Icons.alternate_email)),
            const SizedBox(width: Space.s2),
            KitButton(label: 'Inviter', onPressed: () => setState(() => _invites.add('nouveau.membre${_invites.length}@sotra.ci'))),
          ]),
          Wrap(spacing: Space.s2, runSpacing: Space.s2, children: [for (final e in _invites) InputChip(label: Text(e), onDeleted: () => setState(() => _invites.remove(e)))]),
        ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bar = ExActionBar(children: [
      KitButton(label: 'Retour', variant: KitButtonVariant.ghost, onPressed: _step == 0 ? null : () => setState(() => _step--)),
      KitButton(label: _step == 3 ? 'Terminer' : 'Continuer', onPressed: () => _step == 3 ? exDemo(context, 'Espace configuré') : setState(() => _step++)),
    ]);
    return ExPage(title: 'Configurons votre espace', bottom: bar, children: [
      Text('Étape ${_step + 1} sur 4 · ${_steps[_step]}', style: TextStyle(color: context.kc.textMuted)),
      const SizedBox(height: Space.s2),
      KitProgressBar(value: (_step + 1) / 4),
      const SizedBox(height: Space.s6),
      KitCard(padding: const EdgeInsets.all(Space.s6), child: _body()),
    ]);
  }
}

// ─── Candidature ────────────────────────────────────────────────────────────
class ApplicationFormExample extends StatefulWidget {
  const ApplicationFormExample({super.key});
  @override
  State<ApplicationFormExample> createState() => _ApplicationState();
}

class _ApplicationState extends State<ApplicationFormExample> {
  bool _sent = false, _consent = false;
  final _skills = <String>['Angular', 'Flutter', 'TypeScript'];
  final _jobs = <(String, String)>[('Développeur front-end', 'Orange CI · 2020 – 2024')];
  static const _sections = ['Identité', 'Expérience', 'Documents', 'Prétentions', 'Signature'];

  Widget _section(String title, IconData icon, Widget child) => Padding(padding: const EdgeInsets.only(bottom: Space.s4), child: KitCard(title: title, icon: icon, child: child));

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    if (_sent) {
      return ExPage(title: 'Candidature', children: [KitCard(child: ExSuccess(title: 'Candidature envoyée', message: 'Nous étudions votre dossier et revenons vers vous sous 10 jours.', onReset: () => setState(() => _sent = false)))]);
    }
    final bar = SafeArea(
      child: Container(
        padding: const EdgeInsets.all(Space.s3),
        decoration: BoxDecoration(color: c.card, border: Border(top: BorderSide(color: c.border))),
        child: LayoutBuilder(builder: (context, box) {
          final status = Text(_consent ? 'Prêt à envoyer' : 'Brouillon enregistré · cochez la déclaration', style: TextStyle(color: c.textMuted, fontSize: 13));
          final buttons = [
            KitButton(label: 'Enregistrer', variant: KitButtonVariant.outline, expand: box.maxWidth < Breakpoints.md, onPressed: () => exDemo(context, 'Brouillon enregistré')),
            KitButton(label: 'Envoyer', icon: Icons.send, expand: box.maxWidth < Breakpoints.md, onPressed: _consent ? () => setState(() => _sent = true) : null),
          ];
          if (box.maxWidth < Breakpoints.md) {
            return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [status, const SizedBox(height: Space.s2), Row(children: [Expanded(child: buttons[0]), const SizedBox(width: Space.s2), Expanded(child: buttons[1])])]);
          }
          return Row(children: [Expanded(child: status), buttons[0], const SizedBox(width: Space.s2), buttons[1]]);
        }),
      ),
    );
    return ExPage(title: 'Candidature', bottom: bar, children: [
      const ExHeading('Développeur·se front-end confirmé·e', subtitle: 'CDI · Abidjan, Plateau · Hybride'),
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [for (final s in _sections) Padding(padding: const EdgeInsets.only(right: Space.s2), child: StatusBadge(s, uppercase: false))])),
      const SizedBox(height: Space.s4),
      _section('Identité', Icons.person_outline, const ExGap([
        ExRow([KitTextField(label: 'Prénom', initialValue: 'Mariam', textInputAction: TextInputAction.next), KitTextField(label: 'Nom', initialValue: 'Touré', textInputAction: TextInputAction.next)]),
        ExRow([KitTextField(label: 'Date de naissance', hint: 'jj/mm/aaaa', keyboardType: TextInputType.datetime, textInputAction: TextInputAction.next), KitTextField(label: 'Téléphone', hint: '+225 07 …', keyboardType: TextInputType.phone, textInputAction: TextInputAction.done)]),
      ])),
      _section('Expérience', Icons.work_outline, ExGap([
        for (final j in _jobs)
          ListTile(contentPadding: EdgeInsets.zero, title: Text(j.$1), subtitle: Text(j.$2), trailing: IconButton(tooltip: 'Supprimer ce poste', icon: const Icon(Icons.delete_outline), onPressed: () => setState(() => _jobs.remove(j)))),
        KitButton(label: 'Ajouter un poste', icon: Icons.add, variant: KitButtonVariant.outline, onPressed: () => setState(() => _jobs.add(('Intégrateur web', 'Freelance · 2018 – 2020')))),
        Wrap(spacing: Space.s2, runSpacing: Space.s2, children: [for (final s in _skills) InputChip(label: Text(s), onDeleted: () => setState(() => _skills.remove(s)))]),
      ])),
      _section('Documents', Icons.attach_file, const ExGap([KitTextField(label: 'CV', initialValue: 'cv-mariam-toure.pdf', readOnly: true, icon: Icons.picture_as_pdf), KitTextField(label: 'Lettre de motivation', maxLines: 3)])),
      _section('Prétentions', Icons.payments_outlined, const ExRow([KitTextField(label: 'Salaire brut mensuel', initialValue: '850 000 F CFA'), KitTextField(label: 'Disponibilité', hint: 'jj/mm/aaaa')])),
      _section('Signature', Icons.draw_outlined, CheckboxListTile(contentPadding: EdgeInsets.zero, value: _consent, onChanged: (v) => setState(() => _consent = v!), title: const Text('Je certifie l’exactitude des informations fournies.'))),
    ]);
  }
}
