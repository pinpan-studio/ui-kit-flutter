import 'package:flutter/material.dart';

import '../theme/kit_colors.dart';

// ═══════════════════════════════════════════════════════════════════
// Modèle du module Harnais (interface conversationnelle façon assistant IA).
// Aucune API : les réponses sont simulées localement par HarnaisStore.
// ═══════════════════════════════════════════════════════════════════

/// Bloc d'un message.
sealed class HzBlock {}

class HzThinking extends HzBlock {
  HzThinking(this.text, {this.duration, this.running = false});
  final String text;
  String? duration;
  bool running;
}

class HzText extends HzBlock {
  HzText(this.text);
  String text;
}

class HzList extends HzBlock {
  HzList(this.items);
  final List<String> items;
}

class HzCode extends HzBlock {
  HzCode(this.code, {this.lang = 'text', this.file});
  final String code, lang;
  final String? file;
}

enum HzToolKind { read, search, bash, edit, web }

enum HzToolStatus { running, done, error }

class HzTool extends HzBlock {
  HzTool(this.tool, this.label, this.target, {this.status = HzToolStatus.done, this.output});
  final HzToolKind tool;
  final String label, target;
  HzToolStatus status;
  String? output;
}

class HzArtifactRef extends HzBlock {
  HzArtifactRef(this.id);
  final String id;
}

/// Widget affiché dans une réponse (`HarnaisWidget`) : type + cadre + propriétés libres.
/// Les propriétés reprennent celles du modèle TypeScript (items, columns, rows, fields…).
class HzW extends HzBlock {
  HzW(this.type, {this.title, this.subtitle, this.icon, Map<String, dynamic>? p}) : p = p ?? {};
  final String type;
  final String? title, subtitle;
  final IconData? icon;
  final Map<String, dynamic> p;

  /// Réponse mémorisée pour les widgets interactifs (choix, autorisation, fichier, arbre).
  String? selected;

  /// Valeurs d'un formulaire soumis (le formulaire passe alors en lecture seule).
  Map<String, dynamic>? submitted;

  static const answerable = {'choices', 'approval', 'upload', 'tree'};
}

/// Option (choix, select, radio…).
class HzOption {
  const HzOption(this.value, this.label, {this.icon, this.description});
  final String value, label;
  final IconData? icon;
  final String? description;
}

/// Champ de formulaire.
class HzField {
  const HzField(this.key, this.label, this.kind, {this.placeholder, this.icon, this.required = false, this.options = const [], this.min, this.max, this.step, this.unit, this.value, this.wide = false});
  final String key, label, kind;
  final String? placeholder, unit;
  final IconData? icon;
  final bool required, wide;
  final List<HzOption> options;
  final double? min, max, step;
  final Object? value;
}

class HzStat {
  const HzStat(this.label, this.value, {this.delta, this.up, this.tone = KitTone.primary, this.icon, this.hint, this.spark});
  final String label, value;
  final String? delta, hint;
  final bool? up;
  final KitTone tone;
  final IconData? icon;
  final List<double>? spark;
}

class HzColumn {
  const HzColumn(this.key, this.label, {this.kind = 'text', this.tones = const {}, this.unit = ''});
  final String key, label, kind, unit;
  final Map<String, KitTone> tones;
}

class HzRecord {
  const HzRecord(this.title, {this.subtitle, this.meta, this.tone = KitTone.primary, this.badge, this.badgeTone = KitTone.neutral, this.tags = const []});
  final String title;
  final String? subtitle, meta, badge;
  final KitTone tone, badgeTone;
  final List<String> tags;
}

class HzTimelineItem {
  const HzTimelineItem(this.time, this.title, {this.text, this.tone = KitTone.primary, this.icon = Icons.circle});
  final String time, title;
  final String? text;
  final KitTone tone;
  final IconData icon;
}

class HzTreeNode {
  const HzTreeNode(this.id, this.label, {this.icon = Icons.description_outlined, this.meta, this.badge, this.badgeTone = KitTone.neutral, this.children = const []});
  final String id, label;
  final IconData icon;
  final String? meta, badge;
  final KitTone badgeTone;
  final List<HzTreeNode> children;

  Iterable<HzTreeNode> get leaves sync* {
    if (children.isEmpty) {
      yield this;
    } else {
      for (final c in children) {
        yield* c.leaves;
      }
    }
  }
}

class HzSlide {
  const HzSlide(this.title, {this.text, this.icon, this.tone = KitTone.primary, this.tag, this.stats = const [], this.image});
  final String title;
  final String? text, tag, image;
  final IconData? icon;
  final KitTone tone;
  final List<(String, String)> stats;
}

class HzStep {
  const HzStep(this.label, this.status, {this.text});
  final String label, status; // done | current | todo | error
  final String? text;
}

class HzPair {
  const HzPair(this.label, this.value, {this.icon, this.mono = false, this.tone, this.copy = false});
  final String label, value;
  final IconData? icon;
  final bool mono, copy;
  final KitTone? tone;
}

class HzMeter {
  const HzMeter(this.label, this.value, this.target, {this.unit = '', this.tone = KitTone.primary});
  final String label, unit;
  final double value, target;
  final KitTone tone;
}

class HzCard {
  const HzCard(this.title, {this.text, this.icon, this.tone = KitTone.primary, this.price, this.meta, this.tags = const [], this.cta});
  final String title;
  final String? text, price, meta, cta;
  final IconData? icon;
  final KitTone tone;
  final List<String> tags;
}

class HzSource {
  const HzSource(this.title, this.site, {this.snippet, this.date});
  final String title, site;
  final String? snippet, date;
}

class HzFile {
  const HzFile(this.name, this.ext, this.size, {this.date, this.by});
  final String name, ext, size;
  final String? date, by;
}

// ─── Messages et conversations ───────────────────────────────────────

enum HzRole { user, assistant }

class HzAttachment {
  const HzAttachment(this.name, this.kind, this.size);
  final String name, kind, size; // kind : code | image | pdf | sheet

  IconData get icon => switch (kind) { 'code' => Icons.code, 'image' => Icons.image_outlined, 'pdf' => Icons.picture_as_pdf_outlined, _ => Icons.table_view_outlined };
}

class HzMessage {
  HzMessage({required this.id, required this.role, required this.blocks, required this.time, this.attachments = const [], this.streaming = false, this.stopped = false, this.feedback});
  final String id;
  final HzRole role;
  final List<HzBlock> blocks;
  final String time;
  final List<HzAttachment> attachments;
  bool streaming, stopped;
  String? feedback; // up | down
}

class HzConversation {
  HzConversation({required this.id, required this.title, required this.group, required this.model, required this.messages, this.pinned = false, this.project});
  final String id;
  String title;
  final String group;
  String model;
  bool pinned;
  final String? project;
  final List<HzMessage> messages;
}

class HzModel {
  const HzModel(this.id, this.label, this.description, {this.badge});
  final String id, label, description;
  final String? badge;
}

class HzArtifact {
  const HzArtifact(this.id, this.title, this.kind, this.lang, this.version, this.content);
  final String id, title, kind, lang, content;
  final int version;
}

class HzTask {
  const HzTask(this.label, this.status);
  final String label, status; // done | running | todo
}

class HzContextFile {
  const HzContextFile(this.name, this.path, this.tokens, this.kind);
  final String name, path, kind;
  final int tokens;
}
