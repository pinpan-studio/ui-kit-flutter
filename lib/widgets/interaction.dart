import 'package:flutter/material.dart';

import '../core/format.dart';
import '../data/showcase_data.dart';
import '../theme/kit_colors.dart';
import '../theme/tokens.dart';
import 'common.dart';

// ═══════════════════════════════════════════════════════════════════
// Interactions : palette de commandes, popover, visite guidée,
// centre de notifications, menu contextuel (appui long).
// ═══════════════════════════════════════════════════════════════════

class PaletteCommand {
  const PaletteCommand(this.label, this.icon, this.group, {this.hint, this.shortcut, this.keywords = ''});
  final String label, group;
  final IconData icon;
  final String? hint, shortcut;
  final String keywords;
}

/// Palette de commandes (⌘K) : recherche floue, groupes, raccourci affiché.
/// Sur téléphone elle s'ouvre en feuille plein écran ; avec un clavier physique, ⌘K / Ctrl+K.
Future<PaletteCommand?> showCommandPalette(BuildContext context, List<PaletteCommand> commands) {
  return showModalBottomSheet<PaletteCommand>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: false,
    builder: (_) => _CommandPalette(commands: commands),
  );
}

class _CommandPalette extends StatefulWidget {
  const _CommandPalette({required this.commands});
  final List<PaletteCommand> commands;

  @override
  State<_CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<_CommandPalette> {
  String _q = '';

  /// Correspondance « floue » : toutes les lettres de la requête apparaissent dans l'ordre.
  static int? _score(String q, String text) {
    if (q.isEmpty) return 0;
    final t = text.toLowerCase();
    final idx = t.indexOf(q);
    if (idx >= 0) return idx;
    var pos = 0;
    for (final ch in q.split('')) {
      pos = t.indexOf(ch, pos);
      if (pos < 0) return null;
      pos++;
    }
    return 100 + pos;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final q = _q.trim().toLowerCase();
    final scored = <(PaletteCommand, int)>[];
    for (final cmd in widget.commands) {
      final s = _score(q, '${cmd.label} ${cmd.keywords} ${cmd.group}');
      if (s != null) scored.add((cmd, s));
    }
    if (q.isNotEmpty) scored.sort((a, b) => a.$2.compareTo(b.$2));
    final groups = <String, List<PaletteCommand>>{};
    for (final (cmd, _) in scored) {
      (groups[cmd.group] ??= []).add(cmd);
    }
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.85,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Space.s3, Space.s3, Space.s2, Space.s2),
          child: Row(children: [
            Expanded(
              child: TextField(
                autofocus: true,
                onChanged: (v) => setState(() => _q = v),
                onSubmitted: (_) {
                  if (scored.isNotEmpty) Navigator.pop(context, scored.first.$1);
                },
                decoration: InputDecoration(
                  hintText: 'Page, action, client…',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(Space.s3),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: Space.s2, vertical: Space.s0_5),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(color: c.border)),
                      child: Text('⌘K', style: TextStyle(fontFamily: Fonts.mono, fontSize: 11, color: c.textMuted)),
                    ),
                  ),
                ),
              ),
            ),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ]),
        ),
        Expanded(
          child: scored.isEmpty
              ? EmptyState(compact: true, icon: Icons.search_off, title: 'Aucune commande', subtitle: 'Aucun résultat pour « $_q ».')
              : ListView(padding: const EdgeInsets.fromLTRB(Space.s2, 0, Space.s2, Space.s4), children: [
                  for (final g in groups.entries) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(Space.s3, Space.s3, Space.s3, Space.s1),
                      child: Text(g.key.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: c.textMuted)),
                    ),
                    for (final cmd in g.value)
                      ListTile(
                        leading: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(color: c.hover, borderRadius: BorderRadius.circular(10)),
                          child: Icon(cmd.icon, size: 18, color: c.textSecondary),
                        ),
                        title: Text(cmd.label),
                        subtitle: cmd.hint == null ? null : Text(cmd.hint!),
                        trailing: cmd.shortcut == null ? null : Text(cmd.shortcut!, style: TextStyle(fontFamily: Fonts.mono, fontSize: 11, color: c.textMuted)),
                        onTap: () => Navigator.pop(context, cmd),
                      ),
                  ],
                ]),
        ),
      ]),
    );
  }
}

/// Popover riche ancré à un widget (s'affiche au-dessus ou au-dessous selon la place).
class Popover extends StatefulWidget {
  const Popover({super.key, required this.child, required this.content, this.width = 280});
  final Widget child;
  final Widget Function(BuildContext context, VoidCallback close) content;
  final double width;

  @override
  State<Popover> createState() => _PopoverState();
}

class _PopoverState extends State<Popover> {
  final _ctrl = OverlayPortalController();
  final _link = LayerLink();
  bool _above = false;

