import 'package:flutter/services.dart';

/// Retour haptique léger sur les bascules et sélections (interrupteurs, segments, onglets, mode sombre),
/// pendant de `hapticToggle` du kit React Native. Respecte le réglage « retour tactile » du système.
void kitHaptic() => HapticFeedback.selectionClick();

/// Enveloppe un `onChanged` pour qu'il déclenche [kitHaptic] avant l'action (`null` reste `null`).
ValueChanged<T>? withHaptic<T>(ValueChanged<T>? onChanged) => onChanged == null
    ? null
    : (v) {
        kitHaptic();
        onChanged(v);
      };
