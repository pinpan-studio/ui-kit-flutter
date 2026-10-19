import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/snack.dart';
import '../showcase/doc/doc.dart' show CodeBlock;
import '../theme/kit_colors.dart';
import '../theme/kit_text.dart';
import '../theme/theme_controller.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import '../widgets/fields/editors.dart';
import 'harnais_store.dart';
import 'hz_catalog.dart';
import 'hz_models.dart';
import 'hz_widgets.dart';

/// Harnais : interface conversationnelle façon assistant IA, adaptée au mobile.
/// L'historique passe dans un tiroir, le panneau artefacts / contexte / tâches dans
/// une feuille basse. Toutes les réponses sont simulées localement.
class HarnaisScreen extends StatefulWidget {
  const HarnaisScreen({super.key, this.onExit});
  final VoidCallback? onExit;

  @override
  State<HarnaisScreen> createState() => _HarnaisScreenState();
}

class _HarnaisScreenState extends State<HarnaisScreen> {
  final _store = HarnaisStore();
  final _scroll = ScrollController();
  final _scaffold = GlobalKey<ScaffoldState>();
  int _lastCount = 0;

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStore);
  }

  @override
  void dispose() {
    _store.removeListener(_onStore);
    _store.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// Suit le bas du fil pendant la génération.
  void _onStore() {
    final conv = _store.active;
    final count = conv?.messages.fold<int>(0, (n, m) => n + m.blocks.length) ?? 0;
    if (count != _lastCount && _store.generating) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      });
    }
    _lastCount = count;
  }

  String get _greeting {
    final h = DateTime.now().hour;
    return h < 12 ? 'Bonjour' : (h < 18 ? 'Bon après-midi' : 'Bonsoir');
  }

  void _openPanel([int tab = 0]) {
    final arts = _artifacts();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => SizedBox(height: MediaQuery.sizeOf(context).height * 0.8, child: _SidePanel(artifacts: arts, initialTab: tab)),
    );
  }

  List<HzArtifact> _artifacts() {
    final ids = {for (final m in _store.active?.messages ?? const <HzMessage>[]) ...m.blocks.whereType<HzArtifactRef>().map((a) => a.id)};
    return ids.isEmpty ? kHzArtifacts : kHzArtifacts.where((a) => ids.contains(a.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final c = context.kc;
        final conv = _store.active;
        final actions = HzActions(
          busy: _store.generating,
          onAnswer: (w, o) => _store.answer(w, o),
          onSubmit: (w, v, s) => _store.submitForm(w, v, s),
        );
        return Scaffold(
          key: _scaffold,
          drawer: Drawer(
            width: 310,
            child: _ConversationList(
              store: _store,
              onOpen: (id) {
                Navigator.pop(context);
                _store.open(id);
              },
            ),
          ),
          appBar: AppBar(
            titleSpacing: 0,
            title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(conv?.title ?? 'Nouvelle conversation', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16)),
              if (conv?.project != null)
                Row(children: [
                  Icon(Icons.folder_outlined, size: 13, color: c.textMuted),
                  const SizedBox(width: 3),
                  Text(conv!.project!, style: TextStyle(fontSize: 11.5, color: c.textMuted, fontWeight: FontWeight.w500)),
                ]),
            ]),
            actions: [
              IconButton(tooltip: 'Nouvelle conversation', onPressed: _store.generating ? null : _store.newConversation, icon: const Icon(Icons.rate_review_outlined)),
              IconButton(tooltip: 'Artefacts, contexte et tâches', onPressed: _openPanel, icon: const Icon(Icons.view_sidebar_outlined)),
              PopupMenuButton<String>(
                onSelected: (v) {
                  switch (v) {
                    case 'share':
                      copyToClipboard(context, 'https://harnais.example/c/${conv?.id}', label: 'Lien de partage copié');
                    case 'theme':
                      ThemeController.instance.toggle();
                    case 'appearance':
                      showThemeSheet(context);
                    case 'exit':
                      widget.onExit?.call();
                  }
                },
                itemBuilder: (_) => [
                  if (conv != null) const PopupMenuItem(value: 'share', child: ListTile(leading: Icon(Icons.ios_share), title: Text('Partager'))),
                  const PopupMenuItem(value: 'theme', child: ListTile(leading: Icon(Icons.contrast), title: Text('Changer de thème'))),
                  const PopupMenuItem(value: 'appearance', child: ListTile(leading: Icon(Icons.palette_outlined), title: Text('Apparence…'))),
                  const PopupMenuItem(value: 'exit', child: ListTile(leading: Icon(Icons.widgets_outlined), title: Text('Retour au catalogue'))),
                ],
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: conv == null || conv.messages.isEmpty
                ? _Welcome(store: _store, greeting: _greeting)
                : Column(children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.fromLTRB(Space.s4, Space.s3, Space.s4, Space.s6),
                        itemCount: conv.messages.length,
                        itemBuilder: (_, i) {
                          final m = conv.messages[i];
                          final lastAssistant = m.role == HzRole.assistant && i == conv.messages.length - 1;
                          return _MessageView(
                            message: m,
                            actions: actions,
                            isLast: lastAssistant && !_store.generating,
                            onRetry: _store.retry,
                            onFeedback: (v) => _store.feedback(m, v),
                            onArtifact: (id) => _openPanel(0),
                          );
                        },
                      ),
                    ),
                    _Composer(store: _store, placeholder: 'Répondre…'),
                    Padding(
                      padding: const EdgeInsets.only(bottom: Space.s2),
                      child: Text('Réponses simulées localement — démonstration statique du UI Kit.', style: TextStyle(fontSize: 10.5, color: c.textMuted)),
                    ),
                  ]),
          ),
        );
      },
    );
  }
}

