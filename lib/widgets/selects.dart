import 'package:flutter/material.dart';

import '../theme/kit_colors.dart';
import '../theme/tokens.dart';
import 'common.dart';

/// Option de sélection (`SelectOption` / `FilterOption`).
class SelectOption<T> {
  const SelectOption(this.value, this.label, {this.icon, this.subtitle, this.tone});
  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;
  final KitTone? tone;
}

/// Déclencheur au look « field-box » (fond, bordure, chevron).
class FieldTrigger extends StatelessWidget {
  const FieldTrigger({super.key, required this.text, this.placeholder = 'Sélectionner…', this.icon, this.onTap, this.error = false, this.enabled = true, this.trailing});
  final String? text;
  final String placeholder;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool error, enabled;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final empty = text == null || text!.isEmpty;
    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: Material(
        color: c.fieldBg,
        shape: RoundedRectangleBorder(borderRadius: Radii.rm, side: BorderSide(color: error ? c.error : c.border)),
        child: InkWell(
          borderRadius: Radii.rm,
          onTap: enabled ? onTap : null,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 46),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.s3, vertical: Space.s2),
              child: Row(children: [
                if (icon != null) ...[Icon(icon, size: 20, color: c.textSecondary), const SizedBox(width: 10)],
                Expanded(
                  child: Text(
                    empty ? placeholder : text!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, color: empty ? c.textMuted : c.textPrimary),
                  ),
                ),
                trailing ?? Icon(Icons.expand_more, color: c.textSecondary),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// Feuille de sélection recherchable (sur mobile, remplace le panneau overlay
/// de `<app-searchable-select>`). Renvoie la valeur choisie, ou null.
Future<T?> showSelectSheet<T>(
  BuildContext context, {
  required String title,
  required List<SelectOption<T>> options,
  T? selected,
  bool searchable = true,
  bool allowNull = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) => _SelectSheet<T>(title: title, options: options, selected: selected, searchable: searchable, multi: false, allowNull: allowNull),
  );
}

/// Variante multiple : renvoie la nouvelle liste (ou null si annulé).
Future<List<T>?> showMultiSelectSheet<T>(BuildContext context, {required String title, required List<SelectOption<T>> options, List<T> selected = const []}) {
  return showModalBottomSheet<List<T>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) => _SelectSheet<T>(title: title, options: options, multiSelected: selected, searchable: true, multi: true),
  );
}

class _SelectSheet<T> extends StatefulWidget {
  const _SelectSheet({required this.title, required this.options, this.selected, this.multiSelected = const [], required this.searchable, required this.multi, this.allowNull = false});
  final String title;
  final List<SelectOption<T>> options;
  final T? selected;
  final List<T> multiSelected;
  final bool searchable, multi, allowNull;

  @override
  State<_SelectSheet<T>> createState() => _SelectSheetState<T>();
}

