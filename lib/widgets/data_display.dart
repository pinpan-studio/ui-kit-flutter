import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../core/format.dart';
import '../core/snack.dart';
import '../theme/kit_colors.dart';
import '../theme/kit_text.dart';
import '../theme/tokens.dart';
import 'common.dart';

// ═══════════════════════════════════════════════════════════════════
// Affichage de données : timeline, liste descriptive, compteur animé,
// diff de texte, journal d'audit, QR code / code-barres.
// ═══════════════════════════════════════════════════════════════════

class TimelineEntry {
  const TimelineEntry({required this.title, this.text, this.time, this.icon = Icons.circle, this.tone = KitTone.primary});
  final String title;
  final String? text, time;
  final IconData icon;
  final KitTone tone;
}

/// Timeline verticale (pastilles d'icône reliées par un trait).
class KitTimeline extends StatelessWidget {
  const KitTimeline({super.key, required this.items, this.dense = false});
  final List<TimelineEntry> items;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final dot = dense ? 26.0 : 34.0;
    return Column(children: [
      for (var i = 0; i < items.length; i++)
        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SizedBox(
              width: dot,
              child: Column(children: [
                Container(
                  width: dot,
                  height: dot,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: items[i].tone.light(c)),
                  child: Icon(items[i].icon, size: dot * 0.5, color: items[i].tone.color(c)),
                ),
                if (i < items.length - 1) Expanded(child: Container(width: 2, margin: const EdgeInsets.symmetric(vertical: Space.s1), color: c.border)),
              ]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: i < items.length - 1 ? (dense ? 12 : 18) : 0, top: dense ? 3 : 6),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(items[i].title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: dense ? 13 : 14, color: c.textPrimary))),
                    if (items[i].time != null) Text(items[i].time!, style: TextStyle(fontSize: 11.5, color: c.textMuted, fontFeatures: KitText.tabular)),
                  ]),
                  if (items[i].text != null) ...[
                    const SizedBox(height: 2),
                    Text(items[i].text!, style: TextStyle(fontSize: dense ? 12 : 13, height: 1.45, color: c.textSecondary)),
                  ],
                ]),
              ),
            ),
          ]),
        ),
    ]);
  }
}

enum DescType { text, mono, badge, email, phone, link, multiline }

class DescItem {
  const DescItem(this.label, this.value, {this.icon, this.type = DescType.text, this.tone = KitTone.neutral, this.copy = false, this.hint, this.full = false});
  final String label;
  final String? value, hint;
  final IconData? icon;
  final DescType type;
  final KitTone tone;
  final bool copy, full;
}

/// `<app-description-list>` : grille clé / valeur (colonnes responsives) ou disposition horizontale.
class DescriptionList extends StatelessWidget {
  const DescriptionList({super.key, required this.items, this.columns = 2, this.horizontal = false, this.bordered = false, this.title});
  final List<DescItem> items;
  final int columns;
  final bool horizontal, bordered;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    Widget value(DescItem it) {
      if (it.value == null || it.value!.isEmpty) return Text('—', style: TextStyle(color: c.textMuted));
      final base = TextStyle(fontSize: 14, color: c.textPrimary, fontWeight: FontWeight.w500);
      final Widget w = switch (it.type) {
        DescType.badge => Align(alignment: horizontal ? Alignment.centerRight : Alignment.centerLeft, child: StatusBadge(it.value!, tone: it.tone)),
        DescType.mono => Text(it.value!, style: base.copyWith(fontFamily: Fonts.mono, fontSize: 12.5)),
        DescType.email || DescType.link || DescType.phone => InkWell(
            onTap: () => demoAction(context, 'Ouverture de ${it.value}'),
            child: Text(it.value!, style: base.copyWith(color: c.primary)),
          ),
        _ => Text(it.value!, textAlign: horizontal ? TextAlign.right : TextAlign.left, style: base),
      };
      if (!it.copy) return w;
      return Row(mainAxisSize: MainAxisSize.min, children: [
        Flexible(child: w),
        IconButton(visualDensity: VisualDensity.compact, iconSize: 16, onPressed: () => copyToClipboard(context, it.value!), icon: Icon(Icons.content_copy, color: c.textMuted)),
      ]);
    }

