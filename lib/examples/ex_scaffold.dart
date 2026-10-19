import 'package:flutter/material.dart';

import '../core/snack.dart';
import '../theme/kit_colors.dart';
import '../theme/tokens.dart';
import '../widgets/kit_buttons.dart';

/// Page d'exemple autonome : barre d'app, contenu centré à largeur max, défilement.
class ExPage extends StatelessWidget {
  const ExPage({super.key, required this.title, required this.children, this.maxWidth = 720, this.bottom, this.actions = const []});

  final String title;
  final List<Widget> children;
  final double maxWidth;
  final Widget? bottom;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      bottomNavigationBar: bottom,
      body: LayoutBuilder(builder: (context, box) {
        final pad = box.maxWidth < Breakpoints.tablet ? Space.s4 : Space.s6;
        return SingleChildScrollView(
          padding: EdgeInsets.all(pad),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
            ),
          ),
        );
      }),
    );
  }
}

/// Titre + sous-titre de section.
class ExHeading extends StatelessWidget {
  const ExHeading(this.title, {super.key, this.subtitle});
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.s4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        if (subtitle != null) ...[
          const SizedBox(height: Space.s1),
          Text(subtitle!, style: TextStyle(color: c.textMuted)),
        ],
      ]),
    );
  }
}

/// Colonne espacée régulièrement.
class ExGap extends StatelessWidget {
  const ExGap(this.children, {super.key, this.gap = Space.s4});
  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        for (var i = 0; i < children.length; i++) ...[if (i > 0) SizedBox(height: gap), children[i]],
      ]);
}

/// Deux champs côte à côte au-delà de 600 px, empilés en dessous.
class ExRow extends StatelessWidget {
  const ExRow(this.children, {super.key});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        if (box.maxWidth < Breakpoints.md) return ExGap(children);
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (var i = 0; i < children.length; i++) ...[if (i > 0) const SizedBox(width: Space.s4), Expanded(child: children[i])],
        ]);
      });
}

/// Écran de succès commun aux formulaires.
class ExSuccess extends StatelessWidget {
  const ExSuccess({super.key, required this.title, required this.message, required this.onReset});
  final String title, message;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.s10),
      child: Column(children: [
        Icon(Icons.check_circle, size: 64, color: KitTone.success.text(c)),
        const SizedBox(height: Space.s4),
        Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: Space.s2),
        Text(message, textAlign: TextAlign.center, style: TextStyle(color: c.textMuted)),
        const SizedBox(height: Space.s6),
        KitButton(label: 'Recommencer', icon: Icons.refresh, variant: KitButtonVariant.outline, onPressed: onReset),
      ]),
    );
  }
}

void exDemo(BuildContext context, String what) => showKitSnack(context, '$what (démo)');
