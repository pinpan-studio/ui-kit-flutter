import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/snack.dart';
import '../../data/showcase_data.dart';
import '../../theme/kit_colors.dart';
import '../../widgets/common.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/inputs.dart';
import '../../widgets/selects.dart';
import '../doc/doc.dart';
import 'package:ui_kit_flutter/theme/tokens.dart';
import '../../core/haptics.dart';

final _villes = [for (final v in kVilles) SelectOption(v, v, icon: Icons.location_on_outlined)];
final _secteurs = [for (final s in kSecteurs) SelectOption(s, s)];
const _priorites = [
  SelectOption('basse', 'Basse', tone: KitTone.neutral),
  SelectOption('normale', 'Normale', tone: KitTone.info),
  SelectOption('haute', 'Haute', tone: KitTone.warning),
  SelectOption('critique', 'Critique', tone: KitTone.error),
];

/// `/components/forms` — champs de saisie, sélecteurs, dates, choix, upload, recherche, validation.
class FormsGallery extends StatefulWidget {
  const FormsGallery({super.key, this.initialSection});
  final String? initialSection;

  @override
  State<FormsGallery> createState() => _FormsGalleryState();
}

class _FormsGalleryState extends State<FormsGallery> {
  bool _showPwd = false;
  final _desc = TextEditingController(text: 'Balise hors ligne depuis lundi. Le client demande un passage avant vendredi.');
  String? _ville = 'Abidjan';
  String? _priorite = 'haute';
  String? _secteur;
  String? _errorSelect;
  List<String> _multi = ['Abidjan', 'Bouaké'];
  final _chips = <String>['Transport', 'Logistique'];
  DemoClient? _client;
  DateTime? _date = DateTime(2026, 10, 24);
  DateTime? _date2;
  DateTimeRange? _range;
  String _rangeShortcut = '';
  TimeOfDay? _time = const TimeOfDay(hour: 8, minute: 30);
  int _slot = 1;
  bool _c1 = true, _c2 = false, _cgu = false, _cguTouched = false;
  final _perms = {'Lecture': true, 'Écriture': true, 'Suppression': false};
  String _radio = 'mensuel';
  String _plan = 'standard';
  bool _notif = true, _sms = false;
  final bool _dark = false;
  String _toggle = 'semaine';
  double _slider = 60;
  RangeValues _sliderRange = const RangeValues(150000, 2500000);
  DemoFile? _file;
  DemoFile? _file2 = kDemoFiles[0];
  DemoFile? _photo;
  List<DemoFile> _drop = [kDemoFiles[2]];
  String _search = '';
  String _statut = 'all';
  String _villeFilter = '';

  final _formKey = GlobalKey<FormState>();
  final _form = {'raison': '', 'email': '', 'tel': '', 'vehicules': ''};
  String? _formSecteur;
  bool _formSubmitted = false;

  @override
  void dispose() {
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return DocPage(
      title: 'Formulaires',
      icon: Icons.edit_note,
      initialSection: widget.initialSection,
      subtitle: 'Champs de saisie du projet : motif « field-box » (libellé 12/600 + champ arrondi 12), champs Material outline, sélecteurs en feuille basse, dates, choix et validation — dimensionnés pour le doigt.',
      sections: [
        _inputs(c),
        _inputMaterial(c),
        _textarea(c),
        _masks(),
        _select(c),
        _multiSelect(c),
        _autocomplete(c),
        _dates(c),
        _dateRange(c),
        _times(c),
        _checkbox(c),
        _radioSection(c),
        _toggleSection(c),
        _sliderSection(c),
        _upload(c),
        _searchSection(c),
        _validation(c),
        _crud(c),
      ],
    );
  }

