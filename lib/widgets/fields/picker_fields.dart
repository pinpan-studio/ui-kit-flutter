import 'package:flutter/material.dart';

import '../../data/showcase_data.dart';
import '../../theme/kit_colors.dart';
import '../../theme/tokens.dart';
import '../common.dart';

// ═══════════════════════════════════════════════════════════════════
// Sélecteurs riches : couleur (HSV), arborescence à cases, liste de transfert.
// ═══════════════════════════════════════════════════════════════════

const kColorPresets = [
  Color(0xFF4F6BED), Color(0xFF3B82F6), Color(0xFF06B6D4), Color(0xFF10B981), Color(0xFF22C55E), Color(0xFF84CC16), Color(0xFFEAB308), Color(0xFFF59E0B),
  Color(0xFFF97316), Color(0xFFEF4444), Color(0xFFEC4899), Color(0xFFA855F7), Color(0xFF8B5CF6), Color(0xFF64748B), Color(0xFF334155), Color(0xFF0F172A),
];

String colorHex(Color c) => '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

Color? parseHex(String s) {
  final h = s.replaceAll('#', '').trim();
  if (!RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(h)) return null;
  return Color(0xFF000000 | int.parse(h, radix: 16));
}

Color contrastOn(Color c) => (c.r * 255 * 0.299 + c.g * 255 * 0.587 + c.b * 255 * 0.114) > 150 ? const Color(0xFF0F172A) : Colors.white;

/// `<app-color-picker>` : carré saturation/valeur, barre de teinte, hexadécimal, pastilles.
class ColorPickerField extends StatefulWidget {
  const ColorPickerField({super.key, required this.value, required this.onChanged});
  final Color value;
  final ValueChanged<Color> onChanged;

  @override
  State<ColorPickerField> createState() => _ColorPickerFieldState();
}

class _ColorPickerFieldState extends State<ColorPickerField> {
  late HSVColor _hsv = HSVColor.fromColor(widget.value);
  late final _hex = TextEditingController(text: colorHex(widget.value));

  void _set(HSVColor h, {bool syncHex = true}) {
    setState(() => _hsv = h);
    if (syncHex) _hex.text = colorHex(h.toColor());
    widget.onChanged(h.toColor());
  }

  @override
  void dispose() {
    _hex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final col = _hsv.toColor();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
      LayoutBuilder(builder: (context, cons) {
        final w = cons.maxWidth;
        const h = 160.0;
        void pick(Offset p) => _set(_hsv.withSaturation((p.dx / w).clamp(0, 1)).withValue(1 - (p.dy / h).clamp(0, 1)));
        return GestureDetector(
          onPanDown: (d) => pick(d.localPosition),
          onPanUpdate: (d) => pick(d.localPosition),
          child: ClipRRect(
            borderRadius: Radii.rm,
            child: SizedBox(
              height: h,
              child: Stack(children: [
                Positioned.fill(child: ColoredBox(color: HSVColor.fromAHSV(1, _hsv.hue, 1, 1).toColor())),
                const Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.white, Color(0x00FFFFFF)])))),
                const Positioned.fill(
                  child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x00000000), Colors.black]))),
                ),
                Positioned(
                  left: _hsv.saturation * w - 10,
                  top: (1 - _hsv.value) * h - 10,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: col, border: Border.all(color: Colors.white, width: 3), boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 4)]),
                  ),
                ),
              ]),
            ),
          ),
        );
      }),
      const SizedBox(height: 12),
      LayoutBuilder(builder: (context, cons) {
        final w = cons.maxWidth;
        void pick(double x) => _set(_hsv.withHue((x / w).clamp(0, 1) * 359.9));
        return GestureDetector(
          onPanDown: (d) => pick(d.localPosition.dx),
          onPanUpdate: (d) => pick(d.localPosition.dx),
          child: SizedBox(
            height: 22,
            child: Stack(clipBehavior: Clip.none, children: [
              Positioned.fill(
                top: 4,
                bottom: 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: Radii.pill,
                    gradient: LinearGradient(colors: [for (var i = 0; i <= 6; i++) HSVColor.fromAHSV(1, i * 60.0 % 360, 1, 1).toColor()]),
                  ),
                ),
              ),
              Positioned(
                left: _hsv.hue / 360 * w - 11,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: HSVColor.fromAHSV(1, _hsv.hue, 1, 1).toColor(),
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 4)],
                  ),
                ),
              ),
            ]),
          ),
        );
      }),
      const SizedBox(height: 12),
      Row(children: [
        Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(15), border: Border.all(color: c.textPrimary.withValues(alpha: 0.15))),
          child: Text('Aa', style: TextStyle(fontWeight: FontWeight.w700, color: contrastOn(col))),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: _hex,
            style: const TextStyle(fontFamily: Fonts.mono),
            decoration: const InputDecoration(prefixIcon: Icon(Icons.tag, size: 18)),
            onChanged: (v) {
              final p = parseHex(v);
              if (p != null) _set(HSVColor.fromColor(p), syncHex: false);
            },
          ),
        ),
      ]),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final p in kColorPresets)
          GestureDetector(
            onTap: () => _set(HSVColor.fromColor(p)),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: p,
                shape: BoxShape.circle,
                border: Border.all(color: p.toARGB32() == col.toARGB32() ? c.textPrimary : Colors.transparent, width: 2),
              ),
              child: p.toARGB32() == col.toARGB32() ? Icon(Icons.check, size: 16, color: contrastOn(p)) : null,
            ),
          ),
      ]),
    ]);
  }
}

