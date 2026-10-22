import 'dart:convert';

import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/snack.dart';
import '../theme/kit_colors.dart';
import '../theme/kit_text.dart';
import '../theme/tokens.dart';
import '../showcase/doc/doc.dart' show CodeBlock;
import '../widgets/charts.dart';
import '../widgets/common.dart';
import '../widgets/data_display.dart';
import '../widgets/fields/basic_fields.dart';
import '../widgets/fields/editors.dart';
import '../widgets/inputs.dart';
import '../widgets/map/kit_map.dart';
import '../widgets/map/map_models.dart';
import '../widgets/media/demo_art.dart';
import '../widgets/planning/planning_models.dart';
import '../widgets/planning/planning_views.dart';
import '../widgets/selects.dart';
import 'hz_models.dart';
import '../core/haptics.dart';

/// Rappels vers le store (réponses interactives, formulaires).
class HzActions {
  const HzActions({required this.onAnswer, required this.onSubmit, required this.busy});
  final void Function(HzW w, HzOption option) onAnswer;
  final void Function(HzW form, Map<String, dynamic> values, String summary) onSubmit;
  final bool busy;
}

/// Cadre commun d'un widget de réponse (carte avec en-tête icône / titre / sous-titre).
class HzFrame extends StatelessWidget {
  const HzFrame({super.key, required this.w, required this.child, this.padding = const EdgeInsets.fromLTRB(Space.s4, 0, Space.s4, Space.s4), this.trailing});
  final HzW w;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final hasHead = w.title != null;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: c.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
        if (hasHead)
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.s4, Space.s3, Space.s2, Space.s3),
            child: Row(children: [
              if (w.icon != null) ...[
                Container(width: 30, height: 30, decoration: BoxDecoration(color: c.primaryLight, borderRadius: BorderRadius.circular(Radii.md)), child: Icon(w.icon, size: 17, color: c.primary)),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(w.title!, style: TextStyle(fontFamily: Fonts.heading, fontWeight: FontWeight.w700, fontSize: 14.5, color: c.textPrimary)),
                  if (w.subtitle != null) Text(w.subtitle!, style: TextStyle(fontSize: 11.5, color: c.textMuted)),
                ]),
              ),
              ?trailing,
            ]),
          ),
        Padding(padding: hasHead ? padding : const EdgeInsets.all(Space.s4), child: child),
      ]),
    );
  }
}

