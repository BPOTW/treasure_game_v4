import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:treasure_game_v4/models/game_state.dart';
import '../components/index.dart';

class GameEndedScreen extends StatelessWidget {
  final VoidCallback onContinue;
  const GameEndedScreen({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Chest Placeholder
          const Icon(Icons.inventory_2, size: 120, color: Color(0xFF5D4037)),
          
          Text(
            'Note!',
            style: GoogleFonts.medievalSharp(
              fontSize: 42,
              color: const Color(0xFF3E2723),
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            'Game Has Ended',
            style: GoogleFonts.cinzelDecorative(
              fontSize: 18,
              color: const Color(0xFFB8860B),
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 40),
          
          ParchmentContainer(
            child: Column(
              children: [
                 Text(
                    "Too late — the treasure’s been claimed! \nVictor: ${(AppState.winnerName.value).toUpperCase()}. \nYour quest ends here… but hey, thanks for playing!",
                    style: GoogleFonts.imFellEnglish(fontSize: 18, color: const Color(0xFF4E342E)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Transform.rotate(
                      angle: -0.2,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red.shade900, width: 3),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          'OFFICIAL\nCOMPLETE',
                          style: GoogleFonts.cinzelDecorative(fontSize: 10, color: Colors.red.shade900, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          WoodButton(label: 'Continue', onTap: onContinue),
        ],
      ),
    );
  }
}