    Widget label(DescItem it) => Row(mainAxisSize: MainAxisSize.min, children: [
          if (it.icon != null) ...[Icon(it.icon, size: 15, color: c.textMuted), const SizedBox(width: 5)],
          Flexible(child: Text(it.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: c.textSecondary))),
        ]);

    final body = horizontal
        ? Column(children: [
            for (var i = 0; i < items.length; i++)
              Container(
                padding: const EdgeInsets.symmetric(vertical: Space.s3),
                decoration: BoxDecoration(border: i == 0 ? null : Border(top: BorderSide(color: c.border))),
                child: Row(children: [label(items[i]), const SizedBox(width: 12), Expanded(child: Align(alignment: Alignment.centerRight, child: value(items[i])))]),
              ),
          ])
        : LayoutBuilder(builder: (context, cons) {
            final cols = cons.maxWidth < 360 ? 1 : (cons.maxWidth < 600 ? columns.clamp(1, 2) : columns);
            final w = (cons.maxWidth - (cols - 1) * 16) / cols;
            return Wrap(spacing: 16, runSpacing: 14, children: [
              for (final it in items)
                Container(
                  width: it.full ? cons.maxWidth : w,
                  padding: bordered ? const EdgeInsets.all(Space.s3) : EdgeInsets.zero,
                  decoration: bordered ? BoxDecoration(borderRadius: Radii.rm, border: Border.all(color: c.border)) : null,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    label(it),
                    const SizedBox(height: 4),
                    value(it),
                    if (it.hint != null) Text(it.hint!, style: TextStyle(fontSize: 11, color: c.textMuted)),
                  ]),
                ),
            ]);
          });
    if (title == null) return body;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
      Text(title!, style: context.t.cardTitle),
      const SizedBox(height: 8),
      body,
    ]);
  }
}

/// `<app-stat-counter>` : valeur animée de 0 à la cible.
class StatCounter extends StatelessWidget {
  const StatCounter({super.key, required this.value, this.compact = false, this.suffix = '', this.style, this.duration = const Duration(milliseconds: 1200)});
  final double value;
  final bool compact;
  final String suffix;
  final TextStyle? style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return TweenAnimationBuilder<double>(
      key: ValueKey(value),
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (_, v, _) => Text(
        '${compact ? Fmt.compact(v) : Fmt.number(v.round())}$suffix',
        style: style ?? TextStyle(fontFamily: Fonts.heading, fontSize: 26, fontWeight: FontWeight.w700, color: c.textPrimary, fontFeatures: KitText.tabular),
      ),
    );
  }
}

// ── Diff ───────────────────────────────────────────────────────────

enum DiffOp { same, add, del }

class DiffLine {
  const DiffLine(this.op, this.text, this.oldNo, this.newNo);
  final DiffOp op;
  final String text;
  final int? oldNo, newNo;
}

/// Diff ligne à ligne par plus longue sous-séquence commune (`diff.util.ts`).
List<DiffLine> diffLines(String a, String b) {
  final x = a.split('\n'), y = b.split('\n');
  final n = x.length, m = y.length;
  final dp = List.generate(n + 1, (_) => List.filled(m + 1, 0));
  for (var i = n - 1; i >= 0; i--) {
    for (var j = m - 1; j >= 0; j--) {
      dp[i][j] = x[i] == y[j] ? dp[i + 1][j + 1] + 1 : (dp[i + 1][j] >= dp[i][j + 1] ? dp[i + 1][j] : dp[i][j + 1]);
    }
  }
  final out = <DiffLine>[];
  var i = 0, j = 0;
  while (i < n && j < m) {
    if (x[i] == y[j]) {
      out.add(DiffLine(DiffOp.same, x[i], i + 1, j + 1));
      i++;
      j++;
    } else if (dp[i + 1][j] >= dp[i][j + 1]) {
      out.add(DiffLine(DiffOp.del, x[i], i + 1, null));
      i++;
    } else {
      out.add(DiffLine(DiffOp.add, y[j], null, j + 1));
      j++;
    }
  }
  while (i < n) {
    out.add(DiffLine(DiffOp.del, x[i], i + 1, null));
    i++;
  }
  while (j < m) {
    out.add(DiffLine(DiffOp.add, y[j], null, j + 1));
    j++;
  }
  return out;
}

