import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/format.dart';
import '../../core/snack.dart';
import '../../theme/kit_colors.dart';
import '../../theme/kit_text.dart';
import '../../theme/tokens.dart';

// ═══════════════════════════════════════════════════════════════════
// Champs avancés (shared/components/fields) : OTP, nombre ±, montant,
// notation, mot de passe avec jauge, valeur à copier, tags.
// ═══════════════════════════════════════════════════════════════════

/// `<app-otp-input>` : cases individuelles, avance automatique, collage, effacement arrière.
class OtpInput extends StatefulWidget {
  const OtpInput({super.key, this.length = 6, this.onCompleted, this.onChanged, this.obscure = false, this.error = false, this.enabled = true});
  final int length;
  final ValueChanged<String>? onCompleted, onChanged;
  final bool obscure, error, enabled;

  @override
  State<OtpInput> createState() => OtpInputState();
}

class OtpInputState extends State<OtpInput> {
  late final _ctrl = TextEditingController();
  final _focus = FocusNode();

  void clear() {
    _ctrl.clear();
    setState(() {});
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final v = _ctrl.text;
    return GestureDetector(
      onTap: () => _focus.requestFocus(),
      child: Stack(children: [
        // Champ invisible qui porte la saisie (clavier numérique, autofill SMS).
        Opacity(
          opacity: 0,
          child: SizedBox(
            height: 1,
            child: TextField(
              controller: _ctrl,
              focusNode: _focus,
              enabled: widget.enabled,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.oneTimeCode],
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(widget.length)],
              onChanged: (s) {
                setState(() {});
                widget.onChanged?.call(s);
                if (s.length == widget.length) widget.onCompleted?.call(s);
              },
            ),
          ),
        ),
        ListenableBuilder(
          listenable: _focus,
          builder: (context, _) => Row(mainAxisSize: MainAxisSize.min, children: [
            for (var i = 0; i < widget.length; i++) ...[
              if (i > 0) SizedBox(width: widget.length > 4 && i == widget.length ~/ 2 ? 14 : 8),
              _cell(c, i < v.length ? v[i] : '', _focus.hasFocus && (i == v.length || (i == widget.length - 1 && v.length == widget.length))),
            ],
          ]),
        ),
      ]),
    );
  }

  Widget _cell(KitColors c, String ch, bool active) {
    final border = widget.error ? c.error : (active ? c.primary : c.border);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 44,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? c.card : c.fieldBg,
        borderRadius: Radii.rm,
        border: Border.all(color: border, width: active ? 1.8 : 1),
        boxShadow: active ? [BoxShadow(color: c.primary.withValues(alpha: 0.15), spreadRadius: 3)] : null,
      ),
      child: Text(
        ch.isEmpty ? '' : (widget.obscure ? '•' : ch),
        style: TextStyle(fontFamily: Fonts.heading, fontSize: 22, fontWeight: FontWeight.w700, color: c.textPrimary),
      ),
    );
  }
}

/// `<app-number-stepper>` : −/+ avec bornes, pas, appui long pour répéter.
class NumberStepper extends StatelessWidget {
  const NumberStepper({super.key, required this.value, required this.onChanged, this.min = 0, this.max = 999, this.step = 1, this.unit, this.compact = false});
  final num value, min, max, step;
  final ValueChanged<num> onChanged;
  final String? unit;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    Widget btn(IconData icon, bool enabled, num next) => Material(
          color: enabled ? c.card : Colors.transparent,
          shape: CircleBorder(side: BorderSide(color: c.border)),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: enabled ? () => onChanged(next) : null,
            child: SizedBox(width: compact ? 30 : 36, height: compact ? 30 : 36, child: Icon(icon, size: 18, color: enabled ? c.textPrimary : c.textMuted)),
          ),
        );
    final display = value is int || value == value.roundToDouble() ? Fmt.number(value) : Fmt.decimal1(value);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: c.fieldBg, borderRadius: Radii.pill, border: Border.all(color: c.border)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        btn(Icons.remove, value > min, math.max(min, value - step)),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: compact ? 44 : 64),
          child: Text.rich(
            TextSpan(text: display, children: [if (unit != null) TextSpan(text: ' $unit', style: TextStyle(fontSize: 12, color: c.textSecondary, fontWeight: FontWeight.w500))]),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c.textPrimary, fontFeatures: KitText.tabular),
          ),
        ),
        btn(Icons.add, value < max, math.min(max, value + step)),
      ]),
    );
  }
}

