import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/common.dart';
import '../widgets/feedback.dart';
import '../widgets/fields/basic_fields.dart';
import '../widgets/fields/picker_fields.dart';
import '../widgets/kit_buttons.dart';
import '../widgets/selects.dart';
import 'kit_colors.dart';
import 'app_theme.dart';
import 'custom_theme.dart';
import 'theme_controller.dart';
import 'theme_palettes.dart';
import 'package:ui_kit_flutter/theme/tokens.dart';

/// Ouvre le studio de thème (équivalent de la page Angular `/theme-studio`).
Future<void> openThemeStudio(BuildContext context) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ThemeStudioPage()));

/// Studio de thème : couleur rapide, style de schéma M3, contraste, couleurs imposées par rôle ;
/// aperçu d'une application en clair et en sombre, nuanciers des palettes et rôles avec contrastes.
class ThemeStudioPage extends StatefulWidget {
  const ThemeStudioPage({super.key});

  @override
  State<ThemeStudioPage> createState() => _ThemeStudioPageState();
}

class _ThemeStudioPageState extends State<ThemeStudioPage> {
  final _controller = ThemeController.instance;
  late CustomThemeConfig _draft = _controller.custom ?? CustomThemeConfig(source: _controller.palette.seed);
  bool _live = false;
  Brightness _previewMode = Brightness.light;
  Brightness _rolesMode = Brightness.light;

  /// Incrémenté quand la couleur change hors des color pickers (pastilles, hasard,
  /// réinitialisation) : les `ColorPickerField` sont alors recréés sur la nouvelle valeur.
  int _epoch = 0;

  void _update(CustomThemeConfig next) {
    setState(() => _draft = next);
    if (_live) _controller.applyCustom(next);
  }

  void _setExternal(CustomThemeConfig next) {
    _epoch++;
    _update(next);
  }

  void _apply() {
    _controller.applyCustom(_draft);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thème personnalisé appliqué à tout le kit')));
  }

  void _copyDart() {
    Clipboard.setData(ClipboardData(text: _draft.toDart()));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code Dart du thème copié')));
  }

  void _randomize() {
    final r = math.Random();
    _setExternal(_draft.copyWith(source: HSLColor.fromAHSL(1, r.nextDouble() * 360, 0.55 + r.nextDouble() * 0.35, 0.4 + r.nextDouble() * 0.2).toColor()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Studio de thème'),
        actions: [
          IconButton(tooltip: 'Copier le code Dart', onPressed: _copyDart, icon: const Icon(Icons.code)),
          IconButton(
            tooltip: 'Réinitialiser',
            onPressed: () => _setExternal(CustomThemeConfig(source: _controller.palette.seed)),
            icon: const Icon(Icons.restart_alt),
          ),
          Padding(
            padding: const EdgeInsets.only(right: Space.s3, left: Space.s1),
            child: FilledButton.icon(onPressed: _apply, icon: const Icon(Icons.check), label: const Text('Appliquer')),
          ),
        ],
      ),
      body: LayoutBuilder(builder: (context, cons) {
        final wide = cons.maxWidth >= 960;
        final controls = _Controls(
          draft: _draft,
          live: _live,
          onLive: (v) {
            setState(() => _live = v);
            if (v) _controller.applyCustom(_draft);
          },
          epoch: _epoch,
          onChanged: _update,
          onExternal: _setExternal,
          onRandom: _randomize,
        );
        final previews = _Previews(draft: _draft, mode: _previewMode, onMode: (b) => setState(() => _previewMode = b));
        final details = [
          _Section(title: 'Nuances', subtitle: 'Palettes tonales du noir (0) au blanc (100). Touchez une nuance pour copier son code.', child: _Strips(draft: _draft)),
          _Section(
            title: 'Rôles & contrastes',
            subtitle: 'Paires « rôle / on-rôle » et leur ratio WCAG (AA texte : 4,5:1).',
            trailing: SegmentedButton<Brightness>(
              segments: const [
                ButtonSegment(value: Brightness.light, icon: Icon(Icons.light_mode_outlined), label: Text('Clair')),
                ButtonSegment(value: Brightness.dark, icon: Icon(Icons.dark_mode_outlined), label: Text('Sombre')),
              ],
              selected: {_rolesMode},
              showSelectedIcon: false,
              onSelectionChanged: (s) => setState(() => _rolesMode = s.first),
            ),
            child: _Roles(scheme: _draft.scheme(_rolesMode)),
          ),
        ];
        if (wide) {
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 400, child: ListView(padding: const EdgeInsets.fromLTRB(Space.s4, Space.s2, Space.s2, Space.s8), children: [controls])),
            Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(Space.s2, Space.s2, Space.s4, Space.s8), children: [previews, ...details])),
          ]);
        }
        return ListView(padding: const EdgeInsets.fromLTRB(Space.s4, Space.s2, Space.s4, Space.s8), children: [controls, previews, ...details]);
      }),
    );
  }
}