class _SelectSheetState<T> extends State<_SelectSheet<T>> {
  String _q = '';
  late final Set<T> _multi = {...widget.multiSelected};

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final q = _q.toLowerCase();
    final list = widget.options.where((o) => q.isEmpty || o.label.toLowerCase().contains(q) || (o.subtitle?.toLowerCase().contains(q) ?? false)).toList();
    final maxH = MediaQuery.sizeOf(context).height * 0.75;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxH),
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.s5, 0, Space.s3, Space.s2),
            child: Row(children: [
              Expanded(child: Text(widget.title, style: TextStyle(fontFamily: Fonts.heading, fontSize: 18, fontWeight: FontWeight.w600, color: c.textPrimary))),
              if (widget.multi) ...[
                TextButton(onPressed: () => setState(_multi.clear), child: const Text('Effacer')),
                FilledButton(onPressed: () => Navigator.pop(context, _multi.toList()), child: Text('Valider (${_multi.length})')),
              ],
            ]),
          ),
          if (widget.searchable && widget.options.length > 6)
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.s4, 0, Space.s4, Space.s2),
              child: TextField(
                autofocus: false,
                onChanged: (v) => setState(() => _q = v),
                decoration: const InputDecoration(hintText: 'Rechercher…', prefixIcon: Icon(Icons.search, size: 20)),
              ),
            ),
          Flexible(
            child: list.isEmpty
                ? const EmptyState(compact: true, icon: Icons.search_off, title: 'Aucun résultat', subtitle: 'Essayez un autre terme.')
                : ListView(shrinkWrap: true, padding: const EdgeInsets.fromLTRB(Space.s2, 0, Space.s2, Space.s4), children: [
                    if (widget.allowNull && !widget.multi)
                      ListTile(
                        leading: const Icon(Icons.block, size: 20),
                        title: Text('Aucun', style: TextStyle(color: c.textMuted)),
                        onTap: () => Navigator.pop(context),
                      ),
                    for (final o in list)
                      widget.multi
                          ? CheckboxListTile(
                              value: _multi.contains(o.value),
                              onChanged: (v) => setState(() => v! ? _multi.add(o.value) : _multi.remove(o.value)),
                              secondary: o.icon == null ? null : Icon(o.icon, size: 20),
                              title: Text(o.label),
                              subtitle: o.subtitle == null ? null : Text(o.subtitle!),
                              shape: RoundedRectangleBorder(borderRadius: Radii.rm),
                              controlAffinity: ListTileControlAffinity.trailing,
                            )
                          : ListTile(
                              selected: o.value == widget.selected,
                              selectedTileColor: c.primaryLight,
                              selectedColor: c.primary,
                              leading: o.icon == null
                                  ? (o.tone == null ? null : Icon(Icons.circle, size: 12, color: o.tone!.color(c)))
                                  : Icon(o.icon, size: 20),
                              title: Text(o.label),
                              subtitle: o.subtitle == null ? null : Text(o.subtitle!),
                              trailing: o.value == widget.selected ? Icon(Icons.check, color: c.primary) : null,
                              onTap: () => Navigator.pop(context, o.value),
                            ),
                  ]),
          ),
        ]),
      ),
    );
  }
}

/// `<app-searchable-select>` : champ qui ouvre la feuille de sélection.
class SearchableSelect<T> extends StatelessWidget {
  const SearchableSelect({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.label,
    this.placeholder = 'Sélectionner…',
    this.icon,
    this.allowNull = false,
    this.enabled = true,
    this.error,
    this.sheetTitle,
  });

  final List<SelectOption<T>> options;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String? label, error, sheetTitle;
  final String placeholder;
  final IconData? icon;
  final bool allowNull, enabled;

  @override
  Widget build(BuildContext context) {
    final current = options.where((o) => o.value == value).firstOrNull;
    final trigger = FieldTrigger(
      text: current?.label,
      placeholder: placeholder,
      icon: current?.icon ?? icon,
      error: error != null,
      enabled: enabled,
      onTap: () async {
        final v = await showSelectSheet<T>(context, title: sheetTitle ?? label ?? placeholder, options: options, selected: value, allowNull: allowNull);
        if (v != null || allowNull) onChanged(v);
      },
    );
    if (label == null && error == null) return trigger;
    return FormFieldLabel(label: label ?? '', error: error, child: trigger);
  }
}

/// Sélection multiple affichée en puces.
class MultiSelectField<T> extends StatelessWidget {
  const MultiSelectField({super.key, required this.options, required this.values, required this.onChanged, this.label, this.placeholder = 'Choisir…'});
  final List<SelectOption<T>> options;
  final List<T> values;
  final ValueChanged<List<T>> onChanged;
  final String? label;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final selected = options.where((o) => values.contains(o.value)).toList();
    final field = Material(
      color: c.fieldBg,
      shape: RoundedRectangleBorder(borderRadius: Radii.rm, side: BorderSide(color: c.border)),
      child: InkWell(
        borderRadius: Radii.rm,
        onTap: () async {
          final v = await showMultiSelectSheet<T>(context, title: label ?? placeholder, options: options, selected: values);
          if (v != null) onChanged(v);
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Space.s3, Space.s2, Space.s2, Space.s2),
          child: Row(children: [
            Expanded(
              child: selected.isEmpty
                  ? Padding(padding: const EdgeInsets.all(Space.s1), child: Text(placeholder, style: TextStyle(color: c.textMuted)))
                  : Wrap(spacing: 6, runSpacing: 6, children: [
                      for (final o in selected)
                        InputChip(
                          label: Text(o.label),
                          visualDensity: VisualDensity.compact,
                          onDeleted: () => onChanged([...values]..remove(o.value)),
                        ),
                    ]),
            ),
            Icon(Icons.expand_more, color: c.textSecondary),
          ]),
        ),
      ),
    );
    return label == null ? field : FormFieldLabel(label: label!, child: field);
  }
}