/// Séparateur de milliers à la saisie (`1 250 000`).
class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return const TextEditingValue();
    final n = int.parse(digits.length > 15 ? digits.substring(0, 15) : digits);
    final text = Fmt.number(n);
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}

/// `<app-currency-input>` : montant formaté + devise (FCFA par défaut), raccourcis.
class CurrencyInput extends StatefulWidget {
  const CurrencyInput({super.key, this.initial, required this.onChanged, this.currency = 'FCFA', this.currencies = const ['FCFA', 'EUR', 'USD'], this.presets = const [], this.label});
  final int? initial;
  final ValueChanged<(int?, String)> onChanged;
  final String currency;
  final List<String> currencies;
  final List<int> presets;
  final String? label;

  @override
  State<CurrencyInput> createState() => _CurrencyInputState();
}

class _CurrencyInputState extends State<CurrencyInput> {
  late final _ctrl = TextEditingController(text: widget.initial == null ? '' : Fmt.number(widget.initial!));
  late String _cur = widget.currency;

  int? get _value => int.tryParse(_ctrl.text.replaceAll(RegExp(r'\D'), ''));

  void _emit() => widget.onChanged((_value, _cur));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
      TextField(
        controller: _ctrl,
        keyboardType: TextInputType.number,
        inputFormatters: [ThousandsFormatter()],
        textAlign: TextAlign.right,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, fontFeatures: KitText.tabular, color: c.textPrimary),
        onChanged: (_) => _emit(),
        decoration: InputDecoration(
          hintText: '0',
          prefixIcon: Icon(Icons.payments_outlined, color: c.textSecondary),
          suffixIcon: widget.currencies.length < 2
              ? Padding(padding: const EdgeInsets.all(14), child: Text(_cur, style: TextStyle(fontWeight: FontWeight.w700, color: c.textSecondary)))
              : PopupMenuButton<String>(
                  initialValue: _cur,
                  onSelected: (v) {
                    setState(() => _cur = v);
                    _emit();
                  },
                  itemBuilder: (_) => [for (final x in widget.currencies) PopupMenuItem(value: x, child: Text(x))],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(_cur, style: TextStyle(fontWeight: FontWeight.w700, color: c.primary)),
                      Icon(Icons.arrow_drop_down, color: c.primary),
                    ]),
                  ),
                ),
        ),
      ),
      if (widget.presets.isNotEmpty) ...[
        const SizedBox(height: 8),
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final p in widget.presets)
            ActionChip(
              label: Text(Fmt.compact(p)),
              onPressed: () {
                _ctrl.text = Fmt.number(p);
                _emit();
              },
            ),
        ]),
      ],
    ]);
  }
}

/// `<app-rating>` : étoiles (demi-étoiles optionnelles), lecture seule possible.
class RatingInput extends StatelessWidget {
  const RatingInput({super.key, required this.value, this.onChanged, this.max = 5, this.size = 32, this.icon = Icons.star_rounded, this.emptyIcon = Icons.star_outline_rounded, this.color, this.labels});
  final double value;
  final ValueChanged<double>? onChanged;
  final int max;
  final double size;
  final IconData icon, emptyIcon;
  final Color? color;
  final List<String>? labels;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final col = color ?? c.warning;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      for (var i = 1; i <= max; i++)
        GestureDetector(
          onTap: onChanged == null ? null : () => onChanged!(value == i ? 0 : i.toDouble()),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: AnimatedScale(
              scale: value >= i ? 1.08 : 1,
              duration: const Duration(milliseconds: 150),
              child: value >= i
                  ? Icon(icon, size: size, color: col)
                  : value >= i - 0.5
                      ? Icon(Icons.star_half_rounded, size: size, color: col)
                      : Icon(emptyIcon, size: size, color: c.textMuted.withValues(alpha: 0.6)),
            ),
          ),
        ),
      if (labels != null && value > 0) ...[
        const SizedBox(width: 10),
        Text(labels![(value.ceil() - 1).clamp(0, labels!.length - 1)], style: TextStyle(fontWeight: FontWeight.w600, color: c.textSecondary)),
      ],
    ]);
  }
}

/// Règle de mot de passe (`PasswordRule`).
class PasswordRule {
  const PasswordRule(this.label, this.test);
  final String label;
  final bool Function(String) test;
}

