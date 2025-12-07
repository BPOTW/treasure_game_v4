import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatMini extends StatelessWidget {
  final String label;
  final String value;
  final bool isDanger;

  const StatMini({super.key, 
    required this.label, 
    required this.value, 
    this.isDanger = false
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label, 
          style: GoogleFonts.cinzelDecorative(
            fontSize: 10, 
            color: const Color(0xFFE6D5AC).withOpacity(0.7)
          )
        ),
        Text(
          value, 
          style: GoogleFonts.imFellEnglish(
            fontSize: 18, 
            color: isDanger ? Colors.red.shade300 : const Color(0xFFE6D5AC)
          )
        ),
      ],
    );
  }
}
