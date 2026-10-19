import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../theme/kit_colors.dart';
import '../../theme/tokens.dart';
import '../common.dart';
import '../selects.dart';
import 'planning_models.dart';

// ═══════════════════════════════════════════════════════════════════
// Vues de planification génériques (shared/components/planning) adaptées
// au mobile : barre d'outils, kanban (glisser-déposer à l'appui long),
// Gantt défilant, notes, vue groupée, calendrier mensuel, agenda.
// ═══════════════════════════════════════════════════════════════════

/// Barre d'outils commune : recherche, filtres déclaratifs, « En retard » — chaque bloc optionnel.
class PlanningToolbar extends StatelessWidget {
  const PlanningToolbar({super.key, required this.state, required this.onChanged, this.filters = const [], this.search = true, this.lateToggle = true, this.count});
  final PlanningFilterState state;
  final ValueChanged<PlanningFilterState> onChanged;
  final List<PlanningFilter> filters;
  final bool search, lateToggle;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
      if (search)
        TextField(
          onChanged: (v) => onChanged(state.copyWith(search: v)),
          decoration: const InputDecoration(hintText: 'Rechercher…', prefixIcon: Icon(Icons.search, size: 20)),
        ),
      if (filters.isNotEmpty || lateToggle) ...[
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            for (final f in filters)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterDropdown<String>(
                  label: f.label,
                  value: state.values[f.key] ?? 'all',
                  allValue: 'all',
                  options: [SelectOption('all', f.allLabel), for (final o in f.options) SelectOption(o.value, o.label)],
                  onChanged: (v) => onChanged(state.copyWith(values: {...state.values, f.key: v})),
                ),
              ),
            if (lateToggle)
              FilterChip(
                avatar: Icon(Icons.alarm, size: 16, color: state.lateOnly ? c.errorText : c.textSecondary),
                label: const Text('En retard'),
                selected: state.lateOnly,
                selectedColor: c.errorLight,
                showCheckmark: false,
                onSelected: (v) => onChanged(state.copyWith(lateOnly: v)),
              ),
            if (count != null) ...[
              const SizedBox(width: 10),
              Text('$count élément(s)', style: TextStyle(fontSize: 12, color: c.textMuted)),
            ],
          ]),
        ),
      ],
    ]);
  }
}

/// Carte d'un élément (kanban, notes, vue groupée).
class PlanningCard extends StatelessWidget {
  const PlanningCard({super.key, required this.item, this.onTap, this.compact = false, this.dragging = false});
  final PlanningItem item;
  final VoidCallback? onTap;
  final bool compact, dragging;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final col = item.color(c);
    return Material(
      color: c.card,
      elevation: dragging ? 8 : 0,
      shadowColor: Colors.black38,
      shape: RoundedRectangleBorder(borderRadius: Radii.rm, side: BorderSide(color: item.isLate ? c.error.withValues(alpha: 0.45) : c.border)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(border: Border(left: BorderSide(color: col, width: 4))),
          padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              Expanded(child: Text(item.ref ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: Fonts.mono, fontSize: 10.5, color: c.textMuted))),
              if (item.badge != null) Flexible(child: StatusBadge(item.badge!, tone: item.badgeTone ?? KitTone.neutral)),
            ]),
            const SizedBox(height: 4),
            Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, height: 1.3, color: item.done ? c.textMuted : c.textPrimary, decoration: item.done ? TextDecoration.lineThrough : null)),
            if (!compact && item.description != null) ...[
              const SizedBox(height: 4),
              Text(item.description!, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: c.textSecondary)),
            ],
            if (item.progress != null && item.progress! > 0 && !item.done) ...[
              const SizedBox(height: 8),
              KitProgressBar(value: item.progress! / 100, height: 4, tone: item.tone ?? KitTone.primary),
            ],
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: Wrap(spacing: 6, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
                  if (item.due != null)
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(item.isLate ? Icons.alarm : Icons.event, size: 14, color: item.isLate ? c.errorText : c.textMuted),
                      const SizedBox(width: 3),
                      Text(Fmt.dayMonth(item.due!), style: TextStyle(fontSize: 11.5, fontWeight: item.isLate ? FontWeight.w700 : null, color: item.isLate ? c.errorText : c.textMuted)),
                    ]),
                  for (final t in item.tags) StatusBadge(t, tone: KitTone.error, uppercase: false),
                ]),
              ),
              if (item.assignee != null) KitAvatar(name: item.assignee!, size: 24),
            ]),
          ]),
        ),
      ),
    );
  }
}

