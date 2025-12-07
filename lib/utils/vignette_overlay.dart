import 'package:flutter/material.dart';

class VignetteOverlay extends StatelessWidget {
  const VignetteOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              Colors.transparent,
              const Color(0xFF2C1810).withValues(alpha: 0.4),
              const Color(0xFF140A05).withValues(alpha: 0.8),
            ],
            stops: const [0.1, 0.9, 1.0],
          ),
        ),
      ),
    );
  }
}
