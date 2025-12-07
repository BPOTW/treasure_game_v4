import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatItem extends StatelessWidget {
  final IconData icon;
  final ValueListenable value;
  final ValueListenable label;
  final bool highlight;

  const StatItem({super.key, 
    required this.icon, 
    required this.value, 
    required this.label, 
    this.highlight = false
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon, 
          color: highlight 
            ? const Color(0xFFB8860B) 
            : const Color(0xFF5D4037).withOpacity(0.8)
        ),
        const SizedBox(height: 4),
        ValueListenableBuilder(
          valueListenable: value,
          builder: (context, value, child) {
            return Text(
              value.toString(), 
              style: GoogleFonts.imFellEnglish(
                fontSize: 24, 
                fontWeight: FontWeight.bold, 
                color: highlight ? const Color(0xFFB8860B) : const Color(0xFF5D4037)
              )
            );
          }
        ),
        ValueListenableBuilder(
          valueListenable: label,
          builder: (context, value, child) {
            return Text(
              value.toString(), 
              style: GoogleFonts.cinzelDecorative(
                fontSize: 10, 
                color: const Color(0xFF5D4037).withOpacity(0.7)
              )
            );
          }
        ),
      ],
    );
  }
}
