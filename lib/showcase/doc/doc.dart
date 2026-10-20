import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/snack.dart';
import '../../theme/kit_colors.dart';
import '../../theme/kit_text.dart';
import '../../theme/theme_controller.dart';
import '../../theme/tokens.dart';

/// Section documentée : ancre + titre + description + démos (`<kit-section>`).
class DocSection {
  const DocSection({
    required this.id,
    required this.title,
    required this.children,
    this.description,
    this.source,
    this.cols = 1,
    this.tocLabel,
  });

  final String id, title;
  final String? description, source, tocLabel;
  final List<Widget> children;

  /// Colonnes sur tablette (1 colonne sur téléphone, comme `@include mobile`).
  final int cols;
}

/// Page de documentation du catalogue (`<kit-doc-page>`) : barre d'application,
/// hero (icône, sur-titre, titre, sous-titre), sommaire collant en puces
/// défilantes, sections. Le sommaire suit la section visible.
class DocPage extends StatefulWidget {
  const DocPage({
    super.key,
    required this.title,
    required this.sections,
    this.subtitle,
    this.icon = Icons.widgets_outlined,
    this.eyebrow = 'Composants',
    this.actions = const [],
    this.initialSection,
    this.header,
    this.leading,
  });

  final String title;
  final String? subtitle, initialSection;
  final IconData icon;
  final String eyebrow;
  final List<DocSection> sections;
  final List<Widget> actions;

  /// Contenu libre inséré entre le hero et la première section.
  final Widget? header;

  /// Bouton de tête (menu du catalogue quand la page est un onglet racine).
  final Widget? leading;

  @override
  State<DocPage> createState() => _DocPageState();
}

class _DocPageState extends State<DocPage> {
  final _scroll = ScrollController();
  final _tocScroll = ScrollController();
  late final Map<String, GlobalKey> _keys = {for (final s in widget.sections) s.id: GlobalKey()};
  final Map<String, GlobalKey> _chipKeys = {};
  String? _active;

  @override
  void initState() {
    super.initState();
    _active = widget.sections.isEmpty ? null : widget.sections.first.id;
    _scroll.addListener(_onScroll);
    if (widget.initialSection != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _goTo(widget.initialSection!, animate: false));
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    _tocScroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    String? current;
    for (final s in widget.sections) {
      final ctx = _keys[s.id]!.currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) continue;
      final dy = box.localToGlobal(Offset.zero).dy;
      if (dy < 200) current = s.id;
    }
    current ??= widget.sections.isEmpty ? null : widget.sections.first.id;
    if (current != _active) {
      setState(() => _active = current);
      final chip = _chipKeys[current]?.currentContext;
      if (chip != null) Scrollable.ensureVisible(chip, alignment: 0.5, duration: const Duration(milliseconds: 250));
    }
  }

  Future<void> _goTo(String id, {bool animate = true}) async {
    final ctx = _keys[id]?.currentContext;
    if (ctx == null) return;
    await Scrollable.ensureVisible(
      ctx,
      duration: animate ? const Duration(milliseconds: 420) : Duration.zero,
      curve: Curves.easeInOutCubic,
      alignment: 0.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final width = MediaQuery.sizeOf(context).width;
    final pad = width < Breakpoints.tablet ? Space.m : Space.l;
    return Scaffold(
      appBar: AppBar(
        leading: widget.leading,
        title: Text(widget.title),
        actions: [...widget.actions, const ThemeToggleButton(), const ThemePickerButton(), const SizedBox(width: 4)],
        bottom: widget.sections.length < 2
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  height: 48,
                  color: c.bg,
                  child: ListView(
                    controller: _tocScroll,
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: pad, vertical: Space.s2),
                    children: [
                      for (final s in widget.sections)
                        Padding(
                          key: _chipKeys.putIfAbsent(s.id, GlobalKey.new),
                          padding: const EdgeInsets.only(right: Space.s2),
                          child: _TocChip(label: s.tocLabel ?? s.title, active: s.id == _active, onTap: () => _goTo(s.id)),
                        ),
                    ],
                  ),
                ),
              ),
      ),
      body: SingleChildScrollView(
        controller: _scroll,
        padding: EdgeInsets.fromLTRB(pad, Space.l, pad, 96 + MediaQuery.paddingOf(context).bottom),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              _Hero(icon: widget.icon, eyebrow: widget.eyebrow, title: widget.title, subtitle: widget.subtitle),
              const SizedBox(height: Space.l),
              if (widget.header != null) ...[widget.header!, const SizedBox(height: Space.l)],
              for (final s in widget.sections) _SectionView(key: _keys[s.id], section: s),
            ]),
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.icon, required this.eyebrow, required this.title, this.subtitle});
  final IconData icon;
  final String eyebrow, title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(shape: BoxShape.circle, color: c.primaryLight),
        child: Icon(icon, size: 28, color: c.primary),
      ),
      const SizedBox(width: Space.m),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(eyebrow.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.1, color: c.textMuted)),
          const SizedBox(height: 2),
          Text(title, style: KitText.h2.copyWith(fontSize: 26, fontWeight: FontWeight.w700, color: c.textPrimary)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: TextStyle(fontSize: 14, height: 1.5, color: c.textSecondary)),
          ],
        ]),
      ),
    ]);
  }
}

class _TocChip extends StatelessWidget {
  const _TocChip({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return Material(
      color: active ? c.primaryLight : c.fieldBg,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.s3, vertical: Space.s2),
          child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: active ? c.primary : c.textSecondary)),
        ),
      ),
    );
  }
}

