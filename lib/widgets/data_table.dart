import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/kit_colors.dart';
import '../theme/kit_text.dart';
import '../theme/tokens.dart';
import 'common.dart';
import 'inputs.dart';

/// Colonne d'un tableau du kit.
class KitColumn<T> {
  const KitColumn({
    required this.label,
    required this.cell,
    this.sortValue,
    this.width = 140,
    this.numeric = false,
    this.hidden = false,
    this.total,
    this.onEdit,
  });

  final String label;
  final Widget Function(BuildContext context, T row) cell;
  final Comparable<Object?> Function(T row)? sortValue;
  final double width;
  final bool numeric, hidden;

  /// Valeur de la ligne de total (pied de tableau).
  final String Function(List<T> rows)? total;

  /// Édition en ligne : appelé au toucher de la cellule.
  final void Function(BuildContext context, T row)? onEdit;
}

/// Action groupée sur la sélection.
class BulkAction {
  const BulkAction(this.id, this.label, this.icon, {this.danger = false});
  final String id, label;
  final IconData icon;
  final bool danger;
}

/// Tableau de données mobile : recherche, tri, sélection multiple et actions groupées,
/// colonnes masquables, ligne de total, pagination ; bascule cartes / tableau
/// (le tableau défile horizontalement, la 1re colonne reste fixe).
class KitDataTable<T> extends StatefulWidget {
  const KitDataTable({
    super.key,
    required this.rows,
    required this.columns,
    required this.cardBuilder,
    this.searchText,
    this.selectable = false,
    this.bulkActions = const [],
    this.onBulk,
    this.pageSize = 8,
    this.initialMode = ViewMode.list,
    this.title,
    this.onRowTap,
    this.loading = false,
    this.emptyTitle = 'Aucun résultat',
    this.emptySubtitle = 'Ajustez vos critères de recherche.',
    this.columnToggle = false,
    this.dense = false,
  });

  final List<T> rows;
  final List<KitColumn<T>> columns;
  final Widget Function(BuildContext context, T row, bool selected) cardBuilder;
  final String Function(T row)? searchText;
  final bool selectable, loading, columnToggle, dense;
  final List<BulkAction> bulkActions;
  final void Function(String action, List<T> rows)? onBulk;
  final int pageSize;
  final ViewMode initialMode;
  final String? title;
  final ValueChanged<T>? onRowTap;
  final String emptyTitle, emptySubtitle;

  @override
  State<KitDataTable<T>> createState() => _KitDataTableState<T>();
}

class _KitDataTableState<T> extends State<KitDataTable<T>> {
  String _q = '';
  int? _sortCol;
  bool _asc = true;
  int _page = 1;
  late int _pageSize = widget.pageSize;
  late ViewMode _mode = widget.initialMode;
  final Set<T> _sel = {};
  late final Set<int> _hidden = {for (var i = 0; i < widget.columns.length; i++) if (widget.columns[i].hidden) i};

