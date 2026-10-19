import 'package:flutter/material.dart';

import '../../theme/kit_colors.dart';

/// Modèle générique des vues de planification (kanban, gantt, notes, vue groupée,
/// calendrier, agenda) — `planning.models.ts`. Aucun champ propre à un métier.
class PlanningItem {
  const PlanningItem({
    required this.id,
    required this.title,
    this.ref,
    this.description,
    this.status,
    this.group,
    this.start,
    this.end,
    this.due,
    this.done = false,
    this.progress,
    this.tone,
    this.badge,
    this.badgeTone,
    this.assignee,
    this.tags = const [],
    this.fields = const {},
  });

  final String id, title;
  final String? ref, description, status, group, assignee, badge;
  final DateTime? start, end, due;
  final bool done;
  final int? progress;
  final KitTone? tone, badgeTone;
  final List<String> tags;
  final Map<String, String> fields;

  PlanningItem copyWith({String? status, bool? done, int? progress, DateTime? start, DateTime? end, String? group}) => PlanningItem(
        id: id,
        title: title,
        ref: ref,
        description: description,
        status: status ?? this.status,
        group: group ?? this.group,
        start: start ?? this.start,
        end: end ?? this.end,
        due: due,
        done: done ?? this.done,
        progress: progress ?? this.progress,
        tone: tone,
        badge: badge,
        badgeTone: badgeTone,
        assignee: assignee,
        tags: tags,
        fields: fields,
      );

  /// En retard : échéance dépassée et non terminé.
  bool get isLate => !done && due != null && due!.isBefore(DateTime.now());

  /// Date de référence (début, sinon échéance).
  DateTime? get anchor => start ?? due;

  /// `itemColor` : tone, sinon terminé / en retard / primaire.
  Color color(KitColors c) {
    if (tone != null) return tone!.color(c);
    if (done) return c.success;
    if (isLate) return c.error;
    return c.primary;
  }
}

class PlanningColumn {
  const PlanningColumn(this.key, this.label, this.tone);
  final String key, label;
  final KitTone tone;
}

class PlanningGroup {
  const PlanningGroup(this.key, this.label, {this.subtitle, this.tone = KitTone.primary, this.icon});
  final String key, label;
  final String? subtitle;
  final KitTone tone;
  final IconData? icon;
}

class FilterOption {
  const FilterOption(this.value, this.label);
  final String value, label;
}

/// Filtre déclaratif optionnel : lit `item.fields[key]` (ou `group` / `status`).
class PlanningFilter {
  const PlanningFilter({required this.key, required this.label, required this.options, this.allLabel = 'Tous'});
  final String key, label, allLabel;
  final List<FilterOption> options;

  String? valueOf(PlanningItem it) => switch (key) {
        'group' => it.group,
        'status' => it.status,
        _ => it.fields[key],
      };
}

class PlanningFilterState {
  const PlanningFilterState({this.search = '', this.values = const {}, this.lateOnly = false});
  final String search;
  final Map<String, String> values;
  final bool lateOnly;

  PlanningFilterState copyWith({String? search, Map<String, String>? values, bool? lateOnly}) =>
      PlanningFilterState(search: search ?? this.search, values: values ?? this.values, lateOnly: lateOnly ?? this.lateOnly);

  bool get isActive => search.isNotEmpty || lateOnly || values.values.any((v) => v != 'all');
}

/// Applique recherche, filtres déclarés et « en retard uniquement ».
List<PlanningItem> applyPlanningFilters(List<PlanningItem> items, List<PlanningFilter> filters, PlanningFilterState s) {
  final q = s.search.trim().toLowerCase();
  final active = filters.where((f) => (s.values[f.key] ?? 'all') != 'all').toList();
  if (q.isEmpty && active.isEmpty && !s.lateOnly) return items;
  return items.where((it) {
    if (q.isNotEmpty) {
      final hay = [it.title, it.ref, it.description, it.assignee, ...it.tags].whereType<String>().join(' ').toLowerCase();
      if (!hay.contains(q)) return false;
    }
    for (final f in active) {
      if (f.valueOf(it) != s.values[f.key]) return false;
    }
    if (s.lateOnly && !it.isLate) return false;
    return true;
  }).toList();
}

bool sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
DateTime addDays(DateTime d, int n) => DateTime(d.year, d.month, d.day + n, d.hour, d.minute);
DateTime startOfWeek(DateTime d) => startOfDay(d).subtract(Duration(days: d.weekday - 1));

const kWeekdaysShort = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
const kMonths = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];
