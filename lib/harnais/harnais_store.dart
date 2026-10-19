import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/format.dart';
import 'hz_catalog.dart';
import 'hz_models.dart';

/// État du Harnais (équivalent de `HarnaisStore`) : conversations, génération simulée
/// en flux (réflexion → outils → texte mot à mot → widgets), arrêt, relance, retours.
class HarnaisStore extends ChangeNotifier {
  HarnaisStore() : conversations = buildConversations();

  final List<HzConversation> conversations;
  String? activeId;
  String modelId = 'opus';
  bool generating = false;
  bool _cancel = false;
  int _seq = 0;

  HzConversation? get active => conversations.where((c) => c.id == activeId).firstOrNull;

  String _now() => Fmt.time(DateTime.now());
  String _id() => 'g${DateTime.now().microsecondsSinceEpoch}_${_seq++}';

  void open(String? id) {
    activeId = id;
    final c = active;
    if (c != null) modelId = c.model;
    notifyListeners();
  }

  void newConversation() => open(null);

  void setModel(String id) {
    modelId = id;
    active?.model = id;
    notifyListeners();
  }

  void togglePin(String id) {
    final c = conversations.firstWhere((c) => c.id == id);
    c.pinned = !c.pinned;
    notifyListeners();
  }

  void remove(String id) {
    conversations.removeWhere((c) => c.id == id);
    if (activeId == id) activeId = null;
    notifyListeners();
  }

  void rename(String id, String title) {
    conversations.firstWhere((c) => c.id == id).title = title;
    notifyListeners();
  }

  void feedback(HzMessage m, String? value) {
    m.feedback = m.feedback == value ? null : value;
    notifyListeners();
  }

  void stop() {
    if (generating) _cancel = true;
  }

  /// Envoie un message utilisateur et lance la réponse simulée.
  Future<void> send(String text, {List<HzAttachment> attachments = const []}) async {
    if (text.trim().isEmpty || generating) return;
    var conv = active;
    if (conv == null) {
      conv = HzConversation(
        id: _id(),
        title: text.length > 42 ? '${text.substring(0, 40)}…' : text,
        group: 'Aujourd’hui',
        model: modelId,
        messages: [],
      );
      conversations.insert(0, conv);
      activeId = conv.id;
    }
    conv.messages.add(HzMessage(id: _id(), role: HzRole.user, time: _now(), blocks: [HzText(text.trim())], attachments: attachments));
    notifyListeners();
    await _respond(conv, scenarioFor(detectIntent(text)), thinking: 'L’utilisateur demande : « ${text.trim()} ». Je choisis la forme la plus lisible pour y répondre.');
  }

  /// Relance la dernière réponse.
  Future<void> retry() async {
    final conv = active;
    if (conv == null || generating) return;
    final lastUser = conv.messages.lastWhere((m) => m.role == HzRole.user);
    final text = lastUser.blocks.whereType<HzText>().map((t) => t.text).join(' ');
    if (conv.messages.last.role == HzRole.assistant) conv.messages.removeLast();
    notifyListeners();
    await _respond(conv, scenarioFor(detectIntent(text)), thinking: 'Nouvelle tentative avec une présentation différente.');
  }

  /// Soumission d'un formulaire de réponse.
  Future<void> submitForm(HzW form, Map<String, dynamic> values, String summary) async {
    final conv = active;
    if (conv == null || generating) return;
    form.submitted = values;
    conv.messages.add(HzMessage(id: _id(), role: HzRole.user, time: _now(), blocks: [HzText(summary)]));
    notifyListeners();
    await _respond(conv, formFollowUp(form.p['formId'] as String, values));
  }

  /// Réponse à un widget interactif (choix, autorisation, fichier, arbre).
  Future<void> answer(HzW w, HzOption option) async {
    final conv = active;
    if (conv == null || generating) return;
    w.selected = option.value;
    conv.messages.add(HzMessage(id: _id(), role: HzRole.user, time: _now(), blocks: [HzText(option.label)]));
    notifyListeners();
    await _respond(conv, answerFollowUp(w.type, option));
  }

  Future<bool> _wait(int ms) async {
    await Future<void>.delayed(Duration(milliseconds: ms));
    return !_cancel;
  }

  Future<void> _respond(HzConversation conv, HzScenario s, {String? thinking}) async {
    generating = true;
    _cancel = false;
    final msg = HzMessage(id: _id(), role: HzRole.assistant, time: _now(), blocks: [], streaming: true);
    conv.messages.add(msg);
    notifyListeners();
    final started = DateTime.now();

    Future<void> finish({bool stopped = false}) async {
      msg.streaming = false;
      msg.stopped = stopped;
      for (final b in msg.blocks) {
        if (b is HzThinking) b.running = false;
        if (b is HzTool && b.status == HzToolStatus.running) b.status = HzToolStatus.error;
      }
      generating = false;
      _cancel = false;
      notifyListeners();
    }

    // 1. Réflexion.
    final th = HzThinking(thinking ?? 'Je récupère les données utiles puis je construis la réponse.', running: true);
    msg.blocks.add(th);
    notifyListeners();
    if (!await _wait(700)) return finish(stopped: true);
    th.running = false;
    th.duration = '${DateTime.now().difference(started).inSeconds.clamp(1, 9)} s';

    // 2. Outils.
    final tools = s.tools ?? [HzTool(HzToolKind.search, 'Recherche', s.tool, output: 'résultats trouvés')];
    for (final t in tools) {
      final out = t.output;
      t
        ..status = HzToolStatus.running
        ..output = null;
      msg.blocks.add(t);
      notifyListeners();
      if (!await _wait(500)) return finish(stopped: true);
      t
        ..status = HzToolStatus.done
        ..output = out;
      notifyListeners();
    }

    // 3. Texte d'introduction, mot à mot.
    final intro = HzText('');
    msg.blocks.add(intro);
    for (final w in s.intro.split(' ')) {
      intro.text = intro.text.isEmpty ? w : '${intro.text} $w';
      notifyListeners();
      if (!await _wait(28)) return finish(stopped: true);
    }

    // 4. Widgets, un par un.
    for (final b in s.blocks) {
      msg.blocks.add(b);
      notifyListeners();
      if (!await _wait(260)) return finish(stopped: true);
    }

    // 5. Conclusion.
    if (s.outro != null) {
      msg.blocks.add(HzText(s.outro!));
      notifyListeners();
    }
    await finish();
  }
}