// ─── Accueil ─────────────────────────────────────────────────────────
class _Welcome extends StatelessWidget {
  const _Welcome({required this.store, required this.greeting});
  final HarnaisStore store;
  final String greeting;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.auto_awesome, color: c.tertiary, size: 28),
              const SizedBox(width: 10),
              Flexible(child: Text('$greeting, Jean', style: KitText.h1.copyWith(fontSize: 26, color: c.textPrimary))),
            ]),
            const SizedBox(height: 20),
            _Composer(store: store, placeholder: 'Comment puis-je vous aider aujourd’hui ?', elevated: true),
            const SizedBox(height: 16),
            Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
              for (final (icon, label, prompt) in kHzSuggestions)
                ActionChip(avatar: Icon(icon, size: 16, color: c.textSecondary), label: Text(label), onPressed: () => store.send(prompt)),
            ]),
          ]),
        ),
      ),
    );
  }
}

// ─── Historique ──────────────────────────────────────────────────────
class _ConversationList extends StatefulWidget {
  const _ConversationList({required this.store, required this.onOpen});
  final HarnaisStore store;
  final ValueChanged<String?> onOpen;

  @override
  State<_ConversationList> createState() => _ConversationListState();
}

class _ConversationListState extends State<_ConversationList> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final s = widget.store;
    final list = s.conversations.where((x) => _q.isEmpty || x.title.toLowerCase().contains(_q.toLowerCase())).toList();
    final pinned = list.where((x) => x.pinned).toList();
    final groups = <String, List<HzConversation>>{};
    for (final x in list.where((x) => !x.pinned)) {
      (groups[x.group] ??= []).add(x);
    }
    Widget tile(HzConversation x) => ListTile(
          dense: true,
          selected: x.id == s.activeId,
          selectedTileColor: c.primaryLight,
          leading: x.pinned ? Icon(Icons.push_pin, size: 16, color: c.tertiary) : null,
          minLeadingWidth: 16,
          title: Text(x.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: x.project == null ? null : Text(x.project!),
          onTap: () => widget.onOpen(x.id),
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz, size: 18),
            onSelected: (v) {
              if (v == 'pin') s.togglePin(x.id);
              if (v == 'del') s.remove(x.id);
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'pin', child: Text(x.pinned ? 'Désépingler' : 'Épingler')),
              PopupMenuItem(value: 'del', child: Text('Supprimer', style: TextStyle(color: c.error))),
            ],
          ),
        );
    return SafeArea(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Space.s4, Space.s4, Space.s3, Space.s2),
          child: Row(children: [
            Icon(Icons.auto_awesome, color: c.tertiary),
            const SizedBox(width: 8),
            Expanded(child: Text('Harnais', style: TextStyle(fontFamily: Fonts.brand, fontSize: 18, fontWeight: FontWeight.w700, color: c.textPrimary))),
            IconButton.filledTonal(tooltip: 'Nouvelle conversation', onPressed: () => widget.onOpen(null), icon: const Icon(Icons.add)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.s3),
          child: TextField(onChanged: (v) => setState(() => _q = v), decoration: const InputDecoration(hintText: 'Rechercher…', prefixIcon: Icon(Icons.search, size: 20))),
        ),
        Expanded(
          child: ListView(padding: const EdgeInsets.symmetric(horizontal: Space.s2, vertical: Space.s2), children: [
            if (pinned.isNotEmpty) ...[_head(c, 'Épinglées'), for (final x in pinned) tile(x)],
            for (final g in groups.entries) ...[_head(c, g.key), for (final x in g.value) tile(x)],
            if (list.isEmpty) Padding(padding: const EdgeInsets.all(Space.s6), child: Text('Aucune conversation', textAlign: TextAlign.center, style: TextStyle(color: c.textMuted))),
          ]),
        ),
        const Divider(),
        const ListTile(leading: KitAvatar(name: 'Jean Kouassi', size: 32), title: Text('Jean Kouassi'), subtitle: Text('Forfait Pro')),
      ]),
    );
  }

  Widget _head(KitColors c, String t) => Padding(
        padding: const EdgeInsets.fromLTRB(Space.s3, Space.s3, Space.s3, Space.s1),
        child: Text(t.toUpperCase(), style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: c.textMuted)),
      );
}

