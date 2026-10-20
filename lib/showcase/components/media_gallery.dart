import 'package:flutter/material.dart';

import '../../theme/kit_colors.dart';
import '../../theme/tokens.dart';
import '../../widgets/common.dart';
import '../../widgets/media/demo_art.dart';
import '../../widgets/media/players.dart';
import '../../widgets/media/viewers.dart';
import '../doc/doc.dart';

const _videos = [
  ('Trajet CI-4521-AB', '2:14', 0),
  ('Pose balise FMB920', '5:02', 3),
  ('Dashcam — 10:05', '0:47', 4),
  ('Formation exploitants', '12:30', 2),
  ('Contrôle anti-démarrage', '1:36', 5),
  ('Recette port', '3:21', 1),
];

/// `/components/media` — lecteurs et visionneuses sans dépendance externe ni réseau.
class MediaGallery extends StatelessWidget {
  const MediaGallery({super.key, this.initialSection});
  final String? initialSection;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return DocPage(
      title: 'Médias',
      icon: Icons.perm_media,
      initialSection: initialSection,
      subtitle: 'Lecture et aperçu de fichiers sans dépendance : vidéo aux contrôles tactiles, YouTube en mode façade, audio à forme d’onde, PDF, visionneuse universelle, carrousel, galeries et recadrage. Tous les médias de démonstration sont générés localement.',
      sections: [
        const DocSection(
          id: 'video',
          title: 'Lecteur vidéo',
          source: 'KitVideoPlayer',
          description: 'Toucher : lecture / pause · double-toucher à gauche ou à droite : −10 s / +10 s · repères de chapitres · vitesse · plein écran en paysage.',
          children: [Demo(label: 'Trajet CI-4521-AB', child: KitVideoPlayer())],
        ),
        const DocSection(
          id: 'youtube',
          title: 'Lecteur YouTube',
          source: 'YoutubeFacade',
          description: 'Mode façade : seule une vignette est affichée ; aucun script ni requête vers YouTube tant que l’utilisateur n’a pas lancé la lecture (simulée ici).',
          children: [Demo(label: 'Vidéo de présentation', child: YoutubeFacade(title: 'Lookas — suivi de flotte en temps réel'))],
        ),
        const DocSection(
          id: 'audio',
          title: 'Lecteur audio',
          source: 'KitAudioPlayer',
          cols: 2,
          children: [
            Demo(label: 'Enregistrement d’appel', child: KitAudioPlayer(title: 'Appel client — Transports Yao', subtitle: '15/10/2026 · 09:42 · Marie Yao')),
            Demo(label: 'Message vocal (compact)', child: KitAudioPlayer(title: 'Message vocal', compact: true, duration: Duration(seconds: 23), seed: 8)),
          ],
        ),
        const DocSection(
          id: 'pdf',
          title: 'Lecteur PDF',
          source: 'PdfViewer',
          description: 'Pages défilant verticalement, pincement pour zoomer, miniatures de navigation.',
          children: [Demo(label: 'Facture', flush: true, child: PdfViewer())],
        ),
        DocSection(
          id: 'viewer',
          title: 'Visionneuse de fichiers',
          source: 'openFileViewer · FilePreview',
          description: 'Aperçu adapté au type (image, PDF, vidéo, audio, CSV, code, texte, non pris en charge) ; balayez pour passer au fichier suivant.',
          children: [
            Demo(
              label: 'Pièces du dossier',
              flush: true,
              child: Column(children: [
                for (var i = 0; i < kViewerFiles.length; i++)
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: kViewerFiles[i].tone.light(c), borderRadius: Radii.rm),
                      child: Icon(kViewerFiles[i].icon, color: kViewerFiles[i].tone.color(c)),
                    ),
                    title: Text(kViewerFiles[i].name),
                    subtitle: Text(kViewerFiles[i].size),
                    trailing: Icon(Icons.chevron_right, color: c.textMuted),
                    onTap: () => openFileViewer(context, kViewerFiles, i),
                  ),
              ]),
            ),
          ],
        ),
        const DocSection(
          id: 'carousel',
          title: 'Carrousel',
          source: 'KitCarousel',
          description: 'Aperçu de la diapositive suivante, défilement automatique suspendu pendant le toucher.',
          children: [
            Demo(
              label: 'Offres',
              child: KitCarousel(slides: [
                (title: 'Suivi essentiel', subtitle: 'Position en temps réel, historique 90 jours, alertes de zone.', seed: 0, icon: Icons.gps_fixed),
                (title: 'Poids lourds', subtitle: 'Sondes carburant, temps de conduite, chronotachygraphe.', seed: 1, icon: Icons.local_shipping),
                (title: 'Vidéo embarquée', subtitle: 'Caméra double face et détection de fatigue.', seed: 2, icon: Icons.videocam),
                (title: 'Anti-démarrage', subtitle: 'Coupure moteur à distance et badge chauffeur.', seed: 4, icon: Icons.lock),
              ]),
            ),
          ],
        ),
        const DocSection(
          id: 'image-gallery',
          title: 'Galerie d’images',
          source: 'ImageGallery · openLightbox',
          description: 'Touchez une vignette : visionneuse plein écran avec balayage et zoom par pincement.',
          children: [
            Demo(
              label: 'Photos d’installation',
              child: ImageGallery(
                seeds: [1, 3, 5, 0, 2, 4],
                captions: ['Cabine CI-4521-AB', 'Boîtier sous tableau de bord', 'Antenne GPS', 'Relais coupure moteur', 'Faisceau d’alimentation', 'Contrôle final'],
              ),
            ),
          ],
        ),
        DocSection(
          id: 'video-gallery',
          title: 'Galerie vidéo',
          source: 'grille de vignettes + lecteur',
          children: [
            Demo(
              label: 'Vidéos',
              child: GridView.count(
                crossAxisCount: MediaQuery.sizeOf(context).width >= Breakpoints.tablet ? 3 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.05,
                children: [
                  for (final (t, d, s) in _videos)
                    InkWell(
                      borderRadius: Radii.rm,
                      onTap: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (ctx) => SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(Space.s4, 0, Space.s4, Space.s4), child: KitVideoPlayer(title: t, seed: s, autoplay: true))),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        AspectRatio(
                          aspectRatio: 16 / 10,
                          child: ClipRRect(
                            borderRadius: Radii.rm,
                            child: Stack(fit: StackFit.expand, children: [
                              DemoArt(seed: s),
                              const Center(child: CircleAvatar(radius: 18, backgroundColor: Colors.black45, child: Icon(Icons.play_arrow, color: Colors.white))),
                              Positioned(
                                right: 6,
                                bottom: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(Radii.xs)),
                                  child: Text(d, style: const TextStyle(color: Colors.white, fontSize: 10.5)),
                                ),
                              ),
                            ]),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(t, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.textPrimary)),
                      ]),
                    ),
                ],
              ),
            ),
          ],
        ),
        const DocSection(
          id: 'masonry',
          title: 'Grille masonry',
          source: 'MasonryGrid',
          children: [Demo(label: 'Photos de sites', child: MasonryGrid(count: 8))],
        ),
        const DocSection(
          id: 'cropper',
          title: 'Recadrage d’image / avatar',
          source: 'ImageCropper',
          description: 'Faites glisser et pincez l’image dans le masque ; masque rond ou carré, rotation, aperçu aux tailles d’avatar.',
          children: [Demo(label: 'Photo de profil', child: ImageCropper())],
        ),
        DocSection(
          id: 'media-note',
          title: 'Note',
          tocLabel: 'Note',
          children: [
            KitCard(
              child: Row(children: [
                Icon(Icons.info_outline, color: c.info),
                const SizedBox(width: 10),
                const Expanded(child: Text('Pour de vrais fichiers, branchez video_player / just_audio / pdfx sur ces mêmes contrôles : l’interface reste identique.')),
              ]),
            ),
          ],
        ),
      ],
    );
  }
}
