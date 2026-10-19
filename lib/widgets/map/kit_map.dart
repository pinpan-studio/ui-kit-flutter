import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../theme/kit_colors.dart';
import '../../theme/tokens.dart';
import 'map_models.dart';

/// Outils de dessin (équivalent Leaflet Draw / Geoman).
enum DrawTool { none, marker, line, polygon }

/// Forme dessinée par l'utilisateur.
class DrawnShape {
  DrawnShape(this.tool, this.points);
  final DrawTool tool;
  final List<LatLng> points;

  String get label => switch (tool) {
        DrawTool.marker => 'Point',
        DrawTool.line => 'Tracé · ${_km(points).toStringAsFixed(2)} km',
        DrawTool.polygon => 'Zone · ${points.length} sommets',
        DrawTool.none => '',
      };

  static double _km(List<LatLng> p) {
    const d = Distance();
    var t = 0.0;
    for (var i = 1; i < p.length; i++) {
      t += d.as(LengthUnit.Meter, p[i - 1], p[i]);
    }
    return t / 1000;
  }
}

/// `<app-map>` mobile (flutter_map) : fonds gratuits sans clé, marqueurs « flat »,
/// clustering, trajets, zones, dessin, contrôles et popups qui suivent le thème.
class KitMap extends StatefulWidget {
  const KitMap({
    super.key,
    this.height = 320,
    this.center = const LatLng(5.33, -4.01),
    this.zoom = 12,
    this.markers = const [],
    this.routes = const [],
    this.zones = const [],
    this.basemap,
    this.cluster = false,
    this.showBasemapSwitcher = true,
    this.showZoom = true,
    this.fitToContent = false,
    this.drawTools = const [],
    this.onShapesChanged,
    this.onTap,
    this.legend = const [],
    this.interactive = true,
    this.radius = Radii.l,
    this.selectedId,
    this.onMarkerTap,
    this.overlay,
  });

  final double height;
  final LatLng center;
  final double zoom;
  final List<MapMarkerData> markers;
  final List<MapRouteData> routes;
  final List<MapZoneData> zones;

  /// Fond imposé ; sinon gris clair / gris foncé selon le thème.
  final Basemap? basemap;
  final bool cluster, showBasemapSwitcher, showZoom, fitToContent, interactive;
  final List<DrawTool> drawTools;
  final ValueChanged<List<DrawnShape>>? onShapesChanged;
  final ValueChanged<LatLng>? onTap;
  final List<(String, KitTone)> legend;
  final double radius;
  final String? selectedId;
  final ValueChanged<MapMarkerData>? onMarkerTap;
  final Widget? overlay;

  @override
  State<KitMap> createState() => KitMapState();
}

class KitMapState extends State<KitMap> {
  final _map = MapController();
  Basemap? _basemap;
  MapMarkerData? _popup;
  double _zoom = 12;
  DrawTool _tool = DrawTool.none;
  final List<DrawnShape> _shapes = [];
  final List<LatLng> _draft = [];

  @override
  void initState() {
    super.initState();
    _basemap = widget.basemap;
    _zoom = widget.zoom;
  }

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  Basemap _effective(BuildContext context) => _basemap ?? (context.isDark ? Basemap.canvasDark : Basemap.canvasLight);

  List<LatLng> get _allPoints => [
        ...widget.markers.map((m) => m.point),
        for (final r in widget.routes) ...r.points,
        for (final z in widget.zones) ...?z.polygon,
        for (final z in widget.zones) ?z.center,
      ];

  void fit() {
    final pts = _allPoints;
    if (pts.length < 2) {
      _map.move(widget.center, widget.zoom);
      return;
    }
    _map.fitCamera(CameraFit.bounds(bounds: LatLngBounds.fromPoints(pts), padding: const EdgeInsets.all(Space.s12)));
  }

  void flyTo(LatLng p, [double zoom = 15]) => _map.move(p, zoom);

  void _onMapTap(TapPosition _, LatLng p) {
    if (_tool != DrawTool.none) {
      setState(() {
        if (_tool == DrawTool.marker) {
          _shapes.add(DrawnShape(DrawTool.marker, [p]));
          widget.onShapesChanged?.call(List.of(_shapes));
        } else {
          _draft.add(p);
        }
      });
      return;
    }
    setState(() => _popup = null);
    widget.onTap?.call(p);
  }

