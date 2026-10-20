import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/french_typography.dart';
import '../../core/snack.dart';
import '../../theme/kit_colors.dart';
import '../../theme/kit_text.dart';
import '../../theme/tokens.dart';
import '../../widgets/common.dart';
import '../../widgets/fields/editors.dart';
import '../doc/doc.dart';

const _lorem =
    'La plateforme Lookas suit en temps réel plus de 8 000 véhicules en Côte d’Ivoire. Chaque balise transmet sa position toutes les 30 secondes ; les alertes de zone, de vitesse et de coupure moteur sont envoyées aux exploitants en moins de cinq secondes.';

/// `/components/typography` — tous les concepts typographiques du kit, adaptés au mobile.
class TypographyGallery extends StatefulWidget {
  const TypographyGallery({super.key, this.initialSection});
  final String? initialSection;

  @override
  State<TypographyGallery> createState() => _TypographyGalleryState();
}

class _TypographyGalleryState extends State<TypographyGallery> {
  double _lh = 1.55;
  double _tracking = 0;
  double _measure = 1;
  String _input = 'Le client a dit : "la balise est hors ligne depuis 14h05..." Montant du : 1250000 FCFA ! Equipe d\'intervention - priorite haute ?';
  // Testeur
  String _family = Fonts.heading;
  double _size = 24;
  FontWeight _weight = FontWeight.w700;
  double _pgTracking = 0;
  double _pgLh = 1.3;
  String _pgText = 'Votre flotte, en temps réel';

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final t = context.t;
    return DocPage(
      title: 'Typographie',
      icon: Icons.text_fields,
      initialSection: widget.initialSection,
      subtitle: 'Familles, échelle et hiérarchie, graisses, interlignage, interlettrage, mesure, contraste, chiffres, troncature, styles en ligne, typographie française, tailles adaptatives, accessibilité, et un testeur.',
      sections: [
        DocSection(
          id: 'families',
          title: 'Familles de polices',
          source: 'Fonts.heading · Fonts.body · Fonts.mono · Fonts.brand',
          description: 'Toutes embarquées dans assets/fonts (aucune requête réseau).',
          cols: 2,
          children: [
            for (final (name, fam, role, sample) in const [
              ('Outfit', Fonts.heading, 'Titres, chiffres clés', 'Tableau de bord Finance'),
              ('Inter', Fonts.body, 'Texte courant, interface', 'Le client signale une perte de signal.'),
              ('Space Mono', Fonts.mono, 'Codes, références, valeurs techniques', 'FAC-2026-0912 · 356307042441013'),
              ('TT Wellingtons', Fonts.brand, 'Marque', 'Lookas'),
            ])
              KitCard(
                onTap: () => copyToClipboard(context, "fontFamily: '$fam'"),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(name, style: TextStyle(fontFamily: fam, fontSize: 22, fontWeight: FontWeight.w600, color: c.textPrimary))),
                    Icon(Icons.content_copy, size: 16, color: c.textMuted),
                  ]),
                  Text(role, style: t.caption),
                  const SizedBox(height: 10),
                  Text(sample, style: TextStyle(fontFamily: fam, fontSize: 15, color: c.textSecondary)),
                  const SizedBox(height: 6),
                  Text('Aa Bb Cc 0123456789 éèàçœ « » € %', style: TextStyle(fontFamily: fam, fontSize: 13, color: c.textMuted)),
                ]),
              ),
          ],
        ),
        DocSection(
          id: 'scale',
          title: 'Échelle typographique',
          source: 'KitText (ratio ≈ 1,2 sur la grille de 2 px)',
          children: [
            KitCard(
              padding: EdgeInsets.zero,
              child: Column(children: [
                for (final (n, st, px) in [
                  ('display', t.display, '40'), ('h1', t.h1, '32'), ('h2', t.h2, '24'), ('pageTitle', t.pageTitle, '22'), ('h3', t.h3, '20'),
                  ('h4', t.h4, '16'), ('bodyLg', t.bodyLg, '16'), ('body', t.body, '14'), ('bodySm', t.bodySm, '13'), ('label', t.label, '12'),
                  ('caption', t.caption, '12'), ('overline', t.overline, '11'),
                ])
                  InkWell(
                    onTap: () => copyToClipboard(context, 'KitText.$n'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: Space.s4, vertical: Space.s3),
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.divider))),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                        SizedBox(
                          width: 74,
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(n, style: TextStyle(fontFamily: Fonts.mono, fontSize: 10.5, color: c.primary)),
                            Text('$px px', style: TextStyle(fontSize: 10.5, color: c.textMuted)),
                          ]),
                        ),
                        Expanded(child: Text(n == 'overline' ? 'SUR-TITRE' : 'Suivi de flotte', maxLines: 1, overflow: TextOverflow.ellipsis, style: st)),
                      ]),
                    ),
                  ),
              ]),
            ),
          ],
        ),
        DocSection(
          id: 'hierarchy',
          title: 'Hiérarchie & rythme vertical',
          description: 'Un seul titre fort par écran, sur-titre discret, espacements multiples de 4.',
          children: [
            Demo(
              label: 'Fiche',
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('CONTRAT', style: t.overline),
                const SizedBox(height: 4),
                Text('Contrat en cours', style: t.h3),
                const SizedBox(height: 4),
                Text('Premium — Flotte · 24 véhicules', style: t.bodySm),
                const SizedBox(height: 16),
                Text('Dernière intervention', style: t.h4),
                const SizedBox(height: 4),
                Text('Remplacement de l’antenne GPS sur CI-4521-AB, le 14 octobre à 09 h 55.', style: t.body),
                const SizedBox(height: 12),
                Text('Mis à jour il y a 2 h', style: t.caption),
              ]),
            ),
          ],
        ),
        DocSection(
          id: 'weights',
          title: 'Graisses',
          cols: 2,
          children: [
            for (final fam in const [Fonts.heading, Fonts.body])
              KitCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  for (final (w, n) in const [(FontWeight.w300, 'Light 300'), (FontWeight.w400, 'Regular 400'), (FontWeight.w500, 'Medium 500'), (FontWeight.w600, 'Semibold 600'), (FontWeight.w700, 'Bold 700'), (FontWeight.w800, 'Extrabold 800')])
                    Padding(padding: const EdgeInsets.symmetric(vertical: Space.s0_5), child: Text('${fam == Fonts.heading ? 'Outfit' : 'Inter'} $n', style: TextStyle(fontFamily: fam, fontWeight: w, fontSize: 16, color: c.textPrimary))),
                ]),
              ),
          ],
        ),
        DocSection(
          id: 'line-height',
          title: 'Interlignage',
          description: 'Titres serrés (1,15–1,3), texte 1,55, lecture longue 1,7.',
          children: [
            Demo(
              label: 'height: ${_lh.toStringAsFixed(2).replaceAll('.', ',')}',
              child: Gap([
                Slider(value: _lh, min: 1, max: 2.2, divisions: 24, onChanged: (v) => setState(() => _lh = v)),
                Text(_lorem, style: t.body.copyWith(height: _lh)),
              ]),
            ),
          ],
        ),
        DocSection(
          id: 'tracking',
          title: 'Interlettrage',
          description: 'Négatif sur les grands titres, positif sur les capitales et sur-titres.',
          children: [
            Demo(
              label: 'letterSpacing: ${_tracking.toStringAsFixed(1).replaceAll('.', ',')}',
              child: Gap([
                Slider(value: _tracking, min: -2, max: 4, divisions: 30, onChanged: (v) => setState(() => _tracking = v)),
                Text('Tableau de bord', style: t.h1.copyWith(letterSpacing: _tracking)),
                Text('VÉHICULES ACTIFS', style: t.overline.copyWith(letterSpacing: _tracking + 0.66, fontSize: 13)),
              ]),
            ),
          ],
        ),
        DocSection(
          id: 'measure',
          title: 'Longueur de ligne (mesure)',
          description: 'Idéal : 45 à 75 caractères. Sur téléphone, la largeur d’écran suffit ; sur tablette, limitez avec ConstrainedBox(maxWidth: ~68 em).',
          children: [
            Demo(
              label: 'Largeur ${(_measure * 100).round()} %',
              child: Gap([
                Slider(value: _measure, min: 0.4, max: 1, onChanged: (v) => setState(() => _measure = v)),
                FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: _measure, child: Text(_lorem, style: t.body)),
              ]),
            ),
          ],
        ),
        DocSection(
          id: 'color',
          title: 'Couleur du texte & contraste',
          source: 'textPrimary · textSecondary · textMuted',
          children: [
            KitCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                for (final (n, col, ratio) in [
                  ('textPrimary', c.textPrimary, _contrast(c.textPrimary, c.card)),
                  ('textSecondary', c.textSecondary, _contrast(c.textSecondary, c.card)),
                  ('textMuted', c.textMuted, _contrast(Color.alphaBlend(c.textMuted, c.card), c.card)),
                  ('primary', c.primary, _contrast(c.primary, c.card)),
                  ('errorText', c.errorText, _contrast(c.errorText, c.card)),
                ])
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(children: [
                      Expanded(child: Text('Texte $n', style: TextStyle(color: col, fontWeight: FontWeight.w600))),
                      Text('${ratio.toStringAsFixed(1).replaceAll('.', ',')}:1', style: TextStyle(fontFamily: Fonts.mono, fontSize: 11.5, color: c.textSecondary)),
                      const SizedBox(width: 8),
                      StatusBadge(ratio >= 7 ? 'AAA' : (ratio >= 4.5 ? 'AA' : (ratio >= 3 ? 'AA large' : 'Échec')), tone: ratio >= 4.5 ? KitTone.success : (ratio >= 3 ? KitTone.warning : KitTone.error)),
                    ]),
                  ),
              ]),
            ),
          ],
        ),
        DocSection(
          id: 'alignment',
          title: 'Alignement, césure & retour à la ligne',
          cols: 2,
          children: [
            Demo(label: 'Gauche (par défaut)', child: Text(_lorem, style: t.bodySm)),
            Demo(label: 'Centré (titres courts, états vides)', child: Text('Aucun véhicule ne correspond à vos filtres.', textAlign: TextAlign.center, style: t.body)),
            Demo(label: 'Justifié (à éviter sur mobile)', child: Text(_lorem, textAlign: TextAlign.justify, style: t.bodySm)),
            Demo(label: 'Droite (montants)', child: Text('1 250 000 FCFA\n45 000 FCFA\n2 500 FCFA', textAlign: TextAlign.right, style: t.body.copyWith(fontFeatures: KitText.tabular))),
          ],
        ),
        DocSection(
          id: 'numbers',
          title: 'Chiffres & formats',
          source: 'Fmt (intl fr_FR) · FontFeature.tabularFigures',
          cols: 2,
          children: [
            Demo(
              label: 'Chiffres tabulaires vs proportionnels',
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [for (final v in const ['111 111', '888 888', '1 234 567']) Text(v, style: t.body.copyWith(fontFeatures: KitText.tabular))])),
                const SizedBox(width: 20),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [for (final v in const ['111 111', '888 888', '1 234 567']) Text(v, style: t.body)])),
              ]),
            ),
            Demo(
              label: 'Formats fr-FR',
              child: Column(children: [
                for (final (l, v) in [
                  ('Montant', Fmt.fcfa(1250000)),
                  ('Compact', '${Fmt.compact(55800000)} FCFA'),
                  ('Décimal', Fmt.decimal1(96.4)),
                  ('Date', Fmt.date(DateTime(2026, 10, 16))),
                  ('Date longue', Fmt.dateLong(DateTime(2026, 10, 16))),
                  ('Relative', Fmt.ago(DateTime.now().subtract(const Duration(minutes: 12)))),
                ])
                  Padding(padding: const EdgeInsets.symmetric(vertical: Space.s1), child: Row(children: [Expanded(child: Text(l, style: t.bodySm)), Text(v, style: t.body.copyWith(fontWeight: FontWeight.w600))])),
              ]),
            ),
          ],
        ),
        DocSection(
          id: 'overflow',
          title: 'Troncature & mots longs',
          cols: 2,
          children: [
            Demo(label: 'Une ligne (ellipsis)', child: Text('Groupe Diallo Négoce — Direction régionale de Korhogo et du Poro', maxLines: 1, overflow: TextOverflow.ellipsis, style: t.body)),
            Demo(label: '2 lignes', child: Text(_lorem, maxLines: 2, overflow: TextOverflow.ellipsis, style: t.body)),
            Demo(label: 'Fondu', child: Text(_lorem, maxLines: 2, overflow: TextOverflow.fade, softWrap: true, style: t.body)),
            Demo(label: 'Identifiant long (coupure)', child: Text('lk_live_9f2c4e1a7b3d8e6f5a0c2d4e6f8a0b1c3d5e7f9a', style: t.mono.copyWith(fontSize: 12))),
          ],
        ),
        DocSection(
          id: 'inline',
          title: 'Styles en ligne',
          children: [
            Demo(
              label: 'Text.rich',
              child: Text.rich(
                TextSpan(style: t.body, children: [
                  const TextSpan(text: 'Le '),
                  const TextSpan(text: 'GPS', style: TextStyle(fontWeight: FontWeight.w700)),
                  const TextSpan(text: ' ('),
                  TextSpan(text: 'Global Positioning System', style: const TextStyle(fontStyle: FontStyle.italic)),
                  const TextSpan(text: ') de '),
                  TextSpan(text: 'CI-4521-AB', style: t.mono.copyWith(color: c.primary, backgroundColor: c.primaryLight)),
                  const TextSpan(text: ' est '),
                  TextSpan(text: 'hors ligne', style: TextStyle(color: c.errorText, fontWeight: FontWeight.w600)),
                  const TextSpan(text: '. Ancien statut : '),
                  const TextSpan(text: 'actif', style: TextStyle(decoration: TextDecoration.lineThrough)),
                  const TextSpan(text: '. '),
                  TextSpan(text: 'Voir la fiche', style: TextStyle(color: c.primary, decoration: TextDecoration.underline, decorationColor: c.primary)),
                  const TextSpan(text: ' · H'),
                  const TextSpan(text: '2', style: TextStyle(fontFeatures: [FontFeature.subscripts()])),
                  const TextSpan(text: 'O · 10'),
                  const TextSpan(text: 'e', style: TextStyle(fontFeatures: [FontFeature.superscripts()])),
                  const TextSpan(text: ' étage'),
                ]),
              ),
            ),
          ],
        ),
        const DocSection(
          id: 'prose',
          title: 'Listes, citations & contenu éditorial',
          source: 'MarkdownView',
          children: [
            Demo(
              label: 'Article d’aide',
              child: MarkdownView('''## Installer une balise GPS

Avant de commencer, vérifiez que le véhicule est **à l’arrêt** et le contact coupé.

1. Repérez l’alimentation 12 V permanente
2. Fixez le boîtier sous le tableau de bord
3. Orientez l’antenne vers le ciel

- Durée moyenne : `45 min`
- Outils : multimètre, colliers, gaine

> Une antenne mal orientée réduit la précision de 5 à 15 mètres.'''),
            ),
          ],
        ),
        DocSection(
          id: 'french',
          title: 'Règles de la typographie française',
          source: 'frenchTypography()',
          description: 'Espace insécable (◦) avant « : » et « » », espace fine insécable (·) avant ; ! ?, guillemets « », apostrophe ’, points de suspension, heures 14 h 05, milliers.',
          children: [
            Demo(
              label: 'Correcteur',
              child: Gap([
                TextField(controller: TextEditingController(text: _input), maxLines: 3, onChanged: (v) => setState(() => _input = v)),
                Row(children: [Icon(Icons.arrow_downward, size: 18, color: c.primary), const SizedBox(width: 6), Text('Corrigé', style: t.label)]),
                Container(
                  padding: const EdgeInsets.all(Space.s3),
                  decoration: BoxDecoration(color: c.successLight, borderRadius: Radii.rm),
                  child: Text.rich(TextSpan(children: [
                    for (final (s, k) in revealSpaces(frenchTypography(_input)))
                      k == 'text'
                          ? TextSpan(text: s)
                          : TextSpan(text: k == 'nbsp' ? '◦' : '·', style: TextStyle(color: k == 'nbsp' ? c.primary : c.tertiary, fontWeight: FontWeight.w900)),
                  ]), style: t.body),
                ),
                Wrap(alignment: WrapAlignment.spaceBetween, crossAxisAlignment: WrapCrossAlignment.center, spacing: 12, children: [
                  Text('◦ insécable', style: TextStyle(color: c.primary, fontSize: 12)),
                  Text('· fine insécable', style: TextStyle(color: c.tertiary, fontSize: 12)),
                  TextButton.icon(onPressed: () => copyToClipboard(context, frenchTypography(_input), label: 'Texte corrigé copié'), icon: const Icon(Icons.content_copy, size: 16), label: const Text('Copier')),
                ]),
              ]),
            ),
          ],
        ),
        DocSection(
          id: 'fluid',
          title: 'Typographie responsive (adaptative)',
          description: 'La taille des titres suit la largeur disponible (bornée), et respecte le réglage de taille de texte du système.',
          children: [
            Demo(
              label: 'Titre adaptatif',
              child: LayoutBuilder(builder: (context, cons) {
                final size = (cons.maxWidth * 0.075).clamp(22.0, 40.0);
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Votre flotte, en temps réel', style: t.display.copyWith(fontSize: size)),
                  Text('${cons.maxWidth.round()} px disponibles → ${size.toStringAsFixed(1).replaceAll('.', ',')} px', style: t.caption),
                ]);
              }),
            ),
          ],
        ),
        DocSection(
          id: 'a11y',
          title: 'Accessibilité typographique',
          description: 'Corps ≥ 14 px, contraste AA, pas de texte en image, et respect de la mise à l’échelle du texte (TextScaler) — testez ci-dessous.',
          children: [
            _ScaleDemo(text: _lorem),
          ],
        ),
        DocSection(
          id: 'playground',
          title: 'Testeur typographique',
          children: [
            Demo(
              label: 'Composez votre style',
              code: "TextStyle(fontFamily: '$_family', fontSize: ${_size.round()}, fontWeight: FontWeight.w${_weight.value}, letterSpacing: ${_pgTracking.toStringAsFixed(1)}, height: ${_pgLh.toStringAsFixed(2)})",
              child: Gap([
                Container(
                  padding: const EdgeInsets.all(Space.s4),
                  decoration: BoxDecoration(color: c.fieldBg, borderRadius: Radii.rm),
                  child: Text(_pgText, style: TextStyle(fontFamily: _family, fontSize: _size, fontWeight: _weight, letterSpacing: _pgTracking, height: _pgLh, color: c.textPrimary)),
                ),
                TextField(decoration: const InputDecoration(hintText: 'Texte d’essai'), onChanged: (v) => setState(() => _pgText = v.isEmpty ? 'Votre flotte, en temps réel' : v)),
                SegmentedToggle<String>(
                  value: _family,
                  expand: true,
                  onChanged: (v) => setState(() => _family = v),
                  options: const [(Fonts.heading, 'Outfit', null), (Fonts.body, 'Inter', null), (Fonts.mono, 'Mono', null), (Fonts.brand, 'Marque', null)],
                ),
                _slider('Taille', '${_size.round()} px', _size, 10, 56, (v) => setState(() => _size = v)),
                _slider('Graisse', '${_weight.value}', (_weight.value / 100).toDouble(), 3, 8, (v) => setState(() => _weight = FontWeight.values[v.round() - 1]), divisions: 5),
                _slider('Interlettrage', _pgTracking.toStringAsFixed(1), _pgTracking, -2, 4, (v) => setState(() => _pgTracking = v)),
                _slider('Interlignage', _pgLh.toStringAsFixed(2), _pgLh, 1, 2, (v) => setState(() => _pgLh = v)),
              ]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _slider(String label, String value, double v, double min, double max, ValueChanged<double> onChanged, {int? divisions}) {
    final c = context.kc;
    return Row(children: [
      SizedBox(width: 92, child: Text(label, style: TextStyle(fontSize: 12.5, color: c.textSecondary))),
      Expanded(child: Slider(value: v.clamp(min, max), min: min, max: max, divisions: divisions, onChanged: onChanged)),
      SizedBox(width: 48, child: Text(value, textAlign: TextAlign.right, style: TextStyle(fontFamily: Fonts.mono, fontSize: 11.5, color: c.textPrimary))),
    ]);
  }

  /// Luminance relative WCAG 2.1.
  static double _lum(Color c) {
    double ch(double v) => v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b);
  }

  static double _contrast(Color a, Color b) {
    final l1 = _lum(a), l2 = _lum(b);
    final hi = l1 > l2 ? l1 : l2, lo = l1 > l2 ? l2 : l1;
    return (hi + 0.05) / (lo + 0.05);
  }
}

class _ScaleDemo extends StatefulWidget {
  const _ScaleDemo({required this.text});
  final String text;

  @override
  State<_ScaleDemo> createState() => _ScaleDemoState();
}

class _ScaleDemoState extends State<_ScaleDemo> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Demo(
      label: 'Taille du texte système ×${_scale.toStringAsFixed(1).replaceAll('.', ',')}',
      child: Gap([
        Slider(value: _scale, min: 0.8, max: 2, divisions: 12, onChanged: (v) => setState(() => _scale = v)),
        MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(_scale)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Balise hors ligne', style: t.h4),
            const SizedBox(height: 4),
            Text(widget.text, style: t.body),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              FilledButton(onPressed: () {}, child: const Text('Intervenir')),
              OutlinedButton(onPressed: () {}, child: const Text('Ignorer')),
            ]),
          ]),
        ),
      ]),
    );
  }
}
