import 'dart:math' as math;
import 'package:flutter/material.dart';

class FinancialHealthGauge extends StatelessWidget {
  final int score;
  final String feedbackText;

  const FinancialHealthGauge({
    super.key,
    required this.score,
    required this.feedbackText,
  });

  Color _getScoreColor(int score) {
    if (score >= 80) return const Color(0xFF10B981); // Emerald Green
    if (score >= 50) return const Color(0xFFF59E0B); // Amber Yellow
    return const Color(0xFFEF4444); // Neon Red
  }

  @override
  Widget build(BuildContext context) {
    final scoreColor = _getScoreColor(score);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 185,
          height: 110,
          child: CustomPaint(
            painter: _GaugePainter(
              score: score,
              color: scoreColor,
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$score',
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'HEALTH INDEX',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white38,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          feedbackText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: scoreColor,
          ),
        ),
      ],
    );
  }
}

class _GaugePainter extends CustomPainter {
  final int score;
  final Color color;

  _GaugePainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 5);
    final radius = size.width / 2 - 10;

    final paintBase = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    // Draw the background arc from 180 degrees (left) to 0 degrees (right)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      paintBase,
    );

    final sweepAngle = (score / 100).clamp(0.0, 1.0) * math.pi;

    final paintProgress = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    // Draw active progress arc
    if (sweepAngle > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        math.pi,
        sweepAngle,
        false,
        paintProgress,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
