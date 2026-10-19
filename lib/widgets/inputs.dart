import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/format.dart';
import '../theme/kit_colors.dart';
import '../theme/tokens.dart';
import 'common.dart';
import 'selects.dart';

/// Masque de saisie (`input-mask.directive`) : `#` = chiffre, `A` = lettre, `*` = alphanumérique ;
/// les autres caractères sont des littéraux insérés automatiquement.
class MaskFormatter extends TextInputFormatter {
  MaskFormatter(this.mask, {this.upperCase = true});
  final String mask;
  final bool upperCase;

  static bool _accepts(String m, String ch) => switch (m) {
        '#' => RegExp(r'\d').hasMatch(ch),
        'A' => RegExp(r'[a-zA-Z]').hasMatch(ch),
        '*' => RegExp(r'[a-zA-Z0-9]').hasMatch(ch),
        _ => false,
      };

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final raw = newValue.text.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    final buf = StringBuffer();
    var i = 0;
    for (var m = 0; m < mask.length && i < raw.length; m++) {
      final mc = mask[m];
      if (mc == '#' || mc == 'A' || mc == '*') {
        while (i < raw.length && !_accepts(mc, raw[i])) {
          i++;
        }
        if (i >= raw.length) break;
        buf.write(upperCase ? raw[i].toUpperCase() : raw[i]);
        i++;
      } else {
        buf.write(mc);
        if (raw.length > i && raw[i] == mc) i++;
      }
    }
    final text = buf.toString();
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}

/// Champ date (sélecteur Material fr-FR).
class DateField extends StatelessWidget {
  const DateField({super.key, required this.value, required this.onChanged, this.label, this.placeholder = 'JJ/MM/AAAA', this.first, this.last, this.error});
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final String? label, error;
  final String placeholder;
  final DateTime? first, last;

  @override
  Widget build(BuildContext context) {
    final trigger = FieldTrigger(
      text: value == null ? null : Fmt.date(value!),
      placeholder: placeholder,
      icon: Icons.event,
      error: error != null,
      trailing: value == null
          ? Icon(Icons.calendar_month, color: context.kc.textSecondary)
          : IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.close, size: 18), onPressed: () => onChanged(null)),
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: first ?? DateTime(2020),
          lastDate: last ?? DateTime(2030),
          helpText: label ?? 'Choisir une date',
        );
        if (d != null) onChanged(d);
      },
    );
    return label == null ? trigger : FormFieldLabel(label: label!, error: error, child: trigger);
  }
}

/// Période (date de début / fin) avec raccourcis.
class DateRangeField extends StatelessWidget {
  const DateRangeField({super.key, required this.value, required this.onChanged, this.label});
  final DateTimeRange? value;
  final ValueChanged<DateTimeRange?> onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final trigger = FieldTrigger(
      text: value == null ? null : '${Fmt.date(value!.start)}  →  ${Fmt.date(value!.end)}',
      placeholder: 'Début  →  Fin',
      icon: Icons.date_range,
      onTap: () async {
        final r = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2024),
          lastDate: DateTime(2028),
          initialDateRange: value,
          helpText: label ?? 'Période',
        );
        if (r != null) onChanged(r);
      },
    );
    return label == null ? trigger : FormFieldLabel(label: label!, child: trigger);
  }
}

/// Champ heure (sélecteur Material 24 h).
class TimeField extends StatelessWidget {
  const TimeField({super.key, required this.value, required this.onChanged, this.label, this.placeholder = 'HH:MM'});
  final TimeOfDay? value;
  final ValueChanged<TimeOfDay> onChanged;
  final String? label;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    String fmt(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    final trigger = FieldTrigger(
      text: value == null ? null : fmt(value!),
      placeholder: placeholder,
      icon: Icons.schedule,
      onTap: () async {
        final t = await showTimePicker(
          context: context,
          initialTime: value ?? const TimeOfDay(hour: 9, minute: 0),
          builder: (ctx, child) => MediaQuery(data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true), child: child!),
        );
        if (t != null) onChanged(t);
      },
    );
    return label == null ? trigger : FormFieldLabel(label: label!, child: trigger);
  }
}

/// Fichier « local » de démonstration (aucun envoi réseau).
class DemoFile {
  const DemoFile(this.name, this.bytes, {this.icon = Icons.insert_drive_file});
  final String name;
  final int bytes;
  final IconData icon;

  String get ext => name.contains('.') ? name.split('.').last.toUpperCase() : '';
  String get size => Fmt.fileSize(bytes);
}