class _SectionView extends StatelessWidget {
  const _SectionView({super.key, required this.section});
  final DocSection section;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final s = section;
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.xl),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 10, runSpacing: 4, children: [
          Text(s.title, style: KitText.h3.copyWith(color: c.textPrimary)),
          if (s.source != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: Space.s2, vertical: Space.s0_5),
              decoration: BoxDecoration(color: c.hover, borderRadius: BorderRadius.circular(Radii.sm)),
              child: Text(s.source!, style: TextStyle(fontFamily: Fonts.mono, fontSize: 10.5, color: c.textMuted)),
            ),
        ]),
        if (s.description != null) ...[
          const SizedBox(height: Space.s),
          Text(s.description!, style: TextStyle(fontSize: 13, height: 1.5, color: c.textSecondary)),
        ],
        const SizedBox(height: Space.m),
        LayoutBuilder(builder: (context, cons) {
          final cols = math.min(s.cols, Breakpoints.columns(cons.maxWidth, max: s.cols));
          if (cols <= 1) {
            return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              for (var i = 0; i < s.children.length; i++) ...[
                if (i > 0) const SizedBox(height: Space.m),
                s.children[i],
              ],
            ]);
          }
          final w = (cons.maxWidth - Space.m * (cols - 1)) / cols;
          return Wrap(spacing: Space.m, runSpacing: Space.m, children: [for (final ch in s.children) SizedBox(width: w, child: ch)]);
        }),
      ]),
    );
  }
}

/// Cadre de démonstration d'une variante, avec extrait de code copiable (`<kit-demo>`).
class Demo extends StatefulWidget {
  const Demo({super.key, required this.label, required this.child, this.hint, this.code, this.flush = false, this.muted = false, this.padding});

  final String label;
  final String? hint, code;
  final Widget child;

  /// Sans marge interne (cartes, tableaux pleine largeur).
  final bool flush;

  /// Fond atténué (scène « page »).
  final bool muted;
  final EdgeInsetsGeometry? padding;

  @override
  State<Demo> createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  bool _showCode = false;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: c.card, borderRadius: Radii.rl),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
        Container(
          constraints: const BoxConstraints(minHeight: 40),
          padding: const EdgeInsets.fromLTRB(Space.s4, Space.s1, Space.s1, Space.s1),
          color: c.hover.withValues(alpha: 0.5),
          child: Row(children: [
            if (widget.hint != null) ...[
              Flexible(child: Text(widget.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.textPrimary))),
              const SizedBox(width: 8),
              Expanded(
                child: Text(widget.hint!, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: c.textMuted)),
              ),
            ] else
              Expanded(child: Text(widget.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.textPrimary))),
            if (widget.code != null)
              IconButton(
                visualDensity: VisualDensity.compact,
                iconSize: 18,
                tooltip: _showCode ? 'Masquer le code' : 'Voir le code',
                color: _showCode ? c.primary : c.textMuted,
                onPressed: () => setState(() => _showCode = !_showCode),
                icon: Icon(_showCode ? Icons.code_off : Icons.code),
              )
            else
              const SizedBox(height: 32),
          ]),
        ),
        Container(
          color: widget.muted ? c.bg : null,
          padding: widget.flush ? EdgeInsets.zero : (widget.padding ?? const EdgeInsets.all(Space.m)),
          child: widget.child,
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          child: !_showCode
              ? const SizedBox(width: double.infinity)
              : CodeBlock(code: widget.code!.trim()),
        ),
      ]),
    );
  }
}

/// Bloc de code monospace avec bouton copier.
class CodeBlock extends StatelessWidget {
  const CodeBlock({super.key, required this.code, this.file, this.rounded = false});
  final String code;
  final String? file;
  final bool rounded;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final bg = dark ? const Color(0xFF0D1117) : const Color(0xFF1E293B);
    const fg = Color(0xFFE2E8F0);
    return Container(
      decoration: BoxDecoration(color: bg, borderRadius: rounded ? Radii.rm : null),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          const SizedBox(width: 14),
          if (file != null)
            Expanded(child: Text(file!, style: const TextStyle(fontFamily: Fonts.mono, fontSize: 11, color: Color(0xFF94A3B8))))
          else
            const Spacer(),
          IconButton(
            iconSize: 16,
            visualDensity: VisualDensity.compact,
            color: const Color(0xFF94A3B8),
            tooltip: 'Copier',
            onPressed: () => copyToClipboard(context, code, label: 'Extrait copié dans le presse-papiers'),
            icon: const Icon(Icons.content_copy),
          ),
        ]),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(Space.s4, 0, Space.s4, Space.s4),
          child: SelectableText(code, style: const TextStyle(fontFamily: Fonts.mono, fontSize: 11.5, height: 1.55, color: fg)),
        ),
      ]),
    );
  }
}

/// Petite légende sous une démo.
class DemoNote extends StatelessWidget {
  const DemoNote(this.text, {super.key, this.icon = Icons.info_outline});
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 16, color: c.textMuted),
      const SizedBox(width: 6),
      Expanded(child: Text(text, style: TextStyle(fontSize: 12, height: 1.45, color: c.textMuted))),
    ]);
  }
}

/// Rangée de widgets qui passe à la ligne (boutons, badges…).
class DemoWrap extends StatelessWidget {
  const DemoWrap({super.key, required this.children, this.spacing = 10, this.runSpacing = 10, this.alignment = WrapAlignment.start});
  final List<Widget> children;
  final double spacing, runSpacing;
  final WrapAlignment alignment;

  @override
  Widget build(BuildContext context) =>
      Wrap(spacing: spacing, runSpacing: runSpacing, alignment: alignment, crossAxisAlignment: WrapCrossAlignment.center, children: children);
}

/// Colonne espacée.
class Gap extends StatelessWidget {
  const Gap(this.children, {super.key, this.gap = 12});
  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
        for (var i = 0; i < children.length; i++) ...[if (i > 0) SizedBox(height: gap), children[i]],
      ]);
}
