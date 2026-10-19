import 'package:flutter/material.dart';

import '../theme/kit_colors.dart';
import '../theme/tokens.dart';
import 'common.dart';

// ═══════════════════════════════════════════════════════════════════
// Dialogs génériques — équivalents du ModalService (alert, confirm, prompt,
// bottomConfirm, push / priority message), de ConfirmDialog et CrudDialog.
// Sur mobile, les formulaires s'ouvrent en feuille plein écran.
// ═══════════════════════════════════════════════════════════════════

Widget _dialogIcon(BuildContext context, IconData icon, KitTone tone) {
  final c = context.kc;
  return Container(
    width: 56,
    height: 56,
    decoration: BoxDecoration(shape: BoxShape.circle, color: tone.light(c)),
    child: Icon(icon, size: 28, color: tone.color(c)),
  );
}

/// `modal.alert(...)`
Future<void> showKitAlert(BuildContext context, {required String title, required String message, IconData icon = Icons.info_outline, KitTone tone = KitTone.info, String ok = 'Compris'}) {
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: _dialogIcon(ctx, icon, tone),
      title: Text(title, textAlign: TextAlign.center),
      content: Text(message, textAlign: TextAlign.center),
      actionsAlignment: MainAxisAlignment.center,
      actions: [FilledButton(onPressed: () => Navigator.pop(ctx), child: Text(ok))],
    ),
  );
}

/// `modal.confirm(...)` / `ConfirmDialogComponent` : renvoie true si confirmé.
Future<bool> showKitConfirm(
  BuildContext context, {
  required String title,
  required String message,
  String confirm = 'Confirmer',
  String cancel = 'Annuler',
  bool danger = false,
  IconData? icon,
  String? typeToConfirm,
}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => _ConfirmDialog(title: title, message: message, confirm: confirm, cancel: cancel, danger: danger, icon: icon, typeToConfirm: typeToConfirm),
  );
  return r ?? false;
}

class _ConfirmDialog extends StatefulWidget {
  const _ConfirmDialog({required this.title, required this.message, required this.confirm, required this.cancel, required this.danger, this.icon, this.typeToConfirm});
  final String title, message, confirm, cancel;
  final bool danger;
  final IconData? icon;
  final String? typeToConfirm;

  @override
  State<_ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<_ConfirmDialog> {
  String _typed = '';

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final ok = widget.typeToConfirm == null || _typed.trim() == widget.typeToConfirm;
    return AlertDialog(
      icon: _dialogIcon(context, widget.icon ?? (widget.danger ? Icons.delete_forever : Icons.help_outline), widget.danger ? KitTone.error : KitTone.primary),
      title: Text(widget.title, textAlign: TextAlign.center),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(widget.message, textAlign: TextAlign.center, style: TextStyle(color: c.textSecondary)),
        if (widget.typeToConfirm != null) ...[
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(text: 'Saisissez ', children: [
              TextSpan(text: widget.typeToConfirm, style: const TextStyle(fontWeight: FontWeight.w700, fontFamily: Fonts.mono)),
              const TextSpan(text: ' pour confirmer'),
            ]),
            style: TextStyle(fontSize: 12.5, color: c.textSecondary),
          ),
          const SizedBox(height: 8),
          TextField(autofocus: true, onChanged: (v) => setState(() => _typed = v)),
        ],
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(widget.cancel)),
        FilledButton(
          style: widget.danger ? FilledButton.styleFrom(backgroundColor: c.error, foregroundColor: Theme.of(context).colorScheme.onError) : null,
          onPressed: ok ? () => Navigator.pop(context, true) : null,
          child: Text(widget.confirm),
        ),
      ],
    );
  }
}

/// `modal.prompt(...)` : saisie texte.
Future<String?> showKitPrompt(BuildContext context, {required String title, String? message, String? initial, String hint = '', String ok = 'Valider'}) {
  final ctrl = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (message != null) ...[Text(message), const SizedBox(height: 12)],
        TextField(controller: ctrl, autofocus: true, decoration: InputDecoration(hintText: hint)),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
        FilledButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: Text(ok)),
      ],
    ),
  );
}

/// `modal.bottomConfirm(...)` : confirmation en feuille basse (idéal au pouce).
Future<bool> showBottomConfirm(BuildContext context, {required String title, required String message, String confirm = 'Confirmer', bool danger = false, IconData icon = Icons.help_outline}) async {
  final r = await showModalBottomSheet<bool>(
    context: context,
    builder: (ctx) {
      final c = ctx.kc;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Center(child: _dialogIcon(ctx, icon, danger ? KitTone.error : KitTone.primary)),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: TextStyle(fontFamily: Fonts.heading, fontSize: 19, fontWeight: FontWeight.w600, color: c.textPrimary)),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: c.textSecondary)),
            const SizedBox(height: 20),
            FilledButton(
              style: danger ? FilledButton.styleFrom(backgroundColor: c.error) : null,
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(confirm),
            ),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ]),
        ),
      );
    },
  );
  return r ?? false;
}