/// Fiche détaillée d'un élément en feuille basse.
void showPlanningItem(BuildContext context, PlanningItem it, {String? statusLabel}) {
  showModalBottomSheet(
    context: context,
    builder: (ctx) {
      final c = ctx.kc;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: it.color(c), shape: BoxShape.circle)),
              const SizedBox(width: 8),
              if (it.ref != null) Text(it.ref!, style: TextStyle(fontFamily: Fonts.mono, color: c.textMuted, fontSize: 12)),
              const Spacer(),
              if (it.isLate) const StatusBadge('En retard', tone: KitTone.error, icon: Icons.alarm) else if (it.done) const StatusBadge('Terminé', tone: KitTone.success),
            ]),
            const SizedBox(height: 8),
            Text(it.title, style: TextStyle(fontFamily: Fonts.heading, fontSize: 19, fontWeight: FontWeight.w600, color: c.textPrimary)),
            if (it.description != null) ...[const SizedBox(height: 6), Text(it.description!, style: TextStyle(color: c.textSecondary, height: 1.5))],
            const SizedBox(height: 14),
            Wrap(spacing: 16, runSpacing: 8, children: [
              if (statusLabel != null) _meta(c, Icons.flag_outlined, statusLabel),
              if (it.assignee != null) _meta(c, Icons.person_outline, it.assignee!),
              if (it.start != null) _meta(c, Icons.play_circle_outline, Fmt.dateTime(it.start!)),
              if (it.end != null) _meta(c, Icons.stop_circle_outlined, Fmt.date(it.end!)),
              if (it.due != null) _meta(c, Icons.event, 'Échéance ${Fmt.date(it.due!)}'),
              if (it.progress != null) _meta(c, Icons.donut_large, '${it.progress} %'),
            ]),
          ]),
        ),
      );
    },
  );
}

Widget _meta(KitColors c, IconData i, String t) => Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(i, size: 16, color: c.textMuted),
      const SizedBox(width: 4),
      Text(t, style: TextStyle(fontSize: 12.5, color: c.textSecondary)),
    ]);

/// Kanban : colonnes défilant horizontalement (≈ 85 % de l'écran), glisser-déposer à l'appui long.
class KanbanBoard extends StatefulWidget {
  const KanbanBoard({super.key, required this.columns, required this.items, required this.onMove, this.height = 460});
  final List<PlanningColumn> columns;
  final List<PlanningItem> items;
  final void Function(PlanningItem item, String status) onMove;
  final double height;

  @override
  State<KanbanBoard> createState() => _KanbanBoardState();
}

class _KanbanBoardState extends State<KanbanBoard> {
  String? _hover;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return LayoutBuilder(builder: (context, cons) {
      final colW = math.min(300.0, cons.maxWidth * 0.82);
      return SizedBox(
        height: widget.height,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: widget.columns.length,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (context, ci) {
            final col = widget.columns[ci];
            final items = widget.items.where((i) => i.status == col.key).toList();
            return DragTarget<PlanningItem>(
              onWillAcceptWithDetails: (d) {
                setState(() => _hover = col.key);
                return d.data.status != col.key;
              },
              onLeave: (_) => setState(() => _hover = null),
              onAcceptWithDetails: (d) {
                setState(() => _hover = null);
                widget.onMove(d.data, col.key);
              },
              builder: (context, cand, _) => AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: colW,
                decoration: BoxDecoration(
                  color: _hover == col.key && cand.isNotEmpty ? col.tone.light(c) : c.hover.withValues(alpha: 0.5),
                  borderRadius: Radii.rm,
                  border: Border.all(color: _hover == col.key && cand.isNotEmpty ? col.tone.color(c) : Colors.transparent, width: 1.5),
                ),
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                    child: Row(children: [
                      Container(width: 10, height: 10, decoration: BoxDecoration(color: col.tone.color(c), shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(col.label, style: TextStyle(fontWeight: FontWeight.w700, color: c.textPrimary))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                        decoration: BoxDecoration(color: c.card, borderRadius: Radii.pill),
                        child: Text('${items.length}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.textSecondary)),
                      ),
                    ]),
                  ),
                  Expanded(
                    child: items.isEmpty
                        ? Center(child: Text('Déposez ici', style: TextStyle(fontSize: 12, color: c.textMuted)))
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                            itemCount: items.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 8),
                            itemBuilder: (context, i) => LongPressDraggable<PlanningItem>(
                              data: items[i],
                              feedback: SizedBox(width: colW - 16, child: Transform.rotate(angle: 0.03, child: PlanningCard(item: items[i], dragging: true, compact: true))),
                              childWhenDragging: Opacity(opacity: 0.3, child: PlanningCard(item: items[i], compact: true)),
                              child: PlanningCard(item: items[i], compact: true, onTap: () => showPlanningItem(context, items[i], statusLabel: col.label)),
                            ),
                          ),
                  ),
                ]),
              ),
            );
          },
        ),
      );
    });
  }
}

