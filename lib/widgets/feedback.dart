import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/kit_colors.dart';
import '../theme/tokens.dart';
import 'inputs.dart';

// ═══════════════════════════════════════════════════════════════════
// Feedback : alertes, bannières globales, page de résultat, file d'envoi.
// ═══════════════════════════════════════════════════════════════════

IconData toneIcon(KitTone t) => switch (t) {
      KitTone.success => Icons.check_circle,
      KitTone.warning => Icons.warning_amber_rounded,
      KitTone.error => Icons.error,
      KitTone.info => Icons.info,
      _ => Icons.notifications,
    };

/// Bannière d'alerte en ligne (fond léger, bordure gauche teintée, action, fermeture).
class KitAlert extends StatelessWidget {
  const KitAlert({super.key, required this.tone, required this.text, this.title, this.icon, this.onClose, this.action, this.onAction, this.compact = false, this.filled = false});
  final KitTone tone;
  final String text;
  final String? title, action;
  final IconData? icon;
  final VoidCallback? onClose, onAction;
  final bool compact, filled;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final col = tone.color(c);
    final fg = filled ? Colors.white : tone.text(c);
    return Container(
      padding: EdgeInsets.fromLTRB(compact ? 10 : 14, compact ? 8 : 12, onClose == null ? 14 : 4, compact ? 8 : 12),
      decoration: BoxDecoration(
        color: filled ? col : tone.light(c),
        borderRadius: Radii.rm,
        border: Border(left: BorderSide(color: col, width: 4)),
      ),
      child: Row(crossAxisAlignment: compact ? CrossAxisAlignment.center : CrossAxisAlignment.start, children: [
        Icon(icon ?? toneIcon(tone), size: compact ? 18 : 22, color: filled ? Colors.white : col),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (title != null && !compact) ...[
              Text(title!, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: fg)),
              const SizedBox(height: 2),
            ],
            Text(compact && title != null ? '$title — $text' : text, style: TextStyle(fontSize: 13, height: 1.45, color: filled ? Colors.white : c.textPrimary)),
            if (action != null && !compact) ...[
              const SizedBox(height: 6),
              InkWell(
                onTap: onAction,
                child: Text(action!, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: fg, decoration: TextDecoration.underline, decorationColor: fg)),
              ),
            ],
          ]),
        ),
        if (onClose != null)
          IconButton(visualDensity: VisualDensity.compact, iconSize: 18, onPressed: onClose, icon: Icon(Icons.close, color: filled ? Colors.white : c.textSecondary)),
      ]),
    );
  }
}

/// Bannière globale (`<app-banner>`) : maintenance, incident, abonnement, nouveauté, hors ligne.
class GlobalBanner extends StatelessWidget {
  const GlobalBanner({super.key, required this.tone, required this.title, this.text, this.icon, this.action, this.onAction, this.onClose});
  final KitTone tone;
  final String title;
  final String? text, action;
  final IconData? icon;
  final VoidCallback? onAction, onClose;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final col = tone.color(c);
    return Material(
      color: Color.alphaBlend(tone.light(c), c.card),
      child: Container(
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: col.withValues(alpha: 0.35)))),
        padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
        child: Row(children: [
          Icon(icon ?? toneIcon(tone), color: col, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(children: [
                TextSpan(text: title, style: const TextStyle(fontWeight: FontWeight.w700)),
                if (text != null) TextSpan(text: ' · $text'),
              ]),
              style: TextStyle(fontSize: 12.5, height: 1.4, color: c.textPrimary),
            ),
          ),
          if (action != null) TextButton(onPressed: onAction, style: TextButton.styleFrom(foregroundColor: tone.text(c), padding: const EdgeInsets.symmetric(horizontal: 10), minimumSize: const Size(0, 32)), child: Text(action!)),
          if (onClose != null) IconButton(visualDensity: VisualDensity.compact, iconSize: 18, onPressed: onClose, icon: const Icon(Icons.close)),
        ]),
      ),
    );
  }
}

/// Page de résultat (`<app-result>`) : succès, erreur, info, attente, 404, 403.
class ResultView extends StatelessWidget {
  const ResultView({super.key, required this.tone, required this.title, this.subtitle, this.icon, this.actions = const [], this.extra});
  final KitTone tone;
  final String title;
  final String? subtitle;
  final IconData? icon;
  final List<Widget> actions;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.6, end: 1),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (_, v, child) => Transform.scale(scale: v, child: child),
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(shape: BoxShape.circle, color: tone.light(c)),
            child: Icon(icon ?? toneIcon(tone), size: 44, color: tone.color(c)),
          ),
        ),
        const SizedBox(height: 18),
        Text(title, textAlign: TextAlign.center, style: TextStyle(fontFamily: Fonts.heading, fontSize: 22, fontWeight: FontWeight.w700, color: c.textPrimary)),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(subtitle!, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, height: 1.5, color: c.textSecondary)),
        ],
        if (extra != null) ...[const SizedBox(height: 16), extra!],
        if (actions.isNotEmpty) ...[
          const SizedBox(height: 20),
          Wrap(spacing: 10, runSpacing: 10, alignment: WrapAlignment.center, children: actions),
        ],
      ]),
    );
  }
}

enum UploadStatus { queued, uploading, done, error, paused }

class UploadItem {
  UploadItem(this.file, {this.fail = false});
  final DemoFile file;
  final bool fail;
  double progress = 0;
  UploadStatus status = UploadStatus.queued;
}

