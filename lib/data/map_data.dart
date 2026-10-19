import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../theme/kit_colors.dart';
import '../widgets/map/map_models.dart';

/// Données géographiques statiques (Abidjan et environs) — `data/static/map.data.ts`.
const kAbidjan = LatLng(5.33, -4.01);

const kFlotte = [
  MapMarkerData(id: 'v1', point: LatLng(5.3237, -4.0193), title: 'CI-4521-AB · Toyota Hilux', lines: ['En mouvement · 54 km/h', 'Plateau, bd de la République'], icon: Icons.local_shipping, tone: KitTone.success, pulse: true, heading: 120, tooltip: 'CI-4521-AB'),
  MapMarkerData(id: 'v2', point: LatLng(5.3600, -3.9900), title: 'CI-2210-CD · Renault Kangoo', lines: ['À l’arrêt depuis 12 min', 'Cocody, Riviera 2'], icon: Icons.airport_shuttle, tone: KitTone.warning, tooltip: 'CI-2210-CD'),
  MapMarkerData(id: 'v3', point: LatLng(5.3450, -4.0800), title: 'CI-3307-EF · Suzuki Swift', lines: ['En mouvement · 38 km/h', 'Yopougon, Selmer'], icon: Icons.directions_car, tone: KitTone.success, pulse: true, heading: 40, tooltip: 'CI-3307-EF'),
  MapMarkerData(id: 'v4', point: LatLng(5.3030, -3.9850), title: 'CI-0418-GH · Yamaha Crux', lines: ['Hors ligne depuis 2 j', 'Marcory, zone 4'], icon: Icons.two_wheeler, tone: KitTone.error, tooltip: 'CI-0418-GH'),
  MapMarkerData(id: 'v5', point: LatLng(5.2930, -4.0050), title: 'CI-7781-JK · Mercedes Actros', lines: ['Moteur coupé', 'Treichville, port'], icon: Icons.local_shipping, tone: KitTone.neutral, tooltip: 'CI-7781-JK'),
  MapMarkerData(id: 'v6', point: LatLng(5.4180, -4.0200), title: 'CI-1150-LM · Toyota Coaster', lines: ['En mouvement · 61 km/h', 'Abobo, gare'], icon: Icons.directions_bus, tone: KitTone.success, pulse: true, heading: 200, tooltip: 'CI-1150-LM'),
  MapMarkerData(id: 'v7', point: LatLng(5.2550, -3.9300), title: 'CI-9902-NP · Isuzu D-Max', lines: ['Alerte : sortie de zone', 'Port-Bouët, aéroport'], icon: Icons.warning, tone: KitTone.error, pulse: true, tooltip: 'CI-9902-NP'),
  MapMarkerData(id: 'v8', point: LatLng(5.2970, -3.9480), title: 'CI-6630-QR · Peugeot Partner', lines: ['En maintenance', 'Koumassi, atelier'], icon: Icons.build, tone: KitTone.info, tooltip: 'CI-6630-QR'),
];

/// Nuage de positions pour la démo de clustering (pseudo-aléatoire déterministe).
final List<MapMarkerData> kPositionsDenses = () {
  const centres = [[5.33, -4.02, 0.06], [7.69, -5.03, 0.05], [4.75, -6.64, 0.04], [6.82, -5.28, 0.04], [9.45, -5.63, 0.03]];
  var seed = 7;
  double rnd() => (seed = (seed * 16807) % 2147483647) / 2147483647;
  final out = <MapMarkerData>[];
  for (var ci = 0; ci < centres.length; ci++) {
    final c = centres[ci];
    final n = ci == 0 ? 220 : 50;
    for (var i = 0; i < n; i++) {
      final r = rnd();
      final lat = c[0] + (rnd() - 0.5) * c[2] * 2;
      final lng = c[1] + (rnd() - 0.5) * c[2] * 2;
      out.add(MapMarkerData(
        id: 'p$ci-$i',
        point: LatLng(lat, lng),
        icon: Icons.sensors,
        tone: r > 0.9 ? KitTone.error : r > 0.75 ? KitTone.warning : KitTone.success,
        title: 'Balise #${1000 + out.length}',
        lines: [r > 0.9 ? 'Hors ligne' : 'En ligne'],
      ));
    }
  }
  return out;
}();

const kTrajets = [
  MapRouteData(id: 't1', label: 'Trajet réalisé · 38 km · 52 min', tone: KitTone.primary, endpoints: true, points: [
    LatLng(5.3237, -4.0193), LatLng(5.3100, -4.0050), LatLng(5.2950, -3.9900), LatLng(5.2850, -3.9600), LatLng(5.2600, -3.9300),
    LatLng(5.2450, -3.8900), LatLng(5.2300, -3.8300), LatLng(5.2150, -3.7800), LatLng(5.2000, -3.7380),
  ]),
  MapRouteData(id: 't2', label: 'Itinéraire prévu', tone: KitTone.warning, dashed: true, points: [
    LatLng(5.2000, -3.7380), LatLng(5.2400, -3.7600), LatLng(5.2900, -3.8200), LatLng(5.3300, -3.8900), LatLng(5.3600, -3.9900),
  ]),
];

const kTrajetEtapes = [
  MapMarkerData(id: 'e1', point: LatLng(5.2600, -3.9300), title: 'Arrêt 8 min', lines: ['10:42 – 10:50', 'Port-Bouët'], icon: Icons.pause, tone: KitTone.warning),
  MapMarkerData(id: 'e2', point: LatLng(5.2300, -3.8300), title: 'Excès de vitesse', lines: ['94 km/h (limite 70)', '11:05'], icon: Icons.speed, tone: KitTone.error),
];

const kZones = [
  MapZoneData(id: 'z1', label: 'Dépôt central (rayon 600 m)', tone: KitTone.success, center: LatLng(5.3030, -3.9850), radius: 600),
  MapZoneData(id: 'z2', label: 'Zone portuaire — accès restreint', tone: KitTone.error, polygon: [LatLng(5.2990, -4.0180), LatLng(5.3010, -3.9990), LatLng(5.2860, -3.9960), LatLng(5.2820, -4.0150)]),
  MapZoneData(id: 'z3', label: 'Secteur de livraison Cocody', tone: KitTone.info, polygon: [LatLng(5.3750, -4.0050), LatLng(5.3800, -3.9700), LatLng(5.3500, -3.9600), LatLng(5.3420, -3.9950)]),
  MapZoneData(id: 'z4', label: 'Aéroport (rayon 1,5 km)', tone: KitTone.warning, center: LatLng(5.2550, -3.9300), radius: 1500),
];

const kZoneMarkers = [
  MapMarkerData(id: 'zm1', point: LatLng(5.3030, -3.9850), icon: Icons.warehouse, tone: KitTone.success, title: 'Dépôt central', lines: ['12 véhicules présents']),
];
