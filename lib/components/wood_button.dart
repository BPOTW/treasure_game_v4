import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WoodButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const WoodButton({super.key, required this.label, required this.onTap, this.isActive = true});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF4A3B2A) : const Color.fromARGB(255, 156, 141, 124),
          border: Border.all(color: const Color(0xFF2C1810), width: 3),
          boxShadow: const [BoxShadow(color: Color(0xFF2C1810), offset: Offset(4, 4))],
          borderRadius: BorderRadius.circular(2),
        ),
        child: Center(
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.cinzelDecorative(
              color: const Color(0xFFF3E5AB),
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