  void _toggle() {
    final box = context.findRenderObject() as RenderBox;
    final y = box.localToGlobal(Offset.zero).dy;
    _above = y > MediaQuery.sizeOf(context).height * 0.55;
    _ctrl.toggle();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _ctrl,
        overlayChildBuilder: (ctx) => Stack(children: [
          Positioned.fill(child: GestureDetector(behavior: HitTestBehavior.translucent, onTap: _ctrl.hide)),
          CompositedTransformFollower(
            link: _link,
            targetAnchor: _above ? Alignment.topLeft : Alignment.bottomLeft,
            followerAnchor: _above ? Alignment.bottomLeft : Alignment.topLeft,
            offset: Offset(0, _above ? -8 : 8),
            child: Align(
              alignment: Alignment.topLeft,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.92, end: 1),
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                builder: (_, v, child) => Transform.scale(
                  scale: v,
                  alignment: _above ? Alignment.bottomLeft : Alignment.topLeft,
                  child: Opacity(opacity: ((v - 0.92) / 0.08).clamp(0, 1), child: child),
                ),
                child: Material(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  elevation: 8,
                  shadowColor: Colors.black38,
                  shape: RoundedRectangleBorder(borderRadius: Radii.rm, side: BorderSide(color: c.border)),
                  child: SizedBox(width: widget.width, child: widget.content(ctx, _ctrl.hide)),
                ),
              ),
            ),
          ),
        ]),
        child: GestureDetector(onTap: _toggle, child: widget.child),
      ),
    );
  }
}

/// Étape de visite guidée.
class TourStep {
  const TourStep(this.target, this.title, this.text, {this.icon = Icons.lightbulb_outline});
  final GlobalKey target;
  final String title, text;
  final IconData icon;
}

/// Visite guidée : voile sombre percé autour de la cible, bulle d'explication, navigation.
Future<void> startTour(BuildContext context, List<TourStep> steps) async {
  final overlay = Overlay.of(context);
  var index = 0;
  late OverlayEntry entry;
  void close() => entry.remove();

  Future<void> show() async {
    final ctx = steps[index].target.currentContext;
    if (ctx != null) {
      await Scrollable.ensureVisible(ctx, alignment: 0.4, duration: const Duration(milliseconds: 300));
    }
    entry.markNeedsBuild();
  }

  entry = OverlayEntry(builder: (octx) {
    final step = steps[index];
    final box = step.target.currentContext?.findRenderObject() as RenderBox?;
    final rect = box == null ? Rect.zero : (box.localToGlobal(Offset.zero) & box.size).inflate(8);
    final size = MediaQuery.sizeOf(octx);
    final below = rect.center.dy < size.height / 2;
    final c = octx.kc;
    return Stack(children: [
      Positioned.fill(
        child: GestureDetector(
          onTap: () {},
          child: TweenAnimationBuilder<Rect?>(
            tween: RectTween(end: rect),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            builder: (_, r, _) => CustomPaint(painter: _SpotlightPainter(r ?? rect)),
          ),
        ),
      ),
      Positioned(
        left: 16,
        right: 16,
        top: below ? rect.bottom + 14 : null,
        bottom: below ? null : size.height - rect.top + 14,
        child: Material(
          color: Theme.of(octx).colorScheme.surfaceContainerLow,
          borderRadius: Radii.rl,
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, Space.s4, Space.s3, Space.s3),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 34, height: 34, decoration: BoxDecoration(color: c.primaryLight, shape: BoxShape.circle), child: Icon(step.icon, size: 18, color: c.primary)),
                const SizedBox(width: 10),
                Expanded(child: Text(step.title, style: TextStyle(fontFamily: Fonts.heading, fontSize: 16, fontWeight: FontWeight.w700, color: c.textPrimary))),
                Text('${index + 1}/${steps.length}', style: TextStyle(fontSize: 12, color: c.textMuted)),
              ]),
              const SizedBox(height: 8),
              Text(step.text, style: TextStyle(fontSize: 13.5, height: 1.5, color: c.textSecondary)),
              const SizedBox(height: 8),
              Wrap(alignment: WrapAlignment.end, crossAxisAlignment: WrapCrossAlignment.center, spacing: 4, children: [
                TextButton(onPressed: close, child: const Text('Passer')),
                if (index > 0)
                  TextButton(
                    onPressed: () {
                      index--;
                      show();
                    },
                    child: const Text('Précédent'),
                  ),
                FilledButton(
                  onPressed: () {
                    if (index == steps.length - 1) {
                      close();
                    } else {
                      index++;
                      show();
                    }
                  },
                  child: Text(index == steps.length - 1 ? 'Terminer' : 'Suivant'),
                ),
              ]),
            ]),
          ),
        ),
      ),
    ]);
  });
  overlay.insert(entry);
  await show();
}

class _SpotlightPainter extends CustomPainter {
  _SpotlightPainter(this.hole);
  final Rect hole;

