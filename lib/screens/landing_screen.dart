import 'package:flutter/material.dart';
import 'package:treasure_game_v4/screens/buy_game_pass.dart';
import '../components/index.dart';

class LandingScreen extends StatelessWidget {
  final VoidCallback onEnter;

  const LandingScreen({super.key, required this.onEnter});

  void _navigateToPurchase(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GamePassScreen(
          onClose: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LandingTitle(),
          const SizedBox(height: 48),
          LandingParchment(
            onEnter: onEnter,
            onPurchaseGamePass: () => _navigateToPurchase(context),
          ),
        ],
      ),
    );
  }
}