/// Gantt : libellés de lignes fixes, grille de jours défilante, ligne « aujourd'hui ».
class GanttTimeline extends StatefulWidget {
  const GanttTimeline({super.key, required this.items, this.groups, this.days = 21, this.dayWidth = 44, this.startOffset = -7});
  final List<PlanningItem> items;
  final List<PlanningGroup>? groups;
  final int days, startOffset;
  final double dayWidth;

  @override
  State<GanttTimeline> createState() => _GanttTimelineState();
}

class _GanttTimelineState extends State<GanttTimeline> {
  late final _scroll = ScrollController(initialScrollOffset: (-widget.startOffset - 2) * widget.dayWidth);
  late double _dayW = widget.dayWidth;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final today = startOfDay(DateTime.now());
    final start = addDays(today, widget.startOffset);
    const rowH = 46.0, headH = 46.0, labelW = 118.0;
    final rows = <(String, String?, IconData?, KitTone, List<PlanningItem>)>[];
    if (widget.groups != null) {
      for (final g in widget.groups!) {
        rows.add((g.label, g.subtitle, g.icon, g.tone, widget.items.where((i) => i.group == g.key).toList()));
      }
    } else {
      for (final i in widget.items) {
        rows.add((i.title, i.ref, null, i.tone ?? KitTone.primary, [i]));
      }
    }
    double x(DateTime d) => startOfDay(d).difference(start).inDays * _dayW;
    final todayX = x(today) + _dayW / 2;

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Text('Zoom', style: TextStyle(fontSize: 12, color: c.textSecondary)),
        Expanded(child: Slider(value: _dayW, min: 26, max: 72, onChanged: (v) => setState(() => _dayW = v))),
        TextButton.icon(
          onPressed: () => _scroll.animateTo(((-widget.startOffset - 2) * _dayW).clamp(0, _scroll.position.maxScrollExtent), duration: const Duration(milliseconds: 400), curve: Curves.easeOut),
          icon: const Icon(Icons.today, size: 18),
          label: const Text('Aujourd’hui'),
        ),
      ]),
      Container(
        decoration: BoxDecoration(borderRadius: Radii.rm, border: Border.all(color: c.border), color: c.card),
        clipBehavior: Clip.antiAlias,
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: labelW,
            child: Column(children: [
              Container(height: headH, color: c.tableHeader, alignment: Alignment.centerLeft, padding: const EdgeInsets.only(left: 10), child: Text(widget.groups != null ? 'RESSOURCE' : 'PHASE', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: c.textSecondary))),
              for (final r in rows)
                Container(
                  height: rowH,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(border: Border(top: BorderSide(color: c.border), right: BorderSide(color: c.border))),
                  child: Row(children: [
                    if (r.$3 != null) ...[Icon(r.$3, size: 16, color: r.$4.color(c)), const SizedBox(width: 6)],
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(r.$1, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.textPrimary)),
                        if (r.$2 != null) Text(r.$2!, maxLines: 1, style: TextStyle(fontSize: 10.5, color: c.textMuted, fontFamily: Fonts.mono)),
                      ]),
                    ),
                  ]),
                ),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scroll,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: widget.days * _dayW,
                height: headH + rows.length * rowH,
                child: Stack(children: [
                  // En-tête des jours + colonnes de week-end.
                  for (var d = 0; d < widget.days; d++) ...[
                    if (addDays(start, d).weekday >= 6) Positioned(left: d * _dayW, top: headH, width: _dayW, bottom: 0, child: ColoredBox(color: c.hover.withValues(alpha: 0.6))),
                    Positioned(
                      left: d * _dayW,
                      top: 0,
                      width: _dayW,
                      height: headH,
                      child: Container(
                        color: c.tableHeader,
                        alignment: Alignment.center,
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Text(kWeekdaysShort[addDays(start, d).weekday - 1].substring(0, _dayW < 36 ? 1 : 3), style: TextStyle(fontSize: 10, color: c.textMuted)),
                          Text('${addDays(start, d).day}', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: sameDay(addDays(start, d), today) ? c.primary : c.textPrimary)),
                        ]),
                      ),
                    ),
                  ],
                  for (var r = 0; r < rows.length; r++) Positioned(left: 0, right: 0, top: headH + r * rowH, child: Container(height: 1, color: c.border)),
                  // Barres.
                  for (var r = 0; r < rows.length; r++)
                    for (final it in rows[r].$5)
                      if (it.start != null)
                        Positioned(
                          left: x(it.start!) + 2,
                          top: headH + r * rowH + 9,
                          width: math.max(_dayW - 4, x(it.end ?? it.start!) - x(it.start!) + _dayW - 4),
                          height: rowH - 18,
                          child: GestureDetector(
                            onTap: () => showPlanningItem(context, it),
                            child: Container(
                              decoration: BoxDecoration(
                                color: it.color(c).withValues(alpha: it.done ? 0.35 : 0.18),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: it.isLate ? c.error : it.color(c), width: it.isLate ? 1.5 : 1),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Stack(children: [
                                if (it.progress != null)
                                  FractionallySizedBox(widthFactor: it.progress! / 100, child: Container(color: it.color(c).withValues(alpha: 0.35))),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(it.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c.textPrimary)),
                                  ),
                                ),
                              ]),
                            ),
                          ),
                        ),
                  // Ligne « aujourd'hui ».
                  Positioned(left: todayX - 1, top: headH, bottom: 0, width: 2, child: ColoredBox(color: c.error)),
                  Positioned(left: todayX - 4, top: headH - 4, child: Container(width: 8, height: 8, decoration: BoxDecoration(color: c.error, shape: BoxShape.circle))),
                ]),
              ),
            ),
          ),
        ]),
      ),
    ]);
  }
}

