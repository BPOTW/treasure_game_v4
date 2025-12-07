import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:treasure_game_v4/models/game_state.dart';

class GamePassInput extends StatefulWidget {
  final Function(String) enteredGamePass;

  const GamePassInput({super.key, required this.enteredGamePass});

  @override
  State<GamePassInput> createState() => _GamePassInputState();
}

class _GamePassInputState extends State<GamePassInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'ENTER YOUR GAME PASS',
            style: GoogleFonts.cinzelDecorative(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF5D4037),
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder(
          valueListenable: AppState.isLoggedIn,
          builder: (context, value, child) {
            if (AppState.isLoggedIn.value) {
              _controller.text = AppState.storedGamePass.value;
            }
            return TextField(
              controller: _controller,
              readOnly: value,
              onChanged: (value) => widget.enteredGamePass(value),
              textCapitalization: TextCapitalization.characters,
              autofillHints: null,
              onTapOutside: (event) {
                FocusScope.of(context).unfocus();
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.vpn_key, color: Color(0xFF8D6E63)),
                filled: true,
                fillColor: const Color(0xFFE6D5AC).withOpacity(0.5),
                border: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF8D6E63), width: 2),
                ),
                hintText: value ? AppState.storedGamePass.value : 'X-Y-Z-0-0-0',
                hintStyle: GoogleFonts.imFellEnglish(
                  color: const Color(0xFF8D6E63).withOpacity(0.5),
                  fontSize: 18,
                ),
              ),
              style: GoogleFonts.imFellEnglish(
                fontSize: 20,
                color: const Color(0xFF3E2723),
              ),
            );
          },
        ),
      ],
    );
  }
}