  @override
  void paint(Canvas canvas, Size size) {
    final rr = RRect.fromRectAndRadius(hole, const Radius.circular(Radii.lg));
    canvas.drawPath(Path.combine(PathOperation.difference, Path()..addRect(Offset.zero & size), Path()..addRRect(rr)), Paint()..color = Colors.black.withValues(alpha: 0.62));
    canvas.drawRRect(
      rr,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_SpotlightPainter old) => old.hole != hole;
}

/// Centre de notifications : filtres par catégorie, non lues, tout marquer lu, balayage.
class NotificationCenter extends StatefulWidget {
  const NotificationCenter({super.key, this.onUnreadChanged});
  final ValueChanged<int>? onUnreadChanged;

  @override
  State<NotificationCenter> createState() => _NotificationCenterState();
}

class _NotificationCenterState extends State<NotificationCenter> {
  late final List<(DemoNotification, bool)> _items = [for (final n in kNotifications) (n, n.read)];
  String _cat = 'Toutes';
  bool _unreadOnly = false;

  void _emit() => widget.onUnreadChanged?.call(_items.where((e) => !e.$2).length);

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final cats = ['Toutes', ...{for (final n in kNotifications) n.category}];
    final list = _items.where((e) => (_cat == 'Toutes' || e.$1.category == _cat) && (!_unreadOnly || !e.$2)).toList();
    final unread = _items.where((e) => !e.$2).length;
    final now = DateTime.now();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Flexible(child: Text('Notifications', style: TextStyle(fontFamily: Fonts.heading, fontSize: 17, fontWeight: FontWeight.w700, color: c.textPrimary))),
        const SizedBox(width: 8),
        if (unread > 0) CountDot(unread),
        const Spacer(),
        TextButton(
          onPressed: unread == 0
              ? null
              : () {
                  setState(() {
                    for (var i = 0; i < _items.length; i++) {
                      _items[i] = (_items[i].$1, true);
                    }
                  });
                  _emit();
                },
          child: const Text('Tout lu'),
        ),
      ]),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          FilterChip(label: const Text('Non lues'), selected: _unreadOnly, onSelected: (v) => setState(() => _unreadOnly = v)),
          const SizedBox(width: 8),
          for (final cat in cats)
            Padding(padding: const EdgeInsets.only(right: Space.s2), child: ChoiceChip(label: Text(cat), selected: _cat == cat, onSelected: (_) => setState(() => _cat = cat))),
        ]),
      ),
      const SizedBox(height: 6),
      if (list.isEmpty) const EmptyState(compact: true, icon: Icons.notifications_off_outlined, title: 'Rien de neuf', subtitle: 'Vous êtes à jour.'),
      for (final e in list)
        Dismissible(
          key: ValueKey(e.$1.title),
          direction: DismissDirection.endToStart,
          background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: Space.s5), color: c.errorLight, child: Icon(Icons.delete_outline, color: c.errorText)),
          onDismissed: (_) {
            setState(() => _items.remove(e));
            _emit();
          },
          child: InkWell(
            onTap: () {
              final i = _items.indexOf(e);
              setState(() => _items[i] = (e.$1, true));
              _emit();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: Space.s3, horizontal: Space.s1),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.border))),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: 38, height: 38, decoration: BoxDecoration(shape: BoxShape.circle, color: e.$1.tone.light(c)), child: Icon(e.$1.icon, size: 19, color: e.$1.tone.color(c))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(e.$1.title, style: TextStyle(fontWeight: e.$2 ? FontWeight.w500 : FontWeight.w700, color: c.textPrimary)),
                    Text(e.$1.text, style: TextStyle(fontSize: 12.5, color: c.textSecondary)),
                    const SizedBox(height: 2),
                    Text('${Fmt.ago(now.subtract(Duration(minutes: e.$1.minutesAgo)), now)} · ${e.$1.category}', style: TextStyle(fontSize: 11, color: c.textMuted)),
                  ]),
                ),
                if (!e.$2) Container(margin: const EdgeInsets.only(top: Space.s2, left: Space.s2), width: 9, height: 9, decoration: BoxDecoration(color: c.primary, shape: BoxShape.circle)),
              ]),
            ),
          ),
        ),
    ]);
  }
}

/// Menu contextuel à l'appui long (équivalent du clic droit), positionné sous le doigt.
class LongPressMenu<T> extends StatelessWidget {
  const LongPressMenu({super.key, required this.child, required this.items, required this.onSelected});
  final Widget child;
  final List<PopupMenuEntry<T>> items;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (d) async {
        final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
        final v = await showMenu<T>(
          context: context,
          position: RelativeRect.fromRect(d.globalPosition & const Size(1, 1), Offset.zero & overlay.size),
          items: items,
        );
        if (v != null) onSelected(v);
      },
      child: child,
    );
  }
}
