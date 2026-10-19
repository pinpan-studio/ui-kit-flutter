import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/kit_colors.dart';

enum SnackKind { neutral, success, error, info }

/// Snackbars du kit (`snackbar-success`, `snackbar-error`, `snackbar-info`) :
/// fond teinté à 22 % sur l'arrière-plan, texte dans la couleur de l'état.
void showKitSnack(
  BuildContext context,
  String message, {
  SnackKind kind = SnackKind.neutral,
  String? action,
  VoidCallback? onAction,
  Duration duration = const Duration(milliseconds: 2400),
}) {
  final c = context.kc;
  final (Color? tint, IconData? icon) = switch (kind) {
    SnackKind.success => (c.success, Icons.check_circle),
    SnackKind.error => (c.error, Icons.error),
    SnackKind.info => (c.info, Icons.info),
    SnackKind.neutral => (null, null),
  };
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      duration: duration,
      backgroundColor: tint == null ? null : Color.alphaBlend(tint.withValues(alpha: 0.22), c.bg),
      content: Row(
        children: [
          if (icon != null) ...[Icon(icon, color: tint, size: 20), const SizedBox(width: 10)],
          Expanded(
            child: Text(message, style: TextStyle(color: tint, fontWeight: tint == null ? null : FontWeight.w600)),
          ),
        ],
      ),
      action: action == null
          ? null
          : SnackBarAction(label: action, textColor: tint, onPressed: onAction ?? () {}),
    ),
  );
}

/// Copie dans le presse-papiers + confirmation.
Future<void> copyToClipboard(BuildContext context, String text, {String? label}) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (context.mounted) showKitSnack(context, label ?? '« $text » copié');
}

/// Action « métier » sans effet réel : on le signale (règle du kit statique).
void demoAction(BuildContext context, String what) =>
    showKitSnack(context, '$what (démo statique)', kind: SnackKind.info);
