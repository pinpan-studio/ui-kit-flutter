import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/kit_colors.dart';
import '../../theme/tokens.dart';
import 'demo_art.dart';

// ═══════════════════════════════════════════════════════════════════
// Lecteurs : vidéo aux contrôles maison, façade YouTube, audio à forme d'onde.
// La lecture est simulée (horloge locale) : aucun fichier ni réseau.
// ═══════════════════════════════════════════════════════════════════

/// Horloge de lecture simulée partagée par les lecteurs.
class _Playback {
  _Playback(this.duration, this.onTick);
  final Duration duration;
  final VoidCallback onTick;
  Duration position = Duration.zero;
  double speed = 1;
  bool playing = false;
  Timer? _timer;

  void play() {
    if (position >= duration) position = Duration.zero;
    playing = true;
    _timer ??= Timer.periodic(const Duration(milliseconds: 100), (_) {
      position += Duration(milliseconds: (100 * speed).round());
      if (position >= duration) {
        position = duration;
        pause();
      }
      onTick();
    });
    onTick();
  }

  void pause() {
    playing = false;
    _timer?.cancel();
    _timer = null;
    onTick();
  }

  void toggle() => playing ? pause() : play();

  void seek(Duration d) {
    position = Duration(milliseconds: d.inMilliseconds.clamp(0, duration.inMilliseconds));
    onTick();
  }

  double get ratio => duration.inMilliseconds == 0 ? 0 : position.inMilliseconds / duration.inMilliseconds;

  void dispose() => _timer?.cancel();
}

/// Lecteur vidéo (`<app-video-player>`) : lecture / pause au toucher, double-toucher ±10 s,
/// barre de progression avec chapitres, vitesse, son, plein écran (paysage).
class KitVideoPlayer extends StatefulWidget {
  const KitVideoPlayer({
    super.key,
    this.title = 'Trajet CI-4521-AB',
    this.seed = 0,
    this.duration = const Duration(minutes: 2, seconds: 14),
    this.chapters = const [0.18, 0.46, 0.72],
    this.autoplay = false,
  });
  final String title;
  final int seed;
  final Duration duration;
  final List<double> chapters;
  final bool autoplay;

  @override
  State<KitVideoPlayer> createState() => _KitVideoPlayerState();
}

class _KitVideoPlayerState extends State<KitVideoPlayer> {
  late final _pb = _Playback(widget.duration, () => mounted ? setState(() {}) : null);
  bool _muted = false;
  bool _controls = true;
  Timer? _hide;
  String? _flash;

  @override
  void initState() {
    super.initState();
    if (widget.autoplay) _pb.play();
  }

  @override
  void dispose() {
    _pb.dispose();
    _hide?.cancel();
    super.dispose();
  }

  void _poke() {
    setState(() => _controls = true);
    _hide?.cancel();
    _hide = Timer(const Duration(seconds: 3), () {
      if (mounted && _pb.playing) setState(() => _controls = false);
    });
  }

  void _skip(int s) {
    _pb.seek(_pb.position + Duration(seconds: s));
    setState(() => _flash = s > 0 ? '+${s}s' : '${s}s');
    Timer(const Duration(milliseconds: 600), () => mounted ? setState(() => _flash = null) : null);
  }

