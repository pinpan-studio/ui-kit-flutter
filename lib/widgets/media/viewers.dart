import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/snack.dart';
import '../../theme/kit_colors.dart';
import '../../theme/tokens.dart';
import 'demo_art.dart';
import 'players.dart';

// ═══════════════════════════════════════════════════════════════════
// Visionneuses : PDF (pages générées), fichiers, carrousel, galeries,
// masonry, recadrage d'image.
// ═══════════════════════════════════════════════════════════════════

/// Page de facture « PDF » générée localement (format A4).
class _InvoicePage extends StatelessWidget {
  const _InvoicePage(this.page, this.total);
  final int page, total;

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF1F2937);
    const muted = Color(0xFF6B7280);
    const teal = Color(0xFF006A6A);
    const t = TextStyle(fontSize: 7.5, color: ink, height: 1.4);
    final lines = [
      ('Abonnement Suivi Premium — 24 véhicules', 24, 14500),
      ('Installation balise FMB920', 6, 35000),
      ('Option anti-démarrage', 6, 4500),
      ('Carte SIM data 1 Go', 24, 2500),
      ('Déplacement technicien (Yamoussoukro)', 1, 45000),
    ];
    return AspectRatio(
      aspectRatio: 1 / 1.414,
      child: FittedBox(
        child: Container(
          width: 300,
          height: 424,
          color: Colors.white,
          padding: const EdgeInsets.all(18),
          child: DefaultTextStyle(
            style: t,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(color: teal, borderRadius: BorderRadius.circular(5)),
                      child: const Icon(Icons.gps_fixed, size: 12, color: Colors.white),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'LOOKAS CI',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: teal),
                    ),
                    const Spacer(),
                    Text(page == 1 ? 'FACTURE' : 'ANNEXE ${page - 1}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 10),
                if (page == 1) ...[
                  const Text('FAC-2026-0912 · 15/10/2026', style: TextStyle(color: muted)),
                  const SizedBox(height: 8),
                  const Text('Facturé à :', style: TextStyle(fontWeight: FontWeight.w700)),
                  const Text('Transports Yao & Fils\nZone industrielle de Yopougon\nAbidjan, Côte d’Ivoire'),
                  const SizedBox(height: 10),
                  Container(
                    color: const Color(0xFFF1F5F9),
                    padding: const EdgeInsets.all(4),
                    child: const Row(
                      children: [
                        Expanded(
                          child: Text('Désignation', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                        Text('Qté   Montant', style: TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  for (final (l, q, p) in lines)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2.5),
                      child: Row(
                        children: [
                          Expanded(child: Text(l)),
                          Text('$q   ${Fmt.number(q * p)}'),
                        ],
                      ),
                    ),
                  const Divider(height: 10, color: muted),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('Total TTC : ${Fmt.number(lines.fold<int>(0, (a, l) => a + l.$2 * l.$3))} FCFA', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 9)),
                  ),
                ] else ...[
                  for (var i = 0; i < 14; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Container(height: 4, width: 60.0 + (i * 37 % 140), color: const Color(0xFFE5E7EB)),
                    ),
                ],
                const Spacer(),
                Row(
                  children: [
                    const Text('RCCM CI-ABJ-2019-B-12345', style: TextStyle(color: muted, fontSize: 6)),
                    const Spacer(),
                    Text('Page $page / $total', style: const TextStyle(color: muted, fontSize: 6)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Lecteur PDF (`<app-pdf-viewer>`) : pages défilantes, miniatures, zoom par pincement, navigation.
class PdfViewer extends StatefulWidget {
  const PdfViewer({super.key, this.pages = 3, this.fileName = 'FAC-2026-0912.pdf', this.height = 460});
  final int pages;
  final String fileName;
  final double height;

  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  final _pc = PageController();
  final _tc = TransformationController();
  int _page = 0;

  @override
  void dispose() {
    _pc.dispose();
    _tc.dispose();
    super.dispose();
  }

  void _zoom(double f) {
    final s = (_tc.value.getMaxScaleOnAxis() * f).clamp(1.0, 4.0);
    setState(() => _tc.value = Matrix4.identity()..scaleByDouble(s, s, 1, 1));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return Container(
      height: widget.height,
      decoration: BoxDecoration(color: context.isDark ? const Color(0xFF0B0F12) : const Color(0xFF525659), borderRadius: Radii.rm),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            color: c.card,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              children: [
                const SizedBox(width: 6),
                Icon(Icons.picture_as_pdf, color: c.error, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
                IconButton(visualDensity: VisualDensity.compact, onPressed: () => _zoom(1 / 1.25), icon: const Icon(Icons.zoom_out, size: 20)),
                IconButton(visualDensity: VisualDensity.compact, onPressed: () => _zoom(1.25), icon: const Icon(Icons.zoom_in, size: 20)),
                IconButton(visualDensity: VisualDensity.compact, onPressed: () => demoAction(context, 'Téléchargement'), icon: const Icon(Icons.download, size: 20)),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pc,
              scrollDirection: Axis.vertical,
              itemCount: widget.pages,
              onPageChanged: (p) => setState(() {
                _page = p;
                _tc.value = Matrix4.identity();
              }),
              itemBuilder: (_, i) => InteractiveViewer(
                transformationController: i == _page ? _tc : null,
                maxScale: 4,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: DecoratedBox(
                      decoration: const BoxDecoration(boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 10)]),
                      child: _InvoicePage(i + 1, widget.pages),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            color: c.card,
            height: 46,
            child: Row(
              children: [
                IconButton(
                  onPressed: _page == 0 ? null : () => _pc.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut),
                  icon: const Icon(Icons.keyboard_arrow_up),
                ),
                Expanded(
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < widget.pages; i++)
                          GestureDetector(
                            onTap: () => _pc.animateToPage(i, duration: const Duration(milliseconds: 300), curve: Curves.easeOut),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: 22,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: i == _page ? c.primary : c.border, width: i == _page ? 2 : 1),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              alignment: Alignment.center,
                              child: Text('${i + 1}', style: const TextStyle(fontSize: 10, color: Colors.black87)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _page == widget.pages - 1 ? null : () => _pc.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut),
                  icon: const Icon(Icons.keyboard_arrow_down),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Fichier de démonstration pour la visionneuse universelle.
class ViewerFile {
  const ViewerFile(this.name, this.kind, this.size, {this.seed = 0});
  final String name, kind, size;
  final int seed;

  IconData get icon => switch (kind) {
    'image' => Icons.image,
    'pdf' => Icons.picture_as_pdf,
    'video' => Icons.movie,
    'audio' => Icons.audiotrack,
    'csv' => Icons.table_view,
    'code' => Icons.code,
    'text' => Icons.description,
    _ => Icons.insert_drive_file,
  };

  KitTone get tone => switch (kind) {
    'image' => KitTone.purple,
    'pdf' => KitTone.error,
    'video' => KitTone.info,
    'audio' => KitTone.warning,
    'csv' => KitTone.success,
    'code' => KitTone.primary,
    _ => KitTone.neutral,
  };
}

const kViewerFiles = [
  ViewerFile('photo-installation.jpg', 'image', '2,4 Mo', seed: 1),
  ViewerFile('FAC-2026-0912.pdf', 'pdf', '184 Ko'),
  ViewerFile('dashcam-10h05.mp4', 'video', '18,2 Mo', seed: 4),
  ViewerFile('appel-client.wav', 'audio', '1,1 Mo'),
  ViewerFile('positions-octobre.csv', 'csv', '86 Ko'),
  ViewerFile('gt06-config.json', 'code', '2 Ko'),
  ViewerFile('notes-intervention.txt', 'text', '1 Ko'),
  ViewerFile('firmware-v03.28.bin', 'bin', '512 Ko'),
];

/// Ouvre la visionneuse plein écran d'un fichier (aperçu selon le type, défilement entre fichiers).
void openFileViewer(BuildContext context, List<ViewerFile> files, int index) {
  Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _FileViewerPage(files: files, index: index),
    ),
  );
}

class _FileViewerPage extends StatefulWidget {
  const _FileViewerPage({required this.files, required this.index});
  final List<ViewerFile> files;
  final int index;

  @override
  State<_FileViewerPage> createState() => _FileViewerPageState();
}

class _FileViewerPageState extends State<_FileViewerPage> {
  late final _pc = PageController(initialPage: widget.index);
  late int _i = widget.index;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.files[_i];
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(f.name, style: const TextStyle(fontSize: 15)),
            Text(
              '${f.size} · ${_i + 1} / ${widget.files.length}',
              style: TextStyle(fontSize: 11.5, color: context.kc.textMuted, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: () => demoAction(context, 'Partage'), icon: const Icon(Icons.share_outlined)),
          IconButton(onPressed: () => demoAction(context, 'Téléchargement'), icon: const Icon(Icons.download_outlined)),
        ],
      ),
      body: PageView.builder(
        controller: _pc,
        itemCount: widget.files.length,
        onPageChanged: (i) => setState(() => _i = i),
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.all(16),
          child: Center(child: FilePreview(file: widget.files[i])),
        ),
      ),
    );
  }
}

/// Aperçu d'un fichier selon son type.
class FilePreview extends StatelessWidget {
  const FilePreview({super.key, required this.file});
  final ViewerFile file;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    switch (file.kind) {
      case 'image':
        return InteractiveViewer(
          maxScale: 5,
          child: ClipRRect(
            borderRadius: Radii.rm,
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: DemoArt(seed: file.seed),
            ),
          ),
        );
      case 'pdf':
        return const PdfViewer(height: 560);
      case 'video':
        return KitVideoPlayer(title: file.name, seed: file.seed, duration: const Duration(seconds: 47));
      case 'audio':
        return KitAudioPlayer(title: file.name, subtitle: 'Appel entrant · +225 07 10 20 30 40');
      case 'csv':
        const rows = [
          ['Immat.', 'Date', 'Km', 'Vitesse max'],
          ['CI-4521-AB', '01/10', '182', '94'],
          ['CI-2210-CD', '01/10', '96', '71'],
          ['CI-3307-EF', '02/10', '214', '88'],
          ['CI-0418-GH', '02/10', '0', '0'],
          ['CI-1150-LM', '03/10', '301', '102'],
        ];
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStatePropertyAll(c.tableHeader),
            columns: [
              for (final h in rows.first)
                DataColumn(
                  label: Text(h, style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
            ],
            rows: [
              for (final r in rows.skip(1)) DataRow(cells: [for (final v in r) DataCell(Text(v))]),
            ],
          ),
        );
      case 'code':
      case 'text':
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: c.hover, borderRadius: Radii.rm),
          child: SelectableText(
            file.kind == 'code'
                ? '{\n  "intervalle_gps": 15,\n  "vitesse_max": 90,\n  "coupe_moteur": true,\n  "alertes": ["sortie_zone", "batterie_faible"]\n}'
                : 'Intervention INT-0412\n\nBalise remplacée, antenne repositionnée.\nTest de coupure moteur : OK.\nClient informé.',
            style: TextStyle(fontFamily: Fonts.mono, fontSize: 12.5, height: 1.6, color: c.textPrimary),
          ),
        );
      default:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.visibility_off_outlined, size: 54, color: c.textMuted),
            const SizedBox(height: 12),
            Text(
              'Aperçu indisponible',
              style: TextStyle(fontFamily: Fonts.heading, fontSize: 18, fontWeight: FontWeight.w700, color: c.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              'Ce type de fichier (.${file.name.split('.').last}) ne peut pas être prévisualisé.',
              textAlign: TextAlign.center,
              style: TextStyle(color: c.textSecondary),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: () => demoAction(context, 'Téléchargement'), icon: const Icon(Icons.download, size: 18), label: Text('Télécharger (${file.size})')),
          ],
        );
    }
  }
}

/// Carrousel (`<app-carousel>`) : pages avec aperçu de la suivante, indicateurs, lecture automatique.
class KitCarousel extends StatefulWidget {
  const KitCarousel({super.key, required this.slides, this.height = 200, this.autoplay = true});
  final List<({String title, String subtitle, int seed, IconData? icon})> slides;
  final double height;
  final bool autoplay;

  @override
  State<KitCarousel> createState() => _KitCarouselState();
}

class _KitCarouselState extends State<KitCarousel> {
  final _pc = PageController(viewportFraction: 0.88);
  int _i = 0;
  Timer? _t;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoplay) {
      _t = Timer.periodic(const Duration(seconds: 4), (_) {
        if (!_paused && _pc.hasClients) _pc.animateToPage((_i + 1) % widget.slides.length, duration: const Duration(milliseconds: 450), curve: Curves.easeInOut);
      });
    }
  }

  @override
  void dispose() {
    _t?.cancel();
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: Listener(
            onPointerDown: (_) => _paused = true,
            onPointerUp: (_) => _paused = false,
            child: PageView.builder(
              controller: _pc,
              itemCount: widget.slides.length,
              onPageChanged: (i) => setState(() => _i = i),
              itemBuilder: (_, i) {
                final s = widget.slides[i];
                return AnimatedPadding(
                  duration: const Duration(milliseconds: 250),
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: i == _i ? 0 : 10),
                  child: ClipRRect(
                    borderRadius: Radii.rl,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        DemoArt(seed: s.seed, icon: s.icon),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(begin: Alignment.center, end: Alignment.bottomCenter, colors: [Color(0x00000000), Color(0xCC000000)]),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 14,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.title,
                                style: const TextStyle(color: Colors.white, fontFamily: Fonts.heading, fontSize: 18, fontWeight: FontWeight.w700),
                              ),
                              Text(s.subtitle, maxLines: 2, style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < widget.slides.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _i ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(color: i == _i ? c.primary : c.border, borderRadius: Radii.pill),
              ),
          ],
        ),
      ],
    );
  }
}

