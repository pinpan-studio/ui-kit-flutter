import 'package:flutter/material.dart';

import '../../theme/kit_colors.dart';
import '../../theme/kit_text.dart';
import '../../theme/tokens.dart';
import '../common.dart';

// ═══════════════════════════════════════════════════════════════════
// Éditeurs : texte riche (sans dépendance) et Markdown avec aperçu.
// ═══════════════════════════════════════════════════════════════════

/// Rendu inline Markdown : **gras**, *italique*, `code`, ~~barré~~, [lien](url).
List<InlineSpan> markdownInline(String text, TextStyle base, KitColors c) {
  final spans = <InlineSpan>[];
  final re = RegExp(r'(\*\*([^*]+)\*\*|`([^`]+)`|~~([^~]+)~~|\*([^*]+)\*|\[([^\]]+)\]\(([^)\s]+)\))');
  var last = 0;
  for (final m in re.allMatches(text)) {
    if (m.start > last) spans.add(TextSpan(text: text.substring(last, m.start)));
    if (m.group(2) != null) {
      spans.add(TextSpan(text: m.group(2), style: const TextStyle(fontWeight: FontWeight.w700)));
    } else if (m.group(3) != null) {
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(color: c.hover, borderRadius: BorderRadius.circular(5)),
          child: Text(m.group(3)!, style: TextStyle(fontFamily: Fonts.mono, fontSize: (base.fontSize ?? 14) * 0.86, color: c.primary)),
        ),
      ));
    } else if (m.group(4) != null) {
      spans.add(TextSpan(text: m.group(4), style: const TextStyle(decoration: TextDecoration.lineThrough)));
    } else if (m.group(5) != null) {
      spans.add(TextSpan(text: m.group(5), style: const TextStyle(fontStyle: FontStyle.italic)));
    } else if (m.group(6) != null) {
      spans.add(TextSpan(text: m.group(6), style: TextStyle(color: c.primary, decoration: TextDecoration.underline, decorationColor: c.primary)));
    }
    last = m.end;
  }
  if (last < text.length) spans.add(TextSpan(text: text.substring(last)));
  return spans;
}

/// Rendu d'un document Markdown (titres, listes, citations, code, séparateurs).
class MarkdownView extends StatelessWidget {
  const MarkdownView(this.source, {super.key, this.fontSize = 14});
  final String source;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final base = TextStyle(fontSize: fontSize, height: 1.55, color: c.textPrimary);
    final blocks = <Widget>[];
    final lines = source.replaceAll('\r\n', '\n').split('\n');
    var i = 0;
    Widget para(String t, {TextStyle? style}) => Text.rich(TextSpan(style: style ?? base, children: markdownInline(t, style ?? base, c)));
    while (i < lines.length) {
      final l = lines[i];
      if (l.trim().isEmpty) {
        i++;
        continue;
      }
      if (l.startsWith('```')) {
        final buf = <String>[];
        i++;
        while (i < lines.length && !lines[i].startsWith('```')) {
          buf.add(lines[i++]);
        }
        i++;
        blocks.add(Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Space.s3),
          decoration: BoxDecoration(color: c.hover, borderRadius: Radii.rm),
          child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(buf.join('\n'), style: KitText.mono.copyWith(color: c.textPrimary, fontSize: 12))),
        ));
        continue;
      }
      final h = RegExp(r'^(#{1,3})\s+(.*)').firstMatch(l);
      if (h != null) {
        final lvl = h.group(1)!.length;
        final st = (lvl == 1 ? KitText.h2 : lvl == 2 ? KitText.h3 : KitText.h4).copyWith(color: c.textPrimary);
        blocks.add(Padding(padding: const EdgeInsets.only(top: Space.s1), child: para(h.group(2)!, style: st)));
        i++;
        continue;
      }
      if (RegExp(r'^(-{3,}|\*{3,})$').hasMatch(l.trim())) {
        blocks.add(const Divider(height: 8));
        i++;
        continue;
      }
      if (l.startsWith('>')) {
        final buf = <String>[];
        while (i < lines.length && lines[i].startsWith('>')) {
          buf.add(lines[i++].replaceFirst(RegExp(r'^>\s?'), ''));
        }
        blocks.add(Container(
          padding: const EdgeInsets.fromLTRB(Space.s3, Space.s2, Space.s2, Space.s2),
          decoration: BoxDecoration(border: Border(left: BorderSide(color: c.primary, width: 3)), color: c.primaryLight),
          child: para(buf.join(' '), style: base.copyWith(color: c.textSecondary, fontStyle: FontStyle.italic)),
        ));
        continue;
      }
      final li = RegExp(r'^\s*([-*]|\d+\.)\s+(.*)');
      if (li.hasMatch(l)) {
        final items = <(String, String)>[];
        while (i < lines.length && li.hasMatch(lines[i])) {
          final m = li.firstMatch(lines[i++])!;
          items.add((m.group(1)!, m.group(2)!));
        }
        blocks.add(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (final (mark, t) in items)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.s1),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(
                  width: 22,
                  child: Text(mark == '-' || mark == '*' ? '•' : mark, style: base.copyWith(color: c.primary, fontWeight: FontWeight.w700)),
                ),
                Expanded(
                  child: t.startsWith('[ ] ') || t.startsWith('[x] ')
                      ? Row(children: [
                          Icon(t.startsWith('[x]') ? Icons.check_box : Icons.check_box_outline_blank, size: 18, color: t.startsWith('[x]') ? c.success : c.textMuted),
                          const SizedBox(width: 6),
                          Expanded(child: para(t.substring(4))),
                        ])
                      : para(t),
                ),
              ]),
            ),
        ]));
        continue;
      }
      final buf = <String>[];
      while (i < lines.length && lines[i].trim().isNotEmpty && !RegExp(r'^(#|>|```|\s*[-*]\s|\s*\d+\.\s)').hasMatch(lines[i])) {
        buf.add(lines[i++]);
      }
      if (buf.isEmpty) buf.add(lines[i++]);
      blocks.add(para(buf.join(' ')));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (var k = 0; k < blocks.length; k++) ...[if (k > 0) const SizedBox(height: 10), blocks[k]],
    ]);
  }
}