final kPasswordRules = [
  PasswordRule('8 caractères minimum', (v) => v.length >= 8),
  PasswordRule('Une majuscule et une minuscule', (v) => RegExp(r'[a-z]').hasMatch(v) && RegExp(r'[A-Z]').hasMatch(v)),
  PasswordRule('Un chiffre', (v) => RegExp(r'\d').hasMatch(v)),
  PasswordRule('Un caractère spécial', (v) => RegExp(r'[^A-Za-z0-9]').hasMatch(v)),
];

int passwordScore(String v) {
  if (v.isEmpty) return 0;
  var s = kPasswordRules.where((r) => r.test(v)).length;
  if (v.length >= 12 && s >= 3) s = 4;
  return s.clamp(0, 4);
}

/// `<app-password-field>` : visibilité, jauge 4 niveaux, règles, générateur.
class PasswordField extends StatefulWidget {
  const PasswordField({super.key, this.label = 'Mot de passe', this.generator = true, this.onChanged});
  final String label;
  final bool generator;
  final ValueChanged<String>? onChanged;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  final _ctrl = TextEditingController();
  bool _visible = false;
  int _seed = 3;

  static const _levels = ['Très faible', 'Faible', 'Moyen', 'Bon', 'Excellent'];

  String _generate() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#%&*?';
    final r = math.Random(_seed++);
    var out = List.generate(14, (_) => chars[r.nextInt(chars.length)]).join();
    if (passwordScore(out) < 4) out = 'Ab3!$out';
    return out;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final v = _ctrl.text;
    final score = passwordScore(v);
    final col = switch (score) { 0 || 1 => c.error, 2 => c.warning, 3 => c.info, _ => c.success };
    final textCol = switch (score) { 0 || 1 => c.errorText, 2 => c.warningText, 3 => c.info, _ => c.successText };
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
      Text(widget.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.textSecondary)),
      const SizedBox(height: 6),
      TextField(
        controller: _ctrl,
        obscureText: !_visible,
        autofillHints: const [AutofillHints.newPassword],
        onChanged: (s) {
          setState(() {});
          widget.onChanged?.call(s);
        },
        decoration: InputDecoration(
          hintText: '••••••••',
          prefixIcon: const Icon(Icons.lock_outline, size: 20),
          suffixIcon: Row(mainAxisSize: MainAxisSize.min, children: [
            if (widget.generator)
              IconButton(
                tooltip: 'Générer',
                icon: const Icon(Icons.auto_fix_high, size: 20),
                onPressed: () => setState(() {
                  _ctrl.text = _generate();
                  _visible = true;
                }),
              ),
            IconButton(
              tooltip: _visible ? 'Masquer' : 'Afficher',
              icon: Icon(_visible ? Icons.visibility_off : Icons.visibility, size: 20),
              onPressed: () => setState(() => _visible = !_visible),
            ),
          ]),
        ),
      ),
      const SizedBox(height: 8),
      Row(children: [
        for (var i = 0; i < 4; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 4,
              decoration: BoxDecoration(color: v.isNotEmpty && i < math.max(1, score) ? col : c.fieldBg, borderRadius: Radii.pill),
            ),
          ),
        ],
        const SizedBox(width: 10),
        SizedBox(width: 72, child: Text(v.isEmpty ? '' : _levels[score], style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: textCol))),
      ]),
      const SizedBox(height: 8),
      Wrap(spacing: 14, runSpacing: 4, children: [
        for (final r in kPasswordRules)
          Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(r.test(v) ? Icons.check_circle : Icons.radio_button_unchecked, size: 15, color: r.test(v) ? c.success : c.textMuted),
            const SizedBox(width: 4),
            Flexible(child: Text(r.label, style: TextStyle(fontSize: 12, color: r.test(v) ? c.textPrimary : c.textMuted))),
          ]),
      ]),
    ]);
  }
}

/// `<app-copy-field>` : valeur en lecture seule + bouton copier (avec retour visuel), masquage optionnel.
class CopyField extends StatefulWidget {
  const CopyField({super.key, required this.value, this.label, this.secret = false, this.mono = true, this.icon});
  final String value;
  final String? label;
  final bool secret, mono;
  final IconData? icon;

  @override
  State<CopyField> createState() => _CopyFieldState();
}