// ─── Réglages ─────────────────────────────────────────────────

class _Controls extends StatelessWidget {
  const _Controls({
    required this.draft,
    required this.live,
    required this.onLive,
    required this.epoch,
    required this.onChanged,
    required this.onExternal,
    required this.onRandom,
  });

  final CustomThemeConfig draft;
  final bool live;
  final ValueChanged<bool> onLive;
  final int epoch;
  final ValueChanged<CustomThemeConfig> onChanged;

  /// Changement venu d'ailleurs que les color pickers (ils se resynchronisent).
  final ValueChanged<CustomThemeConfig> onExternal;
  final VoidCallback onRandom;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final derived = draft.derivedKeyColors();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _Panel(
        title: 'Couleur source',
        subtitle: 'primary',
        children: [
          Row(children: [
            Expanded(child: Text(colorHex(draft.source), style: text.titleMedium?.copyWith(fontFamily: 'SpaceMono'))),
            IconButton(tooltip: 'Couleur au hasard', onPressed: onRandom, icon: const Icon(Icons.casino_outlined)),
          ]),
          const SizedBox(height: 8),
          ColorPickerField(
            key: ValueKey('source-$epoch'),
            value: draft.source,
            onChanged: (c) => onChanged(draft.copyWith(source: c)),
          ),
          const SizedBox(height: 16),
          Text('Couleurs des thèmes', style: text.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Wrap(spacing: 2, runSpacing: 2, children: [
            for (final p in kitPalettes)
              Semantics(
                button: true,
                selected: p.seed == draft.source,
                label: p.label,
                child: Tooltip(
                  message: p.label,
                  excludeFromSemantics: true,
                  child: InkResponse(
                    onTap: () => onExternal(draft.copyWith(source: p.seed)),
                    radius: 20,
                    child: SizedBox.square(
                      dimension: 40,
                      child: Center(
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: p.seed,
                            shape: BoxShape.circle,
                            boxShadow: p.seed == draft.source
                                ? [BoxShadow(color: scheme.surfaceContainer, spreadRadius: 2), BoxShadow(color: scheme.onSurface, spreadRadius: 4)]
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ]),
        ],
      ),
      _Panel(
        title: 'Style',
        subtitle: draft.style.label,
        children: [
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final s in SchemeStyle.values)
              ChoiceChip(
                label: Text(s.label),
                selected: s == draft.style,
                side: BorderSide.none,
                backgroundColor: scheme.surfaceContainerHigh,
                onSelected: (_) => onChanged(draft.copyWith(style: s)),
              ),
          ]),
          const SizedBox(height: 10),
          Text(draft.style.description, style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => onChanged(draft.copyWith(style: SchemeStyle.monochrome, overrides: const {})),
              icon: const Icon(Icons.contrast),
              label: const Text('Noir & blanc'),
            ),
          ),
        ],
      ),
      _Panel(
        title: 'Contraste',
        children: [
          SegmentedButton<double>(
            segments: [for (final (v, l) in kContrastLevels) ButtonSegment(value: v, label: Text(l))],
            selected: {draft.contrast},
            showSelectedIcon: false,
            // Fond rempli, sans contour ni séparateurs (comme le sélecteur de contraste web).
            style: SegmentedButton.styleFrom(
              side: BorderSide.none,
              backgroundColor: scheme.surfaceContainerHigh,
              selectedBackgroundColor: scheme.secondaryContainer,
            ),
            onSelectionChanged: (s) => onChanged(draft.copyWith(contrast: s.first)),
          ),
          const SizedBox(height: 8),
          Text('Moyen et Élevé renforcent l’écart entre chaque rôle et son « on- » (accessibilité).',
              style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
        ],
      ),
      _Panel(
        title: 'Couleurs des rôles',
        subtitle: 'auto = dérivée de la source',
        children: [
          for (final role in OverridableRole.values) ...[
            _RoleRow(
              role: role,
              color: draft.overrides[role] ?? derived[role]!,
              overridden: draft.overrides.containsKey(role),
              pickerKey: ValueKey('${role.name}-$epoch'),
              onToggle: (on) => onChanged(draft.withOverride(role, on ? derived[role] : null)),
              onColor: (c) => onChanged(draft.withOverride(role, c)),
            ),
            if (role != OverridableRole.values.last) const Divider(height: 16),
          ],
        ],
      ),
      _Panel(
        title: 'Application',
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Appliquer en direct à tout le kit'),
            value: live,
            onChanged: onLive,
          ),
        ],
      ),
    ]);
  }
}