/// Éditeur Markdown : barre d'outils (insère la syntaxe), onglets Écrire / Aperçu, compteur.
class MarkdownEditor extends StatefulWidget {
  const MarkdownEditor({super.key, required this.initial, this.onChanged, this.minLines = 8});
  final String initial;
  final ValueChanged<String>? onChanged;
  final int minLines;

  @override
  State<MarkdownEditor> createState() => _MarkdownEditorState();
}

class _MarkdownEditorState extends State<MarkdownEditor> {
  late final _ctrl = TextEditingController(text: widget.initial);
  bool _preview = false;

  void _wrap(String before, [String? after]) {
    after ??= before;
    final v = _ctrl.value;
    final s = v.selection.isValid ? v.selection : TextSelection.collapsed(offset: v.text.length);
    final sel = v.text.substring(s.start, s.end);
    final ins = '$before${sel.isEmpty ? 'texte' : sel}$after';
    final text = v.text.replaceRange(s.start, s.end, ins);
    _ctrl.value = TextEditingValue(text: text, selection: TextSelection(baseOffset: s.start + before.length, extentOffset: s.start + ins.length - after.length));
    widget.onChanged?.call(text);
    setState(() {});
  }

  void _line(String prefix) {
    final v = _ctrl.value;
    final pos = v.selection.isValid ? v.selection.start : v.text.length;
    final start = v.text.lastIndexOf('\n', pos - 1 < 0 ? 0 : pos - 1) + 1;
    final text = v.text.replaceRange(start, start, prefix);
    _ctrl.value = TextEditingValue(text: text, selection: TextSelection.collapsed(offset: pos + prefix.length));
    widget.onChanged?.call(text);
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
    final words = _ctrl.text.trim().isEmpty ? 0 : _ctrl.text.trim().split(RegExp(r'\s+')).length;
    final tools = <(IconData, String, VoidCallback)>[
      (Icons.title, 'Titre', () => _line('## ')),
      (Icons.format_bold, 'Gras', () => _wrap('**')),
      (Icons.format_italic, 'Italique', () => _wrap('*')),
      (Icons.strikethrough_s, 'Barré', () => _wrap('~~')),
      (Icons.code, 'Code', () => _wrap('`')),
      (Icons.format_list_bulleted, 'Liste', () => _line('- ')),
      (Icons.format_list_numbered, 'Liste numérotée', () => _line('1. ')),
      (Icons.check_box_outlined, 'Tâche', () => _line('- [ ] ')),
      (Icons.format_quote, 'Citation', () => _line('> ')),
      (Icons.link, 'Lien', () => _wrap('[', '](https://)')),
    ];
    return Container(
      decoration: BoxDecoration(color: c.card, borderRadius: Radii.rm, border: Border.all(color: c.border)),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          color: c.hover.withValues(alpha: 0.5),
          padding: const EdgeInsets.fromLTRB(Space.s2, Space.s2, Space.s2, Space.s2),
          child: Row(children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SegmentedToggle<bool>(
                    value: _preview,
                    onChanged: (v) => setState(() => _preview = v),
                    options: const [(false, 'Écrire', Icons.edit), (true, 'Aperçu', Icons.visibility)],
                  ),
                ),
              ),
            ),
            Text('$words mots', style: TextStyle(fontSize: 11.5, color: c.textMuted)),
          ]),
        ),
        if (!_preview)
          SizedBox(
            height: 44,
            child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: Space.s1), children: [
              for (final (icon, tip, fn) in tools) IconButton(tooltip: tip, iconSize: 20, onPressed: fn, icon: Icon(icon)),
            ]),
          ),
        const Divider(height: 1),
        if (_preview)
          Padding(padding: const EdgeInsets.all(Space.s4), child: MarkdownView(_ctrl.text))
        else
          TextField(
            controller: _ctrl,
            maxLines: null,
            minLines: widget.minLines,
            style: KitText.mono.copyWith(fontSize: 13, color: c.textPrimary),
            onChanged: (v) {
              widget.onChanged?.call(v);
              setState(() {});
            },
            decoration: const InputDecoration(
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.all(Space.s4),
            ),
          ),
      ]),
    );
  }
}

