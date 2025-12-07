import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingTitle extends StatelessWidget {
  const LandingTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Treasure Hunt',
          style: GoogleFonts.medievalSharp(
            fontSize: 46,
            color: const Color(0xFF4E342E),
            shadows: [
              const Shadow(
                color: Colors.white38,
                offset: Offset(0, 2),
                blurRadius: 2,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        Container(
          height: 4,
          width: 120,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF8D6E63).withOpacity(0.6),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Text(
          'THE HUNT BEGINS',
          style: GoogleFonts.cinzelDecorative(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 3.0,
            color: const Color(0xFF5D4037),
          ),
        ),
      ],
    );
  }
}
