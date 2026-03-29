import 'dart:math';
import 'package:flutter/material.dart';

class ChatBackground extends StatelessWidget {
  final Widget child;
  const ChatBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _DoodlePainter(isDark: isDark),
          ),
        ),
        child,
      ],
    );
  }
}

class _DoodlePainter extends CustomPainter {
  final bool isDark;
  _DoodlePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark
          ? Colors.white.withAlpha(13)
          : Colors.black.withAlpha(10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = isDark
          ? Colors.white.withAlpha(8)
          : Colors.black.withAlpha(6)
      ..style = PaintingStyle.fill;

    final rng = Random(42); // Fixed seed for consistent pattern
    final iconSize = 18.0;
    final spacingX = 52.0;
    final spacingY = 52.0;

    final cols = (size.width / spacingX).ceil() + 1;
    final rows = (size.height / spacingY).ceil() + 1;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final offsetX = col * spacingX + (row.isOdd ? spacingX * 0.5 : 0);
        final offsetY = row * spacingY;

        // Random jitter
        final jx = offsetX + rng.nextDouble() * 12 - 6;
        final jy = offsetY + rng.nextDouble() * 12 - 6;

        if (jx > size.width + iconSize || jy > size.height + iconSize) continue;

        final iconIndex = rng.nextInt(20);
        final rotation = rng.nextDouble() * 0.4 - 0.2;

        canvas.save();
        canvas.translate(jx, jy);
        canvas.rotate(rotation);

        switch (iconIndex) {
          case 0: _drawStar(canvas, paint, iconSize);
          case 1: _drawChat(canvas, paint, iconSize);
          case 2: _drawHeart(canvas, paint, iconSize);
          case 3: _drawCircle(canvas, paint, iconSize);
          case 4: _drawLightning(canvas, paint, iconSize);
          case 5: _drawCode(canvas, paint, iconSize);
          case 6: _drawSmile(canvas, paint, iconSize);
          case 7: _drawDots(canvas, fillPaint, iconSize);
          case 8: _drawSparkle(canvas, paint, iconSize);
          case 9: _drawSquare(canvas, paint, iconSize);
          case 10: _drawMoon(canvas, paint, iconSize);
          case 11: _drawCloud(canvas, paint, iconSize);
          case 12: _drawTriangle(canvas, paint, iconSize);
          case 13: _drawWave(canvas, paint, iconSize);
          case 14: _drawDiamond(canvas, paint, iconSize);
          case 15: _drawPlus(canvas, paint, iconSize);
          case 16: _drawMusicNote(canvas, paint, iconSize);
          case 17: _drawArrow(canvas, paint, iconSize);
          case 18: _drawEye(canvas, paint, iconSize);
          case 19: _drawBulb(canvas, paint, iconSize);
        }

        canvas.restore();
      }
    }
  }

  void _drawStar(Canvas canvas, Paint paint, double s) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 144 - 90) * pi / 180;
      final x = s / 2 + cos(angle) * s * 0.4;
      final y = s / 2 + sin(angle) * s * 0.4;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawChat(Canvas canvas, Paint paint, double s) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, s, s * 0.7),
        Radius.circular(s * 0.2),
      ),
      paint,
    );
    final tail = Path()
      ..moveTo(s * 0.2, s * 0.7)
      ..lineTo(s * 0.1, s * 0.95)
      ..lineTo(s * 0.45, s * 0.7);
    canvas.drawPath(tail, paint);
  }

  void _drawHeart(Canvas canvas, Paint paint, double s) {
    final path = Path()
      ..moveTo(s * 0.5, s * 0.85)
      ..cubicTo(s * 0.15, s * 0.55, -s * 0.05, s * 0.2, s * 0.5, s * 0.15)
      ..cubicTo(s * 1.05, s * 0.2, s * 0.85, s * 0.55, s * 0.5, s * 0.85);
    canvas.drawPath(path, paint);
  }

  void _drawCircle(Canvas canvas, Paint paint, double s) {
    canvas.drawCircle(Offset(s / 2, s / 2), s * 0.35, paint);
  }

  void _drawLightning(Canvas canvas, Paint paint, double s) {
    final path = Path()
      ..moveTo(s * 0.55, 0)
      ..lineTo(s * 0.25, s * 0.45)
      ..lineTo(s * 0.5, s * 0.45)
      ..lineTo(s * 0.35, s)
      ..lineTo(s * 0.75, s * 0.4)
      ..lineTo(s * 0.5, s * 0.4)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawCode(Canvas canvas, Paint paint, double s) {
    // < >
    final left = Path()
      ..moveTo(s * 0.35, s * 0.2)
      ..lineTo(s * 0.1, s * 0.5)
      ..lineTo(s * 0.35, s * 0.8);
    canvas.drawPath(left, paint);
    final right = Path()
      ..moveTo(s * 0.65, s * 0.2)
      ..lineTo(s * 0.9, s * 0.5)
      ..lineTo(s * 0.65, s * 0.8);
    canvas.drawPath(right, paint);
  }

  void _drawSmile(Canvas canvas, Paint paint, double s) {
    canvas.drawCircle(Offset(s / 2, s / 2), s * 0.4, paint);
    canvas.drawCircle(Offset(s * 0.35, s * 0.38), s * 0.04, paint);
    canvas.drawCircle(Offset(s * 0.65, s * 0.38), s * 0.04, paint);
    canvas.drawArc(
      Rect.fromCenter(center: Offset(s / 2, s * 0.52), width: s * 0.35, height: s * 0.25),
      0.1, pi * 0.8, false, paint,
    );
  }

  void _drawDots(Canvas canvas, Paint paint, double s) {
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(s * 0.2 + i * s * 0.3, s / 2),
        s * 0.06,
        paint,
      );
    }
  }

  void _drawSparkle(Canvas canvas, Paint paint, double s) {
    final cx = s / 2, cy = s / 2;
    final r = s * 0.4;
    for (int i = 0; i < 4; i++) {
      final angle = i * pi / 4;
      canvas.drawLine(
        Offset(cx + cos(angle) * r * 0.15, cy + sin(angle) * r * 0.15),
        Offset(cx + cos(angle) * r, cy + sin(angle) * r),
        paint,
      );
    }
  }

  void _drawSquare(Canvas canvas, Paint paint, double s) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.15, s * 0.15, s * 0.7, s * 0.7),
        Radius.circular(s * 0.1),
      ),
      paint,
    );
  }

  void _drawMoon(Canvas canvas, Paint paint, double s) {
    final path = Path()
      ..addArc(Rect.fromCircle(center: Offset(s / 2, s / 2), radius: s * 0.35), -pi / 2, pi * 1.5);
    final cutout = Path()
      ..addOval(Rect.fromCircle(center: Offset(s * 0.62, s * 0.38), radius: s * 0.25));
    final moon = Path.combine(PathOperation.difference, path, cutout);
    canvas.drawPath(moon, paint);
  }

  void _drawCloud(Canvas canvas, Paint paint, double s) {
    canvas.drawCircle(Offset(s * 0.3, s * 0.5), s * 0.2, paint);
    canvas.drawCircle(Offset(s * 0.5, s * 0.35), s * 0.22, paint);
    canvas.drawCircle(Offset(s * 0.7, s * 0.5), s * 0.2, paint);
  }

  void _drawTriangle(Canvas canvas, Paint paint, double s) {
    final path = Path()
      ..moveTo(s / 2, s * 0.1)
      ..lineTo(s * 0.85, s * 0.85)
      ..lineTo(s * 0.15, s * 0.85)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawWave(Canvas canvas, Paint paint, double s) {
    final path = Path()..moveTo(0, s / 2);
    for (double x = 0; x <= s; x += 1) {
      path.lineTo(x, s / 2 + sin(x / s * pi * 2) * s * 0.2);
    }
    canvas.drawPath(path, paint);
  }

  void _drawDiamond(Canvas canvas, Paint paint, double s) {
    final path = Path()
      ..moveTo(s / 2, s * 0.1)
      ..lineTo(s * 0.85, s / 2)
      ..lineTo(s / 2, s * 0.9)
      ..lineTo(s * 0.15, s / 2)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawPlus(Canvas canvas, Paint paint, double s) {
    canvas.drawLine(Offset(s / 2, s * 0.15), Offset(s / 2, s * 0.85), paint);
    canvas.drawLine(Offset(s * 0.15, s / 2), Offset(s * 0.85, s / 2), paint);
  }

  void _drawMusicNote(Canvas canvas, Paint paint, double s) {
    canvas.drawCircle(Offset(s * 0.3, s * 0.7), s * 0.12, paint);
    canvas.drawLine(Offset(s * 0.42, s * 0.7), Offset(s * 0.42, s * 0.15), paint);
    canvas.drawLine(Offset(s * 0.42, s * 0.15), Offset(s * 0.7, s * 0.25), paint);
  }

  void _drawArrow(Canvas canvas, Paint paint, double s) {
    canvas.drawLine(Offset(s * 0.15, s / 2), Offset(s * 0.85, s / 2), paint);
    canvas.drawLine(Offset(s * 0.6, s * 0.25), Offset(s * 0.85, s / 2), paint);
    canvas.drawLine(Offset(s * 0.6, s * 0.75), Offset(s * 0.85, s / 2), paint);
  }

  void _drawEye(Canvas canvas, Paint paint, double s) {
    canvas.drawOval(
      Rect.fromCenter(center: Offset(s / 2, s / 2), width: s * 0.8, height: s * 0.4),
      paint,
    );
    canvas.drawCircle(Offset(s / 2, s / 2), s * 0.1, paint);
  }

  void _drawBulb(Canvas canvas, Paint paint, double s) {
    canvas.drawCircle(Offset(s / 2, s * 0.35), s * 0.25, paint);
    canvas.drawLine(Offset(s * 0.38, s * 0.58), Offset(s * 0.38, s * 0.8), paint);
    canvas.drawLine(Offset(s * 0.62, s * 0.58), Offset(s * 0.62, s * 0.8), paint);
    canvas.drawLine(Offset(s * 0.35, s * 0.8), Offset(s * 0.65, s * 0.8), paint);
  }

  @override
  bool shouldRepaint(covariant _DoodlePainter oldDelegate) =>
      isDark != oldDelegate.isDark;
}