/// Rendu d'un widget de réponse selon son type.
class HzWidgetView extends StatelessWidget {
  const HzWidgetView({super.key, required this.w, required this.actions});
  final HzW w;
  final HzActions actions;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final p = w.p;
    switch (w.type) {
      case 'stats':
        return _Stats(items: (p['items'] as List).cast<HzStat>());
      case 'chart':
        return HzFrame(
          w: w,
          child: KitChart(
            kind: p['kind'] as ChartKind,
            labels: (p['labels'] as List).cast<String>(),
            series: (p['series'] as List).cast<ChartSeries>(),
            unit: p['unit'] as String? ?? '',
            height: (p['kind'] == ChartKind.hbar) ? 190 : 200,
          ),
        );
      case 'table':
        return HzFrame(w: w, padding: EdgeInsets.zero, child: _HzTable(w: w));
      case 'map':
        return HzFrame(
          w: w,
          padding: EdgeInsets.zero,
          child: KitMap(height: 280, radius: 0, markers: (p['markers'] as List).cast<MapMarkerData>(), fitToContent: true, legend: (p['legend'] as List? ?? const []).cast<(String, KitTone)>()),
        );
      case 'form':
        return HzFrame(w: w, child: _HzForm(w: w, actions: actions));
      case 'choices':
        return _Choices(w: w, actions: actions);
      case 'records':
        return HzFrame(
          w: w,
          padding: const EdgeInsets.fromLTRB(Space.s2, 0, Space.s2, Space.s2),
          child: Column(children: [
            for (final r in (p['items'] as List).cast<HzRecord>())
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: Space.s2),
                leading: KitAvatar(name: r.title, tone: r.tone, size: 38),
                title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text([r.subtitle, r.meta].whereType<String>().join(' · ')),
                  if (r.tags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: Space.s1),
                      child: Wrap(spacing: 4, runSpacing: 4, children: [for (final t in r.tags) StatusBadge(t, uppercase: false)]),
                    ),
                ]),
                trailing: r.badge == null ? null : StatusBadge(r.badge!, tone: r.badgeTone, uppercase: false),
              ),
          ]),
        );
      case 'timeline':
        return HzFrame(
          w: w,
          child: KitTimeline(dense: true, items: [for (final t in (p['items'] as List).cast<HzTimelineItem>()) TimelineEntry(title: t.title, text: t.text, time: t.time, icon: t.icon, tone: t.tone)]),
        );
      case 'callout':
        final tone = p['tone'] as KitTone;
        return Container(
          padding: const EdgeInsets.all(Space.s3),
          decoration: BoxDecoration(color: tone.light(c), borderRadius: Radii.rm, border: Border(left: BorderSide(color: tone.color(c), width: 4))),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(p['icon'] as IconData, color: tone.color(c), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p['title'] as String, style: TextStyle(fontWeight: FontWeight.w700, color: tone.text(c))),
                const SizedBox(height: 2),
                Text(p['text'] as String, style: TextStyle(fontSize: 13, height: 1.45, color: c.textPrimary)),
              ]),
            ),
          ]),
        );
      case 'calendar':
        return HzFrame(w: w, child: MonthCalendar(items: (p['items'] as List).cast<PlanningItem>()));
      case 'kanban':
        return HzFrame(w: w, child: _HzKanban(w: w));
      case 'gantt':
        return HzFrame(w: w, child: GanttTimeline(items: (p['items'] as List).cast<PlanningItem>(), groups: (p['groups'] as List).cast<PlanningGroup>(), days: 18, dayWidth: 36, startOffset: -4));
      case 'agenda':
        return HzFrame(w: w, child: AgendaView(items: (p['items'] as List).cast<PlanningItem>()));
      case 'tree':
        return HzFrame(w: w, child: _HzTree(w: w, actions: actions));
      case 'carousel':
        return HzFrame(w: w, padding: const EdgeInsets.only(bottom: Space.s4), child: _HzCarousel(slides: (p['slides'] as List).cast<HzSlide>()));
      case 'modal':
        return HzFrame(
          w: w,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(p['summary'] as String, style: TextStyle(fontSize: 13, height: 1.45, color: c.textSecondary)),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonalIcon(
                onPressed: () => _openModal(context),
                icon: const Icon(Icons.open_in_full, size: 18),
                label: Text(p['button'] as String? ?? 'Ouvrir'),
              ),
            ),
          ]),
        );
      case 'tabs':
        return HzFrame(w: w, padding: EdgeInsets.zero, child: _HzTabs(w: w, actions: actions));
      case 'accordion':
        return HzFrame(
          w: w,
          padding: EdgeInsets.zero,
          child: Column(children: [
            for (final (title, icon, open, blocks) in (p['items'] as List).cast<(String, IconData, bool, List<HzW>)>())
              Theme(
                data: Theme.of(context).copyWith(dividerColor: c.border),
                child: ExpansionTile(
                  initiallyExpanded: open,
                  leading: Icon(icon, size: 20),
                  title: Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                  childrenPadding: const EdgeInsets.fromLTRB(Space.s4, 0, Space.s4, Space.s4),
                  children: [for (final b in blocks) Padding(padding: const EdgeInsets.only(bottom: Space.s2), child: HzWidgetView(w: b, actions: actions))],
                ),
              ),
          ]),
        );
      case 'steps':
        final steps = (p['steps'] as List).cast<HzStep>();
        return HzFrame(
          w: w,
          child: Column(children: [
            for (var i = 0; i < steps.length; i++)
              IntrinsicHeight(
                child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Column(children: [
                    _stepDot(c, steps[i].status, i),
                    if (i < steps.length - 1) Expanded(child: Container(width: 2, color: steps[i].status == 'done' ? c.primary : c.border)),
                  ]),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: Space.s1, bottom: Space.s3),
                      child: Row(children: [
                        Expanded(
                          child: Text(steps[i].label, style: TextStyle(fontWeight: steps[i].status == 'current' ? FontWeight.w700 : FontWeight.w500, color: steps[i].status == 'todo' ? c.textMuted : c.textPrimary)),
                        ),
                        if (steps[i].text != null) Text(steps[i].text!, style: TextStyle(fontSize: 12, color: c.textMuted)),
                      ]),
                    ),
                  ),
                ]),
              ),
          ]),
        );
      case 'keyvalue':
        return HzFrame(
          w: w,
          child: Column(children: [
            for (final kv in (p['items'] as List).cast<HzPair>())
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(children: [
                  if (kv.icon != null) ...[Icon(kv.icon, size: 16, color: kv.tone?.color(c) ?? c.textMuted), const SizedBox(width: 8)],
                  Expanded(child: Text(kv.label, style: TextStyle(fontSize: 12.5, color: c.textSecondary))),
                  Flexible(
                    child: Text(kv.value, textAlign: TextAlign.right, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: kv.mono ? Fonts.mono : null, color: kv.tone?.text(c) ?? c.textPrimary)),
                  ),
                  if (kv.copy) InkWell(onTap: () => copyToClipboard(context, kv.value), child: Padding(padding: const EdgeInsets.only(left: Space.s2), child: Icon(Icons.content_copy, size: 15, color: c.textMuted))),
                ]),
              ),
          ]),
        );
      case 'checklist':
        return HzFrame(w: w, child: _HzChecklist(items: (p['items'] as List).cast<(String, bool, String?)>()));
      case 'progress':
        return HzFrame(
          w: w,
          child: Column(children: [
            for (final m in (p['items'] as List).cast<HzMeter>())
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Space.s2),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Row(children: [
                    Expanded(child: Text(m.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                    Text('${Fmt.number(m.value)}${m.unit} / ${Fmt.number(m.target)}${m.unit}', style: TextStyle(fontSize: 12, color: c.textSecondary, fontFeatures: KitText.tabular)),
                  ]),
                  const SizedBox(height: 5),
                  KitProgressBar(value: m.value / m.target, tone: m.tone, height: 7),
                ]),
              ),
          ]),
        );
      case 'diff':
        return HzFrame(w: w, child: TextDiff(before: p['before'] as String, after: p['after'] as String, fileName: p['file'] as String, mono: true));
      case 'json':
        return HzFrame(
          w: w,
          trailing: IconButton(tooltip: 'Copier', iconSize: 18, onPressed: () => copyToClipboard(context, const JsonEncoder.withIndent('  ').convert(p['data']), label: 'JSON copié'), icon: const Icon(Icons.content_copy)),
          child: Container(
            padding: const EdgeInsets.all(Space.s2),
            decoration: BoxDecoration(color: c.hover.withValues(alpha: 0.6), borderRadius: Radii.rm),
            child: _JsonNode(name: null, value: p['data'], depth: 0),
          ),
        );
      case 'sources':
        return HzFrame(
          w: w,
          child: Column(children: [
            for (final (i, s) in (p['items'] as List).cast<HzSource>().indexed)
              InkWell(
                onTap: () => demoAction(context, 'Ouverture de ${s.site}'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: Space.s2),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    CircleAvatar(radius: 11, backgroundColor: c.primaryLight, child: Text('${i + 1}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c.primary))),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('${s.site}${s.date == null ? '' : ' · ${s.date}'}', style: TextStyle(fontSize: 11, color: c.textMuted)),
                        Text(s.title, style: TextStyle(fontWeight: FontWeight.w600, color: c.primary)),
                        if (s.snippet != null) Text(s.snippet!, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: c.textSecondary)),
                      ]),
                    ),
                  ]),
                ),
              ),
          ]),
        );
      case 'tags':
        return HzFrame(
          w: w,
          child: Wrap(spacing: 6, runSpacing: 6, children: [
            for (final (label, count, tone) in (p['items'] as List).cast<(String, int?, KitTone?)>())
              Container(
                padding: const EdgeInsets.symmetric(horizontal: Space.s3, vertical: 5),
                decoration: BoxDecoration(color: (tone ?? KitTone.neutral).light(c), borderRadius: Radii.pill),
                child: Text(count == null ? label : '$label · $count', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: (tone ?? KitTone.neutral).text(c))),
              ),
          ]),
        );
      case 'heatmap':
        return HzFrame(w: w, child: _Heatmap(rows: (p['rows'] as List).cast<String>(), cols: (p['cols'] as List).cast<String>(), values: (p['values'] as List).cast<List<double>>(), unit: p['unit'] as String? ?? ''));
      case 'files':
        return HzFrame(
          w: w,
          padding: const EdgeInsets.fromLTRB(Space.s1, 0, Space.s1, Space.s2),
          child: Column(children: [
            for (final f in (p['items'] as List).cast<HzFile>())
              ListTile(
                dense: true,
                leading: Icon(switch (f.ext) { 'pdf' => Icons.picture_as_pdf, 'csv' || 'xls' => Icons.table_view, _ => Icons.insert_drive_file }, color: f.ext == 'pdf' ? c.error : c.success),
                title: Text(f.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text([f.size, f.date, f.by].whereType<String>().join(' · ')),
                trailing: IconButton(onPressed: () => demoAction(context, 'Téléchargement de ${f.name}'), icon: const Icon(Icons.download_outlined)),
              ),
          ]),
        );
      case 'cards':
        return HzFrame(
          w: w,
          child: SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: (p['items'] as List).length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final card = (p['items'] as List).cast<HzCard>()[i];
                return Container(
                  width: 170,
                  padding: const EdgeInsets.all(Space.s3),
                  decoration: BoxDecoration(borderRadius: Radii.rm, border: Border.all(color: c.border), color: c.bg),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(width: 32, height: 32, decoration: BoxDecoration(color: card.tone.light(c), borderRadius: BorderRadius.circular(Radii.md)), child: Icon(card.icon, size: 18, color: card.tone.color(c))),
                      const Spacer(),
                      if (card.meta != null) Text(card.meta!, style: TextStyle(fontSize: 11, color: c.textMuted)),
                    ]),
                    const SizedBox(height: 8),
                    Text(card.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                    if (card.text != null) Text(card.text!, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11.5, color: c.textSecondary)),
                    const Spacer(),
                    Row(children: [
                      Expanded(child: Text(card.price ?? '', style: TextStyle(fontWeight: FontWeight.w800, color: c.primary, fontSize: 13))),
                      if (card.cta != null) IconButton.filledTonal(visualDensity: VisualDensity.compact, iconSize: 18, onPressed: () => showKitSnack(context, '${card.title} ajouté au devis'), icon: const Icon(Icons.add)),
                    ]),
                  ]),
                );
              },
            ),
          ),
        );
      case 'compare':
        return HzFrame(w: w, padding: const EdgeInsets.fromLTRB(0, 0, 0, Space.s3), child: _Compare(w: w));
      case 'approval':
        return _Approval(w: w, actions: actions);
      case 'upload':
        return HzFrame(w: w, child: _Upload(w: w, actions: actions));
      case 'paragraph':
        return Text.rich(TextSpan(children: markdownInline(p['text'] as String, KitText.body, c)), style: TextStyle(fontSize: 13.5, height: 1.55, color: c.textPrimary));
      default:
        return Text('Widget « ${w.type} » non pris en charge', style: TextStyle(color: c.textMuted));
    }
  }

  void _openModal(BuildContext context) {
    final p = w.p;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        builder: (ctx, sc) => ListView(controller: sc, padding: const EdgeInsets.fromLTRB(Space.s4, 0, Space.s4, Space.s6), children: [
          Text(p['dialogTitle'] as String, style: ctx.t.h3),
          if (p['dialogSubtitle'] != null) Text(p['dialogSubtitle'] as String, style: ctx.t.bodySm),
          const SizedBox(height: 14),
          for (final b in (p['blocks'] as List).cast<HzW>()) Padding(padding: const EdgeInsets.only(bottom: Space.s3), child: HzWidgetView(w: b, actions: actions)),
        ]),
      ),
    );
  }

  Widget _stepDot(KitColors c, String status, int i) => Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: switch (status) { 'done' => c.primary, 'current' => c.primaryLight, 'error' => c.error, _ => c.fieldBg },
          border: Border.all(color: status == 'todo' ? c.border : (status == 'error' ? c.error : c.primary), width: 2),
        ),
        child: status == 'done'
            ? Icon(Icons.check, size: 14, color: c.onPrimary)
            : status == 'error'
                ? const Icon(Icons.close, size: 14, color: Colors.white)
                : Text('${i + 1}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: status == 'current' ? c.primary : c.textMuted)),
      );
}

