import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../data/map_data.dart';
import '../../theme/kit_colors.dart';
import '../../theme/tokens.dart';
import '../../widgets/common.dart';
import '../../widgets/map/kit_map.dart';
import '../../widgets/map/map_models.dart';
import '../doc/doc.dart';

/// `/components/maps` — KitMap (flutter_map) : fonds gratuits, marqueurs, clustering,
/// trajets, zones, dessin, carte compacte, états.
class MapsGallery extends StatefulWidget {
  const MapsGallery({super.key, this.initialSection});
  final String? initialSection;

  @override
  State<MapsGallery> createState() => _MapsGalleryState();
}

class _MapsGalleryState extends State<MapsGallery> {
  Basemap _basemap = Basemap.streets;
  String? _selected;
  List<DrawnShape> _shapes = [];
  String _state = 'loading';
  final _fleetKey = GlobalKey<KitMapState>();

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return DocPage(
      title: 'Cartes',
      icon: Icons.map,
      initialSection: widget.initialSection,
      subtitle: 'Composant KitMap basé sur flutter_map : fonds de carte libres sans clé d’API (seules les tuiles sont téléchargées), marqueurs flat, clustering, trajets, zones, dessin au doigt. Contrôles et popups suivent le thème clair / sombre.',
      sections: [
        DocSection(
          id: 'basemaps',
          title: 'Fonds de carte',
          source: 'Basemap (Esri Canvas, Rues, Topo, Satellite, OpenStreetMap)',
          description: 'Par défaut, gris clair ou gris foncé selon le thème. Le bouton « calques » de la carte permet aussi de changer de fond.',
          children: [
            Demo(
              label: 'Sélecteur de fond',
              flush: true,
              child: Column(children: [
                SizedBox(
                  height: 52,
                  child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.all(8), children: [
                    for (final b in Basemap.values)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(avatar: Icon(b.icon, size: 16), label: Text(b.label), selected: _basemap == b, onSelected: (_) => setState(() => _basemap = b)),
                      ),
                  ]),
                ),
                KitMap(key: ValueKey(_basemap), basemap: _basemap, height: 260, radius: 0, zoom: 13, showBasemapSwitcher: false),
              ]),
            ),
          ],
        ),
        DocSection(
          id: 'markers',
          title: 'Marqueurs',
          source: 'MapMarkerData · FlatMarker',
          description: 'Disque teinté avec icône, halo pulsé pour les véhicules en mouvement, flèche de cap. Touchez un marqueur : popup en carte flottante ; la liste sous la carte centre le véhicule.',
          children: [
            Demo(
              label: 'Flotte en temps réel',
              flush: true,
              child: Column(children: [
                KitMap(
                  key: _fleetKey,
                  height: 320,
                  radius: 0,
                  markers: kFlotte,
                  fitToContent: true,
                  legend: const [('En mouvement', KitTone.success), ('À l’arrêt', KitTone.warning), ('Maintenance', KitTone.info), ('Alerte', KitTone.error)],
                ),
                SizedBox(
                  height: 64,
                  child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.all(10), children: [
                    for (final m in kFlotte)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          avatar: Icon(m.icon, size: 16, color: m.tone.color(c)),
                          label: Text(m.tooltip ?? m.id),
                          selected: _selected == m.id,
                          onSelected: (_) {
                            setState(() => _selected = m.id);
                            _fleetKey.currentState?.flyTo(m.point, 15);
                          },
                        ),
                      ),
                  ]),
                ),
              ]),
            ),
          ],
        ),
        DocSection(
          id: 'cluster',
          title: 'Clustering',
          source: 'KitMap(cluster: true)',
          description: '420 balises réparties en Côte d’Ivoire. Les bulles se divisent en zoomant ; leur couleur reflète l’état le plus critique. Touchez une bulle pour zoomer.',
          children: [
            Demo(label: 'Parc de balises', flush: true, child: KitMap(height: 340, radius: 0, markers: kPositionsDenses, cluster: true, zoom: 6.4, center: const LatLng(7.4, -5.5))),
          ],
        ),
        DocSection(
          id: 'routes',
          title: 'Trajets',
          source: 'MapRouteData (plein, pointillé, départ / arrivée)',
          children: [
            Demo(
              label: 'Trajet réalisé vs prévu',
              flush: true,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                KitMap(height: 300, radius: 0, routes: kTrajets, markers: kTrajetEtapes, fitToContent: true),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(spacing: 16, runSpacing: 6, children: [
                    for (final r in kTrajets)
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(width: 22, height: 4, decoration: BoxDecoration(color: r.tone.color(c), borderRadius: Radii.pill)),
                        const SizedBox(width: 6),
                        Flexible(child: Text(r.label ?? '', style: TextStyle(fontSize: 12, color: c.textSecondary))),
                      ]),
                  ]),
                ),
              ]),
            ),
          ],
        ),
        DocSection(
          id: 'zones',
          title: 'Zones / géofences',
          source: 'MapZoneData (cercle en mètres, polygone)',
          children: [
            Demo(
              label: 'Géofences',
              flush: true,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                KitMap(height: 300, radius: 0, zones: kZones, markers: kZoneMarkers, fitToContent: true),
                for (final z in kZones)
                  ListTile(
                    dense: true,
                    leading: Icon(z.center != null ? Icons.radio_button_checked : Icons.pentagon_outlined, color: z.tone.color(c)),
                    title: Text(z.label),
                    trailing: StatusBadge(z.tone == KitTone.error ? 'Restreinte' : 'Active', tone: z.tone == KitTone.error ? KitTone.error : KitTone.success),
                  ),
              ]),
            ),
          ],
        ),
        DocSection(
          id: 'draw',
          title: 'Dessin',
          source: 'KitMap(drawTools: …) — équivalent Leaflet Draw / Geoman',
          description: 'Choisissez un outil (point, ligne, zone) puis touchez la carte ; « Terminer » ferme la forme, ↶ annule le dernier sommet.',
          children: [
            Demo(
              label: 'Éditeur de zones',
              flush: true,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                KitMap(height: 340, radius: 0, zoom: 13, drawTools: const [DrawTool.marker, DrawTool.line, DrawTool.polygon], onShapesChanged: (s) => setState(() => _shapes = s)),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: _shapes.isEmpty
                      ? Text('Aucune forme dessinée.', style: TextStyle(fontSize: 12.5, color: c.textMuted))
                      : Wrap(spacing: 6, runSpacing: 6, children: [
                          for (final s in _shapes)
                            Chip(
                              avatar: Icon(switch (s.tool) { DrawTool.marker => Icons.place, DrawTool.line => Icons.timeline, _ => Icons.pentagon_outlined }, size: 16),
                              label: Text(s.label),
                            ),
                        ]),
                ),
              ]),
            ),
          ],
        ),
        DocSection(
          id: 'compact',
          title: 'Carte compacte',
          source: 'KitMap(interactive: false)',
          description: 'Vignette non interactive pour une fiche (position du véhicule, adresse d’un client).',
          cols: 2,
          children: [
            Demo(
              label: 'Fiche véhicule',
              flush: true,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                KitMap(height: 150, radius: 0, interactive: false, showZoom: false, showBasemapSwitcher: false, zoom: 15, center: kFlotte.first.point, markers: [kFlotte.first]),
                ListTile(
                  leading: const Icon(Icons.local_shipping),
                  title: const Text('CI-4521-AB · Toyota Hilux'),
                  subtitle: const Text('Plateau, bd de la République · il y a 12 s'),
                  trailing: StatusBadge('54 km/h', tone: KitTone.success, uppercase: false),
                ),
              ]),
            ),
            Demo(
              label: 'Adresse client',
              flush: true,
              child: KitMap(height: 200, radius: 0, interactive: false, showZoom: false, showBasemapSwitcher: false, zoom: 14, center: kZoneMarkers.first.point, markers: kZoneMarkers),
            ),
          ],
        ),
        DocSection(
          id: 'states',
          title: 'États',
          source: 'MapStatePlaceholder',
          children: [
            Demo(
              label: 'Chargement · vide · erreur',
              child: Gap([
                SegmentedToggle<String>(
                  value: _state,
                  expand: true,
                  onChanged: (v) => setState(() => _state = v),
                  options: const [('loading', 'Chargement', null), ('empty', 'Vide', null), ('error', 'Erreur', null)],
                ),
                MapStatePlaceholder(kind: _state),
              ]),
            ),
          ],
        ),
      ],
    );
  }
}