  void _finishDraft() {
    final min = _tool == DrawTool.polygon ? 3 : 2;
    if (_draft.length >= min) {
      _shapes.add(DrawnShape(_tool, List.of(_draft)));
      widget.onShapesChanged?.call(List.of(_shapes));
    }
    setState(_draft.clear);
  }

  // ── Clustering par grille (dépend du zoom) ───────────────────────────
  List<(LatLng, List<MapMarkerData>)> _clusters() {
    if (!widget.cluster || _zoom >= 15) return [for (final m in widget.markers) (m.point, [m])];
    final cell = 360 / math.pow(2, _zoom) * 0.9; // ~60 px à l'écran
    final buckets = <String, List<MapMarkerData>>{};
    for (final m in widget.markers) {
      final k = '${(m.point.latitude / cell).floor()}:${(m.point.longitude / cell).floor()}';
      (buckets[k] ??= []).add(m);
    }
    return [
      for (final b in buckets.values)
        (
          LatLng(b.map((m) => m.point.latitude).reduce((a, x) => a + x) / b.length, b.map((m) => m.point.longitude).reduce((a, x) => a + x) / b.length),
          b,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final bm = _effective(context);
    final clusters = _clusters();
    final draftColor = c.primary;

    return SizedBox(
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
        child: Stack(children: [
          FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCenter: widget.center,
              initialZoom: widget.zoom,
              minZoom: 3,
              maxZoom: 18,
              backgroundColor: c.hover,
              onTap: _onMapTap,
              onMapReady: () {
                if (widget.fitToContent) WidgetsBinding.instance.addPostFrameCallback((_) => fit());
              },
              onPositionChanged: (cam, _) {
                if ((cam.zoom - _zoom).abs() > 0.25 && widget.cluster) {
                  setState(() => _zoom = cam.zoom);
                } else {
                  _zoom = cam.zoom;
                }
              },
              interactionOptions: InteractionOptions(
                flags: widget.interactive ? InteractiveFlag.all & ~InteractiveFlag.rotate : InteractiveFlag.none,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: bm.url,
                userAgentPackageName: 'com.lookas.ui_kit_flutter',
                maxNativeZoom: bm.maxZoom,
              ),
              if (widget.zones.any((z) => z.polygon != null))
                PolygonLayer(polygons: [
                  for (final z in widget.zones.where((z) => z.polygon != null))
                    Polygon(
                      points: z.polygon!,
                      color: z.tone.color(c).withValues(alpha: 0.16),
                      borderColor: z.tone.color(c),
                      borderStrokeWidth: 2,
                      label: z.label,
                      labelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: z.tone.text(c)),
                    ),
                ]),
              if (widget.zones.any((z) => z.center != null))
                CircleLayer(circles: [
                  for (final z in widget.zones.where((z) => z.center != null))
                    CircleMarker(
                      point: z.center!,
                      radius: z.radius ?? 500,
                      useRadiusInMeter: true,
                      color: z.tone.color(c).withValues(alpha: 0.16),
                      borderColor: z.tone.color(c),
                      borderStrokeWidth: 2,
                    ),
                ]),
              if (widget.routes.isNotEmpty)
                PolylineLayer(polylines: [
                  for (final r in widget.routes) ...[
                    if (!r.dashed) Polyline(points: r.points, color: Colors.white.withValues(alpha: context.isDark ? 0.15 : 0.9), strokeWidth: 8),
                    Polyline(
                      points: r.points,
                      color: r.tone.color(c),
                      strokeWidth: 4.5,
                      pattern: r.dashed ? StrokePattern.dashed(segments: [10, 8]) : const StrokePattern.solid(),
                    ),
                  ],
                ]),
              // Formes dessinées + brouillon.
              PolygonLayer(polygons: [
                for (final s in _shapes.where((s) => s.tool == DrawTool.polygon))
                  Polygon(points: s.points, color: draftColor.withValues(alpha: 0.18), borderColor: draftColor, borderStrokeWidth: 2.5),
                if (_tool == DrawTool.polygon && _draft.length >= 3)
                  Polygon(points: _draft, color: draftColor.withValues(alpha: 0.10), borderColor: draftColor, borderStrokeWidth: 2, pattern: StrokePattern.dashed(segments: [8, 6])),
              ]),
              PolylineLayer(polylines: [
                for (final s in _shapes.where((s) => s.tool == DrawTool.line)) Polyline(points: s.points, color: draftColor, strokeWidth: 4),
                if ((_draft.length >= 2 && _tool != DrawTool.polygon) || _draft.length == 2)
                  Polyline(points: _draft, color: draftColor, strokeWidth: 3, pattern: StrokePattern.dashed(segments: [8, 6])),
              ]),
              MarkerLayer(markers: [
                for (final p in _draft)
                  Marker(
                    point: p,
                    width: 14,
                    height: 14,
                    child: Container(decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: draftColor, width: 3))),
                  ),
                for (final s in _shapes.where((s) => s.tool == DrawTool.marker))
                  Marker(point: s.points.first, width: 34, height: 34, child: _Pin(color: draftColor, icon: Icons.place)),
                for (final r in widget.routes.where((r) => r.endpoints)) ...[
                  Marker(point: r.points.first, width: 26, height: 26, child: _Endpoint(color: c.success, icon: Icons.play_arrow)),
                  Marker(point: r.points.last, width: 26, height: 26, child: _Endpoint(color: c.error, icon: Icons.flag)),
                ],
                for (final (pt, group) in clusters)
                  group.length == 1
                      ? Marker(
                          point: pt,
                          width: 44,
                          height: 44,
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _popup = group.first);
                              widget.onMarkerTap?.call(group.first);
                            },
                            child: FlatMarker(data: group.first, selected: group.first.id == (widget.selectedId ?? _popup?.id)),
                          ),
                        )
                      : Marker(
                          point: pt,
                          width: 52,
                          height: 52,
                          child: GestureDetector(
                            onTap: () => _map.move(pt, math.min(_zoom + 2, 16)),
                            child: _ClusterBubble(group: group),
                          ),
                        ),
              ]),
              SimpleAttributionWidget(source: Text(bm.attribution), backgroundColor: c.card.withValues(alpha: 0.8)),
            ],
          ),
          ?widget.overlay,
          // Contrôles (zoom, recentrer, fonds).
          Positioned(
            right: 10,
            top: 10,
            child: Column(children: [
              if (widget.showZoom)
                _ControlGroup(children: [
                  _CtlBtn(icon: Icons.add, tip: 'Zoom avant', onTap: () => _map.move(_map.camera.center, _map.camera.zoom + 1)),
                  _CtlBtn(icon: Icons.remove, tip: 'Zoom arrière', onTap: () => _map.move(_map.camera.center, _map.camera.zoom - 1)),
                ]),
              const SizedBox(height: 8),
              _ControlGroup(children: [_CtlBtn(icon: Icons.center_focus_strong, tip: 'Recentrer', onTap: fit)]),
              if (widget.showBasemapSwitcher) ...[
                const SizedBox(height: 8),
                _ControlGroup(children: [
                  PopupMenuButton<Basemap>(
                    tooltip: 'Fond de carte',
                    onSelected: (b) => setState(() => _basemap = b),
                    itemBuilder: (_) => [
                      for (final b in Basemap.values)
                        CheckedPopupMenuItem(value: b, checked: b == bm, child: Row(children: [Icon(b.icon, size: 18), const SizedBox(width: 10), Text(b.label)])),
                    ],
                    child: SizedBox(width: 38, height: 38, child: Icon(Icons.layers_outlined, size: 20, color: c.textPrimary)),
                  ),
                ]),
              ],
            ]),
          ),
          // Outils de dessin.
          if (widget.drawTools.isNotEmpty)
            Positioned(
              left: 10,
              top: 10,
              child: _ControlGroup(children: [
                for (final t in widget.drawTools)
                  _CtlBtn(
                    icon: switch (t) { DrawTool.marker => Icons.add_location_alt_outlined, DrawTool.line => Icons.timeline, DrawTool.polygon => Icons.pentagon_outlined, DrawTool.none => Icons.pan_tool },
                    tip: switch (t) { DrawTool.marker => 'Placer un point', DrawTool.line => 'Tracer une ligne', DrawTool.polygon => 'Dessiner une zone', DrawTool.none => '' },
                    active: _tool == t,
                    onTap: () => setState(() {
                      _draft.clear();
                      _tool = _tool == t ? DrawTool.none : t;
                    }),
                  ),
                _CtlBtn(
                  icon: Icons.delete_sweep_outlined,
                  tip: 'Tout effacer',
                  onTap: () => setState(() {
                    _shapes.clear();
                    _draft.clear();
                    widget.onShapesChanged?.call(const []);
                  }),
                ),
              ]),
            ),
          if (_tool == DrawTool.line || _tool == DrawTool.polygon || _tool == DrawTool.marker)
            Positioned(
              left: 10,
              right: 60,
              bottom: 28,
              child: Material(
                color: c.card,
                elevation: 3,
                borderRadius: Radii.rm,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(Space.s3, Space.s2, Space.s2, Space.s2),
                  child: Row(children: [
                    Icon(Icons.touch_app, size: 18, color: c.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _tool == DrawTool.marker ? 'Touchez la carte pour placer un point' : 'Touchez la carte pour ajouter des sommets (${_draft.length})',
                        style: TextStyle(fontSize: 12, color: c.textPrimary),
                      ),
                    ),
                    if (_tool != DrawTool.marker) ...[
                      IconButton(visualDensity: VisualDensity.compact, tooltip: 'Annuler le dernier', onPressed: _draft.isEmpty ? null : () => setState(_draft.removeLast), icon: const Icon(Icons.undo, size: 18)),
                      FilledButton(style: FilledButton.styleFrom(minimumSize: const Size(0, 32), padding: const EdgeInsets.symmetric(horizontal: Space.s3)), onPressed: _finishDraft, child: const Text('Terminer')),
                    ] else
                      TextButton(onPressed: () => setState(() => _tool = DrawTool.none), child: const Text('OK')),
                  ]),
                ),
              ),
            ),
          if (widget.legend.isNotEmpty)
            Positioned(
              left: 10,
              bottom: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: Space.s3, vertical: Space.s2),
                decoration: BoxDecoration(color: c.card.withValues(alpha: 0.94), borderRadius: Radii.rm, border: Border.all(color: c.border)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  for (final (l, t) in widget.legend)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: Space.s0_5),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(width: 10, height: 10, decoration: BoxDecoration(color: t.color(c), shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text(l, style: TextStyle(fontSize: 11.5, color: c.textPrimary)),
                      ]),
                    ),
                ]),
              ),
            ),
          // Popup du marqueur sélectionné (carte flottante en bas, adaptée au doigt).
          if (_popup != null && widget.onMarkerTap == null)
            Positioned(
              left: 10,
              right: 10,
              bottom: 24,
              child: _MarkerPopup(data: _popup!, onClose: () => setState(() => _popup = null)),
            ),
        ]),
      ),
    );
  }
}