class _Stats extends StatelessWidget {
  const _Stats({required this.items});
  final List<HzStat> items;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return ResponsiveGrid(minItemWidth: 150, spacing: 8, children: [
      for (final s in items)
        Container(
          padding: const EdgeInsets.all(Space.s3),
          decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(Radii.lg), border: Border.all(color: c.border)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              if (s.icon != null) Icon(s.icon, size: 16, color: s.tone.color(c)),
              const SizedBox(width: 6),
              Expanded(child: Text(s.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11.5, color: c.textSecondary))),
            ]),
            const SizedBox(height: 4),
            Text(s.value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: Fonts.heading, fontSize: 20, fontWeight: FontWeight.w700, color: c.textPrimary)),
            Row(children: [
              if (s.delta != null) Flexible(child: TrendChip(s.delta!, up: s.up ?? true, goodWhenUp: s.tone != KitTone.error && s.tone != KitTone.warning)),
              if (s.hint != null) ...[const SizedBox(width: 4), Flexible(child: Text(s.hint!, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: c.textMuted)))],
            ]),
            if (s.spark != null) ...[const SizedBox(height: 6), Sparkline(s.spark!, color: s.tone.color(c), height: 26)],
          ]),
        ),
    ]);
  }
}

class _HzTable extends StatefulWidget {
  const _HzTable({required this.w});
  final HzW w;