// ─── Saisie ──────────────────────────────────────────────────────────
class _Composer extends StatefulWidget {
  const _Composer({required this.store, required this.placeholder, this.elevated = false});
  final HarnaisStore store;
  final String placeholder;
  final bool elevated;

  @override
  State<_Composer> createState() => _ComposerState();
}

class _ComposerState extends State<_Composer> {
  final _ctrl = TextEditingController();
  final List<HzAttachment> _att = [];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _send() {
    final t = _ctrl.text;
    if (t.trim().isEmpty) return;
    widget.store.send(t, attachments: List.of(_att));
    _ctrl.clear();
    setState(_att.clear);
  }

  Future<void> _attach() async {
    final a = await showModalBottomSheet<HzAttachment>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          for (final a in kHzAttachable) ListTile(leading: Icon(a.icon), title: Text(a.name), subtitle: Text(a.size), onTap: () => Navigator.pop(ctx, a)),
          const SizedBox(height: 8),
        ]),
      ),
    );
    if (a != null && !_att.contains(a)) setState(() => _att.add(a));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final s = widget.store;
    final model = kHzModels.firstWhere((m) => m.id == s.modelId);
    return Container(
      margin: widget.elevated ? EdgeInsets.zero : const EdgeInsets.fromLTRB(Space.s3, 0, Space.s3, Space.s2),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: c.border),
        boxShadow: Elevations.e3(Theme.of(context).brightness),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
        if (_att.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.s3, Space.s3, Space.s3, 0),
            child: Wrap(spacing: 6, runSpacing: 6, children: [
              for (final a in _att) InputChip(avatar: Icon(a.icon, size: 16), label: Text(a.name), onDeleted: () => setState(() => _att.remove(a))),
            ]),
          ),
        TextField(
          controller: _ctrl,
          minLines: 1,
          maxLines: 6,
          textInputAction: TextInputAction.newline,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: widget.placeholder,
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.fromLTRB(Space.s4, Space.s4, Space.s4, Space.s2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(Space.s2, 0, Space.s2, Space.s2),
          child: Row(children: [
            IconButton(tooltip: 'Joindre', onPressed: _attach, icon: const Icon(Icons.add_circle_outline)),
            PopupMenuButton<String>(
              tooltip: 'Modèle',
              initialValue: s.modelId,
              onSelected: s.setModel,
              itemBuilder: (_) => [
                for (final m in kHzModels)
                  PopupMenuItem(
                    value: m.id,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Row(children: [Text(m.label), if (m.badge != null) ...[const SizedBox(width: 6), StatusBadge(m.badge!, tone: KitTone.tertiary, uppercase: false)]]),
                      subtitle: Text(m.description),
                      trailing: m.id == s.modelId ? Icon(Icons.check, color: c.primary) : null,
                    ),
                  ),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Space.s2, vertical: Space.s2),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(model.label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.textSecondary)),
                  Icon(Icons.expand_more, size: 18, color: c.textSecondary),
                ]),
              ),
            ),
            const Spacer(),
            if (s.generating)
              IconButton.filled(tooltip: 'Arrêter', onPressed: s.stop, icon: const Icon(Icons.stop))
            else
              IconButton.filled(
                tooltip: 'Envoyer',
                onPressed: _ctrl.text.trim().isEmpty ? null : _send,
                style: IconButton.styleFrom(backgroundColor: c.tertiary, foregroundColor: Theme.of(context).colorScheme.onTertiary),
                icon: const Icon(Icons.arrow_upward),
              ),
          ]),
        ),
      ]),
    );
  }
}