/// `<app-text-diff>` : vue unifiée (adaptée au mobile), statistiques, lignes inchangées repliables.
class TextDiff extends StatefulWidget {
  const TextDiff({super.key, required this.before, required this.after, this.fileName, this.mono = false});
  final String before, after;
  final String? fileName;
  final bool mono;

  @override
  State<TextDiff> createState() => _TextDiffState();
}

class _TextDiffState extends State<TextDiff> {
  bool _collapse = false;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final lines = diffLines(widget.before, widget.after);
    final adds = lines.where((l) => l.op == DiffOp.add).length;
    final dels = lines.where((l) => l.op == DiffOp.del).length;
    final style = TextStyle(fontFamily: widget.mono ? Fonts.mono : null, fontSize: widget.mono ? 11.5 : 12.5, height: 1.5);
    return Container(
      decoration: BoxDecoration(borderRadius: Radii.rm, border: Border.all(color: c.border), color: c.card),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          color: c.tableHeader,
          padding: const EdgeInsets.fromLTRB(Space.s3, Space.s2, Space.s1, Space.s2),
          child: Row(children: [
            Icon(Icons.difference_outlined, size: 18, color: c.textSecondary),
            const SizedBox(width: 8),
            Expanded(child: Text(widget.fileName ?? 'Comparaison', style: TextStyle(fontFamily: Fonts.mono, fontSize: 12, color: c.textPrimary))),
            Text('+$adds', style: TextStyle(fontWeight: FontWeight.w700, color: c.successText, fontSize: 12)),
            const SizedBox(width: 6),
            Text('−$dels', style: TextStyle(fontWeight: FontWeight.w700, color: c.errorText, fontSize: 12)),
            IconButton(
              tooltip: _collapse ? 'Afficher tout' : 'Masquer les lignes identiques',
              iconSize: 18,
              onPressed: () => setState(() => _collapse = !_collapse),
              icon: Icon(_collapse ? Icons.unfold_more : Icons.unfold_less),
            ),
          ]),
        ),
        for (final l in lines)
          if (!_collapse || l.op != DiffOp.same)
            Container(
              color: switch (l.op) { DiffOp.add => c.successLight, DiffOp.del => c.errorLight, DiffOp.same => null },
              padding: const EdgeInsets.symmetric(vertical: Space.s0_5),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(
                  width: 30,
                  child: Text('${l.newNo ?? l.oldNo ?? ''}', textAlign: TextAlign.right, style: style.copyWith(color: c.textMuted, fontSize: 10.5, fontFamily: Fonts.mono)),
                ),
                SizedBox(
                  width: 20,
                  child: Text(switch (l.op) { DiffOp.add => '+', DiffOp.del => '−', DiffOp.same => '' }, textAlign: TextAlign.center, style: style.copyWith(fontWeight: FontWeight.w700, color: l.op == DiffOp.add ? c.successText : c.errorText)),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: Space.s2),
                    child: Text(l.text.isEmpty ? ' ' : l.text, style: style.copyWith(color: l.op == DiffOp.same ? c.textSecondary : c.textPrimary, decoration: l.op == DiffOp.del ? TextDecoration.lineThrough : null, decorationColor: c.errorText.withValues(alpha: 0.5))),
                  ),
                ),
              ]),
            ),
      ]),
    );
  }
}

// ── Audit log ──────────────────────────────────────────────────────

enum AuditAction { create, update, delete, status, comment, export, login }

class AuditChange {
  const AuditChange(this.label, this.before, this.after);
  final String label;
  final String? before, after;
}

