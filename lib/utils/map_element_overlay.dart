import 'package:flutter/material.dart';

class MapElementOverlay extends StatelessWidget {
  const MapElementOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      right: 50,
      child: Opacity(
        opacity: 0.1,
        child: Transform.rotate(
          angle: 0.2,
          child: const Icon(Icons.explore, size: 300, color: Color(0xFF5D4037)),
        ),
      ),
    );
  }
}