// ─── Message ─────────────────────────────────────────────────────────
class _MessageView extends StatelessWidget {
  const _MessageView({required this.message, required this.actions, required this.isLast, required this.onRetry, required this.onFeedback, required this.onArtifact});
  final HzMessage message;
  final HzActions actions;
  final bool isLast;
  final VoidCallback onRetry;
  final ValueChanged<String> onFeedback;
  final ValueChanged<String> onArtifact;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final m = message;
    if (m.role == HzRole.user) {
      final text = m.blocks.whereType<HzText>().map((t) => t.text).join('\n');
      return Padding(
        padding: const EdgeInsets.only(bottom: Space.s4, left: Space.s10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          if (m.attachments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.s2),
              child: Wrap(spacing: 6, runSpacing: 6, alignment: WrapAlignment.end, children: [for (final a in m.attachments) HzAttachmentPreview(a)]),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: Space.s4, vertical: Space.s3),
            decoration: BoxDecoration(color: c.hover, borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18), bottomLeft: Radius.circular(18), bottomRight: Radius.circular(Radii.sm))),
            child: Text(text, style: TextStyle(fontSize: 14, height: 1.45, color: c.textPrimary)),
          ),
          const SizedBox(height: 2),
          Text(m.time, style: TextStyle(fontSize: 10.5, color: c.textMuted)),
        ]),
      );
    }
    final plain = m.blocks.whereType<HzText>().map((t) => t.text).join('\n\n');
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Icon(Icons.auto_awesome, size: 18, color: c.tertiary),
          const SizedBox(width: 6),
          Text('Harnais', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: c.textPrimary)),
          const SizedBox(width: 6),
          Text(m.time, style: TextStyle(fontSize: 10.5, color: c.textMuted)),
          if (m.streaming) ...[const SizedBox(width: 8), SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.8, color: c.tertiary))],
        ]),
        const SizedBox(height: 8),
        for (final b in m.blocks) Padding(padding: const EdgeInsets.only(bottom: Space.s3), child: _block(context, c, b)),
        if (m.stopped)
          Row(children: [Icon(Icons.stop_circle_outlined, size: 16, color: c.textMuted), const SizedBox(width: 6), Text('Génération interrompue', style: TextStyle(fontSize: 12, color: c.textMuted, fontStyle: FontStyle.italic))]),
        if (!m.streaming)
          Row(children: [
            _act(Icons.content_copy, 'Copier', () => copyToClipboard(context, plain, label: 'Réponse copiée')),
            _act(m.feedback == 'up' ? Icons.thumb_up : Icons.thumb_up_outlined, 'Bonne réponse', () => onFeedback('up'), active: m.feedback == 'up', color: c.primary),
            _act(m.feedback == 'down' ? Icons.thumb_down : Icons.thumb_down_outlined, 'Mauvaise réponse', () => onFeedback('down'), active: m.feedback == 'down', color: c.error),
            if (isLast) _act(Icons.refresh, 'Régénérer', onRetry),
          ]),
      ]),
    );
  }

  Widget _act(IconData i, String tip, VoidCallback onTap, {bool active = false, Color? color}) =>
      IconButton(tooltip: tip, visualDensity: VisualDensity.compact, iconSize: 17, color: active ? color : null, onPressed: onTap, icon: Icon(i));

  Widget _block(BuildContext context, KitColors c, HzBlock b) {
    switch (b) {
      case HzThinking():
        return _ThinkingView(b: b);
      case HzText():
        return Text.rich(TextSpan(children: markdownInline(b.text, KitText.body, c)), style: TextStyle(fontSize: 14, height: 1.55, color: c.textPrimary));
      case HzList():
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (final it in b.items)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.s1),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(padding: const EdgeInsets.only(top: Space.s2, right: Space.s2, left: Space.s1), child: Container(width: 5, height: 5, decoration: BoxDecoration(color: c.textSecondary, shape: BoxShape.circle))),
                Expanded(child: Text.rich(TextSpan(children: markdownInline(it, KitText.body, c)), style: TextStyle(fontSize: 14, height: 1.5, color: c.textPrimary))),
              ]),
            ),
        ]);
      case HzCode():
        return CodeBlock(code: b.code, file: b.file ?? b.lang, rounded: true);
      case HzTool():
        return _ToolView(t: b);
      case HzArtifactRef():
        final a = kHzArtifacts.where((x) => x.id == b.id).firstOrNull;
        if (a == null) return const SizedBox.shrink();
        return KitCard(
          radius: Radii.m,
          padding: const EdgeInsets.all(Space.s3),
          onTap: () => onArtifact(a.id),
          child: Row(children: [
            Container(width: 38, height: 38, decoration: BoxDecoration(color: c.tertiaryLight, borderRadius: Radii.rm), child: Icon(a.kind == 'code' ? Icons.code : Icons.article_outlined, color: c.tertiary)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(a.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('${a.kind == 'code' ? 'Code' : 'Document'} · v${a.version} · ${a.content.split('\n').length} lignes', style: TextStyle(fontSize: 11.5, color: c.textMuted)),
              ]),
            ),
            Icon(Icons.open_in_new, size: 18, color: c.textMuted),
          ]),
        );
      case HzW():
        return HzWidgetView(w: b, actions: actions);
    }
  }
}

