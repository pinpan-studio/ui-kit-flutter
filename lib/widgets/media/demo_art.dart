import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Scène illustrée générée localement (remplace les images / vidéos de démonstration
/// produites en canvas côté web). Déterministe selon `seed` ; `t` (0–1) anime la scène.
class DemoArt extends StatelessWidget {
  const DemoArt({super.key, required this.seed, this.t = 0, this.label, this.icon});
  final int seed;
  final double t;
  final String? label;
  final IconData? icon;

  static const palettes = [
    [Color(0xFF0EA5E9), Color(0xFF006A6A), Color(0xFFFDE68A)],
    [Color(0xFFF97316), Color(0xFF7C2D12), Color(0xFFFFEDD5)],
    [Color(0xFF8B5CF6), Color(0xFF1E1B4B), Color(0xFFF5D0FE)],
    [Color(0xFF22C55E), Color(0xFF14532D), Color(0xFFFEF9C3)],
    [Color(0xFFEF4444), Color(0xFF450A0A), Color(0xFFFECACA)],
    [Color(0xFF06B6D4), Color(0xFF083344), Color(0xFFCFFAFE)],
  ];

  @override
  Widget build(BuildContext context) {
    final p = palettes[seed % palettes.length];
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(painter: _ScenePainter(seed, t, p)),
        if (icon != null) Center(child: Icon(icon, size: 42, color: Colors.white.withValues(alpha: 0.9))),
        if (label != null)
          Positioned(
            left: 10,
            bottom: 8,
            child: Text(
              label!,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
              ),
            ),
          ),
      ],
    );
  }
}

class _ScenePainter extends CustomPainter {
  _ScenePainter(this.seed, this.t, this.p);
  final int seed;
  final double t;
  final List<Color> p;

  @override
  void paint(Canvas canvas, Size s) {
    final r = math.Random(seed);
    final sky = Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [p[0], Color.lerp(p[0], p[2], 0.6)!]).createShader(Offset.zero & s);
    canvas.drawRect(Offset.zero & s, sky);
    // Soleil.
    canvas.drawCircle(Offset(s.width * (0.2 + r.nextDouble() * 0.6), s.height * 0.28), s.shortestSide * 0.11, Paint()..color = p[2].withValues(alpha: 0.9));
    // Collines.
    for (var layer = 0; layer < 3; layer++) {
      final path = Path()..moveTo(0, s.height);
      final base = s.height * (0.55 + layer * 0.12);
      final amp = s.height * (0.08 + r.nextDouble() * 0.06);
      final phase = r.nextDouble() * math.pi * 2 + t * math.pi * 2 * (layer + 1) * 0.15;
      for (var x = 0.0; x <= s.width; x += 6) {
        path.lineTo(x, base - math.sin(x / s.width * math.pi * (1.5 + layer) + phase) * amp);
      }
      path
        ..lineTo(s.width, s.height)
        ..close();
      canvas.drawPath(path, Paint()..color = Color.lerp(p[1], p[0], 0.45 - layer * 0.2)!.withValues(alpha: 0.85 + layer * 0.05));
    }
    // Route + véhicule animé.
    final roadY = s.height * 0.86;
    canvas.drawRect(Rect.fromLTWH(0, roadY, s.width, s.height * 0.14), Paint()..color = const Color(0xFF1F2937));
    final dash = Paint()
      ..color = Colors.white70
      ..strokeWidth = 2;
    for (var x = -40 + (t * 80) % 40; x < s.width; x += 40) {
      canvas.drawLine(Offset(x, roadY + s.height * 0.07), Offset(x + 18, roadY + s.height * 0.07), dash);
    }
    final carX = (s.width + 60) * ((t + r.nextDouble()) % 1) - 40;
    final body = RRect.fromRectAndRadius(Rect.fromLTWH(carX, roadY - s.height * 0.07, s.width * 0.14, s.height * 0.07), const Radius.circular(4));
    canvas.drawRRect(body, Paint()..color = p[2]);
    canvas.drawCircle(Offset(carX + s.width * 0.03, roadY), s.height * 0.018, Paint()..color = Colors.black87);
    canvas.drawCircle(Offset(carX + s.width * 0.11, roadY), s.height * 0.018, Paint()..color = Colors.black87);
  }

  @override
  bool shouldRepaint(_ScenePainter old) => old.t != t || old.seed != seed;
}

/// Durée formatée m:ss.
String mmss(Duration d) => '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