/// `<app-filter-dropdown>` : puce compacte « Libellé : valeur ▾ ».
class FilterDropdown<T> extends StatelessWidget {
  const FilterDropdown({super.key, required this.label, required this.options, required this.value, required this.onChanged, this.allValue, this.icon = Icons.filter_list});
  final String label;
  final List<SelectOption<T>> options;
  final T value;
  final T? allValue;
  final ValueChanged<T> onChanged;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final cur = options.where((o) => o.value == value).firstOrNull;
    final active = allValue == null ? false : value != allValue;
    return Material(
      color: active ? c.primaryLight : c.card,
      shape: StadiumBorder(side: BorderSide(color: active ? c.primary.withValues(alpha: 0.6) : c.border)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: () async {
          final v = await showSelectSheet<T>(context, title: label, options: options, selected: value, searchable: options.length > 8);
          if (v != null) onChanged(v);
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Space.s3, Space.s2, Space.s2, Space.s2),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(cur?.icon ?? icon, size: 16, color: active ? c.primary : c.textSecondary),
            const SizedBox(width: 6),
            Text('$label : ', style: TextStyle(fontSize: 12.5, color: c.textSecondary)),
            Text(cur?.label ?? '—', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: active ? c.primary : c.textPrimary)),
            Icon(Icons.arrow_drop_down, size: 18, color: c.textSecondary),
          ]),
        ),
      ),
    );
  }
}

/// `<app-entity-autocomplete>` : recherche filtrée en mémoire, résultats enrichis.
class EntityAutocomplete<T extends Object> extends StatelessWidget {
  const EntityAutocomplete({
    super.key,
    required this.items,
    required this.display,
    required this.onSelected,
    this.subtitle,
    this.hint = 'Rechercher…',
    this.icon = Icons.search,
    this.maxResults = 8,
  });

  final List<T> items;
  final String Function(T) display;
  final String Function(T)? subtitle;
  final ValueChanged<T> onSelected;
  final String hint;
  final IconData icon;
  final int maxResults;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return LayoutBuilder(builder: (context, cons) {
      return Autocomplete<T>(
        displayStringForOption: display,
        optionsBuilder: (v) {
          final q = v.text.trim().toLowerCase();
          if (q.isEmpty) return const Iterable.empty();
          return items.where((e) => display(e).toLowerCase().contains(q) || (subtitle?.call(e).toLowerCase().contains(q) ?? false)).take(maxResults);
        },
        onSelected: onSelected,
        fieldViewBuilder: (context, ctrl, focus, submit) => TextField(
          controller: ctrl,
          focusNode: focus,
          onSubmitted: (_) => submit(),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
            suffixIcon: ValueListenableBuilder(
              valueListenable: ctrl,
              builder: (_, v, _) => v.text.isEmpty ? const SizedBox.shrink() : IconButton(icon: const Icon(Icons.close, size: 18), onPressed: ctrl.clear),
            ),
          ),
        ),
        optionsViewBuilder: (context, select, options) => Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 6,
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: Radii.rm,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 280, maxWidth: cons.maxWidth),
              child: ListView(padding: const EdgeInsets.symmetric(vertical: Space.s2), shrinkWrap: true, children: [
                for (final o in options)
                  ListTile(
                    dense: true,
                    leading: KitAvatar(name: display(o), size: 32),
                    title: Text(display(o), style: TextStyle(color: c.textPrimary)),
                    subtitle: subtitle == null ? null : Text(subtitle!(o)),
                    onTap: () => select(o),
                  ),
              ]),
            ),
          ),
        ),
      );
    });
  }
}