/// Arborescence à cases (`<app-tree-select>`) : sélection en cascade, état indéterminé, recherche.
class TreeSelect extends StatefulWidget {
  const TreeSelect({super.key, required this.nodes, required this.selected, required this.onChanged, this.searchable = true});
  final List<TreeNodeData> nodes;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;
  final bool searchable;

  @override
  State<TreeSelect> createState() => _TreeSelectState();
}

class _TreeSelectState extends State<TreeSelect> {
  final Set<String> _open = {};
  String _q = '';

  @override
  void initState() {
    super.initState();
    for (final n in widget.nodes) {
      _open.add(n.id);
    }
  }

  bool? _state(TreeNodeData n) {
    if (n.isLeaf) return widget.selected.contains(n.id);
    final leaves = n.leaves.map((e) => e.id).toList();
    final count = leaves.where(widget.selected.contains).length;
    if (count == 0) return false;
    if (count == leaves.length) return true;
    return null;
  }

  void _toggle(TreeNodeData n) {
    final next = {...widget.selected};
    final ids = n.leaves.map((e) => e.id);
    if (_state(n) == true) {
      next.removeAll(ids);
    } else {
      next.addAll(ids);
    }
    widget.onChanged(next);
  }

  bool _matches(TreeNodeData n) => _q.isEmpty || n.label.toLowerCase().contains(_q) || n.children.any(_matches);

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final labels = [for (final n in widget.nodes) ...n.leaves].where((l) => widget.selected.contains(l.id)).map((l) => l.label).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
      if (widget.searchable) ...[
        TextField(
          onChanged: (v) => setState(() => _q = v.trim().toLowerCase()),
          decoration: const InputDecoration(hintText: 'Filtrer…', prefixIcon: Icon(Icons.search, size: 20)),
        ),
        const SizedBox(height: 8),
      ],
      Container(
        decoration: BoxDecoration(borderRadius: Radii.rm, border: Border.all(color: c.border)),
        padding: const EdgeInsets.symmetric(vertical: Space.s1),
        child: Column(children: [for (final n in widget.nodes) if (_matches(n)) ..._build(c, n, 0)]),
      ),
      const SizedBox(height: 8),
      Text(
        labels.isEmpty ? 'Aucune zone sélectionnée' : '${labels.length} sélectionnée(s) : ${labels.take(4).join(', ')}${labels.length > 4 ? '…' : ''}',
        style: TextStyle(fontSize: 12, color: c.textMuted),
      ),
    ]);
  }

  List<Widget> _build(KitColors c, TreeNodeData n, int depth) {
    final open = _open.contains(n.id) || _q.isNotEmpty;
    return [
      InkWell(
        onTap: () => n.isLeaf ? _toggle(n) : setState(() => open ? _open.remove(n.id) : _open.add(n.id)),
        child: Padding(
          padding: EdgeInsets.only(left: Space.s1 + depth * 22, right: Space.s2),
          child: Row(children: [
            SizedBox(
              width: 32,
              child: n.isLeaf ? null : Icon(open ? Icons.expand_more : Icons.chevron_right, size: 20, color: c.textSecondary),
            ),
            Checkbox(tristate: !n.isLeaf, value: _state(n), onChanged: (_) => _toggle(n), visualDensity: VisualDensity.compact),
            if (n.icon != null) ...[Icon(n.icon, size: 18, color: c.textSecondary), const SizedBox(width: 6)],
            Expanded(child: Text(n.label, style: TextStyle(fontSize: 13.5, fontWeight: n.isLeaf ? FontWeight.w400 : FontWeight.w600, color: c.textPrimary))),
            if (!n.isLeaf) Text('${n.leaves.length}', style: TextStyle(fontSize: 11.5, color: c.textMuted)),
          ]),
        ),
      ),
      if (open && !n.isLeaf) for (final ch in n.children) if (_matches(ch)) ..._build(c, ch, depth + 1),
    ];
  }
}