  @override
  State<_HzTable> createState() => _HzTableState();
}

class _HzTableState extends State<_HzTable> {
  String _q = '';
  String? _sort;
  bool _asc = true;
  int _page = 1;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final cols = (widget.w.p['columns'] as List).cast<HzColumn>();
    var rows = (widget.w.p['rows'] as List).cast<Map<String, Object>>().toList();
    final pageSize = widget.w.p['pageSize'] as int? ?? 100;
    if (_q.isNotEmpty) rows = rows.where((r) => r.values.any((v) => '$v'.toLowerCase().contains(_q.toLowerCase()))).toList();
    if (_sort != null) {
      rows.sort((a, b) {
        final x = a[_sort], y = b[_sort];
        final r = x is num && y is num ? x.compareTo(y) : '$x'.compareTo('$y');
        return _asc ? r : -r;
      });
    }
    final pages = (rows.length / pageSize).ceil().clamp(1, 999);
    if (_page > pages) _page = pages;
    final shown = rows.skip((_page - 1) * pageSize).take(pageSize).toList();

    Widget cell(HzColumn col, Object? v) => switch (col.kind) {
          'person' => Row(children: [KitAvatar(name: '$v', size: 24), const SizedBox(width: 6), Flexible(child: Text('$v', overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)))]),
          'number' => Text('${Fmt.number(v as num)}${col.unit}', style: const TextStyle(fontFeatures: KitText.tabular)),
          'badge' => StatusBadge('$v', tone: col.tones['$v'] ?? KitTone.neutral, uppercase: false),
          'progress' => Row(children: [Expanded(child: KitProgressBar(value: (v as num) / 100, tone: v >= 80 ? KitTone.success : (v >= 40 ? KitTone.warning : KitTone.error))), const SizedBox(width: 6), Text('$v %', style: const TextStyle(fontSize: 11.5))]),
          'mono' => Text('$v', style: const TextStyle(fontFamily: Fonts.mono, fontSize: 12)),
          _ => Text('$v'),
        };
    double width(HzColumn col) => switch (col.kind) { 'person' => 190, 'progress' => 140, 'badge' => 120, 'number' => 120, _ => 110 };

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (widget.w.p['searchable'] == true)
        Padding(
          padding: const EdgeInsets.fromLTRB(Space.s3, 0, Space.s3, Space.s2),
          child: TextField(onChanged: (v) => setState(() => _q = v), decoration: const InputDecoration(hintText: 'Filtrer…', prefixIcon: Icon(Icons.search, size: 18))),
        ),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            color: c.tableHeader,
            child: Row(children: [
              for (final col in cols)
                InkWell(
                  onTap: () => setState(() {
                    if (_sort == col.key) {
                      _asc = !_asc;
                    } else {
                      _sort = col.key;
                      _asc = true;
                    }
                  }),
                  child: Container(
                    width: width(col),
                    padding: const EdgeInsets.symmetric(horizontal: Space.s3, vertical: Space.s3),
                    child: Row(children: [
                      Flexible(child: Text(col.label.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.4, color: _sort == col.key ? c.primary : c.textSecondary))),
                      if (_sort == col.key) Icon(_asc ? Icons.arrow_upward : Icons.arrow_downward, size: 13, color: c.primary),
                    ]),
                  ),
                ),
            ]),
          ),
          for (final r in shown)
            Container(
              decoration: BoxDecoration(border: Border(top: BorderSide(color: c.border))),
              child: Row(children: [
                for (final col in cols)
                  Container(width: width(col), padding: const EdgeInsets.symmetric(horizontal: Space.s3, vertical: 9), child: DefaultTextStyle.merge(style: const TextStyle(fontSize: 12.5), child: cell(col, r[col.key]))),
              ]),
            ),
        ]),
      ),
      if (rows.isEmpty) Padding(padding: const EdgeInsets.all(Space.s4), child: Text('Aucune ligne', textAlign: TextAlign.center, style: TextStyle(color: c.textMuted))),
      if (pages > 1)
        Padding(
          padding: const EdgeInsets.fromLTRB(Space.s3, Space.s1, Space.s1, Space.s1),
          child: Row(children: [
            Expanded(child: Text('${rows.length} lignes', style: TextStyle(fontSize: 12, color: c.textMuted))),
            IconButton(visualDensity: VisualDensity.compact, onPressed: _page > 1 ? () => setState(() => _page--) : null, icon: const Icon(Icons.chevron_left)),
            Text('$_page / $pages', style: const TextStyle(fontSize: 12.5)),
            IconButton(visualDensity: VisualDensity.compact, onPressed: _page < pages ? () => setState(() => _page++) : null, icon: const Icon(Icons.chevron_right)),
          ]),
        ),
    ]);
  }
}

class _HzKanban extends StatefulWidget {
  const _HzKanban({required this.w});
  final HzW w;

  @override
  State<_HzKanban> createState() => _HzKanbanState();
}

class _HzKanbanState extends State<_HzKanban> {
  late List<PlanningItem> _items = (widget.w.p['items'] as List).cast<PlanningItem>().toList();

  @override
  Widget build(BuildContext context) => KanbanBoard(
        height: 330,
        columns: (widget.w.p['columns'] as List).cast<PlanningColumn>(),
        items: _items,
        onMove: (it, s) => setState(() {
          _items = [for (final x in _items) x.id == it.id ? x.copyWith(status: s, done: s == 'done') : x];
          widget.w.p['items'] = _items;
        }),
      );
}

class _HzForm extends StatefulWidget {
  const _HzForm({required this.w, required this.actions});
  final HzW w;
  final HzActions actions;

  @override
  State<_HzForm> createState() => _HzFormState();
}

class _HzFormState extends State<_HzForm> {
  late final List<HzField> _fields = (widget.w.p['fields'] as List).cast<HzField>();
  late final Map<String, dynamic> _v = widget.w.submitted != null
      ? {...widget.w.submitted!}
      : {
          for (final f in _fields)
            if (f.value != null) f.key: f.value is List ? [...(f.value! as List)] : f.value,
        };
  final Set<String> _errors = {};