  DocSection _inputs(KitColors c) => DocSection(
        id: 'input',
        title: 'Input',
        source: 'KitTextField · FormFieldLabel (.form-field > .field-box)',
        description: 'Motif maison : libellé au-dessus, champ sur fond surface-high, bordure primaire au focus.',
        cols: 3,
        children: [
          const Demo(
            label: 'Default',
            code: "KitTextField(label: 'Raison sociale', hint: 'Ex : Transports Yao & Fils')",
            child: KitTextField(label: 'Raison sociale', hint: 'Ex : Transports Yao & Fils'),
          ),
          const Demo(label: 'Filled', child: KitTextField(label: 'Code client', initialValue: 'CLI-1043', icon: Icons.tag)),
          const Demo(label: 'Disabled', child: KitTextField(label: 'Créé par', initialValue: 'Système', enabled: false)),
          const Demo(label: 'Readonly', child: KitTextField(label: 'Référence', initialValue: 'CLI-1043', readOnly: true, icon: Icons.lock_outline)),
          Demo(
            label: 'Error',
            child: KitTextField(label: 'E-mail', initialValue: 'jean.kouassi@', icon: Icons.alternate_email, errorText: 'Adresse e-mail invalide', suffix: Icon(Icons.error, color: c.error)),
          ),
          Demo(
            label: 'Success',
            child: FormFieldLabel(
              label: 'Identifiant',
              hint: 'Disponible ✓',
              child: TextFormField(
                initialValue: 'transports.yao',
                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.check_circle, color: c.success),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Radii.md), borderSide: BorderSide(color: c.success)),
                ),
              ),
            ),
          ),
          const Demo(label: 'Required', child: KitTextField(label: 'Téléphone', required: true, hint: '+225 07 00 00 00 00', keyboardType: TextInputType.phone, icon: Icons.phone)),
          Demo(
            label: 'With icon / action',
            child: KitTextField(
              label: 'Site web',
              initialValue: 'transports-yao.ci',
              icon: Icons.language,
              suffix: IconButton(icon: const Icon(Icons.content_copy, size: 18), onPressed: () => copyToClipboard(context, 'transports-yao.ci')),
            ),
          ),
          const Demo(label: 'With helper text', child: KitTextField(label: 'IMEI', hint: '15 chiffres', helper: 'Inscrit au dos du boîtier GPS.', keyboardType: TextInputType.number)),
          Demo(
            label: 'Loading',
            child: KitTextField(
              label: 'Vérification du compte',
              initialValue: 'CI-4521-AB',
              suffix: Padding(padding: const EdgeInsets.all(Space.s4), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: c.primary))),
            ),
          ),
          Demo(
            label: 'Password',
            child: KitTextField(
              label: 'Mot de passe',
              initialValue: 'Abidjan2026!',
              obscure: !_showPwd,
              icon: Icons.lock_outline,
              suffix: IconButton(icon: Icon(_showPwd ? Icons.visibility_off : Icons.visibility, size: 20), onPressed: () => setState(() => _showPwd = !_showPwd)),
            ),
          ),
        ],
      );

  DocSection _inputMaterial(KitColors c) => DocSection(
        id: 'input-material',
        title: 'Input Material (outline / fill)',
        source: 'TextField(decoration: InputDecoration(labelText: …))',
        description: 'Champs à libellé flottant des écrans de compte (connexion, profil).',
        cols: 3,
        children: [
          const Demo(
            label: 'Outline',
            child: TextField(decoration: InputDecoration(labelText: 'Nom complet', hintText: 'Prénom(s) Nom', filled: false, prefixIcon: Icon(Icons.person_outline))),
          ),
          const Demo(
            label: 'Outline — erreur',
            child: TextField(decoration: InputDecoration(labelText: 'Email', filled: false, errorText: 'Ce champ est obligatoire')),
          ),
          Demo(
            label: 'Fill — disabled',
            child: TextField(
              enabled: false,
              controller: TextEditingController(text: 'jean.kouassi@transports-yao.ci'),
              decoration: const InputDecoration(labelText: 'E-mail', border: UnderlineInputBorder(), enabledBorder: UnderlineInputBorder(), disabledBorder: UnderlineInputBorder()),
            ),
          ),
        ],
      );

  DocSection _textarea(KitColors c) => DocSection(
        id: 'textarea',
        title: 'Textarea',
        source: 'KitTextField(maxLines: …)',
        cols: 3,
        children: [
          const Demo(label: 'Default', child: KitTextField(label: 'Description', hint: 'Décrivez la demande…', maxLines: 4, minLines: 3)),
          Demo(
            label: 'Filled + compteur',
            child: FormFieldLabel(
              label: 'Commentaire',
              child: TextField(controller: _desc, maxLines: 4, minLines: 3, maxLength: 200, onChanged: (_) => setState(() {})),
            ),
          ),
          const Demo(label: 'Disabled', child: KitTextField(label: 'Note interne', initialValue: 'Client prioritaire — contrat cadre 2026.', maxLines: 3, enabled: false)),
        ],
      );

  DocSection _masks() => DocSection(
        id: 'mask',
        title: 'Masque de saisie',
        source: 'MaskFormatter (# chiffre · A lettre · * alphanumérique)',
        description: 'Le clavier adapté s’ouvre automatiquement (numérique pour téléphone et dates).',
        cols: 2,
        children: [
          Demo(
            label: 'Téléphone',
            code: "KitTextField(keyboardType: TextInputType.phone,\n  inputFormatters: [MaskFormatter('+225 ## ## ## ## ##')])",
            child: KitTextField(label: 'Téléphone', hint: '+225 07 00 00 00 00', keyboardType: TextInputType.phone, icon: Icons.phone, inputFormatters: [MaskFormatter('+225 ## ## ## ## ##')]),
          ),
          Demo(
            label: 'Immatriculation',
            child: KitTextField(label: 'Immatriculation', hint: '1234 AB 01', icon: Icons.directions_car, inputFormatters: [MaskFormatter('#### AA ##')]),
          ),
          Demo(
            label: 'Date saisie au clavier',
            child: KitTextField(label: 'Date de naissance', hint: 'JJ/MM/AAAA', keyboardType: TextInputType.number, icon: Icons.cake_outlined, inputFormatters: [MaskFormatter('##/##/####')]),
          ),
          Demo(
            label: 'Code avec préfixe',
            child: KitTextField(label: 'Code client', hint: 'CLI-00000', icon: Icons.tag, inputFormatters: [MaskFormatter('CLI-#####')]),
          ),
        ],
      );

  DocSection _select(KitColors c) => DocSection(
        id: 'select',
        title: 'Select',
        source: 'SearchableSelect · DropdownButtonFormField',
        description: 'Sur mobile, la liste s’ouvre en feuille basse avec recherche dès 7 options.',
        cols: 3,
        children: [
          Demo(
            label: 'Sélecteur (feuille)',
            code: '''SearchableSelect<String>(
  label: 'Ville',
  options: villes,
  value: ville,
  onChanged: (v) => setState(() => ville = v),
)''',
            child: SearchableSelect<String>(label: 'Ville', options: _villes, value: _ville, onChanged: (v) => setState(() => _ville = v)),
          ),
          Demo(
            label: 'Avec pastilles de couleur',
            child: SearchableSelect<String>(label: 'Priorité', placeholder: 'Priorité…', options: _priorites, value: _priorite, onChanged: (v) => setState(() => _priorite = v)),
          ),
          Demo(
            label: 'Vide + allowNull',
            child: SearchableSelect<String>(label: 'Secteur', placeholder: 'Sélectionner un secteur…', allowNull: true, options: _secteurs, value: _secteur, onChanged: (v) => setState(() => _secteur = v)),
          ),
          Demo(
            label: 'Disabled',
            child: SearchableSelect<String>(label: 'Pays', enabled: false, options: const [SelectOption('ci', 'Côte d’Ivoire')], value: 'ci', onChanged: (_) {}),
          ),
          Demo(
            label: 'Natif (menu)',
            child: FormFieldLabel(
              label: 'Statut',
              child: DropdownButtonFormField<ClientStatut>(
                initialValue: ClientStatut.actif,
                borderRadius: BorderRadius.circular(Radii.md),
                items: [for (final s in ClientStatut.values) DropdownMenuItem(value: s, child: Text(s.label))],
                onChanged: (_) {},
              ),
            ),
          ),
          Demo(
            label: 'Erreur',
            child: SearchableSelect<String>(
              label: 'Type d’intervention',
              placeholder: 'Choisir…',
              error: _errorSelect == null ? 'Sélection obligatoire' : null,
              options: const [SelectOption('inst', 'Installation'), SelectOption('maint', 'Maintenance'), SelectOption('diag', 'Diagnostic')],
              value: _errorSelect,
              onChanged: (v) => setState(() => _errorSelect = v),
            ),
          ),
        ],
      );

  DocSection _multiSelect(KitColors c) => DocSection(
        id: 'multi-select',
        title: 'Multi-select',
        source: 'MultiSelectField · InputChip',
        cols: 2,
        children: [
          Demo(
            label: 'Sélection multiple',
            child: MultiSelectField<String>(label: 'Villes couvertes', placeholder: 'Choisir des villes', options: _villes, values: _multi, onChanged: (v) => setState(() => _multi = v)),
          ),
          Demo(
            label: 'Chips',
            child: FormFieldLabel(
              label: 'Secteurs',
              child: Wrap(spacing: 8, runSpacing: 8, children: [
                for (final s in kSecteurs)
                  FilterChip(
                    label: Text(s),
                    selected: _chips.contains(s),
                    onSelected: (v) => setState(() => v ? _chips.add(s) : _chips.remove(s)),
                  ),
              ]),
            ),
          ),
        ],
      );

  DocSection _autocomplete(KitColors c) => DocSection(
        id: 'autocomplete',
        title: 'Autocomplete',
        source: 'EntityAutocomplete · Autocomplete',
        description: 'Recherche filtrée en mémoire dans 40 clients (raison sociale ou code).',
        cols: 2,
        children: [
          Demo(
            label: 'Entité (client)',
            code: '''EntityAutocomplete<DemoClient>(
  items: clients,
  display: (c) => c.raisonSociale,
  subtitle: (c) => '\${c.code} · \${c.ville}',
  onSelected: select,
)''',
            child: Gap([
              EntityAutocomplete<DemoClient>(
                items: kDemoClients,
                hint: 'Rechercher un client…',
                display: (x) => x.raisonSociale,
                subtitle: (x) => '${x.code} · ${x.ville}',
                onSelected: (x) => setState(() => _client = x),
              ),
              if (_client != null)
                Row(children: [
                  StatusBadge(_client!.statut.label, tone: _client!.statut.tone),
                  const SizedBox(width: 8),
                  Expanded(child: Text('${_client!.contact} · ${_client!.telephone}', style: TextStyle(fontSize: 12, color: c.textSecondary))),
                ]),
            ]),
          ),
          Demo(
            label: 'Suggestions simples',
            child: Autocomplete<String>(
              optionsBuilder: (v) => v.text.isEmpty ? const Iterable.empty() : kVilles.where((x) => x.toLowerCase().startsWith(v.text.toLowerCase())),
              fieldViewBuilder: (context, ctrl, focus, _) => TextField(controller: ctrl, focusNode: focus, decoration: const InputDecoration(hintText: 'Commencez à taper…', prefixIcon: Icon(Icons.location_on_outlined, size: 20))),
            ),
          ),
        ],
      );

  DocSection _dates(KitColors c) => DocSection(
        id: 'date',
        title: 'Date picker',
        source: 'showDatePicker (locale fr-FR)',
        cols: 3,
        children: [
          Demo(label: 'field-box', child: DateField(label: 'Date d’installation', value: _date, onChanged: (d) => setState(() => _date = d))),
          Demo(
            label: 'Bornes (2026)',
            child: DateField(label: 'Échéance', value: _date2, first: DateTime(2026), last: DateTime(2026, 12, 31), onChanged: (d) => setState(() => _date2 = d)),
          ),
          Demo(
            label: 'Calendrier inline',
            flush: true,
            child: CalendarDatePicker(
              initialDate: _date ?? DateTime(2026, 10, 24),
              firstDate: DateTime(2024),
              lastDate: DateTime(2028),
              onDateChanged: (d) => setState(() => _date = d),
            ),
          ),
        ],
      );

  DocSection _dateRange(KitColors c) {
    void preset(String key, int days) {
      final now = DateTime.now();
      setState(() {
        _rangeShortcut = key;
        _range = DateTimeRange(start: DateTime(now.year, now.month, now.day - days), end: DateTime(now.year, now.month, now.day));
      });
    }

    return DocSection(
      id: 'date-range',
      title: 'Date range',
      source: 'showDateRangePicker',
      cols: 2,
      children: [
        Demo(label: 'Période', child: DateRangeField(label: 'Période', value: _range, onChanged: (r) => setState(() {
              _range = r;
              _rangeShortcut = '';
            }))),
        Demo(
          label: 'Raccourcis de période',
          child: Gap([
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final (k, l, d) in const [('7', '7 jours', 7), ('30', '30 jours', 30), ('90', '3 mois', 90), ('365', '12 mois', 365)])
                ChoiceChip(label: Text(l), selected: _rangeShortcut == k, onSelected: (_) => preset(k, d)),
            ]),
            DateRangeField(value: _range, onChanged: (r) => setState(() => _range = r)),
          ]),
        ),
      ],
    );
  }

  DocSection _times(KitColors c) => DocSection(
        id: 'time',
        title: 'Time picker',
        source: 'showTimePicker (24 h)',
        cols: 2,
        children: [
          Demo(label: 'Heure', child: TimeField(label: 'Heure de passage', value: _time, onChanged: (t) => setState(() => _time = t))),
          Demo(
            label: 'Créneau (puces)',
            child: FormFieldLabel(
              label: 'Créneau',
              child: Wrap(spacing: 8, runSpacing: 8, children: [
                for (final (i, s) in const ['08:00 – 10:00', '10:00 – 12:00', '14:00 – 16:00', '16:00 – 18:00'].indexed)
                  ChoiceChip(label: Text(s), selected: _slot == i, onSelected: (_) => setState(() => _slot = i)),
              ]),
            ),
          ),
        ],
      );

  DocSection _checkbox(KitColors c) {
    final all = _perms.values.every((v) => v);
    final none = _perms.values.every((v) => !v);
    return DocSection(
      id: 'checkbox',
      title: 'Checkbox',
      source: 'Checkbox · CheckboxListTile',
      cols: 3,
      children: [
        Demo(
          label: 'États',
          child: Column(children: [
            CheckboxListTile(contentPadding: EdgeInsets.zero, value: _c1, onChanged: (v) => setState(() => _c1 = v!), title: const Text('Coché'), controlAffinity: ListTileControlAffinity.leading),
            CheckboxListTile(contentPadding: EdgeInsets.zero, value: _c2, onChanged: (v) => setState(() => _c2 = v!), title: const Text('Non coché'), controlAffinity: ListTileControlAffinity.leading),
            const CheckboxListTile(contentPadding: EdgeInsets.zero, value: true, onChanged: null, title: Text('Désactivé'), controlAffinity: ListTileControlAffinity.leading),
          ]),
        ),
        Demo(
          label: 'Indéterminé (tout sélectionner)',
          child: Column(children: [
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              tristate: true,
              value: all ? true : (none ? false : null),
              onChanged: (_) => setState(() => _perms.updateAll((_, _) => !all)),
              title: const Text('Toutes les permissions', style: TextStyle(fontWeight: FontWeight.w700)),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            for (final k in _perms.keys)
              CheckboxListTile(
                contentPadding: const EdgeInsets.only(left: 28),
                dense: true,
                value: _perms[k],
                onChanged: (v) => setState(() => _perms[k] = v!),
                title: Text(k),
                controlAffinity: ListTileControlAffinity.leading,
              ),
          ]),
        ),
        Demo(
          label: 'Erreur (CGU)',
          child: Gap([
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              isError: _cguTouched && !_cgu,
              value: _cgu,
              onChanged: (v) => setState(() => _cgu = v!),
              title: const Text('J’accepte les conditions générales'),
              subtitle: _cguTouched && !_cgu ? Text('Obligatoire pour continuer', style: TextStyle(color: c.errorText)) : null,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            FilledButton(onPressed: () => setState(() => _cguTouched = true), child: const Text('Continuer')),
          ]),
        ),
      ],
    );
  }

  DocSection _radioSection(KitColors c) => DocSection(
        id: 'radio',
        title: 'Radio',
        source: 'RadioGroup · cartes de choix',
        cols: 2,
        children: [
          Demo(
            label: 'Vertical',
            child: RadioGroup<String>(
              groupValue: _radio,
              onChanged: (v) => setState(() => _radio = v!),
              child: const Column(children: [
                RadioListTile(contentPadding: EdgeInsets.zero, value: 'mensuel', title: Text('Facturation mensuelle')),
                RadioListTile(contentPadding: EdgeInsets.zero, value: 'trimestriel', title: Text('Trimestrielle'), subtitle: Text('−5 %')),
                RadioListTile(contentPadding: EdgeInsets.zero, value: 'annuel', title: Text('Annuelle'), subtitle: Text('−12 %')),
              ]),
            ),
          ),
          Demo(
            label: 'Cartes de choix',
            child: Gap(gap: 8, [
              for (final (k, t, p, ic) in const [
                ('essentiel', 'Essentiel', '9 900 F / mois', Icons.gps_fixed),
                ('standard', 'Standard', '14 500 F / mois', Icons.verified),
                ('premium', 'Premium', '24 000 F / mois', Icons.workspace_premium),
              ])
                _ChoiceCard(icon: ic, title: t, subtitle: p, selected: _plan == k, onTap: () => setState(() => _plan = k)),
            ]),
          ),
        ],
      );

  DocSection _toggleSection(KitColors c) => DocSection(
        id: 'toggle',
        title: 'Toggle',
        source: 'SwitchListTile · SegmentedButton',
        cols: 2,
        children: [
          Demo(
            label: 'Switch',
            child: Column(children: [
              SwitchListTile(contentPadding: EdgeInsets.zero, value: _notif, onChanged: withHaptic((v) => setState(() => _notif = v)), title: const Text('Notifications push'), subtitle: const Text('Alertes de zone et de vitesse')),
              SwitchListTile(contentPadding: EdgeInsets.zero, value: _sms, onChanged: withHaptic((v) => setState(() => _sms = v)), title: const Text('Rappel SMS au client')),
              SwitchListTile(contentPadding: EdgeInsets.zero, value: _dark, onChanged: null, title: const Text('Désactivé')),
            ]),
          ),
          Demo(
            label: 'Button toggle',
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'jour', label: Text('Jour'), icon: Icon(Icons.today)),
                ButtonSegment(value: 'semaine', label: Text('Semaine'), icon: Icon(Icons.view_week)),
                ButtonSegment(value: 'mois', label: Text('Mois'), icon: Icon(Icons.calendar_month)),
              ],
              selected: {_toggle},
              onSelectionChanged: (s) => setState(() => _toggle = s.first),
            ),
          ),
        ],
      );

  DocSection _sliderSection(KitColors c) => DocSection(
        id: 'slider',
        title: 'Slider',
        source: 'Slider · RangeSlider',
        cols: 2,
        children: [
          Demo(
            label: 'Valeur simple',
            child: FormFieldLabel(
              label: 'Seuil d’alerte vitesse : ${_slider.round()} km/h',
              child: Slider(value: _slider, min: 30, max: 130, divisions: 20, label: '${_slider.round()} km/h', onChanged: (v) => setState(() => _slider = v)),
            ),
          ),
          Demo(
            label: 'Intervalle',
            child: FormFieldLabel(
              label: 'CA mensuel : ${(_sliderRange.start / 1000).round()} k – ${(_sliderRange.end / 1000).round()} k FCFA',
              child: RangeSlider(
                values: _sliderRange,
                min: 0,
                max: 5000000,
                divisions: 50,
                onChanged: (v) => setState(() => _sliderRange = v),
              ),
            ),
          ),
        ],
      );

  DocSection _upload(KitColors c) => DocSection(
        id: 'upload',
        title: 'File upload',
        source: 'FileUploadField · DropZone (local, sans envoi)',
        description: 'Le choix de fichier est simulé (fichiers de démonstration) : aucun accès au stockage ni envoi réseau.',
        cols: 2,
        children: [
          Demo(label: 'Champ — vide', child: FileUploadField(label: 'Pièce jointe', file: _file, onChanged: (f) => setState(() => _file = f))),
          Demo(label: 'Champ — fichier joint', child: FileUploadField(label: 'Document', file: _file2, onChanged: (f) => setState(() => _file2 = f))),
          Demo(
            label: 'Photo',
            child: Row(children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: c.fieldBg,
                  shape: BoxShape.circle,
                  image: _photo == null ? null : const DecorationImage(image: AssetImage('assets/images/camion.png'), fit: BoxFit.cover),
                ),
                child: _photo == null ? Icon(Icons.add_a_photo_outlined, color: c.textMuted) : null,
              ),
              const SizedBox(width: 16),
              Expanded(child: FileUploadField(placeholder: 'Photo', icon: Icons.photo_camera_outlined, file: _photo, onChanged: (f) => setState(() => _photo = f))),
            ]),
          ),
          Demo(label: 'Zone de dépôt', child: DropZone(files: _drop, onChanged: (f) => setState(() => _drop = f))),
          Demo(label: 'Disabled', child: FileUploadField(label: 'Pièce justificative', enabled: false, file: null, onChanged: (_) {})),
        ],
      );

  DocSection _searchSection(KitColors c) {
    final q = _search.toLowerCase();
    final results = kDemoClients
        .where((x) =>
            (q.isEmpty || x.raisonSociale.toLowerCase().contains(q) || x.code.toLowerCase().contains(q)) &&
            (_statut == 'all' || x.statut.name == _statut) &&
            (_villeFilter.isEmpty || x.ville == _villeFilter))
        .toList();
    return DocSection(
      id: 'search',
      title: 'Search',
      source: 'KitSearchBar · FilterDropdown',
      description: 'Recherche unifiée avec filtres en puces ; le résultat se met à jour en direct.',
      children: [
        Demo(
          label: 'Recherche unifiée + filtres',
          child: Gap([
            KitSearchBar(hint: 'Rechercher par code, raison sociale…', onChanged: (v) => setState(() => _search = v)),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                FilterDropdown<String>(
                  label: 'Statut',
                  value: _statut,
                  allValue: 'all',
                  options: [const SelectOption('all', 'Tous'), for (final s in ClientStatut.values) SelectOption(s.name, s.label, tone: s.tone)],
                  onChanged: (v) => setState(() => _statut = v),
                ),
                const SizedBox(width: 8),
                FilterDropdown<String>(
                  label: 'Ville',
                  icon: Icons.public,
                  value: _villeFilter,
                  allValue: '',
                  options: [const SelectOption('', 'Toutes', icon: Icons.public), ..._villes],
                  onChanged: (v) => setState(() => _villeFilter = v),
                ),
              ]),
            ),
            Text('${results.length} résultat(s)', style: TextStyle(fontSize: 12, color: c.textMuted)),
            if (results.isEmpty)
              const EmptyState(compact: true, icon: Icons.search_off, title: 'Aucun résultat', subtitle: 'Ajustez votre recherche ou vos filtres.')
            else
              for (final x in results.take(4))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: KitAvatar(name: x.raisonSociale),
                  title: Text(x.raisonSociale),
                  subtitle: Text('${x.code} · ${x.ville}'),
                  trailing: StatusBadge(x.statut.label, tone: x.statut.tone),
                ),
          ]),
        ),
        Demo(label: 'Barre compacte (.m3-search-bar)', child: KitSearchBar(trailing: IconButton(icon: const Icon(Icons.tune, size: 20), onPressed: () {}))),
      ],
    );
  }

  DocSection _validation(KitColors c) {
    String? req(String? v) => (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null;
    return DocSection(
      id: 'validation',
      title: 'Form validation',
      source: 'Form · TextFormField(validator: …)',
      description: 'Validation à la soumission puis en direct ; les erreurs apparaissent sous chaque champ.',
      children: [
        Demo(
          label: 'Formulaire client',
          code: '''Form(
  key: formKey,
  autovalidateMode: submitted ? AutovalidateMode.always : AutovalidateMode.disabled,
  child: Column(children: [
    KitTextField(label: 'Raison sociale', required: true, validator: required),
    …
  ]),
)''',
          child: Form(
            key: _formKey,
            autovalidateMode: _formSubmitted ? AutovalidateMode.always : AutovalidateMode.disabled,
            child: Gap(gap: 14, [
              KitTextField(label: 'Raison sociale', required: true, hint: 'Ex : Bolloré Logistics CI', validator: req, onChanged: (v) => _form['raison'] = v),
              KitTextField(
                label: 'E-mail',
                required: true,
                hint: 'contact@societe.ci',
                keyboardType: TextInputType.emailAddress,
                validator: (v) => req(v) ?? (RegExp(r'^[^@\s]+@[^@\s]+\.[a-z]{2,}$').hasMatch(v!.trim()) ? null : 'Adresse e-mail invalide'),
              ),
              KitTextField(
                label: 'Téléphone',
                hint: '+225 07 00 00 00 00',
                keyboardType: TextInputType.phone,
                inputFormatters: [MaskFormatter('+225 ## ## ## ## ##')],
                validator: (v) => (v ?? '').isEmpty || v!.length == 19 ? null : 'Numéro incomplet',
              ),
              FormField<String>(
                validator: (_) => _formSecteur == null ? 'Sélection obligatoire' : null,
                builder: (state) => SearchableSelect<String>(
                  label: 'Secteur *',
                  placeholder: 'Choisir…',
                  options: _secteurs,
                  value: _formSecteur,
                  error: state.errorText,
                  onChanged: (v) {
                    setState(() => _formSecteur = v);
                    state.didChange(v);
                  },
                ),
              ),
              KitTextField(
                label: 'Nombre de véhicules',
                hint: '1 – 500',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null) return 'Champ obligatoire';
                  return n < 1 || n > 500 ? 'Entre 1 et 500' : null;
                },
              ),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _formKey.currentState!.reset();
                      setState(() {
                        _formSubmitted = false;
                        _formSecteur = null;
                      });
                    },
                    child: const Text('Réinitialiser'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      setState(() => _formSubmitted = true);
                      if (_formKey.currentState!.validate()) {
                        showKitSnack(context, 'Client enregistré (démo statique)', kind: SnackKind.success);
                      } else {
                        showKitSnack(context, 'Corrigez les champs en erreur', kind: SnackKind.error);
                      }
                    },
                    child: const Text('Enregistrer'),
                  ),
                ),
              ]),
            ]),
          ),
        ),
      ],
    );
  }

  DocSection _crud(KitColors c) {
    Future<void> open(CrudMode mode) async {
      final client = kDemoClients[0];
      var raison = mode == CrudMode.create ? '' : client.raisonSociale;
      var ville = mode == CrudMode.create ? null : client.ville;
      final ro = mode == CrudMode.view;
      final r = await showFormSheet<String>(
        context,
        title: switch (mode) { CrudMode.create => 'Nouveau client', CrudMode.edit => 'Modifier le client', CrudMode.view => client.raisonSociale },
        subtitle: mode == CrudMode.create ? null : client.code,
        icon: switch (mode) { CrudMode.create => Icons.person_add, CrudMode.edit => Icons.edit, CrudMode.view => Icons.visibility },
        readOnly: ro,
        submitLabel: mode == CrudMode.create ? 'Créer' : 'Enregistrer',
        onSubmit: () => raison.trim().isEmpty ? null : raison,
        builder: (ctx, set) => Gap(gap: 14, [
          KitTextField(label: 'Raison sociale', required: !ro, initialValue: raison, readOnly: ro, onChanged: (v) => raison = v),
          SearchableSelect<String>(label: 'Ville', options: _villes, value: ville, enabled: !ro, onChanged: (v) => set(() => ville = v)),
          KitTextField(label: 'Contact', initialValue: mode == CrudMode.create ? null : client.contact, readOnly: ro, icon: Icons.person_outline),
          KitTextField(label: 'Téléphone', initialValue: mode == CrudMode.create ? null : client.telephone, readOnly: ro, icon: Icons.phone, keyboardType: TextInputType.phone),
          KitTextField(label: 'Notes', maxLines: 3, readOnly: ro, initialValue: mode == CrudMode.create ? null : 'Contrat cadre 2026 — 24 balises.'),
        ]),
      );
      if (r != null && mounted) showKitSnack(context, '« $r » enregistré (démo statique)', kind: SnackKind.success);
    }

    return DocSection(
      id: 'crud-dialog',
      title: 'Formulaire en modale',
      source: 'showFormSheet (CrudDialog)',
      description: 'Sur mobile, la modale de formulaire devient une feuille quasi plein écran, actions collées en bas, clavier pris en compte.',
      children: [
        Demo(
          label: 'Modes create / edit / view',
          code: '''showFormSheet<String>(context,
  title: 'Nouveau client',
  onSubmit: () => raison.isEmpty ? null : raison,
  builder: (ctx, setState) => Column(children: [...]),
)''',
          child: DemoWrap(children: [
            FilledButton.icon(onPressed: () => open(CrudMode.create), icon: const Icon(Icons.add, size: 18), label: const Text('Créer')),
            OutlinedButton.icon(onPressed: () => open(CrudMode.edit), icon: const Icon(Icons.edit, size: 18), label: const Text('Modifier')),
            TextButton.icon(onPressed: () => open(CrudMode.view), icon: const Icon(Icons.visibility, size: 18), label: const Text('Consulter')),
          ]),
        ),
      ],
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({required this.icon, required this.title, required this.subtitle, required this.selected, required this.onTap});
  final IconData icon;
  final String title, subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return KitCard(
      radius: 14,
      onTap: onTap,
      color: selected ? c.primaryLight : null,
      borderColor: selected ? c.primary : null,
      padding: const EdgeInsets.symmetric(horizontal: Space.s4, vertical: Space.s3),
      child: Row(children: [
        Icon(icon, color: selected ? c.primary : c.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: c.textPrimary)),
            Text(subtitle, style: TextStyle(fontSize: 12, color: c.textSecondary)),
          ]),
        ),
        Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: selected ? c.primary : c.textMuted),
      ]),
    );
  }
}
