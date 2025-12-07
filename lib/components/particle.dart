import 'package:flutter/material.dart';

class Particle extends StatelessWidget {
  final Color color;
  
  const Particle({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4, 
      height: 4,
      decoration: BoxDecoration(
        color: color, 
        shape: BoxShape.circle, 
        boxShadow: [BoxShadow(color: color, blurRadius: 4)]
      ),
    );
  }
}