  bool get _readOnly => widget.w.submitted != null;

  String _describe(HzField f, Object? v) {
    if (v == null || v == '') return '—';
    if (v is DateTime) return Fmt.date(v);
    if (v is bool) return v ? 'oui' : 'non';
    String label(Object? x) => f.options.where((o) => o.value == x).firstOrNull?.label ?? '$x';
    if (v is List) return v.isEmpty ? '—' : v.map(label).join(', ');
    if (f.kind == 'rating') return '${(v as num).round()} / 5';
    if (f.kind == 'slider') return '${(v as num).round()}${f.unit ?? ''}';
    return label(v) + (f.kind == 'number' ? (f.unit ?? '') : '');
  }

  void _submit() {
    setState(() {
      _errors
        ..clear()
        ..addAll(_fields.where((f) => f.required && (_v[f.key] == null || _v[f.key] == '')).map((f) => f.key));
    });
    if (_errors.isNotEmpty) return;
    final summary = _fields.where((f) => _v[f.key] != null && _v[f.key] != '').map((f) => '${f.label} : ${_describe(f, _v[f.key])}').join('\n');
    widget.actions.onSubmit(widget.w, Map.of(_v), summary);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final desc = widget.w.p['description'] as String?;
    return AbsorbPointer(
      absorbing: _readOnly,
      child: Opacity(
        opacity: _readOnly ? 0.75 : 1,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (desc != null) ...[Text(desc, style: TextStyle(fontSize: 13, color: c.textSecondary)), const SizedBox(height: 12)],
          for (final f in _fields) Padding(padding: const EdgeInsets.only(bottom: Space.s3), child: _field(c, f)),
          if (_readOnly)
            Row(children: [Icon(Icons.check_circle, color: c.success, size: 18), const SizedBox(width: 6), Text('Envoyé', style: TextStyle(color: c.successText, fontWeight: FontWeight.w700))])
          else
            FilledButton.icon(
              onPressed: widget.actions.busy ? null : _submit,
              icon: const Icon(Icons.send, size: 18),
              label: Text(widget.w.p['submitLabel'] as String? ?? 'Envoyer'),
            ),
        ]),
      ),
    );
  }

  Widget _field(KitColors c, HzField f) {
    final err = _errors.contains(f.key) ? 'Champ obligatoire' : null;
    void set(Object? v) => setState(() {
          _v[f.key] = v;
          _errors.remove(f.key);
        });
    final Widget input = switch (f.kind) {
      'select' => SearchableSelect<String>(options: [for (final o in f.options) SelectOption(o.value, o.label, icon: o.icon)], value: _v[f.key] as String?, icon: f.icon, error: err, onChanged: set, sheetTitle: f.label),
      'date' => DateField(value: _v[f.key] as DateTime?, error: err, onChanged: set),
      'segmented' => SegmentedButton<String>(
          showSelectedIcon: false,
          segments: [for (final o in f.options) ButtonSegment(value: o.value, label: Text(o.label, overflow: TextOverflow.ellipsis), icon: o.icon == null ? null : Icon(o.icon, size: 16))],
          selected: {_v[f.key] as String? ?? f.options.first.value},
          onSelectionChanged: (s) => set(s.first),
        ),
      'radio' => RadioGroup<String>(
          groupValue: _v[f.key] as String?,
          onChanged: set,
          child: Wrap(spacing: 4, children: [
            for (final o in f.options)
              Row(mainAxisSize: MainAxisSize.min, children: [Radio<String>(value: o.value), Text(o.label), const SizedBox(width: 6)]),
          ]),
        ),
      'chips' => Wrap(spacing: 6, runSpacing: 6, children: [
          for (final o in f.options)
            FilterChip(
              label: Text(o.label),
              selected: (_v[f.key] as List? ?? const []).contains(o.value),
              onSelected: (s) {
                final l = [...(_v[f.key] as List? ?? const [])];
                s ? l.add(o.value) : l.remove(o.value);
                set(l);
              },
            ),
        ]),
      'slider' => Row(children: [
          Expanded(
            child: Slider(
              value: ((_v[f.key] as num?) ?? f.min ?? 0).toDouble(),
              min: f.min ?? 0,
              max: f.max ?? 100,
              divisions: f.step == null ? null : ((f.max! - f.min!) / f.step!).round(),
              onChanged: set,
            ),
          ),
          Text(_describe(f, _v[f.key]), style: const TextStyle(fontWeight: FontWeight.w700)),
        ]),
      'toggle' => SwitchListTile(contentPadding: EdgeInsets.zero, title: Text(f.label), value: _v[f.key] == true, onChanged: withHaptic(set)),
      'checkbox' => CheckboxListTile(contentPadding: EdgeInsets.zero, controlAffinity: ListTileControlAffinity.leading, title: Text(f.label), value: _v[f.key] == true, onChanged: set),
      'rating' => RatingInput(value: ((_v[f.key] as num?) ?? 0).toDouble(), onChanged: set, labels: const ['Mauvais', 'Passable', 'Correct', 'Très bien', 'Excellent']),
      'textarea' => TextFormField(initialValue: _v[f.key] as String?, maxLines: 3, minLines: 2, onChanged: set, decoration: InputDecoration(hintText: f.placeholder)),
      _ => TextFormField(initialValue: _v[f.key] as String?, onChanged: set, decoration: InputDecoration(hintText: f.placeholder, prefixIcon: f.icon == null ? null : Icon(f.icon, size: 20), errorText: err)),
    };
    if (f.kind == 'toggle' || f.kind == 'checkbox') return input;
    return FormFieldLabel(label: f.label, required: f.required, child: input);
  }
}