  Future<void> _fullscreen() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    if (!mounted) return;
    _pb.pause();
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Center(
              child: KitVideoPlayer(title: widget.title, seed: widget.seed, duration: widget.duration, chapters: widget.chapters, autoplay: true),
            ),
          ),
        ),
      ),
    );
    await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: Radii.rm,
        child: GestureDetector(
          onTap: () => _controls ? _pb.toggle() : _poke(),
          onDoubleTapDown: (d) => _skip(d.localPosition.dx < (context.size?.width ?? 0) / 2 ? -10 : 10),
          onDoubleTap: () {},
          child: Stack(
            fit: StackFit.expand,
            children: [
              DemoArt(seed: widget.seed, t: _pb.ratio * 6),
              AnimatedOpacity(
                opacity: _controls || !_pb.playing ? 1 : 0,
                duration: const Duration(milliseconds: 250),
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x99000000), Color(0x00000000), Color(0x00000000), Color(0xB3000000)],
                      stops: [0, 0.3, 0.6, 1],
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 6, 0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                              ),
                            ),
                            PopupMenuButton<double>(
                              tooltip: 'Vitesse',
                              initialValue: _pb.speed,
                              onSelected: (v) => setState(() => _pb.speed = v),
                              itemBuilder: (_) => [
                                for (final s in const [0.5, 1.0, 1.5, 2.0]) PopupMenuItem(value: s, child: Text('×${s.toString().replaceAll('.0', '').replaceAll('.', ',')}')),
                              ],
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  '×${_pb.speed.toString().replaceAll('.0', '').replaceAll('.', ',')}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withValues(alpha: 0.45)),
                            child: Icon(_pb.playing ? Icons.pause : (_pb.position >= widget.duration ? Icons.replay : Icons.play_arrow), color: Colors.white, size: 36),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          children: [
                            Text(
                              '  ${mmss(_pb.position)}',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontFeatures: [FontFeature.tabularFigures()]),
                            ),
                            Expanded(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      trackHeight: 3,
                                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                      overlayShape: SliderComponentShape.noOverlay,
                                      activeTrackColor: c.primary,
                                      inactiveTrackColor: Colors.white30,
                                      thumbColor: Colors.white,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: Slider(
                                        value: _pb.ratio,
                                        onChanged: (v) {
                                          _poke();
                                          _pb.seek(widget.duration * v);
                                        },
                                      ),
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: IgnorePointer(
                                      child: LayoutBuilder(
                                        builder: (_, cons) => Stack(
                                          children: [
                                            for (final ch in widget.chapters)
                                              Positioned(
                                                left: 10 + (cons.maxWidth - 20) * ch,
                                                top: cons.maxHeight / 2 - 3,
                                                child: Container(width: 2, height: 6, color: Colors.black54),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text('${mmss(widget.duration)}  ', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              color: Colors.white,
                              onPressed: () => setState(() => _muted = !_muted),
                              icon: Icon(_muted ? Icons.volume_off : Icons.volume_up, size: 20),
                            ),
                            IconButton(visualDensity: VisualDensity.compact, color: Colors.white, onPressed: _fullscreen, icon: const Icon(Icons.fullscreen, size: 22)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_flash != null)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: Radii.pill),
                    child: Text(
                      _flash!,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Façade YouTube (`<app-youtube-player>`) : vignette + bouton ; le lecteur réel n'est
/// jamais chargé (aucun appel externe) — le toucher bascule sur la lecture simulée.
class YoutubeFacade extends StatefulWidget {
  const YoutubeFacade({super.key, required this.title, this.channel = 'Lookas CI', this.duration = '4:32', this.seed = 2});
  final String title, channel, duration;
  final int seed;

  @override
  State<YoutubeFacade> createState() => _YoutubeFacadeState();
}

class _YoutubeFacadeState extends State<YoutubeFacade> {
  bool _started = false;

  @override
  Widget build(BuildContext context) {
    if (_started) return KitVideoPlayer(title: widget.title, seed: widget.seed, duration: const Duration(minutes: 4, seconds: 32), autoplay: true);
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: Radii.rm,
        child: GestureDetector(
          onTap: () => setState(() => _started = true),
          child: Stack(
            fit: StackFit.expand,
            children: [
              DemoArt(seed: widget.seed),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.center, colors: [Color(0xB3000000), Color(0x00000000)]),
                ),
              ),
              Positioned(
                left: 12,
                top: 10,
                right: 12,
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.gps_fixed, size: 16, color: Color(0xFF006A6A)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                          Text(widget.channel, style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Container(
                  width: 68,
                  height: 48,
                  decoration: BoxDecoration(color: const Color(0xFFFF0000), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.play_arrow, color: Colors.white, size: 34),
                ),
              ),
              Positioned(
                right: 10,
                bottom: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(4)),
                  child: Text(
                    widget.duration,
                    style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lecteur audio à forme d'onde (`<app-audio-player>`) : toucher / glisser l'onde pour se déplacer,
/// vitesse, ±15 s. Forme d'onde déterministe.
class KitAudioPlayer extends StatefulWidget {
  const KitAudioPlayer({super.key, required this.title, this.subtitle, this.duration = const Duration(minutes: 1, seconds: 48), this.seed = 3, this.compact = false});
  final String title;
  final String? subtitle;
  final Duration duration;
  final int seed;
  final bool compact;

  @override
  State<KitAudioPlayer> createState() => _KitAudioPlayerState();
}

class _KitAudioPlayerState extends State<KitAudioPlayer> {
  late final _pb = _Playback(widget.duration, () => mounted ? setState(() {}) : null);
  late final List<double> _wave = () {
    final r = math.Random(widget.seed);
    return List.generate(64, (i) => 0.18 + 0.82 * (0.5 + 0.5 * math.sin(i / 3.2 + r.nextDouble())) * (0.45 + r.nextDouble() * 0.55));
  }();

  @override
  void dispose() {
    _pb.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final wave = LayoutBuilder(
      builder: (context, cons) {
        void seek(double dx) => _pb.seek(widget.duration * (dx / cons.maxWidth).clamp(0, 1));
        return GestureDetector(
          onTapDown: (d) => seek(d.localPosition.dx),
          onHorizontalDragUpdate: (d) => seek(d.localPosition.dx),
          child: SizedBox(
            height: widget.compact ? 30 : 44,
            width: double.infinity,
            child: CustomPaint(painter: _WavePainter(_wave, _pb.ratio, c.primary, c.textMuted.withValues(alpha: 0.35))),
          ),
        );
      },
    );
    final play = Material(
      color: c.primary,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _pb.toggle,
        child: SizedBox(
          width: widget.compact ? 40 : 48,
          height: widget.compact ? 40 : 48,
          child: Icon(_pb.playing ? Icons.pause : Icons.play_arrow, color: c.onPrimary, size: 26),
        ),
      ),
    );
    if (widget.compact) {
      return Container(
        padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: Radii.pill,
          border: Border.all(color: c.border),
        ),
        child: Row(
          children: [
            play,
            const SizedBox(width: 10),
            Expanded(child: wave),
            const SizedBox(width: 10),
            Text(
              mmss(_pb.playing || _pb.position > Duration.zero ? _pb.position : widget.duration),
              style: TextStyle(fontSize: 12, color: c.textSecondary, fontFeatures: const [FontFeature.tabularFigures()]),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: Radii.rl,
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: c.primaryLight, borderRadius: Radii.rm),
                child: Icon(Icons.graphic_eq, color: c.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w700, color: c.textPrimary),
                    ),
                    if (widget.subtitle != null)
                      Text(
                        widget.subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: c.textSecondary),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          wave,
          Row(
            children: [
              Text(mmss(_pb.position), style: TextStyle(fontSize: 11.5, color: c.textMuted)),
              const Spacer(),
              Text(mmss(widget.duration), style: TextStyle(fontSize: 11.5, color: c.textMuted)),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(fit: BoxFit.scaleDown, child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(onPressed: () => setState(() => _pb.speed = _pb.speed >= 2 ? 0.5 : _pb.speed + 0.5), child: Text('×${_pb.speed.toString().replaceAll('.0', '').replaceAll('.', ',')}')),
              IconButton(onPressed: () => _pb.seek(_pb.position - const Duration(seconds: 15)), icon: const Icon(Icons.replay_10)),
              play,
              IconButton(onPressed: () => _pb.seek(_pb.position + const Duration(seconds: 15)), icon: const Icon(Icons.forward_10)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.download_outlined)),
            ],
          )),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter(this.wave, this.progress, this.active, this.idle);
  final List<double> wave;
  final double progress;
  final Color active, idle;

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width / wave.length;
    for (var i = 0; i < wave.length; i++) {
      final h = wave[i] * s.height;
      final paint = Paint()..color = (i + 0.5) / wave.length <= progress ? active : idle;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(i * w + w * 0.2, (s.height - h) / 2, w * 0.6, h), const Radius.circular(2)), paint);
    }
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.progress != progress || old.active != active;
}
