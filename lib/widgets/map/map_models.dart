import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../theme/kit_colors.dart';

/// Modèles de `shared/components/map/map.models.ts`.
class MapMarkerData {
  const MapMarkerData({
    required this.id,
    required this.point,
    this.title,
    this.lines = const [],
    this.icon = Icons.place,
    this.tone = KitTone.primary,
    this.pulse = false,
    this.heading,
    this.tooltip,
  });

  final String id;
  final LatLng point;
  final String? title, tooltip;
  final List<String> lines;
  final IconData icon;
  final KitTone tone;
  final bool pulse;
  final double? heading;
}

class MapRouteData {
  const MapRouteData({required this.id, required this.points, this.label, this.tone = KitTone.primary, this.dashed = false, this.endpoints = false});
  final String id;
  final List<LatLng> points;
  final String? label;
  final KitTone tone;
  final bool dashed, endpoints;
}

class MapZoneData {
  const MapZoneData({required this.id, required this.label, this.tone = KitTone.primary, this.polygon, this.center, this.radius});
  final String id, label;
  final KitTone tone;
  final List<LatLng>? polygon;
  final LatLng? center;

  /// Rayon en mètres (zone circulaire).
  final double? radius;
}

/// Fonds de carte gratuits sans clé d'API (README du kit web) : seules les tuiles
/// sont téléchargées, aucune API n'est appelée.
enum Basemap { canvasLight, canvasDark, streets, topo, satellite, osm }

extension BasemapX on Basemap {
  String get label => switch (this) {
        Basemap.canvasLight => 'Gris clair',
        Basemap.canvasDark => 'Gris foncé',
        Basemap.streets => 'Rues',
        Basemap.topo => 'Topographique',
        Basemap.satellite => 'Satellite',
        Basemap.osm => 'OpenStreetMap',
      };

  IconData get icon => switch (this) {
        Basemap.canvasLight => Icons.light_mode_outlined,
        Basemap.canvasDark => Icons.dark_mode_outlined,
        Basemap.streets => Icons.signpost_outlined,
        Basemap.topo => Icons.terrain,
        Basemap.satellite => Icons.satellite_alt,
        Basemap.osm => Icons.public,
      };

  String get url => switch (this) {
        Basemap.canvasLight => 'https://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer/tile/{z}/{y}/{x}',
        Basemap.canvasDark => 'https://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Dark_Gray_Base/MapServer/tile/{z}/{y}/{x}',
        Basemap.streets => 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
        Basemap.topo => 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}',
        Basemap.satellite => 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
        Basemap.osm => 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      };

  int get maxZoom => this == Basemap.canvasLight || this == Basemap.canvasDark ? 16 : 19;

  String get attribution => this == Basemap.osm ? '© OpenStreetMap' : '© Esri';
}