/// Marqueur « flat » : disque teinté, icône blanche, halo pulsé, flèche de cap.
class FlatMarker extends StatefulWidget {
  const FlatMarker({super.key, required this.data, this.selected = false});
  final MapMarkerData data;
  final bool selected;

  @override
  State<FlatMarker> createState() => _FlatMarkerState();
}

class _FlatMarkerState extends State<FlatMarker> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
    if (widget.data.pulse) _ctrl.repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final col = widget.data.tone.color(c);
    final size = widget.selected ? 34.0 : 28.0;
    return Stack(alignment: Alignment.center, children: [
      if (widget.data.pulse)
        AnimatedBuilder(
          animation: _ctrl,
          builder: (_, _) => Container(
            width: 28 + 16 * _ctrl.value,
            height: 28 + 16 * _ctrl.value,
            decoration: BoxDecoration(shape: BoxShape.circle, color: col.withValues(alpha: 0.35 * (1 - _ctrl.value))),
          ),
        ),
      if (widget.data.heading != null)
        Transform.rotate(
          angle: widget.data.heading! * math.pi / 180,
          child: SizedBox(width: 44, height: 44, child: Align(alignment: Alignment.topCenter, child: Icon(Icons.navigation, size: 12, color: col))),
        ),
      AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: col,
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 6, offset: Offset(0, 2))],
        ),
        child: Icon(widget.data.icon, size: size * 0.52, color: Colors.white),
      ),
    ]);
  }
}