class _Choices extends StatelessWidget {
  const _Choices({required this.w, required this.actions});
  final HzW w;
  final HzActions actions;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final opts = (w.p['options'] as List).cast<HzOption>();
    final done = w.selected != null;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (w.p['question'] != null) Padding(padding: const EdgeInsets.only(bottom: Space.s2), child: Text(w.p['question'] as String, style: TextStyle(fontWeight: FontWeight.w600, color: c.textPrimary))),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final o in opts)
          ChoiceChip(
            avatar: o.icon == null ? null : Icon(o.icon, size: 16),
            label: Text(o.label),
            selected: w.selected == o.value,
            showCheckmark: false,
            onSelected: done || actions.busy ? null : (_) => actions.onAnswer(w, o),
          ),
      ]),
    ]);
  }
}

class _HzTree extends StatefulWidget {
  const _HzTree({required this.w, required this.actions});
  final HzW w;
  final HzActions actions;

  @override
  State<_HzTree> createState() => _HzTreeState();
}

class _HzTreeState extends State<_HzTree> {
  final Set<String> _sel = {'c1', 'f1'};
  final Set<String> _open = {'contrats', 'factures'};

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final nodes = (widget.w.p['nodes'] as List).cast<HzTreeNode>();
    final done = widget.w.selected != null;
    final all = [for (final n in nodes) ...n.leaves];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (final n in nodes) ..._node(c, n, 0, done),
      const SizedBox(height: 8),
      if (!done)
        FilledButton.icon(
          onPressed: _sel.isEmpty || widget.actions.busy
              ? null
              : () => widget.actions.onAnswer(widget.w, HzOption('tree', '${_sel.length} pièce(s) : ${all.where((l) => _sel.contains(l.id)).map((l) => l.label).join(', ')}')),
          icon: const Icon(Icons.summarize, size: 18),
          label: Text(widget.w.p['submitLabel'] as String? ?? 'Valider'),
        )
      else
        Text('Sélection envoyée', style: TextStyle(color: c.successText, fontWeight: FontWeight.w700)),
    ]);
  }

  List<Widget> _node(KitColors c, HzTreeNode n, int depth, bool done) {
    final leaf = n.children.isEmpty;
    final open = _open.contains(n.id);
    final ids = n.leaves.map((e) => e.id).toList();
    final count = ids.where(_sel.contains).length;
    final state = count == 0 ? false : (count == ids.length ? true : null);
    return [
      InkWell(
        onTap: leaf ? null : () => setState(() => open ? _open.remove(n.id) : _open.add(n.id)),
        child: Padding(
          padding: EdgeInsets.only(left: depth * 18.0),
          child: Row(children: [
            SizedBox(width: 22, child: leaf ? null : Icon(open ? Icons.expand_more : Icons.chevron_right, size: 18, color: c.textSecondary)),
            Checkbox(
              visualDensity: VisualDensity.compact,
              tristate: !leaf,
              value: state,
              onChanged: done ? null : (_) => setState(() => state == true ? _sel.removeAll(ids) : _sel.addAll(ids)),
            ),
            Icon(n.icon, size: 17, color: leaf ? c.textSecondary : c.warning),
            const SizedBox(width: 6),
            Expanded(child: Text(n.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, fontWeight: leaf ? FontWeight.w400 : FontWeight.w600))),
            if (n.badge != null) Flexible(child: StatusBadge(n.badge!, tone: n.badgeTone, uppercase: false)),
            if (n.meta != null) Flexible(child: Padding(padding: const EdgeInsets.only(left: Space.s2), child: Text(n.meta!, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: c.textMuted)))),
          ]),
        ),
      ),
      if (open && !leaf) for (final ch in n.children) ..._node(c, ch, depth + 1, done),
    ];
  }
}

class _HzCarousel extends StatefulWidget {
  const _HzCarousel({required this.slides});
  final List<HzSlide> slides;

  @override
  State<_HzCarousel> createState() => _HzCarouselState();
}

class _HzCarouselState extends State<_HzCarousel> {
  final _pc = PageController(viewportFraction: 0.86);
  int _i = 0;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return Column(children: [
      SizedBox(
        height: 230,
        child: PageView.builder(
          controller: _pc,
          itemCount: widget.slides.length,
          onPageChanged: (i) => setState(() => _i = i),
          itemBuilder: (_, i) {
            final s = widget.slides[i];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Container(
                decoration: BoxDecoration(borderRadius: Radii.rm, border: Border.all(color: c.border), color: c.bg),
                clipBehavior: Clip.antiAlias,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  SizedBox(
                    height: 84,
                    child: Stack(fit: StackFit.expand, children: [
                      Container(color: s.tone.light(c)),
                      if (s.image != null) Image.asset(s.image!, fit: BoxFit.contain) else Icon(s.icon, size: 40, color: s.tone.color(c)),
                      if (s.tag != null) Positioned(left: 8, top: 8, child: StatusBadge(s.tag!, tone: s.tone, uppercase: false)),
                    ]),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(Space.s3),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(s.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                        if (s.text != null) Expanded(child: Text(s.text!, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: c.textSecondary))),
                        Wrap(spacing: 12, children: [
                          for (final (l, v) in s.stats) Text.rich(TextSpan(text: '$l : ', children: [TextSpan(text: v, style: const TextStyle(fontWeight: FontWeight.w700))]), style: TextStyle(fontSize: 11.5, color: c.textSecondary)),
                        ]),
                      ]),
                    ),
                  ),
                ]),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        for (var i = 0; i < widget.slides.length; i++)
          AnimatedContainer(duration: const Duration(milliseconds: 200), margin: const EdgeInsets.symmetric(horizontal: Space.s1), width: i == _i ? 18 : 6, height: 6, decoration: BoxDecoration(color: i == _i ? c.primary : c.border, borderRadius: Radii.pill)),
      ]),
    ]);
  }
}

class _HzTabs extends StatelessWidget {
  const _HzTabs({required this.w, required this.actions});
  final HzW w;
  final HzActions actions;