/// Liste de transfert (`<app-transfer-list>`) : deux listes, sélection, déplacement, recherche.
/// Sur téléphone, les listes s'empilent avec les boutons de transfert entre elles.
class TransferList extends StatefulWidget {
  const TransferList({super.key, required this.available, required this.chosen, required this.onChanged, this.leftTitle = 'Disponibles', this.rightTitle = 'Sélectionnés'});
  final List<String> available, chosen;
  final void Function(List<String> available, List<String> chosen) onChanged;
  final String leftTitle, rightTitle;

  @override
  State<TransferList> createState() => _TransferListState();
}

class _TransferListState extends State<TransferList> {
  final Set<String> _selL = {}, _selR = {};
  String _qL = '', _qR = '';

  void _move(bool toRight, {bool all = false}) {
    final from = toRight ? widget.available : widget.chosen;
    final sel = toRight ? _selL : _selR;
    final moving = all ? from.toList() : from.where(sel.contains).toList();
    if (moving.isEmpty) return;
    final a = toRight ? (widget.available.toList()..removeWhere(moving.contains)) : [...widget.available, ...moving];
    final b = toRight ? [...widget.chosen, ...moving] : (widget.chosen.toList()..removeWhere(moving.contains));
    sel.clear();
    widget.onChanged(a, b);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final wide = MediaQuery.sizeOf(context).width >= Breakpoints.tablet;
    final left = _panel(c, widget.leftTitle, widget.available, _selL, _qL, (v) => setState(() => _qL = v));
    final right = _panel(c, widget.rightTitle, widget.chosen, _selR, _qR, (v) => setState(() => _qR = v));
    final buttons = Flex(
      direction: wide ? Axis.vertical : Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.outlined(tooltip: 'Tout ajouter', onPressed: () => _move(true, all: true), icon: Icon(wide ? Icons.keyboard_double_arrow_right : Icons.keyboard_double_arrow_down)),
        IconButton.filledTonal(tooltip: 'Ajouter la sélection', onPressed: _selL.isEmpty ? null : () => _move(true), icon: Icon(wide ? Icons.chevron_right : Icons.expand_more)),
        IconButton.filledTonal(tooltip: 'Retirer la sélection', onPressed: _selR.isEmpty ? null : () => _move(false), icon: Icon(wide ? Icons.chevron_left : Icons.expand_less)),
        IconButton.outlined(tooltip: 'Tout retirer', onPressed: () => _move(false, all: true), icon: Icon(wide ? Icons.keyboard_double_arrow_left : Icons.keyboard_double_arrow_up)),
      ],
    );
    if (wide) {
      return IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Expanded(child: left), Padding(padding: const EdgeInsets.all(Space.s2), child: buttons), Expanded(child: right)]));
    }
    return Column(children: [left, Padding(padding: const EdgeInsets.symmetric(vertical: Space.s2), child: buttons), right]);
  }

  Widget _panel(KitColors c, String title, List<String> items, Set<String> sel, String q, ValueChanged<String> onQ) {
    final shown = items.where((e) => q.isEmpty || e.toLowerCase().contains(q.toLowerCase())).toList();
    return Container(
      decoration: BoxDecoration(color: c.card, borderRadius: Radii.rm, border: Border.all(color: c.border)),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Space.s3, Space.s3, Space.s3, Space.s2),
          child: Row(children: [
            Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: c.textPrimary))),
            Text('${sel.length}/${items.length}', style: TextStyle(fontSize: 12, color: c.textMuted)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.s2),
          child: TextField(onChanged: onQ, decoration: const InputDecoration(hintText: 'Rechercher…', prefixIcon: Icon(Icons.search, size: 18))),
        ),
        SizedBox(
          height: 180,
          child: shown.isEmpty
              ? Center(child: Text('Aucun élément', style: TextStyle(color: c.textMuted, fontSize: 12.5)))
              : ListView(padding: const EdgeInsets.symmetric(vertical: Space.s1), children: [
                  for (final e in shown)
                    CheckboxListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      value: sel.contains(e),
                      onChanged: (v) => setState(() => v! ? sel.add(e) : sel.remove(e)),
                      title: Text(e),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                ]),
        ),
      ]),
    );
  }
}

/// Puce de sélection compacte pour afficher la couleur choisie.
class ColorChipLabel extends StatelessWidget {
  const ColorChipLabel(this.color, {super.key});
  final Color color;

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 14, height: 14, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(colorHex(color), style: const TextStyle(fontFamily: Fonts.mono, fontSize: 12)),
        const SizedBox(width: 8),
        StatusBadge('Aperçu', tone: KitTone.neutral, icon: Icons.palette_outlined, uppercase: false),
      ]);
}