class _Pin extends StatelessWidget {
  const _Pin({required this.color, required this.icon});
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Icon(icon, size: 34, color: color, shadows: const [Shadow(color: Colors.black38, blurRadius: 4)]);
}

class _Endpoint extends StatelessWidget {
  const _Endpoint({required this.color, required this.icon});
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(shape: BoxShape.circle, color: color, border: Border.all(color: Colors.white, width: 2)),
        child: Icon(icon, size: 14, color: Colors.white),
      );
}

class _ClusterBubble extends StatelessWidget {
  const _ClusterBubble({required this.group});
  final List<MapMarkerData> group;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final hasError = group.any((m) => m.tone == KitTone.error);
    final hasWarn = group.any((m) => m.tone == KitTone.warning);
    final col = hasError ? c.error : (hasWarn ? c.warning : c.primary);
    final size = group.length > 100 ? 52.0 : group.length > 20 ? 44.0 : 36.0;
    return Center(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: col.withValues(alpha: 0.9),
          border: Border.all(color: col.withValues(alpha: 0.3), width: 6, strokeAlign: BorderSide.strokeAlignOutside),
        ),
        child: Text('${group.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
      ),
    );
  }
}

class _MarkerPopup extends StatelessWidget {
  const _MarkerPopup({required this.data, required this.onClose});
  final MapMarkerData data;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return Material(
      color: c.card,
      elevation: 4,
      borderRadius: Radii.rm,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Space.s3, Space.s3, Space.s1, Space.s3),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(shape: BoxShape.circle, color: data.tone.light(c)),
            child: Icon(data.icon, size: 18, color: data.tone.color(c)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(data.title ?? data.id, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: c.textPrimary)),
              for (final l in data.lines) Text(l, style: TextStyle(fontSize: 12, color: c.textSecondary)),
            ]),
          ),
          IconButton(onPressed: onClose, icon: const Icon(Icons.close, size: 18)),
        ]),
      ),
    );
  }
}