class _CopyFieldState extends State<CopyField> {
  bool _copied = false;
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final shown = widget.secret && !_revealed ? '•' * math.min(24, widget.value.length) : widget.value;
    final box = Container(
      constraints: const BoxConstraints(minHeight: 46),
      padding: const EdgeInsets.only(left: 12),
      decoration: BoxDecoration(color: c.fieldBg, borderRadius: Radii.rm, border: Border.all(color: c.border)),
      child: Row(children: [
        if (widget.icon != null) ...[Icon(widget.icon, size: 20, color: c.textSecondary), const SizedBox(width: 10)],
        Expanded(
          child: Text(shown, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: widget.mono ? Fonts.mono : null, fontSize: 13, color: c.textPrimary)),
        ),
        if (widget.secret)
          IconButton(icon: Icon(_revealed ? Icons.visibility_off : Icons.visibility, size: 18), onPressed: () => setState(() => _revealed = !_revealed)),
        IconButton(
          tooltip: 'Copier',
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(_copied ? Icons.check : Icons.content_copy, key: ValueKey(_copied), size: 18, color: _copied ? c.success : null),
          ),
          onPressed: () async {
            await copyToClipboard(context, widget.value, label: 'Copié dans le presse-papiers');
            setState(() => _copied = true);
            await Future<void>.delayed(const Duration(milliseconds: 1500));
            if (mounted) setState(() => _copied = false);
          },
        ),
      ]),
    );
    if (widget.label == null) return box;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
      Text(widget.label!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.textSecondary)),
      const SizedBox(height: 6),
      box,
    ]);
  }
}

/// `<app-tag-input>` : tags libres (Entrée / virgule), suggestions, limite.
class TagInput extends StatefulWidget {
  const TagInput({super.key, required this.tags, required this.onChanged, this.suggestions = const [], this.max, this.hint = 'Ajouter un tag…'});
  final List<String> tags;
  final ValueChanged<List<String>> onChanged;
  final List<String> suggestions;
  final int? max;
  final String hint;

  @override
  State<TagInput> createState() => _TagInputState();
}

class _TagInputState extends State<TagInput> {
  final _ctrl = TextEditingController();

  void _add(String raw) {
    final t = raw.trim().replaceAll(',', '');
    if (t.isEmpty || widget.tags.any((x) => x.toLowerCase() == t.toLowerCase())) {
      _ctrl.clear();
      return;
    }
    if (widget.max != null && widget.tags.length >= widget.max!) return;
    widget.onChanged([...widget.tags, t]);
    _ctrl.clear();
    setState(() {});
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final q = _ctrl.text.trim().toLowerCase();
    final sugg = widget.suggestions.where((s) => !widget.tags.contains(s) && (q.isEmpty || s.toLowerCase().contains(q))).take(8).toList();
    final full = widget.max != null && widget.tags.length >= widget.max!;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
      Container(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
        decoration: BoxDecoration(color: c.fieldBg, borderRadius: Radii.rm, border: Border.all(color: c.border)),
        child: Wrap(spacing: 6, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
          for (final t in widget.tags)
            InputChip(
              label: Text(t),
              visualDensity: VisualDensity.compact,
              backgroundColor: c.primaryLight,
              side: BorderSide.none,
              labelStyle: TextStyle(color: c.primary, fontWeight: FontWeight.w600, fontSize: 12.5),
              deleteIconColor: c.primary,
              onDeleted: () => widget.onChanged([...widget.tags]..remove(t)),
            ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 120, maxWidth: 220),
            child: TextField(
              controller: _ctrl,
              enabled: !full,
              onChanged: (v) {
                if (v.endsWith(',')) {
                  _add(v);
                } else {
                  setState(() {});
                }
              },
              onSubmitted: _add,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: full ? 'Limite atteinte' : widget.hint,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ]),
      ),
      if (sugg.isNotEmpty && !full) ...[
        const SizedBox(height: 8),
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final s in sugg)
            ActionChip(avatar: Icon(Icons.add, size: 16, color: c.textSecondary), label: Text(s), onPressed: () => _add(s)),
        ]),
      ],
      if (widget.max != null) ...[
        const SizedBox(height: 4),
        Text('${widget.tags.length} / ${widget.max}', textAlign: TextAlign.right, style: TextStyle(fontSize: 11.5, color: c.textMuted)),
      ],
    ]);
  }
}
