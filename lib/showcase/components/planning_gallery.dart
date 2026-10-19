import 'package:flutter/material.dart';

import '../../core/snack.dart';
import '../../data/planning_data.dart';
import '../../theme/kit_colors.dart';
import '../../widgets/common.dart';
import '../../widgets/planning/planning_models.dart';
import '../../widgets/planning/planning_views.dart';
import '../doc/doc.dart';

const _modelCode = '''class PlanningItem {
  final String id, title;
  final String? ref, description, status, group, assignee, badge;
  final DateTime? start, end, due;   // retard = due dépassée et !done
  final bool done;
  final int? progress;               // 0–100
  final KitTone? tone;               // couleur sémantique (suit le thème)
  final List<String> tags;
  final Map<String, String> fields;  // valeurs filtrables
}

PlanningFilter(key: 'type', label: 'Type', options: [...])
applyPlanningFilters(items, filters, state)''';

/// `/components/planning` — vues de planification génériques sur un modèle commun.
class PlanningGallery extends StatefulWidget {
  const PlanningGallery({super.key, this.initialSection});
  final String? initialSection;

  @override
  State<PlanningGallery> createState() => _PlanningGalleryState();
}

class _PlanningGalleryState extends State<PlanningGallery> {
  late List<PlanningItem> _inters = buildInterventions();
  final _reservations = buildReservations();
  final _phases = buildPhases();
  final _rdv = buildRendezVous();
  PlanningFilterState _kanbanF = const PlanningFilterState();
  PlanningFilterState _ganttF = const PlanningFilterState();
  PlanningFilterState _agendaF = const PlanningFilterState();
  bool _ganttGroups = true;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final kanbanItems = applyPlanningFilters(_inters, kInterventionFilters, _kanbanF);
    final resa = applyPlanningFilters(_reservations, const [kMotifFilter], _ganttF);
    final rdv = applyPlanningFilters(_rdv, const [kRdvKindFilter], _agendaF);
    return DocPage(
      title: 'Planning',
      icon: Icons.view_timeline,
      initialSection: widget.initialSection,
      subtitle: 'Vues de planification génériques : kanban, Gantt, notes, vue groupée, calendrier et agenda. Toutes reposent sur le même modèle PlanningItem et partagent une barre d’outils dont chaque bloc est optionnel.',
      sections: [
        DocSection(
          id: 'model',
          title: 'Modèle & options',
          source: 'planning_models.dart',
          description: 'Interventions, réservations, tâches ou rendez-vous se projettent tous sur PlanningItem. Les dates sont relatives à aujourd’hui : retards et ligne « aujourd’hui » restent parlants.',
          children: [
            Demo(label: 'PlanningItem', code: _modelCode, child: Row(children: [
              for (final (l, n, t) in [('Interventions', _inters.length, KitTone.primary), ('En retard', _inters.where((i) => i.isLate).length, KitTone.error), ('Terminées', _inters.where((i) => i.done).length, KitTone.success)])
                Expanded(
                  child: Column(children: [
                    Text('$n', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: t.color(c))),
                    Text(l, style: TextStyle(fontSize: 12, color: c.textSecondary)),
                  ]),
                ),
            ])),
          ],
        ),
        DocSection(
          id: 'kanban',
          title: 'Kanban',
          source: 'KanbanBoard',
          description: 'Colonnes défilant horizontalement ; appui long sur une carte pour la glisser dans une autre colonne. Touchez une carte pour sa fiche.',
          children: [
            Demo(
              label: 'Interventions terrain',
              child: Gap([
                PlanningToolbar(state: _kanbanF, filters: kInterventionFilters, count: kanbanItems.length, onChanged: (s) => setState(() => _kanbanF = s)),
                KanbanBoard(
                  columns: kInterventionColumns,
                  items: kanbanItems,
                  onMove: (it, status) {
                    setState(() => _inters = [for (final x in _inters) x.id == it.id ? x.copyWith(status: status, done: status == 'cloturee', progress: status == 'cloturee' ? 100 : x.progress) : x]);
                    showKitSnack(context, '${it.ref} → ${kInterventionColumns.firstWhere((c) => c.key == status).label}', kind: SnackKind.success);
                  },
                ),
              ]),
            ),
          ],
        ),
        DocSection(
          id: 'timeline',
          title: 'Timeline / Gantt',
          source: 'GanttTimeline',
          description: 'Libellés fixes, jours défilants, zoom, retour à aujourd’hui ; la progression remplit la barre, les retards sont cerclés de rouge.',
          children: [
            Demo(
              label: 'Réservations de véhicules',
              child: Gap([
                PlanningToolbar(state: _ganttF, filters: const [kMotifFilter], onChanged: (s) => setState(() => _ganttF = s)),
                SegmentedToggle<bool>(expand: true, value: _ganttGroups, onChanged: (v) => setState(() => _ganttGroups = v), options: const [(true, 'Par véhicule', Icons.directions_car), (false, 'Projet (phases)', Icons.flag)]),
                _ganttGroups ? GanttTimeline(key: const ValueKey('g'), items: resa, groups: kVehicules) : GanttTimeline(key: const ValueKey('p'), items: _phases, startOffset: -13, days: 26),
              ]),
            ),
          ],
        ),
        DocSection(
          id: 'notes',
          title: 'Grille de notes',
          source: 'NoteGrid',
          children: [
            Demo(
              label: 'Notes',
              child: NoteGrid(
                items: _inters.take(8).toList(),
                onToggle: (it) => setState(() => _inters = [for (final x in _inters) x.id == it.id ? x.copyWith(done: !x.done, status: !x.done ? 'cloturee' : 'planifiee') : x]),
              ),
            ),
          ],
        ),
        DocSection(
          id: 'grouped',
          title: 'Vue groupée',
          source: 'GroupedBoard',
          children: [Demo(label: 'Par technicien', child: GroupedBoard(groups: kTechniciens, items: _inters))],
        ),
        DocSection(
          id: 'calendar',
          title: 'Calendrier',
          source: 'MonthCalendar',
          description: 'Grille compacte avec pastilles colorées ; la liste du jour sélectionné s’affiche dessous.',
          children: [Demo(label: 'Interventions du mois', child: MonthCalendar(items: _inters))],
        ),
        DocSection(
          id: 'agenda',
          title: 'Agenda',
          source: 'AgendaView',
          description: 'Bande de la semaine + chronologie horaire du jour (chevauchements en colonnes, ligne de l’heure courante) ou liste de la semaine.',
          children: [
            Demo(
              label: 'Rendez-vous de la semaine',
              child: Gap([
                PlanningToolbar(state: _agendaF, filters: const [kRdvKindFilter], lateToggle: false, onChanged: (s) => setState(() => _agendaF = s)),
                AgendaView(items: rdv),
              ]),
            ),
          ],
        ),
      ],
    );
  }
}