class _ControlGroup extends StatelessWidget {
  const _ControlGroup({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return Material(
      color: c.card,
      elevation: 2,
      borderRadius: Radii.rm,
      clipBehavior: Clip.antiAlias,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        for (var i = 0; i < children.length; i++) ...[if (i > 0) Divider(height: 1, color: c.border), children[i]],
      ]),
    );
  }
}

class _CtlBtn extends StatelessWidget {
  const _CtlBtn({required this.icon, required this.tip, required this.onTap, this.active = false});
  final IconData icon;
  final String tip;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return Tooltip(
      message: tip,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          color: active ? c.primaryLight : null,
          child: Icon(icon, size: 20, color: active ? c.primary : c.textPrimary),
        ),
      ),
    );
  }
}

/// Aperçu statique (vignette non interactive) avec état de chargement / erreur.
class MapStatePlaceholder extends StatelessWidget {
  const MapStatePlaceholder({super.key, required this.kind, this.height = 200});
  final String kind; // loading | empty | error
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final (icon, title, sub, tone) = switch (kind) {
      'loading' => (Icons.map_outlined, 'Chargement de la carte…', 'Récupération des positions', KitTone.primary),
      'error' => (Icons.wifi_off, 'Carte indisponible', 'Les tuiles n’ont pas pu être chargées.', KitTone.error),
      _ => (Icons.location_off_outlined, 'Aucune position', 'Aucun véhicule ne correspond aux filtres.', KitTone.neutral),
    };
    return Container(
      height: height,
      decoration: BoxDecoration(color: c.hover, borderRadius: Radii.rl, border: Border.all(color: c.border)),
      child: Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _GridPainter(c.border))),
        Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (kind == 'loading')
              SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 3, color: c.primary))
            else
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(shape: BoxShape.circle, color: tone.light(c)),
                child: Icon(icon, color: tone.color(c)),
              ),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: c.textPrimary)),
            Text(sub, style: TextStyle(fontSize: 12, color: c.textSecondary)),
          ]),
        ),
      ]),
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (var y = 0.0; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.color != color;
}