class AuditEntry {
  const AuditEntry({required this.user, required this.action, required this.hoursAgo, this.target, this.changes = const [], this.comment, this.meta});
  final String user;
  final AuditAction action;
  final double hoursAgo;
  final String? target, comment, meta;
  final List<AuditChange> changes;
}

/// `<app-audit-log>` : fil d'activité groupé par jour, avant → après, filtres par type.
class AuditLog extends StatefulWidget {
  const AuditLog({super.key, required this.entries});
  final List<AuditEntry> entries;

  @override
  State<AuditLog> createState() => _AuditLogState();
}

class _AuditLogState extends State<AuditLog> {
  AuditAction? _filter;

  static (IconData, String, KitTone) _meta(AuditAction a) => switch (a) {
        AuditAction.create => (Icons.add_circle_outline, 'a créé', KitTone.success),
        AuditAction.update => (Icons.edit_outlined, 'a modifié', KitTone.info),
        AuditAction.delete => (Icons.delete_outline, 'a supprimé', KitTone.error),
        AuditAction.status => (Icons.published_with_changes, 'a changé le statut de', KitTone.purple),
        AuditAction.comment => (Icons.chat_bubble_outline, 'a commenté', KitTone.primary),
        AuditAction.export => (Icons.download_outlined, 'a exporté', KitTone.warning),
        AuditAction.login => (Icons.login, 's’est connecté', KitTone.neutral),
      };

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final now = DateTime.now();
    final list = widget.entries.where((e) => _filter == null || e.action == _filter).toList();
    final groups = <String, List<AuditEntry>>{};
    for (final e in list) {
      final d = now.subtract(Duration(minutes: (e.hoursAgo * 60).round()));
      final key = sameDayKey(d, now);
      (groups[key] ??= []).add(e);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          Padding(padding: const EdgeInsets.only(right: Space.s2), child: ChoiceChip(label: const Text('Tout'), selected: _filter == null, onSelected: (_) => setState(() => _filter = null))),
          for (final a in [AuditAction.update, AuditAction.status, AuditAction.create, AuditAction.comment, AuditAction.delete])
            Padding(
              padding: const EdgeInsets.only(right: Space.s2),
              child: ChoiceChip(
                avatar: Icon(_meta(a).$1, size: 16),
                label: Text(switch (a) { AuditAction.update => 'Modifs', AuditAction.status => 'Statuts', AuditAction.create => 'Créations', AuditAction.comment => 'Commentaires', _ => 'Suppressions' }),
                selected: _filter == a,
                onSelected: (_) => setState(() => _filter = _filter == a ? null : a),
              ),
            ),
        ]),
      ),
      const SizedBox(height: 12),
      if (list.isEmpty) const EmptyState(compact: true, icon: Icons.history, title: 'Aucune activité', subtitle: 'Aucune entrée pour ce filtre.'),
      for (final g in groups.entries) ...[
        Padding(
          padding: const EdgeInsets.only(bottom: Space.s2, top: Space.s1),
          child: Text(g.key.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: c.textMuted)),
        ),
        for (final e in g.value) _entry(c, e, now),
      ],
    ]);
  }

  static String sameDayKey(DateTime d, DateTime now) {
    final days = DateTime(now.year, now.month, now.day).difference(DateTime(d.year, d.month, d.day)).inDays;
    if (days == 0) return 'Aujourd’hui';
    if (days == 1) return 'Hier';
    return Fmt.weekday(d);
  }

  Widget _entry(KitColors c, AuditEntry e, DateTime now) {
    final (icon, verb, tone) = _meta(e.action);
    final at = now.subtract(Duration(minutes: (e.hoursAgo * 60).round()));
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.s4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Stack(clipBehavior: Clip.none, children: [
          KitAvatar(name: e.user, size: 34),
          Positioned(
            right: -4,
            bottom: -4,
            child: Container(
              padding: const EdgeInsets.all(Space.s0_5),
              decoration: BoxDecoration(color: c.card, shape: BoxShape.circle),
              child: Icon(icon, size: 13, color: tone.color(c)),
            ),
          ),
        ]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text.rich(
              TextSpan(children: [
                TextSpan(text: e.user, style: const TextStyle(fontWeight: FontWeight.w700)),
                TextSpan(text: ' $verb '),
                if (e.target != null) TextSpan(text: e.target, style: TextStyle(fontWeight: FontWeight.w600, color: c.primary)),
              ]),
              style: TextStyle(fontSize: 13, color: c.textPrimary, height: 1.4),
            ),
            Text('${Fmt.ago(at, now)} · ${Fmt.time(at)}${e.meta == null ? '' : ' · ${e.meta}'}', style: TextStyle(fontSize: 11.5, color: c.textMuted)),
            if (e.comment != null)
              Container(
                margin: const EdgeInsets.only(top: Space.s2),
                padding: const EdgeInsets.all(Space.s3),
                decoration: BoxDecoration(color: c.hover, borderRadius: const BorderRadius.only(topRight: Radius.circular(Radii.md), bottomLeft: Radius.circular(Radii.md), bottomRight: Radius.circular(Radii.md))),
                child: Text(e.comment!, style: TextStyle(fontSize: 12.5, height: 1.45, color: c.textPrimary)),
              ),
            for (final ch in e.changes)
              Padding(
                padding: const EdgeInsets.only(top: Space.s2),
                child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 6, runSpacing: 4, children: [
                  Text('${ch.label} :', style: TextStyle(fontSize: 12, color: c.textSecondary)),
                  if (ch.before != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: Space.s2, vertical: 1),
                      decoration: BoxDecoration(color: c.errorLight, borderRadius: Radii.rs),
                      child: Text(ch.before!, style: TextStyle(fontSize: 12, color: c.errorText, decoration: TextDecoration.lineThrough)),
                    ),
                  if (ch.before != null) Icon(Icons.arrow_forward, size: 14, color: c.textMuted),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: Space.s2, vertical: 1),
                    decoration: BoxDecoration(color: c.successLight, borderRadius: Radii.rs),
                    child: Text(ch.after ?? '—', style: TextStyle(fontSize: 12, color: c.successText, fontWeight: FontWeight.w600)),
                  ),
                ]),
              ),
          ]),
        ),
      ]),
    );
  }
}