class _RoleRow extends StatelessWidget {
  const _RoleRow({
    required this.role,
    required this.color,
    required this.overridden,
    required this.pickerKey,
    required this.onToggle,
    required this.onColor,
  });

  final OverridableRole role;
  final Color color;
  final bool overridden;
  final Key pickerKey;
  final ValueChanged<bool> onToggle;
  final ValueChanged<Color> onColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: scheme.outlineVariant)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(role.label, style: text.labelLarge),
            Text(overridden ? colorHex(color) : 'Auto · ${role.hint}', style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
          ]),
        ),
        Switch(key: ValueKey('override-${role.name}'), value: overridden, onChanged: onToggle),
      ]),
      if (overridden) ...[
        const SizedBox(height: 10),
        ColorPickerField(key: pickerKey, value: color, onChanged: onColor),
      ],
    ]);
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, this.subtitle, required this.children});

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: Space.s3),
      padding: const EdgeInsets.all(Space.s4),
      decoration: BoxDecoration(color: scheme.surfaceContainer, borderRadius: BorderRadius.circular(Radii.lg)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
          Text(title, style: text.titleSmall),
          if (subtitle != null) ...[
            const SizedBox(width: 8),
            Flexible(child: Text(subtitle!, style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant))),
          ],
        ]),
        const SizedBox(height: 12),
        ...children,
      ]),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.subtitle, required this.child, this.trailing});

  final String title, subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(title, style: text.titleLarge),
        const SizedBox(height: 4),
        Text(subtitle, style: text.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        if (trailing != null) ...[const SizedBox(height: 12), Align(alignment: Alignment.centerLeft, child: trailing)],
        const SizedBox(height: 12),
        child,
      ]),
    );
  }
}

// ─── Aperçus ──────────────────────────────────────────────────

class _Previews extends StatelessWidget {
  const _Previews({required this.draft, required this.mode, required this.onMode});

  final CustomThemeConfig draft;
  final Brightness mode;
  final ValueChanged<Brightness> onMode;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, cons) {
      final both = cons.maxWidth >= 700;
      Widget phone(Brightness b) => _PhonePreview(theme: AppTheme.fromScheme(draft.scheme(b)), label: b == Brightness.dark ? 'Sombre' : 'Clair');
      if (both) {
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: phone(Brightness.light)),
          const SizedBox(width: 16),
          Expanded(child: phone(Brightness.dark)),
        ]);
      }
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Center(
          child: SegmentedButton<Brightness>(
            segments: const [
              ButtonSegment(value: Brightness.light, icon: Icon(Icons.light_mode_outlined), label: Text('Clair')),
              ButtonSegment(value: Brightness.dark, icon: Icon(Icons.dark_mode_outlined), label: Text('Sombre')),
            ],
            selected: {mode},
            showSelectedIcon: false,
            onSelectionChanged: (s) => onMode(s.first),
          ),
        ),
        const SizedBox(height: 12),
        phone(mode),
      ]);
    });
  }
}

/// Maquette d'application rendue avec un thème donné (vrais widgets Material).
class _PhonePreview extends StatelessWidget {
  const _PhonePreview({required this.theme, required this.label});

  final ThemeData theme;
  final String label;

  @override
  Widget build(BuildContext context) {
    final outer = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: const EdgeInsets.only(bottom: Space.s2),
        child: Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: outer.onSurfaceVariant)),
      ),
      Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Container(
            height: 680,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: outer.outlineVariant),
            ),
            child: Theme(
              data: theme,
              child: Builder(builder: (context) => _MockApp(scheme: theme.colorScheme)),
            ),
          ),
        ),
      ),
    ]);
  }
}