/// Grille de notes (post-it) : colonnes adaptatives, cocher pour terminer.
class NoteGrid extends StatelessWidget {
  const NoteGrid({super.key, required this.items, required this.onToggle});
  final List<PlanningItem> items;
  final ValueChanged<PlanningItem> onToggle;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return ResponsiveGrid(minItemWidth: 150, spacing: 10, children: [
      for (final it in items)
        GestureDetector(
          onTap: () => showPlanningItem(context, it),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            constraints: const BoxConstraints(minHeight: 130),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color.alphaBlend(it.color(c).withValues(alpha: context.isDark ? 0.16 : 0.12), c.card),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(16), bottomLeft: Radius.circular(16), bottomRight: Radius.circular(4)),
              border: Border.all(color: it.color(c).withValues(alpha: 0.3)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(it.ref ?? '', style: TextStyle(fontFamily: Fonts.mono, fontSize: 10.5, color: c.textMuted))),
                GestureDetector(onTap: () => onToggle(it), child: Icon(it.done ? Icons.check_circle : Icons.circle_outlined, size: 20, color: it.done ? c.success : c.textMuted)),
              ]),
              const SizedBox(height: 6),
              Text(it.title, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.textPrimary, decoration: it.done ? TextDecoration.lineThrough : null)),
              const SizedBox(height: 8),
              if (it.due != null) Text(Fmt.dayMonth(it.due!), style: TextStyle(fontSize: 11, color: it.isLate ? c.errorText : c.textMuted, fontWeight: it.isLate ? FontWeight.w700 : null)),
            ]),
          ),
        ),
    ]);
  }
}