/// `<app-qr-code>` : QR code + libellé + copie ; ou code-barres Code 128.
class QrBlock extends StatelessWidget {
  const QrBlock({super.key, required this.data, this.label, this.size = 150, this.withLogo = false});
  final String data;
  final String? label;
  final double size;
  final bool withLogo;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        padding: const EdgeInsets.all(Space.s3),
        decoration: BoxDecoration(color: Colors.white, borderRadius: Radii.rm, border: Border.all(color: c.border)),
        child: QrImageView(
          data: data,
          size: size,
          padding: EdgeInsets.zero,
          errorCorrectionLevel: withLogo ? QrErrorCorrectLevel.H : QrErrorCorrectLevel.M,
          eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF0F172A)),
          dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Color(0xFF0F172A)),
          embeddedImage: withLogo ? const AssetImage('assets/images/logo.png') : null,
          embeddedImageStyle: const QrEmbeddedImageStyle(size: Size(34, 34)),
        ),
      ),
      if (label != null) ...[
        const SizedBox(height: 8),
        Text(label!, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.textSecondary)),
      ],
    ]);
  }
}

class BarcodeBlock extends StatelessWidget {
  const BarcodeBlock({super.key, required this.data, this.width = 240});
  final String data;
  final double width;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return Container(
      padding: const EdgeInsets.all(Space.s3),
      decoration: BoxDecoration(color: Colors.white, borderRadius: Radii.rm, border: Border.all(color: c.border)),
      child: BarcodeWidget(
        barcode: Barcode.code128(),
        data: data,
        width: width,
        height: 80,
        color: const Color(0xFF0F172A),
        style: const TextStyle(fontFamily: Fonts.mono, fontSize: 12, color: Color(0xFF0F172A)),
      ),
    );
  }
}
