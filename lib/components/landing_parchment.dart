import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:treasure_game_v4/components/loading_box.dart';
import 'package:treasure_game_v4/models/game_state.dart';
import 'package:treasure_game_v4/utils/functions.dart';
import 'parchment_container.dart';
import 'landing_stats.dart';
import 'game_pass_input.dart';
import 'wood_button.dart';
import 'purchase_game_pass_link.dart';

class LandingParchment extends StatelessWidget {
  final VoidCallback onEnter;
  final VoidCallback onPurchaseGamePass;

  const LandingParchment({
    super.key,
    required this.onEnter,
    required this.onPurchaseGamePass,
  });

  void enteredGamePass(String value) {
    AppState.storedGamePass.value = value;
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.02,
      child: ParchmentContainer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Stats Row
            const LandingStats(),
            const Divider(color: Color(0xFFD7CCC8), thickness: 2, height: 32),

            // Input
            GamePassInput(enteredGamePass: enteredGamePass),
            const SizedBox(height: 24),

            // Button
            WoodButton(
              label: 'Enter The Hunt',
              onTap: () => enterGame(onEnter, context),
            ),
            const SizedBox(height: 16),

            // Purchase Link
            PurchaseGamePassLink(
              onTap: () async {
                AudioService().playSoundEffect('sfx/button-tap.ogg');
                showLoader(context);
                await InternetUtils.isInternetAvailable(context);
                if (AppState.isConnectedToInternet.value) {
                  if (AppState.isBuyingEnable.value) {
                    hideLoader(context);
                    onPurchaseGamePass();

                  } else {
                    hideLoader(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF3E2723),
                        content: Text(
                          "Time has ended. Can't buy GamePass now.",
                          style: GoogleFonts.cinzelDecorative(
                            color: const Color(0xFFE8DCC5),
                          ),
                        ),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
