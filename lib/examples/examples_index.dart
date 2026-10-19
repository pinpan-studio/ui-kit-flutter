import 'package:flutter/material.dart';

import '../theme/kit_colors.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import 'auth_examples.dart';
import 'forms_examples.dart';

/// Entrée d'exemple : (id, titre, description, icône, page).
typedef ExEntry = (String, String, String, IconData, WidgetBuilder);

final List<(String, List<ExEntry>)> kExampleGroups = [
  ('Authentification', [
    for (final id in kAuthVariants.keys)
      ('auth/$id', kAuthLabels[id]!, '/examples/auth/$id', Icons.lock_outline, (_) => AuthExample(variant: id)),
  ]),
  ('Formulaires', [
    ('forms/contact', 'Contact', 'Formulaire de contact avec coordonnées', Icons.mail_outline, (_) => const ContactFormExample()),
    ('forms/checkout', 'Commande', 'Tunnel de paiement en 3 étapes', Icons.shopping_bag_outlined, (_) => const CheckoutFormExample()),
    ('forms/onboarding', 'Onboarding', 'Configuration de l’espace en 4 étapes', Icons.rocket_launch_outlined, (_) => const OnboardingFormExample()),
    ('forms/survey', 'Questionnaire', 'Sondage NPS question par question', Icons.poll_outlined, (_) => const SurveyFormExample()),
    ('forms/booking', 'Réservation', 'Choix de prestation, jour et créneau', Icons.event_outlined, (_) => const BookingFormExample()),
    ('forms/application', 'Candidature', 'Long formulaire à sections avec barre fixe', Icons.badge_outlined, (_) => const ApplicationFormExample()),
  ]),
];

/// Index des pages d'exemple (`/examples`).
class ExamplesIndex extends StatelessWidget {
  const ExamplesIndex({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return Scaffold(
      appBar: AppBar(title: const Text('Pages d’exemple')),
      body: ListView(padding: const EdgeInsets.all(Space.s4), children: [
        for (final g in kExampleGroups) ...[
          Padding(padding: const EdgeInsets.fromLTRB(Space.s1, Space.s4, 0, Space.s3), child: Text(g.$1.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1, color: c.textMuted))),
          ResponsiveGrid(minItemWidth: 260, spacing: Space.s3, children: [
            for (final e in g.$2)
              KitCard(
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: e.$5)),
                child: Row(children: [
                  Icon(e.$4, color: c.primary),
                  const SizedBox(width: Space.s3),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(e.$2, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(e.$3, style: TextStyle(fontSize: 12, color: c.textMuted)),
                  ])),
                  Icon(Icons.chevron_right, color: c.textMuted),
                ]),
              ),
          ]),
        ],
      ]),
    );
  }
}
