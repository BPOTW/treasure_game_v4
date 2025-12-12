import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'wood_button.dart';

class PermissionRequestWidget extends StatefulWidget {
  final VoidCallback onPermissionsGranted;

  const PermissionRequestWidget({
    super.key,
    required this.onPermissionsGranted,
  });

  @override
  State<PermissionRequestWidget> createState() =>
      _PermissionRequestWidgetState();
}

class _PermissionRequestWidgetState extends State<PermissionRequestWidget> {
  bool _requesting = false;

  Future<void> _requestPermissions() async {
    setState(() => _requesting = true);

    final camera = await Permission.camera.request();
    final location = await Permission.locationWhenInUse.request();

    final granted = camera.isGranted && location.isGranted;

    setState(() => _requesting = false);

    if (granted) {
      widget.onPermissionsGranted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Permissions Needed",
          style: GoogleFonts.imFellEnglish(
            color: const Color(0xFFE6D8C3),
            fontSize: 26,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 15),

        Text(
          "To continue, the game needs:\n"
          "• Camera access\n"
          "• Location access\n",
          style: GoogleFonts.imFellEnglish(
            color: const Color(0xFFF2E8D8),
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 30),

        WoodButton(
          label: _requesting ? "Requesting..." : "Grant Permissions",
          isActive: !_requesting,
          onTap: _requestPermissions,
        )
      ],
    );
  }
}
