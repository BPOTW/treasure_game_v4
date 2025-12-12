import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Request both camera + location permissions
  static Future<bool> requestRequiredPermissions() async {
    // Request camera
    final cameraStatus = await Permission.camera.request();

    // Request location
    final locationStatus = await Permission.locationWhenInUse.request();

    bool allGranted =
        cameraStatus.isGranted && locationStatus.isGranted;

    return allGranted;
  }

  /// Check permission status without asking
  static Future<bool> arePermissionsGranted() async {
    final cam = await Permission.camera.status;
    final loc = await Permission.locationWhenInUse.status;

    return cam.isGranted && loc.isGranted;
  }
}