/// Maquette montée avec les widgets et champs du kit ; elle lit le thème du brouillon
/// (`Theme.of` / `context.kc`) comme n'importe quel écran du projet.
class _MockApp extends StatefulWidget {
  const _MockApp({required this.scheme});

  final ColorScheme scheme;

  @override
  State<_MockApp> createState() => _MockAppState();
}

class _MockAppState extends State<_MockApp> {
  ViewMode _view = ViewMode.card;
  String _filter = 'Tous';
  num _qty = 6;
  double _rating = 4;
  bool _notify = true, _urgent = true;

  @override
  Widget build(BuildContext context) {
    final s = widget.scheme;
    const gap = SizedBox(height: 12);
    return Material(
      color: context.kc.bg,
      child: Column(children: [
        AppBar(
          primary: false,
          title: const Text('Clients'),
          leading: const Icon(Icons.menu),
          actions: [
            IconButton(onPressed: () {}, icon: const Badge(label: Text('3'), child: Icon(Icons.notifications_outlined))),
            const KitAvatar(name: 'Jean Kouassi', size: 32),
            const SizedBox(width: 12),
          ],
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(Space.s4, Space.s1, Space.s4, Space.s6),
            children: [
              const KpiCard(icon: Icons.people_outline, value: '434', label: 'Clients actifs'),
              const SizedBox(height: 8),
              const KpiCard(icon: Icons.payments_outlined, value: '12,4', unit: 'M F', label: 'CA du mois', tone: KitTone.success, delta: '+18 %', up: true),
              gap,
              const KitTextField(hint: 'Rechercher un client…', icon: Icons.search),
              gap,
              Row(children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      for (final (f, n) in const [('Tous', 434), ('Actifs', 398), ('Suspendus', 36)]) ...[
                        FilterChipButton(label: f, count: n, active: _filter == f, onTap: () => setState(() => _filter = f)),
                        const SizedBox(width: 6),
                      ],
                    ]),
                  ),
                ),
                ViewModeToggle(mode: _view, showLabels: false, onChanged: (v) => setState(() => _view = v)),
              ]),
              gap,
              KitCard(
                title: 'Transports Yao & Fils',
                icon: Icons.business,
                trailing: const StatusBadge('Actif', tone: KitTone.success),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('CLI-1042 · Logistique · Abidjan', style: TextStyle(color: context.kc.textSecondary, fontSize: 12.5)),
                  const SizedBox(height: 10),
                  const KitProgressBar(value: 0.64),
                  const SizedBox(height: 12),
                  Wrap(alignment: WrapAlignment.end, spacing: 8, runSpacing: 8, children: [
                    KitButton(label: 'Détails', variant: KitButtonVariant.secondary, size: KitButtonSize.compact, onPressed: () {}),
                    KitButton(label: 'Fiche client', iconEnd: Icons.arrow_forward, size: KitButtonSize.compact, onPressed: () {}),
                  ]),
                ]),
              ),
              gap,
              const KitAlert(tone: KitTone.info, title: 'Synchronisation planifiée', text: 'Prochaine synchronisation ce soir à 22:00.', compact: true),
              gap,
              KitCard(
                title: 'Nouvelle intervention',
                icon: Icons.build_outlined,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  const FormFieldLabel(label: 'Raison sociale', child: KitTextField(initialValue: 'Transports Yao & Fils', icon: Icons.business)),
                  gap,
                  FormFieldLabel(label: 'Type', child: FieldTrigger(text: 'Installation balise', icon: Icons.category_outlined, onTap: () {})),
                  gap,
                  CurrencyInput(label: 'Montant', initial: 250000, onChanged: (_) {}),
                  gap,
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                      child: FormFieldLabel(
                        label: 'Balises',
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: NumberStepper(value: _qty, max: 50, compact: true, onChanged: (v) => setState(() => _qty = v)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: FormFieldLabel(label: 'Satisfaction', child: RatingInput(value: _rating, size: 22, onChanged: (v) => setState(() => _rating = v))),
                    ),
                  ]),
                  gap,
                  const FormFieldLabel(
                    label: 'Email',
                    required: true,
                    error: 'Adresse email invalide',
                    child: KitTextField(initialValue: 'jean.kouassi@', icon: Icons.alternate_email, errorText: ''),
                  ),
                  const SizedBox(height: 4),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Notifier le client'),
                    value: _notify,
                    onChanged: (v) => setState(() => _notify = v),
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: const Text('Urgent'),
                    value: _urgent,
                    onChanged: (v) => setState(() => _urgent = v ?? false),
                  ),
                  const Wrap(spacing: 6, runSpacing: 6, children: [
                    StatusBadge('En cours', tone: KitTone.info),
                    StatusBadge('En retard', tone: KitTone.warning),
                    StatusBadge('Annulée', tone: KitTone.error),
                    StatusBadge('Brouillon'),
                  ]),
                  gap,
                  Wrap(alignment: WrapAlignment.end, spacing: 8, runSpacing: 8, children: [
                    KitButton(label: 'Annuler', variant: KitButtonVariant.outline, onPressed: () {}),
                    KitButton(label: 'Enregistrer', icon: Icons.check, onPressed: () {}),
                  ]),
                ]),
              ),
              gap,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: Space.s4, vertical: Space.s3),
                decoration: BoxDecoration(color: s.inverseSurface, borderRadius: BorderRadius.circular(Radii.xs)),
                child: Row(children: [
                  Expanded(child: Text('Thème mis à jour', style: TextStyle(color: s.onInverseSurface))),
                  Text('Annuler', style: TextStyle(color: s.inversePrimary, fontWeight: FontWeight.w600)),
                ]),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