  @override
  Widget build(BuildContext context) {
    final tabs = (w.p['tabs'] as List).cast<(String, IconData, String?, List<HzW>)>();
    return DefaultTabController(
      length: tabs.length,
      child: Builder(builder: (context) {
        final ctrl = DefaultTabController.of(context);
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              for (final (l, i, b, _) in tabs)
                Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(i, size: 16), const SizedBox(width: 6), Text(l), if (b != null) ...[const SizedBox(width: 6), CountDot(int.parse(b), tone: KitTone.error)]])),
            ],
          ),
          AnimatedBuilder(
            animation: ctrl,
            builder: (_, _) => Padding(
              padding: const EdgeInsets.all(Space.s3),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                for (final b in tabs[ctrl.index].$4) Padding(padding: const EdgeInsets.only(bottom: Space.s3), child: HzWidgetView(w: b, actions: actions)),
              ]),
            ),
          ),
        ]);
      }),
    );
  }
}

class _HzChecklist extends StatefulWidget {
  const _HzChecklist({required this.items});
  final List<(String, bool, String?)> items;

  @override
  State<_HzChecklist> createState() => _HzChecklistState();
}

class _HzChecklistState extends State<_HzChecklist> {
  late final List<bool> _done = [for (final i in widget.items) i.$2];

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final n = _done.where((d) => d).length;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Expanded(child: KitProgressBar(value: n / _done.length, tone: n == _done.length ? KitTone.success : KitTone.primary)),
        const SizedBox(width: 8),
        Text('$n / ${_done.length}', style: TextStyle(fontSize: 12, color: c.textSecondary)),
      ]),
      for (var i = 0; i < widget.items.length; i++)
        CheckboxListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: _done[i],
          onChanged: (v) => setState(() => _done[i] = v!),
          title: Text(widget.items[i].$1, style: TextStyle(decoration: _done[i] ? TextDecoration.lineThrough : null, color: _done[i] ? c.textMuted : c.textPrimary)),
          subtitle: widget.items[i].$3 == null ? null : Text(widget.items[i].$3!),
        ),
    ]);
  }
}

class _Heatmap extends StatelessWidget {
  const _Heatmap({required this.rows, required this.cols, required this.values, required this.unit});
  final List<String> rows, cols;
  final List<List<double>> values;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final max = values.expand((r) => r).reduce((a, b) => a > b ? a : b);
    return Column(children: [
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(children: [
          Row(children: [
            const SizedBox(width: 34),
            for (var j = 0; j < cols.length; j++) SizedBox(width: 26, child: Text(j.isEven ? cols[j] : '', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: c.textMuted))),
          ]),
          for (var i = 0; i < rows.length; i++)
            Row(children: [
              SizedBox(width: 34, child: Text(rows[i], style: TextStyle(fontSize: 11, color: c.textSecondary))),
              for (var j = 0; j < cols.length; j++)
                Tooltip(
                  message: '${rows[i]} ${cols[j]} : ${values[i][j].round()}$unit',
                  triggerMode: TooltipTriggerMode.tap,
                  child: Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(color: c.primary.withValues(alpha: 0.08 + 0.85 * values[i][j] / max), borderRadius: BorderRadius.circular(5)),
                  ),
                ),
            ]),
        ]),
      ),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        Text('Faible', style: TextStyle(fontSize: 11, color: c.textMuted)),
        const SizedBox(width: 6),
        for (final a in const [0.1, 0.3, 0.5, 0.7, 0.9]) Container(width: 14, height: 10, margin: const EdgeInsets.symmetric(horizontal: 1), decoration: BoxDecoration(color: c.primary.withValues(alpha: a), borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 6),
        Text('Fort', style: TextStyle(fontSize: 11, color: c.textMuted)),
      ]),
    ]);
  }
}

class _Compare extends StatelessWidget {
  const _Compare({required this.w});
  final HzW w;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final plans = (w.p['plans'] as List).cast<(String, String, String?, bool)>();
    final feats = (w.p['features'] as List).cast<(String, List<Object>)>();
    const fw = 128.0, pw = 104.0;
    Widget val(Object v) => v is bool ? Icon(v ? Icons.check_circle : Icons.remove, size: 18, color: v ? c.success : c.textMuted) : Text('$v', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12));
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          const SizedBox(width: fw),
          for (final (name, price, note, rec) in plans)
            Container(
              width: pw,
              padding: const EdgeInsets.symmetric(vertical: Space.s2, horizontal: Space.s1),
              decoration: BoxDecoration(color: rec ? c.primaryLight : null, borderRadius: const BorderRadius.vertical(top: Radius.circular(Radii.md))),
              child: Column(children: [
                if (rec) const StatusBadge('Recommandé', tone: KitTone.primary, uppercase: false),
                Text(name, style: TextStyle(fontWeight: FontWeight.w700, color: rec ? c.primary : c.textPrimary)),
                Text(price, style: const TextStyle(fontFamily: Fonts.heading, fontWeight: FontWeight.w700)),
                if (note != null) Text(note, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: c.textMuted)),
              ]),
            ),
        ]),
        for (final (label, values) in feats)
          Container(
            decoration: BoxDecoration(border: Border(top: BorderSide(color: c.border))),
            child: Row(children: [
              SizedBox(width: fw, child: Padding(padding: const EdgeInsets.fromLTRB(Space.s4, Space.s2, Space.s2, Space.s2), child: Text(label, style: TextStyle(fontSize: 12.5, color: c.textSecondary)))),
              for (var i = 0; i < values.length; i++) Container(width: pw, color: plans[i].$4 ? c.primaryLight : null, padding: const EdgeInsets.symmetric(vertical: Space.s2), alignment: Alignment.center, child: val(values[i])),
            ]),
          ),
      ]),
    );
  }
}

