import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PurchaseGamePassLink extends StatelessWidget {
  final VoidCallback onTap;

  const PurchaseGamePassLink({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        'Purchase a Game Pass',
        style: GoogleFonts.cinzelDecorative(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
          decorationStyle: TextDecorationStyle.dotted,
          color: const Color(0xFF5D4037),
        ),
      ),
    );
  }
}
