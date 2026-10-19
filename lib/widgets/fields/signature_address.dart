import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../../theme/kit_colors.dart';
import '../../theme/tokens.dart';
import '../map/kit_map.dart';
import '../map/map_models.dart';

// ═══════════════════════════════════════════════════════════════════
// Signature manuscrite et adresse avec carte.
// ═══════════════════════════════════════════════════════════════════

/// `<app-signature-pad>` : tracé lissé au doigt, couleur, épaisseur, annuler, effacer.
class SignaturePad extends StatefulWidget {
  const SignaturePad({super.key, this.height = 180, this.onChanged});
  final double height;
  final ValueChanged<bool>? onChanged;

  @override
  State<SignaturePad> createState() => SignaturePadState();
}

class _Stroke {
  _Stroke(this.color, this.width);
  final Color color;
  final double width;
  final List<Offset> points = [];
}

class SignaturePadState extends State<SignaturePad> {
  final List<_Stroke> _strokes = [];
  Color? _color;
  double _width = 2.6;

  bool get isEmpty => _strokes.isEmpty;

  void clear() {
    setState(_strokes.clear);
    widget.onChanged?.call(false);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final ink = _color ?? c.textPrimary;
    final colors = [c.textPrimary, const Color(0xFF1D4ED8), c.primary];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
      Container(
        height: widget.height,
        decoration: BoxDecoration(color: c.card, borderRadius: Radii.rm, border: Border.all(color: c.border)),
        child: ClipRRect(
          borderRadius: Radii.rm,
          child: Stack(children: [
            Positioned(
              left: 24,
              right: 24,
              bottom: 40,
              child: Row(children: [
                Text('✕', style: TextStyle(color: c.textMuted, fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(child: Container(height: 1, color: c.textMuted.withValues(alpha: 0.5))),
              ]),
            ),
            if (_strokes.isEmpty)
              Center(child: Text('Signez ici avec le doigt', style: TextStyle(color: c.textMuted, fontStyle: FontStyle.italic))),
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (d) {
                  setState(() => _strokes.add(_Stroke(ink, _width)..points.add(d.localPosition)));
                  widget.onChanged?.call(true);
                },
                onPanUpdate: (d) => setState(() => _strokes.last.points.add(d.localPosition)),
                child: CustomPaint(painter: _SignaturePainter(_strokes)),
              ),
            ),
          ]),
        ),
      ),
      const SizedBox(height: 8),
      Row(children: [
        for (final col in colors)
          GestureDetector(
            onTap: () => setState(() => _color = col),
            child: Container(
              margin: const EdgeInsets.only(right: Space.s2),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: col,
                shape: BoxShape.circle,
                border: Border.all(color: ink == col ? c.primary : c.border, width: ink == col ? 2.5 : 1),
              ),
            ),
          ),
        const SizedBox(width: 6),
        Expanded(
          child: Slider(value: _width, min: 1.5, max: 6, onChanged: (v) => setState(() => _width = v)),
        ),
        IconButton(tooltip: 'Annuler', onPressed: _strokes.isEmpty ? null : () => setState(_strokes.removeLast), icon: const Icon(Icons.undo)),
        IconButton(tooltip: 'Effacer', onPressed: _strokes.isEmpty ? null : clear, icon: const Icon(Icons.delete_outline)),
      ]),
    ]);
  }
}

class _SignaturePainter extends CustomPainter {
  _SignaturePainter(this.strokes);
  final List<_Stroke> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in strokes) {
      final p = Paint()
        ..color = s.color
        ..strokeWidth = s.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      if (s.points.length == 1) {
        canvas.drawCircle(s.points.first, s.width / 2, p..style = PaintingStyle.fill);
        continue;
      }
      // Lissage quadratique par points milieux.
      final path = Path()..moveTo(s.points.first.dx, s.points.first.dy);
      for (var i = 1; i < s.points.length - 1; i++) {
        final mid = (s.points[i] + s.points[i + 1]) / 2;
        path.quadraticBezierTo(s.points[i].dx, s.points[i].dy, mid.dx, mid.dy);
      }
      path.lineTo(s.points.last.dx, s.points.last.dy);
      canvas.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(_SignaturePainter old) => true;
}

/// Adresse du répertoire statique (aucun géocodage distant).
class PlaceOption {
  const PlaceOption(this.id, this.label, this.detail, this.city, this.point, this.kind);
  final String id, label, detail, city, kind;
  final LatLng point;

  IconData get icon => switch (kind) { 'poi' => Icons.place, 'area' => Icons.location_city, _ => Icons.signpost_outlined };
}