/// Message poussé (`showPushMessage`) : annonce avec illustration.
Future<void> showPushMessage(BuildContext context, {required String title, required String message, String cta = 'Découvrir', IconData icon = Icons.campaign}) {
  return showDialog(
    context: context,
    builder: (ctx) {
      final c = ctx.kc;
      return Dialog(
        clipBehavior: Clip.antiAlias,
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            height: 120,
            decoration: BoxDecoration(gradient: LinearGradient(colors: [c.primary, c.info], begin: Alignment.topLeft, end: Alignment.bottomRight)),
            child: Icon(icon, size: 56, color: Colors.white),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Column(children: [
              const StatusBadge('Nouveau', tone: KitTone.primary),
              const SizedBox(height: 10),
              Text(title, textAlign: TextAlign.center, style: TextStyle(fontFamily: Fonts.heading, fontSize: 20, fontWeight: FontWeight.w700, color: c.textPrimary)),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center, style: TextStyle(color: c.textSecondary, height: 1.5)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(children: [
              Expanded(child: TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Plus tard'))),
              Expanded(child: FilledButton(onPressed: () => Navigator.pop(ctx), child: Text(cta))),
            ]),
          ),
        ]),
      );
    },
  );
}

/// Message prioritaire (`showPriorityMessage`) : bloquant, case « J'ai lu ».
Future<void> showPriorityMessage(BuildContext context, {required String title, required String message}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      var read = false;
      return StatefulBuilder(builder: (ctx, set) {
        final c = ctx.kc;
        return AlertDialog(
          icon: _dialogIcon(ctx, Icons.priority_high, KitTone.error),
          title: Text(title, textAlign: TextAlign.center),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: c.errorLight, borderRadius: Radii.rm),
              child: Text(message, style: TextStyle(color: c.errorText, height: 1.5)),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: read,
              onChanged: (v) => set(() => read = v!),
              title: const Text('J’ai lu et compris ce message'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ]),
          actions: [FilledButton(onPressed: read ? () => Navigator.pop(ctx) : null, child: const Text('Continuer'))],
        );
      });
    },
  );
}

/// Modes du formulaire en modale (`CrudDialogConfig.mode`).
enum CrudMode { create, edit, view }

/// Formulaire en feuille plein écran (`CrudDialogComponent` adapté au mobile) :
/// en-tête titré, contenu défilant, barre d'actions collée en bas.
Future<T?> showFormSheet<T>(
  BuildContext context, {
  required String title,
  String? subtitle,
  IconData icon = Icons.edit_note,
  required Widget Function(BuildContext context, StateSetter setState) builder,
  String submitLabel = 'Enregistrer',
  bool readOnly = false,
  T? Function()? onSubmit,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: false,
    builder: (ctx) {
      final c = ctx.kc;
      return StatefulBuilder(builder: (ctx, setState) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * 0.92),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 8, 12),
                child: Row(children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: c.primaryLight),
                    child: Icon(icon, size: 20, color: c.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(title, style: TextStyle(fontFamily: Fonts.heading, fontSize: 18, fontWeight: FontWeight.w600, color: c.textPrimary)),
                      if (subtitle != null) Text(subtitle, style: TextStyle(fontSize: 12.5, color: c.textSecondary)),
                    ]),
                  ),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                ]),
              ),
              const Divider(),
              Flexible(
                child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: builder(ctx, setState)),
              ),
              const Divider(),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: Row(children: [
                    Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: Text(readOnly ? 'Fermer' : 'Annuler'))),
                    if (!readOnly) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            final r = onSubmit?.call();
                            if (onSubmit == null || r != null) Navigator.pop(ctx, r);
                          },
                          child: Text(submitLabel),
                        ),
                      ),
                    ],
                  ]),
                ),
              ),
            ]),
          ),
        );
      });
    },
  );
}

/// Drawer latéral droit (panneau 360 px du shell) — sur téléphone : feuille plein écran.
Future<void> showSidePanel(BuildContext context, {required String title, required Widget child, IconData icon = Icons.view_sidebar}) {
  final wide = MediaQuery.sizeOf(context).width >= Breakpoints.tablet;
  Widget panel(BuildContext ctx) {
    final c = ctx.kc;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 8, 8),
        child: Row(children: [
          Icon(icon, color: c.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: TextStyle(fontFamily: Fonts.heading, fontSize: 18, fontWeight: FontWeight.w600, color: c.textPrimary))),
          IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
        ]),
      ),
      const Divider(),
      Expanded(child: child),
    ]);
  }

  if (!wide) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      builder: (ctx) => SizedBox(height: MediaQuery.sizeOf(ctx).height * 0.85, child: panel(ctx)),
    );
  }
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: title,
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (ctx, _, _) => Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Theme.of(ctx).colorScheme.surfaceContainerLow,
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(Radii.l)),
        child: SafeArea(child: SizedBox(width: 360, child: panel(ctx))),
      ),
    ),
    transitionBuilder: (ctx, a, _, child) => SlideTransition(
      position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
      child: child,
    ),
  );
}