/// Attributs de mise en forme d'un caractère.
enum RtAttr { bold, italic, underline, strike, highlight }

/// Contrôleur de texte riche : un jeu d'attributs par caractère, rendu dans `buildTextSpan`.
class RichTextController extends TextEditingController {
  RichTextController({String text = '', List<Set<RtAttr>>? attrs})
      : _attrs = attrs ?? List.generate(text.length, (_) => <RtAttr>{}),
        super(text: text);

  List<Set<RtAttr>> _attrs;
  final Set<RtAttr> pending = {};
  Color highlightColor = const Color(0x66FDE047);

  bool isActive(RtAttr a) {
    final s = selection;
    if (!s.isValid) return false;
    if (s.isCollapsed) return pending.contains(a) || (s.start > 0 && s.start <= _attrs.length && _attrs[s.start - 1].contains(a));
    return _attrs.sublist(s.start, s.end).every((x) => x.contains(a));
  }

  void toggle(RtAttr a) {
    final s = selection;
    if (!s.isValid) return;
    if (s.isCollapsed) {
      pending.contains(a) ? pending.remove(a) : pending.add(a);
    } else {
      final on = !isActive(a);
      for (var i = s.start; i < s.end; i++) {
        on ? _attrs[i].add(a) : _attrs[i].remove(a);
      }
    }
    notifyListeners();
  }

  void clearFormatting() {
    final s = selection;
    if (!s.isValid) return;
    for (var i = s.start; i < s.end; i++) {
      _attrs[i].clear();
    }
    pending.clear();
    notifyListeners();
  }

  @override
  set value(TextEditingValue newValue) {
    final old = text;
    final nt = newValue.text;
    if (old != nt) {
      var pre = 0;
      while (pre < old.length && pre < nt.length && old[pre] == nt[pre]) {
        pre++;
      }
      var suf = 0;
      while (suf < old.length - pre && suf < nt.length - pre && old[old.length - 1 - suf] == nt[nt.length - 1 - suf]) {
        suf++;
      }
      final inserted = nt.length - pre - suf;
      final inherit = pending.isNotEmpty ? {...pending} : (pre > 0 && pre <= _attrs.length ? {..._attrs[pre - 1]} : <RtAttr>{});
      _attrs = [
        ..._attrs.sublist(0, pre),
        for (var i = 0; i < inserted; i++) {...inherit},
        ..._attrs.sublist(old.length - suf),
      ];
      if (inserted > 0) pending.clear();
    }
    super.value = newValue;
  }

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    if (text.isEmpty) return TextSpan(style: style, text: '');
    final children = <TextSpan>[];
    var start = 0;
    for (var i = 1; i <= text.length; i++) {
      if (i == text.length || !_same(_attrs[i], _attrs[start])) {
        children.add(TextSpan(text: text.substring(start, i), style: _style(_attrs[start])));
        start = i;
      }
    }
    return TextSpan(style: style, children: children);
  }

  bool _same(Set<RtAttr> a, Set<RtAttr> b) => a.length == b.length && a.containsAll(b);

  TextStyle _style(Set<RtAttr> a) => TextStyle(
        fontWeight: a.contains(RtAttr.bold) ? FontWeight.w700 : null,
        fontStyle: a.contains(RtAttr.italic) ? FontStyle.italic : null,
        backgroundColor: a.contains(RtAttr.highlight) ? highlightColor : null,
        decoration: TextDecoration.combine([
          if (a.contains(RtAttr.underline)) TextDecoration.underline,
          if (a.contains(RtAttr.strike)) TextDecoration.lineThrough,
        ]),
      );
}