/// Visionneuse plein écran d'images : balayage, pincement pour zoomer, double-toucher.
void openLightbox(BuildContext context, List<int> seeds, int index, {List<String>? captions}) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black,
      pageBuilder: (_, _, _) => _Lightbox(seeds: seeds, index: index, captions: captions),
      transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
    ),
  );
}

class _Lightbox extends StatefulWidget {
  const _Lightbox({required this.seeds, required this.index, this.captions});
  final List<int> seeds;
  final int index;
  final List<String>? captions;

  @override
  State<_Lightbox> createState() => _LightboxState();
}

class _LightboxState extends State<_Lightbox> {
  late final _pc = PageController(initialPage: widget.index);
  late int _i = widget.index;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pc,
            itemCount: widget.seeds.length,
            onPageChanged: (i) => setState(() => _i = i),
            itemBuilder: (_, i) => InteractiveViewer(
              maxScale: 5,
              child: Center(
                child: Hero(
                  tag: 'img-${widget.seeds[i]}-$i',
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: DemoArt(seed: widget.seeds[i]),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Row(
              children: [
                IconButton(color: Colors.white, onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                const Spacer(),
                Text(
                  '${_i + 1} / ${widget.seeds.length}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
          if (widget.captions != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 32,
              child: SafeArea(
                child: Text(
                  widget.captions![_i],
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Grille d'images : vignettes carrées, ouverture en visionneuse.
class ImageGallery extends StatelessWidget {
  const ImageGallery({super.key, required this.seeds, this.captions, this.columns = 3});
  final List<int> seeds;
  final List<String>? captions;
  final int columns;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, mainAxisSpacing: 6, crossAxisSpacing: 6),
      itemCount: seeds.length,
      itemBuilder: (context, i) => GestureDetector(
        onTap: () => openLightbox(context, seeds, i, captions: captions),
        child: Hero(
          tag: 'img-${seeds[i]}-$i',
          child: ClipRRect(
            borderRadius: Radii.rm,
            child: Stack(
              fit: StackFit.expand,
              children: [
                DemoArt(seed: seeds[i]),
                if (i == seeds.length - 1 && seeds.length > 5)
                  Container(
                    color: Colors.black45,
                    alignment: Alignment.center,
                    child: const Icon(Icons.collections, color: Colors.white),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Grille masonry (2 colonnes, hauteurs variables).
class MasonryGrid extends StatelessWidget {
  const MasonryGrid({super.key, required this.count, this.columns = 2});
  final int count, columns;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final cols = List.generate(columns, (_) => <Widget>[]);
    final heights = List.filled(columns, 0.0);
    for (var i = 0; i < count; i++) {
      final h = 110.0 + (i * 53) % 120;
      final col = heights.indexOf(heights.reduce(math.min));
      heights[col] += h;
      cols[col].add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ClipRRect(
            borderRadius: Radii.rm,
            child: SizedBox(
              height: h,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DemoArt(seed: i + 7),
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: c.card.withValues(alpha: 0.9), borderRadius: Radii.pill),
                      child: Text(
                        'Site ${i + 1}',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c.textPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < columns; i++) ...[if (i > 0) const SizedBox(width: 8), Expanded(child: Column(children: cols[i]))],
      ],
    );
  }
}

/// Recadrage d'image / avatar (`<app-image-cropper>`) : déplacer / pincer dans un masque
/// rond ou carré, zoom, rotation, aperçu du résultat.
class ImageCropper extends StatefulWidget {
  const ImageCropper({super.key, this.image = const AssetImage('assets/images/bg.jpg')});
  final ImageProvider image;

  @override
  State<ImageCropper> createState() => _ImageCropperState();
}

class _ImageCropperState extends State<ImageCropper> {
  final _tc = TransformationController();
  bool _round = true;
  int _quarter = 0;
  double _scale = 1;

  @override
  void initState() {
    super.initState();
    _tc.addListener(() {
      final s = _tc.value.getMaxScaleOnAxis();
      if ((s - _scale).abs() > 0.01) setState(() => _scale = s);
    });
  }

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  void _setScale(double s) {
    final m = _tc.value.clone();
    final cur = m.getMaxScaleOnAxis();
    m.scaleByDouble(s / cur, s / cur, 1, 1);
    _tc.value = m;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    const size = 240.0;
    final img = RotatedBox(
      quarterTurns: _quarter,
      child: Image(image: widget.image, fit: BoxFit.cover, width: size * 1.6, height: size * 1.6),
    );
    return Column(
      children: [
        Center(
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              children: [
                ClipRect(
                  child: InteractiveViewer(transformationController: _tc, minScale: 1, maxScale: 4, constrained: false, boundaryMargin: const EdgeInsets.all(40), child: img),
                ),
                IgnorePointer(
                  child: CustomPaint(
                    size: const Size(size, size),
                    painter: _MaskPainter(round: _round, color: c.bg.withValues(alpha: 0.6), border: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.zoom_out, size: 18),
            Expanded(
              child: Slider(value: _scale.clamp(1, 4), min: 1, max: 4, onChanged: _setScale),
            ),
            const Icon(Icons.zoom_in, size: 18),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: true, icon: Icon(Icons.circle_outlined), label: Text('Rond')),
                ButtonSegment(value: false, icon: Icon(Icons.crop_square), label: Text('Carré')),
              ],
              selected: {_round},
              onSelectionChanged: (s) => setState(() => _round = s.first),
            ),
            IconButton.outlined(tooltip: 'Pivoter', onPressed: () => setState(() => _quarter = (_quarter + 1) % 4), icon: const Icon(Icons.rotate_90_degrees_ccw)),
            IconButton.outlined(
              tooltip: 'Réinitialiser',
              onPressed: () => setState(() {
                _tc.value = Matrix4.identity();
                _quarter = 0;
              }),
              icon: const Icon(Icons.restart_alt),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 8,
          children: [
            Text('Aperçu :', style: TextStyle(fontSize: 12, color: c.textSecondary)),
            const SizedBox(width: 10),
            for (final s in const [64.0, 40.0, 28.0])
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(_round ? s : 8),
                  child: SizedBox(
                    width: s,
                    height: s,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      clipBehavior: Clip.hardEdge,
                      child: SizedBox(
                        width: size,
                        height: size,
                        child: ClipRect(
                          child: Transform(
                            transform: _tc.value,
                            child: OverflowBox(alignment: Alignment.topLeft, maxWidth: size * 1.6, maxHeight: size * 1.6, child: img),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(width: 4),
            FilledButton(
              onPressed: () => showKitSnack(context, 'Avatar mis à jour (démo statique)', kind: SnackKind.success),
              child: const Text('Valider'),
            ),
          ],
        ),
      ],
    );
  }
}

class _MaskPainter extends CustomPainter {
  _MaskPainter({required this.round, required this.color, required this.border});
  final bool round;
  final Color color, border;

  @override
  void paint(Canvas canvas, Size s) {
    final inner = Rect.fromCircle(center: s.center(Offset.zero), radius: s.shortestSide / 2 - 14);
    final hole = Path()..addRect(Offset.zero & s);
    final shape = round ? (Path()..addOval(inner)) : (Path()..addRRect(RRect.fromRectAndRadius(inner, const Radius.circular(12))));
    canvas.drawPath(Path.combine(PathOperation.difference, hole, shape), Paint()..color = color);
    canvas.drawPath(
      shape,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_MaskPainter old) => old.round != round || old.color != color;
}