const kDemoFiles = [
  DemoFile('contrat-cadre-2026.pdf', 1258000, icon: Icons.picture_as_pdf),
  DemoFile('carte-grise-CI-4521-AB.jpg', 845000, icon: Icons.image),
  DemoFile('releve-kilometrique-T3.xlsx', 86000, icon: Icons.table_view),
  DemoFile('photo-installation.png', 2410000, icon: Icons.image),
  DemoFile('attestation-assurance.pdf', 412000, icon: Icons.picture_as_pdf),
];

/// Sélecteur de fichier simulé (feuille) : le kit reste 100 % local.
Future<DemoFile?> pickDemoFile(BuildContext context, {String title = 'Choisir un fichier'}) {
  return showSelectSheet<DemoFile>(
    context,
    title: title,
    searchable: false,
    options: [for (final f in kDemoFiles) SelectOption(f, f.name, icon: f.icon, subtitle: f.size)],
  );
}

/// `<app-file-upload>` : champ avec fichier joint, aperçu et suppression.
class FileUploadField extends StatelessWidget {
  const FileUploadField({super.key, required this.file, required this.onChanged, this.label, this.placeholder = 'Joindre un document', this.enabled = true, this.icon = Icons.attach_file});
  final DemoFile? file;
  final ValueChanged<DemoFile?> onChanged;
  final String? label;
  final String placeholder;
  final bool enabled;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final trigger = FieldTrigger(
      enabled: enabled,
      icon: file?.icon ?? icon,
      text: file == null ? null : '${file!.name} · ${file!.size}',
      placeholder: placeholder,
      trailing: file == null
          ? Icon(Icons.upload_file, color: c.primary)
          : IconButton(visualDensity: VisualDensity.compact, tooltip: 'Retirer', icon: Icon(Icons.delete_outline, size: 20, color: c.error), onPressed: () => onChanged(null)),
      onTap: () async {
        final f = await pickDemoFile(context);
        if (f != null) onChanged(f);
      },
    );
    return label == null ? trigger : FormFieldLabel(label: label!, child: trigger);
  }
}

/// Zone de dépôt : bordure pointillée, liste des fichiers ajoutés.
class DropZone extends StatelessWidget {
  const DropZone({super.key, required this.files, required this.onChanged, this.hint = 'PDF, JPG ou PNG · 10 Mo max.'});
  final List<DemoFile> files;
  final ValueChanged<List<DemoFile>> onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      CustomPaint(
        painter: DashedBorderPainter(color: c.primary.withValues(alpha: 0.5), radius: Radii.l),
        child: Material(
          color: c.primaryLight,
          borderRadius: Radii.rl,
          child: InkWell(
            borderRadius: Radii.rl,
            onTap: () async {
              final f = await pickDemoFile(context, title: 'Ajouter des fichiers');
              if (f != null) onChanged([...files, f]);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              child: Column(children: [
                Icon(Icons.cloud_upload_outlined, size: 40, color: c.primary),
                const SizedBox(height: 8),
                Text('Touchez pour choisir des fichiers', style: TextStyle(fontWeight: FontWeight.w600, color: c.textPrimary)),
                const SizedBox(height: 2),
                Text(hint, style: TextStyle(fontSize: 12, color: c.textMuted)),
              ]),
            ),
          ),
        ),
      ),
      for (final f in files)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: KitCard(
            radius: Radii.m,
            padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
            child: Row(children: [
              Icon(f.icon, color: c.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(f.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  Text(f.size, style: TextStyle(fontSize: 11.5, color: c.textMuted)),
                ]),
              ),
              IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => onChanged([...files]..remove(f))),
            ]),
          ),
        ),
    ]);
  }
}

/// Bordure pointillée arrondie.
class DashedBorderPainter extends CustomPainter {
  DashedBorderPainter({required this.color, this.radius = 12, this.dash = 6, this.gap = 4, this.strokeWidth = 1.5});
  final Color color;
  final double radius, dash, gap, strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final path = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)));
    for (final m in path.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, d + dash), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(DashedBorderPainter old) => old.color != color;
}

/// Barre de recherche compacte (`.m3-search-bar`).
class KitSearchBar extends StatelessWidget {
  const KitSearchBar({super.key, this.controller, this.onChanged, this.hint = 'Rechercher…', this.trailing});
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String hint;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return Container(
      height: 46,
      decoration: BoxDecoration(color: c.card, borderRadius: Radii.pill, border: Border.all(color: c.border)),
      child: Row(children: [
        const SizedBox(width: 14),
        Icon(Icons.search, size: 20, color: c.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        ?trailing,
        const SizedBox(width: 6),
      ]),
    );
  }
}