class _ThinkingView extends StatefulWidget {
  const _ThinkingView({required this.b});
  final HzThinking b;

  @override
  State<_ThinkingView> createState() => _ThinkingViewState();
}

class _ThinkingViewState extends State<_ThinkingView> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final b = widget.b;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      InkWell(
        borderRadius: Radii.rs,
        onTap: () => setState(() => _open = !_open),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Space.s0_5),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.psychology_outlined, size: 17, color: c.textMuted),
            const SizedBox(width: 6),
            Text(b.running ? 'Réflexion en cours…' : 'Réflexion · ${b.duration ?? '1 s'}', style: TextStyle(fontSize: 12.5, color: c.textMuted, fontStyle: b.running ? FontStyle.italic : null)),
            Icon(_open ? Icons.expand_less : Icons.expand_more, size: 17, color: c.textMuted),
          ]),
        ),
      ),
      AnimatedSize(
        duration: const Duration(milliseconds: 180),
        child: !_open
            ? const SizedBox(width: double.infinity)
            : Container(
                margin: const EdgeInsets.only(top: Space.s2),
                padding: const EdgeInsets.fromLTRB(Space.s3, Space.s1, Space.s1, Space.s1),
                decoration: BoxDecoration(border: Border(left: BorderSide(color: c.border, width: 2))),
                child: Text(b.text, style: TextStyle(fontSize: 12.5, height: 1.5, color: c.textSecondary)),
              ),
      ),
    ]);
  }
}