/// Éditeur de texte riche (remplace CKEditor / Quill) : gras, italique, souligné,
/// barré, surligné, listes, effacement de la mise en forme, compteur.
class RichTextEditor extends StatefulWidget {
  const RichTextEditor({super.key, this.initialText = '', this.minLines = 6});
  final String initialText;
  final int minLines;

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  late final RichTextController _ctrl = () {
    final t = widget.initialText;
    final attrs = List.generate(t.length, (_) => <RtAttr>{});
    // Démo : met en gras le premier segment et souligne « vendredi ».
    final firstStop = t.indexOf('.');
    for (var i = 0; i < (firstStop < 0 ? 0 : firstStop); i++) {
      attrs[i].add(RtAttr.bold);
    }
    final v = t.indexOf('vendredi');
    if (v >= 0) {
      for (var i = v; i < v + 8; i++) {
        attrs[i].add(RtAttr.highlight);
      }
    }
    return RichTextController(text: t, attrs: attrs);
  }();

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _bullet(String mark) {
    final v = _ctrl.value;
    final pos = v.selection.isValid ? v.selection.start : v.text.length;
    final start = v.text.lastIndexOf('\n', pos == 0 ? 0 : pos - 1) + 1;
    _ctrl.value = TextEditingValue(text: v.text.replaceRange(start, start, mark), selection: TextSelection.collapsed(offset: pos + mark.length));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    Widget tool(IconData icon, String tip, RtAttr a) {
      final on = _ctrl.isActive(a);
      return IconButton(
        tooltip: tip,
        iconSize: 20,
        isSelected: on,
        style: IconButton.styleFrom(backgroundColor: on ? c.primaryLight : null, foregroundColor: on ? c.primary : c.textSecondary),
        onPressed: () => _ctrl.toggle(a),
        icon: Icon(icon),
      );
    }

    final chars = _ctrl.text.length;
    return Container(
      decoration: BoxDecoration(color: c.card, borderRadius: Radii.rm, border: Border.all(color: c.border)),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          color: c.hover.withValues(alpha: 0.5),
          height: 48,
          child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: Space.s1, vertical: Space.s1), children: [
            tool(Icons.format_bold, 'Gras', RtAttr.bold),
            tool(Icons.format_italic, 'Italique', RtAttr.italic),
            tool(Icons.format_underline, 'Souligné', RtAttr.underline),
            tool(Icons.strikethrough_s, 'Barré', RtAttr.strike),
            tool(Icons.format_color_fill, 'Surligner', RtAttr.highlight),
            const VerticalDivider(width: 12, indent: 8, endIndent: 8),
            IconButton(tooltip: 'Liste à puces', iconSize: 20, onPressed: () => _bullet('• '), icon: const Icon(Icons.format_list_bulleted)),
            IconButton(tooltip: 'Liste numérotée', iconSize: 20, onPressed: () => _bullet('1. '), icon: const Icon(Icons.format_list_numbered)),
            IconButton(tooltip: 'Effacer la mise en forme', iconSize: 20, onPressed: _ctrl.clearFormatting, icon: const Icon(Icons.format_clear)),
          ]),
        ),
        const Divider(height: 1),
        TextField(
          controller: _ctrl,
          maxLines: null,
          minLines: widget.minLines,
          style: TextStyle(fontSize: 14, height: 1.55, color: c.textPrimary),
          decoration: const InputDecoration(
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.all(Space.s4),
            hintText: 'Rédigez votre message…',
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(Space.s4, 0, Space.s4, Space.s2),
          child: Text('$chars caractère(s)', textAlign: TextAlign.right, style: TextStyle(fontSize: 11.5, color: c.textMuted)),
        ),
      ]),
    );
  }
}
