import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/snack.dart';
import '../../data/showcase_data.dart';
import '../../theme/kit_colors.dart';
import '../../widgets/common.dart';
import '../../widgets/fields/basic_fields.dart';
import '../../widgets/fields/editors.dart';
import '../../widgets/fields/picker_fields.dart';
import '../../widgets/fields/signature_address.dart';
import '../../widgets/inputs.dart';
import '../../widgets/selects.dart';
import '../doc/doc.dart';

const _mdSample = '''## Compte-rendu d’intervention

Balise **FMB920** remplacée sur *CI-4521-AB*.

- Antenne GPS repositionnée
- Firmware mis à jour en `v03.28.07`
- [x] Test de coupure moteur
- [ ] Formation du chauffeur

> Le client confirme la reprise du signal.''';

/// `/components/fields` — champs complémentaires aux formulaires de base.
class FieldsGallery extends StatefulWidget {
  const FieldsGallery({super.key, this.initialSection});
  final String? initialSection;

  @override
  State<FieldsGallery> createState() => _FieldsGalleryState();
}

class _FieldsGalleryState extends State<FieldsGallery> {
  final _otpKey = GlobalKey<OtpInputState>();
  String _otp = '';
  bool _otpError = false;
  num _qty = 3, _duree = 12, _temp = 4.5;
  (int?, String) _amount = (1250000, 'FCFA');
  RangeValues _range = const RangeValues(20, 70);
  double _rating = 4, _sat = 0;
  final double _ratingHalf = 3.5;
  Color _color = const Color(0xFF006A6A);
  Set<String> _zones = {'marc', 'treich', 'yakro'};
  List<String> _avail = ['Tableau de bord', 'Alertes', 'Rapports carburant', 'Historique', 'Géofences', 'Maintenance', 'Chauffeurs'];
  List<String> _chosen = ['Position temps réel', 'Trajets'];
  List<String> _tags = ['urgent', 'abidjan-sud'];
  List<String> _tags2 = ['FMB920'];
  bool _signed = false;

