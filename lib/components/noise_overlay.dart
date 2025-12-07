import 'package:flutter/material.dart';
import 'dart:math' as math;

class NoiseOverlay extends StatelessWidget {
  const NoiseOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.05,
      child: CustomPaint(
        painter: _NoisePainter(),
      ),
    );
  }
}

class _NoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    final random = math.Random();
    for (int i = 0; i < 5000; i++) {
      canvas.drawCircle(
        Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
        1,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
