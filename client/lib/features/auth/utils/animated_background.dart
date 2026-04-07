import 'dart:math' as math;

import 'package:client/features/auth/utils/theme.dart';
import 'package:flutter/material.dart';

class ParticlePainter extends CustomPainter {
  final double t;
  static final _rng = math.Random(42);
  static final _pts = List.generate(
    22,
    (_) => Offset(
      _rng.nextDouble(),
      _rng.nextDouble(),
    ),
  );

  ParticlePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = PromptaWelcomeTheme.accent.withValues(alpha: 0.07);
    for (int i = 0; i < _pts.length; i++) {
      final dx =
          _pts[i].dx * size.width + math.sin(t * 2 * math.pi + i * 0.7) * 18;
      final dy =
          _pts[i].dy * size.height + math.cos(t * 2 * math.pi + i * 0.5) * 14;
      final r = 1.5 + (i % 4) * 0.8;
      canvas.drawCircle(Offset(dx, dy), r, paint);
    }

    // Soft glow blob top-right
    final glowPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              PromptaWelcomeTheme.accent.withValues(
                alpha: 0.12 + math.sin(t * math.pi * 2) * 0.04,
              ),
              PromptaWelcomeTheme.accent.withValues(alpha: 0),
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.85, size.height * 0.08),
              radius: 220,
            ),
          );
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.08),
      220,
      glowPaint,
    );

    // Soft glow blob bottom-left
    final glowPaint2 = Paint()
      ..shader =
          RadialGradient(
            colors: [
              PromptaWelcomeTheme.accent.withValues(alpha: 0.07),
              PromptaWelcomeTheme.accent.withValues(alpha: 0),
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.1, size.height * 0.92),
              radius: 160,
            ),
          );
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.92),
      160,
      glowPaint2,
    );
  }

  @override
  bool shouldRepaint(ParticlePainter old) => old.t != t;
}