class _ToolView extends StatelessWidget {
  const _ToolView({required this.t});
  final HzTool t;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final icon = switch (t.tool) { HzToolKind.read => Icons.description_outlined, HzToolKind.search => Icons.search, HzToolKind.bash => Icons.terminal, HzToolKind.edit => Icons.edit_outlined, HzToolKind.web => Icons.language };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Space.s3, vertical: Space.s2),
      decoration: BoxDecoration(color: c.hover.withValues(alpha: 0.5), borderRadius: Radii.rm, border: Border.all(color: c.border)),
      child: Row(children: [
        Icon(icon, size: 16, color: c.textSecondary),
        const SizedBox(width: 8),
        Text(t.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.textSecondary)),
        const SizedBox(width: 6),
        Expanded(child: Text(t.target, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: Fonts.mono, fontSize: 11.5, color: c.textPrimary))),
        const SizedBox(width: 6),
        switch (t.status) {
          HzToolStatus.running => SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 1.8, color: c.primary)),
          HzToolStatus.done => Flexible(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Flexible(child: Text(t.output ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: c.textMuted))),
                const SizedBox(width: 4),
                Icon(Icons.check_circle, size: 15, color: c.success),
              ]),
            ),
          HzToolStatus.error => Icon(Icons.cancel, size: 15, color: c.error),
        },
      ]),
    );
  }
}

// ─── Panneau artefacts / contexte / tâches ───────────────────────────
class _SidePanel extends StatelessWidget {
  const _SidePanel({required this.artifacts, this.initialTab = 0});
  final List<HzArtifact> artifacts;
  final int initialTab;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final used = kHzContext.fold<int>(0, (n, f) => n + f.tokens);
    return DefaultTabController(
      length: 3,
      initialIndex: initialTab,
      child: Column(children: [
        const TabBar(tabs: [Tab(text: 'Artefacts'), Tab(text: 'Contexte'), Tab(text: 'Tâches')]),
        Expanded(
          child: TabBarView(children: [
            ListView(padding: const EdgeInsets.all(Space.s4), children: [
              for (final a in artifacts) ...[
                Row(children: [
                  Icon(a.kind == 'code' ? Icons.code : Icons.article_outlined, color: c.tertiary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(a.title, style: const TextStyle(fontWeight: FontWeight.w700))),
                  StatusBadge('v${a.version}', uppercase: false),
                ]),
                const SizedBox(height: 8),
                a.kind == 'code' ? CodeBlock(code: a.content, file: a.lang, rounded: true) : KitCard(child: MarkdownView(a.content)),
                const SizedBox(height: 18),
              ],
            ]),
            ListView(padding: const EdgeInsets.all(Space.s4), children: [
              Text('Fenêtre de contexte', style: context.t.h4),
              const SizedBox(height: 6),
              KitProgressBar(value: used / kHzContextLimit, height: 8),
              const SizedBox(height: 4),
              Text('${Fmt.number(used)} / ${Fmt.number(kHzContextLimit)} jetons (${(used / kHzContextLimit * 100).toStringAsFixed(1).replaceAll('.', ',')} %)', style: context.t.caption),
              const SizedBox(height: 12),
              for (final f in kHzContext)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(f.kind == 'image' ? Icons.image_outlined : Icons.code),
                  title: Text(f.name),
                  subtitle: Text(f.path),
                  trailing: Text('${Fmt.number(f.tokens)} j.', style: TextStyle(fontSize: 12, color: c.textMuted)),
                ),
            ]),
            ListView(padding: const EdgeInsets.all(Space.s4), children: [
              for (final t in kHzTasks)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: switch (t.status) {
                    'done' => Icon(Icons.check_circle, color: c.success),
                    'running' => SizedBox(width: 22, height: 22, child: Padding(padding: const EdgeInsets.all(Space.s0_5), child: CircularProgressIndicator(strokeWidth: 2, color: c.primary))),
                    _ => Icon(Icons.radio_button_unchecked, color: c.textMuted),
                  },
                  title: Text(t.label, style: TextStyle(decoration: t.status == 'done' ? TextDecoration.lineThrough : null, color: t.status == 'done' ? c.textMuted : c.textPrimary)),
                ),
            ]),
          ]),
        ),
      ]),
    );
  }
}
