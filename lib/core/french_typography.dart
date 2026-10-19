/// Corrige la typographie française d'un texte saisi au clavier (`french-typography.util.ts`) :
/// guillemets « », apostrophe ’, points de suspension …, tiret –, espaces insécables avant
/// : ; ! ? », séparateurs de milliers (espace fine), unités et heures (14 h 05).
const kNbsp = ' ';
const kNnbsp = ' ';

final _urlRe = RegExp(r'(https?://\S+|www\.\S+|\S+@\S+\.\w+)');
const _units = r'FCFA|F CFA|F|XOF|€|EUR|\$|km|kg|m|habitants|véhicules|balises|clients|Mo|Ko|Go';

String frenchTypography(String input) {
  final out = StringBuffer();
  var last = 0;
  for (final m in _urlRe.allMatches(input)) {
    out.write(_fix(input.substring(last, m.start)));
    out.write(m.group(0));
    last = m.end;
  }
  out.write(_fix(input.substring(last)));
  return out.toString();
}

String _fix(String input) {
  var s = input.replaceAll('...', '…');
  s = s.replaceAllMapped(RegExp(r"(\p{L})'(\p{L})", unicode: true), (m) => '${m[1]}’${m[2]}');
  var open = true;
  s = s.replaceAllMapped(RegExp('"'), (_) {
    final q = open ? '«' : '»';
    open = !open;
    return q;
  });
  s = s.replaceAll(RegExp(r'«\s*'), '«$kNbsp').replaceAll(RegExp(r'\s*»'), '$kNbsp»');
  s = s.replaceAll(' - ', ' – ');
  s = s.replaceAllMapped(RegExp(r'\b(\d{1,2})\s?h\s?(\d{2})?\b'), (m) => '${m[1]}${kNbsp}h${m[2] != null ? '$kNbsp${m[2]}' : ''}');
  s = s.replaceAllMapped(
    RegExp('(?<![\\d,.\\p{L}-])(\\d{4,})(?=(?:[.,]\\d+)?\\s?(?:$_units)(?![\\p{L}\\d]))', unicode: true),
    (m) => m[1]!.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => kNnbsp),
  );
  s = s.replaceAllMapped(RegExp(r'(\d)\s?(FCFA|F CFA|€|%|km/h|km|kg|m|h|min|Mo|Ko|Go)(?![\p{L}\d])', unicode: true), (m) => '${m[1]}$kNbsp${m[2]}');
  s = s.replaceAllMapped(RegExp(r'\s*([;!?])'), (m) => '$kNnbsp${m[1]}');
  s = s.replaceAllMapped(RegExp(r'(\S)\s*:(?!//|\d)'), (m) => '${m[1]}$kNbsp:');
  s = s.replaceAll(RegExp(r'\bEtat\b'), 'État').replaceAll(RegExp(r'\bEquipe\b'), 'Équipe').replaceAllMapped(RegExp(r'\bA (?=\p{Ll})', unicode: true), (_) => 'À ');
  return s;
}

/// Segments pour visualiser les espaces spéciales (◦ insécable, · fine insécable).
List<(String, String)> revealSpaces(String s) {
  final out = <(String, String)>[];
  for (final ch in s.split('')) {
    final kind = ch == kNbsp ? 'nbsp' : (ch == kNnbsp ? 'nnbsp' : 'text');
    if (kind == 'text' && out.isNotEmpty && out.last.$2 == 'text') {
      out[out.length - 1] = (out.last.$1 + ch, 'text');
    } else {
      out.add((kind == 'text' ? ch : ' ', kind));
    }
  }
  return out;
}