  List<T> get _filtered {
    var list = widget.rows;
    final q = _q.trim().toLowerCase();
    if (q.isNotEmpty && widget.searchText != null) list = list.where((r) => widget.searchText!(r).toLowerCase().contains(q)).toList();
    if (_sortCol != null) {
      final f = widget.columns[_sortCol!].sortValue!;
      list = [...list]..sort((a, b) => _asc ? f(a).compareTo(f(b)) : f(b).compareTo(f(a)));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final all = _filtered;
    final pages = math.max(1, (all.length / _pageSize).ceil());
    if (_page > pages) _page = pages;
    final rows = all.skip((_page - 1) * _pageSize).take(_pageSize).toList();
    final cols = [for (var i = 0; i < widget.columns.length; i++) if (!_hidden.contains(i)) i];

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // Barre d'outils.
      Row(children: [
        if (widget.searchText != null)
          Expanded(
            child: KitSearchBar(
              hint: 'Rechercher…',
              onChanged: (v) => setState(() {
                _q = v;
                _page = 1;
              }),
            ),
          )
        else
          const Spacer(),
        const SizedBox(width: 8),
        if (widget.columnToggle && _mode == ViewMode.list)
          PopupMenuButton<int>(
            tooltip: 'Colonnes',
            icon: const Icon(Icons.view_column_outlined),
            itemBuilder: (_) => [
              for (var i = 1; i < widget.columns.length; i++)
                CheckedPopupMenuItem(value: i, checked: !_hidden.contains(i), child: Text(widget.columns[i].label)),
            ],
            onSelected: (i) => setState(() => _hidden.contains(i) ? _hidden.remove(i) : _hidden.add(i)),
          ),
        ViewModeToggle(mode: _mode, showLabels: false, onChanged: (m) => setState(() => _mode = m)),
      ]),
      const SizedBox(height: 10),
      // Barre de sélection.
      AnimatedSize(
        duration: const Duration(milliseconds: 200),
        child: _sel.isEmpty
            ? const SizedBox(width: double.infinity)
            : Container(
                margin: const EdgeInsets.only(bottom: Space.s3),
                padding: const EdgeInsets.fromLTRB(Space.s3, Space.s1, Space.s1, Space.s1),
                decoration: BoxDecoration(color: c.primaryLight, borderRadius: Radii.rm, border: Border.all(color: c.primary.withValues(alpha: 0.3))),
                child: Row(children: [
                  Text('${_sel.length} sélectionné(s)', style: TextStyle(fontWeight: FontWeight.w700, color: c.primary)),
                  const Spacer(),
                  for (final a in widget.bulkActions)
                    IconButton(
                      tooltip: a.label,
                      color: a.danger ? c.error : c.primary,
                      onPressed: () {
                        widget.onBulk?.call(a.id, _sel.toList());
                        setState(_sel.clear);
                      },
                      icon: Icon(a.icon),
                    ),
                  IconButton(tooltip: 'Désélectionner', onPressed: () => setState(_sel.clear), icon: const Icon(Icons.close)),
                ]),
              ),
      ),
      if (widget.loading)
        for (var i = 0; i < 4; i++) const SkeletonListTile()
      else if (all.isEmpty)
        KitCard(child: EmptyState(compact: true, icon: Icons.search_off, title: widget.emptyTitle, subtitle: widget.emptySubtitle))
      else if (_mode == ViewMode.card)
        Column(children: [
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.s3),
              child: GestureDetector(
                onLongPress: widget.selectable ? () => setState(() => _sel.contains(r) ? _sel.remove(r) : _sel.add(r)) : null,
                onTap: _sel.isNotEmpty ? () => setState(() => _sel.contains(r) ? _sel.remove(r) : _sel.add(r)) : (widget.onRowTap == null ? null : () => widget.onRowTap!(r)),
                child: widget.cardBuilder(context, r, _sel.contains(r)),
              ),
            ),
          if (widget.selectable)
            Padding(padding: const EdgeInsets.only(bottom: Space.s2), child: Text('Appui long sur une carte pour la sélectionner.', style: TextStyle(fontSize: 11.5, color: c.textMuted))),
        ])
      else
        _table(context, c, rows, all, cols),
      const SizedBox(height: 8),
      KitPaginator(
        page: _page,
        pageSize: _pageSize,
        total: all.length,
        compact: MediaQuery.sizeOf(context).width < Breakpoints.sm,
        onPage: (p) => setState(() => _page = p),
        onPageSize: (s) => setState(() {
          _pageSize = s;
          _page = 1;
        }),
      ),
    ]);
  }

  Widget _table(BuildContext context, KitColors c, List<T> rows, List<T> all, List<int> cols) {
    final rowH = widget.dense ? 44.0 : 52.0;
    final first = cols.first;
    final rest = cols.skip(1).toList();
    final hasTotal = widget.columns.any((col) => col.total != null);
    final allSel = rows.isNotEmpty && rows.every(_sel.contains);

    Widget header(int i) {
      final col = widget.columns[i];
      final sortable = col.sortValue != null;
      return InkWell(
        onTap: sortable
            ? () => setState(() {
                  if (_sortCol == i) {
                    _asc ? _asc = false : _sortCol = null;
                  } else {
                    _sortCol = i;
                    _asc = true;
                  }
                })
            : null,
        child: Container(
          width: col.width,
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: Space.s3),
          alignment: col.numeric ? Alignment.centerRight : Alignment.centerLeft,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Flexible(child: Text(col.label.toUpperCase(), overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: _sortCol == i ? c.primary : c.textSecondary))),
            if (_sortCol == i) Icon(_asc ? Icons.arrow_upward : Icons.arrow_downward, size: 14, color: c.primary),
          ]),
        ),
      );
    }

    Widget cell(int i, T r) {
      final col = widget.columns[i];
      final content = Container(
        width: col.width,
        height: rowH,
        padding: const EdgeInsets.symmetric(horizontal: Space.s3),
        alignment: col.numeric ? Alignment.centerRight : Alignment.centerLeft,
        child: DefaultTextStyle.merge(style: TextStyle(fontSize: 13, color: c.textPrimary, fontFeatures: col.numeric ? KitText.tabular : null), child: col.cell(context, r)),
      );
      if (col.onEdit == null) return content;
      return InkWell(onTap: () => col.onEdit!(context, r), child: Stack(children: [content, Positioned(right: 2, top: 4, child: Icon(Icons.edit, size: 11, color: c.textMuted))]));
    }

    Widget rowBox(T r, Widget child, {bool last = false}) => Container(
          decoration: BoxDecoration(
            color: _sel.contains(r) ? c.primaryLight : c.card,
            border: Border(top: BorderSide(color: c.divider)),
          ),
          child: child,
        );

    final selW = widget.selectable ? 44.0 : 0.0;
    final firstCol = Column(children: [
      Container(
        color: c.tableHeader,
        child: Row(children: [
          if (widget.selectable)
            SizedBox(
              width: selW,
              child: Checkbox(
                tristate: true,
                value: allSel ? true : (rows.any(_sel.contains) ? null : false),
                onChanged: (_) => setState(() => allSel ? _sel.removeAll(rows) : _sel.addAll(rows)),
              ),
            ),
          header(first),
        ]),
      ),
      for (final r in rows)
        rowBox(
          r,
          InkWell(
            onTap: widget.onRowTap == null ? null : () => widget.onRowTap!(r),
            child: Row(children: [
              if (widget.selectable)
                SizedBox(width: selW, child: Checkbox(value: _sel.contains(r), onChanged: (v) => setState(() => v! ? _sel.add(r) : _sel.remove(r)))),
              cell(first, r),
            ]),
          ),
        ),
      if (hasTotal)
        Container(
          height: 44,
          width: selW + widget.columns[first].width,
          padding: const EdgeInsets.symmetric(horizontal: Space.s3),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(color: c.tableHeader, border: Border(top: BorderSide(color: c.divider, width: 1.5))),
          child: Text('Total (${all.length})', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
        ),
    ]);

    final scrollPart = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(color: c.tableHeader, child: Row(children: [for (final i in rest) header(i)])),
        for (final r in rows) rowBox(r, Row(children: [for (final i in rest) cell(i, r)])),
        if (hasTotal)
          Container(
            decoration: BoxDecoration(color: c.tableHeader, border: Border(top: BorderSide(color: c.divider, width: 1.5))),
            child: Row(children: [
              for (final i in rest)
                Container(
                  width: widget.columns[i].width,
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: Space.s3),
                  alignment: widget.columns[i].numeric ? Alignment.centerRight : Alignment.centerLeft,
                  child: Text(widget.columns[i].total?.call(all) ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, fontFeatures: KitText.tabular)),
                ),
            ]),
          ),
      ]),
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: Radii.rm, color: c.card),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          decoration: BoxDecoration(border: Border(right: BorderSide(color: c.divider)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(2, 0))]),
          child: firstCol,
        ),
        Expanded(child: scrollPart),
      ]),
    );
  }
}
