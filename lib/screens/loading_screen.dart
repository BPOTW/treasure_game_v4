import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:treasure_game_v4/components/wood_button.dart';
import 'package:treasure_game_v4/components/permission_request_widget.dart';
import 'package:treasure_game_v4/utils/functions.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool _showAgreement = true;
  bool _showPermissionRequest = false;
  bool _showLoading = false;
  bool _checkingPrefs = true;

  @override
  void initState() {
    super.initState();
    _initFlow();
  }

  // ------------------------------------------------------
  // CHECK AGREEMENT + PERMISSIONS
  // ------------------------------------------------------
  Future<void> _initFlow() async {
    final prefs = await SharedPreferences.getInstance();
    final agreed = prefs.getBool("AGREEMENT_ACCEPTED") ?? false;

    if (!agreed) {
      // User must accept the agreement first
      setState(() {
        _showAgreement = true;
        _checkingPrefs = false;
      });
      return;
    }

    // Agreement accepted → check permissions
    await _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final camera = await Permission.camera.status;
    final location = await Permission.locationWhenInUse.status;

    if (camera.isGranted && location.isGranted) {
      setState(() {
        _showAgreement = false;
        _showPermissionRequest = false;
        _showLoading = true;
        _checkingPrefs = false;
      });
      initAppResources();
    } else {
      setState(() {
        _showAgreement = false;
        _showPermissionRequest = true;
        _showLoading = false;
        _checkingPrefs = false;
      });
    }
  }

  // ------------------------------------------------------
  // ACCEPT AGREEMENT
  // ------------------------------------------------------
  Future<void> _acceptAgreement() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("AGREEMENT_ACCEPTED", true);

    // After accepting → request permissions
    setState(() {
      _showAgreement = false;
      _showPermissionRequest = true;
    });
  }

  // ------------------------------------------------------
  // PERMISSIONS GRANTED → SHOW LOADING
  // ------------------------------------------------------
  void _onPermissionsGranted() {
    setState(() {
      _showPermissionRequest = false;
      _showLoading = true;
    });

    initAppResources();
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingPrefs) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        _background(),
        Center(
          child: _showAgreement
              ? _buildAgreement()
              : _showPermissionRequest
                  ? PermissionRequestWidget(
                      onPermissionsGranted: _onPermissionsGranted,
                    )
                  : _buildLoading(),
        ),
      ],
    );
  }

  // Background widget
  Widget _background() {
    return Stack(
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: 0.5,
            child: Image.asset(
              "assets/imgs/background1.png",
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.2),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------
  // AGREEMENT
  // ------------------------------------------------------
  Widget _buildAgreement() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Safety & Gameplay Agreement",
            style: GoogleFonts.imFellEnglish(
              fontSize: 26,
              color: const Color(0xFFE6D8C3),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            "• This game may access your location.\n"
            "• Stay aware of your surroundings.\n"
            "• We are not responsible for accidents or injuries.\n"
            "• All purchases are final.\n"
            "• Continue only if you agree.",
            style: GoogleFonts.imFellEnglish(
              color: const Color(0xFFF2E8D8),
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          WoodButton(
            label: "Continue",
            onTap: () => _acceptAgreement(),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------
  // LOADING
  // ------------------------------------------------------
  Widget _buildLoading() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Preparing Your Adventure...",
          style: GoogleFonts.imFellEnglish(
            fontSize: 24,
            color: const Color(0xFFE6D8C3),
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 25),
        const SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: Color(0xFFB08968),
          ),
        ),
      ],
    );
  }
}
