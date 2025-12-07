import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/index.dart';

class GameScreen extends StatelessWidget {
  final VoidCallback onWin;

  const GameScreen({super.key, required this.onWin});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF3E2723),
            borderRadius: BorderRadius.circular(12),
            border: Border(
              bottom: const BorderSide(color: Color(0xFF251510), width: 4),
            ),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatMini(label: 'PLAYERS', value: '1,398'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C1810),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color.fromARGB(255, 230, 197, 52)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Color(0xFFB8860B), size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '10/10 SOLVED',
                      style: GoogleFonts.cinzelDecorative(
                        color: const Color(0xFFB8860B),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              StatMini(label: 'TIME LEFT', value: '45:20', isDanger: true),
            ],
          ),
        ),

        Expanded(
          child: Center(
            child: ParchmentContainer(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, size: 32, color: Color(0xFF3E2723)),
                  const SizedBox(height: 24),
                  Text(
                    '"I have a tongue but cannot speak,\nI have a lip but cannot eat.\nI have a bed but do not sleep,\nFound where the shadows are dark and deep."',
                    style: GoogleFonts.imFellEnglish(fontSize: 22, color: const Color(0xFF4E342E), fontStyle: FontStyle.italic, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Container(height: 4, width: 80, decoration: BoxDecoration(color: const Color(0xFF8D6E63).withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 16),
                  Text(
                    'SOLVE THE RIDDLE TO FIND THE LOCATION',
                    style: GoogleFonts.cinzelDecorative(fontSize: 10, color: const Color(0xFF8D6E63), fontWeight: FontWeight.bold, letterSpacing: 2),textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Scanner Medallion
        GestureDetector(
          onTap: onWin,
          child: Container(
            width: 90,
            height: 90,
            margin: const EdgeInsets.only(bottom: 30),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFB300), Color(0xFFB8860B)],
              ),
              border: Border.all(color: const Color(0xFF5D4037), width: 4),
              boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 5))],
            ),
            child: const Center(
              child: Icon(Icons.qr_code, size: 40, color: Color(0xFF3E2723)),
            ),
          ),
        ),
      ],
    );
  }
}
