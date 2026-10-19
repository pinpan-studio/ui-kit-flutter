import 'package:intl/intl.dart';

/// Formats d'affichage fr-FR (dates, montants FCFA, nombres).
abstract final class Fmt {
  static final _int = NumberFormat.decimalPattern('fr_FR');
  static final _dec1 = NumberFormat('#,##0.0', 'fr_FR');

  /// `1 250 000` (espaces fines insécables, comme `| number` côté web).
  static String number(num v) => _int.format(v);

  static String decimal1(num v) => _dec1.format(v);

  /// `1 250 000 FCFA`
  static String fcfa(num v) => '${number(v)} FCFA';

  /// `1,3 M` — montants compacts des KPI.
  static String compact(num v) {
    if (v.abs() >= 1e9) return '${decimal1(v / 1e9)} Md';
    if (v.abs() >= 1e6) return '${decimal1(v / 1e6)} M';
    if (v.abs() >= 1e3) return '${number((v / 1e3).round())} k';
    return number(v);
  }

  static String date(DateTime d) => DateFormat('dd/MM/yyyy', 'fr_FR').format(d);
  static String dateLong(DateTime d) => DateFormat('d MMMM yyyy', 'fr_FR').format(d);
  static String dayMonth(DateTime d) => DateFormat('d MMM', 'fr_FR').format(d);
  static String time(DateTime d) => DateFormat('HH:mm', 'fr_FR').format(d);
  static String dateTime(DateTime d) => DateFormat("dd/MM/yyyy 'à' HH:mm", 'fr_FR').format(d);
  static String weekday(DateTime d) => DateFormat('EEEE d MMMM', 'fr_FR').format(d);

  /// « il y a 5 min », « hier »… (pipe `inTime`).
  static String ago(DateTime d, [DateTime? now]) {
    final diff = (now ?? DateTime.now()).difference(d);
    if (diff.inSeconds < 60) return 'à l’instant';
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
    if (diff.inDays == 1) return 'hier';
    if (diff.inDays < 30) return 'il y a ${diff.inDays} j';
    return date(d);
  }

  static String initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    return name.trim().split(RegExp(r'\s+')).take(2).map((p) => p[0]).join().toUpperCase();
  }

  static String fileSize(int bytes) {
    if (bytes >= 1 << 20) return '${decimal1(bytes / (1 << 20))} Mo';
    if (bytes >= 1 << 10) return '${(bytes / (1 << 10)).round()} Ko';
    return '$bytes o';
  }
}