const kDemoPlaces = [
  PlaceOption('a1', 'Boulevard de la République', 'Plateau, Abidjan', 'Abidjan', LatLng(5.3237, -4.0193), 'road'),
  PlaceOption('a2', 'Riviera 2, rue des Jardins', 'Cocody, Abidjan', 'Abidjan', LatLng(5.3600, -3.9900), 'road'),
  PlaceOption('a3', 'Carrefour Selmer', 'Yopougon, Abidjan', 'Abidjan', LatLng(5.3450, -4.0800), 'poi'),
  PlaceOption('a4', 'Zone 4, rue du Docteur Blanchard', 'Marcory, Abidjan', 'Abidjan', LatLng(5.3030, -3.9850), 'road'),
  PlaceOption('a5', 'Port autonome d’Abidjan', 'Treichville, Abidjan', 'Abidjan', LatLng(5.2930, -4.0050), 'poi'),
  PlaceOption('a6', 'Gare routière d’Abobo', 'Abobo, Abidjan', 'Abidjan', LatLng(5.4180, -4.0200), 'poi'),
  PlaceOption('a7', 'Aéroport Félix-Houphouët-Boigny', 'Port-Bouët, Abidjan', 'Abidjan', LatLng(5.2550, -3.9300), 'poi'),
  PlaceOption('a8', 'Boulevard Valéry Giscard d’Estaing', 'Koumassi, Abidjan', 'Abidjan', LatLng(5.2970, -3.9480), 'road'),
  PlaceOption('a9', 'Angré 8e tranche', 'Cocody, Abidjan', 'Abidjan', LatLng(5.3980, -3.9870), 'area'),
  PlaceOption('a10', 'Avenue Houphouët-Boigny', 'Bouaké', 'Bouaké', LatLng(7.6906, -5.0306), 'road'),
  PlaceOption('a11', 'Basilique Notre-Dame de la Paix', 'Yamoussoukro', 'Yamoussoukro', LatLng(6.8115, -5.2970), 'poi'),
  PlaceOption('a12', 'Port de San-Pédro', 'San-Pédro', 'San-Pédro', LatLng(4.7485, -6.6363), 'poi'),
  PlaceOption('a13', 'Quartier Commerce', 'Korhogo', 'Korhogo', LatLng(9.4580, -5.6296), 'area'),
  PlaceOption('a14', 'Marché central', 'Daloa', 'Daloa', LatLng(6.8774, -6.4502), 'poi'),
  PlaceOption('a15', 'Plage d’Assinie Mafia', 'Assinie', 'Assinie', LatLng(5.1330, -3.2830), 'area'),
  PlaceOption('a16', 'Quartier France', 'Grand-Bassam', 'Grand-Bassam', LatLng(5.1980, -3.7380), 'area'),
];

String _fold(String s) {
  const from = 'àâäéèêëîïôöùûüçœ’';
  const to = 'aaaeeeeiioouuuco\'';
  final b = StringBuffer();
  for (final ch in s.toLowerCase().split('')) {
    final i = from.indexOf(ch);
    b.write(i >= 0 ? to[i] : ch);
  }
  return b.toString();
}

/// `<app-address-field>` : recherche locale insensible aux accents + carte ;
/// toucher la carte place l'épingle (adresse « Position personnalisée »).
class AddressField extends StatefulWidget {
  const AddressField({super.key, this.initial, this.onChanged, this.mapHeight = 200});
  final PlaceOption? initial;
  final ValueChanged<PlaceOption>? onChanged;
  final double mapHeight;

  @override
  State<AddressField> createState() => _AddressFieldState();
}

class _AddressFieldState extends State<AddressField> {
  late PlaceOption? _place = widget.initial;
  final _mapKey = GlobalKey<KitMapState>();

  void _select(PlaceOption p) {
    setState(() => _place = p);
    _mapKey.currentState?.flyTo(p.point, 15);
    widget.onChanged?.call(p);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final p = _place;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
      Autocomplete<PlaceOption>(
        displayStringForOption: (o) => '${o.label}, ${o.detail}',
        optionsBuilder: (v) {
          final q = _fold(v.text.trim());
          if (q.length < 2) return const Iterable.empty();
          return kDemoPlaces.where((o) => _fold('${o.label} ${o.detail}').contains(q)).take(6);
        },
        onSelected: _select,
        fieldViewBuilder: (context, ctrl, focus, _) => TextField(
          controller: ctrl,
          focusNode: focus,
          decoration: const InputDecoration(hintText: 'Rechercher une adresse (ex : Marcory)…', prefixIcon: Icon(Icons.search, size: 20)),
        ),
        optionsViewBuilder: (context, select, options) => Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 6,
            borderRadius: Radii.rm,
            color: Theme.of(context).colorScheme.surfaceContainer,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 260, maxWidth: MediaQuery.sizeOf(context).width - 64),
              child: ListView(shrinkWrap: true, padding: EdgeInsets.zero, children: [
                for (final o in options)
                  ListTile(dense: true, leading: Icon(o.icon, color: c.primary), title: Text(o.label), subtitle: Text(o.detail), onTap: () => select(o)),
              ]),
            ),
          ),
        ),
      ),
      const SizedBox(height: 10),
      KitMap(
        key: _mapKey,
        height: widget.mapHeight,
        radius: Radii.m,
        zoom: p == null ? 11 : 14,
        center: p?.point ?? const LatLng(5.33, -4.01),
        showBasemapSwitcher: false,
        markers: [if (p != null) MapMarkerData(id: 'pin', point: p.point, icon: Icons.place, tone: KitTone.primary, title: p.label, lines: [p.detail])],
        onTap: (pt) => _select(PlaceOption('custom', 'Position personnalisée', '${pt.latitude.toStringAsFixed(5)}, ${pt.longitude.toStringAsFixed(5)}', '', pt, 'poi')),
      ),
      const SizedBox(height: 8),
      if (p != null)
        Row(children: [
          Icon(p.icon, size: 18, color: c.primary),
          const SizedBox(width: 6),
          Expanded(child: Text('${p.label} — ${p.detail}', style: TextStyle(fontSize: 12.5, color: c.textPrimary, fontWeight: FontWeight.w600))),
          Text('${p.point.latitude.toStringAsFixed(4)}, ${p.point.longitude.toStringAsFixed(4)}', style: TextStyle(fontFamily: Fonts.mono, fontSize: 10.5, color: c.textMuted)),
        ])
      else
        Text('Recherchez une adresse ou touchez la carte.', style: TextStyle(fontSize: 12, color: c.textMuted)),
    ]);
  }
}