/// Vue groupée : une section repliable par groupe (technicien, véhicule…).
class GroupedBoard extends StatelessWidget {
  const GroupedBoard({super.key, required this.groups, required this.items});
  final List<PlanningGroup> groups;
  final List<PlanningItem> items;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return Column(children: [
      for (final g in groups)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: KitCard(
            padding: EdgeInsets.zero,
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: g == groups.first,
                leading: KitAvatar(name: g.label, tone: g.tone, size: 36),
                title: Text(g.label, style: TextStyle(fontWeight: FontWeight.w700, color: c.textPrimary)),
                subtitle: Text('${g.subtitle ?? ''} · ${items.where((i) => i.group == g.key).length} élément(s)'),
                childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                children: [
                  for (final it in items.where((i) => i.group == g.key))
                    Padding(padding: const EdgeInsets.only(bottom: 8), child: PlanningCard(item: it, compact: true, onTap: () => showPlanningItem(context, it))),
                  if (!items.any((i) => i.group == g.key)) Padding(padding: const EdgeInsets.all(8), child: Text('Aucun élément', style: TextStyle(color: c.textMuted))),
                ],
              ),
            ),
          ),
        ),
    ]);
  }
}

/// Calendrier mensuel : grille compacte avec pastilles, liste du jour sélectionné.
class MonthCalendar extends StatefulWidget {
  const MonthCalendar({super.key, required this.items});
  final List<PlanningItem> items;

  @override
  State<MonthCalendar> createState() => _MonthCalendarState();
}

class _MonthCalendarState extends State<MonthCalendar> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selected = startOfDay(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final first = _month;
    final gridStart = startOfWeek(first);
    final today = startOfDay(DateTime.now());
    final dayItems = widget.items.where((i) => i.anchor != null && sameDay(i.anchor!, _selected)).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        IconButton(onPressed: () => setState(() => _month = DateTime(_month.year, _month.month - 1)), icon: const Icon(Icons.chevron_left)),
        Expanded(child: Text('${kMonths[_month.month - 1]} ${_month.year}', textAlign: TextAlign.center, style: TextStyle(fontFamily: Fonts.heading, fontSize: 17, fontWeight: FontWeight.w700, color: c.textPrimary))),
        IconButton(onPressed: () => setState(() => _month = DateTime(_month.year, _month.month + 1)), icon: const Icon(Icons.chevron_right)),
      ]),
      Row(children: [for (final d in kWeekdaysShort) Expanded(child: Text(d, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c.textMuted)))]),
      const SizedBox(height: 6),
      for (var w = 0; w < 6; w++)
        Row(children: [
          for (var d = 0; d < 7; d++)
            Expanded(
              child: Builder(builder: (context) {
                final day = addDays(gridStart, w * 7 + d);
                final inMonth = day.month == _month.month;
                final its = widget.items.where((i) => i.anchor != null && sameDay(i.anchor!, day)).toList();
                final sel = sameDay(day, _selected);
                final isToday = sameDay(day, today);
                return InkWell(
                  borderRadius: Radii.rm,
                  onTap: () => setState(() => _selected = day),
                  child: Container(
                    height: 48,
                    margin: const EdgeInsets.all(1.5),
                    decoration: BoxDecoration(
                      color: sel ? c.primary : (isToday ? c.primaryLight : null),
                      borderRadius: Radii.rm,
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('${day.day}', style: TextStyle(fontSize: 13, fontWeight: isToday || sel ? FontWeight.w700 : FontWeight.w500, color: sel ? c.onPrimary : (inMonth ? c.textPrimary : c.textMuted.withValues(alpha: 0.5)))),
                      const SizedBox(height: 3),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        for (final it in its.take(3))
                          Container(width: 5, height: 5, margin: const EdgeInsets.symmetric(horizontal: 1), decoration: BoxDecoration(shape: BoxShape.circle, color: sel ? c.onPrimary : it.color(c))),
                      ]),
                    ]),
                  ),
                );
              }),
            ),
        ]),
      const Divider(height: 24),
      Text(Fmt.weekday(_selected), style: TextStyle(fontWeight: FontWeight.w700, color: c.textPrimary)),
      const SizedBox(height: 8),
      if (dayItems.isEmpty)
        Text('Aucun élément ce jour.', style: TextStyle(color: c.textMuted, fontSize: 13))
      else
        for (final it in dayItems) Padding(padding: const EdgeInsets.only(bottom: 8), child: PlanningCard(item: it, compact: true, onTap: () => showPlanningItem(context, it))),
    ]);
  }
}