class _Approval extends StatelessWidget {
  const _Approval({required this.w, required this.actions});
  final HzW w;
  final HzActions actions;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final risk = w.p['risk'] as KitTone? ?? KitTone.warning;
    final sel = w.selected;
    return Container(
      padding: const EdgeInsets.all(Space.s4),
      decoration: BoxDecoration(color: risk.light(c), borderRadius: BorderRadius.circular(18), border: Border.all(color: risk.color(c).withValues(alpha: 0.4))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Icon(Icons.shield_outlined, color: risk.color(c)),
          const SizedBox(width: 8),
          Expanded(child: Text(w.p['title'] as String, style: TextStyle(fontWeight: FontWeight.w700, color: c.textPrimary))),
        ]),
        const SizedBox(height: 6),
        Text(w.p['text'] as String, style: TextStyle(fontSize: 13, color: c.textSecondary)),
        if (w.p['command'] != null) ...[
          const SizedBox(height: 10),
          CodeBlock(code: '\$ ${w.p['command']}', rounded: true),
        ],
        const SizedBox(height: 10),
        if (sel != null)
          Row(children: [
            Icon(sel == 'approve' ? Icons.check_circle : Icons.cancel, size: 18, color: sel == 'approve' ? c.success : c.error),
            const SizedBox(width: 6),
            Text(sel == 'approve' ? 'Autorisé' : 'Refusé', style: TextStyle(fontWeight: FontWeight.w700, color: sel == 'approve' ? c.successText : c.errorText)),
          ])
        else
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: actions.busy ? null : () => actions.onAnswer(w, const HzOption('deny', 'Refuser')), child: const Text('Refuser'))),
            const SizedBox(width: 10),
            Expanded(child: FilledButton(onPressed: actions.busy ? null : () => actions.onAnswer(w, const HzOption('approve', 'Autoriser')), child: const Text('Autoriser'))),
          ]),
      ]),
    );
  }
}

class _Upload extends StatelessWidget {
  const _Upload({required this.w, required this.actions});
  final HzW w;
  final HzActions actions;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    if (w.selected != null) {
      return Row(children: [Icon(Icons.check_circle, color: c.success), const SizedBox(width: 8), Expanded(child: Text(w.selected!, style: const TextStyle(fontWeight: FontWeight.w600)))]);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      CustomPaint(
        painter: DashedBorderPainter(color: c.primary.withValues(alpha: 0.5), radius: Radii.m),
        child: InkWell(
          borderRadius: Radii.rm,
          onTap: actions.busy
              ? null
              : () async {
                  final f = await pickDemoFile(context, title: 'Fichier à analyser');
                  if (f != null) actions.onAnswer(w, HzOption(f.name, f.name));
                },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 22),
            child: Column(children: [
              Icon(Icons.cloud_upload_outlined, size: 34, color: c.primary),
              const SizedBox(height: 6),
              Text('Choisir un fichier', style: TextStyle(fontWeight: FontWeight.w700, color: c.primary)),
            ]),
          ),
        ),
      ),
      if (w.p['hint'] != null) ...[const SizedBox(height: 8), Text(w.p['hint'] as String, style: TextStyle(fontSize: 11.5, color: c.textMuted))],
    ]);
  }
}

/// Arbre JSON dépliable.
class _JsonNode extends StatefulWidget {
  const _JsonNode({required this.name, required this.value, required this.depth});
  final String? name;
  final Object? value;
  final int depth;

  @override
  State<_JsonNode> createState() => _JsonNodeState();
}

class _JsonNodeState extends State<_JsonNode> {
  late bool _open = widget.depth < 2;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final v = widget.value;
    final key = widget.name == null ? null : TextSpan(text: '"${widget.name}": ', style: TextStyle(color: c.purple));
    const st = TextStyle(fontFamily: Fonts.mono, fontSize: 12, height: 1.6);
    if (v is Map || v is List) {
      final entries = v is Map ? v.entries.map((e) => (e.key.toString(), e.value)).toList() : [for (final (i, x) in (v as List).indexed) ('$i', x)];
      final open = v is Map ? '{' : '[', close = v is Map ? '}' : ']';
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        InkWell(
          onTap: () => setState(() => _open = !_open),
          child: Text.rich(TextSpan(style: st.copyWith(color: c.textPrimary), children: [
            WidgetSpan(child: Icon(_open ? Icons.arrow_drop_down : Icons.arrow_right, size: 16, color: c.textMuted)),
            ?key,
            TextSpan(text: _open ? open : '$open … $close  ', style: TextStyle(color: c.textMuted)),
            if (!_open) TextSpan(text: '${entries.length} élément(s)', style: TextStyle(color: c.textMuted, fontSize: 11)),
          ])),
        ),
        if (_open) ...[
          Padding(
            padding: const EdgeInsets.only(left: Space.s4),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              for (final (k, x) in entries) _JsonNode(name: v is Map ? k : null, value: x, depth: widget.depth + 1),
            ]),
          ),
          Padding(padding: const EdgeInsets.only(left: Space.s4), child: Text(close, style: st.copyWith(color: c.textMuted))),
        ],
      ]);
    }
    final Color col = switch (v) { String() => c.successText, num() => c.info, bool() => c.tertiary, _ => c.textMuted };
    return Padding(
      padding: const EdgeInsets.only(left: Space.s4),
      child: Text.rich(TextSpan(style: st, children: [?key, TextSpan(text: v is String ? '"$v"' : '$v', style: TextStyle(color: col))])),
    );
  }
}

/// Aperçu d'image utilisé par les pièces jointes.
class HzAttachmentPreview extends StatelessWidget {
  const HzAttachmentPreview(this.a, {super.key});
  final HzAttachment a;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return Container(
      padding: const EdgeInsets.fromLTRB(Space.s2, Space.s2, Space.s3, Space.s2),
      decoration: BoxDecoration(color: c.card, borderRadius: Radii.rm, border: Border.all(color: c.border)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (a.kind == 'image')
          ClipRRect(borderRadius: BorderRadius.circular(Radii.sm), child: const SizedBox(width: 30, height: 30, child: DemoArt(seed: 2)))
        else
          Container(width: 30, height: 30, decoration: BoxDecoration(color: c.primaryLight, borderRadius: BorderRadius.circular(Radii.sm)), child: Icon(a.icon, size: 16, color: c.primary)),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          ConstrainedBox(constraints: const BoxConstraints(maxWidth: 150), child: Text(a.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
          Text(a.size, style: TextStyle(fontSize: 11, color: c.textMuted)),
        ]),
      ]),
    );
  }
}