/// File d'envoi multiple (`<app-upload-queue>`) : progression simulée par fichier,
/// pause / reprise, nouvelle tentative, total. Aucun réseau.
class UploadQueue extends StatefulWidget {
  const UploadQueue({super.key, this.concurrency = 2});
  final int concurrency;

  @override
  State<UploadQueue> createState() => _UploadQueueState();
}

class _UploadQueueState extends State<UploadQueue> {
  final List<UploadItem> _items = [];
  Timer? _timer;
  int _tick = 0;

  void _add(List<DemoFile> files) {
    setState(() {
      for (final f in files) {
        _items.add(UploadItem(f, fail: f.name.contains('photo')));
      }
    });
    _timer ??= Timer.periodic(const Duration(milliseconds: 120), (_) => _step());
  }

  void _step() {
    if (!mounted) return;
    _tick++;
    setState(() {
      final active = _items.where((i) => i.status == UploadStatus.uploading).length;
      var slots = widget.concurrency - active;
      for (final i in _items) {
        if (slots <= 0) break;
        if (i.status == UploadStatus.queued) {
          i.status = UploadStatus.uploading;
          slots--;
        }
      }
      for (final i in _items.where((i) => i.status == UploadStatus.uploading)) {
        final speed = 0.6e6 / math.max(i.file.bytes, 80000) * 0.12;
        i.progress = math.min(1, i.progress + speed + (_tick % 3) * 0.004);
        if (i.fail && i.progress > 0.62) {
          i.status = UploadStatus.error;
        } else if (i.progress >= 1) {
          i.status = UploadStatus.done;
        }
      }
    });
    if (_items.every((i) => i.status == UploadStatus.done || i.status == UploadStatus.error || i.status == UploadStatus.paused)) {
      _timer?.cancel();
      _timer = null;
    }
  }

  void _resume() => _timer ??= Timer.periodic(const Duration(milliseconds: 120), (_) => _step());

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final total = _items.isEmpty ? 0.0 : _items.fold<double>(0, (a, i) => a + i.progress) / _items.length;
    final done = _items.where((i) => i.status == UploadStatus.done).length;
    final errors = _items.where((i) => i.status == UploadStatus.error).length;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () => _add(kDemoFiles),
            icon: const Icon(Icons.upload_file, size: 18),
            label: const Text('Envoyer 5 fichiers'),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton(onPressed: _items.isEmpty ? null : () => setState(_items.clear), child: const Text('Vider')),
      ]),
      if (_items.isNotEmpty) ...[
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: Text('$done / ${_items.length} envoyé(s)${errors > 0 ? ' · $errors échec(s)' : ''}', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.textSecondary))),
          Text('${(total * 100).round()} %', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: c.primary)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(borderRadius: Radii.pill, child: LinearProgressIndicator(value: total, minHeight: 6, backgroundColor: c.fieldBg)),
        const SizedBox(height: 10),
        for (final i in _items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
              decoration: BoxDecoration(color: c.card, borderRadius: Radii.rm, border: Border.all(color: i.status == UploadStatus.error ? c.error.withValues(alpha: 0.5) : c.border)),
              child: Row(children: [
                Icon(i.file.icon, color: i.status == UploadStatus.error ? c.error : c.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(i.file.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    if (i.status == UploadStatus.uploading || i.status == UploadStatus.paused)
                      ClipRRect(borderRadius: Radii.pill, child: LinearProgressIndicator(value: i.progress, minHeight: 4, backgroundColor: c.fieldBg, color: i.status == UploadStatus.paused ? c.warning : null)),
                    const SizedBox(height: 2),
                    Text(
                      switch (i.status) {
                        UploadStatus.queued => 'En attente · ${i.file.size}',
                        UploadStatus.uploading => '${(i.progress * 100).round()} % · ${i.file.size}',
                        UploadStatus.paused => 'En pause · ${(i.progress * 100).round()} %',
                        UploadStatus.done => 'Envoyé · ${i.file.size}',
                        UploadStatus.error => 'Échec : délai dépassé',
                      },
                      style: TextStyle(fontSize: 11.5, color: i.status == UploadStatus.error ? c.errorText : (i.status == UploadStatus.done ? c.successText : c.textMuted)),
                    ),
                  ]),
                ),
                switch (i.status) {
                  UploadStatus.done => Padding(padding: const EdgeInsets.all(10), child: Icon(Icons.check_circle, color: c.success)),
                  UploadStatus.error => IconButton(
                      tooltip: 'Réessayer',
                      onPressed: () {
                        setState(() {
                          _items[_items.indexOf(i)] = UploadItem(i.file);
                        });
                        _resume();
                      },
                      icon: Icon(Icons.refresh, color: c.error),
                    ),
                  UploadStatus.uploading => IconButton(tooltip: 'Pause', onPressed: () => setState(() => i.status = UploadStatus.paused), icon: const Icon(Icons.pause)),
                  UploadStatus.paused => IconButton(
                      tooltip: 'Reprendre',
                      onPressed: () {
                        setState(() => i.status = UploadStatus.queued);
                        _resume();
                      },
                      icon: const Icon(Icons.play_arrow),
                    ),
                  UploadStatus.queued => IconButton(tooltip: 'Retirer', onPressed: () => setState(() => _items.remove(i)), icon: const Icon(Icons.close)),
                },
              ]),
            ),
          ),
      ],
    ]);
  }
}
