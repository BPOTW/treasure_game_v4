import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:treasure_game_v4/components/loading_box.dart';
import 'package:treasure_game_v4/components/noise_overlay.dart';
import 'package:treasure_game_v4/components/parchment_container.dart';
import 'package:treasure_game_v4/components/wood_button.dart';
import 'package:treasure_game_v4/models/game_state.dart';
import 'package:treasure_game_v4/utils/firebase_listner.dart';
import 'package:treasure_game_v4/utils/functions.dart';

// --- Game Pass Purchase Screen ---

class GamePassScreen extends StatefulWidget {
  final VoidCallback onClose;

  const GamePassScreen({super.key, required this.onClose});

  @override
  State<GamePassScreen> createState() => _GamePassScreenState();
}

class _GamePassScreenState extends State<GamePassScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Controllers to capture input
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _txIdController = TextEditingController();

  bool personalDetails = false;
  bool transactionId = false;

  @override
  void initState() {
    super.initState();
    // Listen to text changes to update validation state
    _nameController.addListener(_updateValidationState);
    _phoneController.addListener(_updateValidationState);
    _emailController.addListener(_updateValidationState);
    _txIdController.addListener(_updateValidationState);
  }

  void _updateValidationState() {
    setState(() {
      personalDetails =
          _nameController.text.isNotEmpty &&
          _phoneController.text.isNotEmpty &&
          _emailController.text.isNotEmpty;
      transactionId = _txIdController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _txIdController.dispose();
    super.dispose();
  }

  Future<bool> saveUserData() async {
    String gamePass = await generateGamePass();
    AppState.name.value = _nameController.text;
    AppState.phoneNo.value = _phoneController.text;
    AppState.email.value = _emailController.text;
    AppState.paymentId.value = _txIdController.text;
    AppState.isPaymentVerified.value = false;
    AppState.paymentStatus.value = "Not Verified";
    AppState.isGamePassEnable.value = false;
    AppState.totalRiddles.value = 0;
    AppState.completedRiddles.value = 0;
    AppState.currentRiddleIndex.value = 1;
    AppState.currentRiddle.value = "";
    AppState.hasWon.value = false;
    AppState.isGameLost.value = false;
    AppState.storedGamePass.value = gamePass;
    bool res = await FirestoreService.addUser();
    FirestoreListener.listenToUser(AppState.userId.value);
    res ? saveGamePassInStorage() : AppState.storedGamePass.value = "";
    return res;
  }

  void _nextStep() async {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
      setState(() => _currentStep++);
    } else {
      if (mounted) {
        showLoader(context);
      }
      await InternetUtils.isInternetAvailable(context);
      if (AppState.isConnectedToInternet.value) {
        bool res = await saveUserData();
        if (mounted) {
          hideLoader(context);
        }
        if (mounted && res) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF3E2723),
              content: Text(
                "Your payment will be verified soon...",
                style: GoogleFonts.cinzelDecorative(
                  color: const Color(0xFFE8DCC5),
                ),
              ),
            ),
          );
          Future.delayed(const Duration(seconds: 1), widget.onClose);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color(0xFF3E2723),
                content: Text(
                  "Something went wront. Try again",
                  style: GoogleFonts.cinzelDecorative(
                    color: const Color(0xFFE8DCC5),
                  ),
                ),
              ),
            );
          }
        }
      }

      hideLoader(context);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
      setState(() => _currentStep--);
    } else {
      widget.onClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8DCC5), // Base paper color
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Reuse Background Layers from MainScreen
          // 1. Noise
          const Positioned.fill(child: NoiseOverlay()),
          // 2. Vignette
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF2C1810).withOpacity(0.4),
                    const Color(0xFF140A05).withOpacity(0.8),
                  ],
                  stops: const [0.1, 0.9, 1.0],
                ),
              ),
            ),
          ),

          // 3. Back Button (Top Left)
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Color(0xFF5D4037),
                size: 30,
              ),
              onPressed: _prevStep,
            ),
          ),

          // 4. Main Content Area
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Header
                Text(
                  'Buy Game Pass',
                  style: GoogleFonts.medievalSharp(
                    fontSize: 36,
                    color: const Color(0xFF4E342E),
                  ),
                ),
                // Step Indicator
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      bool isActive = index == _currentStep;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: isActive ? 40 : 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFFB8860B)
                              : const Color(0xFF8D6E63).withOpacity(0.4),
                          borderRadius: BorderRadius.circular(6),
                          border: isActive
                              ? Border.all(color: const Color(0xFF3E2723))
                              : null,
                        ),
                      );
                    }),
                  ),
                ),

                // Page View
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics:
                        const NeverScrollableScrollPhysics(), // Prevent swipe, force buttons
                    children: [
                      _buildStep1Personal(),
                      _buildStep2Payment(),
                      _buildStep3Verification(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Step 1: Personal Details ---
  Widget _buildStep1Personal() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ParchmentContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                'PLAYER REGISTRATION',
                style: GoogleFonts.cinzelDecorative(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: const Color(0xFF5D4037),
                ),
              ),
            ),
            const Divider(color: Color(0xFF8D6E63), thickness: 1, height: 30),

            _ThemedTextField(
              label: 'Full Name',
              hint: 'Sir Explorer...',
              controller: _nameController,
              icon: Icons.person,
            ),
            const SizedBox(height: 20),
            _ThemedTextField(
              label: 'Email',
              hint: 'scrolls@kingdom.com',
              controller: _emailController,
              icon: Icons.email,
            ),
            const SizedBox(height: 20),
            _ThemedTextField(
              label: 'Phone',
              hint: '03 123 456 789',
              controller: _phoneController,
              icon: Icons.phone,
            ),

            const SizedBox(height: 40),
            WoodButton(
              label: 'Proceed to Pay',
              isActive: personalDetails,
              onTap: personalDetails ? _nextStep : () {},
            ),
          ],
        ),
      ),
    );
  }

  // --- Step 2: Account Details ---
  Widget _buildStep2Payment() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ParchmentContainer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.account_balance,
              size: 40,
              color: Color(0xFF3E2723),
            ),
            const SizedBox(height: 16),
            Text(
              'THE ROYAL TREASURY',
              style: GoogleFonts.cinzelDecorative(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                color: const Color(0xFF3E2723),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Send Rs.50 to the following bank account to proceed further:',
              textAlign: TextAlign.center,
              style: GoogleFonts.imFellEnglish(
                fontSize: 18,
                color: const Color(0xFF5D4037),
              ),
            ),

            const SizedBox(height: 24),

            // Bank Card / Scroll
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF5D4037),
                  width: 2,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(4),
                color: const Color(0xFFE6D5AC).withOpacity(0.3),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PaymentRow(label: 'Bank Name', value: 'Jazz Cash'),
                  const Divider(color: Color(0xFF8D6E63)),
                  _PaymentRow(label: 'Account Name', value: 'M. Zain Ali.'),
                  const Divider(color: Color(0xFF8D6E63)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account Number',
                            style: GoogleFonts.cinzelDecorative(
                              fontSize: 10,
                              color: const Color(0xFF8D6E63),
                            ),
                          ),
                          Text(
                            '03-208-362-440',
                            style: GoogleFonts.imFellEnglish(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF3E2723),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(
                            const ClipboardData(text: '03-208-362-440'),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Account copied!")),
                          );
                        },
                        icon: const Icon(Icons.copy, color: Color(0xFF8D6E63)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
            WoodButton(label: 'I Have Sent The Payment', onTap: _nextStep),
          ],
        ),
      ),
    );
  }

  // --- Step 3: Verification ---
  Widget _buildStep3Verification() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          ParchmentContainer(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_user,
                  size: 40,
                  color: Color(0xFF3E2723),
                ),
                const SizedBox(height: 16),
                Text(
                  'PROOF OF PAYMENT',
                  style: GoogleFonts.cinzelDecorative(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    color: const Color(0xFF5D4037),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Enter the Transaction ID provided on the recipt to verify the Payment.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.imFellEnglish(
                    fontSize: 18,
                    color: const Color(0xFF5D4037),
                  ),
                ),

                const SizedBox(height: 32),

                TextField(
                  controller: _txIdController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFFFFFFF).withOpacity(0.3),
                    hintText: 'TRX-0000-0000',
                    hintStyle: GoogleFonts.cinzelDecorative(
                      color: const Color(0xFF8D6E63).withOpacity(0.5),
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xFF5D4037),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xFFB8860B),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: GoogleFonts.imFellEnglish(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3E2723),
                  ),
                ),

                const SizedBox(height: 40),
                WoodButton(
                  label: 'Verify Payment',
                  isActive: transactionId,
                  onTap: transactionId ? _nextStep : () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Text(
            'The GAMEPASS will be activated after payment Verification which may take up to 48 hours.',
            style: GoogleFonts.imFellEnglish(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: const Color(0xFF5D4037).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Helper Components ---

class _ThemedTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;

  const _ThemedTextField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.cinzelDecorative(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF8D6E63),
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: icon == Icons.phone
              ? TextInputType.number
              : TextInputType.text,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            prefixIcon: Icon(icon, color: const Color(0xFF8D6E63), size: 20),
            hintText: hint,
            hintStyle: GoogleFonts.imFellEnglish(
              color: const Color(0xFF8D6E63).withOpacity(0.4),
              fontSize: 16,
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFD7CCC8)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF5D4037), width: 2),
            ),
          ),
          style: GoogleFonts.imFellEnglish(
            fontSize: 18,
            color: const Color(0xFF3E2723),
          ),
        ),
      ],
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final String label;
  final String value;

  const _PaymentRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.cinzelDecorative(
              fontSize: 12,
              color: const Color(0xFF8D6E63),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.imFellEnglish(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF3E2723),
            ),
          ),
        ],
      ),
    );
  }
}