/// Agenda : bande de la semaine + chronologie horaire du jour (événements journée entière en tête).
class AgendaView extends StatefulWidget {
  const AgendaView({super.key, required this.items, this.startHour = 7, this.endHour = 19});
  final List<PlanningItem> items;
  final int startHour, endHour;

  @override
  State<AgendaView> createState() => _AgendaViewState();
}

class _AgendaViewState extends State<AgendaView> {
  DateTime _day = startOfDay(DateTime.now());
  bool _week = false;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final weekStart = startOfWeek(_day);
    final today = startOfDay(DateTime.now());
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        IconButton(onPressed: () => setState(() => _day = addDays(_day, -7)), icon: const Icon(Icons.chevron_left)),
        Expanded(child: Text('Semaine du ${Fmt.dayMonth(weekStart)}', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700, color: c.textPrimary))),
        IconButton(onPressed: () => setState(() => _day = addDays(_day, 7)), icon: const Icon(Icons.chevron_right)),
      ]),
      Row(children: [
        for (var d = 0; d < 7; d++)
          Expanded(
            child: Builder(builder: (context) {
              final day = addDays(weekStart, d);
              final sel = sameDay(day, _day);
              final n = widget.items.where((i) => i.start != null && sameDay(i.start!, day)).length;
              return GestureDetector(
                onTap: () => setState(() {
                  _day = day;
                  _week = false;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(color: sel && !_week ? c.primary : c.card, borderRadius: Radii.rm, border: Border.all(color: sameDay(day, today) ? c.primary : c.border)),
                  child: Column(children: [
                    Text(kWeekdaysShort[d], style: TextStyle(fontSize: 11, color: sel && !_week ? c.onPrimary : c.textMuted)),
                    Text('${day.day}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: sel && !_week ? c.onPrimary : c.textPrimary)),
                    const SizedBox(height: 2),
                    Container(width: 5, height: 5, decoration: BoxDecoration(shape: BoxShape.circle, color: n == 0 ? Colors.transparent : (sel && !_week ? c.onPrimary : c.primary))),
                  ]),
                ),
              );
            }),
          ),
      ]),
      const SizedBox(height: 8),
      Align(
        alignment: Alignment.centerRight,
        child: SegmentedToggle<bool>(value: _week, onChanged: (v) => setState(() => _week = v), options: const [(false, 'Jour', Icons.view_day), (true, 'Liste semaine', Icons.view_agenda)]),
      ),
      const SizedBox(height: 10),
      if (_week) _weekList(c, weekStart) else _dayTimeline(c),
    ]);
  }

  Widget _weekList(KitColors c, DateTime weekStart) {
    final children = <Widget>[];
    for (var d = 0; d < 7; d++) {
      final day = addDays(weekStart, d);
      final its = widget.items.where((i) => i.start != null && sameDay(i.start!, day)).toList()..sort((a, b) => a.start!.compareTo(b.start!));
      if (its.isEmpty) continue;
      children.add(Padding(padding: const EdgeInsets.only(top: 8, bottom: 6), child: Text(Fmt.weekday(day).toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: c.textMuted))));
      for (final it in its) {
        children.add(ListTile(
          contentPadding: EdgeInsets.zero,
          onTap: () => showPlanningItem(context, it),
          leading: SizedBox(width: 48, child: Text(it.start!.hour == 0 && it.end == null ? 'Jour' : Fmt.time(it.start!), style: TextStyle(fontWeight: FontWeight.w700, color: c.textSecondary, fontFeatures: const []))),
          title: Text(it.title),
          subtitle: it.assignee == null ? null : Text(it.assignee!),
          trailing: Container(width: 4, height: 32, decoration: BoxDecoration(color: it.color(c), borderRadius: Radii.pill)),
        ));
      }
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children);
  }

  Widget _dayTimeline(KitColors c) {
    const hourH = 52.0;
    final its = widget.items.where((i) => i.start != null && sameDay(i.start!, _day)).toList();
    final allDay = its.where((i) => i.start!.hour == 0 && i.end == null).toList();
    final timed = its.where((i) => !allDay.contains(i)).toList()..sort((a, b) => a.start!.compareTo(b.start!));
    // Placement en colonnes des événements qui se chevauchent.
    final lanes = <PlanningItem, int>{};
    final laneEnds = <DateTime>[];
    for (final it in timed) {
      final end = it.end ?? it.start!.add(const Duration(hours: 1));
      var lane = laneEnds.indexWhere((e) => !e.isAfter(it.start!));
      if (lane < 0) {
        lane = laneEnds.length;
        laneEnds.add(end);
      } else {
        laneEnds[lane] = end;
      }
      lanes[it] = lane;
    }
    final laneCount = math.max(1, laneEnds.length);
    final now = DateTime.now();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (final it in allDay)
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: it.color(c).withValues(alpha: 0.15), borderRadius: Radii.rs, border: Border(left: BorderSide(color: it.color(c), width: 3))),
            child: Text('Journée · ${it.title}', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.textPrimary)),
          ),
        ),
      if (timed.isEmpty && allDay.isEmpty) const EmptyState(compact: true, icon: Icons.event_available, title: 'Journée libre', subtitle: 'Aucun rendez-vous ce jour.'),
      if (timed.isNotEmpty || allDay.isEmpty)
        LayoutBuilder(builder: (context, cons) {
          const gutter = 46.0;
          final w = (cons.maxWidth - gutter - 4) / laneCount;
          double y(DateTime d) => (d.hour + d.minute / 60 - widget.startHour) * hourH;
          return SizedBox(
            height: (widget.endHour - widget.startHour) * hourH,
            child: Stack(children: [
              for (var h = widget.startHour; h < widget.endHour; h++)
                Positioned(
                  top: (h - widget.startHour) * hourH,
                  left: 0,
                  right: 0,
                  child: Row(children: [
                    SizedBox(width: gutter, child: Text('${h.toString().padLeft(2, '0')}:00', style: TextStyle(fontSize: 10.5, color: c.textMuted))),
                    Expanded(child: Container(height: 1, color: c.border)),
                  ]),
                ),
              for (final it in timed)
                Positioned(
                  top: y(it.start!) + 1,
                  left: gutter + lanes[it]! * w,
                  width: w - 3,
                  height: math.max(26, y(it.end ?? it.start!.add(const Duration(hours: 1))) - y(it.start!) - 2),
                  child: GestureDetector(
                    onTap: () => showPlanningItem(context, it),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(8, 4, 6, 4),
                      decoration: BoxDecoration(color: Color.alphaBlend(it.color(c).withValues(alpha: 0.18), c.card), borderRadius: Radii.rs, border: Border(left: BorderSide(color: it.color(c), width: 3))),
                      // Créneau court : le contenu est rogné plutôt que de déborder.
                      child: ClipRect(
                        child: OverflowBox(
                          alignment: Alignment.topLeft,
                          maxHeight: double.infinity,
                          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(it.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: c.textPrimary)),
                            Text('${Fmt.time(it.start!)}${it.end == null ? '' : ' – ${Fmt.time(it.end!)}'}', maxLines: 1, style: TextStyle(fontSize: 10.5, color: c.textSecondary)),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ),
              if (sameDay(now, _day) && now.hour >= widget.startHour && now.hour < widget.endHour)
                Positioned(
                  top: y(now),
                  left: gutter - 4,
                  right: 0,
                  child: Row(children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: c.error, shape: BoxShape.circle)),
                    Expanded(child: Container(height: 2, color: c.error)),
                  ]),
                ),
            ]),
          );
        }),
    ]);
  }
}