// ─── Nuances & rôles ──────────────────────────────────────────

class _Strips extends StatelessWidget {
  const _Strips({required this.draft});

  final CustomThemeConfig draft;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Column(children: [
      for (final (label, key, tones) in draft.paletteStrips())
        Padding(
          padding: const EdgeInsets.only(bottom: Space.s3),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 16, height: 16, decoration: BoxDecoration(color: key, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(label, style: text.labelLarge),
              const SizedBox(width: 8),
              Text(colorHex(key), style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant, fontFamily: 'SpaceMono')),
            ]),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(Radii.md),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                    for (final (tone, color) in tones)
                      Tooltip(
                        message: '$label $tone · ${colorHex(color)}',
                        child: InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: colorHex(color)));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('« ${colorHex(color)} » copié')));
                          },
                          child: Container(
                            width: 44,
                            height: 48,
                            color: color,
                            alignment: Alignment.bottomCenter,
                            padding: const EdgeInsets.only(bottom: Space.s2),
                            child: Text('$tone',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: tone < 55 ? Colors.white : Colors.black)),
                          ),
                        ),
                      ),
                ]),
              ),
            ),
          ]),
        ),
    ]);
  }
}

class _Roles extends StatelessWidget {
  const _Roles({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final s = scheme;
    final pairs = [
      ('Primary', s.primary, s.onPrimary),
      ('Primary container', s.primaryContainer, s.onPrimaryContainer),
      ('Secondary', s.secondary, s.onSecondary),
      ('Secondary container', s.secondaryContainer, s.onSecondaryContainer),
      ('Tertiary', s.tertiary, s.onTertiary),
      ('Tertiary container', s.tertiaryContainer, s.onTertiaryContainer),
      ('Error', s.error, s.onError),
      ('Error container', s.errorContainer, s.onErrorContainer),
      ('Surface', s.surface, s.onSurface),
      ('Surface container', s.surfaceContainer, s.onSurface),
      ('Surface container highest', s.surfaceContainerHighest, s.onSurfaceVariant),
      ('Inverse surface', s.inverseSurface, s.onInverseSurface),
    ];
    return LayoutBuilder(builder: (context, cons) {
      final cols = math.max(1, (cons.maxWidth / 180).floor());
      final w = (cons.maxWidth - (cols - 1) * 8) / cols;
      return Wrap(spacing: 8, runSpacing: 8, children: [
        for (final (label, bg, fg) in pairs)
          Container(
            width: w,
            height: 84,
            padding: const EdgeInsets.all(Space.s3),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(Radii.md)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 13))),
                Text('${contrastRatio(bg, fg).toStringAsFixed(1)}:1', style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w700)),
              ]),
              const Spacer(),
              Text('${colorHex(bg)} / ${colorHex(fg)}', style: TextStyle(color: fg.withValues(alpha: 0.85), fontSize: 11, fontFamily: 'SpaceMono')),
            ]),
          ),
      ]);
    });
  }
}
