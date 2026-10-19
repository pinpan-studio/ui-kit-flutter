import 'package:flutter/material.dart';

import '../core/snack.dart';
import '../theme/kit_colors.dart';
import '../theme/tokens.dart';
import '../widgets/kit_buttons.dart';

/// Indique qu'une page est rendue dans le shell applicatif ([ExAppShell]) : la page masque alors
/// sa propre barre d'app (le shell fournit barre supérieure, fil d'Ariane et navigation).
class ExShellScope extends InheritedWidget {
  const ExShellScope({super.key, required super.child});
  static bool of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<ExShellScope>() != null;
  @override
  bool updateShouldNotify(ExShellScope oldWidget) => false;
}

/// Barre d'app d'une page à Scaffold propre : supprimée dans le shell, sauf si elle porte des
/// actions utiles (elle devient alors une barre secondaire compacte, sans retour automatique).
PreferredSizeWidget? exAppBar(BuildContext context, String title, {List<Widget> actions = const [], Widget? leading}) {
  if (!ExShellScope.of(context)) return AppBar(title: Text(title), actions: actions, leading: leading);
  if (actions.isEmpty && leading == null) return null;
  return AppBar(primary: false, automaticallyImplyLeading: false, toolbarHeight: 48, leading: leading, title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)), actions: actions);
}

/// Page d'exemple autonome : barre d'app, contenu centré à largeur max, défilement.
class ExPage extends StatelessWidget {
  const ExPage({super.key, required this.title, required this.children, this.maxWidth = 720, this.bottom, this.actions = const [], this.endDrawer, this.scaffoldKey});

  final String title;
  final List<Widget> children;
  final double maxWidth;
  final Widget? bottom;
  final List<Widget> actions;
  final Widget? endDrawer;
  final Key? scaffoldKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      endDrawer: endDrawer,
      appBar: ExShellScope.of(context) ? null : AppBar(title: Text(title), actions: actions),
      bottomNavigationBar: bottom,
      body: LayoutBuilder(builder: (context, box) {
        final pad = box.maxWidth < Breakpoints.tablet ? Space.s4 : Space.s6;
        final shell = ExShellScope.of(context);
        return SingleChildScrollView(
          padding: shell ? EdgeInsets.fromLTRB(pad, Space.s3, pad, pad) : EdgeInsets.all(pad),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                if (shell && actions.isNotEmpty) Align(alignment: Alignment.centerRight, child: Row(mainAxisSize: MainAxisSize.min, children: actions)),
                ...children,
              ]),
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