  // Formulaire complet
  final _fk = GlobalKey<FormState>();
  String? _fType;
  DateTime? _fDate;
  num _fVeh = 1;
  double _fPrio = 2;
  bool _fSubmitted = false;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return DocPage(
      title: 'Champs avancés',
      icon: Icons.dynamic_form,
      initialSection: widget.initialSection,
      subtitle: 'Types de champs complémentaires, alignés sur le motif « field-box » : codes OTP, nombres, montants FCFA, intervalles, notation, couleur, éditeurs, signature, sélection arborescente, transfert, tags, adresse, mot de passe et valeurs à copier.',
      sections: [
        DocSection(
          id: 'otp',
          title: 'Code OTP / PIN',
          source: 'OtpInput',
          description: 'Clavier numérique, remplissage automatique du code SMS (autofill), avance automatique et effacement arrière.',
          cols: 2,
          children: [
            Demo(
              label: 'Code à 6 chiffres',
              hint: 'essayez 123456',
              code: "OtpInput(length: 6, onCompleted: verify)",
              child: Gap([
                Center(
                  child: OtpInput(
                    key: _otpKey,
                    error: _otpError,
                    onChanged: (v) => setState(() {
                      _otp = v;
                      _otpError = false;
                    }),
                    onCompleted: (v) {
                      final ok = v == '123456';
                      setState(() => _otpError = !ok);
                      showKitSnack(context, ok ? 'Code vérifié' : 'Code incorrect', kind: ok ? SnackKind.success : SnackKind.error);
                    },
                  ),
                ),
                Center(
                  child: Text(
                    _otpError ? 'Code incorrect, réessayez.' : 'Saisi : ${_otp.isEmpty ? '—' : _otp}',
                    style: TextStyle(fontSize: 12, color: _otpError ? c.errorText : c.textMuted),
                  ),
                ),
                Center(child: TextButton.icon(onPressed: () => _otpKey.currentState?.clear(), icon: const Icon(Icons.refresh, size: 18), label: const Text('Renvoyer le code'))),
              ]),
            ),
            const Demo(label: 'PIN masqué (4)', child: Center(child: OtpInput(length: 4, obscure: true))),
          ],
        ),
        DocSection(
          id: 'stepper',
          title: 'Nombre avec + / −',
          source: 'NumberStepper',
          cols: 3,
          children: [
            Demo(label: 'Quantité', child: Center(child: NumberStepper(value: _qty, min: 1, max: 20, onChanged: (v) => setState(() => _qty = v)))),
            Demo(label: 'Avec unité et pas', child: Center(child: NumberStepper(value: _duree, min: 1, max: 60, step: 6, unit: 'mois', onChanged: (v) => setState(() => _duree = v)))),
            Demo(label: 'Décimal', child: Center(child: NumberStepper(value: _temp, min: -20, max: 20, step: 0.5, unit: '°C', onChanged: (v) => setState(() => _temp = v)))),
          ],
        ),
        DocSection(
          id: 'currency',
          title: 'Montant / devise',
          source: 'CurrencyInput · ThousandsFormatter',
          description: 'Séparateur de milliers à la saisie, devise au choix, raccourcis de montant.',
          cols: 2,
          children: [
            Demo(
              label: 'Montant FCFA',
              child: Gap([
                CurrencyInput(initial: 1250000, presets: const [50000, 250000, 1000000, 5000000], onChanged: (v) => setState(() => _amount = v)),
                Text('Valeur : ${_amount.$1 == null ? '—' : Fmt.number(_amount.$1!)} ${_amount.$2}', style: TextStyle(fontSize: 12, color: c.textMuted)),
              ]),
            ),
            Demo(label: 'Devise unique', child: CurrencyInput(currencies: const ['FCFA'], onChanged: (_) {})),
          ],
        ),
        DocSection(
          id: 'range',
          title: 'Intervalle à double curseur',
          source: 'RangeSlider',
          children: [
            Demo(
              label: 'Plage de vitesse autorisée',
              child: Gap([
                Row(children: [
                  Expanded(child: _MiniBox(label: 'Min', value: '${_range.start.round()} km/h')),
                  const SizedBox(width: 12),
                  Expanded(child: _MiniBox(label: 'Max', value: '${_range.end.round()} km/h')),
                ]),
                RangeSlider(
                  values: _range,
                  min: 0,
                  max: 130,
                  divisions: 26,
                  labels: RangeLabels('${_range.start.round()}', '${_range.end.round()}'),
                  onChanged: (v) => setState(() => _range = v),
                ),
              ]),
            ),
          ],
        ),
        DocSection(
          id: 'rating',
          title: 'Notation',
          source: 'RatingInput',
          cols: 3,
          children: [
            Demo(
              label: 'Étoiles + libellé',
              child: RatingInput(value: _rating, labels: const ['Mauvais', 'Passable', 'Correct', 'Très bien', 'Excellent'], onChanged: (v) => setState(() => _rating = v)),
            ),
            Demo(label: 'Lecture seule (demi-étoile)', child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 8, runSpacing: 4, children: [RatingInput(value: _ratingHalf, size: 22), Text('${_ratingHalf.toString().replaceAll('.', ',')} / 5 · 128 avis', style: TextStyle(fontSize: 12, color: c.textSecondary))])),
            Demo(
              label: 'Icône personnalisée',
              child: RatingInput(value: _sat, icon: Icons.favorite, emptyIcon: Icons.favorite_border, color: c.error, onChanged: (v) => setState(() => _sat = v)),
            ),
          ],
        ),
        DocSection(
          id: 'color',
          title: 'Sélecteur de couleur',
          source: 'ColorPickerField',
          cols: 2,
          children: [
            Demo(label: 'Couleur de la catégorie', child: ColorPickerField(value: _color, onChanged: (v) => setState(() => _color = v))),
            Demo(
              label: 'Résultat',
              child: Gap([
                ColorChipLabel(_color),
                Container(
                  height: 90,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: _color, borderRadius: BorderRadius.circular(16)),
                  child: Text('Catégorie « Poids lourds »', style: TextStyle(fontWeight: FontWeight.w700, color: contrastOn(_color))),
                ),
              ]),
            ),
          ],
        ),
        DocSection(
          id: 'rich-text',
          title: 'Éditeur de texte riche',
          source: 'RichTextEditor (remplace CKEditor / Quill)',
          description: 'Sélectionnez du texte puis appliquez gras, italique, souligné, barré ou surlignage ; sans sélection, le style s’applique à la frappe suivante.',
          children: const [
            Demo(
              label: 'Message au client',
              flush: true,
              padding: EdgeInsets.zero,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: RichTextEditor(initialText: 'Bonjour Monsieur Kouassi. Notre technicien passera vendredi entre 8 h et 10 h pour remplacer la balise du véhicule CI-4521-AB.'),
              ),
            ),
          ],
        ),
        const DocSection(
          id: 'markdown',
          title: 'Éditeur Markdown',
          source: 'MarkdownEditor · MarkdownView',
          description: 'Barre d’outils qui insère la syntaxe, bascule Écrire / Aperçu, compteur de mots.',
          children: [Demo(label: 'Compte-rendu', child: MarkdownEditor(initial: _mdSample))],
        ),
        DocSection(
          id: 'signature',
          title: 'Signature',
          source: 'SignaturePad',
          description: 'Tracé lissé au doigt, couleur d’encre, épaisseur, annulation du dernier trait.',
          children: [
            Demo(
              label: 'Signature du client',
              hint: _signed ? 'signé' : 'vide',
              child: SignaturePad(onChanged: (v) => setState(() => _signed = v)),
            ),
          ],
        ),
        DocSection(
          id: 'tree-select',
          title: 'Sélection arborescente',
          source: 'TreeSelect',
          description: 'Cases en cascade avec état indéterminé, dépliage et filtre.',
          children: [Demo(label: 'Zones d’intervention', child: TreeSelect(nodes: kZonesTree, selected: _zones, onChanged: (v) => setState(() => _zones = v)))],
        ),
        DocSection(
          id: 'transfer',
          title: 'Liste de transfert',
          source: 'TransferList',
          description: 'Sur téléphone, les deux listes s’empilent avec les commandes de transfert entre elles.',
          children: [
            Demo(
              label: 'Modules de l’abonnement',
              child: TransferList(
                available: _avail,
                chosen: _chosen,
                leftTitle: 'Modules disponibles',
                rightTitle: 'Inclus',
                onChanged: (a, b) => setState(() {
                  _avail = a;
                  _chosen = b;
                }),
              ),
            ),
          ],
        ),
        DocSection(
          id: 'tags',
          title: 'Tags libres avec suggestions',
          source: 'TagInput',
          cols: 2,
          children: [
            Demo(
              label: 'Tags (Entrée ou virgule)',
              child: TagInput(tags: _tags, suggestions: const ['urgent', 'vip', 'abidjan-sud', 'abidjan-nord', 'relance', 'contentieux', 'nouveau'], onChanged: (v) => setState(() => _tags = v)),
            ),
            Demo(label: 'Limite (3 max)', child: TagInput(tags: _tags2, max: 3, hint: 'Modèle de balise…', suggestions: const ['FMB920', 'FMC130', 'GT06', 'TK103'], onChanged: (v) => setState(() => _tags2 = v))),
          ],
        ),
        DocSection(
          id: 'address',
          title: 'Adresse avec carte',
          source: 'AddressField (répertoire local, sans géocodeur)',
          description: 'Recherche insensible aux accents dans 16 adresses ivoiriennes ; touchez la carte pour une position personnalisée.',
          children: [Demo(label: 'Adresse d’installation', child: AddressField(initial: kDemoPlaces[3]))],
        ),
        const DocSection(
          id: 'password',
          title: 'Mot de passe avec jauge',
          source: 'PasswordField',
          children: [Demo(label: 'Nouveau mot de passe', child: PasswordField())],
        ),
        const DocSection(
          id: 'copy',
          title: 'Valeur à copier',
          source: 'CopyField',
          cols: 2,
          children: [
            Demo(label: 'Identifiant', child: CopyField(label: 'IMEI', value: '356307042441013', icon: Icons.memory)),
            Demo(label: 'Secret masqué', child: CopyField(label: 'Clé d’API', value: 'lk_live_9f2c4e1a7b3d8e6f5a0c', secret: true, icon: Icons.key)),
          ],
        ),
        DocSection(
          id: 'form',
          title: 'Formulaire complet (réactif)',
          source: 'Form + champs avancés',
          children: [
            Demo(
              label: 'Demande d’intervention',
              child: Form(
                key: _fk,
                autovalidateMode: _fSubmitted ? AutovalidateMode.always : AutovalidateMode.disabled,
                child: Gap(gap: 14, [
                  FormField<String>(
                    validator: (_) => _fType == null ? 'Sélection obligatoire' : null,
                    builder: (s) => SearchableSelect<String>(
                      label: 'Type *',
                      error: s.errorText,
                      options: [for (final e in const {'installation': 'Installation', 'maintenance': 'Maintenance', 'diagnostic': 'Diagnostic'}.entries) SelectOption(e.key, e.value)],
                      value: _fType,
                      onChanged: (v) {
                        setState(() => _fType = v);
                        s.didChange(v);
                      },
                    ),
                  ),
                  SearchableSelect<String>(
                    label: 'Client',
                    options: [for (final x in kDemoClients.take(12)) SelectOption(x.id, x.raisonSociale, subtitle: x.ville)],
                    value: null,
                    onChanged: (_) {},
                  ),
                  FormField<DateTime>(
                    validator: (_) => _fDate == null ? 'Date obligatoire' : null,
                    builder: (s) => DateField(
                      label: 'Date souhaitée *',
                      value: _fDate,
                      error: s.errorText,
                      onChanged: (d) {
                        setState(() => _fDate = d);
                        s.didChange(d);
                      },
                    ),
                  ),
                  FormFieldLabel(label: 'Nombre de véhicules', child: Align(alignment: Alignment.centerLeft, child: NumberStepper(value: _fVeh, min: 1, max: 50, onChanged: (v) => setState(() => _fVeh = v)))),
                  FormFieldLabel(
                    label: 'Priorité',
                    child: RatingInput(value: _fPrio, icon: Icons.local_fire_department, emptyIcon: Icons.local_fire_department_outlined, color: c.tertiary, max: 4, labels: const ['Basse', 'Normale', 'Haute', 'Critique'], onChanged: (v) => setState(() => _fPrio = v)),
                  ),
                  const FormFieldLabel(label: 'Adresse', child: AddressField(mapHeight: 160)),
                  FilledButton.icon(
                    onPressed: () {
                      setState(() => _fSubmitted = true);
                      final ok = _fk.currentState!.validate();
                      showKitSnack(context, ok ? 'Demande envoyée (démo statique)' : 'Complétez les champs obligatoires', kind: ok ? SnackKind.success : SnackKind.error);
                    },
                    icon: const Icon(Icons.send, size: 18),
                    label: const Text('Envoyer la demande'),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MiniBox extends StatelessWidget {
  const _MiniBox({required this.label, required this.value});
  final String label, value;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: c.fieldBg, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 11, color: c.textMuted)),
        Text(value, style: TextStyle(fontWeight: FontWeight.w700, color: c.textPrimary)),
      ]),
    );
  }
}
